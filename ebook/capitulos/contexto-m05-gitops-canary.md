## Deploy que não pode derrubar o *Pix*

Bancos migraram de “janela de madrugada” para **deploy contínuo** — mas pagamento exige **exposição gradual**. Daí **canary**, **blue-green** e **feature flags**.

## GitOps

Antes: `kubectl edit` em produção. **Drift** invisível até o incidente.

**GitOps** (~2017): Git é a planta; operador reconcilia. **Argo CD** (2018) e **Flux** popularizaram diff e rollback por commit.

| Benefício | No lab |
|-----------|--------|
| Auditoria | Histórico no Git |
| Rollback | Revert + apply |
| Homolog ≈ prod | Mesmos manifests com overlay |

## Canary e mirror no Istio

**Canary** — 1 % do tráfego em `servico-credito` v2 antes de promover. **Mirror** — cópia assíncrona sem mudar resposta ao cliente (cuidado se v2 escreve no banco).

Critério de promoção: **métrica**, não feeling (erro &lt; 0,1 % por 30 min).

## Kubernetes além do básico

Objetos que o Módulo 5 aprofunda: **HPA**, **PDB**, probes, **requests/limits** — evitar que um pod coma o nó e derrube vizinhos.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2015 | K8s 1.0; Deployments |
| 2017 | GitOps; Istio traffic split |
| 2018 | Argo CD |
| 2020s | Progressive delivery + SLO |
