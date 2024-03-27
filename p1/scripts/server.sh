#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p1/scripts/server.sh										#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script is used for setup the Server Machine.	#
# It will install K3s and configure it for a server machine.		#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo LC_ALL=C >> /etc/environment

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "Arguments are missing"
	exit 1
fi

SSH_TMP_DIR=$1
SERVER_IP=$2
LOWER_HOSTNAME=`echo "$(hostname)" | sed 's/./\L&/g'`
echo "The server IP is: ${SERVER_IP}"
echo "The server hostname is: $(hostname) [$LOWER_HOSTNAME]"

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

# Install curl
apt-get update && apt-get install -y curl

# Install K3s and configure it for a server machine
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init --bind-address=${SERVER_IP} --advertise-address=${SERVER_IP} --node-ip=${SERVER_IP}" K3S_KUBECONFIG_MODE="644" sh -

# Set the KUBECONFIG environment variable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Wait for the node to be ready and label it as a master node with NoSchedule taint
kubectl wait --for=condition=Ready node/${LOWER_HOSTNAME} --timeout=5m
kubectl label node ${LOWER_HOSTNAME} node-role.kubernetes.io/master=true
kubectl taint --overwrite node ${LOWER_HOSTNAME} node-role.kubernetes.io/master=true:NoSchedule
