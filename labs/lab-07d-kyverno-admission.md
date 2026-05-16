# Lab 07d — Kyverno (admission policies)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.4](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Bloquear Deployments inseguros (sem `resources.limits`, tag `:latest`) antes de entrarem no cluster.

Sem admission policy, qualquer YAML perigoso vira pod rodando — como deixar qualquer pessoa ligar um forno sem checar extintor. **Kyverno** avalia o manifest na hora do `kubectl apply` e **nega** com mensagem clara; isso vira evidência de auditoria (“o cluster recusou deploy sem limite de memória”).

## Antes de começar

### Conhecimento (este lab)

- **Admission controller** avalia YAML **antes** do pod existir ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — namespace `core-banking` e Deployments base.

### Ambiente

- *kind* no ar; **Helm 3**; Kyverno instalado nos passos abaixo.

## Passos

### 1. Instalar Kyverno

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

### 2. Política — limits obrigatórios

Crie `deploy/policies/kyverno/require-resources.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resources-core-banking
spec:
  validationFailureAction: Enforce
  rules:
    - name: require-limits
      match:
        any:
          - resources:
              kinds: [Deployment]
              namespaces: [core-banking]
      validate:
        message: "Deployments em core-banking precisam de resources.limits"
        pattern:
          spec:
            template:
              spec:
                containers:
                  - name: "*"
                    resources:
                      limits:
                        memory: "?*"
                        cpu: "?*"
```

```bash
mkdir -p deploy/policies/kyverno
kubectl apply -f deploy/policies/kyverno/
```

### 3. Manifest “ruim”

Tente aplicar Deployment sem `limits` — deve ser **negado** com mensagem clara.

### 4. Política — proibir :latest

Segunda `ClusterPolicy` negando imagens `*:latest` em `core-banking`.

### 5. Corrigir manifests do lab

Ajuste `deploy/k8s/base/*.yaml` se alguma política falhar (já há limits nos serviços base).

## Deu certo quando

- [ ] `kubectl apply` de manifest ruim retorna erro de policy.
- [ ] Manifest corrigido é aceito.
- [ ] Pelo menos **duas** políticas ativas (limits + latest).

## Próximo passo

[Lab 07e — DR](lab-07e-disaster-recovery.md)
