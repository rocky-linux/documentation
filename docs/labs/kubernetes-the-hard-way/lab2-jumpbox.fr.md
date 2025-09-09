---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n°2 : Mise en Place de The Jumpbox

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Dans ce labo, vous allez configurer l'une des quatre machines comme `jumpbox`. Vous utiliserez cette machine pour exécuter des commandes dans ce didacticiel. Bien qu'une machine dédiée soit utilisée pour assurer la cohérence, vous pouvez exécuter ces commandes à partir de n'importe quelle machine, y compris votre poste de travail personnel exécutant macOS ou Linux.

Considérez la `jumpbox` comme la machine d’administration que vous utiliserez comme base lors de la configuration de votre grappe Kubernetes à partir de zéro. Une chose que vous devez faire avant de commencer est d'installer quelques utilitaires de ligne de commande et de cloner le référentiel git `Kubernetes The Hard Way`, qui contient des fichiers de configuration supplémentaires que vous utiliserez pour configurer divers composants `Kubernetes` tout au long de ce didacticiel.

Connectez-vous au serveur `jumpbox` :

```bash
ssh root@jumpbox
```

Pour plus de commodité, vous exécuterez toutes les commandes en tant qu'utilisateur `root`, ce qui contribuera à réduire le nombre de commandes nécessaires pour tout configurer.

## Installation des Utilitaires de Ligne de Commande

Une fois connecté à la machine `jumpbox` en tant qu'utilisateur `root`, vous installerez les utilitaires de ligne de commande que vous utiliserez pour effectuer diverses tâches tout au long du didacticiel :

```bash
sudo dnf -y install wget curl vim openssl git
```

## Synchronisation du Dépôt GitHub

Il est maintenant temps de télécharger une copie de ce tutoriel, qui contient les fichiers de configuration et les modèles que vous utiliserez pour créer votre grappe Kubernetes à partir de zéro. Clonez le dépôt git de Kubernetes The Hard Way à l'aide de la commande `git` :

```bash
git clone --depth 1 \
  https://github.com/wsoyinka/kubernetes-the-hard-way.git
```

Accédez au répertoire `kubernetes-the-hard-way` :

```bash
cd kubernetes-the-hard-way
```

Ce sera le répertoire de travail pour le reste du tutoriel. Si jamais vous vous perdez, exécutez la commande `pwd` pour vérifier que vous êtes dans le bon répertoire lors de l'exécution de commandes sur la `jumpbox` :

```bash
pwd
```

```text
/root/kubernetes-the-hard-way
```

## Téléchargement des Fichiers Binaires

Ici, vous téléchargerez les binaires des différents composants Kubernetes. Stockez ces binaires dans le répertoire `downloads` sur la `jumpbox`. Cela réduira la quantité de bande passante Internet requise pour terminer ce tutoriel, car vous éviterez de télécharger les binaires plusieurs fois pour chaque machine de notre grappe Kubernetes.

Le fichier `download.txt` répertorie les binaires que vous allez télécharger, que vous pouvez consulter à l'aide de la commande `cat` :

```bash
cat downloads.txt
```

Téléchargez les binaires répertoriés dans le fichier `downloads.txt` dans un répertoire appelé `downloads` à l'aide de la commande `wget` :

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads.txt
```

Selon la vitesse de votre connexion Internet, le téléchargement des `584` mégaoctets de binaires peut prendre un certain temps. Une fois le téléchargement terminé, vous pouvez les lister à l'aide de la commande `ls` :

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

## Installation de `kubectl`

Dans cette section, vous installerez `kubectl`, l'outil de ligne de commande client officiel Kubernetes, sur la machine `jumpbox`. Vous utiliserez `kubectl` pour interagir avec le plan de contrôle Kubernetes une fois le provisionnement de votre grappe terminé plus tard dans ce didacticiel.

Utilisez la commande `chmod` pour rendre le binaire `kubectl` exécutable et le déplacer vers le répertoire `/usr/local/bin/` :

```bash
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
```

Étant donné que votre installation de `kubectl` est terminée, vous pouvez la vérifier en exécutant la commande `kubectl` :

```bash
kubectl version --client
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
```

À ce stade, vous avez configuré une `jumpbox` avec tous les outils et utilitaires de ligne de commande nécessaires pour terminer les travaux pratiques de ce didacticiel.

Suivant : [Provisionnement des ressources de calcul](lab3-compute-resources.md)
