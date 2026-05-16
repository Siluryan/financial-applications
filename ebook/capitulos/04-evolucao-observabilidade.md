*Contexto histórico — leia antes do [Módulo 2](../../modulos/modulo-02-observabilidade.md).*

## Quando “está no ar” não basta

Nos anos 2000, monitoramento era **ping + CPU + disco**. Banco respondia 200 no load balancer — verde no painel. Microsserviços quebraram essa ilusão: o cliente vê erro intermitente enquanto cada caixa individual parece saudável.

Surge a distinção:

- **monitoramento** — alertas em métricas conhecidas;
- **observabilidade** — perguntas novas com **métricas, logs e traces** correlacionados.

O caso do livro: *Pix* aprovado, destinatário sem crédito — só um **trace** com `trace_id` único mostra onde a jornada parou.

## Três pilares (e a guerra dos fornecedores)

| Pilar | Ferramentas históricas | Pergunta |
|-------|------------------------|----------|
| **Métricas** | Nagios, Zabbix → **Prometheus** (2012) | Quantos? Quão rápido? |
| **Logs** | Splunk, ELK → **Loki** | O que esta requisição disse? |
| **Traces** | Dapper (Google) → Zipkin, **Jaeger** | Onde foi o tempo? |

**Prometheus** popularizou pull, labels e PromQL. **Grafana** virou painel neutro. **ELK** dominou busca em log textual; **Loki** empurrou indexação por label (mais barato em escala).

## Dapper e a genealogia do trace

O paper **Dapper** (Google, 2010) mostrou **trace distribuído** em produção. Ideia: propagar ID entre serviços; spans com pai/filho; amostragem para controlar custo.

**Zipkin** (Twitter) e **Jaeger** (Uber, ~2015) open-sourcaram o modelo. Devs passaram a esperar “ver a árvore” em incidentes — especialmente em pagamentos com SLA agressivo.

## A torre de Babel: OpenTracing vs OpenCensus

Cada APM (*Application Performance Monitoring*) tinha SDK próprio. Vendor lock-in, instrumentação duplicada.

- **OpenTracing** (CNCF) — API de tracing neutra.
- **OpenCensus** (Google) — métricas + traces, exportadores variados.

Em **2019**, fundiu-se **OpenTelemetry (OTel)** — um projeto para **instrumentar uma vez**, exportar para Jaeger, Prometheus, Datadog, etc.

## OpenTelemetry hoje

Componentes que você toca no lab:

| Peça | Função |
|------|--------|
| **API / SDK** | Instrumentar Python (FastAPI, httpx, Kafka manual) |
| **OTel Collector** | Receber OTLP, filtrar PII, encaminhar |
| **Exporters** | Jaeger, Prometheus, vendor cloud |

**W3C Trace Context** padronizou `traceparent` em HTTP — sem isso, o buraco entre *Pix* e worker persiste.

Conceitos operacionais do [Módulo 2](../../modulos/modulo-02-observabilidade.md):

- **sampling** — gravar fração dos traces;
- **cardinalidade** — não rotular métrica com `user_id` único;
- **exemplars** — ligar métrica ao trace no Grafana.

## SLO, SLI e error budget

Cultura **SRE** (Google, livro *Site Reliability Engineering*, 2016) popularizou:

- **SLI** — indicador medido;
- **SLO** — meta interna;
- **SLA** — contrato;
- **error budget** — quanto pode falhar antes de parar feature.

Em banco, SLO de *Pix* não é vanity metric — alimenta decisão de deploy (canary) e prioridade de incidente.

## Stack do lab vs produção

| Lab | Evolução típica em produção |
|-----|------------------------------|
| Jaeger | Tempo, Honeycomb, Datadog APM |
| Logs JSON no stdout | Loki + Grafana ou ELK |
| Collector simples | Pipelines com tail sampling, PII scrub |

`deploy/observability/` no repo mostra Collector — ponte mental para ambiente real.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2010 | Paper Dapper |
| 2012 | Prometheus (SoundCloud) |
| 2015 | Jaeger (Uber) |
| 2016 | Livro SRE; onda de SLO |
| 2019 | OpenTelemetry (fusão) |
| 2020+ | OTel GA; vendors adotam OTLP |
| 2020s | eBPF (Cilium, Pixie) como complemento |

## Ligação com o livro

- [Módulo 2](../../modulos/modulo-02-observabilidade.md)
- [Lab 02](../../labs/lab-02-opentelemetry-jaeger.md)
- [Lab 07f](../../labs/lab-07f-pii-observabilidade.md) — PII em telemetria

Próximo: [Módulo 2](../../modulos/modulo-02-observabilidade.md) · [Labs 02 e 02b](../../labs/lab-02-opentelemetry-jaeger.md).
