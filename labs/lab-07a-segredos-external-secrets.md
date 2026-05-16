# Lab 07a — Segredos e External Secrets

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.1](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Remover credenciais do Git e montar senhas de Postgres/Redis via **Kubernetes Secret** sincronizado por **External Secrets Operator** (ou Vault dev).

## Antes de começar

### Conhecimento (este lab)

- `Secret` no Kubernetes não é cofre (base64 ≠ criptografia forte) — [Módulo 7](../modulos/modulo-07-operacao-conformidade.md).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — cluster no ar.
- [Lab 04](lab-04-redis-postgres-idempotencia.md) — **opcional** (se validar credenciais de Postgres/Redis).

### Ambiente

- *kind* + **Helm 3**.
- Cofre simulado ou External Secrets conforme passos (Vault/local ou provider de lab).

## Passos

### 1. Auditar o repositório

```bash
git grep -i password || true
git grep -i secret || true
```

Nenhuma senha real deve estar versionada.

### 2. Secret manual (passo de transição)

```bash
kubectl -n core-banking create secret generic pix-dados \
  --from-literal=DATABASE_URL='postgresql://...' \
  --dry-run=client -o yaml | kubectl apply -f -
```

No Deployment do *Pix*, use `envFrom.secretRef` — **não** commite o valor.

### 3. Instalar External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace
```

### 4. ClusterSecretStore (lab)

Para estudo sem Vault corporativo, use o [provider fake](https://external-secrets.io/latest/provider/fake/) ou suba Vault dev em pod e documente o endereço.

Crie `ExternalSecret` que gera `Secret` `pix-dados` a partir da store.

### 5. App lê só de env injetada

No Python, falhe o startup se `DATABASE_URL` contiver valor default inseguro (`pytest`).

### 6. Rotação (documental)

1. Altere valor na fonte (Vault/fake).
2. Force reconcile do `ExternalSecret`.
3. `kubectl rollout restart deployment/servico-pix`.
4. Verifique reconexão sem perda de dados.

## Deu certo quando

- [ ] `git log` não contém senhas.
- [ ] Pod sobe com variáveis vindas de `Secret`.
- [ ] Procedimento de rotação descrito em 1 página no README do lab ou em `docs/`.

## Próximo passo

[Lab 07b — Outbox](lab-07b-outbox-kafka.md)
