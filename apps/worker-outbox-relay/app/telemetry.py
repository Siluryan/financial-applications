from __future__ import annotations

import logging

from app import config

logger = logging.getLogger(__name__)


def setup_telemetry() -> None:
    if not config.OTEL_EXPORTER_OTLP_ENDPOINT:
        return
    from opentelemetry import trace
    from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor

    resource = Resource.create({"service.name": config.OTEL_SERVICE_NAME})
    provider = TracerProvider(resource=resource)
    exporter = OTLPSpanExporter(endpoint=config.OTEL_EXPORTER_OTLP_ENDPOINT, insecure=True)
    provider.add_span_processor(BatchSpanProcessor(exporter))
    trace.set_tracer_provider(provider)
    logger.info("OTel relay: %s", config.OTEL_EXPORTER_OTLP_ENDPOINT)


def get_tracer():
    from opentelemetry import trace

    return trace.get_tracer(config.OTEL_SERVICE_NAME)
