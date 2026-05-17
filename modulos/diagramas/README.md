# Diagramas dos módulos

Os guias em [`modulos/`](../) embutem **imagens PNG** no Markdown (`![legenda](diagramas/....png)`). O código-fonte Mermaid fica em [`mmd/`](mmd/).

**Leitura no ebook:** regenere com `./scripts/build-ebook.sh` após alterar diagramas — o EPUB inclui as PNG quando o build está atualizado (ver `scripts/build-ebook.sh`, função `flatten_for_ebook`, que **preserva** imagens).

| Pasta / ficheiro | Conteúdo |
|------------------|----------|
| [`mmd/`](mmd/) | Fonte **Mermaid** (`.mmd`) — edite aqui |
| `*.png` | Imagens geradas para os `.md` dos módulos |
| `mermaid-config.json` | Tema editorial (cores, tipografia, espaçamento) |
| `mermaid-custom.css` | Ajustes finos no SVG (traços, cantos, labels) |

## Qualidade para impressão (KDP)

Os PNG são gerados para **impressão a 300 DPI**:

| Parâmetro | Predefinição | Efeito |
|-----------|--------------|--------|
| `MERMAID_WIDTH` | `2200` | Largura lógica do diagrama (px) |
| `MERMAID_SCALE` | `2` | Escala Puppeteer (resolução efetiva ≈ largura × escala) |
| `MERMAID_DPI` | `300` | Metadados DPI gravados no PNG (`scripts/embed-png-dpi.py`) |

Exemplo: largura 2200 × escala 2 ≈ **4400 px** na imagem final — suficiente para figuras de ~14 cm a 300 DPI no PDF do livro.

## Regenerar PNG após editar um diagrama

```bash
./scripts/render-diagramas.sh
```

Requer **Pillow** (`python3-pil` ou `pip install Pillow`). Se `npx` não existir no sistema, o script instala Node portátil em `.tools/node` e o Mermaid CLI em `node_modules/` (ambos ignorados pelo Git).

Diagramas muito altos (sequências longas): pode aumentar só esse ficheiro com altura explícita no `mmdc` ou ajustar `MERMAID_WIDTH` / `MERMAID_SCALE` antes do build.

## Índice de imagens

| PNG | Módulo | Assunto |
|-----|--------|---------|
| `m01-fluxo-toxiproxy.png` | 1 | Cliente → *Pix* → *Toxiproxy* → *Limites* |
| `m01-circuit-breaker.png` | 1 | Estados Closed / Open / Half-open |
| `m01-retry-storm.png` | 1 | Retry amplification |
| `m00-arquitetura-salas.png` | 0 | Monólito vs microsserviços |
| `m00-cap-tradeoff.png` | 0 | CAP em partição |
| `m01-timeout-chain.png` | 1 | Cadeia gateway → Pix → Limites |
| `m02-tres-pilares.png` | 2 | Métricas, logs, traces |
| `m02-sampling-strategies.png` | 2 | Head vs tail sampling |
| `m02-trace-propagation.png` | 2 | traceparent HTTP → Kafka |
| `m02-kafka-partitions.png` | 2 | Partições, chave, brokers |
| `m02-kafka-isr.png` | 2 | Leader, ISR, acks=all |
| `m02-red-use.png` | 2 | RED vs USE |
| `m02-cardinalidade.png` | 2 | Labels seguros vs explosão |
| `m02-rebalance-storm.png` | 2 | Rebalance em loop |
| `m02-dlq-poison.png` | 2 | Poison pill → DLQ |
| `m02-otel-pipeline.png` | 2 | App → Collector → backends |
| `m02-kafka-consumer-group.png` | 2 | Partições e consumer group |
| `m02-trace-pix.png` | 2 | Trace ponta a ponta (*Pix*, *Limites*, Kafka) |
| `m03-mesh-fluxo.png` | 3 | Sidecars, mTLS, Istiod |
| `m03-control-plane.png` | 3 | Control plane vs data plane |
| `m03-tls-vs-mtls.png` | 3 | TLS one-way vs mTLS |
| `m03-auth-policy.png` | 3 | *AuthorizationPolicy* no Envoy |
| `m03-mtls-handshake.png` | 3 | Handshake mTLS entre sidecars |
| `m03-mesh-landscape.png` | 3 | Istio, Linkerd, Cilium, ambient |
| `m04-saga.png` | 4 | Saga com compensação |
| `m04-saga-orchestration.png` | 4 | Orquestração com compensação |
| `m04-isolamento-mvcc.png` | 4 | MVCC e versão na linha |
| `m04-2pc-vs-saga.png` | 4 | 2PC vs saga |
| `m06-catalog-grafo.png` | 6 | Grafo Backstage |
| `m06-golden-path.png` | 6 | Golden path / template |
| `m04-outbox.png` | 4 | Transactional outbox |
| `m04-saga-estilos.png` | 4 | Orquestração vs coreografia |
| `m05-canary.png` | 5 | Canary por peso |
| `m05-gitops.png` | 5 | Git → Argo CD → cluster |
| `m07-incident-response.png` | 7 | IC, mitigação, postmortem |
| `m07-burn-rate.png` | 7 | Multi-window burn rate |
| `m07-sli-slo-sla.png` | 7 | SLI → SLO → error budget |
| `mtls-sidecar-fluxo.png` | 3 | Ilustração de referência (opcional) |
