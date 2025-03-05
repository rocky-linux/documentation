---
author: Wale Soyinka 
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Lab 2: Set Up The Jumpbox

In this lab you will set up one of the four machines to be a `jumpbox`. You will use this machine to run commands in this tutorial. While the use of a dedicated machine is to ensure consistency, you can run these commands from just about any machine, including your personal workstation running macOS or Linux.

Think of the `jumpbox` as the administration machine that you will use as a home base when setting up your Kubernetes cluster from the ground up. One thing you need to do before you get started is to install a few command line utilities and clone the Kubernetes The Hard Way git repository, which contains some additional configuration files that you will use to configure various Kubernetes components throughout this tutorial.

Log in to the `jumpbox`:

```bash
ssh root@jumpbox
```

You will run all commands as the `root` user, for the sake of convenience, and it will help reduce the number of commands required to set everything up.

## Install Command Line Utilities

Once logged into the `jumpbox` machine as the `root` user, you will install the command line utilities that you will use to preform various tasks throughout the tutorial:

```bash
sudo dnf -y install wget curl vim openssl git
```

## Sync GitHub Repository

Now it is time to download a copy of this tutorial which contains the configuration files and templates that you will use to build your Kubernetes cluster from the ground up. Clone the Kubernetes The Hard Way git repository using the `git` command:

```bash
git clone --depth 1 \
  https://github.com/wsoyinka/kubernetes-the-hard-way.git
```

Change into the `kubernetes-the-hard-way` directory:

```bash
cd kubernetes-the-hard-way
```

This will be the working directory for the rest of the tutorial. If you ever get lost run the `pwd` command to verify you are in the right directory when running commands on the `jumpbox`:

```bash
pwd
```

```text
/root/kubernetes-the-hard-way
```

## Download Binaries

Here you will download the binaries for the various Kubernetes components. Store these binaries in the `Downloads` directory on the `jumpbox`. This will reduce the amount of internet bandwidth required to complete this tutorial as you avoid downloading the binaries many times for each machine in our Kubernetes cluster.

The `download.txt` file lists the binaries you will download, which you can review using the `cat` command:

```bash
cat downloads.txt
```

Download the binaries listed in the `downloads.txt` file into a directory called `downloads` using the `wget` command:

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads.txt
```

Depending on your internet connection speed it might take a while to download the `584` megabytes of binaries. Once the download is complete, you can list them using the `ls` command:

```bash
ls -loh downloads
```

```text
total 557M
-rw-r--r--. 1 root 51M Jan  6 11:13 cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r--. 1 root 36M Feb 28 14:09 containerd-2.0.3-linux-amd64.tar.gz
-rw-r--r--. 1 root 19M Dec  9 04:16 crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r--. 1 root 17M Feb 25 14:19 etcd-v3.4.36-linux-amd64.tar.gz
-rw-r--r--. 1 root 89M Dec 11 16:12 kube-apiserver
-rw-r--r--. 1 root 82M Dec 11 16:12 kube-controller-manager
-rw-r--r--. 1 root 55M Dec 11 16:12 kubectl
-rw-r--r--. 1 root 74M Dec 11 16:12 kubelet
-rw-r--r--. 1 root 64M Dec 11 16:12 kube-proxy
-rw-r--r--. 1 root 63M Dec 11 16:12 kube-scheduler
-rw-r--r--. 1 root 11M Feb 13 20:19 runc.amd64
```

## Install `kubectl`

In this section you will install the `kubectl`, the official Kubernetes client command line tool, on the `jumpbox` machine. You will use `kubectl` to interact with the Kubernetes control plane after provisioning of your cluster completes later in this tutorial.

Use the `chmod` command to make the `kubectl` binary executable and move it to the `/usr/local/bin/` directory:

```bash
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
```

Since your installation of `kubectl` is complete, you can verify it by running the `kubectl` command:

```bash
kubectl version --client
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
```

At this point, you have set up `jumpbox` with all the command line tools and utilities necessary to complete the labs in this tutorial.

Next: [Provisioning Compute Resources](lab3-compute-resources.md)
