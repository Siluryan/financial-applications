# Apache Kafka no cluster (kind)

Complemento ao **Módulo 2** / laboratório Kafka (broker no **kind**; no laptop use o `docker-compose.yml` da raiz). Roteiro completo no [`PLANO_DE_ESTUDO.md`](../../PLANO_DE_ESTUDO.md#estudo-kafka).

Os manifests em [`deploy/k8s/`](../k8s/) **não** incluem Kafka por padrão (economia de RAM no laptop). Para estudar **Strimzi**, **Helm** ou operadores, suba o broker num namespace dedicado (ex.: `kafka`) e aponte o *servico-pix* com:

- `KAFKA_BOOTSTRAP_SERVERS` — ex.: `my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092`
- `KAFKA_TOPIC_PIX_INICIADO` — default `pix.iniciado`

## Strimzi (recomendado para cluster Kubernetes)

1. Instale o operador Strimzi ([quick start](https://strimzi.io/quickstarts/)).
2. Aplique um `Kafka` single-node para lab (reduza réplicas e volumes no CR).
3. Crie o tópico `pix.iniciado` via `KafkaTopic` ou auto-criação no primeiro `send`.

## Helm Bitnami (alternativa mais rápida no lab)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install lab-kafka bitnami/kafka -n kafka --create-namespace \
  --set replicaCount=1 --set controller.replicaCount=1
```

Consulte os valores do chart para o **bootstrap** interno ao cluster.

## Teste rápido a partir de um pod

```bash
kubectl -n core-banking run -it --rm kcat --image=edenhill/kcat:1.7.1 --restart=Never -- \
  kcat -b <bootstrap-host>:9092 -t pix.iniciado -C -o beginning
```

*(Substitua `<bootstrap-host>` pelo Service DNS do seu Kafka.)*

## Leitura

- [Documentação Apache Kafka](https://kafka.apache.org/documentation/)
- [Strimzi](https://strimzi.io/documentation/)
