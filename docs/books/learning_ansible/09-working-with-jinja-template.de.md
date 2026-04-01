---
title: Arbeit mit Jinja-Vorlagen in Ansible
author: Srinivas Nishant Viswanadha
contributors: Steven Spencer, Antoine Le Morvan, Ganna Zhyrnova
---

## Einleitung

Ansible bietet über das integrierte `template`-Modul eine leistungsstarke und unkomplizierte Möglichkeit, Konfigurationen mit `Jinja`-Vorlagen zu verwalten. In diesem Dokument werden zwei grundlegende Möglichkeiten zur Verwendung von Jinja-Vorlagen in Ansible behandelt:

- Hinzufügen von Variablen zu einer Konfigurationsdatei
- Erstellung komplexer Dateien mit Schleifen und aufwendigen Datenstrukturen.

## Hinzufügen von Variablen zu einer Konfigurationsdatei

### Schritt 1: Erstellen einer Jinja-Vorlage

Erstellen Sie eine Jinja-Vorlagendatei, z. B. `sshd_config.j2`, mit Platzhaltern für Variablen:

```jinja
# /path/to/sshd_config.j2

Port {{ ssh_port }}
PermitRootLogin {{ permit_root_login }}
# Add more variables as needed
```

### Schritt 2: Verwendung des Ansible-Vorlagenmoduls

Verwenden Sie in Ihrem Ansible-Playbook das Modul `template`, um die Jinja-Vorlage mit bestimmten Werten zu rendern:

```yaml
---
- name: Generate sshd_config
  hosts: your_target_hosts
  tasks:
    - name: Template sshd_config
      template:
        src: /path/to/sshd_config.j2
        dest: /etc/ssh/sshd_config
      vars:
        ssh_port: 22
        permit_root_login: no
      # Add more variables as needed
```

### Schritt 3: Konfigurationsänderungen anwenden

Führen Sie das Ansible-Playbook aus, um die Änderungen auf die Zielhosts anzuwenden:

```bash
ansible-playbook your_playbook.yml
```

Dieser Schritt stellt sicher, dass die Konfigurationsänderungen einheitlich in Ihrer gesamten Infrastruktur angewendet werden.

## Erstellen einer vollständigen Datei mit Schleifen und komplexen Datenstrukturen

### Schritt 1: Erweiterung der Jinja-Vorlage

Erweitern Sie Ihre Jinja-Vorlage, um Schleifen und komplexe Datenstrukturen zu verarbeiten. Hier ein Beispiel für die Konfiguration einer hypothetischen Anwendung mit mehreren Komponenten:

```jinja
# /path/to/app_config.j2

{% for component in components %}
[{{ component.name }}]
    Path = {{ component.path }}
    Port = {{ component.port }}
    # Add more configurations as needed
{% endfor %}
```

### Schritt 2: Integration des Ansible-Vorlagenmoduls

Integrieren Sie in Ihrem Ansible-Playbook das Modul `template`, um eine vollständige Konfigurationsdatei zu generieren:

```yaml
---
- name: Generate Application Configuration
  hosts: your_target_hosts
  vars:
    components:
      - name: web_server
        path: /var/www/html
        port: 80
      - name: database
        path: /var/lib/db
        port: 3306
      # Add more components as needed
  tasks:
    - name: Template Application Configuration
      template:
        src: /path/to/app_config.j2
        dest: /etc/app/config.ini
```

Führen Sie das Ansible-Playbook aus, um die Änderungen auf die Zielhosts anzuwenden:

```bash
ansible-playbook your_playbook.yml
```

Dieser Schritt stellt sicher, dass die Konfigurationsänderungen einheitlich in Ihrer gesamten Infrastruktur angewendet werden.

Das Ansible-Modul `template` ermöglicht die Verwendung von Jinja-Vorlagen zur dynamischen Generierung von Konfigurationsdateien während der Playbook-Ausführung. Dieses Modul ermöglicht die Trennung von Konfigurationslogik und Daten und macht Ihre Ansible-Playbooks dadurch flexibler und wartungsfreundlicher.

### Hauptmerkmale

1. **Vorlagen-Rendering:**
   - Das Modul rendert Jinja-Vorlagen, um Konfigurationsdateien mit dynamischem Inhalt zu erstellen.
   - Im Playbook oder Inventar definierte Variablen können in Vorlagen eingefügt werden, wodurch dynamische Konfigurationen ermöglicht werden.

2. **Verwendung von Jinja2:**
   - Das Modul `template` nutzt die Jinja2-Templating-Engine und bietet leistungsstarke Funktionen wie Bedingungen, Schleifen und Filter für die erweiterte Template-Manipulation.

3. **Quell- und Zielpfade:**
   - Gibt die Jinja-Quellvorlagedatei und den Zielpfad für die generierte Konfigurationsdatei an.

4. **Variablenübergabe:**
   - Variablen können direkt im Playbook-Task übergeben oder aus externen Dateien geladen werden, was eine flexible und dynamische Konfigurationsgenerierung ermöglicht.

5. **Idempotente Ausführung:**
   - Das Modul `template` unterstützt die idempotente Ausführung und stellt sicher, dass die Vorlage nur angewendet wird, wenn Änderungen erkannt werden.

### Beispiel eines Playbook-Snippet

```yaml
---
- name: Generate Configuration File
  hosts: your_target_hosts
  tasks:
    - name: Template Configuration File
      template:
        src: /path/to/template.j2
        dest: /etc/config/config_file
      vars:
        variable1: value1
        variable2: value2
```

### Anwendungsfälle

1. \*\*Konfiguration-Management: \*\*
   - Ideal für die Verwaltung von Systemkonfigurationen durch dynamische Generierung von Dateien auf Basis spezifischer Parameter.

2. \*\*Anwendungs--Setup: \*\*
   - Nützlich zum Erstellen anwendungsspezifischer Konfigurationsdateien mit unterschiedlichen Einstellungen.

3. \*\*Infrastruktur als Code: \*\*
   - Unterstützt die Umsetzung von Infrastructure-as-Code-Praktiken durch die Möglichkeit dynamischer Anpassungen der Konfigurationen auf Basis von Variablen.

### Bewährte Vorgehensweisen

1. \*\*Trennung der Zuständigkeiten: \*\*
   - Die eigentliche Konfigurationslogik sollte in Jinja-Vorlagen gespeichert werden, um sie von der Hauptstruktur des Playbooks zu trennen.

2. **Versionskontrolle:**
   - Speichern Sie Jinja-Vorlagen in versions-kontrollierten Repositorys, um die Nachverfolgung und Zusammenarbeit zu verbessern.

3. **Testbarkeit**:
   - Testen Sie die Vorlagen unabhängig voneinander, um sicherzustellen, dass sie die erwartete Konfigurationsausgabe erzeugen.

Durch die Nutzung des Moduls `template` können Ansible-Benutzer die Verwaltbarkeit und Flexibilität von Konfigurationsaufgaben verbessern und so einen optimierten und effizienteren Ansatz für die System- und Anwendungsinstallation fördern.

### Referenzen

[Ansible Template Module Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).
