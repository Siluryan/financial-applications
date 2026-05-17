# Lab 07b — Transactional outbox → Kafka

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.2](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Garantir que eventos `pix.iniciado` são gravados na **mesma transação** PostgreSQL que a transferência, e publicados no Kafka por um **relay** assíncrono — sem `producer.send` na thread HTTP.

Publicar Kafka directo no handler HTTP arrisca: DB commitou e mensagem não saiu (ou o contrário). O **transactional outbox** torna o evento uma linha SQL; o relay lê linhas pendentes e publica — at-least-once com idempotência no consumer.

**Tempo estimado:** 90–120 min.

## Antes de começar

### Conhecimento (este lab)

- Padrão outbox ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Fundamentos — Kafka](../ebook/capitulos/fundamentos-kafka.md)).

### Labs anteriores

- [Lab 04](lab-04-redis-postgres-idempotencia.md) — Postgres no *Pix*.
- [Lab 02b](lab-02b-kafka-consumer.md) — broker e tópico.

### Ambiente

- Compose com Postgres + Kafka **ou** equivalente no *kind*.
- `apps/worker-outbox-relay/` no repositório.

## Passos

### 1. Onde está o código

| Peça | Arquivo | Papel |
|------|---------|--------|
| `OutboxEvent` | `apps/servico-pix/app/models.py` | Linha pendente de publicação |
| Gravação | `apps/servico-pix/app/pix_service.py` | `session.begin()`: transferência + outbox + idempotência |
| Modo outbox | `PIX_USE_OUTBOX=true` + `DATABASE_URL` | Padrão com Postgres |
| Legado | `PIX_SYNC_KAFKA=true` | Publish HTTP — só para comparar |
| Relay | `apps/worker-outbox-relay/app/main.py` | `FOR UPDATE SKIP LOCKED`, span `outbox.publish` |

Consulta SQL:

```sql
SELECT id, aggregate_id, event_type, published_at IS NULL AS pending
FROM outbox ORDER BY created_at DESC LIMIT 5;
```

### 2. Subir Compose com outbox

```bash
docker compose up --build -d
```

Verifique no `docker-compose.yml`: *Pix* com `DATABASE_URL`, `PIX_USE_OUTBOX=true`; serviço `worker-outbox-relay` com `KAFKA_BOOTSTRAP_SERVERS`.

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-07b-001' \
  -d '{"account_id":"acc_demo","amount":10,"destination":"acc_dest_1"}' | jq .
```

**Esperado:** `"kafka": "outbox_pending"`. Em segundos, o relay publica — confirme no console consumer (lab 02b).

### 3. Validar mesma transação

Revise `pix_service.py`: `OutboxEvent` dentro do mesmo `session.begin()` que `PixTransfer`. Em `main.py`, o producer Kafka só activa com `PIX_SYNC_KAFKA=true` — desligado no fluxo outbox.

### 4. Teste de crash

1. `docker compose stop worker-outbox-relay` (ou escale a zero).
2. Envie *Pix* aprovado — linha na outbox com `published_at` NULL.
3. Suba o relay — mensagens no tópico **sem** duplicar transferência (uma linha de negócio por chave idempotente).

### 5. Trace contínuo

Com [Lab 02](lab-02-opentelemetry-jaeger.md), o trace deve incluir span `outbox.publish` no worker, ligado ao HTTP do *Pix* se propagação estiver configurada.

### 6. DLQ — poison pill

1. Tópico `pix.iniciado.dlq`.
2. Após 3 falhas no consumer, publique cópia na DLQ com headers `original_offset`, `error`, `trace_id`.
3. Commit offset da mensagem original — descreva o trade-off (desbloquear partição vs perda de reprocessamento).

O exercício **A6** do [Lab 02b](lab-02b-kafka-consumer.md) aborda consumo e *lag* em cenário semelhante.

### 7. Exactly-once — o que o lab garante

Escreva em 5 linhas:

- O que **transação + outbox** garante.
- O que **Kafka transactional producer** garantiria (sem implementar).
- Por que o consumer ainda precisa **idempotência**.

## Deu certo quando

- [ ] Nenhum evento perdido após crash simulado do relay.
- [ ] Consumer idempotente não duplica efeito.
- [ ] Fluxo alinhado ao diagrama [m04-outbox](../modulos/diagramas/m04-outbox.png).
- [ ] Mensagem poison enviada à DLQ após N tentativas.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| `outbox_pending` eterno | Relay parado; logs do worker |
| Mensagens duplicadas no tópico | At-least-once normal — consumer deduplica |
| HTTP chama Kafka directo | `PIX_SYNC_KAFKA` activo por engano |

## Próximo passo

[Lab 07c — Pact](lab-07c-pact-contratos.md) · [Lab 07g — SRE](lab-07g-sre-praticas.md)
