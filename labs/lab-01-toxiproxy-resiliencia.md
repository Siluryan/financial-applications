# Lab 01 — Toxiproxy, Tenacity e circuit breaker

[← Índice dos labs](README.md) · **Onda 1** · [Módulo 1](../modulos/modulo-01-resiliencia.md) · [`PLANO` §1.3](../PLANO_DE_ESTUDO.md#modulo-1)

## Objetivo

Colocar *Toxiproxy* entre *Pix* e *Limites*, injetar latência/falha e validar timeout + retry com jitter + circuit breaker no Python.

## Antes de começar

### Conhecimento (este lab)

- *Pix* chama *Limites* por HTTP **antes** de responder ao cliente (fluxo síncrono).
- Ideia de **timeout** e **retry** ([Módulo 1](../modulos/modulo-01-resiliencia.md)).
- Ler status HTTP **200** vs **503** no `curl`.

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — *Pix* e *Limites* respondem (*kind* ou `docker compose`).

### Ambiente

- `curl`; `jq` (opcional).
- *Toxiproxy* conforme passos (manifest em `deploy/toxiproxy/` no *kind*, ou Compose).

## Passos (kind)

### 1. Subir o Toxiproxy

```bash
kubectl apply -f deploy/toxiproxy/deployment.yaml
kubectl -n core-banking wait --for=condition=available deployment/toxiproxy --timeout=120s
```

### 2. Criar o proxy (API → limites)

Port-forward da API do Toxiproxy:

```bash
kubectl -n core-banking port-forward svc/toxiproxy 8474:8474
```

Em outro terminal, registre o upstream:

```bash
curl -sS -X POST http://127.0.0.1:8474/proxies -d '{
  "name": "limites",
  "listen": "0.0.0.0:8666",
  "upstream": "servico-limites.core-banking.svc.cluster.local:8000",
  "enabled": true
}'
```

### 3. Apontar o *Pix* para o proxy

```bash
kubectl -n core-banking set env deployment/servico-pix \
  LIMITES_URL=http://toxiproxy.core-banking.svc.cluster.local:8666 \
  HTTP_TIMEOUT=2
kubectl -n core-banking rollout status deployment/servico-pix
```

### 4. Baseline (sem toxic)

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-01-ok' \
  -d '{"account_id":"acc_demo","amount":1,"destination":"x"}' | jq .
```

*(Mantenha `port-forward` do *Pix* na 8000 como no lab 00.)*

### 5. Injetar latência

Com API do Toxiproxy acessível em `8474`:

```bash
curl -sS -X POST http://127.0.0.1:8474/proxies/limites/toxics -d '{
  "name": "latencia",
  "type": "latency",
  "attributes": { "latency": 3000, "jitter": 500 }
}'
```

Repita o `POST /v1/pix` e observe tempo de resposta e logs do *Pix*.

### 6. Implementar resiliência no código (sua entrega)

No `apps/servico-pix`:

1. Adicione ao `requirements.txt`: `tenacity`, `pybreaker`.
2. Envolva a chamada `httpx` a limites com `@retry(wait=wait_exponential_jitter(...))`.
3. Envolva com `pybreaker` e logue mudança de estado em JSON.

Referência de parâmetros no [módulo 1](../modulos/modulo-01-resiliencia.md).

### 7. Remover toxic

```bash
curl -sS -X DELETE http://127.0.0.1:8474/proxies/limites/toxics/latencia
```

## Passos (Docker Compose — só caos, sem k8s)

Suba a stack e use *Toxiproxy* no host apontando para `servico-limites:8001` publicado no laptop (documente o proxy local conforme [documentação Toxiproxy](https://github.com/Shopify/toxiproxy)).

## Deu certo quando

- [ ] Com latência de 3 s e `HTTP_TIMEOUT=2`, o *Pix* falha de forma controlada (sem travar o processo).
- [ ] Com Tenacity + jitter, retentativas não sincronizam em “rajada” visível nos logs de *Limites*.
- [ ] Com toxic severo, o circuit breaker abre e respostas ficam *fail-fast* (sem esperar 3 s em toda requisição).
- [ ] Ao remover o toxic, o sistema volta ao normal sem reiniciar o cluster.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| `connection refused` no proxy | Proxy criado? *Pix* usa porta **8666** do Service `toxiproxy`? |
| latência não aparece | Toxic na proxy certa (`limites`)? API na 8474? |
| breaker nunca abre | Reduza limiar no pybreaker ou use toxic `timeout` |

## Próximo passo

[Lab 02b — Kafka](lab-02b-kafka-consumer.md) (Onda 2) ou [Lab 02 — OTel + Jaeger](lab-02-opentelemetry-jaeger.md) (Onda 3).
