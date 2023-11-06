---
title: Gestion des logiciels
author: Antoine Le Morvan
contributors: Franco Colussi, Steven Spencer, Ganna Zhyrnova
tested version: 8.5
tags:
  - formation
  - logiciel
  - gestion de logiciels
---

# Gestion des logiciels

## Généralités

Sur un système GNU/Linux, il est possible d’installer un logiciel de deux façons :

* En utilisant un paquet d’installation ;
* En compilant les fichiers sources.

!!! note "Remarque"

    L'installation à partir des fichiers sources n'est pas couverte ici. En règle générale, vous devriez utiliser la méthode d'installation par paquet, à moins que le logiciel que vous voulez ne soit pas disponible via le gestionnaire de paquets. La raison à cela est que les dépendances sont généralement gérées par le système de paquets, tandis qu'avec les sources, vous devez gérer les dépendances manuellement.

**Le paquet** : Il s’agit d’un unique fichier comprenant toutes les données utiles à l’installation du programme. Il peut être exécuté directement sur le système à partir d’un dépôt logiciel.

**Les fichiers sources** : Certains logiciels ne sont pas fournis dans des paquets prêts à être installés mais via une archive contenant les fichiers sources. Charge à l’administrateur de préparer ces fichiers et de les compiler pour installer le programme.

## RPM : RedHat Package Manager

**RPM** (RedHat Package Manager) est un système de gestion des logiciels. Il est possible d’installer, de désinstaller, de mettre à jour ou de vérifier des logiciels contenus dans des paquets.

**RPM** est le format utilisé par toutes les distributions à base RedHat (Rocky Linux, Fedora, CentOS, SuSe, Mandriva,…​). Son équivalent dans le monde de Debian est DPKG (Debian Package).

Le nom d’un paquet RPM répond à une nomenclature précise :

![Illustration d'un nom de paquet](images/software-001.png)

### La commande `rpm`

La commande rpm permet d’installer un paquet.

```bash
rpm [-i][-U] package.rpm [-e] package
```

Exemple (pour un paquet nommé 'package') :

```bash
rpm -ivh package.rpm
```

| Option           | Description                              |
| ---------------- | ---------------------------------------- |
| `-i package.rpm` | Installe le paquet.                      |
| `-U package.rpm` | Met à jour un paquet déjà installé.      |
| `-e package.rpm` | Désinstalle le paquet.                   |
| `-h`             | Affiche une barre de progression.        |
| `-v`             | Informe sur l’avancement de l’opération. |
| `--test`         | Teste la commande sans l’exécuter.       |

La commande `rpm` permet aussi d’interroger la base de données des paquets du système en ajoutant l’option `-q`.

Il est possible d’exécuter plusieurs types de requêtes pour obtenir différentes informations sur les paquets installés. La base de donnée RPM se trouve dans le répertoire `/var/lib/rpm`.

Exemple :

```bash
rpm -qa
```

Cette commande interroge tous les paquets installés sur le système.

```bash
rpm -q [-a][-i][-l] package [-f] file
```

Exemple :

```bash
[root]# rpm -qil package
[root]# rpm -qf /path/to/file
```

| Option           | Description                                                                                                          |
| ---------------- | -------------------------------------------------------------------------------------------------------------------- |
| `-a`             | Liste tous les paquets installés sur le système.                                                                     |
| `-i __package__` | Affiche les informations du paquet.                                                                                  |
| `-l __package__` | Liste les fichiers contenus dans le paquet.                                                                          |
| `-f`             | Affiche le nom du paquet contenant le fichier précisé.                                                               |
| `--last`         | La liste des paquets est donnée par date d’installation (les derniers paquetages installés apparaissent en premier). |

!!! warning "Avertissement"

    Après l’option `-q`, le nom du paquet doit être exact. Les métacaractères (wildcards) ne sont pas gérés.

!!! tip "Astuce"

    Il est cependant possible de lister tous les paquets installés et de filtrer avec la commande `grep`.

Exemple : lister les derniers paquets installés :

```bash
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

Exemple : lister l’historique d’installation du kernel :

```bash
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Exemple : lister tous les paquets installés avec un nom spécifique en utilisant `grep` :

```bash
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF: Dandified Yum

**DNF** (**Dandified Yum**) est un gestionnaire de paquets logiciels, successeur de **YUM** (**Yellow dog **U**pdater **M**odified). Il fonctionne avec des paquets **RPM** regroupés dans un dépôt (un répertoire de stockage des paquets) local ou distant. Pour les commandes les plus courantes, son utilisation est identique à celle de `yum`.

La commande `dnf` permet la gestion des paquets en comparant ceux installés sur le système à ceux présents dans les dépôts définis sur le serveur. Elle permet aussi d’installer automatiquement les dépendances, si elles sont également présentes dans les dépôts.

`dnf` est le gestionnaire utilisé par de nombreuses distributions à base RedHat (Rocky Linux, Fedora, CentOS, …​). Son équivalent dans le monde Debian est **APT** (**A**dvanced **P**ackaging **T**ool).

### La commande `dnf`

La commande `dnf` permet d’installer un paquet en ne spécifiant que le nom court.

```bash
dnf [install][remove][list all][search][info] package
```

Exemple :

```bash
dnf install tree
```

Seul le nom court du paquet est nécessaire.

| Option                    | Description                                                                                    |
| ------------------------- | ---------------------------------------------------------------------------------------------- |
| `install`                 | Installe le paquet.                                                                            |
| `remove`                  | Désinstalle le paquet.                                                                         |
| `list all`                | Liste les paquets déjà présents dans le dépôt.                                                 |
| `search`                  | Recherche un paquet dans le dépôt.                                                             |
| `provides */command_name` | Recherche une commande.                                                                        |
| `info`                    | Affiche les informations du paquet.                                                            |
| `autoremove`              | Supprime tous les paquets installés en tant que dépendances mais qui ne sont plus nécessaires. |


La commande `dnf install` vous permet d'installer le paquet désiré sans vous soucier de ses dépendances, qui seront résolues directement par `dnf` lui-même.

```bash
dnf install nginx
Last metadata expiration check: 3:13:41 ago on Wed 23 Mar 2022 07:19:24 AM CET.
Dependencies resolved.
============================================================================================================================
 Package                             Architecture    Version                                        Repository         Size
============================================================================================================================
Installing:
 nginx                               aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream         543 k
Installing dependencies:
 nginx-all-modules                   noarch          1:1.14.1-9.module+el8.4.0+542+81547229         appstream          22 k
 nginx-mod-http-image-filter         aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          33 k
 nginx-mod-http-perl                 aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          44 k
 nginx-mod-http-xslt-filter          aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          32 k
 nginx-mod-mail                      aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          60 k
 nginx-mod-stream                    aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          82 k

Transaction Summary
============================================================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.2 M
Is this ok [y/N]:
```

Dans le cas où vous ne vous souvenez pas du nom exact du paquet, vous pouvez le rechercher avec la commande `dnf search name`. Comme vous pouvez le voir, il y a une section qui contient le nom exact et une autre qui contient la correspondance du paquet, tous ces éléments sont mis en évidence pour faciliter la recherche.

```bash
dnf search nginx
Last metadata expiration check: 0:20:55 ago on Wed 23 Mar 2022 10:40:43 AM CET.
=============================================== Name Exactly Matched: nginx ================================================
nginx.aarch64 : A high performance web server and reverse proxy server
============================================== Name & Summary Matched: nginx ===============================================
collectd-nginx.aarch64 : Nginx plugin for collectd
munin-nginx.noarch : NGINX support for Munin resource monitoring
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-filesystem.noarch : The basic directory layout for the Nginx server
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
pagure-web-nginx.noarch : Nginx configuration for Pagure
pcp-pmda-nginx.aarch64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver
python3-certbot-nginx.noarch : The nginx plugin for certbot
```

Le gestionnaire DNF s’appuie sur un ou plusieurs fichiers de configuration afin de cibler les dépôts contenant les paquets RPM.

```bash
dnf search nginx | grep mod
Last metadata expiration check: 3:44:49 ago on Wed 23 Mar 2022 06:16:47 PM CET.
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
```


La commande `dnf remove` supprime un paquet du système et ses dépendances. Voici un extrait de la commande **dnf remove httpd**.

```bash
dnf remove httpd
Dependencies resolved.
============================================================================================================================
 Package                        Architecture    Version                                            Repository          Size
============================================================================================================================
Removing:
 httpd                          aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         8.9 M
Removing dependent packages:
 mod_ssl                        aarch64         1:2.4.37-43.module+el8.5.0+727+743c5577.1          @appstream         274 k
 php                            aarch64         7.4.19-1.module+el8.5.0+696+61e7c9ba               @appstream         4.4 M
 python3-certbot-apache         noarch          1.22.0-1.el8                                       @epel              539 k
Removing unused dependencies:
 apr                            aarch64         1.6.3-12.el8                                       @appstream         299 k
 apr-util                       aarch64         1.6.1-6.el8.1                                      @appstream         224 k
 apr-util-bdb                   aarch64         1.6.1-6.el8.1                                      @appstream          67 k
 apr-util-openssl               aarch64         1.6.1-6.el8.1                                      @appstream          68 k
 augeas-libs                    aarch64         1.12.0-6.el8                                       @baseos            1.4 M
 httpd-filesystem               noarch          2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         400
 httpd-tools                    aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1
...
```

La commande `dnf list` liste tous les paquets installés sur le système ou présents dans le dépôt. Elle accepte plusieurs paramètres :

| Paramètre   | Description                                                                  |
| ----------- | ---------------------------------------------------------------------------- |
| `all`       | Liste les paquets installés puis ceux disponibles sur les dépôts.            |
| `available` | Liste uniquement les paquets disponibles pour installation.                  |
| `updates`   | Liste les paquets pouvant être mis à jour.                                   |
| `obsoletes` | Liste les paquets rendus obsolètes par des versions supérieures disponibles. |
| `recent`    | Liste les derniers paquets ajoutés au dépôt.                                 |

La commande `dnf info` fournit des informations détaillées sur un paquet :

```bash
dnf info firewalld
Last metadata expiration check: 15:47:27 ago on Tue 22 Mar 2022 05:49:42 PM CET.
Installed Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8
Architecture : noarch
Size         : 2.0 M
Source       : firewalld-0.9.3-7.el8.src.rpm
Repository   : @System
From repo    : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.

Available Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8_5.1
Architecture : noarch
Size         : 501 k
Source       : firewalld-0.9.3-7.el8_5.1.src.rpm
Repository   : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.
```

Parfois, vous ne connaissez que l'exécutable que vous souhaitez utiliser, mais pas le paquet qui le contient. Dans ce cas, vous pouvez utiliser la commande `dnf provides */paquet` qui cherchera dans la base de données la correspondance souhaitée.

Exemple de recherche de la commande `semanage` :

```bash
dnf provides */semanage
Last metadata expiration check: 1:12:29 ago on Wed 23 Mar 2022 10:40:43 AM CET.
libsemanage-devel-2.9-6.el8.aarch64 : Header files and libraries used to build policy manipulation tools
Repo        : powertools
Matched from:
Filename    : /usr/include/semanage

policycoreutils-python-utils-2.9-16.el8.noarch : SELinux policy core python utilities
Repo        : baseos
Matched from:
Filename    : /usr/sbin/semanage
Filename    : /usr/share/bash-completion/completions/semanage
```

La commande `dnf autoremove` ne nécessite aucun paramètre. DNF s'occupe de la recherche de paquets candidats à la suppression.

```bash
dnf autoremove
Last metadata expiration check: 0:24:40 ago on Wed 23 Mar 2022 06:16:47 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
```

### Autres options utiles de `dnf`

| Option      | Description                                   |
| ----------- | --------------------------------------------- |
| `repolist`  | Liste les dépôts configurés sur le système.   |
| `grouplist` | Liste les collections de paquets disponibles. |
| `clean`     | Supprime les fichiers temporaires.            |

La commande `dnf repolist` liste les dépôts configurés sur le système. Par défaut, il liste uniquement les dépôts activés, mais peut être utilisé avec ces paramètres :

| Paramètre    | Observation                             |
| ------------ | --------------------------------------- |
| `--all`      | Liste tous les dépôts.                  |
| `--enabled`  | Par défaut                              |
| `--disabled` | Liste uniquement les dépôts désactivés. |

Exemple :

```bash
dnf repolist
repo id                                                  repo name
appstream                                                Rocky Linux 8 - AppStream
baseos                                                   Rocky Linux 8 - BaseOS
epel                                                     Extra Packages for Enterprise Linux 8 - aarch64
epel-modular                                             Extra Packages for Enterprise Linux Modular 8 - aarch64
extras                                                   Rocky Linux 8 - Extras
powertools                                               Rocky Linux 8 - PowerTools
rockyrpi                                                 Rocky Linux 8 - Rasperry Pi
```

Et un extrait de la commande avec l'indicateur `--all`.

```bash
dnf repolist --all

...
repo id                                             repo name                                                                                       status
appstream                                           Rocky Linux 8 - AppStream                                                                       enabled
appstream-debug                                     Rocky Linux 8 - AppStream - Source                                                              disabled
appstream-source                                    Rocky Linux 8 - AppStream - Source                                                              disabled
baseos                                              Rocky Linux 8 - BaseOS                                                                          enabled
baseos-debug                                        Rocky Linux 8 - BaseOS - Source                                                                 disabled
baseos-source                                       Rocky Linux 8 - BaseOS - Source                                                                 disabled
devel                                               Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE                                       disabled
epel                                                Extra Packages for Enterprise Linux 8 - aarch64                                                 enabled
epel-debuginfo                                      Extra Packages for Enterprise Linux 8 - aarch64 - Debug                                         disabled
epel-modular                                        Extra Packages for Enterprise Linux Modular 8 - aarch64                                         enabled
epel-modular-debuginfo                              Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug                                 disabled
epel-modular-source                                 Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
...
```

Et ci-dessous voilà un extrait de la liste des dépôts désactivés.

```bash
dnf repolist --disabled
repo id                                 repo name
appstream-debug                         Rocky Linux 8 - AppStream - Source
appstream-source                        Rocky Linux 8 - AppStream - Source
baseos-debug                            Rocky Linux 8 - BaseOS - Source
baseos-source                           Rocky Linux 8 - BaseOS - Source
devel                                   Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
epel-debuginfo                          Extra Packages for Enterprise Linux 8 - aarch64 - Debug
epel-modular-debuginfo                  Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug
epel-modular-source                     Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
epel-source                             Extra Packages for Enterprise Linux 8 - aarch64 - Source
epel-testing                            Extra Packages for Enterprise Linux 8 - Testing - aarch64
...
```

L'utilisation de l'option `-v` améliore la liste avec beaucoup d'informations supplémentaires. Ci-dessous vous pouvez voir une partie du résultat de la commande.

```bash
dnf repolist -v

...
Repo-id            : powertools
Repo-name          : Rocky Linux 8 - PowerTools
Repo-revision      : 8.5
Repo-distro-tags      : [cpe:/o:rocky:rocky:8]:  ,  , 8, L, R, c, i, k, n, o, u, x, y
Repo-updated       : Wed 16 Mar 2022 10:07:49 PM CET
Repo-pkgs          : 1,650
Repo-available-pkgs: 1,107
Repo-size          : 6.4 G
Repo-mirrors       : https://mirrors.rockylinux.org/mirrorlist?arch=aarch64&repo=PowerTools-8
Repo-baseurl       : https://mirror2.sandyriver.net/pub/rocky/8.8/PowerTools/x86_64/os/ (30 more)
Repo-expire        : 172,800 second(s) (last: Tue 22 Mar 2022 05:49:24 PM CET)
Repo-filename      : /etc/yum.repos.d/Rocky-PowerTools.repo
...
```

!!! info "Utilisation des Groupes"

    Les groupes sont un ensemble de paquets (vous pouvez considérer un groupe comme un paquet virtuel) qui groupent logiquement un ensemble d'applications pour accomplir un but (un environnement de bureau, un serveur, des outils de développement, etc.).

La commande `dnf grouplist` liste tous les groupes disponibles.

```bash
dnf grouplist
Last metadata expiration check: 1:52:00 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   KDE Plasma Workspaces
   Custom Operating System
Available Groups:
   Container Management
   .NET Core Development
   RPM Development Tools
   Development Tools
   Headless Management
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
```

La commande `dnf groupinstall` vous permet d'installer l'un de ces groupes.

```bash
dnf groupinstall "Network Servers"
Last metadata expiration check: 2:33:26 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Dependencies resolved.
================================================================================
 Package           Architecture     Version             Repository         Size
================================================================================
Installing Groups:
 Network Servers

Transaction Summary
================================================================================

Is this ok [y/N]:
```

Notez qu'il est bon de placer le nom du groupe entre guillemets " " car sans la commande, il ne s'exécutera correctement que si le nom du groupe ne contient aucun espace.

Donc une commande `dnf groupinstall Network Servers` produit l'erreur suivante :

```bash
dnf groupinstall Network Servers
Last metadata expiration check: 3:05:45 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Module or Group 'Network' is not available.
Module or Group 'Servers' is not available.
Error: Nothing to do.
```

La commande correspondante pour supprimer un groupe est `dnf groupremove "name group"`.

La commande `dnf clean` nettoie tous les caches et fichiers temporaires créés par `dnf`. Il peut être utilisé avec les paramètres suivants :

| Paramètres     | Observation                                                           |
| -------------- | --------------------------------------------------------------------- |
| `all`          | Supprime tous les fichiers temporaires créés pour les dépôts activés. |
| `dbcache`      | Supprime les fichiers de cache des métadonnées du dépôt.              |
| `expire-cache` | Supprime les fichiers cookies locaux.                                 |
| `métadonnées`  | Supprime toutes les métadonnées des dépôts.                           |
| `paquets`      | Supprime tous les paquets mis en cache.                               |


### Comment fonctionne DNF

Le gestionnaire DNF s’appuie sur un ou plusieurs fichiers de configuration afin de cibler les dépôts contenant les paquets RPM.

Ces fichiers sont situés dans `/etc/yum.repos.d/` et se terminent obligatoirement par `.repo` afin d’être exploités par DNF.

Exemple :

```bash
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Chaque fichier `.repo` contient au minimum les informations suivantes, une directive par ligne :

Exemple :

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

Par défaut, la directive `enabled` est absente ce qui signifie que le dépôt est activé. Pour désactiver un dépôt, il faut spécifier la directive `enabled=0`.

## Modules DNF

Les modules ont été introduits dans Rocky Linux 8 par le système upstream. Afin d'utiliser des modules, le dépôt AppStream doit exister et être activé.

!!! hint "Package Confusion"

    La création de modules streams dans le dépôt AppStream a causé beaucoup de confusion. Puisque les modules sont empaquetés dans un flux (stream, voir nos exemples ci-dessous), un paquet particulier s'affichera dans nos RPMs, mais si une tentative était faite pour l'installer sans activer le module, rien ne se passerait. N'oubliez pas de regarder les modules si vous essayez d'installer un paquet et qu'il ne le trouve pas.

### Que sont les modules ?

Les modules proviennent du dépôt AppStream et contiennent à la fois des flux et des profils. Ceux-ci peuvent être décrits comme suit:

* **module streams :** Un module stream peut être considéré comme un dépôt séparé dans le dépôt AppStream qui contient des versions différentes d'applications. Ces dépôts de modules contiennent les RPMs de l'application, les dépendances et la documentation de ce flux particulier. Un exemple de module stream dans Rocky Linux 8 serait `postgresql`. Si vous installez `postgresql` en utilisant la commande standard `sudo dnf install postgresql` vous obtiendrez la version 10. Cependant, en utilisant les modules, vous pouvez installer les versions 9.6, 12 ou 13.

* **profils de module :** Ce que fait un profil de module c'est de prendre en compte le cas d'utilisation pour le flux de module lors de l'installation du package. Appliquer un profil ajuste les RPMs, les dépendances et la documentation du paquet pour tenir compte de l'utilisation du module. En utilisant le même flux `postgresql` dans notre exemple, vous pouvez appliquer un profil de "serveur" ou "client". Évidemment, vous n'avez pas besoin des mêmes paquets installés sur votre système si vous allez juste utiliser `postgresql` comme client pour accéder à un serveur.

### Liste des modules

Vous pouvez obtenir une liste de tous les modules en exécutant la commande suivante :

```
dnf module list
```

Vous obtenez ainsi une longue liste des modules disponibles et des profils qui peuvent être utilisés pour ceux-ci. Le fait est que vous savez probablement déjà quel paquet vous intéresse, ainsi pour savoir s'il existe des modules pour un paquet particulier, ajoutez le nom du paquet après « liste ». Nous allons de nouveau utiliser notre exemple de paquet `postgresql` ici :

```
dnf module list postgresql
```

Cela devrait fournir le résultat suivant :

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Notez le "[d]" dans la liste. Cela signifie que c'est la valeur par défaut. Il indique que la version par défaut est 10 et que quelle que soit la version que vous choisissez, si vous ne spécifiez pas de profil, le profil du serveur sera utilisé, qui est également celui par défaut.

### Prise en charge des modules

En utilisant notre paquet `postgresql`, supposons que nous voulions activer la version 12. Pour ce faire, il suffit d'utiliser la procédure suivante :

```
dnf module enable postgresql:12
```

Ici, la commande enable requiert le nom du module suivi par un deux points ":" et le nom du flux.

Pour vérifier que le stream du module `postgresql` version 12 a été activé, utilisez à nouveau la commande list qui devrait afficher le résultat suivant :

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12 [e]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Ici, vous pouvez voir le symbole "[e]" pour "activé" à côté du flux 12, nous savons donc que la version 12 est activée.

### Installation de paquets depuis le flux du module

Maintenant que notre flux de module est activé, l'étape suivante est d'installer `postgresql`, l'application client pour le serveur postgresql. Cela peut être réalisé en exécutant la commande suivante :

```
dnf install postgresql
```

Ce qui devrait donner le résultat suivant :

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k

Transaction Summary
========================================================================================================================================
Install  2 Packages
Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Après avoir approuvé en tapant "y", l'application sera installée.

### Installation de paquets depuis les profils des modules de flux

Vous pouvez aussi installer directement des paquets sans même avoir à activer le streaming de modules ! Dans cet exemple, supposons que nous voulons appliquer le profil client uniquement à notre installation. Pour ce faire, entrez simplement cette commande :

```
dnf install postgresql:12/client
```

Ce qui devrait fournir le résultat suivant :

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k
Installing module profiles:
 postgresql/client
Enabling module streams:
 postgresql                                        12

Transaction Summary
========================================================================================================================================
Install  2 Packages

Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

En répondant « y » à l'invite, vous installerez tout ce dont vous avez besoin pour utiliser postgresql version 12 en tant que client.

### Retrait et réinitialisation du module ou commutation (Switch-To)

Après l'installation, vous pouvez décider que, pour quelque raison que ce soit, vous avez besoin d'une version différente du stream. La première étape consiste en la suppression des paquets. En utilisant à nouveau notre paquet `postgresql`, nous le ferons avec la commande suivante :

```
dnf remove postgresql
```

Cela affichera une sortie similaire à la procédure d'installation ci-dessus, sauf qu'il supprimera le paquet et toutes ses dépendances. Répondez "y" à l'invite et appuyez sur la touche entrée pour désinstaller `postgresql`.

Une fois cette étape terminée, vous pouvez lancer la commande de réinitialisation pour le module en utilisant la commande suivante :

```
dnf module reset postgresql
```

Ce qui vous donnera un résultat comme cela :

```
Dependencies resolved.
========================================================================================================================================
 Package                         Architecture                   Version                           Repository                       Size
========================================================================================================================================
Disabling module profiles:
 postgresql/client                                                                                                                     
Resetting modules:
 postgresql                                                                                                                            

Transaction Summary
========================================================================================================================================

Is this ok [y/N]:
```

Répondre "y" à l'invite réinitialisera alors `postgresql` au stream par défaut, le flux que nous avions activé (12 dans notre exemple) n'étant plus activé :

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Vous pouvez maintenant utiliser la valeur par défaut.

Vous pouvez aussi utiliser la sous-commande de commutation pour passer d'un flux activé à un autre. L'utilisation de cette méthode non seulement passe au nouveau stream, mais installe les paquets nécessaires (downgrade ou mise à jour) sans étape séparée. Pour utiliser cette méthode afin d'activer le flux `postgresql` en version 13 et utiliser le profil "client", vous pouvez utiliser la commande suivante :

```
dnf module switch-to postgresql:13/client
```

### Désactiver un flux de module

Il peut arriver que vous vouliez désactiver la possibilité d'installer des paquets à partir d'un stream de module. Dans le cas de notre exemple `postgresql`, cela peut être dû au fait que vous vouliez utiliser le dépôt directement depuis [PostgreSQL](https://www.postgresql.org/download/linux/redhat/) afin que vous puissiez utiliser une version plus récente (au moment où nous écrivons, les versions 14 et 15 sont disponibles à partir de ce dépôt). La désactivation d'un flux de module rend impossible l'installation de ces paquets sans les réactiver au préalable.

Pour désactiver les flux de module pour `postgresql` il suffit d'utiliser la commande suivante :

```
dnf module disable postgresql
```

Et si vous listez à nouveau les modules `postgresql`, vous verrez ce qui suit montrant toutes les versions de module `postgresql` désactivées :

```
Rocky Linux 8 - AppStream
Name                       Stream                   Profiles                          Summary                                           
postgresql                 9.6 [x]                  client, server [d]                PostgreSQL server and client module               
postgresql                 10 [d][x]                client, server [d]                PostgreSQL server and client module               
postgresql                 12 [x]                   client, server [d]                PostgreSQL server and client module               
postgresql                 13 [x]                   client, server [d]                PostgreSQL server and client module
```

## Le dépôt EPEL

### Qu'est-ce que l'EPEL et comment est-il utilisé ?

Le dépôt **EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) est un dépôt contenant des paquets logiciels supplémentaires pour Entreprise Linux, ce qui inclut RedHat Entreprise Linux (RHEL), Rocky Linux, CentOS, etc.

Il fournit des paquets qui ne sont pas inclus dans les dépôts officiels de RHEL. Ils ne sont pas inclus parce qu'ils ne sont pas considérés comme nécessaires dans un environnement d'entreprise ou considérés en dehors du champ d'application de RHEL. Nous ne devons pas oublier que RHEL est une distribution de classe entreprise et les utilitaires de bureau ou autres logiciels spécialisés peuvent ne pas être une priorité pour un projet d'entreprise.

### Installation

L'installation des fichiers nécessaires peut se faire facilement avec le paquet fourni par défaut par Rocky Linux.

Si vous êtes derrière un proxy internet :

```bash
export http_proxy=http://172.16.1.10:8080
```

Puis :

```bash
dnf install epel-release
```

Une fois installé, vous pouvez vérifier que le paquet a été installé correctement avec la commande `dnf info`.

```bash
dnf info epel-release
Last metadata expiration check: 1:30:29 ago on Thu 24 Mar 2022 09:36:42 AM CET.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 14.el8
Architecture : noarch
Size         : 32 k
Source       : epel-release-8-14.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux
             : (EPEL) repository GPG key as well as configuration for yum.
```

Le paquet, comme vous pouvez le voir dans la description du paquet ci-dessus, ne contient pas d'exécutables, de bibliothèques, etc. , mais seulement les fichiers de configuration et les clés GPG pour configurer le dépôt.

Une autre façon de vérifier que l'installation est correcte est d'interroger la base de données rpm.

```bash
rpm -qa | grep epel
epel-release-8-14.el8.noarch
```

Maintenant vous devez exécuter une mise à jour pour permettre à `dnf` de reconnaître le dépôt. Il vous sera demandé d'accepter les clés GPG des dépôts. Il est clair que vous devez répondre YES pour pouvoir les utiliser.

```bash
dnf update
```

Une fois la mise à jour terminée, vous pouvez vérifier que le dépôt a été configuré correctement avec la commande `dnf repolist` qui devrait maintenant lister les nouveaux dépôts.

```bash
dnf repolist
repo id            repo name
...
epel               Extra Packages for Enterprise Linux 8 - aarch64
epel-modular       Extra Packages for Enterprise Linux Modular 8 - aarch64
...
```

Les fichiers de configuration du dépôt se trouvent dans `/etc/yum.repos.d/`.

```
ll /etc/yum.repos.d/ | grep epel
-rw-r--r--. 1 root root 1485 Jan 31 17:19 epel-modular.repo
-rw-r--r--. 1 root root 1422 Jan 31 17:19 epel.repo
-rw-r--r--. 1 root root 1584 Jan 31 17:19 epel-testing-modular.repo
-rw-r--r--. 1 root root 1521 Jan 31 17:19 epel-testing.repo
```

Et ci-dessous, nous pouvons voir le contenu du fichier `epel.repo`.

```bash
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Debug
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place it's address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1
```

### Utilisation d'EPEL

À ce stade, une fois configuré, nous sommes prêts à installer des paquets depuis l'EPEL. Pour commencer, nous pouvons lister les paquets disponibles dans le référentiel avec la commande suivante :

```bash
dnf --disablerepo="*" --enablerepo="epel" list available
```

Et un extrait de la commande

```bash
dnf --disablerepo="*" --enablerepo="epel" list available | less
Last metadata expiration check: 1:58:22 ago on Fri 25 Mar 2022 09:23:29 AM CET.
Available Packages
3proxy.aarch64                                                    0.8.13-1.el8                                    epel
AMF-devel.noarch                                                  1.4.23-2.el8                                    epel
AMF-samples.noarch                                                1.4.23-2.el8                                    epel
AusweisApp2.aarch64                                               1.22.3-1.el8                                    epel
AusweisApp2-data.noarch                                           1.22.3-1.el8                                    epel
AusweisApp2-doc.noarch                                            1.22.3-1.el8                                    epel
BackupPC.aarch64                                                  4.4.0-1.el8                                     epel
BackupPC-XS.aarch64                                               0.62-1.el8                                      epel
BibTool.aarch64                                                   2.68-1.el8                                      epel
CCfits.aarch64                                                    2.5-14.el8                                      epel
CCfits-devel.aarch64                                              2.5-14.el8                                      epel
...
```

À partir de la commande nous pouvons voir que pour installer à partir de l'EPEL, nous devons forcer **dnf** à interroger le dépôt demandé avec les options `--disablerepo` et `--enablerepo`. C'est parce que sinon une correspondance trouvée dans d'autres dépôts optionnels (RPM Fusion, REMI, ELRepo, etc.), pourrait être plus récente et donc avoir la priorité. Ces options ne sont pas nécessaires si vous avez installé uniquement EPEL comme référentiel optionnel car les paquets du référentiel ne seront jamais disponibles dans les paquets officiels. Au moins dans la même version !

!!! attention "Considérations relatives au support"

    Un aspect à considérer en ce qui concerne le support (mises à jour, corrections de bogues, patchs de sécurité) est que les paquets EPEL n'ont pas de support officiel de RHEL et techniquement leur vie pourrait durer seulement l'espace d'un développement de Fedora (six mois) puis disparaître. Il s’agit d’une possibilité lointaine, mais elle devrait être envisagée.

Ainsi, pour installer un paquet à partir des dépôts EPEL que vous pouvez utiliser la commande suivante :

```bash
dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 2:01:36 ago on Fri 25 Mar 2022 04:28:04 PM CET.
Dependencies resolved.
==============================================================================================================================================================
 Package                            Architecture                          Version                                    Repository                          Size
==============================================================================================================================================================
Installing:
 nmon                               aarch64                               16m-1.el8                                  epel                                71 k

Transaction Summary
==============================================================================================================================================================
Install  1 Package

Total download size: 71 k
Installed size: 214 k
Is this ok [y/N]:
```

### Conclusion

EPEL n'est pas un référentiel officiel pour RHEL, mais il peut être très utile pour les administrateurs et les développeurs qui travaillent avec RHEL ou un de ses dérivés, et qui ont besoin de quelques utilitaires préparés pour RHEL à partir d'une source dont ils peuvent avoir confiance.

## Plugiciels DNF

Le paquet `dnf-plugins-core` ajoute des plugiciels à `dnf` qui seront utiles pour gérer vos dépôts.

!!! note "Remarque"

    Des informations plus détaillées sont disponibles ici : 
    https://dnf-plugins-core.readthedocs.io/en/latest/index.html

Installer le paquet sur votre système :

```
dnf install dnf-plugins-core
```

Tous les plugins ne seront pas présentés ici, mais vous pouvez vous référer à la documentation du paquet pour une liste complète des plugins et des informations détaillées.

### Plugiciel `config-manager`

Gestion des options DNF, ajouter des dépôts ou les désactiver.

Exemples :

* Télécharger un fichier `.repo` et l'utiliser :

```
dnf config-manager --add-repo https://packages.centreon.com/ui/native/rpm-standard/23.04/el8/centreon-23.04.repo
```

* Vous pouvez également définir une url comme une url de base pour un repo :

```
dnf config-manager --add-repo https://repo.rocky.lan/repo
```

* Activer ou désactiver une ou plusieurs repos :

```
dnf config-manager --set-enabled epel centreon
dnf config-manager --set-disabled epel centreon
```

* Ajouter un proxy à votre fichier de configuration :

```
dnf config-manager --save --setopt=*.proxy=http://proxy.rocky.lan:3128/
```

### Plugin `copr`

`copr` est un forgeage automatique de rpm, fournissant un dépôt avec les paquets construits.

* Activer un dépôt de copr :

```
copr enable xxxx
```

### `Télécharger` le plugin

Télécharger le paquet rpm au lieu de l'installer :

```
dnf download ansible
```

Si vous voulez juste obtenir l'url de l'emplacement distant du paquet :

```
dnf download --url ansible
```

Ou si vous voulez également télécharger les dépendances :

```
dnf download --resolv --alldeps ansible
```

### Plugiciel `needs-restarting`

Après avoir exécuté une mise à jour avec `dnf update`, les processus en cours d'exécution continueront à s'exécuter, mais avec les anciens binaires. Afin de prendre en compte les changements de code et en particulier les mises à jour de sécurité, ils doivent être redémarrés.

Le plugin `needs-restarting` vous permettra de détecter les processus qui sont dans ce cas.

```
dnf needs-restarting [-u] [-r] [-s]
```

| Options | Observation                                                             |
| ------- | ----------------------------------------------------------------------- |
| `-u`    | Considérez uniquement les processus appartenant à l'utilisateur actuel. |
| `-r`    | pour vérifier si un redémarrage peut être nécessaire.                   |
| `-s`    | pour vérifier si les services ont besoin d'être redémarrés.             |
| `-s -r` | pour faire les deux en une seule étape.                                 |

### Plugiciel `versionlock`

Parfois, il est utile de protéger des paquets de toutes les mises à jour ou d'exclure certaines versions d'un paquet (à cause de problèmes connus par exemple). Pour cela, le plugin versionlock sera d'une grande utilité.

Il vous faut installer un paquet supplémentaire :

```
dnf install python3-dnf-plugin-versionlock
```

Exemples :

* Verrouiller la version d'ansible :

```
dnf versionlock add ansible
Adding versionlock on: ansible-0:6.3.0-2.el9.*
```

* Liste des paquets verrouillés :

```
dnf versionlock list
ansible-0:6.3.0-2.el9.*
```
