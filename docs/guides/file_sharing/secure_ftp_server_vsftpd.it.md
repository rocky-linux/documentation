---
title: Server FTP sicuro - vsftpd
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested with: 8.5
tags:
  - security
  - ftp
  - vsftpd
---

# Server FTP sicuro - vsftpd

## Prerequisiti

* Conoscenza di un editor a riga di comando (in questo esempio utilizziamo _vi_)
* Un buon livello di confidenza con l'immissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* È utile la comprensione di PAM e dei comandi _openssl_.
* Tutti i comandi sono eseguiti come utente root o sudo

## Introduzione

_vsftpd_ è il Demone FTP Molto Sicuro (FTP è il protocollo di trasferimento di file). È disponibile da molti anni ed è il demone FTP predefinito in Rocky Linux e in molte altre distribuzioni Linux.

_vsftpd_ consente di utilizzare utenti virtuali con moduli di autenticazione collegabili (PAM). Questi utenti virtuali non esistono nel sistema e non hanno altri permessi se non quello di usare FTP. Ciò significa che se un utente virtuale viene compromesso, la persona con quelle credenziali non avrà altre autorizzazioni una volta ottenuto l'accesso. L'utilizzo di questa configurazione è davvero molto sicura, ma richiede un po' di lavoro in più.

!!! hint "Prendi in considerazione `sftp`"

    Anche con le impostazioni di sicurezza usate qui per configurare `vsftpd`, si potrebbe prendere in considerazione `sftp`. `sftp` cripta l'intero flusso di connessione e per questo motivo è più sicuro. Abbiamo creato un documento [qui](../sftp) che tratta l'impostazione di `sftp` e il blocco di SSH.

## Installazione di vsftpd

Dobbiamo anche assicurarci che _openssl_ sia installato. Se si utilizza un server web, probabilmente questo **è** già installato, ma per sicurezza è possibile eseguirlo:

`dnf install vsftpd openssl`

È inoltre necessario abilitare il servizio vsftpd:

`systemctl enable vsftpd`

Ma _non avviate ancora il servizio._

## Configurazione di vsftpd

Vogliamo assicurarci che alcune impostazioni siano disabilitate e che altre siano abilitate. In genere, quando si installa _vsftpd_, viene fornito con le opzioni più sicure già impostate, ma è una buona idea accertarsene.

Per controllare il file di configurazione e apportare le modifiche necessarie, eseguire:

`vi /etc/vsftpd/vsftpd.conf`

Cercare la riga "anonymous_enable=" e assicurarsi che sia impostata su "NO" e che **NON** sia rimarcata/commentata. (Commentando questa riga si abilitano i login anonimi).  La linea dovrebbe avere questo aspetto quando è corretta:

`anonymous_enable=NO`

Assicurarsi che local_enable sia impostato su yes:

`local_enable=YES`

Aggiungere una riga per l'utente root locale. Se il server su cui si sta installando è un server web, si presume che si utilizzi [Apache Multisito](../web/apache-sites-enabled.md) e che la propria radice locale rifletta tale impostazione. Se la vostra configurazione è diversa, o se non si tratta di un server web, regolate l'impostazione local_root:

`local_root=/var/www/sub-domains`

Assicurarsi che anche write_enable sia impostato su yes:

`write_enable=YES`

Individuare la riga "chroot_local_users" e rimuovere il commento. Aggiungete quindi due righe in basso, in modo da ottenere un aspetto simile a questo:

```
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
```

Al di sotto di questo, vogliamo aggiungere una sezione completamente nuova che si occuperà degli utenti virtuali:

```
# Virtual User Settings
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=vsftpd
guest_username=vsftpd
```

È necessario aggiungere una sezione in fondo al file per forzare la crittografia delle password inviate via internet. Abbiamo bisogno di _openssl_ installato e dovremo creare il file del certificato anche per questo.

Iniziate aggiungendo queste righe in fondo al file:

```
rsa_cert_file=/etc/vsftpd/vsftpd.pem
rsa_private_key_file=/etc/vsftpd/vsftpd.key
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

pasv_min_port=7000
pasv_max_port=7500
```

Ora salva la configurazione. (Questo è `SHIFT:wq` se si utilizza _vi_.)

## Impostazione del Certificato Rsa

È necessario creare il file del certificato RSA di _vsftpd_. L'autore ritiene generalmente che un server sia valido per 4 o 5 anni, quindi imposta il numero di giorni per questo certificato in base al numero di anni in cui si ritiene che il server sarà attivo e funzionante su questo hardware.

Modificate il numero di giorni come ritenete opportuno, quindi utilizzate il formato del comando riportato di seguito per creare i file del certificato e della chiave privata:

`openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.pem`

Come tutti i processi di creazione di certificati, si avvia uno script che richiede alcune informazioni. Non si tratta di un processo difficile. Molti campi possono essere lasciati vuoti.

Il primo campo è quello del codice paese, da compilare con il codice a due lettere del vostro paese:

`Country Name (2 letter code) [XX]:`

Poi viene lo stato o la provincia, da compilare digitando il nome completo, non l'abbreviazione:

`State or Province Name (full name) []:`

Il prossimo è il nome della località. Questa è la tua città:

`Locality Name (eg, city) [Default City]:`

Poi c'è il nome dell'azienda o dell'organizzazione. Si può lasciare in bianco o compilare come si ritiene opportuno:

`Organization Name (eg, company) [Default Company Ltd]:`

Il prossimo è il nome dell'unità organizzativa. È possibile compilare questo campo se il server è per una divisione specifica, oppure lasciarlo vuoto:

`Organizational Unit Name (eg, section) []:`

Il campo successivo deve essere compilato, ma si può decidere come compilarlo. Questo è il nome comune del tuo server. Esempio: `webftp.domainname.ext`:

`Common Name (eg, your name or your server's hostname) []:`

Infine, c'è il campo dell'e-mail, che si può certamente lasciare vuoto senza problemi:

`Email Address []:`

Una volta completato il modulo, verrà creato il certificato.


## <a name="virtualusers"></a>Impostazione Utenti Virtuali

Come già detto, l'uso di utenti virtuali per _vsftpd_ è molto più sicuro, perché non hanno privilegi di sistema. Detto questo, dobbiamo aggiungere un utente da utilizzare per gli utenti virtuali. Dobbiamo anche aggiungere un gruppo:

`groupadd nogroup`

E poi:

`useradd --home-dir /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd`

L'utente deve corrispondere alla riga `guest_username=` nel file vsftpd.conf.

A questo punto, navigare nella directory di configurazione di _vsftpd_:

`cd /etc/vsftpd`

Dobbiamo creare un nuovo database di password che verrà utilizzato per autenticare i nostri utenti virtuali. È necessario creare un file da cui leggere gli utenti virtuali e le password. Questo creerà il database.

In futuro, quando si aggiungeranno nuovi utenti, si dovrà duplicare anche questo processo:

`vi vusers.txt`

L'utente e la password sono separati da una riga, quindi è sufficiente digitare l'utente, premere Invio e quindi digitare la password. Continuate fino a quando non avrete aggiunto tutti gli utenti a cui volete dare accesso al sistema. Esempio:

```
user_name_a
user_password_a
user_name_b
user_password_b
```

Una volta creato il file di testo, vogliamo ora generare il database delle password che _vsftpd_ utilizzerà per gli utenti virtuali. Questo viene fatto con _db\_load_. _db\_load_ è fornito da _libdb-utils_ che dovrebbe essere caricato sul vostro sistema, ma se non lo è, potete semplicemente installarlo con:

`dnf install libdb-utils`

Creare il database dal file di testo con:

`db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db`

Dobbiamo soffermarci un attimo su ciò che _db\_load_ sta facendo qui:

* L'opzione -T viene utilizzata per consentire facilmente l'importazione di un file di testo nel database.
* L'opzione -t dice di specificare il metodo di accesso sottostante.
* L'_hash_ è il metodo di accesso sottostante che stiamo specificando.
* L'opzione -f indica di leggere da un file specificato.
* Il file specificato è _vusers.txt_.
* Il database che stiamo creando o aggiungendo è _vsftpd-virtual-user.db_.

Modificare i permessi predefiniti del file del database:

`chmod 600 vsftpd-virtual-user.db`

E rimuovere il file vusers.txt:

`rm vusers.txt`

Quando si aggiungono nuovi utenti, è sufficiente usare _vi_ per creare un nuovo file vusers.txt e rieseguire il comando _db\_load_, che aggiungerà i nuovi utenti al database.

## Impostazione PAM

_vsftpd_ installa un file pam predefinito quando installi il pacchetto. Stiamo per sostituirlo con il nostro contenuto, quindi **sempre** fate prima una copia di backup del vecchio file.

Creare una directory per il file di backup in /root:

`mkdir /root/backup_vsftpd_pam`

Quindi copiare il file pam in questa directory:

`cp /etc/pam.d/vsftpd /root/backup_vsftpd_pam/`

Ora modificare il file originale:

`vi /etc/pam.d/vsftpd`

Rimuovete tutto quello che c'è in questo file tranne "#%PAM-1.0" e aggiungete le righe seguenti:

```
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```

Salva le tue modifiche ed esci (`SHIFT:wq` in _vi_).

Questo abilita il login per gli utenti virtuali definiti in `vsftpd-virtual-user.db` e disabilita i login locali.

## Impostazione della Configurazione dell'Utente Virtuale

Ogni utente virtuale ha il proprio file di configurazione, che specifica la propria directory local_root. La root locale deve essere di proprietà dell'utente "vsftpd" e del gruppo "nogroup".

Ricordate che questa impostazione è stata fatta nella sezione [Impostazione Utenti Virtuali ](#virtualusers) Per cambiare la proprietà della directory, digitate semplicemente questo dalla riga di comando:

`chown vsftpd.nogroup /var/www/sub-domains/whatever_the_domain_name_is/html`

È necessario creare il file che contiene la configurazione dell'utente virtuale:

`vi /etc/vsftpd/vsftpd_user_conf/username`

Questo contiene una singola riga che specifica la local_root dell'utente virtuale:

`local_root=/var/www/sub-domains/com.testdomain/html`

Il percorso del file è specificato nella sezione "Virtual User" del file vsftpd.conf.

## Avvio di vsftpd

Una volta completato tutto questo, avviare il servizio _vsftpd_ e quindi testare gli utenti, supponendo che il servizio si avvii correttamente:

`systemctl restart vsftpd`

### Test di vsftpd

È possibile testare la configurazione utilizzando la riga di comando su un computer e verificare l'accesso al computer tramite FTP. Detto questo, il modo più semplice per effettuare un test è quello di provare con un client FTP, come [FileZilla](https://filezilla-project.org/).

Quando si esegue il test con un utente virtuale sul server che esegue _vsftpd_, si dovrebbe ottenere un messaggio di attendibilità del certificato SSL. Questo messaggio di affidabilità comunica alla persona che utilizza il client FTP che il server utilizza un certificato e chiede di approvare il certificato prima di continuare. Una volta connessi come utenti virtuali, dovreste essere in grado di inserire i file nella cartella "local_root" che abbiamo impostato per quell'utente.

Se non si riesce a caricare un file, potrebbe essere necessario tornare indietro e assicurarsi che tutti i passaggi precedenti siano stati completati. Ad esempio, potrebbe essere che i permessi di proprietà per "local_root" non siano stati impostati all'utente "vsftpd" e al gruppo "nogroup".

## Conclusione

_vsftpd_ è un server ftp molto diffuso e comune e può essere configurato come server indipendente o come parte di un [Apache Web Server Rinforzato](../web/apache_hardened_webserver/index.md). Se impostato per utilizzare utenti virtuali e un certificato, è abbastanza sicuro.

Sebbene ci sia un certo numero di passaggi per configurare _vsftpd_ come indicato in questo documento, dedicare del tempo in più per configurarlo correttamente assicurerà che il vostro server sia il più sicuro possibile.
