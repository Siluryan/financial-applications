# financial-applications

Laboratório para **engenheiros de cloud**: o repositório traz **aplicações Python mínimas** (FastAPI) e **Apache Kafka** (Compose) para você investir tempo em **Kubernetes (kind)**, **Istio**, *Toxiproxy*, **OpenTelemetry**, **GitOps**, **Kyverno**, etc. O roteiro completo — com a **espinha dorsal** (*kind*, ondas 0–7, *mapa módulos ↔ ondas*) — está em [`PLANO_DE_ESTUDO.md`](PLANO_DE_ESTUDO.md#espinha-dorsal) (tabela de ondas: [`#ondas-principio`](PLANO_DE_ESTUDO.md#ondas-principio)).

## O que já existe aqui

| Pasta | Conteúdo |
|-------|-----------|
| [`apps/`](apps/) | `servico-pix`, `servico-limites`, `servico-credito` + `README` das APIs |
| [`deploy/k8s/`](deploy/k8s/) | Manifests **Kustomize** (`namespace: core-banking`, Deployments com `resources` e probes) |
| [`deploy/kafka/`](deploy/kafka/) | Guia para subir **Apache Kafka** no kind (Strimzi / Helm) |
| [`scripts/build-load-kind.sh`](scripts/build-load-kind.sh) | Build das imagens `:lab` e `kind load docker-image` |
| [`docker-compose.yml`](docker-compose.yml) | Sobe os três serviços no laptop **sem** Kubernetes |
| [`modulos/`](modulos/) | Guias expandidos (Módulo **0** + 1–7: trade-offs, anti-patterns, produção real) |
| [`labs/`](labs/) | **Laboratórios passo a passo** + [exercícios de falha](labs/EXERCICIOS-FALHA-E-TROUBLESHOOTING.md) |
| [`REFERENCIAS.md`](REFERENCIAS.md) | Bibliografia ampliada (ABNT/IEEE) |
| [`ebook/CONVENCOES_EDITORIAIS.md`](ebook/CONVENCOES_EDITORIAIS.md) | Nomenclatura *Pix* / `servico-pix` e termos técnicos |
| [`ebook/`](ebook/README.md) | **EPUB/PDF** — teoria e lab **integrados** por módulo (`scripts/build-ebook.sh`) |
| [`catalog-info.yaml`](catalog-info.yaml) | Entrada **Backstage** (`Location` → `catalog-entities.yaml`) |

**Imagens esperadas no kind:** `servico-pix:lab`, `servico-limites:lab`, `servico-credito:lab` (`imagePullPolicy: IfNotPresent` após `kind load`).

## Subir local (Docker Compose)

```bash
docker compose up --build
```

- *Pix*: `http://127.0.0.1:8000/docs`  
- *Limites*: `http://127.0.0.1:8001/docs`  
- *Crédito*: `http://127.0.0.1:8002/docs`  
- **Kafka** (brokers): `localhost:9092` (acesso de **hosts** externos exige listener adicional; no Compose o *Pix* usa `kafka:9092` na rede interna).

Exemplo de chamada ao *Pix*:

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: demo-001' \
  -d '{"account_id":"acc_demo","amount":10.5,"destination":"acc_dest_1"}' | jq .
```

Resposta aprovada inclui `"kafka": "outbox_pending"` (relay publica em **`pix.iniciado`**) ou `"published"` se `PIX_SYNC_KAFKA=true`.

**Jaeger:** http://127.0.0.1:16686 (com `docker compose up`).

Ler o tópico (outro terminal, com Compose no ar):

```bash
docker compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic pix.iniciado \
  --from-beginning
```

## Subir no kind (resumo)

```bash
kind create cluster
./scripts/build-load-kind.sh
kubectl apply -k deploy/k8s
kubectl -n core-banking port-forward svc/servico-pix 8000:8000
```

Em outro terminal, use o mesmo `curl` apontando para `http://127.0.0.1:8000`.

O `deploy/k8s` **não** inclui Kafka por padrão: para o cluster kind, siga [`deploy/kafka/README.md`](deploy/kafka/README.md) e defina `KAFKA_BOOTSTRAP_SERVERS` no Deployment do *Pix*.

Para mudar a URL de limites (ex.: *Toxiproxy* no meio do caminho), edite o `Deployment` do *Pix* ou aplique um patch que redefine a env `LIMITES_URL`.

## Licença

Veja o arquivo [`LICENSE`](LICENSE).
