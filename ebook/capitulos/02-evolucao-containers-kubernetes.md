*Contexto histórico — leia antes da [Onda 0 / Lab 00](../../labs/lab-00-kind-banco-minimo.md).*

## Antes do container: o problema do “funciona na minha máquina”

Deploy antigo: instalar pacotes no servidor, ajustar bibliotecas, rezar para homologação ser igual à produção. **Máquina virtual (VM)** isolou melhor — cada app com seu SO — mas cada VM carrega disco e boot inteiros. Escala lenta, custo alto.

**Container** empacota processo + dependências + filesystem em camadas compartilhando o kernel do host. Não é VM miniatura: é **processo isolado** com imagem reproduzível. A analogia útil: **apartamento mobiliado padronizado** no mesmo prédio (kernel), não uma casa nova por app.

## Docker e a popularização (2013 em diante)

A Docker Inc. popularizou a experiência de desenvolvedor: `Dockerfile`, registry, `docker run`. Antes existiam **cgroups** e **namespaces** no Linux; o salto foi **ferramenta e ecossistema**.

Consequência nos bancos: pipeline de CI gera **imagem imutável**; produção não “compila no servidor”. O commit vira artefato auditável — alinhado ao que você faz com `servico-pix` neste repo.

Limites que a indústria aprendeu:

- container sozinho **não** agenda milhares de pods em vários hosts;
- **orquestração** virou necessidade, não luxo.

## De Borg/Mesos ao Kubernetes

Google operava **Borg** internamente há anos. Em 2014–2015 o **Kubernetes** (K8s) saiu como open source com DNA de:

- **declarativo** (“quero 3 réplicas”, o sistema reconcilia);
- **API extensível** (CRDs depois);
- **labels** para agrupar pods sem acoplamento rígido.

**2015:** versão 1.0. **2016:** Kubernetes entra na **CNCF** (*Cloud Native Computing Foundation*). O mercado consolidou K8s sobre alternativas como Apache Mesos para greenfield — não porque Mesos era ruim, mas porque **ecossistema** (Helm, operadores, treinamento) migrou em massa.

## O que o Kubernetes resolve (e o que não resolve)

| Resolve | Não resolve |
|---------|-------------|
| Agendar containers em cluster | Lógica de negócio |
| Service discovery interno | Consistência entre bancos de dados |
| Rolling update de Deployments | Observabilidade completa (só dá gancho) |
| Secrets e ConfigMaps (com ressalvas) | Segredo bem gerenciado sem processo |

No lab, **kind** (*Kubernetes in Docker*) sobe um cluster leve no laptop — o mesmo modelo mental de produção, escala reduzida.

## Objetos que você verá no curso

| Objeto | Papel histórico |
|--------|-----------------|
| **Pod** | Unidade mínima desde o início do K8s |
| **Deployment** | Substitui ReplicaSet “na mão” para rolling update |
| **Service** | Estabiliza IP/DNS quando pods morrem e renascem |
| **Namespace** | Separa ambientes/equipes (`core-banking`, `dados-lab`) |
| **HPA / PDB** | Autoscaling e segurança em manutenção (módulo 5) |
| **Admission** | Porteiro de YAML (Kyverno, módulo 7) |

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 1979 | chroot — isolamento primitivo |
| 2000s | cgroups, namespaces no Linux |
| 2013 | Docker populariza workflow de imagem |
| 2014 | Kubernetes anunciado (Google + comunidade) |
| 2015 | K8s 1.0 |
| 2016 | CNCF; onda “cloud native” |
| 2017+ | Operadores (Prometheus, Strimzi Kafka, etc.) |
| 2020s | Policy-as-code, FinOps, multi-cluster |

## Por que bancos adotaram (e resistiram)

**Adoção:** padronizar deploy, reduzir “servidor pet”, integrar com nuvem híbrida.

**Resistência:** skill gap, legado em VM, custo de cluster mal dimensionado, medo de “abstrair demais” sem observabilidade.

Este livro assume: você **já** vai operar algo tipo K8s; o foco é **defender** o serviço financeiro em cima dele (probes, limits, secrets, políticas).

## Ligação com os módulos

- [Onda 0 / Lab 00](../../labs/lab-00-kind-banco-minimo.md) — primeiro deploy
- [Módulo 5](../../modulos/modulo-05-deploy-gitops.md) — canary, GitOps, HPA
- [Módulo 7](../../modulos/modulo-07-operacao-conformidade.md) — Kyverno, segredos

Próximo: [Lab 00 — banco mínimo no *kind*](../../labs/lab-00-kind-banco-minimo.md). Kafka e observabilidade entram nos capítulos antes dos Módulos 2.
