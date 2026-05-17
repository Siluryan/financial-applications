# Fundamentos — Docker e Kubernetes

Continuação do Módulo 0, após [HTTP e FastAPI](fundamentos-http-fastapi.md). O Laboratório 00 usa imagens e manifests; aqui fixamos o vocabulário mínimo de orquestração.

## Imagem e container

| Termo | Papel |
|-------|--------|
| **Imagem** | Pacote imutável (código + runtime) |
| **Container** | Processo em execução a partir da imagem |
| **`docker build`** | Produz a imagem do serviço |
| **`docker compose`** | Sobe vários containers com rede interna |

## Objetos Kubernetes usados no lab

| Objeto | Função |
|--------|--------|
| **Pod** | Um ou mais containers que partilham rede |
| **Deployment** | Mantém N réplicas do pod |
| **Service** | DNS estável (`servico-pix`, `servico-limites`) |
| **Namespace** | Agrupa recursos (`core-banking`) |

Comandos que você repetirá:

```bash
kubectl get pods -n core-banking
kubectl logs deploy/servico-pix -n core-banking
kubectl port-forward svc/servico-pix 8000:8000 -n core-banking
```

## *kind* em uma frase

Cluster Kubernetes leve dentro de containers Docker — ideal para laptop; o lab 00 cria o cluster e aplica manifests de `deploy/k8s/`.

---

Em seguida: o contexto histórico de Kubernetes e containers, e o **Laboratório 00 — Banco mínimo no *kind***.
