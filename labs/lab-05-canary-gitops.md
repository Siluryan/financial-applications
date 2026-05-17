# Lab 05 — Canary, mirror e GitOps

[← Índice dos labs](README.md) · [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

## Objetivo

Publicar *servico-credito* em **v1** e **v2**, encaminhar uma fração do tráfego com **VirtualService** (canary), espelhar tráfego (mirror) e praticar **GitOps** com manifests versionados.

Deploy “big bang” (100 % na versão nova de uma vez) maximiza blast radius. Canary expõe 1 % do tráfego real à v2 antes da promoção. GitOps garante que o cluster converge para o que está no Git — não para `kubectl edit` esquecido.

**Tempo estimado:** 90–120 min.

## Antes de começar

### Conhecimento (este lab)

- **Canary** = percentagem do tráfego na revisão nova ([Módulo 5](../modulos/modulo-05-deploy-gitops.md)).
- `VirtualService` e `DestinationRule` com subsets no Istio.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md).
- [Lab 03](lab-03-istio-mtls.md) — **Istio instalado** e sidecars injectados.

### Ambiente

- *kind* com `servico-credito` deployado.
- Jaeger (Lab 02) ou logs para comparar erro/latência entre versões.

## Passos

### 1. Duas revisões do *Crédito*

O Deployment base usa `SERVICE_VERSION`. Para canary com subsets Istio, os Pods precisam de labels `version: v1` e `version: v2`.

```bash
kubectl -n core-banking set env deployment/servico-credito SERVICE_VERSION=v1
# Crie Deployment servico-credito-v2 com label version=v2
```

Documente qual imagem ou env distingue v1 de v2 nos logs (`SERVICE_VERSION` no JSON de log, por exemplo).

### 2. DestinationRule

Define subsets que o VirtualService referencia:

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

Salve em `deploy/istio/destination-rule-credito.yaml` e `kubectl apply -f`.

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

Gere tráfego (loop de `curl` ou script de carga leve). Compare contagem de linhas de log com `SERVICE_VERSION=v2` — espera-se ~1 %.

**Promoção:** altere pesos para 100/0 ou aumente gradualmente (90/10, 50/50). **Rollback:** 100 % v1.

### 4. Mirror (shadow)

Adicione `mirror` e `mirrorPercentage` na `VirtualService` — tráfego duplicado para v2 **sem** alterar a resposta ao cliente. Cuidado: v2 não deve escrever no mesmo banco de produção sem isolamento ([contexto M5](../ebook/capitulos/contexto-m05-gitops-canary.md)).

Para configurar *mirroring* no Istio, use a tarefa oficial de espelhamento de tráfego na documentação do projeto.

### 5. GitOps leve

1. Commit dos YAML em `deploy/`.
2. Recrie cluster ou namespace e `kubectl apply -k deploy/k8s` — estado reproduzido a partir do Git.

**Drift:** altere um Deployment com `kubectl edit`; compare com Git — GitOps (Argo CD) reverteria essa diferença.

### 6. Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Crie `Application` apontando para este repositório e pasta `deploy/k8s`. Observe sync automático ao push.

## Deu certo quando

- [ ] ~1 % das requisições chega à v2 (evidência em logs).
- [ ] Rollback documentado (pesos ou `kubectl rollout undo`).
- [ ] Manifests no Git descrevem o que corre no cluster.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| 100 % v1 sempre | Labels dos Pods não batem com subsets |
| 503 após VS | DestinationRule aplicada? Sidecars prontos? |
| Mirror duplica escrita | Desactivar escrita em v2 ou usar DB isolado |

## Próximo passo

[Lab 06 — Backstage](lab-06-backstage-catalogo.md)
