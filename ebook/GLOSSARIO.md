Referência rápida dos termos usados neste livro. Cada entrada traz o significado em linguagem direta e uma imagem mental para fixar. Para aprofundar, use o capítulo indicado.

**Como ler:** termos em inglês seguem as [convenções editoriais](CONVENCOES_EDITORIAIS.md) do livro; nomes do lab usam `servico-pix` (recurso) e *Pix* (domínio).

---

## A

**ACID** — Quatro garantias de uma transação num banco relacional: tudo passa junto ou nada passa; regras respeitadas; transações simultâneas não corrompem dados; sobrevive a reinício. *Como um cheque que só compensa se todas as assinaturas estiverem válidas.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 4](../modulos/modulo-04-consistencia.md)

**Acks (Kafka)** — Quantas réplicas do broker precisam confirmar antes do produtor considerar a mensagem gravada. *Como pedir “me avise quando pelo menos dois cofres tiverem a cópia”.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Admission controller** — Componente que aprova ou nega cada manifest Kubernetes antes de virar pod. *Porteiro da portaria que lê o YAML na entrada.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07d](../labs/lab-07d-kyverno-admission.md)

**Argo CD** — Ferramenta GitOps que compara cluster com Git e sincroniza diferenças. *Auditor que confere se o prédio está igual à planta.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**At-least-once** — A mensagem pode ser entregue mais de uma vez; o consumidor precisa deduplicar. *Correio que pode entregar a mesma carta duas vezes.* → [Módulo 4](../modulos/modulo-04-consistencia.md), [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**At-most-once** — A mensagem pode ser perdida; não há garantia de repetição. *Carta enviada sem aviso de recebimento.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**AuthorizationPolicy (Istio)** — Regra de quem pode chamar quem no mesh (por identidade SPIFFE, namespace, etc.). *Lista de convidados na porta do andar.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

---

## B

**Backstage** — Portal que centraliza catálogo de serviços, donos, dependências e documentação. *Mapa do shopping com loja, dono e manual.* → [Módulo 6](../modulos/modulo-06-backstage.md)

**BASE** — Modelo entre microsserviços: disponível, estado que pode estar temporariamente desalinhado, consistência que converge depois. *Várias agendas que alinham após o correio interno.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 4](../modulos/modulo-04-consistencia.md)

**Blue-green** — Dois ambientes completos; troca-se o tráfego de uma vez. *Dois restaurantes; o cardápio muda num único anúncio.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Broker (Kafka)** — Servidor que armazena e distribui mensagens por tópicos. *Armazém central do correio interno.* → [Módulo 2](../modulos/modulo-02-observabilidade.md), [Lab 02b](../labs/lab-02b-kafka-consumer.md)

**Bulkhead** — Isolar recursos para uma falha não drenar todo o sistema. *Anteparas de navio: um compartimento alaga, os outros seguem.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

---

## C

**Canary** — Enviar uma fração pequena do tráfego para a versão nova antes de promover. *Provar o prato numa mesa antes de servir o salão inteiro.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**CAP** — Em partição de rede, escolha entre consistência forte e disponibilidade; não os três juntos. *Linha telefônica cortada entre agências: atender ou travar até alinhar o livro.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**Cardinality (métricas)** — Quantidade de séries distintas (ex.: um label por usuário). Alta cardinalidade explode custo e armazenamento. *Etiqueta diferente para cada cliente no painel — milhões de linhas.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Chaos engineering** — Injetar falhas controladas para aprender antes do incidente real. *Simulado de incêndio no prédio.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Exercícios de falha](../labs/EXERCICIOS-FALHA-E-TROUBLESHOOTING.md)

**Circuit breaker** — Parar de chamar dependência doente após limiar de erros; falha rápida. *Disjuntor da casa que salta no curto.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**Clock skew** — Relógios de máquinas diferentes por alguns ms; não use hora como ordem global. *Relógios de parede que não batem.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**Component (Backstage)** — Entidade que representa um serviço ou biblioteca no catálogo. *Ficha de um balcão no mapa.* → [Módulo 6](../modulos/modulo-06-backstage.md)

**Consistência** — Dados e regras de negócio que “fecham” para quem lê. *Saldo que bate com os lançamentos.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**Consumer group** — Grupo de consumidores Kafka que divide partições; rebalance ao entrar/sair membro. *Equipe de carteiros com o mesmo uniforme.* → [Módulo 2](../modulos/modulo-02-observabilidade.md), [Lab 02b](../labs/lab-02b-kafka-consumer.md)

**Consumer lag** — Mensagens publicadas menos as já processadas pelo grupo. *Cartas na caixa ainda não lidas.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Control plane (Istio)** — Istiod: emite certificados e configura sidecars. *Sala de controle que distribui crachás.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**CQRS** — Separar modelo de escrita (comandos) do de leitura (consultas). *Caderno do caixa diferente do painel do gerente.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

---

## D

**Data plane (mesh)** — Sidecars Envoy que efetivamente roteiam e criptografam tráfego. *Funcionários na porta que executam a regra.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**Deadline** — Tempo máximo restante propagado na cadeia de chamadas. *Relógio compartilhado que todos respeitam.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**Deployment (K8s)** — Objeto que mantém N réplicas de um pod e faz rolling update. *Gerente que garante três guichês iguais abertos.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**DestinationRule** — Define subsets (v1, v2) para roteamento Istio. *Etiquetas “prato antigo” e “prato novo” na cozinha.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**DLQ (dead letter queue)** — Fila para mensagens que falharam após N tentativas. *Gaveta de cartas com endereço inválido.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Drift (GitOps)** — Cluster diferente do que está no Git. *Móvel mudado sem atualizar a planta.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

---

## E

**Envoy** — Proxy usado pelo Istio no sidecar. *Funcionário na porta de cada sala.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**Error budget** — Quanto o SLO ainda pode falhar antes de priorizar estabilidade. *Saldo de “atrasos permitidos” no delivery.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 2](../modulos/modulo-02-observabilidade.md)

**etcd** — Banco chave-valor do Kubernetes (estado desejado do cluster). *Caderno mestre da portaria.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Event sourcing** — Estado derivado de sequência imutável de eventos. *Extrato reconstruído linha a linha, sem apagar.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Exactly-once (efeito)** — Negócio aplicado uma vez; na prática: transação + idempotência. *Uma cobrança no extrato, não duas.* → [Módulo 4](../modulos/modulo-04-consistencia.md), [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Exemplar** — Link de um ponto de métrica para o trace correspondente. *Clique no gráfico que abre a encomenda.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**External Secrets Operator** — Sincroniza segredos de cofre externo para `Secret` no cluster. *Mensageiro do cofre para a gaveta do Kubernetes.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07a](../labs/lab-07a-segredos-external-secrets.md)

---

## F

**Fail-fast** — Responder erro imediatamente em vez de esperar timeout longo. *Fechar o balcão com aviso em vez de fila infinita.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**FLP** — Teorema: consenso assíncrono perfeito é impossível com falha de processo. *Por isso usamos timeout e quórum na prática.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**Fronteira de falha** — Limite onde uma queda não derruba tudo. *Sala com porta: incêndio numa sala não necessariamente no prédio inteiro.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

---

## G

**Gatekeeper** — Admission policies com linguagem Rego. *Mesmo porteiro, regras escritas em outro idioma.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**GitOps** — Git como fonte da verdade; cluster reconcilia com o repositório. *Planta aprovada no repositório; obra deve ser igual.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Golden path** — Caminho padrão opinativo para criar serviços (template, CI, OTel). *Estrada asfaltada em vez de trilha na mata.* → [Módulo 6](../modulos/modulo-06-backstage.md)

**Graceful shutdown** — Tempo para terminar requisições antes de matar o pod. *“Fechamos em 30 min; atendemos quem já está na fila”.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

---

## H

**HPA (Horizontal Pod Autoscaler)** — Aumenta ou reduz réplicas conforme CPU/memória. *Abrir mais guichês quando a fila cresce.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**HTTP 5xx** — Erro no servidor (não culpa do cliente). *Problema na cozinha, não no pedido.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## I

**Idempotência** — Mesma chave de operação → mesmo efeito que uma vez. *Segundo clique no “pagar” devolve o mesmo recibo.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 4](../modulos/modulo-04-consistencia.md)

**Idempotency-Key** — Cabeçalho HTTP que identifica a tentativa do cliente. *Número do protocolo na ordem de serviço.* → [Lab 04](../labs/lab-04-redis-postgres-idempotencia.md)

**ISR (In-Sync Replicas)** — Réplicas Kafka em dia com o líder. *Cópias do livro-caixa que já receberam a última página.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Istio** — Service mesh popular: mTLS, políticas, métricas via sidecar. *Rede de segurança e regras entre salas.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**Istiod** — Control plane do Istio. *Central que emite crachá e regra.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

---

## J

**Jaeger** — Backend de traces (UI para ver jornadas). *Rastreamento de encomenda com mapa.* → [Módulo 2](../modulos/modulo-02-observabilidade.md), [Lab 02](../labs/lab-02-opentelemetry-jaeger.md)

**Jitter** — Atraso aleatório entre retries para evitar efeito manada. *Esperar segundos diferentes para não bater na porta juntos.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

---

## K

**kind** — Kubernetes “de brinquedo” num container Docker (lab local). *Mini-cluster no laptop.* → [Lab 00](../labs/lab-00-kind-banco-minimo.md)

**Kyverno** — Motor de políticas de admission em YAML. *Porteiro com lista de regras legível.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07d](../labs/lab-07d-kyverno-admission.md)

---

## L

**Ledger** — Livro contábil imutável; correções por lançamento compensador. *Nunca apagar linha; estornar com nova linha.* → [Módulo 4](../modulos/modulo-04-consistencia.md)

**Least privilege** — Cada ator com só a permissão mínima necessária. *Chave só da gaveta que precisa abrir.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**LGPD** — Lei brasileira de proteção de dados pessoais. *CPF e nome não são decoração de log.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07f](../labs/lab-07f-pii-observabilidade.md)

**Liveness probe** — Kubernetes reinicia pod que não responde “estou vivo”. *Trocar atendente que travou de vez.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Load shedding** — Recusar novas requisições sob sobrecarga (503 + Retry-After). *Casa lotada: não entra mais ninguém na fila.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**Lock otimista** — Gravar só se a versão da linha não mudou. *Editar planilha com número de revisão.* → [Módulo 4](../modulos/modulo-04-consistencia.md)

**Lock pessimista** — Trancar linha até fim da transação (`FOR UPDATE`). *Caixa único: ninguém mexe no saldo até terminar.* → [Módulo 4](../modulos/modulo-04-consistencia.md)

**Loki** — Armazenamento de logs indexado por labels. *Arquivo por pasta, não por palavra solta em tudo.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## M

**Mirror (traffic)** — Copiar tráfego para v2 sem mudar resposta ao cliente. *Observar cozinha nova sem servir prato dela ao cliente.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**mTLS** — TLS nos dois lados: cliente e servidor apresentam certificado. *Crachá verificado de quem entra e de quem recebe.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

---

## O

**Observabilidade** — Métricas, logs e traces para entender comportamento interno sem adivinhar. *Hospital com painel, prontuário e percurso do paciente.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**OpenTelemetry (OTel)** — Padrão aberto para instrumentar e exportar telemetria. *Tomada única que serve vários aparelhos (Jaeger, Prometheus).* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**OTel Collector** — Hub que recebe, filtra e encaminha telemetria. *Central de triagem antes do arquivo.* → [Módulo 2](../modulos/modulo-02-observabilidade.md), `deploy/observability/`

**Outbox** — Gravar evento na mesma transação do negócio; relay publica depois. *Registrar “carta a enviar” no mesmo caderno do *Pix*.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07b](../labs/lab-07b-outbox-kafka.md)

**OutOfSync (Argo)** — Cluster diferente do Git no Argo CD. *Alerta de planta desatualizada.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

---

## P

**PACELC** — Sem partição: latência vs consistência; com partição: C vs A (como CAP). *Dia normal: cardápio na parede ou garçom que confirma com a cozinha.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**Pact** — Teste de contrato consumidor/provedor versionado no CI. *Combinado escrito antes da festa.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07c](../labs/lab-07c-pact-contratos.md)

**PAN** — Número completo do cartão (PCI). *Nunca trafegar em claro; usar token.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Partição (rede)** — Nós que não se falam temporariamente (P do CAP). *Linha entre agências cortada.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**PCI-DSS** — Padrão de segurança para dados de cartão. *Regras rígidas quando PAN circula.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**PDB (Pod Disruption Budget)** — Mínimo de pods disponíveis durante manutenção. *Pelo menos N guichês abertos na reforma.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**PII** — Dado pessoal identificável (CPF, e-mail, etc.). *Não colocar em trace nem log sem necessidade.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07f](../labs/lab-07f-pii-observabilidade.md)

**Pod** — Menor unidade agendável no Kubernetes (um ou mais containers). *Caixa onde roda o programa.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Poison message** — Mensagem inválida que quebra o consumer em loop. *Carta com endereço impossível — vai para DLQ.* → [Exercícios de falha](../labs/EXERCICIOS-FALHA-E-TROUBLESHOOTING.md)

**Prometheus** — Banco de séries temporais para métricas e alertas. *Painel de temperatura ao longo do dia.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Propagação de contexto** — Repassar `trace_id` entre HTTP, fila e workers. *Mesma etiqueta em cada caixa da encomenda.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## Q

**Quórum** — Maioria dos nós precisa concordar antes de gravar. *Três gerentes: decisão com dois assinando.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

---

## R

**Raft** — Algoritmo de consenso e eleição de líder (usado no etcd). *Votação para quem segura o caderno mestre.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**RBAC** — Controle de acesso no Kubernetes (quem pode o quê). *Crachá com permissão por sala.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Readiness probe** — Pod só recebe tráfego após passar health check. *Guichê abre só quando o sistema interno está pronto.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**RED** — Rate, Errors, Duration — trio para APIs. *Quantos, quantos erros, quão demorado.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Relay (outbox)** — Processo que lê outbox e publica no Kafka. *Carteiro que pega cartas pendentes no caderno.* → [Lab 07b](../labs/lab-07b-outbox-kafka.md), `apps/worker-outbox-relay/`

**Rebalance (Kafka)** — Redistribuição de partições entre consumidores do grupo. *Reorganizar pastas quando entra ou sai carteiro.* → [Lab 02b](../labs/lab-02b-kafka-consumer.md)

**Requests/limits (K8s)** — CPU/RAM reservada e teto máximo do container. *Mesa reservada e teto de consumo no buffet.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Retry** — Nova tentativa após falha transitória. *Ligar de novo quando a linha caiu.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**Retry storm** — Muitos retries simultâneos que impedem recuperação. *Todos empurrando a mesma porta quando ela abre.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**RPO** — Máximo de dados que podemos perder no desastre. *Backup de cinco minutos atrás vs de ontem.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [Lab 07e](../labs/lab-07e-disaster-recovery.md)

**RTO** — Tempo máximo para voltar a operar após desastre. *Quanto até reabrir o balcão.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Rolling update** — Trocar pods aos poucos, um lote por vez. *Trocar funcionários do turno sem fechar o banco.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

---

## S

**Saga** — Fluxo multi-serviço com compensação se um passo falhar. *Viagem com estorno se o hotel cancelar.* → [Módulo 4](../modulos/modulo-04-consistencia.md)

**Sampling (traces)** — Gravar só fração dos traces para controlar custo. *Fotografar 1 em cada 100 encomendas.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Schema Registry** — Catálogo de formato de mensagens (Avro/Protobuf). *Molde do envelope — mudar sem avisar quebra leitores.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Service (K8s)** — DNS estável para um conjunto de pods. *Nome do balcão que não muda quando troca o funcionário.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

**Service mesh** — Camada de proxies que cuida de rede, mTLS e políticas entre serviços. *Correio interno com segurança e regras embutidas.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**Sidecar** — Container auxiliar no mesmo pod (ex.: Envoy). *Assistente na porta de cada sala.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**SLA** — Compromisso contratual com cliente (multa se violar). *“Entrega em 40 min ou cupom”.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 2](../modulos/modulo-02-observabilidade.md)

**SLI** — Medida objetiva (ex.: % de requests &lt; 2 s). *Cronômetro do delivery.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**SLO** — Meta interna baseada no SLI. *Meta do time antes do contrato.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md), [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Software Catalog** — Registro YAML de sistemas, componentes e APIs no Backstage. *Cadastro de lojas do shopping.* → [Módulo 6](../modulos/modulo-06-backstage.md)

**SPIFFE** — Identidade padrão de workload (usada em mTLS do mesh). *CPF do serviço, não do humano.* → [Módulo 3](../modulos/modulo-03-service-mesh.md)

**Span** — Trecho de um trace com início, fim e nome (`pix.initiate`). *Um trecho da viagem da encomenda.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## T

**TechDocs** — Documentação Markdown do repo renderizada no Backstage. *Manual na prateleira da loja.* → [Módulo 6](../modulos/modulo-06-backstage.md)

**Timeout** — Tempo máximo de espera por dependência. *Desligar música de espera após 3 minutos.* → [Módulo 1](../modulos/modulo-01-resiliencia.md)

**Tópico (Kafka)** — Canal nomeado de mensagens (`pix.iniciado`). *Caixa do correio com etiqueta.* → [Lab 02b](../labs/lab-02b-kafka-consumer.md)

**Toxiproxy** — Proxy para simular latência, timeout e queda de rede. *Interruptor de “rede ruim” no lab.* → [Módulo 1](../modulos/modulo-01-resiliencia.md), [Lab 01](../labs/lab-01-toxiproxy-resiliencia.md)

**Trace** — Jornada completa de uma requisição (vários spans). *Rastreio da encomenda do clique ao Kafka.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**traceparent** — Cabeçalho W3C com trace-id e span-id. *Etiqueta padrão colada em cada caixa.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## U

**USE** — Utilization, Saturation, Errors — trio para recursos (CPU, disco). *Quanto usa, quanto fila, quantos erros.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

---

## V

**Vault** — Cofre de segredos com auditoria e rotação. *Cofre com registro de quem abriu.* → [Módulo 7](../modulos/modulo-07-operacao-conformidade.md)

**Vector clock** — Relógios lógicos para ordenar eventos sem hora global. *Números de versão em vez de relógio de parede.* → [Módulo 0](../modulos/modulo-00-fundamentos-distribuidos.md)

**VirtualService (Istio)** — Regras de roteamento HTTP (pesos, headers, mirror). *Placa que diz “90 % para v1, 10 % para v2”.* → [Módulo 5](../modulos/modulo-05-deploy-gitops.md)

---

## W

**W3C Trace Context** — Padrão de cabeçalhos para propagação de trace. *Etiqueta internacional da encomenda.* → [Módulo 2](../modulos/modulo-02-observabilidade.md)

**Worker** — Processo que consome fila ou processa outbox em background. *Carteiro ou backoffice que não atende o balcão principal.* → [Lab 02b](../labs/lab-02b-kafka-consumer.md), `worker-outbox-relay`

---

As **siglas rápidas** para consulta durante a leitura estão no início do livro: [`SIGLAS-RAPIDAS.md`](SIGLAS-RAPIDAS.md).

*Última atualização alinhada aos módulos 0–7 e labs do repositório `financial-applications`.*
