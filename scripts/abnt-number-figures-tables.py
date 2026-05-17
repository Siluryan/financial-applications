#!/usr/bin/env python3
"""Numera figuras e tabelas no Markdown unificado (ABNT NBR 14724 / 6024)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

FONTE_ANO = "2026"
FONTE = f"<em>Fonte: elaborado pelo autor ({FONTE_ANO}).</em>"


def is_body_part_heading(line: str) -> bool:
    return bool(re.match(r"^# \d+ Módulo ", line))


def is_post_text_heading(line: str) -> bool:
    return bool(
        re.match(r"^# (GLOSSÁRIO|APÊNDICE|SOBRE O AUTOR)\b", line)
    )


def number_figures(text: str) -> str:
    fig = 0
    in_fence = False
    in_body = False

    def repl(match: re.Match[str]) -> str:
        nonlocal fig
        if not in_body:
            return match.group(0)
        path = match.group(2)
        if "cover" in path.lower() or "assets/cover" in path:
            return match.group(0)
        fig += 1
        cap = match.group(1).strip() or "Ilustração do capítulo"
        return (
            f"![{cap}]({path})\n\n"
            f'<p class="legenda-figura"><strong>Figura {fig}</strong> – {cap}. {FONTE}</p>'
        )

    out_lines: list[str] = []
    for line in text.splitlines():
        if is_body_part_heading(line):
            in_body = True
        elif is_post_text_heading(line):
            in_body = False
        if line.strip().startswith("```"):
            in_fence = not in_fence
            out_lines.append(line)
            continue
        if in_fence or "legenda-figura" in line:
            out_lines.append(line)
            continue
        out_lines.append(re.sub(r"^!\[([^\]]*)\]\(([^)]+)\)\s*$", repl, line))

    return "\n".join(out_lines)


def is_table_separator(line: str) -> bool:
    return bool(re.match(r"^\|[-: |]+\|\s*$", line))


def is_table_row(line: str) -> bool:
    return line.strip().startswith("|") and line.strip().endswith("|")


def parse_table_title(header_row: str) -> str:
    cells = [c.strip() for c in header_row.strip("|").split("|")]
    cells = [c for c in cells if c]
    if not cells:
        return "Quadro resumo"
    if len(cells) == 1:
        return cells[0]
    return " — ".join(cells[:3])


def number_tables(text: str) -> str:
    """Legenda acima da tabela (ABNT); só no corpo (módulos), tabelas com ≥4 linhas de dados."""
    tab = 0
    lines = text.splitlines()
    out: list[str] = []
    i = 0
    in_fence = False
    in_body = False

    while i < len(lines):
        line = lines[i]
        if is_body_part_heading(line):
            in_body = True
        elif is_post_text_heading(line):
            in_body = False
        if line.strip().startswith("```"):
            in_fence = not in_fence
            out.append(line)
            i += 1
            continue

        if (
            in_body
            and not in_fence
            and is_table_row(line)
            and i + 1 < len(lines)
            and is_table_separator(lines[i + 1])
            and "legenda-tabela" not in (out[-1] if out else "")
        ):
            body_rows = 0
            j = i + 2
            while j < len(lines) and is_table_row(lines[j]):
                body_rows += 1
                j += 1
            if body_rows >= 4:
                tab += 1
                title = parse_table_title(line)
                if out and out[-1].strip() and not out[-1].startswith("<p class="):
                    prev = out[-1].strip()
                    if prev.startswith("**") and prev.endswith("**") and len(prev) < 120:
                        title = prev.strip("*").strip()
                        out.pop()
                out.append(
                    f'<p class="legenda-tabela"><strong>Tabela {tab}</strong> – {title}. {FONTE}</p>'
                )
                out.append("")
        out.append(line)
        i += 1

    return "\n".join(out)


def main() -> int:
    if len(sys.argv) != 2:
        print("Uso: abnt-number-figures-tables.py <ficheiro.md>", file=sys.stderr)
        return 1
    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")
    text = number_figures(text)
    text = number_tables(text)
    path.write_text(text, encoding="utf-8")
    print(f"→ Figuras e tabelas numeradas (ABNT): {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
