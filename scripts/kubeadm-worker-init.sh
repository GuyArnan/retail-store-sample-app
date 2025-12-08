#!/usr/bin/env bash
set -euo pipefail

JOIN_CMD="kubeadm join k8s-control.example.com:6443 \
  --token <your-token> \
  --discovery-token-ca-cert-hash sha256:<your-ca-hash>"

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

echo "[3] Install kubeadm, kubelet (if not installed)"
# Follow your distro’s official instructions if this block is not desired.

echo "[4] Join node to cluster"
sudo ${JOIN_CMD}
