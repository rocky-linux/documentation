---
title: Desktop via RDP teilen
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova, Zhang Zhuyue
---

## Einleitung

Diese Anleitung ist für Sie, wenn Sie Ihren (GNOME-)Desktop auf Rocky Linux freigeben oder auf andere freigegebene Desktops zugreifen möchten.

Das Thema dieser Anleitung ist RDP. RDP steht für Remote Desktop Protocol und tut genau das, was es bedeutet: Es ermöglicht Ihnen, Computer aus der Ferne anzuzeigen und mit ihnen zu interagieren und das alles über eine grafische Benutzeroberfläche. Sie müssen sich jedoch ein wenig mit der Befehlszeile befassen, um die Software einzurichten.

!!! note "Anmerkung"

```
Standardmäßig ermöglicht Rocky Linux Ihnen, Ihren Desktop über ein anderes VNC-Protokoll freizugeben. VNC ist durchaus nützlich, aber RDP bietet normalerweise ein viel flüssigeres Erlebnis und kommt mit ungewöhnlichen Monitorauflösungen zurecht.
```

## Voraussetzungen

Für diese Anleitung wird davon ausgegangen, dass Sie Folgendes bereits eingerichtet haben:

- Rocky Linux inklusiv GNOME
- `Flatpak` und `Flathub` sind betriebsbereit
- Ein User-Account ohne root-Rechte
- Administrator- oder `sudo`-Rechte und die Möglichkeit, Befehle in das Terminal einzufügen
- Der X-Server (zum Teilen Ihres Desktops)

!!! info "Info"

```
Derzeit sind einige Projekte im Gange, um den Wayland-Display-Server und RDP zu integrieren, neuere Versionen von GNOME verfügen über einen integrierten RDP-Server, der diesen Zweck erfüllt. Allerdings verfügt die GNOME-Version von Rocky Linux nicht über diese Funktion, sodass es viel einfacher ist, Ihre RDP-Sitzung mit x11 zu betreiben.
```

## Rocky Linux GNOME-Desktop über RDP teilen

Um den Remote-Zugriff auf Ihren Rocky Linux-Desktop zu ermöglichen, benötigen Sie einen RDP-Server. Für unsere Zwecke ist `xrdp` völlig ausreichend. Allerdings müssen Sie dafür das Terminal verwenden, da es sich um ein reines CLI-Programm handelt.

!!! info "Info"

````
The xrdp package is in [EPEL repository](https://wiki.rockylinux.org/rocky/repo/#community-approved-repositories), which provides rebuilds of Fedora packages for every supported Enterprise Linux. If you have not enabled it, use the following commands. You [should also enable CRB](https://wiki.rockylinux.org/rocky/repo/#notes-on-epel) (called 'PowerTools' in Rocky Linux 8) before adding the EPEL repository.

In Rocky Linux 8, use these commands to add the EPEL repository:

```bash
sudo dnf config-manager --set-enabled powertools
sudo dnf install epel-release
```

In Rocky Linux 9, use these commands to add the EPEL repository:

```bash
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
```
````

Nachdem Sie das `EPEL`-Repository hinzugefügt haben (oder wenn Sie es bereits hinzugefügt haben), verwenden Sie den folgenden Befehl, um `xrdp` zu installieren:

```bash
sudo dnf install xrdp
```

Sobald Sie es installiert haben, müssen Sie den Dienst aktivieren:

```bash
sudo systemctl enable --now xrdp
```

Wenn alles gut geht, sollte der RDP-Server installiert, aktiviert und in Ausführung sein. Sie können jedoch noch keine Verbindung herstellen. Sie müssen zunächst den richtigen Port in Ihrer Firewall öffnen.

Wenn Sie mehr darüber erfahren möchten, wie die Firewall-App `firewalld` von Rocky Linux funktioniert, lesen Sie bitte unseren Leitfaden zu
. Wenn Sie einfach weitermachen möchten, führen Sie folgende Befehle aus:

```bash
sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```

Für Anfänger: Diese Befehle öffnen den RDP-Port in Ihrer Firewall, sodass Sie eingehende RDP-Verbindungen akzeptieren können. Starten Sie dann die Firewall neu, um die Änderungen zu übernehmen. Wenn Sie möchten, können Sie Ihren PC sicherheitshalber neu starten.

Wenn Sie keinen Neustart durchführen möchten, sollten Sie sich abmelden. RDP verwendet aus Sicherheitsgründen die Anmeldeinformationen Ihres Benutzerkontos. Eine Remote-Anmeldung ist nicht möglich, wenn Sie bereits lokal bei Ihrem Desktop angemeldet sind. Zumindest nicht mit gleichen Benutzerkonto.

!!! info "Info"

```
Sie können auch die Firewall-App verwenden, um `firewalld` zu verwalten und alle gewünschten Ports zu öffnen. In diesem Bereich der Rocky Linux Doku finden Sie einen Link zu einer Anleitung des Autors zur Installation und Verwendung der Firewall-App.
```

## Zugriff auf Ihren Rocky Linux-Desktop und/oder andere Desktops mit RDP

Sie haben gesehen, wie ein RDP-Server installiert wird, nun benötigen Sie eine RDP-Client-Anwendung. Unter Windows leistet die App „Remote-Desktop-Verbindung“ recht gute Dienste. Wenn Sie von einem anderen Linux-Rechner aus auf Ihren Rocky Linux-Rechner zugreifen möchten, müssen Sie eine Option eines Drittanbieters installieren.

Auf GNOME kann der Autor die Software `Remmina` wärmstens empfehlen. Die Verwendung ist nicht kompliziert, es ist stabil und es funktioniert im Allgemeinen zuverlässig.

Wenn Sie `Flatpak`/`Flathub` installiert haben, öffnen Sie einfach die Software-App und suchen Sie nach `Remmina`.

![The Gnome Software app on the Remmina page](images/rdp_images/01-remmina.png)

Sie können es einfach installieren und starten. Hinweis: Dies ist insbesondere der Vorgang zum Hinzufügen einer RDP-Verbindung in Remmina, aber er ist für fast jede andere RDP-Client-App, die Sie wahrscheinlich finden werden, ähnlich.

Klicken Sie auf die Plus-Schaltfläche in der oberen linken Ecke, um eine Verbindung hinzuzufügen. Nennen Sie es im Namensfeld wie Sie möchten und geben Sie die IP-Adresse des Remote-Computers sowie den Benutzernamen und das Passwort Ihres Remote-Benutzerkontos ein. Denken Sie daran: Wenn sich Ihre Computer im selben Netzwerk befinden, sollten Sie die lokale IP-Adresse verwenden und nicht die im Internet gültige IP, die Sie auf einer Website wie `whatsmyip.com` sehen würden.

![The Remmina connection profile form](images/rdp_images/02-remmina-config.png)

Und wenn sich Ihre Computer nicht im selben Netzwerk befinden, sollten Sie wissen, wie man eine Portweiterleitung oder eine statische IP für den Remotecomputer einrichtet. Das würde den Rahmen dieses Dokuments sprengen.

Scrollen Sie nach unten, um Optionen wie Multi-Monitor-Unterstützung, benutzerdefinierte Auflösungen und mehr anzuzeigen. Darüber hinaus können Sie mit der Option `Network connection type` die Bandbreitennutzung mit der Bildqualität in Ihrem RDP-Client in Einklang bringen.

Wenn sich Ihre Computer im selben Netzwerk befinden, wählen Sie für die beste Qualität einfach LAN.

Klicken Sie auf ++"Save"++ dann ++"Connect"++.

So sieht es mit dem `Windows Remote Desktop Connection`-Client aus. Der Autor hat das gesamte Dokument auf seinem lokalen Rocky Linux-Server mit RDP geschrieben.

![A screenshot of my docs-writing environment, at a 5120x1440p resolution](images/rdp_images/03-rdp-connection.jpg)

## Zusammenfassung

Das ist alles, was Sie wissen müssen, um RDP auf Rocky Linux zum Laufen zu bringen und Ihren Desktop nach Herzenslust freizugeben. Dies reicht aus, wenn Sie nur remote auf einige Dateien und Apps zugreifen müssen.
