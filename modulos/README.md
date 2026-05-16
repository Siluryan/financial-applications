# Módulos — guias expandidos

Material complementar ao [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md). Cada ficheiro aprofunda **conceitos**, **vocabulário** e **ligação à espinha dorsal** (*kind*, ondas 0–7) sem repetir todo o checklist do plano.

**Glossário:** [`ebook/GLOSSARIO.md`](../ebook/GLOSSARIO.md) — termos do curso com explicação e link para o capítulo.

**Conhecimento (curso):** [`ebook/PRE-REQUISITOS.md`](../ebook/PRE-REQUISITOS.md). **Labs:** cada `labs/lab-*.md` tem *Antes de começar* (conhecimento do lab · labs anteriores · ambiente).

| Módulo | Ficheiro | Onda(s) na espinha dorsal |
|--------|----------|---------------------------|
| **0** — Fundamentos distribuídos | [modulo-00-fundamentos-distribuidos.md](modulo-00-fundamentos-distribuidos.md) | Leitura antes da [Onda 0](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **1** — Resiliência e caos | [modulo-01-resiliencia.md](modulo-01-resiliencia.md) | [Onda 1](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **2** — Observabilidade e Kafka | [modulo-02-observabilidade.md](modulo-02-observabilidade.md) | [Onda 3](../PLANO_DE_ESTUDO.md#ondas-principio); Kafka na [Onda 2](../PLANO_DE_ESTUDO.md#estudo-kafka) |
| **3** — Service mesh (mTLS, políticas) | [modulo-03-service-mesh.md](modulo-03-service-mesh.md) | [Onda 4](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **4** — Concorrência, idempotência, sagas | [modulo-04-consistencia.md](modulo-04-consistencia.md) | [Onda 2](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **5** — Deploy, canary, GitOps | [modulo-05-deploy-gitops.md](modulo-05-deploy-gitops.md) | [Ondas 5–6](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **6** — Backstage e DX | [modulo-06-backstage.md](modulo-06-backstage.md) | [Onda 7](../PLANO_DE_ESTUDO.md#ondas-principio) |
| **7** — Operação e conformidade | [modulo-07-operacao-conformidade.md](modulo-07-operacao-conformidade.md) | Transversal (ondas 2–6) |

**Ordem sugerida de leitura:** 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7, aplicando no cluster conforme as ondas do plano.

Exercícios transversais: [`labs/EXERCICIOS-FALHA-E-TROUBLESHOOTING.md`](../labs/EXERCICIOS-FALHA-E-TROUBLESHOOTING.md).

**Nível avançado / SRE:** checklist mestre no [PLANO § nível avançado](../PLANO_DE_ESTUDO.md#nivel-avancado); exercícios A* nos labs [02](../labs/lab-02-opentelemetry-jaeger.md), [02b](../labs/lab-02b-kafka-consumer.md) e [07g](../labs/lab-07g-sre-praticas.md).

**Diagramas:** os guias mostram **imagens PNG**; o código Mermaid fica em [`diagramas/mmd/`](diagramas/mmd/) (regenerar com [`scripts/render-diagramas.sh`](../scripts/render-diagramas.sh)).

**Laboratórios (passo a passo):** pasta [`labs/`](../labs/README.md) — comandos, critérios “deu certo” e ligação a cada onda.

**Ebook (teoria + lab integrados):** [`ebook/README.md`](../ebook/README.md) — cada parte do livro alterna módulo e laboratório; gere com [`scripts/build-ebook.sh`](../scripts/build-ebook.sh).
