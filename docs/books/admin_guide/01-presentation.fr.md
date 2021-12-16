---
title: Introduction à Linux
---

# Introduction au système d'exploitation Linux

Dans ce chapitre, vous allez en apprendre plus à propos des distributions GNU/Linux.

****

**Objectifs : **Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: Décrire les caractéristiques et les architectures possibles d'un système d'exploitation.   
:heavy_check_mark: Retracer l'histoire d'UNIX et de GNU/Linux   
:heavy_check_mark: Choisir la distribution Linux adaptée à ses besoins   
:heavy_check_mark: Expliquer la philosophie des logiciels libres et open source   
:heavy_check_mark: Découvrir l'utilité de la SHELL.

:checkered_flag: **généralités**, **linux**, **distributions**

**Connaissances : ** :star:    
**Complexité : ** :star:

**Temps de lecture : **10 minutes

****

## Qu'est-ce qu'un système d'exploitation ?

Linux, UNIX, BSD, Windows et MacOS sont tous des **systèmes d'exploitation**.

!!! abstract Un système d'exploitation est un ensemble de programmes qui gèrent les ressources disponibles d'un ordinateur.

Parmi cette gestion des ressources, le système d'exploitation doit :

* Gérer la mémoire physique ou virtuelle.
  * La **mémoire physique** est constituée des barrettes de RAM et de la mémoire cache du processeur, utilisées pour l'exécution des programmes.
  * La **mémoire virtuelle** est un emplacement sur le disque dur (la partition **swap**) qui permet de décharger la mémoire physique et de sauvegarder l'état actuel du système lors de l'arrêt électrique de l'ordinateur.
* Intercepter les **accès aux périphériques**. Les logiciels sont rarement autorisés à accéder directement au matériel (sauf les cartes graphiques pour des besoins très spécifiques).
* Fournir aux applications une **gestion correcte des tâches**. Le système d'exploitation est responsable de la planification des processus pour occuper le processeur.
* **Protéger les fichiers** contre les accès non autorisés.
* **Collecter des informations** sur les programmes utilisés ou en cours d'exécution.

![Operation of an operating system](images/operating_system.png)

## Généralités UNIX - GNU/Linux

### Histoire

#### UNIX

* De **1964 à 1968** : MULTICS (MULTiplexed Information and Computing Service) est développé pour le MIT, Bell Labs (AT&T) et General Electric.

* **1969** : Après le retrait de Bell (1969) puis de General Electric du projet, deux développeurs (Ken Thompson et Dennis Ritchie), rejoint plus tard par Brian Kernighan, jugeant MULTICS trop complexe, ont lancé le développement de UNIX (UNiplexed Information and Computing Service). Développé à l'origine en assembleur, les concepteurs d'UNIX développent le langage B puis le langage C (1971) et réécrivent complètement UNIX. Ayant été développé en 1970, la date de référence des systèmes UNIX/Linux est toujours fixée au 1er janvier 1970.

Le langage C est encore l'un des langages de programmation les plus populaires aujourd'hui! Un langage de bas niveau, proche du matériel, il permet d'adapter le système d'exploitation à toute architecture de machine ayant un compilateur C.

UNIX est un système d'exploitation ouvert et évolutif qui a joué un rôle majeur dans l'histoire de l'informatique. Il a été la base de beaucoup d'autres systèmes : Linux, BSD, MacOS, etc.

UNIX est toujours d'actualité aujourd'hui (HP-UX, AIX, Solaris, etc.)

#### Minix

* **1987** : A.S. Tanenbaum développe MINIX, un UNIX simplifié, pour enseigner les systèmes d'exploitation de manière simple. M. Tanenbaum met à disposition le code source de son système d'exploitation.

#### Linux

* **1991** : Un étudiant finlandais, **Linus Torvalds**, crée un système d'exploitation dédié à son ordinateur personnel et le nomme Linux. Il publie sa première version 0.02, sur le forum de discussion Usenet et d'autres développeurs viennent l'aider à améliorer son système. Le terme Linux est un jeu de mots entre le prénom du fondateur, Linus, et UNIX.

* **1993** : La distribution Debian est créée. Debian est une distribution non commerciale basée sur la communauté. Développé à l'origine pour être utilisée sur les serveurs, elle est particulièrement adaptée à ce rôle, mais elle est destinée à être un système universel et donc utilisable sur un ordinateur personnel également. Debian est utilisée comme base pour de nombreuses autres distributions, comme Mint ou Ubuntu.

* **1994** : La distribution commerciale RedHat est créée par la société RedHat, qui est aujourd'hui le premier distributeur du système d'exploitation GNU/Linux. RedHat prend en charge la version communautaire Fedora et récemment la distribution gratuite CentOS.

* **1997** : L'environnement de bureau KDE est créé. Il est basé sur la bibliothèque de composants Qt et le langage de développement C++.

* **1999** : L'environnement de bureau Gnome est créé. Il est basé sur la bibliothèque de composants GTK+.

* **2002** : La distribution Arch est créée. Sa particularité est d'être diffusée en Rolling Release (mise à jour continue).

* **2004** : Ubuntu est créé par la compagnie Canonical (Mark Shuttleworth). Elle est basé sur Debian, mais inclut des logiciels libres et propriétaires.

* **2021** : Naissance de Rocky Linux, basée sur la distribution RedHat.

### Part de marché

<!--
TODO: graphics with market share for servers and pc.
-->

Linux is still not well known by the general public, even though they use it regularly. Indeed, Linux is hidden in **smartphones**, **televisions**, **internet boxes**, etc. Almost **70% of the web pages** served in the world are served by a Linux or UNIX server!

Linux equips a little more than **3% of personal computers** but more than **82% of smartphones**. **Android** being an operating system whose kernel is a Linux.

<!-- TODO: review those stats -->

Linux equips 100% of the 500 supercomputers since 2018. A supercomputer is a computer designed to achieve the highest possible performance with the techniques known at the time of its design, especially with regard to computing speed.

### Architectural design

* The **kernel** is the first software component.
  * It is the heart of the Linux system.
  * It manages the hardware resources of the system.
  * The other software components must go through it to access the hardware.
* The **shell** is a utility that interprets user commands and ensures their execution.
  * Main shells: Bourne shell, C shell, Korn shell and Bourne-Again shell (bash).
* Applications are user programs such as :
  * Internet browser ;
  * the word processor ;
  * ...

#### Multitask

Linux belongs to the family of time-sharing operating systems. It shares process time between several programs, switching from one to another in a transparent way for the user. This implies:

* simultaneous execution of several programs;
* distribution of CPU time by the scheduler;
* reduction of problems due to a failed application;
* reduced performance when there are too many programs running.

#### Multi user

The purpose of Multics was to allow several users to work from several terminals (screen and keyboard) on a single computer (very expensive at the time). Linux, which is inspired by this operating system, has kept this ability to work with several users simultaneously and independently, each one having its own user account, memory space and access rights to files and software.

#### Multiprocessor

Linux is able to work with multi-processor computers or with multi-core processors.

#### Multi platform

Linux is written in a high-level language that can be adapted to different types of platforms during compilation. It therefore runs on :

* home computers (PC or laptop);
* servers (data, applications,...);
* portable computers (smartphones or tablets)
* embedded systems (car computer);
* active network elements (routers, switches)
* household appliances (TVs, refrigerators,...).

#### Open

Linux is based on recognized standards [posix](http://fr.wikipedia.org/wiki/POSIX), TCP/IP, NFS, Samba ... allowing to share data and services with other application systems.

### The UNIX/Linux philosophy

* Everything is a file.
* Portability.
* Do only one thing and do it well.
* KISS: Keep It Simple Stupid.
* "UNIX is basically a simple operating system, but you have to be a genius to understand the simplicity." (__Dennis Ritchie__)
* "Unix is user-friendly. It just isn't promiscuous about which users it's friendly with." (__Steven King__)

## The GNU/LINUX distributions

A Linux distribution is a **consistent set of software** assembled around the Linux kernel and ready to be installed along with the necessary components to manage this software (installation, removal, configuration). There are **associative or community** distributions (Debian, Rocky) or **commercial** (RedHat, Ubuntu).

Each distribution offers one or more **desktop environments**, provides a set of pre-installed software and a library of additional software. Configuration options (kernel or services options for example) are specific to each one.

This principle allows you to have distributions oriented to **beginners** (Ubuntu, Linux Mint...), to have a more complex approach (Gentoo, Arch), to be focused more towards **servers** (Debian, Redhat), or to be dedicated towards **workstations**.

### Desktop environments

There are many graphic environments: **Gnome**, **KDE**, **LXDE**, **XFCE**, etc. There is something for everyone, and their **ergonomics** have nothing to be ashamed of when compared to Microsoft or Apple systems!

So why is there so little enthusiasm for Linux, when **there are no (or almost no) viruses for this system**? Maybe because all editors (Adobe) or manufacturers (Nvidia) do not play the free game and do not provide a version of their software or their __drivers__ for GNU/Linux? Fear of change? The difficulty to find where to buy a Linux computer? Too few games (but not for long) distributed under Linux? Will the situation change with the arrival of the steam-box game console that runs on Linux?

![Gnome Desktop](images/01-presentation-gnome.png)

The **Gnome 3** desktop environment no longer uses the concept of Desktop but that of Gnome Shell (not to be confused with the command line shell). It serves as a desktop, a dashboard, a notification area and a window selector. The Gnome desktop environment is based on the GTK+ component library.

![KDE Desktop](images/01-presentation-kde.png)

The **KDE** desktop environment is based on the **Qt** component library.

It is traditionally more recommended for users coming from a Windows world.

![Tux - The Linux mascot](images/tux.png)

### Free / Open source

A user of a Microsoft or Mac operating system must purchase a license to use the operating system. This license has a cost, although it is usually transparent (the price of the license is included in the price of the computer).

In the **GNU/Linux** world, the Free Software movement provides mostly free distributions.

**Free** does not mean free!

**Open source**: the source codes are available, so it is possible to consult and modify them under certain conditions.

A free software is necessarily Open Source, but the opposite is not true since an Open Source software is separated from the freedom proposed by the GPL license.

#### GPL License (General Public License)

The **GPL License** guarantees the author of a software its intellectual property, but allows modification, redistribution or resale of software by third parties, provided that the source codes are provided with the software. The GPL is the license that came out of the **GNU** (GNU is Not UNIX) project, which was instrumental in creating Linux.

It implies :

* the freedom to run the program, for any purpose;
* the freedom to study how the program works and adapt it to your needs
* the freedom to redistribute copies;
* the freedom to improve the program and publish your improvements, for the benefit of the whole community.

On the other hand, even products licensed under the GPL can be paid for. This is not the product itself, but the guarantee that a team of developers will continue to work on it to make it evolve and troubleshoot errors, or even provide support to users.

## Areas of use

A Linux distribution excels for :

* **A server**: HTTP, email, groupware, file sharing, etc.
* **Security**: Gateway, firewall, router, proxy, etc.
* **Central computer**: Banks, insurance, industry, etc.
* **Embedded system**: Routers, Internet boxes, SmartTV, etc.

Linux is a suitable choice for hosting databases or websites, or as a mail server, DNS or firewall. In short, Linux can do just about anything, which explains the quantity of specific distributions.

## Shell

### Generalities

The **shell**, known as _command interface_, allows users to send commands to the operating system. It is less visible today, since the implementation of graphical interfaces, but remains a privileged means on Linux systems which do not all have graphical interfaces and whose services do not always have a setting interface.

It offers a real programming language including the classical structures: loops, alternatives, and the common constituents: variables, passing of parameters, and sub-programs. It allows the creation of scripts to automate certain actions (backups, creation of users, system monitoring, etc.).

There are several types of shells available and configurable on a platform or according to the user's preference:

* sh, the POSIX standard shell ;
* csh, command-oriented shell in C ;
* bash, Bourne-Again Shell, Linux shell.
* etc, ...

## Functionalities

* Command execution (checks the command given and executes it);
* Input/Output redirection (returns data to a file instead of writing it on the screen);
* Connection process (manages the user's connection);
* Interpreted programming language (allowing the creation of scripts);
* Environment variables (access to information specific to the system during operation).

### Principle

![Operating principle of the SHELL](images/shell-principle.png)

## Check your Knowledge

:heavy_check_mark: An operating system is a set of programs for managing the available resources of a computer:

- [ ] True
- [ ] False

:heavy_check_mark: The operating system is brought to:

- [ ] Manage physical and virtual memory
- [ ] Allow direct access to peripherals
- [ ] Subcontract the management of tasks to the processor
- [ ] Collect information about the programs used or in use

:heavy_check_mark: Among these personalities, which ones participated in the development of UNIX:

- [ ] Linus Torvalds
- [ ] Ken Thompson
- [ ] Lionel Richie
- [ ] Brian Kernighan
- [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: The original nationality of Linus Torvalds, creator of the Linux kernel, is:

- [ ] Swedish
- [ ] Finnish
- [ ] Norwegian
- [ ] Flemish
- [ ] French of course

:heavy_check_mark: Which of the following distributions is the oldest:

- [ ] Debian
- [ ] Slackware
- [ ] RedHat
- [ ] Arch

:heavy_check_mark: Is the Linux kernel:

- [ ] Multitasking
- [ ] Multi user
- [ ] Multiprocessor
- [ ] Multi-core
- [ ] Cross-platform
- [ ] Open

:heavy_check_mark: Is free software necessarily open source?

- [ ] True
- [ ] False

:heavy_check_mark: Is Open Source software necessarily free?

- [ ] True
- [ ] False

:heavy_check_mark: Which of the following is not a shell:

- [ ] Jason
- [ ] Jason-Bourne shell (jbsh)
- [ ] Bourne-Again shell (bash)
- [ ] C shell (csh)
- [ ] Korn shell (ksh)   
