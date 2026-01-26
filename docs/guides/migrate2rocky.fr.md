---
title: Migrer vers Rocky Linux
author: Ezequiel Bruni
contributors: Tianci Li, Steven Spencer, Sébastien Poher
update: 2021-11-23
---

# Comment migrer vers Rocky Linux depuis CentOS Stream, CentOS, Alma Linux, RHEL ou Oracle Linux

## Prérequis

- CentOS Stream, CentOS, Alma Linux, RHEL ou Oracle Linux fonctionnant correctement sur un serveur physique ou virtuel (VPS) ; Par opposition à CentOS-Stream, CentOS-Linux ne sera sera disponible que jusqu'à la version 8.5. La version actuellement prise en charge pour les autres systèmes est la **8.10** respectivement **9.6**. La version 10 n'est pas encore prise en charge.
- Une bonne connaissance de la ligne de commande
- Être à l'aise avec l'usage de SSH dans le cas de machines distantes 
- Une capacité à accepter les risques.
- Toutes les commandes doivent être exécutées en tant qu'utilisateur root. Connectez vous directement en tant que root ou faites un usage fréquent de sudo.

## Introduction

Dans ce guide, vous apprendrez comment convertir tous les systèmes d'exploitation (OS) listés ci-dessus en installations Rocky Linux parfaitement fonctionnelles. C'est probablement l'un des moyens les moins directs d'installer Rocky Linux mais il peut être pratique pour certains d'entre vous dans de nombreux cas.

Par exemple dans le cas de certains hébergeurs qui ne fournissent pas encore de VPS avec Rocky Linux. Ou encore si vous avez un serveur de production que vous voulez convertir en Rocky Linux sans avoir à tout réinstaller.

Nous avons l'outil adéquat pour vous : [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

Il s'agît d'un script qui, lors de son exécution, va changer tous vos dépôts par ceux de Rocky Linux. Les paquets seront installés, mis à jour ou rétrogradés lorsque nécessaire et toutes les marques, noms et logos seront également modifiés.

Pas d'inquiétude si vous êtes débutant en administration système, ce guide sera aussi convivial que possible. Du moins autant que peut l'être la ligne de commande.

### Mises en garde préalables

1. Prenez connaissance du README de migrate2rocky, il y a en effet une incompatibilité connue entre le script et les dépôts de Katello. Au fil du temps, il est probable que nous découvrions (et finalement corrigions) plus d'incompatibilités, vous devez donc en être conscients, particulièrement pour des serveurs en production.
2. Ce script est plus susceptible de fonctionner sans incident sur des installations complètement nouvelles. _Si vous souhaitez convertir un serveur de production, par pitié, **faites une sauvegarde des données et un instantané (snapshot) du système, ou faites-le d'abord dans un environnement de test.**_

Êtes-vous prêts ?

## Préparez votre serveur

Vous devez récupérer le fichier de script depuis le dépôt. Cela peut être fait de plusieurs façons.

### La méthode manuelle

Téléchargez les fichiers compressés depuis GitHub et extrayez celui dont vous avez besoin (à savoir *migrate2rocky.sh* ou bien * migrate2rocky9.sh*). Vous pouvez trouver les fichiers zip de n'importe quel dépôt GitHub sur le côté droit de la page principale du dépôt :

![Le bouton "Télécharger Zip"](images/migrate2rocky-github-zip.png)

Ensuite, téléchargez l'exécutable sur votre serveur avec ssh en exécutant cette commande sur votre machine locale :

!!! note "Remarque"
    Si vous utilisez un système 9.x, ajoutez un 9 avant le suffixe `.sh`

```bash
scp PATH/TO/FILE/migrate2rocky.sh root@votredomaine.com:/home/
```

Bien entendu, ajustez tous les chemins de fichiers et les domaines de serveur ou les adresses IP selon vos besoins.

### La méthode `git`

Installez `git` sur votre serveur avec la commande suivante :

```bash
dnf install git
```

Ensuite, clonez le dépôt rocky-tools avec :

```git
git clone https://github.com/rocky-linux/rocky-tools.git
```

Remarque : cette méthode téléchargera tous les scripts et fichiers du dépôt rocky-tools.

### La manière simple

C'est surement la façon la plus facile pour obtenir le script. Vous aurez seulement besoin d'un client HTTP adéquat (`curl, wget, lynx,` etc.) installé sur le serveur.

En supposant que vous ayez installé l'utilitaire `curl`, exécutez la commande suivante pour télécharger le script dans le répertoire que vous utilisez :

!!! note "Remarque"
    Si vous utilisez un système 9.x, ajoutez un 9 avant le suffixe `.sh`

```bash
curl -O https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh
```

Cette commande téléchargera le fichier directement sur votre serveur et *uniquement* le fichier que vous voulez. Mais encore une fois, cela peut poser des problèmes de sécurité impliquant que ce n'est pas nécessairement la meilleure pratique, alors gardez cela à l'esprit.

## Exécution du script et installation

Utilisez la commande `cd` pour basculer vers le répertoire où se trouve le script, assurez-vous que le fichier est exécutable et accordez au propriétaire du fichier de script les autorisations `x`.

!!! note "Remarque"
    Pour les commandes suivantes, si vous utilisez un système 9.x, ajoutez un 9 avant le suffixe `.sh`

```bash
chmod u+x migrate2rocky.sh
```

Finalement, exécutez le script :

```bash
./migrate2rocky.sh -r
```

L'option "-r" indique au script de continuer et de tout installer.

Si vous avez tout fait correctement, votre fenêtre de terminal devrait ressembler un peu à ceci :

![un démarrage réussi du script](images/migrate2rocky-convert-01.png)

Il faudra un certain temps au script pour tout convertir, en fonction de la machine virtuelle ou du serveur physique ainsi que de la connexion Internet dont il dispose.

Si vous voyez un message **Complete!** à la fin, tout va bien et vous pouvez redémarrer le serveur.

![un message de migration du système d'exploitation réussie](images/migrate2rocky-convert-02.png)

Donnez-lui un peu de temps, reconnectez-vous et vous devriez avoir un serveur Rocky Linux tout beau, tout neuf pour jouer avec... Exécutez la commande `hostnamectl` pour vérifier que votre système d'exploitation a été migré correctement et vous voilà prêt à l'utiliser ! <small> <br/><br/> 🌐 Traductions: <a href="https://crowdin.com/project/rockydocs/de">crowdin.com/project/rockydocs</a> <br/> 🌍 Traducteurs: <a href="https://crowdin.com/project/rockydocs/activity-stream">rockydocs/activity-stream</a> , <a href="https://crowdin.com/project/rockylinuxorg/activity-stream">rockylinux.org</a> <br/> 🖋 Contribution: <a href="https://github.com/rocky-linux/documentation?tab=readme-ov-file#mattermost">github.com/rocky-linux</a> </small>

![Les résultats de la commande hostnamectl](images/migrate2rocky-convert-03.png)
