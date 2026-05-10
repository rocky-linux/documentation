---
title: openQA – openqa-cli POST — Beispiele
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  level: Final
  r8: "8.10"
  r8date: 20250527
  r9: "9.6"
  r9date: 20250604
  r10: "10.0"
  r10date: 20250707
render_macros: true
---

# openqa-cli POST-Beispiele

Diese Seite bietet einen kurzen Überblick über einige grundlegende `openqa-cli` `POST`-Beispiele.

## System-/Zugriffsanforderungen

Um eines der Beispiele durchzuarbeiten, führen Sie bitte die im Dokument [openQA - Rocky Production Access](openqa_access.md) beschriebenen API `POST`-Zugriffsschritte durch.

## Basic POST

Für jede der standardmäßigen Testsuiten für die verschiedenen {{ rc.prod }}-Medien, die zur Verfügung gestellt werden, kann ein einfacher `POST`-Request verwendet werden. Die folgenden Beispiele zeigen einige dieser Standard-`POST`-Anfragen, die von unserem Team häufig verwendet werden und anhand derer einige kleinere Variationen veranschaulicht werden.

### FLAVOR=boot-iso

Dieser erste `POST`-Aufruf ist der einfachste und stellt lediglich die minimalen Variablen bereit, die erforderlich sind, um die Standard-Testsuite für das {{ rc.prod }} {{ rc.r9 }} Boot-ISO auf OpenQA-Workern für die `x86_64`-Architektur auszulösen. Alle Tests der Testsuite sind vordefiniert und auf dem openQA-Server konfiguriert. Da die Boot-ISO keine Pakete enthält, handelt es sich bei dieser Testsuite effektiv um eine Netzwerkinstallation von Standard-Repository-Servern {{ rc.prod }} und/oder Spiegelservern.

```bash
$ openqa-cli api -X POST isos ISO=Rocky-{{ rc.r9 }}-x86_64-boot.iso ARCH=x86_64 \
  DISTRI=rocky FLAVOR=boot-iso VERSION={{ rc.r9}} CURRREL=9 BUILD={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0
```

### FLAVOR=minimal-iso

Dieser `POST`-Request demonstriert, wie ein anderer Medientyp, in diesem Fall das minimale ISO-Format, für eine alternative {{ rc.prod }} Version, in diesem Fall {{ rc.prod }} {{ rc.r8 }}, ausgelöst werden kann. Wie aus diesem und dem vorherigen `POST`-Befehl hervorgeht, bezeichnet die Variable `BUILD` typischerweise das Datum, die Version und die Architektur der Testsuite. Da das minimale ISO alle Pakete enthält, die für eine _**minimale**_ Installation von {{ rc.prod }} erforderlich sind, entspricht dies dem Verhalten dieser Testsuite.

```bash
$ openqa-cli api -X POST isos ISO=Rocky-{{ rc.r8 }}-x86_64-minimal.iso ARCH=x86_64 \
  DISTRI=rocky FLAVOR=minimal-iso VERSION={{ rc.r8 }} CURRREL=8 BUILD={{ rc.r8date }}-Rocky-{{ rc.r8 }}-x86_64.0
```

### FLAVOR=package-set

Dieser `POST` demonstriert die Spezifikation des endgültigen normalen Medientyps, der DVD-ISO, zusammen mit einem sogenannten `FLAVOR`, in diesem Fall einem `package-set` für die Architektur `x86_64` und {{ rc.prod }} {{ rc.r9 }}. Da die DVD-ISO alle Pakete enthält, die zum Zeitpunkt der Veröffentlichung einer bestimmten Version oder {{ rc.prod }} verfügbar sind, testet die Testsuite `package-set` die Installation aller primären Installationstypen von {{ rc.prod }}, die nicht in der oben genannten Testsuite `minimal-iso` enthalten sind.

```bash
$ openqa-cli api -X POST isos ISO=Rocky-{{ rc.r9 }}-x86_64-dvd.iso ARCH=x86_64 \
  DISTRI=rocky FLAVOR=package-set VERSION={{ rc.r9 }} CURRREL=9 BUILD={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0
```

Diese drei Testreihen gewährleisten das Mindesttesting aller ISOs, die für eine bestimmte Version von {{ rc.prod }} erstellt werden.

## Advanced POST

Zusätzlich zu den oben beschriebenen [Basic POSTs](#basic-post) gibt es weitere Standardtest-Suites, die das DVD-ISO-Medium verwenden und wesentlich mehr Testfälle enthalten. Dazu zählen:

- Installation in grafischer, textbasierter und serieller Konsole
- Installation für Standard-BIOS und UEFI
- Validierung des Anaconda-Hilfesystems
- Verschiedene Festplattenlayout-Varianten, einschließlich LVM, RAID, Partitionsverkleinerung und/oder -vergrößerung, iSCSI und LUKS
- PXE-Installation von verschiedenen Netzwerkquellen
- Installation in verschiedenen Sprachen

Die Standard-POST-Anfragen für diese Test-Suites ähneln sehr den oben genannten grundlegenden POST-Anfragen und werden im Folgenden dargestellt...

### FLAVOR=dvd-iso

```bash
$ openqa-cli api -X POST isos ISO=Rocky-{{ rc.r9 }}-x86_64-dvd.iso ARCH=x86_64 \
  DISTRI=rocky FLAVOR=dvd-iso VERSION={{ rc.r9 }} CURRREL=9 BUILD={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0
```

### FLAVOR=universal

```bash
$ openqa-cli api -X POST isos ISO=Rocky-{{ rc.r9 }}-x86_64-dvd.iso ARCH=x86_64 \
  DISTRI=rocky FLAVOR=universal VERSION={{ rc.r9 }} CURRREL=9 BUILD={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0
```

## Sammlung von Testsuiten nach BUILD

Eine Besonderheit von openQA ist, dass für eine bestimmte Jobgruppe Testsuiten, die denselben `BUILD`-Identifikator verwenden, in einer einzigen Ansicht in der Web-Benutzeroberfläche zusammengefasst werden.

![openQA Home View...](../../../../assets/teams/testing/openqa_home_view.png){ loading=lazy }

Daher werden die oben gezeigten Beispiele, die alle `BUILD={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0` verwenden, alle in einer einzigen Ansicht angezeigt. Diese Ansicht ist außerdem über eine vorhersehbare URI zugänglich, beispielsweise [`https://openqa.rockylinux.org/tests/overview?build={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0`](https://openqa.rockylinux.org/tests/overview?build={{ rc.r9date }}-Rocky-{{ rc.r9 }}-x86_64.0), wie unten dargestellt...

![openQA Build View...](../../../../assets/teams/testing/openqa_build_view.png){ loading=lazy }

## Referenzen

[openQA-Documentation](https://open.qa/documentation/)

{% include 'teams/testing/content_bottom.md' %}
