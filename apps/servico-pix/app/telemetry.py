"""OpenTelemetry — export OTLP para Collector (produção) ou desligado."""

from __future__ import annotations

import logging

from app import config

logger = logging.getLogger(__name__)


def setup_telemetry() -> None:
    if not config.OTEL_EXPORTER_OTLP_ENDPOINT:
        return

    from opentelemetry import trace
    from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor

    resource = Resource.create({"service.name": config.OTEL_SERVICE_NAME})
    provider = TracerProvider(resource=resource)
    exporter = OTLPSpanExporter(
        endpoint=config.OTEL_EXPORTER_OTLP_ENDPOINT,
        insecure=True,
    )
    provider.add_span_processor(BatchSpanProcessor(exporter))
    trace.set_tracer_provider(provider)
    HTTPXClientInstrumentor().instrument()
    logger.info(
        "OpenTelemetry ativo: service=%s endpoint=%s",
        config.OTEL_SERVICE_NAME,
        config.OTEL_EXPORTER_OTLP_ENDPOINT,
    )


def instrument_fastapi(app) -> None:
    if not config.OTEL_EXPORTER_OTLP_ENDPOINT:
        return
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

    FastAPIInstrumentor.instrument_app(app, excluded_urls="/healthz")
