---
title: cron - Automatizzare i comandi
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested on: 8.5
tags:
  - automazione del lavoro
  - automazione
  - cron
---

# Automatizzare i Processi con `cron` e `crontab`

## Prerequisiti

* Una macchina con Rocky Linux
* Una certa comodità nel modificare i file di configurazione dalla riga di comando usando il tuo editor preferito (qui è usato `vi` )

## <a name="assumptions"></a> Presupposto

* Conoscenza di base di bash, python, o altri strumenti di scripting/programmazione, e il desiderio di avere uno script eseguito automaticamente
* Che stiate eseguendo come utente root o che siate passati a root con `sudo -s`  
  **(Potete eseguire certi script nelle vostre directory come vostro utente.** In questo caso, non è necessario passare a root)</strong>
* Diamo per scontato che tu sia veramente in gamba.

## Introduzione

Linux fornisce il sistema _cron_, un job scheduler basato sul tempo, per automatizzare i processi. È semplice ma abbastanza potente. Vuoi uno script o un programma da eseguire ogni giorno alle 5 del pomeriggio? Qui è dove lo imposti.

Il _crontab_ è essenzialmente una lista dove gli utenti aggiungono i propri compiti e lavori automatizzati, e ha una serie di opzioni che possono semplificare ulteriormente le cose. Questo documento ne esplorerà alcuni. È un buon aggiornamento per chi ha un po' di esperienza, e i nuovi utenti possono aggiungere il sistema `cron` al loro repertorio.

`anacron` è discusso brevemente qui in riferimento alle directory `cron` "dot". `anacron` è eseguito da `cron`, ed è vantaggioso per le macchine che non sono sempre attive, come le workstation e i portatili. La ragione di questo è che mentre `cron` esegue lavori su una pianificazione, se la macchina è spenta quando il lavoro è programmato, il lavoro non viene eseguito. Con `anacron` il lavoro viene prelevato ed eseguito quando la macchina è di nuovo accesa, anche se l'esecuzione programmata era nel passato. `anacron`, tuttavia, utilizza un approccio più randomizzato per eseguire compiti in cui la tempistica non è esatta. Questo ha senso per le workstation e i portatili, ma non tanto per i server.  Questo può essere un problema per cose come i backup dei server, per esempio, che devono essere eseguiti in un momento specifico. È qui che `cron` continua a fornire la migliore soluzione per gli amministratori di server. Detto questo, gli amministratori di server e gli utenti di workstation o laptop possono guadagnare qualcosa da entrambi gli approcci. Si può facilmente mescolare e abbinare in base alle proprie esigenze.  Per maggiori informazioni su `anacron` vedere [anacron - Automazione dei comandi](anacron.md).

### <a name="starting-easy"></a>Iniziare Comodamente - Le directory di `cron` Dot

Incorporate in ogni sistema Linux da molte versioni, le directory `cron` "dot" aiutano ad automatizzare i processi rapidamente. Queste appaiono come directory che il sistema `cron` chiama in base alle loro convenzioni di denominazione. Sono chiamati in modo diverso, tuttavia, in base a quale processo è assegnato a chiamarli, `anacron` o `cron`. Il comportamento predefinito è di usare `anacron`, ma questo può essere cambiato da un amministratore di server, workstation o laptop.

#### <a name="for_servers"></a>Per i server

Come detto nell'introduzione, `cron` al giorno d'oggi normalmente esegue `anacron` per eseguire gli script in queste directory "dot".  *Potreste*, però, voler usare queste directory "dot" anche sui server, e se questo è il caso, allora ci sono due passi che potete fare per assicurarvi che queste directory "dot" siano eseguite con un programma rigoroso. Per farlo, dobbiamo installare un pacchetto e rimuoverne un altro:

`dnf install cronie-noanacron`

e

`dnf remove cronie-anacron`

Come ci si potrebbe aspettare, questo rimuove `anacron` dal server e torna ad eseguire i compiti all'interno delle directory "dot" con una pianificazione rigorosa. Questo è definito da questo file: `/etc/cron.d/dailyjobs`, che ha il seguente contenuto:

```
# Run the daily, weekly, and monthly jobs if cronie-anacron is not installed
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# run-parts
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

Questo si traduce in quanto segue:

* eseguire gli script in `cron.daily` alle 04:02:00 ogni giorno.
* eseguire gli script in `cron.weekly` alle 04:22:00 di domenica ogni settimana.
* eseguire gli script in `cron.monthly` alle 04:42:00 il primo giorno di ogni mese.

#### <a name="for_workstations"></a>Per le Workstations

Se volete eseguire gli script su una workstation o un portatile nelle directory "dot" di `cron`, allora non c'è niente di speciale da fare. Copiate semplicemente il vostro file di script nella directory in questione, e assicuratevi che sia eseguibile. Ecco le directory:

* `/etc/cron.hourly` - Gli script messi qui saranno eseguiti un minuto dopo l'ora ogni ora. (questo viene eseguito da `cron` indipendentemente dal fatto che `anacron` sia installato o meno)
* `/etc/cron.daily` - Gli script messi qui saranno eseguiti ogni giorno. `anacron` regola i tempi di questi. (vedere il suggerimento)
* `/etc/cron.weekly` - Gli script messi qui verranno eseguiti ogni 7 giorni, in base al giorno di calendario dell'ultima esecuzione. (vedere il suggerimento)
* `/etc/cron.monthly` - Gli script messi qui saranno eseguiti mensilmente in base al giorno di calendario dell'ultima esecuzione. (vedere il suggerimento)

!!! tip "Suggerimento"

    È probabile che questi vengano eseguiti ad orari simili (ma non esattamente gli stessi) ogni giorno, settimana e mese. Per tempi di esecuzione più precisi, vedi le @opzioni qui sotto.

Quindi, se vi va bene lasciare che il sistema esegua automaticamente i vostri script, e permettete loro di essere eseguiti durante il periodo specificato, allora è molto facile automatizzare i compiti.

!!! note "Nota"

    Non c'è nessuna regola che dice che un amministratore del server non può usare i tempi di esecuzione randomizzati che `anacron` usa per eseguire gli script nelle directory "dot". Il caso d'uso per questo sarebbe per uno script che non è sensibile al tempo.

### Crea il Tuo `cron`

Naturalmente, se i tempi automatici e randomizzati non funzionano bene in [Per Workstations sopra](#for-workstations), e i tempi programmati in [Per Servers sopra](#for-servers), allora potete creare i vostri. In questo esempio, assumiamo che lo stiate facendo come root. [vedere Ipotesi](#assumptions) Per fare questo, digitate quanto segue:

`crontab -e`

Questo tirerà fuori il `crontab` dell'utente root così come esiste in questo momento nell'editor scelto, e potrebbe essere qualcosa di simile a questo. Andate avanti e leggete questa versione commentata, poiché contiene le descrizioni di ogni campo che useremo in seguito:

```
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
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

Notate che questo particolare file `crontab` ha un po' della sua documentazione incorporata. Non è sempre così. Quando si modifica un `crontab` su un container o un sistema operativo minimalista, il `crontab` sarà un file vuoto a meno che non vi sia già stata inserita una voce.

Supponiamo di avere uno script di backup che vogliamo eseguire alle 10 di sera. Il `crontab` usa un orologio di 24 ore, quindi questo sarebbe 22:00. Supponiamo che lo script di backup si chiami "backup" e che sia attualmente nella directory _/usr/local/sbin_.

!!! note "Nota"

    Ricorda che anche questo script deve essere eseguibile (`chmod +x`) affinché il `cron` lo esegua.

Per aggiungere il lavoro, dovremmo:

`crontab -e`

`crontab` sta per "cron table" e il formato del file è, in effetti, un layout di tabella libera. Ora che siamo nel `crontab`, vai in fondo al file e aggiungi la tua nuova voce. Se state usando `vi` come editor di sistema predefinito, allora questo viene fatto con i seguenti tasti:

`Shift : $`

Ora che sei in fondo al file, inserisci una riga e scrivi un breve commento per descrivere cosa sta succedendo alla tua voce. Questo viene fatto aggiungendo un "#" all'inizio della linea:

`# Backing up the system every night at 10PM`

Ora premi invio. Dovresti essere ancora nella modalità di inserimento, quindi il prossimo passo è quello di aggiungere la tua voce. Come mostrato nel nostro `crontab` vuoto commentato (sopra) questo è **m** per minuti, **h** per ore, **dom** per giorno del mese, **mon** per mese, e **dow** per giorno della settimana.

Per eseguire il nostro script di backup ogni giorno alle 10:00, la voce sarebbe come questa:

`00  22  *  *  *   /usr/local/sbin/backup`

Questo dice di eseguire lo script alle 10 PM, ogni giorno del mese, ogni mese e ogni giorno della settimana. Ovviamente, questo è un esempio piuttosto semplice e le cose possono diventare piuttosto complicate quando si ha bisogno di specifiche.

### Le @options per `crontab`

Un altro modo per eseguire i lavori a un orario strettamente programmato (cioè, giorno, settimana, mese, anno, ecc.) è quello di usare le @options, che offrono la capacità di usare tempistiche più naturali. Le @options consistono in:

* `@hourly` esegue lo script ogni ora di ogni giorno a 0 minuti dopo l'ora. (questo è esattamente il risultato di mettere il tuo script anche in `/etc/cron.hourly` )
* `@daily` esegue lo script ogni giorno a mezzanotte.
* `@weekly` esegue lo script ogni settimana a mezzanotte di domenica.
* `@monthly` esegue lo script ogni mese a mezzanotte del primo giorno del mese.
* `@yearly` esegue lo script ogni anno alla mezzanotte del primo giorno di gennaio.
* `@reboot` esegue lo script solo all'avvio del sistema.

!!! note "Nota"

    L'uso di queste voci di `crontab` bypassa il sistema `anacron` e ritorna al `crond.service` sia che `anacron` sia installato o meno.

Per il nostro esempio di script di backup, se usassimo l'opzione @daily per eseguire lo script di backup a mezzanotte, la voce sarebbe come questa:

`@daily  /usr/local/sbin/backup`

### Opzioni Più Complesse

Finora, tutto ciò di cui abbiamo parlato ha avuto opzioni abbastanza semplici, ma che dire delle tempistiche di attività più complesse? Diciamo che volete eseguire il vostro script di backup ogni 10 minuti durante il giorno (probabilmente non è una cosa molto pratica da fare, ma ehi, questo è un esempio!) Per fare questo si dovrebbe scrivere:

`*/10  *   *   *   *   /usr/local/sbin/backup`

E se si volesse eseguire il backup ogni 10 minuti, ma solo il lunedì, il mercoledì e il venerdì?

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

Che ne dite di ogni 10 minuti tutti i giorni tranne il sabato e la domenica?

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

Nella tabella, le virgole ti permettono di specificare voci individuali all'interno di un campo, mentre il trattino ti permette di specificare un intervallo di valori all'interno di un campo. Questo può accadere in qualsiasi campo, e su più campi allo stesso tempo. Come potete vedere, le cose possono diventare piuttosto complicate.

Quando si determina quando eseguire uno script, è necessario prendere tempo e pianificarlo, soprattutto se i criteri sono complessi.

## Conclusioni

Il sistema _cron/crontab_ è uno strumento molto potente per l'amministratore di sistemi Linux Rocky o per l'utente desktop. Può permettervi di automatizzare compiti e script in modo da non dovervi ricordare di eseguirli manualmente. Ci sono più esempi qui:

* Per le macchine che **non** sono attive 24 ore al giorno, esplorate [anacron - Automazione dei comandi](anacron.md).
* Per una descrizione concisa dei processi `cron`, controlla [cronie - Attività a tempo](cronie.md)

Mentre le basi sono abbastanza facili, può diventare molto più complesso. Per maggiori informazioni su `crontab` vai alla [pagina del manuale di crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). Sulla maggior parte dei sistemi, puoi anche inserire `man crontab` per ulteriori dettagli sul comando. Potete anche semplicemente fare una ricerca sul web per "crontab" che vi darà un sacco di risultati per aiutarvi a mettere a punto le vostre abilità con `crontab`.
