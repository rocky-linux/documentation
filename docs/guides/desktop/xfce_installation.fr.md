---
title: XFCE Desktop
author: Gerard Arthus, Steven Spencer, Emre Camalan
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova
tested_with: 8.9, 9.5
tags:
  - xfce
  - desktop
---

# Environnement de bureau XFCE

L'environnement de bureau XFCE, créé en tant que fork du Common Desktop Environment (CDE), incarne la philosophie Unix traditionnelle de modularité et de réutilisabilité. Vous pouvez installer XFCE sur la plupart des distributions GNU/Linux, y compris Rocky Linux.

C'est aussi l'un des environnements de bureau les plus faciles à combiner avec des gestionnaires de fenêtres alternatifs, tels que Awesome ou i3. Cette procédure est cependant conçue pour vous permettre de démarrer avec Rocky Linux en utilisant une installation typique de XFCE.

## Prérequis

- Une station de travail ou un notebook
- L'intention d'utiliser l'environnement de bureau XFCE au lieu de GNOME, celui par défaut
- Pour cette procédure, la possibilité d'utiliser `sudo` pour élever les privilèges

## Installation de Rocky Linux Minimal

!!! note

    Dans cette section, vous devrez soit être l'utilisateur `root`, soit être en mesure d'exécuter `sudo` pour élever vos privilèges.

Lors de l'installation de Rocky Linux, vous avez utilisé les ensembles de paquets suivants :

- Minimal
- Standard

## Exécuter la Mise à Jour du Système

D'abord, lancez la commande de mise à jour du serveur. Le système va renouveler le cache des dépôts. Lors de cette opération, le système peut reconnaître les paquets disponibles.

```
dnf update
```

## Activation des Dépôts

Vous avez besoin du dépôt non officiel pour XFCE dans le référentiel EPEL, pour fonctionner sur les versions de Rocky 8.x.

Activez ce dépôt en tapant la commande suivante :

```
dnf install epel-release
```

Répondez 'Y' pour l'installer.

Vous avez également besoin des Powertools et des dépôts lightdm. Continuez en les activant :

```
dnf config-manager --set-enabled powertools
dnf copr enable stenstorp/lightdm
```

!!! warning "Avertissement"

    Le système de compilation `copr` crée un dépôt connu pour l'installation de `lightdm`, mais il n'est pas maintenu par la communauté Rocky Linux. À utiliser à vos risques et périls !

Encore une fois, un message d'avertissement concernant le répertoire vous sera présenté. Allez-y et répondez <code>Y</code> à l'invite.

## Vérification des Environnements et Outils disponibles dans le Groupe

Maintenant que les dépôts sont activés, exécutez les commandes suivantes pour tout vérifier.

Tout d'abord, vérifiez votre liste de dépôts avec :

```
dnf repolist
```

Vous devriez récupérer les résultats suivants affichant tous les dépôts activés :

```bash
appstream                                                        Rocky Linux 8 - AppStream
    baseos                                                           Rocky Linux 8 - BaseOS
    copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
    epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
    epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
    extras                                                           Rocky Linux 8 - Extras
    powertools                                                       Rocky Linux 8 - PowerTools
```

Exécutez la commande suivante pour vérifier la présence de XFCE:

```
dnf grouplist
```

Vous devriez obtenir "Xfce" en bas de la liste.

Exécutez `dnf update` une ou plusieurs fois pour vous assurer que tous les dépôts activés sont inclus dans le système.

## Installation de Paquets

Pour installer XFCE, exécutez la commande suivante :

```
dnf groupinstall "xfce"
```

Installez également `lightdm` :

```
dnf install lightdm
```

## Étapes Finales

Vous devez désactiver `gdm`, qui est ajouté et activé lors de l'installation du groupe avec _dnf groupinstall "xfce"_ :

```
systemctl disable gdm
```

Vous pouvez maintenant activer _lightdm_ :

```
systemctl enable lightdm
```

Vous devez indiquer au système après le démarrage d'utiliser uniquement l'interface utilisateur graphique. Définissez le système cible par défaut sur l'interface utilisateur graphique :

```
systemctl set-default graphical.target
```

Puis redémarrez le système :

```
reboot
```

Vous devriez vous retrouver avec une invite de connexion dans l'interface XFCE et, lorsque vous vous connectez, vous aurez tout l'environnement XFCE.

## Conclusion

XFCE est un environnement léger avec une interface simple. C'est une alternative à l'environnement GNOME par défaut sur Rocky Linux.
