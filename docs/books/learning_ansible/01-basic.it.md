---
title: Nozioni di base su Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Aditya Putta
update: 19-Dec-2021
---

# Nozioni di base su Ansible

In questo capitolo imparerai come lavorare con Ansible.

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: Implementare Ansible;       
:heavy_check_mark: Applicare modifiche alla configurazione su un server;   
:heavy_check_mark: Creare i primi playbook Ansible;

:checkered_flag: **ansible**, **moduli**, **playbook**

**Conoscenza**: :star: :star: :star:     
**Complessità**: :star: :star:

**Tempo di lettura**: 30 minuti

****

Ansible centralizza e automatizza i compiti di amministrazione. È:

* **agentless** (non richiede implementazioni specifiche sui client),
* **idempotent** (stesso effetto ogni volta che viene eseguito).

Utilizza il protocollo **SSH** per configurare in remoto i client Linux o il protocollo **WinRM** per funzionare con i client Windows. Se nessuno di questi protocolli è disponibile, è sempre possibile per Ansible utilizzare un'API, che rende Ansible un vero coltellino svizzero per la configurazione di server, postazioni di lavoro, servizi docker, attrezzature di rete, ecc. (Quasi tutto in realtà).

!!! Warning "Attenzione"

    L'apertura di flussi SSH o WinRM a tutti i client dal server Ansible lo rende un elemento critico dell'architettura che deve essere attentamente monitorato.

Poiché Ansible è principalmente basato su push, non manterrà lo stato dei suoi server tra le sue esecuzioni. Al contrario, eseguirà nuovi controlli di stato ogni volta che viene eseguito. Si dice che sia senza stato.

Ti aiuterà con:

* fornitura (distribuzione di una nuova VM),
* distribuzione di applicazioni
* gestione della configurazione,
* automazione
* orchestrazione (quando è in uso più di 1 destinazione).

!!! Note "Nota"

    Ansible è stato originariamente scritto da Michael DeHaan, il fondatore di altri strumenti come Cobbler.
    
    ![Michael DeHaan](images/Michael_DeHaan01.jpg)
    
    La prima versione è stata la 0.0.1, rilasciata il 9 marzo 2012.
    
    Il 17 ottobre 2015, AnsibleWorks (la società dietro Ansible) è stata acquisita da Red Hat per 150 milioni di dollari.

![Le caratteristiche di Ansible](images/ansible-001.png)

Per offrire un'interfaccia grafica al tuo uso quotidiano di Ansible, puoi installare alcuni strumenti come Ansible Tower (RedHat), che non è gratuito, la sua controparte opensource Awx, o possono anche essere utilizzati altri progetti come Jenkins e l'eccellente Rundeck.

!!! Abstract "In astratto"

    Per seguire questa formazione, avrai bisogno di almeno 2 server con Rocky8:

    * il primo sarà la **macchina di gestione**, Ansible sarà installato su di esso.
    * il secondo sarà il server da configurare e gestire (un altro Linux diverso da Rocky Linux andrà altrettanto bene).

    Negli esempi seguenti, la stazione di amministrazione ha l'indirizzo IP 172.16.1.10, la stazione gestita 172.16.1.11. Sta a voi adattare gli esempi in base al vostro piano di indirizzamento IP.

## Il vocabolario Ansible

* La **macchina di gestione**: la macchina su cui è installato Ansible. Dal momento che Ansible è **agentless**, nessun software viene distribuito sui server gestiti.
* I **nodi gestiti**: i dispositivi di destinazione che Ansible gestisce sono anche chiamati "host" Possono essere server, dispositivi di rete o qualsiasi altro computer.
* L'**inventory**: un file contenente informazioni sui server gestiti.
* I **tasks**: un task è un blocco che definisce una procedura da eseguire (ad esempio, creare un utente o un gruppo, installare un pacchetto software, ecc.).
* Un **module**: un modulo astrae un compito. Esistono molti moduli forniti da Ansible.
* I **playbook**: un semplice file in formato yaml che definisce i server di destinazione e i compiti da eseguire.
* Un **role**: un role consente di organizzare i playbook e tutti gli altri file necessari (modelli, script, ecc.) per facilitare la condivisione e il riutilizzo del codice.
* Una **collection**: una collezione comprende un insieme logico di playbook, ruoli, moduli e plugin.
* I **facts**: sono variabili globali che contengono informazioni sul sistema (nome della macchina, versione del sistema, interfaccia di rete e configurazione, ecc.).
* Gli **handler**: sono utilizzati per causare l'arresto o il riavvio di un servizio in caso di modifica.

## Installazione sul server di gestione

Ansible è disponibile nel repository _EPEL_, ma a volte può essere datato per la versione corrente e si desidera lavorare con una versione più recente.

Prenderemo quindi in considerazione due tipi di installazione:

* quella basata sui repository EPEL
* una basata sul gestore di pacchetti python `pip`

L'_EPEL_ è necessario per entrambe le versioni, quindi potete procedere all'installazione:

* Installazione di EPEL:

```
$ sudo dnf install epel-release
```

### Installazione da EPEL

Se installiamo Ansible da _EPEL_, possiamo fare quanto segue:

```
$ sudo dnf install ansible
```

Successivamente, verificare l'installazione:

```
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

Si noti che ansible viene fornito con una propria versione di python, diversa da quella di sistema (qui 3.11.2 contro 3.6.8). È necessario considerarlo quando si installano con pip i moduli python necessari per l'installazione (ad esempio `pip3.11 install PyVMomi`).

### Installazione da python pip

Poiché vogliamo usare una versione più recente di Ansible, la installeremo da `python3-pip`:

!!! Note "Nota"

    Rimuovere Ansible se è stato installato in precedenza da _EPEL_.

In questa fase, possiamo scegliere di installare ansible con la versione di python che desideriamo.

```
$ sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! Note "Nota"

    `python3-argcomplete' è fornito da _EPEL_. Installare epel-release se non è ancora stato fatto.
    Questo pacchetto vi aiuterà a completare i comandi di Ansible.

Ora possiamo installare Ansible:

```
$ pip3.8 install --user ansible
$ activate-global-python-argcomplete --user
```

Controllare la versione di Ansible:

```
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

!!! NOTE "Nota"

    La versione installata manualmente nel nostro caso è più vecchia della versione pacchettizzata da RPM perché abbiamo usato una versione precedente di python. Questa osservazione varia con il tempo, l'età della distribuzione e la versione di python.

## File di configurazione

La configurazione del server si trova in `/etc/ansible`.

I file di configurazione principali sono due:

* Il file di configurazione principale `ansible.cfg` dove risiedono i comandi, i moduli, i plugin e la configurazione ssh;
* Il file di inventario della gestione dei computer client `hosts` in cui sono dichiarati i client e i gruppi di client.

Il file di configurazione viene creato automaticamente se Ansible è stato installato con il suo pacchetto RPM. Con un'installazione `pip`, questo file non esiste. Dovremo crearlo a mano con il comando `ansible-config`:

```
$ ansible-config -h
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

Visualizzare la configurazione di ansibile.

argomenti di posizione:
  {list,dump,view,init}
    list Stampa tutte le opzioni di configurazione
    dump Configurazione Dump
    view Visualizza i file di configurazione
    init Crea configurazione iniziale
```

Esempio:

```
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

L'opzione `--disabled` consente di commentare l'insieme delle opzioni anteponendo ad esse il prefisso `;`.

!!! NOTE "Nota"

    Si può anche scegliere di incorporare la configurazione di Ansible nel proprio repository di codice, con Ansible che carica i file di configurazione che trova nel seguente ordine (elaborando il primo file che incontra e ignorando gli altri):

    * se la variabile d'ambiente `$ANSIBLE_CONFIG` è impostata, carica il file specificato.
    * `ansible.cfg` se esiste nella directory corrente.
    * `~/.ansible.cfg` se esiste (nella home directory dell'utente).

    Se non viene trovato nessuno di questi tre file, viene caricato il file predefinito.

### Il file di inventario `/etc/ansible/hosts`

Poiché Ansible dovrà lavorare con tutte le macchine configurate, è essenziale fornirgli uno (o più) file di inventario ben strutturati che corrispondano perfettamente alla vostra organizzazione.

A volte è necessario riflettere attentamente su come costruire questo file.

Andare al file di inventario predefinito, che si trova in `/etc/ansible/hosts`. Vengono forniti alcuni esempi commentati:

```
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

Come si può notare, il file fornito come esempio utilizza il formato INI, ben noto agli amministratori di sistema. Si noti che è possibile scegliere un altro formato di file (come yaml, per esempio), ma per i primi test il formato INI si adatta bene ai nostri prossimi esempi.

L'inventario può essere generato automaticamente in produzione, soprattutto se si dispone di un ambiente di virtualizzazione come VMware VSphere o di un ambiente cloud (Aws, OpenStack o altro).

* Creare un gruppo di host in `/etc/ansible/hosts`:

Come avrete notato, i gruppi sono dichiarati tra parentesi quadre. Poi vengono gli elementi che appartengono ai gruppi. Si può creare, ad esempio, un gruppo `rocky8` inserendo il seguente blocco nel file:

```
[rocky8]
172.16.1.10
172.16.1.11
```

I gruppi possono essere utilizzati all'interno di altri gruppi. In questo caso, occorre specificare che il gruppo padre è composto da sottogruppi con l'attributo `:children`, come in questo caso:

```
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

Non ci dilungheremo oltre sull'inventario, ma se siete interessati, valutate la possibilità di consultare [questo link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Ora che il nostro server di gestione è installato e il nostro inventario è pronto, è il momento di eseguire i nostri primi comandi `ansible`.

## utilizzo della riga di comando `ansibile`

Il comando `ansible` lancia un task su uno o più host di destinazione.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Esempi:

!!! Warning "Attenzione"

    Dal momento che non abbiamo ancora configurato l'autenticazione sui nostri 2 server di test, non tutti gli esempi seguenti funzioneranno. Sono forniti come esempi per facilitare la comprensione e saranno completamente funzionanti più avanti in questo capitolo.

* Elenca gli host appartenenti al gruppo rocky8:

```
ansible rocky8 --list-hosts
```

* Eseguire il ping di un gruppo di host con il modulo `ping`:

```
ansible rocky8 -m ping
```

* Visualizzare i fatti di un gruppo di host con il modulo `setup`:

```
ansible rocky8 -m setup
```

* Eseguire un comando su un gruppo di host invocando il modulo `command` con degli argomenti:

```
ansible rocky8 -m command -a 'uptime'
```

* Eseguire un comando con privilegi di amministratore:

```
ansible ansible_clients --become -m command -a 'reboot'
```

* Eseguire un comando utilizzando un file di inventario personalizzato:

```
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! Note "Nota"

    Come in questo esempio, a volte è più semplice separare la dichiarazione dei dispositivi gestiti in diversi file (ad esempio per progetto cloud) e fornire ad Ansible il percorso di questi file, piuttosto che mantenere un lungo file di inventario.

| Opzione                  | Informazione                                                                                                    |
| ------------------------ | --------------------------------------------------------------------------------------------------------------- |
| `-a 'arguments'`         | Gli argomenti da passare al modulo.                                                                             |
| `-b -K`                  | Richiede una password ed esegue il comando con privilegi superiori.                                             |
| `--user=username`        | Utilizza questo utente per connettersi all'host di destinazione invece dell'utente corrente.                    |
| `--become-user=username` | Esegue l'operazione come questo utente (predefinito: `root`).                                                   |
| `-C`                     | Simulazione. Non apporta alcuna modifica all'obiettivo, ma lo prova per vedere cosa dovrebbe essere modificato. |
| `-m module`              | Esegue il modulo chiamato                                                                                       |

### Preparazione del client

Sia sulla macchina di gestione che sui client, creeremo un utente `ansible` dedicato alle operazioni eseguite da Ansible. Questo utente dovrà utilizzare i diritti di sudo, quindi dovrà essere aggiunto al gruppo `wheel`.

Questo utente servirà:

* Sul lato della stazione di amministrazione: per eseguire comandi `ansible` e SSH ai client gestiti.
* Sulle stazioni gestite (qui il server che funge da stazione di amministrazione funge anche da client, quindi è gestito da solo) per eseguire i comandi lanciati dalla stazione di amministrazione: deve quindi avere i diritti sudo.

Su entrambe le macchine, creare un utente `ansible`, dedicato ad ansible:

```
$ sudo useradd ansible
$ sudo usermod -aG wheel ansible
```

Impostare una password per questo utente:

```
$ sudo passwd ansible
```

Modificare la configurazione di sudoers per consentire ai membri del gruppo `wheel` di eseguire sudo senza password:

```
$ sudo visudo
```

Il nostro obiettivo è commentare l'opzione predefinita e decommentare l'opzione NOPASSWD, in modo che queste righe abbiano l'aspetto seguente:

```
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! Warning "Attenzione"

    Se si riceve il seguente messaggio di errore quando si inseriscono i comandi di Ansible, probabilmente significa che si è dimenticato questo passaggio su uno dei client:
    `"msg": " Missing sudo password"`

Quando si utilizza la gestione da questo momento in poi, si inizia a lavorare con questo nuovo utente:

```
$ sudo su - ansible
```

### Verifica con il modulo ping

Per impostazione predefinita, il login con password non è consentito da Ansible.

Togliere il commento alla seguente riga dalla sezione `[defaults]` del file di configurazione `/etc/ansible/ansible.cfg` e impostarla su True:

```
ask_pass      = True
```

Eseguire un `ping` su ogni server del gruppo rocky8:

```
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

!!! Note "Nota"

    Viene richiesta la password `ansible` dei server remoti, il che rappresenta un problema di sicurezza...

!!! Tip "Suggerimento"

    Se si ottiene questo errore `"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"`, è sufficiente installare `sshpass` sulla stazione di gestione:

    ```
    $ sudo dnf install sshpass
    ```

!!! Abstract "In astratto"

    Ora puoi testare i comandi che non hanno funzionato in precedenza in questo capitolo.

## Autenticazione con chiave

L'autenticazione tramite password sarà sostituita da un'autenticazione a chiave privata/pubblica molto più sicura.

### Creazione di una chiave SSH

La doppia chiave sarà generata con il comando `ssh-keygen` sulla stazione di gestione dall'utente `ansible`:

```
[ansible]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
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

La chiave pubblica può essere copiata sui server:

```
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

Ricommentare la seguente riga dalla sezione `[defaults]` del file di configurazione `/etc/ansible/ansible.cfg` per impedire l'autenticazione tramite password:

```
#ask_pass      = True
```

### Test di autenticazione con chiave privata

Per il prossimo test, viene utilizzato il modulo `shell`, che consente l'esecuzione di comandi remoti:

```
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Non è richiesta alcuna password, l'autenticazione a chiave privata/pubblica funziona!

!!! Note "Nota"

    Nell'ambiente di produzione, si dovrebbero ora rimuovere le password `ansible` precedentemente impostate per rafforzare la sicurezza (poiché ora non è necessaria una password di autenticazione).

## Usare Ansible

Ansible può essere utilizzato dalla shell o tramite playbook.

### I moduli

L'elenco dei moduli classificati per categoria può essere [trovato qui](https://docs.ansible.com/ansible/latest/collections/index_module.html). Ansible ne offre più di 750!

I moduli sono ora raggruppati in raccolte di moduli, il cui elenco può essere [trovato qui](https://docs.ansible.com/ansible/latest/collections/index.html).

Le collezioni sono un formato di distribuzione per i contenuti di Ansible che possono includere playbook, ruoli, moduli e plugin.

Un modulo viene invocato con l'opzione `-m` del comando `ansible`:

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

C'è un modulo per quasi tutte le necessità! Si consiglia quindi, invece di utilizzare il modulo shell, di cercare un modulo adatto alle esigenze.

Ogni categoria di esigenze ha un proprio modulo. Ecco un elenco non esaustivo:

| Tipo                  | Esempi                                                    |
| --------------------- | --------------------------------------------------------- |
| Gestione Sistema      | `user` (gestione utenti), `group` (gestione gruppi), ecc. |
| Gestione del software | `dnf`,`yum`, `apt`, `pip`, `npm`                          |
| Gestione file         | `copy`, `fetch`, `lineinfile`, `template`, `archive`      |
| Gestione database     | `mysql`, `postgresql`, `redis`                            |
| Gestione cloud        | `amazon S3`, `cloudstack`, `openstack`                    |
| Gestione cluster      | `consul`, `zookeeper`                                     |
| Invia comandi         | `shell`, `script`, `expect`                               |
| Downloads             | `get_url`                                                 |
| Gestione sorgenti     | `git`, `gitlab`                                           |

#### Esempio di installazione software

Il modulo `dnf` consente di installare il software sui client di destinazione:

```
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

Essendo il software installato un servizio, è necessario avviarlo con il modulo `systemd`:

```
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

!!! Tip "Suggerimento"

    Provate a lanciare gli ultimi due comandi due volte. Si noterà che la prima volta Ansible intraprenderà delle azioni per raggiungere lo stato impostato dal comando. La seconda volta, non farà nulla perché avrà rilevato che lo stato è già stato raggiunto!

### Esercizi

Per scoprire di più su Ansible e per abituarsi a consultare la documentazione di Ansible, ecco alcuni esercizi da fare prima di proseguire:

* Creare i gruppi Parigi, Tokio, NewYork
* Creare l'utente `supervisor`
* Cambiare l'utente per avere un uid di 10000
* Cambia l'utente in modo che appartenga al gruppo Parigi
* Installare il software ad albero
* Ferma il servizio di crond
* Creare un file vuoto con i permessi `0644`
* Aggiorna la distribuzione del client
* Riavvia il tuo client

!!! Warning "Attenzione"

    Non utilizzare il modulo shell. Cercate nella documentazione i moduli appropriati!

#### modulo `setup`: introduzione ai fatti

I fatti di sistema sono variabili recuperate da Ansible tramite il suo modulo `setup`.

Date un'occhiata ai diversi fatti dei vostri client per avere un'idea della quantità di informazioni che possono essere facilmente recuperate con un semplice comando.

Vedremo più tardi come utilizzare i fatti nei nostri playbook e come creare i nostri fatti.

```
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

Ora che abbiamo visto come configurare un server remoto con Ansible dalla riga di comando, saremo in grado di introdurre la nozione di playbook. I playbook sono un altro modo di utilizzare Ansible, non molto più complesso, ma che renderà più facile il riutilizzo del codice.

## Playbooks

I playbook di Ansible descrivono una politica da applicare ai sistemi remoti, per forzarne la configurazione. I playbook sono scritti in un formato di testo facilmente comprensibile che raggruppa un insieme di attività: il formato `yaml`.

!!! Note "Nota"

    Ulteriori informazioni su [yaml qui](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)

```
ansible-playbook <file.yml> ... [options]
```

Le opzioni sono identiche al comando `ansible`.

Il comando restituisce i seguenti codici di errore:

| Codice | Errore                              |
| ------ | ----------------------------------- |
| `0`    | OK o nessun host corrispondente     |
| `1`    | Errore                              |
| `2`    | Uno o più host hanno fallito        |
| `3`    | Uno o più host sono irraggiungibili |
| `4`    | Analizzare errore                   |
| `5`    | Opzioni errate o incomplete         |
| `99`   | Esecuzione interrotta dall'utente   |
| `250`  | Errore inaspettato                  |

!!! Note "Nota"

    Si noti che `ansible` restituirà Ok quando nessun host corrisponde al target, il che potrebbe trarre in inganno!

### Esempio di playbook Apache e MySQL

Il seguente playbook ci permetterà di installare Apache e MariaDB sui nostri server di destinazione.

Crea un file `test.yml` con il seguente contenuto:

```
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

* <1> Il gruppo o il server in questione devono esistere nell'inventario
* <2> Una volta connesso, l'utente diventa `root` (tramite `sudo` per impostazione predefinita)

L'esecuzione del playbook avviene con il comando `ansible-playbook`:

```
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

Per una maggiore leggibilità, è consigliabile scrivere i playbook in formato yaml completo. Nell'esempio precedente, gli argomenti sono indicati sulla stessa riga del modulo, con il valore dell'argomento che segue il suo nome separato da un `=`. Guardate lo stesso playbook in yaml completo:

```
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

!!! Tip "Suggerimento"

    `dnf` è uno dei moduli che permette di fornire un elenco come argomento.

Nota sulle collezioni: Ansible ora fornisce moduli sotto forma di collezioni. Alcuni moduli sono forniti di default nella collezione `ansible.builtin`, altri devono essere installati manualmente tramite il:

```
ansible-galaxy collection install [collectionname]
```
dove [collectionname] è il nome dell'insieme (le parentesi quadre servono a evidenziare la necessità di sostituirlo con il nome effettivo dell'insieme e NON fanno parte del comando).

L'esempio precedente dovrebbe essere scritto come segue:

```
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

Un playbook non è limitato a un obiettivo:

```
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

Puoi controllare la sintassi del tuo playbook:

```
$ ansible-playbook --syntax-check play.yml
```

È anche possibile utilizzare un "linter" per yaml:

```
$ dnf install -y yamllint
```

quindi controllare la sintassi yaml dei tuoi playbook:

```
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Risultati degli esercizi

* Creare i gruppi Parigi, Tokio, NewYork
* Creare l'utente `supervisor`
* Cambiare l'utente per avere un uid di 10000
* Cambiare l'utente in modo che appartenga al gruppo Parigi
* Installare l'albero del software
* Fermare il servizio crond
* Creare un file vuoto con i permessi `0644`
* Aggiornare la distribuzione del client
* Riavviare il tuo client

```
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
