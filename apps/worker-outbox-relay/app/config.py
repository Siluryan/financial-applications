from __future__ import annotations

import os

DATABASE_URL = os.environ["DATABASE_URL"]
KAFKA_BOOTSTRAP = os.environ["KAFKA_BOOTSTRAP_SERVERS"]
KAFKA_TOPIC = os.environ.get("KAFKA_TOPIC_PIX_INICIADO", "pix.iniciado")
POLL_INTERVAL_SEC = float(os.environ.get("OUTBOX_POLL_INTERVAL_SEC", "1.0"))
BATCH_SIZE = int(os.environ.get("OUTBOX_BATCH_SIZE", "50"))

OTEL_EXPORTER_OTLP_ENDPOINT = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "").strip()
OTEL_SERVICE_NAME = os.environ.get("OTEL_SERVICE_NAME", "worker-outbox-relay")
