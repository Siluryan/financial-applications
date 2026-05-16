# Diagramas dos módulos

Os guias em [`modulos/`](../) mostram **só imagens PNG** — o código dos gráficos fica aqui, fora da leitura principal.

| Pasta / ficheiro | Conteúdo |
|------------------|----------|
| [`mmd/`](mmd/) | Fonte **Mermaid** (`.mmd`) — edite aqui |
| `*.png` | Imagens geradas para os `.md` dos módulos |

## Regenerar PNG após editar um diagrama

```bash
./scripts/render-diagramas.sh
```

Requer Node.js (`npx`). O script usa [@mermaid-js/mermaid-cli](https://github.com/mermaid-js/mermaid-cli).

## Índice de imagens

| PNG | Módulo | Assunto |
|-----|--------|---------|
| `m01-fluxo-toxiproxy.png` | 1 | Cliente → *Pix* → *Toxiproxy* → *Limites* |
| `m01-circuit-breaker.png` | 1 | Estados Closed / Open / Half-open |
| `m01-retry-storm.png` | 1 | Retry amplification |
| `m02-tres-pilares.png` | 2 | Métricas, logs, traces |
| `m02-otel-pipeline.png` | 2 | App → Collector → backends |
| `m02-kafka-consumer-group.png` | 2 | Partições e consumer group |
| `m02-trace-pix.png` | 2 | Trace ponta a ponta (*Pix*, *Limites*, Kafka) |
| `m03-mesh-fluxo.png` | 3 | Sidecars, mTLS, Istiod |
| `m03-control-plane.png` | 3 | Control plane vs data plane |
| `m03-tls-vs-mtls.png` | 3 | TLS one-way vs mTLS |
| `m03-auth-policy.png` | 3 | *AuthorizationPolicy* no Envoy |
| `m04-saga.png` | 4 | Saga com compensação |
| `m04-outbox.png` | 4 | Transactional outbox |
| `m04-saga-estilos.png` | 4 | Orquestração vs coreografia |
| `m05-canary.png` | 5 | Canary por peso |
| `m05-gitops.png` | 5 | Git → Argo CD → cluster |
| `mtls-sidecar-fluxo.png` | 3 | Ilustração de referência (opcional) |
