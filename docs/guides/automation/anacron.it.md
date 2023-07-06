---
title: anacron - Automatizzare i comandi
author: tianci li
contributors: Steven Spencer, Franco Colussi
update: 2022-02-13
---

# `anacron` - Eseguire i Comandi con Regolarità

## Prerequisiti

* Un computer con Rocky Linux in esecuzione.
* Sapere come utilizzare l'editor preferito per modificare il file di configurazione (ad esempio *vim*) nell'ambiente da riga di comando.
* Comprendere la gestione di base dei pacchetti RPM.

## Presupposti

* Avete compreso le conoscenze di base di bash, python o altri strumenti di scripting o di programmazione e volete eseguire lo script automaticamente.
* Ci si è collegati come utente root o si è passati a root con `su - root`.

## `anacron` Introduzione

**`anacron` esegue i comandi su base regolare e la frequenza operativa è definita in unità di giorni. È adatto ai computer che non funzionano 24/7, come i computer portatili e i desktop. Supponiamo che abbiate un compito programmato (come uno script di backup) da eseguire la mattina presto di ogni giorno usando crontab. Quando ci si addormenta, il desktop o il notebook sono spenti. Lo script di backup non viene eseguito. Tuttavia, se si utilizza `anacron`, si può essere certi che la prossima volta che si accende il desktop o il notebook, lo script di backup verrà eseguito.**

L'aspetto di `anacron` non è quello di sostituire `crontab`, ma di completare `crontab`. La loro relazione è la seguente:

![ Relazioni ](../images/anacron_01.png)

## `anacron` File di Configurazione

```bash
shell > rpm -ql cronie-anacron
/etc/anacrontab
/etc/cron.hourly/0anacron
/usr/lib/.build-id
/usr/lib/.build-id/0e
/usr/lib/.build-id/0e/6b094fa55505597cb69dc5a6b7f5f30b04d40f
/usr/sbin/anacron
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man8/anacron.8.gz
/var/spool/anacron
/var/spool/anacron/cron.daily
/var/spool/anacron/cron.monthly
/var/spool/anacron/cron.weekly
```

Prima controlla il file di configurazione predefinito:
```bash
shell > cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# Default 45 minutes delay for each specified job anacron random increase 0-45 minutes.
RANDOM_DELAY=45
# Specify the scope of work time, represented here 3:00 ~ 22:00
START_HOURS_RANGE=3-22
# period in days delay in minutes job-identifier command
# Boot every day to check whether the files in the directory /etc/cron.daily be executed in 5 minutes, if not executed today, then to the next
1 5 cron.daily nice run-parts /etc/cron.daily
# Every 7 days within 25 minutes if the file check /etc/cron.weekly directory is executed after boot, if not executed within a week, it will be executed next
7 25 cron.weekly nice run-parts /etc/cron.weekly
# Whether the files in the directory /etc/cron.monthly 45 minutes checking is performed after every start for a month
@monthly 45 cron.monthly nice run-parts /etc/cron.monthly
```

**/etc/cron.hourly/** -Tramite `journalctl -u crond.service`, potete sapere che i file messi dentro sono effettivamente chiamati da crond.server, il che significa che il comando sarà eseguito dopo il primo minuto di ogni ora. Come segue:

```bash
shell > cat /etc/cron.d/0hourly
# Run the hourly jobs
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 *  *  *  * root run-parts /etc/cron.hourly
```
```
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-20 23:32:42 CST. -
October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)

```

Per ulteriori informazioni sul file di configurazione, si prega di [consultare la pagina del manuale](https://man7.org/linux/man-pages/man5/anacrontab.5.html)

## Utilizzo da parte dell'utente

Per fare in modo che alcuni file vengano eseguiti entro questi tempi definiti automaticamente, è sufficiente copiare il file di script nella directory corrispondente e verificare che abbia ** x permessi di esecuzione (chmod +x) ** . Pertanto, è sufficiente lasciare che il sistema esegua automaticamente lo script in uno di questi momenti programmati, semplificando così l'attività di automazione.

Utilizziamo cron.daily per illustrare il processo di esecuzione di /etc/anacrontab:

1. `anacron` legge il file ** /var/spool/anacron/cron.daily ** e il contenuto del file mostra l'ora dell'ultima esecuzione.
2. Rispetto all'ora corrente, se la differenza tra i due orari supera 1 giorno, verrà eseguito il lavoro cron.daily.
3. Questo lavoro può essere eseguito solo dalle 03:00-22:00.
4. Verificare se un file viene eseguito dopo 5 minuti dall'avvio. Quando viene eseguito il primo, l'esecuzione del successivo viene ritardata in modo casuale di 0～45 minuti.
5. Utilizzare il parametro nice per specificare la priorità predefinita e il parametro run-parts per eseguire tutti i file eseguibili nella directory /etc/cron.daily/.

## Comandi Correlati

Uso dell comando `anacron`, le opzioni comunemente usate sono:

| Opzioni | Descrizione                                                         |
| ------- | ------------------------------------------------------------------- |
| -f      | Eseguire tutti i lavori, ignorando i timestamp                      |
| -u      | Aggiorna il timestamp all'ora corrente senza eseguire alcuna azione |
| -T      | Verificare la validità del file di configurazione /etc/anacrontab   |

Per ulteriori informazioni sulla guida, [guardare la pagina del manuale](https://man7.org/linux/man-pages/man8/anacron.8.html)
