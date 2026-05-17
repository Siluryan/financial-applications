# Laboratórios — passo a passo

Guias **práticos** alinhados aos [módulos](../modulos/): em cada parte do [ebook](../ebook/README.md), a **teoria** (módulo) vem **antes** do lab correspondente. Cada lab inclui contexto, tempo estimado, diagramas quando útil, o que observar após comandos e troubleshooting expandido — não é só checklist de comandos.

| Lab | Ferramenta / tema | Onda | Módulo | Estado no repo |
|-----|-------------------|------|--------|----------------|
| [00 — Banco mínimo no kind](lab-00-kind-banco-minimo.md) | kind, kubectl, Kustomize | **0** | — | `deploy/k8s` pronto |
| [01 — Toxiproxy e resiliência](lab-01-toxiproxy-resiliencia.md) | *Toxiproxy*, Tenacity, pybreaker | **1** | [1](../modulos/modulo-01-resiliencia.md) | `resilience.py` + `deploy/toxiproxy/` |
| [02 — OpenTelemetry + Jaeger](lab-02-opentelemetry-jaeger.md) | OTel, Jaeger, logs JSON | **3** | [2](../modulos/modulo-02-observabilidade.md) | `telemetry.py` — ativar `OTEL_*` |
| [02b — Kafka consumer](lab-02b-kafka-consumer.md) | Kafka, *aiokafka*, lag | **2** | [2](../modulos/modulo-02-observabilidade.md) | Compose pronto; kind: [`deploy/kafka/`](../deploy/kafka/) |
| [03 — Istio mTLS](lab-03-istio-mtls.md) | Istio, mTLS STRICT, *AuthorizationPolicy* | **4** | [3](../modulos/modulo-03-service-mesh.md) | exemplos em `deploy/istio/` |
| [04 — Redis, Postgres, idempotência](lab-04-redis-postgres-idempotencia.md) | Redis, Postgres, locks | **2** | [4](../modulos/modulo-04-consistencia.md) | `idempotency.py` + `models.py` |
| [05 — Canary e GitOps](lab-05-canary-gitops.md) | Istio VS, Argo CD | **5–6** | [5](../modulos/modulo-05-deploy-gitops.md) | *credito* v1/v2 por env |
| [06 — Backstage catálogo](lab-06-backstage-catalogo.md) | Backstage, TechDocs | **7** | [6](../modulos/modulo-06-backstage.md) | `catalog-info.yaml` pronto |
| [07a — Segredos](lab-07a-segredos-external-secrets.md) | Vault / External Secrets | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | lab + Helm |
| [07b — Outbox](lab-07b-outbox-kafka.md) | transactional outbox | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | `pix_service` + `worker-outbox-relay` |
| [07c — Pact](lab-07c-pact-contratos.md) | Pact, CI | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | lab + testes de contrato |
| [07d — Kyverno](lab-07d-kyverno-admission.md) | Kyverno | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | `deploy/policies/kyverno/` |
| [07e — DR](lab-07e-disaster-recovery.md) | RPO/RTO, restore Postgres | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | runbook + simulação |
| [07f — PII em logs/traces](lab-07f-pii-observabilidade.md) | structlog, OTel Collector, tail sampling | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | `deploy/observability/` |
| [07g — SRE prático](lab-07g-sre-praticas.md) | incident command, postmortem, burn rate | transversal | [7](../modulos/modulo-07-operacao-conformidade.md) | exercícios de operação |

## Exercícios avançados (nível SRE)

| Lab | Exercícios |
|-----|------------|
| [02 — OTel/Jaeger](lab-02-opentelemetry-jaeger.md) | A1–A7: RED/USE, exemplars, cardinalidade, sampling, correlation vs trace, custo |
| [02b — Kafka](lab-02b-kafka-consumer.md) | A1–A6: ISR, rebalance, consumer internals, partições, compacted, poison pill |
| [07b — Outbox](lab-07b-outbox-kafka.md) | DLQ, EOS na prática |
| [07g — SRE](lab-07g-sre-praticas.md) | IC, postmortem, toil, alert fatigue, burn rate, SLI |

Checklist mestre: [PLANO § nível avançado](../PLANO_DE_ESTUDO.md#nivel-avancado).

## Exercícios de falha e troubleshooting

Cenários avançados (retry storm, rebalance, trace vs métricas, “quando NÃO usar”): [`EXERCICIOS-FALHA-E-TROUBLESHOOTING.md`](EXERCICIOS-FALHA-E-TROUBLESHOOTING.md).

## Ordem sugerida

Leia o [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md). Siga as **ondas 0 → 7** do plano. Os labs **07\*** assumem a espinha dorsal das ondas anteriores.

## Conhecimento do curso (não é “pré-requisito de um lab”)

Base comum: blocos *Fundamentos* no ebook ([índice](../ebook/capitulos/fundamentos-indice.md)) + [`ebook/PRE-REQUISITOS.md`](../ebook/PRE-REQUISITOS.md) (máquina e ritmo). Os labs aprofundam o passo a passo, não substituem a teoria do módulo.

## Convenção em cada lab

Cada `lab-*.md` usa a seção **«Antes de começar»** com três blocos (não misturar):

| Bloco | Significado |
|-------|-------------|
| **Conhecimento (este lab)** | Só o que este passo assume que você *entende* (módulo + ebook) |
| **Labs anteriores** | O que você já *rodou* neste repo |
| **Ambiente** | Programas instalados, RAM, serviços no ar |

Depois vêm: **Objetivo** → **Passos** → **Deu certo quando** → **Próximo passo**.

Modelo copiável: [`_TEMPLATE-ANTES-DE-COMEÇAR.md`](_TEMPLATE-ANTES-DE-COMEÇAR.md).
