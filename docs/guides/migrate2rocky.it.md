---
title: Migrazione a Rocky Linux
author: Ezequiel Bruni
contributors: Franco Colussi, Steven Spencer
update: 11-30-2021
---

# Come migrare a Rocky Linux da CentOS Stream, CentOS, Alma Linux, RHEL, o Oracle Linux

## Prerequisiti e presupposti

* Un server hardware o VPS in esecuzione, beh... CentOS Stream, CentOS, Alma Linux, RHEL, o Oracle Linux. La versione corrente supportata per ciascuno di questi è la 8.5.
* Una conoscenza operativa della riga di comando.
* Una conoscenza operativa di SSH per macchine remote.
* Un atteggiamento leggermente rischioso.
* Tutti i comandi devono essere eseguiti come root. Accedi come root o preparati a digitare molti "sudo".

## Introduzione

In questa guida, imparerai come convertire tutti i sistemi operativi sopra elencati in installazioni Rocky Linux completamente funzionali. Questo è probabilmente uno dei modi più indiretti per installare Rocky Linux, ma sarà utile per le persone in una varietà di situazioni.

Ad esempio, alcuni provider di server non supporteranno Rocky Linux per impostazione predefinita per un po'. Oppure potresti avere un server di produzione che vuoi convertire in Rocky Linux senza reinstallare tutto.

Bene, abbiamo lo strumento per te: [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

È uno script che, una volta eseguito, cambierà tutti i tuoi repository in quelli di Rocky Linux. I pacchetti verranno installati e aggiornati/declassati secondo necessità e anche tutti i marchi del tuo sistema operativo cambieranno.

Non preoccuparti, se sei nuovo nell'amministrazione dei sistemi, lo terrò il più user-friendly possibile. Bene, facile da usare per quanto consentito dalla riga di comando.

### Precisazione e avvertimenti

1. Dai un'occhiata alla pagina README di migrate2rocky (collegata sopra), perché c'è un conflitto noto tra lo script e i repository di Katello. Col tempo, è probabile che scopriremo (ed eventualmente correggeremo) più conflitti e incompatibilità, quindi ti consigliamo di conoscerli, specialmente per i server di produzione.
2. È molto probabile che questo script funzioni senza incidenti su installazioni completamente nuove. _Se vuoi convertire un server di produzione, per amore di tutto ciò che è santo e buono, **fallo prima in un ambiente di staging.**_

Ok? Siamo pronti? Facciamolo.

## Preparare il server

Dovrai prendere il file di script corrente dal repository. Questo può essere fatto in diversi modi.

### Il modo manuale

Scarica i file compressi da GitHub ed estrai quello che ti serve (sarebbe *migrate2rocky.sh*). Puoi trovare i file zip per qualsiasi repository GitHub sul lato destro della pagina principale del repository:

![The "Download Zip" button](images/migrate2rocky-github-zip.png)

Quindi, carica l'eseguibile sul tuo server con ssh eseguendo questo comando sul tuo computer locale:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

Basta, capisci, regolare tutti i percorsi dei file e i domini o gli indirizzi del server secondo necessità.

### Il modo git

Installa git sul tuo server con:

```
dnf install git
```

Quindi clona il repository rocky-tools con:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

Nota: questo metodo scaricherà tutti gli script e i file nel repository rocky-tools.

### Il modo facile-ma-leggermente-meno-sicuro

Ok, questa non è necessariamente la cosa migliore da fare, dal punto di vista della sicurezza. Ma è il modo più semplice per scaricare lo script.

Esegui questo comando per scaricare lo script in qualsiasi directory tu stia utilizzando:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

Quel comando scaricherà il file direttamente sul tuo server e *solo* il file che desideri. Ma ancora una volta, ci sono problemi di sicurezza che suggeriscono che questa non sia necessariamente la pratica migliore, quindi tienilo a mente.

## Installazione

Ecco che arriva quello che è probabilmente la parte più semplice. Accedere al server e quindi utilizzare il terminale per passare alla cartella contenente il file migrate2rocky.sh.

Quindi, assicurati che il file sia eseguibile:

```
chmod +x migrate2rocky.sh
```

E ora, finalmente, esegui lo script:

```
./migrate2rocky.sh -r
```

L'opzione "-r" dice allo script di andare avanti e installare tutto.

Se hai fatto tutto bene, la finestra del terminale dovrebbe assomigliare un po' a questa:

![a successful script startup](images/migrate2rocky-convert-01.png)

Ora, ci vorrà un po' di tempo per convertire tutto, a seconda della macchina/server e della connessione che ha verso Internet.

Se vedi questo messaggio alla fine, tutto è andato per il verso giusto. Basta riavviare il server per completare il lavoro.

![a successful OS migration message](images/migrate2rocky-convert-02.png)

Dagli un po' di tempo, accedi di nuovo e dovresti avere un nuovo server Rocky Linux con cui giocarci... Voglio dire lavorarci sul serio. Esegui il comando 'hostnamectl' per verificare che il tuo sistema operativo sia stato migrato correttamente e sei a posto.

![The results of the hostnamectl command](images/migrate2rocky-convert-03.png)
