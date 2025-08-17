---
title: perl – Suchen und Ersetzen
author: Steven Spencer
tags:
  - perl
  - suche
---

# `perl` – Suchen und Ersetzen

Manchmal müssen Sie schnell nach Zeichenketten in einer Datei oder Gruppe von Dateien suchen und ersetzen. Es gibt viele Möglichkeiten, dies zu tun, aber diese Methode verwendet `perl`

Um eine bestimmte Zeichenfolge in mehreren Dateien eines Verzeichnisses zu suchen und zu ersetzen, lautet der Befehl:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' ~/Dir_to_search/*.html
```

Für eine einzelne Datei, die mehrere Instanzen des Strings enthalten könnte, können Sie die Datei angeben:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' /var/www/htdocs/bigfile.html
```

Dieser Befehl verwendet die `vi`-Syntax zum Suchen und Ersetzen, um alle Vorkommen einer Zeichenfolge zu finden und sie in einer oder mehreren Dateien eines bestimmten Typs durch eine andere Zeichenfolge zu ersetzen. Dies ist nützlich zum Ersetzen von html/PHP-Links Änderungen in diesen Dateitypen und vielen anderen Dingen.

## Optionen-Beschreibung

| Option | Erläuterung                                                          |
| ------ | -------------------------------------------------------------------- |
| `-p`   | stellt eine Schleife um ein Skript herum                             |
| `-i`   | die Datei bearbeiten                                                 |
| `-w`   | gibt Warnmeldungen aus, falls etwas schief geht                      |
| `-e`   | ermöglicht die Eingabe einer einzelnen Codezeile in der Befehlszeile |
| `-s`   | spezifiziert die Suche                                               |
| `-g`   | global ersetzen, mit anderen Worten alle Vorkommnisse ändern         |

## Zusammenfassung

Eine einfache Möglichkeit, eine Zeichenkette in einer oder mehreren Dateien mit `perl` zu ersetzen.
