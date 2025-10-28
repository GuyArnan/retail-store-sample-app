#!/bin/bash
# Reset kubeadm setup on node
sudo kubeadm reset -f

# Remove CNI network interfaces (change "cni0" if different)
sudo ip link delete cni0 || true

# Flush iptables rules
sudo iptables -F
sudo iptables -X

# Restart kubelet service
sudo systemctl restart kubelet

echo "Node reset complete."
