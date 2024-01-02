---
title: Einführung in GNU/Linux
---

<!-- markdownlint-disable MD025 MD007 -->

# Einführung in GNU/Linux

In diesem Kapitel werden GNU/Linux Distributionen behandelt.

****

**Ziele**: In diesem Kapitel lernen Sie Folgendes:

:heavy_check_mark: Funktionen und mögliche Architekturen eines Betriebssystems beschreiben  
:heavy_check_mark: Die Entwicklung von UNIX und GNU/Linux  
:heavy_check_mark: Wie Sie die richtige Linux-Distribution für Ihre Bedürfnisse auswählen  
:heavy_check_mark: Die Philosophie der freien und Open-Source Software   
:heavy_check_mark: Die Anwendung der SHELL.

:checkered_flag: **Allgemeines**, **Linux**, **Distributionen**

**Vorwissen**: :star:

**Schwierigkeitsgrad**: :star:

**Lesezeit**: 11 Minuten

****

## Was ist ein Betriebsystem?

Linux, UNIX, BSD, VxWorks, Windows und MacOS sind Beispiele für **Betriebssysteme**.

!!! Abstrakt

    Ein Betriebssystem ist eine Sammlung von Programmen, die die **verfügbaren Komponenten eines Computers verwalten**.

Als Teil dieser Ressourcenverwaltung muss das Betriebssystem Folgendes tun:

* **Physikalischen** und **virtuellen** Speicher.

    * Der **physikalische Speicher** besteht aus den RAM-Balken und dem Prozessor-Cache-Speicher, die zur Ausführung von Programmen verwendet werden.

    * Der **virtuelle Speicher** ist ein Ort auf der Festplatte (die **Swap** Partition), der das Entladen des physikalischen Speichers und die Speicherung des aktuellen Status des Systems während des elektrischen Herunterfahrens des Computers ermöglicht.

* **Zugriff auf Peripheriegeräte** abfangen. Der Software ist selten erlaubt, auf Hardware direkt zuzugreifen (außer Grafikkarten für sehr spezifische Bedürfnisse).

* Bereitstellen von Anwendungen mit einem geeigneten **Task-Management**. Das Betriebssystem ist für die Planung von Prozessen verantwortlich, um den Prozessor zu belegen.

* **Schützt Dateien** vor unbefugtem Zugriff.

* **Sammeln von Informationen** über laufende Programme.

![Arbeitsweise eines Betriebssystems](images/operating_system.png)

## Allgemeines über UNIX und GNU/Linux

### Geschichte

#### UNIX

* Von **1964 bis 1968**: MULTICS (MULTiplexed Information and Computing Service) wurde für das MIT entwickelt, sowie für Bell Labs (AT&T) und General Electric.

* **1969 – 1971**: Nach dem Rückzug von Bell (1969) und dann von General Electric aus dem Projekt wurden zwei Entwickler, Ken Thompson und Dennis Ritchie (zu denen später Brian Kernighan hinzukam), die MULTICS für zu komplex hielten, mit der Entwicklung von UNIX (UNiplexed Information and Computing Service) betraut. Ursprünglich im Assembler entwickelt, entwickelten die Designer von UNIX die B-Sprache und dann die C-Sprache (1971) und schrieben UNIX. Seit 1970 ist das Referenzdatum (epoch) der UNIX/Linux-Systeme noch am 01. Januar 1970 festgelegt.

Die Programmiersprache C ist noch heute eine der beliebtesten Programmiersprachen. Eine Low-Level-Sprache, nahe der Hardware, sie ermöglicht die Anpassung des Betriebssystems an jede Maschinenarchitektur.

UNIX ist ein offenes und sich entwickelndes Betriebssystem, das eine wichtige Rolle in der Geschichte der Informatik gespielt hat. Es war die Basis für viele andere Systeme: Linux, BSD, MacOS, etc.

UNIX ist noch heute relevant (HP-UX, AIX, Solaris, etc.)

#### GNU Projekt

* **1984**: Richard Matthew Stallman startete das GNU (GNU's Not Unix) Projekt, das darauf abzielt, ein **freies** und **offenes** Unix System in dem die wichtigsten Tools enthalten sind: gcc Compiler, bash shell, Emacs Editor und so weiter. GNU ist ein Unix-ähnliches Betriebssystem. Die Entwicklung von GNU, die im Januar 1984 begonnen wurde, ist als GNU-Projekt bekannt. Viele der Programme in GNU werden unter der Schirmherrschaft des GNU-Projekts veröffentlicht, die wir GNU-Pakete nennen.

* **1990**: Gnus eigener Kernel, der GNU Kurt, wurde 1990 gestartet (bevor Linux selber).

#### MINIX

* **1987**: Andrew S. Tanenbaum entwickelt MINIX, eine vereinfachte UNIX-Variante, um Betriebssysteme auf einfache Weise zu lehren. Herr Tanenbaum stellt den Quellcode seines Betriebssystems zur Verfügung.

#### Linux

* **1991**: Ein finnischer Student, **Linus Torvalds**, erstellt ein Betriebssystem, das auf seinem PC läuft und es Linux benennt. Er veröffentlicht seine erste Version, genannt 0.02, im Usenet-Diskussionsforum, und andere Entwickler helfen ihm, sein System zu verbessern. Der Begriff Linux ist ein Wörterspiel zwischen dem Vornamen des Gründers Linus und UNIX.

* **1993**: Die Debian-Distribution wird erstellt. Debian ist eine nicht-kommerzielle, Community-basierte Distribution. Ursprünglich für den Einsatz auf Servern entwickelt, eignet es sich gut für diese Rolle, aber es ist ein universelles System, das auch auf einem PC nutzbar ist. Debian bildet die Basis für viele andere Distributionen, wie Mint oder Ubuntu.

* **1994**: Der kommerzielle Vertrieb von Red Hat wurde von der Firma Red Hat erstellt, das heute der führende Distributor des GNU/Linux-Betriebssystems ist. Red Hat unterstützt die Community-Version Fedora und bis vor kurzem die freie Distribution CentOS.

* **1997**: Die KDE-Arbeitsumgebung wird erstellt. Es basiert auf der Qt-Komponente und der C++-Entwicklungssprache.

* **1999**: Die GNOME-Desktopumgebung wird erstellt. Es basiert auf der GTK+-Bibliothek.

* **2002**: Die Arch-Distribution wird erstellt. Seine Besonderheit besteht darin, dass er rollende Versionen (kontinuierliche Aktualisierung) anbietet.

* **2004**: Ubuntu wird von der Firma Canonical  erstellt (Mark Shuttleworth). Es basiert auf Debian, enthält aber freie und proprietäre Software.

* **2021**: Rocky Linux wurde erstellt, basierend auf der Red Hat Distribution.

!!! info "Information"

    Kontroverse über den Namen: Obwohl die Leute daran gewöhnt sind, das Linux-Betriebssystem so zu nennen, ist Linux streng genommen ein Kernel. Wir dürfen die Entwicklung und den Beitrag des GNU-Projekts zu Open Source nicht vergessen! Wir ziehen es vor, das Betriebssystem GNU/Linux zu nennen.

### Marktanteile

<!--
TODO: graphics with market share for servers and pc.
-->

Trotz seiner großen Verbreitung ist Linux in der breiten Öffentlichkeit noch relativ unbekannt. Linux versteckt sich in **Smartphones**, **Fernsehgeräten**, **Internetboxen**, usw. Fast **70% der Websites** auf der Welt werden auf einem Linux oder UNIX Server gehostet!

Linux ist in etwa **3 % der Personal Computer**, aber in mehr als **82 % der Smartphones** verbaut. Das Betriebssystem **Android** verwendet beispielsweise einen Linux-Kernel.

<!-- TODO: review those stats -->

Linux rüstet seit 2018 100 % der 500 besten Supercomputer aus. Ein Supercomputer ist ein Computer, der darauf ausgelegt ist, mit den zum Zeitpunkt seiner Konstruktion bekannten Techniken die höchstmögliche Leistung zu erzielen, insbesondere im Hinblick auf die Rechengeschwindigkeit.

### Architektur-Design

* Der **Kernel** ist die erste Softwarekomponente.

    * Es ist das Herz des GNU/Linux-Systems.
    * Es verwaltet die Hardware-Ressourcen des Systems.
    * Die anderen Softwarekomponenten müssen den Kernel durchlaufen, um auf die Hardware zuzugreifen.

* Die **Shell** ist ein Dienstprogramm, das Benutzerbefehle interpretiert und deren Ausführung sicherstellt.

    * Die Wichtigsten sind: Bourne Shell, C Shell, Korn Shell und Bourne-Again Shell (bash).

* **Anwendungen** sind Benutzerprogramme, einschließlich, aber nicht beschränkt auf:

    * Internet-Browser
    * Textverarbeitung
    * Tabellenkalkulation

#### Multi-Task

Linux gehört zur Familie der Time-Sharing-Betriebssysteme. Es teilt die Verarbeitungszeit auf mehrere Programme auf und wechselt auf für den Benutzer transparente Weise von einem zum anderen. Das bedeutet:

* Gleichzeitige Ausführung mehrerer Programme.
* Verteilung der CPU-Zeit durch den Scheduler.
* Reduzierung von Problemen, die durch eine fehlgeschlagene Anwendung verursacht werden.
* Reduzierte Leistung, wenn zu viele Programme ausgeführt werden.

#### Mehrbenutzer

Der Zweck von MULTICS war es, mehreren Benutzern die Möglichkeit zu geben, von verschiedenen Terminals (Bildschirm und Tastatur) auf einem einzigen Computer zu arbeiten (sehr teuer zu dieser Zeit). Linux, inspiriert von diesem Betriebssystem, behielt die Möglichkeit bei, mit mehreren Benutzern gleichzeitig und unabhängig zu arbeiten, wobei jeder über ein eigenes Benutzerkonto mit Speicherplatz und Zugriffsrechten auf Dateien und Software verfügt.

#### Multi-Prozessor

Linux ist in der Lage, mit Multicore-Computern oder mit Multi-Core-Prozessoren zu arbeiten.

#### Multi-Plattform

Linux ist in einer Hochsprache geschrieben, die beim Kompilieren an verschiedene Plattformtypen angepasst werden kann. Dadurch kann es ausgeführt werden auf:

* Heimcomputer (PC und laptop)
* Server (Daten und Anwendungen)
* Tragbare Computer (Smartphones und Tablets)
* Eingebettete Systeme (Autocomputer)
* Aktive Netzwerk-Komponenten (Router und Switches)
* Haushaltsgeräte (Fernseher und Kühlschrank)

#### Offen

Linux basiert auf anerkannten Standards wie [POSIX](http://en.wikipedia.org/wiki/POSIX), [TCP/IP](https://en.wikipedia.org/wiki/Internet_protocol_suite), [NFS](https://en.wikipedia.org/wiki/Network_File_System) und [Samba](https://en.wikipedia.org/wiki/Samba_(software)), die es ihm erlauben, Daten und Dienste mit anderen Applikationssystemen zu teilen.

### Die UNIX/Linux Philosophie

* Alles wird wie eine Datei behandelt.
* Portabilität.
* Tue nur eine Sache auf einmal und mache sie gut.
* KISS: Keep It Simple Stupid.
* "UNIX ist im Grunde ein einfaches Betriebssystem, aber man muss ein Genie sein, um die Einfachheit zu verstehen." (**Dennis Ritchie**)
* "Unix is user-friendly. It just isn't promiscuous about which users it's friendly with." (**Steven King**)

## GNU/Linux-Distributionen

Eine Linux-Distribution ist ein **konsistenter Softwaresatz**, der rund um den Linux-Kernel zusammengestellt ist und zusammen mit den für die Selbstverwaltung erforderlichen Komponenten (Installation, Entfernung, Konfiguration) installiert werden kann. Es gibt **assoziative** oder **Community**-Distributionen (Debian, Rocky) und ** kommerzielle **Distributionen (Red Hat, Ubuntu).

Jede Distribution bietet eine oder mehrere **Desktop-Umgebungen** und stellt eine Reihe vorinstallierter Software und eine Bibliothek mit zusätzlicher Software bereit. Konfigurationsoptionen (zum Beispiel Kernel- oder Dienste-Optionen) sind spezifisch für jede Distribution.

Dieses Prinzip ermöglicht es, Distributionen auf **Einsteiger** (Ubuntu, Linux Mint...) oder vollständig anpassbar für **fortgeschrittene Benutzer** auszurichten (Gentoo, Arch). Distributionen können auch mit **Servern** (Debian, Red Hat) oder **Workstations** (Fedora) besser geeignet sein.

### Desktop-Umgebungen

Es gibt viele grafische Umgebungen wie **GNOME**, **KDE**, **LXDE **, **XFCE** usw. Für jeden ist etwas dabei, und ihre **Ergonomie** kann sich mit den Systemen von Microsoft oder Apple messen.

Warum also gibt es so wenig Begeisterung für Linux, wenn dieses System **frei** ist? Könnte es daran liegen, dass so viele Editoren (Adobe) und Hersteller (Nvidia) nicht immer mitspielen und selten eine Version ihrer Software oder __Treiber__ für GNU/Linux bereitstellen? Vielleicht ist es die Angst vor Veränderungen, oder die Schwierigkeit zu finden, wo man einen Linux-Computer kaufen kann, oder zu wenige Spiele, die unter Linux verteilt werden. Zumindest diese letzte Ausrede sollte mit dem Aufkommen der Spiele-Engine Steam für Linux nicht mehr lange zutreffen.

![GNOME-Desktop](images/01-presentation-gnome.png)

Die **GNOME 3**-Desktopumgebung verwendet nicht mehr das Konzept des Desktops, sondern das der GNOME-Shell (nicht zu verwechseln mit der Befehlszeilen-Shell). Es dient als Arbeitsfläche, als Dashboard, als Benachrichtigungsbereich und als Fensterauswahl. Die GNOME-Desktopumgebung basiert auf der **GTK+** Komponentenbibliothek.

![KDE-Desktop](images/01-presentation-kde.png)

Die **KDE**-Desktopumgebung basiert auf der **Qt**-Komponentenbibliothek. Es wird traditionell für Benutzer empfohlen, die mit einer Windows-Umgebung vertraut sind.

![Tux - das Linux-Maskottchen](images/tux.png)

### Freie Software versus Open source

Ein Benutzer eines Microsoft- oder Mac-Betriebssystems muss eine Lizenz erwerben, um das Betriebssystem zu nutzen. Diese Lizenz ist mit Kosten verbunden, obwohl sie in der Regel transparent ist (der Preis der Lizenz ist im Preis des Computers inbegriffen).

In der Welt **GNU/Linux** bietet die Bewegung der Freien Software freie Distributionen.

**Frei** ist gemeint im Sinne von Freiheit nicht von Freibier!

**Open Source**: die Quellen sind verfügbar, es ist möglich, sie einzusehen und verändern, aber nur unter bestimmte Bedingungen.

Eine freie Software ist notwendigerweise Open-Source, aber das Gegenteil trifft nicht zu, da Open-Source-Software sich von der Freiheit unterscheidet, die die GPL-Lizenz bietet.

#### GNU GPL (GNU General Public License)

Die **GPL** garantiert dem Autor einer Software ihr geistiges Eigentum, erlaubt aber Modifikationen, Weitergabe oder Weiterverkauf von Software durch Dritte, vorausgesetzt, der Quelltext ist in der Software enthalten. Die GPL ist die Lizenz, die aus dem **GNU**-Projekt (GNU ist Nicht UNIX) hervorgegangen ist, das maßgeblich an der Entwicklung von GNU/Linux beteiligt war.

Das bedeutet:

* Die Freiheit, das Programm für jeden Zweck auszuführen.
* Die Freiheit, die Funktionsweise des Programms zu studieren und an eigene Bedürfnisse anzupassen.
* Die Freiheit, Kopien weiterzugeben.
* Die Freiheit, das Programm zu verbessern und diese Verbesserungen zum Nutzen der gesamten Community zu veröffentlichen.

Auf der anderen Seite können auch Produkte, die unter der GPL lizenziert sind, Kosten verursachen. Dabei geht es nicht um das Produkt selbst, sondern um die **Garantie, dass ein Entwicklerteam weiter daran arbeitet. Es geht auch darum es weiterzuentwickeln und Fehler zu beheben oder sogar Benutzerunterstützung zu leisten**.

## Anwendungsbereiche

Eine Linux-Distribution zeichnet sich aus für:

* **Server**: HTTP, E-Mail, Groupware, File-Sharing usw.
* **Sicherheit**: Gateway, Firewall, Router, Proxy, usw.
* **Zentralrechner**: Banken, Versicherungen, Industrie usw.
* **Eingebettete Systeme**: Router, Internet-Boxen, SmartTVs, usw.

Linux ist eine geeignete Wahl für das Hosting von Datenbanken, Websites, als Mail-Server, DNS oder Firewall. Kurz gesagt, Linux kann fast alles tun, was die Vielfalt der spezifischen Distributionen erklärt.

## Shell

### Allgemeines

Die **Shell**, bekannt als _Kommandoschnittstelle_, ermöglicht Benutzern Befehle an das Betriebssystem zu schicken. Sie ist heute weniger sichtbar seit der Implementierung von grafischen Schnittstellen aber bleibt ein privilegiertes Mittel auf Linux-Systemen, die nicht alle über grafische Schnittstellen verfügen und deren Dienste nicht immer über eine Schnittstelle für Einstellungen verfügen.

Sie bietet eine echte Programmiersprache mit den klassischen Strukturen (Schleifen, Abzweigungen) und allgemeine Bestandteile (Variablen, Übergabe von Parametern und Unterprogramme). Sie erlaubt die Erstellung von Skripten zur Automatisierung bestimmter Aktionen (Backups, Erstellung von Benutzerkonten, Systemüberwachung, usw.).

Es gibt verschiedene Arten von Shells, die auf einer Plattform oder nach den Vorlieben des Benutzers konfiguriert werden können. Einige Beispiele sind:

* sh, die POSIX Standard Shell
* csh, Kommando-Orientierte Shell in C
* bash, Bourne-Again Shell, Linux shell

### Funktionen

* Befehlsausführung (überprüft den gegebenen Befehl und führt ihn aus).
* Eingabe-/Ausgabe-Umleitung (gibt Daten in eine Datei aus, anstatt sie auf den Bildschirm zu schreiben).
* Verbindungsprozess (verwaltet die Anmeldung des Benutzers).
* Interpretierte Programmiersprache (erlaubt die Erstellung von Skripten).
* Umgebungsvariablen (Zugriff auf systemspezifische Informationen während des Betriebs).

### Grundsatz

![Arbeitsweise der SHELL](images/shell-principle.png)

## Testen Sie Ihr Wissen

:heavy_check_mark: Ein Betriebssystem ist eine Zusammenstellung von Programmen zur Verwaltung der verfügbaren Ressourcen eines Computers:

* [ ] Wahr
* [ ] Falsch

:heavy_check_mark: Das Betriebssystem ist notwendig z.B. um:

* [ ] Physischen und virtuellen Speicher verwalten.
* [ ] Direkten Zugriff auf Geräte zulassen
* [ ] die Aufgabenverwaltung dem Computer überlassen
* [ ] Informationen über benutzte Programme oder gerade in Verwendung

:heavy_check_mark: Welche dieser Persönlichkeiten waren an der Entwicklung von UNIX beteiligt:

* [ ] Linus Torvalds
* [ ] Ken Thompson
* [ ] Lionel Richie
* [ ] Brian Kernighan
* [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: Die ursprüngliche Nationalität von Linus Torvalds, Schöpfer des Linux-Kernels, ist:

* [ ] Swedisch
* [ ] Finnisch
* [ ] Norwegisch
* [ ] Flämisch
* [ ] Französisch

:heavy_check_mark: Welche der folgenden Distributionen ist die älteste:

* [ ] Debian
* [ ] Slackware
* [ ] Red Hat
* [ ] Arch

:heavy_check_mark: ist der Linux-Kernel:

* [ ] Multitasking
* [ ] Multi-User
* [ ] Multi-Prozessor
* [ ] Multi-Core
* [ ] Plattformübergreifend
* [ ] Offen

:heavy_check_mark: Ist Freie Software notwendigerweise Open-Source?

* [ ] Wahr
* [ ] Falsch

:heavy_check_mark: Ist Open-Source-Software notwendigerweise frei?

* [ ] Wahr
* [ ] Falsch

:heavy_check_mark: Was von den Folgenden ist keine Shell:

* [ ] Jason
* [ ] Jason-Bourne Shell (jbsh)
* [ ] Bourne-Again Shell (bash)
* [ ] C Shell (csh)
* [ ] Korn Shell (ksh)  
