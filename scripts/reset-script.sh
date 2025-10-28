#!/bin/bash

# Step 1: Run kubeadm reset (no prompt, force, specify CRI socket if containerd is used)
kubeadm reset -f --cri-socket unix:///run/containerd/containerd.sock

# Step 2: Remove CNI config files
rm -rf /etc/cni/net.d

# Step 3: Remove kube configs and state directories
rm -rf $HOME/.kube/
rm -rf /etc/kubernetes/
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet
rm -rf /var/lib/cni/
rm -rf /var/run/kubernetes/

# Step 4: Clean iptables rules (use with caution)
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Step 5: (Optional) Clear IPVS tables
ipvsadm --clear

# Step 6: Restart containerd and kubelet to clear runtime state
systemctl restart containerd
systemctl restart kubelet

echo "Kubernetes node fully reset and ready for new cluster initialization."
