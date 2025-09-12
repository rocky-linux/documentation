---
title: bash — Zeichenketten-Farbe
author: tianci li
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - bash
  - Farben
---

# Einleitung

Wenn wir Bash-Skripte herunterladen, die von anderen geschrieben wurden, werden manchmal einige Zeichenketten mit speziellen Farben gekennzeichnet. Wie kann dieser Effekt in einem bash-Skript erreicht werden?

## Schriftfarbe

| **Farbcode** | **Beschreibung** |
|:------------:|:----------------:|
|      30      |     schwarz      |
|      31      |       rot        |
|      32      |       grün       |
|      33      |       gelb       |
|      34      |       blue       |
|              |       lila       |
|      36      |    dunkelgrün    |
|      37      |       weiß       |

## Hintergrundfarbe der Schrift

| **Hintergrundfarbcode** | **Beschreibung** |
|:-----------------------:|:----------------:|
|           40            |     schwarz      |
|           41            |     crimson      |
|           42            |       grün       |
|           43            |       gelb       |
|           44            |       blau       |
|           45            |       lila       |
|           46            |    dunkelgrün    |
|           47            |       weiß       |

## Anzeigemodus

| **Code** |        **Beschreibung**        |
|:--------:|:------------------------------:|
|    0     | Terminal-Standardeinstellungen |
|    1     |          Hervorhebung          |
|    4     |         Unterstrichen          |
|    5     |         Cursor blinkt          |
|    7     |        Anzeige umkehren        |
|    8     |           Ausblenden           |

## Ausführungsmodus

* **\033[1;31;40m** `1` gibt den Anzeigemodus an, der optional ist. „31“ gibt die Schriftfarbe an. `40m` gibt die Hintergrundfarbe der Schrift an

* **\033[0m** Stellt die Standardfarbe des Terminals wieder her, d. h., hebt die Farbeinstellung auf

## Skript-Beispiel

Sie können ein Skript schreiben, um die Farbänderung zu testen, z.B.:

```bash
#!/bin/bash
# Font color cycle
for color1 in {31..37}
    do
        echo -e "\033[0;${color1};40m---hello! Rocky---\033[0m"
    done

echo "-------"

# Background color cycle
for color2 in {40..47}
    do
        echo -e "\033[30;${color2}m---hello! Rocky---\033[0m"
    done

echo "-------"

# Cycle of display mode
for color3 in 0 1 4 5 7 8
    do
        echo -e "\033[${color3};37;40m---hello! Rocky---\033[0m"
    done
```

```bash
Shell > chmod a+x color_set.sh
Shell > ./color_set.sh
```

So sieht das Ergebnis aus:

![Bild1](./images/string_color_image1.png)
