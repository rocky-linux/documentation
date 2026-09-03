---
title: Moderner PC-Bootvorgang
author: Wale Soyinka
ai-contributor: Gemini 3 Flash-Image (Nano Banana 2)
---

# UEFI, SHIMs und Secure Boot

Wenn man bei einem modernen Computer den Netzschalter drückt, beginnt lange bevor Linux startet, eine komplexe Abfolge von Ereignissen.
Die Firmware initialisiert die Hardware, erkennt bootfähige Geräte, lädt die frühe Boot-Software und übergibt schließlich die Kontrolle an den Betriebssystemkern.
Jahrzehntelang beruhte dieser Prozess auf Firmware, die kaum oder gar keine Überprüfung dessen durchführte, was sie ausführte. Durch diese Konstruktion wurde der frühe Bootvorgang zu einem attraktiven Ziel für Schadsoftware.
UEFI und Secure Boot wurden eingeführt, um dieses Problem zu lösen.

Dieser Artikel stellt die moderne PC-Boot-Architektur vor und erklärt, warum Secure Boot existiert. In späteren Beiträgen dieser Reihe wird auf dieser Grundlage aufgebaut und untersucht, wie Linux-Distributionen Secure Boot integrieren.

## Der Bootvorgang im Überblick

Bevor man sich mit technischen Details befasst, ist es hilfreich, die allgemeinen Phasen der Systeminbetriebnahme zu verstehen.

Eine vereinfachte Version der modernen Bootsequenz sieht folgendermaßen aus:

1. System einschalten
2. Firmware-Initialisierung
3. Hardwareerkennung
4. Bootloader-Erkennung
5. Bootloader-Ausführung
6. Laden des Betriebssystem-Kernels

Jede Phase läuft mit extrem hohen Privilegien ab. Wenn ein Angreifer frühzeitig in diese Sequenz bösartigen Code einfügen kann, kann dieser Code möglicherweise alles kontrollieren, was später ausgeführt wird.

Aus diesem Grund stellt der Bootvorgang eine kritische Sicherheitsbarriere dar.

## Legacy-BIOS-Boot

Viele Jahre verwendeten PCs das Basic Input Output System, kurz BIOS.

Die BIOS-Firmware führt eine Hardware-Initialisierung durch und versucht dann, den ersten Sektor einer bootfähigen Festplatte in den Speicher zu laden.

Dieser Bereich wird Master Boot Record genannt.

Der Master Boot Record enthält sowohl eine Partitionstabelle als auch ein kleines Stück ausführbaren Codes, das die nächste Stufe des Bootloaders lädt.

Der Prozess sieht in etwa so aus:

1. Das BIOS initialisiert CPU, Speicher und Hardwaregeräte
2. Das BIOS wählt ein Startgerät aus
3. Das BIOS liest den Master Boot Record
4. Der MBR-Code lädt zusätzlichen Bootloader-Code
5. Der Bootloader lädt das Betriebssystem

Diese Konstruktion hat zwei wesentliche Einschränkungen.

Erstens ist der Master Boot Record nur 512 Byte groß, was die Funktionalität stark einschränkt.

Zweitens führt das BIOS keine kryptografische Überprüfung der geladenen Daten durch.

Wenn Schadsoftware den MBR verändert, wird die Firmware diese Änderung ohne Weiteres ausführen.

Diese Schwachstelle ermöglichte die Entwicklung einer Klasse von Schadsoftware, die als Bootkits bezeichnet werden.

## Bootkits und Malware für den frühen Systemstart

Bootkits sind so konzipiert, dass sie die frühesten Phasen des Bootvorgangs infizieren.

Im Gegensatz zu normaler Malware, die innerhalb des Betriebssystems ausgeführt wird, werden Bootkits ausgeführt, bevor der Betriebssystemkern geladen wird.

Dies macht sie besonders wirksam, denn:

- Sie können vor den Sicherheitstools des Betriebssystems verborgen werden
- Sie können das Laden des Kernels abfangen
- Sie können den Systemspeicher verändern, bevor die Schutzmechanismen aktiviert werden

Historisch gesehen zielten Bootkits auf Komponenten wie den Master Boot Record, den Bootloader-Code und Firmware-Erweiterungen ab

Da das BIOS keine Signaturprüfung durchführte, benötigten Angreifer lediglich Schreibzugriff auf die Festplatte oder die Firmware, um auch nach Neustarts bestehen zu können.

Diese Schwächen veranlassten die Branche, die Boot-Architektur zu überdenken.

![Legacy BIOS Boot Process](images/fig_1_secure_boot_1.png)

## Der Umstieg auf UEFI

Die Unified Extensible Firmware Interface ersetzt das ältere BIOS-Modell.

UEFI bietet eine flexiblere Firmware-Umgebung und führt das Konzept der Ausführung von EFI-Anwendungen während des Bootvorgangs ein.

Anstatt einen winzigen 512 Byte großen Sektor zu laden, lädt UEFI vollständige ausführbare Dateien, die auf einer dedizierten Partition, der sogenannten EFI-Systempartition, gespeichert sind.

Diese Dateien verwenden das PE-Executable-Format und haben typischerweise die Dateiendung `.efi`.

Beispiele hierfür sind:

- Bootloader wie GRUB
- Bootmanager wie `systemd-boot`
- Firmware-Dienstprogramme

!!! note "Bootloader vs. Bootmanager"

    Ein _Bootmanager_ ist dafür zuständig, auszuwählen, welches Betriebssystem oder welcher Boot-Eintrag gestartet werden soll. Es präsentiert ein Menü mit Auswahlmöglichkeiten und entscheidet, welches Boot-Ziel gestartet werden soll. Ein _Bootloader_ hingegen ist dafür zuständig, den Betriebssystemkern in den Speicher zu laden und die Kontrolle an ihn zu übergeben.
    
    In vielen Linux-Systemen sind diese Aufgaben in einem einzigen Programm zusammengefasst. Beispielsweise kann GRUB2 ein Bootmenü anzeigen (und fungiert dabei als Bootmanager) und anschließend den Linux-Kernel laden (und fungiert dabei als Bootloader).

Der moderne Bootvorgang sieht in etwa so aus:

1. System einschalten
2. Die UEFI-Firmware initialisiert die Hardware
3. Die Firmware lädt Konfigurationsvariablen
4. Die Firmware sucht nach EFI-Boot-Einträgen
5. Die Firmware lädt eine EFI-Anwendung
6. Die EFI-Anwendung lädt den Betriebssystemkernel

Diese Architektur ermöglicht einen wesentlich größeren Funktionsumfang als das herkömmliche BIOS-Modell.

Dadurch vergrößert sich jedoch auch die Angriffsfläche.

![UEFI Boot Process](images/fig_2_secure_boot_1.png)

## Die EFI-Systempartition

UEFI-Systeme speichern Bootloader in einer dedizierten Partition, die als EFI-Systempartition bezeichnet wird.

Diese Partition wird üblicherweise mit FAT32 formatiert und in Linux-Systemen unter `/boot/efi` eingebunden.

Verwenden Sie den Befehl `tree` oder `ls`, um den Inhalt der EFI-Systempartition anzuzeigen:

```
# tree  /boot/efi/
/boot/efi/
└── EFI
    ├── BOOT
    │   ├── BOOTX64.EFI
    │   └── fbx64.efi
    └── rocky
        ├── BOOTX64.CSV
        ├── grub.cfg
        ├── grubx64.efi
        ├── mmx64.efi
        ├── shim.efi
        ├── shimx64.efi
        └── shimx64-rocky.efi
```

Im Unterordner `/boot/efi/EFI/rocky/` finden Sie einige wichtige EFI-Programmdateien wie z. B. `shimx64.efi`, `grubx64.efi` usw. Da diese Dateien direkt von der Firmware ausgeführt werden, fungieren sie als kritische Sicherheitskomponenten.

Diese binären/ausführbaren EFI-Dateien bilden den Anfang der Linux-Bootkette.

In späteren Artikeln wird erläutert, wie diese Dateien signiert und verifiziert werden.

## Warum Secure Boot eingeführt wurde

UEFI allein macht Systeme nicht automatisch sicher.

Ohne Verifizierung würde die Firmware trotzdem jede beliebige EFI-Binärdatei ausführen, auf die sie stößt.

Secure Boot fügt einen kryptografischen Verifizierung-Schritt hinzu.

Wenn Secure Boot aktiviert ist, überprüft die Firmware vor der Ausführung, ob die EFI-Binärdateien mit vertrauenswürdigen Zertifikaten signiert sind.

Wenn eine Binärdatei nicht mit einem vertrauenswürdigen Schlüssel signiert ist, weigert sich die Firmware, sie auszuführen.

Dieser Mechanismus etabliert den Beginn einer Vertrauenskette, die sich über den Bootloader bis hin zum Betriebssystemkernel fortsetzt.

## Das Konzept einer Vertrauenskette

Secure Boot funktioniert, indem es das Vertrauen von einer Komponente zur nächsten erweitert.

Jede Stufe überprüft die nächste Stufe, bevor sie ausgeführt wird.

Die Prozedur folgt diesem Muster:

1. Firmware überprüft eine EFI-Anwendung
2. Die EFI-Anwendung überprüft die nächste Bootkomponente
3. Der Bootloader überprüft den Betriebssystemkernel

Wenn eine Phase der Überprüfung fehlschlägt, wird der Bootvorgang abgebrochen.

In späteren Artikeln wird detailliert erläutert, wie diese Vertrauenskette funktioniert.

## Praxistest: Ermitteln Sie, ob Ihr System UEFI verwendet

Sie können schnell feststellen, ob ein Linux-System mit UEFI gestartet wurde.

Führen Sie folgenden Befehl aus:

```
ls /sys/firmware/efi
```

Wenn das Verzeichnis existiert, wurde das System mit UEFI gestartet.

Falls das Verzeichnis nicht existiert, wurde das System im Legacy-BIOS-Modus gestartet.

## Praktische Anwendung: UEFI-Boot-Einträge anzeigen

Die UEFI-Firmware speichert Bootkonfigurationseinträge, die auf EFI-ausführbare Dateien verweisen.

Sie können sie mit dem Tool `efibootmgr` untersuchen.

Installieren Sie es nach Bedarf:

```
sudo dnf -y install efibootmgr
```

Dann führen Sie Folgendes aus:

```
efibootmgr -v
```

Hier werden die in der Firmware gespeicherten Boot-Einträge zusammen mit den Pfaden zu den EFI-Executables angezeigt.

Ein Beispiel für die Ausgabe ist in der folgenden Abbildung dargestellt:

![UEFI Boot Entries](images/fig_3_secure_boot_1.png)

Diese Einträge teilen der Firmware mit, welche EFI-Anwendungen beim Systemstart gestartet werden sollen.

## Zusammenfassung

In diesem Artikel haben wir untersucht, wie moderne Systeme starten und warum Secure Boot entwickelt wurde.

Zu den hier vorgestellten Kernideen gehören:

- Die Einschränkungen des Legacy-BIOS-Bootvorgangs
- Das Design der UEFI-Firmware
- Die Rolle von EFI-Anwendungen
- Die Bedeutung der frühen Boot-Sicherheit

Im nächsten Teil dieser Secure-Boot-Serie werden wir die kryptografischen Grundlagen untersuchen, die Secure Boot ermöglichen.

Wir werden digitale Signaturen, Public-Key-Kryptographie und das Konzept einer Vertrauenskette vorstellen.

