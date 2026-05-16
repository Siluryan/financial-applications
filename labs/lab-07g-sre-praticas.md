# Lab 07g — SRE prático (incidentes, alertas, postmortem)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.7](../PLANO_DE_ESTUDO.md#modulo-7-sre)

## Objetivo

Praticar **resposta a incidente**, **postmortem blameless**, **burn rate**, **alert fatigue** e desenho de **SLI** — sem depender de produção real.

## Antes de começar

### Conhecimento (este lab)

- SLO, SLI, error budget ([Módulo 2](../modulos/modulo-02-observabilidade.md)).
- Operação SRE ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md) § 7.7).

### Labs anteriores

- [Lab 02](lab-02-opentelemetry-jaeger.md) e [02b](lab-02b-kafka-consumer.md) — cenário “API 200, lag alto”.
- [Lab 01](lab-01-toxiproxy-resiliencia.md) — caos controlado.

### Ambiente

- Papel e caneta ou documento compartilhado; opcional: Grafana/Prometheus do Compose.

## Cenário base

**Incidente simulado:** às 14:00 o painel mostra *Pix* com **99,2 %** de sucesso (SLO 99,9 %). Consumer lag de `pix.iniciado` = **50.000**. Clientes reclamam de crédito atrasado. API responde em 200 ms.

## Exercício 1 — Incident command (30 min)

Forme um grupo de 3 (ou jogue 3 papéis sozinho):

| Papel | Faz | Não faz |
|-------|-----|---------|
| **IC** | Prioriza, cronometra, decide rollback | Debug profundo sozinho |
| **SME** | Investiga Kafka, traces, outbox | Falar por cima do IC |
| **Scribe** | Linha do tempo UTC | Corrigir código |

**Roteiro:**

1. Min 0–5: declarar severidade (SEV2?) e canal (#incidente-pix-lab).
2. Min 5–15: SME consulta lag, trace com tail sampling, tabela `outbox`.
3. Min 15–25: mitigar (scale consumer, pausar deploy, acionar DLQ).
4. Min 25–30: IC declara “estabilizado” ou escalonamento.

**Evidência:** timeline de 8–12 linhas com horário UTC.

Diagrama: [`m07-incident-response.png`](../modulos/diagramas/m07-incident-response.png).

## Exercício 2 — Postmortem blameless (45 min)

Copie [`docs/postmortem-template.md`](../docs/postmortem-template.md) para `docs/postmortem-lab-07g.md` e preencha com o incidente simulado.

Regra: nenhuma frase “fulano errou”; use “o deploy não passou por Pact” ou “alerta de lag não existia”.

## Exercício 3 — Toil (15 min)

Liste **5 tarefas toil** do seu lab (reiniciar pod à mão, copiar secret, etc.). Para cada uma, escreva automação possível (Helm, Kyverno, External Secrets, runbook script).

## Exercício 4 — Alert fatigue (20 min)

Avalie estes alertas fictícios — **página** ou **ticket** ou **descartar**?

| Alerta | Sua decisão | Motivo |
|--------|-------------|--------|
| CPU > 70 % no *Pix* | | |
| 1 erro 500 em 5 min | | |
| Burn rate 14× em 5 min (SLO *Pix*) | | |
| Pod restart 1× | | |
| Kafka broker JMX up | | |
| Consumer lag > 10k por 10 min | | |

Documente 1 alerta **noisy** que você já viu na vida real e como reescrever.

## Exercício 5 — Burn rate (30 min)

SLO: **99,9 %** de `POST /v1/pix` com latência < 2 s no mês (43 min de budget/mês).

1. Calcule: se em **5 min** 5 % das requisições falharem, o burn rate é ~ quantas vezes o sustentável? (ordem de grandeza: dezenas)
2. Defina janelas: **5 min** → página; **6 h** → ticket prioritário.
3. Desenhe política em texto (Grafana SLO ou Prometheus recording rules — não precisa implementar).

Diagrama: [`m07-burn-rate.png`](../modulos/diagramas/m07-burn-rate.png).

## Exercício 6 — SLI mal desenhado (20 min)

Reescreva estes SLIs ruins para o *Pix*:

| SLI ruim | SLI bom (sua proposta) |
|----------|-------------------------|
| Pods Running | |
| CPU < 80 % | |
| Kafka broker up | |
| Sem log ERROR | |

Cada SLI bom deve ser **mensurável**, **ligado ao cliente** e **acionável**.

## Deu certo quando

- [ ] Timeline de incidente simulado entregue.
- [ ] Postmortem blameless preenchido (≥ 1 página).
- [ ] Tabela de alertas com decisão página/ticket/descartar.
- [ ] Política de burn rate escrita (2 janelas).
- [ ] 4 SLIs reescritos.
- [ ] [Checklist avançado § SRE](../PLANO_DE_ESTUDO.md#nivel-avancado) marcado.

## Próximo passo

[Checklist integrador §7.9](../PLANO_DE_ESTUDO.md#modulo-7-integrador) — gravar demo 10–15 min incluindo trecho de postmortem (opcional).
