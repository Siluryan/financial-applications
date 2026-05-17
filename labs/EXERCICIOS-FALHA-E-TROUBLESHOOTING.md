# Exercícios de falha e troubleshooting

Complemento ao [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md) e aos **exercícios A\*** nos labs [02](lab-02-opentelemetry-jaeger.md), [02b](lab-02b-kafka-consumer.md) e [07g](lab-07g-sre-praticas.md). Cada exercício pede evidência (trace, métrica, log, política negada, postmortem).

**Checklist mestre:** [PLANO — nível avançado](../PLANO_DE_ESTUDO.md#nivel-avancado).

## Falhas de rede e resiliência (Onda 1)

| Cenário | O que fazer | Evidência esperada | Diagrama |
|---------|-------------|-------------------|----------|
| **Retry storm** | *Toxiproxy* latency + retry sem jitter em 3 réplicas *Pix* | p99 explode; retry rate alta; recuperação lenta | `m01-retry-storm.png` |
| **Thundering herd** | Reiniciar *Limites* com muitos clientes simultâneos | Pico de conexões; comparar com backoff+jitter | — |
| **Cascading timeout** | Timeout *Pix* > timeout gateway | 504 no cliente; spans filhos curtos | `m01-timeout-chain.png` |
| **DNS failure** | Service errado no `LIMITES_URL` | Falha rápida; breaker abre | `m01-circuit-breaker.png` |

## Observabilidade (Onda 3) — ver também Lab 02 A1–A7

| Cenário | Pergunta | Passos |
|---------|----------|--------|
| Trace com timeout, métricas “normais” | Onde está o tempo? | Trace → span mais longo → log por `trace_id` → pool/thread |
| Lag alto, API rápida | Fila ou consumer? | `kafka-consumer-groups`; spans `kafka.publish` vs consumer |
| Cardinalidade explosiva | Custo de métricas | Lab 02 A3; listar labels proibidos |
| Exemplar no p99 | Métrica → trace | Lab 02 A2; clicar exemplar no Grafana |
| Sampling perde incidente | Head vs tail | Lab 02 A4; regra tail para 5xx |
| Correlation vs trace | Suporte vs APM | Lab 02 A5; mesmo evento com ambos IDs |
| Custo de tracing | FinOps | Lab 02 A6; tabela spans × retenção |

## Kafka (Onda 2) — ver também Lab 02b A1–A6

| Cenário | Objetivo | Lab |
|---------|----------|-----|
| **ISR / acks** | Publish falha com réplica atrasada | 02b A1 |
| **Rebalance storm** | Lag durante rolling deploy | 02b A2 |
| **Consumer expulso** | `max.poll.interval` estourado | 02b A3 |
| **Ordering** | Mesma chave vs chaves diferentes | 02b A4 |
| **Compacted topic** | Último valor por chave | 02b A5 |
| **Poison message** | DLQ após N tentativas | 02b A6 + [07b](lab-07b-outbox-kafka.md) |
| **EOS real** | Outbox + idempotência vs broker EOS | [07b](lab-07b-outbox-kafka.md) §7 |

## Consistência (Onda 2)

| Cenário | Objetivo | Lab |
|---------|----------|-----|
| **Write skew** | Duas transações violam invariante global | [04](lab-04-redis-postgres-idempotencia.md) + módulo 4 |
| **Phantom read** | `SERIALIZABLE` vs `READ COMMITTED` | Leitura módulo 4 |
| **Saga compensação** | Estorno após falha em fidelidade | Desenho + `m04-saga-orchestration.png` |

## Mesh e deploy (Ondas 4–6)

| Cenário | Objetivo | Diagrama |
|---------|----------|----------|
| Plaintext após STRICT | Falha no Envoy | `m03-mtls-handshake.png` |
| Marketing bloqueado | 403 sem Python | `m03-auth-policy.png` |
| Canary com v2 quebrada | Erro na fatia mínima | `m05-canary.png` |
| Manifest sem `limits` | Kyverno nega | — |
| GitOps drift | Argo reconcilia | `m05-gitops.png` |

## SRE e operação (Módulo 7) — Lab 07g

| Cenário | Objetivo | Diagrama |
|---------|----------|----------|
| API 200 + lag 50k | IC + SME + scribe | `m07-incident-response.png` |
| SLO 99,9 % queimando | Burn rate 5 min + 6 h | `m07-burn-rate.png` |
| Alerta CPU 70 % | Classificar noisy vs página | 07g ex. 4 |
| Postmortem | Blameless + ações | `docs/postmortem-template.md` |

## Quando NÃO usar (reflexão escrita)

Para cada ferramenta, uma página respondendo:

1. **Kafka** — volume baixo, equipe sem ops de fila, necessidade de transação síncrona simples.
2. **Service mesh** — poucos serviços, latência ultra-sensível sem budget de sidecar ([módulo 3](../modulos/modulo-03-service-mesh.md)).
3. **Saga** — fluxo curto com transação local suficiente.
4. **Canary** — tráfico insignificante ou sem métricas confiáveis.
5. **Tracing 100 %** — sem budget de storage ([módulo 2](../modulos/modulo-02-observabilidade.md)).

## Estudos de caso (leitura)

- Netflix — resiliência e chaos
- Uber — tracing em escala
- Nubank / Mercado Livre — plataforma e eventos (posts públicos)
- Google SRE — error budgets e postmortem

Registre no relatório: qual problema cada caso ilustra e qual ferramenta do lab se aplica.
