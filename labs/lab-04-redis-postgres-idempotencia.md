# Lab 04 — Redis, Postgres, locks e idempotência

[← Índice dos labs](README.md) · **Onda 2** · [Módulo 4](../modulos/modulo-04-consistencia.md) · [`PLANO` §4.4](../PLANO_DE_ESTUDO.md#modulo-4)

## Objetivo

Persistir idempotência com **Redis**, saldo/limites em **PostgreSQL** e eliminar corrida de débito com lock otimista ou pessimista.

## Antes de começar

### Conhecimento (este lab)

- **Idempotência** = mesma chave, mesmo efeito ([Módulo 4](../modulos/modulo-04-consistencia.md)).
- Redis como cache rápido; Postgres como registro durável (contexto [Postgres/Redis](../ebook/capitulos/contexto-m04-postgres-redis.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou Compose — *Pix* aceita `Idempotency-Key`.
- [Lab 02b](lab-02b-kafka-consumer.md) — **opcional** (só se for validar consumer com dedup).

### Ambiente

- *kind* ou Compose; Helm 3 se subir Redis/Postgres via chart no *kind* (passos abaixo).
- Postgres acessível pelo `servico-pix` (`DATABASE_URL` ou equivalente no Compose).

## Passos

### 1. Subir Redis e Postgres no kind

Exemplo com Helm (Bitnami) em namespaces de lab:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace dados-lab --dry-run=client -o yaml | kubectl apply -f -

helm install lab-redis bitnami/redis -n dados-lab \
  --set architecture=standalone --set auth.enabled=false

helm install lab-postgres bitnami/postgresql -n dados-lab \
  --set auth.postgresPassword=labsecret --set primary.persistence.size=1Gi
```

Anote os hosts DNS internos (`lab-redis-master.dados-lab.svc.cluster.local`, etc.).

### 2. Secrets (não commitar senha)

```bash
kubectl -n core-banking create secret generic pix-dados \
  --from-literal=REDIS_URL=redis://lab-redis-master.dados-lab.svc.cluster.local:6379/0 \
  --from-literal=DATABASE_URL=postgresql+psycopg://postgres:labsecret@lab-postgresql.dados-lab.svc.cluster.local:5432/postgres
```

### 3. Idempotência no *Pix*

Fluxo com `Idempotency-Key`:

1. `SET idempotency:{key} PROCESSING NX EX 86400`
2. Processar negócio
3. Gravar resultado final na chave

Repita o mesmo `curl` do lab 00 com a **mesma** chave — resposta idêntica, sem segundo débito.

### 4. Schema Postgres (exemplo)

```sql
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  balance NUMERIC(15,2) NOT NULL,
  version INT NOT NULL DEFAULT 0
);
```

Lock otimista:

```sql
UPDATE accounts SET balance = balance - :amt, version = version + 1
WHERE id = :id AND version = :expected;
```

### 5. Script de concorrência

```bash
# Exemplo: 20 POSTs paralelos (chaves diferentes) no mesmo account_id
for i in $(seq 1 20); do
  curl -sS -X POST http://127.0.0.1:8000/v1/pix/debito \
    -H "Idempotency-Key: race-$i" \
    -d '{"account_id":"acc_demo","amount":90}' &
done
wait
```

Primeiro sem lock (demonstrar furo); depois com lock (saldo nunca negativo).

## Deu certo quando

- [ ] Mesma `Idempotency-Key` → mesma resposta HTTP.
- [ ] Corrida sem lock mostra inconsistência; com lock, apenas N aprovações válidas.
- [ ] Consumer Kafka (se houver) deduplica por `idempotency_key`.

## Próximo passo

[Lab 07b — Outbox](lab-07b-outbox-kafka.md) · [Lab 02 — Jaeger](lab-02-opentelemetry-jaeger.md)
