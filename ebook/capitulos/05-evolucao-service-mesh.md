*Contexto histórico — leia antes do [Módulo 3](../../modulos/modulo-03-service-mesh.md).*

## Segurança de rede antes do mesh

Tradicionalmente, bancos usavam **firewall**, VLAN, **mTLS pontual** entre alguns pares, certificados renovados na mão. Funcionava com dezenas de servidores; com **centenas de pods** que nascem e morrem por dia, o modelo quebra.

Cada squad escolhendo biblioteca TLS diferente vira **auditoria impossível** e incidente de certificado expirado.

## Do load balancer ao sidecar

**NGINX** e **HAProxy** ficaram na borda (north-south). Tráfego **leste-oeste** (serviço a serviço) cresceu com microsserviços — o atacante ou o bug também circula por dentro.

**Envoy** (Lyft, open source ~2016) popularizou proxy de alta performance com:

- observabilidade rica (métricas por rota);
- configuração dinâmica (xDS);
- extensibilidade (filtros).

**Linkerd** (2016) foi um dos primeiros meshes “amigáveis”. **Istio** (anúncio 2017, Google/IBM/Lyft) apostou em **Envoy como sidecar** + control plane separado (**Istiod**).

## O que é um service mesh

Malha de **proxies** ao lado de cada workload (sidecar) + **control plane** que distribui políticas e certificados.

| Camada | No Istio |
|--------|----------|
| **Data plane** | Envoy no sidecar |
| **Control plane** | Istiod (antes Pilot + Mixer + Citadel — simplificados ao longo dos anos) |

A aplicação continua chamando `http://servico-limites:8000`; o proxy intercepta, criptografa, mede, aplica regra.

## mTLS como identidade, não como magia

**mTLS** (*mutual TLS*) faz cliente e servidor apresentarem certificado. No mesh, certificados de **vida curta** ligados à identidade do pod (**SPIFFE**).

Isso responde: “quem é este processo?” — **não** “este usuário pode pagar?”. Regra de negócio continua no código; mesh cuida da **porta**.

Modos Istio que você pratica no [Lab 03](../../labs/lab-03-istio-mtls.md):

- **PERMISSIVE** — migração (aceita plaintext e mTLS);
- **STRICT** — só mTLS entre workloads do mesh.

## Políticas e roteamento

Além de criptografia, mesh trouxe **AuthorizationPolicy**, **VirtualService**, **DestinationRule** — canary e mirror no [Módulo 5](../../modulos/modulo-05-deploy-gitops.md) sem recompilar o *Pix*.

Histórico: versões antigas do Istio tinham **Mixer** (telemetria e policy externa); a comunidade simplificou para reduzir latência e complexidade. Lições: mesh **não é grátis** — CPU, memória, curva de troubleshooting.

## Mesh em bancos: adoção e ceticismo

**Por que adotam**

- mTLS uniforme leste-oeste;
- política centralizada;
- observabilidade de tráfego L7.

**Por que hesitam**

- overhead de sidecar (~50–100 MiB por pod, ordem de grandeza);
- debug difícil (“quem fechou a conexão?”);
- alternativas: **mTLS no app**, **Cilium** (eBPF), service mesh **sem sidecar** (ambiente evolui).

Regra prática deste curso: mesh faz sentido com **muitos serviços** e time de plataforma; para três serviços no *kind*, é **laboratório de competência**, não obrigação universal.

## Linha do tempo

| Ano | Marco |
|-----|--------|
| 2016 | Envoy (Lyft); Linkerd 1.0 |
| 2017 | Istio anunciado |
| 2018–2019 | Adoção enterprise; críticas de complexidade |
| 2020+ | Istio simplifica; ambient mesh, eBPF |
| 2020s | CNCF Incubation/Graduation; competição (Linkerd, Cilium Service Mesh) |

## Ligação com o livro

- [Módulo 3](../../modulos/modulo-03-service-mesh.md)
- [Lab 03](../../labs/lab-03-istio-mtls.md)
- [Módulo 5](../../modulos/modulo-05-deploy-gitops.md) — canary no Istio

Próximo: [Módulo 3](../../modulos/modulo-03-service-mesh.md) · [Lab 03](../../labs/lab-03-istio-mtls.md).
