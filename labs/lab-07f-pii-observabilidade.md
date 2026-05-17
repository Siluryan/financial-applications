# Lab 07f — PII em logs e traces

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.6](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Impedir que CPF, e-mail e tokens completos apareçam em **logs JSON** e **spans** exportados ao Jaeger — alinhado a LGPD e boas práticas de observabilidade.

Traces e logs são replicados para sistemas de terceiros (SaaS, retenção longa). Dado pessoal em atributo de span vira vazamento difícil de apagar. O lab separa **identificadores técnicos** (`trace_id`, `account_id` fictício) de **PII** regulada.

**Tempo estimado:** 75–90 min.

## Antes de começar

### Conhecimento (este lab)

- PII e minimização ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [LGPD](../ebook/capitulos/contexto-m07-lgpd-pci.md)).

### Labs anteriores

- [Lab 02 — OTel + Jaeger](lab-02-opentelemetry-jaeger.md).

### Ambiente

- Compose ou *kind* com OTLP; Collector em `deploy/observability/` quando usar filtro centralizado.

## Passos

### 1. Política de dados

Crie `docs/dados-observabilidade.md` listando campos **proibidos** em log/trace:

- CPF/CNPJ em claro
- PAN de cartão
- Senha, OTP, token OAuth completo
- Chave PIX de terceiros (conforme política interna)

Liste campos **permitidos** com justificativa: `trace_id`, `transfer_id`, `account_id` de teste (`acc_demo`).

### 2. Processor em logs (structlog)

```python
import re

def mask_cpf(_, __, event_dict):
    for key in ("cpf", "document", "metadata"):
        if key in event_dict and isinstance(event_dict[key], str):
            event_dict[key] = re.sub(r"\d{11}", "***.***.***-**", event_dict[key])
    return event_dict
```

Integre na cadeia do structlog do *Pix*. Gere log de teste com CPF fictício `12345678901` — saída deve estar mascarada.

### 3. OTel Collector — attributes processor

Em `deploy/observability/collector-config.yaml`:

```yaml
processors:
  attributes/redact:
    actions:
      - key: user.email
        action: delete
      - key: cpf
        action: hash
```

Pipeline: `receivers: [otlp]` → `processors: [attributes/redact]` → `exporters: [otlp/jaeger]`.

Reinicie Collector e reenvie traces de teste.

### 4. Revisão manual

1. `POST /v1/pix` de teste.
2. Jaeger — inspeccione atributos de todos os spans.
3. `kubectl logs` / `docker compose logs` — confirme mascaramento.

Registe capturas ou descrição textual para evidência.

### 5. Tail sampling e custo

Documente regra de **tail sampling** (erro + latência > SLO). Estime redução de volume vs 100 % ([Lab 02 A6](lab-02-opentelemetry-jaeger.md)). Confirme que traces de erro ainda aparecem após política.

Reveja o diagrama *m02-sampling-strategies* (Módulo 2) ao decidir o que amostrar em produção.

## Deu certo quando

- [ ] Política escrita em `docs/dados-observabilidade.md`.
- [ ] Log de teste com CPF fictício mascarado.
- [ ] Trace no Jaeger sem campos proibidos.
- [ ] Política de sampling documentada.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| PII ainda no Jaeger | App exporta antes do Collector; processor na app |
| Hash reversível | Preferir delete ou tokenização |

## Próximo passo

[Lab 07g — SRE prático](lab-07g-sre-praticas.md)
