---
title: Migrazione A Rocky Linux
author: Ezequiel Bruni
contributors: tianci li, Steven Spencer, Ganna Zhyrnova
update: 11-23-2021
---

# Come migrare a Rocky Linux da CentOS Stream, CentOS, Alma Linux, RHEL, o Oracle Linux

## Prerequisiti e presupposti

* CentOS Stream, CentOS, Alma Linux, RHEL, o Oracle Linux che funziona bene su un server hardware o VPS. La versione attualmente supportata per ciascuno di essi è la 8.8 o la 9.2.
* Conoscenza della riga di comando
* Conoscenza operativa di SSH per macchine remote.
* Un atteggiamento di leggera propensione al rischio
* Eseguire i comandi come root. Accedere come root o avere la possibilità di elevare i privilegi con `sudo`.

## Introduzione

In questa guida, imparerete a convertire tutti i sistemi operativi di cui sopra in installazioni Rocky Linux completamente funzionali. Questo è probabilmente uno dei modi più complicati per installare Rocky Linux, ma è utile a chi si dovesse trovare in diverse situazioni.

Ad esempio, alcuni fornitori di server non supporteranno Rocky Linux di default per un po' di tempo. Oppure si può avere un server di produzione che si desidera convertire in Rocky Linux senza reinstallare tutto.

Abbiamo lo strumento che fa al caso vostro: [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

Si tratta di uno script che, una volta eseguito, cambierà tutti i vostri repository con quelli di Rocky Linux. I pacchetti verranno installati e aggiornati o declassati secondo le necessità, e anche il marchio del sistema operativo cambierà.

Non preoccupatevi, se siete alle prime armi con l'amministrazione dei sistemi, vi assicuro che il programma sarà il più semplice possibile per l'utente. Beh, per quanto user friendly possa essere la riga di comando.

### Precisazioni e avvertimenti

1. Si consiglia di controllare la pagina README di migrate2rocky (linkata sopra), perché esistono conflitti noti tra lo script e i repository di Katello. Con il tempo, probabilmente scopriremo (e alla fine applicheremo una patch) altri conflitti e incompatibilità, quindi è bene che ne siate a conoscenza, soprattutto per i server di produzione.
2. Questo script è molto probabile che funzioni senza incidenti su installazioni completamente nuove. _Se volete convertire un server di produzione, **effettuate un backup dei dati e un'istantanea del sistema, oppure fatelo prima in un ambiente di staging.**_

Sei pronto?

## Preparare il tuo server

È necessario prendere il file di script vero e proprio dal repository. È possibile farlo in diversi modi.

### Il modo manuale

Scaricate i file compressi da GitHub ed estraete quello che vi serve (sarà *migrate2rocky.sh*). È possibile trovare i file zip per qualsiasi repository GitHub sul lato destro della pagina principale del repository:

![Il pulsante "Download Zip"](images/migrate2rocky-github-zip.png)

Quindi, caricare l'eseguibile sul server tramite SSH eseguendo questo comando sul computer locale:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

Regolare tutti i percorsi dei file e i domini dei server o gli indirizzi IP secondo le necessità.

### Il modo `git`

Installare `git` sul proprio server con:

```
dnf install git
```

Quindi clona il repository rocky-tools con:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

Nota: questo metodo scaricherà tutti gli script e i file nel repository rocky-tools.

### Il modo più semplice

Questo è probabilmente il modo più semplice per ottenere lo script. È sufficiente che sul server sia installato un client HTTP adeguato (curl, wget, lynx e così via).

Supponendo che abbiate installato l'utilità `curl`, eseguite questo comando per scaricare lo script nella directory che state utilizzando:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

Questo comando scaricherà il file direttamente sul server e *solo* il file che vuoi. Ma anche in questo caso, i problemi di sicurezza suggeriscono che questa non è necessariamente la pratica migliore, quindi tenetene conto.

## Esecuzione dello script e installazione

Usate il comando `cd` per passare alla directory in cui si trova lo script, assicuratevi che il file sia eseguibile e date i permessi x al proprietario del file dello script.

```
chmod u+x migrate2rocky.sh
```

E ora, finalmente, eseguite lo script:

```
./migrate2rocky.sh -r
```

Questa opzione "-r" dice allo script di andare avanti e installare tutto.

Se avete fatto tutto correttamente, la vostra finestra di terminale avrà un aspetto simile a questo:

![avvio dello script riuscito](images/migrate2rocky-convert-01.png)

Ora, lo script impiegherà un po' di tempo per convertire tutto, a seconda della macchina in uso e della connessione a Internet.

Se vedi un messaggio **Complete!** alla fine, allora tutto va bene e puoi riavviare il server.

![messaggio di migrazione OS riuscito](images/migrate2rocky-convert-02.png)

Lasciate passare un po' di tempo, riaccedete e dovreste avere un nuovo server Rocky Linux. Eseguite il comando `hostnamectl` per verificare che il sistema operativo sia stato migrato correttamente e siete a posto.

![Il risultato del comando hostnamectl](images/migrate2rocky-convert-03.png)
