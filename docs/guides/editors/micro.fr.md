---
title: micro
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
tested version: 8.5
tags:
  - éditeur
  - éditeurs
  - micro
---

# Installation de micro sous Rocky Linux

## Présentation de micro

*[micro](https://micro-editor.github.io)* est un simple éditeur de texte intermédiaire entre *nano* et *vim* du point de vue complexité. Il propose un flux de travail simple et facilement reconnaissable, ainsi que plusieurs fonctionnalités appréciables :

- Toutes les commandes habituelles ++control+c++, ++control+v++ et ++control+f++ fonctionnent comme dans un éditeur normal. Toutes les combinaisons de touches peuvent bien sûr être modifiées.
- Prise en charge de la souris - cliquer et faire glisser pour sélectionner le texte, double-cliquer pour sélectionner les mots, triple-cliquer pour sélectionner les lignes.
- Plus de 75 langues sont prises en charge avec une mise en évidence de la syntaxe par défaut.
- Des curseurs multiples pour vous permettre de modifier plusieurs lignes à la fois.
- Intègre un système de plugiciels.
- Multi-fenêtrage.

Voilà ce à quoi il ressemble sur mon terminal :

![Capture d'écran de l'éditeur de micro texte](images/micro-text-editor.png)

!!! note "Remarque"

    Vous *pouvez* installer micro via snap app. Si vous utilisez déjà snap sur votre ordinateur... Après tout, pourquoi pas ? Mais il est préférable de l'installer à partir des sources.

## Prérequis

- Une machine ou un conteneur Rocky Linux connecté à internet.
- Des connaissances de base de l'utilisation de la ligne de commande et le souhait d’éditer vos fichiers depuis un terminal.
- Certaines commandes devront être exécutées en tant que root ou avec `sudo`.

### Comment installer micro

C'est peut-être le tutoriel le plus simple que l'auteur a écrit jusqu'à présent, avec exactement trois commandes. Tout d'abord, vous devez vous assurer que *tar* et *curl* sont installés. Cela ne devrait être pertinent que si vous exécutez une installation minimale de Rocky, ou si vous l'exécutez à l'intérieur d'un conteneur.

```bash
sudo dnf install tar curl
```

Ensuite, vous aurez besoin de l'installateur disponible sur le site web de *Micro*. La commande suivante récupère l'installateur et l'exécute pour vous dans le répertoire où vous travaillez. Je sais que nous ne conseillons pas de copier-coller les commandes depuis des sites web, mais celle-ci ne m'a jamais posé de problème.

```bash
curl https://getmic.ro | bash
```

Pour installer l'application sur l'ensemble du système (afin que vous puissiez simplement taper "micro" pour ouvrir l'application), vous pouvez exécuter le script en tant que root dans `/usr/bin/`. Cependant, si vous voulez d'abord vérifier et être prudent, vous pouvez installer *micro* dans le dossier de votre choix, puis déplacer l'application plus tard :

```bash
sudo mv micro /usr/bin/
```

Et c'est tout ! Bonne édition de texte.

### La méthode vraiment facile

J'ai créé un script très simple qui exécute toutes ces commandes. Vous pouvez le trouver dans mes [gists Github](https://gist.github.com/EzequielBruni/0e29f2c0a63500baf6fe9e8c51c7b02f), et soit copier/coller le texte dans un fichier sur votre machine, soit le télécharger avec `wget`.

## Désinstaller Micro

Allez dans le dossier dans lequel vous avez installé *micro* et (en utilisant vos pouvoirs d'administrateur tout puissant si nécessaire) exécutez :

```bash
rm micro
```

De plus, *micro* laissera des fichiers de configuration dans votre répertoire personnel (et dans les répertoires personnels de tous les utilisateurs qui l'ont exécuté). Vous pouvez vous en débarrasser avec :

```bash
rm -rf /home/[username]/.config/micro
```

## Conclusion

Si vous souhaitez un guide complet sur l'utilisation de *Micro*, consultez le [site web principal](https://micro-editor.github.io) et la documentation dans le [dépôt Github](https://github.com/zyedidia/micro/tree/master/runtime/help). Vous pouvez également appuyer sur « Control-G » pour ouvrir le fichier d'aide principal dans l'application elle-même.

*micro* ne répondra probablement pas aux besoins des personnes ayant acquis de l'expérience avec *vim* ou *emacs*, mais il est parfait pour les gens comme moi. J'ai toujours voulu avoir l'expérience de Sublime Text dans le terminal, et maintenant j'ai quelque chose de *vraiment* proche.

Essayez-le, voyez s'il vous convient.
