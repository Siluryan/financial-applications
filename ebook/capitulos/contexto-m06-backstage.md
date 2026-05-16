## O problema dos cem repositórios

Spotify (e outros) chegaram a centenas de serviços sem mapa único: onboarding lento, incidente virando “quem é dono disso?”. **Backstage** (open source **2020**) centraliza **Software Catalog**, **TechDocs** e **Templates**.

## Platform engineering

| Conceito | Significado |
|----------|-------------|
| **IDP** | “Shopping” interno de ferramentas e padrões |
| **Golden path** | Novo serviço já com CI, OTel, `catalog-info.yaml` |
| **Scorecards** | Maturidade visível (testes, SLO, scan) |

Backstage não deploya pod — dá **contexto humano** ao que o Kubernetes já rodou.

## Catálogo em banco

Regulatório pede: qual sistema processa pagamento, quem mantém, qual API expõe. YAML no repo (`catalog-entities.yaml`) alimenta auditoria e escalação.

**Anti-pattern:** `owner: unknown` em tudo — catálogo mentiroso.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2016+ | “Platform teams” em tech |
| 2020 | Backstage OSS (Spotify) |
| 2020s | Portais internos + scorecards |
