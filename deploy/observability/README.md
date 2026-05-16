# Observabilidade no cluster (Onda 3)

Stack alvo documentada no [Módulo 2](../../modulos/modulo-02-observabilidade.md):

```text
servico-pix / servico-limites  →  OTLP  →  OpenTelemetry Collector
                                              ├→ Jaeger ou Tempo (traces)
                                              ├→ Prometheus (métricas)
                                              └→ Loki (logs) → Grafana
```

## Docker Compose (já integrado)

O [`docker-compose.yml`](../../docker-compose.yml) na raiz sobe `jaeger` + `otel-collector` com [`collector-config.yaml`](collector-config.yaml).

Apps usam `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317`.

## kind

1. Namespace `observability` + apply deste diretório (Kustomize futuro) ou Helm Jaeger.
2. Service DNS: `otel-collector.observability.svc.cluster.local:4317`
3. Mesma variável nos Deployments de `servico-pix`, `servico-limites` e `worker-outbox-relay`.

## PII (lab 07f)

Adicione processor `attributes/redaction` no Collector antes de exportar traces com dados sensíveis.
