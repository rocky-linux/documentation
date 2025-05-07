---
title: Présentation
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - codage
  - éditeur
---

# :material-book-open-page-variant-outline: Introduction

Tout au long de ce livre, vous trouverez des moyens d'implémenter Neovim, avec NvChad, pour créer un environment IDE (**I**ntegrated **D**eveloppement **E**).

Nous disons "moyens" car il y a de nombreuses possibilités. L'auteur se concentre ici sur l'utilisation de ces outils pour écrire en markdown, mais si markdown n'est pas votre focus, ne vous inquiétez pas et survolez simplement les détails de markdown. Si vous n'êtes pas familier avec l'un de ces outils (NvChad ou Neovim), alors ce livre vous donnera une introduction aux deux, et si vous parcourez ces documents, vous réaliserez bientôt que vous pouvez configurer cet environnement pour être une aide considérable pour n'importe quel besoin de programmation ou d'écriture de scripts.

Vous voulez un IDE qui vous aidera à écrire desplay books Ansible? Vous pouvez obtenir cela ! Vous voulez un IDE pour Golang ? C'est également disponible. Vous voulez simplement une bonne interface pour écrire des scripts BASH ? C'est tout aussi possible.

Grâce à l'utilisation de ==**L**anguage **S**serveur **P**rotocols== et ==linters==, vous pouvez configurer un environnement personnalisé pour vous-même. Un des avantages est qu'une fois que vous avez la configuration de l'environnement, elle peut être rapidement mise à jour lorsque de nouveaux changements sont disponibles grâce à l'utilisation de [lazy.nvim](https://github.com/folke/lazy.nvim) et [Mason](https://github.com/williamboman/mason.nvim), qui sont tous deux couverts ici.

Comme Neovim est un fork de [Vim](https://www.vim.org/), l'interface globale sera familière aux utilisateurs de *vim*. Si vous n'êtes pas un utilisateur `vim`, vous assimilerez rapidement la syntaxe des commandes en utilisant ce livre. Il y a beaucoup d'informations couvertes ici, mais il est facile de les suivre et, une fois que vous avez terminé le contenu, vous en saurez assez pour construire votre propre IDE adapté à *vos exigences* avec ces outils.

Il était dans l'intention de l'auteur de ne **pas** diviser ce livre en chapitres. La raison en est que cela implique un ordre qui doit être suivi et, pour la plus grande part, ce n'est pas nécessaire. Vous *voudrez* commencer par cette page, lire et suivre les sections "Logiciel Supplémentaire", "Installer Neovim" et "Installer NvChad", mais à partir de là, vous pouvez choisir comment procéder.

## :simple-neovim: Utiliser Neovim en tant qu'IDE

L'installation de base de Neovim fournit un excellent éditeur pour le développement, mais on ne peut pas encore l'appeler IDE ; toutes les fonctionnalités IDE avancées, même si déjà prédéfinies, ne sont pas encore activées. Pour ce faire, nous devons passer en revue les configurations nécessaires à Neovim et c'est là que NvChad vient à notre aide. Cela nous permet d'avoir une configuration de base avec une seule commande !

La configuration est écrite en Lua, un langage de programmation très rapide qui permet à NvChad d'avoir des temps très courts de démarrage et l'exécution très rapide pour les commandes et les touches correspondantes. Ceci est également rendu possible par la technique de chargement ==Lazy loading== utilisée pour les plugins qui ne les charge que lorsque nécessaire.

L'interface se révèle tout à fait propre et agréable.

Comme les développeurs de NvChad tiennent à le souligner, le projet est uniquement destiné à être une base sur laquelle construire votre propre IDE personnalisé. La personnalisation subséquente se fait par le biais de plugiciels.

![Interface NvChad](images/nvchad_rocky.png)

### Caractéristiques principales

* :material-run-fast: **Conçu pour être rapide.** Du choix du langage de programmation aux techniques de chargement des composants, tout est conçu pour minimiser le temps d'exécution.
* :material-invert-colors: **Interface attrayante.** Bien qu'il s'agisse d'une application *cli*, l'interface est moderne et élégante graphiquement et tous les composants s'adaptent parfaitement à l'interface utilisateur.
* :material-file-settings-outline: **Extrêmement configurable.** Grâce à la modularité dérivée de l'application de base (NeoVim), l'éditeur s'adapte parfaitement aux besoins de chacun. Cependant, n'oubliez pas que lorsque nous parlons de personnalisation, nous faisons référence à la fonctionnalité et non à l'apparence de l'interface.
* :material-update: **Mécanisme de mise à jour automatique.** L'éditeur est livré avec un mécanisme (via l'utilisation de *git*) qui permet les mises à jour avec une simple commande `:NvChadUpdate`.
* :material-langage-lua: **Propulsé par Lua.** La configuration de NvChad est entièrement écrite en *lua*, ce qui lui permet de s'intégrer de manière transparente à la configuration de `Neovim` en profitant de tout le potentiel de l'éditeur sur lequel il est basé.
* :material-palette-outline: **Nombreux thèmes intégrés.** La configuration inclut déjà un grand nombre de thèmes à utiliser, en gardant toujours à l'esprit que nous parlons d'une application *cli*, les thèmes peuvent être sélectionnés avec la touche `<leader> + th`.

![Thèmes NvChad](images/nvchad_th.png)

## Références

### :simple-lua: Lua

#### Qu'est-ce que le langage Lua ?

Lua est un langage de script robuste et léger, qui supporte une variété de paradigmes de programmation. Le nom « Lua » vient du mot portugais signifiant « lune ».

Lua a été développé à l'université catholique de Rio de Janeiro par Roberto Lerusalimschy, Luiz Henrique de Figueiredo et Waldemar Celes. Le développement était nécessaire pour eux parce que, jusqu'en 1992, le Brésil était soumis à des règles d'importation strictes pour le matériel et les logiciels. Par simple nécessité, ces trois programmeurs développent leur propre langage de script appelé Lua.

Comme le langage Lua se concentre principalement sur les scripts, il est rarement utilisé comme un langage de programmation autonome. Par conséquent, il est le plus souvent utilisé comme un langage de script qui peut être intégré (intégré) à d'autres programmes.

Lua est utilisé dans le développement de jeux vidéo et de moteurs de jeux (Roblox, Warframe, ...) en tant que langage de programmation dans de nombreux programmes réseau (Nmap, ModSecurity, ...) et en tant que langage de programmation dans des programmes industriels. Le langage Lua est également utilisé comme une bibliothèque que les développeurs peuvent intégrer dans leurs programmes pour activer les fonctionnalités de scripting en agissant uniquement comme partie intégrante de l'application hôte.

#### Fonctionnement de Lua

Il existe deux composantes principales de Lua :

* L'interpréteur de Lua
* La machine virtuelle de Lua (VM)

Lua n'est pas interprété directement à travers un fichier Lua comme d'autres langages, par exemple Python. À la place, il utilise l'interpréteur de Lua pour compiler un fichier Lua en bytecode. L'interprète `Lua` est hautement portable et capable de fonctionner sur une multitude d'appareils.

#### Caractéristiques Principales

* Performance : Lua est considéré comme l'un des langages de programmation les plus rapides parmi les langages de script interprétés ; il peut effectuer des tâches très gourmandes en performances plus rapidement que la plupart des autres langages de programmation.
* Taille : Lua est modeste par rapport aux autres langages de programmation. Cette petite taille est idéale pour intégrer Lua dans plusieurs plates-formes, des appareils embarqués aux moteurs de jeu.
* Portabilité et intégration : la portabilité de Lua est pratiquement illimitée. Toute plate-forme prenant en charge le compilateur C standard peut exécuter Lua sans problème. Lua ne nécessite pas de réécriture complexe pour être compatible avec d’autres langages de programmation.
* Simplicité : Lua a une conception simple mais offre des fonctionnalités puissantes. L'une des principales fonctionnalités de Lua réside dans les métamécanismes, qui permettent aux développeurs d'implémenter leurs propres fonctionnalités. La syntaxe est simple et facile à comprendre, de sorte que tout le monde peut apprendre Lua et l'utiliser dans ses propres programmes.
* Licence : Lua est un logiciel libre et open-source distribué sous licence MIT. Cela permet à quiconque de l’utiliser à n’importe quelle fin sans être obligé de payer une licence ou des redevances.

### :simple-neovim: Neovim

Neovim est décrit en détail sur sa [page dédiée](./install_nvim.md), nous nous attarderons donc uniquement sur les principales fonctionnalités, qui sont les suivantes :

* Performances : Très rapide.
* Personnalisable : Large écosystème de plugins et de thèmes.
* Mise en évidence de la syntaxe : intégration avec Treesitter et LSP (nécessite quelques configurations supplémentaires).
* Multiplateforme : Linux, Windows et macOS
* Licence MIT : Une licence permissive courte et simple avec des conditions exigeant uniquement la préservation des mentions de droit d'auteur et de licence.

### :material-protocol: LSP

Qu'est-ce que le LSP, **L**anguage **S**erver **P**rotocol ?

Un serveur de langue est une bibliothèque de langue standardisée qui utilise sa propre procédure (protocole) pour fournir le support de fonctions telles que l'autocomplétion, définition de `goto` ou redéfinition de `mouseover`.

L'idée qui sous-tend le protocole de serveur de langue (LSP) est de standardiser le protocole de communication entre les outils et les serveurs, afin qu'un serveur de langue unique puisse être réutilisé dans plusieurs outils de développement. De cette façon, les développeurs peuvent simplement intégrer ces bibliothèques dans leur éditeur et référencer les infrastructures linguistiques existantes, au lieu de personnaliser leur code pour les inclure.

### :material-file-document-check-outline: tree-sitter

[Tree-sitter](https://tree-sitter.github.io/tree-sitter/) se compose essentiellement de deux composantes : un générateur d'analyseur ==parser generator== et une bibliothèque d'analyse incrémentale ==incremental parsing library==. Il peut construire une arborescence syntaxique du fichier source et le mettre à jour efficacement à chaque modification.

Un analyseur est un composant qui décompose des données en éléments plus petits pour faciliter sa traduction dans une autre langue ou comme dans notre cas, d'être ensuite passé à la bibliothèque d'analyse. Une fois le fichier source décomposé, la bibliothèque d'analyse traite le code et le transforme en arborescence syntaxique, permettant de manipuler plus intelligemment la structure du code. Cela permet d'améliorer (et d'accélérer)

* coloration syntaxique
* navigation de code
* réusinage de code
* objets texte et mouvements

??? note "complémentarité de LSP et tree-sitter".

    Bien qu'il puisse sembler que les deux services (LSP et tree-sitter) soient redondants, ils sont en fait complémentaires dans la mesure où LSP travaille au niveau du projet alors que tree-sitter ne fonctionne que sur le fichier open source.

Maintenant que nous avons expliqué un peu les technologies utilisées pour créer l'IDE, nous pouvons passer au [Logiciel supplémentaire](./additional_software.md) nécessaire pour configurer et personnaliser NvChad.
