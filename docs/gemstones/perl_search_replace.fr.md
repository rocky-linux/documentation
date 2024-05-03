---
title: perl - Rechercher et Remplacer
author: Steven Spencer
tags:
  - perl
  - search
---

# `perl` - Rechercher et Remplacer

Parfois, vous devez rechercher et remplacer rapidement des chaînes de caractères dans un fichier ou un groupe de fichiers. Il y a plusieurs façons de le faire, mais cette méthode utilise `perl`

Pour rechercher et remplacer une chaîne de caractères particulière dans plusieurs fichiers d'un répertoire, la commande serait la suivante :

```bash
perl -pi -w -e 's/search_for/replace_with/g;' ~/Dir_to_search/*.html
```

Pour un seul fichier qui peut avoir plusieurs instances de la chaîne, vous pouvez indiquer le fichier :

```bash
perl -pi -w -e 's/search_for/replace_with/g;' /var/www/htdocs/bigfile.html
```

Cette commande utilise la syntaxe de vi pour rechercher et remplacer toute occurrence d'une chaîne de caractères et la remplacer par une autre chaîne de caractères dans un ou plusieurs fichiers d'un type particulier. Utile pour remplacer les changements de liens html/php intégrés dans ces types de fichiers et beaucoup d'autres choses.

## Description des options

| Option | Description                                                               |
| ------ | ------------------------------------------------------------------------- |
| `-p`   | place une boucle autour d'un script                                       |
| `-i`   | éditer le fichier                                                         |
| `-w`   | affiche les messages d'avertissement en cas de problème                   |
| `-e`   | autorise une seule ligne de code saisie sur la ligne de commande          |
| `-s`   | spécifie la recherche                                                     |
| `-g`   | indique un remplacement global, en d'autres termes toutes les occurrences |

## Conclusion

Un moyen simple de remplacer une chaîne dans un ou plusieurs fichiers en utilisant `perl`.
