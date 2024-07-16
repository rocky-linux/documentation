---
title: Déploiement avec Ansistrano
---

# Déploiements Ansible avec Ansistrano

Dans ce chapitre vous allez apprendre le déploiement d'applications en utilisant le rôle [Ansistrano](https://ansistrano.com) d'Ansible.

****

**Objectifs** : Dans ce chapitre, vous apprendrez :

:heavy_check_mark: Implémentation d'Ansistrano ; :heavy_check_mark: Configuration d'Ansistrano ; :heavy_check_mark: Utilisation de répertoires et de fichiers partagés entre des versions déployées ; :heavy_check_mark: Déploiement de différentes versions d'un site à partir de git ; :heavy_check_mark: Rétrospective entre différentes étapes de déploiement.

:checkered_flag: **ansible**, **ansistrano**, **rôles**, **déploiements**

**Connaissances** : :star: :star: **Complexité** : :star: :star: :star:

**Temps de lecture** : 40 minutes

****

Ansistrano est un rôle d'Ansible pour déployer facilement des applications PHP, Python, etc. Il est basé sur les fonctionalités de [Capistrano](http://capistranorb.com/).

## Introduction

Ansistrano requiert les composants suivants :

* Ansible sur la machine chargée du déploiement,
* `rsync` ou bien `git` sur la machine client.

Il peut télécharger le code source à partir de `rsync`, `git`, `scp`, `http`, `S3`, ...

!!! note "Note"

    Pour notre exemple de déploiement, nous utiliserons `git`.

Ansistrano déploie des applications en suivant les 5 étapes suivantes :

* **Setup** : crée l'arborescence pour héberger les différentes versions ;
* **Update Code** : télécharger la nouvelle version vers les destinations ;
* **Symlink Shared** et **Symlink** : après le déploiement de la nouvelle version le lien symbolique `actuel` est modifié pour pointer vers cette nouvelle version ;
* **Clean Up** : nettoyage (suppression des versions obsoletes).

![Étapes de déploiement](images/ansistrano-001.png)

Le squelete d'un déploiement en utilisant Ansistrano se décrit comme suit :

```bash
/var/www/site/
├── current -> ./releases/20210718100000Z
├── releases
│   └── 20210718100000Z
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       └── REVISION
├── repo
└── shared
    ├── css/
    └── img/
```

Vous trouverez toute la documentation de Ansistrano dans son [dépôt sur Github](https://github.com/ansistrano/deploy).

## Labos

Vous continuerez à travailler en utilisant les 2 serveurs :

Le serveur de gestion :

* Ansible est déjà installé. Vous devrez installer le rôle `ansistrano.deploy`.

Le serveur géré :

* Vous devrez installer Apache et déployer le site client.

### Déploiement du serveur web

Pour une meilleure efficacité nous utiliserons le rôle `geerlingguy.apache` pour configurer le serveur :

```bash
$ ansible-galaxy role install geerlingguy.apache
Starting galaxy role install process
- downloading role 'apache', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-apache/archive/3.1.4.tar.gz
- extracting geerlingguy.apache to /home/ansible/.ansible/roles/geerlingguy.apache
- geerlingguy.apache (3.1.4) was installed successfully
```

Nous aurons probablement besoin d'accéder à certaines règles du pare-feu, ainsi nous installerons la collection `ansible.posix` pour utiliser le module `firewalld` :

```bash
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/ansible-posix-1.2.0.tar.gz to /home/ansible/.ansible/tmp/ansible-local-519039bp65pwn/tmpsvuj1fw5/ansible-posix-1.2.0-bhjbfdpw
Installing 'ansible.posix:1.2.0' to '/home/ansible/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:1.2.0 was installed successfully
```

Après avoir installé le rôle et la collection, nous pouvons créer la première partie de notre playbook qui va :

* Installer Apache,
* Créer un répertoire pour contenir `vhost`,
* Créer `vhost` par défaut,
* Accéder au pare-feu,
* Lancer ou bien relancer Apache.

Considérations techniques :

* Nous allons déployer notre site dans le répertoire `/var/www/site/`.
* Comme nous le verrons plus tard, `Ansistrano` va créer un lien symbolique qui pointe vers le répertoire de la version `actuelle`.
* Le code source à déployer contient un répertoire `html` vers lequel <0>vhost</0> devrait pointer. L'indexe `DirectoryIndex` est représenté par le fichier `index.htm`.
* Le déploiement se faisant en utilisant `git`, le paquet correspondant sera installé.

!!! note "Remarque"

    Par conséquent la destination de notre vhost sera : `/var/www/site/current/html`.

Le playbook pour configurer le serveur : `playbook-config-server.yml`

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
    documentroot: "{{ dest }}current/html"

  tasks:

    - name: create directory for website
      file:
        path: /var/www/site/
        state: directory
        mode: 0755

    - name: install git
      package:
        name: git
        state: latest

    - name: permit traffic in default zone for http service
      ansible.posix.firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

  roles:
    - { role: geerlingguy.apache }
```

Pour appliquer le playbook au serveur :

```bash
ansible-playbook playbook-config-server.yml
```

Notez l'exécution des tâches suivantes :

```bash
TASK [geerlingguy.apache : Ensure Apache is installed on RHEL.] ****************
TASK [geerlingguy.apache : Configure Apache.] **********************************
TASK [geerlingguy.apache : Add apache vhosts configuration.] *******************
TASK [geerlingguy.apache : Ensure Apache has selected state and enabled on boot.] ***
TASK [permit traffic in default zone for http service] *************************
RUNNING HANDLER [geerlingguy.apache : restart apache] **************************
```

Le rôle `geerlingguy.apache` simplifie la tâche en prenant en charge l'installation et la configuration du logiciel Apache.

Vous pouvez vérifier le résultat en utilisant `curl` :

```bash
$ curl -I http://192.168.1.11
HTTP/1.1 404 Not Found
Date: Mon, 05 Jul 2021 23:30:02 GMT
Server: Apache/2.4.37 (rocky) OpenSSL/1.1.1g
Content-Type: text/html; charset=iso-8859-1
```

!!! note "Remarque"

    Jusqu'à présent nous n'avons déployé aucun code, c'est pourquoi `curl` renvoie le code HTTP `404`. Mais nous pouvons confirmer que le service `httpd` est actif et que le pare-feu autorise l'accès.

### Déploiement de logiciel

Maintenant que notre serveur est opérationel, nous sommes en mesure de déployer l'application.

Pour cela nous utiliserons le rôle `ansistrano.deploy` dans un deuxième playbook dédié au déploiement d'application (pour une meilleure lisibilité).

```bash
$ ansible-galaxy role install ansistrano.deploy
Starting galaxy role install process
- downloading role 'deploy', owned by ansistrano
- downloading role from https://github.com/ansistrano/deploy/archive/3.10.0.tar.gz
- extracting ansistrano.deploy to /home/ansible/.ansible/roles/ansistrano.deploy
- ansistrano.deploy (3.10.0) was installed successfully

```

Les sources du logiciel se trouvent dans le dépôt de [github](https://github.com/alemorvan/demo-ansible.git).

Nous allons créer un playbook `playbook-deploy.yml` pour gérer notre déploiement :

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"

  roles:
     - { role: ansistrano.deploy }
```

```bash
$ ansible-playbook playbook-deploy.yml

PLAY [ansible_clients] *********************************************************

TASK [ansistrano.deploy : ANSISTRANO | Ensure deployment base path exists] *****
TASK [ansistrano.deploy : ANSISTRANO | Ensure releases folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared elements folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure basedir shared files exists]
TASK [ansistrano.deploy : ANSISTRANO | Get release version] ********************
TASK [ansistrano.deploy : ANSISTRANO | Get release path]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Register ansistrano_git_result variable]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Set git_real_repo_tree]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Create release folder]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Sync repo subtree[""] to release path]
TASK [ansistrano.deploy : ANSISTRANO | Copy git released version into REVISION file]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent]
TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files]
TASK [ansistrano.deploy : ANSISTRANO | Ensure .rsync-filter is absent]
TASK [ansistrano.deploy : ANSISTRANO | Setup .rsync-filter with shared-folders]
TASK [ansistrano.deploy : ANSISTRANO | Get current folder]
TASK [ansistrano.deploy : ANSISTRANO | Remove current folder if it's a directory]
TASK [ansistrano.deploy : ANSISTRANO | Change softlink to new release]
TASK [ansistrano.deploy : ANSISTRANO | Clean up releases]

PLAY RECAP ********************************************************************************************************************************************************************************************************
192.168.1.11 : ok=25   changed=8    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0

```

Tout cela avec seulement onze lignes de code !

```html
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version Master</h1>
</body>
<html>
```

### Vérification sur le serveur

Vous pouvez maintenant vous connecter sur la machine client en utilisant ssh.

* Créer une arborescence `tree` dans le répertoire `/var/www/site/` :

```bash
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722155312Z
├── releases
│   └── 20210722155312Z
│       ├── REVISION
│       └── html
│    └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Notez s'il vous plait :

* le lien symbolique actuel `current` `./releases/20210722155312Z`
* la présence du répertoire partagé `shared`
* la présence des répertoires git dans `./repo/`

* À partir du serveur Ansible relancez le déploiement **3** fois et vérifiez le résultat sur le serveur client.

```bash
$ tree /var/www/site/
var/www/site
├── current -> ./releases/20210722160048Z
├── releases
│   ├── 20210722155312Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160032Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160048Z
│       ├── REVISION
│       └── html
│    └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Notez s'il vous plait :

* `ansistrano` conserve les 4 dernières versions,
* le lien symbolique actuel `current` pointe maintenant vers la dernière version

### Limitation du nombre de versions

La variable `ansistrano_keep_releases` indique le nombre de versions à conserver.

* En utilisant la variable `ansistrano_keep_releases`, conserver seulement 3 versions du projet. Vérifier le résultat.

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3

  roles:
     - { role: ansistrano.deploy }
```

```bash
---
$ ansible-playbook -i hosts playbook-deploy.yml
```

Sur la machine client :

```bash
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722160318Z
├── releases
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160048Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160318Z
│       ├── REVISION
│       └── html
│    └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

### Utilisation des variables shared_paths et shared_files

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"

  roles:
     - { role: ansistrano.deploy }
```

Créer le fichier `logs` dans le répertoire `shared` sur la machine client :

```bash
sudo touch /var/www/site/shared/logs
```

Ensuite relancez le playbook :

```bash
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent] *******************************************************
ok: [192.168.10.11] => (item=img)
ok: [192.168.10.11] => (item=css)
ok: [192.168.10.11] => (item=logs/log)

TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files] **************************************************
changed: [192.168.10.11] => (item=img)
changed: [192.168.10.11] => (item=css)
changed: [192.168.10.11] => (item=logs)
```

Sur la machine client :

```bash
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722160631Z/
├── releases/
│   ├── 20210722160048Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   └── 20210722160631Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── html/
│       │   └── index.htm
│       ├── img -> ../../shared/img/
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

Notez que la dernière version contient 3 liens : `css`, `img` et `logs`

* de `/var/www/site/releases/css` vers le répertoire `../../shared/css/`.
* lien de `/var/www/site/releases/img` vers le répertoire `../../shared/img/`.
* lien de `/var/www/site/releases/logs` vers le répertoire `../../shared/logs`.

Ainsi, les fichiers contenus dans ces 2 répertoires ainsi que le fichier `logs` seront toujours accessibles en utilisant les chemins suivants :

* `/var/www/site/current/css/`,
* `/var/www/site/current/img/`,
* `/var/www/site/current/logs`,

mais surtout ils seront conservés d'une version à l'autre.

### Utilisation d'un sous-répertoire du dépôt à déployer

Dans notre cas présent, le dépôt possède un répertoire `html` qui contient les fichiers du site.

* Pour éviter ce niveau supplémentaire de répertoire, utiliser la variable `ansistrano_git_repo_tree` en indiquant le chemin du sous-répertoire à utiliser.

N'oubliez pas de modifier la configuration de Apache pour prendre en compte ce changement !

Modifier le playbook pour la configuration du serveur `playbook-config-server.yml`

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
 documentroot: "{{ dest }}current/" # <1>

  tasks:

    - name: create directory for website
      file:
 path: /var/www/site/
 state: directory
 mode: 0755

    - name: install git
      package:
 name: git
 state: latest

  roles:
    - { role: geerlingguy.apache }
```

<1> Modifier cette ligne

Modifier le playbook de déploiement `playbook-deploy.yml`

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html' # <1>

  roles:
     - { role: ansistrano.deploy }
```

<1> Modifier cette ligne

* N'oubliez de relancer chacun des deux playbooks

* Vérifier le résultat sur la machine client :

```bash
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722161542Z/
├── releases/
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160631Z/
│   │   ├── REVISION
│   │   ├── css -> ../../shared/css/
│   │   ├── html/
│   │   │   └── index.htm
│   │   ├── img -> ../../shared/img/
│   │   └── logs -> ../../shared/logs
│   └── 20210722161542Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       ├── index.htm
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

<1> Notez l'absence de `html`

### Gestion des branches et tags de git

La variable `ansistrano_git_branch` pour indiquer une `branch`e ou bien un `tag` à deployer.

* Deployer la branche `releases/v1.1.0` :

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'releases/v1.1.0'

  roles:
     - { role: ansistrano.deploy }
```

!!! note "Remarque"

    Pendant le déploiement vous pouvez suivre les modifications en actualisant votre navigateur.

```html
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 1.0.1</h1>
</body>
<html>
```

* Deployer le tag `v2.0.0` :

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'

  roles:
     - { role: ansistrano.deploy }
```

```html
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 2.0.0</h1>
</body>
<html>
```

### Opérations entre les étapes de déploiement

Un déploiement utilisant Ansistrano poursuit les étapes suivantes :

* `Setup`
* `Mise à jour du code`
* `Partage du lien symbolique`
* `Lien symbolique`
* `Nettoyage`

Il est possible d'intervenir avant et après chacune des étapes.

![Étapes d'un déploiement](images/ansistrano-001.png)

Un playbook peut être inclus par l'intermédiaire de variables prévues dans ce but :

* `ansistrano_before_<task>_tasks_file`
* ou bien `ansistrano_after_<task>_tasks_file`

* Un simple exemple : envoyer un courriel (ou tout ce que vous voulez, comme une notification Slack) en début de déploiement :

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

Créer le fichier `deploy/before-setup-tasks.yml` :

```yaml
---
- name: Send a mail
  mail:
    subject: Starting deployment on {{ ansible_hostname }}.
  delegate_to: localhost
```

```bash
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/before-setup-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : Send a mail] *************************************************************************************
ok: [192.168.10.11 -> localhost]
```

```bash
[root] # mailx
Heirloom Mail version 12.5 7/5/10.  ?  affiche une page d'aide.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.local  Tue Aug 21 14:41  28/946   "Starting deployment on localhost."
```

* Vous devrez probablement relancer certains services en fin de déploiement, pour mettre à jour les caches, par exemple. Relancer Apache en fin de déploiement :

```yaml
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"
    ansistrano_after_symlink_tasks_file: "{{ playbook_dir }}/deploy/after-symlink-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

Créer le fichier `deploy/after-symlink-tasks.yml` :

```yaml
---
- name: restart apache
  systemd:
    name: httpd
    state: restarted
```

```bash
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/after-symlink-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : restart apache] **************************************************************************************
changed: [192.168.10.11]
```

Comme le montre ce chapitre, Ansible peut considérablement simplifier la vie de l'administrateur du système. Des rôles très judicieux comme Ansistrano deviennent rapidement indispensables.

L'utilisation de Ansistrano assure le respect de bonnes pratiques, réduit le temps nécessaire à rendre un système productif et évite bon nombre d'erreurs humaines potentielles. La machine est rapide, efficace et réduit le risque d'erreurs !
