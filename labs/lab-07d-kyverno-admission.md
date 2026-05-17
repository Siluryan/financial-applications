# Lab 07d — Kyverno (admission policies)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.4](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Impedir que Deployments inseguros entrem no cluster — sem `resources.limits`, com imagem `:latest` — usando **Kyverno** como admission controller.

Sem política na admissão, YAML perigoso vira Pod em produção. Kyverno avalia o manifest no `kubectl apply` e **nega** com mensagem auditável — defesa em profundidade antes do runtime.

**Tempo estimado:** 60–75 min.

## Antes de começar

### Conhecimento (este lab)

- Admission controller ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — namespace `core-banking`.

### Ambiente

- *kind* + Helm 3.

## Passos

### 1. Instalar Kyverno

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
kubectl -n kyverno wait --for=condition=available deployment/kyverno-admission-controller --timeout=120s
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

Aplique Deployment de teste **sem** `resources.limits` no namespace `core-banking`.

**Esperado:** erro de policy com mensagem clara — não `Running`.

Guarde o output como evidência no relatório do lab.

### 4. Política — proibir `:latest`

Segunda `ClusterPolicy` negando imagens `*:latest` em `core-banking`. Teste com imagem `nginx:latest` — deve falhar.

### 5. Corrigir manifests do lab

Ajuste `deploy/k8s/base/*.yaml` se alguma política falhar nos serviços base. O objectivo é que `kubectl apply -k deploy/k8s` passe **com** políticas activas.

## Deu certo quando

- [ ] `kubectl apply` de manifest ruim é negado.
- [ ] Manifest corrigido é aceite.
- [ ] Pelo menos duas políticas activas (limits + latest).

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Policy não aplica | `kubectl get clusterpolicy`; webhook Kyverno |
| Falso positivo | Ajustar pattern; excluir namespace de sistema |

## Próximo passo

[Lab 07e — DR](lab-07e-disaster-recovery.md)
