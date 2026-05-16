# Lab 07e — Disaster recovery (RPO / RTO)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.5](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Documentar **RPO/RTO** do lab e executar um **restore** de Postgres com medição de tempo.

**RPO** responde: “se o datacenter sumir agora, até quando o backup cobre?” — se o backup é diário, você pode perder até um dia de *Pix*. **RTO** responde: “quanto tempo até o balcão reabrir?” — do `kind delete` até o `curl` do lab 00 voltar. Restore ensaiado vale mais que backup que nunca foi testado.

## Antes de começar

### Conhecimento (este lab)

- **RPO** = quanto dado pode perder; **RTO** = tempo para reabrir ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md), contexto [LGPD/DR](../ebook/capitulos/contexto-m07-lgpd-pci.md)).

### Labs anteriores

- [Lab 04](lab-04-redis-postgres-idempotencia.md) — Postgres com dados de exercício.
- [Lab 00](lab-00-kind-banco-minimo.md) — saber recriar cluster.

### Ambiente

- `pg_dump` / `psql` disponíveis; tempo para recriar *kind* (~30–60 min no lab documental).

## Passos

### 1. Matriz RPO/RTO

Crie `docs/dr-runbook.md`:

| Componente | RPO alvo | RTO alvo | Ferramenta backup |
|------------|----------|----------|-------------------|
| Postgres (saldos) | 5 min | 30 min | `pg_dump` / snapshot PVC |
| Redis (idempotência) | 15 min | 15 min | aceitar re-seed no lab |
| Manifests K8s | 0 | 10 min | Git + `kubectl apply -k` |
| Kafka | 1 min | 20 min | retenção + replay tópico |

### 2. Backup

```bash
kubectl -n dados-lab exec -it lab-postgresql-0 -- \
  pg_dump -U postgres postgres > backup-lab-$(date +%Y%m%d).sql
```

Guarde **fora** do pod.

### 3. Simular desastre

```bash
kind delete cluster --name banco-lab
kind create cluster --name banco-lab --config deploy/kind/cluster-config.yaml
./scripts/build-load-kind.sh
kubectl apply -k deploy/k8s
# reinstale Postgres e restaure
```

### 4. Restore e medição

1. Anote `T0` — início do restore.
2. `psql < backup-lab-....sql`
3. Anote `T1` — *Pix* responde com saldo consistente.
4. `RTO ≈ T1 - T0` (lab documental).

### 5. Runbook de uma página

Checklist: recriar cluster → aplicar Git → restaurar DB → validar smoke test (`curl` do lab 00).

## Deu certo quando

- [ ] `docs/dr-runbook.md` preenchido.
- [ ] Restore executado ao menos uma vez com tempo anotado.
- [ ] Você explica diferença entre RPO e RTO em uma frase cada.

## Próximo passo

[Lab 07f — PII](lab-07f-pii-observabilidade.md)
