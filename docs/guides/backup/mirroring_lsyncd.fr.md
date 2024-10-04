---
title: Solution Miroir - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - synchronisation
  - miroir
---

## Prérequis

- Une machine tournant sous Rocky Linux
- Pourvoir modifier des fichiers de configuration depuis la ligne de commande
- Connaissance de l'utilisation d'un éditeur de ligne de commande (nous utilisons `vi` ici, mais n'hésitez pas à le remplacer par votre éditeur favori.)
- Vous aurez besoin d'un accès `root` ou de privilèges supplémentaires grâce à `sudo` (utiliser `sudo -s` dès le début est une bonne idée)
- Paire de clés SSH publiques et privées
- Les dépôts EPEL (Extra Packages for Enterprise Linux) de Fedora
- Vous devrez être familier avec *inotify*, un interface de suivi des événements
- Facultatif : familiarité avec l'outil *tail*

## Introduction

Il est en fait possible de mettre complètement en miroir un serveur à l'aide de `lsyncd` en spécifiant soigneusement les répertoires et fichiers que vous souhaitez synchroniser. Mais vous devez tout configurer depuis la ligne de commande.

C'est un programme qui vaut la peine d'être appris pour tout administrateur système.

La meilleure description de `lsyncd`, vient de sa propre page de manuel — `man lsyncd`. Légèrement paraphrasé, `lsyncd` est une solution Live Mirror légère qui n'est pas difficile à installer. Il ne nécessite pas de nouveaux systèmes de fichiers ou périphériques de blocs et ne nuit pas aux performances du système de fichiers local. En bref, il duplique les fichiers.

`lsyncd` surveille l'interface du moniteur d'événements d'une arborescence de répertoires locale (`inotify`). Il agrège et combine les événements pendant quelques secondes et génère un (ou plusieurs) processus pour synchroniser les modifications. Par défaut, il s'agit de `rsync`.

Pour les besoins de ce guide, vous appellerez le système contenant les fichiers originaux la « source » et celui avec lequel vous effectuez la synchronisation sera la « cible ». Il est en fait possible de refléter complètement un serveur en utilisant `lsyncd` en spécifiant soigneusement les répertoires et les fichiers que vous souhaitez synchroniser.

Pour la synchronisation à distance, vous voudrez également configurer les [paires de clé privée-publique SSH de Rocky Linux](../security/ssh_public_private_keys.md). Les exemples utilisent ici SSH (port 22).

## Installation de `lsyncd`

L'installation de `lsyncd` se fait de deux manières. Vous trouverez des descriptions de chaque méthode dans ce qui suit. Le RPM a tendance à prendre un peu de retard par rapport aux paquets sources, mais la différence devrait rester gérable. La version installée par la méthode RPM au moment de la rédaction de cet article est la 2.2.3-5, tandis que la version du code source est désormais la 2.3.1. Choisissez la méthode avec laquelle vous vous sentez le plus à l’aise.

## Installation de `lsyncd` – Méthode RPM

L'installation par la méthode RPM est plutôt facile. La seule chose que vous devriez installer en premier est le référentiel logiciel EPEL de Fedora. Pour ce faire :

```bash
dnf install -y epel-release
```

Installez maintenant `lsyncd` avec toutes les dépendances manquantes :

```bash
dnf install lsyncd
```

Configurez le service pour qu'il soit lancé au cours du démarrage du système, mais ne le démarrez pas tout de suite :

```bash
systemctl enable lsyncd
```

## Installation de `lsyncd` – Méthode utilisant les sources

L'installation à partir des sources n'est pas difficile.

### Installation les dépendances

Vous aurez besoin de certaines dépendances pour `lsyncd` et pour créer des packages à partir des sources. Utilisez cette commande sur votre machine Rocky Linux pour vous assurer que vous avez les dépendances nécessaires. Si vous allez construire à partir des sources, c'est une bonne idée d'installer tous les outils de développement :

```bash
dnf groupinstall 'Development Tools'
```

!!! warning "Avertissement concernant Rocky Linux 9.0"

    `lsyncd` a été entièrement testé avec Rocky Linux 9.0 et devrait fonctionner comme prévu. Pour que toutes les dépendances nécessaires soient installées, vous devrez cependant activer un dépôt supplémentaire :

    ```
    dnf config-manager --enable crb
    ```


    Faire cela en 9 étapes avant les étapes suivantes vous permettra de terminer la construction sans revenir en arrière.

Voici les dépendances nécessaires pour `lsyncd` :

```bash
dnf install lua lua-libs lua-devel cmake unzip wget rsync
```

### Télécharger les Sources et Construire `lsyncd`

Ensuite, vous avez besoin du code source :

```bash
wget https://github.com/axkibe/lsyncd/archive/master.zip
```

Décompressez le fichier `master.zip` :

`unzip master.zip`

Cela créera un répertoire appelé `lsyncd-master`. Vous devez accéder à ce répertoire et créer un répertoire appelé `build` :

```bash
cd lsyncd-master
```

Puis :

```bash
mkdir build
```

Changez de répertoire pour accéder au répertoire de construction `build` :

```bash
cd build
```

Exécutez les commandes suivantes :

```bash
cmake ..
make
make install
```

Une fois terminé, le binaire `lsyncd` devrait être installé et prêt à être utilisé dans */usr/local/bin*

### `lsyncd` Systemd Service

Avec la méthode d'installation RPM, le service `systemd` sera installé pour vous, mais si vous choisissez d'installer à partir des sources, vous devrez créer ce service `systemd` vous-même. Bien que vous puissiez démarrer le logiciel sans le service systemd, vous devez vous assurer qu'il est bien *lancé* au démarrage du système. Sinon, un redémarrage du serveur arrêtera votre effort de synchronisation. Si vous oubliez de le redémarrer manuellement, cela posera problème !

La création du service `systemd` n'est pas très difficile et vous fera gagner beaucoup de temps à long terme.

#### Créer le fichier du service `lsyncd`

Ce fichier peut être créé n'importe où, même à la racine du système de fichiers de votre serveur. Une fois qu'il est créé, vous pouvez facilement le déplacer au bon endroit.

```bash
vi /root/lsyncd.service`
```

Le contenu de ce fichier sera le suivant :

```bash
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```

Installez le fichier que vous venez de créer à l'emplacement adéquat :

```bash
install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service
```

Enfin, rechargez le démon de `systemctl` pour que systemd "prenne en compte" le nouveau fichier service :

```bash
systemctl daemon-reload
```

## Configuration de `lsyncd`

Quelle que soit la méthode d'installation de `lsyncd`, vous aurez besoin d'un fichier de configuration : */etc/lsyncd.conf*. La section suivante vous indiquera comment construire un fichier de configuration et le tester.

### Exemple de configuration à tester

Voici un exemple de fichier de configuration simpliste qui synchronise */home* avec un autre ordinateur. Notre machine cible aura une adresse IP locale : *192.168.1.40*

```bash
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home",
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Décomposons un peu ces commandes :

- Les fichiers `logfile` et `statusFile` seront automatiquement créés au démarrage du service.
- La variable `statusInterval` représente le nombre de secondes à attendre avant d'écrire dans le fichier `statusFile`.
- `maxProcesses` est le nombre de processus que le service `lsyncd` est autorisé à créer. À moins que vous ne l'exécutiez sur une machine super occupée, un seul processus suffit.
- Dans la section de synchronisation `default.rsyncssh` il est indiqué d'utiliser `rsync` en combinaison avec `ssh`
- La variable `source=` indique le chemin du répertoire depuis lequel vous êtes en train de synchroniser
- La variable `host=` contient notre machine cible vers laquelle nous sommes en train de synchroniser
- La variable `excludeFrom=` indique à `lsyncd` où se trouve le fichier d'exclusions. Elle doit exister, mais elle peut être vide.
- La variable `targetdir=` indique le répertoire cible vers lequel vous envoyez des fichiers. Dans la plupart des cas, cela sera égal à la source, mais pas toujours.
- Ensuite, nous avons la section `rsync=` qui contient les options avec lesquelles nous exécutons `rsync`.
- La variable `ssh=` indique le port SSH qui est en train d'écouter sur la machine cible

Si vous ajoutez plusieurs répertoires à synchroniser, vous devez répéter toute la section `sync`, y compris toutes les parenthèses ouvrantes et fermantes pour chaque répertoire.

## Le fichier `lsyncd.exclude`

Comme il a été noté précédemment, le fichier `excludeFrom` doit exister. Créez ce fichier comme suit :

```bash
touch /etc/lsyncd.exclude
```

Par exemple, si vous synchronisez le dossier `/etc` sur votre ordinateur, il y aura de nombreux fichiers et répertoires que vous souhaiterez exclure du processus `lsyncd`. Chaque fichier ou répertoire exclu se trouve dans le fichier, un par ligne :

```bash
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test et Lancement du Service `lsyncd`

Maintenant que tout le reste est mis en place, nous pouvons tester l'ensemble. Assurez-vous que notre service systemd `lsyncd.service` va bien démarrer :

```bash
systemctl start lsyncd
```

Si aucune erreur n'apparaît après l'exécution de cette commande, vérifiez l'état du service, juste pour vous assurer :

```bash
systemctl status lsyncd
```

Si cela montre le service en cours d'exécution, utilisez tail pour examiner les deux fichiers de log et assurez-vous que tout s'affiche correctement :

```bash
tail /var/log/lsyncd.log
tail /var/log/lsyncd-status.log
```

En supposant que tout cela semble correct, accédez au répertoire `/home/[user]`, où `[user]` est un utilisateur sur l'ordinateur et créez un fichier avec la commande *touch*.

```bash
touch /home/[user]/testfile
```

Allez sur la machine cible et vérifiez si le fichier apparaît. Si tel est le cas, tout fonctionne comme il se doit. Définissez le service `lsyncd.service` pour qu'il soit lancé automatiquement au démarrage du système avec :

```bash
systemctl enable lsyncd
```

## N’oubliez Pas d'être Prudent

Chaque fois que vous synchronisez un ensemble de fichiers ou de répertoires sur une autre machine, réfléchissez soigneusement aux conséquences sur la machine cible. Si vous revenez au **fichier lsyncd.exclude** dans notre exemple ci-dessus, pouvez-vous imaginer ce qui pourrait arriver si vous omettez d'exclure */etc/fstab* ?

`fstab` est le fichier utilisé pour configurer les lecteurs de stockage sur n'importe quel ordinateur Linux. Les disques et les étiquettes sont presque certainement différents selon les machines. Le prochain redémarrage de l’ordinateur cible échouerait probablement complètement.

## Conclusion et Références

`lsyncd` est un outil efficace pour la synchronisation des répertoires entre machines. Comme vous avez pu le constater, il est plutôt facile à installer et il n’est pas difficile à entretenir par la suite.

Vous pouvez en savoir plus sur `lsyncd` en allant sur [le Site Officiel](https://github.com/axkibe/lsyncd)
