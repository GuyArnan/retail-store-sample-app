curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | tee /usr/share/keyrings/kubernetes-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
