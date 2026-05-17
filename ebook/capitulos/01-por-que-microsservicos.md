## De um programa só a muitas salas

Até os anos 2000, a maior parte dos sistemas corporativos era um **monólito**: um deploy, um banco, uma equipe que conhecia “o sistema”. Funcionava bem enquanto o time cabia numa sala e o banco aguentava o volume. O problema não era a arquitetura em si — era o **teto** quando crescimento, regulatório e velocidade de mudança passaram a exigir escala organizacional e técnica ao mesmo tempo.

**SOA** (*Service-Oriented Architecture*), popular na década de 2000, já quebrava o monólito em **serviços** com contratos (muitas vezes SOAP e barramento ESB). A ideia era reutilizar capacidades entre áreas. Na prática, muitos bancos herdaram **ESBs pesados** — um “monólito distribuído” com fila central, XSD enorme e deploy que levava meses. O ganho de reuso vinha com **acoplamento no barramento** e filas opacas.

**Microsserviços**, como discurso consolidado após ~2014 (Netflix, Amazon, artigos de Martin Fowler e Sam Newman), empurram outra combinação:

- serviços **pequenos o suficiente** para um time dono;
- deploy **independente**;
- dados **por serviço** (sem banco compartilhado como atalho);
- falha **isolada** por fronteira de processo.

Não é “dividir o código em pedaços”. É dividir **responsabilidade operacional**: quem deploya, quem acorda de madrugada, quem paga a conta do Kafka.

## O que mudou no setor financeiro

Bancos digitais e fintechs competem em **tempo de lançamento** e **disponibilidade**. Um incidente no *Pix* não é bug de tela — é manchete. Isso explica por que plataforma virou produto:

| Pressão | Resposta arquitetural |
|---------|------------------------|
| Picos (salário, Black Friday) | Escala horizontal por serviço |
| Regulatório e auditoria | Rastreio, segregação, política no cluster |
| Integração com parceiros | APIs e eventos padronizados |
| Múltiplos canais (app, internet, API) | Mesmo núcleo, fronteiras claras |

O cenário deste livro — *Pix*, *Limites*, *Crédito* — é fictício, porém típico de bancos digitais: **caminho síncrono** (aprovar na hora) e **caminho assíncrono** (notificar, antifraude, analytics) desacoplados por fila.

## CAP, PACELC e dinheiro

Fundamentos do [Módulo 0](../../modulos/modulo-00-fundamentos-distribuidos.md) não são exercício acadêmico. Em pagamentos, **consistência** e **disponibilidade** são negociadas o tempo todo:

- travar o balcão até alinhar saldo (**CP**);
- responder “tente de novo” e corrigir depois (**AP**);
- no dia a dia, escolher entre resposta rápida e leitura perfeitamente alinhada (**PACELC**).

Quem vende “microsserviço resolve tudo” esconde que **você troca complexidade de código por complexidade de operação**. Este curso assume essa troca e ensina a operar.

## Anti-padrões que a história repetiu

| Moda | O que deu errado |
|------|------------------|
| Micro por religião | 40 serviços para 3 desenvolvedores |
| ESB como Deus | Fila única, contrato rígido, deploy lento |
| “Eventual” sem desenho | Saldo que nunca converge |
| Shared database | Monólito disfarçado |
| Kubernetes sem observabilidade | Caixa preta em produção |

## Linha do tempo resumida

| Período | Marco |
|---------|--------|
| Anos 1990–2000 | Cliente-servidor, primeiros clusters |
| 2000s | SOA, ESB, XML |
| ~2010 | REST generalizado; NoSQL; início de “big data” |
| 2011–2014 | Kafka (LinkedIn); containers Docker; Netflix OSS |
| 2015–2017 | Kubernetes 1.0; Istio anunciado; onda de mesh |
| 2019+ | OpenTelemetry; GitOps maduro; IDP (Backstage, etc.) |
| 2020s | Regulatório de dados (LGPD); supply chain; política como código |

## O que você leva daqui para o lab

Microsserviço **não é** obrigatório para todo problema. Este repositório usa três serviços para **ensinar plataforma** — rede, fila, mesh, observabilidade — não para provar que todo banco deve ter cinquenta APIs.
