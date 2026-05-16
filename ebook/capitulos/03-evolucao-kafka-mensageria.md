*Contexto histórico — leia antes do [Módulo 2](../../modulos/modulo-02-observabilidade.md) (parte Kafka).*

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

- produtor com **acks** configuráveis;
- consumidor com **commit** de offset;
- **at-least-once** comum → **idempotência** no consumer (Módulo 4).

**Exactly-once** entre Kafka e banco externo é projeto de engenharia (transações, outbox), não checkbox do broker.

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

## Ligação com o livro

- [Módulo 2](../../modulos/modulo-02-observabilidade.md) — lag, traces no publish
- [Módulo 4](../../modulos/modulo-04-consistencia.md) — idempotência no consumer
- [Lab 02b](../../labs/lab-02b-kafka-consumer.md)
- [Lab 07b](../../labs/lab-07b-outbox-kafka.md)

Leia também [observabilidade](04-evolucao-observabilidade.md) (mesmo módulo) → [Módulo 2](../../modulos/modulo-02-observabilidade.md).
