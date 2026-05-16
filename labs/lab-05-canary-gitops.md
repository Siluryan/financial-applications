# Lab 05 — Canary, mirror e GitOps

[← Índice dos labs](README.md) · **Ondas 5–6** · [Módulo 5](../modulos/modulo-05-deploy-gitops.md) · [`PLANO` §5.3](../PLANO_DE_ESTUDO.md#modulo-5)

## Objetivo

Publicar *servico-credito* **v1** e **v2**, dividir tráfego com **VirtualService** e praticar GitOps com `kubectl apply -k` ou Argo CD.

## Antes de começar

### Conhecimento (este lab)

- **Canary** = fração do tráfego na versão nova ([Módulo 5](../modulos/modulo-05-deploy-gitops.md)).
- `VirtualService` / `DestinationRule` no Istio (subsets v1 e v2).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md).
- [Lab 03](lab-03-istio-mtls.md) — **Istio instalado** e mTLS no namespace.

### Ambiente

- *kind* com `servico-credito` deployado (v1/v2 via `SERVICE_VERSION`).
- Métricas ou logs para comparar erro/latência entre versões (Jaeger do Lab 02 ajuda).

## Passos

### 1. Duas revisões do *Crédito*

Build duas imagens ou um Deployment com `SERVICE_VERSION`:

```bash
# Deployment v1 — já existe com SERVICE_VERSION=v1
kubectl -n core-banking set env deployment/servico-credito SERVICE_VERSION=v1

# Segundo Deployment servico-credito-v2 (sua entrega) com label version=v2
```

Labels sugeridos nos pods: `version: v1` e `version: v2`.

### 2. DestinationRule

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: servico-credito
  namespace: core-banking
spec:
  host: servico-credito
  subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
```

Salve em `deploy/istio/destination-rule-credito.yaml` e aplique.

### 3. Canary 99/1

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: servico-credito
  namespace: core-banking
spec:
  hosts:
    - servico-credito
  http:
    - route:
        - destination:
            host: servico-credito
            subset: v1
          weight: 99
        - destination:
            host: servico-credito
            subset: v2
          weight: 1
```

Gere tráfego e compare logs/métricas das duas versões.

### 4. Mirror (shadow)

Adicione bloco `mirror` e `mirrorPercentage` na `VirtualService` (consulte [doc Istio](https://istio.io/latest/docs/tasks/traffic-management/mirroring/)).

### 5. GitOps leve

1. Commit dos YAML em `deploy/`.
2. `kubectl apply -k deploy/k8s` em cluster novo → estado reproduzido.

### 6. (Opcional) Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Crie `Application` apontando para este repositório e pasta `deploy/k8s`.

## Deu certo quando

- [ ] ~1 % das requisições chega na v2 (logs com `SERVICE_VERSION=v2`).
- [ ] Rollback = alterar peso para 100 % v1 ou `kubectl rollout undo`.
- [ ] Manifests versionados no Git são a fonte do que roda no cluster.

## Próximo passo

[Lab 06 — Backstage](lab-06-backstage-catalogo.md)
