---
title: Installation des pilotes NVIDIA GPU
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

NVIDIA^&reg;^ est l’un des fabricants de GPU les plus connus. Il existe plusieurs façons d'installer les pilotes GPU de NVIDIA. Ce guide utilise le dépôt officiel de NVIDIA pour installer leurs pilotes. Par conséquent, le [Guide d'installation du pilote NVIDIA](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html) est largement référencé ici.

Voici d'autres méthodes alternatives pour installer les pilotes NVIDIA :

- Programme d'installation `.run` de NVIDIA
- Dépôt RPMFusion tiers
- Pilote ELRepo tiers

Dans la plupart des cas, il est préférable d'installer les pilotes NVIDIA à partir de la source officielle. RPMFusion et ELRepo sont disponibles pour ceux qui préfèrent un dépôt communautaire. Pour les matériels plus anciens, RPMFusion fonctionne mieux. Il est recommandé d'éviter d'utiliser le programme d'installation `.run`. Bien que pratique, l'utilisation du programme d'installation `.run` est connue pour écraser les fichiers système et présente des problèmes d'incompatibilité.

## Prérequis

Pour ce guide, vous aurez besoin des éléments suivants :

- Poste de travail Rocky Linux
- Droits d'accès `sudo`

## Installation des utilitaires et dépendances nécessaires

Installez le dépôt EPEL (Extra Packages for Enterprise Linux) :

```bash
sudo dnf install epel-release -y
```

Activez le référentiel CodeReady Builder (CRB) :

```bash
sudo dnf config-manager --enable crb
```

L'installation des outils de développement garantit les dépendances de compilation nécessaires :

```bash
sudo dnf groupinstall "Development Tools" -y
```

Le package `kernel-devel` fournit les fichiers d'en-têtes et les outils nécessaires pour construire les modules du noyau :

```bash
sudo dnf install kernel-devel-matched kernel-headers -y
```

## Installation des pilotes NVIDIA

Après avoir installé les prérequis nécessaires, il est temps d'installer les pilotes NVIDIA.

Ajoutez le dépôt officiel NVIDIA avec la commande suivante :

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -m)/cuda-rhel10.repo
```

Ensuite, nettoyez le cache du référentiel DNF :

```bash
sudo dnf clean expire-cache
```

Finalement, installez le dernier pilote NVIDIA pour votre système. Pour les modules de noyau ouverts, exécutez :

```bash
sudo dnf install nvidia-open -y
```

Pour les modules de noyau propriétaires, exécutez :

```bash
sudo dnf install cuda-drivers -y
```

### Anciens GPUs

La version 590 du pilote NVIDIA [abandonne la prise en charge des GPU basés sur Maxwell, Pascal et Volta](https://forums.developer.nvidia.com/t/unix-graphics-feature-deprecation-schedule/60588). Sur de tels systèmes, les instructions ci-dessus installeront le pilote sans erreur, mais au redémarrage, le chargement du module échouera car il ne trouvera aucun GPU compatible. Toutefois, si vous avez une telle carte graphique, vous pouvez toujours installer l'ancien pilote :

```bash
sudo dnf install cuda-drivers-580 -y
```

Vous devrez ensuite protéger le paquet cuda-drivers contre les futures mises à jour via le plugiciel [versionlock de dnf](https://docs.rockylinux.org/books/admin_guide/13-softwares/#versionlock-plugin).

## Désactivation de `Nouveau`

`Nouveau` est un pilote NVIDIA open-source qui offre des fonctionnalités limitées par rapport aux pilotes propriétaires de NVIDIA. Il est préférable de le désactiver pour éviter les conflits de drivers :

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! note "Remarque"

````
Pour les systèmes avec démarrage sécurisé activé, procédez comme suit :

```bash
sudo mokutil --import /var/lib/dkms/mok.pub
```

La commande `mokutil` vous demandera de créer un mot de passe qui sera utilisé lors du redémarrage.

Après le redémarrage, votre système devrait vous demander si vous souhaitez enregistrer une clé ou quelque chose de similaire. Répondez `yes` et le mot de passe saisi dans la commande `mokutil` vous sera demandé.
````

Reboot:

```bash
sudo reboot now
```

## Conclusion

Vous avez installé avec succès les pilotes GPU NVIDIA sur votre système à l'aide du dépôt officiel NVIDIA. Bénéficiez des capacités GPU NVIDIA avancées que les pilotes `Nouveau` par défaut ne peuvent pas fournir.
