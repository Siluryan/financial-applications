# Ebook — teoria + laboratório integrados

O ebook **não** inclui o `README.md` do repositório nem o `PLANO_DE_ESTUDO.md` integral (evita duplicação e tom de “índice técnico”). Em vez disso:

1. **[`INTRODUCAO.md`](INTRODUCAO.md)** — prefácio (público, cenário, espinha dorsal).
2. **[`SIGLAS-RAPIDAS.md`](SIGLAS-RAPIDAS.md)** — tabela de siglas para consulta durante a leitura.
3. **[`PRE-REQUISITOS.md`](PRE-REQUISITOS.md)** — o que você precisa saber (HTTP, Docker, K8s, Python) antes dos labs.
4. **[`capitulos/fundamentos-indice.md`](capitulos/fundamentos-indice.md)** — fundamentos repartidos antes de cada módulo (2.ª ed.).
5. **[`AVISO-LEGAL-EDITORIAL.md`](AVISO-LEGAL-EDITORIAL.md)** — direitos autorais e marcas (obrigatório para KDP).
6. **[`FORMACAO-ABNT.md`](FORMACAO-ABNT.md)** — notas de produção ABNT (autor; **não** entra no EPUB).
7. **Cada parte** — contexto histórico ([`capitulos/`](capitulos/)) + teoria em [`modulos/`](../modulos/) + **lab** em [`labs/`](../labs/).

Formatação ABNT: [`FORMACAO-ABNT.md`](FORMACAO-ABNT.md). Publicação KDP: [`KDP-PUBLICACAO.md`](KDP-PUBLICACAO.md).

A ordem está em [`manifesto.txt`](manifesto.txt). O plano completo com checklists detalhados permanece em [`PLANO_DE_ESTUDO.md`](../PLANO_DE_ESTUDO.md) no Git.

## Estrutura das partes

| Parte | Teoria | Lab(s) |
|-------|--------|--------|
| Introdução | [`INTRODUCAO.md`](INTRODUCAO.md) | — |
| Módulo 0 | contexto + [fundamentos](../modulos/modulo-00-fundamentos-distribuidos.md) | — |
| Módulo 0 | teoria + fundamentos + contexto K8s + [lab-00](../labs/lab-00-kind-banco-minimo.md) | lab |
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

O script **instala automaticamente** (com `sudo`, se necessário) o que faltar:

| Pacote | Perfil | Uso |
|--------|--------|-----|
| **pandoc** | EPUB (obrigatório) | Sempre tentado se ausente |
| **texlive** | PDF | Ao gerar PDF ou com `--install-deps` |
| **poppler** | `pdfinfo` | Contagem de páginas no PDF |

Opções:

```bash
./scripts/build-ebook.sh              # instala pandoc (e LaTeX ao gerar PDF)
./scripts/build-ebook.sh --install-deps   # pandoc + TeX + poppler de uma vez
./scripts/build-ebook.sh --skip-install   # só usa o que já está no sistema
```

Sem pandoc e com `--skip-install`, o Markdown unificado em `ebook/build/` é gerado na mesma execução, mas o script termina com erro antes do EPUB.

O build **não** inclui linhas `Fonte: caminho/arquivo.md`. Links viram **texto** (URLs deixam de ser clicáveis); referências a ficheiros `.md` e pastas do repo são **reescritas** para linguagem de livro (ex.: “cada capítulo de laboratório” em vez de `labs/lab-*.md`). **Imagens dos módulos são preservadas** (`modulos/diagramas/*.png`). Regenere diagramas com `./scripts/render-diagramas.sh` antes do ebook se editou `.mmd`. Listas `- [ ]` dos labs viram **bullets** (sem checkbox clicável no ereader).

**Acabamento de livro:** capa em [`assets/cover.png`](assets/cover.png) (retrato 1600×2560), folha de [`colofon.md`](colofon.md), metadados Dublin Core (autor: Guilherme Rogério Ramos Dias), [`sobre-o-autor.md`](sobre-o-autor.md) no **final** do volume (após glossário e apêndice), **Sumário** enxuto (só **partes** e seções *Contexto* / *Teoria* / *Laboratório* — títulos internos dos capítulos não entram no índice), quebra de página antes de cada parte/módulo. Entre **contexto**, **teoria** e **lab**, o build insere *A seguir — …* no fim da seção anterior e uma página só com o título da seguinte (classes `secao-ponte` / `secao-divisor` em [`epub.css`](epub.css)). Tipografia: corpo **9pt**. Blocos de código sem fundo claro fixo nem *syntax highlighting* colorido (`--no-highlight`), para leitura aceitável em modo escuro do leitor.

Manjaro / Arch (instalação manual, se preferir não usar o script):

```bash
sudo pacman -S pandoc texlive-basic texlive-bin texlive-latexrecommended texlive-latexextra poppler
sudo fmtutil-sys --all
./scripts/build-ebook.sh --skip-install
```

Se aparecer `I can't find the format file pdflatex.fmt`, o TeX está instalado mas os **formatos não foram gerados** — o script tenta `fmtutil-sys` / `fmtutil-user`; ou execute `sudo fmtutil-sys --all`. O EPUB é gerado na mesma execução mesmo quando o PDF falha.

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
