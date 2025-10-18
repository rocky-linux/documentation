---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n°6 : Création de la configuration et de la clé de chiffrement des données

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Kubernetes stocke diverses données, notamment l'état du cluster, les configurations d'applications et les secrets. Kubernetes permet de [chiffrer](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) les données du cluster au repos.

Dans cet atelier, vous allez générer une clé de chiffrement et une [configuration de chiffrement](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration) adaptées au chiffrement des secrets Kubernetes.

## La Clé de Chiffrement

Générez une clé de chiffrement :

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## Le fichier de configuration du chiffrement

Créez le fichier de configuration de chiffrement `encryption-config.yaml` :

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Copiez le fichier de configuration de chiffrement `encryption-config.yaml` sur chaque instance de contrôleur :

```bash
scp encryption-config.yaml root@server:~/
```

Next: [Bootstrapping the etcd Cluster](lab7-bootstrapping-etcd.md)
