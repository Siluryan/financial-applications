## Filas antes do Kafka

Sistemas financeiros sempre usaram **filas**: IBM MQ, RabbitMQ, ActiveMQ, TIBCO. O padrão mental era **fila por consumidor** — mensagem consumida, some. Escala vertical, operação madura, contratos rígidos.

O problema em escala de **eventos** e **replay**: analytics, antifraude e novos consumidores queriam ler o histórico sem drenar a fila dos outros. “Apagar ao ler” virou gargalo organizacional.

## Origem no LinkedIn (2010–2011)

**Kafka** nasceu no LinkedIn para **pipeline de atividade** em volume enorme: rastreamento de cliques, métricas, ingestão para Hadoop. Open source em **2011**. A aposta central: tratar stream como **log append-only particionado**, não como fila clássica.

Analogia que fixa: **caderno de registro** onde você só escreve no fim; leitores guardam marcador (offset) de onde pararam. Vários leitores podem ler o mesmo caderno em velocidades diferentes.

## Log, partição, broker

| Conceito | Ideia |
|----------|--------|
| **Tópico** | Nome do assunto (`pix.iniciado`) |
| **Partição** | Shards ordenados dentro do tópico |
| **Broker** | Servidor que armazena partições |
| **Consumer group** | Equipe que divide partições entre si |
| **Offset** | Posição de leitura de cada consumidor |

Ordem **garantida por partição**, não globalmente no tópico — por isso chaves de mensagem (ex.: `account_id`) importam para *Pix* da mesma conta.

## Semântica de entrega

Kafka não “resolve” duplicidade sozinho. Na prática:

- produtor com **acks** configuráveis e **ISR** em dia;
- consumidor com **commit** de offset após processar;
- **at-least-once** comum → **idempotência** no consumer (Módulo 4);
- **transactional producer** para EOS **entre tópicos Kafka**;
- **outbox** para EOS **Kafka + Postgres**.

**Exactly-once** ponta a ponta (API → banco → fila → consumer → outro banco) é projeto de engenharia — não checkbox do broker.

## ISR e durabilidade (aprofundamento)

Cada partição tem **leader** e **followers**. O conjunto **ISR** (*In-Sync Replicas*) são cópias que acompanham o leader dentro do `replica.lag.time.max.ms`.

- `acks=all` + `min.insync.replicas=2` em cluster de 3 brokers: perda de um nó não para gravação.
- Follower lento **sai do ISR** — não participa de eleição “limpa”.
- **Unclean election** acelera recuperação à custa de perda de mensagens — raro em pagamentos.

## Consumer groups e rebalance storms

O **group coordinator** (broker) e o **group leader** (consumer) negociam quem lê qual partição. **Rebalance** em todo deploy rolling redistribui partições — durante o rebalance, consumo **pausa**.

**Rebalance storm**: muitos restarts + `max.poll.interval.ms` estourado (processamento lento) → grupo nunca estabiliza → **lag** sobe com API verde.

Mitigações modernas: `group.instance.id` (static membership), **cooperative-sticky** assignor, processamento assíncrono com commit consciente.

## Sticky partitioning e tópicos compactados

Sem chave, o produtor pode usar **sticky partitioner** para agrupar mensagens na mesma partição por lote — throughput, não ordem de negócio.

**Log compaction** (`cleanup.policy=compact`) mantém último valor por chave — catálogo de contas, não histórico de *Pix* imutável.

## Poison pill e DLQ

Mensagem que **sempre** falha trava a partição se o consumer reprocessa infinitamente. Padrão: N retries → tópico **DLQ** → alerta → replay manual após fix.

## Schema evolution

**Schema Registry** versiona Avro/Protobuf. Compatibilidade **BACKWARD** (campo novo opcional) é o padrão mais comum. Quebra silenciosa é incidente de madrugada — combine Registry com Pact (Módulo 7).

## Ecossistema que cresceu em volta

| Ferramenta / padrão | Papel |
|---------------------|--------|
| **Schema Registry** | Contrato Avro/Protobuf versionado |
| **Kafka Connect** | Integração com DB e sistemas legados |
| **ksqlDB / Flink / Spark** | Stream processing |
| **Strimzi** | Operador Kafka no Kubernetes |
| **Confluent Platform** | Distribuição comercial e suporte |

No lab: imagem **Apache Kafka** no Compose; no *kind*, README em `deploy/kafka/` aponta Strimzi ou Helm.

## Kafka em bancos

Casos típicos:

- **eventos de pagamento** para antifraude e conciliação;
- **integração** com legado sem acoplar HTTP síncrono;
- **CDC** (*Change Data Capture*) do core banking para projeções.

Riscos reais:

- **lag** alto (fila acumulada) com API aparentemente saudável;
- **rebalance** após deploy de consumer;
- **poison message** sem DLQ;
- mudança de schema sem governança.

Este curso liga Kafka a **outbox** (Módulo 7): gravar negócio e evento na mesma transação Postgres; relay publica depois.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2010–2011 | Kafka no LinkedIn; open source |
| 2014 | Confluent fundada por criadores |
| 2015+ | Adoção massiva em tech; bancos começam POCs |
| 2017 | Kafka 1.0 (protocolo mais estável) |
| 2019+ | Remoção de ZooKeeper em roadmap (KRaft) |
| 2020s | Operadores K8s; streaming como produto |

## Alternativas (quando não é Kafka)

| Tecnologia | Onde brilha |
|------------|-------------|
| **RabbitMQ** | Filas clássicas, routing flexível, volume moderado |
| **NATS / JetStream** | Baixa latência, simplicidade |
| **Pulsar** | Multi-tenancy, tiered storage |
| **SQS / Service Bus** | Managed na nuvem |

Kafka não é obrigatório — mas é o **linguajar comum** em vagas de plataforma e em labs corporativos.
