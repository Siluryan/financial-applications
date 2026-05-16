# Lab 02b — Apache Kafka (tópico, consumer, lag)

[← Índice dos labs](README.md) · **Onda 2** · [Módulo 2](../modulos/modulo-02-observabilidade.md) · [`PLANO` §2.5](../PLANO_DE_ESTUDO.md#estudo-kafka)

## Objetivo

Publicar `pix.iniciado`, consumir com um worker, medir **consumer lag** e correlacionar falha no broker com resposta do *Pix*.

**Tópico** é a caixa do correio (`pix.iniciado`). **Consumer group** é a equipe de carteiros com o mesmo nome (`lab-worker`): o Kafka divide as cartas entre eles; se um carteiro some, as cartas são redistribuídas (**rebalance**). **Lag** é quantas cartas ainda estão na caixa esperando leitura — API rápida com lag alto significa fila acumulada no fundo. **Broker** é o armazém que guarda as mensagens; se cair, o *Pix* pode responder “degraded” enquanto o outbox (lab 07b) segura o que já foi gravado no Postgres.

## Antes de começar

### Conhecimento (este lab)

- Evento `pix.iniciado` = mensagem assíncrona depois do HTTP (não trava a tela).
- Noções de **tópico**, **consumer group** e **lag** — explicadas no objetivo e no [Módulo 2](../modulos/modulo-02-observabilidade.md).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou Compose — *Pix* publica (ou enfileira) evento.
- [Lab 02](lab-02-opentelemetry-jaeger.md) recomendado se quiser correlacionar trace no consumer.

### Ambiente

- **`docker compose`** (caminho mais rápido) **ou** Kafka no *kind* ([`deploy/kafka/README.md`](../deploy/kafka/README.md)).
- **~2 GB RAM** extras para o broker; não subir Istio no mesmo momento se tiver 8 GB no total.

## Passos (Docker Compose)

### 1. Subir a stack

```bash
docker compose up --build -d
```

### 2. Publicar um *Pix* aprovado

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-02b-001' \
  -d '{"account_id":"acc_demo","amount":10,"destination":"acc_dest_1"}' | jq .
```

Campo `"kafka": "published"` indica envio ao tópico.

### 3. Ler o tópico

```bash
docker compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic pix.iniciado \
  --from-beginning \
  --max-messages 3
```

### 4. Consumer group e lag

Em outro terminal, produza várias mensagens (repita o `curl` com chaves idempotentes diferentes).

```bash
docker compose exec kafka /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --describe \
  --group lab-worker
```

*(O group `lab-worker` existirá depois que você subir um consumer — passo 5.)*

### 5. Worker mínimo (sua entrega)

Crie `apps/worker-pix-consumer/` com `aiokafka`:

- Consumer group: `lab-worker`
- Tópico: `pix.iniciado`
- Log JSON por mensagem; opcional: header `traceparent` do payload

Rode no Compose com `KAFKA_BOOTSTRAP_SERVERS=kafka:9092`.

### 6. Simular broker lento / fora

```bash
docker compose stop kafka
```

Chame o *Pix* de novo e observe o campo `kafka` na resposta (`error` vs `published`).

## Passos (kind)

1. Instale Kafka conforme [`deploy/kafka/README.md`](../deploy/kafka/README.md).
2. No Deployment do *Pix*, defina `KAFKA_BOOTSTRAP_SERVERS`.
3. Use `kcat` ou console consumer a partir de um pod (comando no README do Kafka).

## Deu certo quando

- [ ] Mensagem JSON aparece em `pix.iniciado` após *Pix* aprovado.
- [ ] Worker consome e loga `idempotency_key` / `account_id`.
- [ ] Com broker parado, *Pix* ainda responde (degraded) e indica falha Kafka na resposta.
- [ ] Você explica o que é **lag** e por que at-least-once exige idempotência no consumer ([Módulo 4](../modulos/modulo-04-consistencia.md)).

## Próximo passo

[Lab 04 — Redis e Postgres](lab-04-redis-postgres-idempotencia.md) · [Lab 02 — Jaeger](lab-02-opentelemetry-jaeger.md)
