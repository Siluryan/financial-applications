#!/usr/bin/env bash
# Ebook integrado: cada parte = teoria (módulo) + laboratório(s) em sequência.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/ebook/build"
MANIFEST="$ROOT/ebook/manifesto.txt"
MASTER="$OUT_DIR/microsservicos-financeiros-lab.md"
TITLE="Microsserviços financeiros — teoria e laboratório"
AUTHOR="financial-applications"

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

# Leitura no ereader: sem links clicáveis; listas de tarefa viram bullets normais.
flatten_for_ebook() {
  perl -pe '
    s/\[([^\]]+)\]\([^)]+\)/$1/g;
    s/<(https?:\/\/[^>]+)>/$1/g;
    s/^(\s*)- \[[ xX]\]\s*/$1- /g;
  '
}

prepare_content() {
  local base_dir="$1"
  if [[ -n "$base_dir" ]]; then
    fix_images "$base_dir" | flatten_for_ebook
  else
    flatten_for_ebook
  fi
}

secao_label() {
  case "$1" in
    teoria) echo "Teoria e conceitos" ;;
    lab) echo "Laboratório prático" ;;
    contexto) echo "Contexto histórico" ;;
    intro) echo "" ;;
    apendice) echo "Referência" ;;
    *) echo "$1" ;;
  esac
}

cat >"$MASTER" <<EOF
---
title: "$TITLE"
author: "$AUTHOR"
lang: pt-BR
date: "$(date +%Y-%m-%d)"
---

# $TITLE

Cada parte traz **teoria** (capítulo do módulo) e **laboratório prático** em seguida. Este volume é autocontido para leitura no ereader; o plano de estudo expandido com checklists permanece no repositório Git do projeto, se precisar do roteiro completo fora do livro.

---

EOF

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
    echo "### ${label}" >>"$MASTER"
    echo "" >>"$MASTER"
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
    echo "---" >>"$MASTER"
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

RESOURCE_PATH="$ROOT:$ROOT/ebook:$ROOT/ebook/capitulos:$ROOT/modulos:$ROOT/modulos/diagramas:$ROOT/labs:$ROOT/apps:$ROOT/deploy"

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
  --from markdown
  --toc --toc-depth=3
  --resource-path="$RESOURCE_PATH"
  --metadata title="$TITLE"
  --metadata author="$AUTHOR"
)
[[ -f "$EPUB_CSS" ]] && pandoc_args+=(--css="$EPUB_CSS")

pandoc "$MASTER" -o "$EPUB" "${pandoc_args[@]}"

echo "→ EPUB: $EPUB"

generate_pdf() {
  local engine="$1"
  pandoc "$MASTER" -o "$PDF" \
    --from markdown \
    --toc --toc-depth=3 \
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
