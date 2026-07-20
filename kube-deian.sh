#!/usr/bin/env bash
# Exit on error, undefined variable, or failed pipe

set -euo pipefail

# Optional – expose the containerd socket as an environment variable
export CONTAINERD_SOCKET="unix:///var/run/containerd/containerd.sock"

# Update package index & install prerequisites

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add Kubernetes apt repository signing key

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes apt source

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable --now kubelet
