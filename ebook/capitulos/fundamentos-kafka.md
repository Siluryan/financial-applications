# Fundamentos — Apache Kafka

Este bloco também pertence ao **Módulo 2** (laboratórios 02b e, mais tarde, outbox no 7b). Leia-o depois de [OpenTelemetry](fundamentos-opentelemetry.md) se seguir a ordem do livro.

## Kafka no curso

**Kafka** é um **log distribuído**: mensagens **append-only** por **tópico**, lidas por grupos de consumidores, com retenção configurável. Aqui serve para **desacoplar** a resposta HTTP do *Pix* do processamento lento (antifraude, notificação).

| Conceito | Definição | No lab |
|----------|-----------|--------|
| **Broker** | Nó que armazena partições | `KAFKA_BOOTSTRAP_SERVERS` |
| **Tópico** | Canal nomeado | `pix.iniciado` |
| **Partição** | Subfluxo ordenado | Paralelismo |
| **Offset** | Posição de leitura na partição | “Até onde o grupo leu” |
| **Producer** | Publica mensagens | **Outbox relay** (fluxo preferido) |
| **Consumer** | Processa mensagens | Worker do lab 02b |
| **Consumer group** | Reparte partições entre consumidores | `lab-worker` |

## Entrega e ordem

**At-least-once:** a mensagem pode ser entregue mais de uma vez; o consumidor precisa de **idempotência** ([Módulo 4](fundamentos-postgres-redis.md)).

**Consumer lag:** diferença entre mensagens publicadas e processadas. Lag elevado indica fila a acumular.

**Chave de partição:** a mesma chave (ex. `account_id`) cai na mesma partição — ordem por conta.

## Fluxo no *Pix*

```text
POST /v1/pix → Postgres (outbox) → relay → tópico pix.iniciado → consumer(s)
```

Publicar de forma **síncrona** na thread HTTP (`PIX_SYNC_KAFKA=true`) existe apenas para comparação; o fluxo de referência usa **outbox** (Módulo 7b).

```bash
docker compose exec kafka /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 --describe --group lab-worker
```

Depois vêm o contexto histórico, a teoria do Módulo 2 e os laboratórios 02 e 02b.
