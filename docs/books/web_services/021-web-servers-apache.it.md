---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 2.1 Server Web Apache
---

## Apache

In questo capitolo, si introdurrà il server web Apache.

****

**Obiettivi**: Si imparerà come:

:heavy_check_mark: installare e configurare Apache

:checkered_flag: **apache**, **http**, **httpd**

**Conoscenza**: :star: :star:
**Complessità**: :star: :star:

**Tempo di lettura**: 30 minuti

****

### Generalità

Il server HTTP Apache è sviluppato da un gruppo di volontari: The Apache Group. Questo gruppo si è proposto di costruire un server Web allo stesso livello dei prodotti commerciali, ma come software libero (il suo codice sorgente è liberamente accessibile).

Centinaia di utenti si sono uniti al team originale e hanno contribuito con idee, test e righe di codice, per rendere Apache il server Web più utilizzato al mondo.

L'antenato di Apache è il accessible server sviluppato dal National Center for Supercomputing Applications dell'Università dell'Illinois. L'evoluzione di questo server si è interrotta quando il responsabile ha lasciato l'NCSA nel 1994. Gli utenti continuavano a correggere bug e a creare estensioni, che distribuivano come “patch”, da cui il nome “a patchee server”.

La versione 1.0 di Apache è stata rilasciata il 1° dicembre 1995 (oltre 30 anni fa!).

Il team di sviluppo coordina il proprio lavoro attraverso una mailing list, dove vengono discusse le proposte e le modifiche al software. Le modifiche vengono votate prima di essere incorporate nel progetto. Chiunque può unirsi al team di sviluppo. Per diventare un membro del Gruppo Apache, è necessario contribuire attivamente al progetto.

Il server Apache ha una solida presenza su Internet e rappresenta circa il 50% della quota di mercato di tutti i siti attivi.

Apache sta cedendo spesso quote di mercato a favore del suo principale sfidante, il server Nginx. Quest'ultimo è più veloce nel fornire pagine web, ma meno completo dal punto di vista funzionale rispetto al gigante Apache.

### Installazione

Apache è **multi-piattaforma**. È utilizzabile su Linux, Windows, Mac...

L'amministratore deve scegliere tra due metodi di installazione:

- **Package installation**: il fornitore della distribuzione fornisce **versioni stabili e supportate** (ma a volte più vecchie).

- **Installation from source**: Questo comporta la compilazione del software da parte dell'amministratore, che può specificare le opzioni che gli interessano, ottimizzando così il servizio. Poiché Apache ha un'architettura modulare, in genere non è necessario ricompilare il software Apache per aggiungere o rimuovere funzionalità aggiuntive (aggiungere o rimuovere moduli).

Il metodo di installazione package-based è fortemente consigliato. Sono disponibili repository aggiuntive per installare versioni più recenti di Apache su distribuzioni più vecchie, ma nessuno fornisce supporto in caso di problemi.

Nelle distribuzioni Enterprise Linux, il pacchetto `httpd` fornisce il server Apache.

In futuro, potrebbe essere necessario installare alcuni moduli aggiuntivi. Ecco un elenco di alcuni moduli e dei loro ruoli:

- **mod_access**: filtra l'accesso dei client in base al nome dell'host, all'indirizzo IP o ad altre caratteristiche.
- **mod_alias**: abilita la creazione di alias o directory virtuali.
- **mod_auth**: autentica i client.
- **mod_cgi**: esegue gli script CGI.
- **mod_info**: fornisce informazioni sullo stato del server
- **mod_mime**: associa i tipi di file all'azione corrispondente.
- **mod_proxy**: gestisce un server proxy
- **mod_rewrite**: riscrive gli URL al volo con espressioni regolari, condizioni e flag.
- Altri

```bash
sudo dnf install httpd
```

La versione installata su Rocky Linux 9 è la 2.4.

L'installazione del pacchetto crea un utente di sistema `apache` e un gruppo di sistema corrispondente `apache`.

```bash
$ grep apache /etc/passwd
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
$ grep apache /etc/group
apache:x:48:
```

Attivare e avviare il servizio con il seguente comando:

```bash
$ sudo systemctl enable httpd --now
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

È possibile controllare lo stato del servizio:

```bash
$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabl>     Active: active (running) since Fri 2024-06-21 14:22:34 CEST; 8s ago
       Docs: man:httpd.service(8)
   Main PID: 4387 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 177 (limit: 11110)
     Memory: 24.0M
        CPU: 68ms
     CGroup: /system.slice/httpd.service
             ├─4387 /usr/sbin/httpd -DFOREGROUND
             ├─4389 /usr/sbin/httpd -DFOREGROUND
             ├─4390 /usr/sbin/httpd -DFOREGROUND
             ├─4391 /usr/sbin/httpd -DFOREGROUND
```

Non si dimentichi di aprire il firewall (consultare la sezione Sicurezza).

Ora è possibile verificare se il servizio è attivo:

- Da qualsiasi browser web fornendo l'indirizzo IP del vostro server (ad esempio, <http://192.168.1.100/>).
- Direttamente sul server host.

Per farlo, è necessario installare un text browser, come elinks.

```bash
sudo dnf install elinks
```

Si consulti il server per un controllo della pagina predefinita:

```bash
elinks http://localhost
```

L'installazione del pacchetto \`httpd' genera una struttura ad albero completa che deve essere compresa a fondo:

```text
/etc/httpd/
├── conf
│   ├── httpd.conf
│   └── magic
├── conf.d
│   ├── README
│   ├── autoindex.conf
│   ├── userdir.conf
│   └── welcome.conf
├── conf.modules.d
│   ├── 00-base.conf
│   ├── 00-brotli.conf
│   ├── 00-dav.conf
│   ├── 00-lua.conf
│   ├── 00-mpm.conf
│   ├── 00-optional.conf
│   ├── 00-proxy.conf
│   ├── 00-systemd.conf
│   ├── 01-cgi.conf
│   ├── 10-h2.conf
│   ├── 10-proxy_h2.conf
│   └── README
├── logs -> ../../var/log/httpd
├── modules -> ../../usr/lib64/httpd/modules
├── run -> /run/httpd
└── state -> ../../var/lib/httpd
/var/log/httpd/
├── access_log
└── error_log
/var/www/
├── cgi-bin
└── html
```

Si noterà che la cartella `/etc/httpd/logs` è un link simbolico alla cartella `/var/log/httpd`.  Allo stesso modo, si noterà che i file che compongono il sito predefinito si trovano nella cartella `/var/www/html`.

### Configurazione

Inizialmente, l'intera configurazione del server Apache era contenuta in un singolo file \`/etc/httpd/conf/httpd.conf'. Col tempo, questo file è diventato sempre più imponente e meno leggibile.

Nelle distribuzioni moderne, quindi, si tende a distribuire la configurazione di Apache in una serie di file `*.conf` nelle directory `/etc/httpd/conf.d` e `/etc/httpd/conf.modules.d`, collegati al file principale `/etc/httpd/conf/httpd.conf` tramite la direttiva Include.

```bash
$ sudo grep "^Include" /etc/httpd/conf/httpd.conf
Include conf.modules.d/*.conf
IncludeOptional conf.d/*.conf
```

Il file \`/etc/httpd/conf/httpd.conf' è ampiamente documentato. In generale, questi commenti sono sufficienti a chiarire le opzioni dell'amministratore.

La configurazione globale del server si trova in `/etc/httpd/conf/httpd.conf`.

Questo file ha tre sezioni per la configurazione:

- Nella **section 1**, il global environment;
- Nella **section 2**, i parametri del sito e del sito virtuale predefiniti.
- Nella **section 3**, gli hosts virtuali.

Il **Virtual hosting** consente di mettere online **diversi siti virtuali** sullo stesso server. I siti vengono quindi contraddistinti in base ai loro nomi di dominio, indirizzi IP, ecc.

La modifica di un valore nella sezione 1 o 2 si ripercuote sui tutti i siti nel host.

In un ambiente condiviso, le modifiche si trovano dunque nella sezione 3.

Per facilitare gli aggiornamenti futuri, si consiglia di creare un file di configurazione della sezione 3 per ogni sito virtuale.

Ecco una versione minimale del file `httpd.conf`:

```file
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
```

#### Sezione 1

Le varie direttive incontrate nella Sezione 1 sono :

| Opzione                | Informazione                                                                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ServerTokens`         | Questa direttiva sarà oggetto di un prossimo capitolo.                                                                                       |
| `ServertRoot`          | Indica il percorso della directory contenente tutti i file che compongono il server Apache.                                                  |
| `Timeout`              | Il numero di secondi prima della scadenza di una richiesta troppo lunga (in entrata o in uscita).                         |
| `KeepAlive`            | Connessione persistente (più richieste per connessione TCP).                                                              |
| `MaxKeepAliveRequests` | Numero massimo di connessioni persistenti.                                                                                                   |
| `KeepAliveTimeout`     | Numero di secondi per attendere la prossima richiesta del client prima di chiudere la connessione TCP.                                       |
| `Listen`               | Consente ad Apache di tenersi in ascolto di indirizzi o porte specifiche.                                                                    |
| `LoadModule`           | Carica i moduli aggiuntivi (in generale, meno moduli = maggiore sicurezza).                                               |
| `Include`              | Contiene altri file di configurazione del server.                                                                                            |
| `ExtendedStatus`       | Visualizza ulteriori informazioni sul server nel status module del server.                                                                   |
| `User` and `Group`     | Consente l'avvio di processi Apache con utenti diversi. Apache è avviato sempre come root, poi cambia proprietario e gruppo. |

##### Multi-Process Modules (MPM)

Il server Apache è stato progettato per essere potente e flessibile, in grado di funzionare su diverse piattaforme.

Piattaforme e ambienti diversi spesso significano funzionalità diverse o l'uso di altri metodi per implementare la stessa funzionalità nel modo più efficiente possibile.

La struttura modulare di Apache consente all'amministratore di scegliere quali funzionalità includere nel server selezionando i moduli da caricare, sia in fase di compilazione che di esecuzione.

Questa modularità comprende anche le funzioni più rudimentali del server web.

I moduli Multi-Process Modules (MPM) sono responsabili dell'associazione con le porte di rete del server, dell'accettazione delle richieste e della loro distribuzione tra i vari processi figli.

La configurazione dei moduli MPM avviene nel file di configurazione /etc/httpd/conf.modules.d/00-mpm.conf:

```file
# Select the MPM module which should be used by uncommenting exactly
# one of the following LoadModule lines.  See the httpd.conf(5) man
# page for more information on changing the MPM.

# prefork MPM: Implements a non-threaded, pre-forking web server
# See: http://httpd.apache.org/docs/2.4/mod/prefork.html
#
# NOTE: If enabling prefork, the httpd_graceful_shutdown SELinux
# boolean should be enabled, to allow graceful stop/shutdown.
#
#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so

# worker MPM: Multi-Processing Module implementing a hybrid
# multi-threaded multi-process web server
# See: http://httpd.apache.org/docs/2.4/mod/worker.html
#
#LoadModule mpm_worker_module modules/mod_mpm_worker.so

# event MPM: A variant of the worker MPM with the goal of consuming
# threads only for connections with active processing
# See: http://httpd.apache.org/docs/2.4/mod/event.html
#
LoadModule mpm_event_module modules/mod_mpm_event.so
```

Come si può vedere, l'MPM predefinito è mpm_event.

Le prestazioni e le capacità del server web dipendono molto dalla scelta dell'MPM.

La scelta di un modulo rispetto a un altro è un compito complesso, così come l'ottimizzazione del modulo MPM scelto (numero di client, query, ecc.).

La configurazione di Apache presuppone un servizio moderatamente trafficato (256 client al massimo) per impostazione predefinita.

##### Informazioni sulle direttive keepalive

Con la direttiva `KeepAlive` disabilitata, ogni richiesta di risorse sul server richiede l'apertura di una connessione TCP,  il che è dispendioso dal punto di vista della rete e richiede molte risorse di sistema.

Con la direttiva  `KeepAlive` impostata su `On`, il server mantiene aperta la connessione con il client per la durata del `KeepAlive`.

Questa strategia è vincente perché una pagina web contiene diversi file (immagini, fogli di stile, Javascript, ecc.).

Tuttavia, è importante impostare questo valore nel modo più accurato possibile:

- Un valore troppo breve penalizza il cliente,
- Un valore troppo lungo penalizza le risorse del server.

I valori di `KeepAlive` per gli host virtuali dei singoli client consentono una maggiore granularità per cliente. In questo caso, l'impostazione dei valori di `KeepAlive` avviene direttamente nel VirtualHost del client o a livello di proxy (`ProxyKeepalive` e `ProxyKeepaliveTimeout`).

#### Sezione 2

Nella sezione 2 si impostano i valori utilizzati dal server principale. Il server principale risponde a tutte le richieste non gestite da uno dei Virtualhost di cui alla sezione 3.

I valori vengono utilizzati anche come valori predefiniti per i siti virtuali.

| Opzione             | Descrizione                                                                                                                                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ServerAdmin`       | specifica un indirizzo e-mail che appare in alcune pagine generate automaticamente, come quelle di errore.                                                                                          |
| `ServerName`        | specifica il nome con il quale è identificato il server. Può avvenire automaticamente, ma si consiglia di specificarlo esplicitamente (indirizzo IP o nome DNS). |
| `DocumentRoot`      | specifica la directory contenente i file da fornire ai client. La cartella predefinita è /var/www/html/.                                                                            |
| `ErrorLog`          | specifica il percorso del log file degli errori.                                                                                                                                                    |
| `LogLevel`          | debug, info, notice, warn, error, crit, alert, emerg.                                                                                                                                               |
| `LogFormat`         | definisce un formato specifico di log. Definito con la opzione CustomLog.                                                                                                           |
| `CustomLog`         | specifica il percorso per accedere al file.                                                                                                                                                         |
| `ServerSignature`   | già visto nella parte relativa alla sicurezza.                                                                                                                                                      |
| `Alias`             | specifica una directory esterna al tree e la rende accessibile. La presenza o l'assenza dell'ultima barra nel contesto è importante.                                                |
| `Directory`         | specifica i comportamenti e i diritti di accesso per directory.                                                                                                                                     |
| `AddDefaultCharset` | specifica il formato di codifica delle pagine inviate (i caratteri accentati possono essere sostituiti da ?...).                 |
| `ErrorDocument`     | personalizza le pagine di errore.                                                                                                                                                                   |
| `server-status`     | Riporta lo status del server.                                                                                                                                                                       |
| `server-info`       | Espone la configurazione del server.                                                                                                                                                                |

##### La `ErrorLog` directive

La directive `ErrorLog` definisce il log degli errori da utilizzare.

Questa direttiva definisce il nome del file in cui il server registra tutti gli errori che incontra. Se il percorso del file non è assoluto, si assume che sia relativo a ServerRoot.

##### La `DirectoryIndex` directive

La DirectoryIndex directive definisce la pagina iniziale del sito.

Questa direttiva specifica il nome del file caricato per primo, che fungerà da indice del sito o da pagina iniziale.

Sintassi:

```file
DirectoryIndex display-page
```

Il path completo non è specificato. La ricerca del file avviene nella directory specificata da DocumentRoot.

Esempio:

```file
DocumentRoot /var/www/html
DirectoryIndex index.php index.htm
```

Questa direttiva specifica il nome dell'index file del sito web. L'Index file è la pagina predefinita che si apre quando il cliente digita l'URL del sito (senza dover digitare l'index name). Questo file deve trovarsi nella directory specificata dalla directive`DocumentRoot`.

La directive `DirectoryIndex` può specificare molti nomi di Index file separati da spazi. Ad esempio, una index page predefinita con contenuti dinamici e, come seconda scelta, una pagina statica.

##### La directive `Directory`

Il tag Directory è usato per definire directive per le specifiche directory.

Questo tag applica i diritti a una o più directory. Deve essere inserito il path assoluto alla directory.

Sintassi:

```file
<Directory directory-path>
Defining user rights
</Directory>
```

Esempio:

```file
<Directory /var/www/html/public>
    Require all granted   # we allow everyone
</Directory>
```

La sezione `Directory` definisce un blocco di directive applicabili a una parte del file system del server. Questo tag applica diritti a una o più directory. Le directive qui riportate si applicano solo alla directory (e alle sottodirectory) specificata.

La sintassi di questo blocco accetta wildcards, ma è preferibile usare il blocco DirectoryMatch.

Nell'esempio seguente, si negherà l'accesso al disco rigido locale del server, indipendentemente dal client. La directory “/” rappresenta la root del disco rigido.

```file
<Directory />
    Require all denied
</Directory>
```

L'esempio seguente mostra l'autorizzazione all'accesso alla directory di pubblicazione /var/www/html di tutti i client.

```file
<Directory /var/www/html>
    Require all granted
</Directory>
```

Quando il server trova un file `.htaccess', deve sapere se le directive inserite nel file sono autorizzate a modificare la configurazione preesistente. La direttiva `AllowOverride`controlla l'autorizzazione nelle directive`Directory`. Se impostato su `none`, i file `.htaccess\` saranno completamente ignorati.

##### Il `mod_status`

`mod_status` visualizza una pagina `/server-status` o `/server-info` che riassume lo stato del server:

```file
<Location /server-status>
    SetHandler server-status
    Require local
</Location>

<Location /server-info>
    SetHandler server-info
    Require local
</Location>
```

Si noti che questo modulo fornisce informazioni che non devono essere accessibili agli utenti.

#### Hosting condiviso (sezione 3)

Con l'hosting condiviso, il cliente pensa di visitare diversi server. In realtà, esiste un solo server e diversi siti virtuali.

Per impostare un hosting condiviso, è necessario creare degli host virtuali:

- dichiarare più porte di ascolto
- dichiarare più indirizzi IP di ascolto (hosting virtuale per IP)
- dichiarare più nomi di server (hosting virtuale per nome)

Ogni sito virtuale corrisponde a una struttura a tree diversa.

La sezione 3 del file `httpd.conf` permette di dichiarare questi host virtuali.

Si consiglia vivamente di creare un file di configurazione per la sezione 3 per ogni sito virtuale, per facilitare gli aggiornamenti futuri.

Scegliete l'hosting virtuale “per IP” o “per nome”. Non è consigliabile combinare le due soluzioni per la produzione.

- Configurare un file di configurazione indipendente per ogni sito virtuale
- I VirtualHost sono salvati in `/etc/httpd/conf.d/`.
- L'estensione del file è \`.conf\`\`.

##### La direttiva `VirtualHost`

La direttiva `VirtualHost` definisce gli host virtuali.

```file
<VirtualHost IP-address[:port]>
    # if the "NameVirtualHost" directive is present
    # then "address-IP" must match the one entered
    # under "NameVirtualHost" as well as for "port".
 ...
 </VirtualHost>
```

Se si configura il server Apache con le direttive di base viste sopra, è possibile pubblicare un solo sito. Infatti, non è possibile pubblicare più siti con le impostazioni predefinite: stesso indirizzo IP, stessa porta TCP, e nessun hostname o hostname unico.

I siti virtuali ci permetteranno di pubblicare diversi siti web sullo stesso server Apache. Si definiscono dei blocchi, ognuno dei quali descrive un sito web. In questo modo, ogni sito avrà la propria configurazione.

Per facilitare la comprensione, un sito web è spesso associato ad un singolo server. I siti virtuali o host sono chiamati così perché smaterializzano il legame tra il server fisico e siti web.

Esempio 1:

```file
Listen 192.168.0.10:8080
<VirtualHost 192.168.0.10:8080>
  DocumentRoot /var/www/site1/
  ErrorLog /var/log/httpd/site1-error.log
</VirtualHost>

Listen 192.168.0.11:9090
<VirtualHost 192.168.0.11:9090>
  DocumentRoot /var/www/site2/
  ErrorLog /var/log/httpd/site2-error.log
</VirtualHost>
```

L'hosting virtuale basato su IP applica linee guida specifiche in base all'indirizzo IP e alla porta su cui viene ricevuta la richiesta. Ciò significa generalmente servire siti web diversi su porte o interfacce diverse.

##### La direttiva `NameVirtualHost`

La direttiva `NameVirtualHost` definisce gli host virtuali name-based.

Questa direttiva è obbligatoria per l'impostazione di host virtuali name-based. Con questa direttiva si specifica l'indirizzo IP su cui il server riceverà le richieste dagli host virtuali name-based.

Sintassi:

```text
NameVirtualHost adresse-IP[:port]
```

Esempio:

```test
NameVirtualHost 160.210.169.6:80
```

La direttiva deve precedere i blocchi di descrizione del sito virtuale. Definisce gli indirizzi IP utilizzati per ascoltare le richieste dei client per i siti virtuali.

Per ascoltare le richieste su tutti gli indirizzi IP del server, utilizzare il carattere \*.

#### Tenere in considerazione i cambiamenti

Per ogni modifica della configurazione, è necessario ricaricarla con il seguente comando:

```bash
sudo systemctl reload httpd
```

#### Manuale

Un pacchetto chiamato 'httpd-manual' contiene un sito che funge da manuale d'uso di Apache.

```bash
sudo dnf install httpd-manual
sudo systemctl reload httpd
```

È possibile accedere al manuale con un browser Web all'indirizzo <http://127.0.0.1/manual> quando è installato.

```bash
$ elinks http://127.0.0.1/manual
```

#### Il comando `apachectl`

`apachectl` è l'interfaccia di controllo del server Apache `httpd`.

È un comando molto utile con l'opzione `-t` o `configtest`, che esegue un test della sintassi del file di configurazione.

!!! NOTE "Nota"

```
È molto utile se usato con i gestori di Ansible per testare la configurazione.
```

### Sicurezza

Quando si protegge il server con un firewall (che è una buona cosa), potrebbe essere necessario considerare la possibilità di aprirlo.

```bash
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --zone=public --add-service=https
sudo firewall-cmd --reload
```

#### SELinux

Per impostazione predefinita, se la sicurezza SELinux è attiva, impedisce la lettura di un sito da una directory diversa da `/var/www/`.

La directory contenente il sito deve avere il contesto di sicurezza `httpd_sys_content_t`.

È possibile verificare il contesto attuale con il comando:

```bash
* ls -Z /dir
```

Aggiungere il contesto con il seguente comando:

```bash
sudo chcon -vR --type=httpd_sys_content_t /dir
```

Inoltre, impedisce l'apertura di una porta non standard. L'apertura della porta è un'operazione manuale da eseguire con il comando `semanage` (non installato di default).

```bash
sudo semanage port -a -t http_port_t -p tcp 1664
```

#### Direttive User e Group

Le direttive `User` e `Group` definiscono un account e un gruppo di gestione di Apache.

Storicamente, root eseguiva Apache, il che causava problemi di sicurezza. Root esegue sempre Apache, ma poi la sua identità viene cambiata. Generalmente l'utente `apache` e il gruppo `apache`.

Mai ROOT!

Il server Apache (processo `httpd`) si avvia con l'account di superutente `root`. Ogni richiesta del client attiva la creazione di un processo “child”. Per limitare i rischi, questi processi child vengono lanciati da un account meno privilegiato.

Le direttive User e Group dichiarano l'account e il gruppo utilizzati per creare i processi child.

Questo account e questo gruppo devono esistere nel sistema (per impostazione predefinita, ciò avviene durante l'installazione).

#### Permessi dei file

Come regola generale di sicurezza, il contenuto del server Web non deve appartenere al processo che esegue il server. Nel nostro caso, i file non dovrebbero appartenere all'utente e al gruppo `apache`, che ha accesso in scrittura alle cartelle.

I contenuti vengono assegnati all'utente non privilegiato, all'utente root e al gruppo associato. Tra l'altro, è possibile anche limitare i diritti di accesso del gruppo.

```bash
cd /var/www/html
sudo chown -R root:root ./*
sudo find ./ -type d -exec chmod 0755 "{}" \;
sudo find ./ -type f -exec chmod 0644 "{}" \;
```

<!---

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

## Nginx

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
