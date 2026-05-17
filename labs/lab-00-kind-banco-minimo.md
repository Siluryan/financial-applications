# Lab 00 — Banco mínimo no kind

[← Índice dos labs](README.md) · **Laboratório 00** · [Módulo 0 — fundamentos](../modulos/modulo-00-fundamentos-distribuidos.md)

## Objetivo

Subir *servico-pix* e *servico-limites* num cluster Kubernetes local (*kind*) e validar uma transferência *Pix* ponta a ponta por HTTP.

Este é o **primeiro laboratório hands-on** do percurso. Até aqui você leu (ou consultará) os blocos *Fundamentos* sobre HTTP e Docker/Kubernetes. Aqui o objetivo não é decorar objetos do Kubernetes, mas **confirmar na prática** que dois serviços conversam dentro do cluster com os mesmos nomes DNS que aparecem nos manifests — o mesmo padrão que usará nos módulos de resiliência, mesh e GitOps.

**Ao terminar**, você deve conseguir: explicar qual Pod responde em cada porta; ler logs de falha de conexão entre serviços; e repetir o `curl` do *Pix* sem depender da UI do Swagger (embora `/docs` continue útil para inspecionar o contrato).

**Tempo estimado:** 45–90 min na primeira vez (inclui download de imagens e criação do cluster).

## Antes de começar

| Tipo | Este lab |
|------|----------|
| **Conhecimento** | Ver [`ebook/PRE-REQUISITOS.md`](../ebook/PRE-REQUISITOS.md) e [Fundamentos — HTTP](../ebook/capitulos/fundamentos-http-fastapi.md) / [Docker/K8s](../ebook/capitulos/fundamentos-docker-kubernetes.md) |
| **Labs anteriores** | Nenhum — é o primeiro lab |
| **Ambiente** | Abaixo |

### Conhecimento (este lab)

- Enviar **GET/POST** com corpo JSON (`curl` ou navegador em `http://127.0.0.1:8000/docs` após o port-forward).
- Entender que um **Pod** é a unidade mínima agendada no Kubernetes — normalmente um container da aplicação (detalhe no [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md) e no contexto [Kubernetes](../ebook/capitulos/02-evolucao-containers-kubernetes.md)).
- Reconhecer que o *Pix* **consulta** *Limites* antes de responder ao cliente: fluxo síncrono, não fila.

### Labs anteriores

Nenhum.

### Ambiente

- **Docker** em execução (`docker ps` sem erro).
- **[kind](https://kind.sigs.k8s.io/)** e **`kubectl`** instalados e no `PATH`.
- Repositório clonado; ~4 GB de disco livre para imagens; **≥ 4 GB de RAM** disponíveis para o cluster.
- **`jq`** para formatar JSON no terminal.

**Sem *kind*:** na raiz do repositório, `docker compose up --build` sobe as mesmas APIs na máquina local, sem objetos Kubernetes. O restante do curso assume *kind* para mesh, políticas e GitOps; no portátil com 8 GB de RAM, Compose é aceitável nos módulos 1–2.

## Visão do que será criado

```text
[Laptop]  port-forward :8000
              │
              ▼
     Service servico-pix (core-banking)
              │
              │  HTTP GET /v1/limits/{account_id}
              ▼
     Service servico-limites (core-banking)
```

O Deployment do *Pix* recebe `LIMITES_URL` apontando para o DNS interno do Service de *Limites*, não para `localhost` dentro do Pod.

## Passos

### 1. Criar o cluster

O ficheiro `deploy/kind/cluster-config.yaml` define portas e recursos do cluster de estudo. O nome `banco-lab` permite vários clusters kind no mesmo portátil sem confusão.

```bash
kind create cluster --name banco-lab --config deploy/kind/cluster-config.yaml
```

**O que verificar:** `kubectl cluster-info` responde sem erro; `kubectl get nodes` mostra um nó `Ready`.

Se o comando falhar por porta ocupada ou Docker sem permissão, corrija o ambiente antes de avançar — os passos seguintes dependem deste cluster.

### 2. Build e carregar imagens

Os manifests referem imagens locais (`servico-pix:lab`, etc.). O registry do *kind* não puxa do Docker Hub automaticamente: é preciso **construir** e **carregar** cada imagem no nó.

```bash
./scripts/build-load-kind.sh
```

O script percorre `apps/` e executa `docker build` + `kind load docker-image` para o cluster `banco-lab`.

*(Alternativa manual: `docker build -t servico-pix:lab apps/servico-pix` e `kind load docker-image servico-pix:lab --name banco-lab` para cada serviço.)*

**O que observar:** ao final, `docker images | grep lab` lista as tags construídas.

### 3. Aplicar manifests

O diretório `deploy/k8s` usa Kustomize (`kubectl apply -k`). Isso aplica namespace, Deployments, Services e ConfigMaps numa ordem consistente — reproduzível em qualquer máquina com o mesmo Git.

```bash
kubectl apply -k deploy/k8s
kubectl -n core-banking get pods -w
```

Aguarde até ambos os Deployments mostrarem `READY 1/1`. O `-w` (watch) ajuda a ver reinícios: se um Pod entrar em `CrashLoopBackOff`, interrompa com Ctrl+C e consulte a secção Troubleshooting.

**O que observar:**

- Namespace `core-banking` criado.
- Pods `servico-pix-…` e `servico-limites-…` em `Running`.
- Nenhum `ImagePullBackOff` (indica imagem não carregada no passo 2).

### 4. Port-forward e teste

O Service do *Pix* é `ClusterIP` por defeito: não fica exposto no host até fazer port-forward ou Ingress. Para o lab, o port-forward é o caminho mais simples.

Num terminal, deixe este processo aberto:

```bash
kubectl -n core-banking port-forward svc/servico-pix 8000:8000
```

Noutro terminal, envie um *Pix* de teste:

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-00-001' \
  -d '{"account_id":"acc_demo","amount":10.5,"destination":"acc_dest_1"}' | jq .
```

**Resposta esperada (estrutura):** JSON com `status` (`approved` ou `rejected`), campos de negócio e, conforme configuração, indicação de Kafka ou limites. Para `acc_demo`, o mock de *Limites* costuma aprovar valores modestos.

**Validação adicional:**

```bash
kubectl -n core-banking logs deploy/servico-pix --tail=30
kubectl -n core-banking logs deploy/servico-limites --tail=20
```

Nos logs do *Pix* não deve aparecer `connection refused` ao resolver `servico-limites`. Se aparecer, o `LIMITES_URL` no Deployment está incorreto.

Abra `http://127.0.0.1:8000/docs` no navegador e compare o contrato OpenAPI com o corpo que enviou no `curl`.

## Deu certo quando

- [ ] Pods `servico-pix` e `servico-limites` estão `Running` com `READY 1/1`.
- [ ] `POST /v1/pix` devolve JSON coerente (aprovação ou rejeição explicada).
- [ ] Logs do *Pix* não mostram falha persistente de ligação a *Limites*.
- [ ] Você consegue indicar, num desenho ou em texto, o caminho DNS `servico-limites.core-banking.svc.cluster.local`.

## Troubleshooting

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| `ImagePullBackOff` | Imagem não existe no nó kind | `./scripts/build-load-kind.sh` de novo |
| `CrashLoopBackOff` | App não arranca (env, porta) | `kubectl logs` no Pod; ver `LIMITES_URL` |
| timeout ao chamar limites | URL errada ou *Limites* down | `kubectl get svc,endpoints -n core-banking` |
| `connection refused` no curl | Port-forward não ativo | Repetir passo 4 no primeiro terminal |
| port-forward encerra | Pod reiniciou ou terminal fechou | Verificar Pod `Running`; reabrir port-forward |

## Próximo passo

[Lab 01 — Toxiproxy e resiliência](lab-01-toxiproxy-resiliencia.md). No laptop sem *kind*, continue com `docker compose up --build` ([`README.md`](../README.md)) e volte ao cluster quando for estudar mesh ou políticas.
