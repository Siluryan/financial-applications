# Lab 07c — Testes de contrato (Pact)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.3](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Garantir que alterações na API de *Limites* não quebram o *Pix* sem deploy integrado, usando **Pact**: o consumidor define expectativas; o provedor verifica-as no CI.

Integração só em ambiente partilhado descobre incompatibilidades tarde. Contrato versionado é o acordo formal: URL, status HTTP, forma do JSON. O *Pix* é **consumidor**; *Limites* é **provedor**.

**Tempo estimado:** 60–90 min.

## Antes de começar

### Conhecimento (este lab)

- Contrato HTTP consumidor/provedor ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — conhecer `GET /v1/limits/{account_id}` manualmente.

### Ambiente

- Python 3.11+, `pip install pact-python pytest`.
- Cluster **não** obrigatório para testes locais.

## Passos

### 1. Instalar pact-python

```bash
cd apps/servico-pix
pip install pact-python pytest
```

### 2. Teste do consumidor

Crie `apps/servico-pix/tests/contract/test_limites_consumer.py`:

```python
import pytest
from pact import Consumer, Provider

pact = Consumer("servico-pix").has_pact_with(Provider("servico-limites"))

@pytest.mark.contract
def test_get_limits():
    (pact
     .given("conta acc_demo existe")
     .upon_receiving("consulta de limites")
     .with_request("GET", "/v1/limits/acc_demo")
     .will_respond_with(200, body={
         "account_id": "acc_demo",
         "daily_remaining": 5000.0,
         "currency": "BRL",
     }))
    with pact:
        # Reutilize _fetch_limits_sync ou cliente fino com base_url = MOCK_URL do pact
        ...
```

Execute `pytest -m contract` e gere o ficheiro pact em `tests/contract/pacts/`.

**Importante:** não duplique path/URL no handler do *Pix* — reutilize a função de `resilience.py` apontando para o mock do Pact.

### 3. Verificação do provedor

Suba *Limites* (Compose ou local) e execute provider verification contra o JSON gerado (`pact-verifier` conforme versão da biblioteca).

### 4. CI com GitHub Actions

```yaml
jobs:
  contract:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install -r apps/servico-pix/requirements.txt pact-python pytest
      - run: pytest apps/servico-pix/tests/contract -m contract
      - run: # subir limites e pact verify provider
```

### 5. Quebra intencional

Altere o JSON de *Limites* (remova `currency`) sem actualizar o contrato — o build deve **falhar**. Restaure e confirme verde.

Documente política de equipa: “mudança de API = actualizar Pact antes do merge”.

## Deu certo quando

- [ ] Contrato em `apps/servico-pix/tests/contract/pacts/`.
- [ ] CI (ou comando local) falha quando provedor quebra campo obrigatório.
- [ ] Política escrita no README ou `docs/`.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| Mock URL errada | Variável `PACT_MOCK_HOST` / porta do pact |
| Provider verify skipped | *Limites* não está a escutar na porta esperada |

## Próximo passo

[Lab 07d — Kyverno](lab-07d-kyverno-admission.md)
