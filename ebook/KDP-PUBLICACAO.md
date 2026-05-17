# Publicação na Amazon KDP — segunda edição (2026)

Registo editorial do volume *Microsserviços financeiros: teoria e laboratório*. Documento de apoio à submissão na KDP; não faz parte do corpo narrativo do EPUB.

## Direitos e conteúdo

| Item | Situação |
|------|----------|
| Autoria do texto | Guilherme Rogério Ramos Dias — © 2026, todos os direitos reservados |
| Código do repositório | Licença MIT (repositório *financial-applications*) |
| Diagramas | Autor, a partir de Mermaid no repositório |
| Capas | Originais — `cover.png`, `cover-back-kdp.png`, `cover-paperback-6x9-full.png` |
| Marcas de terceiros | Aviso em `AVISO-LEGAL-EDITORIAL.md` |
| Ferramentas de apoio à capa | Declarar na submissão KDP conforme política vigente da Amazon |

Metadados de direitos no painel KDP: **Todos os direitos reservados** (texto do livro).

## Pacote técnico

| Item | Arquivo / comando |
|------|-------------------|
| EPUB | `./scripts/build-ebook.sh` → `ebook/build/microsservicos-financeiros-lab.epub` |
| Capa ebook | `ebook/assets/cover.png` (1600×2560) |
| Contracapa | `ebook/assets/cover-back-kdp.png` |
| Capa brochura 6×9 | `./scripts/build-kdp-cover.sh` → `cover-paperback-6x9-full.png` |
| Páginas (brochura) | 420 — lombada calculada automaticamente |
| Sumário | Gerado; título **Sumário** |
| Formatação | ABNT adaptada — `FORMACAO-ABNT.md`, `epub.css` |
| Idioma | pt-BR |

## Metadados do painel KDP

| Campo | Valor |
|-------|--------|
| **Título** | Microsserviços financeiros: teoria e laboratório |
| **Subtítulo** | Pix, Kubernetes, Kafka, OpenTelemetry e operação em bancos digitais |
| **Edição** | 2 |
| **Autor** | Guilherme Rogério Ramos Dias |
| **Editora** | Personal DevOps Trainer |
| **Descrição** | Percurso prático para engenheiros de plataforma: resiliência, mensageria, observabilidade, service mesh, dados, GitOps e operação segura, com laboratórios em Python e cluster kind. Segunda edição, 2026. |
| **Categorias** | Computadores e tecnologia › Redes; Programação |
| **Palavras-chave** | microsserviços, kubernetes, kafka, opentelemetry, pix, devops, sre |
| **Público** | Profissional / técnico |

## Edição pronta para submissão

- Aviso legal e ficha catalográfica no volume
- Capa frontal e contracapa com sinopse
- Capa completa brochura 6″×9″ (420 páginas)
- Código e labs disponíveis no repositório *financial-applications* como material complementar

Validação recomendada: Kindle Previewer (EPUB) e visualização da capa brochura antes de publicar.
