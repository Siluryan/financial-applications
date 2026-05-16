## Vazamento de dados e confiança

### Equifax (2017)

Falha de patch e segmentação em sistema legado; exposição massiva de dados pessoais. Lições: **atualização**, **segmentação**, inventário do que está exposto — não só “app novo em K8s”.

### Logs públicos acidentalmente

Buckets S3 ou índices Elasticsearch abertos com dumps de aplicação — CPF, senha, PAN. Lição do lab **07f**: PII em log/trace é **incidente esperado** se não houver máscara e política.

### Credencial no GitHub

Tokens e chaves commitados; bots varrem repositórios em minutos. Lição do lab **07a**: cofre + External Secrets; nunca treinar time a copiar `.env` para o repo.

## Deploy e supply chain

### SolarWinds (2020)

Compromisso na cadeia de build — artefato confiável virou vetor. Lição: imagem assinada, scan, SBOM (tema transversal no Módulo 7).

### Manifest sem limites

Pod consome nó inteiro; vizinhos morrem — não é “hackeado”, é **governança ausente**. Lição: Kyverno lab **07d**.

## Contrato quebrado silenciosamente

Consumidor interno assume JSON estável; provedor renomeia campo — falha só em produção no fim de semana. Lição: **Pact** lab **07c**.

## Tabela: incidente → prática no lab

| Tipo | Lab / módulo |
|------|----------------|
| Segredo vazado | 07a |
| Evento perdido / duplicado | 07b, Módulo 4 |
| API quebrada | 07c |
| Deploy inseguro | 07d |
| Restore nunca testado | 07e |
| PII em trace | 07f |

## O que não é objetivo deste capítulo

Não substituir assessoria jurídica nem checklist PCI oficial — ancora **por que** o lab existe em banco real.
