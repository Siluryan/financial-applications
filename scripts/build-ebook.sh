#!/usr/bin/env bash
# Ebook integrado: cada parte = teoria (módulo) + laboratório(s) em sequência.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/ebook/build"
MANIFEST="$ROOT/ebook/manifesto.txt"
MASTER="$OUT_DIR/microsservicos-financeiros-lab.md"
TITLE="Microsserviços financeiros — teoria e laboratório"
SUBTITLE="Pix, Kubernetes, observabilidade e operação em bancos digitais"
AUTHOR="Guilherme Dias"
PUBLISHER="Personal DevOps Trainer / financial-applications (open source)"
COVER="$ROOT/ebook/assets/cover.png"
DESCRIPTION="Percurso prático de microsserviços em contexto financeiro: resiliência, Kafka, OpenTelemetry, service mesh, consistência, GitOps, Backstage e operação SRE. Teoria e laboratórios com cluster kind."

mkdir -p "$OUT_DIR"

fix_images() {
  local base_dir="$1"
  if [[ -z "$base_dir" || "$base_dir" == "." ]]; then
    cat
    return
  fi
  sed -E \
    -e "s|!\[([^\]]*)\]\(\./([^)]+)\)|![\1](${base_dir}/\2)|g" \
    -e "s|!\[([^\]]*)\]\(([^./][^)]*)\)|![\1](${base_dir}/\2)|g"
}

# Leitura no ereader: sem links clicáveis (exceto imagens); listas de tarefa viram bullets.
flatten_for_ebook() {
  perl -pe '
    s/(?<!!)\[([^\]]+)\]\([^)]+\)/$1/g;
    s/<(https?:\/\/[^>]+)>/$1/g;
    s/^(\s*)- \[[ xX]\]\s*/$1- /g;
  '
}

# Nomes de ficheiro .md e pastas do repo → linguagem de livro (quem só lê o EPUB).
readerize_for_ebook() {
  perl -pe '
    s/Este arquivo é/Esta seção é/g;
    s/\*\*Aqui \((`)?PRE-REQUISITOS\.md(`)?\)\*\*/**Nesta seção (início do livro)**/g;
    s/\*\*Cada lab \((`)?labs\/lab-\*\.md(`)?\)\*\*/**Cada capítulo de laboratório**/g;
    s/\*\*(`)?PLANO_DE_ESTUDO\.md(`)?\*\*/**Plano de estudo (repositório Git)**/g;
    s/`labs\/lab-\*\.md`/cada capítulo de laboratório/g;
    s/labs\/lab-\*\.md/cada capítulo de laboratório/g;
    s/`PRE-REQUISITOS\.md`/esta seção/g;
    s/PRE-REQUISITOS\.md/Pré-requisitos/g;
    s/`PLANO_DE_ESTUDO\.md`/plano de estudo (repositório Git)/g;
    s/PLANO_DE_ESTUDO\.md/plano de estudo (repositório Git)/g;
    s/`CONVENCOES_EDITORIAIS\.md`/convenções editoriais/g;
    s/CONVENCOES_EDITORIAIS\.md/convenções editoriais/g;
    s/`SIGLAS-RAPIDAS\.md`/siglas rápidas/g;
    s/`capitulos\/README\.md`/índice dos capítulos de contexto/g;
    s/capitulos\/README\.md/índice dos capítulos de contexto/g;
    s/`modulos\/`/capítulo de teoria /g;
    s/`labs\/`/capítulo de laboratório /g;
    s/→ teoria \(`modulos\/`\)/→ teoria/g;
    s/→ lab \(`labs\/`\)/→ laboratório/g;
    s/teoria \(`modulos\/`\)/teoria/g;
    s/lab \(`labs\/`\)/laboratório/g;
    s/Glossário e apêndices \(`apps\/`, `deploy\/`\) no final/Glossário e apêndices de referência no final/g;
    s/— capítulo em `modulos\/`/— teoria/g;
    s/— `labs\/`/— laboratório/g;
    s/Manifests em `deploy\/k8s\/`/Manifests Kubernetes do laboratório/g;
    s/em `deploy\/k8s\/`/no material de deploy do laboratório/g;
    s/`docs\/[^`]+`/documento de apoio (repositório Git)/g;
    s/· `PLANO`/· plano de estudo/g;
    s/· PLANO §/· checklist (repositório), §/g;
    s/Checklist completo: plano de estudo \(repositório Git\)\./Checklists por módulo ficam no repositório Git (fora deste volume)./g;
    s/Detalhe: plano de estudo \(repositório Git\)\./Checklists expandidos: repositório Git do projeto./g;
    s/O arquivo legado `06-evolucao[^`]+`[^.]*\./Os módulos 5–7 têm capítulos de contexto dedicados neste livro./g;
    s/Monorepo \*\*financial-applications\*\*: `apps\/`, `deploy\/`, `labs\/`, `modulos\/`\./Código e manifests do laboratório ficam no repositório Git **financial-applications** (opcional para quem for reproduzir os passos)./g;
    s/plano de estudo com checklists detalhados permanece no repositório Git/Checklists detalhados e código-fonte ficam no repositório Git/g;
    s/teoria \(`modulos\/`\) e laboratório \(`labs\/`\)/teoria e laboratório/g;
    s/\| Checklist \| plano de estudo \(repositório Git\) \|/| Checklist detalhado | Repositório Git (online) |/g;
    s/`labs\/[^`]+`/laboratório desta parte do livro/g;
    s/Laboratório: laboratório desta parte do livro/Laboratório: capítulo prático desta parte/g;
    s/Laboratório completo: laboratório desta parte do livro/Laboratório completo: capítulo prático desta parte/g;
    s/para laboratório desta parte do livro/para o laboratório desta parte/g;
    s/Arquivos de referência para laboratório desta parte do livro/Arquivos de referência para o laboratório desta parte/g;
    s/Lista completa: laboratório desta parte do livro/Lista completa: exercícios de falha e troubleshooting/g;
    s/Ver laboratório desta parte do livro/Ver exercícios de falha e troubleshooting/g;
    s/`REFERENCIAS\.md`/bibliografia do repositório/g;
    s/REFERENCIAS\.md/bibliografia/g;
    s/`README\.md`/documentação do repositório/g;
    s/`deploy\/[^`]+`/material de deploy do laboratório/g;
    s/para os `\.md` dos módulos/para os capítulos de teoria/g;
    s/Imagens geradas para os `\.md`/Imagens geradas para os capítulos/g;
  '
}

prepare_content() {
  local base_dir="$1"
  if [[ -n "$base_dir" ]]; then
    fix_images "$base_dir" | flatten_for_ebook | readerize_for_ebook
  else
    flatten_for_ebook | readerize_for_ebook
  fi
}

secao_label() {
  case "$1" in
    teoria) echo "Teoria e conceitos" ;;
    lab) echo "Laboratório prático" ;;
    contexto) echo "Contexto histórico" ;;
    intro) echo "" ;;
    apendice) echo "" ;;
    *) echo "$1" ;;
  esac
}

cat >"$MASTER" <<EOF
---
title: "$TITLE"
subtitle: "$SUBTITLE"
author: "$AUTHOR"
lang: pt-BR
date: "$(date +%Y-%m-%d)"
publisher: "$PUBLISHER"
description: "$DESCRIPTION"
rights: "© $(date +%Y) — Material educacional open source. Uso livre conforme licença do repositório."
identifier:
  - scheme: URL
    text: "https://github.com/financial-applications"
cover-image: assets/cover.png
---

EOF

if [[ -f "$ROOT/ebook/colofon.md" ]]; then
  prepare_content "ebook" <"$ROOT/ebook/colofon.md" >>"$MASTER"
  echo "" >>"$MASTER"
fi

current_part=""
current_secao=""

append_file() {
  local rel="$1"
  local path="$ROOT/$rel"
  [[ -f "$path" ]] || { echo "Aviso: em falta: $rel" >&2; return; }
  local base_dir
  base_dir="$(dirname "$rel")"
  [[ "$base_dir" == "." ]] && base_dir=""

  echo "" >>"$MASTER"
  if [[ -n "$current_secao" && "$current_secao" != "intro" ]]; then
    local label
    label="$(secao_label "$current_secao")"
    if [[ -n "$label" ]]; then
      echo "### ${label}" >>"$MASTER"
      echo "" >>"$MASTER"
    fi
  fi

  if [[ -n "$base_dir" ]]; then
    prepare_content "$base_dir" <"$path" >>"$MASTER"
  else
    prepare_content "" <"$path" >>"$MASTER"
  fi
  echo "" >>"$MASTER"
}

while IFS= read -r line || [[ -n "${line:-}" ]]; do
  line="${line%%#*}"
  line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -z "$line" ]] && continue

  if [[ "$line" == @parte* ]]; then
    current_part="${line#@parte }"
    current_secao=""
    echo "" >>"$MASTER"
    echo "# ${current_part}" >>"$MASTER"
    echo "" >>"$MASTER"
    continue
  fi

  if [[ "$line" == @secao* ]]; then
    current_secao="${line#@secao }"
    continue
  fi

  append_file "$line"
done <"$MANIFEST"

echo "→ Markdown unificado: $MASTER"
echo "   $(wc -l <"$MASTER") linhas, $(du -h "$MASTER" | cut -f1)"

RESOURCE_PATH="$ROOT:$ROOT/ebook:$ROOT/ebook/assets:$ROOT/ebook/capitulos:$ROOT/modulos:$ROOT/modulos/diagramas:$ROOT/labs:$ROOT/apps:$ROOT/deploy"

if ! command -v pandoc &>/dev/null; then
  echo ""
  echo "pandoc não encontrado. Instale (sudo pacman -S pandoc) e execute de novo."
  echo "Ou importe no Calibre: $MASTER"
  exit 0
fi

EPUB="$OUT_DIR/microsservicos-financeiros-lab.epub"
PDF="$OUT_DIR/microsservicos-financeiros-lab.pdf"
EPUB_CSS="$ROOT/ebook/epub.css"

pandoc_args=(
  --from markdown+raw_html
  --no-highlight
  --toc
  --toc-depth=2
  --resource-path="$RESOURCE_PATH"
  --metadata title="$TITLE"
  --metadata subtitle="$SUBTITLE"
  --metadata author="$AUTHOR"
  --metadata lang="pt-BR"
  --metadata publisher="$PUBLISHER"
  --metadata description="$DESCRIPTION"
)

[[ -f "$EPUB_CSS" ]] && pandoc_args+=(--css="$EPUB_CSS")

if [[ -f "$COVER" ]]; then
  pandoc_args+=(--epub-cover-image="$COVER")
  echo "→ Capa: $COVER"
else
  echo "Aviso: capa não encontrada em ebook/assets/cover.png" >&2
fi

pandoc "$MASTER" -o "$EPUB" "${pandoc_args[@]}"

echo "→ EPUB: $EPUB"

generate_pdf() {
  local engine="$1"
  pandoc "$MASTER" -o "$PDF" \
    --from markdown+raw_html \
    --toc --toc-depth=2 \
    --pdf-engine="$engine" \
    -V geometry:margin=2.5cm \
    -V documentclass=report \
    -V lang=pt-BR \
    -V fontsize=10pt \
    --resource-path="$RESOURCE_PATH" \
    --metadata title="$TITLE" \
    --metadata author="$AUTHOR"
}

tex_format_ready() {
  local fmt="$1"
  kpsewhich "$fmt" &>/dev/null
}

fix_tex_formats_hint() {
  cat <<'EOF'

PDF não gerado: formato LaTeX em falta (erro comum no Arch/Manjaro).

Corrija com:

  sudo pacman -S texlive-basic texlive-bin texlive-latexrecommended texlive-latexextra
  sudo fmtutil-sys --all

Se não tiver sudo no momento, tente só para o seu utilizador:

  fmtutil-user --byfmt pdflatex
  fmtutil-user --byfmt xelatex

Depois execute de novo: ./scripts/build-ebook.sh

Alternativa sem LaTeX: use o EPUB (./scripts/open-ebook.sh) ou no Calibre:
  Converter livros → microsservicos-financeiros-lab.epub → PDF
EOF
}

if command -v pdflatex &>/dev/null || command -v xelatex &>/dev/null; then
  pdf_ok=false
  if command -v xelatex &>/dev/null && tex_format_ready "xelatex.fmt"; then
    if generate_pdf xelatex 2>/dev/null; then pdf_ok=true; fi
  fi
  if [[ "$pdf_ok" == false ]] && command -v pdflatex &>/dev/null && tex_format_ready "pdflatex.fmt"; then
    if generate_pdf pdflatex 2>/dev/null; then pdf_ok=true; fi
  fi
  if [[ "$pdf_ok" == true ]]; then
    echo "→ PDF: $PDF"
    if command -v pdfinfo &>/dev/null; then
      pages="$(pdfinfo "$PDF" 2>/dev/null | awk '/Pages:/ {print $2}')"
      [[ -n "$pages" ]] && echo "   Páginas (PDF): $pages"
    fi
  else
    fix_tex_formats_hint
  fi
else
  echo ""
  echo "LaTeX não instalado — apenas EPUB gerado."
  echo "Para PDF: sudo pacman -S texlive-basic texlive-latexrecommended && sudo fmtutil-sys --all"
fi

echo ""
echo "Concluído."
