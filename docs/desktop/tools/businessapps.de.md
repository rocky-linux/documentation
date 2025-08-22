---
title: Business & Office Apps
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

Ganz gleich, ob Sie einen glänzenden neuen Linux-basierten Arbeitslaptop haben oder versuchen, eine Heimbüroumgebung einzurichten, Sie fragen sich vielleicht, wo sich all Ihre üblichen Büro- und Geschäftsanwendungen befinden.

Auf Flathub gibt es davon viele. In diesem Leitfaden erfahren Sie, wie Sie die gängigsten dieser Programme installieren und stellen eine Liste möglicher Ersatzlösungen bereit. Lesen Sie weiter, wenn Sie wissen möchten, wie Sie Office, Zoom und mehr installieren können.

## Voraussetzungen

Für diese Anleitung benötigen Sie Folgendes:

 - Eine Rocky Linux-Installation mit einer grafischen Desktopumgebung
 - Berechtigung, Software auf Ihrem System zu installieren
 - `Flatpak` und `Flathub` sind betriebsbereit

## So installieren Sie gängige Business-Software unter Rocky Linux

Bei den meisten, nachdem Sie Flatpak und Flathub installiert haben, gehen Sie zum `Software Center`, suchen nach dem, was Sie brauchen, und installieren es. Auf diese Weise können Sie einige der gängigsten Lösungen in Betracht ziehen. Für andere müssen Sie die Web-Variante der Apps verwenden.

![A screenshot of Zoom in the software center](images/businessapps-01.png)

Um Ihnen den Einstieg zu erleichtern, finden Sie hier eine Liste der gängigsten Business-Anwendungen, die über Desktop-Clients verfügen, und die besten Möglichkeiten, diese zu erhalten.

!!! note "Anmerkung"

```
Wenn Sie mehr über den Status von Microsoft Office unter Linux erfahren möchten, scrollen Sie nach unten und fahren Sie mit dem nächsten Abschnitt fort.
```

Außerdem enthält diese Liste keine Apps wie Jira, für die es keine offiziellen Desktop-Apps gibt.

### Asana Desktop

Desktop-Anwendung: Unter Linux nicht verfügbar

Empfehlung: Verwenden Sie die Web-Variante.

### Discord

Desktop-App: Offizielle Apps und Apps von Drittanbietern, verfügbar bei `Flathub` im `Software Center`

Empfehlung: Verwenden Sie den offiziellen Client, wenn Sie `Push-to-Talk`-Funktionalität wünschen. Verwenden Sie die Web-Variante oder beliebige Drittanbieter-Clients im `Software Center`.

### Dropbox

Desktop-App: Die offizielle Apps ist bei `Flathub` im `Software Center` verfügbar.

Empfehlung: Nutzen Sie die offizielle App in GNOME und den meisten anderen Desktop-Umgebungen. Wenn Sie KDE verwenden, nutzen Sie die integrierte Dropbox-Integration.

### Evernote

Desktop-Anwendung: Unter Linux nicht mehr verfügbar.

Empfehlung: Verwenden Sie die Web-Variante.

### Freshbooks

Desktop-Anwendung: Unter Linux nicht verfügbar.

Empfehlung: Verwenden Sie die Web-Variante.

### Google Drive

Desktop-Anwendung: Clients von Drittanbietern.

Empfehlung: Melden Sie sich mit der Funktion `Online-Accounts` in GNOME Shell oder KDE bei Ihrem Google-Konto an. Dadurch erhalten Sie in GNOME integrierten Zugriff auf Ihre Dateien, E-Mails, Kalender, Aufgabenlisten und mehr.

Mit dem Dateimanager in KDE können Sie Dateien auf `Drive` anzeigen und verwalten. Es ist zwar nicht so vollständig integriert wie GNOME, aber trotzdem nützlich.

### Hubspot

Desktop-Anwendung: Unter Linux nicht verfügbar.

Empfehlung: Verwenden Sie die Web-Variante.

### Microsoft Exchange

Desktop App: Nur Third-party Clients.

Empfehlung: In GNOME können Sie die Funktion „Online-Konten“ verwenden, um Ihre Anwendungen ähnlich wie bei einem Google-Konto in Exchange zu integrieren.

Verwenden Sie Thunderbird in jeder anderen Arbeitsumgebung mit einem der _mehreren_ Exchange-Add-ons. Thunderbird ist im Standard-Repository von Rocky Linux verfügbar, Sie können jedoch eine neuere Version von Flathub erhalten.

### Notion

Desktop-Anwendung: Unter Linux nicht verfügbar.

Empfehlung: Verwenden Sie die Web-Variante.

### Outlook

Desktop-App: Nur Third-party Clients.

Empfehlung: Verwenden Sie den E-Mail-Client Ihrer Wahl. Evolution und Thunderbird sind gute Lösungen, oder Sie verwenden die Webversion.

### Quickbooks

Desktop-Anwendung: Unter Linux nicht verfügbar.

Empfehlung: Verwenden Sie die Web-Version.

### Slack

Desktop-App: Die offizielle App ist auf Flathub im Software Center verfügbar.

Empfehlung: Nutzen Sie je nach Wunsch die App oder die Web-Variante.

### Teams

Desktop-App: Die offizielle App ist auf Flathub im Software Center verfügbar.

Empfehlung: Verwenden Sie es nach Belieben auf Ihrem Desktop oder in Ihrem Browser. Wenn Sie die Bildschirmfreigabe aktivieren müssen, melden Sie sich beim Booten Ihres PCs bei Ihrer X11-Sitzung an. Die Bildschirmfreigabe wird auf Wayland noch nicht unterstützt.

### Zoom

Desktop-App: Die offizielle App ist auf Flathub im Software Center verfügbar.

Empfohlen: Wenn Sie die Desktop-Anwendung unter Rocky Linux verwenden, melden Sie sich mit einer X11-Sitzung bei Ihrem PC an und nicht mit Wayland, wenn Sie Ihren Bildschirm teilen müssen. Die Bildschirmfreigabe funktioniert jetzt in Wayland, jedoch nur in neueren Versionen der Software.

Als stabiles Unternehmensbetriebssystem wird Rocky Linux einige Zeit brauchen, um aufzuholen.

Abhängig von Ihrem Browser haben Sie jedoch möglicherweise mehr Erfolg beim Teilen Ihres Bildschirms auf Wayland, wenn Sie die Desktop-App ganz überspringen und einfach die Webversion verwenden.

## Open-Source-Ersatzlösungen zu herkömmlicher Unternehmenssoftware

Wenn Sie Ihre Software für Arbeit und Produktivität auswählen können, sollten Sie Ihre Routine ändern und eine Open-Source-Ersatzlösung ausprobieren. Die meisten der oben aufgeführten Anwendungen können durch eine Instanz von [Nextcloud](https://nextcloud.com) ersetzt werden, die auf Ihrem eigenen Server oder in der Cloud gehostet wird, und einige Anwendungen von Drittanbietern können auf dieser Plattform installiert werden.

Es kann Dateisynchronisierung, Projektmanagement, CRM, Kalender, Notizen-Verwaltung, grundlegende Buchhaltung, E-Mail und, mit etwas Arbeit und Anpassung, Text- und Video-Chat verwalten.

[Wikisuite](https://wikisuite.org/Software) kann alle oben genannten Aufgaben erfüllen und Ihnen bei der Erstellung Ihrer Unternehmenswebsite helfen. Es ist `Odoo` sehr ähnlich.

Beachten Sie jedoch, dass diese Plattformen größtenteils webbasiert sind. Der Nextcloud Desktop-Client dient nur der Dateisynchronisierung, Wikisuite verfügt nicht über eine.

Sie können Slack ganz einfach durch [Mattermost](https://mattermost.com) ersetzen, eine Open-Source-Chat- und Team-Management-Plattform. Wenn Sie die Video- und Audiofunktionen von Discord, Teams oder Zoom benötigen, können Sie dem Mix [Jitsi Meet] (https://meet.jit.si) hinzufügen. Es ist ein bisschen wie ein selbst hostendes Google Meet.

Sowohl Mattermost als auch Jitsi verfügen auch über Linux-Desktop-Clients auf Flathub.

Das Gleiche gilt für [Joplin](https://joplinapp.org) und [QOwnNotes](https://www.qownnotes.org/) und [Notesnook](https://notesnook.com), die bemerkenswerte Ersatzlösungen zu Evernote sind.

Suchen Sie im Software Center nach einer Ersatzlösung für `Notion`? [AppFlowy](https://appflowy.io) oder [SiYuan](https://b3log.org/siyuan/en/) könnten das sein, was Sie brauchen.

!!! note "Anmerkung"

```
Obwohl alle oben aufgeführten Ersarz-Apps Open Source sind, sind nicht alle „Free Libre and Open Source (FLOSS)“. Das bedeutet, dass einige für zusätzliche Funktionen oder Premium-Versionen ihrer Dienste Geld verlangen.
```

## Microsoft Office unter Rocky Linux

Neulinge in der Linux-Welt fragen sich vielleicht, was daran so schwierig ist, das zum Laufen zu bringen. Es ist nicht schwierig, wenn Sie mit der Webversion von Office365 zufrieden sind.

Schwieriger wird es allerdings, wenn Sie das komplette Desktop-Erlebnis mit allem Schnickschnack benötigen, den die Windows-Apps bieten. Zwar schreibt gelegentlich jemand ein Tutorial darüber, wie man die neueste Version der Office-Apps unter Linux mit WINE zum Laufen bringt, aber diese Lösungen funktionieren oft früher oder später nicht mehr. Es gibt keine 100%-stabile Möglichkeit, Desktop-Anwendungen unter Linux auszuführen.

Es gibt Linux-freundliche Office-Suiten, die mit Microsoft Office kompatibel sind, aber das eigentliche Problem ist Excel.

Bislang war die Desktopversion von Excel hinsichtlich ihrer Funktionen, Möglichkeiten zur Datenbearbeitung usw. praktisch beispiellos. Zugegebenermaßen handelt es sich hierbei um ein großartiges Programm, das für andere nur schwer zu toppen ist.

Der Arbeitsablauf ist anders, auch wenn die Ersatzlösungen über alle Funktionen verfügen, die ein bestimmter Benutzer möglicherweise benötigt. Sie können Ihre kompliziertesten Formeln und Tabellen nicht einfach in eine der Ersatzlösungen (nicht einmal in die Webversion von Excel) einfügen und erwarten, dass es funktioniert.

Wenn Excel jedoch keinen großen Teil Ihres Arbeitsablaufs ausmacht, sollten Sie sich auf jeden Fall die Ersatzlösungen ansehen. Sie sind _alle_ im `Software Center` mit Flathub verfügbar.

### Ersatzlösungen für Microsoft Office unter Rocky Linux

#### LibreOffice

[LibreOffice](https://www.libreoffice.org) ist der De-facto-Standard für Büro- und Produktivitätssoftware im FLOSS-Umfeld. Es deckt die meisten Ihrer Büroanforderungen ab: Dokumente, Tabellen, Präsentationen, Vektorzeichensoftware (für den Druck entwickelt) und Datenbanken.

Es verfügt im Allgemeinen über eine anständige, aber nicht perfekte Kompatibilität mit Microsoft Office, kann jedoch _sehr_ gut mit offenen Formaten umgehen. Wenn Sie sich vollständig vom Microsoft-Ökosystem lösen möchten, ist LibreOffice wahrscheinlich Ihre beste Option.

Es gibt auch eine webgehostete Version namens `Collabora Office`, die mit Einschränkungen verbunden ist, sofern Sie nicht für die Premiumversionen bezahlen.

#### OnlyOffice

[OnlyOffice](https://www.onlyoffice.com) ist eine etwas weniger umfassende, aber dennoch hervorragende Suite von Programmen zum Erstellen von Dokumenten, Präsentationen, Tabellenkalkulationen und PDFs. Bemerkenswert ist, dass es auch einen PDF-Editor enthält.

Wenn Sie Kompatibilität mit Microsoft Office benötigen, insbesondere für Dokumente und Präsentationen, ist OnlyOffice wahrscheinlich die beste Wahl. OnlyOffice verarbeitet Word-Dokumente besser als die Online-Version von Office365.

#### WPS Office

[WPS Office](https://www.wps.com), ehemals Kingsoft Office, ist schon seit geraumer Zeit im Linux-Ökosystem vertreten. Es unterstützt auch Dokumente, Tabellenkalkulationen, Präsentationen und einen PDF-Editor.

WPS Office ist etwas besser mit Microsoft Office kompatibel als LibreOffice, aber nicht so kompatibel wie OnlyOffice. Es verfügt außerdem über weniger Funktionen und ist weniger anpassbar. Dies ist ein Auszug aus ihrem Blog:

![WPS Office verfügt über eine modernere und benutzerfreundlichere Oberfläche als OnlyOffice. Außerdem ist es einfacher zu erlernen und zu verwenden, insbesondere für Anfänger. WPS Office verfügt außerdem über eine größere Auswahl an Vorlagen und Designs, die die Erstellung professioneller Dokumente erleichtern. OnlyOffice ist leistungsfähiger und individuell besser anpassbar als WPS Office. Es verfügt über ein breiteres Spektrum an Funktionen, darunter Tools für Dokumentenverwaltung und Projektmanagement. OnlyOffice is also more compatible with Microsoft Office formats than WPS Office.](images/businessapps-02.png)

Ihr Hauptaugenmerk liegt auf der Schaffung einer einfacheren und zugänglicheren Benutzererfahrung, die genau das sein könnte, was Sie möchten.

#### Calligra

Die Office-Suite [Calligra](https://calligra.org) ist ein FLOSS-Projekt der Entwickler von KDE. Es bietet einen benutzerfreundlichen Satz grundlegender Office-Apps zum Erstellen von Dokumenten, Tabellen, Präsentationen, Datenbanken, Flussdiagrammen, Vektorzeichnungen, E-Books und mehr.

Allerdings sind die Calligra-Apps auf Rocky Linux nicht einfach zu installieren. Wenn Sie über eine andere Maschine verfügen, auf der Fedora läuft, empfiehlt Ihnen der Autor, es auszuprobieren.

## Zusammenfassung

Mit einigen bemerkenswerten Ausnahmen können Sie Ihre gesamte Office-Software unter Rocky Linux verwenden, indem Sie die Apps auf Flathub finden oder einfach die Web-Variante verwenden. Auf jeden Fall dürfte Rocky Linux eine stabile und praktische Plattform für die meisten typischen Büroaufgaben sein.

Wenn die fehlende Unterstützung von Excel auf dem Desktop für Sie ein Problem darstellt, empfiehlt der Autor die Verwendung eines vollwertigen Datenbankservers. Datenbankserver können erstaunliche Dinge tun.
