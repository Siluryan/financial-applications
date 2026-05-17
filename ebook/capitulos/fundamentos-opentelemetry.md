# Fundamentos — OpenTelemetry

Este bloco antecede o **Módulo 2** (observabilidade; laboratório com Jaeger). *Pix* e *Limites* devem responder HTTP antes de instrumentar *traces*.

## OpenTelemetry em uma página

**OpenTelemetry (OTel)** especifica como gerar e exportar **telemetria** (métricas, logs, traces). Não é um único produto: a mesma instrumentação alimenta Jaeger, Prometheus, Loki e outros backends.

| Conceito | Significado | No lab |
|----------|-------------|--------|
| **Trace** | Uma requisição de ponta a ponta (ex.: `POST /v1/pix`) | Árvore no Jaeger |
| **Span** | Etapa do trace (HTTP, DB, publish) | Filho de outro span |
| **trace_id** | Identificador comum a spans e logs | Campo no JSON do *Pix* |
| **Instrumentação** | Biblioteca que cria spans | FastAPI + httpx |
| **OTLP** | Protocolo de exportação | Porta `4317` |
| **Collector** | Recebe, filtra e encaminha | `deploy/observability` |
| **Backend** | Visualização | Jaeger UI `:16686` |

## Métricas, logs e traces

| Sinal | Pergunta operacional |
|-------|----------------------|
| Métricas | Quantos pedidos? Qual latência? Qual taxa de erro? |
| Logs | O que esta requisição registou? |
| Traces | Entre quais serviços foi o tempo? |

Os três sinais complementam-se; o lab 02 foca em **traces** e na correlação por `trace_id`.

## Propagação entre *Pix* e *Limites*

Com **httpx** instrumentado, o cabeçalho **W3C Trace Context** (`traceparent`) transporta o contexto até *Limites*. Sem propagação, o Jaeger mostra dois traces desligados — o lab 02 trata precisamente desse caso.

```text
Cliente → [span POST /v1/pix] servico-pix
              └── [span GET /v1/limits/...] servico-limites
```

## Ativar no ambiente

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317
OTEL_SERVICE_NAME=servico-pix
```

No repositório do curso, a instrumentação está em `apps/servico-pix/app/telemetry.py` (e equivalente em *Limites*).

No mesmo módulo, o capítulo seguinte neste bloco de fundamentos é [Apache Kafka](fundamentos-kafka.md); depois vêm contexto, teoria e os laboratórios 02 e 02b.
