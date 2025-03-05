---
title: Introduction
author: Wale Soyinka
contributors: Steven Spencer
---

This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower).
Unlike the original that bases itself on Debian like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux running on x86_64 architecture.

# Kubernetes The Hard Way

This tutorial walks you through setting up Kubernetes the hard way. This guide is not for someone looking for a fully automated tool to bring up a Kubernetes cluster. Kubernetes The Hard Way, designed for learning, means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

Do not view the results of this tutorial as production ready, and it might not receive support from the community, but do not let that stop you from learning!

## Copyright

![Creative Commons License](images/cc_by_sa.png)

Licensing of this work is under a [Creative Commons Attribution-NonCommercial-=ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Target Audience

The target audience for this tutorial is someone who wants to understand the fundamentals of Kubernetes and how the core components fit together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a basic Kubernetes cluster with all control plane components running on a single node, and two worker nodes, which is enough to learn the core concepts.

Component versions:

* [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
* [containerd](https://github.com/containerd/containerd) v2.0.x
* [cni](https://github.com/containernetworking/cni) v1.6.x
* [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Labs

This tutorial requires four (4) x86_64 based virtual or physical machines connected to the same network. While the tutorial uses x86_64 based machines, you can apply the lessons learned to other platforms.

* [Prerequisites](01-prerequisites.md)
* [Setting up the Jumpbox](02-jumpbox.md)
* [Provisioning Compute Resources](03-compute-resources.md)
* [Provisioning the CA and Generating TLS Certificates](04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](09-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](10-configuring-kubectl.md)
* [Provisioning Pod Network Routes](11-pod-network-routes.md)
* [Smoke Test](12-smoke-test.md)
* [Cleaning Up](13-cleanup.md)
