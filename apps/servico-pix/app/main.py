"""servico-pix — limites resilientes, outbox Postgres, OpenTelemetry."""

from __future__ import annotations

import json
import logging
from contextlib import asynccontextmanager
from typing import Annotated, Any

from fastapi import FastAPI, Header, Request

from app import config
from app.database import close_db, init_db
from app.idempotency import create_redis_client
from app.idempotency import get_cached_response
from app.pix_service import PixRequest, process_pix
from app.telemetry import instrument_fastapi, setup_telemetry

logging.basicConfig(
    level=logging.INFO,
    format='{"level":"%(levelname)s","logger":"%(name)s","message":"%(message)s"}',
)
logger = logging.getLogger(__name__)

setup_telemetry()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    app.state.redis = await create_redis_client()
    app.state.kafka_producer = None

    if config.KAFKA_BOOTSTRAP and config.PIX_SYNC_KAFKA:
        from aiokafka import AIOKafkaProducer

        producer = AIOKafkaProducer(
            bootstrap_servers=[h.strip() for h in config.KAFKA_BOOTSTRAP.split(",") if h.strip()],
            value_serializer=lambda v: json.dumps(v, default=str).encode("utf-8"),
        )
        await producer.start()
        app.state.kafka_producer = producer
        logger.info("Kafka producer síncrono ligado (PIX_SYNC_KAFKA=true)")

    if config.DATABASE_URL and config.PIX_USE_OUTBOX:
        logger.info("Modo outbox ativo — eventos via worker-outbox-relay")

    yield

    if app.state.kafka_producer is not None:
        await app.state.kafka_producer.stop()
    if app.state.redis is not None:
        await app.state.redis.aclose()
    await close_db()


app = FastAPI(
    title="servico-pix",
    version="0.2.0",
    lifespan=lifespan,
    description="Pix com Tenacity, pybreaker, outbox, idempotência e OpenTelemetry.",
)
instrument_fastapi(app)


@app.get("/healthz")
async def healthz() -> dict[str, Any]:
    out: dict[str, Any] = {
        "status": "ok",
        "service": config.OTEL_SERVICE_NAME,
        "limites_url": config.LIMITES_URL,
        "outbox_mode": config.PIX_USE_OUTBOX and bool(config.DATABASE_URL),
        "sync_kafka": config.PIX_SYNC_KAFKA,
    }
    if config.KAFKA_BOOTSTRAP:
        out["kafka_bootstrap"] = config.KAFKA_BOOTSTRAP
        out["kafka_topic"] = config.KAFKA_TOPIC_PIX
    if config.DATABASE_URL:
        out["database"] = "configured"
    if config.REDIS_URL:
        out["redis"] = "configured"
    if config.OTEL_EXPORTER_OTLP_ENDPOINT:
        out["otel_endpoint"] = config.OTEL_EXPORTER_OTLP_ENDPOINT
    return out


@app.post("/v1/pix")
async def create_pix(
    request: Request,
    body: PixRequest,
    idempotency_key: Annotated[str | None, Header(alias="Idempotency-Key")] = None,
) -> dict[str, Any]:
    from app.database import SessionLocal

    redis_client = getattr(request.app.state, "redis", None)
    kafka_producer = getattr(request.app.state, "kafka_producer", None)

    if SessionLocal is None:
        return await process_pix(body, idempotency_key, None, redis_client, kafka_producer)

    if idempotency_key:
        async with SessionLocal() as read_session:
            cached = await get_cached_response(read_session, redis_client, idempotency_key)
            if cached is not None:
                cached = dict(cached)
                cached["idempotent_replay"] = True
                return cached

    async with SessionLocal() as session:
        return await process_pix(
            body,
            idempotency_key,
            session,
            redis_client,
            kafka_producer,
            skip_idempotency_read=True,
        )
