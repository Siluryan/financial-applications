# Fundamentos — resiliência (timeout, retry, circuit breaker)

Este bloco antecede o **Módulo 1** (resiliência e caos na rede). Pressupõe os fundamentos de [HTTP](fundamentos-http-fastapi.md) e o par *Pix* → *Limites* a correr em Compose ou no cluster.

## Falha em cascata

*Limites* pode degradar-se (deploy, GC, pico). Sem limites de espera e sem proteção ao dependente, o *Pix* retém threads à espera ou insiste na chamada — e o incidente alastra-se.

## Três mecanismos

| Mecanismo | Função | No repositório |
|-----------|--------|----------------|
| **Timeout** | Teto de espera na chamada HTTP | `HTTP_TIMEOUT`, `httpx.Timeout` |
| **Retry** | Nova tentativa em falha **transitória** (503, timeout) | **Tenacity** em `_fetch_limits_sync` |
| **Circuit breaker** | Interrompe chamadas após limiar de falha | **pybreaker** — `limites_breaker.call(...)` |

## Onde está o código

Toda a política de rede para *Limites* concentra-se em **`apps/servico-pix/app/resilience.py`**, não em `pix_service.py`.

Ordem, de dentro para fora:

```text
httpx GET /v1/limits/{id}
  → Tenacity (backoff + jitter em 502/503/504, timeout, rede)
  → pybreaker (contagem de falhas; abertura do circuito)
  → asyncio.to_thread (não bloquear o event loop do FastAPI)
```

`pix_service.py` invoca `await fetch_limits(...)` e trata `CircuitBreakerError` com `limites_unavailable`.

## Toxiproxy

Proxy entre *Pix* e *Limites* que injeta latência e perda — permite calibrar timeout, retry e breaker sem alterar o serviço de *Limites* (Lab 01).

Na sequência do Módulo 1 vêm o contexto histórico, o capítulo de teoria e o laboratório com *Toxiproxy*.
