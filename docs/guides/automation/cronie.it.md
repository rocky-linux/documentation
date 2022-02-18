---
title: cronie - Compiti a tempo
author: tianci li
contributors: Steven Spencer, Franco Colussi
update: 2022-02-14
---

# Prerequisiti

* Una macchina con Rocky Linux.
* Sapere come usare il vostro editor preferito per modificare il file di configurazione nell'ambiente della riga di comando (questo articolo userà `vi`).
* Hai capito la conoscenza di base di bash, python o altri strumenti di scripting/programmazione, e ti aspetti di eseguire lo script automaticamente.
* Ti sei collegato alla tua macchina via ssh (può essere l'utente root o un utente normale con UID maggiore di 1000)
* Pensiamo che tu sia una persona molto sveglia.

## introduzione cron

GNU/Linux fornisce il sistema *cron*, che è un programma di lavoro `cron` basato sul tempo per processi automatizzati. È semplice, ma abbastanza potente. Vuoi uno script o un programma da eseguire ogni giorno alle 5 del pomeriggio? `cron` può farlo. Ci sono diversi rami (o varianti) di `cron`, che hanno le stesse funzioni. In questo documento si usa **cronie** e la versione è la 1.5.2. Potete cliccare \[qui\](https://github .com/cronie-crond/cronie) per trovare l'ultima versione e il log di aggiornamento.

## descrizione di cronie

*  **cronie** -nome del pacchetto, Rocky Linux include cronie di default;
*  **crontab** -comando per mantenere `crontab` (pianificazione dei compiti) per ogni utente;
*  **crond.service** -cronie il demone, è possibile gestire il demone da `systemctl start | restart | stop | status`;
*  **/etc/crontab** -Assegnare cron jobs a diversi utenti, di solito siamo più abituati a usare `crontab -e`. Per esempio, se siete attualmente registrati come utente root, digitate `crontab -e` e vedrete i specifici cron job nel file /var/spool/cron/root dopo il salvataggio.
*  **/var/log/cron \* ** -Il log di Cronie, per default, fa la rotazione dei log e finisce con un suffisso di data. \* Qui significa jolly
*  **anacron** - parte di cronie. Per maggiori informazioni su `anacron`, vedi [anacron - automatizzare i comandi](anacron.md).

## comando `crontab`

`crontab` è un comando ottenuto dopo l'installazione del pacchetto cronie. Rispetto ad `anacron`, è più adatto ai server che lavorano 7 giorni su 7* 24 ore al giorno. Le opzioni comuni di `crontab` sono:

```bash
-e # modificare le attività pianificate di crontab
-l # Visualizza il compito crontab
-r # cancella tutti i compiti crontab dell'utente corrente
```

## Uso di cronie

Per permettere a diversi utenti di eseguire diversi comandi (o script) in momenti diversi, essi possono essere scritti in questo file. Tuttavia, di solito siamo più abituati a usare `crontab -e`.

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

| Parametro | Significato              | Gamma di valori                           |
| --------- | ------------------------ | ----------------------------------------- |
| Il 1º\* | Il primo minuto dell'ora | 0-59                                      |
| Il 2º\* | Ora del giorno           | 0-23                                      |
| Il 3º\* | Giorno del mese          | 1-31                                      |
| Il 4º\* | Il mese dell'anno        | 1-12                                      |
| Il 5°\* | Giorno della settimana   | 0-7 (0 e 7 indicano entrambi la domenica) |

In questo esempio, supponendo che tu stia eseguendo questa operazione come utente root, digita quanto segue: `crontab -e` , questo farà apparire le attività a tempo dell'utente root, se usi `vi` come editor di sistema predefinito, premi il tasto <kbd>i</kbd> per entrare la modalità di inserimento, inserisci il seguente contenuto, # significa che questa è una riga di commento. Premere <kbd>Esc</kbd> per uscire dalla modalità di inserimento, inserire: wq (visualizzato in basso) per salvare e uscire da `vi`, il che significa eseguire lo script una volta ogni notte alle 22:00. Ovviamente, questo è un esempio molto semplice, e la situazione può diventare molto complicata quando si deve elaborare.

```bash
# Nightly 10:00 backup system
00 22 *  *  * /usr/local/sbin/backup
```

!!! tip "Attenzione"

    Lo script deve avere il permesso di esecuzione (`chmod +x`) prima che cronie possa eseguirlo.

#### Opzioni complesse

Finora, i contenuti discussi sono opzioni molto semplici, ma come completare compiti a tempo più complessi?

```bash
# Suppose you want to run every 10 minutes backup script (may be impractical, however, it is only an example!) Throughout the day. To this end, the following will be written:
* /10 *  *  *  * /usr/local/sbin/backup
#What if you only want to run a backup every 10 minutes on Monday, Wednesday, and Friday? :
* /10 *  *  * 1,3,5 /usr/local/sbin/backup
# In addition to Saturdays and Sundays, once every 10 minutes, every day, how to back up?
* /10 *  *  * 1-5 /usr/local/sbin/backup
```

| Simboli speciali | Significato                                                                                                                                                           |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *                | rappresenta qualsiasi momento. Per esempio, il primo * significa qualsiasi minuto, e il secondo * significa qualsiasi ora                                           |
| ,                | sta per tempo discontinuo, come "0 8,12,16 * * * ", che significa che il comando sarà eseguito una volta al giorno alle 8:00, 12:00 e 16:00                         |
| -                | rappresenta un intervallo di tempo continuo, come "0 5 * * 1-6 ", che significa che un comando sarà eseguito alle cinque del mattino ogni giorno da lunedì a sabato |
| */n              | Rappresenta quanto spesso l'intervallo viene eseguito, come "*/10 * * * *" significa che viene eseguito ogni 10 minuti                                            |

!!! tip "Suggerimento"

    La più piccola unità di tempo che cronie può riconoscere è 1 minuto; quando si usa, per esempio, `30 4 1,15 * 5 comando`, il comando verrà eseguito il 1° e il 15 di ogni mese e alle 4:30 del mattino di ogni venerdì; le informazioni di output di alcuni script o comandi impediranno l'esecuzione di compiti a tempo, ed è necessaria una redirezione dell'output, come questa- `*/10 * * * * /usr/local/sbin/backup &> /dev/null`

## Q & A

1. /etc/crontab e `crontab -e`, c'è qualche differenza tra i due metodi? `crontab -e` non ha bisogno di specificare un utente (l'utente attualmente registrato è usato di default), mentre /etc/crontab ha bisogno di specificare un utente.
2. Cosa devo fare se il comando o lo script specificato non viene eseguito correttamente? Controllate il file /var/log/cron*, usate `journalctl -u crond.service` per controllare le informazioni sul processo del demone, se lo script ha il permesso x, ecc.
3. Oltre a cronie, quali varianti di cron esistono? [ dcron ](http://www.jimpryor.net/linux/dcron.html), l'ultima versione è la 4.5 (2011-50-01). [ fcron ](http://fcron.free.fr/), l'ultima versione è 3.3.0 (dev, 2016-08-14). [ bcron ](http://untroubled.org/bcron/), l'ultima versione è 0.11 (2015-08-12). [ cronsun ](https://github.com/shunfei/cronsun), l'ultima versione 0.3.5 (2018-11-20).

## Sommario

Per gli utenti del desktop Rocky Linux o gli amministratori di sistema, cronie è uno strumento molto potente. Permette di automatizzare compiti e script in modo da non doversi ricordare di eseguirli manualmente. Anche se la conoscenza di base è semplice, il compito effettivo può essere complesso. Per maggiori informazioni su `crontab`, visitate la [pagina man di crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). Potete anche semplicemente cercare "crontab" su Internet, che vi fornirà un gran numero di risultati di ricerca e vi aiuterà a mettere a punto l'espressione `crontab`.
