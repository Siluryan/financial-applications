"""servico-limites — API mínima para laboratório (engenheiros de cloud focam em rede, mesh, etc.)."""

from __future__ import annotations

from fastapi import FastAPI
from pydantic import BaseModel, Field

from app.telemetry import instrument, setup_telemetry

setup_telemetry()

app = FastAPI(title="servico-limites", version="0.2.0", description="Consulta de limites diários (dados mock em memória).")
instrument(app)

# Conta demo para testes; qualquer outro account_id recebe o default generoso.
_MOCK_LIMITS: dict[str, dict[str, float | str]] = {
    "acc_demo": {
        "daily_remaining": 5000.0,
        "currency": "BRL",
        "limit_daily": 5000.0,
    },
}


class LimitResponse(BaseModel):
    account_id: str
    daily_remaining: float = Field(ge=0)
    currency: str
    limit_daily: float = Field(ge=0)


def _limits_for(account_id: str) -> dict[str, float | str]:
    base = _MOCK_LIMITS.get(
        account_id,
        {"daily_remaining": 5000.0, "currency": "BRL", "limit_daily": 5000.0},
    )
    return dict(base)


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok", "service": "servico-limites"}


@app.get("/v1/limits/{account_id}", response_model=LimitResponse)
def get_limits(account_id: str) -> LimitResponse:
    data = _limits_for(account_id)
    return LimitResponse(account_id=account_id, **data)  # type: ignore[arg-type]
