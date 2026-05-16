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

## Exercícios avançados (nível SRE)

Referência: [Módulo 2 § avançado](../modulos/modulo-02-observabilidade.md) · [PLANO §2.6](../PLANO_DE_ESTUDO.md#modulo-2).

### A1 — RED vs USE

1. Liste 3 métricas **RED** do endpoint `POST /v1/pix`.
2. Liste 3 métricas **USE** da infra (CPU do pod, pool de conexões httpx, fila Uvicorn).
3. Escreva: “se só RED estiver verde e USE saturado, o que o cliente sente?”

**Evidência:** parágrafo no caderno ou `docs/observabilidade-red-use.md`.

### A2 — Exemplars (opcional com Prometheus)

Se tiver Prometheus + Grafana: habilite exemplars no histograma de latência do *Pix* e clique de um p99 até o trace no Jaeger. Sem Prometheus, descreva o fluxo em texto (métrica → `trace_id` → Jaeger).

### A3 — Cardinalidade explosiva

1. Adicione temporariamente label `account_id` num contador de teste (ou documente o anti-pattern).
2. Explique por que isso explodiria séries no Prometheus.
3. Remova a label; mantenha `account_id` só em **log** e **span attribute**.

### A4 — Sampling head vs tail

1. Configure **100 %** sampling (lab) e estime: `req/min × spans/request × 30 dias` = GB aproximados.
2. Escreva regra de **tail sampling** que você aplicaria em produção (ex.: erro, latência > 2s).
3. Compare com head 5 % — quando perderia o incidente raro?

Diagrama: [`m02-sampling-strategies.png`](../modulos/diagramas/m02-sampling-strategies.png).

### A5 — Correlation ID vs trace ID

1. No gateway ou *Pix*, aceite header `X-Correlation-ID` (ou gere UUID).
2. Inclua **ambos** no log JSON: `correlation_id` e `trace_id`.
3. Simule ticket de suporte: “ache tudo pelo correlation” vs “ache árvore pelo trace”.

### A6 — Custo de tracing

Preencha tabela:

| Variável | Seu valor estimado |
|----------|-------------------|
| Requisições/min | |
| Spans por *Pix* | |
| Sampling % | |
| Retenção (dias) | |
| Custo mensal aceitável (R$) | |

Conclusão: sampling alvo ___ %.

### A7 — Quebra de propagação (obrigatório)

Remova propagação `traceparent` na chamada httpx ou no publish Kafka; reproduza buraco no Jaeger; restaure e confirme trace contínuo.

Diagrama: [`m02-trace-propagation.png`](../modulos/diagramas/m02-trace-propagation.png).

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Jaeger vazio | OTLP na porta 4317? Firewall? Endpoint correto no exporter? |
| só um serviço | Instrumentou httpx no *Pix*? *Limites* também exporta OTLP? |
| trace quebrado | Propagação W3C: não sobrescreva headers `traceparent` manualmente. |
| Métricas OK, trace vazio | Sampling head descartou; verificar flags em `traceparent`. |

## Próximo passo

[Lab 02b — Kafka consumer](lab-02b-kafka-consumer.md) · [PLANO — nível avançado](../PLANO_DE_ESTUDO.md#nivel-avancado) · [Lab 03 — Istio mTLS](lab-03-istio-mtls.md)
