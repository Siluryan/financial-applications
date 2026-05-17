#!/usr/bin/env bash
# Monta capa completa KDP (capa + lombo + contracapa) para paperback 6"×9".
# Usa cover.png (frente) e cover-back-kdp.png (verso).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/ebook/assets"
FRONT="$ASSETS/cover.png"
BACK="$ASSETS/cover-back-kdp.png"
OUT="$ASSETS/cover-paperback-6x9-full.png"
OUT_PDF="$ASSETS/cover-paperback-6x9-full.pdf"
INTERIOR_PDF="$ROOT/ebook/build/microsservicos-financeiros-lab.pdf"

# Páginas do interior: KDP_PAGE_COUNT > pdfinfo do build > 420 (fallback)
if [[ -n "${KDP_PAGE_COUNT:-}" ]]; then
  PAGE_COUNT="$KDP_PAGE_COUNT"
elif command -v pdfinfo &>/dev/null && [[ -f "$INTERIOR_PDF" ]]; then
  PAGE_COUNT="$(pdfinfo "$INTERIOR_PDF" 2>/dev/null | awk '/^Pages:/ {print $2}')"
fi
PAGE_COUNT="${PAGE_COUNT:-420}"
TRIM_W_IN=6
TRIM_H_IN=9
BLEED_IN=0.125
DPI=300

# Espessura lombo — papel branco KDP (~0,002252" por página)
SPINE_IN=$(python3 -c "print(round(${PAGE_COUNT} * 0.002252, 4))")
PANEL_W=$(python3 -c "print(int((${TRIM_W_IN} + 2*${BLEED_IN}) * ${DPI}))")
PANEL_H=$(python3 -c "print(int((${TRIM_H_IN} + 2*${BLEED_IN}) * ${DPI}))")
SPINE_W=$(python3 -c "print(max(int(${SPINE_IN} * ${DPI}), 1))")
FULL_W=$(python3 -c "print(2*${PANEL_W} + max(int(${SPINE_IN} * ${DPI}), 1))")

echo "→ Páginas: $PAGE_COUNT | Lombada: ${SPINE_IN}\" (${SPINE_W}px) | Painel: ${PANEL_W}×${PANEL_H}px"
echo "→ Largura total: ${FULL_W}px × ${PANEL_H}px"

[[ -f "$FRONT" ]] || { echo "Em falta: $FRONT" >&2; exit 1; }

echo "→ Contracapa (margens de impressão)..."
python3 "$ROOT/scripts/build-cover-back-kdp.py"

python3 <<PY
from PIL import Image, ImageDraw, ImageFont
import os

front_path = "$FRONT"
back_path = "$BACK"
out_path = "$OUT"
panel_w, panel_h = $PANEL_W, $PANEL_H
spine_w = $SPINE_W
full_w = $FULL_W
title = "Microsserviços Financeiros"
author = "Guilherme Rogério Ramos Dias"
spine_line = f"{title}  ·  {author}"

def fit_cover(img, w, h):
    """Capa ilustrada: preenche o painel (crop central)."""
    img = img.convert("RGB")
    s = max(w / img.width, h / img.height)
    nw, nh = int(img.width * s), int(img.height * s)
    img = img.resize((nw, nh), Image.Resampling.LANCZOS)
    x, y = (nw - w) // 2, (nh - h) // 2
    return img.crop((x, y, x + w, y + h))

def fit_back(img, w, h):
    """Contracapa: painel exato ou encaixe sem cortar texto."""
    img = img.convert("RGB")
    if img.size == (w, h):
        return img
    s = min(w / img.width, h / img.height)
    nw, nh = int(img.width * s), int(img.height * s)
    img = img.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (w, h), (10, 22, 40))
    # Alinha à direita (lado do lombo) para preservar margem externa à esquerda
    canvas.paste(img, (w - nw, (h - nh) // 2))
    return canvas

front = fit_cover(Image.open(front_path), panel_w, panel_h)
back = fit_back(Image.open(back_path), panel_w, panel_h)

# Lombada: gradiente alinhado à capa
spine = Image.new("RGB", (spine_w, panel_h), (10, 22, 40))
draw = ImageDraw.Draw(spine)
for y in range(panel_h):
    t = y / panel_h
    r = int(10 + t * 8)
    g = int(22 + t * 20)
    b = int(40 + t * 18)
    draw.line([(0, y), (spine_w, y)], fill=(r, g, b))

# Texto no lombo (vertical) se houver largura mínima
if spine_w >= 40:
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", max(14, spine_w // 3))
    except OSError:
        font = ImageFont.load_default()
    txt = Image.new("RGBA", (panel_h, spine_w), (0, 0, 0, 0))
    td = ImageDraw.Draw(txt)
    label = spine_line if spine_w >= 80 else title[:28]
    td.text((panel_h // 2, spine_w // 2), label, fill=(230, 240, 255, 255), font=font, anchor="mm")
    txt = txt.rotate(90, expand=True)
    spine.paste(txt, (0, 0), txt)

# Ordem KDP: contracapa | lombo | capa (da esquerda para direita no arquivo plano)
full = Image.new("RGB", (full_w, panel_h))
full.paste(back, (0, 0))
full.paste(spine, (panel_w, 0))
full.paste(front, (panel_w + spine_w, 0))
full.save(out_path, dpi=(300, 300))
print(f"→ Gravado: {out_path} ({full.size[0]}×{full.size[1]})")
PY

python3 <<PY
from PIL import Image
img = Image.open("$OUT").convert("RGB")
pdf_path = "$OUT_PDF"
img.save(pdf_path, "PDF", resolution=300.0)
print(f"→ PDF capa: {pdf_path}")
PY

echo ""
echo "Upload KDP brochura (PDF pronto para impressão): $OUT_PDF"
echo "  Ordem no arquivo: contracapa (esq.) | lombo | capa (dir.)"
echo "  Código de barras: deixe a caixa DESMARCADA na KDP (eles inserem o ISBN)."
echo "Pré-visualização PNG: $OUT"
echo "Capa ebook Kindle (só frente): $FRONT"
