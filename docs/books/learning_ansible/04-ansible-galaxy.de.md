---
title: Ansible Galaxy
---

# Ansible Galaxy: Kollektionen und Rollen

In diesem Kapitel erfahren Sie, wie Sie Ansible Rollen und Kollektionen verwenden, installieren und verwalten.

****

**Ziele**: In diesem Kapitel lernen Sie Folgendes:

:heavy_check_mark: Installation und Verwaltung von Kollektionen.       
:heavy_check_mark: Installieren und Verwalten von Rollen.

:checkered_flag: **ansible**, **ansible-galaxy**, **Rollen**, **Kollektionen**

**Vorkenntnisse**: :star: :star:      
**Komplexität**: :star: :star: :star:

**Lesezeit**: 41 Minuten

****

[Ansible Galaxy](https://galaxy.ansible.com) bietet Ansible Rollen und Kollektionen aus der Ansible Community.

Die bereitgestellten Elemente können in Playbooks referenziert und sofort verwendet werden

## Das Kommando `ansible-galaxy`

Der `ansible-galaxy` Befehl verwaltet Rollen und Kollektionen unter Verwendung von [galaxy.ansible.com](http://galaxy.ansible.com).

* Rollen verwalten:

```
ansible-galaxy role [import|init|install|login|remove|...]
```

| Sub-Kommandos | Funktion                                                              |
| ------------- | --------------------------------------------------------------------- |
| `install`     | installiert eine Rolle.                                               |
| `remove`      | eine oder mehrere Rollen entfernen.                                   |
| `list`        | zeigt den Namen und die Version der installierten Rollen an.          |
| `info`        | Informationen über eine Rolle anzeigen.                               |
| `init`        | das Skelett einer neuen Rolle generieren.                             |
| `import`      | eine Rolle von der Galaxy-Webseite importieren. Benötigt einen Login. |

* Um Kollektionen zu verwalten:

```
ansible-galaxy collection [import|init|install|login|remove|...]
```

| Sub-Kommandos | Funktion                                                           |
| ------------- | ------------------------------------------------------------------ |
| `init`        | das Skelett einer neuen Kollektion generieren.                     |
| `install`     | eine Kollektion installieren.                                      |
| `list`        | zeigt den Namen und die Version der installierten Kollektionen an. |

## Ansible Rollen

Eine ansible Rolle ist eine Einheit, die die Wiederverwendbarkeit von Playbooks fördert.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

### Installation nützlicher Rollen

Um das Interesse an der Verwendung von Rollen hervorzuheben, empfehlen wir, die `alemorvan/patchmanagement` Rolle zu verwenden. Diese Rolle ermöglicht, während des Update-Prozesses, viele Aufgaben (zum Beispiel Vor- oder Nachaktualisierung) mit wenigen Zeilen Code auszuführen.

Der Code im Github Repo der Rolle kann [hier](https://github.com/alemorvan/patchmanagement) überprüft werden.

* Die Rolle installieren. Dies benötigt nur einen Befehl:

```
ansible-galaxy role install alemorvan.patchmanagement
```

* Playbook erstellen, um die Rolle einzubinden:

```
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

Mit dieser Rolle können Sie Ihre eigenen Aufgaben für all Ihr Inventar oder nur für Ihren Zielknoten hinzufügen.

Erstellen der Aufgaben, die vor und nach dem Aktualisierungsprozess ausgeführt werden:

* Den `custom_tasks` Ordner anlegen:

```
mkdir custom_tasks
```

* `custom_tasks/pm_before_update_tasks_file.yml` erstellen (Name und Inhalt dieser Datei können beliebig geändert werden)

```
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* `custom_tasks/pm_after_update_tasks_file.yml` erstellen (Name und Inhalt dieser Datei können beliebig geändert werden)

```
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

Und starten Sie Ihre erste Patch-Verwaltung:

```
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

Ziemlich einfach für einen so komplizierter Prozess, oder?

Dies ist nur ein Beispiel dafür, was mit Hilfe von Rollen, die von der Community zur Verfügung gestellt werden, getan werden kann. Werfen Sie einen Blick auf [galaxy.ansible.com](https://galaxy.ansible.com/) um die Rollen zu entdecken, die für Sie nützlich sein könnten!

Sie können auch Ihre eigenen Rollen für Ihre Bedürfnisse erstellen und im Internet veröffentlichen, wenn Sie es möchten. Darauf werden wir im nächsten Kapitel kurz eingehen.

### Einführung in die Entwicklung von Ansible-Rollen

Ein Rollenskelett, das als Ausgangspunkt für benutzerdefinierte Rollen dient, kann durch den `ansible-galaxy` Befehl erzeugt werden:

```
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

Der Befehl generiert die folgende Baumstruktur um die `rocky8` Rolle zu enthalten:

```
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

Durch Rollen werden Includes von Dateien vermieden. Dateipfade oder `include` Direktiven müssen in Playbooks nicht angegeben werden. Sie müssen nur eine Aufgabe angeben und Ansible kümmert sich um die Includes.

Die Struktur einer Rolle ist ziemlich offensichtlich.

Variablen werden einfach in `vars/main.yml` gespeichert, wenn die Variablen nicht überschrieben werden sollen, oder in `default/main.yml`, wenn Sie die Möglichkeit offen halten möchten, den Inhalt der Variablen außerhalb Ihrer Rolle zu überschreiben.

Die für Ihren Code benötigten Handler, Dateien und Vorlagen werden in `handlers/main.yml`, `files` und `templates` gespeichert.

Alles was übrig bleibt, ist den Code für die Aufgaben der Rolle in `tasks/main.yml` zu definieren.

Sobald das alles gut funktioniert, können Sie diese Rolle in Ihren Playbooks nutzen. Sie können Ihre Rolle verwenden, ohne sich um den technischen Aspekt seiner Aufgaben zu kümmern, während Sie dessen Betrieb mit Variablen anpassen.

### Praktische Aufgabe: Erstellen Sie eine erste einfache Rolle

Lassen Sie uns dies mit einer "go anywhere"-Rolle implementieren, die einen Default-Benutzer erstellt und Softwarepakete installiert. Diese Rolle kann systematisch auf alle Ihre Server angewendet werden.

#### Variablen

Wir werden einen `rockstar` Benutzer auf allen unseren Servern erstellen. Da wir nicht wollen, dass dieser Benutzer überschrieben wird, definieren wir ihn in der Datei `vars/main.yml`:

```
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

Wir können diese Variablen jetzt in unsere `tasks/main.yml` ohne Include verwenden.

```
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

Um die neue Rolle zu testen, erstellen wir ein `test-role.yml` Playbook im selben Verzeichnis wie die Rolle:

```
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

und starten:

```
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

Herzlichen Glückwunsch! Mit nur wenigen Zeilen können Sie jetzt tolle Dinge implementieren.

Lass uns die Verwendung von Default-Variablen untersuchen.

Eine Liste der Pakete erstellen, die standardmäßig auf Ihren Servern installiert werden sollen, und eine leere Liste der zu deinstallierenden Pakete. Die Datei `defaults/main.yml` ändern und diese zwei Listen hinzufügen:

```
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

und sie in `tasks/main.yml` verwenden:

```
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

Testen Sie Ihre Rolle mit Hilfe des zuletzt erstellten Playbook:

```
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

Sie können jetzt `rocky8_remove_packages` im Playbook überschreiben und zum Beispiel `cockpit` deinstallieren:

```
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

```
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

Offensichtlich gibt es keine Grenzen, wie viel Sie die Rolle verbessern können. Stellen Sie sich vor, dass Sie für einen Ihrer Server ein Paket benötigen, das in der Liste der zu deinstallierenden Pakete steht. Sie könnten dann beispielsweise eine neue Liste erstellen, die überschrieben werden kann, und sie dann aus der Liste der Pakete entfernen, um diejenigen in der Liste der spezifischen zu installierenden Pakete mithilfe des Jinja-Filters `difference()` zu deinstallieren.

```
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Ansible Kollektionen

Die Kollektion ist ein Verteilungsformat für Ansible Inhalte, das Playbooks, Rollen, Module und Plugins enthalten kann.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)

Zum Installieren oder Aktualisieren einer Sammlung:

```
ansible-galaxy collection install namespace.collection [--upgrade]
```

Sie können dann die neu installierte Kollektion mit ihrem Namensraum und Namen vor dem Namen des Moduls oder der Rolle verwenden:

```
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

Einen Kollektionsindex ist [hier verfügbar](https://docs.ansible.com/ansible/latest/collections/index.html).

Lass uns die Kollektion `-community.general` installieren:

```
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

Wir können nun das neu verfügbare Modul `yum_versionlock` verwenden:

```
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

```
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

### Eine eigene Kollektion erstellen

Wie bei Rollen, können Sie eine eigene Kollektion mit Hilfe des `ansible-galaxy` Befehls erstellen:

```
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│   └── README.md
├── README.md
└── roles
```

Sie können dann die eigenen Plugins oder Rollen in dieser neuen Kollektion speichern.
