# Istio — exemplos para o lab

Arquivos de referência para [`labs/lab-03-istio-mtls.md`](../../labs/lab-03-istio-mtls.md). Instale o Istio no cluster antes de aplicar:

```bash
istioctl install -y --set profile=default
kubectl label namespace core-banking istio-injection=enabled --overwrite
kubectl apply -f deploy/istio/
```
