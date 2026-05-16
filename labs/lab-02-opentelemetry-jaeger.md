# Lab 02 — OpenTelemetry + Jaeger (“*Pix* perdido”)

[← Índice dos labs](README.md) · **Onda 3** · [Módulo 2](../modulos/modulo-02-observabilidade.md) · [`PLANO` §2.4](../PLANO_DE_ESTUDO.md#modulo-2)

## Objetivo

Instrumentar *Pix* e *Limites* com OpenTelemetry, exportar OTLP para um Collector e ver **um único `trace_id`** no Jaeger cobrindo HTTP entre os serviços.

## Antes de começar

### Conhecimento (este lab)

- **Log** = uma linha sobre uma requisição; **trace** = vários passos com o mesmo `trace_id` ([Módulo 2](../modulos/modulo-02-observabilidade.md)).
- Jaeger é introduzido aqui — não precisa conhecê-lo antes.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou `docker compose up` — *Pix* → *Limites* OK.

### Ambiente

- Python 3.11+ para instalar pacotes OTel no `servico-pix`.
- Com Compose: Jaeger em http://127.0.0.1:16686 (sobe com `docker compose up`).

## Passos

### 1. Subir Jaeger (all-in-one com OTLP)

No laptop (fora do cluster, para aprender rápido):

```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/all-in-one:1.57
```

UI: http://localhost:16686

### 2. Dependências Python (cada serviço)

Em `apps/servico-pix/requirements.txt` e `apps/servico-limites/requirements.txt`, adicione por exemplo:

```text
opentelemetry-api
opentelemetry-sdk
opentelemetry-exporter-otlp
opentelemetry-instrumentation-fastapi
opentelemetry-instrumentation-httpx
```

Rebuild das imagens / Compose após alterar código.

### 3. Bootstrap OTel no `main.py` (esboço)

Antes de criar o `FastAPI()`:

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor

provider = TracerProvider()
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://host.docker.internal:4317", insecure=True))
)
trace.set_tracer_provider(provider)
HTTPXClientInstrumentor().instrument()

app = FastAPI(...)
FastAPIInstrumentor.instrument_app(app)
```

Ajuste o endpoint:

- **Compose:** `http://jaeger:4317` (adicione serviço `jaeger` na rede do Compose) ou `host.docker.internal`.
- **kind:** `http://jaeger.observability.svc.cluster.local:4317` se Jaeger estiver no cluster.

### 4. Span manual no *Pix* (opcional)

```python
tracer = trace.get_tracer(__name__)
with tracer.start_as_current_span("pix.initiate") as span:
    span.set_attribute("account_id", body.account_id)
    ...
```

### 5. Gerar tráfego

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-02-trace' \
  -d '{"account_id":"acc_demo","amount":5,"destination":"acc_dest_1"}'
```

### 6. Inspecionar no Jaeger

1. Service: `servico-pix` (ou nome que configurou).
2. Encontre o trace; deve aparecer span filho para a chamada HTTP a *limites*.

### 7. Logs JSON com `trace_id`

Configure `structlog` ou logging para incluir `trace_id` do span ativo (consulte [documentação OTel Python](https://opentelemetry-python.readthedocs.io/)).

## Deu certo quando

- [ ] Um `POST /v1/pix` gera trace com ≥ 2 serviços (ou ≥ 2 spans HTTP claros).
- [ ] O mesmo ID aparece nos logs JSON do *Pix* e do *Limites*.
- [ ] Você consegue explicar qual span seria “vermelho” se o consumer Kafka falhar (próximo lab).

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Jaeger vazio | OTLP na porta 4317? Firewall? Endpoint correto no exporter? |
| só um serviço | Instrumentou httpx no *Pix*? *Limites* também exporta OTLP? |
| trace quebrado | Propagação W3C: não sobrescreva headers `traceparent` manualmente. |

## Próximo passo

[Lab 02b — Kafka consumer](lab-02b-kafka-consumer.md) · [Lab 03 — Istio mTLS](lab-03-istio-mtls.md)
