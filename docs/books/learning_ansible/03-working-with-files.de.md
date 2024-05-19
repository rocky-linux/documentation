---
title: Dateiverwaltung
---

# Ansible - Dateiverwaltung

In diesem Kapitel erfahren Sie, wie Sie Dateien mit Ansible verwalten.

****

**Ziele**: In diesem Kapitel lernen Sie Folgendes:

:heavy_check_mark: den Inhalt einer Datei ändern;  
:heavy_check_mark: Dateien auf Zielserver hochladen;  
:heavy_check_mark: Dateien von Zielservern herunterladen.

:checkered_flag: **ansible**, **module**, **Dateien**

**Vorkenntnisse**: :star: :star:  
**Schwierigkeitsgrad**: :star:

**Lesezeit**: 23 Minuten

****

Je nach Bedarf werden Sie unterschiedliche Ansible-Module verwenden, um Systemkonfigurationsdateien zu ändern.

## `ini_file` module

Wenn Sie eine INI-Datei (Abschnitt zwischen eckige Klammern `[]` und `key=value` Paare) bearbeiten möchten, ist die Verwendung des Moduls `ini_file` am einfachsten.

!!! note "Anmerkung"

    Weitere Informationen können Sie [hier finden](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

Das Modul erfordert Folgendes:

* Der Wert der Sektion
* Der Name der Option
* Der neue Wert

Anwendungsbeispiel:

```bash
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## `lineinfile` Modul

Um sicherzustellen, dass eine Zeile in einer Datei vorhanden ist oder wenn eine einzelne Zeile in einer Datei hinzugefügt oder geändert werden sollte, sollten Sie das Modul `linefile` verwenden.

!!! note "Anmerkung"

    Weitere Informationen können Sie [hier finden](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

In diesem Fall wird die zu ändernde Zeile in einer Datei mithilfe eines regulären Ausdrucks gesucht.

Um beispielsweise sicherzustellen, dass die mit `SELINUX=` beginnende Zeile in der Datei `/etc/selinux/config` den Wert `enforcing` enthält:

```bash
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## `copy` Modul

Wenn eine Datei vom Ansible-Server auf einen oder mehrere Hosts kopiert werden muss, ist es am besten, das `copy`-Modul zu verwenden.

!!! note "Anmerkung"

    Weitere Informationen können Sie [hier finden](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

Hier kopieren wir `myfile.conf` von einem Ort an einen anderen:

```bash
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## `fetch` Modul

Wenn eine Datei von einem Remote-Server auf den lokalen Server kopiert werden sollte, ist es am besten, das `fetch`-Modul zu verwenden.

!!! note "Anmerkung"

    Weitere Informationen können Sie [hier finden](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

Das Modul macht das Gegenteil wie das `copy`-Modul:

```bash
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## `template` Modul

Ansible und sein `template`-Modul verwenden das **Jinja2**-Vorlagensystem (<http://jinja.pocoo.org/docs/>), um Dateien auf den Zielhosts zu generieren.

!!! note "Anmerkung"

    Weitere Informationen können Sie [hier finden](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

Zum Beispiel:

```bash
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

Sie können einen Validierungsschritt hinzufügen, wenn der Zieldienst dies zulässt (z. B. Apache mit dem Befehl `apachectl -t`):

```bash
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## Modul `get_url`

Um Dateien von einer Website oder FTP auf einen oder mehrere Hosts hochzuladen, verwenden Sie das `get_url`-Modul:

```bash
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

Durch die Bereitstellung einer Prüfsumme wird die Datei nicht erneut heruntergeladen, wenn sie bereits am Zielort vorhanden ist und ihre Prüfsumme mit dem angegebenen Wert übereinstimmt.
