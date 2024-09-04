---
title: Installation des pilotes NVIDIA GPU
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

Nvidia est l’un des fabricants de GPU les plus connus. Il existe plusieurs façons d'installer les pilotes GPU de Nvidia. Ce guide utilise le dépôt officiel de Nvidia pour installer leurs pilotes. Ainsi, le [Guide d'installation Nvidia] (https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) est largement référencé ici.

!!! note "Remarque"

```
Le lien vers les étapes de pré-installation dans le manuel officiel de Nvidia ne fonctionne pas. Pour installer le pilote Nvidia depuis le dépôt officiel, vous devrez installer les utilitaires et dépendances nécessaires.
```

Voici d'autres méthodes de substitution pour installer les pilotes Nvidia :

- Nvidia's `.run` installer
- Dépôt tiers RPMFusion
- Pilote Third-party ELRepo

Dans la plupart des cas, il est préférable d'installer les pilotes Nvidia à partir d'une source officielle. RPMFusion et ELRepo sont disponibles pour ceux qui préfèrent un dépôt communautaire. Pour les matériels plus anciens, RPMFusion fonctionne mieux. Il est recommandé d'éviter d'utiliser le programme d'installation `.run`. Bien que pratique, l'utilisation du programme d'installation `.run` est connue pour écraser les fichiers système et présente des problèmes d'incompatibilité.

## Prérequis

Pour ce guide, vous aurez besoin des conditions suivantes :

- Poste de travail Rocky Linux
- Droits d'accès `sudo`

## Installer les utilitaires et dépendances nécessaires

Installez le dépôt EPEL (Extra Packages for Enterprise Linux) :

```bash
sudo dnf install epel-release -y
```

L'installation des outils de développement fournit les dépendances de construction du logiciel nécessaires :

```bash
sudo dnf groupinstall "Development Tools" -y
```

Le package `kernel-devel` fournit les fichiers d'en-têtes et les outils nécessaires pour construire les modules du noyau :

```bash
sudo dnf install kernel-devel -y
```

Dynamic Kernel Module Support (DKMS) est un programme utilisé pour restaurer automatiquement les modules du noyau :

```bash
sudo dnf install dkms -y
```

## Installation des pilotes NVIDIA

Après avoir installé les prérequis nécessaires, il est temps d'installer les pilotes Nvidia.

Ajoutez le dépôt officiel Nvidia avec la commande suivante :

!!! note "Remarque"

```
Si vous utilisez Rocky Linux 8, remplacez `rhel9` dans le chemin du fichier par `rhel8`.
```

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
```

Ensuite, installez un ensemble de packages nécessaires pour créer et installer les modules du noyau :

```bash
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglv-devel acpid pkgconfig dkms -y
```

Installez le dernier module de pilote NVIDIA pour votre système :

```bash
sudo dnf module install nvidia-driver:latest-dkms -y
```

## Désactivation de `Nouveau`

`Nouveau` est un pilote NVIDIA open-source qui offre des fonctionnalités limitées par rapport aux pilotes propriétaires de NVIDIA. Il est préférable de le désactiver pour éviter les conflits de drivers :

Ouvrez le fichier de configuration `grub` avec l'éditeur de votre choix :

```bash
sudo vim /etc/default/grub
```

Ajoutez `nouveau.modeset=0` et `rd.driver.blacklist=nouveau` à la fin de `GRUB_CMDLINE_LINUX`.

La valeur `GRUB_CMDLINE_LINUX` devrait ressembler au texte ci-dessous, bien qu'elle ne corresponde pas exactement et ne doive pas être identique :

```bash
GRUB_CMDLINE_LINUX="resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap crashkernel=auto rhgb quiet nouveau.modeset=0 rd.driver.blacklist=nouveau"
```

Rechargez l'environnement `grub` :

```bash
grub2-mkconfig -o /boot/grub2/grubenv
```

Reboot:

```bash
sudo reboot now
```

## Conclusion

Vous avez installé avec succès les pilotes GPU NVIDIA sur votre système à l'aide du dépôt officiel NVIDIA. Bénéficiez de capacités GPU NVIDIA avancées que les pilotes `Nouveau` par défaut ne peuvent pas fournir.
