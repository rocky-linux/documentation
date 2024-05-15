---
title: Ansibile Intermedio
---

# Ansibile Intermedio

In questo capitolo si continuerà a imparare a lavorare con Ansible.

****

**Obiettivi**: in questo capitolo imparerete come:

:heavy_check_mark: lavorare con le variabili;  
:heavy_check_mark: usare i cicli;  
:heavy_check_mark: gestire i cambiamenti di stato e reagire a loro;  
:heavy_check_mark: gestire le attività asincrone.

:checkered_flag: **ansible**, **moduli**, **playbook**

**Conoscenza**: :star: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 30 minuti

****

Nel capitolo precedente si è appreso come installare Ansible, utilizzarlo dalla riga di comando e scrivere playbook per promuovere la riutilizzabilità del codice.

In questo capitolo, possiamo iniziare a scoprire nozioni più avanzate su come utilizzare Ansible e alcuni task interessanti che utilizzerete regolarmente.

## Le variabili

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html).

Sotto Ansible, ci sono diversi tipi di variabili primitive:

* stringhe,
* interi,
* booleani.

Queste variabili possono essere organizzate come:

* dizionari,
* elenchi.

Una variabile può essere definita in diversi luoghi, come un playbook, un ruolo o la riga di comando.

Per esempio, da un playbook:

```bash
---
- hosts: apache1
  vars:
    port_http: 80
    service:
      debian: apache2
      rhel: httpd
```

o dalla riga di comando:

```bash
ansible-playbook deploy-http.yml --extra-vars "service=httpd"
```

Una volta definita, una variabile può essere utilizzata chiamandola tra due parentesi graffe:

* `{{ port_http }}` per un valore semplice,
* `{{ service['rhel'] }}` o `{{ service.rhel }}` per un dizionario.

Per esempio:

```bash
- name: make sure apache is started
  ansible.builtin.systemd:
    name: "{{ service['rhel'] }}"
    state: started
```

Naturalmente, è anche possibile accedere alle variabili globali (i **fatti**) di Ansible (tipo di OS, indirizzi IP, nome VM, ecc.).

### Variabili di esternalizzazione

Le variabili possono essere incluse in un file esterno al playbook, in questo caso questo file deve essere definito nel playbook con la direttiva `vars_files`:

```bash
---
- hosts: apache1
  vars_files:
    - myvariables.yml
```

Il file `myvariables.yml`:

```bash
---
port_http: 80
ansible.builtin.systemd::
  debian: apache2
  rhel: httpd
```

Può anche essere aggiunto dinamicamente con l'uso del modulo `include_vars`:

```bash
- name: Include secrets.
  ansible.builtin.include_vars:
    file: vault.yml
```

### Visualizzare una variabile

Per visualizzare una variabile, è necessario attivare il modulo `di debug` come segue:

```bash
- ansible.builtin.debug:
    var: service['debian']
```

È anche possibile utilizzare la variabile all'interno di un testo:

```bash
- ansible.builtin.debug:
    msg: "Print a variable in a message : {{ service['debian'] }}"
```

### Salva il ritorno di un'attività

Per salvare il risultato di un compito e per essere in grado di accedervi più tardi, devi usare la parola chiave `register` all'interno del compito stesso.

Uso di una variabile memorizzata:

```bash
- name: /home content
  shell: ls /home
  register: homes

- name: Print the first directory name
  ansible.builtin.debug:
    var: homes.stdout_lines[0]

- name: Print the first directory name
  ansible.builtin.debug:
    var: homes.stdout_lines[1]
```

!!! Note "Nota"

    La variabile `homes.stdout_lines' è un elenco di variabili di tipo stringa, un modo per organizzare le variabili che non avevamo ancora incontrato.

Le stringhe che compongono la variabile memorizzata possono essere consultate tramite il valore `stdout` (che ti permette di fare cose come `homes.stdout.find("core") != -1`), per sfruttarli usando un ciclo (vedi `loop`), o semplicemente dai loro indici come visto nell'esempio precedente.

### Esercizi:

* Scrivere un playbook, `play-vars.yml,` usando variabili globali che stampino il nome della distribuzione e la versione principale del target.

* Scrivi un playbook usando il seguente dizionario per visualizzare i servizi che verranno installati:

```bash
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Il tipo predefinito dovrebbe essere "web".

* Sovrascrivi la variabile `type` usando la riga di comando

* Esternalizza le variabili in un file `vars.yml`

## Gestione dei cicli

Un ciclo consente di iterare un'operazione su un elenco, un hash o un dizionario, ad esempio.

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html).

Un semplice esempio di utilizzo, la creazione di 4 utenti:

```bash
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
```

Ad ogni iterazione del ciclo, il valore della lista utilizzata viene memorizzato nella variabile `item`, accessibile nel codice del ciclo.

Naturalmente, un elenco può essere definito in un file esterno:

```bash
users:
  - antoine
  - patrick
  - steven
  - xavier
```

ed essere utilizzato all'interno del task in questo modo (dopo aver incluso il file vars):

```bash
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop: "{{ users }}"
```

Possiamo utilizzare l'esempio visto durante lo studio delle variabili memorizzate per migliorarlo. Uso di una variabile memorizzata:

```bash
- name: /home content
  shell: ls /home
  register: homes

- name: Print the directories name
  ansible.builtin.debug:
    msg: "Directory => {{ item }}"
  loop: "{{ homes.stdout_lines }}"
```

Un dizionario può anche essere usato in un ciclo.

In questo caso, è necessario trasformare il dizionario in un elemento con un filtro **jinja** (jinja è il motore di template utilizzato da Ansible): `| dict2items`.

Nel ciclo, è possibile utilizzare `item.key`, che corrisponde alla chiave del dizionario, e `item.value`, che corrisponde ai valori della chiave.

Vediamo questo attraverso un esempio concreto, mostrando la gestione degli utenti del sistema:

```bash
---
- hosts: rocky8
  become: true
  become_user: root
  vars:
    users:
      antoine:
        group: users
        state: present
      steven:
        group: users
        state: absent

  tasks:

  - name: Manage users
    user:
      name: "{{ item.key }}"
      group: "{{ item.value.group }}"
      state: "{{ item.value.state }}"
    loop: "{{ users | dict2items }}"
```

!!! Note "Nota"

    I loop possono essere utilizzati per molte cose. Quando l'uso di Ansible vi spingerà a utilizzarli in modo più complesso, scoprirete le possibilità che offrono.

### Esercizi:

* Visualizza il contenuto della variabile `service` dell'esercizio precedente utilizzando un loop.

!!! Note "Nota"

    Dovrai trasformare la tua variabile `service`, che è un dizionario, in una lista con l'aiuto del filtro jinja `list` in questo modo:

    ```
    {{ service.values() | list }}
    ```

## Condizionali

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

L'istruzione `when` è molto utile in molti casi, ad esempio per non eseguire determinate azioni su certi tipi di server, se un file o un utente non esiste, ecc.

!!! Note "Nota"

    Dietro l'istruzione `when`, le variabili non hanno bisogno di doppie parentesi (sono infatti espressioni Jinja2...).

```bash
- name: "Reboot only Debian servers"
  reboot:
  when: ansible_os_family == "Debian"
```

Le condizioni possono essere raggruppate tra parentesi:

```bash
- name: "Reboot only CentOS version 6 and Debian version 7"
  reboot:
  when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
        (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")
```

Le condizioni corrispondenti a una logica AND possono essere fornite sotto forma di elenco:

```bash
- name: "Reboot only CentOS version 6"
  reboot:
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "6"
```

Puoi testare il valore di un booleano e verificare che sia vero:

```bash
- name: check if directory exists
  stat:
    path: /home/ansible
  register: directory

- ansible.builtin.debug:
    var: directory

- ansible.builtin.debug:
    msg: The directory exists
  when:
    - directory.stat.exists
    - directory.stat.isdir
```

Puoi anche verificare che non sia vero:

```bash
when:
  - file.stat.exists
  - not file.stat.isdir
```

Probabilmente dovrai verificare che esiste una variabile per evitare errori di esecuzione:

```bash
when: myboolean is defined and myboolean
```

### Esercizi:

* Stampa il valore di `service.web` solo quando `type` è uguale a `web`.

## Gestione delle modifiche: gli `handlers`

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html).

Quando si verificano le modifiche, i gestori sono autorizzati a lanciare operazioni, come il riavvio di un servizio.

Un modulo, essendo idempotente, un playbook può rilevare che c'è stato un cambiamento significativo su un sistema remoto e quindi attivare un'operazione in reazione a questo cambiamento. Una notifica viene inviata alla fine di un blocco di attività di playbook e l'operazione di reazione verrà attivata una sola volta, anche se più attività inviano la stessa notifica.

![Gestori](images/handlers.png)

Ad esempio, diverse attività possono indicare che il servizio `httpd` deve essere riavviato a causa di un cambiamento nei suoi file di configurazione. Tuttavia, il servizio verrà riavviato solo una volta per evitare più avvii inutili.

```bash
- name: template configuration file
  template:
    src: template-site.j2
    dest: /etc/httpd/sites-availables/test-site.conf
  notify:
     - restart memcached
     - restart httpd
```

Un gestore è una sorta di compito referenziato da un nome globale unico:

* Uno o più notificatori lo attivano.
* Non inizia immediatamente, ma attende fino a quando tutte le attività sono complete.

Esempio di gestori:

```bash
handlers:

  - name: restart memcached
    systemd:
      name: memcached
      state: restarted

  - name: restart httpd
    systemd:
      name: httpd
      state: restarted
```

Dala versione 2.2 di Ansible, i gestori possono anche ascoltare direttamente:

```bash
handlers:

  - name: restart memcached
    systemd:
      name: memcached
      state: restarted
    listen: "web services restart"

  - name: restart apache
    systemd:
      name: apache
      state: restarted
    listen: "web services restart"

tasks:
    - name: restart everything
      command: echo "this task will restart the web services"
      notify: "web services restart"
```

## Attività asincrone

!!! Note "Nota"

    Ulteriori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html).

Per impostazione predefinita, le connessioni SSH agli host rimangono aperte durante l'esecuzione di varie attività del playbook su tutti i nodi.

Ciò può causare alcuni problemi, in particolare:

* se il tempo di esecuzione dell'attività è più lungo del timeout della connessione SSH
* se la connessione viene interrotta durante l'azione (riavvio del server, ad esempio)

In questo caso, si dovrà passare alla modalità asincrona e specificare un tempo massimo di esecuzione e la frequenza (per impostazione predefinita, 10s) con cui si controllerà lo stato dell'host.

Specificando un valore di misura di 0, Ansible eseguirà l'attività e continuerà senza preoccuparsi del risultato.

Ecco un esempio che utilizza attività asincrone, che consente di riavviare un server e attendere che la porta 22 sia nuovamente raggiungibile:

```bash
# Wait 2s and launch the reboot
- name: Reboot system
  shell: sleep 2 && shutdown -r now "Ansible reboot triggered"
  async: 1
  poll: 0
  ignore_errors: true
  become: true
  changed_when: False

  # Wait the server is available
  - name: Waiting for server to restart (10 mins max)
    wait_for:
      host: "{{ inventory_hostname }}"
      port: 22
      delay: 30
      state: started
      timeout: 600
    delegate_to: localhost
```

Puoi anche decidere di lanciare un'attività di lunga durata e dimenticarla (avvia e dimentica) perché l'esecuzione non ha importanza nel playbook.

## Risultati delle esercitazioni

* Scrivere un playbook, `play-vars.yml, ' usando variabili globali, che stampi il nome della distribuzione del target e la versione principale.

```bash
---
- hosts: ansible_clients

  tasks:

    - name: Print globales variables
      debug:
        msg: "The distribution is {{ ansible_distribution }} version {{ ansible_distribution_major_version }}"
```

```bash
$ ansible-playbook play-vars.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print globales variables] ************************************************************************
ok: [192.168.1.11] => {
    "msg": "The distribution is Rocky version 8"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

* Scrivi un playbook usando il seguente dizionario per visualizzare i servizi che verranno installati:

```bash
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Il tipo predefinito dovrebbe essere "web".

```bash
---
- hosts: ansible_clients
  vars:
    type: web
    service:
      web:
        name: apache
        rpm: httpd
      db:
        name: mariadb
        rpm: mariadb-server

  tasks:

    - name: Print a specific entry of a dictionary
      debug:
        msg: "The {{ service[type]['name'] }} will be installed with the packages {{ service[type].rpm }}"
```

```bash
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a specific entry of a dictionnaire] ********************************************************
ok: [192.168.1.11] => {
    "msg": "The apache will be installed with the packages httpd"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

* Sovrascrivi la variabile `type` usando la riga di comando:

```bash
ansible-playbook --extra-vars "type=db" display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a specific entry of a dictionary] ********************************************************
ok: [192.168.1.11] => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

* Esternalizza le variabili in un file `vars.yml`

```bash
type: web
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

```bash
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a specific entry of a dictionary
      debug:
        msg: "The {{ service[type]['name'] }} will be installed with the packages {{ service[type].rpm }}"
```

* Visualizza il contenuto della variabile `service` dell'esercizio precedente utilizzando un ciclo.

!!! Note "Nota"

    Dovrai trasformare la tua variabile `service`, che è un dizionario, in una lista con l'aiuto del filtro jinja `list` in questo modo:

    ```
    {{ service | dict2items }}
    ```

    ```
    {{ service.values() | list }}
    ```

Con `dict2items`:

```bash
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable with a loop
      debug:
        msg: "{{item.key }} | The {{ item.value.name }} will be installed with the packages {{ item.value.rpm }}"
      loop: "{{ service | dict2items }}"              
```

```bash
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable with a loop] ********************************************************
ok: [192.168.1.11] => (item={'key': 'web', 'value': {'name': 'apache', 'rpm': 'httpd'}}) => {
    "msg": "web | The apache will be installed with the packages httpd"
}
ok: [192.168.1.11] => (item={'key': 'db', 'value': {'name': 'mariadb', 'rpm': 'mariadb-server'}}) => {
    "msg": "db | The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

Con `list`:

```bash
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable with a loop
      debug:
        msg: "The {{ item.name }} will be installed with the packages {{ item.rpm }}"
      loop: "{{ service.values() | list}}"
~                                                 
```

```bash
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable with a loop] ********************************************************
ok: [192.168.1.11] => (item={'name': 'apache', 'rpm': 'httpd'}) => {
    "msg": "The apache will be installed with the packages httpd"
}
ok: [192.168.1.11] => (item={'name': 'mariadb', 'rpm': 'mariadb-server'}) => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

* Stampa il valore di `service.web` solo quando `type` è uguale a `web`.

```bash
---
- hosts: ansible_clients
  vars_files:
    - vars.yml

  tasks:

    - name: Print a dictionary variable
      debug:
        msg: "The {{ service.web.name }} will be installed with the packages {{ service.web.rpm }}"
      when: type == "web"


    - name: Print a dictionary variable
      debug:
        msg: "The {{ service.db.name }} will be installed with the packages {{ service.db.rpm }}"
      when: type == "db"
```

```bash
$ ansible-playbook display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
ok: [192.168.1.11] => {
    "msg": "The apache will be installed with the packages httpd"
}

TASK [Print a dictionary variable] ********************************************************************
skipping: [192.168.1.11]

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

$ ansible-playbook --extra-vars "type=db" display-dict.yml

PLAY [ansible_clients] *********************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
skipping: [192.168.1.11]

TASK [Print a dictionary variable] ********************************************************************
ok: [192.168.1.11] => {
    "msg": "The mariadb will be installed with the packages mariadb-server"
}

PLAY RECAP *********************************************************************************************
192.168.1.11               : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```
