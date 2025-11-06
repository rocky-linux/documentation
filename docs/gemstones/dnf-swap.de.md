- - -
title: dnf — swap-Befehl <br/> author: wale soyinka <br/> Translations: [https://crowdin.com/project/rockydocs](https://crowdin.com/project/rockydocs) <br/> Translators: [https://crowdin.com/project/rockydocs/activity-stream](https://crowdin.com/project/rockydocs/activity-stream) <br/> date: 2025-11-05 20h19 <br/> tags: <br/>
  - cloud images
  - container
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
- - -


# Einleitung

Um Container- und Cloud-Images so klein wie möglich zu halten, stellen Distributionsbetreuer und Paketmanager manchmal abgespeckte Versionen beliebter Pakete bereit. Beispiele für abgespeckte Pakete, die mit Containern oder Cloud-Images gebündelt werden, sind **vim-minimal, curl-minimal, coreutils-single** und so weiter.

Obwohl es sich bei einigen der bereitgestellten Pakete um abgespeckte Versionen handelt, sind sie für die meisten Anwendungsfälle oft völlig ausreichend.

In den Fällen, in denen das abgespeckte Paket nicht ausreichend ist, können Sie mit dem Befehl `dnf swap` schnell das Minimalpaket durch das normale Paket ersetzen.

## Zielsetzung

Dieser Rocky Linux GEMstone zeigt, wie man **dnf** verwendet, um den `vim-minimal`-Paket mit dem normalen `vim`-Paket austauscht.

## Bereits vorhandene `vim`-Variante prüfen

Wenn Sie als Benutzer mit Administratorrechten auf den Container oder die Umgebung der virtuellen Maschine zugreifen, prüfen Sie bitte zunächst, welche Variante des Pakets `vim` bereits installiert ist. Geben Sie bitte Folgendes ein:

```bash
# rpm -qa | grep  ^vim
vim-minimal-9.1.083-5.el10_0.1.x86_64
```

Sie haben `vim-minimal` auf Ihrem System bereits installiert.

## Ersetzen von `vim-minimal` durch `vim`

Verwenden Sie `dnf`, um das installierte Paket `vim-minimal` durch das reguläre Paket `vim` zu ersetzen.

```bash
# dnf -y swap vim-minimal vim
```

## Überprüfung der neuen `vim`-Paketvariante

Um die Änderungen zu bestätigen, fragen Sie die RPM-Datenbank erneut nach den installierten `vim`-Paketen ab, indem Sie folgenden Befehl ausführen:

```bash
# rpm -qa | grep  ^vim
vim-enhanced-9.1.083-5.el10_0.1.x86_64
```

Das war's!

## Anmerkungen

Das Kommando `dnf swap`

**Syntax:**

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Unter der Haube nutzt `dnf swap` die Option `--allowerasing` von DNF, um etwaige Paketkonflikte zu lösen. Daher hätte das in diesem GEMstone gezeigte Beispiel mit `vim-minimal` auch durch Ausführen des folgenden Befehls realisiert werden können:

```bash
dnf install -y --allowerasing vim
```
