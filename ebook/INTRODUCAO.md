## Para quem é este livro

*Segunda edição · 2026.*

Percurso prático de **microsserviços em contexto financeiro**, para quem trabalha com **plataforma e cloud**: Kubernetes, redes, observabilidade, filas e governança. Não é um manual para implementar um core bancário do zero — o foco é montar, observar e endurecer um sistema distribuído credível.

O vocabulário das ferramentas está em capítulos **Fundamentos**, cada um imediatamente antes do módulo que o emprega ([índice](capitulos/fundamentos-indice.md)): HTTP e FastAPI, Docker/Kubernetes, resiliência, OpenTelemetry, Kafka, Istio, Postgres/Redis e GitOps.

Você acompanha um banco digital fictício — *Pix*, limites, crédito — enquanto um cluster **kind** ganha componentes módulo a módulo. Os exemplos em Python são curtos de propósito; o texto privilegia **operar e defender** o sistema.

## O cenário

O cliente inicia um *Pix*. O **serviço *Pix*** consulta **limites**; se aprovado, responde e pode publicar `pix.iniciado` no **Kafka** para antifraude ou notificações, sem travar a tela. Outros fluxos usam **crédito** (v1/v2 no lab de canary).

Aparecem cedo: *Limites* lento derruba o canal; pagamento duplicado; tráfego interno sem proteção; deploy que quebra consumidor; segredo no Git; CPF em log. Cada módulo trata um desses pontos com teoria e laboratório.

## Siglas e termos curtos

Consulte as **[siglas rápidas](SIGLAS-RAPIDAS.md)** (CAP, SLO, mTLS, OTel, RPO/RTO) quando surgir um acrónimo. O [glossário](GLOSSARIO.md), no final, define cada entrada com analogia e remissão ao capítulo correspondente.

## Convenções

Termos técnicos em inglês (*retry*, *consumer lag*, *circuit breaker*) são explicados na primeira vez de cada capítulo; ver [siglas rápidas](SIGLAS-RAPIDAS.md) e [convenções editoriais](CONVENCOES_EDITORIAIS.md). Nomes: domínio *Pix*; recurso `servico-pix`.

## Organização

O **sumário** lista as **partes** do livro. Cada parte (exceto Introdução e apêndices) segue, na leitura: **contexto histórico** → **teoria** → **laboratório**.

| Parte no sumário | Conteúdo |
|------------------|----------|
| **Introdução** | Apresentação, siglas, pré-requisitos, [como estudar](capitulos/07-como-estudar-com-este-livro.md) |
| **Módulo 0** | Contexto → teoria (CAP, SLO) → fundamentos HTTP/Kubernetes → contexto K8s → **Laboratório 00** |
| **Módulos 1–7** | *Fundamentos* (quando houver) → contexto → teoria → **laboratório** (cada um com título no sumário) |
| **Glossário e apêndices** | Referência e guias do repositório no GitHub |

O contexto histórico não está todo no início: Kafka e observabilidade aparecem antes do Módulo 2; Postgres/Redis antes do Módulo 4; LGPD/PCI antes do Módulo 7.

Tabelas de verificação expandidas por módulo estão no repositório *financial-applications* no GitHub, junto do código dos laboratórios.

## Etapas do cluster (repositório)

No GitHub, o cluster **kind** evolui em **oito etapas** (0 a 7): cada uma acrescenta componentes (*Pix* e *Limites*, depois *Toxiproxy*, Kafka, traces, Istio, canary, GitOps, Backstage). Isso é o roteiro de **implementação** no repositório — **não** é o mesmo que as partes do sumário. No livro, a etapa 0 está no **Laboratório 00** (dentro do Módulo 0); as etapas 1–7 nos laboratórios dos módulos da tabela.

| Etapa (cluster) | O que entra | Onde ler no livro |
|-----------------|-------------|-------------------|
| **0** | *Pix*, *Limites*, REST | **Módulo 0** — Laboratório 00 |
| **1** | *Toxiproxy*, retry, breaker | **Módulo 1** |
| **2** | Redis, Postgres, Kafka | **Módulos 2 e 4** |
| **3** | OpenTelemetry, Jaeger | **Módulo 2** |
| **4** | Istio, mTLS | **Módulo 3** |
| **5** | *Crédito* v1/v2, canary | **Módulo 5** |
| **6** | GitOps | **Módulo 5** |
| **7** | Backstage | **Módulo 6** |

O **Módulo 7** (operação e conformidade) cruza várias etapas: segredos, outbox, Pact, Kyverno, DR, PII em traces.

## Pré-requisitos: três coisas diferentes

Três listas distintas evitam confusão:

| Tipo | Onde está | Exemplo |
|------|-----------|---------|
| **Conhecimento** | Blocos *Fundamentos* antes de cada módulo + [índice](capitulos/fundamentos-indice.md) | GET/POST, Pod, trace |
| **Lab anterior** | *Antes de começar* em cada laboratório | Lab 00 concluído |
| **Ambiente** | Mesma seção do lab | Docker, RAM, `helm` |

[Pré-requisitos](PRE-REQUISITOS.md) trata apenas de **máquina e ritmo**. O vocabulário técnico distribui-se pelos capítulos *Fundamentos* ao longo do livro.

**Ritmo sugerido:** um módulo por semana. Em **8 GB de RAM**, não suba Istio, Kafka e Jaeger juntos — detalhes em [Pré-requisitos → Máquina](PRE-REQUISITOS.md#máquina-e-ritmo).

## Material complementar (código)

Os laboratórios reproduzem o repositório **financial-applications** no GitHub: serviços *Pix*, *Limites* e *Crédito*, manifests Kubernetes, scripts de build e diagramas. Use `docker compose` para iteração rápida ou **kind** para a trilha completa. O *Pix* de referência inclui outbox, idempotência, retry/breaker e exportação OTLP.

## Como começar

Leia primeiro *Por que microsserviços* (abre o Módulo 0), conclua esse módulo com teoria, fundamentos e **Laboratório 00**, e siga a ordem do sumário até o Módulo 7. O capítulo [Como estudar com este livro](capitulos/07-como-estudar-com-este-livro.md) traz ritmo semanal e alternativas entre Docker Compose e *kind*.
