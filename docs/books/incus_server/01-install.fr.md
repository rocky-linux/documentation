---
title: "Chapitre 1 : Installation et Configuration"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Incus
  - entreprise
  - installation d'incus
---

Tout au long de ce chapitre, vous devez être l'utilisateur root ou pouvoir utiliser _sudo_ pour avoir les privilèges nécessaires.

## Installation des référentiels EPEL et OpenZFS

Incus nécessite le dépôt EPEL (Extra Packages for Enterprise Linux), qui est facile à installer avec la commande suivante :

```bash
dnf install epel-release -y
```

Une fois installé, vérifiez qu'il n'y a pas de mises à jour en attente :

```bash
dnf upgrade
```

Si des mises à jour du noyau ont été effectuées pendant le processus de mise à niveau, redémarrez le serveur.

### Le dépôt OpenZFS

Installez le dépôt OpenZFS en utilisant la commande suivante :

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
```

## Installation de `dkms`, `vim` et `kernel-devel`

Installation de paquets nécessaires :

```bash
dnf install dkms vim kernel-devel bash-completion
```

## Installation d'Incus

Vous aurez besoin du référentiel CRB disponible pour certains packages spéciaux et du COPR (Cool Other Package Repo) de Neil Hanlon :

```bash
dnf config-manager --enable crb
dnf copr enable neil/incus
dnf install incus incus-tools
```

Activez et démarrez le service `incus`  :

```bash
systemctl enable incus --now
```

Relancez le serveur maintenant avant de continuer.

## Installation d'OpenZFS

```bash
dnf install zfs
```

## Configuration de l'Environnement

L'exécution de nombreux conteneurs nécessite davantage de paramètres que la plupart des paramètres du noyau du serveur. Si nous supposons dès le début que nous utiliserons notre serveur en production, alors nous devons faire ces changements avant pour éviter que des erreurs telles que `Too many open files` ne se produisent.

Heureusement, peaufiner les paramètres d’Incus n’est pas difficile avec quelques modifications de fichiers et un redémarrage.

### Modification de `limits.conf`

Le premier fichier que vous devez modifier est `limits.conf`. Ce fichier est autodocumenté. Examinez les explications dans les commentaires du fichier pour comprendre à quoi sert ce fichier. Pour effectuer vos modifications, saisissez :

```bash
vi /etc/security/limits.conf
```

La plus grande partie de ce fichier est constitué de commentaires et, en bas, affiche les paramètres par défaut actuels. Vous devez ajouter les paramètres personnalisés dans l'espace vide au-dessus de la fin du marqueur de fichier (#End of file). La fin du fichier ressemblera à ceci lorsque vous aurez terminé :

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Enregistrez vos modifications et quittez l'éditeur (++shift+colon+"w"+"q"+exclam++ pour _vi_).

### Modification de `sysctl.conf` avec `90-incus-override.conf`

Avec _systemd_, vous pouvez modifier la configuration globale de votre système et les options du noyau _sans_ modifier le fichier de configuration principal. Au lieu de cela, vous mettrez vos paramètres dans un fichier séparé qui remplacera les paramètres particuliers dont vous avez besoin.

Pour effectuer ces modifications du noyau, vous créerez un fichier appelé `90-incus-override.conf` dans le répertoire `/etc/sysctl.d`. Pour ce faire, tapez ce qui suit :

```bash
vi /etc/sysctl.d/90-incus-override.conf
```

Placez le contenu suivant dans le fichier. Notez que si vous vous demandez comment faire ici, le contenu du fichier est auto-documenté :

```bash
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

net.core.bpf_jit_limit = 1000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Enregistrez vos modifications et quittez l'éditeur.

À ce stade, vous devriez redémarrer le serveur.

### Vérification des variables dans `sysctl.conf`

Une fois le redémarrage terminé, reconnectez-vous sur le serveur. Vous devoez vérifier que le fichier de remplacement a effectivement fait le travail.

Ce n'est pas difficile à faire. Il n'est pas nécessaire de vérifier tous les paramètres, sauf si vous le souhaitez, mais en vérifier quelques-uns permettra de s'assurer que les paramètres sont enregistrés. Pour ce faire, utilisez la commande `sysctl` :

```bash
sysctl net.core.bpf_jit_limit
```

Pour obtenir la ligne suivante :

```bash
net.core.bpf_jit_limit = 1000000000 
```

Faites la même chose avec quelques autres paramètres dans le fichier de substitution pour vérifier que des modifications ont été apportées.
