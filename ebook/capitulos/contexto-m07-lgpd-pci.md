## LGPD no Brasil (Lei 13.709/2018)

Vigência plena a partir de 2020. Trata dado pessoal como direito do titular, não como subproduto de log.

| Princípio | Na prática técnica |
|-----------|-------------------|
| **Finalidade** | Só coletar o necessário para o *Pix* |
| **Minimização** | CPF não vai para trace/métrica |
| **Segurança** | Criptografia, controle de acesso, cofre de segredos |
| **Responsabilização** | Evidência de política (Kyverno) e processo |

**Base legal** — não basta “precisamos para debug”; incidente com log cheio de PII vira passivo jurídico e reputacional.

Log e trace são o **corredor do banco**: a câmera não grava conversa íntima do cliente sem necessidade.

## PCI-DSS e cartão

**PCI-DSS** aplica-se quando **PAN** (número completo do cartão) ou dados sensíveis de autenticação circulam no seu sistema.

| Abordagem | Ideia |
|-----------|--------|
| **Tokenização** | Sistema interno vê token, não PAN |
| **Segmentação de rede** | Menor superfície |
| **Não logar PAN** | Óbvio, ainda violado em incidentes |

Este lab foca *Pix* e conta — mas equipes de plataforma compartilham cluster com times de cartão; **política no cluster** (lab 07d) protege todos.

## Relação com observabilidade

Lab **07f**: lista de campos proibidos, máscara em *structlog*, Collector removendo atributos antes do Jaeger. Telemetria **não é** depósito eterno de dados pessoais.

## Linha do tempo regulatória

| Ano | Marco |
|-----|--------|
| 1999+ | PCI DSS (evolução por versões) |
| 2018 | LGPD sancionada (BR) |
| 2020 | LGPD em vigor; multas e precedentes |
| 2020s | GDPR na Europa influencia fornecedores globais |
