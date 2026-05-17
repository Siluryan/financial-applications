# Lab 07g — SRE prático (incidentes, alertas, postmortem)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.7](../PLANO_DE_ESTUDO.md#modulo-7-sre)

## Objetivo

Praticar **resposta a incidente**, **postmortem blameless**, **burn rate**, **alert fatigue** e desenho de **SLI** — sem ambiente de produção real.

O Módulo 7 fecha a lacuna entre “funciona no lab” e “opera-se em produção”. Este laboratório é sobretudo **documental e de role-play**: cronometra decisões, escreve timeline UTC, evita culpar pessoas.

**Tempo estimado:** 2–3 h (todos os exercícios).

## Antes de começar

### Conhecimento (este lab)

- SLO, SLI, error budget ([Módulo 2](../modulos/modulo-02-observabilidade.md)).
- Operação SRE ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md) § 7.7).

### Labs anteriores

- [Lab 02](lab-02-opentelemetry-jaeger.md) e [02b](lab-02b-kafka-consumer.md) — cenário “API 200, lag alto”.
- [Lab 01](lab-01-toxiproxy-resiliencia.md) — caos controlado.

### Ambiente

- Papel e documento partilhado; Grafana/Prometheus do Compose para métricas de apoio.

## Cenário base

**Incidente simulado (14:00 UTC):** painel mostra *Pix* com **99,2 %** de sucesso (SLO 99,9 %). **Consumer lag** de `pix.iniciado` = **50.000**. Clientes reportam crédito atrasado. API responde em ~200 ms.

Leia o cenário em voz alta antes de cada exercício. Os dados são fictícios mas plausíveis em banco digital com fila assíncrona.

## Exercício 1 — Incident command (30 min)

Forme grupo de 3 (ou três papéis sozinho):

| Papel | Faz | Não faz |
|-------|-----|---------|
| **IC** (Incident Commander) | Prioriza, cronometra, decide rollback | Debug profundo sozinho |
| **SME** (especialista) | Investiga Kafka, traces, outbox | Falar por cima do IC |
| **Scribe** | Linha do tempo UTC | Corrigir código em silêncio |

**Roteiro:**

1. **Min 0–5:** declarar severidade (SEV2?) e canal (`#incidente-pix-lab`).
2. **Min 5–15:** SME consulta lag (`kafka-consumer-groups`), trace no Jaeger, tabela `outbox` pendente.
3. **Min 15–25:** mitigar — scale consumer, pausar deploy, DLQ se poison.
4. **Min 25–30:** IC declara “estabilizado” ou escalonamento.

**Evidência:** timeline de 8–12 linhas com horário UTC e factos (“lag 50k”, “deploy v2 às 13:40”).

O diagrama *m07-incident-response* resume papéis e fases de resposta a incidente.

## Exercício 2 — Postmortem blameless (45 min)

Copie [`docs/postmortem-template.md`](../docs/postmortem-template.md) para `docs/postmortem-lab-07g.md`.

Preencha com o incidente simulado. **Regra:** nenhuma frase “fulano errou”. Use “o deploy não passou por Pact” ou “não existia alerta de lag > 10k”.

Secções mínimas: resumo, impacto, linha do tempo, causa raiz, acções correctivas, lições aprendidas.

## Exercício 3 — Toil (15 min)

Liste **5 tarefas toil** do seu lab (reiniciar pod à mão, copiar secret, port-forward repetido). Para cada uma, proponha automação (Helm, Kyverno, External Secrets, script no `scripts/`).

## Exercício 4 — Alert fatigue (20 min)

Para cada alerta fictício, decida: **página**, **ticket** ou **descartar** — com motivo em uma linha.

| Alerta | Decisão | Motivo |
|--------|---------|--------|
| CPU > 70 % no *Pix* | | |
| 1 erro 500 em 5 min | | |
| Burn rate 14× em 5 min (SLO *Pix*) | | |
| Pod restart 1× | | |
| Kafka broker JMX up | | |
| Consumer lag > 10k por 10 min | | |

Documente um alerta **noisy** que já viu na prática e como reescreveria a condição.

## Exercício 5 — Burn rate (30 min)

SLO: **99,9 %** de `POST /v1/pix` com latência < 2 s no mês (~43 min de error budget/mês).

1. Se em **5 min** 5 % das requisições falharem, o burn rate é quantas vezes o sustentável? (ordem: dezenas)
2. Janelas: **5 min** → página; **6 h** → ticket prioritário.
3. Escreva política em texto (Grafana SLO ou recording rules Prometheus).

O diagrama *m07-burn-rate* ilustra janelas de *burn rate* para alertas multi-janela.

## Exercício 6 — SLI mal desenhado (20 min)

Reescreva SLIs fracos para SLIs **mensuráveis**, **ligados ao cliente** e **acionáveis**:

| SLI ruim | SLI bom (sua proposta) |
|----------|-------------------------|
| Pods Running | |
| CPU < 80 % | |
| Kafka broker up | |
| Sem log ERROR | |

## Deu certo quando

- [ ] Timeline de incidente entregue.
- [ ] Postmortem blameless ≥ 1 página.
- [ ] Tabela de alertas com decisão e motivo.
- [ ] Política de burn rate com duas janelas.
- [ ] Quatro SLIs reescritos.
- [ ] [Checklist avançado § SRE](../PLANO_DE_ESTUDO.md#nivel-avancado) marcado.

## Próximo passo

[Checklist integrador §7.9](../PLANO_DE_ESTUDO.md#modulo-7-integrador) — inclua demo de 10–15 min com trecho de postmortem na entrega final do Módulo 7.
