## Segredos: do post-it ao cofre

1. Senha no Git — histórico eterno.  
2. `Secret` K8s em base64 — disfarce, não cofre.  
3. **Vault** / cloud secret manager — auditoria e rotação.  
4. **External Secrets Operator** — sincroniza cofre → cluster.

**Rotação** e **least privilege** (RBAC) são rotina em due diligence de fornecedor.

## Outbox e integridade

**Transactional outbox**: mesma transação grava negócio + evento; **relay** publica no Kafka. Padrão documentado na literatura de microsserviços; evita “gravei o *Pix* mas perdi o evento”.

**DLQ** — mensagens que falharam N vezes saem da fila principal para análise humana.

## Pact e contratos

API de *Limites* muda campo → *Pix* quebra em produção. **Pact** grava expectativa do consumidor; CI do provedor valida. Comum em bancos com dezenas de consumidores da mesma API interna.

## Kyverno e admission

**Admission controller** avalia YAML antes do pod existir. **Kyverno** (2019) — regras legíveis: sem `limits`, sem `:latest`.

Evidência para auditor: `kubectl apply` **negado** com mensagem clara.

## DR: RPO e RTO

Backup sem **restore ensaiado** é plano no papel. Lab 07e cronometra volta do Postgres — linguagem que diretoria entende.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2017 | GitOps |
| 2018 | Argo CD |
| 2019 | Kyverno; External Secrets maduro |
| 2020s | SBOM, supply chain, policy-as-code |
