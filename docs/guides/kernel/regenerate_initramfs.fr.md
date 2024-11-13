---
title: Régénérer `initramfs`
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - matériel
---

## Introduction

Un `initramfs` est le système de fichiers `root` à l'intérieur d'un noyau Linux pour aider à démarrer le système. Il contient les modules de base nécessaires au démarrage de Linux.

Sometimes, an Linux administrator might want to regenerate the `initramfs`, say if they want to blacklist a driver or include a out-of-band module. L'auteur a fait tout cela pour [activer Intel vPro sur un Minisforum MS-01](https://spaceterran.com/posts/step-by-step-guide-enabling-intel-vpro-on-your-minisforum-ms-01-bios/).

## Prérequis

Les conditions suivantes sont indispensables pour utiliser cette procédure :

- Un système Rocky Linux ou une machine virtuelle (mais pas un conteneur)
- Modifications apportées à la configuration du noyau, telles que mise sur liste noire ou l'ajout d'un module

## Régénérer `initramfs`

Pour régénérer le `initramfs`, vous devez d'abord sauvegarder le fichier `initramfs` existant :

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-$(date +%m-%d-%H%M%S).img
```

Ensuite, exécutez `dracut` pour régénérer le fichier `initramfs` :

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

Puis redémarrez le système :

```bash
reboot
```

## Conclusion

Le noyau Linux est extrêmement puissant et modulaire. Il est logique que certains utilisateurs souhaitent autoriser ou interdire certains modules, et la régénération de `initramfs` permet que cela se produise.
