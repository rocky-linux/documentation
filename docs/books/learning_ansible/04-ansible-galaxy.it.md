---
title: Ansible Galaxy
---

# Galassia Ansibile: Collezioni e Ruoli

In questo capitolo imparerai come usare, installare e gestire ruoli e collezioni Ansible.

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: installare e gestire collezioni;  
:heavy_check_mark: installare e gestire i ruoli.

:checkered_flag: **ansible**, **ansible-galaxy**, **ruoli**, **collezioni**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 40 minuti

****

La [Galassia Ansible](https://galaxy.ansible.com) fornisce Ruoli Ansible e Collezioni della Comunità Ansible.

Gli elementi forniti possono essere referenziati nei playbook e pronti da usare

## comando `ansible-galaxy`

Il comando `ansible-galaxy` gestisce ruoli e collezioni utilizzando [galaxy.ansible.com](http://galaxy.ansible.com).

* Per gestire i ruoli:

```bash
ansible-galaxy role [import|init|install|login|remove|...]
```

| Sotto comandi | Funzionalità                                                       |
| ------------- | ------------------------------------------------------------------ |
| `install`     | installare un ruolo.                                               |
| `remove`      | rimuovere uno o più ruoli.                                         |
| `list`        | mostrare il nome e la versione dei ruoli installati.               |
| `info`        | visualizzare informazioni su un ruolo.                             |
| `init`        | generare uno scheletro di un nuovo ruolo.                          |
| `import`      | importare un ruolo dal sito web della galassia. Richiede un login. |

* Per gestire le collezioni:

```bash
ansible-galaxy collection [import|init|install|login|remove|...]
```

| Sotto comandi | Funzionalità                                                    |
| ------------- | --------------------------------------------------------------- |
| `init`        | generare uno scheletro di una nuova collezione.                 |
| `install`     | installare una collezione.                                      |
| `list`        | visualizzare il nome e la versione delle collezioni installate. |

## Ruoli Ansible

Un ruolo Ansible è un'unità che promuove la riutilizzabilità dei playbook.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

### Installazione di ruoli utili

Al fine di evidenziare l'interesse ad utilizzare i ruoli, vi suggerisco di utilizzare il ruolo `alemorvan/patchmanagement`, che vi permetterà di eseguire un sacco di attività (pre-aggiornamento o post-aggiornamento, per esempio) durante il processo di aggiornamento, in poche righe di codice.

Puoi controllare il codice nel repo github del ruolo [qui](https://github.com/alemorvan/patchmanagement).

* Installare il ruolo. Questo richiede un solo comando:

```bash
ansible-galaxy role install alemorvan.patchmanagement
```

* Creare un playbook per includere il ruolo:

```bash
- name: Start a Patch Management
  hosts: ansible_clients
  vars:
    pm_before_update_tasks_file: custom_tasks/pm_before_update_tasks_file.yml
    pm_after_update_tasks_file: custom_tasks/pm_after_update_tasks_file.yml

  tasks:
    - name: "Include patchmanagement"
      include_role:
        name: "alemorvan.patchmanagement"
```

Con questo ruolo, puoi aggiungere i tuoi compiti per tutto il tuo inventario o solo per il nodo selezionato.

Creiamo delle attività che saranno eseguite prima e dopo il processo di aggiornamento:

* Crea la cartella `custom_tasks`:

```bash
mkdir custom_tasks
```

* Crea `custom_tasks/pm_before_update_tasks_file.yml` (puoi liberamente cambiare il nome e il contenuto di questo file)

```bash
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* Crea `custom_tasks/pm_after_update_tasks_file.yml` (puoi liberamente cambiare il nome e il contenuto di questo file)

```bash
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

E lancia il tuo primo Gestione Patch:

```bash
ansible-playbook patchmanagement.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Include patchmanagement] **************************************************************************

TASK [alemorvan.patchmanagement : MAIN | Linux Patch Management Job] ************************************
ok: [192.168.1.11] => {
    "msg": "Start 192 patch management"
}

...

TASK [alemorvan.patchmanagement : sample task before the update process] ********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

...

TASK [alemorvan.patchmanagement : MAIN | We can now patch] **********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/patch.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : PATCH | Tasks depends on distribution] ********************************
ok: [192.168.1.11] => {
    "ansible_distribution": "Rocky"
}

TASK [alemorvan.patchmanagement : PATCH | Include tasks for CentOS & RedHat tasks] **********************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/linux_tasks/redhat_centos.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : RHEL CENTOS | yum clean all] ******************************************
changed: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Ensure yum-utils is installed] **************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Remove old kernels] *************************************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Update rpm package with yum] ****************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : PATCH | Inlude tasks for Debian & Ubuntu tasks] ***********************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : MAIN | We can now reboot] *********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/reboot.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : REBOOT | Reboot triggered] ********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : REBOOT | Ensure we are not in rescue mode] ****************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : FACTS | Insert fact file] *********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : FACTS | Save date of last PM] *****************************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : sample task after the update process] *********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=31   changed=1    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0  
```

Piuttosto facile per un processo così complesso, vero?

Questo è solo un esempio di ciò che può essere fatto utilizzando i ruoli resi disponibili dalla comunità. Dai un'occhiata a [galaxy.ansible.com](https://galaxy.ansible.com/) per scoprire i ruoli che potrebbero essere utili per te!

Puoi anche creare i tuoi ruoli per le tue esigenze e pubblicarli su Internet se te la senti. Questo è quanto affronteremo brevemente nel prossimo capitolo.

### Introduzione allo sviluppo del ruolo

Uno scheletro di ruolo, che serve come punto di partenza per lo sviluppo di ruolo personalizzato, può essere generato dal comando `ansible-galaxy`:

```bash
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

Il comando genererà la seguente struttura ad albero per contenere il ruolo `rocky8`:

```bash
tree rocky8/
rocky8/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

I ruoli consentono di eliminare la necessità di includere i file. Non c'è bisogno di specificare i percorsi dei file o `includere` direttive nei playbook. Devi solo specificare un compito, e Ansible si occupa delle inclusioni.

La struttura di un ruolo è abbastanza evidente da capire.

Le variabili sono semplicemente memorizzate in `vars/main.yml` se le variabili non devono essere sovrascritte, oppure in `default/main.yml` se vuoi lasciare la possibilità di sovrascrivere il contenuto variabile dall'esterno del tuo ruolo.

I gestori, i file e i modelli necessari per il tuo codice sono memorizzati rispettivamente in `handlers/main.yml`, `files` e `templates`.

Tutto ciò che rimane è definire il codice per le attività del tuo ruolo in `tasks/main.yml`.

Una volta che tutto questo funziona bene, è possibile utilizzare questo ruolo nei tuoi playbook. Sarete in grado di utilizzare il vostro ruolo senza preoccuparvi dell'aspetto tecnico dei suoi compiti, durante la personalizzazione del suo funzionamento con variabili.

### Lavoro pratico: creare un primo ruolo semplice

Implementiamo questo con un ruolo "go anywhere" che creerà un utente predefinito e installerà pacchetti software. Questo ruolo può essere applicato sistematicamente a tutti i tuoi server.

#### Variabili

Creeremo un utente `rockstar` su tutti i nostri server. Poiché non vogliamo che questo utente sia sovrascritto, definiamolo nel `vars/main.yml`:

```bash
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

Ora possiamo usare queste variabili all'interno dei nostri `tasks/main.yml` senza alcuna inclusione.

```bash
---
- name: Create default group
  group:
    name: "{{ rocky8_default_group.name }}"
    gid: "{{ rocky8_default_group.gid }}"

- name: Create default user
  user:
    name: "{{ rocky8_default_user.name }}"
    uid: "{{ rocky8_default_user.uid }}"
    group: "{{ rocky8_default_user.group }}"
```

Per testare il tuo nuovo ruolo, creiamo un playbook `test-role.yml` nella stessa directory del tuo ruolo:

```bash
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

e lancialo:

```bash
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
changed: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Congratulazioni! Ora siete in grado di creare grandi cose con un playbook di solo poche righe.

Vediamo l'uso delle variabili predefinite.

Crea un elenco di pacchetti da installare per impostazione predefinita sui server e un elenco vuoto di pacchetti da disinstallare. Modifica i file `defaults/main.yml` e aggiungi questi due elenchi:

```bash
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

e usali nei tuoi `tasks/main.yml`:

```bash
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

Verifica il tuo ruolo con l'aiuto del playbook precedentemente creato:

```bash
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) []] ***************************************
ok: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Ora puoi sovrascrivere i `rocky8_remove_packages` nel tuo playbook e disinstallare ad esempio `cockpit`:

```bash
---
- name: Test my role
  hosts: localhost
  vars:
    rocky8_remove_packages:
      - cockpit

  roles:

    - role: rocky8
      become: true
      become_user: root
```

```bash
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) ['cockpit']] ******************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Ovviamente, non c'è limite a quanto si può migliorare il proprio ruolo. Immaginate che per uno dei vostri server, avete bisogno di un pacchetto che è nell'elenco di quelli da disinstallare. Si potrebbe quindi, ad esempio, creare una nuova lista che può essere sovrascritta e quindi rimuovere dall'elenco dei pacchetti da disinstallare quelli nell'elenco dei pacchetti specifici da installare utilizzando il filtro jinja `difference()`.

```bash
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Collezioni Ansible

Le collezioni sono un formato di distribuzione per i contenuti Ansible che possono includere libri di gioco, ruoli, moduli e plugin.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)

Per installare o aggiornare una collezione:

```bash
ansible-galaxy collection install namespace.collection [--upgrade]
```

È quindi possibile utilizzare la collezione appena installata usando lo spazio dei nomi e il nome del modulo prima del nome o del ruolo:

```bash
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

Puoi trovare un indice di raccolta [qui](https://docs.ansible.com/ansible/latest/collections/index.html).

Installiamo la collezione `community.general`:

```bash
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

Ora possiamo utilizzare il nuovo modulo disponibile `yum_versionlock`:

```bash
- name: Start a Patch Management
  hosts: ansible_clients
  become: true
  become_user: root
  tasks:

    - name: Ensure yum-versionlock is installed
      package:
        name: python3-dnf-plugin-versionlock
        state: present

    - name: Prevent kernel from being updated
      community.general.yum_versionlock:
        state: present
        name: kernel
      register: locks

    - name: Display locks
      debug:
        var: locks.meta.packages                            
```

```bash
ansible-playbook versionlock.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Ensure yum-versionlock is installed] **************************************************************
changed: [192.168.1.11]

TASK [Prevent kernel from being updated] ****************************************************************
changed: [192.168.1.11]

TASK [Display locks] ************************************************************************************
ok: [192.168.1.11] => {
    "locks.meta.packages": [
        "kernel"
    ]
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

### Creare la propria collezione

Come per i ruoli, puoi creare la tua collezione con l'aiuto del comando `ansible-galaxy`:

```bash
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```bash
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│   └── README.md
├── README.md
└── roles
```

È quindi possibile memorizzare i propri plugin o ruoli all'interno di questa nuova collezione.
