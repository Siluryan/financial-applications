# Lab 07b — Transactional outbox → Kafka

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.2](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Substituir `publish` direto na thread HTTP por **outbox** na mesma transação Postgres e um **relay** que publica no Kafka.

## Antes de começar

### Conhecimento (este lab)

- **Outbox** = gravar evento na mesma transação SQL do *Pix*; relay publica no Kafka ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 04](lab-04-redis-postgres-idempotencia.md) — Postgres no fluxo do *Pix*.
- [Lab 02b](lab-02b-kafka-consumer.md) — broker e tópico `pix.iniciado`.

### Ambiente

- Compose com Postgres + Kafka **ou** equivalente no *kind*.
- `worker-outbox-relay` no repo (`apps/worker-outbox-relay/`).

## Passos

### 1. Tabela outbox

```sql
CREATE TABLE outbox (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  published_at TIMESTAMPTZ
);
CREATE INDEX idx_outbox_pending ON outbox (created_at) WHERE published_at IS NULL;
```

### 2. Mesma transação do negócio

No handler do *Pix* (SQLAlchemy):

```python
async with session.begin():
    # débito / registro pix
    session.add(Outbox(...))
# commit único
```

Remova (ou desative) publish **síncrono** ao broker (`aiokafka`) no caminho da requisição HTTP.

### 3. Relay worker

Processo separado (`apps/worker-outbox-relay/`):

1. `SELECT ... FROM outbox WHERE published_at IS NULL LIMIT 100 FOR UPDATE SKIP LOCKED`
2. Publicar no Kafka
3. `UPDATE outbox SET published_at = now()`

### 4. Teste de crash

1. Pare o relay após commit no DB.
2. Confirme linhas pendentes em `outbox`.
3. Suba o relay — mensagens aparecem no tópico sem duplicar negócio (dedup no consumer).

### 5. Integrar “*Pix* perdido”

Com [Lab 02 — Jaeger](lab-02-opentelemetry-jaeger.md), o trace deve incluir span `outbox.publish` no worker.

## Deu certo quando

- [ ] Nenhum evento perdido após crash simulado do relay.
- [ ] Consumer idempotente não aplica efeito duplicado.
- [ ] Fluxo documentado no diagrama [m04-outbox](../modulos/diagramas/m04-outbox.png).

## Próximo passo

[Lab 07c — Pact](lab-07c-pact-contratos.md)
