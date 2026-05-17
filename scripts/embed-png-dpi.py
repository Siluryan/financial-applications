#!/usr/bin/env python3
"""Define metadados DPI em PNG (impressão KDP / PDF). Uso: embed-png-dpi.py 300 ficheiro.png ..."""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image


def main() -> int:
    if len(sys.argv) < 3:
        print("Uso: embed-png-dpi.py <dpi> <ficheiro.png> ...", file=sys.stderr)
        return 1

    dpi = int(sys.argv[1])
    paths = [Path(p) for p in sys.argv[2:]]
    for path in paths:
        if not path.is_file():
            print(f"Aviso: ignorado (não existe): {path}", file=sys.stderr)
            continue
        with Image.open(path) as im:
            # Fundo branco para PNG com transparência (ebook/impressão)
            if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
                bg = Image.new("RGB", im.size, (255, 255, 255))
                bg.paste(im, mask=im.split()[-1] if im.mode == "RGBA" else None)
                im = bg
            elif im.mode != "RGB":
                im = im.convert("RGB")
            im.save(path, format="PNG", dpi=(dpi, dpi), optimize=True)
        print(f"  DPI {dpi}: {path} ({path.stat().st_size // 1024} KiB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
