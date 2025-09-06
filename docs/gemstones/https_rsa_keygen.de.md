---
title: https — RSA-Schlüssel Generierung
author: Steven Spencer
update: 2022-01-26
---

# https - RSA-Schlüssel Generierung

Dieses Skript wurde mehrfach von uns verwendet. Unabhängig davon, wie oft Sie die OpenSSL-Befehlsstruktur verwenden, müssen Sie manchmal auf das Verfahren zurückgreifen. Dieses Skript hilft Ihnen, die Schlüsselgenerierung für eine Website mithilfe von RSA zu automatisieren. Beachten Sie, dass dieses Skript mit einer Schlüssellänge von 2048 Bits hart-kodiert ist. Wer der Meinung ist, dass die Mindestschlüssellänge 4096 Bit betragen sollte, ändert einfach das entsprechende Teil des Skripts. Denken Sie nur daran, dass Sie den Speicher und die Geschwindigkeit beim Laden einer Website auf einem Gerät gegen die Sicherheit einer längeren Schlüssellänge abwägen müssen.

## Das Skript

Geben Sie diesem Skript einen beliebigen Namen, z.B. `keygen.sh`, machen Sie das Skript ausführbar (`chmod +x scriptname`) und platzieren Sie es in einem Verzeichnis, das sich in Ihrem Pfad befindet, z.B. /usr/local/sbin

```bash
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! note "Anmerkung"

    Sie werden die Passphrase dreimal nacheinander eingeben müssen.

## Kurze Beschreibung

* Dieses Bash-Skript setzt voraus, dass ein Parameter ($1) eingegeben wird, der der Name der Site ohne www, etc. entspricht. Zum Beispiel "mywidget".
* Das Skript erstellt den Standardschlüssel mit einem Passwort und einer Länge von 2048 Bit (die, wie oben angegeben, auf eine Länge von 4096 Bit geändert werden kann)
* Das Passwort wird sofort aus dem Schlüssel entfernt, denn bei einem Neustart des Webservers das Passwort jedes Mal neu eingegeben werden müsste, was in der Praxis problematisch sein kann.
* Anschließend erstellt das Skript den `CSR` (Certificate Signing Request), mit dem dann ein SSL-Zertifikat bei einem Anbieter erworben werden kann.
* Schließlich entfernt der Bereinigungsschritt den zuvor erstellten Schlüssel mit dem angefügten Passwort.
* Die Eingabe des Skriptnamens ohne Parameter erzeugt den Fehler: "requires keyname parameter".
* Hier wird die Positionsparameter-Variable $n verwendet. Während $0 das Kommando selbst enthält, repräsentieren $1 bis $9 die ersten bis neunten Parameter. Wenn die Anzahl Parameter größer als 10 ist, müssen Sie Klammern wie `${10}` verwenden.
