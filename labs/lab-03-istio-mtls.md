# Lab 03 — Istio, mTLS STRICT e AuthorizationPolicy

[← Índice dos labs](README.md) · [Módulo 3](../modulos/modulo-03-service-mesh.md)

## Objetivo

Instalar Istio no *kind*, injetar sidecars Envoy, activar **mTLS STRICT** entre workloads e demonstrar que apenas o *Pix* (identidade SPIFFE permitida) invoca *Limites* com sucesso.

Em muitos clusters históricos, a rede interna era “confiável”: qualquer Pod podia chamar qualquer Service. O mesh move autenticação e autorização para a plataforma. A aplicação mantém `http://servico-limites:8000`; o sidecar negocia certificados e aplica políticas.

**Ao terminar**, deve identificar o **principal** Istio do *Pix* e interpretar um **403** do Envoy como negação de política, não como erro de negócio do *Limites*.

**Tempo estimado:** 90–120 min (Istio consome RAM).

## Antes de começar

### Conhecimento (este lab)

- TLS cifra o canal; **mTLS** exige certificado **dos dois lados** ([Módulo 3](../modulos/modulo-03-service-mesh.md), [Fundamentos — Istio](../ebook/capitulos/fundamentos-istio-mesh.md)).
- *Pix* e *Limites* já comunicam por HTTP no namespace `core-banking`.

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

Aguarde pods `istio-ingressgateway` (se existir) e `istiod` em `Running`. Em portátil com pouca RAM, use o perfil `minimal` e registe essa escolha no relatório do lab.

### 2. Injetar sidecar no namespace

```bash
kubectl label namespace core-banking istio-injection=enabled --overwrite
kubectl -n core-banking rollout restart deployment/servico-pix deployment/servico-limites
kubectl -n core-banking rollout status deployment/servico-pix
```

**Verificação obrigatória:** cada Pod deve mostrar **2/2** containers (`app` + `istio-proxy`):

```bash
kubectl -n core-banking get pods
```

Se continuar 1/1, o label de injecção não foi aplicado antes do create do Pod — repita restart.

### 3. mTLS STRICT

```bash
kubectl apply -f deploy/istio/peer-authentication-strict.yaml
```

`PeerAuthentication` com modo **STRICT** exige mTLS entre workloads no namespace (conforme escopo do manifest). Tráfego plaintext entre Pods com sidecar deixa de ser aceite no mesh.

### 4. Teste mTLS entre workloads

```bash
istioctl x describe pod -n core-banking -l app=servico-pix
```

Procure secção de mTLS / status do proxy. Em seguida, com port-forward do *Pix*, repita o `POST /v1/pix` do Lab 00 — deve continuar **aprovado** ou **rejeitado por negócio**, não por erro de TLS.

### 5. AuthorizationPolicy

A política em `deploy/istio/authorization-policy-pix-limites.yaml` restringe quem pode chamar *Limites*. O `principal` deve coincidir com o ServiceAccount do *Pix*:

```bash
kubectl -n core-banking get pod -l app=servico-pix -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Se não for `default`, edite o YAML com o nome correcto e aplique:

```bash
kubectl apply -f deploy/istio/authorization-policy-pix-limites.yaml
```

### 6. Provar negação (403)

Pod de teste **sem** identidade autorizada:

```bash
kubectl -n core-banking run curl-test --image=curlimages/curl:8.7.1 --rm -it --restart=Never -- \
  curl -sS -o /dev/null -w "%{http_code}\n" \
  http://servico-limites:8000/v1/limits/acc_demo
```

**Esperado:** **403** do Envoy. O *Pix* autenticado pelo mesh deve continuar a obter **200** na rota de negócio via fluxo normal.

**Registe no relatório do lab:** principal do *Pix*, código HTTP do intruso, diferença entre 403 (mesh) e 404/422 (app).

### 7. Plaintext deve falhar

Tentar `curl` directo ao IP do Pod na porta da aplicação, contornando o Service — com STRICT, o caminho correcto passa pelo mesh com mTLS.

## Deu certo quando

- [ ] Pods com 2 containers após injecção.
- [ ] `PeerAuthentication` STRICT aplicado em `core-banking`.
- [ ] *Pix* → *Limites* funciona via Service DNS.
- [ ] Pod intruso recebe **403** na rota protegida.
- [ ] Principal Istio do *Pix* anotado.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| 503 UF, upstream connect error | Sidecar não pronto; `istioctl analyze -n core-banking` |
| 403 no *Pix* também | Principal errado na `AuthorizationPolicy`; `istioctl x authz check` |
| Cluster lento | Perfil `minimal`; desligar addons Istio |

## Próximo passo

[Lab 05 — Canary e GitOps](lab-05-canary-gitops.md)
