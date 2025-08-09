---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 6: Generazione della configurazione e della chiave di crittografia dei dati

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

Kubernetes memorizza vari dati, tra cui lo stato del cluster, le configurazioni delle applicazioni e i dati segreti. Kubernetes consente di [crittografare](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) i dati del cluster inattivi.

In questo laboratorio, genererai una chiave di crittografia e una [configurazione di crittografia](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration) adatta alla crittografia dei dati segreti Kubernetes.

## La chiave di crittografia

Generare una chiave di crittografia:

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## Il file di configurazione della crittografia

Creare il file di configurazione della crittografia `encryption-config.yaml`:

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Copiare il file di configurazione della crittografia `encryption-config.yaml` su ciascuna istanza del controller:

```bash
scp encryption-config.yaml root@server:~/
```

Successivo: [Avvio del cluster etcd](lab7-bootstrapping-etcd.md)
