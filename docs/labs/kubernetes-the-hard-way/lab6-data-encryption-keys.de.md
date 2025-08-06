---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Übung 6: Generieren der Datenverschlüsselungskonfiguration und des Schlüssels

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

Kubernetes speichert verschiedene Daten, darunter Clusterstatus, Anwendungskonfigurationen und Secrets. Kubernetes ermöglicht die [Verschlüsselung](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) ruhender Clusterdaten.

In diesem Labor generieren Sie einen Verschlüsselungsschlüssel und eine [Verschlüsselungskonfiguration](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration), die zum Verschlüsseln von Kubernetes-Secrets geeignet sind.

## Der Chiffrierschlüssel

Generieren Sie einen Verschlüsselungsschlüssel:

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## Die Verschlüsselungs-Konfigurations-Datei

Erstellen Sie die Verschlüsselungskonfigurationsdatei `encryption-config.yaml`:

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Kopieren Sie die Verschlüsselungskonfigurationsdatei `encryption-config.yaml` in jede Controller-Instanz:

```bash
scp encryption-config.yaml root@server:~/
```

Fortsetzung folgt: [Bootstrapping vom etcd-Cluster](lab7-bootstrapping-etcd.md)
