---
title: sed - Rechercher et Remplacer
author: Steven Spencer
---

# `sed` - Rechercher et remplacer

`sed` est une commande qui signifie « stream editor ».

## Conventions

* `path` : le chemin actuel. Exemple : `/var/www/html/`
* `filename` : Le nom du fichier actuel. Exemple : `index.php`

## Utilisation de `sed`

Utiliser `sed` pour la recherche et le remplacement est la préférence personnelle de l'auteur, car vous pouvez utiliser un délimiteur de votre choix, qui rend très pratique le remplacement de choses comme les liens web contenant « / ». Les exemples par défaut pour l'édition en place en utilisant `sed` montrent des choses comme dans cet exemple :

`sed -i 's/search_for/replace_with/g' /path/filename`

Mais que faire si vous recherchez des chaînes qui contiennent "/" ? Et si la barre oblique était la seule option disponible comme délimiteur ? Vous devez éviter toute barre oblique avant de pouvoir l'utiliser dans votre recherche. C'est ici que `sed` excelle par rapport aux autres outils, car le délimiteur est modifiable à la volée (vous n'avez pas besoin de préciser que vous le modifiez quelque part). Comme mentionné ci-dessus, si vous recherchez des éléments avec "/", vous pouvez le faire en remplaçant le délimiteur par "|". Voici un exemple de recherche de lien en utilisant cette méthode :

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

Vous pouvez utiliser n'importe quel caractère d'un octet pour le délimiteur à l'exception des antislash, newline et "s". Par exemple, cela fonctionne aussi :

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` où "a" est le délimiteur, la fonction recherche et remplacement fonctionne toujours. Pour des raisons de sécurité, vous pouvez spécifier une sauvegarde lors de la recherche et du remplacement, ce qui est pratique pour vous assurer que les changements que vous faites avec `sed` sont ceux que vous _voulez vraiment_. Cela vous donne une option de récupération à partir du fichier de sauvegarde :

`sed -i.bak s|search_for|replacea_with|g /path/filename`

Ce qui va créer une version intacte du fichier `filename` appelée `filename.bak`

Vous pouvez également utiliser des guillemets doubles au lieu de guillemets simples si vous le désirez :

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## Explication des Options

| Option | Description                                                             |
| ------ | ----------------------------------------------------------------------- |
| i      | éditer le fichier                                                       |
| i.ext  | créer une sauvegarde avec une extension quelconque (par exemple., .ext) |
| s      | spécifie la recherche                                                   |
| g      | spécifie le remplacement global, c'est-à-dire de toutes les occurrences |

## Plusieurs fichiers

Malheureusement, `sed` n'a pas d'option de boucle en ligne comme `perl`. Pour traiter plusieurs fichiers ensemble, vous devez intégrer votre commande `sed` dans un script. Voici un exemple de faire ainsi.

Tout d’abord, générez une liste de fichiers que le script va utiliser. Effectuez cette opération à partir de la ligne de commande avec :

`find /var/www/html  -name "*.php" > phpfiles.txt`

Ensuite, créez un script pour utiliser ce fichier `phpfiles.txt`:

```bash
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```

Le script parcoure tous les fichiers créés dans `phpfiles.txt`, crée une sauvegarde de chaque fichier et exécute la fonction rechercher et remplacer de la chaîne de caractères globalement. Une fois que vous avez vérifié que votre recherche et votre remplacement ont été effectués avec succès et que vos modifications sont vérifiées, vous pouvez supprimer tous les fichiers de sauvegarde.

## Autres Articles et Exemples

* `sed` [manual page](https://linux.die.net/man/1/sed)
* `sed` [exemples supplémentaires](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [O'Reilly Book](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Conclusion

`sed` est un outil puissant qui fonctionne très bien pour les fonctions de recherche et de remplacement, en particulier lorsque le délimiteur doit être flexible.
