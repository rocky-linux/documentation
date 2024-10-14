---
title: Présentation du Shell
author: tianci li
contributors: Ganna Zhyrnova
tags:
  - Shell - Introduction
---

# Introduction

**Un Shell, c'est quoi ?**

Le Shell est aussi appelé **command interface** ou bien **command interpreter**. Il fournit un interface au niveau système permettant aux utilisateurs d'envoyer des requêtes au noyau Linux pour exécuter des programmes.

Lors de la présentation du système d'exploitation, nous avons mentionné la phrase suivante :

> Intercepter l\`**accès aux périphériques**. Les logiciels peuvent rarement accéder directement au matériel (à l’exception des cartes graphiques pour des besoins particuliers).

![Shell01](./images/Shell01.png)

La couche inférieure est constituée des périphériques matériels gérés par le noyau Linux. Lorsque quelqu'un se connecte à distance au serveur via SSH et saisit diverses commandes, le noyau Linux ne reconnaît pas directement ces mots ou ces lettres. En fait, les ordinateurs ne peuvent reconnaître que des langages machine composés de 0 et 1. Pour effectuer la conversion entre le langage humain et le langage machine, un véritable agent de traduction bidirectionnelle a été introduit dans le système d'exploitation, à savoir le Shell.

Ça marche comme ça :

**Personnes d'un pays A** <<--->> **Shell** <<--->> **Personnes d'un pays B**

Du point de vue de l'utilisateur, le Shell est une interface entre un humain et un ordinateur. Les interfaces des systèmes d'exploitation modernes comprennent principalement :

- Interface de ligne de commande. Par exemple, des systèmes d'exploitation tels que **RockyLinux** et **Debian** agissent en tant que serveur.
- Interface graphique. Par exemple, le système d'exploitation **Windows 11** pour les environnements domestiques et professionnels.
- Ligne de commande et interface graphique combinées. Par exemple, **Mint**, **Ubuntu** avec environnement graphique, **Windows Server** avec Powershell, etc.

Classification des Shells :

- Bourne Shell - Cette famille comprend, sans toutefois s'y limiter :
  - sh (Bourne Shell, /usr/bin/sh). Il a été développé chez Bell LABS à partir de 1977 par Stephen Bourne et utilisé sur V7 UNIX
  - ksh (Korn Shell, /usr/bin/ksh)
  - Bash (GNU Bourne-Again Shell, /bin/bash) - Né en 1987, c'est un produit du projet GNU. La plupart des systèmes d'exploitation GNU/Linux utilisent `bash` comme shell par défaut
  - psh (POSIX Shell)
  - zsh (Z-shell)
- C Shell - Cette famille comprend, sans toutefois s'y limiter :
  - csh
  - tcsh
- Power Shell
