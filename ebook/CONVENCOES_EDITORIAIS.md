# Convenções editoriais

Como este livro trata **idioma e nomenclatura** no texto e nos exemplos. Folha de rosto, margens e sumário seguem adaptação das normas ABNT para obras técnicas na edição impressa.

## Idioma: inglês técnico + português explicativo

- Termos consagrados na documentação das ferramentas (**retry**, **consumer lag**, **circuit breaker**, **transactional outbox**) permanecem em **inglês** no corpo do texto.
- Na **primeira ocorrência relevante** de cada capítulo, o termo é explicado em português, de forma direta, sem fórmulas repetitivas (“Analogia:”, “Em português claro”).
- Consulta rápida: [Siglas rápidas](SIGLAS-RAPIDAS.md) (início do livro) e [Glossário](GLOSSARIO.md) (final).

Mantemos o termo em inglês junto da explicação — não só “nova tentativa” sem *retry*, nem traduções literais em cada linha (“caixa de saída” por *outbox*) — para alinhar com documentação oficial e relatórios de incidente.

## Nomes de serviços

| Uso | Forma |
|-----|--------|
| Domínio de negócio | *Pix*, *Limites*, *Crédito* |
| Nome lógico em texto | serviço *Pix*, serviço de *Limites* |
| Recurso Kubernetes / código | `servico-pix`, `servico-limites`, `servico-credito` |

## Termos preferidos

| Usar no texto | Evitar |
|---------------|--------|
| retry | só “nova tentativa”, sem o termo inglês |
| consumer lag | só “atraso do consumidor” |
| plaintext | “texto puro” (ambíguo) |
| at-least-once | tradução longa repetida em cada parágrafo |
| circuit breaker | “disjuntor” sem contexto |
| transactional outbox | “caixa de saída” literal |

## Diagramas e código

- Manifests e identificadores permanecem em inglês (Kubernetes, Istio, OpenTelemetry).
- Comentários em código de laboratório podem ser em português.
