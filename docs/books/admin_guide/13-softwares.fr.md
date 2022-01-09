---
title: Gestion des logiciels
---

# Gestion des logiciels

## Généralités

Sur un système Linux, il est possible d’installer un logiciel de deux façons :

* En utilisant un paquet d’installation ;
* En compilant les fichiers sources.

!!! Note

    L'installation à partir des fichiers sources n'est pas couverte ici. En règle générale, vous devriez utiliser la méthode d'installation par paquet, à moins que le logiciel que vous voulez ne soit pas disponible via le gestionnaire de paquets. La raison à cela est que les dépendances sont généralement gérées par le système de paquets, tandis qu'avec les sources, vous devez gérer les dépendances manuellement.

**Le paquet** : Il s’agit d’un unique fichier comprenant toutes les données utiles à l’installation du programme. Il peut être exécuté directement sur le système à partir d’un dépôt logiciel.

**Les fichiers sources** : Certains logiciels ne sont pas fournis dans des paquets prêts à être installés mais via une archive contenant les fichiers sources. Charge à l’administrateur de préparer ces fichiers et de les compiler pour installer le programme.

## RPM : RedHat Package Manager

**RPM** (RedHat Package Manager) est un système de gestion des logiciels. Il est possible d’installer, de désinstaller, de mettre à jour ou de vérifier des logiciels contenus dans des paquets.

**RPM** est le format utilisé par toutes les distributions à base RedHat (RockyLinux, Fedora, CentOS, SuSe, Mandriva, …​). Son équivalent dans le monde de Debian est DPKG (Debian Package).

Le nom d’un paquet RPM répond à une nomenclature précise :

![Illustration d'un nom de paquet](images/software-001.png)

### La commande `rpm`

La commande rpm permet d’installer un paquet.

```
rpm [-i][-U] package.rpm [-e] package
```

Exemple (pour un paquet nommé 'package') :

```
[root]# rpm -ivh package.rpm
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

```
[root]# rpm -qa
```

Cette commande interroge tous les paquets installés sur le système.

```
rpm -q [-a][-i][-l] package [-f] file
```

Exemple :

```
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

!!! Warning

    Après l’option `-q`, le nom du paquet doit être exact. Les métacaractères (wildcards) ne sont pas gérés.

!!! Tip

    Il est cependant possible de lister tous les paquets installés et de filtrer avec la commande `grep`.

Exemple : lister les derniers paquets installés :

```
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

```
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Exemple : lister tous les paquets installés avec un nom spécifique en utilisant `grep` :

```
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos      
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF : Dandified Yum

**DNF** (**Dandified Yum**) est un gestionnaire de paquets logiciels, successeur de **YUM** (**Yellow dog **U**pdater **M**odified). Il fonctionne avec des paquets **RPM** regroupés dans un dépôt (un répertoire de stockage des paquets) local ou distant. Pour les commandes les plus courantes, son utilisation est identique à celle de `yum`.

La commande `dnf` permet la gestion des paquets en comparant ceux installés sur le système à ceux présents dans les dépôts définis sur le serveur. Elle permet aussi d’installer automatiquement les dépendances, si elles sont également présentes dans les dépôts.

`dnf` est le gestionnaire utilisé par de nombreuses distributions à base RedHat (RockyLinux, Fedora, CentOS, …​). Son équivalent dans le monde Debian est **APT** (**A**dvanced **P**ackaging **T**ool).

### La commande `dnf`

La commande `dnf` permet d’installer un paquet en ne spécifiant que le nom court.

```
dnf [install][remove][list all][search][info] package
```

Exemple :

```
[root]# dnf install tree
```

Seul le nom court du paquet est nécessaire.

| Option                    | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `install`                 | Installe le paquet.                            |
| `remove`                  | Désinstalle le paquet.                         |
| `list all`                | Liste les paquets déjà présents dans le dépôt. |
| `search`                  | Recherche un paquet dans le dépôt.             |
| `provides */command_name` | Recherche une commande.                        |
| `info`                    | Affiche les informations du paquet.            |

La commande `dnf list` liste tous les paquets installés sur le système et présents dans le dépôt. Elle accepte plusieurs paramètres :

| Paramètre   | Description                                                                  |
| ----------- | ---------------------------------------------------------------------------- |
| `all`       | Liste les paquets installés puis ceux disponibles sur les dépôts.            |
| `available` | Liste uniquement les paquets disponibles pour installation.                  |
| `updates`   | Liste les paquets pouvant être mis à jour.                                   |
| `obsoletes` | Liste les paquets rendus obsolètes par des versions supérieures disponibles. |
| `recent`    | Liste les derniers paquets ajoutés au dépôt.                                 |

Exemple de recherche de la commande `semanage` :

```
[root]# dnf provides */semanage
```

### Fonctionnement de YUM

Le gestionnaire DNF s’appuie sur un ou plusieurs fichiers de configuration afin de cibler les dépôts contenant les paquets RPM.

Ces fichiers sont situés dans `/etc/yum.repos.d/` et se terminent obligatoirement par `.repo` afin d’être exploités par DNF.

Exemple :

```
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Chaque fichier `.repo` est constituée au minimum des informations suivantes, une directive par ligne.

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

## Le dépôt EPEL

Le dépôt **EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) est un dépôt contenant des paquets logiciels supplémentaires pour Entreprise Linux, ce qui inclut RedHat Entreprise Linux (RHEL), RockyLinux, CentOS, etc.

### Installation

Télécharger et installer le rpm du dépôt :

Si vous êtes derrière un proxy internet :

```
[root]# export http_proxy=http://172.16.1.10:8080
```

Puis :

```
[root]# dnf install epel-release
```
