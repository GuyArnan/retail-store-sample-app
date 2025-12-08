#!/usr/bin/env bash
set -euo pipefail

POD_CIDR="10.244.0.0/16"
CP_ENDPOINT="k8s-control.example.com:6443"
K8S_VERSION="stable-1"   # or v1.30.0 etc.

echo "[1] Disable swap"
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/' /etc/fstab

echo "[2] Enable needed kernel modules"
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo "[3] Install kubeadm, kubelet, kubectl (if not installed)"
# Follow your distro’s official instructions if this block is not desired.

echo "[4] kubeadm init"
sudo kubeadm init \
  --control-plane-endpoint "${CP_ENDPOINT}" \
  --pod-network-cidr "${POD_CIDR}" \
  --kubernetes-version "${K8S_VERSION}" \
  --cri-socket "unix:///run/containerd/containerd.sock"

echo "[5] Set up kubeconfig for current user"
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "[6] Install CNI (example: Flannel, adjust as needed)"
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "[7] Show join command"
kubeadm token create --print-join-command
