# Assets do ebook e capas KDP

| Arquivo | Uso |
|---------|-----|
| [`cover.png`](cover.png) | Capa frontal — EPUB e ebook KDP (1600×2560) |
| [`cover-back-kdp.png`](cover-back-kdp.png) | Contracapa — brochura KDP |
| [`cover-paperback-6x9-full.pdf`](cover-paperback-6x9-full.pdf) | **Upload brochura KDP** — PDF pronto para impressão (contracapa + lombo + capa) |
| [`cover-paperback-6x9-full.png`](cover-paperback-6x9-full.png) | Pré-visualização da capa completa |
| [`cover-illustration-source.png`](cover-illustration-source.png) | Ilustração isométrica (arquivo de trabalho) |
| [`CONTRA-CAPA-TEXTO.md`](CONTRA-CAPA-TEXTO.md) | Texto da contracapa |

## Gerar capa brochura

```bash
./scripts/build-kdp-cover.sh
```

A contracapa (`cover-back-kdp.png`) é gerada em **1875×2775 px** com margem de texto segura; o texto base está em `build-cover-back-kdp.py` (alinhar com `CONTRA-CAPA-TEXTO.md`).

Saída: `cover-paperback-6x9-full.png`. O script lê o PDF em `ebook/build/` (via `pdfinfo`) para calcular a lombada; com **244 páginas** → **3914×2775 px**.

Para forçar outro número de páginas:

```bash
KDP_PAGE_COUNT=300 ./scripts/build-kdp-cover.sh
```

## Gerar ebook

```bash
./scripts/build-ebook.sh
```

| Formato | Ficheiro na KDP |
|---------|-----------------|
| Ebook Kindle | `ebook/build/microsservicos-financeiros-lab.epub` + `cover.png` (só frente) |
| Brochura 6×9″ | interior PDF + **`cover-paperback-6x9-full.pdf`** (capa completa) |

Na KDP, em *código de barras*, **não marque** “já tenho código de barras” — a Amazon coloca o ISBN na contracapa.

## Dimensões (brochura 6×9)

| Peça | Tamanho @ 300 DPI |
|------|-------------------|
| Capa / contracapa | 1875 × 2775 px |
| Lombada (244 p.) | 164 px |
| Arquivo plano | contracapa \| lombo \| capa (esquerda → direita) |
