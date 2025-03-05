---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Lab 6: Generating the Data Encryption Configuration and Key

>This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower). Unlike the original that bases itself on Debian like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux running on x86_64 architecture.

Kubernetes stores a variety of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to [encrypt](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) cluster data at rest.

In this lab you will generate an encryption key and an [encryption configuration](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration) suitable for encrypting Kubernetes Secrets.

## The Encryption Key

Generate an encryption key:

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## The Encryption Configuration File

Create the `encryption-config.yaml` encryption configuration file:

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Copy the `encryption-config.yaml` encryption configuration file to each controller instance:

```bash
scp encryption-config.yaml root@server:~/
```

Next: [Bootstrapping the etcd Cluster](lab7-bootstrapping-etcd.md)
