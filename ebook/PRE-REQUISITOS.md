# Pré-requisitos do curso (conhecimento)

Este capítulo trata de **recursos de hardware e ritmo de estudo**. Termos de HTTP, Kubernetes, Kafka e afins aparecem nos blocos *Fundamentos* que antecedem cada módulo — ver o [índice](capitulos/fundamentos-indice.md).

| Onde | O que lista |
|------|-------------|
| **Aqui** | RAM, ritmo, o que o curso não ensina do zero |
| **[Índice dos fundamentos](capitulos/fundamentos-indice.md)** | Tabela “antes de qual módulo ler o quê” |
| **Cada parte do livro** | Bloco **Fundamentos — …** imediatamente antes do contexto/teoria |
| **Cada lab** | Conhecimento deste lab · Labs anteriores · Ambiente |

---

## Máquina e ritmo

| Situação | Sugestão |
|----------|----------|
| **16 GB+ RAM** | *kind* + uma stack pesada por vez |
| **8 GB RAM** | Compose nos primeiros módulos; no *kind*, não subir Istio + Kafka + Jaeger juntos |
| Porta 8000 ocupada | `PIX_HOST_PORT=18000 docker compose up` |
| Ritmo | ~1 módulo/semana (teoria + lab) |

## O que o curso não ensina do zero

Python para iniciantes, redes em profundidade, certificação CKA. Ordem sugerida: [Índice dos fundamentos](capitulos/fundamentos-indice.md) → **Lab 00** (Compose ou kind) conforme cada capítulo.
