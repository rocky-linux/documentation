---
title: Firewall GUI App
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

Möchten Sie Ihre Firewall ohne den ganzen Befehlszeilenkram verwalten? Es gibt eine großartige App, die speziell für `firewalld`, die in Rocky Linux verwendete Firewall, entwickelt wurde und auf Flathub verfügbar ist. In dieser Anleitung erfahren Sie, wie Sie es schnell zum Laufen bringen und lernen die Grundlagen der Benutzeroberfläche kennen.

Wir werden nicht alles abdecken, was `firewalld` oder die GUI leisten können, aber es sollte für den Anfang ausreichen.

## Voraussetzungen

Für diese Anleitung gehen wir davon aus, dass Sie über Folgendes verfügen:

 - Eine Rocky Linux-Installation mit einer beliebigen grafischen Desktopumgebung
 - `sudo` oder Administratorzugriff
 - Ein grundlegendes Verständnis der Arbeitsweise von `firewalld`

!!! note "Anmerkung"

```
Bedenken Sie, dass diese App Ihnen das Leben zwar definitiv erleichtert, wenn Sie lieber eine grafische Benutzeroberfläche verwenden, Sie aber trotzdem die grundlegenden Konzepte hinter `firewalld` verstehen müssen. Sie müssen sich mit Ports, Zonen, Diensten, Quellen, usw. auskennen.

Wenn Ihnen dies nicht ganz klar ist, lesen Sie bitte den [Anfängerleitfaden zu `firewalld`](../../guides/security/firewalld-beginners.md) und lesen Sie insbesondere den Abschnitt über Zonen, um ein Gefühl dafür zu bekommen, was sie tun.
```

## Installieren Sie die App

Gehen Sie zum `Software Center` und suchen Sie nach `Firewall`. Dies ist ein natives Paket im Rocky Linux-Repository und wird `Firewall` heißen, sodass es leicht zu finden sein sollte.

![Firewall in the Software Center](images/firewallgui-01.png)

Diese befindet sich im Repository unter `firewall-config` und kann mit dem üblichen Befehl installiert werden:

```bash
sudo dnf install firewall-config
```

Wenn Sie die App öffnen, werden Sie nach Ihrem Passwort gefragt. Außerdem wird vor der Durchführung vertraulicher Vorgänge erneut nachgefragt.

## Konfigurationsmodus

Das erste, was Sie beachten sollten, ist der Konfigurationsmodus, in dem Sie sich befinden. Sie können ihn aus dem Dropdown-Menü oben im Fenster auswählen. Wählen Sie aus `Runtime` und `Permanent`.

![the configuration mode dropdown menu is near the top of the window](images/firewallgui-02.png)

Das Öffnen von Ports, das Hinzufügen erlaubter Dienste und alle anderen zur Laufzeit vorgenommenen Änderungen sind _vorübergehend_ und ermöglichen Ihnen nicht den Zugriff auf alle Funktionen. Nach einem Reboot oder einem manuellen Neustart der Firewall verschwinden diese Änderungen. Dies ist ideal, wenn Sie nur eine schnelle Änderung vornehmen müssen, um eine einzelne Aufgabe abzuschließen, oder wenn Sie Ihre Änderungen testen möchten, bevor Sie sie dauerhaft übernehmen.

Wenn Sie beispielsweise einen Port in der `Public`-Zone geöffnet haben, können Sie die Änderungen über `Options > Runtime To Permanent` speichern.

Der `Permanent`-Modus ist riskanter, schaltet aber alle Funktionen frei. Es ermöglicht Ihnen, neue Zonen zu erstellen, Dienste anzupassen, Netzwerkschnittstellen zu verwalten und IPSets hinzuzufügen (mit anderen Worten, Sets von IP-Adressen, denen die Verbindung zu Ihrem Computer oder Server gestattet oder verweigert wird).

Nachdem Sie dauerhafte Änderungen vorgenommen haben, gehen Sie zu `Options > Reload Firewalld`, um sie ordnungsgemäß zu aktivieren.

## Interfaces/Connections – Verwaltung

Im Bereich ganz links mit der Bezeichnung `Active Bindings` können Sie Ihre Netzwerkverbindungen finden und manuell eine Netzwerkschnittstelle hinzufügen. Wenn Sie nach oben scrollen, sehen Sie die Ethernet-Verbindung (eno1) des Autors. Die `Public`-Zone ist standardmäßig gut geschützt und beinhaltet Ihre Netzwerkverbindung.

Am unteren Rand des Panels finden Sie die Schaltfläche `Change Zone`, mit der Sie Ihre Verbindung einer anderen Zone zuweisen können. Im `Permanent`-Modus können Sie auch Ihre personifizierten Zonen erstellen.

![a screenshot featuring the Active Bindings panel on the left of the window](images/firewallgui-03.png)

## Zonen-Verwaltung

Auf der ersten Registerkarte des rechten Panels finden Sie das Menü `Zone`. Hier können Sie Ports öffnen und schließen, Dienste aktivieren und deaktivieren, vertrauenswürdige IP-Adressen für eingehenden Datenverkehr (z. B. LANs) hinzufügen, Portweiterleitung aktivieren, erweiterte Regeln hinzufügen und vieles mehr.

Die gewöhnlichen Desktop-Benutzer werden hier die meiste Zeit verbringen, und die nützlichsten Unterregisterkarten in diesem Bereich sind diejenigen zum Konfigurieren von Diensten und Ports.

!!! note "Anmerkung"

```
Installieren Sie Ihre Apps und Dienste aus dem Repository. Einige davon (normalerweise diejenigen, die für die Verwendung auf dem Desktop entwickelt wurden) aktivieren die entsprechenden Dienste automatisch oder öffnen die richtigen Ports. Wenn dies jedoch nicht geschieht, können Sie die folgenden Schritte ausführen, um alles manuell zu erledigen.
```

### Einen Dienst einer Zone hinzufügen

Dienste sind beliebte Anwendungen und Hintergrunddienste, die standardmäßig von `firewalld` unterstützt werden. Sie können sie schnell und einfach aktivieren, indem Sie durch die Liste scrollen und auf das entsprechende Kontrollkästchen klicken.

Wenn Sie nun KDE Connect\* installiert haben, um Ihren Desktop mit anderen Geräten zu synchronisieren, und möchten, dass es tatsächlich durch Ihre Firewall funktioniert, gehen Sie wie folgt vor:

1. Wählen Sie zunächst die Zone aus, die Sie bearbeiten möchten. Wählen Sie für dieses Beispiel einfach die Default-`Public`-Zone aus.
2. Scrollen Sie in der Liste nach unten und wählen Sie `kdeconnect`.
3. Wenn Sie sich im Runtime-Einrichtungsmodus befinden, vergessen Sie nicht, im Optionsmenü auf `Runtime To Permanent` und `Reload Firewalld` zu klicken.

\* im EPEL-Repository verfügbar.

![a screenshot featuring the Zones tab in the right panel, and the Services sub-panel](images/firewallgui-04.png)

Zu den weiteren beliebten Diensten auf der Liste gehören HTTP und HTTPS zum Hosten von Websites, SSH zum Bereitstellen des Terminalzugriffs von anderen Geräten, Samba zum Hosten Windows-kompatibler Dateifreigaben und viele andere.

Allerdings wird nicht jede Anwendung aufgeführt und Sie müssen den Port möglicherweise manuell öffnen.

### Ports in einer Zone öffnen

Das Öffnen von Ports für spezifische Anwendungen ist recht einfach. Lesen Sie einfach die Dokumentation, um herauszufinden, welche Ports Sie benötigen.

1. Wählen Sie die Zone aus, die Sie bearbeiten möchten.
2. Gehen Sie im rechten Bereich zur Registerkarte `Ports`.
3. Klicken Sie auf die Schaltfläche ++"Add"++.
4. Füllen Sie das Textfeld mit den Ports aus, die Sie öffnen möchten. Prüfen Sie, welches Protokoll die Anwendung benötigt und welches Netzwerkprotokoll sie verwendet (also TCP/UDP usw.).
5. Klicken Sie auf OK und verwenden Sie die Optionen `Runtime To Permanent` und `Reload Firewalld`.

![a screenshot featuring the Ports subpanel, and the popup window where you can enter the port number as needed](images/firewallgui-05.png)

## Zusammenfassung

Wenn Sie Ihr Wissen über das Thema erweitern möchten, sollten Sie mehr über die Grundlagen von `Firewalld` lesen. Sie können auch die Registerkarte `Services` oben im rechten Bereich (neben `Zones`) verwenden, um genau zu konfigurieren, wie Ihre Dienste funktionieren, oder um den Zugriff anderer Computer zu steuern, die über IPsets und Quellen mit Ihrem Computer kommunizieren dürfen.

Oder Sie öffnen einfach Ihren Jellyfin-Server-Port und fahren mit Ihrer Aufgabe fort. `firewalld` ist ein unglaublich leistungsstarkes Tool und die Firewall-App kann Ihnen dabei helfen, seine Fähigkeiten auf einsteigerfreundliche Weise zu entdecken.
