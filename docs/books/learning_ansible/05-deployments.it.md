---
title: Distribuzione con Ansistrano
---

# Distribuzione Ansible con Ansistrano

In questo capitolo imparerai come distribuire applicazioni con il ruolo Ansible [Ansistrano](https://ansistrano.com).

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: Implementare Ansistrano;  
:heavy_check_mark: Configurare Ansistrano;  
:heavy_check_mark: Usare cartelle e file condivisi tra le versioni distribuite;  
:heavy_check_mark: Distribuire diverse versioni di un sito da git;  
:heavy_check_mark: Reagire tra i passaggi di implementazione.

:checkered_flag: **ansible**, **ansistrano**, **ruoli**, **distribuzioni**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 40 minuti

****

Ansistrano è un ruolo Ansible per distribuire facilmente applicazioni PHP, Python, ecc. Si basa sulla funzionalità di [Capistrano](http://capistranorb.com/).

## Introduzione

Ansistrano richiede quanto segue:

* Ansible sulla macchina di distribuzione,
* `rsync` o `git` sulla macchina client.

Può scaricare il codice sorgente da `rsync`, `git`, `scp`, `http`, `S3`, ...

!!! Note "Nota"

    Per il nostro esempio di distribuzione, utilizzeremo il protocollo `git`.

Ansistrano distribuisce applicazioni seguendo questi 5 passaggi:

* **Setup**: crea la struttura delle directory per ospitare le release;
* **Update Code**: scaricando la nuova release per gli obiettivi;
* **Symlink Shared** e **Symlink**: dopo aver distribuito la nuova release, il `link simbolico corrente` è modificato per puntare a questa nuova versione;
* **Clean Up**: per fare un po' di pulizia (rimuovi le vecchie versioni).

![Fasi di una distribuzione](images/ansistrano-001.png)

Lo scheletro di una distribuzione con Ansistrano assomiglia a questo:

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

Puoi trovare tutta la documentazione di Ansistrano sul suo [repository Github](https://github.com/ansistrano/deploy).

## Labs

Continuerai a lavorare sui tuoi 2 server:

Il server di gestione:

* Ansible è già installato. Dovrai installare il ruolo `ansistrano.deploy`.

Il server gestito:

* Sarà necessario installare Apache e distribuire il sito client.

### Distribuzione del server Web

Per una maggiore efficienza, useremo il ruolo `geerlingguy.apache` per configurare il server:

```bash
$ ansible-galaxy role install geerlingguy.apache
Starting galaxy role install process
- downloading role 'apache', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-apache/archive/3.1.4.tar.gz
- extracting geerlingguy.apache to /home/ansible/.ansible/roles/geerlingguy.apache
- geerlingguy.apache (3.1.4) was installed successfully
```

Probabilmente avremo bisogno di aprire alcune regole del firewall, quindi installeremo anche la collezione `ansible.posix` per lavorare con il suo modulo `firewalld`:

```bash
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/ansible-posix-1.2.0.tar.gz to /home/ansible/.ansible/tmp/ansible-local-519039bp65pwn/tmpsvuj1fw5/ansible-posix-1.2.0-bhjbfdpw
Installing 'ansible.posix:1.2.0' to '/home/ansible/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:1.2.0 was installed successfully
```

Una volta installato il ruolo e la collezione, possiamo creare la prima parte del nostro playbook, che sarà:

* Installare Apache,
* Creare una cartella di destinazione per il nostro `vhost`,
* Creare un `vhost` di default,
* Apri il firewall,
* Avviare o riavviare Apache.

Considerazioni tecniche:

* Distribuiremo il nostro sito nella cartella `/var/www/site/`.
* Come vedremo più tardi, `ansistrano` creerà un collegamento simbolico `corrente` alla cartella di rilascio corrente.
* Il codice sorgente da distribuire contiene una cartella `html` alla quale il vhost dovrebbe puntare. Il suo `DirectoryIndex` è `index.htm`.
* La distribuzione è fatta da `git`, il pacchetto sarà installato.

!!! Note "Nota"

    Il target del nostro vhost sarà: `/var/www/site/current/html`.

Il nostro playbook per configurare il server: `playbook-config-server.yml`

```bash
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

Il playbook può essere applicato al server:

```bash
ansible-playbook playbook-config-server.yml
```

Nota l'esecuzione dei seguenti compiti:

```bash
TASK [geerlingguy.apache : Ensure Apache is installed on RHEL.] ****************
TASK [geerlingguy.apache : Configure Apache.] **********************************
TASK [geerlingguy.apache : Add apache vhosts configuration.] *******************
TASK [geerlingguy.apache : Ensure Apache has selected state and enabled on boot.] ***
TASK [permit traffic in default zone for http service] *************************
RUNNING HANDLER [geerlingguy.apache : restart apache] **************************
```

Il ruolo `geerlingguy.apache` rende il nostro lavoro molto più facile prendendosi cura dell'installazione e della configurazione di Apache.

Puoi controllare che tutto funzioni usando `curl`:

```bash
$ curl -I http://192.168.1.11
HTTP/1.1 404 Not Found
Date: Mon, 05 Jul 2021 23:30:02 GMT
Server: Apache/2.4.37 (rocky) OpenSSL/1.1.1g
Content-Type: text/html; charset=iso-8859-1
```

!!! Note "Nota"

    Non abbiamo ancora distribuito alcun codice, quindi è normale che `curl` restituisca un codice HTTP `404`. Ma possiamo già confermare che il servizio `httpd` sta funzionando e che il firewall è aperto.

### Distribuzione del software

Ora che il nostro server è configurato, possiamo distribuire l'applicazione.

Per questo, useremo il ruolo `ansistrano.deploy` in un secondo playbook dedicato alla distribuzione delle applicazioni (per una maggiore leggibilità).

```bash
$ ansible-galaxy role install ansistrano.deploy
Starting galaxy role install process
- downloading role 'deploy', owned by ansistrano
- downloading role from https://github.com/ansistrano/deploy/archive/3.10.0.tar.gz
- extracting ansistrano.deploy to /home/ansible/.ansible/roles/ansistrano.deploy
- ansistrano.deploy (3.10.0) was installed successfully

```

Le fonti del software possono essere trovate nel [repository github](https://github.com/alemorvan/demo-ansible.git).

Creeremo un playbook `playbook-deploy.yml` per gestire la nostra distribuzione:

```bash
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

Tante cose fatte con sole 11 righe di codice!

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

### Controllo sul server

Ora puoi connetterti da ssh alla tua macchina client.

* Crea un `albero` nella directory `/var/www/site/`:

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

Nota che:

* il `current` symlink alla release `./releases/20210722155312Z`
* la presenza di una directory `shared`
* la presenza dei git repos in `./repo/`

* Dal server Ansible riavviare la distribuzione **3** volte, quindi controllare il client.

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

Nota che:

* `ansistrano` ha mantenuto le ultime 4 release,
* il link `current` è collegato ora all'ultima release

### Limita il numero di release

La variabile `ansistrano_keep_releases` è usata per specificare il numero di rilasci da mantenere.

* Utilizzando la variabile `ansistrano_keep_releases`, mantieni solo 3 rilasci del progetto. Verifica.

```bash
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

Sulla macchina client:

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

### Utilizzo di shared_path e shared_files

```bash
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

Sulla macchina client, crea il file `log` nella directory `shared`:

```bash
sudo touch /var/www/site/shared/logs
```

Quindi esegui il playbook:

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

Sulla macchina client:

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

Si prega di notare che l'ultima versione contiene 3 link:  `css`, `img`e `log`

* da `/var/www/site/releases/css` alla directory `../../shared/css/`.
* da `/var/www/site/releases/img` alla directory `../../shared/img/`.
* da `/var/www/site/releases/logs` al file `../../shared/logs`.

Pertanto, i file contenuti in queste 2 cartelle e il file `log` sono sempre accessibili attraverso i seguenti percorsi:

* `/var/www/site/current/css/`,
* `/var/www/site/current/img/`,
* `/var/www/site/current/logs`,

ma soprattutto saranno mantenuti da una release all'altra.

### Usa una sottodirectory del repository per la distribuzione

Nel nostro caso, il repository contiene una cartella `html`, che contiene i file del sito.

* Per evitare questo livello extra di directory, usa la variabile `ansistrano_git_repo_tree` specificando il percorso della sotto-directory da usare.

Non dimenticare di modificare la configurazione di Apache per tenere conto di questo cambiamento!

Modifica il playbook per la configurazione del server `playbook-config-server.yml`

```bash
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

<1> Modifica questa riga

Cambia il playbook per la distribuzione `playbook-deploy.yml`

```bash
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

<1> Modifica questa riga

* Non dimenticare di eseguire entrambi i playbook

* Controlla la macchina cliente:

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

<1> Notare l'assenza di `html`

### Gestione del ramo o dei tag git

La variabile `ansistrano_git_branch` è usata per specificare un `branch` o un `tag` da distribuire.

* Distribuisci il branch `releases/v1.1.0`:

```bash
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

!!! Note "Nota"

    Per divertirti, durante la distribuzione, puoi aggiornare il browser, per vedere in 'live' il cambiamento.

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

* Distribuisci il tag `v2.0.0`:

```bash
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

### Azioni tra le fasi di implementazione

Una distribuzione con Ansistrano rispetta le seguenti fasi:

* `Setup`
* `Update Code`
* `Symlink Shared`
* `Symlink`
* `Clean Up`

È possibile intervenire prima e dopo ciascuno di questi passi.

![Fasi di una distribuzione](images/ansistrano-001.png)

Un playbook può essere incluso attraverso le variabili fornite per questo scopo:

* `ansistrano_before_<task>_tasks_file`
* o `ansistrano_after_<task>_tasks_file`

* Esempio semplice: invia un'email (o qualsiasi cosa desideri come la notifica di Slack) all'inizio della distribuzione:

```bash
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

Crea il file `deploy/before-setup-tasks.yml`:

```bash
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
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.local  Tue Aug 21 14:41  28/946   "Starting deployment on localhost."
```

* Probabilmente dovrai riavviare alcuni servizi alla fine della distribuzione, per esempio per pulire la cache. Riavviamo Apache alla fine della distribuzione:

```bash
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

Crea il file `deploy/after-symlink-tasks.yml`:

```bash
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

Come avete visto durante questo capitolo, Ansible può migliorare notevolmente la vita dell'amministratore di sistema. Ruoli molto intelligenti come Ansistrano sono dei "must haves" che diventano rapidamente indispensabili.

L'utilizzo di Ansistrano garantisce il rispetto delle buone pratiche di diffusione, riduce i tempi necessari per mettere in produzione un sistema ed evita il rischio di potenziali errori umani. La macchina funziona velocemente, bene, e raramente commette errori!
