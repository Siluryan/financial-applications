# Lab 02b — Apache Kafka (tópico, consumer, lag)

[← Índice dos labs](README.md) · [Módulo 2](../modulos/modulo-02-observabilidade.md)

## Objetivo

Publicar eventos em `pix.iniciado`, consumir com um worker, medir **consumer lag** e observar como falha no broker afeta a resposta HTTP do *Pix* sem bloquear o cliente.

Mensageria desacopla o caminho **síncrono** (aprovar na hora) do **assíncrono** (antifraude, notificação). O cliente recebe 200 antes do consumer terminar — por isso lag alto pode coexistir com API “rápida”, um padrão perigoso se ninguém monitorizar a fila.

**Vocabulário (fixe antes dos comandos):**

| Termo | Significado |
|-------|-------------|
| **Tópico** | Canal nomeado (`pix.iniciado`) |
| **Consumer group** | Conjunto de consumidores que dividem partições (`lab-worker`) |
| **Lag** | Mensagens publicadas − processadas |
| **Broker** | Nó que persiste partições |

**Tempo estimado:** 90–150 min (inclui implementação do worker).

## Antes de começar

### Conhecimento (este lab)

- Evento `pix.iniciado` é publicado **depois** da resposta HTTP (não trava a UI).
- [Fundamentos — Kafka](../ebook/capitulos/fundamentos-kafka.md) e [Módulo 2](../modulos/modulo-02-observabilidade.md).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) ou Compose — *Pix* responde.
- [Lab 02](lab-02-opentelemetry-jaeger.md) recomendado para correlacionar trace no consumer.

### Ambiente

- **`docker compose`** (caminho mais rápido) **ou** Kafka no *kind* ([`deploy/kafka/README.md`](../deploy/kafka/README.md)).
- **~2 GB RAM** extras; com 8 GB no total, não suba Istio + Kafka + Jaeger em simultâneo.

## Passos (Docker Compose)

### 1. Subir a stack

```bash
docker compose up --build -d
```

Aguarde `healthy` nos serviços críticos (`docker compose ps`). O broker Kafka demora alguns segundos a aceitar conexões.

### 2. Publicar um *Pix* aprovado

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-02b-001' \
  -d '{"account_id":"acc_demo","amount":10,"destination":"acc_dest_1"}' | jq .
```

**Campo a observar:** `"kafka": "published"` (modo síncrono legado) ou `"outbox_pending"` (modo outbox, lab 07b). Anote qual modo o seu `docker-compose.yml` activa.

### 3. Ler o tópico (inspeção)

Console consumer para ver mensagens brutas:

```bash
docker compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic pix.iniciado \
  --from-beginning \
  --max-messages 3
```

**Esperado:** JSON com `account_id`, `idempotency_key`, metadados do evento. Se vazio, o *Pix* não publicou — verifique env `KAFKA_BOOTSTRAP_SERVERS` e logs do *Pix*.

### 4. Consumer group e lag

Produza várias mensagens (repita o `curl` com chaves idempotentes diferentes: `lab-02b-002`, `003`, …).

```bash
docker compose exec kafka /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --describe \
  --group lab-worker
```

O group `lab-worker` só aparece **depois** do passo 5 (worker a correr). Colunas úteis: `LAG` por partição — zero significa fila vazia para esse consumidor.

### 5. Worker consumer

O **relay outbox** (`apps/worker-outbox-relay/`) publica no tópico. Neste passo você implementa o **consumer de domínio** que processa `pix.iniciado`.

Crie o projeto `apps/worker-pix-consumer/` com `aiokafka`:

- Consumer group: `lab-worker`
- Tópico: `pix.iniciado`
- Log JSON por mensagem (`account_id`, `idempotency_key`)
- **Deduplicar** por `idempotency_key` antes de efeito colateral (ligação com Módulo 4)
- Propagar headers W3C e correlacionar ao trace do *Pix* ([Lab 02](lab-02-opentelemetry-jaeger.md))

Rode no Compose com `KAFKA_BOOTSTRAP_SERVERS=kafka:9092`.

**Publicação:** com outbox (`PIX_USE_OUTBOX=true`), mensagens vêm do relay; com `PIX_SYNC_KAFKA=true`, o *Pix* publica directo — compare no [Lab 07b](lab-07b-outbox-kafka.md).

### 6. Simular broker fora

```bash
docker compose stop kafka
```

Chame o *Pix* de novo. **Observe** o campo `kafka` na resposta (`error`, `degraded`, `outbox_pending`). O HTTP deve continuar a responder — o utilizador não fica à espera do broker.

Suba Kafka (`docker compose start kafka`) e verifique se mensagens pendentes na outbox ou na fila são processadas.

## Passos (kind)

1. Instale Kafka conforme [`deploy/kafka/README.md`](../deploy/kafka/README.md).
2. No Deployment do *Pix*, defina `KAFKA_BOOTSTRAP_SERVERS`.
3. Use `kcat` ou console consumer a partir de um pod — comandos no README do Kafka.

## Exercícios avançados (nível SRE)

### A1 — ISR e `acks`

Documente impacto de follower fora do ISR; teste `acks=all` com broker parado.

### A2 — Rebalance storm

Duas réplicas do worker + restart durante carga; observe lag no `kafka-consumer-groups`.

### A3 — `max.poll.interval`

`sleep(120)` no consumer antes do commit — observe expulsão do grupo.

### A4 — Ordem por chave

Dez *Pix* com mesmo `account_id` vs contas diferentes — ordem e paralelismo.

### A5 — Tópico compactado

Tópico `conta.estado` com `cleanup.policy=compact`.

### A6 — Poison pill

Mensagem inválida → lag sobe → política DLQ (completa no lab 07b).

## Deu certo quando

- [ ] Mensagem JSON em `pix.iniciado` após *Pix* aprovado.
- [ ] Worker consome e regista `idempotency_key` / `account_id`.
- [ ] Com broker parado, *Pix* responde e indica falha ou pendência Kafka.
- [ ] Você explica **lag** e por que at-least-once exige idempotência no consumer.
- [ ] Pelo menos três exercícios avançados A1–A6 concluídos com evidência escrita.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Tópico vazio | Logs do *Pix*; `KAFKA_BOOTSTRAP_SERVERS`; modo outbox vs sync |
| Group não existe | Subir worker do passo 5 |
| Lag infinito | Worker parado ou a falhar em loop — ver logs do consumer |

## Próximo passo

[Lab 04 — Redis e Postgres](lab-04-redis-postgres-idempotencia.md) · [Lab 07b — Outbox/DLQ](lab-07b-outbox-kafka.md)
