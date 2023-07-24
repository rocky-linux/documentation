---
title: Sincronizzazione con rsync
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Franco Colussi
tags:
  - synchronization
  - rsync
---

# Usare `rsync` per mantenere sincronizzate due macchine

## Prerequisiti

Ecco tutto ciò di cui avrete bisogno per capire e seguire questa guida:

* Una macchina con Rocky Linux.
* Essere a proprio agio con la modifica dei file di configurazione dalla riga di comando
* Conoscenza dell'uso di un editor a riga di comando (qui si usa _vi_, ma si può usare il proprio editor preferito)
* È necessario avere accesso a root e, idealmente, essere registrati come utente root nel proprio terminale
* Coppia di chiavi SSH Pubbliche e Private.
* In grado di creare uno script bash con `vi` o con il vostro editor preferito e di testarlo.
* In grado di utilizzare _crontab_ per automatizzare l'esecuzione dello script.

## Introduzione

L'uso di `rsync` su SSH non è né potente come [lsyncd](../backup/mirroring_lsyncd.md) (che consente di monitorare una directory o un file per le modifiche e di mantenerlo sincronizzato in tempo reale), né flessibile come [rsnapshot](../backup/rsnapshot_backup.md) (che offre la possibilità di eseguire il backup di più destinazioni da una singola macchina). Tuttavia, offre la possibilità di mantenere aggiornati due computer in base a una pianificazione definita dall'utente.

Se avete bisogno di mantenere aggiornata una serie di directory sul computer di destinazione e non vi interessa la sincronizzazione in tempo reale come caratteristica, allora `rsync` su SSH è probabilmente la soluzione migliore.

Per questa procedura, si opererà come utente root. Effettuate il login come root o utilizzate il comando `sudo -s` per passare all'utente root nel vostro terminale.

### Installazione di `rsync`

Anche se probabilmente `rsync` è già installato, è meglio aggiornare `rsync` alla versione più recente sui computer di origine e di destinazione. Per assicurarsi che `rsync` sia aggiornato, eseguire le seguenti operazioni su entrambi i computer:

`dnf install rsync`

Se il pacchetto non è installato, `dnf` chiederà di confermare l'installazione; se è già installato, `dnf` cercherà un aggiornamento e chiederà di installarlo.

### Preparazione dell'Ambiente

Questo particolare esempio utilizzerà `rsync` sul computer di destinazione per prelevare dall'origine invece di spingere dall'origine alla destinazione. È necessario impostare una [coppia di chiavi SSH](.../security/ssh_public_private_keys.md) per questo scopo. Una volta creata la coppia di chiavi SSH e confermato l'accesso senza password dal computer di destinazione al computer di origine, si può iniziare.

### parametri di `rsync` e impostazione di uno script

Prima di lasciarsi prendere la mano con l'impostazione di uno script, è necessario decidere quali parametri utilizzare con `rsync`. Ci sono molte possibilità, quindi date un'occhiata al [manuale di rsync](https://linux.die.net/man/1/rsync). Il modo più comune di usare `rsync` è quello di usare l'opzione `-a`, perché `-a`, o archivio, combina una serie di opzioni in una sola e queste sono opzioni molto comuni. Che cosa include -a?

* -r, ricorrere le directory
* -l, mantenere i collegamenti simbolici come collegamenti simbolici
* -p, preservare le autorizzazioni
* -t, preservare i tempi di modifica
* -g, preservare il gruppo
* -o, preservare il proprietario
* -D, conservare i file di dispositivo

Le uniche altre opzioni da specificare in questo esempio sono:

* -e, specificare la shell remota da utilizzare
* --delete, che dice che se la directory di destinazione contiene un file che non esiste nella sorgente, bisogna eliminarlo

Successivamente, dobbiamo impostare uno script creando un file per esso (ancora una volta, utilizzate il vostro editor preferito se non avete familiarità con vi). Per creare il file, basta usare questo comando:

`vi /usr/local/sbin/rsync_dirs`

E poi renderlo eseguibile:

`chmod +x /usr/local/sbin/rsync_dirs`

## Impostazioni

Ora, lo scripting lo rende super semplice e sicuro, in modo da poterlo testare senza timore. Si noti che l'URL utilizzato di seguito è "source.domain.com". Sostituirlo con il dominio o l'indirizzo IP del proprio computer di origine, entrambi funzionano. Ricordate inoltre che in questo esempio lo script viene creato sul computer "di destinazione", perché il file viene estratto dal computer di origine:

```
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

!!! warning "Attenzione"

    In questo caso, si presume che la propria home directory non esista sul computer di destinazione. **Se esiste, si consiglia di eseguire un backup prima di eseguire lo script!**

Ora eseguite lo script:

`/usr/local/sbin/rsync_dirs`

Se tutto va bene, si dovrebbe ottenere una copia completamente sincronizzata della propria home directory sul computer di destinazione. Verificate che sia così.

Supponendo che tutto questo abbia funzionato come sperato, procedete a creare un nuovo file sul computer di origine nella vostra home directory:

`touch /home/your_user/testfile.txt`

Eseguire nuovamente lo script:

`/usr/local/sbin/rsync_dirs`

Quindi verificare che il computer di destinazione riceva il nuovo file. In caso affermativo, il passo successivo consiste nel verificare il processo di eliminazione. Cancellare il file appena creato sul computer di origine:

`rm -f /home/your_user/testfile.txt`

Eseguire nuovamente lo script:

`/usr/local/sbin/rsync_dirs`

Verificare che il file non esista più sul computer di destinazione.

Infine, creiamo un file sul computer di destinazione che non esiste sull'origine. Quindi sul target:

`touch /home/your_user/a_different_file.txt`

Eseguire lo script un'ultima volta:

`/usr/local/sbin/rsync_dirs`

Il file appena creato sulla destinazione dovrebbe essere sparito, perché non esiste sulla sorgente.

Supponendo che tutto questo abbia funzionato come previsto, modificate lo script per sincronizzare tutte le directory desiderate.

## Automatizzare il Tutto

Non si vuole eseguire manualmente questo script ogni volta che si vuole sincronizzare, quindi il passo successivo è quello di farlo automaticamente. Supponiamo di voler eseguire questo script alle 23:00 di ogni sera. Per automatizzare questa operazione, utilizzare crontab:

`crontab -e`

In questo modo si ottiene il cron, che può avere un aspetto simile a questo:

```bash
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```
Il cron è impostato su un orologio di 24 ore, quindi la voce da inserire in fondo al file è:

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

Questo comando deve essere eseguito alle 00 minuti, 23 ore, tutti i giorni, tutti i mesi e tutti i giorni della settimana. Salvare la voce di cron con:

`Shift : wq!`

... o con i comandi che il vostro editor preferito utilizza per salvare un file.

## Flags opzionali
```
-n : Esecuzione Dry-Run per vedere quali file verranno trasferiti 
-v : elenca tutti i file che vengono trasferiti 
-vvv : per fornire informazioni di debug durante il trasferimento dei file 
-z : per abilitare la compressione durante il trasferimento 
```


## Conclusioni

Sebbene `rsync` non sia flessibile o potente come altri strumenti, fornisce una semplice sincronizzazione dei file, che è sempre utile.
