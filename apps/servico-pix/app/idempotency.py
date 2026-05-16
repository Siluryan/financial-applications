"""Idempotência: Redis (rápido) + Postgres (durável)."""

from __future__ import annotations

import json
import logging
from typing import Any

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app import config
from app.models import IdempotencyRecord

logger = logging.getLogger(__name__)

_REDIS_PREFIX = "idempotency:"
_REDIS_TTL = 86400


async def get_cached_response(
    session: AsyncSession | None,
    redis_client: Any | None,
    key: str,
) -> dict[str, Any] | None:
    if redis_client is not None:
        raw = await redis_client.get(f"{_REDIS_PREFIX}{key}")
        if raw:
            return json.loads(raw)

    if session is not None:
        row = await session.scalar(
            select(IdempotencyRecord).where(IdempotencyRecord.key == key)
        )
        if row is not None:
            return dict(row.response_body)
    return None


async def store_response(
    session: AsyncSession | None,
    redis_client: Any | None,
    key: str,
    body: dict[str, Any],
) -> None:
    if redis_client is not None:
        await redis_client.set(
            f"{_REDIS_PREFIX}{key}",
            json.dumps(body, default=str),
            ex=_REDIS_TTL,
        )

    if session is None:
        return

    record = IdempotencyRecord(key=key, response_body=body)
    session.add(record)
    try:
        await session.flush()
    except IntegrityError:
        await session.rollback()
        logger.info("idempotency race: key=%s reutilizada", key)


async def create_redis_client() -> Any | None:
    if not config.REDIS_URL:
        return None
    import redis.asyncio as redis

    client = redis.from_url(config.REDIS_URL, decode_responses=True)
    await client.ping()
    logger.info("Redis ligado para idempotência")
    return client
