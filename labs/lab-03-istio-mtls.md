# Lab 03 — Istio, mTLS STRICT e AuthorizationPolicy

[← Índice dos labs](README.md) · **Onda 4** · [Módulo 3](../modulos/modulo-03-service-mesh.md) · [`PLANO` §3.4](../PLANO_DE_ESTUDO.md#modulo-3)

## Objetivo

Instalar Istio no *kind*, injetar sidecars, ativar **mTLS STRICT** e provar que só o *Pix* (identidade permitida) chama *Limites*.

## Antes de começar

### Conhecimento (este lab)

- TLS criptografa tráfego; **mTLS** exige certificado dos **dois lados** ([Módulo 3](../modulos/modulo-03-service-mesh.md)).
- *Pix* e *Limites* já se falam por HTTP dentro do cluster — o mesh intercepta sem mudar a URL da app.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — apps no namespace `core-banking`.

### Ambiente

- Cluster *kind* no ar; **≥ 4 GB RAM livres** (Istio + sidecars + apps).
- **`istioctl`** instalado ([download](https://istio.io/latest/docs/setup/getting-started/#download)).

## Passos

### 1. Instalar Istio

```bash
istioctl install -y --set profile=default
kubectl get pods -n istio-system
```

### 2. Injetar sidecar no namespace

```bash
kubectl label namespace core-banking istio-injection=enabled --overwrite
kubectl -n core-banking rollout restart deployment/servico-pix deployment/servico-limites
kubectl -n core-banking rollout status deployment/servico-pix
```

Verifique 2/2 containers nos pods (`app` + `istio-proxy`):

```bash
kubectl -n core-banking get pods
```

### 3. mTLS STRICT

```bash
kubectl apply -f deploy/istio/peer-authentication-strict.yaml
```

### 4. Teste mTLS entre workloads

```bash
istioctl x describe pod -n core-banking -l app=servico-pix
```

Chamada via *Pix* (port-forward) deve continuar funcionando.

### 5. AuthorizationPolicy

Ajuste o `principal` em `deploy/istio/authorization-policy-pix-limites.yaml` para o ServiceAccount real do *Pix*:

```bash
kubectl -n core-banking get pod -l app=servico-pix -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Edite o YAML se não for `default`, depois:

```bash
kubectl apply -f deploy/istio/authorization-policy-pix-limites.yaml
```

### 6. Provar negação (403)

Crie um pod de teste com outra identidade:

```bash
kubectl -n core-banking run curl-test --image=curlimages/curl:8.7.1 --rm -it --restart=Never -- \
  curl -sS -o /dev/null -w "%{http_code}\n" \
  http://servico-limites:8000/v1/limits/acc_demo
```

Espere **403** do Envoy (política ativa). O *Pix* autenticado pelo mesh deve continuar recebendo **200** na rota de negócio.

### 7. (Opcional) Plaintext deve falhar

Tente `curl` sem sidecar para o IP do pod de limites na porta da app — com STRICT, tráfego mesh não-plaintext é o caminho correto.

## Deu certo quando

- [ ] Pods com 2 containers após injeção.
- [ ] `PeerAuthentication` STRICT aplicado em `core-banking`.
- [ ] *Pix* → *Limites* funciona via Service DNS.
- [ ] Pod “intruso” recebe **403** na rota protegida.
- [ ] Você anotou o **principal** Istio do *Pix* no caderno.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| 503 UFOS | Sidecar pronto? `istioctl analyze -n core-banking` |
| 403 no *Pix* também | Principal na `AuthorizationPolicy` errado; use `istioctl x authz check` |
| cluster lento | Perfil `minimal` ou menos addons |

## Próximo passo

[Lab 05 — Canary e GitOps](lab-05-canary-gitops.md)
