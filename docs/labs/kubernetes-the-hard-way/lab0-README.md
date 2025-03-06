---
title: Introduction
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes The Hard Way (Rocky Linux)

> This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower). Unlike the original, which bases itself on Debian-like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux, which runs on x86_64 architecture.

This tutorial walks you through setting up Kubernetes the hard way. It is not for someone looking for a fully automated tool to set up a Kubernetes cluster. Kubernetes The Hard Way is designed for learning, so it means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

Do not view the results of this tutorial as production-ready, and it might not receive support from the community, but do not let that stop you from learning!

## Copyright

![Creative Commons License](images/cc_by_sa.png)

Licensing of this work is under a [Creative Commons Attribution-NonCommercial-=ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Target Audience

This tutorial's target audience is anyone who wants to understand the fundamentals of Kubernetes and how the core components work together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a basic Kubernetes cluster with all control plane components running on a single node and two worker nodes, which is enough to learn the core concepts.

Component versions:

* [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
* [containerd](https://github.com/containerd/containerd) v2.0.x
* [cni](https://github.com/containernetworking/cni) v1.6.x
* [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Labs

This tutorial requires four (4) x86_64-based virtual or physical machines connected to the same network. While the tutorial uses x86_64-based machines, you can apply the lessons learned to other platforms.

* [Prerequisites](lab1-prerequisites.md)
* [Setting up the Jumpbox](lab2-jumpbox.md)
* [Provisioning Compute Resources](lab3-compute-resources.md)
* [Provisioning the CA and Generating TLS Certificates](lab4-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](lab5-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](lab6-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](lab7-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](lab8-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](lab9-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](lab10-configuring-kubectl.md)
* [Provisioning Pod Network Routes](lab11-pod-network-routes.md)
* [Smoke Test](lab12-smoke-test.md)
* [Cleaning Up](lab13-cleanup.md)
