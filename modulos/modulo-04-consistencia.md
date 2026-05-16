# Módulo 4 — Concorrência, idempotência e sagas

**Laboratório:** [04 — Redis, Postgres e idempotência](../labs/lab-04-redis-postgres-idempotencia.md)

## Quando o saldo não fecha

Dois cliques em “pagar” podem ler o mesmo saldo e ambos passar — impossível num ledger. **Concorrência** é disputa no mesmo recurso; **consistência** é o livro fechar. Num PostgreSQL há um caderno; entre *Pix* e *Limites* são cadernos distintos. Em microsserviços, o problema se multiplica: não existe uma única transação SQL abrangendo *Pix*, *Limites* e antifraude. Cada serviço tem seu banco; a **consistência** torna-se um desenho explícito de locks, idempotência e, quando necessário, **sagas** com compensação.

Este capítulo conecta **Redis**, **PostgreSQL** e **Kafka** ao fluxo do *Pix* que você já opera no lab.

## Cenário no laboratório

O *servico-pix* já envia o cabeçalho `Idempotency-Key`; falta **persistir** o estado da operação e proteger saldos contra corrida. Você demonstrará o furo sem controle, corrigirá com lock otimista ou pessimista e garantirá que replays HTTP e mensagens Kafka duplicadas não gerem efeito em dobro.

## Concorrência e a ilusão do snapshot

Duas transações leem saldo 100 antes de qualquer escrita; ambas aprovam débito de 90; o saldo final deveria ser 10, mas o sistema registra -80. Isso é **condição de corrida** — não bug de sintaxe, bug de **modelo de isolamento**.

### ACID em um banco vs BASE entre serviços

Num PostgreSQL, **ACID** significa: tudo da transação passa junto ou nada passa (**atomicidade**), regras de negócio respeitadas (**consistência**), transações simultâneas não se atropelam de forma errada (**isolamento**), sobrevive a reinício (**durabilidade**).

Entre *Pix* e *Limites* não existe `BEGIN` único. O padrão é **BASE**:

- **Basically Available** — portas continuam atendendo mesmo com partes degradadas.
- **Soft State** — o saldo que você lê pode estar um instante desatualizado até a fila processar (estado “mole”, não mentira intencional).
- **Eventual Consistency** — depois dos eventos e retries, os cadernos convergem.

Há acordos explícitos (outbox, idempotência, compensação), não um único botão “commit global”.

## Lock otimista: versão como juiz

Como editar planilha com número de revisão: só grava quem ainda vê a mesma revisão. Adicione coluna `version` à conta:

```sql
UPDATE accounts SET balance = balance - 90, version = version + 1
WHERE id = ? AND version = ?;
```

Se nenhuma linha for afetada, outra transação ganhou — retorne conflito (`409`) ou retry controlado. Funciona bem quando conflitos são **raros** e você quer throughput.

## Lock pessimista: segurança na transação

`SELECT ... FOR UPDATE` tranca a fila do caixa até terminar o atendimento (**COMMIT** no SQL). Ninguém mexe no saldo naquela janela. Mais seguro, menos paralelismo — comum quando a mesma conta recebe muitos *Pix* por segundo.

## Idempotência: a mesma chave, o mesmo efeito

**Idempotência** garante que repetir a mesma operação identificada não duplica efeito. O cliente envia `Idempotency-Key: uuid` no *Pix*.

Implementações comuns (não reduza idempotência só a Redis):

| Mecanismo | Uso |
|-----------|-----|
| **Redis `SET NX`** | “Só cria se não existir” — cache rápido da resposta por chave |
| **Unique constraint** (Postgres) | Banco recusa segunda linha com mesma `idempotency_key` |
| **Inbox / dedup table** | Tabela “já processei mensagem X” no consumer Kafka |
| **Event store** | Histórico de eventos imutáveis (cada mudança é registro novo) |
| **Kafka EOS** | *Exactly-once* no Kafka — exige produtor transacional + desenho cuidadoso |

Fluxo típico com **Redis** no lab:

1. `SET idempotency:<key> PROCESSING NX EX 86400`
2. Se a chave foi criada → processar negócio, gravar resultado final na chave
3. Se a chave já existe → devolver resposta armazenada (ou aguardar estado terminal)

O *Pix* do repositório já ecoa o header; neste módulo você **persiste** o comportamento. Em APIs de pagamento, idempotência não é opcional — é proteção contra retry de cliente, timeout de rede e duplo clique.

## Idempotência com Kafka

Kafka entrega **at-least-once** na prática: a mesma mensagem `pix.iniciado` pode ser processada duas vezes. O consumer deve deduplicar pela `idempotency_key` do payload (`SETNX` no Redis ou chave natural no Postgres) **antes** de aplicar efeito colateral — notificação, pontos, projeção de saldo.

## Sagas: passos locais e compensação

**Saga** é fluxo em várias salas sem transação global: débito OK → pontos falha → **compensação** (estorno) no débito. Não existe “desfazer” mágico — em banco faz-se lançamento reverso (**ledger** imutável: nunca apague, sempre compense).

| Estilo | Como funciona |
|--------|----------------|
| **Orquestrada** | Um “maestro” (serviço coordenador) manda fazer e desfazer passos |
| **Coreografada** | Cada serviço ouve evento e publica o próximo — sem centro único |

Exemplo narrativo: débito em contas OK → pontos em fidelidade falha → **estorno** em contas com lançamento reverso no ledger. Prefira **ledger imutável** (novos lançamentos) a apagar histórico — auditoria e regulatório agradecem.

![Orquestração vs coreografia](diagramas/m04-saga-estilos.png)

### Aprofundamento: o que o lab não simplifica

| Tópico | Risco real |
|---------|------------|
| **Compensação não determinística** | Estorno parcial, taxa já cobrada, antifraude irreversível |
| **Saga timeout** | Passo pendente vira transação órfã |
| **Orphan transactions** | Coordenador cai no meio da orquestração |
| **Semantic rollback** | “Desfazer” não restaura estado de negócio (ex.: notificação já enviada) |
| **Pivot transaction** | Ponto após o qual compensação muda de regra |

![Saga com compensação](diagramas/m04-saga.png)

## Transactional outbox: DB e fila alinhados

Cenário ruim: Postgres grava o *Pix*, o processo cai antes de publicar no Kafka — o dinheiro “foi”, o evento não. **Outbox**: na **mesma transação SQL**, grava negócio + linha na tabela `outbox`. Um **relay** (worker separado, no lab `worker-outbox-relay`) lê a tabela e publica no Kafka — como registrar a carta no livro caixa e o carteiro buscar depois.

![Transactional outbox](diagramas/m04-outbox.png)

O Módulo 7 aprofunda outbox e DLQ; aqui você entende por que o *Pix* não deve bloquear a resposta HTTP com **publish síncrono** ao broker como destino final do fluxo crítico.

## Trade-offs

| Escolha | Ganho | Custo |
|---------|-------|-------|
| Lock pessimista | Correção forte no saldo | Menos throughput na mesma conta |
| Lock otimista | Throughput em baixa contenção | Retries e conflitos `409` |
| Saga coreografada | Desacoplamento | Depuração difícil sem tracing |
| Saga orquestrada | Visibilidade central | Ponto único de falha no orchestrator |
| Outbox | Consistência DB + evento | Complexidade de relay e monitoração |

## Anti-patterns

- Publicar no Kafka **antes** do commit no Postgres.
- Compensação que apaga histórico em vez de lançamento reverso.
- Saga longa com dezenas de passos síncronos HTTP.
- Idempotência só no edge, ausente no consumer.

## Quando NÃO usar

- **Saga:** fluxo cabe numa transação local ou um único serviço.
- **Outbox:** volume baixo e perda ocasional de evento é aceitável (raro em pagamentos).
- **Redis para idempotência:** sem TTL e persistência alinhada ao negócio.

## Produção real

- **Schema Registry** (Avro/Protobuf) para evolução de eventos `pix.iniciado`.
- **DLQ** para poison messages após N tentativas.
- Monitorar **lag** e tamanho da outbox não publicada.

## Troubleshooting

| Sintoma | Investigação |
|---------|--------------|
| Saldo divergente | Isolamento, lock, duplicidade de consumer |
| Evento não chegou | Tabela outbox, relay parado, ACL Kafka |
| Compensação falhou | Log de saga, estado órfão, timeout |

## Exercícios

1. Reproduza corrida de saldo sem lock; depois com `version`.
2. Reenvie mesmo `Idempotency-Key` e prove mesma resposta.
3. Desenhe compensação para “pontos falharam após débito”.

## Em resumo

Consistência em microsserviços é engenharia explícita: locks para saldo, idempotência para HTTP e fila, sagas para fluxos multi-serviço, outbox para não perder eventos. O laboratório mostra o furo e a correção com dados reais no *kind*.

## Leitura complementar

- [Transactional outbox](https://microservices.io/patterns/data/transactional-outbox.html)
- [Saga pattern](https://microservices.io/patterns/data/saga.html)
