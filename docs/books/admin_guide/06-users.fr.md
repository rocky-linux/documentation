---
title: La gestion des utilisateurs
---

# La gestion des utilisateurs

Dans ce chapitre, vous aller apprendre à gérer les utilisateurs.

****
**Objectifs** : Dans ce chapitre, les futurs administrateurs Linux apprendront à :

:heavy_check_mark: ajouter, supprimer ou modifier un **groupe** ;   
:heavy_check_mark: ajouter, supprimer ou modifier un **utilisateur** ;   
:heavy_check_mark: comprendre les fichiers associés aux utilisateurs et aux groupes et apprendre à les gérer ;   
:heavy_check_mark: modifiez le *propriétaire* ou le *groupe propriétaire* d'un fichier ;   
:heavy_check_mark: *sécuriser* les comptes utilisateur ;   
:heavy_check_mark: changer d'identité.

:checkered_flag: **utilisateurs**

**Connaissances : ** :star: :star:   
**Complexité : ** :star: :star:

**Temps de lecture** : 30 minutes
****

## Généralités

Chaque utilisateur est membre d'au moins un groupe, qui est appelé le **groupe principal de l'utilisateur**.

Plusieurs utilisateurs peuvent faire partie d’un même groupe.

Les autres groupes que le groupe principal sont appelés **groupes secondaires de l'utilisateur**.

!!! Note

    Chaque utilisateur a un groupe principal et peut être invité dans un ou plusieurs groupes secondaires.

Les groupes et utilisateurs se gèrent par leur identifiant numérique unique `GID` et `UID`.

* `UID` : _User IDentifier_. Identifiant unique d’utilisateur.
* `GID` : _Group IDentifier_. Identifiant unique de groupe.

L'UID et le GID sont reconnus par le noyau, ce qui signifie que le Super Admin n'est pas nécessairement l'utilisateur **root** , tant que l'utilisateur ayant pour **uid=0** est le Super Admin.

Les fichiers liés aux utilisateurs/groupes sont:

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/skel/
* /etc/default/useradd
* /etc/login.defs

!!! Danger

    Il est recommandé d’utiliser les commandes d’administration au lieu de modifier manuellement les fichiers.

## Gestion des groupes

Fichiers modifiés, ajout de lignes :

* `/etc/group`
* `/etc/gshadow`

### La commande `groupadd`

La commande `groupadd` permet d’ajouter un groupe au système.
```
groupadd [-f] [-g GID] groupe
```

Exemple :

```
$ sudo groupadd -g 1012 GroupeB
```

| Option   | Description                                                                                                                                 |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `-g GID` | `GID` du groupe à créer.                                                                                                                    |
| `-f`     | Le système choisit un `GID` si celui précisé par l’option `-g` existe déjà.                                                                 |
| `-r`     | Crée un groupe système avec un `GID` compris entre `SYS_GID_MIN` et `SYS_GID_MAX`. Ces deux variables sont définies dans `/etc/login.defs`. |

Règles de nommage des groupes :

* Pas d’accents, ni caractères spéciaux ;
* Différents du nom d’un utilisateur ou fichier système existant.

!!! Note

    Sous **Debian**, l'administrateur devrait utiliser, sauf dans les scripts destinés à être portables sur toutes les distributions Linux, les commandes `addgroup` et `delgroup` spécifiées dans le `man` :

    ```
    $ man addgroup
    DESCRIPTION
        adduser et addgroup ajoutent des utilisateurs ou des groupes au système en fonction des options fournies en ligne de commande et des informations contenues dans le fichier de configuration /etc/adduser.conf. Ce sont des interfaces plus conviviales que les programmes useradd et groupadd. Elles  permettent de choisir par défaut des UID ou des GID conformes à la charte Debian, de créer un répertoire personnel configuré suivant un modèle (squelette), d'utiliser un script sur mesure, et d'autres fonctionnalités encore.
    ```

### La commande `groupmod`

La commande `groupmod` permet de modifier un groupe existant sur le système.

```
groupmod [-g GID] [-n nom] groupe
```

Exemple :

```
$ sudo groupmod -g 1016 GroupeP
$ sudo groupmod -n GroupeC GroupeB
```

| Option   | Description                         |
| -------- | ----------------------------------- |
| `-g GID` | Nouveau `GID` du groupe à modifier. |
| `-n nom` | Nouveau nom.                        |

Il est possible de modifier le nom d’un groupe, son `GID` ou les deux simultanément.

Après modification, les fichiers appartenant au groupe ont un `GID` inconnu. Il faut leur réattribuer le nouveau `GID`.

```
$ sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### La commande `groupdel`

La commande `groupdel` permet de supprimer un groupe existant sur le système.

```
groupdel groupe
```

Exemple :

```
$ sudo groupdel GroupeC
```

!!! Tip

    Lors de la suppression d'un groupe, il y a deux conditions :

    * Si un utilisateur a un groupe principal unique et que vous exécutez la commande `groupdel` sur ce groupe, vous serez informés qu'il y a un utilisateur spécifique dans le groupe et qu'il ne peut pas être supprimé.
    * Si un utilisateur appartient à un groupe secondaire (ce n'est pas le groupe principal de l'utilisateur) et que ce groupe n'est pas le groupe principal d'un autre utilisateur du système, alors la commande `groupdel` supprimera le groupe sans notification supplémentaire.

    Exemples :

    ```bash
    Shell > useradd testa
    Shell > id testa
    uid=1000(testa) gid=1000(testa) group=1000(testa)
    Shell > groupdel testa
    groupdel: cannot remove the primary group of user 'testa'

    Shell > groupadd -g 1001 testb
    Shell > usermod -G testb root
    Shell > id root
    uid=0(root) gid=0(root) group=0(root),1001(testb)
    Shell > groupdel testb
    ```

!!! Tip

    Lorsque vous supprimez un utilisateur en utilisant la commande `userdel -r`, le groupe principal correspondant est également supprimé. Le nom du groupe principal est généralement le même que celui de l'utilisateur.

!!! Tip

    Chaque groupe a un `GID` unique. Un groupe peut être utilisé par plusieurs utilisateurs comme groupe secondaire. Par convention, le GID du super administrateur est 0. Les GID réservés à certains services ou processus vont de 201à 999, ils sont appelés groupes système ou groupes de pseudo-utilisateurs. Le GID pour les utilisateurs est généralement supérieur ou égal à 1000. Ils sont liés à <font color=red>/etc/login.defs</font>, dont nous reparlerons plus tard.

    ```bash
    # Comment line ignored
    shell > cat  /etc/login.defs
    MAIL_DIR        /var/spool/mail
    UMASK           022
    HOME_MODE       0700
    PASS_MAX_DAYS   99999
    PASS_MIN_DAYS   0
    PASS_MIN_LEN    5
    PASS_WARN_AGE   7
    UID_MIN                  1000
    UID_MAX                 60000
    SYS_UID_MIN               201
    SYS_UID_MAX               999
    GID_MIN                  1000
    GID_MAX                 60000
    SYS_GID_MIN               201
    SYS_GID_MAX               999
    CREATE_HOME     yes
    USERGROUPS_ENAB yes
    ENCRYPT_METHOD SHA512
    ```

!!! Tip

    Un utilisateur faisant obligatoirement partie d’un groupe, il est préférable de créer les groupes avant d’ajouter les utilisateurs. Par conséquent, un groupe peut ne pas avoir de membres.

### Le fichier `/etc/group`

Ce fichier contient les informations de groupes (séparées par `:`).

```
$ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1 : Nom du groupe.
* 2 : Le mot de passe du groupe est identifié par `x`. Le mot de passe du groupe est stocké dans `/etc/gshadow`.
* 3 : GID.
* 4 : Utilisateurs supplémentaires du groupe (à l'exclusion des utilisateurs dont c'est le groupe principal).

!!! Note

   Chaque ligne du fichier `/etc/group` correspond à un groupe. Les informations de l'utilisateur principal sont stockées dans `/etc/passwd`.

### Le fichier `/etc/gshadow`

Ce fichier contient les informations de sécurité sur les groupes (séparés par `:`).

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1 : Nom du groupe.
* 2: Mot de passe chiffré.
* 3 : Nom de l'administrateur du groupe.
* 4 : Utilisateurs supplémentaires du groupe (à l'exclusion des utilisateurs dont c'est le groupe principal).

!!! Warning

    Les noms des groupes dans **/etc/group** et **/etc/gshadow** doivent correspondre ligne par ligne, c'est-à-dire chaque ligne du fichier **/etc/group** doit avoir une ligne correspondante dans le fichier **/etc/gshadow**.

Un `!` au niveau du mot de passe indique que celui-ci est verrouillé. Ainsi aucun utilisateur ne peut utiliser le mot de passe pour accéder au groupe (sachant que les membres du groupe n’en ont pas besoin).

## Gestion des utilisateurs

### Définition

Un utilisateur se définit comme suit dans le fichier `/etc/passwd` :

* 1 : Nom de connexion ;
* 2 : Identification du mot de passe, `x` indique que l'utilisateur a un mot de passe, ce mot de passe encrypté est enregistré dans le second champ du fichier `/etc/shadow` ;
* 3 : UID ;
* 4 : GID du groupe primaire ;
* 5 : Commentaires ;
* 6 : Répertoire de connexion ;
* 7 : Shell (`/bin/bash`, `/bin/nologin`, ...).

Il existe trois types d’utilisateurs :

* **root(uid=0)** : l'administrateur système ;
* **utilisateurs système (uid entre 201 et 999)** : utilisé par le système pour gérer les droits d'accès aux applications ;
* **utilisateur standard (uid>=1000)** : autre compte pour se connecter au système.

Fichiers modifiés, ajout de lignes :

* `/etc/passwd`
* `/etc/shadow`

### La commande `useradd`

La commande `useradd` permet d’ajouter un utilisateur.

```
useradd [-u UID] [-g GID] [-d répertoire] [-s shell] login
```

Exemple :

```
$ sudo useradd -u 1000 -g 1013 -d /home/GroupeC/carine carine
```

| Option              | Description                                                                                                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-u UID`            | `UID` de l’utilisateur à créer.                                                                                                                                                             |
| `-g GID`            | `GID` du groupe principal. Le `GID` ici peut également être un nom de groupe ``.                                                                                                            |
| `-G GID1,[GID2]...` | `GID` des groupes supplémentaires. Le `GID` ici peut également être un `nom de groupe`. Plusieurs groupes supplémentaires peuvent être spécifiés, séparés par des virgules.                 |
| `-d repertoire`     | Répertoire de connexion.                                                                                                                                                                    |
| `-s shell`          | Interpréteur de commandes.                                                                                                                                                                  |
| `-c COMMENTAIRES`   | Ajoute un commentaire.                                                                                                                                                                      |
| `-U`                | Ajoute l’utilisateur à un groupe portant le même nom créé simultanément. Si cette option n'est pas écrite par défaut, un groupe avec le même nom sera créé lorsque l'utilisateur sera créé. |
| `-M`                | Ne pas créer le répertoire personnel de l'utilisateur.                                                                                                                                      |
| `-r`                | Créer un compte système.                                                                                                                                                                    |

À la création, le compte ne possède pas de mot de passe et est verrouillé.

Il faut assigner un mot de passe pour déverrouiller le compte.

Lorsque la commande `useradd` n'a pas d'options, elle apparaît :

* Créer un répertoire personnel avec le même nom ;
* Créer un groupe primaire avec le même nom ;
* Le shell par défaut est bash ;
* L'`UID` de l'utilisateur et le `GID` du groupe primaire sont automatiquement enregistrés à partir de 1000, et généralement les UID et GID sont les mêmes.

```bash
Shell > useradd test1

Shell > tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

Shell > tail -n 1 /etc/shadow
test1:! :19253:0:99999:7
:::

Shell > tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

Règles de nommage des comptes :

* Pas d’accents, de majuscules ni caractères spéciaux ;
* Différents du nom d’un groupe ou fichier système existant ;
* Facultatif : spécifier les options `-u`, `-g`, `-d` et `-s` lors de la création.

!!! Warning

    L’arborescence du répertoire de connexion doit être créée à l’exception du dernier répertoire.

Le dernier répertoire est créé par la commande `useradd` qui en profite pour y copier les fichiers de `/etc/skel`.

**Un utilisateur peut appartenir à plusieurs groupes en plus de son groupe principal.**

Exemple :

```
$ sudo useradd -u 1000 -g GroupeA -G GroupeP,GroupeC albert
```

!!! Note

    Sous **Debian**, il faudra spécifier l’option `-m` pour forcer la création du répertoire de connexion ou positionner la variable `CREATE_HOME` du fichier `/etc/login.defs`. Dans tous les cas, l’administrateur devrait privilégier, sauf dans des scripts ayant la vocation d’être portables sur toutes les distributions Linux, les commandes `adduser` et `deluser` comme précisé dans le `man` :

    ```
    $ man useradd
    DESCRIPTION
        **useradd** est un utilitaire de bas niveau pour ajouter des utilisateurs. Sur Debian, les administrateurs devraient généralement utiliser **adduser(8)**
         à la place.
    ```

#### Valeur par défaut de création d’utilisateur.

Modification du fichier `/etc/default/useradd`.

```
useradd -D [-b repertoire] [-g groupe] [-s shell]
```

Exemple :

```
$ sudo useradd -D -g 1000 -b /home -s /bin/bash
```

| Option          | Description                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------- |
| `-D`            | Définit les valeurs par défaut de création d’utilisateur.                                   |
| `-b repertoire` | Définit le répertoire de connexion par défaut.                                              |
| `-g groupe`     | Définit le groupe par défaut.                                                               |
| `-s shell`      | Définit le shell par défaut.                                                                |
| `-f`            | Nombre de jours suivant l’expiration du mot de passe avant que le compte ne soit désactivé. |
| `-e`            | Date à laquelle le compte sera désactivé.                                                   |

### La commande `usermod`

La commande `usermod` permet de modifier un utilisateur.

```
usermod [-u UID] [-g GID] [-d repertoire] [-m] login
```

Exemple :

```
$ sudo usermod -u 1044 carine
```

Options identiques à la commande `useradd`.

| Option          | Description                                                                                                                                                                                                                                                       |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-m`            | Associé à l'option `-d` , déplace le contenu de l'ancien répertoire de connexion vers le nouveau. Si l'ancien répertoire personnel n'existe pas, le nouveau répertoire personnel ne sera pas créé ; Si le nouveau répertoire personnel n'existe pas, il est créé. |
| `-l login`      | Nouveau nom de connexion. Une fois que vous avez modifié le nom de connexion, vous devez également modifier le nom du répertoire personnel pour le correspondre.                                                                                                  |
| `-e AAAA-MM-JJ` | Date d’expiration du compte.                                                                                                                                                                                                                                      |
| `-L`            | Verrouiller définitivement le compte. C'est-à-dire, un `!` est ajouté au début du champ de mot de passe `/etc/shadow`                                                                                                                                             |
| `-U`            | Déverrouille le compte.                                                                                                                                                                                                                                           |
| `-a`            | Ajoute les groupes supplémentaires de l'utilisateur, qui doivent être utilisés avec l'option `-G`.                                                                                                                                                                |
| `-G`            | Modifier les groupes secondaires de l'utilisateur pour écraser les groupes secondaires précédents.                                                                                                                                                                |

!!! Tip

    Pour être modifié, un utilisateur doit être déconnecté et ne pas avoir de processus en cours.

Après modification de l’identifiant, les fichiers appartenant à l’utilisateur ont un `UID` inconnu. Il faut leur réattribuer le nouvel `UID`.

Où `1000` est l’ancien `UID` et `1044` le nouveau. En voici quelques exemples :

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Verrouillage et déverrouillage du compte d'utilisateur. En voici quelques exemples :

```
Shell > usermod -L test1
Shell > grep test1 /etc/shadow
test1:!$6$n.hxglA.X5r7X0ex$qCXeTx.kQVmqsPLeuvIQnNidnSHvFiD7bQTxU7PLUCmBOcPNd5meqX6AEKSQvCLtbkdNCn.re2ixYxOeGWVFI0:19259:0:99999:7
:::

Shell > usermod -U test1
```

La différence entre l'option `-aG` et l'option `-G` peut être expliquée par l'exemple suivant :

```bash
Shell > useradd test1
Shell > passwd test1
Shell > groupadd groupA ; groupadd groupB ; groupadd groupC ; groupadd groupD
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1)

Shell > gpasswd -a test1 groupA
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1002(groupA)

Shell > usermod -G groupB,groupC test1
Shell > id test1 
uid=1000(test1) gid=1000(test1) gorups=1000(test1),1003(groupB),1004(groupC)

Shell > usermod -aG groupD test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1003(groupB),1004(groupC),1005(groupD)
```

### La commande `userdel`

La commande `userdel` permet de supprimer le compte d’un utilisateur.

```
$ sudo userdel -r carine
```

| Option | Description                                                                                                                     |
| ------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `-r`   | Supprime le répertoire de connexion de l'utilisateur et les fichiers de messagerie situés dans le répertoire `/var/spool/mail/` |

!!! Tip

    Pour être modifié, un utilisateur doit être déconnecté et ne pas avoir de processus en cours.

La commande `userdel` supprime les lignes correspondantes dans `/etc/passwd`, `/ <unk> shadow`, `/etc/group`, `/etc/gshadow`. Comme mentionné ci-dessus, `userdel -r` supprimera également le groupe principal correspondant de l'utilisateur.

### Le fichier `/etc/passwd`

Ce fichier contient les informations des utilisateurs (séparées par `:`).

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1: Login ;
* 2 : Identification du mot de passe, `x` indique que l'utilisateur a un mot de passe, ce mot de passe encrypté est enregistré dans le second champ du fichier `/etc/shadow` ;
* 3: UID ;
* 4: GID du groupe primaire ;
* 5: Commentaires ;
* 6: Répertoire de connexion ;
* 7: Interpréteur de commandes (`/bin/bash`, `/bin/nologin`, ...).

### Le fichier `/etc/shadow`

Ce fichier contient les informations de sécurité des utilisateurs (séparées par `:`).
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7
:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Login.
* 2: Mot de passe chiffré. Utilise l'algorithme de chiffrement SHA512, défini par l' `ENCRYPT_METHOD` de `/etc/login.defs`.
* 3: La date à laquelle le mot de passe a été modifié pour la dernière fois, au format de l'horodatage, en jours. L'horodatage est basé sur le 1er janvier 1970 comme heure standard. Chaque fois qu'un jour se passe, l'horodatage est +1.
* 4: Durée de vie minimale du mot de passe. C'est-à-dire L'intervalle de temps entre deux changements de mot de passe (liés au troisième champ), en jours.  Défini par le `PASS_MIN_DAYS` de `/etc/login.defs`, la valeur par défaut est 0, c'est-à-dire lorsque vous changez le mot de passe pour la deuxième fois, il n'y a pas de restriction. Cependant, s'il est de 5, cela signifie qu'il n'est pas autorisé à changer le mot de passe dans les 5 jours, et seulement après 5 jours.
* 5: Durée de vie maximale du mot de passe. C'est-à-dire la période de validité du mot de passe (lié au troisième champ). Défini par le `PASS_MAX_DAYS` de `/etc/login.defs`.
* 6: Le nombre de jours d'avertissement avant l'expiration du mot de passe (lié au cinquième champ). La valeur par défaut est de 7 jours, définie par le `PASS_WARN_AGE` de `/etc/login.defs`.
* 7: Le nombre de jours de grâce après l'expiration du mot de passe (lié au 5ème champ).
* 8: Heure d'expiration du compte, le format de l'horodatage, en jours. **Notez que l'expiration d'un compte diffère de l'expiration d'un mot de passe. En cas d'expiration d'un compte, l'utilisateur ne sera pas autorisé à se connecter. En cas d'expiration du mot de passe, l'utilisateur n'est pas autorisé à se connecter en utilisant son mot de passe.**
* 9: Réservé pour une utilisation future.

!!! Danger

    Pour chaque ligne du fichier `/etc/passwd` doit correspondre une ligne du fichier `/etc/shadow`.

Pour la conversion de l'horodatage et de la date, veuillez vous référer au format de commande suivant :

```bash
# L'horodatage est converti en date, "17718" indique l'horodatage à remplir.
Shell > date -d "1970-01-01 17718 days" 

# La date est convertie en un horodatage, "2018-07-06" indique la date à remplir.
Shell > echo $(($(date --date="2018-07-06" +%s)/86400+1))
```

## Les propriétaires des fichiers

!!! Danger

    Tous les fichiers appartiennent forcément à un utilisateur et à un groupe.

Le groupe principal de l'utilisateur qui crée le fichier est, par défaut, le groupe propriétaire du fichier.

### Commandes de modifications

#### La commande `chown`

La commande `chown` permet de modifier les propriétaires d’un fichier.
```
chown [-R] [-v] login[:groupe] fichier
```

Exemples :
```
$ sudo chown root monfichier
$ sudo chown albert:GroupeA monfichier
```

| Option | Description                                                |
| ------ | ---------------------------------------------------------- |
| `-R`   | Modifie les propriétaires du répertoire et de son contenu. |
| `-v`   | Affiche les modifications exécutées.                       |

Pour ne modifier que l’utilisateur propriétaire :

```
$ sudo chown albert fichier
```

Pour ne modifier que le groupe propriétaire :

```
$ sudo chown :GroupeA fichier
```

Modification de l’utilisateur et du groupe propriétaire :

```
$ sudo chown albert:GroupeA fichier
```

Dans l'exemple suivant, le groupe assigné sera le groupe principal de l'utilisateur spécifié.

```
$ sudo chown albert: fichier
```

Changer le propriétaire et le groupe de tous les fichiers dans un répertoire

```
$ sudo chown -R albert:GroupA /dir1
```

### La commande `chgrp`

La commande `chgrp` permet de modifier le groupe propriétaire d’un fichier.

```
chgrp [-R] [-v] groupe fichier
```

Exemple :
```
$ sudo chgrp groupe1 fichier
```

| Option | Description                                                                      |
| ------ | -------------------------------------------------------------------------------- |
| `-R`   | Modifie les groupes propriétaires du répertoire et de son contenu (récursivité). |
| `-v`   | Affiche les modifications exécutées.                                             |

!!! Note

    Il est possible d’appliquer à un fichier un propriétaire et un groupe propriétaire en prenant comme référence ceux d’un autre fichier :

```
chown [options] --reference=RRFICHIER FICHIER
```

Par exemple :

```
chown --reference=/etc/groups /etc/passwd
```

## Gestion des invités

### La commande `gpasswd`

La commande `gpasswd` permet de gérer un groupe.

```
gpasswd [option] groupe
```

Exemples :

```
$ sudo gpasswd -A alain GroupeA
[alain]$ gpasswd -a patrick GroupeA
```

| Option          | Description                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------- |
| `-a login`      | Ajoute l’utilisateur au groupe. Pour l'utilisateur ajouté, ce groupe est un groupe supplémentaire. |
| `-A login, ...` | Définit la liste des administrateurs du groupe.                                                    |
| `-d login`      | Retire l’utilisateur du groupe.                                                                    |
| `-M login,...`  | Définit la liste exhaustive des invités.                                                           |

La commande `gpasswd -M` agit en modification et non en ajout.

```
# gpasswd GroupeA
New Password :
Re-enter new password :
```

!!! note

    En plus de l'utilisation de `gpasswd -a` pour ajouter des utilisateurs à un groupe, vous pouvez également utiliser le `usermod -G` ou le `usermod -AG` mentionné précédemment.

### La commande `id`

La commande `id` affiche les noms des groupes d’un utilisateur.

```
ID UTILISATEUR
```

Exemple :

```
$ sudo id alain
uid=1000(alain) gid=1000(GroupeA) groupes=1000(GroupeA),1016(GroupeP)
```

### La commande `newgrp`

La commande `newgrp` peut sélectionner un groupe parmi les groupes supplémentaires de l'utilisateur comme le nouveau groupe principal**temporaire** de l'utilisateur. La commande `newgrp` à chaque fois que vous basculez le groupe principal d'un utilisateur, créera un nouveau **shell enfant** (processus fils). Attention ! **le shell enfant** et **sous shell** sont différents.

```
newgrp [groupesecondaire]
```

Exemple :

```
Shell > useradd test1
Shell > passwd test1
Shell > groupadd groupA ; groupadd groupB 
Shell > usermod -G groupA,groupB test1
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1001(groupA),1002(groupB)
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

Shell > su - test1
Shell > touch a.txt
Shell > ll
-rw-rw-r-- 1 test1 test1 0 10月  7 14:02 a.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

# Generate a new child shell
Shell > newgrp groupA
Shell > touch b.txt
Shell > ll
-rw-rw-r-- 1 test1 test1  0 10月  7 14:02 a.txt
-rw-r--r-- 1 test1 groupA 0 10月  7 14:02 b.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
2
0

# You can exit the child shell using the `exit` command
Shell > exit
Shell > logout
Shell > whoami
root
```

## Sécurisation

### La commande `passwd`

La commande `passwd` permet de gérer un mot de passe.

```
passwd [-d] [-l] [-S] [-u] [login]
```

Exemples :

```
Shell > passwd -l albert
Shell > passwd -n 60 -x 90 -w 80 -i 10 patrick
```

| Option     | Description                                                                                                                      |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `-d`       | Supprime définitivement le mot de passe. Réservé à l'utilisateur root (uid=0) uniquement.                                        |
| `-l`       | Verrouiller définitivement le compte utilisateur. Réservé à l'utilisateur root (uid=0) uniquement.                               |
| `-S`       | Affiche le statut du compte. Réservé à l'utilisateur root (uid=0) uniquement.                                                    |
| `- u`      | Déverrouille définitivement le compte utilisateur. Réservé à l'utilisateur root (uid=0) uniquement.                              |
| `-e`       | Expiration permanente du mot de passe. Réservé à l'utilisateur root (uid=0) uniquement.                                          |
| `-n jours` | Durée de vie minimale du mot de passe. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                    |
| `-x jours` | Durée de vie maximale du mot de passe. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                    |
| `-w jours` | Délai d’avertissement avant expiration. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                   |
| `-i jours` | Délai avant désactivation lorsque le mot de passe expire. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement. |

Utiliser `password -l` ajoute "!!" devant le mot de passe de l'utilisateur correspondant qui est contenu dans le fichier `/etc/shadow`.

Exemple :

* Alain change son mot de passe :

```
[alain]$ passwd
```

* root change le mot de passe d’Alain :

```
$ sudo passwd alain
```

!!! Note

    La commande `passwd` est accessible aux utilisateurs pour modifier leur mot de passe (l’ancien mot de passe est demandé). L’administrateur peut modifier les mots de passe de tous les utilisateurs sans restriction.

Ils devront se soumettre aux restrictions de sécurité.

Lors d’une gestion des comptes utilisateurs par script shell, il peut être utile de définir un mot de passe par défaut après avoir créé l’utilisateur.

Ceci peut se faire en passant le mot de passe à la commande `passwd`.

Exemple :

```
$ sudo echo "azerty,1" | passwd --stdin philippe
```

!!! Warning

    Le mot de passe est saisi en clair, `passwd` se charge de le chiffrer.

### La commande `chage`

La commande `chage` est chargée de changer les informations d'expiration du mot de passe utilisateur.

```
chage [-d date] [-E date] [-I jours] [-l] [-m jours] [-M jours] [-W jours] [login]
```

Exemple :

```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

| Option               | Description                                                                                                                                  |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `-I jours`           | Délai avant désactivation, mot de passe expiré (i majuscule). Changement permanent.                                                          |
| `-l`                 | Affiche le détail de la stratégie (l minuscule).                                                                                             |
| `-m jours`           | Durée de vie minimale du mot de passe. Changement permanent.                                                                                 |
| `-M jours`           | Durée de vie maximale du mot de passe. Changement permanent.                                                                                 |
| `-d LAST_DAY`        | Dernière modification du mot de passe. Vous pouvez utiliser le style de l'horodatage des jours ou le style AAAA-MM-JJ. Changement permanent. |
| `-E DATE_EXPIRATION` | Date d’expiration du compte. Vous pouvez utiliser le style de l'horodatage des jours ou le style AAAA-MM-JJ. Changement permanent.           |
| `-W jours`           | Délai d’avertissement avant expiration. Changement permanent.                                                                                |

Exemples :

```
# La commande `chage` offre également un mode interactif.
$ sudo chage philippe

# L'option `-d` force le mot de passe à changer à la connexion.
$ sudo chage -d 0 philippe
```

![Gestion du compte utilisateur avec chage](images/chage-timeline.png)

## Gestion avancée

Fichiers de configuration :

* `/etc/default/useradd`
* `/etc/login.defs`
* `/etc/skel`

!!! Note

    L’édition du fichier `/etc/default/useradd` se fait grâce à la commande `useradd`.
    
    Les autres fichiers sont à modifier avec un éditeur de texte.

### Fichier `/etc/default/useradd`

Ce fichier contient le paramétrage des données par défaut.

!!! Tip

    Lors de la création d’un utilisateur, si les options ne sont pas précisées, le système utilise les valeurs par défaut définies dans `/etc/default/useradd`.

Ce fichier est modifié par la commande `useradd -D` (`useradd -D` saisie sans autre option affiche le contenu du fichier `/etc/default/useradd`).

```
Shell > grep -v ^# /etc/default/useradd 
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```

| Paramètres          | Commentaire                                                                                                                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GROUP`             | Groupe par défaut.                                                                                                                                                                                |
| `HOME`              | Définir le chemin du répertoire du niveau supérieur au répertoire de connexion d'un l'utilisateur standard.                                                                                       |
| `INACTIVE`          | Nombre de jours de grâce après l'expiration du mot de passe. Correspond au 7ème champ du fichier `/etc/shadow`. La valeur `-1` signifie que la fonctionnalité de période de grâce est désactivée. |
| `EXPIRE`            | Date d’expiration du compte. Correspond au 8ème champ du fichier `/etc/shadow`.                                                                                                                   |
| `SHELL`             | Interpréteur de commandes.                                                                                                                                                                        |
| `SKEL`              | Répertoire squelette du répertoire de connexion.                                                                                                                                                  |
| `CREATE_MAIL_SPOOL` | Création de la boîte aux lettres dans `/var/spool/mail`.                                                                                                                                          |

Si vous n'avez pas besoin d'un groupe primaire portant le même nom lors de la création d'utilisateurs, vous pouvez faire :

```
Shell > useradd -N test2
Shell > id test2
uid=1001(test2) gid=100(users) groups=100(users)
```

### Fichier `/etc/login.defs`

```bash
# Comment line ignored
shell > cat  /etc/login.defs
MAIL_DIR        /var/spool/mail
UMASK           022
HOME_MODE       0700
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_MIN_LEN    5
PASS_WARN_AGE   7
UID_MIN                  1000
UID_MAX                 60000
SYS_UID_MIN               201
SYS_UID_MAX               999
GID_MIN                  1000
GID_MAX                 60000
SYS_GID_MIN               201
SYS_GID_MAX               999
CREATE_HOME     yes
USERGROUPS_ENAB yes
ENCRYPT_METHOD SHA512
```

`UMASK 022`: Cela signifie que la permission de créer un fichier est 755 (rwxr-xr-x). Cependant, pour des raisons de sécurité, GNU/Linux n'a pas l'autorisation **x** pour les fichiers nouvellement créés, cette restriction s'applique à root(uid=0) et aux utilisateurs ordinaires (uid>=1000). Par exemple :

```
Shell > touch a.txt
Shell > ll
-rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
```

`HOME_MODE 0700`: Les permissions du répertoire personnel d'un utilisateur standard. Ne fonctionne pas pour le répertoire personnel de root.

```
Shell > ll -d /root
dr-xr-x---. 10 root root 4096 Oct  8 13:12 /root

Shell > ls -ld /home/test1/
drwx------ 2 test1 test1 4096 Oct  8 13:10 /home/test1/
```

`USERGROUPS_ENAB yes`: "Quand vous supprimez un utilisateur en utilisant la commande `userdel -r` , le groupe principal correspondant est également supprimé." Pourquoi ? C'est la raison.

### Fichier `/etc/skel`

Lors de la création d’un utilisateur, son répertoire personnel et ses fichiers d’environnement sont créés. Vous pouvez considérer les fichiers du répertoire `/etc/skel/` comme les modèles de fichiers dont vous avez besoin pour créer des utilisateurs.

Ces fichiers sont copiés automatiquement à partir du répertoire `/etc/skel`.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

Tous les fichiers et répertoires placés dans ce répertoire seront copiés dans l’arborescence des utilisateurs lors de leur création.

## Changement d’identité

### La commande `su`

La commande `su` permet de modifier l’identité de l’utilisateur connecté.

```
su [-] [-c command] [login]
```

Exemples :

```
$ sudo su - alain
[albert]$ su - root -c "passwd alain"
```

| Option       | Description                                           |
| ------------ | ----------------------------------------------------- |
| `-`          | Charge l’environnement complet de l’utilisateur.      |
| `-c` command | Exécute la commande sous l’identité de l’utilisateur. |

Si le login n’est pas spécifié, ce sera `root`.

Les utilisateurs standards devront taper le mot de passe de la nouvelle identité.

!!! Tip

    Vous pouvez utiliser la commande `exit`/`logout` pour déconnecter les utilisateurs. Il devrait être noté qu'après un changement d'utilisateur, il n'y a pas de nouveau `child shell` or `sub shell`, par exemple :

    ```
    Shell > whoami
    racine
    Shell > écho $SHLVL ; echo $BASH_SUBSHELL
    1
    0

    Shell > su - test1
    Shell > echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0
    ```

Attention s'il vous plaît ! `su` et `su -` sont différents, comme indiqué dans l'exemple suivant :

```
Shell > whoami
test1
Shell > su root
Shell > pwd
/home/test1

Shell > env
...
USER=test1
PWD=/home/test1
HOME=/root
MAIL=/var/spool/mail/test1
LOGNAME=test1
...
```

```
Shell > whoami
test1
Shell > su - root
Shell > pwd
/root

Shell > env
...
USER=root
PWD=/root
HOME=/root
MAIL=/var/spool/mail/root
LOGNAME=root
...
```

Donc, lorsque vous voulez changer d'utilisateurs, n'oubliez pas le `-`. Comme les fichiers de variables d'environnement nécessaires ne sont pas chargés, il peut y avoir des problèmes pour exécuter certains programmes.
