---
title: inotify-tools installazione e uso
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-12-26
---

# Compilare e installare

Eseguire le seguenti operazioni nel server. Nel vostro ambiente, alcuni pacchetti dipendenti potrebbero essere mancanti. Installali utilizzando: `dnf -y install autoconf automake libtool`

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh && \
./configure --prefix=/usr/local/inotify-tools && \
make && \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

Aggiungi la variabile di ambiente PATH, scrivila al file di configurazione e lascia che abbia effetto in modo permanente.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**Perché non utilizzare il pacchetto RPM inotify-tools dell'archivio EPEL? E il modo per usare il codice sorgente per compilare e installare?**

L'autore ritiene personalmente che la trasmissione di dati a distanza sia una questione di efficienza, soprattutto in un ambiente di produzione, dove ci sono un gran numero di file da sincronizzare e un singolo file è particolarmente grande. Inoltre, la nuova versione avrà alcune correzioni di bug e espansioni delle funzioni, e forse l'efficienza di trasmissione della nuova versione sarà maggiore, quindi vi consiglio di installare inotify-tools dal codice sorgente. Naturalmente, questo è il suggerimento personale dell'autore, non tutti gli utenti lo devono seguire.

## Regolazione dei parametri del kernel

È possibile regolare i parametri del kernel in base alle esigenze dell'ambiente di produzione. Per impostazione predefinita, ci sono tre file in **/proc/sys/fs/inotity/**

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events-dimensione massima della coda del monitor, predefinita 16384
* max_user_instances-il numero massimo di istanze di monitoraggio, il valore predefinito è 128
* max_user_watches-il numero massimo di file monitorati per istanza, il valore predefinito è 8192

Scrivi alcuni parametri e valori in **/etc/sysctl.conf**, gli esempi sono i seguenti. Quindi usa `sysctl -p` per rendere i file effettivi

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## Comandi correlati

Lo strumento inotify-tools ha due comandi, chiamati:

* **inotifywait**: per il monitoraggio continuo, risultati in tempo reale. È generalmente usato con lo strumento di backup incrementale rsync. Poiché si tratta di un monitoraggio del file system, può essere utilizzato con uno script. Introdurremo lo script specifico in un secondo momento.

* **inotifywatch**: per il monitoraggio a breve termine, risultati in uscita dopo il completamento dell'attività.

`inotifywait` ha principalmente le seguenti opzioni:

```txt
-m significa monitoraggio continuo
-r Monitoraggio ricorsivo
-q Semplificare le informazioni di output
-e specifica il tipo di evento di dati di monitoraggio, più tipi di eventi sono separati da virgole nello stato inglese
```

I tipi di eventi sono i seguenti:

| Tipo di evento | Descrizione                                                                             |
| -------------- | --------------------------------------------------------------------------------------- |
| access         | Accesso al contenuto di un file o di una directory                                      |
| modify         | I contenuti del file o della directory vengono scritti                                  |
| attrib         | Gli attributi del file o della directory vengono modificati                             |
| close_write    | Il file o la directory viene aperto in modalità scrivibile e quindi chiuso              |
| close_nowrite  | Il file o la directory è chiuso dopo essere stato aperto in modalità di sola lettura    |
| close          | Indipendentemente dalla modalità lettura/scrittura, il file o la directory viene chiuso |
| open           | Il file o la directory è aperto                                                         |
| moved_to       | Un file o una directory è spostato nella directory monitorata                           |
| moved_from     | Un file o una directory viene spostato dalla directory monitorata                       |
| move           | Ci sono file o cartelle che vengono spostati o rimossi dalla directory di monitoraggio  |
| move_self      | Il file o la directory monitorati sono stati spostati                                   |
| create         | Ci sono file o directory create nella directory monitorata                              |
| delete         | Viene eliminato un file o una directory nella directory monitorata                      |
| delete_self    | Il file o la directory sono stati eliminati                                             |
| unmount        | File system contenente file o directory non montati                                     |

Esempio: `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## Dimostrazione del comando `inotifywait`

Digitare il comando nel primo terminale pts/0, e la finestra viene bloccata dopo aver premuto Invio, indicando che sta monitorando

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/

```

Nel secondo terminale pts/1, vai nella directory /rsync/ e crea un file.

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

Torna al primo terminale pts/0, le informazioni di output sono le seguenti:

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/
/rsync/ CREATE inotify
```

## Combinazione di  `inotifywait` and `rsync`

!!! tip "Suggerimento!"

    Stiamo operando nel server Rocky Linux 8, utilizzando il protocollo SSH per la dimostrazione.

Per il login di autenticazione senza password del protocollo SSH, si prega di fare riferimento a [rsync accesso di autenticazione senza password](05_rsync_authentication-free_login.md), che non è descritto qui. Un esempio del contenuto di uno script bash è il seguente. È possibile aggiungere diverse opzioni dopo il comando in base alle esigenze per soddisfare le vostre esigenze. Ad esempio, puoi anche aggiungere `--delete` dopo il comando `rsync`.

```bash
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* testfedora@192.168.100.5:/home/testfedora/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@Rocky ~]# chmod +x rsync_inotify.sh
[root@Rocky ~]# bash /root/rsync_inotify.sh &
```

!!! tip "Suggerimento!"

    Quando si utilizza il protocollo SSH per la trasmissione della sincronizzazione dei dati, se la porta di servizio SSH della macchina di destinazione non è la 22, puoi usare un metodo simile a questo——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192. 68.100.5:/home/testfedora/"`

!!! tip "Suggerimento!"

    Se vuoi avviare questa script all'avvio
    `[root@Rocky ~]# echo "bash /root/rsync_inotify. h &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

Se si sta utilizzando il protocollo rsync per la sincronizzazione, è necessario configurare il servizio rsync della macchina di destinazione, fare riferimento a [rsync demo 02](03_rsync_demo02.md), [rsync file di configurazione](04_rsync_configure.md), [accesso senza autenticazione segreta rsync](05_rsync_authentication-free_login.md)
