# Lab 07a — Segredos e External Secrets

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.1](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Eliminar credenciais do Git, injectar `DATABASE_URL` e `REDIS_URL` via **Kubernetes Secret**, e sincronizar esses Secrets com **External Secrets Operator** (ou cofre de desenvolvimento).

`Secret` no Kubernetes é base64, não cofre forte. O valor pedagógico é **separação**: código no Git, segredos na fonte (Vault, cloud SM, provider fake do lab). Rotação passa a alterar a fonte e reconciliar — não a recompilar imagem.

**Tempo estimado:** 75–90 min.

## Antes de começar

### Conhecimento (este lab)

- Limites do `Secret` nativo ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — cluster no ar.
- [Lab 04](lab-04-redis-postgres-idempotencia.md) — recomendado (Postgres e Redis no fluxo do *Pix*).

### Ambiente

- *kind* + Helm 3.
- Cofre simulado ou External Secrets conforme passos.

## Passos

### 1. Auditar o repositório

```bash
git grep -i password || true
git grep -i secret || true
git grep -E 'postgresql://|redis://' || true
```

Nenhuma senha de produção deve estar versionada. URLs com `labsecret` em exemplos de lab são aceitáveis se documentados como fictícios.

### 2. Secret manual (transição)

Crie Secret sem commitar o valor:

```bash
kubectl -n core-banking create secret generic pix-dados \
  --from-literal=DATABASE_URL='postgresql://...' \
  --dry-run=client -o yaml | kubectl apply -f -
```

No Deployment do *Pix*, `envFrom.secretRef.name: pix-dados`. Reinicie o rollout e confirme Pod `Running`.

**Teste:** `kubectl exec` no Pod e `printenv DATABASE_URL` — deve existir, mas não copie o valor para o caderno.

### 3. Instalar External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace
```

Aguarde pods do operador em `Running`.

### 4. ClusterSecretStore (lab)

Sem Vault corporativo, use o [provider fake](https://external-secrets.io/latest/provider/fake/) ou Vault dev em Pod — registe o endereço da store no relatório do lab.

Crie `ExternalSecret` que materializa `Secret` `pix-dados` a partir da store. Após reconcile:

```bash
kubectl -n core-banking get externalsecret
kubectl -n core-banking get secret pix-dados -o yaml  # não partilhe
```

### 5. App lê só env injectada

No Python, falhe o startup se `DATABASE_URL` for valor default inseguro usado em testes locais sem flag explícita — força falha rápida em deploy mal configurado.

### 6. Rotação (documental)

Procedimento escrito (1 página):

1. Alterar valor na fonte (Vault/fake).
2. Forçar reconcile do `ExternalSecret` (`kubectl annotate` ou esperar intervalo).
3. `kubectl rollout restart deployment/servico-pix`.
4. Smoke test: `curl` do Lab 00.

## Deu certo quando

- [ ] `git log` não contém senhas reais.
- [ ] Pod sobe com variáveis vindas de `Secret`.
- [ ] Procedimento de rotação documentado.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| ExternalSecret não sync | Logs do operador; RBAC; store URL |
| Pod CrashLoop após Secret | URL mal formada; Postgres inacessível |

## Próximo passo

[Lab 07b — Outbox](lab-07b-outbox-kafka.md)
