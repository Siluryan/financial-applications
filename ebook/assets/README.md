# Assets do ebook

| Arquivo | Uso |
|---------|-----|
| [`cover.png`](cover.png) | Capa do EPUB (1600×2560, retrato) |

A capa é gerada/regenerada fora do fluxo normal. Para substituir, coloque um PNG em retrato (proporção ~1:1,6) e execute `./scripts/build-ebook.sh`.

Sugestão visual: fundo escuro, tipografia clara, motivos de rede/microsserviços — estilo livros técnicos (O’Reilly, Manning, etc.). A capa atual inclui o autor **Guilherme Dias** na parte inferior (acima da linha *Pix • Kubernetes • …*).

Para alterar o nome na capa (ImageMagick):

```bash
magick ebook/assets/cover.png -gravity South -fill '#E8EEF5' -font DejaVu-Sans-Bold \
  -pointsize 52 -annotate +0+195 'Guilherme Dias' ebook/assets/cover.png
```
