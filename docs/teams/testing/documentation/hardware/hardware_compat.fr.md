---
title: Compatibilité matérielle
author: Chris Stackpole
contributors: Steven Spencer
translators:
---

## Historique

Une question fréquente est : « Est-ce que Rocky peut s'installer sur ma machine ? » C'est une question importante et, généralement, la réponse est « oui ». Cependant, la question devient plus complexe lorsqu'elle est formulée ainsi : « Rocky Linux fonctionnera-t-il avec cet appareil ou cette configuration ? » Au début du projet, l'équipe de tests avait besoin d'autant de rapports que possible pour s'assurer que Rocky pouvait bel et bien être installé sur un large éventail de matériels. `xsos` a rassemblé ces informations et les a placées dans le [dépôt Git ici](https://github.com/rocky-linux/testing/tree/main/test-reports).

À l'époque, ça marchait bien, mais c'était difficile d'y contribuer, et c'était difficile d'y faire des recherches et filtrer les résultats. Ces rapports n'ont pas été mis à jour depuis des années.

Cependant, la question « Est-ce que Rocky s'installe sur... ? » reste posée. Ces questions demeurent pertinentes étant donné la commercialisation constante de nouveaux matériels. Il existe donc une nécessité voire une volonté de contribuer à la création d'une base de données que les utilisateurs pourront consulter et enrichir.

## Le projet `Hardware Probe`

Le projet [Hardware Probe](https://github.com/linuxhw/hw-probe) a été conçu pour répondre à ces problèmes. Il s'agit d'un projet établi avec [un site Web](https://linux-hardware.org) que les utilisateurs peuvent utiliser pour rechercher du matériel et des systèmes. De plus, il existe de nombreuses façons d'installer [the probe](https://linux-hardware.org/?view=howto) et de soumettre les résultats facilement et anonymement. L'outil `hw-probe` analyse et recueille les résultats d'un certain nombre d'utilitaires, tels que `lspci`, `smartctl` et `hwinfo`, afin de vérifier le matériel et de s'assurer du chargement correct et du fonctionnement optimal des pilotes avant de les soumettre à la base de données.

Voici un exemple de système comportant plusieurs éléments utiles pour les [besoins de l'équipe de test](https://linux-hardware.org/?probe=edebdf0568).

## Motivation

Il y a trois raisons pour lesquelles l'équipe de test aimerait que vous contribuiez votre système à la base de données du projet Hardware Probe :

1. Que vous utilisiez Rocky ou toute autre distribution, soutenir le projet Hardware Probe aide tous les utilisateurs Linux à savoir si leur matériel est pris en charge et fonctionne sous Linux. C'est bon pour la communauté au sens large.

2. Elle constitue une base de données pour la communauté qui se pose la question : « Rocky s'installe-t-il sur... ? » Contribuer à la base de données avec les résultats de `hw-probe` permet de répondre à cette question. Plus la base de données comporte de variantes et de contributions, plus elle est utile aux autres utilisateurs de distributions basées sur EL comme Rocky Linux.

3. Il arrive parfois que les pilotes changent en amont de Rocky, ou même qu'ils disparaissent complètement. Cela aide l'équipe de test de Rocky à identifier et à résoudre plus rapidement les problèmes matériels pour lesquels les pilotes devraient fonctionner, mais qui, pour une raison ou une autre, ne sont plus opérationnels dans des versions plus récentes. Si un composant matériel fonctionnait auparavant mais ne fonctionne plus, nous pourrions ne pas y avoir accès, ce qui peut compliquer la recherche des notes de version si le matériel est désuet, ou la soumission de rapports de bogues en amont pour savoir s'il devrait être pris en charge. Plus l'équipe de test matériel a d'historique de référence, plus il lui est facile de résoudre le problème rapidement.

## Comment participer

Heureusement pour Rocky Linux, l'outil `hw-probe` est disponible dans EPEL. Ce n'est pas un guide complet et exhaustif sur l'utilisation de cet outil. De nombreuses fonctionnalités utiles sont intégrées mais ne sont pas toutes abordées ci-dessous.
Nous traiterons ici uniquement de fonctionnalités nécessaires à l'installation et au chargement dans la base de données.

### Rocky 8, Rocky 9 et Rocky 10

Installez EPEL si vous ne l'avez pas encore fait :

```bash
sudo dnf install -y epel-release
```

Installez `hw-probe` :

```bash
sudo dnf install -y hw-probe
```

Veuillez noter que le paquet EPEL ne récupère pas toujours les dépendances.

Pour toutes les versions, vous devez installer les paquets suivants :

```bash
sudo dnf install -y tar curl
```

Sur Rocky 8, installez aussi `xorg-x11-utils` pour `edid-decode` [Remarque : ce paquet n'est pas disponible pour les versions 9 et 10 ; veuillez ignorer l'avertissement] :

```bash
sudo dnf install -y xorg-x11-utils
```

Exécutez la probe et téléchargez les résultats :

```bash
sudo -E hw-probe -all -upload
```

#### Autres options utiles pour `hw-probe`

La méthode recommandée et la plus simple pour utiliser `hw-probe` est celle décrite ci-dessus :

```bash
sudo -E hw-probe -all -upload
```

Pour ceux qui veulent savoir de quoi il s'agit avant de télécharger, ce qui constitue une bonne mesure de sécurité, nous recommandons l'utilisation de la fonction de sauvegarde de l'utilitaire. C'est aussi une option utile pour ceux qui ont des systèmes auxquels ils aimeraient contribuer, mais qui n'ont pas d'accès direct à Internet (veuillez ne pas enfreindre les politiques en vigueur ! Mais pour ceux qui ont déjà obtenu l'autorisation mais n'ont pas d'accès direct à Internet, c'est une option utile) :

```bash
sudo -E hw-probe -all -save /path/to/writable/folder
```

L'utilitaire peut ensuite être téléchargé avec ceci :

```bash
sudo -E hw-probe -upload -src path/to/hw.info.txz
```

Si la quantité de données, notamment dans les fichiers journaux qu'il peut recueillir, vous préoccupe, veuillez envisager l'option `minimal` plutôt que l'option `all`. Cela peut également être combiné avec l'option `save` ci-dessous :

```bash
sudo -E hw-probe -minimal -upload
# ou 
sudo -E hw-probe -minimal -save /path/to/writable/folder
```

### Avertir l'équipe de test

Si vous exécutez `hw-probe` sur une version officielle (au moment de la rédaction de ce document : 8.10, 9.8, 10.2), soumettez le résultat à l’équipe de test via chat.rockylinux.org (Mattermost Chat) dans le canal de test. Ceci est seulement recommandé et non obligatoire. Cela permet simplement à l'équipe de test de savoir quel matériel vous avez soumis, ainsi que son état actuel par rapport à Rocky Linux. Cela représente une grande plus-value pour la communauté au sens large, ainsi que pour les besoins historiques de l'équipe de tests (savoir si un matériel a fonctionné ou non sur les versions précédentes).

Si vous exécutez `hw-probe` sur une version Candidate (Release Candidate) ou bêta, il est essentiel de signaler le lien — quel que soit son statut — sur [chat.rockylinux.org](https://chat.rockylinux.org) (chat Mattermost), dans le canal dédié aux versions. Si ce n’est pas possible, envoyez un message direct à Rocky Linux sur le réseau social de votre choix, ou publiez sur les forums à l’adresse [forums.rockylinux.org](https://forums.rockylinux.org). L'équipe de test ne peut pas garantir que votre nom apparaîtra dans les crédits des soumissions à l'extérieur des canaux Mattermost sur [chat.rockylinux.org](https://chat.rockylinux.org), mais nous ferons de notre mieux pour inclure TOUS ceux qui soumettent des contributions.

## Autres façons de contribuer

Toute personne disposée à contribuer au projet « Hardware Probe » serait d'une grande aide. Ils sont à la recherche de personnes pour les aider à rédiger les tests et à gérer le projet.

Enfin, la contribution de toute personne disposée à proposer une bonne méthode permettant à l'équipe de test d'examiner toutes les soumissions Rocky sans surcharger la base de données en amont serait grandement appréciée.
