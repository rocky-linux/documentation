---
title: Gestion des Processus
---

# Gestion des Processus

Dans ce chapitre, vous apprendrez comment travailler avec les processus.

****

**Objectifs** : Dans ce chapitre, les futurs administrateurs Linux vont apprendre comment :

:heavy_check_mark: Reconnaître le `PID` et le `PPID` d'un processus ;   
:heavy_check_mark: Voir et rechercher des processus ;   
:heavy_check_mark: Gérer les processus.

:checkered_flag: **processus**, **linux**

**Connaissances** : :star: :star:   
**Complexité** : :star:

**Temps de lecture** : 20 minutes

****

## Généralités

Un système d'exploitation se compose de processus. Ces processus sont exécutés dans un ordre spécifique et sont liés de l'un à l'autre. Il y a deux catégories de processus, ceux concernant l'environnement utilisateur et ceux orientés sur l'environnement du matériel.

Quand un programme s'exécute, le système va créer un processus en plaçant les données et le code du programme en mémoire et en créant une **pile d'exécution**. Un processus est donc une instance d'un programme avec un environnement de processeur associé (compteur, registres, etc...) et un environnement mémoire.

Chaque processus a :

* un _PID_ : _**P**rocessus **ID**entificateur_, un identifiant de processus unique ;
* un _PPID_: _**P**rocessus **P**arent **ID**entificateur_, identifiant unique du processus parent.

Par filiations successives, le processus `init` est le père de tous les processus.

* Un processus est toujours créé par un processus parent ;
* Un processus parent peut avoir plusieurs processus enfants.

Il y a une relation parent/enfant entre les processus. Un processus fils est le résultat du processus parent appelant la primitive _fork()_ et dupliquant son propre code pour créer un enfant. Le _PID_ de l'enfant est renvoyé au processus parent afin qu'ils puissent communiquer. Chaque enfant a l'identifiant de son parent, le _PPID_.

Le numéro _PID_ représente le processus lors de l'exécution. Une fois le processus terminé, le numéro est à nouveau disponible pour un autre processus. Lancer une même commande plusieurs fois va produire un nouveau _PID_ pour chaque processus.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! note "Remarque"

    Il ne faut pas confondre les processus avec les <em x-id="4">threads</em>. Chaque processus a son propre contexte (resources et espace de mémoire), tandis que les _threads_ appartenant à un même processus partagent le même contexte.

## Visualisation des processus

La commande `ps` affiche l'état des processus en cours d'exécution.
```
ps [-e] [-f] [-u login]
```

Exemple :
```
# ps -fu root
```

| Option     | Observation                               |
| ---------- | ----------------------------------------- |
| `-e`       | Affiche tous les processus.               |
| `-f`       | Affiche des informations supplémentaires. |
| `-u` login | Affiche les processus de l'utilisateur.   |

Quelques options supplémentaires :

| Option                | Observation                                                 |
| --------------------- | ----------------------------------------------------------- |
| `-g`                  | Affiche les processus dans le groupe.                       |
| `-t tty`              | Affiche les processus exécutés depuis le terminal.          |
| `-p PID`              | Affiche les informations du processus.                      |
| `-H`                  | Affiche les informations dans une structure d'arborescence. |
| `-I`                  | Affiche des informations supplémentaires.                   |
| `--sort COL`          | Trier le résultat en fonction d'une colonne.                |
| `--headers`           | Affiche l'en-tête sur chaque page du terminal.              |
| `--format "%a %b %c"` | Personnaliser le format d'affichage de sortie.              |

Sans une option spécifiée, la commande `ps` n'affiche que les processus exécutés depuis le terminal actuel.

Le résultat est affiché en colonnes :

```
# ps -ef
UID  PID PPID C STIME  TTY TIME      CMD
root 1   0    0 Jan01  ?   00:00/03 /sbin/init
```

| Colonne | Observation                      |
| ------- | -------------------------------- |
| `UID`   | Utilisateur propriétaire.        |
| `PID`   | Identificateur de processus.     |
| `PPID`  | Identifiant du processus parent. |
| `C`     | Priorité du processus.           |
| `STIME` | Date et heure d'exécution.       |
| `TTY`   | Terminal d'exécution.            |
| `TIME`  | Durée de traitement.             |
| `CMD`   | Commande exécutée.               |

Le comportement du contrôle peut être entièrement personnalisé :

```
# ps -e --format "%P %p %c %n" --sort ppid --headers
 PPID   PID COMMAND          NI
    0     1 systemd           0
    0     2 kthreadd          0
    1   516 systemd-journal   0
    1   538 systemd-udevd     0
    1   598 lvmetad           0
    1   643 auditd           -4
    1   668 rtkit-daemon      1
    1   670 sssd              0
```

## Types de processus

Le processus utilisateur :

* est démarré à partir d'un terminal associé à un utilisateur ;
* accède à des ressources via des requêtes ou des démons.

Le processus système (_daemon_ ) :

* est démarré par le système ;
* n'est associé à aucun terminal, et appartient à un utilisateur système (souvent `root`) ;
* est chargé au démarrage, est en mémoire, et attend un appel ;
* est généralement identifié par la lettre `d` associée au nom du processus.

Les processus système sont donc appelés démons (_**D**isk **A**nd **E**xecution **MON**itor_).

## Permissions et droits

Lorsqu'une commande est exécutée, les identifiants de l'utilisateur sont passés au processus créé.

Par défaut, les `UID` et `GID` actuels (du processus) sont donc identiques à ceux **réels** `UID` et `GID` (les `UID` et `GID` de l'utilisateur qui a exécuté la commande).

Lorsqu'un `SUID` (et/ou `SGID`) est défini sur une commande, l'actuel `UID` (et/ou `GID`) devient celui du propriétaire (et/ou du groupe propriétaire) de la commande et non plus celui de l'utilisateur ou du groupe de l'utilisateur qui a émis la commande. Les **UIDs effectifs et réels** sont donc **différents**.

Chaque fois qu'un fichier est accédé, le système vérifie les droits du processus en fonction de ses identifiants effectifs.

## Gestion des processus

Un processus ne peut pas être exécuté indéfiniment, car cela se ferait au détriment d'autres processus en cours d'exécution et empêcherait le multitâche.

Le temps total de traitement disponible est donc divisé en petites plages et chaque processus (avec priorité) accède au processeur de manière séquentielle. Le processus prendra plusieurs états au cours de sa vie parmi les états suivants :

* ready : en attente de la disponibilité du processus ;
* in execution : en cours d'exécution, accède au processeur ;
* suspended : en attente d'une E/S (entrée/sortie) ;
* suspended : en attente d'un signal d'un autre processus ;
* zombie: demande de destruction ;
* dead  : le père du processus tue son fils.

Le séquençage de la fin du processus est le suivant :

1. Fermeture des fichiers ouverts ;
2. Libération de la mémoire utilisée ;
3. Envoi d'un signal aux processus parent et fils.

Lorsqu'un processus parent meurt, on dit que ses enfants sont orphelins. Ils sont ensuite adoptés par le processus `init` qui les détruira.

### La priorité d'un processus

Le processeur tourne en partageant avec chaque processus une quantité de temps de processeur.

Les processus sont classés par priorité dont la valeur varie de **-20** (la priorité la plus élevée) à **+19** (la priorité la plus basse).

La priorité par défaut d'un processus est **0**.

### Modes de fonctionnement

Les processus peuvent s'exécuter de deux manières:

* **synchrone**: l'utilisateur perd l'accès au shell lors de l'exécution de la commande. L'invite de commande réapparaît à la fin de l'exécution du processus.
* **asynchrone**: le processus est traité en arrière-plan. L'invite de commande s'affiche à nouveau immédiatement.

Les contraintes du mode asynchrone :

* la commande ou le script ne doit pas attendre l'entrée du clavier ;
* la commande ou le script ne doit pas retourner de résultat à l'écran ;
* quitter le shell termine le processus.

## Contrôles de gestion des processus

### la commande `kill`

La commande `kill` envoie un signal d'arrêt à un processus.

```
kill [-signal] PID
```

Exemple :

```
$ kill -9 1664
```

| Code | Signal    | Observation                       |
| ---- | --------- | --------------------------------- |
| `2`  | _SIGINT_  | Fin immédiate du processus        |
| `9`  | _SIGKILL_ | Interrompre le processus (CTRL+D) |
| `15` | _SIGTERM_ | Fin du processus de nettoyage     |
| `18` | _SIGCONT_ | Reprendre le processus            |
| `19` | _SIGSTOP_ | Suspendre le processus            |

Les signaux sont les moyens de communication entre les processus. La commande `kill` envoie un signal à un processus.

!!! tip "Astuce"

    La liste complète des signaux pris en compte par la commande `kill` est disponible en utilisant :

    ```
    $ man 7 signal
    ```

### La commande `nohup`

`nohup` permet le lancement d'un processus indépendamment d'une connexion.

```
commande nohup
```

Exemple :

```
$ nohup myprogram.sh 0</dev/null &
```

`nohup` ignore le signal `SIGHUP` envoyé lorsqu'un utilisateur se déconnecte.

!!! note "Remarque"

    `nohup` gère la sortie standard et d'erreur, mais pas l'entrée standard, d'où la redirection de cette entrée vers `/dev/null`.

### [CTRL] + [Z]

En appuyant simultanément sur les touches <kbd>CTRL</kbd> + <kbd>Z</kbd> , le processus synchronisé est temporairement suspendu. L'accès à l'invite est restauré après avoir affiché le numéro du processus qui vient d'être suspendu.

### `&` instruction

L'instruction `&` exécute la commande de manière asynchrone (la commande est alors appelée _job_) et affiche le nombre de _jobs_. L'accès à l'invite est alors retourné.

Exemple :

```
$ time ls -lR / > list.ls 2> /dev/null &
[1] 15430
$
```

Le numéro du _job_ est obtenu lors du traitement en arrière-plan et est affiché entre crochets, suivi du numéro `PID`.

### Les commandes `fg` et `bg`

La commande `fg` met le processus au premier plan:

```
$ time ls -lR / > list.ls 2>/dev/null &
$ fg 1
time ls -lR / > list.ls 2/dev/null
```

alors que la commande `bg` la place en arrière-plan :

```
[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
```

S'il a été mis en arrière-plan quand il a été créé avec l'argument `&` ou plus tard avec les clés <kbd>CTRL</kbd> +<kbd>Z</kbd> , un processus peut être ramené au premier plan avec la commande `fg` et son numéro de tâche.

### La commande `jobs`

La commande `jobs` affiche la liste des processus exécutés en arrière-plan et spécifie leur numéro de tâche.

Exemple :

```
$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / > arbo.txt
```

Les colonnes représentent :

1. numéro de tâche.
2. l'ordre dans lequel les processus s'exécutent
- a `+` : ce processus est le processus suivant à exécuter par défaut avec `fg` ou `bg` ;
- a `-` : ce processus est le prochain processus à prendre le `+` ; `+`
3.  _Running_ (processus en cours) ou _Stopped_ (processus suspendu).
4. la commande

### Les commandes `nice` et `renice`

La commande `nice` permet l'exécution d'une commande en spécifiant sa priorité.

```
nice priorité commande
```

Exemple :

```
$ nice -n+15 find / -name "file"
```

Contrairement à `root`, un utilisateur standard ne peut que réduire la priorité d'un processus. Seules les valeurs entre +0 et +19 seront acceptées.

!!! tip "Astuce"

    Cette dernière restriction peut être evitée par utilisateur ou par groupe en modifiant le fichier `/etc/security/limits.conf` file.

La commande `renice` vous permet de modifier la priorité d'un processus en cours.

```
renice priority [-g GID] [-p PID] [-u UID]
```

Exemple :

```
$ renice +15 -p 1664
```
| Option | Observation                                |
| ------ | ------------------------------------------ |
| `-g`   | `GID` du groupe propriétaire du processus. |
| `-p`   | `PID` du processus.                        |
| `- u`  | `UID` du processus propriétaire.           |

La commande `renice` agit sur des processus déjà en cours d'exécution. Il est donc possible de modifier la priorité d'un processus spécifique, mais aussi de plusieurs processus appartenant à un utilisateur ou à un groupe.

!!! tip "Astuce"

    La commande `pidof`, associée à la commande `xargs` (voir le cours Commandes Avancées), permet d'appliquer une nouvelle priorité en une seule commande :

    ```
    $ pidof sleep | xargs renice 20
    ```

### La commande `top`

La commande `top` affiche les processus et leur consommation de ressources.

```
$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
```

| Colonne   | Observation                        |
| --------- | ---------------------------------- |
| `PID`     | Identificateur de processus.       |
| `USER`    | Utilisateur propriétaire.          |
| `PR`      | Priorité du processus.             |
| `NI`      | Valeur nice.                       |
| `%CPU`    | Charge du processeur.              |
| `%MEM`    | Charge de la mémoire.              |
| `TIME+`   | Temps d'utilisation du processeur. |
| `COMMAND` | Commande exécutée.                 |

La commande `top` permet d'afficher les processus en temps réel et en mode interactif.

### Les commandes `pgrep` et `pkill`

La commande `pgrep` recherche les processus en cours pour trouver un nom de processus et affiche le _PID_ correspondant aux critères de sélection sur la sortie standard.

La commande `pkill` enverra le signal spécifié (par défaut _SIGTERM_) à chaque processus indiqué par son nom.

```
pgrep process
pkill [-signal] process
```

Exemples :

* Récupère le numéro de processus de `sshd`:

```
$ pgrep -u root sshd
```

* Terminer tous les processus de `tomcat` :

```
$ pkill tomcat
```
