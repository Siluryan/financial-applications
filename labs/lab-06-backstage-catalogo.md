# Lab 06 — Backstage e catálogo de software

[← Índice dos labs](README.md) · [Módulo 6](../modulos/modulo-06-backstage.md)

## Objetivo

Registar o sistema de laboratório no **Software Catalog** do Backstage a partir dos YAML versionados no repositório, ligar documentação (TechDocs) e definir um template de serviço.

Bancos digitais com dezenas de serviços perdem o mapa “quem chama quem”. O catálogo não substitui observabilidade — é o **inventário** com dono, ciclo de vida e dependências declaradas. Este lab não exige cluster Kubernetes a correr.

**Tempo estimado:** 60–90 min (mais tempo se instalar Backstage local pela primeira vez).

## Antes de começar

### Conhecimento (este lab)

- **Software Catalog** = entidades YAML (`Component`, `System`, `API`) ([Módulo 6](../modulos/modulo-06-backstage.md)).

### Labs anteriores

Nenhum obrigatório. O Lab 00 ajuda a reconhecer nomes `servico-pix`, `servico-limites`, `servico-credito`.

### Ambiente

- [`catalog-info.yaml`](../catalog-info.yaml) e [`catalog-entities.yaml`](../catalog-entities.yaml) no repo.
- Backstage local ([getting started](https://backstage.io/docs/getting-started/)) ou instância corporativa (Node 18+, Docker).

## Passos

### 1. Revisar entidades

```bash
cat catalog-info.yaml
cat catalog-entities.yaml
```

Identifique:

- **System** — agrupamento do banco lab.
- **Components** — *Pix*, *Limites*, *Crédito*.
- **Relações** `dependsOn` — *Pix* depende de *Limites*?

Anote inconsistências (nome no YAML vs pasta `apps/servico-pix`) para corrigir antes de importar.

### 2. Backstage local (Docker)

Siga o [getting started](https://backstage.io/docs/getting-started/) oficial. No `app-config.yaml` da instância, adicione Location apontando ao clone deste repositório:

```yaml
catalog:
  locations:
    - type: file
      target: ../../catalog-info.yaml
```

Ajuste o caminho relativo à raiz do app Backstage.

Reinicie o Backstage e abra a UI (porta 3000 por defeito).

### 3. Importar via UI

**Create** → **Register existing component** → URL do Git ou caminho file da Location.

Após processamento, abra o componente `servico-pix` e verifique abas Overview, dependências e links.

### 4. TechDocs

1. Crie `mkdocs.yml` na raiz apontando para `modulos/` e `PLANO_DE_ESTUDO.md`.
2. Habilite plugin TechDocs no Backstage.
3. Na ficha do componente, abra **Docs** e confirme renderização Markdown.

TechDocs aproxima código e documentação no mesmo lugar que o desenvolvedor já usa.

### 5. Template de serviço

Defina `template.yaml` que gera skeleton FastAPI + Dockerfile + `catalog-info.yaml` para novos serviços do laboratório.

## Deu certo quando

- [ ] Componentes visíveis com `owner` e `lifecycle`.
- [ ] Grafo mostra *Pix* → *Limites*.
- [ ] Link para documentação (`modulos/` ou TechDocs) acessível a partir do componente.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Location falha | Caminho file; permissões; YAML válido |
| Componente duplicado | Remover Location antiga na UI |
| TechDocs vazio | `mkdocs build` local para testar |

## Próximo passo

Labs [07a–07g](README.md#ordem-sugerida) — operação e conformidade.
