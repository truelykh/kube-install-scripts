#!/usr/bin/env bash
set -euo pipefail

# Disable SELinux (set to permissive)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add Kubernetes YUM repository (overwrite any existing file)
sudo mkdir -p /etc/yum.repos.d
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install Kubernetes packages
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start kubelet service
sudo systemctl enable --now kubelet

# Initialise the Kubernetes control‑plane (run once)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cluster-name dev

# Set up kubeconfig for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico network
kubectl apply -f https://projectcalico.org/manifests/calico.yaml

echo "Kubernetes cluster setup complete."