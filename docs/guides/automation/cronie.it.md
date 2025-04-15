---
title: cronie - Attività a tempo
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-10-26
---

## Prerequisiti

* Un computer con Rocky Linux.
* Sapere come utilizzare l'editor preferito per modificare il file di configurazione nell'ambiente della riga di comando (in questo articolo si utilizzerà `vi`).
* Avete compreso le conoscenze di base di bash, python o altri strumenti di scripting o programmazione e vi aspettate di eseguire lo script automaticamente
* Ci si è collegati al computer tramite SSH (può essere l'utente root o un utente normale con UID superiore a 1000).

## Introduzione a `cron`

GNU/Linux fornisce il sistema *cron*, un programma di lavoro `cron` basato sul tempo per processi automatizzati. Non è difficile, ma piuttosto potente. Volete che uno script o un programma venga eseguito ogni giorno alle 17:00? `cron` può farlo. Esistono diversi rami (o varianti) di `cron`, che hanno le stesse funzioni. Questo documento utilizza **cronie**, e la versione è la 1.5.2. Fare clic [qui](https://github.com/cronie-crond/cronie) per trovare la versione più recente e aggiornare il registro.

## descrizione `cronie`

* **cronie** -nome del pacchetto, Rocky Linux include cronie per impostazione predefinita
* **crontab** -comando per mantenere `crontab` (pianificazione delle attività) per ogni utente
* **crond.service** - demone di Cronie, è possibile gestire il demone con `systemctl start | restart | stop | status`
* **/etc/crontab** -Assegnare i cron job a diversi utenti, di solito siamo più abituati a usare `crontab -e`. Per esempio, se siete attualmente registrati come utente root, digitate `crontab -e` e vedrete i specifici cron job nel file /var/spool/cron/root dopo il salvataggio.
* **/var/log/cron** \* - il registro di cronie, per impostazione predefinita, effettua la rotazione dei registri e termina con un suffisso di data. In questo caso, si tratta di una wildcard.
* **anacron** - parte di cronie. Per maggiori informazioni su `anacron`, vedi [anacron - automatizzare i comandi](anacron.md).

## Comando `crontab`

`crontab` è un comando ottenuto dopo l'installazione del pacchetto cronie. Rispetto ad `anacron`, è più adatto per i server che lavorano 24 ore su 24, 7 giorni su 7. Le opzioni comuni di `crontab` sono:

```bash
-e # edit crontab scheduled tasks
the -l # View crontab task
-r # delete all the current user's crontab tasks
```

## Uso di `cronie`

La scrittura di comandi o script in questo file consente di eseguirli in momenti diversi. Tuttavia, di solito siamo più abituati a usare `crontab -e`.

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

* `crontab -e` mostrerà le attività temporizzate dell'utente root. Se si utilizza `vi` come editor di sistema predefinito, premere il tasto ++i++ per accedere alla modalità di inserimento.
* "#" significa che si tratta di una riga di commento.

```bash
# Nightly 10:00 backup system
00 22 *  *  * /usr/local/sbin/backup
```

* Dopo aver inserito questa riga (sempre supponendo che `vi` sia l'editor di sistema), premere ++escape++ per uscire dalla modalità di inserimento
* Salvare e uscire dal file con ++shift+colon+"w "+"q "+exclam++ (visualizzato nella parte inferiore dell'editor)

Lo script verrà eseguito ogni sera alle ore 22:00. Questo è un esempio semplicistico. Se avete bisogno di qualcosa di più elaborato, le cose possono diventare più complicate.

!!! tip "Attenzione"

    Lo script deve avere i permessi di esecuzione (`chmod +x`) prima che cronie possa eseguirlo.

### Opzioni Complesse

I contenuti discussi finora sono opzioni semplicistiche, ma che dire di compiti a tempo più complessi?

```bash
# Supponiamo di voler eseguire uno script di backup ogni 10 minuti (potrebbe essere poco pratico, ma è solo un esempio) Per tutto il giorno. A tal fine, verrà scritto quanto segue:
* /10 * * * * /usr/local/sbin/backup
#E se si volesse eseguire un backup solo ogni 10 minuti il lunedì, il mercoledì e il venerdì? :
* /10 * * * 1,3,5 /usr/local/sbin/backup
# Oltre al sabato e alla domenica, una volta ogni 10 minuti, ogni giorno, come si fa il backup?
* /10 * * * 1-5 /usr/local/sbin/backup
```

| Simboli Speciali | Significato                                                                                                                                                                       |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `*`              | rappresenta un momento qualsiasi. Ad esempio, il primo `*` indica un minuto qualsiasi e il secondo `*` indica un'ora qualsiasi                                                    |
| `,`              | sta per tempo discontinuo, come `0 8,12,16 * * *`, che significa che il comando verrà eseguito una volta al giorno alle 8:00, alle 12:00 e alle 16:00                             |
| `-`              | rappresenta un intervallo di tempo continuo, ad esempio `0 5 * * 1-6`, il che significa che un comando verrà eseguito alle cinque del mattino tutti i giorni dal lunedì al sabato |
| `*/n`            | Rappresenta la frequenza di esecuzione dell'intervallo, ad esempio `*/10 * * * *` significa che l'intervallo verrà eseguito ogni 10 minuti                                        |

!!! tip "Attenzione"

    L'unità di tempo più piccola che cronie è in grado di riconoscere è 1 minuto; quando si usa, ad esempio, `30 4 1,15 * 5 command`, il comando verrà eseguito il 1° e il 15 di ogni mese e alle 4:30 del mattino di ogni venerdì; le informazioni di output di alcuni script o comandi impediscono l'esecuzione di attività temporizzate, ed è necessario un reindirizzamento dell'output, come questo- `*/10 * * * * /usr/local/sbin/backup &> /dev/null`

## Domande e risposte

1. /etc/crontab e `crontab -e`, c'è qualche differenza tra i due metodi? `crontab -e` non ha bisogno di specificare un utente (l'utente attualmente registrato è usato di default), mentre /etc/crontab ha bisogno di specificare un utente.
2. Cosa fare se il comando o lo script specificato non viene eseguito correttamente? Controllare il file /var/log/cron*, usare `journalctl -u crond.service` per verificare le informazioni sul processo demone, se lo script ha i permessi x e così via, per la risoluzione dei problemi.
3. Oltre a cronie, quali varianti di cron esistono? [fcron](http://fcron.free.fr/), l'ultima versione è la 3.3.0 (dev, 2016-08-14). [cronsun](https://github.com/shunfei/cronsun), l'ultima versione 0.3.5 (2018-11-20).

## Sommario

Per gli utenti di desktop Rocky Linux o per gli amministratori di sistema, cronie è uno strumento potente. Permette di automatizzare attività e script, in modo da non doversi ricordare di eseguirli manualmente. Sebbene le conoscenze di base non siano difficili, il compito può essere complesso. Per ulteriori informazioni su `crontab`, visitare la [pagina man di crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). È anche possibile cercare "crontab" su Internet, che fornisce molti risultati di ricerca e aiuta a perfezionare l'espressione di `crontab`.
