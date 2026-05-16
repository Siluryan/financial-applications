"""Configuração via variáveis de ambiente."""

from __future__ import annotations

import os

LIMITES_URL = os.environ.get("LIMITES_URL", "http://127.0.0.1:8001").rstrip("/")
HTTP_TIMEOUT = float(os.environ.get("HTTP_TIMEOUT", "2.0"))
KAFKA_BOOTSTRAP = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "").strip()
KAFKA_TOPIC_PIX = os.environ.get("KAFKA_TOPIC_PIX_INICIADO", "pix.iniciado")

DATABASE_URL = os.environ.get("DATABASE_URL", "").strip()
REDIS_URL = os.environ.get("REDIS_URL", "").strip()

PIX_USE_OUTBOX = os.environ.get(
    "PIX_USE_OUTBOX",
    "true" if DATABASE_URL else "false",
).lower() in ("1", "true", "yes")
PIX_SYNC_KAFKA = os.environ.get("PIX_SYNC_KAFKA", "false").lower() in ("1", "true", "yes")

OTEL_EXPORTER_OTLP_ENDPOINT = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "").strip()
OTEL_SERVICE_NAME = os.environ.get("OTEL_SERVICE_NAME", "servico-pix")

BREAKER_FAIL_MAX = int(os.environ.get("BREAKER_FAIL_MAX", "5"))
BREAKER_RESET_TIMEOUT = int(os.environ.get("BREAKER_RESET_TIMEOUT", "30"))
RETRY_MAX_ATTEMPTS = int(os.environ.get("RETRY_MAX_ATTEMPTS", "3"))
