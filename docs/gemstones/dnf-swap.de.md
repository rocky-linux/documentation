---
title: dnf — das Kommando swap
author: Wale Soyinka
contributors:
date: 2023-01-24
tags:
  - Cloud-Images
  - Container
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
---

# Einleitung

Um Container- und Cloud-Images so klein wie möglich zu halten, stellen Distributionsbetreuer und Paketmanager manchmal abgespeckte Versionen beliebter Pakete bereit. Beispiele für abgespeckte Pakete, die mit Containern oder Cloud-Images gebündelt werden, sind **vim-minimal, curl-minimal, coreutils-single** und so weiter.

Obwohl es sich bei einigen der bereitgestellten Pakete um abgespeckte Versionen handelt, sind sie für die meisten Anwendungsfälle oft völlig ausreichend.

Für Fälle, in denen das abgespeckte Paket nicht ausreicht, können Sie den Befehl `dnf swap` verwenden, um das Minimalpaket schnell durch das reguläre Paket zu ersetzen.

## Zielsetzung

Dieses Rocky Linux GEMstone demonstriert, wie man mit **dnf** das mitgelieferte Paket `vim-minimal` durch das reguläre Paket `vim` _austauscht_.

## Bereits vorhandene `vim`-Variante überprüfen

Überprüfen Sie zunächst, welche Variante des `vim`-Pakets installiert ist, während Sie als Benutzer mit Administratorrechten in Ihrer Container- oder virtuellen Maschinenumgebung angemeldet sind. Geben Sie bitte Folgendes ein:

```bash
# rpm -qa | grep  ^vim
vim-minimal-8.2.2637-22.el9_6.1.x86_64
```

Das Paket `vim-minimal` ist auf Ihrem System vorhanden.

## Ersetzen von `vim-minimal` durch `vim`

Verwenden Sie `dnf`, um das installierte Paket `vim-minimal` durch das normale Paket `vim` auszutauschen.

```bash
# dnf -y swap vim-minimal vim

```

## Neue `vim`-Paketvariante überprüfen

Um die Änderungen zu bestätigen, fragen Sie die rpm-Datenbank erneut nach den installierten `vim`-Paketen ab, indem Sie folgenden Befehl ausführen:

```bash
# rpm -qa | grep  ^vim
vim-enhanced-8.2.2637-22.el9_6.1.x86_64
```

Das war's!

## Anmerkungen

Das Kommando `dnf swap`

**Syntax**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Im Hintergrund nutzt `dnf swap` die Option `--allowerasing` von DNF, um etwaige Paketkonflikte zu lösen. Das in diesem GEMstone gezeigte minimale `vim`-Beispiel hätte daher auch durch Ausführen von folgendem Befehl realisiert werden können:

```bash
dnf install -y --allowerasing vim
```
