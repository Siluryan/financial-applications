"""Retry (Tenacity) + circuit breaker (pybreaker) para chamadas a limites."""

from __future__ import annotations

import asyncio
import logging
from typing import Any

import httpx
import pybreaker
from tenacity import (
    retry,
    retry_if_exception,
    stop_after_attempt,
    wait_exponential_jitter,
)

from app import config

logger = logging.getLogger(__name__)


def _transient(exc: BaseException) -> bool:
    if isinstance(exc, httpx.HTTPStatusError):
        return exc.response.status_code in (502, 503, 504)
    return isinstance(exc, (httpx.TimeoutException, httpx.NetworkError, httpx.ConnectError))


class _BreakerLogListener(pybreaker.CircuitBreakerListener):
    def state_change(self, cb: pybreaker.CircuitBreaker, old_state: str, new_state: str) -> None:
        logger.info(
            "circuit_breaker_state dependency=servico-limites old=%s new=%s fails=%s",
            old_state,
            new_state,
            cb.fail_counter,
        )


limites_breaker = pybreaker.CircuitBreaker(
    fail_max=config.BREAKER_FAIL_MAX,
    reset_timeout=config.BREAKER_RESET_TIMEOUT,
    name="servico-limites",
    listeners=[_BreakerLogListener()],
)


@retry(
    stop=stop_after_attempt(config.RETRY_MAX_ATTEMPTS),
    wait=wait_exponential_jitter(initial=0.1, max=2.0),
    retry=retry_if_exception(_transient),
    reraise=True,
)
def _fetch_limits_sync(account_id: str) -> dict[str, Any]:
    with httpx.Client(
        base_url=config.LIMITES_URL,
        timeout=httpx.Timeout(config.HTTP_TIMEOUT),
    ) as client:
        response = client.get(f"/v1/limits/{account_id}")
        response.raise_for_status()
        return response.json()


def fetch_limits_resilient(account_id: str) -> dict[str, Any]:
    return limites_breaker.call(_fetch_limits_sync, account_id)


async def fetch_limits(account_id: str) -> dict[str, Any]:
    return await asyncio.to_thread(fetch_limits_resilient, account_id)
