---
title: Sauvegarde et Restauration
---

# Sauvegarde et Restauration

Dans ce chapitre, vous apprendrez comment sauvegarder et restaurer vos données avec Linux.

****

**Objectifs** : Dans ce chapitre, les futurs administrateurs Linux vont apprendre comment :

:heavy_check_mark: utiliser les commandes `tar` et `cpio` pour faire une sauvegarde ;   
:heavy_check_mark: vérifier les sauvegardes et restaurer des données ;   
:heavy_check_mark: comprimer ou décomprimer les sauvegardes.

:checkered_flag: **sauvegarde**, **restauration**, **compression**

**Connaissances** : :star: :star: :star:   
**Complexité** : :star: :star:

**Temps de lecture** : 40 minutes

****

!!! note "Remarque"

    Tout au long de ce chapitre les commandes utilisent le terme "device" - unité péripherique - pour spécifier à la fois la cible pour la sauvegarde et la source lors de la restauration. Le périphérique - device - peut indiquer soit un média externe, soit un fichier local. Vous pouvez toujours vous référer à cette note pour plus de précisions si besoin est.

La sauvegarde répondra à la nécessité de conserver et de restaurer les données de manière sûre et efficace.

La sauvegarde vous permet de vous protéger des événements suivants :

* **Destruction**: volontaire ou involontaire. Humain ou technique. Logiciels malveillants (virus, etc.)
* **Suppression** : volontaire ou involontaire. Humain ou technique. Logiciels malveillants, ...
* **Atteinte à l'intégrité** : les données deviennent inutilisables.

Aucun système n'est infaillible, aucun humain n'est infaillible, donc pour éviter de perdre des données, il doit être sauvegardé pour pouvoir le restaurer après un problème.

Le support de sauvegarde devrait être conservé dans une autre pièce (ou bâtiment) que le serveur afin qu'une catastrophe ne détruise pas le serveur et les sauvegardes.

En outre, l'administrateur doit vérifier régulièrement que les médias sont toujours lisibles.

## Généralités

Il y a deux principes, la **sauvegarde** et l'**archivage**.

* L'archivage détruit la source d'information après l'opération.
* La sauvegarde conserve la source des informations après l'opération.

Ces opérations consistent à enregistrer des informations dans un fichier, sur un périphérique ou sur un support physique (bandes magnétiques, disques, ...).

### Le processus

Les sauvegardes nécessitent beaucoup de discipline et de rigueur de la part de l'administrateur système. Il est nécessaire de se poser les questions suivantes :

* Quel est le média approprié ?
* Qu'est-ce qui doit être sauvegardé ?
* Combien de copies ?
* Combien de temps prendra la sauvegarde ?
* Quelle méthode ?
* À quelle fréquence ?
* Processus automatique ou manuel ?
* Où stocker la sauvegarde ?
* Combien de temps sera-t-elle conservée ?

### Méthodes de sauvegarde

* **Sauvegarde complète** : un ou plusieurs **systèmes de fichiers** sont sauvegardés (noyau, données, utilitaires, ...).
* **Partielle** : un ou plusieurs **fichiers** sont sauvegardés (configurations, répertoires, ...).
* **Différentielle** : seuls les fichiers modifiés depuis la dernière **sauvegarde complète** sont sauvegardés.
* **Incrémentale** : seuls les fichiers modifiés depuis la dernière sauvegarde sont sauvegardés.

### Périodicité

* **Pré-actuel** : à un moment donné (avant une mise à jour du système, ...).
* **Périodique** : quotidien, hebdomadaire, mensuel, ...

!!! tip "Astuce"

    Avant la modification d'un système, il est souvent utile de lancer une sauvegarde. Cependant, il ne sert à rien de sauvegarder chaque jour des données qui ne sont modifiées que chaque mois.

### Méthodes de restauration

Selon les utilitaires disponibles, il sera possible d'effectuer plusieurs types de restauration.

* **Restauration complète**: arborescences, ...
* **Restauration sélective** : partie de l'arborescence, fichiers, ...

Il est possible de restaurer une sauvegarde complète, mais il est également possible de ne restaurer qu'une partie de celle-ci. Cependant, lors de la restauration d'un répertoire, les fichiers créés après la sauvegarde ne sont pas supprimés.

!!! tip "Astuce"

    Afin de restaurer un répertoire tel qu'il était au moment de la sauvegarde, il est nécessaire de supprimer complètement son contenu avant de lancer la restauration.

### Les outils

Il existe de nombreux utilitaires pour faire des sauvegardes.

* **outils d'édition** ;
* **outils graphiques** ;
* **outils en ligne de commande** : `tar`, `cpio`, `pax`, `dd`, `dump`, ...

Les commandes que nous allons utiliser ici sont `tar` et `cpio`.

* `tar` :
  * facile à utiliser ;
  * permet d'ajouter des fichiers à une sauvegarde existante.
* `cpio` :
  * conserve les propriétaires - owner - ;
  * conserve les groupes, les dates et les droits ;
  * ignore les fichiers endommagés ;
  * arborescence de fichiers complète.

!!! note "Remarque"

    Ces commandes enregistrent les données en utilisant un format propriétaire et standardisé.

### Convention de nommage

L'utilisation d'une convention de nommage permet de cibler rapidement le contenu d'un fichier de sauvegarde et d'éviter ainsi des restaurations dangereuses.

* nom du répertoire ;
* utilitaire utilisé ;
* options utilisées ;
* date.

!!! tip "Astuce"

    Le nom de la sauvegarde doit être explicite.

!!! note "Note"

    La notion d'extension de fichier est inexistante sous Linux. En d'autres termes, l'utilisation des extensions ici est destinée à l'opérateur humain. Les extensions <code>.tar.gz or .tgz par exemple, seront des indications pour le traitement des fichiers par l'administrateur du système.
    </code>

### Contenu d'une sauvegarde

Une sauvegarde contient généralement les éléments suivants :

* le fichier ;
* le nom ;
* le propriétaire ;
* la taille ;
* les permissions ;
* date d'accès.

!!! Note

    Le numéro <code>inode est manquant.
    </code>

### Modes de stockage

Il y a deux modes de stockage différents :

* fichier sur disque ;
* périphérique.

## Tape ArchiveR - `tar`

La commande `tar` permet d'enregistrer sur plusieurs supports successifs (options multi-volumes).

Il est possible d'extraire tout ou une partie d'une sauvegarde.

`tar` sauvegarde implicitement en mode relatif même si le chemin des informations à sauvegarder est mentionné en mode absolu. Cependant, les sauvegardes et les restaurations en mode absolu sont possibles.

### Règles de restauration

Les bonnes questions à poser sont donc :

* quoi ? partiel ou complet ;
* où ? l'endroit où les données seront restaurées ;
* Comment ? absolu ou relatif ?

!!! Warning

    Avant une restauration, il est important de prendre le temps de réfléchir et de déterminer la méthode la plus appropriée pour éviter les erreurs.

Les restaurations sont généralement effectuées après un problème qui doit être résolu rapidement. Dans certains cas, une mauvaise restauration peut aggraver la situation.

### Sauvegarde avec `tar`

L'utilitaire par défaut pour créer des sauvegardes sur les systèmes UNIX est la commande `tar`. Ces sauvegardes peuvent être compressées par `bzip2`, `xz`, `lzip`, `lzma`, `lzop`, `gzip`, `compress` ou `zstd`.

`tar` vous permet d'extraire un seul fichier ou un répertoire d'une sauvegarde, de voir son contenu ou de valider son intégrité.

#### Estimer la taille d'une sauvegarde

La commande suivante estime la taille en kilo-octets d'un fichier _tar_ possible :

```
$ tar cf - /directory/to/backup/ | wc -c
20480
$ tar czf - /directory/to/backup/ | wc -c
508
$ tar cjf - /directory/to/backup/ | wc -c
428
```

!!! Warning

    Attention, la présence de "-" dans la ligne de commande perturbe `zsh`. Passer à <code>bash !
    </code>

#### Convention de nommage pour une sauvegarde avec `tar`

Voici un exemple de convention de nommage pour une sauvegarde `tar` , sachant que la date doit être ajoutée au nom.

| option  | Fichiers | Suffixe          | Observation                                   |
| ------- | -------- | ---------------- | --------------------------------------------- |
| `cvf`   | `home`   | `home.tar`       | `/home` en mode relatif, forme non compressée |
| `cvfP`  | `/etc`   | `etc.A.tar`      | `/etc` en mode absolu, pas de compression     |
| `cvfz`  | `usr`    | `usr.tar.gz`     | `/usr` en mode relatif, compression _gzip_    |
| `cvfj`  | `usr`    | `fr.tar.bz2`     | `/usr` en mode relatif, compression _bzip2_   |
| `cvfPz` | `/home`  | `home.A.tar.gz`  | `home` en mode absolu, compression _gzip_     |
| `cvfPj` | `/home`  | `home.A.tar.bz2` | `home` en mode absolu, compression _bzip2_    |
| …       |          |                  |                                               |

#### Créer une sauvegarde

##### Créer une sauvegarde en mode relatif

La création d'une sauvegarde non compressée en mode relatif est faite avec les paramètres `cvf` :

```
tar c[vf] [device] [fichier(s)]
```

Exemple :

```
[root]# tar cvf /backups/home.133.tar /home/
```


| Option | Observation                                                |
| ------ | ---------------------------------------------------------- |
| `c`    | Crée une sauvegarde.                                       |
| `v`    | Affiche le nom des fichiers traités.                       |
| `f`    | Vous permet de spécifier le nom de la sauvegarde (médium). |

!!! Tip

    Le tiret (`-`) devant les options de `tar` n'est pas nécessaire !

##### Créer une sauvegarde en mode absolu

La création d'une sauvegarde non compressée explicitement en mode absolu est faite avec les paramètres `cvfP`:

```
$ tar c[vf]P [device] [fichier(s)]
```

Exemple :

```
[root]# tar cvfP /backups/home.133.P.tar /home/
```

| Clé | Observation                          |
| --- | ------------------------------------ |
| `P` | Créer une sauvegarde en mode absolu. |


!!! Warning

    Avec l'option `P`, le chemin des fichiers à archiver doit être indiqué comme **absolut**. Si aucune des deux conditions (option `P` et chemin **absolut**) n'est indiquée, l'archivage est effectué en mode relatif.

##### Création d'une sauvegarde compressée avec `gzip`

La création d'une sauvegarde compressée avec `gzip` est faite avec les paramètres `cvfz`:

```
$ tar cvzf backup.tar.gz dirname/
```

| Option | Observation                          |
| ------ | ------------------------------------ |
| `z`    | Compresse la sauvegarde vers _gzip_. |


!!! Note

    L'extension `.tgz` est equivalente à `.tar.gz`.

!!! Note

    Sans modifier les options `cvf` (`tvf` ou `xvf`) pour  les  operations d'archivage et en ajoutant simplement l'option de compression en fin de liste, les commandes sont plus simples à comprendre (par exemple `cvfz` ou `cvfj`, etc.).

##### Création d'une sauvegarde compressée avec `bzip`

La création d'une sauvegarde compressée avec `bzip` est faite avec les paramètres `cvfj` :

```
$ tar cvfj backup.tar.bz2 dirname/
```

| Option | Observation                           |
| ------ | ------------------------------------- |
| `j`    | Compresse la sauvegarde dans _bzip2_. |

!!! Note

    Les extensions `.tbz` and `.tb2` sont equivalentes aux extensions `.tar.bz2`.

##### Compression `compress`, `gzip`, `bzip2`, `lzip` et `xz`

La compression et donc la décompression auront un impact sur la consommation des ressources (temps et utilisation du processeur).

Voici un classement de la compression d'un ensemble de fichiers texte, du moins à la plus efficace :

- compress (`.tar.Z`)
- gzip (`.tar.gz`)
- bzip2 (`.tar.bz2`)
- lzip (`.tar.lz`)
- xz (`.tar.xz`)

#### Ajouter un fichier ou un répertoire à une sauvegarde existante

Il est possible d'ajouter un ou plusieurs éléments à une sauvegarde existante.

```
tar {r|A}[key(s)] [device] [file(s)]
```

Pour ajouter `/etc/passwd` à la sauvegarde `/backups/home.133.tar`:

```
[root]# tar rvf /backups/home.133.tar /etc/passwd
```

L'ajout d'un répertoire est similaire. Ici ajouter `dirtoadd` à `backup_name.tar`:

```
$ tar rvf backup_name.tar dirtoadd
```

| Option | Observation                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------- |
| `r`    | Ajoute un ou plusieurs fichiers à la fin d'une sauvegarde de média en accès direct (disque dur).     |
| `A`    | Ajoute un ou plusieurs fichiers à la fin d'une sauvegarde sur un support d'accès séquentiel (bande). |

!!! Note

    Il n'est pas possible d'ajouter des fichiers ou des répertoires à une sauvegarde comprimée.

    ```
    $ tar rvfz backup.tgz filetoadd
    tar: Cannot update compressed archives
    Try `tar --help' or `tar --usage' for more information.
    ```

!!! Note

    Si la sauvegarde a étée crée en mode relatif, il faut ajouter des fichiers aussi en mode relatif. Si la sauvegarde a été faite en mode absolu, ajoutez des fichiers en mode absolu.
    
    Le mélange de modes (relatif, absolu) peuvent causer des problèmes lors de la restauration.

#### Lister le contenu d'une sauvegarde

Visualiser le contenu d'une sauvegarde sans extraction est possible.

```
tar t[key(s)] [device]
```

| Option | Observation                                              |
| ------ | -------------------------------------------------------- |
| `t`    | Affiche le contenu d'une sauvegarde (compressée ou non). |

Exemples :

```
$ tar tvf backup.tar
$ tar tvfz backup.tar.gz
$ tar tvfj backup.tar.bz2
```

Lorsque le nombre de fichiers dans une sauvegarde devient grand, il est possible de rediriger (_pipe_) le résultat de la commande `tar` vers un _pager_ (`more`, `less`, `most`, etc.) :

```
$ tar tvf backup.tar | less
```

!!! tip "Astuce"

    Pour lister ou récupérer le contenu d'une sauvegarde, il n'est pas nécessaire de mentionner l'algorithme de compression utilisé lors de la création de la sauvegarde. C'est-à-dire la commande <code>tar tvf est équivalente à tar tvfj pour lire le contenu et tar xvf à tar xvfj pour extraire.
    </code>

!!! tip "Astuce"

    Contrôler l'intégrité d'une sauvegarde.

#### Contrôler l'intégrité d'une sauvegarde

L'intégrité d'une sauvegarde peut être testée avec le paramètre `W` au moment de sa création :

```
$ tar cvfW file_name.tar dir/
```

L'intégrité d'une sauvegarde peut être testée avec le paramètre `d` après sa création :

```
$ tar vfd file_name.tar dir/
```

!!! tip "Astuce"

    En ajoutant un deuxième `v` à l'option précédente, vous obtiendrez la liste des fichiers archivés ainsi que les différences entre les fichiers archivés et ceux présents dans le système de fichiers.

    ```
    $ tar vvfd  /tmp/quodlibet.tar .quodlibet/
    drwxr-x--- rockstar/rockstar     0 2021-05-21 00:11 .quodlibet/
    -rw-r--r-- rockstar/rockstar     0 2021-05-19 00:59 .quodlibet/queue
    […]
    -rw------- rockstar/rockstar  3323 2021-05-21 00:11 .quodlibet/config
    .quodlibet/config: Mod time differs
    .quodlibet/config: Size differs
    […]
    ```

L'option `W` est également utilisée pour comparer le contenu d'une archive avec le système de fichiers :

```
$ tar tvfW file_name.tar
Verify 1/file1
1/file1: Mod time differs
1/file1: Size differs
Verify 1/file2
Verify 1/file3
```

La vérification avec l'option `W` ne peut pas être effectuée avec une archive compressée. L'option `d` doit être utilisée :

```
$ tar dfz file_name.tgz
$ tar dfj file_name.tar.bz2
```

#### Extraire (_untar_) une sauvegarde

Extraire (_untar_) une sauvegarde `*.tar` se fait avec les options `xvf` :

Extraire le fichier `etc/export` depuis la sauvegarde `/savings/etc.133.tar` vers le répertoire `etc` du répertoire actif :

```
$ tar xvf /backups/etc.133.tar etc/exports
```

Extraire tous les fichiers de la sauvegarde compressée `/backups/home.133.tar.bz2` dans le répertoire actif :

```
[root]# tar xvfj /backups/home.133.tar.bz2
```

Extraire tous les fichiers de la sauvegarde `/backups/etc.133.P.tar` vers leur répertoire d'origine :

```
$ tar xvfP /backups/etc.133.P.tar
```

!!! warning "Avertissement"

    Allez au bon endroit.
    
    Contrôler l'intégrité d'une sauvegarde.

| Option | Observation                                                |
| ------ | ---------------------------------------------------------- |
| `x`    | Extraire les fichiers de la sauvegarde, compressée ou non. |


L'extraction d'une sauvegarde _tar-gzipped_ (`*.tar.gz`) se fait avec les options `xvfz` :

```
$ tar xvfz backup.tar.gz
```

L'extraction d'une sauvegarde _tar-bzipped_ (`*.tar.bz2`) se fait avec les options `xvfj` :

```
$ tar xvfj backup.tar.bz2
```

!!! tip "Astuce"

    Pour extraire ou lister le contenu d'une sauvegarde, il n'est pas nécessaire de mentionner l'algorithme de compression qui a été utilisé pour créer la sauvegarde. C'est-à-dire, la commande <code>tar xvf est equivalente à tar xvfj pour extraire le contenu et tar tvf respectivement à tar tvfj pour lister.
    </code>

!!! warning "Attention"

    Pour restaurer les fichiers dans leur dossier d'origine (option `P` de `tar xvf`), vous devez avoir généré la sauvegarde avec le chemin absolu. C'est-à-dire l'option <code>P de la commande tar cvf.
    </code>

##### Extraire uniquement un fichier d'une sauvegarde _tar_

Pour extraire un fichier spécifique d'une sauvegarde _tar_ indiquez le nom de ce fichier à la fin de la commande `tar xvf`.

```
$ tar xvf backup.tar /path/to/file
```

La commande précédente n'extrait que le fichier `/path/to/file` de la sauvegarde `backup.tar`. Ce fichier sera restauré dans le répertoire `/path/to/` créé ou déjà présent dans le répertoire actif.

```
$ tar xvfz backup.tar.gz /path/to/file
$ tar xvfj backup.tar.bz2 /path/to/file
```

##### Extraire un dossier à partir d'une sauvegarde _tar_

Pour extraire d'une sauvegarde un seul répertoire (y compris ses sous-répertoires et fichiers), indiquez le nom du répertoire à la fin de la commande `tar xvf`.

```
$ tar xvf backup.tar /path/to/dir/
```

Pour extraire plusieurs répertoires, spécifiez chacun des noms l'un après l'autre :

```
$ tar xvf backup.tar /path/to/dir1/ /path/to/dir2/
$ tar xvfz backup.tar.gz /path/to/dir1/ /path/to/dir2/
$ tar xvfj backup.tar.bz2 /path/to/dir1/ /path/to/dir2/
```

##### Extraire un groupe de fichiers d'une sauvegarde _tar_ en utilisant des expressions régulières (_regex_)

Spécifiez une expression régulière (_regex_) pour extraire les fichiers correspondant au modèle de sélection spécifié.

Par exemple, pour extraire tous les fichiers avec l'extension `.conf`:

```
$ tar xvf backup.tar --wildcards '*.conf'
```

clés :

  * **--wildcards *.conf** correspond aux fichiers avec l'extension `.conf`.

## _CoPy Input Output_ - `cpio`

La commande `cpio` permet d'enregistrer sur plusieurs supports successifs sans spécifier d'options.

Il est possible d'extraire tout ou une partie d'une sauvegarde.

Il n'y a pas d'option, contrairement à la commande `tar` , de sauvegarder et de compresser en même temps. Donc, il se fait en deux étapes: la sauvegarde et la compression.

Pour effectuer une sauvegarde avec `cpio`, vous devez spécifier une liste de fichiers à sauvegarder.

Cette liste est fournie avec les commandes `find`, `ls` ou `cat`.

* `find` : parcourir un arbre, récursivement ou non ;
* `ls` : liste un répertoire, récursivement ou non ;
* `cat` : lit un fichier contenant les arbres ou les fichiers à sauvegarder.

!!! note "Remarque"

    `ls` ne peut pas être utilisé avec `-l` (détails) or `-R` (recursif).
    
    Il faut une simple liste de noms.

### Créer une sauvegarde avec la commande `cpio`

Syntaxe de la commande `cpio`:

```
[commande files |] cpio {-o| --create} [-options] [<file-list] [>device]
```

Exemple :

Avec une redirection de la sortie de `cpio`:

```
$ find /etc | cpio -ov > /backups/etc.cpio
```

Utilisation du nom d'un support de sauvegarde :

```
$ find /etc | cpio -ovF /backups/etc.cpio
```

Le résultat de la commande `find` est envoyé en entrée à la commande `cpio` via un _pipe_ (caractère `|`, <kbd>AltGr</kbd> + <kbd>6</kbd>).

Ici, la commande `find /etc` renvoie une liste de fichiers correspondant au contenu du répertoire `/etc` (récursivement) à la commande `cpio` , qui effectue la sauvegarde.

N'oubliez pas le signe `>` lors de la sauvegarde ou le `F save_name_cpio`.

| Options | Observation                                |
| ------- | ------------------------------------------ |
| `-o`    | Crée une sauvegarde (_sortie_).            |
| `-v`    | Affiche le nom des fichiers traités.       |
| `-F`    | Indique la sauvegarde à modifier (médium). |

Sauvegarde vers un média :

```
$ find /etc | cpio -ov > /dev/rmt0
```

Le support peut être de plusieurs types :

* tape drive: `/dev/rmt0`;
* une partition : `/dev/sda5`, `/dev/hda5`, etc.

### Type de sauvegarde

#### Sauvegarde avec chemin relatif

```
$ cd /
$ find etc | cpio -o > /backups/etc.cpio
```

#### Sauvegarde avec chemin absolu

```
$ find /etc | cpio -o > /backups/etc.A.cpio
```

!!! warning "Avertissement"

    Si le chemin spécifié dans la commande `find` est **absolu**, alors la sauvegarde sera effectuée en **absolu**.
    
    Si le chemin indiqué dans la commande `find` est **relatif**, alors la sauvegarde sera faite en **relative**.

### Ajouter à une sauvegarde

```
[commande files |] cpio {-o| --create} -A [-options] [<fic-list] {F|>device}
```

Exemple :

```
$ find /etc/shadow | cpio -o -AF SystemFiles.A.cpio
```

L'ajout de fichiers n'est possible que sur les supports d'accès direct.

| Option | Observation                                                     |
| ------ | --------------------------------------------------------------- |
| `-A`   | Ajoute un ou plusieurs fichiers à une sauvegarde sur le disque. |
| `-F`   | Indique la sauvegarde à modifier.                               |

### Compression d'une sauvegarde

* Enregistrer la sauvegarde**puis** comprimer

```
$ find /etc | cpio  –o > etc.A.cpio
$ gzip /backups/etc.A.cpio
$ ls /backups/etc.A.cpio*
/backups/etc.A.cpio.gz
```

* Enregistrer **et** comprimer

```
$ find /etc | cpio –o | gzip > /backups/etc.A.cpio.gz
```

Il n'y a pas d'option, contrairement à la commande `tar`, pour sauvegarder et compresser en même temps. Il se fait donc en deux étapes : enregistrer et comprimer.

La syntaxe de la première méthode est plus facile à comprendre et à retenir, car elle se fait en deux étapes.

Pour la première méthode, le fichier de sauvegarde est automatiquement renommé par l'utilitaire `gzip` qui ajoute `.gz` à la fin du nom du fichier. De même, l'utilitaire `bzip2` ajoute automatiquement `.bz2`.

### Lire le contenu d'une sauvegarde

Syntaxe de la commande `cpio` pour lire le contenu d'une sauvegarde _cpio_ :

```
cpio -t [-options] [<fic-list]
```

Exemple :

```
$ cpio -tv </backups/etc.152.cpio | less
```

| Options | Observation                       |
| ------- | --------------------------------- |
| `-t`    | Lit une sauvegarde.               |
| `-v`    | Affiche les attributs du fichier. |

Après avoir fait une sauvegarde, vous devez lire son contenu pour vous assurer qu'il n'y a pas eu d'erreurs.

De la même manière, avant d'effectuer une restauration, vous devez lire le contenu de la sauvegarde qui sera utilisée.

### Restaurer une sauvegarde

Syntaxe de la commande `cpio` pour restaurer une sauvegarde :

```
cpio {-i| --extract} [-E file] [-options] [<device]
```

Exemple :

```
$ cpio -iv </backups/etc.152.cpio | less
```

| Options                      | Observation                                                                  |
| ---------------------------- | ---------------------------------------------------------------------------- |
| `-i`                         | Restaurer une sauvegarde complète.                                           |
| `-E file`                    | Restaure uniquement les fichiers dont le nom est contenu dans le fichier.    |
| `--make-directories` or `-d` | Reconstruit l'arborescence manquante.                                        |
| `- u`                        | Remplace tous les fichiers même s'ils existent.                              |
| `--no-absolute-filenames`    | Permet de restaurer une sauvegarde faite en mode absolu de manière relative. |

!!! warning "Avertissement"

    Par défaut, au moment de la restauration, les fichiers du disque dont la date de dernière modification est plus récente ou égale à la date de la sauvegarde ne sont pas restaurés (afin d'éviter d'écraser des informations récentes par des informations plus anciennes).
    
    L'option `u` vous permet par contre de restaurer les anciennes versions des fichiers.

Exemples :

* Restauration absolue d'une sauvegarde absolue

```
$ cpio –ivF home.A.cpio
```

* Restauration absolue sur une arborescence existante

L'option `u` vous permet de remplacer les fichiers existants à l'endroit où la restauration a lieu.

```
$ cpio –iuvF home.A.cpio
```

* Restaurer une sauvegarde absolue en mode relatif

L'option longue `no-absolute-filenames` permet une restauration en mode relatif. En effet, le `/` au début du chemin sera supprimé.

```
$ cpio --no-absolute-filenames -divuF home.A.cpio
```

!!! tip "Astuce"

    La création de répertoires est peut-être nécessaire, d'où l'utilisation de l'option `d`

* Restaurer une sauvegarde relative

```
$ cpio –iv <etc.cpio
```

* Restauration absolue d'un fichier ou d'un répertoire

La restauration d'un fichier ou d'un répertoire particulier nécessite la création d'un fichier de liste qui doit ensuite être supprimé.

```
echo "/etc/passwd" > tmp
cpio –iuE tmp -F etc.A.cpio
rm -f tmp
```

## Utilitaires de compression - décompression

L'utilisation de la compression au moment d'une sauvegarde peut avoir un certain nombre d'inconvénients :

* Augmente le temps de sauvegarde ainsi que le temps de restauration.
* Il rend impossible d'ajouter des fichiers à la sauvegarde.

!!! Note

    Il est donc préférable de faire une sauvegarde et de la compresser plutôt que de comprimer lors de la sauvegarde.

### Compression avec `gzip`

La commande `gzip` comprime les données.

Syntaxe de la commande `gzip` :

```
gzip [options] [file ...]
```

Exemple :

```
$ gzip usr.tar
$ ls
usr.tar.gz
```

Le fichier obtient l'extension `.gz`.

Elle conserve les mêmes droits et les mêmes dates d'accès et de modification.

### Compression avec `bunzip2`

La commande `bunzip2` compresse également les données.

Syntaxe de la commande `bzip2` :

```
bzip2 [options] [fichier ...]
```

Exemple :

```
$ bzip2 usr.cpio
$ ls
usr.cpio.bz2
```

Le nom du fichier est complété par l'extension `.bz2`.

La compression par `bzip2` est préférable à la compression par `gzip` mais elle met plus de temps à être exécutée.

### Décompression avec `gunzip`

La commande `gunzip` décompresse les données compressées.

Syntaxe de la commande `gunzip` :

```
gunzip [options] [file ...]
```

Exemple :

```
$ gunzip usr.tar.gz
$ ls
usr.tar
```

Le nom du fichier est tronqué par `gunzip` et l'extension `.gz` est supprimée.

`gunzip` décompresse également les fichiers avec les extensions suivantes :

* `.z`;
* `-z` ;
* `_z`.

### Décompression avec `bunzip2`

La commande `bunzip2` décompresse les données compressées.

Syntaxe de la commande `bzip2` :

```
bzip2 [options] [fichier ...]
```

Exemple :

```
$ bunzip2 usr.cpio.bz2
$ ls
usr.cpio
```

Le nom du fichier est tronqué par `bunzip2` et l'extension `.bz2` est supprimée.

`bunzip2` décompresse également un fichier avec les extensions suivantes :

* `-bz` ;
* `.tbz2` ;
* `tbz`.
