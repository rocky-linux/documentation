---
title: XXL-Infrastruktur
---

# Ansible - XXL-Infrastruktur

In diesem Kapitel erfahren Sie, wie Sie Ihr Konfigurationsmanagementsystem skalieren.

****

**Ziele**: In diesem Kapitel lernen Sie Folgendes:

:heavy_check_mark: Ihren Code für eine große Infrastruktur organisieren;   
:heavy_check_mark: Ihr Konfigurationsmanagement ganz oder teilweise auf eine Gruppe von Knoten anwenden;

:checkered_flag: **Ansible**, **Konfig-Management**, **Skalierung**

**Vorkenntnisse**: :star: :star: :star:       
**Schwierigkeitsgrad**: :star: :star: :star: :star:

**Lesezeit**: 30 Minuten

****

Wir haben in den vorherigen Kapiteln gesehen, wie wir unseren Code in Form von Rollen organisieren, aber auch, wie wir einige Rollen für die Updateverwaltung (Patchverwaltung) oder die Codeverteilung verwenden.

Wie sieht es mit der Konfigurationsverwaltung aus? Wie verwaltet man die Konfiguration von zehn, Hunderten oder sogar Tausenden virtuellen Maschinen mit Ansible?

Das Aufkommen der Cloud hat die herkömmlichen Methoden ein wenig verändert. Die VM wird zum Zeitpunkt der Bereitstellung konfiguriert. Stimmt seine Konfiguration nicht mehr überein, wird es gelöscht und durch eine neue ersetzt.

Die in diesem Kapitel vorgestellte Konfigurationsmanagementsystem-Organisation wird auf diese beiden Arten des IT-Verbrauchs reagieren: „einmalige Nutzung“ oder regelmäßige „Neukonfiguration“ eines Pools von Servern.

Seien Sie jedoch vorsichtig: Um die Konformität eines Serverpools mit Ansible zu gewährleisten, müssen Sie Ihre Arbeitsgewohnheiten ändern. Es ist nicht mehr möglich, die Konfiguration eines Service Managers manuell zu ändern, ohne dass diese Änderungen bei der nächsten Ausführung von Ansible überschrieben werden.

!!! note "Anmerkung"

    Was wir, wie weiter unten beschrieben, einrichten werden, ist nicht Ansibles bevorzugtes Terrain. Technologien wie Puppet oder Salt sind viel besser geeignet. Denken Sie daran, dass Ansible ein Schweizer Taschenmesser der Automatisierung und agentenlos ist, was die Leistungsunterschiede erklärt.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html).

## Variablenspeicherung

Das erste, was wir besprechen sollten, ist die Trennung zwischen Daten und Ansible-Code.

Je größer und komplexer Ihr Code wird, desto schwieriger wird es, die darin enthaltenen Variablen zu ändern.

Um die Wartung Ihrer Website sicherzustellen, ist es am wichtigsten, Variablen ordnungsgemäß vom Ansible-Code zu trennen.

Wir haben es hier noch nicht besprochen, aber Sie sollten wissen, dass Ansible automatisch gefundene Variablen in bestimmte Ordner laden kann, abhängig vom Namen des Inventars des verwalteten Knotens oder seiner Mitgliedsgruppen.

Die Ansible-Dokumentation schlägt vor, unseren Code wie folgt zu organisieren:

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

Wenn der ausgewählte Knoten `hostname1` von `group1` ist, werden die in den Dateien `hostname1.yml` und `group1.yml` enthaltenen Variablen automatisch geladen. Es wird empfohlen, alle Daten für alle Rollen am selben Ort zu speichern.

Auf diese Weise wird die Inventardatei Ihres Servers zu seiner Identitätskarte. Sie enthält alle Variablen, die von den Standardvariablen für Ihren Server abweichen.

Aus Sicht der Variablenzentralisierung ist es wichtig, die Namen ihrer Variablen in Rollen zu organisieren, indem ihnen beispielsweise der Name der Rolle vorangestellt wird. Es wird außerdem empfohlen, flache Variablennamen anstelle von Wörterbüchern zu verwenden.

Wenn Sie beispielsweise den Wert `PermitRootLogin` in der Datei `sshd_config` zu einer Variablen machen möchten, könnte ein guter Variablenname `sshd_config_permitrootlogin` sein (anstelle von `sshd.config.permitrootlogin`, was auch ein guter Variablenname sein könnte).

## Über Ansible-Tags

Die Verwendung von Ansible-Tags ermöglicht es Ihnen, einen Teil der Aufgaben in Ihrem Code auszuführen oder zu überspringen.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

Lassen Sie uns zum Beispiel die Aufgabe zur Benutzererstellung ändern:

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

Sie können jetzt nur Aufgaben mit dem Tag `users` mit der Option `ansible-playbook` `--tags` abspielen:

```
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

Sie können auch die Option `--skip-tags` verwenden.

## Informationen zur Verzeichnisstruktur

Konzentrieren wir uns auf einen Vorschlag zur Organisation von Dateien und Verzeichnissen, die für das ordnungsgemäße Funktionieren eines CMS (Content Management System) erforderlich sind.

Unser Ausgangspunkt wird die Datei `site.yml` sein. Diese Datei ähnelt ein wenig dem CMS-Orchesterleiter, da sie nur bei Bedarf die Rollen enthält, die für die Zielknoten erforderlich sind:

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

Natürlich müssen diese Rollen im Verzeichnis `roles` auf derselben Ebene wie die Datei `site.yml` erstellt werden.

Wir verwalten unsere globalen Variablen gerne in einer Datei `vars/global_vars.yml`, obwohl wir sie auch in einer Datei in `inventories/produktion/group_vars/all.yml` speichern könnten

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

Außerdem möchten wir die Möglichkeit behalten, eine Funktion zu deaktivieren. Dann schließen wir meine Rollen mit einer Bedingung und einem Standardwert wie diesem ein:

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

Vergessen Sie nicht, Tags zu verwenden:


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

Sie sollten so etwas erhalten:

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

!!! Note

    Es steht Ihnen frei, Ihre eigenen Rollen innerhalb einer Collection zu entwickeln

## Tests

Lassen Sie uns das Playbook starten und einige Tests ausführen:

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

Wie Sie sehen, werden standardmäßig nur Aufgaben aus der Rolle `functionality1` ausgeführt.

Wir aktivieren `functionality2` für unseren Zielknoten im Inventar und starten das Playbook neu:

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

Versuchen Sie, nur `functionality2` anzuwenden:

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

Lassen Sie uns die gesamte Inventur ausführen:

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

Wie Sie sehen, wird `functionality2` nur auf `client1` abgespielt.

## Vorteile

Wenn Sie die Hinweise in der Ansible-Dokumentation befolgen, erhalten Sie schnell Folgendes:

* der Quellcode ist auch dann leicht zu warten, wenn er eine große Anzahl an Rollen enthält
* ein relativ schnelles, wiederholbares Compliance-System, das teilweise oder vollständig angewendet werden kann
* können im Einzelfall und durch Server angepasst werden
* Ihre Systemspezifikationen sind vom Code getrennt, leicht überprüfbar und zentral in Ihren Konfigurationsmanagement-Inventardateien gespeichert.
