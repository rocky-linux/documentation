---
title: Bash - Vérifiez vos connaissances
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - formation
  - script bash
  - bash
---

# Bash - Vérifiez vos connaissances

:heavy_check_mark: Chaque commande doit retourner un code retour à la fin de son exécution :

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Un code retour de 0 indique une erreur d'exécution :

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Le code retour est stocké dans la variable `$@` :

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: La commande `test` vous permet de :

- [ ] Tester le type de fichier
- [ ] Tester une variable
- [ ] Comparer des nombres
- [ ] Comparer le contenu de 2 fichiers

:heavy_check_mark: La commande `expr`:

- [ ] Concatène 2 chaînes de caractères
- [ ] Effectue des opérations mathématiques
- [ ] Afficher le texte à l'écran

:heavy_check_mark: La syntaxe de la structure conditionnelle ci-dessous vous semble-t-elle correcte ? Expliquez pourquoi.

```bash
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Que signifie la syntaxe suivante : `${variable:=valeur}`

- [ ] Affiche une valeur de remplacement si la variable est vide
- [ ] Affiche une valeur de remplacement si la variable n'est pas vide
- [ ] Assigne une nouvelle valeur à la variable si elle est vide

:heavy_check_mark: La syntaxe de la structure alternative conditionnelle ci-dessous vous semble-t-elle correcte ? Expliquez pourquoi.

```bash
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Lequel des éléments suivants n'est pas une structure pour la boucle?

- [ ] while
- [ ] until
- [ ] boucle
- [ ] for
