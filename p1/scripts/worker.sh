#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p1/scripts/worker.sh										#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script is used for setup the Worker Machine.	#
# It will install K3s and configure it for a working machine.		#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo LC_ALL=C >> /etc/environment

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
	echo "Arguments are missing"
	exit 1
fi

SSH_TMP_DIR=$1
WORKER_IP=$2
SERVER_IP=$3
SERVER_HOSTNAME=$4
LOWER_HOSTNAME=`echo "$(hostname)" | sed 's/./\L&/g'`

echo "The worker IP is: ${WORKER_IP}"
echo "The server IP is: ${SERVER_IP}"
echo "The server hostname is: ${SERVER_HOSTNAME}"
echo "The worker hostname is: $(hostname) [$LOWER_HOSTNAME]"

if [ ! -d ${SSH_TMP_DIR} ] || [ -z "$(ls -A $SSH_TMP_DIR)" ]; then
	echo "The path provided is not a directory or is empty"
	exit 1
fi

# Setup SSH Key to allow each machine to communicate with each other
mv ${SSH_TMP_DIR}/id_rsa* /root/.ssh/
chmod 400 /root/.ssh/id_rsa*
chown root:root /root/.ssh/id_rsa*

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 400 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys

# Add current node to the /etc/hosts file
echo "127.0.1.1  $(hostname)" >> /etc/hosts
echo "${SERVER_IP} ${SERVER_HOSTNAME}" >> /etc/hosts

# Install curl
apt-get update && apt-get install -y curl

# Install K3s and configure it for a worker machine
scp -o StrictHostKeyChecking=no root@${SERVER_HOSTNAME}:/var/lib/rancher/k3s/server/token /tmp/token
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://${SERVER_HOSTNAME}:6443 --token-file /tmp/token --node-ip=${WORKER_IP}" sh -

# Get the K3s configuration file from master node
mkdir -p /etc/rancher/k3s/
scp -o StrictHostKeyChecking=no root@${SERVER_HOSTNAME}:/etc/rancher/k3s/k3s.yaml /etc/rancher/k3s/k3s.yaml
chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


# label the node as worker
kubectl label node ${LOWER_HOSTNAME} kubernetes.io/role=worker
