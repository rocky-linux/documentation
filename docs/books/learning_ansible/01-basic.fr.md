---
title: Les bases d'Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Aditya Putta, Ganna Zhyrnova
update: 15-Déc-2021
---

# Les bases d'Ansible

Dans ce chapitre, vous apprendrez à travailler avec Ansible.

****

**Objectifs** : Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: Mettre en place Ansible ;  
:heavy_check_mark: Appliquer des changements de configuration à des serveurs ;  
:heavy_check_mark: Créer vos premiers playbooks Ansible;

:checkered_flag: **ansible**, **module**, **playbook**

**Connaissances** : :star: :star: :star:  
**Complexité** : :star: :star:

**Temps de lecture**: 30 minutes

****

Ansible centralise et automatise les tâches d'administration. C'est un outil :

* **sans agent** (il ne nécessite pas de déploiement spécifique sur les clients),
* **idempotent** (même effet à chaque fois qu'il est exécuté).

Il utilise le protocole **SSH** pour configurer à distance les clients Linux ou le protocole **WinRM** pour travailler avec les clients Windows. Si aucun de ces protocoles n'est disponible, il est toujours possible pour Ansible d'utiliser une API, ce qui fait d'Ansible un véritable couteau suisse pour la configuration de serveurs, de postes de travail, de services Docker, d'équipements réseau, etc. (presque tout en fait).

!!! warning "Avertissement"

    L'ouverture des flux SSH ou WinRM à tous les clients depuis le serveur Ansible en fait un élément critique de l'architecture qui doit être surveillé de près.

Ansible étant principalement basé sur le push, il ne conservera pas l'état des serveurs ciblés entre chacune de ses exécutions. Au contraire, il effectuera de nouveaux contrôles d'état à chaque fois qu'il sera exécuté. Il est donc considéré stateless.

Il vous sera utile pour :

* le provisionnement (déploiement d'une nouvelle VM),
* les déploiements d'applications,
* la gestion de la configuration,
* l'automatisation,
* l'orchestration (lorsque plus d'une cible est utilisée).

!!! note "Remarque"

    Ansible a été écrit à l'origine par Michael DeHaan, le fondateur d'autres outils tels que Cobbler.
    
    ![Michael DeHaan](images/Michael_DeHaan01.jpg)
    
    La première version la plus ancienne est la 0.0.1, publiée le 9 mars 2012.
    
    Le 17 octobre 2015, AnsibleWorks (la société à l'origine d'Ansible) a été rachetée par Red Hat pour 150 millions de dollars.

![Les fonctionnalités d'Ansible](images/ansible-001.png)

Pour offrir une interface graphique à votre utilisation quotidienne d'Ansible, vous pouvez installer des outils comme Ansible Tower (RedHat), qui n'est pas gratuit ou son homologue opensource Awx, d'autres projets comme Jenkins et l'excellent Rundeck peuvent également être utilisés.

!!! abstract "Abstract"

    Pour suivre cette formation, vous aurez besoin d'au moins 2 serveurs sous Rocky :

    * la première sera la **machine de gestion**, Ansible y sera installé.
    * le second sera le serveur à configurer et à gérer (un autre Linux que Rocky Linux fera tout aussi bien l'affaire).

    Dans les exemples ci-dessous, la station d'administration a l'adresse IP 172.16.1.10, la station gérée l’adresse IP 172.16.1.11. Il vous appartient d'adapter les exemples en fonction de votre plan d'adressage IP.

## Le vocabulaire Ansible

* La **machine de gestion** : la machine sur laquelle Ansible est installé. Ansible étant **sans agent**, aucun logiciel n'est déployé sur les serveurs gérés.
* Les **managed nodes** : les machines cibles gérées par Ansible sont aussi appelées "hôtes". Il peut s'agir de serveurs, composants du réseau ou n'importe quel autre ordinateur.
* L'**inventaire**: un fichier contenant des informations sur les serveurs gérés.
* Les **tâches** : une tâche est un bloc définissant une procédure à exécuter (par exemple, créer un utilisateur ou un groupe, installer un logiciel, etc.).
* Un **module** : un module représente une tâche. De nombreux modules sont fournis avec Ansible.
* Les **playbooks** : un simple fichier au format yaml définissant les serveurs cibles et les tâches à effectuer.
* Un **rôle** : un rôle permet d'organiser les playbooks et tous les autres fichiers nécessaires (modèles, scripts, etc.) pour faciliter le partage et la réutilisation du code.
* Une **collection** : une collection comprend un ensemble logique de playbooks, de rôles, de modules et de plugins.
* Les **faits (facts)** : il s'agit de variables globales contenant des informations sur le système (nom de la machine, version du système, interface et configuration du réseau, etc.)
* Les **handlers** : ils sont utilisés pour faire en sorte qu'un service soit arrêté ou redémarré en cas de modification.

## Installation sur le serveur de gestion

Ansible est disponible dans le dépôt _EPEL_, mais peut parfois être trop ancien pour la version actuelle, et vous voudrez travailler avec une version plus récente.

Nous allons donc considérer deux types d'installation :

* Celle basée sur les dépôts EPEL
* Celle basée sur le gestionnaire de paquets python, `pip`

L'_EPEL_ est nécessaire pour les deux versions, vous pouvez donc l'installer dès maintenant :

* Installation du dépôt EPEL :

```bash
sudo dnf install epel-release
```

### Installation depuis le dépôt EPEL

Si nous installons Ansible à partir de _EPEL_, nous pouvons faire ce qui suit :

```bash
sudo dnf install ansible
```

Puis vérifiez l'installation :

```bash
$ ansible --version
ansible [core 2.14.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.11/site-packages/ansible  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.11.2 (main, Jun 22 2023, 04:35:24) [GCC 8.5.0 20210514 
(Red Hat 8.5.0-18)] (/usr/bin/python3.11)
  jinja version = 3.1.2
  libyaml = True

$ python3 --version
Python 3.6.8
```

Veuillez noter qu’Ansible est livré avec sa propre version de python, différente de la version système de python (ici 3.11.2 vs 3.6.8). Vous devrez en tenir compte lors de l'installation par pip des modules python nécessaires à votre installation (par exemple `pip3.11 install PyVMomi`).

### Installation à partir de python pip

Comme nous voulons utiliser une version plus récente d'Ansible, nous l'installerons à partir de `python3-pip` :

!!! note "Remarque"

    Supprimez Ansible si vous l'avez installé précédemment depuis _EPEL_.

A ce stade, nous pouvons choisir d'installer ansible avec la version de python que nous souhaitons.

```bash
sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! note "Remarque"

    `python3-argcomplete` est fourni par _EPEL_. Veuillez installer epel-release si ce n'est pas encore fait.
    Ce paquetage vous aidera à compléter les commandes Ansible.

Nous pouvons maintenant installer Ansible :

```bash
pip3.8 install --user ansible
activate-global-python-argcomplete --user
```

Vérifiez votre version d'Ansible :

```bash
$ ansible --version
ansible [core 2.13.11]
  config file = None
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/rocky/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/rocky/.local/bin/ansible
  python version = 3.8.16 (default, Jun 25 2023, 05:53:51) [GCC 8.5.0 20210514 (Red Hat 8.5.0-18)]
  jinja version = 3.1.2
  libyaml = True
```

!!! note "Remarque"

    Dans notre cas, la version installée manuellement est plus ancienne que la version empaquetée par RPM parce que nous avons utilisé une version plus ancienne de Python. Cette observation variera avec le temps, l'âge de la distribution et la version de python bien sûr.

## Fichiers de configuration

La configuration du serveur se trouve sous `/etc/ansible`.

Il existe deux fichiers de configuration principaux :

* Le fichier de configuration principal `ansible.cfg` où se trouvent les commandes, les modules, les plugins et la configuration ssh ;
* Le fichier d'inventaire des machines clientes `hosts` où les clients et les groupes de clients sont indiqués.

Le fichier de configuration sera automatiquement créé si Ansible est installé avec son paquetage RPM. Dans le cas d'une installation via `pip`, ce fichier n'existe pas. Nous allons devoir le créer à la main grâce à la commande `ansible-config` :

```bash
$ ansible-config -h
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

Visualiser la configuration d'Ansible.

arguments positionnels :
  {list,dump,view,init}
    list Lister toutes les options de configuration
    dump Afficher la configuration
    view Afficher le fichier de configuration
    init Créer la configuration initiale
```

Exemple :

```bash
ansible-config init --disabled &gt ; /etc/ansible/ansible.cfg
```

L'option `--disabled` permet de commenter l'ensemble des options en les faisant précéder d'un point-virgule `;`.

!!! note "Remarque"

    Vous pouvez également choisir d'intégrer la configuration ansible dans votre référentiel de code, Ansible chargeant les fichiers de configuration qu'il trouve dans l'ordre suivant (en traitant le premier fichier qu'il rencontre et en ignorant les autres) :

    * si la variable d'environnement `$ANSIBLE_CONFIG` est définie, ouvrez le fichier spécifié.
    * `ansible.cfg` s'il existe dans le répertoire courant.
    * `~/.ansible.cfg` s'il existe (dans le répertoire personnel de l'utilisateur).

    Le fichier par défaut est chargé si aucun de ces trois fichiers n'est trouvé.

### Le fichier d'inventaire `/etc/ansible/hosts`

Comme Ansible devra travailler avec tous vos équipements à configurer, il est essentiel de lui fournir un (ou plusieurs) fichier(s) d'inventaire bien structuré(s) qui corresponde(nt) parfaitement à votre projet.

Il est parfois nécessaire de bien réfléchir à la manière de construire ce fichier.

Allez dans le fichier d'inventaire par défaut, qui se trouve sous `/etc/ansible/hosts`. Quelques exemples sont fournis et commentés :

```text
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group:

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern, you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com
```

Comme vous pouvez le constater, le fichier fourni à titre d'exemple utilise le format INI, bien connu des administrateurs système. Notez que vous pouvez choisir un autre format de fichier (comme yaml par exemple), mais pour les premiers tests, le format INI est bien adapté à nos futurs exemples.

L'inventaire peut être généré automatiquement en production, surtout si vous disposez d'un environnement de virtualisation comme VMware VSphere ou d'un environnement cloud (Aws, OpenStack, ou autre).

* Création d'un groupe d'hôtes dans `/etc/ansible/hosts` :

Comme vous l'avez peut-être remarqué, les groupes sont déclarés entre crochets. Viennent ensuite les éléments appartenant aux groupes. Vous pouvez créer, par exemple, un groupe `rocky8` en insérant le bloc suivant dans ce fichier :

```bash
[rocky8]
172.16.1.10
172.16.1.11
```

Les groupes peuvent être utilisés à l'intérieur d'autres groupes. Dans ce cas, il faut préciser que le groupe parent est composé de sous-groupes avec l'attribut `:children` comme ceci :

```bash
[linux:children]
rocky8
debian9

[ansible:children]
ansible_management
ansible_clients

[ansible_management]
172.16.1.10

[ansible_clients]
172.16.1.10
```

Nous n'en dirons pas plus sur l'inventaire, mais si vous êtes intéressé, vous pouvez consulter [ce lien](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Maintenant que notre serveur de gestion est installé et que notre inventaire est prêt, il est temps de lancer nos premières commandes `ansible`.

## utilisation de la ligne de commande `ansible`

La commande `ansible` lance une tâche sur un ou plusieurs hôtes cibles.

```bash
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Exemples :

!!! warning "Avertissement"

    Comme nous n'avons pas encore configuré l'authentification sur nos deux serveurs de test, pas tous les exemples suivants ne fonctionneront. Ils sont donnés à titre d'exemple pour faciliter la compréhension et seront entièrement fonctionnels plus loin dans ce chapitre.

* Liste les hôtes appartenant au groupe rocky8 :

```bash
ansible rocky8 --list-hosts
```

* Effectuer un test de connectivité auprès d'un groupe d'hôtes à l'aide du module `ping`:

```bash
ansible rocky8 -m ping
```

* Afficher les faits d'un groupe d'hôtes avec le module `setup` :

```bash
ansible rocky8 -m setup
```

* Exécuter une commande sur un groupe d'hôtes en invoquant le module `command` avec des arguments :

```bash
ansible rocky8 -m command -a 'uptime'
```

* Exécutez une commande avec les privilèges de l'administrateur root :

```bash
ansible ansible_clients --become -m command -a 'reboot'
```

* Exécuter une commande à l'aide d'un fichier d'inventaire personnalisé :

```bash
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! note "Remarque"

    Comme dans cet exemple, il est parfois plus simple de séparer la déclaration des périphériques gérés en plusieurs fichiers (par projet cloud par exemple) et de fournir à Ansible le chemin vers ces fichiers, plutôt que de maintenir un long fichier d'inventaire.

| Option                   | Information                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `-a 'arguments'`         | Les arguments à transmettre au module.                                                                     |
| `-b -K`                  | Demande un mot de passe et exécute la commande avec des privilèges plus élevés.                            |
| `--user=username`        | Utilise cet utilisateur pour se connecter à l'hôte cible à la place de l'utilisateur actuel.               |
| `--become-user=username` | Exécute l'opération en tant qu'utilisateur (par défaut : `root`).                                          |
| `-C`                     | Simulation. N'apporte aucune modification à la cible, mais la teste pour voir ce qui devrait être modifié. |
| `-m module`              | Exécute le module appelé                                                                                   |

### Préparation du client

Sur la machine de gestion et les clients, nous allons créer un utilisateur `ansible` dédié aux opérations effectuées par Ansible. Cet utilisateur devra utiliser les droits sudo, il devra donc être ajouté au groupe `wheel`.

Cet utilisateur sera utilisé :

* Du côté de la station d'administration : pour exécuter des commandes `ansible` et SSH vers les clients gérés.
* Sur les stations administrées (ici le serveur qui vous sert de station d'administration sert aussi de client, il est donc administré par lui-même) pour exécuter les commandes lancées depuis la station d'administration : il doit donc avoir les droits sudo.

Sur les deux machines, créez un utilisateur `ansible`, dédié à Ansible :

```bash
sudo useradd ansible
sudo usermod -aG wheel ansible
```

Définir un mot de passe pour cet utilisateur :

```bash
sudo passwd ansible
```

Modifier la configuration de sudoers pour permettre aux membres du groupe `wheel` de faire du sudo sans mot de passe :

```bash
sudo visudo
```

Notre but ici est de commenter la valeur par défaut et de décommenter l'option NOPASSWD afin que ces lignes ressemblent à ceci lorsque nous aurons terminé :

```bash
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! warning "Avertissement"

    Si vous recevez le message d'erreur suivant lorsque vous entrez des commandes Ansible, cela signifie probablement que vous avez oublié cette étape sur l'un de vos clients :
    `"msg" : "Missing sudo password`

À partir de maintenant, lorsque vous utilisez le serveur de gestion, utilisez ce nouvel utilisateur :

```bash
sudo su - ansible
```

### Test avec le module ping

Par défaut, la connexion par mot de passe n'est pas autorisée par Ansible.

Décommentez la ligne suivante de la section `[defaults]` du fichier de configuration `/etc/ansible/ansible.cfg` et mettez-la à « True » :

```bash
ask_pass      = True
```

Lancez un `ping` sur chaque serveur du groupe rocky8 :

```bash
# ansible rocky8 -m ping
SSH password:
172.16.1.10 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.16.1.11 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

!!! note "Remarque"

    On vous demande le mot de passe `ansible` des serveurs distants, ce qui constitue un problème de sécurité...

!!! tip "Astuce"

    Si vous obtenez cette erreur `"msg" : "to use the 'ssh' connection type with passwords, you must install the sshpass program"`, vous pouvez simplement installer `sshpass` sur la station de gestion :

    ```
    sudo dnf install sshpass
    ```

!!! abstract "Abstract"

    Vous pouvez maintenant tester les commandes qui n'ont pas fonctionné précédemment dans ce chapitre.

## Clé d'authentification

L'authentification par mot de passe sera remplacée par une authentification par clé privée/publique beaucoup plus sûre.

### Création d'une clé SSH

La double clé sera générée avec la commande `ssh-keygen` sur la station de gestion par l'utilisateur `ansible` :

```bash
[ansible]$ ssh-keygen
Generating public/private rsa key pair.
Saisissez le fichier dans lequel vous souhaitez enregistrer la clé (/home/ansible/.ssh/id_rsa) :
Saisir la phrase de passe (vide si aucune phrase de passe n'a été saisie) :
Saisissez à nouveau la même phrase de passe :
Votre identification a été sauvegardée dans /home/ansible/.ssh/id_rsa.
Votre clé publique a été enregistrée dans /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Oa1d2hYzzdO0e/K10XPad25TA1nrSVRPIuS4fnmKr9g ansible@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|           .o . +|
|           o . =.|
|          . . + +|
|         o . = =.|
|        S o = B.o|
|         = + = =+|
|        . + = o+B|
|         o + o *@|
|        . Eoo .+B|
+----[SHA256]-----+

```

La clé publique peut être copiée sur les serveurs :

```bash
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

Commentez la ligne suivante de la section `[defaults]` du fichier de configuration `/etc/ansible/ansible.cfg` pour empêcher l'authentification par mot de passe :

```bash
#ask_pass      = True
```

### Test d'authentification par clé privée

Pour le test suivant, le module `shell`, qui permet l'exécution de commandes à distance, est utilisé :

```bash
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Aucun mot de passe n'est nécessaire, l'authentification par clé privée/publique fonctionne !

!!! note "Remarque"

    Dans un environnement de production, vous devez maintenant supprimer les mots de passe `ansible` précédemment définis pour renforcer votre sécurité (puisque maintenant un mot de passe d'authentification n'est pas nécessaire).

## Utiliser Ansible

Ansible peut être utilisé à partir du shell ou via des playbooks.

### Les modules

La liste des modules classés par catégorie se trouve [ici](https://docs.ansible.com/ansible/latest/collections/index_module.html). Ansible en offre plus de 750 !

Les modules sont désormais regroupés dans des collections de modules, dont la liste est disponible [ici](https://docs.ansible.com/ansible/latest/collections/index.html).

Les collections sont un format de distribution pour le contenu Ansible qui peut inclure des playbooks, des rôles, des modules et des plugins.

Un module est invoqué avec l'option `-m` de la commande `ansible`:

```bash
ansible <host-pattern> [-m module_name] [-a args] [options]
```

There is a module for almost every need! Il est donc conseillé, au lieu d'utiliser le module shell, de rechercher un module adapté au besoin.

Chaque catégorie de besoins a son propre module. En voici une liste non exhaustive :

| Type                         | Exemples                                                               |
| ---------------------------- | ---------------------------------------------------------------------- |
| Gestion du Système           | `user` (gestion des utilisateurs), `group` (gestion des groupes), etc. |
| Gestion des logiciels        | `dnf`, `yum`, `apt`, `pip`, `npm`                                      |
| Gestion de fichiers          | `copy`, `fetch`, `lineinfile`, `template`, `archive`                   |
| Gestion des bases de données | `mysql`, `postgresql`, `redis`                                         |
| Gestion de Cloud             | `amazon S3`, `cloudstack`, `openstack`                                 |
| Gestion des clusters         | `consul`, `zookeeper`                                                  |
| Envoi de commandes           | `shell`, `script`, `expect`                                            |
| Téléchargements              | `get_url`                                                              |
| Gestion de sources           | `git`, `gitlab`                                                        |

#### Exemple d'installation de logiciel

Le module `dnf` permet d'installer des logiciels sur les clients cibles :

```bash
# ansible rocky8 --become -m dnf -a name="httpd"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
      \n\nComplete!\n"
    ]
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
    \n\nComplete!\n"
    ]
}
```

Le logiciel installé étant un service, il faut maintenant le démarrer avec le module `systemd` :

```bash
# ansible rocky8 --become  -m systemd -a "name=httpd state=started"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
```

!!! tip "Astuce"

    Essayez de lancer ces deux dernières commandes deux fois. Vous observerez que la première fois, Ansible prendra des mesures pour atteindre l'état défini par la commande. La deuxième fois, il ne fera rien car il aura détecté que l'état est déjà atteint !

### Exercices

Pour vous aider à découvrir Ansible et vous habituer à chercher dans la documentation Ansible, voici quelques exercices que vous pouvez faire avant de continuer :

* Créer les groupes Paris, Tokio, NewYork
* Créer un utilisateur `supervisor`
* Modifier l'utilisateur pour qu'il ait un uid de 10000
* Modifier l'utilisateur pour qu'il appartienne au groupe Paris
* Installer le logiciel tree
* Arrêter le service crond
* Créer un fichier vide avec les permissions `644`
* Mise à jour de la distribution client
* Redémarrez votre client

!!! warning "Avertissement"

    Ne pas utiliser le module shell. Recherchez dans la documentation les modules appropriés !

#### module `setup`: introduction aux "facts"

Les "facts" du système sont des variables récupérées par Ansible via son module `setup`.

Jetez un coup d'œil aux différentes données "facts" de vos clients pour vous faire une idée de la quantité d'informations qui peuvent être facilement récupérées par le biais d'une simple commande.

Nous verrons plus tard comment utiliser les "facts" dans nos playbooks et comment créer nos propres "facts".

```bash
# ansible ansible_clients -m setup | less
192.168.1.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.1.11"
        ],
        "ansible_all_ipv6_addresses": [
            "2001:861:3dc3:fcf0:a00:27ff:fef7:28be",
            "fe80::a00:27ff:fef7:28be"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/01/2006",
        "ansible_bios_vendor": "innotek GmbH",
        "ansible_bios_version": "VirtualBox",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "VirtualBox",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "Oracle Corporation",
        ...
```

Maintenant que nous avons vu comment configurer un serveur distant avec Ansible en ligne de commande, nous allons pouvoir introduire la notion de playbook. Les playbooks sont une autre façon d'utiliser Ansible, qui n'est pas beaucoup plus complexe, mais qui facilitera la réutilisation de votre code.

## Playbooks

Ansible's playbooks describe a policy to be applied to remote systems, to force their configuration. Les playbooks sont écrits dans un format textuel facilement compréhensible qui regroupe un ensemble de tâches : le format `yaml`.

!!! note "Remarque"

    Cliquez [ici sur yaml] (https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html) pour en savoir plus

```bash
ansible-playbook <file.yml> ... [options]
```

Les options sont identiques à celles de la commande `ansible`.

La commande renvoie les codes d'erreur suivants :

| Code  | Erreur                                   |
| ----- | ---------------------------------------- |
| `0`   | OK ou pas d'hôte correspondant           |
| `1`   | Erreur                                   |
| `2`   | Un ou plusieurs hôtes sont défaillants   |
| `3`   | Un ou plusieurs hôtes sont inaccessibles |
| `4`   | Analyser l'erreur                        |
| `5`   | Options erronées ou incomplètes          |
| `99`  | Exécution interrompue par l'utilisateur  |
| `250` | Erreur inattendue                        |

!!! note "Remarque"

    Notez que `ansible` renvoie Ok si aucun hôte ne correspond à votre cible, ce qui peut vous induire en erreur !

### Exemple de playbook pour Apache et MySQL

Le playbook suivant nous permet d'installer Apache et MariaDB sur nos serveurs cibles.

Créez un fichier `test.yml` avec le contenu suivant :

```bash
---
- hosts: rocky8 <1>
  become: true <2>
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf: name=httpd,php,php-mysqli state=latest

    - name: ensure httpd is started
      systemd: name=httpd state=started

    - name: ensure mariadb is at the latest version
      dnf: name=mariadb-server state=latest

    - name: ensure mariadb is started
      systemd: name=mariadb state=started
...
```

* <1> Le groupe ou le serveur ciblés doivent exister dans l'inventaire
* <2> Une fois connecté, l'utilisateur devient `root` (via `sudo` par défaut)

L'exécution du playbook se fait avec la commande `ansible-playbook` :

```bash
$ ansible-playbook test.yml

PLAY [rocky8] ****************************************************************

TASK [setup] ******************************************************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure apache is at the latest version] *********************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure httpd is started] ************************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is at the latest version] **********************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is started] ***********************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

PLAY RECAP *********************************************************************
172.16.1.10             : ok=5    changed=3    unreachable=0    failed=0
172.16.1.11             : ok=5    changed=3    unreachable=0    failed=0
```

Pour plus de lisibilité, il est recommandé d'écrire vos playbooks strictement au format yaml. Dans l'exemple précédent, les arguments sont donnés sur la même ligne que le module, la valeur de l'argument suivant son nom séparé par un signe égal `=`. Regardez le même playbook en yaml strict :

```bash
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      systemd:
        name: mariadb
        state: started
...
```

!!! tip "Astuce"

    `dnf` est l'un des modules qui vous permet de lui donner une liste comme argument.

Note sur les collections : Ansible propose désormais des modules sous forme de collections. Certains modules sont fournis par défaut dans la collection `ansible.builtin`, d'autres doivent être installés manuellement via l'option :

```bash
ansible-galaxy collection install [collectionname]
```

où [collectionname] est le nom de la collection (les crochets sont utilisés pour souligner la nécessité de remplacer ce nom par un nom de collection réel et ne font PAS partie de la commande).

L'exemple précédent devrait être rédigé comme suit :

```bash
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Un playbook ne se limite pas à une seule cible :

```bash
---
- hosts: webservers
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

- hosts: databases
  become: true
  become_user: root

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Vous pouvez vérifier la syntaxe de votre playbook :

```bash
ansible-playbook --syntax-check play.yml
```

Vous pouvez également utiliser un "linter" pour yaml :

```bash
dnf install -y yamllint
```

puis vérifiez la syntaxe yaml de vos playbooks :

```bash
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Résultats des exercices

* Créer les groupes Paris, Tokio, NewYork
* Créer l'utilisateur `supervisor`
* Modifier l'utilisateur pour qu'il ait un uid de 10000
* Modifier l'utilisateur pour qu'il appartienne au groupe Paris
* Installer le logiciel tree
* Arrêter le service crond
* Créer un fichier vide avec les permissions `0644`
* Mise à jour de la distribution client
* Redémarrez votre client

```bash
ansible ansible_clients --become -m group -a "name=Paris"
ansible ansible_clients --become -m group -a "name=Tokio"
ansible ansible_clients --become -m group -a "name=NewYork"
ansible ansible_clients --become -m user -a "name=Supervisor"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris"
ansible ansible_clients --become -m dnf -a "name=tree"
ansible ansible_clients --become -m systemd -a "name=crond state=stopped"
ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644"
ansible ansible_clients --become -m dnf -a "name=* state=latest"
ansible ansible_clients --become -m reboot
```
