# Inception of Things - P2

First party of Inception of Things.

K3s and Pods.

## Docs
Link of the official Vagrant [docs](https://developer.hashicorp.com/vagrant/docs) and K3s [docs](https://docs.k3s.io/).

## Box destribution

Based on latest Debian version [12.5.0](https://www.debian.org/News/2024/20240210).

Vagrant box version name is [generic/debian12](https://app.vagrantup.com/generic/boxes/debian12).

## Steps

### VM setup
- Enable [X11-Forward](https://goteleport.com/blog/x11-forwarding/) in [config.ssh](https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings#config-ssh-forward_x11) settings.
- Change [memory and cpus](https://developer.hashicorp.com/vagrant/docs/providers/vmware/configuration) size according to the subject recommendation : `It is STRONGLY advised to allow only the
bare minimum in terms of resources: 1 CPU, 512 MB of RAM (or 1024).`.

### Machine Setup
- Define hostname and IP address in [Vagrantfile](https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings#config-vm-network).
- Copy the K8s app [Manifests](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) in the [VM](https://developer.hashicorp.com/vagrant/docs/vagrantfile/provisioning#inline).
- Setup script provision in root mode with [`config.vm.provision "shell"`](https://developer.hashicorp.com/vagrant/docs/provisioning/shell).
- In `server.sh` script :
  - Check script arguments :
	- `$1`*(Folder contain the manifests)*.
	- `$2`*(IP address)*.
  - Install K3s with `curl -sfL https://get.k3s.io | sh -`.
  - Apply the manifests with `kubectl apply` [command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply).
  - Wait for the pods to be ready with `kubectl wait` [command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait).

## Manifest

### App-one
  - Create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) with image `paulbouwer/hello-kubernetes:1`.
  - Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).
  
### App-Two
  - Create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) with image `paulbouwer/hello-kubernetes:1` with 3 [replicaSet](https://kubernetes.io/fr/docs/concepts/workloads/controllers/replicaset/).
  - Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

### App-three
  - Create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) with image `paulbouwer/hello-kubernetes:1`.
  - Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

### Ingress
  - Create an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) with 3 [rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource):
	- `app1.com` -> `app-one` Service.
	- `app2.com` -> `app-two` Service.
	- `app3.com` -> `app-three` Service.
  - See [utils](#utils) for testing.

## Issues
Sometime the pods are not ready after the `kubectl wait` command. You need to wait a little bit before testing the services.
  
## Utils

- `curl -H "Host:app2.com" 192.168.56.110`
