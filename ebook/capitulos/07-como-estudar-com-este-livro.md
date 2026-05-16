## Duas trilhas: Compose e kind

| Trilha | Quando usar |
|--------|-------------|
| **`docker compose`** | Iterar rápido no *Pix*, Postgres, Redis, Kafka, Jaeger |
| **kind + manifests Kubernetes** | Espinha dorsal completa: mesh, canary, políticas, DR |

## Como o livro está organizado

Cada **módulo** segue a sequência:

1. **Contexto histórico** — por que a ferramenta existe; incidentes reais quando aplicável  
2. **Teoria** — capítulo conceitual do módulo  
3. **Laboratório** — passos práticos

Não leia todos os contextos de uma vez no início; leia o contexto **da parte** em que você está.

| Parte | Contexto (capítulos) |
|-------|----------------------|
| Módulo 0 | Microsserviços e bancos |
| Onda 0 | Kubernetes / containers |
| Módulo 1 | Incidentes de resiliência |
| Módulo 2 | Observabilidade + Kafka |
| Módulo 3 | Service mesh |
| Módulo 4 | Postgres/Redis + incidentes de dados |
| Módulo 5 | GitOps e canary |
| Módulo 6 | Backstage |
| Módulo 7 | LGPD/PCI + governança + incidentes de conformidade |

## Ordem sugerida (16 semanas)

| Semana | Parte | Foco |
|--------|-------|------|
| 1 | Módulo 0 + contexto | CAP, idempotência |
| 2 | Onda 0 + contexto K8s | Cluster mínimo |
| 3 | Módulo 1 | Resiliência |
| 4 | Módulo 2 | Traces e Kafka |
| 5 | Módulo 4 | Idempotência (pode adiantar após 2) |
| 6 | Módulo 3 | mTLS |
| 7 | Módulo 5 | Canary / GitOps |
| 8 | Módulo 6 | Backstage |
| 9–12 | Módulo 7 | Labs 07a–07f |
| 13+ | Exercícios de falha | Integração |

Checklists expandidos: repositório Git do projeto.

## Conhecimento, lab e ambiente

| Tipo | Onde ler |
|------|----------|
| **Conhecimento do curso** (HTTP, Docker, K8s…) | [Pré-requisitos](../PRE-REQUISITOS.md) — **uma vez** no início |
| **Cada laboratório** | Seção *Antes de começar* (conhecimento **deste** lab + labs anteriores + ambiente) |

| RAM (ambiente) | Sugestão |
|----------------|----------|
| **8 GB** | Compose nos módulos 1–2; no *kind*, não suba Istio + Kafka + Jaeger juntos |
| **16 GB+** | Mais folga; um componente pesado por vez |
| Porta ocupada | `PIX_HOST_PORT=18000 docker compose up` |

## Referência cruzada

| Preciso de… | Onde |
|-------------|------|
| Sigla na hora | [Siglas rápidas](../SIGLAS-RAPIDAS.md) (início do livro) |
| Termo com analogia | [Glossário](../GLOSSARIO.md) (final) |
| Checklist detalhado | Repositório Git (online) |

Comece: [Módulo 0](../../modulos/modulo-00-fundamentos-distribuidos.md) após [por que microsserviços](01-por-que-microsservicos.md).
