---
title: Infrastrutture su larga scala
---

# Ansible - Infrastrutture su larga scala

In questo capitolo imparerai come ridimensionare il tuo sistema di gestione delle configurazioni.

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: Organizzare il tuo codice per un'infrastruttura di grandi dimensioni;   
:heavy_check_mark: Applicare tutto o parte della tua gestione di configurazione a un gruppo di nodi;

:checkered_flag: **ansible**, **config management**, **scale**

**Conoscenza**: :star: :star: :star:       
**Complessità**: :star: :star: :star: :star:

**Tempo di lettura**: 30 minuti

****

Abbiamo visto nei capitoli precedenti come organizzare il nostro codice sotto forma di ruoli ma anche come utilizzare alcuni ruoli per la gestione degli aggiornamenti (patch management) o la distribuzione del codice.

Che dire della gestione della configurazione? Come gestire la configurazione di dieci, centinaia, o anche migliaia di macchine virtuali con Ansible?

L'avvento del cloud ha cambiato un po' i metodi tradizionali. La VM è configurata al momento della distribuzione. Se la sua configurazione non è più conforme, viene distrutta e sostituita da una nuova.

L'organizzazione del sistema di gestione della configurazione presentato in questo capitolo risponderà a questi due modi di consumare IT: "uso one-shot" o regolare "riconfigurazione" di una flotta.

Tuttavia, attenzione: l'utilizzo di Ansible per garantire la conformità di un pool di server richiede la modifica delle abitudini di lavoro. Non è più possibile modificare manualmente la configurazione di un service manager senza vedere queste modifiche sovrascritte alla prossima esecuzione di Ansible.

!!! Note "Nota"

    Quello che stiamo per impostare qui sotto non è il terreno preferito di Ansible. Tecnologie come Puppet o Salt faranno molto meglio. Ricordiamo che Ansible è un coltello svizzero dell'automazione ed è senza agenti, il che spiega le differenze nelle prestazioni.

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

## Archiviazione variabili

La prima cosa che dobbiamo discutere è la separazione tra i dati e il codice Ansible.

Poiché il codice diventa più grande e più complesso, sarà sempre più complicato modificare le variabili che contiene.

Per garantire la manutenzione del vostro sito, la cosa più importante è separare correttamente le variabili dal codice Ansible.

Non ne abbiamo ancora discusso qui, ma dovresti sapere che Ansible può caricare automaticamente le variabili che trova in cartelle specifiche a seconda del nome dell'inventario del nodo gestito, o i suoi gruppi membri.

La documentazione Ansible suggerisce di organizzare il nostro codice come sotto:

```
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml
```

Se il nodo selezionato è `hostname1` di `group1`, le variabili contenute nei file `hostname1.yml` e `group1.yml` verranno caricate automaticamente. È un bel modo per memorizzare tutti i dati per tutti i tuoi ruoli nello stesso posto.

In questo modo, il file dell'inventario del tuo server diventa la sua carta d'identità. Contiene tutte le variabili che differiscono dalle variabili predefinite per il tuo server.

Dal punto di vista della centralizzazione delle variabili, diventa essenziale organizzare il nome delle sue variabili nei ruoli prefissandole, ad esempio, con il nome del ruolo. Si consiglia anche di utilizzare nomi di variabili flat piuttosto che dizionari.

Ad esempio, se si desidera rendere il valore `PermitRootLogin` nel file `sshd_config` una variabile, un buon nome della variabile potrebbe essere `sshd_config_permitrootlogin` (invece di `sshd.config.permitrootlogin` che potrebbe anche essere un buon nome di variabile).

## Informazioni sui tag ansible

L'uso di tag Ansible ti permette di eseguire o saltare una parte delle attività nel tuo codice.

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

Ad esempio, modifichiamo l'attività di creazione degli utenti:

```
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop:
     - antoine
     - patrick
     - steven
     - xavier
  tags: users
```

Ora puoi riprodurre solo le attività con il tag `users` con l'opzione `ansible-playbook` `--tags`:

```
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

Puoi anche usare l'opzione `--skip-tags`.

## Informazioni sul layout delle directory

Concentriamoci su una proposta per l'organizzazione di file e directory necessari per il corretto funzionamento di un CMS (Content Management System).

Il nostro punto di partenza sarà il file `site.yml`. Questo file è un po 'come il direttore d'orchestra del CMS in quanto includerà solo i ruoli necessari per i nodi di destinazione se necessario:

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Naturalmente, questi ruoli devono essere creati sotto la directory `roles` allo stesso livello del file `site.yml`.

Mi piace gestire i miei vars globali all'interno di un `vars/global_vars.yml`, anche se potrei memorizzarli all'interno di un file situato in `inventories/production/group_vars/all.yml`

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Mi piace inoltre mantenere la possibilità di disabilitare una funzionalità. Quindi includo i miei ruoli con una condizione e un valore predefinito come questo:

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
```

Non dimenticare di usare i tag:


```
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)
      tags:
        - functionality1

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
      tags:
        - functionality2
```

Dovresti ottenere qualcosa di simile:

```
$ tree cms
cms
├── inventories
│   └── production
│       ├── group_vars
│       │   └── plateform.yml
│       ├── hosts
│       └── host_vars
│           ├── client1.yml
│           └── client2.yml
├── roles
│   ├── functionality1
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   └── functionality2
│       ├── defaults
│       │   └── main.yml
│       └── tasks
│           └── main.yml
├── site.yml
└── vars
    └── global_vars.yml
```

!!! Note "Nota"

    Sei libero di sviluppare i tuoi ruoli all'interno di una collezione

## Test

Avviamo il playbook ed eseguiamo alcuni test:

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
skipping: [client1]

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

Come puoi vedere, per impostazione predefinita, vengono giocate solo le attività del ruolo `functionality1`.

Attiviamo nell'inventario la `functionality2` per il nostro nodo mirato e riavviamo il playbook:

```
$ vim inventories/production/host_vars/client1.yml
---
enable_functionality2: true
```


```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Prova ad applicare solo `funzionalità2`:

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" --tags functionality2 site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Eseguiamo l'intero l'inventario:

```
$ ansible-playbook -i inventories/production/hosts -e "target=plateform" site.yml

PLAY [Config Management for plateform] **************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]
ok: [client2]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}
ok: [client2] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}
skipping: [client2]

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
client2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

Come puoi vedere, `functionality2` è riprodotto solo sul `client1`.

## Vantaggi

Seguendo i consigli forniti nella documentazione Ansible otterrete rapidamente un:

* codice sorgente facilmente mantenibile anche se contiene un gran numero di ruoli
* un sistema di conformità relativamente veloce, ripetibile che è possibile applicare parzialmente o completamente
* può essere adattato caso per caso e dai server
* le specifiche del vostro sistema informativo sono separate dal codice, facilmente controllabili, e centralizzate nei file di inventario della vostra gestione della configurazione.
