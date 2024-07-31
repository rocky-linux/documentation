- - -
title: dnf - swap command author: wale soyinka contributors: date: 2023-01-24 tags:
  - Cloud-Images
  - Container
  - dnf
  - dnf swap
  - curl
  - curl-minimal
  - allowerasing
  - coreutils-single
- - -


# Einleitung

Um Container- und Cloud-Images so klein wie möglich zu halten, stellen Distributionsbetreuer und Paketmanager manchmal abgespeckte Versionen beliebter Pakete bereit. Beispiele für abgespeckte Pakete, die mit Containern oder Cloud-Images gebündelt werden, sind **vim-minimal, curl-minimal, coreutils-single** und so weiter.

Obwohl es sich bei einigen der bereitgestellten Pakete um abgespeckte Versionen handelt, sind sie für die meisten Anwendungsfälle oft völlig ausreichend.

In den Fällen, in denen das abgespeckte Paket nicht ausreichend ist, können Sie mit dem Befehl `dnf swap` schnell das Minimalpaket durch das normale Paket ersetzen.

## Zielsetzung

Dieser Rocky Linux GEMstone zeigt, wie man **dnf swap** verwendet, um den `curl-minimal`-Paket mit dem normalen `curl`-Paket austauscht.

## Bereits vorhandene curl-Variante prüfen

Wenn Sie als Benutzer mit Administratorrechten auf den Container oder die Umgebung der virtuellen Maschine zugreifen, prüfen Sie bitte zunächst, welche Variante des Pakets `curl` bereits installiert ist. Geben Sie bitte Folgendes ein:

```bash
# rpm -qa | grep  ^curl-minimal
curl-minimal-*
```

curl-minimal ist auf unserem Demosystem installiert!

## curl-minimal durch curl ersetzen

Verwenden Sie `dnf`, um das installierte Paket `curl-minimal` durch das reguläre Paket `curl` auszutauschen.

```bash
# dnf -y swap curl-minimal curl

```

## Neue Curl-Paketvariante überprüfen

Um die Änderungen zu übernehmen, fragen Sie die RPM-Datenbank erneut nach installierten Curl-Pakete ab, indem Sie Folgendes ausführen:

```bash
# rpm -qa | grep  ^curl
curl-*
```

Das war's!

## Anmerkungen

Das Kommando DNF Swap

**Syntax:**

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Unter der Haube nutzt `dnf swap` die Option `--allowerasing` von DNF, um etwaige Paketkonflikte zu lösen. Daher hätte das in diesem GEMstone gezeigte Minimal-Curl-Beispiel auch durch Folgendes ausgeführt werden können:

```bash
dnf install -y --allowerasing curl
```
