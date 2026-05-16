Consulte esta tabela ao longo da leitura. Definições completas e analogias: [Glossário](GLOSSARIO.md) (final do livro).

## Siglas e termos curtos

| Sigla / termo | Significado |
|---------------|-------------|
| **ACID** | Garantias de transação num banco (atomicidade, consistência, isolamento, durabilidade) |
| **AP / CP** | Escolhas sob partição de rede: disponibilidade vs consistência forte (CAP) |
| **API** | Interface HTTP exposta pelo serviço |
| **BASE** | Disponível, estado mole, consistência eventual — padrão entre microsserviços |
| **CAP** | Teorema: em partição, não dá para ter consistência e disponibilidade plenas ao mesmo tempo |
| **CI** | Pipeline que roda testes a cada mudança de código |
| **CNCF** | Fundação que hospeda Kubernetes, Prometheus, OpenTelemetry, etc. |
| **CR** | *Custom Resource* — tipo de objeto estendido no Kubernetes |
| **DLQ** | *Dead letter queue* — fila de mensagens que falharam após N tentativas |
| **DR** | *Disaster recovery* — recuperação após desastre |
| **ESB** | *Enterprise Service Bus* — barramento central de integração (era SOA) |
| **GC** | *Garbage collection* — coleta de memória (ex.: pausas na JVM) |
| **GitOps** | Cluster deve refletir o que está versionado no Git |
| **HPA** | *Horizontal Pod Autoscaler* — escala réplicas por CPU/memória |
| **HTTP** | Protocolo web usado pelos serviços do lab |
| **IDP** | *Internal Developer Platform* — plataforma interna para desenvolvedores |
| **ISR** | *In-Sync Replicas* — réplicas Kafka alinhadas com o líder |
| **K8s** | Kubernetes |
| **LGPD** | Lei Geral de Proteção de Dados (Brasil) |
| **mTLS** | *Mutual TLS* — certificado verificado nos dois lados da conexão |
| **OTel** | OpenTelemetry — padrão de métricas, logs e traces |
| **PACELC** | Extensão do CAP: sem partição, latência vs consistência |
| **PAN** | Número completo do cartão (escopo PCI) |
| **PDB** | *Pod Disruption Budget* — mínimo de pods up em manutenção |
| **PCI-DSS** | Padrão de segurança para dados de cartão |
| **PII** | *Personally identifiable information* — dado pessoal (CPF, e-mail, etc.) |
| **RPO** | *Recovery Point Objective* — quanto dado pode se perder no pior caso |
| **RTO** | *Recovery Time Objective* — em quanto tempo o serviço deve voltar |
| **SLA** | Acordo contratual de nível de serviço com o cliente |
| **SLI** | Indicador medido (ex.: % de requests abaixo de 2 s) |
| **SLO** | Meta interna baseada no SLI |
| **SOA** | *Service-Oriented Architecture* — serviços com contrato, muitas vezes via ESB |
| **SPIFFE** | Identidade padrão de workload (certificado do pod no mesh) |
| **TLS** | Criptografia na camada de transporte (HTTPS) |
| **YAML** | Formato de configuração legível (Kubernetes, catálogo Backstage) |

## Termos em inglês usados sem traduzir

| Termo | Em uma linha |
|-------|----------------|
| **at-least-once** | Mensagem pode chegar mais de uma vez — exige idempotência |
| **canary** | Fração pequena do tráfego na versão nova antes de promover |
| **circuit breaker** | Para de insistir em dependência doente (disjuntor) |
| **consumer lag** | Mensagens na fila ainda não processadas pelo grupo |
| **consumer group** | Conjunto de consumidores Kafka que divide o trabalho |
| **drift** | Cluster diferente do que está no Git |
| **idempotency key** | Chave que garante mesmo efeito em repetições |
| **outbox** | Evento gravado na mesma transação do negócio; relay publica depois |
| **retry / jitter** | Nova tentativa; espera aleatória para evitar efeito manada |
| **sidecar** | Container proxy ao lado da app (ex.: Envoy no Istio) |
| **trace / span** | Jornada completa / trecho medido da jornada |

*Pix* = domínio de negócio; `servico-pix` = nome do recurso no cluster e no código.
