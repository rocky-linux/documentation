---
title: Installation und Einrichtung eines Brother All-in-One Druckers
author: Joseph Brinkman
contributors: Steven Spencer
tested with: 9.4
tags:
  - Desktop
  - printer support
---

## Einleitung

Das Drucken und Scannen mit einem All-in-One-Brother-Drucker ist unter Linux dank der Brother All-in-One-Drucker- und Scannertreiber von Drittanbietern möglich.

!!! info

```
Das Verfahren wurde mit einem Brother MFC-J480DW getestet.
```

## Voraussetzungen

- Rocky 9.4 Workstation
- `sudo`-Berechtigungen
- Brother All-in-One-Drucker und -Scanner

In dieser Anleitung wird davon ausgegangen, dass von Ihrer Arbeitsstation aus auf Ihren Drucker entweder über eine direkte USB-Verbindung oder über ein LAN (Local Area Network) zugegriffen werden kann. Das Anschließen eines Druckers an Ihr LAN geht über den Rahmen dieses Artikels hinaus.

## Hinzufügen eines Druckers in GNOME

1. \++"Settings"++ öffnen
2. Klicken Sie im linken Menü auf ++"Printers"++
3. Beachten Sie das Banner oben im Fenster mit der Aufschrift "Unlock to Change Settings"
4. Klicken Sie auf ++"Unlock"++ und geben Sie die `sudo`-Anmeldeinformationen ein.
5. Klicken Sie bitte auf ++"Add"++

Nach dem Klicken auf ++"Add"++ beginnt ++"Settings"++ mit der Suche nach Druckern. Wenn Ihr Drucker nicht angezeigt wird, Sie seine IP-Adresse in Ihrem lokalen Netzwerk aber kennen, geben Sie die IP-Adresse manuell ein. Das Verbinden Ihres Druckers mit Ihrem Heimnetzwerk geht über den Rahmen dieses Artikels hinaus.

Es wird ein Softwarefenster geöffnet, das versucht, Druckertreiber zu finden und zu installieren. Im Allgemeinen wird dies fehlschlagen. Um die zusätzlichen Treiber zu installieren, müssen Sie die Website von Brother besuchen.

## Herunterladen und Installieren der Treiber

[Anleitung zur Installation des Brother-Treiberinstallationsskripts:](https://support.brother.com/g/b/downloadlist.aspx?\&c=us\&lang=en\&prod=mfcj480dw_us_eu_as\&os=127){target="_blank"}

1. [Laden Sie das Bash-Skript für den Brother MFC-J480DW-Druckertreiber herunter](https://support.brother.com/g/b/downloadtop.aspx?c=us\&lang=en\&prod=mfcj480dw_us_eu_as){target="_blank"}

2. Öffnen Sie ein Terminalfenster.

3. Wechseln Sie zu dem Verzeichnis, in das Sie die Datei im letzten Schritt heruntergeladen haben. zum Beispiel `cd Downloads`

4. Geben Sie diesen Befehl ein, um die heruntergeladene Datei zu entpacken:

   ```bash
   gunzip linux-brprinter-installer-*.*.*-*.gz
   ```

5. Holen Sie sich die Superuser-Autorisierung mit dem Befehl `su` oder `sudo su`.

6. Folgendes Kommando ausführen:

   ```bash
   bash linux-brprinter-installer-*.*.*-* Brother machine name
   ```

7. Die Treiberinstallation wird gestartet. Befolgen Sie die Anweisungen auf dem Installationsbildschirm

Der Installationsvorgang kann einige Zeit dauern. Warten Sie, bis es abgeschlossen ist. Wenn Sie fertig sind, können Sie optional einen Testdruck senden.

## Scanner-Support

Xsane ist ein Scan-Dienstprogramm, das eine grafische Benutzeroberfläche zum Erstellen von Scans bereitstellt. Es stehen Pakete aus dem Appstream-Repository zur Verfügung, die keine zusätzliche Konfiguration erfordern.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

Die Benutzeroberfläche von `xsane` sieht ein wenig ungewöhnlich aus, aber ein einfacher Scan ist unkompliziert. Wenn Sie xsane starten, erscheint ein Fenster mit einer Schaltfläche
\++"Acquire a preview"++,
über die Sie eine Vorschau abrufen können. Dadurch wird ein Vorschaubild eines Scans aufgenommen. Sobald Sie zum Scannen bereit sind, klicken Sie im Hauptmenü auf die Schaltfläche ++"Start"++.

Eine umfassendere `xsane`-Anleitung finden Sie in diesem [Artikel der Fakultät für Mathematik der Universität Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

Nach der Installation der erforderlichen Brother-Treiber und `xsane` sollten Sie nun auf Ihrem All-in-One-Drucker und Scanner von Brother drucken und scannen können.
