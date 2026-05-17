# Lab 02 — OpenTelemetry + Jaeger (“*Pix* perdido”)

[← Índice dos labs](README.md) · [Módulo 2](../modulos/modulo-02-observabilidade.md)

## Objetivo

Instrumentar *Pix* e *Limites* com OpenTelemetry, exportar spans via OTLP e visualizar no Jaeger **um único trace** que atravessa a chamada HTTP entre os dois serviços.

O cenário didático do Módulo 2 é o “*Pix* perdido”: o cliente vê aprovação, o destinatário não recebe crédito. Sem trace distribuído, cada equipa defende a sua camada. Com `trace_id` partilhado, você reconstrói a linha do tempo: quanto tempo ficou em *Limites*, se houve publicação Kafka, etc.

**Ao terminar**, deve distinguir log (linha sobre uma requisição) de trace (árvore de spans) e explicar por que a propagação W3C (`traceparent`) é obrigatória entre *Pix* e *Limites*.

**Tempo estimado:** 75–120 min (inclui exercícios de nível avançado).

## Antes de começar

### Conhecimento (este lab)

- **Log** regista eventos pontuais; **trace** liga vários passos com o mesmo `trace_id` ([Módulo 2](../modulos/modulo-02-observabilidade.md), [Fundamentos — OTel](../ebook/capitulos/fundamentos-opentelemetry.md)).
- Jaeger é introduzido aqui — não é pré-requisito conhecê-lo antes.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou `docker compose up` — *Pix* → *Limites* responde sem erro de rede.

### Ambiente

- Python 3.11+ (se for alterar código localmente).
- Com Compose: Jaeger em http://127.0.0.1:16686 sobe com `docker compose up`.
- Port-forward do *Pix* na 8000.

## Passos

### 1. Subir Jaeger (all-in-one com OTLP)

Para aprender rápido no laptop, um container Jaeger com receptor OTLP na 4317 basta. Em produção costuma haver Collector intermédio; o lab aceita export direto.

```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/all-in-one:1.57
```

UI: http://localhost:16686

**Nota:** se já usa `docker compose` do repositório, o serviço `jaeger` na rede Compose evita este passo — use `OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317` nos containers.

### 2. Onde está o código (referência do repositório)

A instrumentação **não** fica espalhada no handler do *Pix*. Cada serviço centraliza em `app/telemetry.py`; `main.py` chama `setup_telemetry()` antes de criar rotas e `instrument_fastapi(app)` depois.

| Serviço | Arquivo | Função |
|---------|---------|--------|
| *Pix* | `apps/servico-pix/app/telemetry.py` | `TracerProvider` + export OTLP; `HTTPXClientInstrumentor` propaga trace na chamada a *Limites* |
| *Limites* | `apps/servico-limites/app/telemetry.py` | Mesmo padrão (FastAPI) |
| *Pix* | `apps/servico-pix/app/main.py` | Ordem: telemetry → app → instrumentação |
| Relay outbox | `apps/worker-outbox-relay/app/telemetry.py` | Span `outbox.publish` (lab 07b) |

Dependências em `requirements.txt`. No lab você **ativa** export com variáveis de ambiente e **valida** no Jaeger — não precisa reescrever o bootstrap.

### 3. Ativar export OTLP

Defina nos Deployments ou no Compose e reinicie os processos:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317   # Compose: hostname jaeger
OTEL_SERVICE_NAME=servico-pix                    # ou servico-limites
```

Endpoints típicos:

- **Compose:** `http://jaeger:4317` ou `http://host.docker.internal:4317` se o Jaeger corre só no host.
- **kind:** `http://otel-collector.observability.svc.cluster.local:4317` — ver [`deploy/observability/README.md`](../deploy/observability/README.md).

Confirme `GET /healthz` do *Pix*: campo `otel_endpoint` preenchido indica que a app leu a variável.

Trecho de referência:

```python
# apps/servico-pix/app/telemetry.py (resumido)
def setup_telemetry() -> None:
    if not config.OTEL_EXPORTER_OTLP_ENDPOINT:
        return
    # TracerProvider + BatchSpanProcessor(OTLPSpanExporter(...))
    HTTPXClientInstrumentor().instrument()

def instrument_fastapi(app) -> None:
    FastAPIInstrumentor.instrument_app(app, excluded_urls="/healthz")
```

**Por que httpx instrumentado:** sem `HTTPXClientInstrumentor`, o *Pix* cria span da entrada HTTP mas **não** propaga `traceparent` ao chamar *Limites* — o Jaeger mostra dois traces isolados.

### 4. Span manual no *Pix*

Spans automáticos cobrem HTTP. Para atributos de negócio (`account_id`, `amount`), adicione span filho:

```python
tracer = trace.get_tracer(__name__)
with tracer.start_as_current_span("pix.initiate") as span:
    span.set_attribute("account_id", body.account_id)
    ...
```

Use atributos de baixa cardinalidade em métricas; `account_id` em span é aceitável no lab, mas evite CPF em claro (lab 07f).

### 5. Gerar tráfego

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-02-trace' \
  -d '{"account_id":"acc_demo","amount":5,"destination":"acc_dest_1"}' | jq .
```

Anote o `trace_id` se vier no corpo da resposta JSON.

### 6. Inspecionar no Jaeger

1. Abra a UI → Service `servico-pix` (ou o nome em `OTEL_SERVICE_NAME`).
2. **Find Traces** — escolha o trace mais recente.
3. Deve existir span filho da chamada HTTP a *limites* (nome depende da instrumentação httpx).
4. Clique no span filho e confirme o mesmo `trace_id` no span raiz.

**Critério de sucesso visual:** árvore com pelo menos dois níveis (*Pix* → *Limites*), não dois traces desconectados na lista.

### 7. Logs JSON com `trace_id`

Configure logging para incluir `trace_id` do span ativo (structlog ou filtro no `logging`). Assim, ao correlacionar log + Jaeger, você cola o ID do log no campo de busca do trace.

Para aprofundar instrumentação em Python, consulte a documentação oficial do OpenTelemetry.

## Deu certo quando

- [ ] Um `POST /v1/pix` gera trace com ≥ 2 serviços (ou ≥ 2 spans HTTP claros).
- [ ] O mesmo `trace_id` aparece nos logs JSON do *Pix* e, se configurado, do *Limites*.
- [ ] Você explica qual span ficaria vermelho se o consumer Kafka falhasse depois do HTTP (lab 02b / 07b).

## Exercícios avançados (nível SRE)

Os exercícios abaixo espelham a secção de nível avançado do [Módulo 2](../modulos/modulo-02-observabilidade.md); checklists adicionais estão no plano de estudo do repositório.

### A1 — RED vs USE

1. Liste 3 métricas **RED** do endpoint `POST /v1/pix`.
2. Liste 3 métricas **USE** da infra (CPU do pod, pool httpx, fila Uvicorn).
3. Escreva: “se só RED estiver verde e USE saturado, o que o cliente sente?”

**Evidência:** parágrafo no relatório do lab ou ficheiro `docs/observabilidade-red-use.md`.

### A2 — Exemplars (com Prometheus)

Com Prometheus + Grafana: exemplars no histograma de latência do *Pix* → clique do p99 ao trace no Jaeger. Sem stack, descreva o fluxo em texto.

### A3 — Cardinalidade explosiva

Documente o anti-pattern de label `account_id` num contador Prometheus e por que `account_id` pertence a log/span, não a métrica agregada.

### A4 — Sampling head vs tail

Estime volume com 100 % sampling; escreva regra de **tail sampling** para produção (erro, latência > 2 s). Compare com head 5 %.

O diagrama *m02-sampling-strategies* (neste capítulo) compara *head* e *tail sampling*.

### A5 — Correlation ID vs trace ID

Aceite `X-Correlation-ID` no gateway; logue `correlation_id` e `trace_id`. Compare busca por ticket de suporte vs árvore no Jaeger.

### A6 — Custo de tracing

Preencha tabela de requisições/min, spans/request, sampling %, retenção — conclusão com sampling alvo.

### A7 — Quebra de propagação (obrigatório)

Remova temporariamente propagação `traceparent` na chamada httpx; reproduza buraco no Jaeger; restaure e confirme trace contínuo.

O diagrama *m02-trace-propagation* mostra o percurso do cabeçalho `traceparent` entre HTTP e Kafka.

## Troubleshooting

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| Jaeger vazio | OTLP não chega | Porta 4317; endpoint; firewall |
| Só um serviço | httpx não instrumentado ou *Limites* sem OTLP | Ver passo 2–3 nos dois serviços |
| Trace quebrado | Headers `traceparent` sobrescritos | Não definir manualmente em cliente custom |
| Métricas OK, trace vazio | Sampling descartou | Aumentar sampling no lab |

## Próximo passo

[Lab 02b — Kafka consumer](lab-02b-kafka-consumer.md) · [Lab 03 — Istio mTLS](lab-03-istio-mtls.md)
