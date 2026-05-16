## Para quem é este livro

Percurso prático de **microsserviços em contexto financeiro**, para quem trabalha com **plataforma e cloud**: Kubernetes, redes, observabilidade, filas e governança. Não é curso de “programar um banco do zero”.

Você acompanha um banco digital fictício — *Pix*, limites, crédito — enquanto um cluster **kind** amadurece onda a onda. O código Python é pequeno de propósito; o foco é **operar e defender** o sistema.

## O cenário

O cliente inicia um *Pix*. O **serviço *Pix*** consulta **limites**; se aprovado, responde e pode publicar `pix.iniciado` no **Kafka** para antifraude ou notificações, sem travar a tela. Outros fluxos usam **crédito** (v1/v2 no lab de canary).

Aparecem cedo: *Limites* lento derruba o canal; pagamento duplicado; tráfego interno sem proteção; deploy que quebra consumidor; segredo no Git; CPF em log. Cada módulo trata um desses pontos com teoria e laboratório.

## Siglas e termos curtos

Antes de mergulhar nos módulos, vale ter à mão a tabela de **[siglas rápidas](SIGLAS-RAPIDAS.md)** (CAP, SLO, mTLS, OTel, RPO/RTO, etc.). O [glossário completo](GLOSSARIO.md) no final traz cada termo com analogia e link para o capítulo.

## Convenções

Termos técnicos em inglês (*retry*, *consumer lag*, *circuit breaker*) são explicados na primeira vez de cada capítulo; ver [siglas rápidas](SIGLAS-RAPIDAS.md) e [`CONVENCOES_EDITORIAIS.md`](CONVENCOES_EDITORIAIS.md). Nomes: domínio *Pix*; recurso `servico-pix`.

## Organização

| Ordem | Conteúdo |
|-------|----------|
| 1 | Cada **parte** do livro: **contexto histórico** → teoria (`modulos/`) → lab (`labs/`) |
| 2 | [Glossário](GLOSSARIO.md) e apêndices (`apps/`, `deploy/`) no final |

O contexto não fica todo no início: antes do Módulo 2 vêm Kafka e observabilidade; antes do Módulo 4, Postgres/Redis e incidentes de dados; antes do Módulo 7, LGPD/PCI e estudos de caso de vazamento e conformidade. Índice: [`capitulos/README.md`](capitulos/README.md). Ritmo: [Como estudar](capitulos/07-como-estudar-com-este-livro.md).

Checklist completo: [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md).

## Espinha dorsal (ondas)

| Onda | O que entra | Capítulo |
|------|-------------|----------|
| **0** | *Pix* e *Limites*, REST | Lab inicial |
| **1** | *Toxiproxy*, retry, breaker | Módulo 1 |
| **2** | Redis, Postgres, Kafka | Módulos 2 e 4 |
| **3** | OpenTelemetry, Jaeger | Módulo 2 |
| **4** | Istio, mTLS | Módulo 3 |
| **5** | *Crédito* v1/v2, canary | Módulo 5 |
| **6** | GitOps | Módulo 5 |
| **7** | Backstage | Módulo 6 |

O **Módulo 7** (operação e conformidade) cruza ondas: segredos, outbox, Pact, Kyverno, DR, PII em traces.

## Pré-requisitos: três coisas diferentes

Leitores se perdem quando tudo vira uma lista só. Neste material:

| Tipo | Onde está | Exemplo |
|------|-----------|---------|
| **Conhecimento do curso** | [Pré-requisitos](PRE-REQUISITOS.md) (este livro, início) | “Sei o que é GET/POST e JSON” |
| **Lab anterior** | Seção *Antes de começar* de cada `labs/lab-*.md` | “Já rodei o Lab 00 — cluster no ar” |
| **Ambiente** | Mesma seção *Antes de começar* do lab | “Docker rodando, 4 GB RAM livres, `helm` instalado” |

O [capítulo Pré-requisitos](PRE-REQUISITOS.md) cobre só **conhecimento** (HTTP, Docker, K8s, Python, SQL). Cada laboratório diz, à parte, o que você precisa **já ter executado** e o que precisa **instalado na máquina**.

**Ritmo sugerido:** um módulo por semana. Em **8 GB de RAM**, não suba Istio, Kafka e Jaeger juntos — detalhes em [Pré-requisitos → Máquina](PRE-REQUISITOS.md#máquina-e-ritmo).

## Repositório

Monorepo **financial-applications**: `apps/`, `deploy/`, `labs/`, `modulos/`. `docker compose` para iteração rápida; **kind** para a trilha completa. O *Pix* no repo já usa outbox, idempotência, retry/breaker e OTLP.

## Como começar

[Por que microsserviços](capitulos/01-por-que-microsservicos.md) → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md) → [Kubernetes](capitulos/02-evolucao-containers-kubernetes.md) → lab Onda 0 → siga módulo a módulo (contexto + teoria + lab de cada parte).
