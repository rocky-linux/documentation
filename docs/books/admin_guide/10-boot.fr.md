---
title: Démarrage du Système
---

# Démarrage du Système

Dans ce chapitre, vous apprendrez comment le système démarre.

****
**Objectifs** : Dans ce chapitre, les futurs administrateurs Linux vont apprendre :

:heavy_check_mark: Les différentes étapes du processus de démarrage ;  
:heavy_check_mark: Comment Rocky Linux prend en charge ce démarrage en utilisant GRUB2 et systemd ;  
:heavy_check_mark: Comment protéger GRUB2 d'une attaque ;  
:heavy_check_mark: Comment gérer les services ;  
:heavy_check_mark: Comment accéder aux journaux depuis `journald`.

:checkered_flag: **utilisateurs**

**Connaissances** : :star: :star:  
**Complexité** : :star: :star: :star:

**Temps de lecture** : 23 minutes
****

## Le processus de démarrage

Il est important de comprendre le processus de démarage de Linux afin de pouvoir résoudre les problèmes qui peuvent se produire.

Le processus de démarrage comprend :

### BIOS startup

Le **BIOS** (Basic Input/Output System) effectue le **POST** (auto-test) pour détecter, tester et initialiser les composants matériels du système.

Il charge ensuite le **MBR** (Master Boot Record).

### L'enregistrement d'amorçage principal (MBR)

L'enregistrement d'amorçage principal est les 512 premiers octets du disque d'amorçage. Le MBR découvre le périphérique d'amorçage et charge le chargeur de démarrage **GRUB2** en mémoire et lui transfère le contrôle.

Les 64 octets suivants contiennent la table de partitions du disque.

### Le chargeur de démarrage GRUB2

Le chargeur de démarrage par défaut pour la distribution Rocky 8 est **GRUB2** (GRand Unified Bootloader n° 2). GRUB2 remplace l'ancien chargeur d'amorçage GRUB (également appelé legacy GRUB).

Le fichier de configuration GRUB 2 se trouve sous `/boot/grub2/grub.cfg` mais ne doit pas être édité directement.

Les paramètres de configuration du menu GRUB2 sont situés dans `/etc/default/grub` et sont utilisés pour générer le fichier `grub.cfg`.

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

Si des modifications sont apportées à un ou plusieurs de ces paramètres, la commande `grub2-mkconfig` doit être exécutée pour régénérer le fichier `/boot/grub2/grub.cfg`.

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 recherche l'image du noyau compressé (le fichier `vmlinuz` ) dans le répertoire `/boot`.
* GRUB2 charge l'image du noyau en mémoire et extrait le contenu du fichier image `initramfs` dans un dossier temporaire en mémoire en utilisant le système de fichiers `tmpfs`.

### Le noyau

Le noyau démarre le processus `systemd` avec PID 1.

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

Systemd est le parent de tous les processus système. Il lit la cible du lien `/etc/systemd/system/default.target` (par exemple, `/usr/lib/systemd/system/multi-user.target`) pour déterminer la cible par défaut du système. Le fichier définit les services à démarrer.

Systemd place ensuite le système dans l'état défini par la cible en effectuant les tâches d'initialisation suivantes :

1. Définir le nom de la machine
2. Initialiser le réseau
3. Initialiser SELinux
4. Afficher la bannière de bienvenue
5. Initialiser le matériel en se basant sur les arguments donnés au noyau au démarrage
6. Monter les systèmes de fichiers, y compris les systèmes de fichiers virtuels comme /proc
7. Nettoyer les répertoires dans /var
8. Lancer la mémoire virtuelle (swap)

## Protéger le chargeur de démarrage GRUB2

Pourquoi protéger le chargeur de démarrage avec un mot de passe ?

1. Empêcher l'accès en mode utilisateur *Single* - Si un attaquant peut démarrer en mode mono-utilisateur, il devient l'utilisateur root.
2. Empêcher l'accès à la console GRUB - Si un attaquant parvient à utiliser la console GRUB, il peut modifier sa configuration ou collecter des informations sur le système en utilisant la commande `cat`.
3. Empêcher l'accès aux systèmes d'exploitation non sécurisés. S'il y a un double démarrage sur le système, un attaquant peut sélectionner un système d'exploitation tel que DOS au démarrage qui ignore les contrôles d'accès et les autorisations de fichiers.

Pour protéger par mot de passe le chargeur de démarrage GRUB2 :

* Retirer `-unrestricted` de l'instruction principale `CLASS=` dans le fichier `/etc/grub.d/10_linux`.

* Si un utilisateur n'a pas encore été configuré, utilisez la commande `grub2-setpassword` pour fournir un mot de passe à l'utilisateur root :

```bash
# grub2-setpassword
```

Un fichier `/boot/grub2/user.cfg` sera créé s'il n'est pas déjà présent. Il contient le mot de passe haché du GRUB2.

!!! note "Remarque"

    Cette commande ne prend en charge que les configurations ne contenant qu'un seul utilisateur root.

```bash
[root]# cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.CC6F56....A21
```

* Recrée le fichier de configuration avec la commande `grub2-mkconfig` :

```bash
[root]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-f9725b0c842348ce9e0bc81968cf7181
Found initrd image: /boot/initramfs-0-rescue-f9725b0c842348ce9e0bc81968cf7181.img
done
```

* Redémarrez le serveur et vérifiez.

Toutes les entrées définies dans le menu GRUB nécessiteront maintenant la saisie d'un utilisateur et d'un mot de passe à chaque démarrage. Le système ne démarre pas un noyau sans intervention directe de l'utilisateur à partir de la console.

* Lorsque l'utilisateur est demandé, entrez `root` ;
* Quand un mot de passe est demandé, indiquez le mot de passe fourni à la commande `grub2-setpassword`.

Pour ne protéger que l'édition des entrées du menu GRUB et l'accès à la console, l'exécution de la commande `grub2-setpassword` est suffisante. Il se peut que vous ayez de bonnes raisons de le faire. Cela peut être particulièrement vrai dans un centre de données à distance où entrer un mot de passe chaque fois qu'un serveur est redémarré, est difficile ou impossible à faire.

## Systemd

*systemd* est un gestionnaire de services pour des systèmes d'exploitation Linux.

Il est développé pour :

* rester compatible avec les anciens scripts d'initialisation SysV,
* fournissent de nombreuses fonctionnalités, telles que le lancement en parallèle des services système au démarrage, l'activation à la demande des démons, le support des snapshots, ou la gestion des dépendances entre les services.

!!! note "Remarque"

    Le service systemd est la procédure d'initialisation du système par défaut depuis la version 7 de RedHat/CentOS 7.

La suite logicielle systemd introduit le concept d'unités système (systemd units).

| Type             | Extension de fichier | Observation                                                 |
| ---------------- | -------------------- | ----------------------------------------------------------- |
| Unité de service | `.service`           | Service système                                             |
| Target unit      | `.target`            | Un groupe d'unités système                                  |
| Monter l'unité   | `.automount`         | Un point de montage automatique pour le système de fichiers |

!!! note "Remarque"

    Il existe de nombreuses unités dans le cadre de systemd : Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* Systemd prend en charge les sauvegardes d'état du système et la restauration.

* Les points de montage peuvent être configurés en tant que cibles pour systemd.

* Au démarrage, systemd crée des sockets d'écoute pour tous les services système qui supportent ce type d'activation et transmet ces sockets à ces services dès qu'ils sont démarrés. Cela permet de redémarrer un service sans perdre un seul message envoyé par le réseau pendant son indisponibilité. Le socket correspondant reste accessible et tous les messages sont mis en attente.

* Les services du système qui utilisent D-BUS pour leurs communications inter-processus peuvent être lancés à la demande dès la première fois qu'ils sont utilisés par un client.

* Le système arrête ou redémarre uniquement les services en cours d'exécution. Les versions précédentes (avant RHEL7) tentaient d'arrêter les services directement sans vérifier leur état actuel.

* Les services système n'héritent d'aucun contexte (comme les variables d'environnement HOME et PATH). Chaque service fonctionne dans son propre contexte d'exécution.

Toutes les opérations des unités de service sont soumises à un délai de 5 minutes par défaut pour éviter qu'un service défectueux ne bloque le système.

### Gestion des services du système

Les unités de service se terminent par l'extension de fichier `.service` et ont un but similaire à celui des scripts init. La commande `systemctl` est utilisée pour `afficher`, `start`, `stop`, `redémarrez` un service système :

| systemctl                                 | Observation                                                   |
| ----------------------------------------- | ------------------------------------------------------------- |
| systemctl start *name*.service            | Lance un service                                              |
| systemctl stop *name*.service             | Arrête un service                                             |
| systemctl restart *name*.service          | Redémarre un service                                          |
| systemctl reload *name*.service           | Recharge une configuration                                    |
| systemctl status *name*.service           | Vérifie si un service est en cours d'exécution                |
| systemctl try-restart *name*.service      | Redémarre un service uniquement s'il est en cours d'exécution |
| systemctl list-units --type service --all | Affiche l'état de tous les services                           |

La commande `systemctl` est également utilisée pour `activer` ou `désactiver` un service et afficher les services associés :

| systemctl                                | Observation                                                        |
| ---------------------------------------- | ------------------------------------------------------------------ |
| systemctl enable *name*.service          | Activer un service                                                 |
| systemctl disable *name*.service         | Désactiver un service                                              |
| systemctl list-unit-files --type service | Liste tous les services et vérifie s'ils sont en cours d'exécution |
| systemctl list-dependencies --after      | Liste les services qui commencent avant l'unité spécifiée          |
| systemctl list-dependencies --before     | Liste les services qui commencent après l'unité spécifiée          |

Exemples :

```bash
systemctl stop nfs-server.service
# ou bien
systemctl stop nfs-server
```

Pour lister toutes les unités actuellement chargées :

```bash
systemctl list-units --type service
```

Pour lister toutes les unités à vérifier si elles sont activées :

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Exemple d'un fichier .service pour le service postfix

```bash
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### Utilisation des cibles du système

Sur Rocky8/RHEL8, le concept de niveaux d'exécution a été remplacé par des cibles systemd.

Les cibles systemd sont représentées par les unités cibles. Les unités cibles se terminent par l' extension `.target` et leur seul but est de regrouper d'autres unités systemd dans une chaîne de dépendances.

Par exemple, l'unité `graphical.target` qui est utilisée pour démarrer une session graphique, démarre les services système tels que le **gestionnaire d'affichage GNOME** (`gdm.service`) ou le service de comptes **** (`accounts-daemon.service`) et active également l'unité `multi-utilisateur.target`.

De même, l'unité `multi-user.target` démarre d'autres services système essentiels, tels que **NetworkManager** (`NetworkManager. ervice`) ou **D-Bus** (`dbus.service`) et active une autre unité cible nommée `basic.target`.

| Target Units      | Observation                                                      |
| ----------------- | ---------------------------------------------------------------- |
| poweroff.target   | Arrête le système et le désactive                                |
| rescue.target     | Active un shell de secours                                       |
| multi-user.target | Active un système multi-utilisateur sans interface graphique     |
| graphical.target  | Active un système multi-utilisateur avec une interface graphique |
| reboot.target     | Arrête et redémarre le système                                   |

#### L'unité cible par défaut

Pour déterminer quelle est la cible utilisée par défaut :

```bash
systemctl get-default
```

Cette commande recherche la cible du lien symbolique situé dans `/etc/systemd/system/default.target` et affiche le résultat.

```bash
$ systemctl get-default
graphical.target
```

La commande `systemctl` peut également fournir une liste de cibles disponibles :

```bash
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

Pour configurer le système pour qu'il utilise une cible par défaut différente :

```bash
systemctl set-default name.target
```

Exemple :

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

Pour passer à une autre unité cible de la session courante :

```bash
systemctl isolate name.target
```

Le mode sauvetage **Rescue Mode** fournit un environnement simple pour réparer votre système dans les cas où il est impossible d'effectuer un processus de démarrage normal.

En `mode de sauvetage`, le système tente de monter tous les systèmes de fichiers locaux et de démarrer plusieurs services système importants, mais n'active pas d'interface réseau et ne permet pas à d'autres utilisateurs de se connecter au système en même temps.

Sur Rocky 8, le `mode de secours` est équivalent à l'ancien `mode utilisateur unique` et nécessite le mot de passe root.

Pour changer la cible actuelle et entrer dans le mode de secours `Rescue Mode` dans la session en cours :

```bash
systemctl rescue
```

**Le mode d'urgence** fournit l'environnement le plus minimaliste possible et permet de réparer le système même dans des situations où le système est incapable de passer en mode sauvetage. En mode d'urgence, le système monte le système de fichiers root uniquement pour la lecture. Il n'essayera pas de monter un autre système de fichiers local, n'activera aucune interface réseau et démarrera certains services essentiels.

Pour modifier la cible actuelle et passer en mode d'urgence dans la session en cours :

```bash
systemctl emergency
```

#### Fermeture, suspension et hibernation

La commande `systemctl` remplace un certain nombre de commandes de gestion d'énergie utilisées dans les versions précédentes :

| Ancienne commande   | Nouvelle commande        | Observation                                        |
| ------------------- | ------------------------ | -------------------------------------------------- |
| `halt`              | `systemctl halt`         | Arrête le système.                                 |
| `poweroff`          | `systemctl poweroff`     | Éteint le système.                                 |
| `reboot`            | `systemctl reboot`       | Redémarre le système.                              |
| `pm-suspend`        | `systemctl suspend`      | Suspend le système.                                |
| `pm-hibernate`      | `systemctl hibernate`    | Mise en veille prolongée du système.               |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | Mise en veille prolongée et interrompt le système. |

### Le processus `journald`

Les fichiers journaux peuvent, en plus de `rsyslogd`, être également gérés par le démon `journald` qui est un composant de `systemd`.

Le démon `journald` capture les messages du Syslog, les messages du noyau, les messages de la mémoire vive initiale et depuis le début du démarrage, ainsi que les messages écrits vers la sortie standard et la sortie d'erreur standard de tous les services, puis les indexe et les met à la disposition de l'utilisateur.

Le format du fichier journal natif, qui est un fichier binaire structuré et indexé, améliore les recherches et permet une execution plus rapide, il stocke également les informations de métadonnées, telles que les horodatages ou les identifiants d'utilisateur.

### La commande `journalctl`

La commande `journalctl` affiche les fichiers journaux.

```bash
journalctl
```

La commande liste tous les fichiers journaux générés sur le système. La structure de cette sortie est similaire à celle utilisée dans `/var/log/messages/` mais elle offre quelques améliorations :

* la priorité des entrées est mise en valeur visuellement ;
* les horodatages sont convertis dans le fuseau horaire local de votre système ;
* toutes les données enregistrées sont affichées, y compris les logs rotatifs ;
* le début d'un lancement est marqué par une ligne spéciale.

#### Utilisation de l'affichage continu

Avec un affichage continu, les messages de log sont affichés en temps réel.

```bash
journalctl -f
```

Cette commande retourne une liste des dix lignes de log les plus récentes. L'utilitaire journalctl continue alors à s'exécuter et attend que de nouveaux changements se produisent avant de les afficher immédiatement.

#### Filtrage des messages

Il est possible d'utiliser différentes méthodes de filtrage pour extraire des informations qui répondent à différents besoins. Les messages de log sont souvent utilisés pour suivre les comportements erronés dans le système. Voir les entrées avec une priorité sélectionnée ou supérieure :

```bash
journalctl -p priority
```

Vous devez remplacer priority par un des mots-clés suivants (ou un nombre) :

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* emerg (0).
