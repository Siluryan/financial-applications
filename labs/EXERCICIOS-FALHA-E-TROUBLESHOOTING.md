# Exercícios de falha e troubleshooting

Complemento ao [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md): cenários para praticar **depois** dos labs por onda. Cada exercício pede evidência (trace, métrica, log, política negada).

## Falhas de rede e resiliência (Onda 1)

| Cenário | O que fazer | Evidência esperada |
|---------|-------------|-------------------|
| **Retry storm** | *Toxiproxy* latency + retry sem jitter em 3 réplicas *Pix* | p99 explode; métrica de retry rate alta; recuperação lenta após remover toxic |
| **Thundering herd** | Reiniciar *Limites* com muitos clientes simultâneos | Pico de conexões; comparar com backoff+jitter |
| **Cascading timeout** | Timeout *Pix* > timeout gateway | 504 no cliente com spans curtos nos filhos |
| **DNS failure** | Service errado no `LIMITES_URL` | Falha rápida; breaker abre |

## Observabilidade (Onda 3)

| Cenário | Pergunta | Passos |
|---------|----------|--------|
| Trace com timeout, métricas “normais” | Onde está o tempo? | Abrir trace; ver span mais longo; correlacionar log por `trace_id`; checar saturação de thread pool |
| Lag alto, API rápida | Fila ou consumer? | `kafka-consumer-groups`; lag por partição; spans `kafka.publish` vs consumer |
| Cardinalidade explosiva | Custo de métricas | Listar labels de alta cardinalidade; propor agregação |

## Kafka (Onda 2)

| Cenário | Objetivo |
|---------|----------|
| **Rebalance storm** | Rolling deploy com consumer group; observar rebalance e lag |
| **Poison message** | Mensagem inválida → DLQ após N tentativas (lab 07b) |
| **Ordering** | Duas chaves na mesma partição vs chaves diferentes |

## Mesh e deploy (Ondas 4–6)

| Cenário | Objetivo |
|---------|----------|
| Plaintext após STRICT | Chamada deve falhar no Envoy |
| Canary com v2 quebrada | Erro só na fatia espelhada/mínima |
| Manifest sem `limits` | Kyverno nega (lab 07d) |

## Quando NÃO usar (reflexão escrita)

Para cada ferramenta, uma página respondendo:

1. **Kafka** — volume baixo, equipe sem ops de fila, necessidade de transação síncrona simples.
2. **Service mesh** — poucos serviços, latência ultra-sensível sem budget de sidecar.
3. **Saga** — fluxo curto com transação local suficiente.
4. **Canary** — tráfego insignificante ou sem métricas confiáveis.

## Estudos de caso (leitura)

- Netflix — resiliência e chaos
- Uber — tracing em escala
- Nubank / Mercado Livre — plataforma e eventos (posts públicos)
- Google SRE — error budgets e postmortem

Registre no caderno: qual problema cada caso ilustra e qual ferramenta do lab se aplica.
