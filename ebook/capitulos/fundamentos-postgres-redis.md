# Fundamentos — PostgreSQL e Redis

Este bloco antecede o **Módulo 4** (dados, idempotência e sagas). *Pix* em Compose ou cluster; para *outbox*, convém já ter lido [Apache Kafka](fundamentos-kafka.md).

## PostgreSQL

Banco **relacional** com transações **ACID** — os dados persistem após `COMMIT`.

| Conceito | No lab |
|----------|--------|
| **Tabela** | `pix_transfers`, `outbox`, `idempotency_records` |
| **Transação** | `async with session.begin():` — tudo ou nada |
| **PK / UNIQUE** | `IdempotencyRecord.key` — sem duplicata |
| **JSONB** | `payload` da outbox, `response_body` da idempotência |
| **Outbox** | Evento na **mesma** transação do *Pix*; relay publica no Kafka |

```sql
SELECT id, account_id, status FROM pix_transfers ORDER BY created_at DESC LIMIT 5;
SELECT id, event_type, published_at IS NULL AS pending FROM outbox ORDER BY created_at DESC LIMIT 5;
```

Modelos e serviço: `models.py`, `pix_service.py`, `idempotency.py`.

## Redis

Armazenamento **em memória** chave → valor, com **TTL**.

| Conceito | No lab |
|----------|--------|
| Chave `idempotency:{uuid}` | Resposta em cache |
| TTL 86400 s | Expira em 24 h |
| Papel | Leitura rápida; Postgres guarda cópia durável |

Sem `REDIS_URL`, a idempotência pode usar só Postgres.

## Idempotência

O cliente envia `Idempotency-Key`. Repetir o pedido com a mesma chave devolve a mesma resposta, sem novo `transfer_id`. O consumidor Kafka aplica a mesma regra ([fundamentos Kafka](fundamentos-kafka.md)).

Depois vêm a teoria e o laboratório do Módulo 4.
