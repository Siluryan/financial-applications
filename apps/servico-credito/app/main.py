"""servico-credito — stub para labs de canary / mirror (duas revisões via env SERVICE_VERSION)."""

from __future__ import annotations

import os
from typing import Any

from fastapi import FastAPI

SERVICE_VERSION = os.environ.get("SERVICE_VERSION", "v1")

app = FastAPI(
    title="servico-credito",
    version="0.1.0",
    description="Score fictício; use dois Deployments com SERVICE_VERSION diferente no Istio.",
)


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok", "service": "servico-credito", "version": SERVICE_VERSION}


@app.get("/v1/score")
def score(account_id: str) -> dict[str, Any]:
    score_val = 700 if SERVICE_VERSION == "v1" else 720
    return {"account_id": account_id, "score": score_val, "model": SERVICE_VERSION}
