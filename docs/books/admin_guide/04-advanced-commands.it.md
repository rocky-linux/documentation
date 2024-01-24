---
title: Comandi Avanzati Linux
---

# Comandi avanzati per gli utenti Linux

I comandi avanzati offrono una maggiore personalizzazione e controlli in situazioni più specialistiche una volta acquisita familiarità con i comandi di base.

****

**Obiettivi** : In questo capitolo, i futuri amministratori Linux impareranno:

:heavy_check_mark: alcuni comandi utili non trattati nel capitolo precedente. :heavy_check_mark: alcuni comandi avanzati.

:checkered_flag: **comandi utente**, **Linux**

**Conoscenza**: :star: **Complessità**: :star: :star: :star:

**Tempo di lettura**: 20 minuti

****

## comando `uniq`

Il comando `uniq` è un comando molto potente, usato con il comando `sort`, soprattutto per l'analisi dei file di registro. Ti consente di ordinare e visualizzare le voci rimuovendo i duplicati.

Per illustrare il funzionamento del comando `uniq`, utilizziamo un file `firstnames.txt` contenente un elenco di nomi:

```text
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! Note "Nota"

    `uniq` richiede che il file di input sia ordinato perché confronta solo le righe consecutive.

Senza argomenti, il comando `uniq` non visualizza le righe identiche che si susseguono nel file `firstnames.txt`:

```bash
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

Per visualizzare solo le righe che appaiono solo una volta, utilizzare l'opzione `-u`:

```bash
$ sort firstnames.txt | uniq -u
patrick
```

Al contrario, per visualizzare solo le righe che compaiono almeno due volte nel file, utilizzare l'opzione `-d`:

```bash
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

Per eliminare semplicemente linee che appaiono solo una volta, utilizzare l'opzione `-D`:

```bash
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

Infine, contare il numero di occorrenze di ciascuna linea, utilizzare l'opzione `-c`:

```bash
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```bash
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## comando `xargs`

Il comando `xargs` consente la costruzione e l'esecuzione delle linee di comando da input standard.

Il comando `xargs` legge lo spazio bianco o gli argomenti delimitati da linefeed dall'ingresso standard, ed esegue il comando (`/bin/echo` per impostazione predefinita.) una o più volte utilizzando gli argomenti iniziali seguiti dagli argomenti letti dall'ingresso standard.

Un primo e più semplice esempio sarebbe il seguente:

```bash
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

Il comando `xargs` attende un input dallo standard input **stdin**. Sono state inserite tre linee. La fine dell'input dell'utente è specificata in `xargs` dalla sequenza di tasti ++ctrl+d++. `xargs` esegue quindi il comando predefinito `echo` seguito dai tre argomenti corrispondenti all'input dell'utente, vale a dire:

```bash
$ echo "use" "of" "xargs"
use of xargs
```

È possibile specificare un comando da far eseguire a `xargs`.

Nell'esempio seguente, `xargs` eseguirà il comando `ls -ld` sul set di cartelle specificate nell'input standard:

```bash
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

In pratica, il comando `xargs` esegue il comando `ls -ld /home /tmp /root`.

Cosa succede se il comando da eseguire non accetta argomenti multipli, come nel caso del comando `find`?

```bash
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

Il comando `xargs` tenta di eseguire il comando `find` con più argomenti dietro l'opzione `-name`, questo causa la generazione di un errore in `find`:

```bash
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

In questo caso, il comando `xargs` deve essere costretto ad eseguire il comando `find` più volte (una volta per riga immessa come ingresso standard). L'opzione `-L` Seguito da un **intero** consente di specificare il numero massimo di voci da elaborare con il comando contemporaneamente:

```bash
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Per specificare entrambi gli argomenti sulla stessa riga, utilizzare l'opzione `-n 1`:

```bash
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Caso di esempio di un backup con un `tar` basato su una ricerca:

```bash
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

La caratteristica speciale del comando `xargs` è che posiziona l'argomento di input alla fine del comando chiamato. Questo funziona molto bene con l'esempio sopra riportato dal momento che i file passati formano l'elenco dei file da aggiungere all'archivio.

Utilizzando l'esempio del comando `cp`, per copiare un elenco di file in una directory, questo elenco di file verrà aggiunto alla fine del comando... ma ciò che il comando `cp` si aspetta alla fine del comando è la destinazione. Per farlo, si può usare l'opzione `-I` per inserire gli argomenti di input in un punto diverso dalla fine della riga.

```bash
find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

L'opzione `-I` consente di specificare un carattere (il carattere `%` nell'esempio precedente) in cui verranno inseriti i file di input di `xargs`.

## pacchetto `yum-utils`

Il pacchetto `yum-utils` è una raccolta di utilità, realizzate per `yum` da vari autori, che ne rendono più facile e potente l'uso.

!!! Note "Nota"

    Mentre `yum` è stato sostituito da `dnf` in Rocky Linux 8, il nome del pacchetto è rimasto `yum-utils`, sebbene possa essere installato anche come `dnf-utils`. Queste sono le classiche utilities YUM implementate come shims CLI sopra a DNF per mantenere la retrocompatibilità con `yum-3`.

Ecco alcuni esempi di queste utilità.

### Comando `repoquery`

Il comando `repoquery` viene utilizzato per interrogare i pacchetti nel repository.

Esempi di utilizzo:

* Visualizzare le dipendenze di un pacchetto (può essere un pacchetto software che è stato installato o non installato), equivalente a `dnf deplist <nome-pacchetto>`

```bash
repoquery --requires <package-name>
```

* Mostra i file forniti da un pacchetto installato (non funziona per i pacchetti che non sono installati), equivalente a `rpm -ql <package-name>`

```bash
$ repoquery -l yum-utils
/etc/bash_completion.d
/etc/bash_completion.d/yum-utils.bash
/usr/bin/debuginfo-install
/usr/bin/find-repos-of-install
/usr/bin/needs-restarting
/usr/bin/package-cleanup
/usr/bin/repo-graph
/usr/bin/repo-rss
/usr/bin/repoclosure
/usr/bin/repodiff
/usr/bin/repomanage
/usr/bin/repoquery
/usr/bin/reposync
/usr/bin/repotrack
/usr/bin/show-changed-rco
/usr/bin/show-installed
/usr/bin/verifytree
/usr/bin/yum-builddep
/usr/bin/yum-config-manager
/usr/bin/yum-debug-dump
/usr/bin/yum-debug-restore
/usr/bin/yum-groups-manager
/usr/bin/yumdownloader
…
```

### Comando `yumdownloader`

Il comando `yumdownloader` scarica i pacchetti RPM dai repository.  Equivalente a `dnf scaricare --downloadonly --downloaddir ./ package-name`

!!! Note "Nota"

    Questo comando è molto utile per creare rapidamente un repository locale di alcuni rpm!

Esempio: `yumdownloader` scaricherà il pacchetto rpm _repoquery_ e tutte le sue dipendenze:

```bash
$ yumdownloader --destdir /var/tmp --resolve samba
or
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Opzioni     | Commenti                                                               |
| ----------- | ---------------------------------------------------------------------- |
| `--destdir` | I pacchetti scaricati verranno memorizzati nella cartella specificata. |
| `--resolve` | Scarica anche le dipendenze del pacchetto.                             |

## pacchetto `psmisc`

Il pacchetto `psmisc` contiene utilità per la gestione dei processi di sistema:

* `pstree`: il comando `pstree` visualizza i processi correnti sul sistema in una struttura ad albero.
* `killall`: il comando `killall` invia un segnale di kill a tutti i processi identificati dal nome.
* `fuser`: il comando `fuser` Identifica il `PID` di processi che utilizzano i file o i file system specificati.

Esempi:

```bash
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```bash
# killall httpd
```

Arresta i processi (opzione `-k`) che accedono al file `/etc/httpd/conf/httpd.conf`:

```bash
# fuser -k /etc/httpd/conf/httpd.conf
```

## comando `watch`

Il comando `watch` esegue regolarmente un comando e visualizza il risultato nel terminale a schermo intero.

L'opzione `-n` consente di specificare il numero di secondi tra ogni esecuzione del comando.

!!! Note "Nota"

    Per uscire dal comando `watch', è necessario digitare i tasti: <kbd>CTRL</kbd>+<kbd>C</kbd> per terminare il processo.

Esempi:

* Visualizza la fine del file `/etc/passwd` ogni 5 secondi:

```bash
watch -n 5 tail -n 3 /etc/passwd
```

Risultato:

```bash
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Monitoraggio del numero di file in una cartella:

```bash
watch -n 1 'ls -l | wc -l'
```

* Mostra un orologio:

```bash
watch -t -n 1 date
```

## Comando `install`

Contrariamente a quanto potrebbe suggerire il nome, il comando `install` non viene usato per installare nuovi pacchetti.

Questo comando combina la copia dei file (`cp`) e la creazione di cartelle (`mkdir`), con la gestione dei diritti (`chmod`, `chown`) e altre utili funzionalità (come i backup).

```bash
install source dest  
install -t directory source [...]
install -d directory
```

Opzioni:

| Opzioni                    | Osservazioni                                                        |
| -------------------------- | ------------------------------------------------------------------- |
| `-b` o `--backup[=suffix]` | crea un backup del file di destinazione                             |
| `-d`                       | tratta gli argomenti come nomi di cartelle                          |
| `-D`                       | crea tutti i componenti principali, prima di copiare SOURCE in DEST |
| `-g` e `-o`                | imposta la proprietà                                                |
| `-m`                       | imposta le autorizzazioni                                           |
| `-p`                       | preservare i timestamp dei file sorgente                            |
| `-t`                       | copia tutti gli argomenti di origine nella directory                |

!!! note "Nota"

    Esistono opzioni per la gestione del contesto SELinux (vedere la pagina del manuale).

Esempi:

Creare una cartella con l'opzione `-d`:

```bash
install -d ~/samples
```

Copiare un file da una posizione di origine in una cartella:

```bash
install src/sample.txt ~/samples/
```

Questi due ordini si sarebbero potuti eseguire con un unico comando:

```bash
$ install -v -D -t ~/samples/ src/sample.txt
install: creating directory '~/samples'
'src/sample.txt' -> '~/samples/sample.txt'
```

Questo comando consente di risparmiare tempo. Combinatelo con la gestione dei proprietari, dei gruppi di proprietari e dei diritti per migliorare e ridurre i tempi:

```bash
sudo install -v -o rocky -g users -m 644 -D -t ~/samples/ src/sample.txt
```

 !!! note "Nota"

     In questo caso è necessario `sudo` per apportare modifiche alle proprietà.

È anche possibile creare un backup dei file esistenti grazie all'opzione `-b`:

```bash
$ install -v -b -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt~')
```

Come si può vedere, il comandodi `install` crea un file di backup con una tilde `~` aggiunta al nome del file originale.

Il suffisso può essere specificato grazie all'opzione `-S`:

```bash
$ install -v -b -S ".bak" -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt.bak')
```
