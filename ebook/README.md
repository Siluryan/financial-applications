# Ebook — teoria + laboratório integrados

O ebook **não** inclui o `README.md` do repositório nem o `PLANO_DE_ESTUDO.md` integral (evita duplicação e tom de “índice técnico”). Em vez disso:

1. **[`INTRODUCAO.md`](INTRODUCAO.md)** — prefácio (público, cenário, espinha dorsal).
2. **[`SIGLAS-RAPIDAS.md`](SIGLAS-RAPIDAS.md)** — tabela de siglas para consulta durante a leitura.
3. **[`PRE-REQUISITOS.md`](PRE-REQUISITOS.md)** — o que você precisa saber (HTTP, Docker, K8s, Python, SQL) antes dos labs.
4. **Cada parte** — contexto histórico ([`capitulos/`](capitulos/)) + teoria em [`modulos/`](../modulos/) + **lab** em [`labs/`](../labs/).

A ordem está em [`manifesto.txt`](manifesto.txt). O plano completo com checklists detalhados permanece em [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md) no Git.

## Estrutura das partes

| Parte | Teoria | Lab(s) |
|-------|--------|--------|
| Introdução | [`INTRODUCAO.md`](INTRODUCAO.md) | — |
| Módulo 0 | contexto + [fundamentos](../modulos/modulo-00-fundamentos-distribuidos.md) | — |
| Onda 0 | contexto K8s + [lab-00](../labs/lab-00-kind-banco-minimo.md) | lab |
| Onda 0 | — | [lab-00](../labs/lab-00-kind-banco-minimo.md) |
| Módulo 1 | contexto incidentes + [resiliência](../modulos/modulo-01-resiliencia.md) | [lab-01](../labs/lab-01-toxiproxy-resiliencia.md) |
| Módulo 2 | contexto OTel/Kafka + [observabilidade](../modulos/modulo-02-observabilidade.md) | [02](../labs/lab-02-opentelemetry-jaeger.md), [02b](../labs/lab-02b-kafka-consumer.md) |
| Módulo 3 | contexto mesh + [mTLS](../modulos/modulo-03-service-mesh.md) | [lab-03](../labs/lab-03-istio-mtls.md) |
| Módulo 4 | contexto Postgres/Redis + incidentes + [consistência](../modulos/modulo-04-consistencia.md) | [lab-04](../labs/lab-04-redis-postgres-idempotencia.md) |
| Módulo 5 | contexto GitOps + [deploy](../modulos/modulo-05-deploy-gitops.md) | [lab-05](../labs/lab-05-canary-gitops.md) |
| Módulo 6 | contexto Backstage + [DX](../modulos/modulo-06-backstage.md) | [lab-06](../labs/lab-06-backstage-catalogo.md) |
| Módulo 7 | contexto LGPD/PCI + governança + incidentes + [operação](../modulos/modulo-07-operacao-conformidade.md) | [07a–07f](../labs/README.md) |
| Glossário | [`GLOSSARIO.md`](GLOSSARIO.md) | — |
| Apêndice | READMEs `apps/`, `deploy/` | — |

## Gerar

```bash
chmod +x scripts/build-ebook.sh
./scripts/build-ebook.sh
```

Requer [pandoc](https://pandoc.org/) para EPUB/PDF. Sem pandoc, usa-se só o `.md` unificado em `ebook/build/`.

O build **não** inclui linhas `Fonte: caminho/arquivo.md`. Links viram **texto** (URLs deixam de ser clicáveis); **imagens dos módulos são preservadas** (`modulos/diagramas/*.png`). Regenere diagramas com `./scripts/render-diagramas.sh` antes do ebook se editou `.mmd`. Listas `- [ ]` dos labs viram **bullets** (sem checkbox clicável no ereader).

**Acabamento de livro:** capa em [`assets/cover.png`](assets/cover.png) (retrato 1600×2560), folha de [`colofon.md`](colofon.md), metadados Dublin Core (autor: Guilherme Dias), [`sobre-o-autor.md`](sobre-o-autor.md) no **final** do volume (após glossário e apêndice), sumário em português, quebra de página antes de cada parte/módulo. Tipografia: [`epub.css`](epub.css) — corpo **9pt**.

Manjaro / Arch:

```bash
sudo pacman -S pandoc texlive-basic texlive-bin texlive-latexrecommended texlive-latexextra
sudo fmtutil-sys --all
./scripts/build-ebook.sh
```

Se aparecer `I can't find the format file pdflatex.fmt`, o TeX está instalado mas os **formatos não foram gerados** — o `fmtutil-sys --all` acima corrige. O EPUB é gerado na mesma execução mesmo quando o PDF falha.

### Contagem de páginas (só no PDF)

Com o PDF gerado:

```bash
pdfinfo ebook/build/microsservicos-financeiros-lab.pdf | grep Pages
```

No **EPUB** (Foliate) o número de “páginas” varia com o tamanho da fonte — não é fixo.

## Personalizar

- **Incluir o plano completo:** adicione `PLANO_DE_ESTUDO.md` ao `manifesto.txt` após a introdução (aumenta bastante o tamanho do EPUB).
- **Só um módulo:** copie no manifesto apenas o bloco `@parte Módulo N …` desejado.
- **Nova ordem:** edite `manifesto.txt` (`@parte`, `@secao teoria|lab`, caminhos `.md`).

## Abrir o EPUB no Manjaro / Linux

O ficheiro **está correto**; o problema costuma ser **falta de leitor** ou associação errada (o sistema abre o gestor de ficheiros ou o File Roller em vez de um app de livros).

### Foliate (recomendado)

```bash
sudo pacman -S foliate
./scripts/open-ebook.sh
```

Ou diretamente:

```bash
foliate ebook/build/microsservicos-financeiros-lab.epub
```

### Calibre

```bash
sudo pacman -S calibre
ebook-viewer ebook/build/microsservicos-financeiros-lab.epub
```

### Associar EPUB ao Foliate (clique duplo no Dolphin)

```bash
xdg-mime default com.github.johnfactotum.Foliate.desktop application/epub+zip
```

*(O nome do `.desktop` pode variar; liste com `ls /usr/share/applications/*foliate*`.)*

### Ler sem EPUB (Markdown unificado)

Abra no editor o Markdown unificado:

`ebook/build/microsservicos-financeiros-lab.md`

### No Cursor

Clique com o botão direito no `.epub` → **Reveal in File Manager** e abra com Foligate **a partir do terminal**, ou use **Open With** no Dolphin após instalar o Foliate.

## Saída e Git

Artefactos em `ebook/build/` (ignorados pelo Git). Fonte da verdade = Markdown no repositório.

## Licença

[`LICENSE`](../LICENSE) do repositório.
