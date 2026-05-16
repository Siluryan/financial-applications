#!/usr/bin/env bash
# Abre o EPUB gerado em ebook/build/ com um leitor instalado.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EPUB="$ROOT/ebook/build/microsservicos-financeiros-lab.epub"

if [[ ! -f "$EPUB" ]]; then
  echo "EPUB não encontrado. Gere antes: ./scripts/build-ebook.sh" >&2
  exit 1
fi

if command -v foliate &>/dev/null; then
  exec foliate "$EPUB"
fi

if command -v ebook-viewer &>/dev/null; then
  exec ebook-viewer "$EPUB"
fi

if command -v xdg-open &>/dev/null; then
  echo "Abrindo com xdg-open (associe um leitor EPUB se abrir o gestor de ficheiros)."
  exec xdg-open "$EPUB"
fi

echo "Nenhum leitor encontrado. Instale Foliate:" >&2
echo "  sudo pacman -S foliate" >&2
echo "Depois: foliate \"$EPUB\"" >&2
exit 1
