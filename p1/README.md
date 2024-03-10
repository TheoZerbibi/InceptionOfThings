# Inception of Things - P1

First party of Inception of Things.

K3s and Vagrant.

## Docs
Link of the official Vagrant [docs](https://developer.hashicorp.com/vagrant/docs) and K3s [docs](https://docs.k3s.io/).

## Box destribution

Based on latest Debian version [12.5.0](https://www.debian.org/News/2024/20240210).

Vagrant version name is [boxomatic/debian-12](https://app.vagrantup.com/boxomatic/boxes/debian-12).

## Setup
- Generate SSH key with `ssh-keygen -f .ssh/id_rsa -t rsa -b 4096` with no passphrase.

## Steps

### VM setup
- Enable [X11-Forward](https://goteleport.com/blog/x11-forwarding/) in [config.ssh](https://developer.hashicorp.com/vagrant/docs/vagrantfile/ssh_settings#config-ssh-forward_x11) settings.
- Change [memory and cpus](https://developer.hashicorp.com/vagrant/docs/providers/vmware/configuration) size according to the subject recommendation : `It is STRONGLY advised to allow only the
bare minimum in terms of resources: 1 CPU, 512 MB of RAM (or 1024).`.

### First machine (Server)
-

### Second machine (Worker)
-

