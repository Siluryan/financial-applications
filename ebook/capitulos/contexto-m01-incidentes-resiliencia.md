## Por que resiliência virou disciplina

Nos anos 2010, outages de grandes varejistas e bancos mostraram o mesmo padrão: dependência lenta → **threads esgotadas** → queda em cascata. O cliente via timeout; o painel mostrava “CPU ok”. Não faltava servidor — faltava **limite de espera** e **proteção ao dependente doente**.

## Estudos de caso (o que aprender)

### AWS us-east-1 (2021) — dependência compartilhada

Uma região afetou dezenas de serviços que usavam os mesmos blocos (DNS, filas, funções). Lição para o lab: **bulkhead** e não concentrar tudo num único “super serviço” sem fallback; *Limites* fora não pode esvaziar o pool inteiro do *Pix*.

### Instagram / Meta (2010s) — efeito manada em retry

Picos de tráfego com retries sincronizados pioram recuperação. Lição: **jitter** e **retry budget** (Módulo 1) — não dez instâncias batendo na mesma porta no mesmo segundo.

### NetFlix (caos como cultura)

**Chaos engineering** (*Chaos Monkey*, depois Simian Army) institucionalizou “quebrar de propósito” em horário controlado. Lição: *Toxiproxy* no lab 01 não é brincadeira — é ensaio de incêndio.

### Circuit breaker na prática

Quando um antifraude ou scoring externo cai, bancos escolhem: **negar transação** (seguro) ou **modo degradado** com limite conservador (regra de negócio). O **circuit breaker** não decide política — implementa a decisão com *fail-fast*.

## Linha do tempo (padrões de resiliência)

| Ano | Marco |
|-----|--------|
| 2000s | Timeouts em ESBs corporativos |
| 2012 | Artigo *Release It!* (Michael Nygard) — breaker, bulkhead |
| 2014+ | Netflix OSS, Hystrix (depois em desuso; conceito permanece) |
| 2016+ | Service mesh e retries no proxy |
| 2020s | SRE + error budget ligados a deploy |

## O que levar para o laboratório

| Incidente real | Prática no lab |
|----------------|----------------|
| Cascata por dependência | *Toxiproxy* + timeout no *Pix* |
| Retry storm | Comparar retry com/sem jitter |
| Dependência crítica fora | Breaker aberto + resposta clara |
