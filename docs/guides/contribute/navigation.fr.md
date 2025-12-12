---
title: Changements de navigation
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tags:
  - contribuer
  - navigation
---

# Changements de navigation - Un document de processus pour les gestionnaires/éditeurs

## Motivation de ce document

Lorsque le projet de documentation a démarré, on espérait que les menus de Mkdocs seraient aussi automatiques que possible, rendant l'édition manuelle de la navigation plutôt rare. Après quelques mois de génération de documents, il est devenu clair que juste placer des documents dans le dossier correct et laisser Mkdocs pour générer la navigation ne pouvait pas permettre de garder les choses claires et nettes. Nous avions besoin de catégories, quelque chose que Mkdocs ne fournit pas à moins que les documents ne soient placés dans des dossiers spécifiques. Mkdocs créera ensuite une navigation avec tri alphabétique. La création d'une structure de dossier qui corrige la navigation n'est pas tout. Même si cela nécessitera parfois des changements supplémentaires pour organiser les choses. Par exemple, la majuscule sans modifier la structure des dossiers et noms de fichiers en minuscules.

## Objectifs

Nos objectifs étaient :

- Créez la structure de dossier si nécessaire maintenant (de nouveaux dossiers peuvent être requis à l'avenir).
- Ajustez la navigation de sorte que les zones de l’installation de Rocky Linux, de la migration et de la contribution soient en première ligne
- Ajuster la navigation pour mieux nommer certains dossiers, et assurer une capitalisation correcte. À titre d'exemple, "DNS" et "Services de partage de fichiers", qui apparaissent autrement comme "Dns" et "Partage de fichiers" sans aucune manipulation.
- Assurez-vous que ces fichiers de navigation sont limités aux gestionnaires et aux éditeurs.

Ce dernier point peut sembler inutile pour certaines personnes qui le lisent, mais il deviendra plus clair au fur et à mesure que ce document sera développé.

## Prérequis

Il est supposé que vous avez un clone local du dépôt GitHub de Rocky : [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## Changements d'environnement

Avec ces changements vient un réel besoin de "voir" comment toute modification que vous apportez affecte le contenu, dans le contexte du site Web, *AVANT* que le contenu soit enregistré dans le référentiel de la documentation et qu'il soit ensuite publié en ligne.

MkDocs est une application [Python](https://www.python.org) et les modules supplémentaires qu'elle utilise sont également du code Python, ce qui signifie que l'environnement requis pour exécuter MkDocs doit être un environnement Python **correctement configuré**. Mettre en place Python pour les tâches de développement (ce qui est nécessaire avec MkDocs) n'est pas une tâche triviale et les instructions pour cela sont hors du champ d'application de ce document. Certaines considérations comprennent :

- La version de Python devrait être >= 3.8. Faites également particulièrement **attention à ne pas utiliser la version Python « système » d'un ordinateur si celui-ci exécute Linux ou macOS**. Par exemple, lors de l'écriture de ce document, la version système de Python sur macOS est toujours en version 2.7.
- Exécution d'un 'environnement virtuel' en Python. Lors de l'exécution du projet d'application Python et de l'installation de paquets, par exemple MkDocs, il est **fortement recommandé** par la communauté Python [de créer un environnement virtuel isolé](https://realpython.com/python-virtual-environments-a-primer/) pour chaque projet.
- Utilisez un IDE moderne (environnement de développement intégré) qui supporte efficacement Python. Deux IDE populaires, qui ont également un support intégré pour l'exécution d'environnements virtuels, sont :
    - PyCharm - (version gratuite non libre disponible) le premier IDE pour Python <https://www.jetbrains.com/pycharm/>
    - Visual Studio Code - (version gratuite non libre disponible) de Microsoft <https://code.visualstudio.com>

Pour ce faire, il faut :

- Configuration d'un nouveau projet Python à l'aide d'un environnement virtuel (ci-dessus).
- Installation de `mkdocs`
- Installation de plugins python
- Cloner ce dépôt Rocky GitHub : [https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
- Créer un lien vers le dossier `docs` dans votre référentiel de documentation cloné (vous pouvez également simplement modifier le fichier `mkdocs.yml` si vous souhaitez charger le bon dossier, mais la création d'un lien permet de garder votre environnement mkdocs plus propre)
- Exécuter `mkdocs serve` dans votre clone de docs.rockylinux.org

!!! tip "Astuce"

    Vous pouvez créer des environnements totalement séparés pour « mkdocs » en utilisant l'une des procédures trouvées dans la section [Documentation locale](localdocs/index.md) du menu `Contribute`.

!!! note "Remarque "

    Ce document a été créé dans un environnement Linux. Si votre environnement est différent (Windows ou Mac), vous devrez alors effectuer une petite recherche pour correspondre à certaines de ces étapes. Un éditeur ou un gestionnaire qui lit cela peut soumettre des modifications pour ajouter des étapes pour ces environnements.

### Installation

- Installer `mkdocs` avec l'environment python : `pip install mkdocs`
- Installer les plugiciels nécessaires :  `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-redirects mkdocs-i18n`
- Cloner le référentiel (comme indiqué)

### Lier et exécuter `mkdocs`

Dans votre copie locale de docs.rockylinux.org local (clone), faites ce qui suit. Cela suppose l'emplacement de votre clone de documentation, donc modifiez si besoin est :

`ln -s /home/username/documentation/docs docs`

Pour rappel, vous pouvez modifier la copie locale du fichier `mkdocs.yml` pour définir le chemin. Si vous utilisez cette méthode, vous modifierez cette ligne pour pointer vers votre dossier `documentation/docs` :

```text
docs_dir: 'docs/docs'
```

Une fois terminé, vous pouvez essayer d'exécuter la commande `mkdocs serve` pour voir si vous obtenez le contenu souhaité. Cela fonctionnera sur votre localhost sur le port 8000 ; par exemple : <http://127.0.0.1:8000/>

## Navigation et autres modifications

La navigation est gérée avec les fichiers mkdocs `.pages` **OU** par la valeur de la méta-variable `title:` dans la première partie du document. Les fichiers `.pages` ne sont pas trop complexes, MAIS, si quelque chose manque, cela peut faire échouer le lancement du serveur. C'est pourquoi cette procédure est **réservée** aux gestionnaires et aux éditeurs. Ces personnes vont avoir les outils en place (installation locale de mkdocs, plus clones de documentation et docs.rockylinux.org) pour que quelque chose publié sur GitHub ne perturbe pas la diffusion du site web de la documentation. On ne s'attend pas à ce qu'un contributeur réponde à ces exigences.

### Fichiers `.pages`

Comme indiqué précédemment, les fichiers `.pages` sont généralement assez simples. Ce sont des fichiers au format YAML que `mkdocs` interprète avant de rendre le contenu. Pour jeter un coup d'œil à l'un des fichiers `.pages` plus élaborés, veuillez examiner celui créé pour aider à formater la navigation latérale :

```yaml
---
nav:
    - ... | index*.md
    - ... | installation*.md
    - ... | migrate2rocky*.md
    - Contribute: contribute
    - Automation: automation
    - Backup & Sync: backup
    - Content Management: cms
    - Communications: communications
    - Containers: containers
    - Database: database
    - Desktop: desktop
    - DNS: dns
    - Email: email
    - File Sharing Services: file_sharing
    - Git: git
    - Interoperability: interoperability
    - Mirror Management: mirror_management
    - Network: network
    - Package Management: package_management
    - ...
```

Ici, `index*.md` affiche la « Page d'accueil des guides : », `installation*.md` affiche le lien vers le document « Installation de Rocky Linux », et `migrate2rocky*.md` affiche le lien vers le document « Migrer vers Rocky Linux ». L'étoile `*` dans chaque lien permet à ce document d'être dans n'importe quelle langue, par exemple `index.fr.md`, `index.de.md`, etc. Enfin, en plaçant ensuite "Contribute", il se situe sous ces éléments plutôt que dans l'ordre de tri normal (alphabétique). Si vous regardez la liste, vous pouvez voir ce que chaque élément fait. Notez qu'après l'entrée `Package Management: package_management`, il y a en fait deux autres dossiers (sécurité et web). Ces derniers ne nécessitent aucun formatage supplémentaire. Le fichier `.pages` indique à `mkdocs` de les charger normalement avec le `- ...`.

Vous pouvez également utiliser le formatage YAML dans un fichier réel. Une raison pour cela peut être que l'en-tête au début du fichier est si long, qu'il ne s'affiche correctement dans la section de navigation. À titre d'exemple, prenez le titre de document "# `mod_ssl` sous Rocky Linux dans un environnement httpd Apache Web-Serveur". C'est trop long. Il s'affiche mal dans la navigation latérale lorsque l'élément de navigation `Web` est ouvert. Pour corriger cela, vous pouvez soit coopérer avec l'auteur pour changer son titre, soit vous pouvez modifier la façon dont il s'affiche dans le menu en ajoutant un titre avant l'en-tête à l'intérieur du document. Dans cet exemple, l'ajout d'un titre au début du texte réduit la longueur du titre dans la liste :

```text
---
title: Apache avec `mod_ssl`
---
```

Cela modifie le titre en ce qui concerne la navigation, mais laisse le titre original de l'auteur en place dans le document.

!!! info "Info"

    Dans la plupart des cas, le titre de l'auteur sera un titre de niveau 1 et la partie avant du titre sera ÉGALEMENT un titre de niveau 1 (« # »). Cela introduit une erreur markdown dans le document. Pour contourner ce problème, supprimez complètement le titre de l'auteur ou remplacez-le par un titre de niveau 2 (« ## »).

Vous devez utiliser les fichiers `.pages` avec parcimonie, uniquement lorsque cela est vraiment nécessaire.

## Conclusion

Bien qu'il ne soit pas difficile d'effectuer les modifications de navigation nécessaires avec les fichiers `.pages`, il existe un risque de discontinuité de la documentation à l'affichage. Pour cette raison, seuls les managers et les éditeurs disposant des outils appropriés devraient avoir les permissions d'éditer ces fichiers. Disposer d'un environnement complet pour visualiser ce que les pages Web à publier affichent empêche le gestionnaire ou l'éditeur de faire une erreur lors de l'édition de ces fichiers.
