# Assets do ebook e capas KDP

| Arquivo | Uso |
|---------|-----|
| [`cover.png`](cover.png) | Capa frontal — EPUB e ebook KDP (1600×2560) |
| [`cover-back-kdp.png`](cover-back-kdp.png) | Contracapa — brochura KDP |
| [`cover-paperback-6x9-full.png`](cover-paperback-6x9-full.png) | Capa completa — contracapa + lombo + frente (6″×9″, 300 DPI, 420 páginas) |
| [`cover-illustration-source.png`](cover-illustration-source.png) | Ilustração isométrica (arquivo de trabalho) |
| [`CONTRA-CAPA-TEXTO.md`](CONTRA-CAPA-TEXTO.md) | Texto da contracapa |

## Gerar capa brochura

```bash
./scripts/build-kdp-cover.sh
```

Saída: `cover-paperback-6x9-full.png` (4033×2775 px para 6″×9″ com lombada de 420 páginas).

Para outro número de páginas após alteração do PDF:

```bash
KDP_PAGE_COUNT=450 ./scripts/build-kdp-cover.sh
```

## Gerar ebook

```bash
./scripts/build-ebook.sh
```

Upload na KDP: `ebook/build/microsservicos-financeiros-lab.epub` + `cover.png`.

## Dimensões (brochura 6×9)

| Peça | Tamanho @ 300 DPI |
|------|-------------------|
| Capa / contracapa | 1875 × 2775 px |
| Lombada (420 p.) | 283 px |
| Arquivo plano | contracapa \| lombo \| capa |
