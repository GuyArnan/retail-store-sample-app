apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release
apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
