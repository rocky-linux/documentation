---
title: Nozioni di base su Ansible
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Franco Colussi
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

Poiché Ansible è basato sui push, non manterrà lo stato dei server di destinazione tra ciascuna delle sue esecuzioni. Al contrario, eseguirà nuovi controlli di stato ogni volta che viene eseguito. Si dice che sia senza stato.

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

!!! Abstract "Astratto"

    Per seguire questa formazione, avrai bisogno di almeno 2 server con Rocky8:

    * il primo sarà la **macchina di gestione**, Ansible sarà installato su di esso.
    * il secondo sarà il server da configurare e gestire (un altro Linux diverso da Rocky Linux andrà altrettanto bene).

    Negli esempi seguenti, la stazione di amministrazione ha l'indirizzo IP 172.16.1.10, la stazione gestita 172.16.1.11. Sta a voi adattare gli esempi in base al vostro piano di indirizzamento IP.

## Il vocabolario Ansible

* La **macchina di gestione**: la macchina su cui è installato Ansible. Dal momento che Ansible è **agentless**, nessun software viene distribuito sui server gestiti.
* L'**Inventario**: un file contenente informazioni sui server gestiti.
* Le **attività**: un'attività è un blocco che definisce una procedura da eseguire (es. crea un utente o un gruppo, installa un pacchetto software, ecc.).
* Un **modulo**: un modulo astrae un compito. Ci sono molti moduli forniti da Ansible.
* I **playbook**: un semplice file in formato yaml che definisce i server di destinazione e le attività da eseguire.
* Un **ruolo**: un ruolo ti permette di organizzare i playbook e tutti gli altri file necessari (modelli, script, ecc.) per facilitare la condivisione e il riutilizzo del codice.
* Una **collezione**: una collezione comprende un insieme logico di playbook, ruoli, moduli e plugin.
* I **fatti**: queste sono variabili globali contenenti informazioni sul sistema (nome macchina, versione di sistema, interfaccia di rete e configurazione, ecc.).
* Gli **handlers**: questi sono utilizzati per far arrestare o riavviare un servizio in caso di cambiamento.

## Installazione sul server di gestione

Ansible è disponibile nel repository _EPEL_ ma è disponibile come versione 2.9.21, che è abbastanza datata. Puoi vedere come si fa seguendo qui, ma salta i passi dell'installazione vera e propria, dato che installeremo l'ultima versione. L'_EPEL_ è richiesto per entrambe le versioni, quindi puoi andare avanti e installarlo ora:

* Installazione EPEL:

```
$ sudo dnf install epel-release
```
Se stessimo installando Ansible dall'_EPEL_ potremmo fare quanto segue:

```
$ sudo dnf install ansible
$ ansible --version
2.9.21
```
Poiché vogliamo utilizzare una nuova versione di Ansible, la installeremo da `python3-pip`:

!!! Note "Nota"

    Rimuovi Ansible se l'hai installato in precedenza da _EPEL_.

```
$ sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! Note "Nota"

    `python3-argcomplete` è fornito da _EPEL_. Per favore installa epel-release se non l'hai ancora fatto.
    Questo pacchetto ti aiuterà a completare i comandi Ansible.

Prima di installare Ansible, dobbiamo dire a Rocky Linux che vogliamo utilizzare la nuova versione installata di Python. Il motivo è che se continuiamo l'installazione senza questo, verrà usato il python3 di default (versione 3.6 al momento in cui scriviamo), invece della nuova versione 3.8 appena installata. Imposta la versione che vuoi usare inserendo il seguente comando:

```
sudo alternatives --set python /usr/bin/python3.8
sudo alternatives --set python3 /usr/bin/python3.8
```

Possiamo ora installare Ansible:

```
$ sudo pip3 install ansible
$ sudo activate-global-python-argcomplete
```

Controlla la tua versione Ansibile:

```
$ ansible --version
ansible [core 2.11.2]
  config file = None
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ansible/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.6 (default, Jun 29 2021, 21:14:45) [GCC 8.4.1 20200928 (Red Hat 8.4.1-1)]
  jinja version = 3.0.1
  libyaml = True
```

## File di configurazione

La configurazione del server si trova sotto `/etc/ansible`.

Ci sono due file di configurazione principali:

* Il file di configurazione principale `ansible.cfg` dove risiedono i comandi, moduli, plugin e configurazione ssh;
* Il file di inventario di gestione delle macchine client `hosts` dove vengono dichiarati i client e i gruppi di client.

Poichè abbiamo installato Ansible con `pip`, questi file non esistono. Dovremo crearli a mano.

Un esempio di `ansible.cfg` lo puoi trovare [qui](https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg) e un esempio di file `host` [qui](https://github.com/ansible/ansible/blob/devel/examples/hosts).

```
$ sudo mkdir /etc/ansible
$ sudo curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
$ sudo curl -o /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts
```

È inoltre possibile utilizzare il comando `ansible-config` per generare un nuovo file di configurazione:

```
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

L'opzione `--disabled` consente di commentare l'insieme delle opzioni prefissandole con un `;`.

### Il file di inventario `/etc/ansible/hosts`

Poichè Ansible dovrà lavorare con tutte le vostre apparecchiature, per essere configurato, è molto importante fornirgli uno (o più) file di inventario ben strutturati, che corrispondano perfettamente alla tua organizzazione.

A volte è necessario riflettere attentamente su come costruire questo file.

Vai al file di inventario predefinito, che si trova sotto `/etc/ansible/hosts`. Vengono forniti alcuni esempi e commentati:

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

Come potete vedere, il file fornito come esempio utilizza il formato INI, che è ben noto agli amministratori di sistema. Si prega di notare che è possibile scegliere un altro formato di file (come yaml per esempio), ma per i primi test, il formato INI si adatta bene ai nostri futuri esempi.

Ovviamente, in produzione, l'inventario può essere generato automaticamente, specialmente se si dispone di un ambiente di virtualizzazione come VMware VSphere o un ambiente cloud (Aws, Openstack o altro).

* Creazione di un hostgroup in `/etc/ansible/hosts`:

Come avrete notato, i gruppi sono dichiarati tra parentesi quadre. Poi vengono gli elementi appartenenti ai gruppi. Puoi creare, ad esempio, un gruppo `rocky8` inserendo il seguente blocco in questo file:

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

Non andremo oltre per il momento sul tema dell'inventario, ma se siete interessati, considerate di dare un'occhiata a [questo link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Ora che il nostro server di gestione è installato e il nostro inventario è pronto, è il momento di eseguire i nostri primi comandi `ansible`.

## utilizzo della riga di comando `ansibile`

Il comando `ansible` lancia un'attività su uno o più host di destinazione.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Esempi:

!!! Warning "Attenzione"

    Dal momento che non abbiamo ancora configurato l'autenticazione sui nostri 2 server di test, non tutti gli esempi seguenti funzioneranno. Essi sono forniti come esempi per facilitare la comprensione e saranno pienamente operativi in un secondo momento in questo capitolo.

* Elenca gli host appartenenti al gruppo rocky8:

```
ansible rocky8 --list-hosts
```

* Ping un gruppo host con il modulo `ping`:

```
ansible rocky8 -m ping
```

* Visualizza i fatti da un gruppo host con il modulo `setup`:

```
ansible rocky8 -m setup
```

* Esegue un comando su un gruppo host invocando il modulo `command` con argomenti:

```
ansible rocky8 -m command -a 'uptime'
```

* Esegue un comando con privilegi di amministratore:

```
ansible ansible_clients --become -m command -a 'reboot'
```

* Esegue un comando utilizzando un file di inventario personalizzato:

```
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! Note "Nota"

    Come in questo esempio, è a volte più semplice separare la dichiarazione dei dispositivi gestiti in diversi file (per esempio per progetto cloud) e fornire ad Ansible il percorso di questi file, piuttosto che mantenere un lungo file di inventario.

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

Questo utente verrà utilizzato:

* Sul lato della stazione di amministrazione: per eseguire comandi `ansible` via ssh ai client gestiti.
* Nelle stazioni gestite (qui il server che funge da stazione di amministrazione serve anche come client, cioè è gestito da se) per eseguire i comandi lanciati dalla stazione di amministrazione: deve quindi avere i diritti sudo.

Su entrambe le macchine, creare un utente `ansible`, dedicato ad ansible:

```
$ sudo useradd ansible
$ sudo usermod -aG wheel ansible
```

Imposta una password per questo utente:

```
$ sudo passwd ansible
```

Modifica la configurazione dei sudoers per consentire ai membri del gruppo `wheel` di eseguire sudo senza password:

```
$ sudo visudo
```

Il nostro obiettivo qui è quello di commentare il default, e decommentare l'opzione NOPASSWD in modo che queste linee assomiglino a questo una volta finito:

```
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! Warning "Attenzione"

    Se si riceve il seguente messaggio di errore quando si inseriscono i comandi Ansible probabilmente significa che hai dimenticato questo passo su uno dei tuoi client:
    `"msg": "Missing sudo password`

Quando usate la gestione da questo punto in poi, iniziate a lavorare con questo nuovo utente:

```
$ sudo su - ansible
```

### Verifica con il modulo ping

Per impostazione predefinita, l'accesso con password non è consentito da Ansible.

Decommenta la riga seguente dalla sezione `[defaults]` nel file di configurazione `/etc/ansible/ansible.cfg` e impostala su True:

```
ask_pass      = True
```

Esegue un ping `` su ogni server del gruppo rocky8:

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

    Ti viene richiesta la password `ansible` dei server remoti, che è un problema di sicurezza...

!!! Tip "Suggerimento"

    Se ottieni questo errore `"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program""`, puoi semplicemente installare `sshpass` sulla stazione di gestione:

    ```
    $ sudo dnf install sshpass
    ```

!!! Abstract "Astratto"

    Ora puoi testare i comandi che non hanno funzionato in precedenza in questo capitolo.

## Autenticazione con chiave

L'autenticazione con password sarà sostituita da un'autenticazione a chiave privata e pubblica molto più sicura.

### Creazione di una chiave SSH

Il dual-key verrà generato con il comando `ssh-keygen` sulla stazione di gestione dall'utente `ansible`:

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

Ricommenta la seguente riga dalla sezione `[defaults]` nel file di configurazione `/etc/ansible/ansible.cfg` per impedire l'autenticazione con password:

```
#ask_pass      = True
```

### Test di autenticazione con chiave privata

Per il prossimo test, viene utilizzato il modulo `shell`, che consente l'esecuzione remota dei comandi:

```
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Nessuna password è richiesta, l'autenticazione a chiave privata/pubblica funziona!

!!! Note "Nota"

    In un ambiente di produzione, dovresti rimuovere le password `ansible` precedentemente impostate per far rispettare la tua sicurezza (in quanto ora non è necessaria una password di autenticazione).

## Usare Ansible

Ansible può essere utilizzato dalla shell o tramite playbook.

### I moduli

L'elenco dei moduli classificati per categoria può essere [trovato qui](https://docs.ansible.com/ansible/latest/collections/index_module.html). Ansible ne offre più di 750!

I moduli sono ora raggruppati in collezioni di moduli, un elenco dei quali può essere [trovato qui](https://docs.ansible.com/ansible/latest/collections/index.html).

Le collezioni sono un formato di distribuzione per i contenuti Ansible che possono includere libri di gioco, ruoli, moduli e plugin.

Un modulo viene invocato con l'opzione `-m` del comando `ansible`:

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

C'è un modulo per quasi tutte le necessità! Si consiglia quindi, invece di utilizzare il modulo shell, di cercare un modulo adatto alle esigenze.

Ogni categoria di necessità ha un suo modulo. Ecco un elenco non esaustivo:

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

Il modulo `dnf` consente l'installazione di software sui client di destinazione:

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

Il software installato è un servizio, ora è necessario avviarlo con il modulo `systemd`:

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

    Prova a lanciare gli ultimi 2 comandi due volte. Osserverai che la prima volta che Ansible intraprenderà azioni per raggiungere lo stato impostato dal comando. La seconda volta, non farà nulla perché avrà rilevato che lo stato è già raggiunto!

### Esercizi

Per aiutarti a scoprire di più su Ansible e per abituarti alla ricerca della documentazione Ansible ecco alcuni esercizi che puoi fare prima di continuare:

* Creare i gruppi Parigi, Tokio, NewYork
* Creare l'utente `supervisor`
* Cambiare l'utente per avere un uid di 10000
* Cambia l'utente in modo che appartenga al gruppo Parigi
* Installare il software ad albero
* Ferma il servizio di crond
* Crea un file vuoto con i permessi `644`
* Aggiorna la distribuzione del client
* Riavvia il tuo client

!!! Warning "Attenzione"

    Non usare il modulo di shell. Cerca nella documentazione i moduli appropriati!

#### modulo `setup`: introduzione ai fatti

I fatti di sistema sono variabili recuperate da Ansible tramite il suo modulo `setup`.

Dai un'occhiata ai diversi fatti dei tuoi client per avere un'idea della quantità di informazioni che possono essere facilmente recuperate tramite un semplice comando.

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

Ora che abbiamo visto come configurare un server remoto con Ansible dalla riga di comando, saremo in grado di introdurre la nozione di playbook. I playbook sono un altro modo per usare Ansible, che non è molto più complesso, ma che renderà più facile riutilizzare il codice.

## Playbooks

I playbook di Ansible descrivono un criterio da applicare ai sistemi remoti, per forzare la loro configurazione. I playbook sono scritti in un formato di testo facilmente comprensibile che raggruppa una serie di compiti: il formato `yaml`.

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

    Si prega di notare che `ansible` restituirà Ok quando non c'è un host corrispondente al tuo target, il che potrebbe ingannarti!

### Esempio di playbook Apache e MySQL

Il seguente playbook ci permette di installare Apache e MariaDB sui nostri server di destinazione.

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

* <1> Il gruppo di destinatari o il server di destinazione deve esistere nell'inventario
* <2> Una volta connesso, l'utente diventa `root` (tramite `sudo` per impostazione predefinita)

L'esecuzione del playbook viene fatta con il comando `ansible-playbook`:

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

Per una maggiore leggibilità, si consiglia di scrivere i tuoi playbook in formato yaml completo. Nell’esempio precedente, gli argomenti sono riportati sulla stessa linea del modulo, il valore dell'argomento che segue il nome separato da un `=`. Guarda lo stesso playbook in yaml completo:

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

    `dnf` è uno dei moduli che consentono di dargli una lista come argomento.

Nota sulle collezioni: Ansible ora fornisce moduli sotto forma di collezioni. Alcuni moduli sono forniti di default nella collezione `ansible.builtin`, altri devono essere installati manualmente tramite il:

```
ansible-galaxy collection install [collectionname]
```
dove [collectionname] è il nome della collezione (le parentesi quadre qui sono usate per evidenziare la necessità di sostituirla con un nome di collezione effettivo; e NON fanno parte del comando).

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

quindi controlla la sintassi yaml dei tuoi playbook:

```
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Risultati degli esercizi

* Creare i gruppi Parigi, Tokio, NewYork
* Creare l'utente `supervisor`
* Cambiare l'utente per avere un uid di 10000
* Cambia l'utente in modo che appartenga al gruppo Parigi
* Installare il software ad albero
* Ferma il servizio di crond
* Crea un file vuoto con i permessi `0644`
* Aggiorna la distribuzione del client
* Riavvia il tuo client

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
