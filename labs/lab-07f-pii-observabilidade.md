# Lab 07f — PII em logs e traces

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.6](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Impedir CPF, e-mail e tokens completos em **logs JSON** e **spans** exportados ao Jaeger.

## Antes de começar

### Conhecimento (este lab)

- **PII** = dado pessoal (CPF, e-mail) — não vai em log/trace ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md), [LGPD](../ebook/capitulos/contexto-m07-lgpd-pci.md)).

### Labs anteriores

- [Lab 02 — OTel + Jaeger](lab-02-opentelemetry-jaeger.md) — traces visíveis no Jaeger.

### Ambiente

- Compose ou *kind* com OTel Collector (`deploy/observability/`) se for filtrar atributos no pipeline.

## Passos

### 1. Política de dados

Liste em `docs/dados-observabilidade.md` campos **proibidos**:

- CPF/CNPJ em claro
- PAN de cartão
- Senha, OTP, token OAuth completo
- Chave PIX de terceiros (conforme política interna)

### 2. Processor em logs (structlog)

```python
import re

def mask_cpf(_, __, event_dict):
    for key in ("cpf", "document", "metadata"):
        if key in event_dict and isinstance(event_dict[key], str):
            event_dict[key] = re.sub(r"\d{11}", "***.***.***-**", event_dict[key])
    return event_dict
```

Configure na cadeia do `structlog`.

### 3. OTel Collector — attributes processor

Arquivo `deploy/observability/collector-config.yaml` (crie a pasta):

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

### 4. Revisão manual

1. Gere um *Pix* de teste.
2. Abra trace no Jaeger — confirme ausência de PII nos atributos.
3. `kubectl logs` — confirme mascaramento.

### 5. Amostragem (opcional)

Documente quando reduzir sampling em produção sem perder traces de erro.

## Deu certo quando

- [ ] Política escrita e revisada.
- [ ] Log de teste com CPF fictício sai mascarado.
- [ ] Trace no Jaeger sem campos proibidos.
- [ ] Checklist §7.8 do plano marcado para este item.

## Próximo passo

Revisar [checklist integrador §7.8](../PLANO_DE_ESTUDO.md#modulo-7) e gravar demo de 10–15 min percorrendo caos → trace limpo → Kyverno → Pact.
