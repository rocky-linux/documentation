---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
  - kubectl
  - etcd
  - runc
---

# Lab 8: Bootstrapping the Kubernetes Control Plane

> This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower). Unlike the original, which bases itself on Debian-like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux, which runs on x86_64 architecture.

In this lab, you will bootstrap the Kubernetes control plane. You will install the following components on the controller machine: Kubernetes API Server, Scheduler, and Controller Manager.

## Prerequisites

Connect to the `jumpbox` and copy Kubernetes binaries and `systemd` unit files to the `server` instance:

```bash
scp \
  downloads/kube-apiserver \
  downloads/kube-controller-manager \
  downloads/kube-scheduler \
  downloads/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  root@server:~/
```

You must run the commands in the following sections of this lab on the `server` machine. Login to the controller instance with the `ssh` command. Example:

```bash
ssh root@server
```

## Provision the Kubernetes Control Plane

Create the Kubernetes configuration directory:

```bash
mkdir -p /etc/kubernetes/config
```

### Install the Kubernetes Controller Binaries

Install the Kubernetes binaries:

```bash
  chmod +x kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl
    
  mv kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
```

### Configure the Kubernetes API Server

```bash
  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/
```

Create the `kube-apiserver.service` `systemd` unit file:

```bash
mv kube-apiserver.service /etc/systemd/system/kube-apiserver.service
```

### Configure the Kubernetes Controller Manager

Move the `kube-controller-manager` kubeconfig into place:

```bash
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Create the `kube-controller-manager.service` `systemd` unit file:

```bash
mv kube-controller-manager.service /etc/systemd/system/
```

### Configure the Kubernetes Scheduler

Move the `kube-scheduler` kubeconfig into place:

```bash
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Create the `kube-scheduler.yaml` configuration file:

```bash
mv kube-scheduler.yaml /etc/kubernetes/config/
```

Create the `kube-scheduler.service` systemd unit file:

```bash
mv kube-scheduler.service /etc/systemd/system/
```

### Start the Controller Services

```bash
  systemctl daemon-reload
  
  systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler
    
  systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
```

> Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

### Verification

```bash
kubectl cluster-info   --kubeconfig admin.kubeconfig
```

```text
Kubernetes control plane is running at https://127.0.0.1:6443
```

## RBAC for Kubelet Authorization

In this section, you will configure RBAC permissions to allow the Kubernetes API Server to access the Kubelet API on each worker node. Access to the Kubelet API is required to retrieve metrics and logs and execute commands in pods.

> This tutorial sets the Kubelet `--authorization-mode` flag to `Webhook`. `Webhook` mode uses the [SubjectAccessReview](https://kubernetes.io/docs/admin/authorization/#checking-api-access) API to determine authorization.

Run the commands in this section on the controller node, affecting the entire cluster.

```bash
ssh root@server
```

Create the `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/admin/authorization/rbac/#role-and-clusterrole) with permissions to access the Kubelet API and perform the most common tasks associated with managing pods:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### RBAC Verification

At this point, the Kubernetes control plane is up and running. Run the following commands from the `jumpbox` machine to verify it is working:

Make an HTTP request for the Kubernetes version info:

```bash
curl -k --cacert ca.crt https://server.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.0",
  "gitCommit": "70d3cc986aa8221cd1dfb1121852688902d3bf53",
  "gitTreeState": "clean",
  "buildDate": "2024-12-11T17:59:15Z",
  "goVersion": "go1.23.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Next: [Bootstrapping the Kubernetes Worker Nodes](lab9-bootstrapping-kubernetes-workers.md)
