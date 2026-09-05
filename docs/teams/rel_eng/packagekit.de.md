---
title: Fehlende PackageKit-Elemente
author: Release Engineering
contributors: Steven Spencer
---

Das Folgende erklärt möglicherweise, warum Sie bestimmte Pakete in Rocky Linux nicht finden können.

## Fehlendes Paket

Das Paket, nach dem Sie suchen, ist in Rocky Linux nicht verfügbar. Dafür kann es verschiedene Gründe geben:

- Wir können keine Software aufnehmen, die mit Softwarepatenten belastet ist.
- Wir können keine Software aufnehmen, die nicht im Basis-Betriebssystem enthalten ist (verwenden Sie stattdessen die Repositorys von EPEL und der Special Interest Group).
- Im Fall einer SIG können wir keine proprietäre Software paketieren.
- Ein Betreuer hat es noch nicht für die Aufnahme in eine SIG paketiert.

## Fehlende Codecs

Die von Ihnen gesuchten Codecs sind in Rocky Linux nicht verfügbar. Ein Codec ist ein Programm zum Kodieren und Dekodieren eines Datenstroms in einem bestimmten Format (man denke an MP3, MOV oder WMV). Upstream – und damit auch Rocky Linux – verfügt im Allgemeinen nicht über solche Codecs.

Die Frage, die uns meistens gestellt wird, lautet: „Warum können Sie es nicht als SIG oder als Extra bereitstellen?“ Dies hat folgende Gründe:

- Viele Codecs sind proprietär oder patentrechtlich problematisch.
- Einige Codecs unterliegen zwar möglicherweise keinen Patentansprüchen, könnten aber unter einer inkompatiblen Lizenz stehen.

Wir ermutigen Nutzer dazu, entweder:

- Verwenden Sie bitte Formate wie OGG, Dirac und FLAC.
- Ziehen Sie in Betracht, ein Repository eines Drittanbieters zu nutzen, das solche Codecs bereitstellt, wie zum Beispiel `rpmfusion`.

  - Bitte beachten Sie, dass wir Sie nicht unterstützen können, wenn Sie sich für die Verwendung von Repositorys entscheiden, die nicht von der Community anerkannt sind.

## Fehlende Treiber

Da Rocky Linux versucht, mit Red Hat Enterprise Linux kompatibel zu sein, gibt es Einschränkungen hinsichtlich der Hardware, die von der Kernel-Konfiguration unterstützt wird. Wir empfehlen Ihnen, [ELRepo](https://elrepo.org) zu nutzen – dort finden Sie Kernel-Module (kmods) und neuere Kernel – oder SIG/Kernel, wo möglicherweise ähnliche Unterstützung angeboten wird.

## Fehlende Schriftarten

Die Schriftart, die Sie suchen, ist in Rocky Linux nicht verfügbar. Das liegt daran, dass wir nur Schriftarten aufnehmen, die in unseren Upstream-Quellen – CentOS Stream und Red Hat Enterprise Linux – verfügbar sind.
