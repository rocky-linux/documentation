---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n°7: Bootstrapping du Cluster `etcd`

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Les composants Kubernetes sont sans état et stockent l'état du cluster dans [etcd](https://github.com/etcd-io/etcd). Dans cet atelier, vous démarrerez un cluster `etcd` à trois nœuds et la configurerez pour une haute disponibilité et un accès à distance sécurisé.

## Prérequis

Copiez les binaires `etcd` et les fichiers `unit` de `systemd` sur l’instance `server` :

```bash
scp \
  downloads/etcd-v3.4.36-linux-amd64.tar.gz \
  units/etcd.service \
  root@server:~/
```

Exécutez les commandes dans les sections suivantes de ce laboratoire sur la machine `server`. Connectez-vous à la machine `server` avec la commande `ssh`. Exemple :

```bash
ssh root@server
```

## Bootstrapping d'un Cluster `etcd`

### Installation des Fichiers Binaires `etcd`

Si vous ne l'avez pas déjà fait, installez d'abord l'utilitaire `tar` avec `dnf`. Ensuite, extrayez et installez le serveur `etcd` et l'utilitaire de ligne de commande `etcdctl` :

```bash
  dnf -y install tar
  tar -xvf etcd-v3.4.36-linux-amd64.tar.gz
  mv etcd-v3.4.36-linux-amd64/etcd* /usr/local/bin/
```

### Configuration du Serveur `etcd`

```bash
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
```

Chaque membre `etcd` doit avoir un nom unique dans un cluster `etcd`. Définissez le nom `etcd` pour qu'il corresponde au nom d'hôte de l'instance de calcul actuelle :

Créez le fichier de l'unité `etcd.service` `systemd` :

```bash
mv etcd.service /etc/systemd/system/
chmod 644 /etc/systemd/system/etcd.service
```

!!! note "Remarque "

    Bien que considéré comme une mauvaise sécurité, vous devrez peut-être désactiver temporairement ou définitivement SELinux si vous rencontrez des problèmes de démarrage du service « etcd » et « systemd ». La solution appropriée consiste à analyser et à créer les fichiers de stratégie nécessaires avec des outils tels que « ausearch », « audit2allow » et autres.
    
    Les commandes suivantes permettent de désactiver SELinux :

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Lancement du Serveur `etcd`

```bash
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
```

## Vérification

Énumérez les membres du cluster `etcd` :

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

Next: [Bootstrapping the Kubernetes Control Plane](lab8-bootstrapping-kubernetes-controllers.md)
