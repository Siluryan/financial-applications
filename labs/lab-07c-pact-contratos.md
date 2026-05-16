# Lab 07c — Testes de contrato (Pact)

[← Índice dos labs](README.md) · **Módulo 7** · [`PLANO` §7.3](../PLANO_DE_ESTUDO.md#modulo-7)

## Objetivo

Garantir que mudanças em *Limites* não quebram o *Pix* com **Pact** no CI.

O *Pix* é **consumidor** (quem chama a API); *Limites* é **provedor**. O teste do consumidor grava um arquivo “combinado” com URL, status e corpo esperados. No pipeline do provedor, o Pact sobe um mock e verifica se a implementação real ainda honra o combinado — como ensaiar a peça de teatro antes da estreia, sem montar o teatro inteiro.

## Antes de começar

### Conhecimento (este lab)

- *Pix* = **consumidor** da API de *Limites*; contrato descreve JSON esperado ([Módulo 7](../modulos/modulo-07-operacao-conformidade.md)).

### Labs anteriores

- [Lab 00](lab-00-kind-banco-minimo.md) — serviços sobem (teste manual da API).

### Ambiente

- **Python 3.11+**, `pip install pact-python pytest`.
- Não exige cluster no ar para rodar teste de contrato no CI/local.

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
        # chame seu cliente httpx contra MOCK_URL do pact
        ...
```

Gere o pact file (`pact.io write` conforme versão da lib).

### 3. Verificação do provedor

No repositório ou job CI, suba *Limites* e rode provider verification contra o JSON gerado.

### 4. CI (GitHub Actions esboço)

```yaml
# .github/workflows/contract.yml
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

Altere o JSON de resposta de *Limites* sem atualizar o contrato — build deve falhar.

## Deu certo quando

- [ ] Contrato versionado em `apps/servico-pix/tests/contract/pacts/`.
- [ ] CI falha quando provedor quebra campo obrigatório.
- [ ] Time documenta política: “mudança de API = atualizar Pact primeiro”.

## Próximo passo

[Lab 07d — Kyverno](lab-07d-kyverno-admission.md)
