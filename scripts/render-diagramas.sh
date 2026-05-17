#!/usr/bin/env bash
# Gera PNG a partir dos fontes Mermaid em modulos/diagramas/mmd/
# Tema editorial + escala alta + metadados 300 DPI para impressão (KDP).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MMD_DIR="$ROOT/modulos/diagramas/mmd"
OUT_DIR="$ROOT/modulos/diagramas"
CONFIG="$OUT_DIR/mermaid-config.json"
CSS="$OUT_DIR/mermaid-custom.css"
PUPPETEER_CFG="$OUT_DIR/puppeteer-config.json"
NODE_TOOLS="$ROOT/.tools/node"
MMDC_VERSION="${MMDC_VERSION:-11}"

# Largura lógica (px) × escala Puppeteer → ~4400 px úteis em diagramas largos (≥300 DPI a ~14 cm).
MERMAID_WIDTH="${MERMAID_WIDTH:-2200}"
MERMAID_SCALE="${MERMAID_SCALE:-2}"
MERMAID_DPI="${MERMAID_DPI:-300}"

ensure_node() {
  if command -v npx &>/dev/null; then
    return 0
  fi
  if [[ -x "$NODE_TOOLS/bin/npx" ]]; then
    export PATH="$NODE_TOOLS/bin:$PATH"
    return 0
  fi
  echo "→ A instalar Node.js portátil em .tools/node (sem sudo)…"
  mkdir -p "$ROOT/.tools"
  NODE_TARBALL="node-v22.14.0-linux-x64.tar.xz"
  NODE_URL="https://nodejs.org/dist/v22.14.0/${NODE_TARBALL}"
  tmp="$(mktemp -d)"
  curl -fsSL "$NODE_URL" -o "$tmp/$NODE_TARBALL"
  tar -xJf "$tmp/$NODE_TARBALL" -C "$tmp"
  rm -rf "$NODE_TOOLS"
  mv "$tmp/node-v22.14.0-linux-x64" "$NODE_TOOLS"
  rm -rf "$tmp"
  export PATH="$NODE_TOOLS/bin:$PATH"
}

ensure_mmdc() {
  if command -v mmdc &>/dev/null; then
    MMDC="mmdc"
    return 0
  fi
  if [[ -x "$ROOT/node_modules/.bin/mmdc" ]]; then
    MMDC="$ROOT/node_modules/.bin/mmdc"
    return 0
  fi
  echo "→ A instalar @mermaid-js/mermaid-cli@${MMDC_VERSION}…"
  (cd "$ROOT" && npm install --no-save "@mermaid-js/mermaid-cli@${MMDC_VERSION}")
  MMDC="$ROOT/node_modules/.bin/mmdc"
}

ensure_node
ensure_mmdc

if ! python3 -c "from PIL import Image" 2>/dev/null; then
  echo "Erro: python3-pil (Pillow) necessário para metadados DPI." >&2
  exit 1
fi

shopt -s nullglob
generated=()
for src in "$MMD_DIR"/*.mmd; do
  base="$(basename "$src" .mmd)"
  out="$OUT_DIR/${base}.png"
  echo "→ $base.png (${MERMAID_WIDTH}px × escala ${MERMAID_SCALE})"
  "$MMDC" \
    -i "$src" \
    -o "$out" \
    -b white \
    -w "$MERMAID_WIDTH" \
    -s "$MERMAID_SCALE" \
    -c "$CONFIG" \
    -C "$CSS" \
    -p "$PUPPETEER_CFG"
  generated+=("$out")
done

if ((${#generated[@]} == 0)); then
  echo "Nenhum ficheiro .mmd em $MMD_DIR" >&2
  exit 1
fi

echo "→ A definir ${MERMAID_DPI} DPI nos PNG…"
python3 "$ROOT/scripts/embed-png-dpi.py" "$MERMAID_DPI" "${generated[@]}"

echo "Concluído: ${#generated[@]} PNG em $OUT_DIR (${MERMAID_DPI} DPI, tema editorial)"
