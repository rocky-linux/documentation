---
title: Quick Methode
author: Lukas Magauer
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.6, 9.0
tags:
  - Dokumentation
  - lokaler Server
---

# Einleitung

Sie können das Dokumentationssystem auch lokal ohne Docker oder LXD erstellen, wenn Sie möchten. Wenn Sie sich jedoch für dieses Verfahren entscheiden, beachten Sie, dass Sie bei viel Python-Codierung oder lokaler Verwendung von Python am sichersten eine virtuelle Python-Umgebung erstellen, [die hier beschrieben wird](https://docs.python.org/3/library/venv.html). Dadurch bleiben alle Ihre Python-Prozesse voneinander geschützt, was zu empfehlen ist. Wenn Sie sich für diese Vorgehensweise ohne die Python Virtual Environment entscheiden, sollten Sie sich darüber im Klaren sein, dass Sie damit ein gewisses Risiko eingehen.

## Prozedur

- Klonen Sie das Repository docs.rockylinux.org:

    ```bash
    git clone https://github.com/rocky-linux/docs.rockylinux.org.git
    ```

- Nach Abschluss des Vorgangs wechseln Sie in das Verzeichnis docs.rockylinux.org:

    ```bash
    cd docs.rockylinux.org
    ```

- Klonen Sie nun das Dokumentations-Repository mit folgendem Befehl:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git docs
    ```

- Installieren Sie als Nächstes die requirements.txt-Datei für mkdocs:

    ```bash
    python3 -m pip install -r requirements.txt
    ```

- Starten Sie abschließend den mkdocs-Server:

    ```text
    mkdocs serve
    ```

## Zusammenfassung

Dies bietet eine schnelle und einfache Möglichkeit, eine lokale Kopie der Dokumentation ohne Docker oder LXD auszuführen. Wenn Sie sich für diese Methode entscheiden, sollten Sie unbedingt eine virtuelle Python-Umgebung einrichten, um Ihre anderen Python-Prozesse zu schützen.
