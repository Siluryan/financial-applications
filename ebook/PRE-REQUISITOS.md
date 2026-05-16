# Pré-requisitos do curso (conhecimento)

Esta seção é só sobre **conhecimento e hábitos** — o que ajuda a entender o texto e os módulos **antes** de abrir qualquer laboratório.

Não confunda com:

| Onde | O que lista |
|------|-------------|
| **Nesta seção (início do livro)** | Base do **curso inteiro** (HTTP, Docker, K8s, Python, SQL) |
| **Cada capítulo de laboratório** | Três blocos: **Conhecimento deste lab** · **Labs anteriores** · **Ambiente** (ferramentas, RAM, cluster) |
| **Plano de estudo (repositório Git)** | Ordem das ondas e checklists — aponta para o conhecimento acima |

Se um lab diz “precisa do Lab 00”, isso é **lab anterior** (você já subiu o cluster), não “precisa ser expert em Kubernetes”.

---

## HTTP e APIs REST

O *Pix* e o *Limites* conversam por HTTP. O cliente chama o *Pix* com POST e JSON.

| Precisa entender | Uso no curso |
|------------------|--------------|
| **GET** e **POST** | Consultar limites; iniciar pagamento |
| Códigos **2xx**, **4xx**, **5xx** | Saber se o erro é do cliente, do serviço ou do dependente |
| Cabeçalhos (`Content-Type`, `Idempotency-Key`, `traceparent`) | Idempotência e rastreio |
| Corpo **JSON** | Payloads dos exemplos `curl` |
| Testar com **curl** ou `/docs` (Swagger) | Validar lab sem criar app cliente |

Não precisa, neste curso: desenhar API do zero, OAuth completo ou HTTP/2 em profundidade.

## Docker

| Precisa entender | Uso no curso |
|------------------|--------------|
| **Imagem** vs **container** | `docker compose` e imagens `servico-pix:lab` |
| `docker compose up --build` | Subir stack no laptop |
| Ler **Dockerfile** simples | Saber o que entra na imagem |

## Kubernetes (básico)

| Precisa entender | Uso no curso |
|------------------|--------------|
| **Pod**, **Deployment**, **Service** | Manifests do laboratório |
| `kubectl apply -k`, `get pods`, `logs` | Operar labs no *kind* |
| **Namespace** | Recursos em `core-banking` |

Ferramentas: [kind](https://kind.sigs.k8s.io/), `kubectl`. O **Lab 00** (Onda 0) guia o primeiro deploy — lá estão os requisitos de **ambiente** (Docker, RAM, etc.).

## Python 3.11+

Ler e ajustar código **FastAPI** pequeno; `pip install` de libs dos labs; variáveis de ambiente (`KAFKA_BOOTSTRAP_SERVERS`, etc.). Não é curso de Python do zero.

## SQL

`SELECT`, `INSERT`, `UPDATE`; ideia de **transação**; constraint **UNIQUE** (idempotência e outbox no Módulo 4).

## Kafka

**Não é pré-requisito de entrada.** Ensinado no Módulo 2 / Lab 02b (tópico, consumer group, *lag*).

## Máquina e ritmo

| Situação | Sugestão |
|----------|----------|
| **16 GB+ RAM** | *kind* + uma stack pesada por vez |
| **8 GB RAM** | Compose nos primeiros módulos; no *kind*, não subir Istio + Kafka + Jaeger juntos |
| Porta 8000 ocupada | `PIX_HOST_PORT=18000 docker compose up` |
| Ritmo | ~1 módulo/semana (teoria + lab) |

## O que o curso não ensina do zero

Python para iniciantes, redes em profundidade, certificação CKA. Se faltar base, comece por `docker compose up` e o **Lab 00** antes do *kind*.
