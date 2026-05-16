# Toxiproxy no kind

Manifests da **Onda 1**. Laboratório completo: [`labs/lab-01-toxiproxy-resiliencia.md`](../../labs/lab-01-toxiproxy-resiliencia.md).

```bash
kubectl apply -f deploy/toxiproxy/deployment.yaml
```

Depois configure o proxy via API (porta **8474**) para encaminhar **8666** → `servico-limites:8000`.
