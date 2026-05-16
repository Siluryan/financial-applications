# Kubernetes (Kustomize)

Manifests alinhados à **Onda 0** da espinha dorsal do [`PLANO_DE_ESTUDO.md`](../../PLANO_DE_ESTUDO.md#ondas-principio) (*serviços* no namespace `core-banking`).

Aplicar no cluster **após** carregar as imagens `*:lab` no kind (veja `scripts/build-load-kind.sh` e o [`README.md`](../../README.md) na raiz).

```bash
kubectl apply -k .
```

Namespace: `core-banking`. Serviços expõem porta **8000**.

Para inspecionar o manifesto renderizado:

```bash
kubectl kustomize .
```
