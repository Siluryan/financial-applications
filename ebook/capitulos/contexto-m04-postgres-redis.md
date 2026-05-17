## PostgreSQL: o caderno que o banco ainda confia

**PostgreSQL** nasce da academia (POSTGRES, anos 1980) e virou referência para **ACID** open source. Bancos usam Oracle, Db2 e SQL Server há décadas; fintechs e novos núcleos adotaram Postgres pela maturidade, extensões (JSON, particionamento) e custo.

No lab, o *Pix* grava transferência e **outbox** na mesma transação — padrão possível porque há **um caderno confiável** no serviço. Entre *Pix* e *Limites* não há esse `BEGIN` único.

| Recurso Postgres | Uso no curso |
|------------------|--------------|
| Transação | *Pix* + linha outbox |
| `FOR UPDATE` | Lock pessimista (teoria) |
| Coluna `version` | Lock otimista |
| Unique em `idempotency_key` | Dedup durável |

## Redis: velocidade com outra regra de jogo

**Redis** (2009, Salvatore Sanfilippo) é estrutura em memória — cache, fila leve, lock distribuído. Não substitui ledger: dados podem **evaporar** se não houver persistência configurada (RDB/AOF).

No lab:

- **idempotência rápida** (`SET NX`) antes de bater no Postgres;
- TTL de chaves — “protocolo válido por 24 h”.

Redis funciona como o **post-it na parede**; Postgres, como o **livro contábil**.

## Por que os dois juntos

| Só Postgres | Só Redis |
|-------------|----------|
| Correto, mais lento em pico de replay | Rápido, risco se cair sem backup |
| Unique constraint aguenta duplicata | `SETNX` sozinho não basta em todo cenário |

Padrão maduro: Redis como **primeira linha**; Postgres como **verdade** e auditoria.

## Evolução no setor financeiro

| Década | Padrão |
|--------|--------|
| 1990s | Mainframe + DB único |
| 2000s | Oracle RAC, réplicas síncronas |
| 2010s | Sharding, read replicas, cache Redis |
| 2020s | Outbox + CDC para eventos; Cockroach/Yugabyte para alguns casos globais |

## Linha do tempo resumida

| Ano | Marco |
|-----|--------|
| 1996 | PostgreSQL open source |
| 2009 | Redis |
| 2010s | Patroni, operadores K8s para Postgres |
| 2020s | Outbox pattern mainstream em microsserviços |
