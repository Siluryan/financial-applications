#!/usr/bin/env python3
"""Gera ebook/assets/cover-back-kdp.png (contracapa 6″×9″ + sangria, 300 DPI)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "ebook/assets/cover-back-kdp.png"

TRIM_W_IN, TRIM_H_IN, BLEED_IN, DPI = 6, 9, 0.125, 300
W = int((TRIM_W_IN + 2 * BLEED_IN) * DPI)
H = int((TRIM_H_IN + 2 * BLEED_IN) * DPI)
# Margem de texto: sangria + zona segura KDP (~0,25″ além do corte)
MARGIN_X = int((BLEED_IN + 0.35) * DPI)
MARGIN_TOP = int((BLEED_IN + 0.45) * DPI)
MARGIN_BOTTOM = int((BLEED_IN + 0.35) * DPI)
# Zona reservada para código de barras (a KDP coloca se não marcar "já tenho barcode")
BARCODE_RESERVE_H = int(1.35 * DPI)

BG_TOP = (10, 22, 40)
BG_BOTTOM = (18, 42, 62)
TEXT = (235, 242, 250)
ACCENT = (56, 189, 248)
MUTED = (148, 163, 184)

BODY = """Percurso prático para engenheiros de plataforma e DevOps que operam sistemas de pagamento modernos.

Acompanhe um banco digital fictício — Pix, limites e crédito — enquanto um cluster Kubernetes evolui módulo a módulo. Cada parte traz contexto histórico, teoria e laboratório: resiliência (timeout, retry, circuit breaker), OpenTelemetry e Jaeger, Apache Kafka, Istio e mTLS, PostgreSQL, Redis, idempotência e outbox, GitOps, canary e operação segura (SRE, conformidade).

Os exemplos em Python (FastAPI) são concisos; o foco é defender o sistema em produção, não implementar um core bancário do zero."""

TECH = "Kubernetes · Apache Kafka · OpenTelemetry · Istio · PostgreSQL · Pix"


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_grid(draw: ImageDraw.ImageDraw, w: int, h: int) -> None:
    step = 48
    for x in range(0, w, step):
        t = x / w
        c = int(30 + t * 12)
        draw.line([(x, 0), (x, h)], fill=(c, c + 8, c + 18), width=1)
    for y in range(0, h, step):
        t = y / h
        c = int(28 + t * 10)
        draw.line([(0, y), (w, y)], fill=(c, c + 6, c + 16), width=1)


def wrap(draw: ImageDraw.ImageDraw, text: str, font, max_w: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current: list[str] = []
    for word in words:
        trial = " ".join(current + [word])
        if draw.textlength(trial, font=font) <= max_w:
            current.append(word)
        else:
            if current:
                lines.append(" ".join(current))
            current = [word]
    if current:
        lines.append(" ".join(current))
    return lines


def draw_background(w: int, h: int) -> Image.Image:
    img = Image.new("RGB", (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(BG_TOP[0] + t * (BG_BOTTOM[0] - BG_TOP[0]))
        g = int(BG_TOP[1] + t * (BG_BOTTOM[1] - BG_TOP[1]))
        b = int(BG_TOP[2] + t * (BG_BOTTOM[2] - BG_TOP[2]))
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    draw_grid(draw, w, h)
    return img


def main() -> None:
    img = draw_background(W, H)
    draw = ImageDraw.Draw(img)

    max_w = W - 2 * MARGIN_X
    y = MARGIN_TOP

    title_font = load_font(52, bold=True)
    body_font = load_font(34)
    label_font = load_font(28, bold=True)
    tech_font = load_font(30, bold=True)
    author_font = load_font(44, bold=True)
    small_font = load_font(28)

    draw.text((MARGIN_X, y), "Sobre este livro", fill=ACCENT, font=label_font)
    y += 56

    line_h = 46
    for para in BODY.split("\n\n"):
        for line in wrap(draw, para, body_font, max_w):
            draw.text((MARGIN_X, y), line, fill=TEXT, font=body_font)
            y += line_h
        y += 18

    y += 8
    draw.text((MARGIN_X, y), "Tecnologias", fill=ACCENT, font=label_font)
    y += 44
    for line in wrap(draw, TECH, tech_font, max_w):
        draw.text((MARGIN_X, y), line, fill=ACCENT, font=tech_font)
        y += 40

    y += 24
    draw.text((MARGIN_X, y), "Segunda edição · 2026", fill=MUTED, font=small_font)
    y += 52

    author_y = H - MARGIN_BOTTOM - BARCODE_RESERVE_H - 100
    draw.text((MARGIN_X, author_y), "Guilherme Rogério Ramos Dias", fill=TEXT, font=author_font)
    draw.text((MARGIN_X, author_y + 58), "Personal DevOps Trainer · Brasil", fill=MUTED, font=small_font)
    # Canto inferior esquerdo livre — a KDP insere o ISBN se não marcar "já tenho código de barras"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, dpi=(DPI, DPI))
    print(f"→ Contracapa: {OUT} ({W}×{H} px, margem texto {MARGIN_X}px)")


if __name__ == "__main__":
    main()
