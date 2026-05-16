#!/usr/bin/env bash
# Constrói as três imagens e carrega no nó do kind (tags :lab).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"

build_one() {
  local name="$1"
  docker build -t "${name}:lab" -f "${ROOT}/apps/${name}/Dockerfile" "${ROOT}/apps/${name}/"
  kind load docker-image "${name}:lab" --name "${CLUSTER_NAME}"
}

build_one servico-limites
build_one servico-pix
build_one servico-credito
build_one worker-outbox-relay

echo "Imagens carregadas no cluster '${CLUSTER_NAME}'. Aplique com: kubectl apply -k ${ROOT}/deploy/k8s"
