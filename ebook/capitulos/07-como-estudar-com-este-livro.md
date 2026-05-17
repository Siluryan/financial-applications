## Duas trilhas: Compose e kind

| Trilha | Quando usar |
|--------|-------------|
| **`docker compose`** | Iterar rápido no *Pix*, Postgres, Redis, Kafka, Jaeger |
| **kind + manifests Kubernetes** | Espinha dorsal completa: mesh, canary, políticas, DR |

## Como o livro está organizado

No **sumário**, cada **módulo** (0 a 7) é uma parte. Dentro de cada um, as secções *Contexto*, *Teoria* e *Fundamentos* (quando existirem) precedem o **laboratório** — com título explícito (*Laboratório 01 — …*, *Laboratório 02b — …*, etc.). O Módulo 7 reúne sete laboratórios (07a–07g), todos listados no sumário.

Cada módulo segue a sequência:

1. **Contexto histórico** — por que a ferramenta existe; incidentes reais quando aplicável  
2. **Teoria** — capítulo conceitual do módulo  
3. **Laboratório** — passos práticos

Não leia todos os contextos de uma vez no início; leia o contexto **da parte** em que você está.

| Parte | Contexto (capítulos) |
|-------|----------------------|
| Módulo 0 | Microsserviços, fundamentos HTTP/K8s e Lab 00 |
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
| 2 | Módulo 0 (completo) | Cluster mínimo (Lab 00) |
| 3 | Módulo 1 | Resiliência |
| 4 | Módulo 2 | Traces e Kafka |
| 5 | Módulo 4 | Idempotência (pode adiantar após 2) |
| 6 | Módulo 3 | mTLS |
| 7 | Módulo 5 | Canary / GitOps |
| 8 | Módulo 6 | Backstage |
| 9–12 | Módulo 7 | Labs 07a–07f |
| 13+ | Exercícios de falha | Integração |

Tabelas de verificação expandidas: repositório *financial-applications* no GitHub.

## Conhecimento, lab e ambiente

| Tipo | Onde ler |
|------|----------|
| **Conhecimento** (HTTP, Docker, K8s…) | Blocos *Fundamentos* de cada parte + [índice](fundamentos-indice.md) |
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

**Ordem sugerida na primeira leitura:** capítulo *Por que microsserviços* (contexto do Módulo 0), depois o **Módulo 0** por completo — teoria, fundamentos de HTTP/Kubernetes e Laboratório 00 — e então os Módulos 1 a 7 na sequência do sumário.
