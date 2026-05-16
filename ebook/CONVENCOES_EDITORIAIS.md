# Convenções editoriais

Regras de **idioma e nomenclatura** adotadas neste livro e no repositório `financial-applications`. Não são norma externa nem certificação — são escolhas explícitas para leitura técnica em português com vocabulário que aparece em vagas, documentação de ferramentas e clusters reais.

## Idioma: inglês técnico + português explicativo

- Termos consagrados na documentação das ferramentas (**retry**, **consumer lag**, **circuit breaker**, **transactional outbox**) permanecem em **inglês** no corpo do texto.
- Na **primeira ocorrência relevante** de cada capítulo, o texto explica o termo em português (sem rótulos do tipo “Analogia:” ou “Em português claro”).
- Consulta rápida: [Siglas rápidas](SIGLAS-RAPIDAS.md) (início do livro) e [Glossário](GLOSSARIO.md) (final).

Evitamos tradução literal em todo parágrafo (“caixa de saída” por *outbox*) ou só português sem o termo inglês (“nova tentativa” sem *retry*), porque isso dificulta busca na documentação oficial e em incidentes reais.

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

## Tom

- Corpo técnico preciso; evitar antropomorfizar (“o broker retorna”, não “o Kafka acha”).
- Em procedimentos, linguagem neutra (“o cliente não observa impacto na resposta”).

## Diagramas e código

- Manifests e identificadores permanecem em inglês (Kubernetes, Istio, OpenTelemetry).
- Comentários em código de laboratório podem ser em português.
