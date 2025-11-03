---
title: Hinzufügen eines Remote-Repositorys mithilfe der Git-CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - git remote
  - git fetch
---

## Einleitung

Dieses Gemstone veranschaulicht, wie mithilfe der Git-Befehlszeilenschnittstelle ein bestimmtes Remote-Repository zu einem vorhandenen lokalen Klon eines FOSS-Projekts hinzugefügt wird.
Wir verwenden das Repository des Rocky Linux-Dokumentationsprojekts als Beispiel für unser FOSS-Projekt - <https://github.com/rocky-linux/documentation.git>

## Voraussetzungen

- Ein Github-Konto.
- „git“ ist auf Ihrem System installiert.
- Ein lokaler Klon eines FOSS-Projekt-Repositorys.

## Prozedur

1. Öffnen Sie ein Terminal und ändern Sie Ihr Arbeitsverzeichnis in den Ordner, der Ihren lokalen Klon des Projekts enthält.
   Wenn Sie beispielsweise das GitHub-Repository nach `~/path/to/your/rl-documentation-clone` geklont haben, geben Sie Folgendes ein

   ```bash
   cd ~/path/to/your/rl-documentation-clone
   ```

2. Bevor Sie Änderungen vornehmen, listen Sie die von Ihnen konfigurierten Remotes auf. Geben Sie bitte Folgendes ein:

   ```bash
   git remote -vv
   ```

   Wenn es sich um ein frisch geklontes Repo handelt, sehen Sie in Ihrer Ausgabe wahrscheinlich ein einzelnes Remote mit dem Namen `origin`.

3. Fügen Sie das Rocky Linux Documentation Repository (`https://github.com/rocky-linux/documentation.git`) als neues Remote zu Ihrem lokalen Repository hinzu. Hier weisen wir `upstream` als Namen für dieses bestimmte `Remote` zu. Geben Sie bitte Folgendes ein:

   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

4. To further emphasize that the names assigned to remote repositories are arbitrary, create another remote named rocky-docs that points to the same repo by running:

   ```bash
   git remote add rocky-docs https://github.com/rocky-linux/documentation.git
   ```

5. Bestätigen Sie, dass das neue Remote-Repository erfolgreich hinzugefügt wurde:

   ```bash
   git remote -v
   ```

   Sie sollten `upstream` zusammen mit seiner URL aufgelistet sehen.

6. Optional können Sie Daten aus dem neu hinzugefügten Remote abrufen, bevor Sie mit Änderungen an Ihrem lokalen Repo beginnen.
   Rufen Sie mit `fetch` Zweige und Commits vom neu hinzugefügten Remote ab, indem Sie Folgendes ausführen:

   ```bash
   git fetch upstream
   ```

## Zusätzliche Anmerkungen

- _origin_: Dies ist der Standardname, den Git dem Remote-Repository gibt, von dem Sie geklont haben. Es ist wie ein Spitzname für die Repository-URL. Wenn Sie ein Repository klonen, wird dieses Remote-Repository in Ihrer lokalen Git-Konfiguration automatisch als `origin` festgelegt. Der Name ist beliebig, soll aber gewissen Konventionen befolgen.

- _upstream_: Dies bezieht sich oft auf das ursprüngliche Repository, wenn Sie ein Projekt geforkt haben.
  Wenn Sie in Open-Source-Projekten ein Repository forken, um Änderungen vorzunehmen, ist das geforkte Repository Ihr `origin` und das ursprüngliche Repository wird normalerweise als `upstream` bezeichnet. Der Name ist beliebig, soll aber gewissen Konventionen befolgen.

  Diese subtile Unterscheidung zwischen der Verwendung/Zuweisung von `origin` und `remote` ist entscheidend, um durch Pull Requests zum ursprünglichen Projekt beizutragen.

## Zusammenfassung

Mit dem Dienstprogramm `git CLI` können Sie ganz einfach einen beschreibenden Namen verwenden und einem lokalen Klon eines FOSS-Projekts ein bestimmtes Remote-Repository hinzufügen. Auf diese Weise können Sie effektiv mit verschiedenen Repositorys synchronisieren und zu ihnen beitragen.
