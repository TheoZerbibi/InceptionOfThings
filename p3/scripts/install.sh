#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p3/scripts/install.sh										#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script will install and configure K3D on 		#
# Vagrant Virtual Machine.											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Install Docker
sudo apt-get update
sudo apt-get install -y \
	ca-certificates \
	curl \
	gnupg \
	lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to docker group
getent group docker || sudo groupadd docker
sudo usermod -aG docker $USER

# # Install KubeCLT
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install K3D
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -o /tmp/
sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd

# Enable ArgoCD UI
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl wait -n argocd --for=condition=available deployment --all --timeout=-1s
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null &

