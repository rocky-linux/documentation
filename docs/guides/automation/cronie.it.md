---
title: cronie - Attività a tempo
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-10-26
---

# Prerequisiti

* Un computer con Rocky Linux.
* Sapere come utilizzare l'editor preferito per modificare il file di configurazione nell'ambiente della riga di comando (in questo articolo si utilizzerà `vi`).
* Aver compreso le conoscenze di base di bash, python o altri strumenti di scripting o programmazione e vi aspettate di eseguire lo script automaticamente.
* Ci si è collegati al computer tramite SSH (può essere l'utente root o un utente normale con UID superiore a 1000).

## cron Introduzione

GNU/Linux fornisce il sistema *cron*, che è un programma di lavoro `cron` basato sul tempo per processi automatizzati. Non è difficile, ma piuttosto potente. Volete uno script o un programma da eseguire ogni giorno alle 17:00? `cron` può farlo. Esistono diversi rami (o varianti) di `cron`, che hanno le stesse funzioni. In questo documento si usa **cronie** e la versione è la 1.5.2. Potete fare clic [qui](https://github.com/cronie-crond/cronie) per trovare l'ultima versione e il registro degli aggiornamenti.

## descrizione di Cronie

*  **cronie** -nome del pacchetto, Rocky Linux include cronie per impostazione predefinita;
*  **crontab** -comando per mantenere `crontab` (pianificazione delle attività) per ogni utente;
*  **crond.service** - demone di Cronie, è possibile gestire il demone con `systemctl start | restart | stop | status`;
*  **/etc/crontab** -Assegnare i cron job a diversi utenti, di solito siamo più abituati a usare `crontab -e`. Per esempio, se siete attualmente registrati come utente root, digitate `crontab -e` e vedrete i specifici cron job nel file /var/spool/cron/root dopo il salvataggio.
*  **/var/log/cron \* ** -Il registro di Cronie, per impostazione predefinita, effettua la rotazione dei registri e termina con un suffisso di data. \* Qui significa jolly
*  **anacron** - parte di cronie. Per maggiori informazioni su `anacron`, vedi [anacron - automatizzare i comandi](anacron.md).

## Comando `crontab`

`crontab` è un comando ottenuto dopo l'installazione del pacchetto cronie. Rispetto a `anacron`, è più adatto per i server che lavorano 7 ´* 24 ore al giorno. Le opzioni comuni di `crontab` sono:

```bash
-e # edit crontab scheduled tasks
the -l # View crontab task
-r # delete all the current user's crontab tasks
```

## Uso di cronie

Per consentire a utenti diversi di eseguire comandi (o script) diversi in momenti diversi, è possibile scriverli in questo file. Tuttavia, di solito siamo più abituati a usare `crontab -e`.

```bash
shell > cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# For details see man 4 crontabs
# Example of job definition:
# .---------------- minute (0-59)
# | .------------- hour (0-23)
# | | .---------- day of month (1-31)
# | | | .------- month (1-12) OR jan,feb,mar,apr ...
# | | | | .---- day of week (0-6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# | | | | |
# * * * * * user-name command to be executed
```

| Parametro | Significato              | Intervallo di valori                      |
| --------- | ------------------------ | ----------------------------------------- |
| Il 1º\* | Il primo minuto dell'ora | 0-59                                      |
| Il 2º\* | Ora del giorno           | 0-23                                      |
| Il 3º\* | Giorno del mese          | 1-31                                      |
| Il 4º\* | Il mese dell'anno        | 1-12                                      |
| Il 5°\* | Giorno della settimana   | 0-7 (0 e 7 indicano entrambi la domenica) |

Nell'esempio che segue, supponendo di eseguire questa operazione come utente root, digitate quanto segue:

* `crontab -e`, che visualizzerà le attività temporizzate dell'utente root. Se si utilizza `vi` come editor di sistema predefinito, premere il tasto <kbd>i</kbd> per accedere alla modalità di inserimento.
* "#" significa che si tratta di una riga di commento.

```bash
# Nightly 10:00 backup system
00 22 *  *  * /usr/local/sbin/backup
```

* Una volta inserito quanto sopra (sempre supponendo che `vi` sia l'editor di sistema), premere <kbd>ESC</kbd> per uscire dalla modalità di inserimento.
* Salvare e uscire dal file con <kbd>SHIFT+</kbd><kbd>:</kbd>+wq<kbd>!</kbd> (visualizzato nella parte inferiore dell'editor).

Ora lo script verrà eseguito ogni sera alle 22:00. Questo è un esempio semplicistico. Le cose possono complicarsi se avete bisogno di qualcosa di più elaborato.

!!! tip "Attenzione"

    Lo script deve avere i permessi di esecuzione (`chmod +x`) prima che cronie possa eseguirlo.

#### Opzioni Complesse

I contenuti discussi finora sono opzioni semplicistiche, ma che dire di compiti a tempo più complessi?

```bash
# Supponiamo di voler eseguire uno script di backup ogni 10 minuti (potrebbe essere poco pratico, ma è solo un esempio) Per tutto il giorno. A tal fine, verrà scritto quanto segue:
* /10 * * * * /usr/local/sbin/backup
#E se si volesse eseguire un backup solo ogni 10 minuti il lunedì, il mercoledì e il venerdì? :
* /10 * * * 1,3,5 /usr/local/sbin/backup
# Oltre al sabato e alla domenica, una volta ogni 10 minuti, ogni giorno, come si fa il backup?
* /10 * * * 1-5 /usr/local/sbin/backup
```

| Simboli Speciali | Significato                                                                                                                                                                          |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| *                | rappresenta un momento qualsiasi. Ad esempio, il primo * indica un minuto qualsiasi e il secondo * indica un'ora qualsiasi                                                         |
| ,                | sta per tempo discontinuo, come "0 8,12,16 * * * ", che significa che il comando verrà eseguito una volta al giorno alle 8:00, alle 12:00 e alle 16:00                             |
| -                | rappresenta un intervallo di tempo continuo, ad esempio "0 5 * * 1-6 ", il che significa che il comando verrà eseguito alle cinque del mattino di ogni giorno dal lunedì al sabato |
| */n              | Rappresenta la frequenza di esecuzione dell'intervallo, ad esempio "*/10 * * *" significa che verrà eseguito ogni 10 minuti                                                      |

!!! tip "Attenzione"

    L'unità di tempo più piccola che cronie è in grado di riconoscere è 1 minuto; quando si usa, ad esempio, `30 4 1,15 * 5 command`, il comando verrà eseguito il 1° e il 15 di ogni mese e alle 4:30 del mattino di ogni venerdì; le informazioni di output di alcuni script o comandi impediscono l'esecuzione di attività temporizzate, ed è necessario un reindirizzamento dell'output, come questo- `*/10 * * * * /usr/local/sbin/backup &> /dev/null`

## Domande e risposte

1. /etc/crontab e `crontab -e`, c'è qualche differenza tra i due metodi? `crontab -e` non ha bisogno di specificare un utente (l'utente attualmente registrato è usato di default), mentre /etc/crontab ha bisogno di specificare un utente.
2. Cosa fare se il comando o lo script specificato non viene eseguito correttamente? Controllare il file /var/log/cron*, usare `journalctl -u crond.service` per verificare le informazioni sul processo demone, se lo script ha i permessi x e così via, per la risoluzione dei problemi.
3. Oltre a cronie, quali varianti di cron esistono? [ dcron ](http://www.jimpryor.net/linux/dcron.html), l'ultima versione è la 4.5 (2011-50-01). [ fcron ](http://fcron.free.fr/), l'ultima versione è la 3.3.0 (dev, 2016-08-14). [ bcron ](http://untroubled.org/bcron/), l'ultima versione è la 0.11 (2015-08-12). [ cronsun ](https://github.com/shunfei/cronsun), l'ultima versione 0.3.5 (2018-11-20).

## Sommario

Per gli utenti del desktop Rocky Linux o gli amministratori di sistema, cronie è uno strumento molto potente. Permette di automatizzare le attività e gli script in modo da non doversi ricordare di eseguirli manualmente. Sebbene le conoscenze di base non siano difficili, il compito effettivo può essere complesso. Per ulteriori informazioni su `crontab`, visitare la [pagina man di crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). È anche possibile cercare "crontab" su Internet, che fornisce un gran numero di risultati di ricerca e aiuta a mettere a punto l'espressione `crontab`.
