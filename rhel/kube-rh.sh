#!/usr/bin/env bash
set -euo pipefail

# 1. Disable Swap (Required for kubelet)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Configure Kernel Modules for Containerd
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 3. Configure Sysctl Networking for Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# 4. Install Containerd Runtime
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io

# 5. Configure Containerd for systemd cgroups
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# 6. Disable SELinux (set to permissive)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# 7. Add Kubernetes YUM repository
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

# 8. Install Kubernetes packages
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# 9. Enable kubelet service
sudo systemctl enable --now kubelet

# 10. Initialise the Kubernetes control-plane
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# 11. Set up kubeconfig for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 12. Deploy Calico network
kubectl apply -f https://projectcalico.org/manifests/calico.yaml

echo "Kubernetes cluster setup complete."