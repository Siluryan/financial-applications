# Formatação segundo a ABNT (notas de produção)

> Documento para **quem prepara a edição** (build EPUB/PDF/KDP). Não entra no manifesto do livro — o leitor vê o resultado na folha de rosto, no sumário e na tipografia, sem detalhes de pipeline.

Este volume segue, em formato **digital (EPUB/PDF)** e na brochura KDP, as orientações usuais da ABNT para obras técnicas, em especial:

| Norma | Aplicação neste livro |
|-------|------------------------|
| **NBR 14724:2011** | Estrutura (folha de rosto, verso, sumário, seções), fonte 12 pt, espaçamento 1,5 no PDF, margens, texto justificado |
| **NBR 6024:2012** | Hierarquia de títulos (partes = nível 1; Contexto/Teoria/Lab = nível 2) |
| **NBR 6027:2012** | Sumário gerado automaticamente (`Sumário`, profundidade parte + seção) |
| **NBR 6023:2018** | Referências e citações — glossário e apêndices |
| **NBR 10520:2023** | Citações no texto — remissões parentéticas |
| **NBR 5890:2019** | Ficha catalográfica no verso da folha de rosto |

## Elementos pré-textuais (ordem)

1. **Folha de rosto** — [`folha-de-rosto.md`](folha-de-rosto.md)  
2. **Verso da folha de rosto** — ficha catalográfica e copyright — [`verso-folha-de-rosto.md`](verso-folha-de-rosto.md)  
3. **Capa** (EPUB/KDP) — `ebook/assets/cover.png`  
4. **Sumário** — gerado pelo Pandoc (`toc-title: Sumário`)  
5. **Apresentação e demais pré-textos** — [`INTRODUCAO.md`](INTRODUCAO.md), siglas, pré-requisitos, fundamentos, convenções  
6. **Corpo** — partes (módulos/ondas) com Contexto, Teoria e Laboratório  
7. **Elementos pós-textuais** — glossário, apêndices, sobre o autor  

## Tipografia (EPUB e PDF)

| Elemento | Especificação |
|----------|-------------|
| Corpo | Fonte serifada (Times / TeX Gyre Termes), **12 pt** |
| Entrelinha | **1,5** (PDF); ~1,45 no EPUB |
| Alinhamento | **Justificado** no corpo narrativo |
| Parágrafo | Recuo da **primeira linha 1,25 cm** entre parágrafos (exceto após títulos, listas, código e tabelas) |
| Títulos | Partes em destaque; seções Contexto/Teoria/Lab um nível abaixo (`epub.css`) |
| Código e tabelas | Fonte 10 pt, borda simples; legendas quando aplicável |

## Numeração automática (build)

| Elemento | Formato no livro |
|----------|------------------|
| Partes do corpo (*Módulo 0* … *7*) | `1`, `2`, … no título de nível 1 |
| Seções (*Contexto*, *Teoria*, labs, *Fundamentos*) | `1.1`, `1.2`, … no título de nível 2 |
| Pré-textos | `INTRODUÇÃO` (sem número arábico) |
| Pós-textos | `GLOSSÁRIO`, `APÊNDICE A`, `SOBRE O AUTOR` |
| Figuras | `Figura 1 –` … *Fonte: elaborado pelo autor (2026).* |
| Tabelas (≥2 linhas de dados) | `Tabela 1 –` … acima da tabela |

Scripts: `scripts/build-ebook.sh` (seções) e `scripts/abnt-number-figures-tables.py` (figuras/tabelas).

## PDF (brochura 6″×9″)

O script `build-ebook.sh` gera PDF com classe `book`, margens **3 cm** (esquerda e superior) e **2 cm** (direita e inferior), `fontsize=12pt` e `linestretch=1.5`.

### Numeração de páginas (NBR 14724)

| Zona | Algarismos | Onde aparece o número |
|------|------------|------------------------|
| Folha de rosto | (sem número visível) | — |
| Verso, sumário, Introdução | Romanos (i, ii, iii…) | Canto superior direito |
| Módulos 0–7 (corpo) | Arábicos (1, 2, 3…) | Canto superior direito, reinicia em 1 no Módulo 0 |
| Glossário e apêndices | Arábicos (continuação) | Mesmo estilo |

Implementação: `ebook/abnt-pdf-header.tex` + blocos `{=latex}` no Markdown unificado (`\frontmatter`, `\mainmatter`, `\tableofcontents`).

## Capa brochura

O script `build-kdp-cover.sh` monta contracapa, lombo e capa para formato 6″×9″ com **420 páginas** (edição atual do volume).

## Manutenção técnica

Alterações de formatação: `ebook/epub.css` (EPUB) e variáveis LaTeX em `scripts/build-ebook.sh` (PDF).
