---
title: Testen Sie Ihr Wissen
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - Bildung
  - bash scripting
  - bash
---

# Bash - Testen Sie Ihr Wissen

:heavy_check_mark: Jede Befehl muss einen Rückgabewert am Ende seiner Ausführung zurückgeben:

- [ ] wahr
- [ ] falsch

:heavy_check_mark: Ein Rückgabewert von 0 gibt einen Ausführungsfehler an:

- [ ] wahr
- [ ] falsch

:heavy_check_mark: Der Rückgabewert wird in der Variable `$@` gespeichert:

- [ ] wahr
- [ ] falsch

:heavy_check_mark: Der Testbefehl ermöglicht Folgendes:

- [ ] Teste den Typ einer Datei
- [ ] Testet eine Variable
- [ ] Zahlen vergleichen
- [ ] Vergleicht den Inhalt von 2 Dateien

:heavy_check_mark: Der Befehl `expr`:

- [ ] Kombiniert 2 Zeichenketten
- [ ] Führt mathematische Operationen aus
- [ ] Text auf dem Bildschirm anzeigen

:heavy_check_mark: Ist die Syntax der folgenden bedingten Struktur für Sie richtig? Erklären Sie, warum.

```
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] wahr
- [ ] falsch

:heavy_check_mark: Was bedeutet folgende Syntax: `${variable:=value}`

- [ ] Zeigt einen Ersatzwert an, wenn die Variable leer ist
- [ ] Zeigt einen Ersatzwert an, wenn die Variable nicht leer ist
- [ ] Weist der Variable einen neuen Wert zu, wenn sie leer ist

:heavy_check_mark: Ist die Syntax der folgenden bedingten alternativen Struktur für Sie richtig? Erklären Sie warum.

```
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] wahr
- [ ] falsch

:heavy_check_mark: Welche der folgenden ist keine Struktur für Schleifen?

- [ ] while
- [ ] until
- [ ] loop
- [ ] for
