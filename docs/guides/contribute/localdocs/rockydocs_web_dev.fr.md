---
title: Méthode docker
author: Wale Soyinka
contributors: Steve Spencer, Ganna Zhyrnova
update: 2022-02-27
---

# Exécution d'une copie locale du site docs.rockylinux.org pour le développement et les auteurs de contenu

Ce document explique comment recréer et exécuter une copie intégrale du site docs.rockylinux.org sur votre ordinateur. **It is a work-in-progress.**

L'exécution d'une copie locale du site de documentation peut être utile pour les scénarios suivants :

* Vous souhaitez en savoir plus et contribuer au développement du site Web docs.rockylinux.org
* Vous êtes un auteur et vous aimeriez voir comment vos documents s'afficheront sur le site web de la documentation avant de les proposer à l'équipe de Rocky Linux
* Vous êtes un développeur web qui souhaite contribuer ou aider à maintenir le site docs.rockylinux.org


### Quelques remarques :

* Les instructions de ce guide ne sont **PAS** des prérequis pour la contribution des auteurs à la documentation de Rocky Linux
* L'environnement complet s'exécute dans un conteneur Docker et vous aurez donc besoin d'un service Docker sur votre ordinateur local
* Le conteneur est créé à partir de l'image officielle docker RockyLinux disponible ici https://hub.docker.com/r/rockylinux/rockylinux
* Le conteneur conserve le contenu de la documentation (guides, books, images, etc.) séparément du moteur web (médocs)
* Le conteneur démarre un serveur web local qui reçoit les requêtes en utilisant le port 8000.  et le port 8000 sera redirigé vers l'hôte Docker


## Créer un nouvel environnement

1. Remplacez le répertoire de travail actuel sur votre système local par un répertoire dans lequel vous avez l'intention d'effectuer vos enregistrements. Nous ferons référence à ce répertoire par l'intermédiaire de la variable `$ROCKYDOCS` dans le reste de ce guide.  Pour notre exemple ici, `$ROCKYDOCS` correspond au répertoire `~/projects/rockydocs` sur notre système de démonstration.

Créez $ROCKYDOCS s'il n'existe pas déjà, puis saisissez :

```
cd  $ROCKYDOCS
```

2. Vérifiez que `git` est déjà installé (`dnf -y install git`).  Dans le répertoire $ROCKYDOCS, utilisez git pour cloner le dépôt du contenu officiel de la documentation Rocky. Entrer la commande :

```
git clone https://github.com/rocky-linux/documentation.git
```

Vous avez maintenant le répertoire `$ROCKYDOCS/documentation`. Ce répertoire est un dépôt git et est géré par git.


## Créer et démarrer l'environnement de développement RockyDocs

3.  Assurez-vous que Docker est opérationnel sur votre ordinateur (vous pouvez vérifier avec `systemctl status docker.service`)

4. Lancez la commande suivante :

```
docker pull wsoyinka/rockydocs:latest
```

5. Vérifiez que l'image docker a bien été téléchargée. Entrer la commande :

```
docker image ls
```

## Lancer le conteneur RockyDocs

1. Lancez un conteneur à partir de l'image rockydocs. Entrez la commande :

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


Sinon, si vous préférez et si vous avez installé `docker-compose`, vous pouvez créer un fichier compose nommé `docker-compose.yml` avec le contenu suivant :

```
version: "3.9"
services:
  rockydocs:
    image: wsoyinka/rockydocs:latest
    volumes:
      - type: bind
        source: ./documentation
        target: /documentation
    container_name: rocky
    ports:
       - "8000:8000"

```

Enregistrez le fichier `docker-compose.yml` dans votre répertoire de travail $ROCKYDOCS.  Ensuite lancez le conteneur en utilisant la commande :

```
docker-compose up
```


## Afficher la copie locale du site docs.rockylinux.org

Une fois le conteneur opérationnel, vous devriez maintenant pouvoir afficher votre copie locale du site avec votre navigateur en utilisant l'URL :

http://localhost:8000
