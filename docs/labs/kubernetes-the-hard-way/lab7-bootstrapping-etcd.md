---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower).
Unlike the original that bases itself on Debian like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux running on x86_64 architecture.

# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/etcd-io/etcd). In this lab you will bootstrap a three node etcd cluster and configure it for high availability and secure remote access.

## Prerequisites

Copy `etcd` binaries and systemd unit files to the `server` instance:

```bash
scp \
  downloads/etcd-v3.4.36-linux-amd64.tar.gz \
  units/etcd.service \
  root@server:~/
```

The commands in the following sections of this lab must be run on the `server` machine. Login to the `server` machine using the `ssh` command. Example:

```bash
ssh root@server
```

## Bootstrapping an etcd Cluster

### Install the etcd Binaries

If you don't already have it installed, first install the `tar` utility using `dnf`. And then extract and install the `etcd` server and the `etcdctl` command line utility:

```bash
  dnf -y install tar
  tar -xvf etcd-v3.4.36-linux-amd64.tar.gz
  mv etcd-v3.4.36-linux-amd64/etcd* /usr/local/bin/
```

### Configure the etcd Server

```bash
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

Create the `etcd.service` systemd unit file:

```bash
mv etcd.service /etc/systemd/system/
chmod 644 /etc/systemd/system/etcd.service
```

!!! Note
  Although considered bad security form, you might have to temporarily or permanently disable SELinux if you run into any issues starting the etcd systemd service. The proper fix is to investigate and create the needed policy files using tools such as ausearch, audit2allow and so on.  
  The commands get SELinux out of the way and disable it is by running the following:
  
  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Start the etcd Server

```bash
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
```

## Verification

List the etcd cluster members:

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

Next: [Bootstrapping the Kubernetes Control Plane](lab8-bootstrapping-kubernetes-controllers.md)
