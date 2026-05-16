"""Relay: lê outbox Postgres e publica no Kafka com span outbox.publish."""

from __future__ import annotations

import asyncio
import json
import logging
import sys
from datetime import datetime, timezone

from aiokafka import AIOKafkaProducer
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app import config
from app.models import OutboxEvent
from app.telemetry import get_tracer, setup_telemetry

logging.basicConfig(
    level=logging.INFO,
    format='{"level":"%(levelname)s","message":"%(message)s"}',
)
logger = logging.getLogger(__name__)

setup_telemetry()
tracer = get_tracer()


def _async_url(url: str) -> str:
    if url.startswith("postgresql://"):
        return url.replace("postgresql://", "postgresql+asyncpg://", 1)
    if url.startswith("postgresql+psycopg://"):
        return url.replace("postgresql+psycopg://", "postgresql+asyncpg://", 1)
    return url


async def process_batch(
    session: AsyncSession,
    producer: AIOKafkaProducer,
) -> int:
    stmt = (
        select(OutboxEvent)
        .where(OutboxEvent.published_at.is_(None))
        .order_by(OutboxEvent.created_at)
        .limit(config.BATCH_SIZE)
        .with_for_update(skip_locked=True)
    )
    rows = (await session.execute(stmt)).scalars().all()
    if not rows:
        return 0

    now = datetime.now(timezone.utc)
    for row in rows:
        with tracer.start_as_current_span("outbox.publish") as span:
            span.set_attribute("outbox.event_id", str(row.id))
            span.set_attribute("outbox.event_type", row.event_type)
            await producer.send_and_wait(
                config.KAFKA_TOPIC,
                row.payload,
                key=row.aggregate_id.encode("utf-8"),
            )
            await session.execute(
                update(OutboxEvent)
                .where(OutboxEvent.id == row.id)
                .values(published_at=now)
            )
            logger.info("outbox published id=%s type=%s", row.id, row.event_type)

    await session.commit()
    return len(rows)


async def run() -> None:
    engine = create_async_engine(_async_url(config.DATABASE_URL))
    async with engine.begin() as conn:
        await conn.run_sync(OutboxEvent.metadata.create_all)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)

    producer = AIOKafkaProducer(
        bootstrap_servers=[h.strip() for h in config.KAFKA_BOOTSTRAP.split(",") if h.strip()],
        value_serializer=lambda v: json.dumps(v, default=str).encode("utf-8"),
    )
    await producer.start()
    logger.info("Relay iniciado — topic=%s", config.KAFKA_TOPIC)

    try:
        while True:
            async with session_factory() as session:
                try:
                    count = await process_batch(session, producer)
                except Exception:
                    await session.rollback()
                    raise
            if count == 0:
                await asyncio.sleep(config.POLL_INTERVAL_SEC)
    finally:
        await producer.stop()
        await engine.dispose()


def main() -> None:
    try:
        asyncio.run(run())
    except KeyboardInterrupt:
        logger.info("Relay encerrado")
        sys.exit(0)


if __name__ == "__main__":
    main()
