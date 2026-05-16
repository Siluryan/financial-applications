# Apps de laboratório (Python)

APIs **FastAPI** para a espinha dorsal do [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md#espinha-dorsal).

| Serviço | Porta (host Compose) | Função |
|---------|----------------------|--------|
| `servico-limites` | 8001 | `GET /v1/limits/{account_id}` — mock + traces OTel |
| `servico-pix` | 8000 | `POST /v1/pix` — **Tenacity**, **pybreaker**, idempotência, **outbox** |
| `worker-outbox-relay` | — | Publica `outbox` → Kafka (span `outbox.publish`) |
| `servico-credito` | 8002 | `GET /v1/score` — canary (`SERVICE_VERSION`) |

## Stack no Docker Compose

`docker compose up --build` sobe: **Kafka**, **Postgres**, **Redis**, **Jaeger**, **OTel Collector**, apps e relay.

- Jaeger UI: http://127.0.0.1:16686  
- *Pix* exporta OTLP para o Collector → Jaeger  
- Resposta aprovada: `"kafka": "outbox_pending"` (relay publica em segundos)

## Variáveis — `servico-pix`

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `LIMITES_URL` | `http://127.0.0.1:8001` | Base do serviço de limites |
| `HTTP_TIMEOUT` | `2.0` | Timeout httpx (sync no breaker) |
| `DATABASE_URL` | — | Postgres — ativa outbox + idempotência SQL |
| `REDIS_URL` | — | Cache de idempotência |
| `PIX_USE_OUTBOX` | `true` se `DATABASE_URL` | Grava evento na tabela `outbox` |
| `PIX_SYNC_KAFKA` | `false` | Se `true`, publish direto na HTTP (legado lab) |
| `KAFKA_BOOTSTRAP_SERVERS` | — | Broker para relay ou sync |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | ex. `http://otel-collector:4317` |
| `BREAKER_FAIL_MAX` | `5` | Falhas antes de abrir circuito |
| `BREAKER_RESET_TIMEOUT` | `30` | Segundos em open → half-open |

## Variáveis — `worker-outbox-relay`

| Variável | Obrigatória |
|----------|-------------|
| `DATABASE_URL` | sim |
| `KAFKA_BOOTSTRAP_SERVERS` | sim |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | não |

## Teste rápido

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: demo-outbox-001' \
  -d '{"account_id":"acc_demo","amount":10.5,"destination":"acc_dest_1"}' | jq .

# Mesma chave — replay idempotente
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: demo-outbox-001' \
  -d '{"account_id":"acc_demo","amount":10.5,"destination":"acc_dest_1"}' | jq .

docker compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 --topic pix.iniciado --from-beginning --max-messages 3
```

## Build kind

```bash
docker build -t servico-pix:lab apps/servico-pix
docker build -t worker-outbox-relay:lab apps/worker-outbox-relay
kind load docker-image servico-pix:lab worker-outbox-relay:lab --name banco-lab
```

No kind, configure `pix-dados` Secret com `DATABASE_URL` e ligue `PIX_USE_OUTBOX=true` no Deployment do *Pix*.
