*Contexto histórico — complementa o [Módulo 4](../../modulos/modulo-04-consistencia.md) (dados e consistência).*

## Quando o dinheiro “duplicou” ou “sumiu”

Incidentes financeiros raramente são “bug de sintaxe”. São **modelo errado** de concorrência, fila ou idempotência.

### Knight Capital (2012) — software errado em produção

Deploy parcial deixou código legado ativo; negociação automática disparou em minutos; prejuízo de centenas de milhões de dólares. Lições transversais:

- deploy não é só Kubernetes — é **processo** (canary, GitOps, Módulo 5);
- falta de **observabilidade** em tempo real agrava (Módulo 2).

### Pagamentos duplicados (padrão recorrente)

Cliente clica duas vezes; gateway retenta; consumer Kafka processa duas vezes. Sem **Idempotency-Key** e dedup, o extrato mostra dois débitos. Lição central do lab 04 e do [Módulo 4](../../modulos/modulo-04-consistencia.md).

### Fila “at-least-once” sem consumer idempotente

Mensagem `pix.iniciado` republicada → notificação ou antifraude dispara duas vezes. Lição: **inbox/dedup** antes de efeito colateral.

### Condição de corrida em saldo

Dois débitos leem saldo 100 antes de qualquer escrita — ambos aprovam. Lição: lock otimista/pessimista **no caderno certo** (Postgres do serviço dono do saldo).

## Sagas na vida real

Reserva de hotel + pagamento + milhas: um passo falha, os outros **compensam** (estorno). Não existe `ROLLBACK` global entre empresas — só lançamentos reversos (**ledger**).

## O que ensaiar no lab

| Cenário | Ferramenta |
|---------|------------|
| Replay HTTP com mesma chave | `curl` + `Idempotency-Key` |
| Mensagem Kafka duplicada | Consumer com dedup |
| Corrida em saldo | `version` ou `FOR UPDATE` |

Próximo: [Módulo 4](../../modulos/modulo-04-consistencia.md) · [Lab 04](../../labs/lab-04-redis-postgres-idempotencia.md).
