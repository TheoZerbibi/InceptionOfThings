# Inception of Things - P1

First party of Inception of Things.

K3s and Vagrant.

## Docs
Link of the official Vagrant [docs](https://developer.hashicorp.com/vagrant/docs) and K3s [docs](https://docs.k3s.io/).

## Box destribution

Based on latest Debian version [12.5.0](https://www.debian.org/News/2024/20240210).

Vagrant box version name is [generic/debian12](https://app.vagrantup.com/generic/boxes/debian12).

## Setup
- Generate SSH key with `ssh-keygen -f .ssh/id_rsa -t rsa -b 4096` with no passphrase.

## Steps

### VM setup
- Enable [X11-Forward](https://goteleport.com/blog/x11-forwarding/) in [config.ssh](https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings#config-ssh-forward_x11) settings.
- Change [memory and cpus](https://developer.hashicorp.com/vagrant/docs/providers/vmware/configuration) size according to the subject recommendation : `It is STRONGLY advised to allow only the
bare minimum in terms of resources: 1 CPU, 512 MB of RAM (or 1024).`.

### First machine (Server)
- Define hostname and IP address in [Vagrantfile](https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings#config-vm-network).
- Copy SSH key inside the VM with [`config.vm.provision "file"`](https://developer.hashicorp.com/vagrant/docs/provisioning/file).
- Setup script provision in root mode with [`config.vm.provision "shell"`](https://developer.hashicorp.com/vagrant/docs/provisioning/shell).
- In `server.sh` script :
  - Check script arguments :
    - `$1`*(Folder contain ssh key)*.
    - `$2`*(IP address)*.
  - Copy SSH key in root folder and change permissions.
  - Put hostname and IP address in `/etc/hosts` file.
  - Install K3s with `curl -sfL https://get.k3s.io | sh -`.
  -  Label the master node with `kubectl label` [command](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).
  - Apply a [taint](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) to the node to prevent pods from being scheduled on it.
### Second machine (Worker)
- Define hostname and IP address in [Vagrantfile](https://developer.hashicorp.com/vagrant/docs/vagrantfile/machine_settings#config-vm-network).
- Copy SSH key inside the VM with [`config.vm.provision "file"`](https://developer.hashicorp.com/vagrant/docs/provisioning/file).
- Setup script provision in root mode with [`config.vm.provision "shell"`](https://developer.hashicorp.com/vagrant/docs/provisioning/shell).
- In `worker.sh` script :
  - Check script arguments :
    - `$1`*(Folder contain ssh key)*.
    - `$2`*(IP address)*.
    - `$3`*(Server Master IP address)*.
    - `$4`*(Server Master Hostname)*.
  - Copy SSH key in root folder and change permissions.
  - Put hostname and IP address in `/etc/hosts` file.
  - Put server master hostname and IP address in `/etc/hosts` file.
  - Get K3s [token](https://docs.k3s.io/cli/token) from server master with `scp` [command](https://man7.org/linux/man-pages/man1/scp.1.html).
  - Get K3s master [configuration file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) with `scp` [command](https://man7.org/linux/man-pages/man1/scp.1.html) and change permission.
  - Set `KUBECONFIG` environment variable to the path of the configuration file.
  -  Label the worker node with `kubectl label` [command](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).

## Utils

- `kubectl get all --all-namespaces`
- `kubectl describe pod <podname> -n kube-system`

