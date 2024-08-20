---
title: Business & Office Apps
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

Que vous ayez un nouvel ordinateur portable de travail basé sur Linux ou que vous essayiez de mettre en place un environnement de bureau, vous vous demandez peut-être où se trouvent toutes vos applications de bureau et professionnelles habituelles.

La plupart d’entre elles sont sur Flathub. Dans ce guide, vous apprendrez à installer les applications les plus courantes, vous obtiendrez aussi une liste d'alternatives viables. Si vous souhaitez savoir comment installer Office, Zoom et plus encore, continuez cette lecture.

## Prérequis

Cet article suppose les éléments suivants :

- Une installation Rocky Linux avec un environnement de bureau graphique
- Les droits nécessaires pour l'installation de logiciels sur votre système
- Flatpak et Flathub installés et opérationnels

## Installation des logiciels professionnels courants sur Rocky Linux

Pour la plupart d'entre eux, il vous suffit d'installer Flatpak et Flathub, d'aller dans `Software Center`, de rechercher ce que vous voulez et de l'installer. Cela prendra en charge bon nombre des options les plus courantes. Pour les autres, vous devrez utiliser les variantes web des applications.

![A screenshot of Zoom in the software center](images/businessapps-01.png)

Pour commencer, voici une liste de certaines des applications professionnelles les plus courantes – celles qui ont au moins des clients de bureau – et les meilleurs moyens de les obtenir.

!!! note "Remarque"

```
Si vous souhaitez simplement connaître l'état de Microsoft Office sur Linux, faites défiler la page vers le bas et passez à la section suivante.
```

De plus, cette liste n'inclura pas les applications comme Jira, qui n'ont pas d'applications de bureau officielles.

### Asana Desktop

Application de bureau : non disponible sur Linux

Recommandation : Utilisez la variante web.

### Discord

Application de bureau : applications officielles et tierces disponibles avec Flathub dans le `Software Center`

Recommandation : utilisez le client officiel si vous souhaitez une fonctionnalité `push-to-talk`. Utilisez la variante web ou tout autre client tiers dans le `Software Center`.

### Dropbox

Application de bureau : l'application officielle est disponible avec Flathub dans le `Software Center`.

Recommandation : utilisez le programme officiel dans GNOME et la plupart des autres environnements de bureau. Si vous utilisez KDE, utilisez la composante Dropbox intégrée.

### Evernote

Application de bureau : n'est plus disponible sur Linux.

Recommandation : Utilisez la variante web.

### Freshbooks

Application de bureau : non disponible sur Linux.

Recommandation : Utilisez la variante web.

### Google Drive

Application de bureau : Applications client tierces uniquement.

Recommandation : connectez-vous à votre compte Google à l'aide de la fonctionnalité de comptes en ligne dans GNOME Shell ou KDE. Cela vous donnera un accès direct à vos fichiers, courriels, calendrier, listes de tâches et plus encore sur GNOME.

Vous pouvez parcourir et gérer vos fichiers Drive à partir du gestionnaire de fichiers sur KDE. Il n'est pas aussi entièrement intégré que sur GNOME, mais il reste utile.

### Hubspot

Application de bureau : non disponible sur Linux.

Recommandation : Utilisez la variante web.

### Microsoft Exchange

Application de bureau : Applications client tierces uniquement.

Recommandation : dans GNOME, vous pouvez utiliser la fonctionnalité de comptes en ligne pour intégrer vos applications à Exchange, de la même manière qu'un compte Google.

Dans tout autre environnement de travail, utilisez Thunderbird avec l'un des _divers_ modules complémentaires Exchange. Thunderbird est disponible dans le dépôt Rocky Linux standard, mais vous pouvez obtenir une version plus récente avec Flathub.

### Notion

Application de bureau : non disponible sur Linux.

Recommandation : Utilisez la variante web.

### Outlook

Application de bureau : Applications tierces uniquement.

Recommandation : utilisez le client de messagerie de votre choix. `Evolution` et `Thunderbird` sont de bonnes options, ou alors utilisez la variante Web.

### Quickbooks

Application de bureau : non disponible sur Linux.

Recommandation : Utilisez la variante web.

### Slack

Application de bureau : l'application officielle est disponible sur Flathub dans le centre logiciel.

Recommandation : utilisez l'application ou la variante Web suivant vos préférences.

### Teams

Application de bureau : l'application officielle est disponible sur Flathub dans le centre logiciel.

Recommandation : utilisez-le sur votre environnement de bureau ou dans votre navigateur comme bon vous semble. Si vous devez activer le partage d'écran, connectez-vous à votre session X11 au démarrage de votre PC. Le partage d'écran n'est pas encore pris en charge sur Wayland.

### Zoom

Application de bureau : l'application officielle est disponible sur Flathub dans le centre logiciel.

Recommandation : si vous utilisez l'application de bureau sur Rocky Linux, connectez-vous à votre PC en utilisant une session X11, et non Wayland, si vous devez partager votre écran. Le partage d'écran fonctionne désormais dans Wayland, mais uniquement dans les versions plus récentes du logiciel.

En tant que système d'exploitation d'entreprise stable, Rocky Linux mettra un certain temps à intégrer toutes ces nouveautés.

Cependant, en fonction de votre navigateur, vous aurez peut-être plus de chance de partager votre écran sur Wayland si vous ignorez complètement l'application de bureau et utilisez simplement la variante Web.

## Alternatives entre open source et logiciels d’entreprise classiques

Si vous pouvez choisir votre logiciel pour le travail et la productivité, vous pourriez envisager de modifier vos habitudes et d'essayer une solution open-source. La plupart des applications répertoriées ci-dessus peuvent être remplacées par une instance de [Nextcloud](https://nextcloud.com) hébergée sur votre propre serveur ou dans le cloud, et certaines applications tierces peuvent être installées sur cette plateforme.

Il peut gérer la synchronisation de fichiers, la gestion de projet, le CRM, le calendrier, l'administration des notes, la comptabilité de base, le courrier électronique et, avec un peu de travail et de personnalisation, le chat texte et vidéo.

[Wikisuite](https://wikisuite.org/Software) peut faire tout ce qui précède et vous aider à créer le site Web de votre entreprise. C'est très similaire à Odoo.

Notez cependant que ces plateformes sont avant tout centrées sur le web. Le client Nextcloud Desktop est uniquement destiné à la synchronisation de fichiers ce que Wikisuite ne possède pas.

Vous pouvez remplacer Slack facilement par [Mattermost](https://mattermost.com), une plateforme open source de discussion et de gestion d'équipe. Si vous avez besoin des fonctionnalités vidéo et audio fournies par Discord, Teams ou Zoom, vous pouvez ajouter [Jitsi Meet](https://meet.jit.si) à l'ensemble. C'est un peu comme un Google Meet auto-hébergé.

Mattermost et Jitsi ont également des clients Desktop pour Linux sur Flathub.

Il en va de même pour [Joplin](https://joplinapp.org) et [QOwnNotes](https://www.qownnotes.org/) et [Notesnook](https://notesnook.com), qui sont des solutions remarquables de remplacement à Evernote.

Vous recherchez une solution de remplacement à Notion dans le centre de logiciels ? [AppFlowy](https://appflowy.io) ou [SiYuan](https://b3log.org/siyuan/en/) pourraient bien être ce dont vous avez besoin.

!!! note "Remarque"

```
Bien que toutes les solutions de remplacement 
 répertoriées ci-dessus soient open source, toutes ne sont pas des « logiciels libres et open source (FLOSS) ». Cela signifie que certains facturent des fonctionnalités supplémentaires ou des versions premium de leurs services.
```

## Microsoft Office sous Rocky Linux

Les nouveaux arrivants dans le monde Linux pourraient se demander pourquoi il est si difficile de faire fonctionner ce système. Ce n'est pas difficile si vous maîtrisez la variante Web d'Office365.

Cependant, ce sera plus compliqué si vous souhaitez un environnement de bureau complet avec toutes les fonctionnalités fournies par les applications Windows. Alors que de temps en temps quelqu'un écrit un tutoriel sur la façon d'obtenir la dernière version des applications Office fonctionnant sous Linux avec WINE, ces solutions sont souvent vouées à l'échec. Il n'existe pas de moyen universel pour faire fonctionner des applications de bureau sous Linux.

Il existe des suites bureautiques compatibles avec Linux et Microsoft Office, mais le problème principal est Excel.

Jusqu'à présent, la version de bureau d'Excel était pratiquement inégalée en termes de fonctionnalités, de méthodes de traitement des données, etc. Certes, c’est un excellent programme difficile à concurrencer.

Même si les solutions de remplacement possèdent toutes les fonctionnalités dont un utilisateur particulier pourrait avoir besoin, la manière de travailler est différente. Vous ne pouvez pas intégrer vos formules et feuilles de calcul les plus complexes dans l'une des solutions de remplacement, même Excel pour le Web, et vous attendre à ce que cela fonctionne sans problème.

Mais si Excel ne constitue pas une partie importante de votre flux de travail, n'hésitez pas à envisager des solutions de remplacement. _Tous_ ces éléments sont disponibles dans le centre logiciel de Flathub.

### Remplacement de Microsoft Office sous Rocky Linux

#### LibreOffice

[LibreOffice](https://www.libreoffice.org) est le standard de facto des logiciels de bureautique et de productivité FLOSS. Il couvre la plupart de vos besoins de bureau : documents, feuilles de calcul, présentations, logiciels de dessin vectoriel (conçus pour l'impression) et bases de données.

Dans l'ensemble, sa compatibilité avec Microsoft Office est satisfaisante sans être parfaite, mais ça fonctionne _très bien_ avec les formats ouverts. Si vous souhaitez vous éloigner complètement de l’écosystème Microsoft, LibreOffice est probablement la meilleure solution.

Il existe également une variante Web appelée Collabora Office, qui présente des limites, sauf si vous payez pour les versions premium.

#### OnlyOffice

[OnlyOffice](https://www.onlyoffice.com) est une suite de programmes légèrement moins complète mais néanmoins fantastique pour créer des documents, des présentations, des feuilles de calcul et des fichiers PDF. Notamment, il comprend également un éditeur PDF.

Si vous avez besoin de la compatibilité avec Microsoft Office, en particulier pour les documents et les présentations, alors OnlyOffice est probablement votre meilleur choix. OnlyOffice gère mieux les documents Word que la version en ligne d'Office365.

#### WPS Office

[WPS Office](https://www.wps.com), anciennement Kingsoft Office, fait partie de l'écosystème Linux depuis un certain temps. Il prend également en charge les documents, les feuilles de calcul, les présentations et un éditeur PDF.

WPS Office a une compatibilité avec Microsoft Office légèrement meilleure que LibreOffice, mais il n'est pas aussi compatible qu'OnlyOffice. Il possède également moins de fonctionnalités et est moins personnalisable. Voici un extrait de leur blog :

![WPS Office a une interface plus moderne et conviviale que OnlyOffice. Il est également plus facile à apprendre et à utiliser, surtout pour les débutants. WPS Office propose également une gamme plus large de modèles et de thèmes, ce qui facilite la création de documents d'aspect professionnel. OnlyOffice est plus puissant et plus personnalisable que WPS Office. Il dispose d'une gamme plus large de fonctionnalités, notamment des outils de gestion de documents et de projets. OnlyOffice est également plus compatible avec les formats Microsoft Office que WPS Office.](images/businessapps-02.png)

Leur objectif principal est de créer une expérience utilisateur plus simple et plus accessible qui pourrait mieux correspondre à ce que vous attendez.

#### Calligra

La suite bureautique [Calligra](https://calligra.org) est un projet FLOSS des développeurs KDE. Il fournit un ensemble pratique de programmes bureautiques de base pour créer des documents, des feuilles de calcul, des présentations, des bases de données, des organigrammes, des graphiques vectoriels, des livres électroniques, etc.

Cependant, les applications Calligra ne sont pas faciles à installer sur Rocky Linux. Si vous disposez d’une autre machine Fedora, l’auteur vous encourage à l’essayer.

## Conclusion

À quelques exceptions notables près, utiliser tous vos logiciels de bureau sur Rocky Linux revient à rechercher les applications sur Flathub ou simplement à utiliser la variante Web. Quoi qu’il en soit, vous constaterez probablement que Rocky Linux constitue une plate-forme stable et pratique pour la plupart des tâches de bureau courantes.

Si le manque de prise en charge du bureau Excel constitue un obstacle, l'auteur recommande d'utiliser un serveur de base de données à part entière. Les serveurs de bases de données peuvent faire des choses étonnantes.
