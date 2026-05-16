# Lab 06 — Backstage e catálogo de software

[← Índice dos labs](README.md) · **Onda 7** · [Módulo 6](../modulos/modulo-06-backstage.md) · [`PLANO` — catálogo](../PLANO_DE_ESTUDO.md#modulo-6)

## Objetivo

Registrar o sistema de laboratório no **Software Catalog** do Backstage usando os YAML já presentes no repositório.

## Antes de começar

### Conhecimento (este lab)

- **Software Catalog** = cadastro YAML de serviços ([Módulo 6](../modulos/modulo-06-backstage.md)).
- Não precisa operar cluster — é catalogação e documentação.

### Labs anteriores

- Nenhum obrigatório (útil ter feito Lab 00 para conhecer nomes `servico-pix`, etc.).

### Ambiente

- Arquivos [`catalog-info.yaml`](../catalog-info.yaml) e [`catalog-entities.yaml`](../catalog-entities.yaml) no repo.
- **Backstage** local ([demo](https://backstage.io/docs/getting-started/)) **ou** instância da empresa (Node 18+, Docker).

## Passos

### 1. Revisar entidades

```bash
cat catalog-info.yaml
cat catalog-entities.yaml
```

Confirme `System`, `Component` (*Pix*, *Limites*, *Crédito*) e relações `dependsOn`.

### 2. Backstage local (Docker)

Siga o [getting started](https://backstage.io/docs/getting-started/) oficial. No `app-config.yaml`, adicione a Location:

```yaml
catalog:
  locations:
    - type: file
      target: ../../catalog-info.yaml
```

*(Ajuste o caminho para o clone deste repositório.)*

### 3. Importar via UI

Em **Create** → **Register existing component** → informe URL do Git ou caminho file da Location.

### 4. TechDocs (opcional)

1. Crie `mkdocs.yml` na raiz apontando para `modulos/` e `PLANO_DE_ESTUDO.md`.
2. Habilite plugin TechDocs no Backstage.
3. Verifique aba **Docs** no componente `servico-pix`.

### 5. Template (opcional)

Esboce um `template.yaml` que gere skeleton FastAPI + Dockerfile + `catalog-info.yaml` (não precisa publicar no GitHub real).

## Deu certo quando

- [ ] Componentes aparecem no catálogo com owner e lifecycle.
- [ ] Grafo de dependências mostra *Pix* → *Limites*.
- [ ] Link para documentação (`modulos/` ou TechDocs) acessível a partir do componente.

## Próximo passo

Labs [07a–07f](README.md#ordem-sugerida) (operação e conformidade).
