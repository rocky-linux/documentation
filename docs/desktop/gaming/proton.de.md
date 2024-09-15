---
title: Gaming unter Linux mit Proton
author: Joseph Brinkman
contributors: Steven Spencer
---

## Einleitung

`Proton` ist ein Projekt von `Valve`, um Gaming innerhalb ihres `Steam`-Clients auf den Linux-Desktop zu bringen. `Proton` ist ein Fork von [Wine](https://www.winehq.org/), einer Kompatibilitätsschicht, die zum Ausführen von Windows-Anwendungen unter Linux (und anderen POSIX-kompatiblen Betriebssystemen) verwendet wird.

Seit der Einführung von `Proton` im August 2018 wurden 802 Bewertungen in der [Proton Compatible Steam Group](https://store.steampowered.com/curator/33483305-Proton-Compatible/about/) gepostet! Dies ist ein enormer Fortschritt für `Valve` und die `Proton`-Community, da zum ursprünglichen Veröffentlichungsdatum nur 27 Spiele getestet und zertifiziert wurden.

Im Gegensatz zu `Wine` erfordert `Proton` normalerweise keine Konfiguration und richtet sich an absolute Anfänger. Installieren Sie einfach `Steam` und aktivieren Sie `Proton`!

## Voraussetzungen

- Eine Rocky Linux-Installation mit einer grafischen Desktopumgebung
- Flatpak
- Steam-Konto

## `Steam`-Installaton

`Steam` mit Flatpak installieren:

```bash
flatpak install steam 
```

Geben Sie Option `20` ein, um `app/com.valvesoftware.Steam/x86_64/stable` auszuwählen, und drücken Sie ++enter++, um `Steam` zu installieren.

![Installing Steam option 20](images/Timeline_1_01_00_22_00.jpg)

Nach der Installation von Steam wird die Aktualisierung automatisch gestartet.

![Steam updates](images/Timeline_1_01_04_16_00.jpg)

Nach dem Update müssen Sie sich in Ihrem Steam-Konto anmelden. Eröffnen Sie ein Konto, wenn Sie noch keins haben.

![Steam](images/Timeline_1_01_06_09_04.jpg)

## `Proton`-Kompatibilität aktivieren

Nachdem Sie sich bei `Steam` angemeldet haben, klicken Sie oben links auf ++"Steam"++ und wählen Sie dann ++"Settings"++.

![Steam settings](images/Timeline_1_01_10_18_38.jpg)

Wählen Sie ++"Compatibility"++ aus dem linken Menü in den Steam-Einstellungen.

![Compatibility settings](images/Timeline_1_01_10_58_27.jpg)

Beachten Sie auf dem Foto oben, dass`Enable Steam Play for supported titles` aktiviert ist und `Enable Steam Play for all other titles` nicht. Dies bedeutet, dass Spiele, deren Funktionsfähigkeit auf Proton getestet und verifiziert wurde, spielbar sind, nicht verifizierte Spiele jedoch nicht laufen. Einige nicht verifizierte Titel funktionieren nahezu einwandfrei mit Proton, es fehlen jedoch Controller-Zuordnungen oder einige Kleinigkeiten. Aus diesem Grund empfiehlt der Autor, bei nicht unterstützten Titeln das Steam-Play zu aktivieren und diese selbst auszuprobieren!

Aktivieren Sie "Enable Steam Play for all other titles". Starten Sie Steam neu, wenn Sie dazu aufgefordert werden.

![Steam play for all other titles toggled](images/Timeline_1_01_11_07_44.jpg)

## Zusammenfassung

Laden Sie nach dem Neustart von `Steam` Ihren Lieblings-Windows-Titel herunter und probieren Sie ihn aus! Es ist keine weitere Konfiguration erforderlich. Viel Spaß!
