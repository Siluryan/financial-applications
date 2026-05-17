# Fundamentos — GitOps e deploy

Este bloco antecede o **Módulo 5** (deploy, canary e GitOps). Pressupõe Kubernetes instalado; para canary com Istio, reveja [Istio e mesh](fundamentos-istio-mesh.md).

## GitOps

O repositório **Git** descreve o estado desejado do cluster. **Argo CD** (ou ferramenta equivalente) compara cluster e repositório e reconcilia. **Drift** é qualquer desvio não intencional em relação ao Git.

| Ideia | Significado |
|-------|-------------|
| **Declarativo** | Manifestos versionados; evitar `kubectl edit` ad hoc em produção |
| **Reconciliação** | O operador corrige o cluster em direção ao Git |
| **Pull** | O cluster obtém o estado desejado do repositório |

## Deploy e tráfego

| Conceito | No lab |
|----------|--------|
| **Rolling update** | Substituição gradual de Pods |
| **Canary** | Fração pequena do tráfego na versão nova |
| **VirtualService** | Pesos v1/v2 no Istio |
| **HPA** | Réplicas adicionais sob carga (teoria do M5) |

`servico-credito` usa `SERVICE_VERSION` (v1/v2) nos exercícios de canary.

## Relação com o *Pix*

O canary do repositório centra-se em **crédito** (`deploy/k8s/`). O *Pix* já consome ConfigMap/Secret para `LIMITES_URL` e `DATABASE_URL` (Módulo 7a).

Em seguida: contexto histórico e laboratório do Módulo 5.
