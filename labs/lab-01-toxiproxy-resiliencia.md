# Lab 01 — Toxiproxy, Tenacity e circuit breaker

[← Índice dos labs](README.md) · [Módulo 1](../modulos/modulo-01-resiliencia.md)

## Objetivo

Inserir **Toxiproxy** entre *Pix* e *Limites*, injetar latência e falhas de rede de forma controlada, e validar no código as políticas de **timeout**, **retry com jitter** e **circuit breaker** (Tenacity + pybreaker).

Na teoria do Módulo 1 você viu por que dependências lentas provocam cascata. Aqui o Toxiproxy substitui incidentes aleatórios em produção por um **ensaio repetível**: você define 3 s de latência e observa se o *Pix* respeita `HTTP_TIMEOUT=2`, se as retentativas não sincronizam em rajada e se o circuito abre após várias falhas.

**Ao terminar**, deve conseguir ler nos logs a transição `circuit_breaker_state` e explicar por que `resilience.py` concentra httpx, Tenacity e pybreaker — e não o handler HTTP do *Pix*.

**Tempo estimado:** 60–90 min.

## Antes de começar

### Conhecimento (este lab)

- O *Pix* chama *Limites* por HTTP **antes** de responder ao cliente (fluxo síncrono).
- Noções de **timeout**, **retry** e **circuit breaker** ([Módulo 1](../modulos/modulo-01-resiliencia.md), [Fundamentos — Resiliência](../ebook/capitulos/fundamentos-resiliencia.md)).
- Interpretar HTTP **200** vs **503** e tempos de resposta no `curl` (flag `-w` para medir duração).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — *Pix* e *Limites* respondem no *kind* ou em `docker compose`.

### Ambiente

- `curl` e `jq`.
- *Toxiproxy* conforme passos: manifest em `deploy/toxiproxy/` no *kind*, ou serviço no Compose.
- Port-forward do *Pix* na porta 8000 (como no Lab 00).

## Arquitetura do ensaio

```text
servico-pix  ──HTTP──►  toxiproxy:8666  ──►  servico-limites:8000
                              ▲
                         API :8474 (toxics)
```

O *Pix* deixa de falar diretamente com *Limites*; fala com o proxy. A API do Toxiproxy (porta 8474) permite ligar/desligar *toxics* sem redeploy da aplicação.

## Passos (kind)

### 1. Subir o Toxiproxy

```bash
kubectl apply -f deploy/toxiproxy/deployment.yaml
kubectl -n core-banking wait --for=condition=available deployment/toxiproxy --timeout=120s
```

Confirme o Pod `Running`. O Toxiproxy precisa estar no **mesmo namespace** que os serviços para o DNS `toxiproxy.core-banking.svc.cluster.local` resolver.

### 2. Criar o proxy (API → limites)

A API de administração do Toxiproxy não é exposta por defeito no host. Use port-forward:

```bash
kubectl -n core-banking port-forward svc/toxiproxy 8474:8474
```

Noutro terminal, registe o *upstream* (destino real) e a porta de escuta do proxy:

```bash
curl -sS -X POST http://127.0.0.1:8474/proxies -d '{
  "name": "limites",
  "listen": "0.0.0.0:8666",
  "upstream": "servico-limites.core-banking.svc.cluster.local:8000",
  "enabled": true
}'
```

**O que observar:** resposta JSON com `"name": "limites"`. Liste proxies com `curl -sS http://127.0.0.1:8474/proxies | jq .`

### 3. Apontar o *Pix* para o proxy

Altere a variável de ambiente do Deployment e aguarde o rollout:

```bash
kubectl -n core-banking set env deployment/servico-pix \
  LIMITES_URL=http://toxiproxy.core-banking.svc.cluster.local:8666 \
  HTTP_TIMEOUT=2
kubectl -n core-banking rollout status deployment/servico-pix
```

`HTTP_TIMEOUT=2` alinha o lab com latência injetada de 3 s no passo 5: o cliente não deve esperar indefinidamente.

### 4. Baseline (sem toxic)

Com port-forward do *Pix* na 8000 (Lab 00):

```bash
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-01-ok' \
  -d '{"account_id":"acc_demo","amount":1,"destination":"x"}' | jq .
```

**Esperado:** resposta rápida, `status` coerente, sem `limites_unavailable`. Guarde este JSON como referência — o mesmo pedido com toxic ativo deve comportar-se diferente.

### 5. Injetar latência

Com a API do Toxiproxy acessível em `8474`:

```bash
curl -sS -X POST http://127.0.0.1:8474/proxies/limites/toxics -d '{
  "name": "latencia",
  "type": "latency",
  "attributes": { "latency": 3000, "jitter": 500 }
}'
```

Repita o `POST /v1/pix` com nova `Idempotency-Key` (ex.: `lab-01-lat`) para não acionar idempotência de testes anteriores.

**O que observar:**

- Tempo total do `curl` próximo do timeout configurado, não dos 3 s completos do toxic (graças ao timeout/retry/breaker).
- Logs do *Pix* com tentativas Tenacity (`retry`) antes de falhar ou abrir circuito.
- Possível `reason: limites_unavailable` ou erro 5xx conforme política implementada.

Compare com `kubectl -n core-banking logs deploy/servico-limites --tail=20` — *Limites* recebe pedidos atrasados; conte quantas chegam por requisição do cliente.

### 6. Resiliência no código (referência do repositório)

A política HTTP a *Limites* está em **`apps/servico-pix/app/resilience.py`**. Não misture retry ou breaker em `pix_service.py` — o domínio *Pix* só chama `await fetch_limits(account_id)`.

| Arquivo | Papel |
|---------|--------|
| `resilience.py` | `httpx` + **Tenacity** (`@retry` em `_fetch_limits_sync`) + **pybreaker** (`limites_breaker.call(...)`) |
| `pix_service.py` | Trata `CircuitBreakerError` → `reason: limites_unavailable` |

Ordem interna (de dentro para fora):

```text
httpx GET /v1/limits/{id}
  → Tenacity (backoff + jitter em 502/503/504, timeout, rede)
  → pybreaker (contagem de falhas; abertura do circuito)
  → asyncio.to_thread (não bloquear o event loop do FastAPI)
```

Consulte no [Módulo 1 — pybreaker](../modulos/modulo-01-resiliencia.md#pybreaker-o-que-é-e-onde-fica-no-código) o diagrama e as variáveis `BREAKER_FAIL_MAX`, `BREAKER_RESET_TIMEOUT`, `RETRY_MAX_ATTEMPTS`.

**Experimento obrigatório:** com toxic severo ou vários `POST /v1/pix` seguidos, force abertura do circuito. Nos logs JSON procure `circuit_breaker_state dependency=servico-limites`. Nas respostas HTTP, `"circuit_breaker": "open"` deve aparecer **sem** esperar 3 s em cada chamada (*fail-fast*).

### 7. Remover toxic e recuperar

```bash
curl -sS -X DELETE http://127.0.0.1:8474/proxies/limites/toxics/latencia
```

Envie de novo o `POST /v1/pix`. O sistema deve voltar ao comportamento do passo 4 **sem** reiniciar o cluster — prova de que a degradação era rede simulada, não estado corrompido da app.

## Passos (Docker Compose — só caos, sem k8s)

Suba a stack com `docker compose up --build`. Instale Toxiproxy no host ou como serviço no Compose e aponte o listen para `servico-limites:8001` (porta publicada no laptop). A API de administração segue na 8474. Registe no relatório do lab o proxy criado — o princípio é idêntico ao *kind*.

## Deu certo quando

- [ ] Com latência de 3 s e `HTTP_TIMEOUT=2`, o *Pix* falha de forma controlada (processo não trava).
- [ ] Retentativas Tenacity não aparecem todas no mesmo instante nos logs de *Limites* (jitter visível).
- [ ] Com toxic severo ou carga repetida, o circuit breaker abre e as respostas são *fail-fast*.
- [ ] Ao remover o toxic, o baseline do passo 4 volta sem redeploy.

## Troubleshooting

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| `connection refused` no proxy | Proxy não criado ou porta errada | Repetir passo 2; *Pix* deve usar `:8666` |
| Latência não aparece | Toxic noutro proxy ou API errada | `curl …/proxies/limites/toxics`; API na 8474 |
| Breaker nunca abre | Limiar alto ou poucas falhas | Reduzir `BREAKER_FAIL_MAX` temporariamente ou toxic `timeout` |
| *Pix* ainda chama limites direto | `LIMITES_URL` antigo no Pod | `kubectl get deploy servico-pix -o yaml \| grep LIMITES` |

## Próximo passo

[Lab 02 — OTel + Jaeger](lab-02-opentelemetry-jaeger.md) ou [Lab 02b — Kafka](lab-02b-kafka-consumer.md), conforme a ordem sugerida no [como estudar](../ebook/capitulos/07-como-estudar-com-este-livro.md).
