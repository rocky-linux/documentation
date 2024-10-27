---
title: Gestion des Processus
---

# Gestion des Processus

Dans ce chapitre, vous apprendrez comment travailler avec les processus.

****

**Objectifs** : Dans ce chapitre, les futurs administrateurs Linux vont apprendre comment :

:heavy_check_mark: Reconnaître le `PID` et le `PPID` d'un processus ;  
:heavy_check_mark: Afficher et rechercher des processus ;  
:heavy_check_mark: Gérer les processus.

:checkered_flag: **processus**, **linux**

**Connaissances** : :star: :star:  
**Complexité** : :star:

**Temps de lecture** : 23 minute

****

## Généralités

Un système d'exploitation se compose de processus. Ces processus sont exécutés dans un ordre spécifique et sont liés de l'un à l'autre. Il y a deux catégories de processus, ceux concernant l'environnement utilisateur et ceux orientés sur l'environnement du matériel.

Quand un programme s'exécute, le système va créer un processus en plaçant les données et le code du programme en mémoire et en créant une **pile d'exécution**. Un processus est donc une instance d'un programme avec un environnement de processeur associé (compteur, registres, etc...) et un environnement mémoire.

Chaque processus a :

* un *PID* : ***P**rocessus **ID**entificateur*, un identifiant de processus unique
* un *PPID*: ***P**rocessus **P**arent **ID**entificateur*, identifiant unique du processus parent

Par filiations successives, le processus `init` est le père de tous les processus.

* Un processus est toujours créé par un processus parent
* Un processus parent peut avoir plusieurs processus enfants.

Il y a une relation parent/enfant entre les processus. Un processus fils est le résultat du processus parent appelant la primitive *fork()* et dupliquant son propre code pour créer un enfant. Le *PID* de l'enfant est renvoyé au processus parent afin qu'ils puissent communiquer. Chaque enfant a l'identifiant de son parent, le *PPID*.

Le numéro *PID* représente le processus lors de l'exécution. Une fois le processus terminé, le numéro est à nouveau disponible pour un autre processus. Lancer une même commande plusieurs fois va produire un nouveau *PID* pour chaque processus.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! note "Remarque"

    Il ne faut pas confondre les processus avec les <em x-id="4">threads</em>. Chaque processus a son propre contexte (resources et espace de mémoire), tandis que les _threads_ appartenant à un même processus partagent le même contexte.

## Visualisation des processus

La commande `ps` affiche l'état des processus en cours d'exécution.

```bash
ps [-e] [-f] [-u login]
```

Exemple :

```bash
# ps -fu root
```

| Option     | Observation                                      |
| ---------- | ------------------------------------------------ |
| `-e`       | Affiche tous les processus.                      |
| `-f`       | Affichage de la liste complète des informations. |
| `-u` login | Affiche les processus de l'utilisateur.          |

Quelques options supplémentaires :

| Option                | Observation                                                 |
| --------------------- | ----------------------------------------------------------- |
| `-g`                  | Affiche les processus dans le groupe.                       |
| `-t tty`              | Affiche les processus exécutés depuis le terminal.          |
| `-p PID`              | Affiche les informations du processus.                      |
| `-H`                  | Affiche les informations dans une structure d'arborescence. |
| `-l`                  | Affichage en format long.                                   |
| `--sort COL`          | Trier le résultat en fonction d'une colonne.                |
| `--headers`           | Affiche l'en-tête sur chaque page du terminal.              |
| `--format "%a %b %c"` | Personnaliser le format d'affichage de sortie.              |

Sans une option spécifiée, la commande `ps` n'affiche que les processus exécutés depuis le terminal actuel.

Le résultat est affiché en colonnes :

```bash
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

```bash
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

Le processus système (*daemon*) :

* est démarré par le système ;
* n'est associé à aucun terminal, et appartient à un utilisateur système (souvent `root`)
* est chargé au démarrage, est en mémoire, et attend un appel ;
* est généralement identifié par la lettre `d` associée au nom du processus.

Les processus système sont donc appelés daemons (***D**isk **A**nd **E**xecution **MON**itor*).

## Permissions et droits

Lorsqu'une commande est exécutée, les identifiants de l'utilisateur sont passés au processus créé.

Par défaut, les `UID` et `GID` actuels (du processus) sont donc identiques à ceux **réels** `UID` et `GID` (les `UID` et `GID` de l'utilisateur qui a exécuté la commande).

Lorsqu'un `SUID` (et/ou `SGID`) est défini sur une commande, l'actuel `UID` (et/ou `GID`) devient celui du propriétaire (et/ou du groupe propriétaire) de la commande et non plus celui de l'utilisateur ou du groupe de l'utilisateur qui a émis la commande. Les **UIDs effectifs et réels** sont donc **différents**.

Chaque fois qu'un fichier est accédé, le système vérifie les droits du processus en fonction de ses identifiants effectifs.

## Gestion des processus

Un processus ne peut pas être exécuté indéfiniment, car cela se ferait au détriment d'autres processus en cours d'exécution et empêcherait le multitâche.

Le temps total de traitement disponible est donc divisé en petites plages et chaque processus (avec sa propre priorité) accède au processeur de manière séquentielle. Le processus prendra plusieurs états au cours de sa vie parmi les états suivants :

* ready : en attente de la disponibilité du processus ;
* in execution : en cours d'exécution, accède au processeur ;
* suspended : en attente d'une E/S (entrée/sortie) ;
* suspended : en attente d'un signal d'un autre processus ;
* zombie: demande de destruction
* dead  : le père du processus tue son fils.

Le séquençage de la fin du processus est le suivant :

1. Fermeture des fichiers ouverts ;
2. Libération de la mémoire utilisée ;
3. Envoi d'un signal aux processus parent et fils.

Lorsqu'un processus parent meurt, on dit que ses enfants sont orphelins. Ils sont ensuite adoptés par le processus `init` qui les détruira.

### La priorité d'un processus

GNU/Linux appartient à la famille des systèmes d'exploitation à temps partagé. Les processeurs fonctionnent en temps partagé et chaque processus se voit attribué du temps processeur. Les processus peuvent être classifiés par priorité :

* Processus en temps réel : le processus avec une priorité **0-99** est planifié par un algorithme de scheduling en temps réel.
* Processus ordinaires : les processus avec des priorités dynamiques de **100-139** sont planifiés à l'aide d'un algorithme de scheduling équilibré.
* Nice value : un paramètre utilisé pour ajuster la priorité d'un processus ordinaire. La plage de valeurs s'étend de **-20** à **19**.

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

```bash
kill [-signal] PID
```

Exemple :

```bash
kill -9 1664
```

| Code | Signal    | Observation                                                                                                                  |
| ---- | --------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `2`  | *SIGINT*  | Fin immédiate du processus                                                                                                   |
| `9`  | *SIGKILL* | Interrompre le processus (++control+"d"++)                                                                                   |
| `15` | *SIGTERM* | Fin du processus de nettoyage                                                                                                |
| `18` | *SIGCONT* | Reprendre le processus. Les processus suspendus par le signal SIGSTOP peuvent continuer à s'exécuter grâce au signal SIGCONT |
| `19` | *SIGSTOP* | Suspendre le processus (Stop process). L'effet de ce signal est équivalent à ++ctrl+"z"++                                    |

Les signaux sont les moyens de communication entre les processus. La commande `kill` envoie un signal à un processus.

!!! tip "Astuce"

    La liste complète des signaux pris en compte par la commande `kill` est disponible en utilisant :

    ```
    $ man 7 signal
    ```

### La commande `nohup`

`nohup` permet le lancement d'un processus indépendamment d'une connexion.

```bash
commande nohup
```

Exemple :

```bash
nohup myprogram.sh 0</dev/null &
```

`nohup` ignore le signal `SIGHUP` envoyé lorsqu'un utilisateur se déconnecte.

!!! note "Remarque"

    `nohup` gère la sortie standard et d'erreur, mais pas l'entrée standard, d'où la redirection de cette entrée vers `/dev/null`.

### [Ctrl] + [z]

En appuyant simultanément sur les touches ++control+"z"++, le processus synchronisé est temporairement suspendu. L'accès à l'invite est restauré après avoir affiché le numéro du processus qui vient d'être suspendu.

### `&` instruction

L'instruction `&` exécute la commande de manière asynchrone (la commande est alors appelée *job*) et affiche l'identifiant du *job*. L'accès à l'invite est alors retourné.

Exemple :

```bash
$ time ls -lR / > list.ls 2> /dev/null &
[1] 15430
$
```

Le numéro du *job* est obtenu lors du traitement en arrière-plan et est affiché entre crochets, suivi de l'identifiant `PID`.

### Les commandes `fg` et `bg`

La commande `fg` met le processus au premier plan:

```bash
$ time ls -lR / > list.ls 2>/dev/null &
$ fg 1
time ls -lR / > list.ls 2/dev/null
```

alors que la commande `bg` la place en arrière-plan :

```bash
[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
```

S'il a été mis en arrière-plan quand il a été créé avec l'argument `&` ou plus tard avec les touches ++control+"z"++, un processus peut être ramené au premier plan avec la commande `fg` et son numéro de `job`.

### La commande `jobs`

La commande `jobs` affiche la liste des processus exécutés en arrière-plan et spécifie leur numéro de tâche.

Exemple :

```bash
$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / > arbo.txt
```

Les colonnes représentent :

1. numéro de tâche.
2. l'ordre dans lequel les processus s'exécutent :

   * a `+` : ce processus est le processus suivant à exécuter par défaut avec `fg` ou `bg` ;
   * a `-` : ce processus est le prochain processus à prendre le `+` ; `+`

3. *Running* (processus en cours) ou *Stopped* (processus suspendu)
4. la commande

### Les commandes `nice` et `renice`

La commande `nice` permet l'exécution d'une commande en spécifiant sa priorité.

```bash
nice priorité commande
```

Exemple d'utilisation :

```bash
nice --adjustment=-5 find / -name "file"

nice -n -5 find / -name "file"

nice --5 find / -name "file"

nice -n 5 find / -name "file"

nice find / -name "file"
```

Contrairement à `root`, un utilisateur standard ne peut que réduire la priorité d'un processus et seules les valeurs comprises entre 0 et 19 seront acceptées.

Comme indiqué dans l'exemple ci-dessus, les trois premières commandes indiquent de définir la valeur Nice à `-5`, tandis que la deuxième commande est votre utilisation recommandée. La quatrième commande indique de définir la valeur Nice à `5`. Pour la cinquième commande, ne pas saisir d'options signifie que la valeur Nice est définie à `10`.

!!! tip "Astuce"

    `nice` est l'abréviation de `niceness`. 
    
    Taper directement la commande `nice` renverra la valeur Nice du shell actuel. 
    
    Vous pouvez lever la limite de valeur Nice pour chaque utilisateur ou groupe en modifiant le fichier `/etc/security/limits.conf`.

La commande `renice` vous permet de modifier la priorité d'un processus en cours d'exécution.

```bash
renice priority [-g GID] [-p PID] [-u UID]
```

Exemple :

```bash
renice -n 15 -p 1664
```

| Option | Observation                                |
| ------ | ------------------------------------------ |
| `-g`   | `GID` du groupe propriétaire du processus. |
| `-p`   | `PID` du processus.                        |
| `-u`   | `UID` du processus propriétaire.           |

La commande `renice` agit sur des processus déjà en cours d'exécution. Il est donc possible de modifier la priorité d'un processus spécifique, mais aussi de plusieurs processus appartenant à un utilisateur ou à un groupe.

!!! tip "Astuce"

    La commande `pidof`, associée à la commande `xargs` (voir le cours Commandes Avancées), permet d'appliquer une nouvelle priorité en une seule commande :

    ```
    $ pidof sleep | xargs renice -n 20
    ```

Pour vous adapter à différentes distributions, vous devriez essayer d'utiliser autant que possible des formes de commande telles que `nice -n 5` ou `renice -n 6`.

### La commande `top`

La commande `top` affiche les processus et leur consommation de ressources.

```bash
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

La commande `top` permet de piloter les processus en temps réel et en mode interactif.

### Les commandes `pgrep` et `pkill`

La commande `pgrep` cherche parmi les processus en cours pour trouver un nom de processus et affiche l'identifiant *PID* correspondant aux critères de sélection sur la sortie standard.

La commande `pkill` enverra le signal spécifié (par défaut *SIGTERM*) à chaque processus.

```bash
pgrep process
pkill [option] [-signal] process
```

Exemples :

* Récupère le numéro de processus de `sshd` :

  ```bash
  pgrep -u root sshd
  ```

* Terminer tous les processus de `tomcat` :

  ```bash
  pkill tomcat
  ```

!!! note "Remarque"

    Avant de détruire un processus, il est préférable de savoir exactement à quoi il sert ; sinon, cela peut entraîner des pannes du système ou d’autres problèmes imprévisibles.

En plus d'envoyer des signaux aux processus concernés, la commande `pkill` peut également mettre fin à la session de connexion de l'utilisateur en fonction du numéro de terminal, par exemple :

```bash
pkill -t pts/1
```

### La commande `killall`

La fonction de cette commande est approximativement la même que celle de la commande `pkill`. La syntaxe est la suivante —`killall [option] [ -s SIGNAL | -SIGNAL ] NAME`. Le signal par défaut est *SIGTERM*.

| Options | Observation                                                            |
|:------- |:---------------------------------------------------------------------- |
| `-l`    | répertorie tous les noms de signaux connus                             |
| `-i`    | demande de confirmation avant destruction du processus                 |
| `-I`    | correspondance du nom du processus qui ne tient pas compte de la casse |

Exemple :

```bash
killall tomcat
```

### La commande `pstree`

Cette commande affiche l'arborescence des processus et son utilisation est la suivante :<br/> `pstree [option]`.

| Option | Observation                                         |
|:------ |:--------------------------------------------------- |
| `-p`   | Affiche l'identifiant PID du processus              |
| `-R`   | trier la sortie par PID                             |
| `-h`   | met en évidence le processus actuel et ses ancêtres |
| `-u`   | affichage des transitions d'UID                     |

```bash
$ pstree -pnhu
systemd(1)─┬─systemd-journal(595)
           ├─systemd-udevd(625)
           ├─auditd(671)───{auditd}(672)
           ├─dbus-daemon(714,dbus)
           ├─NetworkManager(715)─┬─{NetworkManager}(756)
           │                     └─{NetworkManager}(757)
           ├─systemd-logind(721)
           ├─chronyd(737,chrony)
           ├─sshd(758)───sshd(1398)───sshd(1410)───bash(1411)───pstree(1500)
           ├─tuned(759)─┬─{tuned}(1376)
           │            ├─{tuned}(1381)
           │            ├─{tuned}(1382)
           │            └─{tuned}(1384)
           ├─agetty(763)
           ├─crond(768)
           ├─polkitd(1375,polkitd)─┬─{polkitd}(1387)
           │                       ├─{polkitd}(1388)
           │                       ├─{polkitd}(1389)
           │                       ├─{polkitd}(1390)
           │                       └─{polkitd}(1392)
           └─systemd(1401)───(sd-pam)(1404)
```

### Processus orphelin et Processus zombie

**orphan — processus orphelin** : Lorsqu'un processus parent meurt, on dit que ses enfants sont orphelins. Le processus init adopte ces processus d'état spéciaux et la collecte de status est effectuée jusqu'à ce qu'ils soient détruits. D'un point de vue conceptuel, l'existence de processus orphelins ne pose aucun problème.

**processus zombie** : une fois qu'un processus enfant a terminé son travail et est terminé, son processus parent doit appeler la fonction de traitement du signal wait() ou waitpid() pour obtenir l'état de terminaison du processus enfant. Si le processus parent ne le fait pas, même si le processus enfant est déjà terminé, il conserve néanmoins certaines informations sur l'état de sortie dans la table des processus système. Étant donné que le processus parent ne peut pas obtenir les informations d'état du processus enfant, ces processus continueront d'occuper des ressources dans la table des processus. Nous appelons les processus dans cet état des `zombie`s.

Risques :

* ils occupent les ressources du système et entraînent une diminution des performances de la machine,
* et sont incapables de générer de nouveaux processus enfants.

Comment pouvons-nous vérifier la présence de processus zombies dans le système actuel ?

```bash
ps -lef | awk '{print $2}' | grep Z
```

Les caractères suivants peuvent apparaître dans cette colonne :

* **D** - `sleep` ininterrompu (généralement IO)
* **I** - `thread` de noyau inactif
* **R** - en cours d'exécution ou exécutable (`runnable`, dans la file d'attente d'exécution)
* **S** - `sleep` interruptible (en attente d'un événement pour continuer)
* **T** - stoppé par le signal de contrôle de tâche
* **t** - arrêté par le débogueur pendant le traçage
* **W** - pagination (non valide depuis le noyau 2.6.xx)
* **X** - mort (ne devrait jamais apparaître)
* **Z** - processus défunt (`zombie`), terminé mais non récupéré par son parent
