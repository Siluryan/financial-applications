# Fundamentos — Istio e service mesh

Este bloco antecede o **Módulo 3** (service mesh, mTLS e políticas). *Pix* e *Limites* devem já estar no Kubernetes — reveja [Docker e Kubernetes](fundamentos-docker-kubernetes.md) se necessário.

## Service mesh

Um **mesh** acrescenta proxies (**sidecars**) junto a cada Pod. O tráfego **entre serviços** passa pelo proxy — do ponto de vista da plataforma, não pelo socket direto da aplicação.

A aplicação mantém `http://servico-limites:8000`; o sidecar **Envoy** intercepta a ligação.

## Conceitos do lab

| Conceito | Uso no lab |
|----------|------------|
| **Sidecar** | Proxy no mesmo Pod que a app |
| **mTLS** | Certificados mútuos entre workloads |
| **AuthorizationPolicy** | Quem pode invocar quem (SPIFFE, namespace) |
| **PeerAuthentication** | Modo STRICT — só tráfego mTLS |
| **VirtualService** | Regras de roteamento (canary no Módulo 5) |

## Implicações para quem desenvolve

- A rede interna deixa de ser implicitamente confiável.
- Políticas passam a manifestos no cluster, não só a bibliotecas na app.
- Métricas e traces de tráfego L4/L7 surgem no mesh.

Em seguida: contexto histórico do mesh e o laboratório Istio do Módulo 3.
