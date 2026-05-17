# Toxiproxy no kind

Manifests do **Módulo 1** (resiliência). Laboratório: [`labs/lab-01-toxiproxy-resiliencia.md`](../../labs/lab-01-toxiproxy-resiliencia.md).

```bash
kubectl apply -f deploy/toxiproxy/deployment.yaml
```

Depois configure o proxy via API (porta **8474**) para encaminhar **8666** → `servico-limites:8000`.
