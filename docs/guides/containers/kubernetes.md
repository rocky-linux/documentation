---
title: Kubernetes cluster
author: Antoine Le Morvan, Ezequiel Bruni
contributors: Steven Spencer, Serge Croisé 
tested with: 8.6
tags:
  - podman
  - containers
  - kubernetes
  - k8s
---

# Running a Kubernetes Cluster on Rocky Linux

## Introduction

Kubernetes is an automation platform for deploying, scaling and implementing application containers on server clusters.

A kubernetes cluster can run the containers it controls with different types of containerization technologies like Docker or Containerd. 

Kubernetes:
* is also commonly called "k8s",
* is open source,
* was originally designed by Google and then offered to the CNCF (Cloud Native Computing Foundation),
* facilitates both declarative configuration and automation.

----

Note from Ezequiel: These are the notes for the intro I was working on to introduce a lot of the basic concepts. Is it overkill, maybe?

## Introduction

If you just want to know how to install Kubernetes, skip this introduction, it's gonna be a long one.

See the Introduction to Kubernetes course on EDX for more details. You can access the actual course material for free.

### Microservices vs regular apps

Microservice vs the monolith

Scaling apps and processes individually

Basic example: web servers and database servers

Useful particularly in cloud computing environments, but usable on hardware, VPSs, and more.

### What is Container orchestration

Orchestrators group systems (hosts/computers/servers) together into "clusters"

Orchestrators automate container deployment

Schedule containers to run based on available resources

Enable containers to "talk to" each other easily even when they're on separate machines

Load balancing

Save money on cloud computing

Containers in this system come with usually only *one* pre defined function

### Kubernetes

Automatic resource management

Can be extended with custom code

Self healing

Load balancing

Automated rollouts and rollbacks

Storage orchestration

### Architecture

Control plane node is the "brain"

Worker nodes

----


## Concepts

### Pods

### Labels and selectors

### Services

## Installation

### Preconfiguration

Concerns the master and the nodes.

Proceed with a Rocky 8 minimal installation.

Disable swap (no swap on a kubernetes cluster):

```
sed -i '/swap/d' /etc/fstab
swapoff -a
```

Fill in the /etc/hosts file

```
10.1.1.1 master.k8s.priv master
10.1.1.2 node1.k8s.priv node1
10.1.1.3 node2.k8s.priv node2
```

```
dnf install -y iproute-tc dnf-utils yum-plugin-versionlock
```

```
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

```
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

```
sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system
```

Configure the docker repository (for containerd):

```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

```
dnf install -y containerd.io
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

Edit the new file: 

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

You can activate containerd now:

```
systemctl restart containerd
systemctl enable containerd
```

Configure the kubernetes repository:

```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```

### Master

Open the necessary network ports for the master:

```
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
```

Then install the necessary packages:

```
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
dnf versionlock kubelet kubeadm kubectl
```

Enable kubelet service:

```
systemctl enable kubelet.service
systemctl start kubelet.service
```

You can start pulling the docker images needed for the internal operation of Kubernetes and initialize the kubernetes cluster.

```
kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16
```

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown (id -u):(id−u):(id -g) $HOME/.kube/config
```

We will next install the flannel network system:
```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

```
kubeadm join 10.1.1.1:6443 --token 51ilhj.fzqk90qm7qbt0yuw \
 --discovery-token-ca-cert-hash sha256:f849ae7c10f815ada2809507d9f62e43b1a215e9158ed6a4c779d64429dc926c 
```

### Nodes installation

Open the necessary network ports for the master:

```
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload
```

Then install the necessary packages:

```
yum install -y kubelet kubeadm --disableexcludes=kubernetes
dnf versionlock kubelet kubeadm 
```

Enable kubelet service:

```
systemctl enable kubelet.service
systemctl start kubelet.service
```

### Checks

Check if all system pods are deployed:

```
kubectl get pods --all-namespaces
NAMESPACE      NAME                                                  READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-wq7pm                                 1/1     Running   0          23s
kube-system    coredns-565d847f94-2bzjz                              1/1     Running   0          51s
kube-system    coredns-565d847f94-hxkdr                              1/1     Running   0          51s
kube-system    etcd-master.k8s.priv                                  1/1     Running   0          64s
kube-system    kube-apiserver-master.k8s.priv                        1/1     Running   0          67s
kube-system    kube-controller-manager-master.k8s.priv               1/1     Running   0          64s
kube-system    kube-proxy-2stj4                                      1/1     Running   0          52s
kube-system    kube-scheduler-master.k8s.priv                        1/1     Running   0          66s
```

```
kubectl get nodes
NAME                          STATUS   ROLES           AGE    VERSION
master.k8s.priv   Ready    control-plane   118s   v1.25.0
```

Once the nodes have been joined to the master:

```
[root@master ~]# kubectl get nodes
NAME                          STATUS   ROLES           AGE     VERSION
master.k8s.priv   Ready    control-plane   3m48s   v1.25.0
node1.k8s.priv   Ready    <none>          39s     v1.25.0
node2.k8s.priv   Ready    <none>          28s     v1.25.0
```

```
kubectl get pods --all-namespaces
NAMESPACE      NAME                                                  READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-c2zb9                                 1/1     Running   0          79s
kube-flannel   kube-flannel-ds-wq7pm                                 1/1     Running   0          3m43s
kube-flannel   kube-flannel-ds-x8swr                                 1/1     Running   0          68s
kube-system    coredns-565d847f94-2bzjz                              1/1     Running   0          4m11s
kube-system    coredns-565d847f94-hxkdr                              1/1     Running   0          4m11s
kube-system    etcd-master.k8s.priv                                  1/1     Running   0          4m24s
kube-system    kube-apiserver-master.k8s.priv                        1/1     Running   0          4m27s
kube-system    kube-controller-manager-master.k8s.priv               1/1     Running   0          4m24s
kube-system    kube-proxy-2stj4                                      1/1     Running   0          4m12s
kube-system    kube-proxy-dpjrn                                      1/1     Running   0          79s
kube-system    kube-proxy-qtc6n                                      1/1     Running   0          68s
kube-system    kube-scheduler-master.k8s.priv                        1/1     Running   0          4m26s
```

### Deployment test

```
kubectl create deployment webapp-1 --image nginx --port=80
```

```
kubectl get deployment -o wide
NAME       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES   SELECTOR
webapp-1   1/1     1            1           15s   nginx        nginx    app=webapp-1
```

```
kubectl get pod
NAME                        READY   STATUS    RESTARTS   AGE
webapp-1-76585cb4df-t6wpv   1/1     Running   0          31s
```

```
kubectl scale deployment webapp-1 --replicas=2
```

```
kubectl get deployment -o wide
NAME       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES   SELECTOR
webapp-1   2/2     2            2           47s   nginx        nginx    app=webapp-1
```

```
kubectl get pod
NAME                        READY   STATUS    RESTARTS   AGE
webapp-1-76585cb4df-t6wpv   1/1     Running   0          54s
webapp-1-76585cb4df-w9dtp   1/1     Running   0          11s
```

```
kubectl expose deployment webapp-1 --type=NodePort --name=webapp-1-svc
```

```
kubectl get service/webapp-1-svc
NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
webapp-1-svc   NodePort   10.107.240.72   <none>        80:32210/TCP   118s
```

```
kubectl exec -ti webapp-1-76585cb4df-t6wpv /bin/bash
echo "FRONT 1" > /usr/share/nginx/html/index.html
<CTRL+D>
```

```
kubectl exec -ti webapp-1-76585cb4df-w9dtp /bin/bash
echo "FRONT 2" > /usr/share/nginx/html/index.html
<CTRL+D>
```

```
while true
do curl http://10.1.1.2:32210/
done
FRONT 2
FRONT 1
FRONT 1
FRONT 1
FRONT 1
FRONT 2
FRONT 1
FRONT 1
FRONT 2
FRONT 1
FRONT 1
FRONT 1

<CTRL+C>
```
