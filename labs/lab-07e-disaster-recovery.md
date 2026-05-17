# Lab 07e — Disaster recovery (RPO / RTO)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.5](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Documentar **RPO** e **RTO** do laboratório e executar um **restore** de PostgreSQL com medição de tempo — provar que o backup funciona, não apenas que existe.

**RPO** (Recovery Point Objective): quanto dado pode perder-se se o desastre for agora. **RTO** (Recovery Time Objective): quanto tempo até o serviço voltar. Backup nunca testado é esperança, não plano.

**Tempo estimado:** 60–90 min (inclui recriar cluster).

## Antes de começar

### Conhecimento (este lab)

- RPO/RTO ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [contexto LGPD/DR](../ebook/capitulos/contexto-m07-lgpd-pci.md)).

### Labs anteriores

- [Lab 04](lab-04-redis-postgres-idempotencia.md) — dados no Postgres.
- [Lab 00](lab-00-kind-banco-minimo.md) — recriar cluster.

### Ambiente

- `pg_dump` / `psql`; ~30–60 min para simulação completa.

## Passos

### 1. Matriz RPO/RTO

Crie `docs/dr-runbook.md`:

| Componente | RPO alvo | RTO alvo | Ferramenta backup |
|------------|----------|----------|-------------------|
| Postgres (transferências, outbox) | 5 min | 30 min | `pg_dump` / snapshot PVC |
| Redis (idempotência) | 15 min | 15 min | re-seed aceitável no lab |
| Manifests K8s | 0 | 10 min | Git + `kubectl apply -k` |
| Kafka | 1 min | 20 min | retenção + replay |

Justifique cada número em uma frase (negócio fictício do banco lab).

### 2. Backup

```bash
kubectl -n dados-lab exec -it lab-postgresql-0 -- \
  pg_dump -U postgres postgres > backup-lab-$(date +%Y%m%d).sql
```

Copie o ficheiro **para fora** do cluster (directório local seguro). Verifique tamanho > 0 e presença de `COPY` / `INSERT` para tabelas do *Pix*.

### 3. Simular desastre

```bash
kind delete cluster --name banco-lab
kind create cluster --name banco-lab --config deploy/kind/cluster-config.yaml
./scripts/build-load-kind.sh
kubectl apply -k deploy/k8s
# reinstale Postgres (Helm lab 04) antes do restore
```

Registe hora de início do desastre.

### 4. Restore e medição

1. `T0` — início do `psql` restore.
2. `psql < backup-lab-....sql` (ou pipe para o pod Postgres).
3. `T1` — `curl` do Lab 00 devolve resposta coerente; consulta SQL mostra transferências do backup.

`RTO ≈ T1 - T0` (documental). Compare com alvo da matriz.

### 5. Runbook de uma página

Checklist numerado: recriar cluster → Git → Postgres → Redis → Kafka → smoke test. Inclua contactos fictícios e critério “estabilizado”.

## Deu certo quando

- [ ] `docs/dr-runbook.md` preenchido.
- [ ] Restore executado com tempos anotados.
- [ ] RPO e RTO explicados em uma frase cada.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Restore vazio | Backup de base errada; permissões |
| *Pix* sem DB | `DATABASE_URL` após restore |

## Próximo passo

[Lab 07f — PII](lab-07f-pii-observabilidade.md)
