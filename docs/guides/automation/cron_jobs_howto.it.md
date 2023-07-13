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

* Un computer con Rocky Linux in esecuzione
* Una certa dimestichezza nel modificare i file di configurazione dalla riga di comando utilizzando il proprio editor preferito (utilizzando `vi` qui)

## <a name="assumptions"></a> Presupposto

* Conoscenza di base di bash, python o altri strumenti di scripting o programmazione, e si desidera che uno script venga eseguito automaticamente
* Che si stia eseguendo come utente root o che si sia passati a root con `sudo -s`  
  **(È possibile eseguire alcuni script nelle proprie directory come utente personale. In questo caso, il passaggio a root non è necessario)**

## Introduzione

Linux fornisce il sistema _cron_, un job scheduler basato sul tempo, per automatizzare i processi. È semplicistico e tuttavia molto potente. Vuoi uno script o un programma da eseguire ogni giorno alle 5 del pomeriggio? Qui è dove lo imposti.

La _crontab_ è essenzialmente un elenco in cui gli utenti aggiungono le proprie attività e i propri lavori automatizzati, con molte opzioni che possono semplificare ulteriormente le cose. Questo documento ne esplorerà alcuni. È un buon ripasso per chi ha un po' di esperienza e i nuovi utenti possono aggiungere il sistema `cron` alla loro dotazione di strumenti.

`anacron` è discusso brevemente qui in riferimento alle directory `cron` "dot". `cron` viene eseguito da `anacron` ed è utile per le macchine che non sono sempre attive, come le workstation e i notebook. Il motivo è che mentre `cron` esegue i lavori in base a una pianificazione, se la macchina è spenta quando il lavoro è pianificato, il lavoro non viene eseguito. Con `anacron` il lavoro verrà eseguito quando la macchina è di nuovo accesa, anche se l'esecuzione programmata è avvenuta in passato. `anacron`, tuttavia, utilizza un approccio più randomizzato per eseguire compiti in cui la tempistica non è esatta. Questo ha senso per le workstation e i notebook, ma non per i server. Questo può essere un problema per cose come i backup dei server, ad esempio, che richiedono l'esecuzione di un lavoro a un'ora specifica. È qui che `cron` fornisce la soluzione migliore per gli amministratori di server. Tuttavia, gli amministratori di server e gli utenti di workstation o notebook possono trarre vantaggio da entrambi gli approcci. È possibile combinarli in base alle proprie esigenze. Per ulteriori informazioni su `anacron`, vedere [anacron - Automazione dei comandi](anacron.md).

### <a name="starting-easy"></a>Iniziare in modo semplice: le directory dot di `cron`

Incorporate in ogni sistema Linux da molte versioni, le directory `cron` "dot" aiutano ad automatizzare i processi rapidamente. Queste appaiono come directory che il sistema `cron` chiama in base alle loro convenzioni di denominazione. Tuttavia, vengono eseguiti in modo diverso, a seconda del processo assegnato per chiamarli, `anacron` o `cron`. Il comportamento predefinito prevede l'uso di `anacron`, ma può essere modificato dall'amministratore del server, della workstation o del notebook.

#### <a name="for_servers"></a>Per i Server

Come detto nell'introduzione, `cron` normalmente esegue `anacron` attualmente per eseguire gli script in queste directory "dot". È *possibile* che si vogliano usare queste directory "dot" anche sui server e, in tal caso, è necessario eseguire due passaggi per verificare che queste directory "dot" vengano eseguite secondo un sistema di pianificazione rigoroso. Per farlo, è necessario installare un pacchetto e rimuoverne un altro:

`dnf install cronie-noanacron`

e

`dnf remove cronie-anacron`

Come ci si potrebbe aspettare, questo rimuove `anacron` dal server e torna ad eseguire i compiti all'interno delle directory "dot" con una pianificazione rigorosa. `/etc/cron.d/dailyjobs` è il file che controlla la pianificazione, con i seguenti contenuti:

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

#### <a name="for_workstations"></a>Per le workstations

Se si desidera eseguire gli script su una workstation o un notebook nelle directory `cron` "dot", non è necessario nulla di particolare. È sufficiente copiare il file di script nella directory in questione e assicurarsi che sia eseguibile. Ecco le directory:

* `/etc/cron.hourly` - Gli script inseriti qui verranno eseguiti un minuto dopo l'ora ogni ora (questo viene eseguito da `cron`, indipendentemente dal fatto che `anacron` sia installato o meno)
* `/etc/cron.daily` - Gli script messi qui saranno eseguiti ogni giorno. `anacron` regola la tempistica di queste operazioni (vedere il suggerimento)
* `/etc/cron.weekly` - Gli script inseriti qui verranno eseguiti ogni 7 giorni, in base al giorno del calendario dell'ultima esecuzione (vedi suggerimento)
* `/etc/cron.monthly` - Gli script inseriti qui verranno eseguiti mensilmente in base al giorno di calendario dell'ultima esecuzione (vedi suggerimento)

!!! tip "Suggerimento"

    È probabile che questi vengano eseguiti ad orari simili (ma non esattamente gli stessi) ogni giorno, settimana e mese. Per tempi di esecuzione più precisi, vedi le @opzioni qui sotto.

Se si è in grado di lasciare che il sistema esegua automaticamente gli script e che questi vengano eseguiti in un momento specifico, questo semplifica l'automazione delle attività.

!!! note "Nota"

    Non c'è nessuna regola che dice che un amministratore del server non può usare i tempi di esecuzione randomizzati che `anacron` usa per eseguire gli script nelle directory "dot". Il caso d'uso per questo sarebbe per uno script che non è sensibile al tempo.

### Creare il proprio `cron`

Se gli orari automatici e randomizzati non funzionano bene in [Per le postazioni di lavoro sopra](#for-workstations) e gli orari programmati in [Per i server sopra](#for-servers), è possibile crearne di propri. In questo esempio, si presume che l'operazione venga eseguita come utente root. [vedere Ipotesi](#assumptions) Per fare questo, digitate quanto segue:

`crontab -e`

Questo tirerà fuori il `crontab` dell'utente root così come esiste in questo momento nell'editor scelto, e potrebbe essere qualcosa di simile a questo. Leggete questa versione commentata, poiché contiene le descrizioni di ogni campo che utilizzerete successivamente:

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

Notate che questo particolare file `crontab` ha un po' della sua documentazione incorporata. Non è sempre così. Quando si modifica un `crontab` su un container o su un sistema operativo minimalista, il `crontab` sarà un file vuoto a meno che non ci sia una voce al suo interno.

Si supponga di avere uno script di backup da eseguire alle 22: 00 di sera. Il `crontab` utilizza un orologio di 24 ore, quindi le 22:00. Si supponga che lo script di backup sia "backup" e che si trovi attualmente nella directory _/usr/local/sbin_.

!!! note "Nota"

    Ricorda che anche questo script deve essere eseguibile (`chmod +x`) affinché il `cron` lo esegua.

Per aggiungere il lavoro, è necessario:

`crontab -e`

`crontab` sta per "cron table" e il formato del file è, in effetti, un layout di tabella libera. Ora che siete nella `crontab`, andate in fondo al file e aggiungete la vostra nuova voce. Se si utilizza `vi` come editor di sistema predefinito, ciò viene fatto con i seguenti tasti:

`Shift : $`

Ora che siete in fondo al file, inserite una riga e un breve commento per descrivere la vostra voce. A questo scopo si aggiunge un "#" all'inizio della riga:

`# Backing up the system every night at 10PM`

Premete invio. Dovresti essere ancora nella modalità di inserimento, quindi il prossimo passo è quello di aggiungere la tua voce. Come mostrato nel nostro `crontab` vuoto commentato (sopra) questo è **m** per minuti, **h** per ore, **dom** per giorno del mese, **mon** per mese, e **dow** per giorno della settimana.

Per eseguire il nostro script di backup ogni giorno alle 10:00, la voce sarebbe come questa:

`00  22  *  *  *   /usr/local/sbin/backup`

Questo dice di eseguire lo script alle 10 PM, ogni giorno del mese, ogni mese e ogni giorno della settimana. Questo è un esempio semplicistico e le cose possono complicarsi quando si ha bisogno di informazioni specifiche.

### Le @options per `crontab`

Un altro modo per eseguire i lavori a un orario strettamente programmato (ad esempio, giorno, settimana, mese, anno e così via) è quello di utilizzare le @options, che offrono la possibilità di utilizzare una tempistica più naturale. Le @options consistono in:

* `@hourly` esegue lo script ogni ora di ogni giorno a 0 minuti dopo l'ora (questo è esattamente il risultato del posizionamento dello script in `/etc/cron.hourly`).
* `@daily` esegue lo script ogni giorno a mezzanotte.
* `@weekly` esegue lo script ogni settimana a mezzanotte di domenica.
* `@monthly` esegue lo script ogni mese a mezzanotte del primo giorno del mese.
* `@yearly` esegue lo script ogni anno alla mezzanotte del primo giorno di gennaio.
* `@reboot` esegue lo script solo all'avvio del sistema.

!!! note "Nota"

    L'uso di queste voci di `crontab` bypassa il sistema `anacron` e ritorna al `crond.service` sia che `anacron` sia installato o meno.

Per il nostro esempio di script di backup, se si usa l'opzione @daily per eseguire lo script di backup a mezzanotte, la voce avrà il seguente aspetto:

`@daily  /usr/local/sbin/backup`

### Opzioni più complesse

Finora le soluzioni utilizzate sono state piuttosto semplicistiche, ma che dire di tempistiche più complesse? Supponiamo di voler eseguire lo script di backup ogni 10 minuti durante il giorno (probabilmente non è una cosa pratica da fare, ma è un esempio!). Per fare questo, il crontab dovrebbe essere :

`*/10  *   *   *   *   /usr/local/sbin/backup`

E se si volesse eseguire il backup ogni 10 minuti, ma solo il lunedì, il mercoledì e il venerdì?

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

Che ne dite di ogni 10 minuti tutti i giorni tranne il sabato e la domenica?

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

Nella tabella, le virgole consentono di specificare singole voci all'interno di un campo, mentre il trattino consente di specificare un intervallo di valori all'interno di un campo. Questo può accadere in qualsiasi campo e su più campi contemporaneamente. Come potete vedere, le cose possono diventare piuttosto complicate.

Quando si determina quando eseguire uno script, è necessario prendere tempo e pianificarlo, soprattutto se i criteri sono complessi.

## Conclusioni

Il sistema _cron/crontab_ è un potente strumento per l'amministratore di sistemi Rocky Linux o per l'utente desktop. Permette di automatizzare le attività e gli script in modo da non dover ricordare di eseguirli manualmente. Esempi più complessi si trovano qui:

* Per le macchine che **non** sono attive 24 ore al giorno, esplorate [anacron - Automazione dei comandi](anacron.md).
* Per una descrizione concisa dei processi `cron`, controlla [cronie - Attività a tempo](cronie.md)

Sebbene le basi siano piuttosto semplici, le cose possono essere più complesse. Per maggiori informazioni su `crontab` vai alla [pagina del manuale di crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). Sulla maggior parte dei sistemi, puoi anche inserire `man crontab` per ulteriori dettagli sul comando. Potete anche fare una ricerca sul web per "crontab", che vi darà una grande quantità di risultati per aiutarvi a perfezionare le vostre capacità con `crontab`.
