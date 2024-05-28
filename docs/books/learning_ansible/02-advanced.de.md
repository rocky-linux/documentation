---
title: Ansible Intermediate
---

# Ansible für Fortgeschrittene

In diesem Kapitel lernen Sie weitere Themen über die Arbeit mit Ansible.

****

**Ziele**: In diesem Kapitel wird Folgendes behandelt:

:heavy_check_mark: arbeiten mit Variablen;  
:heavy_check_mark: Verwendung von Schleifen;  
:heavy_check_mark: Statusänderungen verwalten und darauf reagieren;  
:heavy_check_mark: asynchrone Aufgaben verwalten.

:checkered_flag: **Ansible**, **Module**, **Playbook**

**Vorkenntnisse**: :star: :star: :star:  
**Schwierigkeitsgrad**: :star: :star:

**Lesezeit**: 31 Minuten

****

Im vorherigen Kapitel haben Sie gelernt, wie man Ansible installiert und in der Befehlszeile verwendet oder wie man Playbooks entwirft, um die Wiederverwendbarkeit Ihres Codes zu sichern.

In diesem Kapitel können wir einige fortgeschrittenere Konzepte zur Verwendung von Ansible kennenlernen und interessante Vorgehensweisen entdecken, die Sie regelmäßig verwenden können.

## Die Variablen

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html).

Unter Ansible gibt es verschiedene Arten Variablen als primitive:

* Strings,
* ganze Zahlen: integers,
* Booleans.

Diese Variablen können wie folgt organisiert werden:

* als Wörterbücher: dictionaries,
* als Listen.

Eine Variable kann an verschiedenen Orten definiert werden, wie in einem Playbook, in einer Rolle oder in der Kommandozeile zum Beispiel.

Zum Beispiel in einem Playbook:

```bash
---
- hosts: apache1
  vars:
    port_http: 80
    service:
      debian: apache2
      rhel: httpd
```

oder in der Kommandozeile:

```bash
ansible-playbook deploy-http.yml --extra-vars "service=httpd"
```

Einmal definiert, kann eine Variable verwendet werden, indem sie zwischen doppelten geschweiften Klammern aufgerufen wird:

* `{{ port_http }}` für einen einfachen Wert,
* `{{ service['rhel'] }}` oder `{{ service.rhel }}` für ein Wörterbuch - dictionary.

Zum Beispiel:

```bash
- name: make sure apache is started
  ansible.builtin.systemd:
    name: "{{ service['rhel'] }}"
    state: started
```

Natürlich ist es auch möglich, auf die globalen Variablen (die **facts**) von Ansible (Betriebssystem, IP-Adressen, VM-Name usw.) zuzugreifen.

### Outsourcing-Variablen

Variablen können in eine externe Datei zum Playbook aufgenommen werden, in diesem Fall muss diese Datei im Playbook mit der `vars_files` Direktive definiert werden:

```bash
---
- hosts: apache1
  vars_files:
    - myvariables.yml
```

Die `myvariables.yml` Datei:

```bash
---
port_http: 80
ansible.builtin.systemd::
  debian: apache2
  rhel: httpd
```

Es kann auch dynamisch mithilfe des `include_vars`-Moduls hinzugefügt werden:

```bash
- name: Include secrets.
  ansible.builtin.include_vars:
    Datei: vault.yml
```

### Eine Variable anzeigen

Um eine Variable anzuzeigen, müssen Sie das `debug` Modul wie folgt aktivieren:

```bash
- ansible.builtin.debug:
    var: service['debian']
```

Sie können auch die Variablen innerhalb eines Textes verwenden:

```bash
- ansible.builtin.debug:
    msg: "Print a variable in a message : {{ service['debian'] }}"
```

### Rückgabe einer Aufgabe - task - speichern

Um die Rückgabe einer Aufgabe - task - zu speichern und später darauf zugreifen zu können, müssen Sie das Schlüsselwort `register` in der Aufgabe selbst verwenden.

Verwendung einer gespeicherten Variable:

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

!!! note "Anmerkung"

    Die Variable `homes.stdout_lines` ist eine Liste von Variablen des Typ String, eine Möglichkeit, Variablen zu organisieren, die wir bisher noch nicht gesehen hatten.

Die Strings, aus denen die gespeicherte Variable besteht, können über den Wert von `stdout` abgerufen werden (der Ihnen Dinge wie `homes.stdout.find("core") != -1`ermöglicht), um sie mithilfe einer Schleife (siehe `loop`) oder einfach anhand ihrer Indizes abzugreifen, wie im vorherigen Beispiel gezeigt wurde.

### Übungen:

* Ein Playbook schreiben `play-vars.yml`, das den Namen der Distribution des Ziels mit seiner Hauptversion ausdruckt und dabei globale Variablen verwendet.

* ein Playbook mit folgendem Dictionary schreiben, um die Dienste anzuzeigen, die installiert werden:

```bash
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Der Default-Typ sollte "web" sein.

* Überschreiben Sie die Variable `type` über die Befehlszeile

* Variablen in einer `vars.yml` Datei externalisieren

## Schleifen-Verwaltung

Mithilfe einer Schleife können Sie beispielsweise eine Aufgabe über eine Liste, eine Hashtabelle oder ein Dictionary iterieren.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html).

Als einfaches Beispiel implementieren wir eine Anwendung zur Erstellung von vier Benutzern:

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

Bei jeder Wiederholung der Schleife wird der Wert der verwendeten Liste in der Variable `item` gespeichert, die im Loop-Code zugänglich ist.

Natürlich kann eine Liste in einer externen Datei definiert werden:

```bash
users:
  - antoine
  - patrick
  - steven
  - xavier
```

und im Task wie folgt verwendet werden (nach dem Einbinden der vars-Datei):

```bash
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop: "{{ users }}"
```

Wir können das Beispiel mit den gespeicherten Variablen verwenden, um es zu verbessern. Verwendung einer gespeicherten Variable:

```bash
- name: /home content
  shell: ls /home
  register: homes

- name: Print the directories name
  ansible.builtin.debug:
    msg: "Directory => {{ item }}"
  loop: "{{ homes.stdout_lines }}"
```

Ein Wörterbuch kann auch in einer Schleife verwendet werden.

In diesem Fall müssen das Dictionary mit einem **jinja filter** (jinja ist die von Ansible verwendete Template-Engine) in ein Item umwandeln: `| dict2items`.

In der Schleife ist es möglich, `item.key` zu verwenden, der dem Dictionary-Schlüssel entspricht, und `item.value`, der den Werten des Schlüssels entspricht.

Sehen wir uns das an einem konkreten Beispiel, das die Verwaltung der Systembenutzer anzeigt:

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

!!! note "Anmerkung"

    Viele Dinge können mit Schleifen implementiert werden. Sie werden die Möglichkeiten entdecken, die Schleifen bieten, wenn Ihre Verwendung von Ansible Sie dazu bringt, sie auf komplexere Weise zu nutzen.

### Übungen:

* Zeigt Sie den Inhalt der `service` Variable der vorherigen Übung mit einer Schleife an.

!!! note "Anmerkung"

    Sie sollten die `service`-Variable, die ein Dictionary ist, in eine Liste mit Hilfe der jinja-Filter `list` wie folgt umwandeln:

    ```
    {{ service.values() | list }}
    ```

## Conditionals

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

Die `when` Anweisung ist in vielen Fällen sehr nützlich, z.B., bestimmte Aktionen auf bestimmten Servertypen nicht ausführen, wenn eine Datei oder ein Benutzer nicht existiert, etc.

!!! note "Anmerkung"

    Hinter der `when` Anweisung brauchen die Variablen keine doppelten Klammern (sie sind eigentlich Jinja2-Ausdrücke...).

```bash
- name: "Reboot only Debian servers"
  reboot:
  when: ansible_os_family == "Debian"
```

Bedingungen können mit Klammern gruppiert werden:

```bash
- name: "Reboot only CentOS version 6 and Debian version 7"
  reboot:
  when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
        (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")
```

Die Bedingungen, die einem logischen UND entsprechen, können als Liste zur Verfügung gestellt werden:

```bash
- name: "Reboot only CentOS version 6"
  reboot:
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "6"
```

Sie können den Wert eines Booleschen testen und überprüfen, ob es wahr ist:

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

Sie können auch testen, daß es nicht stimmt:

```bash
when:
  - file.stat.exists
  - not file.stat.isdir
```

Sie müssen wahrscheinlich testen, daß eine Variable existiert, um Ausführungsfehler zu vermeiden:

```bash
when: myboolean is defined and myboolean
```

### Übungen:

* Gibt den Wert von `service.web` nur aus, wenn `type` gleich `web` ist.

## Änderungen verwalten: die `handler`

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html).

Die Handler erlauben den Start von Operationen, wie, z.B., das Neustarten eines Dienstes, wenn Änderungen vorkommen.

In einem Playbook kann ein Modul erkennen, dass es eine bedeutende Änderung auf einem entfernten System gegeben hat und so eine Operation als Reaktion auf diese Änderung auslösen. Eine Benachrichtigung wird am Ende eines Playbook-Taskblocks versendet, und die Reaktionsoperation nur einmal ausgelöst, selbst wenn mehrere Aufgaben die gleiche Benachrichtigung senden.

![Handlers](images/handlers.png)

Beispielsweise können mehrere Aufgaben darauf hindeuten, dass der `httpd` Dienst aufgrund einer Änderung in den Konfigurationsdateien neu gestartet werden muss. Dennoch wird der Dienst nur einmal neu gestartet, um mehrere unnötige Starts zu vermeiden.

```bash
- name: template configuration file
  template:
    src: template-site.j2
    dest: /etc/httpd/sites-availables/test-site.conf
  notify:
     - restart memcached
     - restart httpd
```

Ein Handler ist eine Art Aufgabe, auf die ein eindeutiger globaler Name verweist:

* Es wird von einem oder mehreren Notifier aktiviert.
* Es startet nicht sofort, sondern wartet, bis alle Aufgaben abgeschlossen sind.

Beispiel für Handler:

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

Seit Version 2.2 von Ansible können Handler auch direkt lauschen:

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

## Asynchronous tasks

!!! note "Anmerkung"

    Weitere Informationen sind [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html) verfügbar.

Standardmäßig bleiben SSH-Verbindungen zu Hosts während der Ausführung verschiedener Playbook-Tasks auf allen Knoten offen.

Dies kann einige Probleme verursachen, insbesondere:

* wenn die Ausführungszeit der Aufgabe länger ist als das SSH-Verbindungs-Timeout
* wenn die Verbindung während der Aktion unterbrochen wird (Server-Neustart zum Beispiel)

In diesem Fall müssen Sie in den asynchronen Modus wechseln und eine maximale Ausführungszeit sowie die Häufigkeit (standardmäßig 10s) angeben, mit der Sie den Host-Status überprüfen.

Durch Angabe eines Umfragewertes von 0 wird Ansible die Aufgabe ausführen und fortfahren, ohne sich um das Ergebnis Sorgen zu machen.

Hier ist ein Beispiel mit asynchronen Aufgaben, die es Ihnen erlauben, einen Server neu zu starten und darauf zu warten, dass Port 22 wieder erreichbar ist:

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

Sie können sich auch entscheiden, eine lang-laufende Aufgabe zu starten und sie zu vergessen (fire and forget), weil die Ausführung keine Rolle im Playbook spielt.

## Übungsergebnisse

* Ein Playbook schreiben `play-vars.yml`, das den Namen der Distribution des Ziels mit seiner Hauptversion ausdruckt, wobei globale Variablen verwendet werden.

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

* Ein Playbook mit folgendem Dictionary schreiben, um die Dienste anzuzeigen, die installiert werden sollen:

```bash
service:
  web:
    name: apache
    rpm: httpd
  db:
    name: mariadb
    rpm: mariadb-server
```

Der Default-Typ sollte "web" sein.

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

* Überschreiben der Variable `type` in der Befehlszeile:

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

* Variablen in einer `vars.yml` Datei auslagern

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

* Den Inhalt der `service` Variable der vorherigen Übung mit einer Schleife anzeigen.

!!! note "Anmerkung"

    Sie sollten die "service"-Variable, die ein Dictionary ist, in ein Element oder eine Liste mit Hilfe des jinja Filter `dict2items` oder `list` wie folgt umwandeln:

    ```
    {{ service | dict2items }}
    ```

    ```
    {{ service.values() | list }}
    ```

Mit `dict2items`:

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

Mit `list`:

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

* Den Wert von `service.web` nur ausgeben, wenn `type` gleich `web` ist.

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
