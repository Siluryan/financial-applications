#!/usr/bin/env bash
# Gera PNG a partir dos fontes Mermaid em modulos/diagramas/mmd/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MMD_DIR="$ROOT/modulos/diagramas/mmd"
OUT_DIR="$ROOT/modulos/diagramas"

if ! command -v npx &>/dev/null; then
  echo "Erro: npx não encontrado (instale Node.js)." >&2
  exit 1
fi

shopt -s nullglob
for src in "$MMD_DIR"/*.mmd; do
  base="$(basename "$src" .mmd)"
  echo "→ $base.png"
  PUPPETEER_CFG="$OUT_DIR/puppeteer-config.json"
  npx --yes @mermaid-js/mermaid-cli@11 \
    -i "$src" \
    -o "$OUT_DIR/${base}.png" \
    -b white \
    -w 1200 \
    -p "$PUPPETEER_CFG"
done

echo "Concluído: PNG em $OUT_DIR"
