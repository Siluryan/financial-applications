# Lab 04 — Redis, Postgres, locks e idempotência

[← Índice dos labs](README.md) · [Módulo 4](../modulos/modulo-04-consistencia.md)

## Objetivo

Persistir respostas idempotentes com **Redis** (cache) e **PostgreSQL** (registo durável), gravar transferências e eventos **outbox** na mesma transação SQL, e reflectir sobre locks em cenários de concorrência.

Pagamentos exigem: repetir o mesmo pedido não pode debitar duas vezes. A chave `Idempotency-Key` identifica a intenção do cliente. O lab mostra onde o repositório guarda a resposta (Redis + tabela) e como isso se liga ao consumer Kafka (at-least-once).

**Tempo estimado:** 90–120 min.

## Antes de começar

### Conhecimento (este lab)

- **Idempotência:** mesma chave → mesmo efeito ([Módulo 4](../modulos/modulo-04-consistencia.md), [Fundamentos — Postgres/Redis](../ebook/capitulos/fundamentos-postgres-redis.md)).
- Redis como cache de leitura rápida; Postgres como fonte durável após `COMMIT`.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou Compose — *Pix* aceita `Idempotency-Key`.
- [Lab 02b](lab-02b-kafka-consumer.md) — recomendado para validar dedup no consumer.

### Ambiente

- *kind* ou Compose; Helm 3 se subir Redis/Postgres via chart.
- `DATABASE_URL` e `REDIS_URL` acessíveis pelo `servico-pix`.

## Passos

### 1. Subir Redis e Postgres no kind

Exemplo Bitnami em namespace dedicado:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace dados-lab --dry-run=client -o yaml | kubectl apply -f -

helm install lab-redis bitnami/redis -n dados-lab \
  --set architecture=standalone --set auth.enabled=false

helm install lab-postgres bitnami/postgresql -n dados-lab \
  --set auth.postgresPassword=labsecret --set primary.persistence.size=1Gi
```

Anote DNS internos: `lab-redis-master.dados-lab.svc.cluster.local`, `lab-postgresql.dados-lab.svc.cluster.local`.

No Compose, Postgres e Redis já sobem com a stack — adapte os passos 2–3 às variáveis do `docker-compose.yml`.

### 2. Secrets (não commitar senha)

```bash
kubectl -n core-banking create secret generic pix-dados \
  --from-literal=REDIS_URL=redis://lab-redis-master.dados-lab.svc.cluster.local:6379/0 \
  --from-literal=DATABASE_URL=postgresql+psycopg://postgres:labsecret@lab-postgresql.dados-lab.svc.cluster.local:5432/postgres
```

Ligue o Secret ao Deployment do *Pix* (`envFrom.secretRef`). Reinicie o rollout.

### 3. Idempotência no *Pix* (referência do repositório)

| Camada | Comportamento |
|--------|----------------|
| `main.py` | Se há `Idempotency-Key`, `get_cached_response` antes de `process_pix` |
| `idempotency.py` | Redis `idempotency:{key}` (TTL 86400 s) + tabela `idempotency_records` |
| `pix_service.py` | `store_response` na mesma transação do outbox quando Postgres activo |
| `models.py` | `IdempotencyRecord.key` é **PK** — duplicata → `IntegrityError` tratado |

**Primeiro pedido:**

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-04-001' \
  -d '{"account_id":"acc_demo","amount":10,"destination":"acc_dest_1"}' | jq .
```

**Replay (mesma chave, mesmo corpo):**

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-04-001' \
  -d '{"account_id":"acc_demo","amount":10,"destination":"acc_dest_1"}' | jq .
```

**Esperado no segundo:** `"idempotent_replay": true`, mesmo `transfer_id`, sem novo débito lógico.

Confirme no Postgres:

```sql
SELECT key, response_body->>'transfer_id' FROM idempotency_records WHERE key = 'lab-04-001';
```

Confirme no Redis: `redis-cli GET idempotency:lab-04-001` (com Redis exposto no cluster ou Compose).

### 4. Outbox e transferência (mesmo Postgres)

Com `DATABASE_URL` e `PIX_USE_OUTBOX=true`, `pix_service.py` grava `pix_transfers` + `outbox` em `session.begin()`. Tabelas criadas por `init_db()` — modelos em `models.py`.

Após um *Pix* aprovado:

```sql
SELECT id, account_id, amount, status FROM pix_transfers ORDER BY created_at DESC LIMIT 3;
SELECT id, event_type, published_at IS NULL AS pending FROM outbox ORDER BY created_at DESC LIMIT 3;
```

Linhas `pending = true` na outbox aguardam o relay (lab 07b).

### 5. Lock e corrida

O monorepo **não** expõe `POST /v1/pix/debito` local — limites vêm de *servico-limites*. Para locks do Módulo 4:

- **Opção A:** desenhe `UPDATE … WHERE version = :expected` e relacione ao `IntegrityError` da idempotência.
- **Opção B:** implemente tabela `accounts` e endpoint de débito com `SELECT FOR UPDATE` ou coluna `version`.

Carga paralela no endpoint existente (chaves **diferentes**, mesma conta):

```bash
for i in $(seq 1 10); do
  curl -sS -X POST http://127.0.0.1:8000/v1/pix \
    -H 'Content-Type: application/json' \
    -H "Idempotency-Key: lab-04-race-$i" \
    -d '{"account_id":"acc_demo","amount":100,"destination":"acc_dest_1"}' &
done
wait
```

Observe rejeições por limite diário e ordem nos logs — não é lock local, mas ilustra concorrência no dependente.

## Deu certo quando

- [ ] Mesma `Idempotency-Key` → mesma resposta e `idempotent_replay: true`.
- [ ] Linha em `idempotency_records` e/ou chave Redis após o primeiro POST.
- [ ] Documento ou diagrama sobre lock otimista (Opção A) ou implementação da Opção B.
- [ ] Consumer do [Lab 02b](lab-02b-kafka-consumer.md) deduplica por `idempotency_key`.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Segundo POST processa de novo | Redis/Postgres desligados; ver env |
| `IntegrityError` no log | Esperado em corrida extrema na mesma chave — ver tratamento em `idempotency.py` |
| Tabelas vazias | `DATABASE_URL` ausente; `init_db` não correu |

## Próximo passo

[Lab 07b — Outbox](lab-07b-outbox-kafka.md) · [Lab 02 — Jaeger](lab-02-opentelemetry-jaeger.md)
