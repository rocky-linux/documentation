---
title: Méthode rapide
author: Lukas Magauer
contributors: Steven Spencer, Anna Zhyrnova
tested_with: 8.6, 9.0
tags:
  - documentation
  - serveur local
---

# Introduction

Vous pouvez compiler le système de documentation localement sans Docker ou LXD si vous le souhaitez. Si vous choisissez d'utiliser cette procédure, sachez que si vous faites beaucoup de programmation Python ou que vous utilisez Python localement, la marche à suivre la plus sûre est de créer un environnement virtuel Python [décrit ici](https://docs.python.org/3/library/venv.html). Cela permet de protéger tous vos processus Python les uns contre les autres, ce qui est recommandé. Si vous choisissez d'utiliser cette procédure sans l'environnement virtuel Python, sachez simplement que vous prenez un certain risque.

## Procédure

* Cloner le dépôt docs.rockylinux.org :

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* Une fois terminé, changez dans le répertoire docs.rockylinux.org :

```
cd docs.rockylinux.org
```

* Maintenant, clonez le dépôt de documentation en utilisant :

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* Ensuite, installez le fichier requirements.txt pour mkdocs :

```
python3 -m pip install -r requirements.txt
```

* Enfin pour terminer lancez le serveur mkdocs :

```
mkdocs serve
```

## Conclusion

Ceci fournit un moyen rapide et simple d'exécuter une copie locale de la documentation sans Docker ni LXD. Si vous choisissez cette méthode, il est fortement conseillé de configurer un environnement virtuel Python pour protéger vos autres processus Python.
