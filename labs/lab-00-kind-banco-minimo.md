# Lab 00 — Banco mínimo no kind

[← Índice dos labs](README.md) · **Onda 0** · [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md#ondas-principio)

## Objetivo

Subir *servico-pix* e *servico-limites* no Kubernetes local (*kind*) e validar uma chamada HTTP ponta a ponta.

## Antes de começar

| Tipo | Este lab |
|------|----------|
| **Conhecimento** | Ver [`ebook/PRE-REQUISITOS.md`](../ebook/PRE-REQUISITOS.md) (HTTP/JSON, noções de Docker e K8s) |
| **Labs anteriores** | Nenhum — é o primeiro lab |
| **Ambiente** | Abaixo |

### Conhecimento (este lab)

- Fazer **GET/POST** com JSON (`curl` ou navegador em `/docs`).
- Saber que **pod** ≈ container rodando no Kubernetes (detalhe no [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md) e no contexto [Kubernetes](../ebook/capitulos/02-evolucao-containers-kubernetes.md)).

### Labs anteriores

- Nenhum.

### Ambiente

- **Docker** rodando (`docker ps` sem erro).
- **[kind](https://kind.sigs.k8s.io/)** e **`kubectl`** instalados.
- Repositório clonado; ~4 GB de disco para imagens; **≥ 4 GB RAM livres** para o cluster.

**Sem *kind*:** `docker compose up --build` na raiz — mesmas APIs, sem objetos Kubernetes (ambiente mais leve).

## Passos

### 1. Criar o cluster

```bash
kind create cluster --name banco-lab --config deploy/kind/cluster-config.yaml
```

### 2. Build e carregar imagens

```bash
./scripts/build-load-kind.sh
```

*(Ou manualmente: `docker build -t servico-pix:lab apps/servico-pix` e `kind load docker-image servico-pix:lab --name banco-lab` para cada serviço.)*

### 3. Aplicar manifests

```bash
kubectl apply -k deploy/k8s
kubectl -n core-banking get pods -w
```

Aguarde `READY 1/1` nos dois Deployments.

### 4. Port-forward e teste

```bash
kubectl -n core-banking port-forward svc/servico-pix 8000:8000
```

Em outro terminal:

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-00-001' \
  -d '{"account_id":"acc_demo","amount":10.5,"destination":"acc_dest_1"}' | jq .
```

## Deu certo quando

- [ ] Pods `servico-pix` e `servico-limites` estão `Running`.
- [ ] Resposta JSON com status de aprovação/rejeição coerente (conta `acc_demo` existe no mock de limites).
- [ ] `kubectl logs -n core-banking deploy/servico-pix` não mostra erro de conexão com limites.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| `ImagePullBackOff` | Rode `./scripts/build-load-kind.sh` de novo. |
| timeout ao chamar limites | Confira `LIMITES_URL` no Deployment do *Pix* (`servico-limites.core-banking.svc.cluster.local:8000`). |
| port-forward fecha | Verifique se o pod do *Pix* ainda está `Running`. |

## Próximo passo

[Lab 01 — Toxiproxy e resiliência](lab-01-toxiproxy-resiliencia.md) ou, no laptop sem kind, `docker compose up --build` ([`README.md`](../README.md)).
