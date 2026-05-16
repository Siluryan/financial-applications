"""Postgres assíncrono (SQLAlchemy 2)."""

from __future__ import annotations

from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app import config
from app.models import Base

engine = None
SessionLocal: async_sessionmaker[AsyncSession] | None = None


def _async_url(url: str) -> str:
    if url.startswith("postgresql://"):
        return url.replace("postgresql://", "postgresql+asyncpg://", 1)
    if url.startswith("postgresql+psycopg://"):
        return url.replace("postgresql+psycopg://", "postgresql+asyncpg://", 1)
    return url


async def init_db() -> None:
    global engine, SessionLocal
    if not config.DATABASE_URL:
        return
    engine = create_async_engine(_async_url(config.DATABASE_URL), echo=False)
    SessionLocal = async_sessionmaker(engine, expire_on_commit=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def close_db() -> None:
    global engine
    if engine is not None:
        await engine.dispose()
        engine = None


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    if SessionLocal is None:
        raise RuntimeError("DATABASE_URL não configurado")
    async with SessionLocal() as session:
        yield session
