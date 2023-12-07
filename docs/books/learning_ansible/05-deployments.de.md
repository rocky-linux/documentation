---
title: Verteilung mit Ansistrano
---

# Ansible Verteilung mit Ansistrano

In diesem Kapitel erfahren Sie, wie Sie Anwendungen mit der Ansible-Rolle [Ansistrano](https://ansistrano.com) bereitstellen.

****

**Ziele**: In diesem Kapitel weren Sie Folgendes lernen:

:heavy_check_mark: Ansistrano implementieren;       
:heavy_check_mark: Ansistrano konfigurieren;       
:heavy_check_mark: Verwenden Sie freigegebene Ordner und Dateien zwischen bereitgestellten Versionen;       
:heavy_check_mark: Stellen Sie verschiedene Versionen einer Website über git;        
bereit :heavy_check_mark: Zwischen Bereitstellungsschritten reagieren.

:checkered_flag: **ansible**, **ansistrano**, **Rollen**, **Bereitstellung**

**Vorkenntnisse**: :star: :star:      
**Komplexität**: :star: :star: :star:

**Lesezeit**: 41 Minuten

****

Ansistrano ist eine Ansible-Rolle zur einfachen Bereitstellung von PHP-, Python- und anderen Anwendungen. Es basiert auf den Features von [Capistrano](http://capistranorb.com/).

## Einleitung

Für Ansistrano ist Folgendes erforderlich:

* Ansible auf der Verteilung-Maschine
* `rsync` oder `git` auf der Client-Maschine.

Es kann Sourcecode über `rsync`, `git`, `scp`, `http`, `S3`, ... herunterladen.

!!! note "Anmerkung"

    Für unser Bereitstellungsbeispiel verwenden wir das `git`-Protokoll.

Ansistrano verteilt Anwendungen in 5 Schritten:

* **Setup**: erstellt die Verzeichnisstruktur zum Hosten der verteilten Versionen;
* **Update-Code**: Herunterladen der neuen Version für die Ziele;
* **Symlink Shared** und **Symlink**: Nach der Bereitstellung der neuen Version wird der `aktuelle symbolische Link` geändert, um auf diese neue Version zu verweisen;
* **clean up**: um einige Aufräumarbeiten durchzuführen (alte Versionen entfernen).

![Verteilungs-Phasen](images/ansistrano-001.png)

Das Grundgerüst einer Verteilung mit Ansistrano sieht folgendermaßen aus:

```
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

Sie finden die gesamte Ansistrano-Dokumentation in diesem [Github-Repository](https://github.com/ansistrano/deploy).

## Labore

Sie werden weiterhin mit den beiden Servern arbeiten:

Der Verwaltungs-Server:

* Ansible ist bereits installiert. Sie werden die `ansistrano.deploy` Rolle installieren.

Der verwaltete Server:

* Sie werden Apache installieren und die Client-Site bereitstellen.

### Web-Server bereitstellen

Für eine höhere Effizienz verwenden wir die Rolle `geerlingguy.apache`, um den Server zu konfigurieren:

```
$ ansible-galaxy role install geerlingguy.apache
Starting galaxy role install process
- downloading role 'apache', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-apache/archive/3.1.4.tar.gz
- extracting geerlingguy.apache to /home/ansible/.ansible/roles/geerlingguy.apache
- geerlingguy.apache (3.1.4) was installed successfully
```

Wir werden wahrscheinlich einige Firewall-Regeln öffnen müssen, daher werden wir auch die `ansible.posix`-Kollektion installieren, um mit dem `firewalld`-Modul zu arbeiten:

```
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/ansible-posix-1.2.0.tar.gz to /home/ansible/.ansible/tmp/ansible-local-519039bp65pwn/tmpsvuj1fw5/ansible-posix-1.2.0-bhjbfdpw
Installing 'ansible.posix:1.2.0' to '/home/ansible/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:1.2.0 was installed successfully
```

Sobald Rolle und Sammlung installiert sind, können wir den ersten Teil unseres Playbooks erstellen, der folgende Schritte enthält:

* Apache installieren,
* einen Zielordner für unseren `vhost` erstellen,
* Einen `vhost` als Default erstellen,
* Firewall öffnen,
* Apache (neu-)starten.

Technische Überlegungen:

* Wir stellen unsere Website im Ordner `/var/www/site/` bereit.
* Wie wir später sehen werden, erstellt `ansistrano` einen symbolischen Link `current` zum aktuellen Release-Ordner.
* Der bereitzustellende Quellcode enthält einen Ordner `html`, auf den der Vhost verweisen soll. Der `DirectoryIndex` ist `index.htm`.
* Die Verteilung erfolgt durch `git`, das Paket wird entsprechend installiert.

!!! note "Anmerkung"

    Das Ziel unseres vhost wird: `/var/www/site/current/html`.

Unser Playbook zur Konfiguration des Servers: `playbook-config-server.yml`

```
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

Das Playbook kann auf den Server angewendet werden:

```
$ ansible-playbook playbook-config-server.yml
```

Beachten Sie die Ausführung folgender Aufgaben:

```
TASK [geerlingguy.apache : Ensure Apache is installed on RHEL.] ****************
TASK [geerlingguy.apache : Configure Apache.] **********************************
TASK [geerlingguy.apache : Add apache vhosts configuration.] *******************
TASK [geerlingguy.apache : Ensure Apache has selected state and enabled on boot.] ***
TASK [permit traffic in default zone for http service] *************************
RUNNING HANDLER [geerlingguy.apache : restart apache] **************************
```

Die Rolle `geerlingguy.apache` erleichtert uns die Arbeit erheblich, indem sie sich um die Installation und Konfiguration von Apache kümmert.

Mit `curl` können Sie überprüfen, ob alles funktioniert:

```
$ curl -I http://192.168.1.11
HTTP/1.1 404 Not Found
Date: Mon, 05 Jul 2021 23:30:02 GMT
Server: Apache/2.4.37 (rocky) OpenSSL/1.1.1g
Content-Type: text/html; charset=iso-8859-1
```

!!! note "Anmerkung"

    Da wir noch keinen Code bereitgestellt haben, ist es normal, dass „curl“ einen HTTP-Code „404“ zurückgibt. Wir können aber bereits bestätigen, dass der Dienst „httpd“ funktioniert und die Firewall geöffnet ist.

### Bereitstellung der Software

Nachdem unser Server nun konfiguriert ist, können wir die Anwendung bereitstellen.

Zu diesem Zweck verwenden wir die Rolle `ansistrano.deploy` in einem zweiten Playbook, das der Bereitstellung von Anwendungen gewidmet ist (zur besseren Lesbarkeit).

```
$ ansible-galaxy role install ansistrano.deploy
Starting galaxy role install process
- downloading role 'deploy', owned by ansistrano
- downloading role from https://github.com/ansistrano/deploy/archive/3.10.0.tar.gz
- extracting ansistrano.deploy to /home/ansible/.ansible/roles/ansistrano.deploy
- ansistrano.deploy (3.10.0) was installed successfully

```

Die Softwarequellen finden Sie im [Github-Repository](https://github.com/alemorvan/demo-ansible.git).

Wir werden ein Playbook `playbook-deploy.yml` erstellen, um unsere Bereitstellung zu verwalten:

```
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

```
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
192.168.1.11               : ok=25   changed=8    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   

```

Mit nur 11 Zeilen Code lässt sich so viel erledigen!

```
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

### Überprüfung auf dem Server

Sie können sich mittels ssh mit der client-maschine verbinden.

* Erstellen Sie einen `Baum` im Verzeichnis `/var/www/site/`:

```
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722155312Z
├── releases
│   └── 20210722155312Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Bitte beachten:

* der `aktuelle` Symlink zur Veröffentlichung `./releases/20210722155312Z`
* das Vorhandensein eines `shared`-Verzeichnisses
* das Vorhandensein von Git-Repos im Verzeichnis `./repo/`

* Starten Sie die Verteilung vom Ansible-Server aus **dreimal** neu und überprüfen Sie dann den Client.

```
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
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

Bitte beachten:

* `ansistrano` hat die letzten 4 Versionen behalten,
* der Link `current` ist nun mit der neuesten Version verknüpft

### Begrenzung der Anzahl von Versionen

Die Variable `ansistrano_keep_releases` wird verwendet, um die Anzahl der aufzubewahrenden Releases anzugeben.

* Mit der Variablen `ansistrano_keep_releases` behalten Sie nur drei Releases des Projekts. Bitte überprüfen.

```
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

```
---
$ ansible-playbook -i hosts playbook-deploy.yml
```

Auf der Client Maschine:

```
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
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

### Verwendung von shared_paths und shared_files


```
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

Erstellen Sie auf dem Client-Computer die Datei `log` im Verzeichnis `shared`:

```
sudo touch /var/www/site/shared/logs
```

Führen Sie dann das Playbook aus:

```
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent] *******************************************************
ok: [192.168.10.11] => (item=img)
ok: [192.168.10.11] => (item=css)
ok: [192.168.10.11] => (item=logs/log)

TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files] **************************************************
changed: [192.168.10.11] => (item=img)
changed: [192.168.10.11] => (item=css)
changed: [192.168.10.11] => (item=logs)
```

Auf der Client Maschine:

```
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

Bitte beachten Sie, dass die neueste Version 3 Links enthält: `css`, `img` und `log`

* von `/var/www/site/releases/css` nach `../../shared/css/`.
* vom `/var/www/site/releases/img` zum `../../shared/img/` Verzeichnis.
* von `/var/www/site/releases/logs` zur `../../shared/logs` Datei.

Daher sind die in diesen beiden Ordnern enthaltenen Dateien und die `log`-Datei immer über die folgenden Pfade zugänglich:

* `/var/www/site/current/css/`,
* `/var/www/site/current/img/`,
* `/var/www/site/current/logs`,

aber vor allem werden sie von einer Veröffentlichung zur anderen beibehalten.

### Verwenden Sie ein Unterverzeichnis des Repositorys für die Bereitstellung

In unserem Fall enthält das Repository einen Ordner `html`, der die Site-Dateien enthält.

* Um diese zusätzliche Verzeichnisebene zu vermeiden, benutzen Sie die Variable `ansistrano_git_repo_tree`, die den Pfad des zu verwendenden Unterverzeichnisses angibt.

Vergessen Sie nicht, Ihre Apache-Konfiguration entsprechend zu ändern!

Bearbeiten Sie das Playbook für die Serverkonfiguration `playbook-config-server.yml`

```
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

<1> Diese Zeile ändern

Ändern Sie das Deployment-Playbook `playbook-deploy.yml`

```
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

<1> Diese Zeile ändern

* Vergessen Sie nicht, beide Playbooks auszuführen

* Überprüfen Sie die Client-Maschine:

```
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

<1> Beachten Sie, dass `html` nicht vorhanden ist

### Branch- oder Git-Tag-Verwaltung

Die Variable `ansistrano_git_branch` wird verwendet, um einen `branch` oder `tag` für die Bereitstellung anzugeben.

* Den Branch `releases/v1.1.0` bereitstellen:

```
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

!!! note "Anmerkung"

    Während der Bereitstellung können Sie Ihren Browser aktualisieren, um die Änderung „live“ zu verfolgen.

```
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

* Das Git-Tag `v2.0.0` bereitstellen:

```
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

```
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

### Aktionen zwischen den Bereitstellungsphasen

Eine Verteilung mit Ansistrano berücksichtigt die folgenden Phasen:

* `Setup`
* `Code-Update`
* `Symlink Shared`
* `Symbolischer Link`
* `Aufräumen`

Vor und nach jedem dieser Schritte ist ein Eingriff möglich.

![Verteilungs-Phasen](images/ansistrano-001.png)

Über die dafür bereitgestellten Variablen kann ein Playbook eingebunden werden:

* `ansistrano_before_<task>_tasks_file`
* oder `ansistrano_after_<task>_tasks_file`

* Einfaches Beispiel: zu Beginn der Bereitstellung eine E-Mail (oder eine beliebige Slack-Benachrichtigung) senden:


```
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

Die Datei `deploy/before-setup-tasks.yml` erstellen:

```
---
- name: Send a mail
  mail:
    subject: Starting deployment on {{ ansible_hostname }}.
  delegate_to: localhost
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/before-setup-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : Send a mail] *************************************************************************************
ok: [192.168.10.11 -> localhost]
```

```
[root] # mailx
Heirloom Mail version 12.5 7/5/10.  ?  zeigt Hilfe an.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.local  Tue Aug 21 14:41  28/946   "Starting deployment on localhost."
```

* Am Ende der Bereitstellung müssen Sie wahrscheinlich einige Dienste neu starten, beispielsweise um den Cache zu leeren. Nach Abschluss der Bereitstellung starten wir Apache neu:

```
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

Erstellen Sie die Datei `deploy/after-symlink-tasks.yml`:

```
---
- name: restart apache
  systemd:
    name: httpd
    state: restarted
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/after-symlink-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : restart apache] **************************************************************************************
changed: [192.168.10.11]
```

Wie Sie in diesem Kapitel gesehen haben, kann Ansible die Arbeit des Systemadministrators erheblich vereinfachen. Intelligente Rollen wie beim Ansistrano sind „Must-haves“, die schnell unverzichtbar werden.

Der Einsatz von Ansistrano garantiert die Einhaltung guter Bereitstellungspraktiken, verkürzt die Zeit, die für die Inbetriebnahme eines Systems benötigt wird, und vermeidet das Risiko potenzieller menschlicher Fehler. Die Maschine arbeitet schnell, gut und macht selten Fehler!
