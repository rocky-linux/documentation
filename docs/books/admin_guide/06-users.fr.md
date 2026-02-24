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

* `UID`: *User IDentifier*. Identifiant unique d’utilisateur.
* `GID`: *Group IDentifier*. Identifiant unique de groupe.

L'UID et le GID sont reconnus par le noyau, ce qui signifie que le Super Admin n'est pas nécessairement l'utilisateur **root**. L'utilisateur ayant pour **uid=0** est le Super Admin.

Les fichiers liés aux utilisateurs/groupes sont:

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/skel/
* /etc/default/useradd
* /etc/login.defs

!!! danger "Attention"

    Il est recommandé d’utiliser les commandes d’administration au lieu de modifier manuellement les fichiers.

!!! note "Remarque"

    Certaines commandes dans ce chapitre nécessitent des droits d'administrateur. 
    Par convention, nous spécifierons la commande « sudo » lorsque les commandes doivent être exécutées avec des droits d'administrateur.
    Pour que les exemples fonctionnent correctement, assurez-vous que votre compte dispose des droits nécessaires pour utiliser la commande `sudo`.

## Gestion des groupes

Fichiers modifiés, ajout de lignes :

* `/etc/group`
* `/etc/gshadow`

### La commande `groupadd`

La commande `groupadd` permet d’ajouter un groupe au système.

```bash
groupadd [-f] [-g GID] group
```

Exemple :

```bash
sudo groupadd -g 1012 GroupeB
```

| Option   | Description                                                                                                                                 |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `-g GID` | Définit le `GID` du groupe à créer.                                                                                                         |
| `-f`     | Le système choisit un `GID` si celui précisé par l’option `-g` existe déjà.                                                                 |
| `-r`     | Crée un groupe système avec un `GID` compris entre `SYS_GID_MIN` et `SYS_GID_MAX`. Ces deux variables sont définies dans `/etc/login.defs`. |

Règles de nommage des groupes :

* Pas d’accents, ni caractères spéciaux ;
* Différents du nom d’un utilisateur ou fichier système existant.

!!! note "Remarque"

    Sous **Debian**, l'administrateur devrait utiliser, sauf dans les scripts destinés à être portables sur toutes les distributions Linux, les commandes `addgroup` et `delgroup` spécifiées dans le `man` :

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. Ce sont des interfaces plus conviviales pour les outils de bas niveau tels que les programmes useradd, groupadd et usermod,
par défaut, en choisissant les valeurs UID et GID conformes à la politique Debian, en créant un répertoire personnel avec une configuration squelettique,
exécuter un script personnalisé et d'autres fonctionnalités.
    ```

### La commande `groupmod`

La commande `groupmod` permet de modifier un groupe existant dans le système.

```bash
groupmod [-g GID] [-n nom] group
```

Exemple :

```bash
sudo groupmod -g 1016 GroupP

sudo groupmod -n GroupC GroupB
```

| Option    | Description                         |
| --------- | ----------------------------------- |
| `-g GID`  | Nouveau `GID` du groupe à modifier. |
| `-n name` | Nouveau nom.                        |

Il est possible de modifier le nom d’un groupe, son `GID` ou bien les deux simultanément.

Après modification, les fichiers appartenant au groupe ont un `GID` inconnu. Il faut leur réattribuer le nouveau `GID`.

```bash
sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### La commande `groupdel`

La commande `groupdel` permet de supprimer un groupe existant sur le système.

```bash
groupdel group
```

Exemple :

```bash
sudo groupdel GroupC
```

!!! tip "Astuce"

    Lors de la suppression d'un groupe, deux conditions sont possibles :

    * Si un utilisateur a un groupe principal unique et que vous exécutez la commande `groupdel` sur ce groupe, vous serez informés qu'il y a un utilisateur spécifique dans le groupe et qu'il ne peut pas être supprimé.
    * Si un utilisateur appartient à un groupe secondaire (ce n'est pas le groupe principal de l'utilisateur) et que ce groupe n'est pas le groupe principal d'un autre utilisateur du système, alors la commande `groupdel` supprimera le groupe sans notification supplémentaire.

    Exemples :

    ```bash
    $ sudo useradd test
    $ id test
    uid=1000(test) gid=1000(test) group=1000(test)
    $ sudo groupdel test
    groupdel: cannot remove the primary group of user 'test'

    $ sudo usermod -g users -G test test
    $ id test
    uid=1000(test) gid=100(users) group=100(users),1000(test)
    $ sudo groupdel test
    ```

!!! tip "Astuce"

    Lorsque vous supprimez un utilisateur en utilisant la commande `userdel -r`, le groupe principal correspondant est également supprimé. Le nom du groupe principal est généralement le même que celui de l'utilisateur.

!!! tip "Astuce"

    Chaque groupe possède un `GID` unique. Un groupe peut être utilisé par plusieurs utilisateurs comme groupe secondaire. Par convention, le GID de l'dministrateur principal est 0. Les GID réservés à certains services ou processus vont de 201à 999, ils sont appelés groupes système ou groupes de pseudo-utilisateurs. Le GID des utilisateurs est généralement supérieur ou égal à 1000. Ils sont liés à <font color=red>/etc/login.defs</font>, dont nous reparlerons plus tard.

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

!!! tip "Astuce"

    Un utilisateur faisant obligatoirement partie d’un groupe, il est préférable de créer les groupes avant d’ajouter les utilisateurs. Par conséquent, un groupe peut ne pas avoir de membres.

### Le fichier `/etc/group`

Ce fichier contient les informations de groupes (séparées par `:`).

```bash
$ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1 : Nom du groupe.
* 2 : Le mot de passe du groupe est identifié par `x`. Le mot de passe du groupe est stocké dans `/etc/gshadow`.
* 3 : GID.
* 4 : Utilisateurs supplémentaires du groupe (à l'exclusion des utilisateurs dont c'est le groupe principal).

!!! note "Remarque "

    Chaque ligne du fichier `/etc/group` correspond à un groupe. Les informations de l'utilisateur principal sont stockées dans `/etc/passwd`.

### Le fichier `/etc/gshadow`

Ce fichier contient les informations de sécurité sur les groupes (séparées par des deux-points `:`).

```bash
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1 : Nom du groupe.
* 2: Mot de passe chiffré.
* 3 : Nom de l'administrateur du groupe.
* 4 : Utilisateurs supplémentaires du groupe (à l'exclusion des utilisateurs dont c'est le groupe principal).

!!! warning "Avertissement"

    Le nom du groupe dans **/etc/group** et **/etc/gshadow** doivent correspondre un par un. Autrement dit, chaque ligne du fichier **/etc/group** doit avoir une ligne correspondante dans le fichier **/etc/gshadow**.

Un point d'exclamation –`!`– dans le mot de passe indique qu'il est verrouillé. Ainsi aucun utilisateur ne peut utiliser le mot de passe pour accéder au groupe (sachant que les membres du groupe n’en ont pas besoin).

## Gestion des utilisateurs

### Définition

Un utilisateur est défini comme suit dans le fichier `/etc/passwd` :

* 1 : Nom de connexion ;
* 2 : Identification du mot de passe, `x` indique que l'utilisateur a un mot de passe, ce mot de passe encrypté est enregistré dans le second champ du fichier `/etc/shadow` ;
* 3 : UID ;
* 4 : GID du groupe primaire ;
* 5 : Commentaires ;
* 6 : Répertoire de connexion ;
* 7 : Shell (`/bin/bash`, `/bin/nologin`, ...).

Il existe trois types d’utilisateurs :

* **root(uid=0)** : l'administrateur système ;
* **utilisateurs système (UID entre 201 et 999)** : utilisés par le système pour gérer les droits d'accès aux applications ;
* **utilisateur standard (uid>=1000)** : autre compte pour se connecter au système.

Fichiers modifiés, ajout de lignes :

* `/etc/passwd`
* `/etc/shadow`

### La commande `useradd`

La commande `useradd` ajoute un utilisateur.

```bash
useradd [-u UID] [-g GID] [-d directory] [-s shell] login
```

Exemple :

```bash
sudo useradd -u 1000 -g 1013 -d /home/GroupC/carine carine
```

| Option              | Description                                                                                                                                                                      |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-u UID`            | `UID` de l’utilisateur à créer.                                                                                                                                                  |
| `-g GID`            | `GID` du groupe principal. Le `GID` ici peut également être un nom de groupe ``.                                                                                                 |
| `-G GID1,[GID2]...` | `GID` des groupes supplémentaires. Le `GID` ici peut également être un `nom de groupe`. Il est possible de spécifier plusieurs groupes supplémentaires séparés par des virgules. |
| `-d repertoire`     | Crée le répertoire personnel.                                                                                                                                                    |
| `-s shell`          | Spécifie l'interpréteur de commandes de l'utilisateur.                                                                                                                           |
| `-c COMMENTAIRES`   | Ajoute un commentaire.                                                                                                                                                           |
| `-U`                | Ajoute l’utilisateur à un groupe portant le même nom créé simultanément. Si rien n'est spécifié, un groupe portant le même nom est créé lors de la création de l'utilisateur.    |
| `-M`                | Pas de création du répertoire personnel de l'utilisateur.                                                                                                                        |
| `-r`                | Crée un compte système.                                                                                                                                                          |

À la création, le compte ne possède pas de mot de passe et est verrouillé.

L'utilisateur doit attribuer un mot de passe pour déverrouiller le compte.

Lors de l'appel de la commande `useradd` sans aucune option, les paramètres par défaut suivants sont définis pour le nouvel utilisateur :

* Un répertoire personnel – home – portant le même nom que le nom d'utilisateur est créé ;
* Un groupe principal portant le même nom que le nom d’utilisateur est créé ;
* Le shell par défaut est bash (`/bin/bash`) ;
* Les valeurs UID de l'utilisateur et GID du groupe principal sont automatiquement déduites. Il s'agit généralement d'une valeur unique comprise entre 1000 et 60,000.

!!! note "Remarque"

    Les paramètres et valeurs par défaut sont obtenus à partir des fichiers de configuration suivants :
    
    `/etc/login.defs` et `/etc/default/useradd`

```bash
$ sudo useradd test1

$ tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

$ tail -n 1 /etc/shadow
test1:!!:19253:0:99999:7
:::

$ tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

Règles de nommage des règles :

* Les lettres minuscules, les chiffres et les traits de soulignement sont autorisés ; les autres caractères spéciaux tels que les astérisques, les signes de pourcentage et les symboles pleine largeur ne sont pas acceptés.
* Bien que vous puissiez choisir un nom d'utilisateur en majuscules dans RockyLinux, nous ne le recommandons pas ;
* Il n’est pas recommandé de commencer les noms par des chiffres et des traits de soulignement, même si cela peut être autorisé ;
* Différent du nom d’un groupe ou fichier système existant ;
* Le nom d'utilisateur peut contenir jusqu'à 32 caractères.

!!! warning "Avertissement"

    L'utilisateur doit créer un répertoire personnel – home –, à l'exception du dernier répertoire.

Le dernier répertoire est créé par la commande `useradd`, qui en profite pour y copier les fichiers de `/etc/skel`.

**Un utilisateur peut appartenir à plusieurs groupes en plus de son groupe principal.**

Exemple :

```bash
sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note

    Sous **Debian**, il faudra spécifier l’option `-m` pour forcer la création du répertoire de connexion ou renseigner la variable `CREATE_HOME` du fichier `/etc/login.defs`. Dans tous les cas, l’administrateur devrait privilégier, sauf dans des scripts ayant la vocation d’être portables sur toutes les distributions Linux, les commandes `adduser` et `deluser` comme précisé dans le manuel `man` :

    ```
    $ man useradd
    DESCRIPTION
        **useradd** is a low-level utility for adding users. Sous Debian, les administrateurs doivent généralement utiliser **adduser(8)** 
à la place.
    ```

#### Valeur par défaut de création d’utilisateur.

Modification du fichier `/etc/default/useradd`.

```bash
useradd -D [-b directory] [-g group] [-s shell]
```

Exemple :

```bash
sudo useradd -D -g 1000 -b /home -s /bin/bash
```

| Option              | Description                                                                                                                                                                                                              |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `-D`                | Définit les valeurs par défaut de création d’utilisateur.                                                                                                                                                                |
| `-b base_directory` | Définissez le répertoire de base pour le dossier personnel `home` de l'utilisateur. Si vous ne spécifiez pas cette option, utilisez la variable HOME dans le fichier `/etc/default/useradd` ou simplement `/home/` |
| `-g groupe`         | Définit le groupe par défaut.                                                                                                                                                                                            |
| `-s shell`          | Définit le shell par défaut.                                                                                                                                                                                             |
| `-f`                | Nombre de jours suivant l’expiration du mot de passe avant que le compte ne soit désactivé.                                                                                                                              |
| `-e`                | Définit la date de désactivation du compte.                                                                                                                                                                              |

### La commande `usermod`

La commande `usermod` permet de modifier un utilisateur.

```bash
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

Exemple :

```bash
sudo usermod -u 1044 carine
```

Options identiques à celles de la commande `useradd`.

| Option          | Observation                                                                                                                                                                                                                                                                         |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-m`            | Associé à l'option `-d.`  Déplace le contenu de l'ancien répertoire de connexion vers le nouveau. Si l'ancien répertoire d'origine n'existe pas, la création d'un nouveau répertoire d'origine n'a pas lieu ; la création du nouveau répertoire d'origine a lieu s'il n'existe pas. |
| `-l login`      | Modifie le nom d'utilisateur. Une fois que vous avez modifié le nom de connexion, vous devez également modifier le nom du répertoire personnel pour le correspondre.                                                                                                                |
| `-e AAAA-MM-JJ` | Change la date d’expiration du compte.                                                                                                                                                                                                                                              |
| `-L`            | Verrouille définitivement le compte. C'est-à-dire, un point d'exclamation `!` est ajouté au début du champ de mot de passe de `/etc/shadow`.                                                                                                                                        |
| `-U`            | Déverrouille le compte.                                                                                                                                                                                                                                                             |
| `-a`            | Ajoute des groupes d'utilisateurs supplémentaires à utiliser avec l'option `-G`.                                                                                                                                                                                                    |
| `-G`            | Modifie les groupes secondaires de l'utilisateur pour écraser les groupes secondaires précédents.                                                                                                                                                                                   |

!!! tip "Astuce"

    Pour pouvoir être modifié, un utilisateur doit être déconnecté et ne pas avoir de processus en cours.

Après modification de l'identifiant, les fichiers appartenant à l'utilisateur ont un `UID` inconnu. Il faut leur réattribuer le nouvel `UID`.

Où `1000` est l'ancien `UID` et `1044` le nouveau. En voici quelques exemples :

```bash
sudo find / -uid 1000 -exec chown 1044: {} \;
```

Verrouillage et déverrouillage des comptes utilisateurs. En voici quelques exemples :

```bash
$ usermod -L test1
$ grep test1 /etc/shadow
test1:!$6$n.hxglA.X5r7X0ex$qCXeTx.kQVmqsPLeuvIQnNidnSHvFiD7bQTxU7PLUCmBOcPNd5meqX6AEKSQvCLtbkdNCn.re2ixYxOeGWVFI0:19259:0:99999:7
:::

$ usermod -U test1
```

La différence entre l'option `-aG` et l'option `-G` peut être expliquée par l'exemple suivant :

```bash
$ sudo useradd test1
$ sudo passwd test1
$ sudo groupadd groupA ; sudo groupadd groupB ; sudo groupadd groupC ; sudo groupadd groupD
$ id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1)

$ sudo gpasswd -a test1 groupA
$ id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1002(groupA)

$ sudo usermod -G groupB,groupC test1
$ id test1 
uid=1000(test1) gid=1000(test1) groups=1000(test1),1003(groupB),1004(groupC)

$ sudo usermod -aG groupD test1
$ id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1003(groupB),1004(groupC),1005(groupD)
```

### La commande `userdel`

La commande `userdel` permet de supprimer le compte d’un utilisateur.

```bash
sudo userdel -r carine
```

| Option | Observation                                                                                                                              |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `-r`   | Supprime le répertoire de connexion `home` de l'utilisateur et les fichiers de messagerie situés dans le répertoire `/var/spool/mail/` |

!!! tip "Astuce"

    Pour pouvoir être supprimé, l'utilisateur doit être déconnecté et n'avoir aucun processus en cours d'exécution.

The `userdel` command removes the corresponding lines in `/etc/passwd`, `/ etc/shadow`, `/etc/group`, `/etc/gshadow`. Comme mentionné ci-dessus, `userdel -r` supprimera également le groupe principal correspondant de l'utilisateur.

### Le fichier `/etc/passwd`

Ce fichier contient des informations sur l'utilisateur (séparées par des deux-points `:`).

```bash
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

Ce fichier contient les informations de sécurité des utilisateurs (séparées par des deux-points `:`).

```bash
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7
:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1 : Login.
* 2: Mot de passe chiffré. Utilise l'algorithme de chiffrement SHA512, défini par l' `ENCRYPT_METHOD` de `/etc/login.defs`.
* 3: La date à laquelle le mot de passe a été modifié pour la dernière fois, au format de l'horodatage, en jours. L'horodatage est basé sur le 1er janvier 1970 comme heure standard. Chaque fois qu'un jour se passe, l'horodatage est +1.
* 4: Durée de vie minimale du mot de passe. C'est-à-dire L'intervalle de temps entre deux changements de mot de passe (liés au troisième champ), en jours.  Défini par le `PASS_MIN_DAYS` de `/etc/login.defs`, la valeur par défaut est 0, c'est-à-dire lorsque vous changez le mot de passe pour la deuxième fois, il n'y a pas de restriction. Cependant, s'il est de 5, cela signifie qu'il n'est pas autorisé à changer le mot de passe dans les 5 jours, et seulement après 5 jours.
* 5: Durée de vie maximale du mot de passe. C'est-à-dire la période de validité du mot de passe (lié au troisième champ). Défini par le `PASS_MAX_DAYS` de `/etc/login.defs`.
* 6: Le nombre de jours d'avertissement avant l'expiration du mot de passe (lié au cinquième champ). La valeur par défaut est de 7 jours, définie par le `PASS_WARN_AGE` de `/etc/login.defs`.
* 7: Le nombre de jours de grâce après l'expiration du mot de passe (lié au 5ème champ).
* 8: Heure d'expiration du compte, le format de l'horodatage, en jours. **Notez que l'expiration d'un compte diffère de l'expiration d'un mot de passe. En cas d'expiration d'un compte, l'utilisateur ne sera pas autorisé à se connecter. En cas d'expiration du mot de passe, l'utilisateur n'est pas autorisé à se connecter en utilisant son mot de passe.**
* 9: Réservé pour une utilisation future.

!!! danger "Attention"

    Pour chaque ligne dans le fichier `/etc/passwd`, il doit y avoir une ligne correspondante dans le fichier `/etc/shadow`.

Pour la conversion de l'horodatage et de la date, veuillez vous référer au format de commande suivant :

```bash
# The timestamp is converted to a date, "17718" indicates the timestamp to be filled in.
$ date -d "1970-01-01 17718 days" 

# The date is converted to a timestamp, "2018-07-06" indicates the date to be filled in.
$ echo $(($(date --date="2018-07-06" +%s)/86400+1))
```

## Les propriétaires des fichiers

!!! danger "Attention"

    Tous les fichiers appartiennent impérativement à au moins un utilisateur et à un groupe.

Par défaut, le groupe principal de l’utilisateur créant le fichier est le groupe qui possède le fichier.

### Commandes de modifications

#### La commande `chown`

La commande `chown` permet de modifier les propriétaires d’un fichier.

```bash
chown [-R] [-v] login[:group] file
```

Exemples :

```bash
sudo chown root myfile

sudo chown albert:GroupA myfile
```

| Option | Observation                                                |
| ------ | ---------------------------------------------------------- |
| `-R`   | Modifie les propriétaires du répertoire et de son contenu. |
| `-v`   | Affiche les modifications.                                 |

Pour ne modifier que l’utilisateur propriétaire :

```bash
sudo chown albert file
```

Pour ne modifier que le groupe propriétaire :

```bash
sudo chown :GroupA file
```

Modifier l'utilisateur et le groupe propriétaire du fichier :

```bash
sudo chown albert:GroupA file
```

Dans l'exemple suivant, le groupe assigné sera le groupe principal de l'utilisateur en question.

```bash
sudo chown albert: file
```

Changer le propriétaire et le groupe de tous les fichiers d'un répertoire

```bash
sudo chown -R albert:GroupA /dir1
```

### La commande `chgrp`

La commande `chgrp` permet de modifier le groupe propriétaire d’un fichier.

```bash
chgrp [-R] [-v] group file
```

Exemple :

```bash
sudo chgrp group1 file
```

| Option | Observation                                                                      |
| ------ | -------------------------------------------------------------------------------- |
| `-R`   | Modifie les groupes propriétaires du répertoire et de son contenu (récursivité). |
| `-v`   | Affiche les modifications.                                                       |

!!! Note

    Il est possible d'appliquer à un fichier un propriétaire et un groupe propriétaire en prenant comme référence ceux d'un autre fichier :

```bash
chown [options] --reference=RRFILE FILE
```

Par exemple :

```bash
chown --reference=/etc/groups /etc/passwd
```

## Gestion des invités

### La commande `gpasswd`

La commande `gpasswd` permet de gérer un groupe.

```bash
gpasswd [option] group
```

Exemples :

```bash
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
```

| Option          | Observation                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------- |
| `-a USER`       | Ajoute l’utilisateur au groupe. Pour l'utilisateur ajouté, ce groupe est un groupe supplémentaire. |
| `-A login, ...` | Définit la liste des administrateurs du groupe.                                                    |
| `-d USER`       | Retire l’utilisateur du groupe.                                                                    |
| `-M login,...`  | Définit la liste des membres du groupe.                                                            |

La commande `gpasswd -M` agit en modification et non en ajout.

```bash
# gpasswd GroupeA
New Password:
Re-enter new password:
```

!!! note "Remarque"

    En plus d'utiliser `gpasswd -a` pour ajouter des utilisateurs à un groupe, vous pouvez également utiliser les commandes `usermod -G` ou `usermod -aG` mentionnées précédemment.

### La commande `id`

La commande `id` affiche les noms de groupe d'un utilisateur.

```bash
id USER
```

Exemple :

```bash
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```

### La commande `newgrp`

La commande `newgrp` peut sélectionner un groupe parmi les groupes supplémentaires de l'utilisateur comme nouveau groupe principal **temporaire** de l'utilisateur. Avec la commande `newgrp`, à chaque fois que vous changez le groupe principal d'un utilisateur, il y aura un nouveau **child shell** (processus enfant). Attention ! **child shell** et **sub shell** sont deux choses différentes.

```bash
newgrp [secondarygroups]
```

Exemple :

```bash
$ sudo useradd test1
$ sudo passwd test1
$ sudo groupadd groupA ; sudo groupadd groupB 
$ sudo usermod -G groupA,groupB test1
$ id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1001(groupA),1002(groupB)
$ echo $SHLVL ; echo $BASH_SUBSHELL
1
0

$ su - test1
$ touch a.txt
$ ll
-rw-rw-r-- 1 test1 test1 0 10月  7 14:02 a.txt
$ echo $SHLVL ; echo $BASH_SUBSHELL
1
0

# Generate a new child shell
$ newgrp groupA
$ touch b.txt
$ ll
-rw-rw-r-- 1 test1 test1  0 10月  7 14:02 a.txt
-rw-r--r-- 1 test1 groupA 0 10月  7 14:02 b.txt
$ echo $SHLVL ; echo $BASH_SUBSHELL
2
0

# You can exit the child shell using the `exit` command
$ exit
$ logout
$ whoami
root
```

## Sécurisation

### La commande `passwd`

La commande `passwd` permet de gérer un mot de passe.

```bash
passwd [-d] [-l] [-S] [-u] [login]
```

Exemples :

```bash
sudo passwd -l albert

sudo passwd -n 60 -x 90 -w 80 -i 10 patrick
```

| Option    | Observation                                                                                                                                    |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `-d`      | Supprime définitivement le mot de passe. Réservé à l'utilisateur root (uid=0) uniquement.                                                      |
| `-l`      | Verrouille définitivement le compte utilisateur. Réservé à l'utilisateur root (uid=0) uniquement.                                              |
| `-S`      | Affiche le statut du compte. Réservé à l'utilisateur root (uid=0) uniquement.                                                                  |
| `- u`     | Déverrouille définitivement le compte utilisateur. Réservé à l'utilisateur root (uid=0) uniquement.                                            |
| `-e`      | Expiration permanente du mot de passe. Réservé à l'utilisateur root (uid=0) uniquement.                                                        |
| `-n DAYS` | Définit la durée de vie minimale du mot de passe. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                       |
| `-x DAYS` | Définit la durée de vie maximale du mot de passe. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                       |
| `-w DAYS` | Indique le délai d’avertissement avant expiration. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement.                      |
| `-i DAYS` | Définit le délai avant la désactivation lorsque le mot de passe expire. Changement permanent. Réservé à l'utilisateur root (uid=0) uniquement. |

Utiliser `password -l`, c'est-à-dire, ajouter "!!" devant le mot de passe de l'utilisateur correspondant qui est contenu dans le fichier `/etc/shadow`.

Exemple :

* Alain change son mot de passe :

```bash
[alain]$ passwd
```

* root change le mot de passe d’Alain :

```bash
sudo passwd alain
```

!!! Note

    Les utilisateurs connectés au système peuvent utiliser la commande `passwd` pour modifier leurs mots de passe (ce processus nécessite la saisie de l'ancien mot de passe de l'utilisateur). L'utilisateur `root`(uid=0) peut modifier le mot de passe de n'importe quel utilisateur.

La modification des mots de passe nécessite le respect des politiques de sécurité prescrites, ce qui implique la connaissance des **PAM (Pluggable Authentication Modules)**.

Lors de la gestion des comptes utilisateurs par script shell, la définition d'un mot de passe par défaut après la création de l'utilisateur peut être utile.

Ceci peut se faire en passant le mot de passe à la commande `passwd`.

Exemple :

```bash
sudo echo "azerty,1" | passwd --stdin philippe
```

!!! warning "Avertissement"

    Le mot de passe est saisi en clair, `passwd` se charge de le chiffrer.

### La commande `chage`

La commande `chage` est destinée à modifier les informations sur la date d'expiration du mot de passe d'un utilisateur.

```bash
chage [-d date] [-E date] [-I days] [-l] [-m days] [-M days] [-W days] [login]
```

Exemple :

```bash
sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

| Option               | Observation                                                                                                                                                                       |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-I DAYS`            | Définit le délai avant la désactivation lorsque le mot de passe expire. Changement permanent.                                                                                     |
| `-l`                 | Affiche le détail de la stratégie (l minuscule).                                                                                                                                  |
| `-m DAYS`            | Définit la durée de vie minimale du mot de passe. Changement permanent.                                                                                                           |
| `-M DAYS`            | Définit la durée de vie maximale du mot de passe. Changement permanent.                                                                                                           |
| `-d LAST_DAY`        | Définit le nombre de jours depuis la dernière modification du mot de passe. Vous pouvez utiliser le style de l'horodatage des jours ou le style AAAA-MM-JJ. Changement permanent. |
| `-E DATE_EXPIRATION` | Indique la date d’expiration du compte. Vous pouvez utiliser le style de l'horodatage des jours ou le style YYYY-MM-DD. Changement permanent.                                     |
| `-W WARN_DAYS`       | Indique le délai d’avertissement avant expiration. Changement permanent.                                                                                                          |

Exemples :

```bash
# La commande `chage` offre également un mode interactif.
$ sudo chage philippe

# L'option `-d` force le mot de passe à changer à la connexion.
$ sudo chage -d 0 philippe
```

![User account management with chage](images/chage-timeline.png)

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

!!! tip "Astuce"

   Si aucun paramètre n'est spécifié lors de la création d'un utilisateur, le système utilise les valeurs par défaut définies dans `/etc/default/useradd`.

Ce fichier est modifié par la commande `useradd -D` (`useradd -D` saisie sans aucune autre option affiche le contenu du fichier `/etc/default/useradd`).

```bash
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
| `GROUP`             | Groupe - GID - par défaut.                                                                                                                                                                        |
| `HOME`              | Définir le chemin du répertoire du niveau supérieur au répertoire de connexion d'un l'utilisateur standard.                                                                                       |
| `INACTIVE`          | Nombre de jours de grâce après l'expiration du mot de passe. Correspond au 7ème champ du fichier `/etc/shadow`. La valeur `-1` signifie que la fonctionnalité de période de grâce est désactivée. |
| `EXPIRE`            | Date d’expiration du compte. Correspond au 8ème champ du fichier `/etc/shadow`.                                                                                                                   |
| `SHELL`             | Définit l'interpréteur de commandes.                                                                                                                                                              |
| `SKEL`              | Définit le répertoire squelette du dossier de connexion.                                                                                                                                          |
| `CREATE_MAIL_SPOOL` | Définit la création de la boîte aux lettres dans `/var/spool/mail/`.                                                                                                                              |

Si vous n'avez pas besoin d'un groupe primaire portant le même nom lors de la création d'utilisateurs, vous pouvez faire comme suit :

```bash
Shell > useradd -N test2
Shell > id test2
uid=1001(test2) gid=100(users) groups=100(users)
```

!!! note "Remarque"

    GNU/Linux dispose de deux mécanismes de groupe :

    1. Groupe public, son groupe principal est GID=100
    2. Groupe privé, c'est-à-dire que lors de l'ajout d'utilisateurs, un groupe portant le même nom est créé comme groupe principal. Ce mécanisme de groupe est couramment utilisé par Fedora et les distributions en aval associées.

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

`UMASK 022`: Cela correspond à l'autorisation de créer un fichier suivant 755 (rwxr-xr-x). Cependant, pour des raisons de sécurité, GNU/Linux ne dispose pas de la permission **x** pour les fichiers nouvellement créés. Cette restriction s'applique à `root` (uid=0) et aux utilisateurs ordinaires (uid&gt;=1000). Par exemple :

```bash
Shell > touch a.txt
Shell > ll
-rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
```

`HOME_MODE 0700` : correspond aux autorisations du répertoire personnel d'un utilisateur ordinaire. Ne fonctionne pas pour le répertoire `home` de `root`.

```bash
Shell > ll -d /root
dr-xr-x---. 10 root root 4096 Oct  8 13:12 /root

Shell > ls -ld /home/test1/
drwx------ 2 test1 test1 4096 Oct  8 13:10 /home/test1/
```

`USERGROUPS_ENAB yes` : "Quand vous supprimez un utilisateur en utilisant la commande `userdel -r`, le groupe principal correspondant est également supprimé." Pour quelle raison ? C'est la raison.

### Fichier `/etc/skel`

Lors de la création d’un utilisateur, son répertoire personnel – home – et ses fichiers d’environnement sont créés. Vous pouvez considérer les fichiers du répertoire `/etc/skel/` comme les modèles de fichiers dont vous avez besoin pour créer des utilisateurs.

Ces fichiers sont automatiquement copiés depuis le répertoire `/etc/skel`.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

Tous les fichiers et répertoires placés dans ce répertoire seront copiés dans l’arborescence de l'utilisateur lors de sa création.

## Changement d’identité

### La commande `su`

La commande `su` permet de modifier l’identité de l’utilisateur connecté.

```bash
su [-] [-c command] [login]
```

Exemples :

```bash
$ sudo su - alain
[albert]$ su - root -c "passwd alain"
```

| Option       | Observation                                           |
| ------------ | ----------------------------------------------------- |
| `-`          | Charge l’environnement complet de l’utilisateur.      |
| `-c` command | Exécute la commande sous l’identité de l’utilisateur. |

Si le login n’est pas spécifié, ce sera `root`.

Les utilisateurs standards devront taper le mot de passe de la nouvelle identité.

!!! tip "Astuce"

    Vous pouvez utiliser la commande `exit`/`logout` pour déconnecter les utilisateurs. Il faut noter qu'après un changement d'utilisateur, il n'y a pas de nouveau `child shell` ni `sub shell`, par exemple :

    ```
    $ whoami
    root
    $ echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0

    $ su - test1
    $ echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0
    ```

Attention, s'il vous plaît ! `su` et `su -` sont différents, comme illustré dans l'exemple suivant :

```bash
$ whoami
test1
$ su root
$ pwd
/home/test1

$ env
...
USER=test1
PWD=/home/test1
HOME=/root
MAIL=/var/spool/mail/test1
LOGNAME=test1
...
```

```bash
$ whoami
test1
$ su - root
$ pwd
/root

$ env
...
USER=root
PWD=/root
HOME=/root
MAIL=/var/spool/mail/root
LOGNAME=root
...
```

Donc, lorsque vous voulez changer d'utilisateur, n'oubliez pas le tiret `-`. Si les fichiers de variables d'environnement nécessaires ne sont pas chargés, il peut y avoir des problèmes pour exécuter certains programmes.
