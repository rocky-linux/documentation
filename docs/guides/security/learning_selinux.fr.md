---
title: Module de Sécurité SELinux
author: Antoine Le Morvan
contributors: Steven Spencer, markooff, Ganna Zhyrnova
tags:
  - sécurité
  - SELinux
---

# Module de Sécurité SELinux

Avec l'arrivée de la version 2.6 du noyau, un nouveau système de sécurité a été introduit pour fournir un mécanisme permettant de prendre en charge les politiques de contrôle d'accès.

Ce système appelé **SELinux** (**S**ecurity **E**nhanced **Linux**) a été créé par la **NSA** (**N**ational **S**ecurity **A**gency) en implementant une architecture robuste **M**andatory **A**ccess **C**ontrol (**MAC**) dans les sous-systèmes du noyau Linux.

Si, tout au long de votre carrière, vous avez désactivé ou ignoré SELinux, ce document sera une bonne introduction à ce système. SELinux permet de limiter les privilèges ou de supprimer les risques associés à la compromission d'un programme ou d'un démon.

Avant de commencer, vous devez savoir que SELinux est principalement destiné aux distributions basée sur RHEL, bien qu'il soit possible de l'implémenter sur d'autres distributions comme Debian (mais bonne chance !). Les distributions de la famille Debian intègrent généralement le système AppArmor qui fonctionne différemment de SELinux.

## Généralités

**SELinux** (Security Enhanced Linux) est un système de contrôle d'accès obligatoire.

Avant l'apparition des systèmes MAC, la sécurité standard de la gestion des accès était basée sur les systèmes **DAC** (**D**iscretionary **A**ccess **C**ontrol). Une application, ou un démon, opéré avec les droits **UID** ou **SUID** (**S**et **O**wner **U**ser **I**d) qui ont rendu possible l'évaluation des permissions (sur les fichiers, les sockets et d'autres processus...) selon cet utilisateur. Cette opération ne limite pas suffisamment les droits d'un programme corrompu, ce qui lui permet potentiellement d'accéder aux sous-systèmes du système d'exploitation.

Un système MAC renforce la séparation de la confidentialité et de l'information d'intégrité dans le système afin de parvenir à un système d'endiguement. Le système de confinement est indépendant du système de droits traditionnel et il n'y a pas de notion de super-utilisateur.

Lors de chaque appel système, le noyau interroge SELinux pour vérifier s'il permet d'effectuer l'action.

![SELinux](../images/selinux_001.png)

SELinux utilise un ensemble de règles (polices) pour cela. Un ensemble de deux ensembles de règles standards (**ciblé** et **strict**) est fourni et chaque application fournit généralement ses propres règles.

### Le contexte SELinux

Le fonctionnement de SELinux est totalement différent des droits Unix traditionnels.

Le contexte de sécurité de SELinux est défini par le trio **identity**+**role**+**domain**.

L'identité d'un utilisateur dépend directement de son compte Linux. Une identité est assignée à un ou plusieurs rôles, mais à chaque rôle correspond un domaine, et à un seul.

C'est en fonction du domaine du contexte de sécurité (et donc du rôle) que les droits d'un utilisateur sur une ressource sont évalués.

![Contexte SELinux](../images/selinux_002.png)

Les termes "domaine" et "type" sont similaires. Généralement "domain" est utilisé lorsque l'on fait référence à un processus, alors que "type" fait référence à un objet.

La convention de nommage est la suivante : **user_u:role_r:type_t**.

Le contexte de sécurité est assigné à un utilisateur au moment de sa connexion, selon ses rôles. Le contexte de sécurité d'un fichier est défini par la commande `chcon` (**ch**ange **con**text) que nous verrons plus loin dans ce document.

Considérez les pièces suivantes du puzzle SELinux :

- Les sujets
- Les objets
- Les politiques
- Le mode

Lorsqu'un sujet (par exemple une application) tente d'accéder à un objet (un fichier par exemple), la partie SELinux du noyau Linux interroge sa base de données de règles. En fonction du mode d'opération, SELinux autorise l'accès à l'objet en cas de succès, sinon il enregistre l'échec dans le fichier `/var/log/messages`.

#### Le contexte SELinux des processus standards

Les droits d'un processus dépendent de son contexte de sécurité.

Par défaut, le contexte de sécurité du processus est défini par le contexte de l'utilisateur (identité + rôle + domaine) qui le lance.

Un domaine SELinux (domain) désigne un type spécial lié à un processus, type hérité (normalement) de l'utilisateur qui l'a lancé. Les droits s'expriment en termes d'autorisation ou de refus sur des types liés aux objets :

Un processus dont le contexte a un **domaine de sécurité D** peut accéder à des objets de **type T**.

![Le contexte SELinux des processus standards](../images/selinux_003.png)

#### Le contexte SELinux des processus importants

Les programmes les plus importants sont assignés à un domaine dédié.

Chaque exécutable est marqué avec un type dédié (ici **sshd_exec_t**) qui bascule automatiquement le processus associé au contexte **sshd_t** (au lieu de **user_t**).

Ce mécanisme est essentiel car il restreint autant que possible les droits d'un processus.

![Le contexte SELinux d'un processus important - exemple de sshd](../images/selinux_004.png)

## Gestion

La commande `semanage` est utilisée pour gérer les règles SELinux.

```bash
semanage [object_type] [options]
```

Exemple :

```bash
semanage boolean -l
```

| Options | Observations      |
| ------- | ----------------- |
| -a      | Ajoute un objet   |
| -d      | Supprime un objet |
| -m      | Modifie un objet  |
| -l      | Liste les objets  |

La commande `semanage` peut ne pas être installée par défaut sous Rocky Linux.

Sans connaître le paquet qui fournit cette commande, vous devriez rechercher son nom avec la commande suivante :

```bash
dnf provides */semanage
```

puis installez :

```bash
sudo dnf install policycoreutils-python-utils
```

### Administration des objets booléens

Les objets booléens permettent de contenir les processus.

```bash
semanage boolean [options]
```

Pour lister les Booleans disponibles :

```bash
semanage boolean –l
SELinux boolean    State Default  Description
…
httpd_can_sendmail (off , off) Autoriser httpd à envoyer du courrier
…
```

!!! note "Remarque"

    Comme vous pouvez le constater, il y a un état `default` (par exemple au démarrage) et un état en cours d'exécution.

La commande `setsebool` est utilisée pour modifier l'état d'un objet booléen :

```bash
setsebool [-PV] boolean on|off
```

Exemple :

```bash
sudo setsebool -P httpd_can_sendmail on
```

| Options | Observations                                                                     |
| ------- | -------------------------------------------------------------------------------- |
| `-P`    | Modifie la valeur par défaut au démarrage (sinon seulement jusqu'au redémarrage) |
| `-V`    | Supprime un objet                                                                |

!!! warning "Avertissement"

    N'oubliez pas l'option `-P` pour conserver l'état après le prochain démarrage.

### Administration des objets Port

La commande `semanage` est utilisée pour gérer les objets de type port :

```bash
semanage port [options]
```

Exemple : autoriser le port 81 pour les processus du domaine httpd

```bash
sudo semanage port -a -t http_port_t -p tcp 81
```

## Modes de fonctionnement

SELinux possède trois modes de fonctionnement :

- Renforcé

Mode par défaut pour Rocky Linux. L'accès sera restreint selon les règles en vigueur.

- Permissif

Les règles sont verifiées, les erreurs d'accès sont enregistrées dans le log, mais l'accès ne sera pas bloqué.

- Désactivé

Rien ne sera restreint, rien ne sera enregistré.

Par défaut, la plupart des systèmes d'exploitation sont configurés avec SELinux en mode Enforcing.

La commande `getenforce` retourne le mode de fonctionnement actuel

```bash
getenforce
```

Exemple :

```bash
$ getenforce
Enforcing
```

La commande `sestatus` retourne des informations sur SELinux

```bash
sestatus
```

Exemple :

```bash
$ sestatus
SELinux status:       enabled
SELinuxfs mount:     /sys/fs/selinux
SELinux root directory:    /etc/selinux
Loaded policy name:        targeted
Current mode:             enforcing
Mode from config file:     enforcing
...
Version maximale de la politique du noyau : 33
```

La commande `setenforce` modifie le mode de fonctionnement actuel :

```bash
setenforce 0|1
```

Faire passer SELinux au mode permissif :

```bash
sudo setenforce 0
```

### Le fichier `/etc/sysconfig/selinux`

Le fichier `/etc/sysconfig/selinux` vous permet de changer le mode de fonctionnement de SELinux.

!!! warning "Avertissement"

    La désactivation de SELinux se fait à vos propres risques et périls ! Il est préférable d'apprendre comment fonctionne SELinux plutôt que de le désactiver de manière systématique !

Modifier le fichier `/etc/sysconfig/selinux`

```bash
SELINUX=disabled
```

!!! note "Remarque"

    `/etc/sysconfig/selinux` est un lien symbolique vers `/etc/selinux/config`

Redémarrez le système :

```bash
sudo reboot
```

!!! warning "Avertissement"

    Méfiez-vous du changement de mode SELinux !

En mode permissif ou désactivé, les fichiers nouvellement créés n'auront aucune étiquette.

Pour réactiver SELinux, vous devrez repositionner les étiquettes sur l'ensemble de votre système.

Étiquetage de l'ensemble du système :

```bash
sudo touch /.autorelabel
sudo reboot
```

## Le type de règles

SELinux fournit deux types de règles standard :

- **Targeted** : seuls les démons de réseau sont protégés (`dhcpd`, `httpd`, `named`, `nscd`, `ntpd`, `portmap`, `snmpd`, `squid` et `syslogd`)
- **Strict** : tous les démons sont protégés

## Contexte

L'affichage des contextes de sécurité s'effectue avec l'option `-Z`. L'option est associée à de nombreuses commandes :

Exemples :

```bash
id -Z # le contexte de l'utilisateur
ls -Z # celui des fichiers actuels
ps -eZ # celui des processus
netstat –Z # pour les connexions réseau
lsof -Z # pour les fichiers ouverts
```

La commande `matchpathcon` renvoie le contexte d'un répertoire.

```bash
matchpathcon directory
```

Exemple :

```bash
sudo matchpathcon /root
 /root system_u:object_r:admin_home_t:s0

sudo matchpathcon /
 /      system_u:object_r:root_t:s0
```

La commande `chcon` modifie un contexte de sécurité :

```bash
chcon [-vR] [-u USER] [–r ROLE] [-t TYPE] file
```

Exemple :

```bash
sudo chcon -vR -t httpd_sys_content_t /data/websites/
```

| Options        | Observations                                    |
| -------------- | ----------------------------------------------- |
| `-v`           | Passer en mode détaillé                         |
| `-R`           | Applique la récursion                           |
| `-u`,`-r`,`-t` | S'applique à un utilisateur, un rôle ou un type |

La commande `restorecon` restaure le contexte de sécurité par défaut (celle fournie par les règles) :

```bash
restorecon [-vR] directory
```

Exemple :

```bash
sudo restorecon -vR /home/
```

| Options | Observations            |
| ------- | ----------------------- |
| `-v`    | Passer en mode détaillé |
| `-R`    | Appliquer la récursion  |

Pour faire un changement de contexte qui tient compte de `restorecon`, vous devez modifier les contextes de fichier par défaut avec la commande `semanage fcontext` :

```bash
semanage fcontext -a options file
```

!!! note "Remarque"

    Si vous effectuez un changement de contexte pour un dossier qui n'est pas standard pour le système, créer la règle et ensuite appliquer le contexte est une bonne pratique, comme dans l'exemple ci-dessous !

Exemple :

```bash
sudo semanage fcontext -a -t httpd_sys_content_t "/data/websites(/.*)?"
sudo restorecon -vR /data/websites/
```

## La commande `audit2why`

La commande `audit2why` indique la cause d'un rejet de SELinux :

```bash
audit2why [-vw]
```

Exemple pour obtenir la cause du dernier rejet par SELinux :

```bash
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2why
```

| Options | Observations                                                                                           |
| ------- | ------------------------------------------------------------------------------------------------------ |
| `-v`    | Passer en mode détaillé                                                                                |
| `-w`    | Interprète la cause d'un rejet par SELinux et propose une solution pour y remédier (option par défaut) |

### Approfondir avec SELinux

La commande `audit2allow` crée un module pour permettre une action SELinux (quand aucun module n'existe) à partir d'une ligne dans un fichier "audit" :

```bash
audit2allow [-mM]
```

Exemple :

```bash
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2allow -M mylocalmodule
```

| Options | Observations                                        |
| ------- | --------------------------------------------------- |
| `-m`    | Créez simplement le module (`*.te`)                 |
| `-M`    | Créez le module, compilez et empaquetez-le (`*.pp`) |

#### Exemple de configuration

Après l'exécution d'une commande, le système vous renvoie à l'invite de commande mais le résultat attendu n'est pas visible : aucun message d'erreur à l'écran.

- **Étape 1**: Lisez le fichier log sachant que le message qui nous intéresse est de type AVC (SELinux), refusé (refusé) et le plus récent (donc le dernier).

```bash
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1
```

Le message est correctement isolé, mais il ne nous est d'aucune utilité.

- **Étape 2**: Lisez le message isolé avec la commande `audit2why` pour obtenir un message plus explicite qui pourrait contenir la solution à notre problème (généralement un booléen à définir).

```bash
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2why
```

Il y a deux cas : soit nous pouvons placer un contexte ou remplir un booléen, soit nous allons à l'étape 3 pour créer notre propre contexte.

- **Étape 3**: Créez votre propre module.

```bash
$ sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2allow -M mylocalmodule
Generating type enforcement: mylocalmodule.te
Compiling policy: checkmodule -M -m -o mylocalmodule.mod mylocalmodule.te
Building package: semodule_package -o mylocalmodule.pp -m mylocalmodule.mod

$ sudo semodule -i mylocalmodule.pp
```
