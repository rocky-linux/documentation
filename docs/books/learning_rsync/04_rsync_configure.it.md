---
title: file di configurazione rsync
author: tianci li
update: 2021-12-25
---

# /etc/rsyncd.conf

Nel precedente articolo [rsync demo 02](03_rsync_demo02.md) abbiamo introdotto alcuni parametri di base. Questo articolo è per integrare altri parametri.

| Parametri                           | Descrizione                                                                                                                                                                                                                                                                                                                                                                    |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| fake super = yes                    | sì significa che non è necessario che il demone venga eseguito come root per memorizzare gli attributi completi del file.                                                                                                                                                                                                                                                      |
| uid =                               | user id                                                                                                                                                                                                                                                                                                                                                                        |
| gid =                               | Due parametri sono utilizzati per specificare l'utente e il gruppo utilizzati per trasferire i file quando si esegue il demone rsync come root. Il valore predefinito è nobody                                                                                                                                                                                                 |
| use chroot = yes                    | Se la directory radice deve essere bloccata prima della trasmissione, sì sì, no no. Al fine di aumentare la sicurezza, rsync yes di default.                                                                                                                                                                                                                                   |
| max connections = 4                 | Il numero massimo di connessioni ammesse, il valore predefinito è 0, il che significa che non ci sono restrizioni                                                                                                                                                                                                                                                              |
| lock file = /var/run/rsyncd.lock    | Il file di blocco specificato, che è associato al parametro "max connection"                                                                                                                                                                                                                                                                                                   |
| exclude = lost+found/               | Escludi directory che non devono essere trasferite                                                                                                                                                                                                                                                                                                                             |
| transfer logging = yes              | Indica se abilitare il formato di log simile a ftp per registrare i caricamenti e i download di rsync                                                                                                                                                                                                                                                                          |
| timeout = 900                       | Specifica il periodo di timeout. Se nessun dato viene trasmesso entro il tempo specificato, rsync uscirà direttamente. L'unità è secondi, il valore predefinito è 0 significa mai time out                                                                                                                                                                                     |
| ignore nonreadable = yes            | Indica se ignorare i file a cui l'utente non ha diritti di accesso                                                                                                                                                                                                                                                                                                             |
| motd file = /etc/rsyncd/rsyncd.motd | Usato per specificare il percorso del file del messaggio. Per impostazione predefinita, non c'è un file motd. Questo messaggio è il messaggio di benvenuto visualizzato quando l'utente accede.                                                                                                                                                                                |
| hosts allow = 10.1.1.1/24           | Usato per specificare a quali client IP o segmento di rete è consentito accedere. È possibile compilare l'ip, il segmento di rete, il nome dell'host, l'host sotto il dominio e separare i multipli con gli spazi. Consenti a tutti di accedere per impostazione predefinita                                                                                                   |
| hosts deny = 10.1.1.20              | A quali client Ip o segmento di rete specificati dall'utente non è consentito accedere. Se gli host consentono e gli host negano lo stesso risultato corrispondente, il client non può accedervi alla fine. Se l'indirizzo del client non è né nel host allow né nel host deny, il client è autorizzato ad accedere. Per impostazione predefinita, questo parametro non esiste |
| auth users = li                     | Abilita utenti virtuali, più utenti sono separati da virgole nello stato inglese                                                                                                                                                                                                                                                                                               |
| syslog facility = daemon            | Definisce il livello del registro di sistema. Questo valore può essere riempito con: auth, authpriv, cron, daemon, ftp, kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2 local3, local4, local5, local6 and local7. Il valore predefinito è daemon                                                                                                  |

## Configurazione raccomandata

```ini title="/etc/rsyncd.conf"
uid = nobody
gid = nobody
address = 192.168.100.4
use chroot = yes
max connections = 10
syslog facility = daemon
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock
[file]
  comment = rsync
  path = /rsync/
  read only = no
  dont compress = *.gz *.bz2 *.zip
  auth users = li
  secrets file = /etc/rsyncd users.db
```
