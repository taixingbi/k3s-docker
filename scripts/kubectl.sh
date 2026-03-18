#!/usr/bin/env bash
# Run kubectl with the k3s cluster kubeconfig.
# Usage: ./scripts/kubectl.sh get nodes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBECONFIG="${SCRIPT_DIR}/../output/kubeconfig.yaml"

if [[ ! -f "$KUBECONFIG" ]]; then
  echo "Error: kubeconfig not found at $KUBECONFIG"
  echo "Start the k3s server first: ./scripts/start-server.sh"
  exit 1
fi

exec env KUBECONFIG="$KUBECONFIG" kubectl "$@"
