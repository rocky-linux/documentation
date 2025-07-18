---
title: Sincronizzazione con rsync
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tags:
  - synchronization
  - rsync
---

## Prerequisiti

Ecco tutto ciò di cui avrete bisogno per capire e seguire questa guida:

- Una macchina con Rocky Linux.
- Essere a proprio agio con la modifica dei file di configurazione dalla riga di comando
- Conoscenza dell'uso di un editor a riga di comando (qui si usa _vi_, ma si può usare il proprio editor preferito)
- È necessario disporre dell'accesso root o dei privilegi `sudo`
- Coppia di chiavi SSH Pubbliche e Private.
- È possibile creare uno script bash con `vi` o con il proprio editor preferito e testarlo.
- In grado di utilizzare `crontab` per automatizzare l'esecuzione dello script

## Introduzione

L'uso di `rsync` su SSH non è potente come [lsyncd](../backup/mirroring_lsyncd.md) (che consente di osservare una directory o un file per le modifiche e di mantenerlo sincronizzato in tempo reale), né flessibile come [rsnapshot](../backup/rsnapshot_backup.md) (che offre la possibilità di eseguire il backup di più obiettivi da un singolo computer). Tuttavia, consente di tenere aggiornati due computer secondo un programma definito dall'utente.

Se avete bisogno di mantenere aggiornata una serie di directory sul computer di destinazione e non vi interessa la sincronizzazione in tempo reale come caratteristica, allora `rsync` su SSH è probabilmente la soluzione migliore.

Per questa procedura, si opererà come utente root. Accedere come root o usare il comando `sudo -s` per passare all'utente root nel terminale.

### Installazione di `rsync`

Anche se probabilmente `rsync` è già installato. Per assicurarsi che `rsync` sia aggiornato, eseguire le seguenti operazioni su entrambi i computer:

```bash
dnf install rsync
```

Se il pacchetto non è installato, `dnf` chiederà di confermare l'installazione. Se è già installato, `dnf` cercherà un aggiornamento e chiederà di installarlo.

### Preparazione dell'Ambiente

Questo esempio utilizzerà `rsync` sul computer di destinazione per prelevare dall'origine invece di spingere dall'origine alla destinazione. A tale scopo è necessario impostare una [coppia di chiavi SSH](../security/ssh_public_private_keys.md). Dopo aver creato la coppia di chiavi SSH, verificare l'accesso senza password dal computer di destinazione al computer di origine.

### parametri di `rsync` e impostazione di uno script

Prima di continuare la configurazione dello script, è necessario decidere quali parametri utilizzare con `rsync`. Esistono molte possibilità. Per un elenco completo, consultare il [manuale di rsync](https://linux.die.net/man/1/rsync). Il modo più comune di usare `rsync` è quello di usare l'opzione `-a` perché `-a`, o “archivio”, combina diverse opzioni comuni. Cosa include `-a`?

- `-r`, ricorre le directory
- `-l`, mantiene i collegamenti simbolici come collegamenti simbolici
- `-p`, preserva i permessi
- `-t`, preserva i tempi di modifica
- `-g`, preserva il gruppo
- `-o`, preserva il proprietario
- `-D`, conserva i file del dispositivo

Le uniche altre opzioni da specificare in questo esempio sono:

- `-e`, specifica la shell remota da utilizzare
- `--delete`, che dice che se la directory di destinazione contiene un file che non esiste nella sorgente, bisogna eliminarlo

Quindi, impostate uno script sul computer di destinazione creando un file apposito (ancora una volta, utilizzate il vostro editor preferito se non avete familiarità con `vi`). Per creare il file, utilizzare questo comando:

```bash
vi /usr/local/sbin/rsync_dirs
```

Aggiungere il contenuto:

```bash
#!/usr/bin/env bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

Sostituire “source.domain.com” con il nome di dominio, il nome host o l'indirizzo IP.

E poi renderlo eseguibile:

```bash
chmod +x /usr/local/sbin/rsync_dirs
```

## Impostazioni

Lo scripting consente di eseguire i test senza preoccupazioni.

!!! warning "Attenzione"

    In questo caso, si presuppone che la propria home directory non esista sul computer di destinazione. **Se esiste, si consiglia di eseguire un backup prima di eseguire lo script!**

Eseguire lo script:

```bash
/usr/local/sbin/rsync_dirs
```

Se tutto va bene, si otterrà una copia sincronizzata della propria home directory sul computer di destinazione. Assicurarsi che sia questo il caso.

Supponendo che i precedenti passaggi abbiano funzionato, si crei un nuovo file sul computer di origine nella home directory:

```bash
touch /home/your_user/testfile.txt
```

Eseguire nuovamente lo script:

```bash
/usr/local/sbin/rsync_dirs
```

Verificare che il computer di destinazione riceva il nuovo file. In caso affermativo, il passo successivo consiste nel verificare il processo di eliminazione. Cancellare il file appena creato sul computer di origine:

```bash
rm -f /home/your_user/testfile.txt
```

Eseguire nuovamente lo script:

```bash
/usr/local/sbin/rsync_dirs
```

Verificare che il file non esista più sul computer di destinazione.

Infine, creare un file sul computer di destinazione che non esiste sull'origine:

```bash
touch /home/your_user/a_different_file.txt
```

Eseguire lo script un'ultima volta:

```bash
/usr/local/sbin/rsync_dirs
```

Il file creato sulla destinazione non dovrebbe più esistere perché non esiste sull'origine.

Supponendo che tutto questo abbia funzionato come previsto, modificate lo script per sincronizzare tutte le directory desiderate.

## Automatizzare il tutto

È possibile che non si voglia eseguire questo script ogni volta che si desidera effettuare una sincronizzazione manuale. Usare una `crontab` per eseguire questa operazione automaticamente secondo un programma. Eseguire questo script alle 23:00 di ogni sera:

```bash
crontab -e
```

L'aspetto sarà simile a questo:

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

!!! info "Informazione"

    L'esempio `crontab` mostra un file vuoto ma commentato. Il commento non appare su tutte le istanze del computer e potrebbe essere un file vuoto. Su un computer attivo, è possibile che vengano visualizzate altre voci.

La `crontab` è su un orologio di 24 ore. La voce deve essere inserita in fondo a questo file:

```crontab
00 23   *  *  *    /usr/local/sbin/rsync_dirs
```

Questo dice di eseguire questo comando alle ore 00 e 23 di ogni giorno, di ogni mese e di ogni giorno della settimana. Salvare la voce `crontab` con:

++shift+colon+"w"+"q"+exclam++

## Flags opzionali

```bash
-n : Esecuzione Dry-Run per vedere quali file verranno trasferiti 
-v : elenca tutti i file che vengono trasferiti 
-vvv : per fornire informazioni di debug durante il trasferimento dei file 
-z : per abilitare la compressione durante il trasferimento
```

## Conclusioni

Sebbene `rsync` non sia flessibile o robusto come altri strumenti, fornisce la sincronizzazione dei file, che è sempre utile.
