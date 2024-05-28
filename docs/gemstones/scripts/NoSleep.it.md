---
title: NoSleep.sh - Un semplice script di configurazione
author: Andrew Thiesen
tags:
  - configuration
  - server
  - workstation
---

# NoSleep.sh

## Script Bash per modificare `/etc/systemd/logind.conf`

Questo script bash è stato progettato per modificare il file di configurazione `/etc/systemd/logind.conf` su un server o una workstation Rocky Linux. In particolare, modifica l'opzione `HandleLidSwitch` e la imposta su `ignore`. Questa modifica della configurazione viene comunemente utilizzata per evitare che il sistema si sospenda o esegua qualsiasi azione quando il coperchio del portatile è chiuso.

### Utilizzo

Per utilizzare lo script, procedere come segue:

1. Aprite un terminale sul vostro sistema Linux.
2. `cd` alla directory preferita.
3. Scaricare lo script NoSleep.sh tramite `curl`: `curl -O https://github.com/andrewthiesen/NoSleep.sh/blob/main/NoSleep.sh`
4. Rendete lo script NoSleep eseguibile con il comando `chmod +x NoSleep.sh`.
5. Eseguite lo script come root usando il comando `sudo ./NoSleep.sh`.
6. Lo script aggiornerà l'opzione `HandleLidSwitch` nel file `logind.conf` in modo da `ignorarla`.
7. Opzionalmente, verrà richiesto di riavviare il sistema affinché le modifiche abbiano effetto immediato.

### Note importanti

* Questo script **deve** essere eseguito come root o con privilegi di superutente per modificare i file di sistema.
* Presuppone che il file `logind.conf` si trovi in `/etc/systemd/logind.conf`. Se il vostro sistema utilizza una posizione diversa, modificate lo script di conseguenza.
* La modifica dei file di configurazione del sistema può avere conseguenze indesiderate. Rivedete le modifiche apportate dallo script e assicuratevi che siano in linea con i vostri requisiti.
* Si raccomanda di prendere le dovute precauzioni, come il backup del file di configurazione originale, prima di eseguire lo script.
* Il riavvio del sistema è facoltativo, ma può garantire che le modifiche abbiano effetto immediato. Dopo l'esecuzione dello script verrà richiesto il riavvio.

---

Sentitevi liberi di personalizzare e utilizzare lo script secondo le vostre esigenze. Assicuratevi di aver compreso lo script e le sue implicazioni prima di eseguirlo sul vostro sistema.
