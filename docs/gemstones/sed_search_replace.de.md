---
title: sed - Suchen und Ersetzen
author: Steven Spencer
---

# `sed` - Suchen und Ersetzen

`sed` ist ein Befehl, der für "stream-editor" steht.

## Konventionen

* `path`: Der aktuelle Pfad. Beispiel: `/var/www/html/`
* `Dateiname`: Der aktuelle Dateiname. Beispiel: `index.php`

## `sed` - Verwendung

Die Verwendung von `sed` zum Suchen und Ersetzen ist die persönliche Präferenz des Autors, da Sie ein Trennzeichen Ihrer Wahl verwenden können, was das Ersetzen von Dingen wie Weblinks durch „/“ sehr praktisch macht. Die Standardbeispiele für die `in place`-Bearbeitung mit `sed` schlagen solche Dinge vor:

`sed -i 's/search_for/replace_with/g' /path/filename`

Was aber, wenn Sie nach Zeichenfolgen suchen, die `/` enthalten? Wenn der Schrägstrich die einzige als Trennzeichen verfügbare Option wäre? Sie müssten jeden Schrägstrich maskieren, bevor Sie ihn in der Suche verwenden könnten. In diesem Punkt ist `sed` anderen Tools überlegen, da das Trennzeichen im laufenden Betrieb geändert werden kann (Sie müssen nicht angeben, dass Sie es irgendwo ändern). Wenn Sie wie gesagt nach Dingen suchen, die „/“ enthalten, können Sie das tun, indem Sie das Trennzeichen in „|“ ändern. Hier ist ein Beispiel für die Suche nach einem Link mit dieser Methode:

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

Sie können jedes einzelne Byte-Zeichen als Trennzeichen verwenden, mit Ausnahme von Backslash, Newline und "s". Zum Beispiel funktioniert das auch:

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` where "a" is the delimiter, and the search and replace still works. Aus Sicherheitsgründen können Sie beim Suchen und Ersetzen ein Backup angeben. Dies ist nützlich, um sicherzustellen, dass die Änderungen, die Sie mit `SED` vornehmen, die sind, die Sie _wirklich</ em> beabsichtigen. Dies gibt Ihnen eine Wiederherstellungsoption aus der Sicherungsdatei:</p>

`sed -i.bak s|search_for|replacea_with|g /path/filename`

Das erzeugt eine unbearbeitete Version von `Dateiname` namens `Dateiname.bak`

Sie können auch vollständige Anführungszeichen anstelle von einfachen Anführungszeichen verwenden:

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## Optionen erklärt

| Option | Erläuterung                                                     |
| ------ | --------------------------------------------------------------- |
| i      | Datei an Ort bearbeiten                                         |
| i.ext  | erstellt ein Backup, passend zur Erweiterung (ext hier)         |
| s      | spezifiziert die Suche                                          |
| g      | Gibt an, dass global oder alle Vorkommen ersetzt werden sollen. |

## Mehrere Dateien

Leider hat `sed` keine Inline-Looping-Option wie `perl`. Um mehrere Dateien zu durchlaufen, müssen Sie Ihren `sed`-Befehl in einem Skript kombinieren. Hier ist ein Beispiel dafür.

Erstellen Sie zunächst eine Liste der Dateien, die das Skript verwenden soll. Tun Sie dies von der Befehlszeile aus mit Folgendem:

`find /var/www/html  -name "*.php" > phpfiles.txt`

Als Nächstes erstellen Sie ein Skript um die Datei `phpfiles.txt` zu bearbeiten:

```bash
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```

Das Skript durchläuft alle in `phpfiles.txt` erstellten Dateien, erstellt eine Sicherungskopie jeder Datei und führt die Such- und Ersetzungszeichenfolge global aus. Wenn Sie überprüft haben, dass die Änderungen Ihren Wünschen entsprechen, können Sie alle Sicherungsdateien löschen.

## Weitere Lektüre und Beispiele

* `sed` [manual page](https://linux.die.net/man/1/sed)
* `sed` [additional examples](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [O'Reilly Book](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Zusammenfassung

`sed` ist ein leistungsfähiges Werkzeug und funktioniert sehr gut für Such- und Ersetzungs-Funktionen, insbesondere dort, wo der Trenner flexibel sein muss.
