---
title: Comment gérer un `Kernel panic`
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - kernel
  - kernel panic
  - dépannage
---

## Introduction

Parfois, l'installation du noyau se passe mal et vous devez revenir en arrière.

Il peut y avoir plusieurs raisons à cela : espace insuffisant sur la partition `/boot`, installation interrompue ou problème avec une application tierce.

Heureusement pour nous, il y a toujours quelque chose que nous pouvons faire pour sauver la situation.

## Essayez de redémarrer avec le noyau précédent

La première chose à essayer est de redémarrer avec le kernel précédent.

- Redémarrer le système.
- Une fois que vous avez atteint l'écran de démarrage de GRUB 2, déplacez la sélection vers l'entrée de menu correspondant au noyau précédent et appuyez sur la touche ++enter++.

Une fois le système redémarré, il peut être réparé.

Si le système ne démarre pas, essayez le **mode de secours** (`rescue mode`, voir ci-dessus).

## Désinstallez le noyau défectueux

Le moyen le plus simple de procéder consiste à désinstaller la version du noyau qui ne fonctionne pas, puis à la réinstaller.

!!! note "Remarque"

````
Vous ne pouvez pas supprimer un noyau en cours d'exécution.

Pour afficher la version du noyau actuellement exécuté :

```bash
uname -r
```
````

Vous pouvez vérifier la liste des noyaux installés :

```bash
dnf list installed kernel\* | sort -V
```

mais cette commande est peut-être plus pratique, puisqu'elle ne renvoie que les packages ayant plusieurs versions installées :

```bash
dnf repoquery --installed --installonly
```

Pour supprimer un noyau spécifique, vous pouvez utiliser `dnf`, en spécifiant la version du noyau que vous avez récupérée précédemment :

```bash
dnf remove kernel-core-<version>
```

Exemple :

```bash
dnf remove kernel-5.14.0-427.20.1.el9_4.x86_64
```

or use the `dnf repoquery` command:

```bash
dnf remove $(dnf repoquery --installed --installonly --latest=1)
```

Vous pouvez maintenant mettre à niveau votre système et essayer de réinstaller la dernière version du noyau.

```bash
dnf update
```

Redémarrez et voyez si le nouveau noyau fonctionne cette fois correctement.

## Mode de Secours

Le mode Rescue correspond à l’ancien mode mono-utilisateur.

!!! note "Remarque"

```
Pour entrer en mode de secours, vous devez fournir le mot de passe root.
```

Pour accéder au mode de secours, le moyen le plus simple est de sélectionner la ligne commençant par `0-rescue-*` dans le menu grub.

Une autre façon consiste à éditer n'importe quelle ligne du menu grub (en appuyant sur la touche ++'e'++) et à ajouter `systemd.unit=rescue.target` à la fin de la ligne qui commence par `linux`, puis à appuyer sur ++ctrl++ + ++x++ pour démarrez le système en mode de secours.

!!! note "Remarque"

```
Vous êtes alors en mode QWERTY.
```

Une fois que vous êtes en mode de secours et que vous avez entré le mot de passe root, vous pouvez alors réparer votre système.

Pour cela, vous devrez peut-être configurer une adresse IP temporaire grâce à `ip ad add …` (voir chapitre réseau de notre guide d'administration).

## Dernière chance : Anaconda Rescue Mode

Si aucune des méthodes ci-dessus ne fonctionne, il est toujours possible de démarrer à partir de l'image ISO d'installation et de réparer le système.

Cette méthode n'est pas couverte par cette documentation.

## Maintenance du Système

### Nettoyage des anciennes versions du kernel

Vous pouvez supprimer les anciens packages de noyau installés, en ne conservant que la dernière version et la version du noyau en cours d'exécution :

```bash
dnf remove --oldinstallonly
```

### Limitation du nombre de versions de noyaux installées

Nous pouvons limiter le nombre de versions du noyau en éditant le fichier `/etc/yum.conf` et en définissant la variable **installonly_limit** :

```text
installonly_limit=3
```

!!! note "Remarque"

```
Vous devez toujours conserver au moins la dernière version du noyau et une version de sauvegarde.
```
