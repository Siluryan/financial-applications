"""Lógica de negócio do Pix — limites, outbox, idempotência."""

from __future__ import annotations

import logging
import uuid
from typing import Any

import pybreaker
from pydantic import BaseModel, Field
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app import config
from app.idempotency import get_cached_response, store_response
from app.models import IdempotencyRecord, OutboxEvent, PixTransfer
from app.resilience import fetch_limits

logger = logging.getLogger(__name__)


class PixRequest(BaseModel):
    account_id: str = Field(min_length=1)
    amount: float = Field(gt=0, description="Valor em BRL")
    destination: str = Field(default="acc_dest_unknown", min_length=1)


async def process_pix(
    body: PixRequest,
    idempotency_key: str | None,
    session: AsyncSession | None,
    redis_client: Any | None,
    kafka_producer: Any | None,
    *,
    skip_idempotency_read: bool = False,
) -> dict[str, Any]:
    if not skip_idempotency_read and idempotency_key and (session is not None or redis_client is not None):
        cached = await get_cached_response(session, redis_client, idempotency_key)
        if cached is not None:
            cached = dict(cached)
            cached["idempotent_replay"] = True
            return cached

    try:
        lim = await fetch_limits(body.account_id)
    except pybreaker.CircuitBreakerError:
        return {
            "status": "rejected",
            "reason": "limites_unavailable",
            "circuit_breaker": "open",
            "idempotency_key": idempotency_key,
        }
    except Exception as exc:
        logger.warning("limites_call_failed", extra={"error": str(exc)})
        return {
            "status": "rejected",
            "reason": "limites_error",
            "detail": str(exc),
            "idempotency_key": idempotency_key,
        }

    remaining = float(lim["daily_remaining"])
    if body.amount > remaining:
        result = {
            "status": "rejected",
            "reason": "above_daily_limit",
            "limits": lim,
            "idempotency_key": idempotency_key,
        }
        await _persist_idempotency(session, redis_client, idempotency_key, result)
        return result

    transfer_id = uuid.uuid4()
    event_payload = {
        "event": "pix_iniciado",
        "transfer_id": str(transfer_id),
        "account_id": body.account_id,
        "amount": body.amount,
        "destination": body.destination,
        "idempotency_key": idempotency_key,
    }

    if session is not None and config.PIX_USE_OUTBOX:
        result = {
            "status": "approved",
            "transfer_id": str(transfer_id),
            "amount": body.amount,
            "destination": body.destination,
            "limits_snapshot": lim,
            "idempotency_key": idempotency_key,
            "kafka": "outbox_pending",
        }
        try:
            async with session.begin():
                session.add(
                    PixTransfer(
                        id=transfer_id,
                        account_id=body.account_id,
                        amount=body.amount,
                        destination=body.destination,
                        status="approved",
                        idempotency_key=idempotency_key,
                    )
                )
                session.add(
                    OutboxEvent(
                        aggregate_id=body.account_id,
                        event_type="pix.iniciado",
                        payload=event_payload,
                    )
                )
                if idempotency_key:
                    session.add(
                        IdempotencyRecord(key=idempotency_key, response_body=result)
                    )
        except IntegrityError:
            await session.rollback()
            if idempotency_key:
                replay = await get_cached_response(session, redis_client, idempotency_key)
                if replay:
                    replay = dict(replay)
                    replay["idempotent_replay"] = True
                    return replay
            raise
        if idempotency_key and redis_client is not None:
            await store_response(None, redis_client, idempotency_key, result)
        return result

    result = {
        "status": "approved",
        "transfer_id": str(transfer_id),
        "amount": body.amount,
        "destination": body.destination,
        "limits_snapshot": lim,
        "idempotency_key": idempotency_key,
    }

    if kafka_producer is not None and config.PIX_SYNC_KAFKA:
        kafka_status = await _publish_kafka_direct(kafka_producer, event_payload)
        result["kafka"] = kafka_status

    await _persist_idempotency(session, redis_client, idempotency_key, result)
    return result


async def _persist_idempotency(
    session: AsyncSession | None,
    redis_client: Any | None,
    key: str | None,
    body: dict[str, Any],
) -> None:
    if not key:
        return
    if session is not None:
        async with session.begin():
            await store_response(session, redis_client, key, body)
    elif redis_client is not None:
        await store_response(None, redis_client, key, body)


async def _publish_kafka_direct(producer: Any, payload: dict[str, Any]) -> str:
    try:
        await producer.send_and_wait(config.KAFKA_TOPIC_PIX, payload)
        return "published"
    except Exception as exc:
        logger.warning("Kafka publish falhou: %s", exc)
        return f"error:{exc!s}"
