# Fundamentos — HTTP e FastAPI

Este bloco prepara o **Laboratório 00** do Módulo 0. Pressupõe que você já sabe enviar pedidos HTTP com corpo JSON e interpretar códigos de resposta — não é um curso introdutório de redes.

## Verbo, rota e contrato

| Ideia | Exemplo no lab |
|-------|----------------|
| **GET** | Consultar estado (`GET /health`) |
| **POST** | Criar operação (`POST /v1/pix`) |
| **JSON** | Corpo `{"valor": 10.0, "conta_destino": "..."}` |
| **Status** | `200` ok, `400` validação, `502` dependência falhou |

No FastAPI, rota + modelo Pydantic definem o contrato que o cliente e o *Limites* devem respeitar.

## `curl` mínimo

```bash
curl -sS http://127.0.0.1:8000/health
curl -sS -X POST http://127.0.0.1:8000/v1/pix \
  -H 'Content-Type: application/json' \
  -d '{"valor": 1.0, "conta_destino": "00012345"}'
```

## Swagger (`/docs`)

Interface gerada a partir dos tipos — útil para inspecionar schemas antes de automatizar testes.

---

Depois deste capítulo vêm **Fundamentos — Docker e Kubernetes**, o contexto histórico de containers e o Laboratório 00.
