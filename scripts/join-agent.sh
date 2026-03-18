#!/usr/bin/env bash
set -euo pipefail

# Run this script ON gpu-node-1 (Linux), not on the Mac Mini.
# Usage: ./join-agent.sh <SERVER_IP> <TOKEN> [GPU_NODE_IP]

SERVER_IP="${1:?Usage: $0 <SERVER_IP> <TOKEN> [GPU_NODE_IP]}"
TOKEN="${2:?Usage: $0 <SERVER_IP> <TOKEN> [GPU_NODE_IP]}"
GPU_NODE_IP="${3:-}"

K3S_URL="https://${SERVER_IP}:6443"

echo "Joining k3s cluster..."
echo "  Server: $K3S_URL"
echo "  Node name: gpu-node-1"
echo ""

export K3S_URL
export K3S_TOKEN="$TOKEN"

INSTALL_ARGS="agent --node-name gpu-node-1"
if [[ -n "$GPU_NODE_IP" ]]; then
  INSTALL_ARGS="$INSTALL_ARGS --node-external-ip $GPU_NODE_IP"
fi

curl -sfL https://get.k3s.io | sh -s - $INSTALL_ARGS

echo ""
echo "Agent joined successfully. Verify with (from Mac Mini):"
echo "  kubectl get nodes"
echo "  kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu"
