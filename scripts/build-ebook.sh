#!/usr/bin/env bash
# Ebook integrado: cada parte = teoria (módulo) + laboratório(s) em sequência.
# Instala pandoc (e opcionalmente LaTeX/poppler) se faltarem — use --skip-install para desativar.
set -euo pipefail

SKIP_INSTALL=false
INSTALL_ALL_DEPS=false

usage() {
  cat <<'EOF'
Uso: ./scripts/build-ebook.sh [opções]

  (sem opções)     Gera Markdown; instala pandoc/LaTeX em falta (pacman/apt/dnf)
  --install-deps   Instala também LaTeX e poppler (PDF + pdfinfo)
  --skip-install   Não tenta instalar pacotes do sistema
  -h, --help       Esta ajuda

Variável: EBOOK_PKG_MANAGER=pacman|apt|dnf|zypper|brew (forçar gestor)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-install) SKIP_INSTALL=true; shift ;;
    --install-deps|--with-pdf-deps) INSTALL_ALL_DEPS=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Opção desconhecida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/ebook/build"
MANIFEST="$ROOT/ebook/manifesto.txt"
MASTER="$OUT_DIR/microsservicos-financeiros-lab.md"
TITLE="Microsserviços financeiros — teoria e laboratório"
SUBTITLE="Pix, Kubernetes, Kafka, OpenTelemetry e operação em bancos digitais — 2.ª ed."
AUTHOR="Guilherme Rogério Ramos Dias"
PUBLISHER="Personal DevOps Trainer"
EBOOK_EDITION="Segunda edição"
COVER="$ROOT/ebook/assets/cover.png"
DESCRIPTION="Percurso prático de microsserviços em contexto financeiro: resiliência, Kafka, PostgreSQL, OpenTelemetry, service mesh, consistência, GitOps e operação SRE. Segunda edição — teoria e laboratórios com cluster kind."

mkdir -p "$OUT_DIR"

detect_pkg_manager() {
  if [[ -n "${EBOOK_PKG_MANAGER:-}" ]]; then
    echo "$EBOOK_PKG_MANAGER"
    return 0
  fi
  if command -v pacman &>/dev/null; then echo pacman
  elif command -v apt-get &>/dev/null; then echo apt
  elif command -v dnf &>/dev/null; then echo dnf
  elif command -v zypper &>/dev/null; then echo zypper
  elif [[ "$(uname -s 2>/dev/null || true)" == Darwin ]] && command -v brew &>/dev/null; then echo brew
  else echo unknown
  fi
}

run_privileged() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    return 1
  fi
}

# Perfil: pandoc | tex | poppler
pkg_list_for() {
  local profile="$1"
  local mgr
  mgr="$(detect_pkg_manager)"
  case "$mgr:$profile" in
    pacman:pandoc) echo pandoc ;;
    pacman:tex) echo texlive-basic texlive-bin texlive-latexrecommended texlive-latexextra ;;
    pacman:poppler) echo poppler ;;
    apt:pandoc) echo pandoc ;;
    apt:tex) echo texlive-latex-base texlive-binaries texlive-latex-recommended texlive-latex-extra ;;
    apt:poppler) echo poppler-utils ;;
    dnf:pandoc) echo pandoc ;;
    dnf:tex) echo texlive-scheme-basic texlive-collection-latexrecommended ;;
    dnf:poppler) echo poppler-utils ;;
    zypper:pandoc) echo pandoc ;;
    zypper:tex) echo texlive texlive-latex ;;
    zypper:poppler) echo poppler-tools ;;
    brew:pandoc) echo pandoc ;;
    brew:tex) echo basictex ;;
    brew:poppler) echo poppler ;;
    *) return 1 ;;
  esac
}

install_ebook_packages() {
  local profile="$1"
  local mgr pkgs _pkg
  mgr="$(detect_pkg_manager)"
  if ! pkgs="$(pkg_list_for "$profile")"; then
    echo "Gestor de pacotes não suportado para perfil '$profile' (detectado: $mgr)." >&2
    return 1
  fi
  # shellcheck disable=SC2206
  pkgs=($pkgs)
  echo "→ [$mgr] a instalar: ${pkgs[*]}"
  case "$mgr" in
    pacman)
      run_privileged pacman -S --needed --noconfirm "${pkgs[@]}"
      ;;
    apt)
      run_privileged apt-get update -qq
      run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
      ;;
    dnf)
      run_privileged dnf install -y "${pkgs[@]}"
      ;;
    zypper)
      run_privileged zypper --non-interactive install -y "${pkgs[@]}"
      ;;
    brew)
      for _pkg in "${pkgs[@]}"; do
        brew install "$_pkg"
      done
      ;;
    *)
      return 1
      ;;
  esac
}

print_manual_install_hint() {
  local profile="$1"
  local mgr
  mgr="$(detect_pkg_manager)"
  local pkgs
  pkgs="$(pkg_list_for "$profile" 2>/dev/null || true)"
  case "$mgr" in
    pacman) echo "  sudo pacman -S --needed ${pkgs:-pandoc}" ;;
    apt) echo "  sudo apt-get update && sudo apt-get install -y ${pkgs:-pandoc}" ;;
    dnf) echo "  sudo dnf install -y ${pkgs:-pandoc}" ;;
    zypper) echo "  sudo zypper install -y ${pkgs:-pandoc}" ;;
    brew) echo "  brew install ${pkgs:-pandoc}" ;;
    *) echo "  Instale pandoc e, para PDF, uma distribuição TeX (texlive)." ;;
  esac
}

tex_format_ready() {
  local fmt="$1"
  local engine="/"
  command -v kpsewhich &>/dev/null || return 1
  kpsewhich "$fmt" &>/dev/null && return 0
  kpsewhich -format fmt "$fmt" &>/dev/null && return 0
  case "$fmt" in
    pdflatex.fmt|pdfetex.fmt|pdftex.fmt) engine=pdftex ;;
    xelatex.fmt) engine=xetex ;;
    lualatex.fmt) engine=luatex ;;
  esac
  kpsewhich -engine="$engine" -format fmt "$fmt" &>/dev/null
}

fix_tex_formats() {
  if command -v fmtutil-sys &>/dev/null; then
    echo "→ A gerar formatos LaTeX (fmtutil-sys --all)..."
    run_privileged fmtutil-sys --all 2>/dev/null || true
  fi
  if ! tex_format_ready "pdflatex.fmt" && command -v fmtutil-user &>/dev/null; then
    echo "→ A gerar formatos LaTeX (fmtutil-user)..."
    fmtutil-user --byfmt pdflatex 2>/dev/null || true
    fmtutil-user --byfmt xelatex 2>/dev/null || true
  fi
}

ensure_pandoc() {
  command -v pandoc &>/dev/null && return 0
  [[ "$SKIP_INSTALL" == true ]] && return 1
  echo ""
  echo "pandoc não encontrado — a instalar dependências de build do EPUB..."
  install_ebook_packages pandoc || return 1
  command -v pandoc &>/dev/null
}

ensure_tex_for_pdf() {
  if command -v pdflatex &>/dev/null || command -v xelatex &>/dev/null; then
    return 0
  fi
  [[ "$SKIP_INSTALL" == true ]] && return 1
  echo ""
  echo "LaTeX não encontrado — a instalar dependências de build do PDF..."
  install_ebook_packages tex || return 1
  fix_tex_formats
  command -v pdflatex &>/dev/null || command -v xelatex &>/dev/null
}

ensure_poppler() {
  command -v pdfinfo &>/dev/null && return 0
  [[ "$SKIP_INSTALL" == true ]] && return 1
  install_ebook_packages poppler 2>/dev/null || return 0
  command -v pdfinfo &>/dev/null
}

if [[ "$INSTALL_ALL_DEPS" == true && "$SKIP_INSTALL" == false ]]; then
  ensure_pandoc || true
  ensure_tex_for_pdf || true
  ensure_poppler || true
fi

fix_images() {
  local base_dir="$1"
  if [[ -z "$base_dir" || "$base_dir" == "." ]]; then
    cat
    return
  fi
  sed -E \
    -e "s|!\[([^\]]*)\]\(\./([^)]+)\)|![\1](${base_dir}/\2)|g" \
    -e "s|!\[([^\]]*)\]\(([^./][^)]*)\)|![\1](${base_dir}/\2)|g"
}

# Leitura no ereader: sem links clicáveis (exceto imagens); listas de tarefa viram bullets.
flatten_for_ebook() {
  perl -pe '
    s/(?<!!)\[([^\]]+)\]\([^)]+\)/$1/g;
    s/<(https?:\/\/[^>]+)>/$1/g;
    s/^(\s*)- \[[ xX]\]\s*/$1- /g;
  '
}

# Nomes de ficheiro .md e pastas do repo → linguagem de livro (quem só lê o EPUB).
readerize_for_ebook() {
  perl -pe '
    s/Este arquivo é/Esta seção é/g;
    s/\*\*Aqui \((`)?PRE-REQUISITOS\.md(`)?\)\*\*/**Nesta seção (início do livro)**/g;
    s/\*\*Cada lab \((`)?labs\/lab-\*\.md(`)?\)\*\*/**Cada capítulo de laboratório**/g;
    s/\*\*(`)?PLANO_DE_ESTUDO\.md(`)?\*\*/**Plano de estudo (repositório Git)**/g;
    s/`labs\/lab-\*\.md`/cada capítulo de laboratório/g;
    s/labs\/lab-\*\.md/cada capítulo de laboratório/g;
    s/`PRE-REQUISITOS\.md`/esta seção/g;
    s/PRE-REQUISITOS\.md/Pré-requisitos/g;
    s/`PLANO_DE_ESTUDO\.md`/plano de estudo (repositório Git)/g;
    s/PLANO_DE_ESTUDO\.md/plano de estudo (repositório Git)/g;
    s/`CONVENCOES_EDITORIAIS\.md`/convenções editoriais/g;
    s/CONVENCOES_EDITORIAIS\.md/convenções editoriais/g;
    s/`SIGLAS-RAPIDAS\.md`/siglas rápidas/g;
    s/`capitulos\/README\.md`/índice dos capítulos de contexto/g;
    s/capitulos\/README\.md/índice dos capítulos de contexto/g;
    s/`modulos\/`/capítulo de teoria /g;
    s/`labs\/`/capítulo de laboratório /g;
    s/→ teoria \(`modulos\/`\)/→ teoria/g;
    s/→ lab \(`labs\/`\)/→ laboratório/g;
    s/teoria \(`modulos\/`\)/teoria/g;
    s/lab \(`labs\/`\)/laboratório/g;
    s/Glossário e apêndices \(`apps\/`, `deploy\/`\) no final/Glossário e apêndices de referência no final/g;
    s/— capítulo em `modulos\/`/— teoria/g;
    s/— `labs\/`/— laboratório/g;
    s/Manifests em `deploy\/k8s\/`/Manifests Kubernetes do laboratório/g;
    s/em `deploy\/k8s\/`/no material de deploy do laboratório/g;
    s/`docs\/[^`]+`/documento de apoio (repositório Git)/g;
    s/· `PLANO`/· plano de estudo/g;
    s/· PLANO §/· checklist (repositório), §/g;
    s/Checklist completo: plano de estudo \(repositório Git\)\./Checklists por módulo ficam no repositório Git (fora deste volume)./g;
    s/Detalhe: plano de estudo \(repositório Git\)\./Checklists expandidos: repositório Git do projeto./g;
    s/O arquivo legado `06-evolucao[^`]+`[^.]*\./Os módulos 5–7 têm capítulos de contexto dedicados neste livro./g;
    s/Monorepo \*\*financial-applications\*\*: `apps\/`, `deploy\/`, `labs\/`, `modulos\/`\./Código e manifests do laboratório ficam no repositório Git **financial-applications** (opcional para quem for reproduzir os passos)./g;
    s/plano de estudo com checklists detalhados permanece no repositório Git/Checklists detalhados e código-fonte ficam no repositório Git/g;
    s/teoria \(`modulos\/`\) e laboratório \(`labs\/`\)/teoria e laboratório/g;
    s/\| Checklist \| plano de estudo \(repositório Git\) \|/| Checklist detalhado | Repositório Git (online) |/g;
    s/`labs\/[^`]+`/laboratório desta parte do livro/g;
    s/Laboratório: laboratório desta parte do livro/Laboratório: capítulo prático desta parte/g;
    s/Laboratório completo: laboratório desta parte do livro/Laboratório completo: capítulo prático desta parte/g;
    s/para laboratório desta parte do livro/para o laboratório desta parte/g;
    s/Arquivos de referência para laboratório desta parte do livro/Arquivos de referência para o laboratório desta parte/g;
    s/Lista completa: laboratório desta parte do livro/Lista completa: exercícios de falha e troubleshooting/g;
    s/Ver laboratório desta parte do livro/Ver exercícios de falha e troubleshooting/g;
    s/`REFERENCIAS\.md`/bibliografia do repositório/g;
    s/REFERENCIAS\.md/bibliografia/g;
    s/`README\.md`/documentação do repositório/g;
    s/`deploy\/[^`]+`/material de deploy do laboratório/g;
    s/para os `\.md` dos módulos/para os capítulos de teoria/g;
    s/Imagens geradas para os `\.md`/Imagens geradas para os capítulos/g;
    s/^Comece: /Ordem sugerida: /g;
    s/^Antecede /Este bloco antecede /g;
    s/^A seguir: /Em seguida: /g;
    s/^Documentação: /Para aprofundar, consulte /g;
    s/^Referência: /Ver também /g;
    s/^Relacionado: /Cenário relacionado: /g;
    s/^Diagrama: /Ilustração: /g;
    s/\x{2033}/''/g;
    s/×/ x /g;
  '
}

prepare_content() {
  local base_dir="$1"
  if [[ -n "$base_dir" ]]; then
    fix_images "$base_dir" | flatten_for_ebook | readerize_for_ebook
  else
    flatten_for_ebook | readerize_for_ebook
  fi
}

lab_section_title() {
  local rel="$1"
  local path="$ROOT/$rel"
  local title
  [[ -f "$path" ]] || { echo "Laboratório"; return; }
  title="$(sed -n '1s/^# //p' "$path" | head -1)"
  if [[ "$title" == Lab* ]]; then
    echo "Laboratório ${title#Lab }"
  else
    echo "Laboratório"
  fi
}

secao_label() {
  case "$1" in
    teoria) echo "Teoria" ;;
    lab) echo "Laboratório" ;;
    contexto) echo "Contexto" ;;
    contexto-k8s) echo "Contexto — Kubernetes e containers" ;;
    intro) echo "" ;;
    apendice) echo "" ;;
    fundamentos-http) echo "Fundamentos — HTTP e FastAPI" ;;
    fundamentos-docker) echo "Fundamentos — Docker e Kubernetes" ;;
    fundamentos-resiliencia) echo "Fundamentos — Resiliência" ;;
    fundamentos-otel) echo "Fundamentos — OpenTelemetry" ;;
    fundamentos-kafka) echo "Fundamentos — Apache Kafka" ;;
    fundamentos-istio) echo "Fundamentos — Istio e mesh" ;;
    fundamentos-dados) echo "Fundamentos — PostgreSQL e Redis" ;;
    fundamentos-gitops) echo "Fundamentos — GitOps e deploy" ;;
    fundamentos-*) echo "Fundamentos" ;;
    *) echo "$1" ;;
  esac
}

# Entre dois blocos @secao fundamentos-* não inserir ponte (ficam colados na mesma parte).
is_fundamentos_secao() {
  [[ "$1" == fundamentos-* ]]
}

# Numeração ABNT (NBR 6024): partes do corpo = 1, 2, 3…; seções = 1.1, 1.2…
ABNT_PART_NUM=0
ABNT_SEC_NUM=0

part_is_numbered() {
  [[ "$1" == Módulo* ]]
}

# Blocos LaTeX no Markdown (só PDF; ignorados no EPUB sem efeito nocivo).
emit_latex_raw() {
  {
    echo ""
    echo '```{=latex}'
    echo "$1"
    echo '```'
    echo ""
  } >>"$MASTER"
}

format_part_heading() {
  local title="$1"
  case "$title" in
    Introdução) echo "# INTRODUÇÃO" ;;
    Glossário)
      emit_latex_raw $'\\backmatter\n\\pagestyle{abnt}'
      echo "# GLOSSÁRIO"
      ;;
    Sobre\ o\ autor) echo "# SOBRE O AUTOR" ;;
    Apêndice\ —\ *)
      echo "# APÊNDICE A — ${title#Apêndice — }"
      ;;
    *)
      ABNT_PART_NUM=$((ABNT_PART_NUM + 1))
      ABNT_SEC_NUM=0
      if [[ "$ABNT_PART_NUM" -eq 1 ]]; then
        emit_latex_raw $'\\cleardoublepage\n\\mainmatter\n\\pagenumbering{arabic}\n\\setcounter{page}{1}\n\\pagestyle{abnt}'
      fi
      echo "# ${ABNT_PART_NUM} ${title}"
      ;;
  esac
}

format_section_heading() {
  local title="$1"
  if part_is_numbered "$current_part"; then
    ABNT_SEC_NUM=$((ABNT_SEC_NUM + 1))
    echo "## ${ABNT_PART_NUM}.${ABNT_SEC_NUM} ${title}"
  else
    echo "## ${title}"
  fi
}

next_section_label() {
  local label="$1"
  if part_is_numbered "$current_part"; then
    echo "${ABNT_PART_NUM}.$((ABNT_SEC_NUM + 1)) ${label}"
  else
    echo "$label"
  fi
}

# Sumário acadêmico: só H1 (parte) + H2 (seção). Conteúdo fonte desce um nível (# → ## → ### …).
# Não altera linhas dentro de blocos ``` (evita comentários # virarem entrada no sumário).
demote_headings() {
  perl -ne '
    if (/^```/) { $fence = !$fence }
    if (!$fence) {
      s/^###### /####### /;
      s/^##### /###### /;
      s/^#### /##### /;
      s/^### /#### /;
      s/^## /### /;
      s/^# /## /;
    }
    print;
  '
}

strip_redundant_lead_heading() {
  perl -0777 -pe 's/^## (\d+\.\d+ )?(Módulo \d|Lab \d+|Laboratório \d+|Onda \d|Fundamentos)[^\n]*\n+//m'
}

# O H2 estrutural (Contexto / Teoria / Lab) já foi emitido; remove o primeiro título do ficheiro fonte.
strip_leading_body_heading() {
  perl -0777 -pe 's/^## [^\n]+\n+//m'
}

intro_section_title() {
  case "$1" in
    ebook/AVISO-LEGAL-EDITORIAL.md) echo "Aviso legal" ;;
    ebook/INTRODUCAO.md) echo "Apresentação" ;;
    ebook/SIGLAS-RAPIDAS.md) echo "Siglas e termos" ;;
    ebook/PRE-REQUISITOS.md) echo "Pré-requisitos" ;;
    ebook/capitulos/fundamentos-indice.md) echo "Índice dos fundamentos" ;;
    ebook/CONVENCOES_EDITORIAIS.md) echo "Convenções editoriais" ;;
    ebook/FORMACAO-ABNT.md) echo "Formatação ABNT" ;;
    ebook/capitulos/07-como-estudar-com-este-livro.md) echo "Como estudar" ;;
    *) echo "" ;;
  esac
}

apendice_section_title() {
  case "$1" in
    apps/README.md) echo "Apps do laboratório" ;;
    deploy/kind/README.md) echo "Cluster kind" ;;
    deploy/kafka/README.md) echo "Kafka no deploy" ;;
    deploy/toxiproxy/README.md) echo "Toxiproxy" ;;
    deploy/istio/README.md) echo "Istio" ;;
    modulos/diagramas/README.md) echo "Diagramas" ;;
    *) echo "" ;;
  esac
}

prepare_body_for_ebook() {
  local base_dir="$1"
  prepare_content "$base_dir" | demote_headings | strip_redundant_lead_heading | strip_leading_body_heading
}

emit_toc_section_heading() {
  local title="$1"
  [[ -z "$title" ]] && return 0
  echo "" >>"$MASTER"
  format_section_heading "$title" >>"$MASTER"
  echo "" >>"$MASTER"
}

cat >"$MASTER" <<EOF
---
title: "$TITLE"
subtitle: "$SUBTITLE"
author: "$AUTHOR"
lang: pt-BR
date: "$(date +%Y-%m-%d)"
publisher: "$PUBLISHER"
description: "$DESCRIPTION"
rights: "© $(date +%Y) $AUTHOR. Todos os direitos reservados."
identifier:
  - scheme: URL
    text: "https://github.com/financial-applications"
cover-image: assets/cover.png
toc-title: "Sumário"
edition: "$EBOOK_EDITION"
---

EOF

# Pré-textos fixos ABNT (folha de rosto + verso + sumário) — antes do manifesto
ABNT_PDF_HEADER="$ROOT/ebook/abnt-pdf-header.tex"
ABNT_PDF_UNICODE="$ROOT/ebook/abnt-pdf-unicode.tex"
for front in folha-de-rosto.md verso-folha-de-rosto.md; do
  if [[ -f "$ROOT/ebook/$front" ]]; then
    if [[ "$front" == "folha-de-rosto.md" ]]; then
      emit_latex_raw $'\\pagestyle{empty}\n\\thispagestyle{empty}'
    fi
    if [[ "$front" == "verso-folha-de-rosto.md" ]]; then
      emit_latex_raw $'\\pagenumbering{roman}\n\\setcounter{page}{1}\n\\pagestyle{abnt}'
    fi
    prepare_content "ebook" <"$ROOT/ebook/$front" >>"$MASTER"
    echo "" >>"$MASTER"
  fi
done
# Sumário no PDF (ordem ABNT: após verso, antes da Introdução)
emit_latex_raw $'\\setcounter{tocdepth}{2}\n\\renewcommand{\\contentsname}{Sumário}\n\\tableofcontents\n\\newpage\n\\frontmatter\n\\pagestyle{abnt}'

current_part=""
current_secao=""
content_in_part=false
secao_heading_pending=false

# Ponte no fim da seção anterior (sem página só com o título — o H2 da seção já abre o capítulo).
emit_secao_transition() {
  local to_secao="$1"
  [[ "$to_secao" == "intro" || "$to_secao" == "apendice" ]] && return 0
  if is_fundamentos_secao "$current_secao" && is_fundamentos_secao "$to_secao"; then
    return 0
  fi
  local label display
  label="$(secao_label "$to_secao")"
  [[ -z "$label" ]] && return 0
  display="$(next_section_label "$label")"

  {
    echo ""
    echo '<div class="secao-ponte">'
    echo ""
    echo "A próxima seção desta parte do livro é **${display}**."
    echo ""
    echo '</div>'
    echo ""
  } >>"$MASTER"
}

append_file() {
  local rel="$1"
  local path="$ROOT/$rel"
  [[ -f "$path" ]] || { echo "Aviso: em falta: $rel" >&2; return; }
  local base_dir
  base_dir="$(dirname "$rel")"
  [[ "$base_dir" == "." ]] && base_dir=""

  local toc_h2=""
  if [[ "$current_secao" == "intro" ]]; then
    toc_h2="$(intro_section_title "$rel")"
  elif [[ "$current_secao" == "apendice" ]]; then
    toc_h2="$(apendice_section_title "$rel")"
  elif [[ "$current_secao" == "lab" ]]; then
    toc_h2="$(lab_section_title "$rel")"
    secao_heading_pending=false
  elif [[ "$secao_heading_pending" == true ]]; then
    toc_h2="$(secao_label "$current_secao")"
    secao_heading_pending=false
  elif is_fundamentos_secao "$current_secao" && [[ "$secao_heading_pending" == true ]]; then
    toc_h2="$(secao_label "$current_secao")"
    secao_heading_pending=false
  fi
  emit_toc_section_heading "$toc_h2"

  echo "" >>"$MASTER"

  if [[ -n "$base_dir" ]]; then
    prepare_body_for_ebook "$base_dir" <"$path" >>"$MASTER"
  else
    prepare_body_for_ebook "" <"$path" >>"$MASTER"
  fi
  echo "" >>"$MASTER"
  content_in_part=true
}

while IFS= read -r line || [[ -n "${line:-}" ]]; do
  line="${line%%#*}"
  line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -z "$line" ]] && continue

  if [[ "$line" == @parte* ]]; then
    current_part="${line#@parte }"
    current_secao=""
    content_in_part=false
    secao_heading_pending=false
    echo "" >>"$MASTER"
    format_part_heading "$current_part" >>"$MASTER"
    echo "" >>"$MASTER"
    continue
  fi

  if [[ "$line" == @secao* ]]; then
    new_secao="${line#@secao }"
    if [[ "$content_in_part" == true && -n "$current_secao" ]]; then
      emit_secao_transition "$new_secao"
    fi
    current_secao="$new_secao"
    secao_heading_pending=true
    continue
  fi

  append_file "$line"
done <"$MANIFEST"

if [[ -f "$ROOT/scripts/abnt-number-figures-tables.py" ]]; then
  python3 "$ROOT/scripts/abnt-number-figures-tables.py" "$MASTER"
fi

echo "→ Markdown unificado: $MASTER"
echo "   $(wc -l <"$MASTER") linhas, $(du -h "$MASTER" | cut -f1)"

RESOURCE_PATH="$ROOT:$ROOT/ebook:$ROOT/ebook/assets:$ROOT/ebook/capitulos:$ROOT/modulos:$ROOT/modulos/diagramas:$ROOT/labs:$ROOT/apps:$ROOT/deploy"

if ! ensure_pandoc; then
  echo ""
  echo "Erro: pandoc é obrigatório para gerar EPUB."
  print_manual_install_hint pandoc
  echo ""
  echo "Markdown já gerado — importe no Calibre: $MASTER"
  echo "Ou execute sem --skip-install (pede sudo) ou: ./scripts/build-ebook.sh --install-deps"
  exit 1
fi

EPUB="$OUT_DIR/microsservicos-financeiros-lab.epub"
PDF="$OUT_DIR/microsservicos-financeiros-lab.pdf"
EPUB_CSS="$ROOT/ebook/epub.css"

pandoc_args=(
  --from markdown+raw_html+raw_tex
  --no-highlight
  --resource-path="$RESOURCE_PATH"
  --metadata title="$TITLE"
  --metadata subtitle="$SUBTITLE"
  --metadata author="$AUTHOR"
  --metadata lang="pt-BR"
  --metadata publisher="$PUBLISHER"
  --metadata description="$DESCRIPTION"
)

[[ -f "$EPUB_CSS" ]] && pandoc_args+=(--css="$EPUB_CSS")

if [[ -f "$COVER" ]]; then
  pandoc_args+=(--epub-cover-image="$COVER")
  echo "→ Capa: $COVER"
else
  echo "Aviso: capa não encontrada em ebook/assets/cover.png" >&2
fi

pandoc "$MASTER" -o "$EPUB" \
  "${pandoc_args[@]}" \
  --toc --toc-depth=2 \
  -M toc-title="Sumário"

echo "→ EPUB: $EPUB"

generate_pdf() {
  local engine="$1"
  local font_args=()
  local header_args=()
  if [[ -f "$ABNT_PDF_HEADER" ]]; then
    header_args=(--include-in-header="$ABNT_PDF_HEADER")
    [[ -f "$ABNT_PDF_UNICODE" ]] && header_args+=(--include-in-header="$ABNT_PDF_UNICODE")
  fi
  if [[ "$engine" == "xelatex" || "$engine" == "lualatex" ]]; then
    font_args=(
      -V mainfont="TeX Gyre Termes"
      -V monofont="TeX Gyre Cursor"
    )
  fi
  pandoc "$MASTER" -o "$PDF" \
    --from markdown+raw_html+raw_tex \
    -M numbersections=false \
    "${header_args[@]}" \
    --pdf-engine="$engine" \
    -V documentclass=book \
    -V classoption=oneside,openany \
    -V geometry:"top=3cm,left=3cm,right=2cm,bottom=2.5cm,headheight=14pt" \
    -V lang=pt-BR \
    -V fontsize=12pt \
    -V linestretch=1.5 \
    "${font_args[@]}" \
    --resource-path="$RESOURCE_PATH" \
    --metadata title="$TITLE" \
    --metadata author="$AUTHOR" \
    --metadata subtitle="$SUBTITLE"
}

fix_tex_formats_hint() {
  echo ""
  echo "PDF não gerado: formato LaTeX em falta (comum no Arch/Manjaro após instalar texlive)."
  echo "Tente:"
  print_manual_install_hint tex
  echo "  sudo fmtutil-sys --all   # ou: fmtutil-user --byfmt pdflatex"
  echo ""
  echo "Ou: ./scripts/build-ebook.sh --install-deps"
  echo "Alternativa: EPUB em ./scripts/open-ebook.sh ou Calibre → converter para PDF"
}

if ensure_tex_for_pdf; then
  pdf_ok=false
  if command -v xelatex &>/dev/null && tex_format_ready "xelatex.fmt"; then
    if generate_pdf xelatex; then pdf_ok=true; fi
  fi
  if [[ "$pdf_ok" == false ]] && command -v lualatex &>/dev/null && tex_format_ready "lualatex.fmt"; then
    if generate_pdf lualatex; then pdf_ok=true; fi
  fi
  if [[ "$pdf_ok" == false ]] && command -v pdflatex &>/dev/null && tex_format_ready "pdflatex.fmt"; then
    if generate_pdf pdflatex; then pdf_ok=true; fi
  fi
  if [[ "$pdf_ok" == false ]] && [[ "$SKIP_INSTALL" == false ]]; then
    echo ""
    echo "→ A corrigir formatos LaTeX e repetir geração do PDF..."
    fix_tex_formats
    if command -v xelatex &>/dev/null && tex_format_ready "xelatex.fmt"; then
      if generate_pdf xelatex; then pdf_ok=true; fi
    fi
    if [[ "$pdf_ok" == false ]] && command -v lualatex &>/dev/null && tex_format_ready "lualatex.fmt"; then
      if generate_pdf lualatex; then pdf_ok=true; fi
    fi
    if [[ "$pdf_ok" == false ]] && command -v pdflatex &>/dev/null && tex_format_ready "pdflatex.fmt"; then
      if generate_pdf pdflatex; then pdf_ok=true; fi
    fi
  fi
  if [[ "$pdf_ok" == true ]]; then
    echo "→ PDF: $PDF"
    ensure_poppler || true
    if command -v pdfinfo &>/dev/null; then
      pages="$(pdfinfo "$PDF" 2>/dev/null | awk '/Pages:/ {print $2}')"
      [[ -n "$pages" ]] && echo "   Páginas (PDF): $pages"
    fi
  else
    fix_tex_formats_hint
  fi
else
  echo ""
  echo "LaTeX não instalado — apenas EPUB gerado."
  print_manual_install_hint tex
  echo "Ou: ./scripts/build-ebook.sh --install-deps"
fi

echo ""
echo "Concluído."
