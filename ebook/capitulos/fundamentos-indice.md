# Onde ler os fundamentos

O vocabulário das ferramentas não está concentrado na Introdução. Cada bloco **Fundamentos** precede o módulo que o emprega.

| Antes de | Capítulo | Ferramentas / ideias |
|----------|----------|----------------------|
| **Módulo 0** | [HTTP e FastAPI](fundamentos-http-fastapi.md) | REST, `curl`, rotas, Pydantic |
| **Módulo 0** | [Docker e Kubernetes](fundamentos-docker-kubernetes.md) | Imagem, Pod, Service, `kubectl` |
| **Módulo 1** | [Resiliência](fundamentos-resiliencia.md) | Timeout, retry, circuit breaker, Toxiproxy |
| **Módulo 2** | [OpenTelemetry](fundamentos-opentelemetry.md) | Trace, span, OTLP, Jaeger |
| **Módulo 2** | [Apache Kafka](fundamentos-kafka.md) | Tópico, partição, consumer group, lag |
| **Módulo 3** | [Istio e mesh](fundamentos-istio-mesh.md) | Sidecar, mTLS, políticas |
| **Módulo 4** | [PostgreSQL e Redis](fundamentos-postgres-redis.md) | Transação, outbox, cache idempotente |
| **Módulo 5** | [GitOps e deploy](fundamentos-gitops-deploy.md) | Canary, Argo CD, rolling update |

O **Módulo 0** trata conceitos distribuídos (CAP, idempotência, SLO), sem bloco de ferramenta. O **Módulo 7** reaproveita Postgres, Kafka e OTel e aprofunda conformidade e operação.
