---
title: Python VENV Methode
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova, Joey Brinkman
tested_with: 8.7, 9.1, 9.4
tags:
  - mkdocs
  - Testen
  - Dokumentation
---

# MkDocs (Python Virtual Environment)

## Einleitung

Einer der Aspekte beim Erstellen der Dokumentation für Rocky Linux besteht darin, vor der Veröffentlichung zu überprüfen, ob Ihr neues Dokument korrekt angezeigt wird.

Das Ziel dieses Leitfadens ist es, einige Vorschläge für die Durchführung dieser Aufgabe in einer lokalen Python-Umgebung zu geben, die ausschließlich zu diesem Zweck gewidmet ist.

Die Dokumentation für Rocky Linux ist in der Sprache Markdown geschrieben und wird im Allgemeinen in andere Formate konvertiert. Markdown weist eine elegante Syntax auf und eignet sich besonders gut zum Schreiben technischer Dokumentationen.

In unserem Fall wird die Dokumentation mit Hilfe einer Python-Anwendung in `HTML` konvertiert, die sich um das Erstellen der statischen Seite kümmert. Die von den Entwicklern verwendete Anwendung ist [MkDocs](https://www.mkdocs.org/).

Ein Problem, das bei der Entwicklung einer Python-Anwendung auftritt, ist die Isolierung der Python-Instanz, die für die Entwicklung vom System-Interpreter verwendet wird. Die Isolierung verhindert Inkompatibilitäten zwischen den zur Installation der Python-Anwendung erforderlichen Modulen und den auf dem Hostsystem installierten Modulen.

Es gibt bereits hervorragende Anleitungen, die **Container** zur Isolierung des Python-Interpreters verwenden. Allerdings setzen diese Anleitungen Kenntnisse über verschiedene Containerisierungstechniken voraus.

In dieser Anleitung wird das `venv` Modul, das vom *python* Paket von Rocky Linux zur Isolierung verwendet. Dieses Modul ist seit Version 3.6 auf allen neuen Versionen von *Python* verfügbar. Dadurch wird die Isolierung des Python-Interpreters auf dem System direkt erreicht, ohne dass neue "**Systeme**" installiert und konfiguriert werden müssen.

### Voraussetzungen

- eine laufende Instanz von Rocky Linux
- eine geeignete Installation des *python* Pakets
- Erfahrung mit der Kommandozeile
- eine aktive Internetverbindung

## Vorbereitung der Umgebung

Die Umgebung stellt einen Root-Ordner zur Verfügung, der die zwei erforderlichen Rocky Linux GitHub Repositories und den Ordner enthält, in dem initialisiert wird, und das Ausführen Ihrer Python-Kopie in der virtuellen Umgebung erfolgt.

Erstellen Sie zunächst den Ordner, der alles andere enthält, und erstellen Sie gleichzeitig auch den Ordner **env**, in dem MkDocs ausgeführt wird:

```bash
mkdir -p ~/lab/rockydocs/env
```

### Virtuelle Python-Umgebung

Um Ihre eigene Kopie von Python zu erstellen, in der MkDocs ausgeführt wird, verwenden Sie das speziell für diesen Zweck entwickelte Modul, das Python-Modul `venv`. Dadurch können Sie eine virtuelle Umgebung erstellen, die von der auf dem System installierten Umgebung abgeleitet ist und völlig isoliert und unabhängig ist.

Dies ermöglicht es uns, in einem separaten Ordner eine Kopie des Interpreters zu haben, die nur die Pakete enthält, die von `MkDocs` zum Generieren der Rocky Linux-Dokumentation benötigt werden.

Wechseln Sie zu dem gerade erstellten Ordner (*rockydocs*) und erstellen Sie die virtuelle Umgebung mit folgenden Anweisungen:

```bash
cd ~/lab/rockydocs/
```

```bash
python -m venv env
```

Der Befehl füllt den Ordner **env** mit einer Reihe von Ordnern und Dateien, die den *Python*-Baum des Systems nachahmen, ähnlich wie Folgendes:

```text
env/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.11
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.11 -> python
├── include
│   └── python3.11
├── lib
│   └── python3.11
├── lib64 -> lib
└── pyvenv.cfg
```

Wie Sie sehen können, ist der von der virtuellen Umgebung verwendete Python-Interpreter immer noch derjenige, der auf dem System verfügbar ist `python -> /usr/bin/python`. Der Virtualisierungsprozess kümmert sich nur um die Isolierung Ihrer Instanz.

#### Aktivierung der Virtuelle Umgebung

Unter den in der Struktur aufgelisteten Dateien befinden sich mehrere Dateien mit dem Namen **activate**, die diesem Zweck dienen. Das Suffix jeder Datei gibt die entsprechende *Shell* an.

Durch die Aktivierung wird diese Python-Instanz von der System-Python-Instanz getrennt und ermöglicht eine störungsfreie Entwicklung der Dokumentation. Um es zu aktivieren, wechseln Sie zum Ordner *env* und führen Sie den folgenden Befehl aus:

```bash
cd ~/lab/rockydocs/env/
```

```bash
source ./bin/activate
```

Der Befehl *activate* wurde ohne Suffix ausgegeben, da er sich auf die *bash*-Shell bezieht, die Standard-Shell von Rocky Linux. An dieser Stelle sollte die *Shell-Eingabeaufforderung* wie folgt lauten:

```bash
(env) [rocky_user@rl9 env]$
```

Wie Sie sehen können, zeigt der erste Teil *(env)* an, dass Sie sich jetzt in der virtuellen Umgebung befinden. Das erste, was Sie an dieser Stelle tun müssen, ist die Aktualisierung von **pip**, dem Python-Modulmanager, der zur Installation von MkDocs verwendet wird. Benutzen Sie dazu folgenden Befehl:

```bash
python -m pip install --upgrade pip
```

Nachfolgend ein Beispiel, wie dies in Ihrer Shell aussehen könnte.

```bash
Requirement already satisfied: pip in ./lib/python3.9/site-packages (21.2.3)
Collecting pip
  Downloading pip-23.1-py3-none-any.whl (2.1 MB)
......
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.3
    Uninstalling pip-21.2.3:
      Successfully uninstalled pip-21.2.3
Successfully installed pip-23.1
```

#### Deaktivierung der Umgebung

Um die virtuelle Umgebung zu verlassen, verwenden Sie den Befehl *deactivate*:

```bash
deactivate
```

Nachfolgend ein Beispiel, wie dies in Ihrer Shell aussehen könnte.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

Wie Sie sehen können, ist die Terminal-Eingabeaufforderung nach der Deaktivierung wieder auf die Systemeingabeaufforderung zurückgesetzt worden. Sie sollten die Eingabeaufforderung immer sorgfältig prüfen, bevor Sie die *MkDocs*-Installation und nachfolgende Befehle ausführen. Durch diese Überprüfung werden unnötige und unerwünschte globale Anwendungsinstallationen sowie verpasste Ausführungen von `mkdocs serve` verhindert.

### Herunterladen der Repositorys

Nachdem Sie nun gesehen haben, wie Sie Ihre virtuelle Umgebung erstellen und verwalten, können Sie mit der Vorbereitung aller notwendigen Dinge beginnen.

Für die Implementierung einer lokalen Version der Rocky Linux-Dokumentation werden zwei Repositories benötigt: das Dokumentations-Repository [documentation](https://github.com/rocky-linux/documentation) und das Site-Structure-Repository [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org). Diese werden vom Rocky Linux GitHub heruntergeladen.

Beginnen Sie mit dem Site-Struktur-Repository, das Sie in den Ordner **rockydocs** klonen:

```bash
cd ~/lab/rockydocs/
```

```bash
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

In diesem Ordner befinden sich zwei Dateien, die Sie zum Erstellen der lokalen Dokumentation verwenden werden. Es handelt sich um **mkdocs.yml**, die Konfigurationsdatei, die zur Initialisierung von MkDocs verwendet wird, und **requirement.txt**, die alle für die Installation von *mkdocs* benötigten Python-Pakete enthält.

Nach Abschluss der Arbeiten müssen Sie auch das Dokumentations-Repository herunterladen:

```bash
git clone https://github.com/rocky-linux/documentation.git
```

An diesem Punkt sollte die Ordnerstruktur **rockydocs** wie folgt aussehen:

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

Schematisch lässt sich sagen, dass der **env**-Ordner Ihre *MkDocs*-Engine ist, die **docs.rockylinux.org** als Container verwendet, um die in **documentation** enthaltenen Daten anzuzeigen.

### Installation von MkDocs

Wie bereits erwähnt, stellen die Entwickler von Rocky Linux die Datei `requirement.txt` zur Verfügung, die die Liste der Module enthält, die für den ordnungsgemäßen Betrieb einer benutzerdefinierten Instanz von MkDocs erforderlich sind. Sie verwenden die Datei, um alles Notwendige in einem einzigen Arbeitsgang zu installieren.

Zuerst wechseln Sie in Ihre virtuelle Python-Umgebung:

```bash
cd ~/lab/rockydocs/env/
```

```bash
source ./bin/activate
```

Installieren Sie anschließend MkDocs und alle zugehörigen Komponenten mit folgendem Befehl:

```bash
python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

Um zu überprüfen, ob alles geklappt hat, können Sie die MkDocs-Hilfe aufrufen, in der auch die verfügbaren Befehle vorgestellt werden:

```bash
mkdocs -h
```

An dieser Stelle sollte die *Shell-Eingabeaufforderung* wie folgt lauten:

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

Options:
  -V, --version  Show the version and exit.
  -q, --quiet    Silence warnings
  -v, --verbose  Enable verbose output
  -h, --help     Show this message and exit.

Commands:
  build      Build the MkDocs documentation
  gh-deploy  Deploy your documentation to GitHub Pages
  new        Create a new MkDocs project
  serve      Run the builtin development server
```

Wenn alles wie geplant funktioniert hat, können Sie die virtuelle Umgebung verlassen und mit der Vorbereitung der notwendigen Verbindungen beginnen.

```bash
deactivate
```

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Verknüpfung der Dokumentation

Nachdem nun alles verfügbar ist, müssen Sie das Dokumentations-Repository innerhalb der *docs.rockylinux.org* Container-Site verlinken. Gemäß der in *mkdocs.yml* definierten Konfiguration:

```yaml
docs_dir: 'docs/docs'
```

Sie müssen zunächst einen Ordner namens **docs** im Verzeichnis **docs.rockylinux.org** erstellen und anschließend von dort aus Ihren **docs**-Ordner aus dem **documentation-**-Repository verknüpfen.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org/configs
```

```bash
mkdir docs
```

```bash
cd docs
```

```bash
ln -s ~/lab/rockydocs/documentation/docs/ docs
```

## Lokale Dokumentation starten

Sie können nun die lokale Kopie der Rocky Linux-Dokumentation starten. Zuerst müssen Sie die virtuelle Python-Umgebung starten und anschließend Ihre MkDocs-Instanz mit den in **docs.rockylinux.org/mkdocs.yml** definierten Einstellungen initialisieren.

Diese Datei enthält alle Einstellungen für Lokalisierung, Funktionen und Themenverwaltung.

Die Entwickler der Benutzeroberfläche der Website wählten das [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)-Theme, das gegenüber dem Standard-MkDocs-Theme viele zusätzliche Funktionen und Anpassungsmöglichkeiten bietet.

Führen Sie die folgenden Befehle aus:

```bash
cd ~/lab/rockydocs/env/
```

```bash
source .bin/activate
```

```bash
mkdocs serve -f ../docs.rockylinux.org/configs/mkdocs.yml --theme material
```

Sie sollten in Ihrem Terminal den Beginn der Baustellenerstellung sehen. Das Display zeigt alle von MkDocs gefundenen Fehler an, wie z. B. fehlende Verknüpfungen oder Ähnliches:

```text
INFO     -  Building documentation...
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
...
...
INFO     -  Documentation built in 102.59 seconds
INFO     -  [11:46:50] Watching paths for changes:
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/docs/docs',
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'
INFO     -  [11:46:50] Serving on http://127.0.0.1:8000/
```

Sie können Ihre Kopie der Dokumentationsseite aufrufen, indem Sie Ihren Browser unter der angegebenen Adresse öffnen: [http://127.0.0.1:8000](http://127.0.0.1:8000). Der Text spiegelt die Funktionalität und Struktur der Online-Seite perfekt wider, sodass Sie das Erscheinungsbild und die Wirkung Ihrer Seite auf der Website beurteilen können.

MkDocs beinhaltet einen Mechanismus, der Änderungen an den Dateien im durch den Pfad `docs_dir` angegebenen Ordner überprüft. Das Einfügen einer neuen Seite oder das Ändern einer bestehenden Seite in `documentation/docs` wird automatisch erkannt und führt zu einem neuen Build der statischen Website.

Da die Erstellung der statischen Website mit MkDocs mehrere Minuten dauern kann, empfiehlt es sich, die Seite, die Sie gerade schreiben, vor dem Speichern oder Einfügen sorgfältig zu überprüfen. Dadurch entfällt das Warten auf den Website-Aufbau, nur weil man beispielsweise die Zeichensetzung vergessen hat.

### Beenden Sie die Entwicklungsumgebung

Sobald Sie mit der Darstellung Ihrer neuen Seite zufrieden sind, können Sie Ihre Entwicklungsumgebung verlassen. Dies beinhaltet zuerst das Beenden von *MkDocs* und anschließend das Deaktivieren der virtuellen Python-Umgebung. Um *MkDocs* zu beenden, müssen Sie die Tastenkombination ++ctrl++ + ++"C"++ verwenden, und wie Sie oben gesehen haben, müssen Sie zum Verlassen der virtuellen Umgebung den Befehl `deactivate` aufrufen.

```bash
deactivate
```

Nachfolgend ein Beispiel, wie dies in Ihrer Shell aussehen könnte.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Erstellen Sie einen Alias ​​für die venv-Methode

Sie können einen Bash-Alias ​​erstellen, um den Prozess der Bereitstellung von mkdocs mit der venv-Methode zu beschleunigen.

Führen Sie den folgenden Befehl aus, um den Alias ​​`venv` zu Ihrer `.bash_profile` hinzuzufügen:

```bash
printf "# mkdocs alias\nalias venv='source $HOME/lab/rockydocs/env/bin/activate && mkdocs serve -f $HOME/lab/rockydocs/docs.rockylinux.org/configs/mkdocs.yml --theme material'" >> ~/.bash_profile
```

Aktualisieren Sie die Shell-Umgebung mit Ihrem neu erstellten Alias:

```bash
source ~/.bash_profile
```

Jetzt können Sie `venv` ausführen, um mit mkdocs und der venv-Methode eine lokale Entwicklungsumgebung zu erstellen:

```bash
venv
```

Sie müssen weiterhin `deactivate` ausführen, um die virtuelle Umgebung zu verlassen:

```bash
deactivate
```

## Zusammenfassung

Durch die Überprüfung Ihrer neuen Seiten auf einer lokalen Entwicklungsseite stellen wir sicher, dass Ihre Arbeit stets der Online-Dokumentationsseite entspricht, sodass wir optimal dazu beitragen können.

Die Einhaltung der Dokumentationsvorgaben ist auch eine große Hilfe für die Kuratoren der Dokumentationsseite, die sich dann nur noch um die Korrektheit der Inhalte kümmern müssen.

Zusammenfassend lässt sich sagen, dass diese Methode es ermöglicht, die Anforderungen für eine „saubere“ Installation von MkDocs zu erfüllen, ohne auf Containerisierung zurückgreifen zu müssen.
