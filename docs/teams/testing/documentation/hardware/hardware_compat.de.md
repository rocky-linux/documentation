---
title: Hardware-Kompatibilität
author: Chris Stackpole
contributors: Steven Spencer
translators:
---

## Historie

Eine häufige Frage lautet: „Lässt sich Rocky auf meinem Rechner installieren?“ Das ist eine wichtige Frage und die Antwort lautet im Allgemeinen:
`yes`. Die Frage wird jedoch anspruchsvoller, wenn sie lautet: „Wird Rocky mit diesem Gerät oder Setup funktionieren?“ Zu Beginn des Projekts benötigte das Testteam so viele Berichte wie möglich, um sicherzustellen, dass sich Rocky tatsächlich auf einer breiten Palette von Hardware installieren ließ. `xsos` hat diese Informationen zusammengetragen und im [Git-Repository hier](https://github.com/rocky-linux/testing/tree/main/test-reports) abgelegt.

Damals funktionierte es zwar gut, doch es war schwierig, Beiträge dazu zu leisten, und es war schwierig, darin zu suchen und zu filtern. Es gab seit Jahren keine Aktualisierungen dieser Berichte.

Die Fragen nach dem „Lässt sich Rocky auf … installieren?“ sind immer präsent. Dies sind nach wie vor berechtigte Fragen, da ständig neue Hardware auf den Markt kommt. Somit besteht der Wunsch, beim Aufbau einer Datenbank mitzuhelfen, die Nutzer durchsuchen und zu der sie beitragen können.

## Hardware-Probe-Projekt

Das [Hardware Probe-Projekt](https://github.com/linuxhw/hw-probe) hat sich zum Ziel gesetzt, diese Problematik zu beantworten. Es handelt sich um ein etabliertes Projekt mit [einer Website](https://linux-hardware.org), über die Benutzer nach Hardware und Systemen suchen können. Darüber hinaus gibt es zahlreiche Möglichkeiten, [the probe](https://linux-hardware.org/?view=howto) zu installieren und die Ergebnisse einfach sowie anonym einzureichen. Das Tool `hw-probe` analysiert und sammelt die Ausgaben einer Reihe von Dienstprogrammen – wie etwa `lspci`, `smartctl` und `hwinfo` –, um die Hardware zu verifizieren sowie das ordnungsgemäße Laden und die optimale Funktionalität der Treiber zu überprüfen, bevor die Daten an die Datenbank übermittelt werden.

Hier ist ein Beispiel für ein System, das mehrere für die Zwecke des [Testteams](https://linux-hardware.org/?probe=edebdf0568) nützliche Komponenten enthält.

## Motivation

Es gibt drei Gründe, warum das Testing-Team Sie bitten möchte, Ihr System zur Hardware-Probe-Projektdatenbank beizusteuern:

1. Ganz gleich, ob Sie Rocky oder eine andere Distribution verwenden: Die Unterstützung des Hardware-Probe-Projekts hilft allen Linux-Nutzern dabei, herauszufinden, ob ihre Hardware unter Linux unterstützt wird und funktioniert. Es ist gut für die größere Community.

2. Es baut eine Datenbank für die Community auf, die sich die Frage stellt: „Lässt sich Rocky auf … installieren?“ Das Beitragen Ihrer `hw-probe`-Ergebnisse zur Datenbank hilft dabei, diese Fragen zu behandeln. Je mehr Variationen und Beiträge es gibt, desto hilfreicher ist die Datenbank für andere, die auf EL basierende Distributionen wie Rocky Linux nutzen.

3. Manchmal wechseln die Treiber Upstream von Rocky oder fallen sogar vollständig aus. Es hilft dem Rocky-Testing-Team, Bedenken bezüglich Hardware zu erkennen und schneller zu beheben – insbesondere dort, wo Treiber eigentlich funktionieren sollten, aus irgendeinem Grund jedoch in neueren Releases nicht mehr funktionsfähig sind. Wenn ein Hardware-Bauteil zuvor funktioniert hat, nun aber nicht mehr, haben wir unter Umständen keinen Zugriff auf diese Hardware; dies kann die Suche nach Release Notes erschweren – falls die Hardware abgekündigt wurde – oder auch das Einreichen von Upstream-Fehlerberichten, sofern die Hardware eigentlich unterstützt werden sollte. Je mehr historische Daten dem Hardware-Testteam als Referenz zur Verfügung stehen, desto einfacher und schneller kann es bei der Behebung des Issues helfen.

## Wie Sie beitragen können

Glücklicherweise ist das Tool `hw-probe` für Rocky Linux in EPEL verfügbar – mit Ausnahme von Rocky Linux 10 (noch). Dies ist kein vollständiger und umfassender Leitfaden zur Verwendung dieses Tools. Es sind eine Reihe nützlicher Funktionen integriert, die im Folgenden nicht behandelt werden.
Hier behandeln wir lediglich die Funktionen, die für die Installation und das Hochladen in die Datenbank erforderlich sind.

### Rocky 8 und Rocky 9

Installieren Sie EPEL, falls Sie dies noch nicht getan haben:

```bash
dnf install -y epel-release
```

Installieren Sie `hw-probe`:

```bash
sudo dnf install -y hw-probe
```

Bitte beachten Sie, dass das EPEL-Paket nicht immer die Abhängigkeiten mitliefert.

Für alle Versionen müssen Sie diese Pakete installieren:

```bash
sudo dnf install -y tar curl
```

Installieren Sie zusätzlich `xorg-x11-utils` für `edid-decode` unter Rocky 8 [Hinweis: Dieses Paket ist für Version 9/10 nicht verfügbar; ignorieren Sie die Warnung]:

```bash
sudo dnf install -y xorg-x11-utils
```

Führen Sie die `hw-probe` aus und laden Sie die Ergebnisse hoch:

```bash
sudo -E hw-probe -all -upload
```

### Rocky 10

Für Rocky 10 ist `hw-probe` zum Zeitpunkt der Verfassung dieses Textes noch nicht im Haupt-EPEL-Repository enthalten; es wird jedoch bereits an dessen Erstellung gearbeitet ([siehe hier](https://packages.fedoraproject.org/pkgs/hw-probe/hw-probe)). In der Zwischenzeit besteht die einfachste Möglichkeit, `hw-probe` mit der geringstmöglichen Anzahl an zu installierenden Abhängigkeiten zu erhalten, darin, [das AppImage](https://github.com/linuxhw/hw-probe/blob/master/README.md#appimage) herunterzuladen und zu verwenden. Überprüfen Sie den Link auf die neueste Version. Die folgenden Beispiele verwenden Version `1.6.5-189`.

Sie müssen das Paket `libxcrypt-compat` installieren:

```bash
sudo dnf install -y libxcrypt-compat
```

Machen Sie das AppImage abschließend ausführbar:

```bash
chmod +x ./hw-probe-1.6.5-189-x86_64.AppImage
```

Führen Sie die `hw-probe` aus und laden Sie die Ergebnisse hoch:

```bash
sudo -E ./hw-probe-1.6.5-189-x86_64.AppImage -all -upload
```

### Benachrichtigen Sie das Testing-Team

Falls Sie die `hw-probe` auf einer offiziellen Rocky Linux Version ausführen (zum Zeitpunkt der Verfassung dieses Textes: 8.10, 9.7, 10.1), übermitteln Sie das Ergebnis bitte über chat.rockylinux.org (Mattermost-Chat) an das Testing-Team im Kanal „testing“. Dies wird lediglich nur empfohlen und ist nicht zwingend erforderlich. Es informiert das Testteam lediglich darüber, welche Hardware Sie eingereicht haben und welchen aktuellen Status diese bei Rocky hat. Dies bietet einen erheblichen Mehrwert für die breitere Community sowie für die historischen Aufzeichnungen des Testteams (um zu wissen, ob Hardware in früheren Releases funktioniert hat oder nicht).

Falls Sie die `hw-probe` auf einem Release Candidate oder einer Beta ausführen, ist es wichtig, den Link – unabhängig vom Status – unter [chat.rockylinux.org](https://chat.rockylinux.org) (Mattermost-Chat) im Release-Kanal zu melden. Falls dies nicht möglich ist, senden Sie Rocky Linux eine Direktnachricht über das soziale Netzwerk Ihrer Wahl oder posten Sie im Forum unter [forums.rockylinux.org](https://forums.rockylinux.org). Das Testing-Team kann nicht garantieren, dass Ihr Name bei Einsendungen außerhalb der Mattermost-Kanäle unter [chat.rockylinux.org](https://chat.rockylinux.org) in den Credits erscheint; wir werden jedoch unser Bestes geben, um alle Personen aufzunehmen, die Einsendungen beisteuern.

## Weitere Möglichkeiten, einen Beitrag zu leisten

Es wäre fantastisch, wenn `hw-probe` vollständig in EPEL für Version 10 aufgenommen würde – und zwar für so viele Architekturen wie möglich. Wir wären sehr dankbar für jeden, der über EPEL-Erfahrung verfügt und bereit ist, dabei mitzuwirken. Sie können den [Upstream-Fehlerbericht hier einsehen](https://bugzilla.redhat.com/show_bug.cgi?id=2479630) oder das [Issue des Testing-Teams verfolgen](https://github.com/rocky-linux/testing/issues/89).

Darüber hinaus wäre jeder, der zum Hardware Probe-Projekt beitragen möchte, eine große Hilfe. Sie suchen nach Personen, die beim Schreiben von Tests und bei der Verwaltung des Projekts unterstützen.

Abschließend möchten wir uns bei allen bedanken, die bereit sind, eine gute Methode zu entwickeln, mit der das Testteam alle Rocky-Einreichungen überprüfen kann, ohne die Upstream-Datenbank zu überlasten.
