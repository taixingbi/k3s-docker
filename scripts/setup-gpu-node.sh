#!/usr/bin/env bash
set -euo pipefail

# Run this script on gpu-node-1 (Linux) BEFORE joining the k3s cluster.
# Prerequisites: NVIDIA driver installed (verify with nvidia-smi)

echo "=== NVIDIA Container Toolkit for k3s (containerd) ==="

# Verify NVIDIA driver
if ! command -v nvidia-smi &>/dev/null; then
  echo "Error: nvidia-smi not found. Install NVIDIA drivers first."
  exit 1
fi
nvidia-smi
echo ""

# Add NVIDIA Container Toolkit repository (Ubuntu/Debian)
echo "Adding NVIDIA Container Toolkit repository..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# k3s auto-detects the nvidia runtime when present - no manual containerd config needed

echo ""
echo "=== NVIDIA setup complete ==="
echo "Restart k3s agent after joining: sudo systemctl restart k3s-agent"
echo ""
echo "After joining the cluster, deploy the NVIDIA Device Plugin:"
echo "  kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.13.0/nvidia-device-plugin.yml"
echo ""
echo "GPU pods require runtimeClassName: nvidia in the Pod spec."
