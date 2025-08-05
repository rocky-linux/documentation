---
title: NoSleep.sh – Ein einfaches Konfigurationsskript
author: Andrew Thiesen
tags:
  - Konfiguration
  - Server
  - Workstation
---

# NoSleep.sh

## Bash Script editieren `/etc/systemd/logind.conf`

Dieses Bash-Skript dient zum Ändern der Konfigurationsdatei `/etc/systemd/logind.conf` auf einem Rocky Linux-Server oder einer Rocky Linux-Workstation. Insbesondere ändert es die Option `HandleLidSwitch` und setzt sie auf `ignore`. Diese Konfigurationsänderung wird häufig verwendet, um zu verhindern, dass das System in den Ruhezustand versetzt wird oder eine Aktion ausführt, wenn der Laptopdeckel geschlossen ist.

### Verwendung

Um das Skript zu verwenden, führen Sie die folgenden Schritte aus:

1. Öffnen Sie ein Terminal auf Ihrem Linux-System.
2. `cd` in Ihr bevorzugtes Verzeichnis.
3. Laden Sie das Skript NoSleep.sh über `curl` herunter: `curl -O https://github.com/andrewthiesen/NoSleep.sh/blob/main/NoSleep.sh`
4. Machen Sie das NoSleep-Skript ausführbar, indem Sie den Befehl `chmod +x NoSleep.sh` ausführen.
5. Führen Sie das Skript als Root mit dem Befehl `sudo ./NoSleep.sh` aus.
6. Das Skript aktualisiert die Option `HandleLidSwitch` in der Datei `logind.conf` auf `ignore`.
7. Optional werden Sie aufgefordert, das System neu zu starten, damit die Änderungen endgültig wirksam werden.

### Wichtige Hinweise

* Dieses Skript **muss** als Root oder mit Superuser-Berechtigungen ausgeführt werden, um Systemdateien zu ändern.
* Es wird davon ausgegangen, dass sich die Datei `logind.conf` unter `/etc/systemd/logind.conf` befindet. Wenn Ihr System einen anderen Speicherort verwendet, ändern Sie das Skript bitte entsprechend.
* Das Ändern von Systemkonfigurationsdateien kann unbeabsichtigte Folgen haben. Bitte überprüfen Sie die vom Skript vorgenommenen Änderungen und stellen Sie sicher, dass sie Ihren Anforderungen entsprechen.
* Es wird empfohlen, vor der Ausführung des Skripts entsprechende Vorsichtsmaßnahmen zu treffen, z. B. eine Sicherungskopie der ursprünglichen Konfigurationsdatei zu erstellen.
* Ein Neustart Ihres Systems ist optional, kann aber sicherstellen, dass die Änderungen sofort wirksam werden. Nach der Ausführung des Skripts werden Sie zum Neustart aufgefordert.

---

Sie können das Skript gerne Ihren Anforderungen entsprechend anpassen und verwenden. Stellen Sie sicher, dass Sie das Skript und seine Auswirkungen verstehen, bevor Sie es auf Ihrem System ausführen.
