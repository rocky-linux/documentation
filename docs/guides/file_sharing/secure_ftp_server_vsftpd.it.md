---
title: Server FTP sicuro - vsftpd
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - ftp
  - vsftpd
---

# Server FTP sicuro - `vsftpd`

## Prerequisiti

* Abilità con un editor a riga di comando (utilizzando `vi` in questo esempio)
* Un buon livello di confidenza con l'immissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* La comprensione di PAM e dei comandi `openssl` è utile
* Eseguire i comandi qui con l'utente root o con un utente normale e `sudo`

## Introduzione

`vsftpd` è il demone FTP very secure (FTP è il protocollo di trasferimento dei file). È disponibile da molti anni ed è il demone FTP predefinito in Rocky Linux e in molte altre distribuzioni Linux.

_vsftpd_ consente di utilizzare utenti virtuali con moduli di autenticazione collegabili (PAM). Questi utenti virtuali non esistono nel sistema e non hanno altre autorizzazioni, tranne quella di FTP. Se un utente virtuale viene compromesso, la persona con quelle credenziali non avrà altre autorizzazioni dopo aver ottenuto l'accesso come utente. Questa configurazione è molto sicura, ma richiede un po' di lavoro in più.

!!! tip "Prendi in considerazione `sftp`"

    Anche con le impostazioni di sicurezza usate qui per configurare `vsftpd`, si potrebbe prendere in considerazione `sftp`. `sftp` cripta l'intero flusso di connessione ed è più sicuro. Abbiamo creato un documento chiamato [Secure Server - `sftp`](../sftp) che tratta l'impostazione di `sftp` e il blocco di SSH.

## Installazione di `vsftpd`

È inoltre necessario accertarsi dell'installazione di `openssl`. Se si utilizza un server web, probabilmente questo **è** già installato, ma per verificare è possibile eseguire:


```
dnf install vsftpd openssl
```

Inoltre, vorrai abilitare il servizio vsftpd:

```
systemctl enable vsftpd
```

Non avviate ancora il servizio.

## Configurazione di `vsftpd`

Si vuole garantire la disabilitazione di alcune impostazioni e l'abilitazione di altre. In genere, l'installazione di `vsftpd` include le opzioni più corrette già impostate. Tuttavia, è comunque una buona idea verificarle.

Per controllare il file di configurazione e apportare le modifiche necessarie, eseguire:

```
vi /etc/vsftpd/vsftpd.conf
```

Cercare la riga "anonymous_enable=" e assicurarsi che sia "NO" e che sia **NON** commentata. (Commentando questa riga si abilitano i login anonimi).  La riga somiglierà a questa, quando corretta:

```
anonymous_enable=NO
```

Assicurarsi che "local_enable" sia yes:

```
local_enable=YES
```

Aggiungere una riga per l'utente root locale. Se il server è un server web e si utilizza il file [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), la root locale lo rifletterà. Se la tua configurazione è differente, o se questo non è un server web, regola l'impostazione "local_root":

```
local_root=/var/www/sub-domains
```

Assicurati che anche "write_enable" sia impostata a YES:

```
write_enable=YES
```

Trova la riga "chroot_local_users" e rimuovi il commento. Aggiungere due righe dopo quella mostrata qui:

```
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
```

Al di sotto di questa si vuole aggiungere una sezione che si occuperà degli utenti virtuali:

```
# Virtual User Settings
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=vsftpd
guest_username=vsftpd
```

È necessario aggiungere una sezione in fondo al file per forzare la crittografia delle password inviate via Internet. È necessario installare `openssl` e creare il file del certificato anche per questo.

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

Salvare la configurazione. (<kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd> per `vi`.)

## Impostazione del Certificato Rsa

È necessario creare il file del certificato RSA di `vsftpd`. L'autore, solitamente, immagina che un server vada bene per 4 o 5 anni. Impostare il numero di giorni per questo certificato in base al numero di anni in cui si ritiene che il server sarà attivo e funzionante su questo hardware.

Modificare il numero di giorni come si ritiene opportuno e utilizzare il formato di questo comando per creare i file del certificato e della chiave privata:

```
openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.pem
```

Come tutti i processi di creazione di certificati, si avvia uno script che richiede alcune informazioni. Non è un processo difficile. Molti campi verranno lasciati in bianco.

Il primo campo è quello del codice paese, da compilare con il codice a due lettere del vostro paese:

```
Country Name (2 letter code) [XX]:
```

Poi viene lo stato o la provincia, da compilare digitando il nome intero, non l'abbreviazione:

```
State or Province Name (full name) []:
```

Il prossimo è il nome della località. Questa è la tua città:

```
Locality Name (eg, city) [Default City]:
```

Poi c'è il nome dell'azienda o dell'organizzazione. Si può lasciare in bianco o compilare. È facoltativo:

```
Organization Name (eg, company) [Default Company Ltd]:
```

Il prossimo è il nome dell'unità organizzativa. È possibile compilare questo campo se il server è per una divisione specifica, oppure lasciarlo vuoto:

```
Organizational Unit Name (eg, section) []:
```

Il campo seguente deve essere compilato, ma potete decidere voi come farlo. Questo è il nome comune del tuo server. Esempio: `webftp.domainname.ext`:

```
Common Name (eg, your name or your server's hostname) []:
```

Il campo dell'email può essere lasciato vuoto:

```
Email Address []:
```

Una volta terminato, si verificherà la creazione del certificato.

## <a name="virtualusers"></a>Impostazione utenti virtuali

Come già detto, l'uso di utenti virtuali per `vsftpd` è molto più sicuro perché non hanno privilegi di sistema. Detto questo, è necessario aggiungere un utente da utilizzare per gli utenti virtuali. È inoltre necessario aggiungere un gruppo:

```
groupadd nogroup
useradd --home-dir /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
```

L'utente deve corrispondere alla riga `guest_username=` nel file `vsftpd.com`.

Andare alla directory di configurazione di `vsftpd`:

```
cd /etc/vsftpd
```

È necessario creare un database di password. Questo database viene utilizzato per autenticare i nostri utenti virtuali. È necessario creare un file per leggere gli utenti virtuali e le password. Questo creerà il database.

In futuro, quando si aggiungeranno utenti, si dovrà ripetere questa procedura:

```
vi vusers.txt
```

L'utente e la password sono separati da una riga; inserire l'utente, premere <kbd>INVIO</kbd> e inserire la password. Continuate fino a quando non avrete aggiunto tutti gli utenti a cui volete dare accesso al sistema. Esempio:

```
user_name_a
user_password_a
user_name_b
user_password_b
```

Una volta creato il file di testo, si vuole generare il database delle password che `vsftpd` utilizzerà per gli utenti virtuali. Per farlo, utilizzare il comando `db_load`. `db_load` è fornito da `libdb-utils` che dovrebbe essere caricato sul vostro sistema, ma se non lo è, potete semplicemente installarlo con:

```
dnf install libdb-utils
```

Creare il database dal file di testo con:

```
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db
```

 Prendetevi un momento per rivedere cosa fa `db_load`:


* L'opzione -T consente di importare un file di testo nel database
* L'opzione -t dice di specificare il metodo di accesso sottostante.
* Il _hash_ è il metodo di accesso sottostante che si sta specificando
* L'opzione -f indica di leggere da un file specificato.
* Il file specificato è _vusers.txt_.
* Il database che si sta creando o aggiungendo è _vsftpd-virtual-user.db_

Modificare i permessi predefiniti del file del database:

```
chmod 600 vsftpd-virtual-user.db
```

Rimuovere il file "vusers.txt":

```
rm vusers.txt
```

Quando si aggiungono gli utenti, usare `vi` per creare un altro file "vusers.txt" e rieseguire il comando `db_load`, che aggiungerà gli utenti al database.

## Impostazione PAM

`vsftpd` installa un file pam predefinito quando si installa il pacchetto. Sostituirete il tutto con i vostri contenuti.  **Eseguire sempre** una copia di backup del vecchio file.

Creare una directory per il file di backup in /root:

```
mkdir /root/backup_vsftpd_pam
```

Copiare il file pam in questa directory:

```
cp /etc/pam.d/vsftpd /root/backup_vsftpd_pam/
```

Modifica del file originale:

```
vi /etc/pam.d/vsftpd
```

Rimuovete tutto quello che c'è in questo file tranne "#%PAM-1.0" e aggiungete le righe seguenti:

```
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```

Salvare le modifiche e uscire (<kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd> in `vi`).

Questo abilita il login per gli utenti virtuali definiti in `vsftpd-virtual-user.db` e disabilita i login locali.

## Impostazione della configurazione dell'utente virtuale

Ogni utente virtuale ha un proprio file di configurazione, che specifica la propria directory "local_root". La proprietà di questa radice locale è dell'utente "vsftpd" e del gruppo "nogroup".

Fare riferimento alla sezione [Impostazione degli utenti virtuali di cui sopra.](#virtualusers) Per cambiare la proprietà della directory, immettere questo alla riga di comando:

```
chown vsftpd.nogroup /var/www/sub-domains/whatever_the_domain_name_is/html
```

È necessario creare il file che contiene la configurazione dell'utente virtuale:

```
mkdir /etc/vsftpd/vsftpd_user_conf
vi /etc/vsftpd/vsftpd_user_conf/username
```

Questo, conterrà una singola riga che specifica la "local_root" dell'utente virtuale:

```
local_root=/var/www/sub-domains/com.testdomain/html
```

La specifica di questo percorso si trova nella sezione "Virtual User" del file `vsftpd.conf`.

## Avvio di `vsftpd`

Avviare il servizio `vsftpd` e testare gli utenti, supponendo che il servizio si avvii correttamente:

```
systemctl restart vsftpd
```

### Test di `vsftpd`

È possibile testare la configurazione con la riga di comando su un computer e verificare l'accesso al computer con FTP. Detto questo, il modo più semplice per effettuare un test è quello di provare con un client FTP, come [FileZilla](https://filezilla-project.org/).

Quando si esegue il test con un utente virtuale sul server che esegue `vsftpd`, si ottiene un messaggio di fiducia del certificato SSL/TLS. Questo messaggio di fiducia comunica alla persona che il server utilizza un certificato e le chiede di approvarlo prima di continuare. Quando si è connessi come utente virtuale, è possibile inserire i file nella cartella "local_root".

Se non si riesce a caricare un file, potrebbe essere necessario tornare indietro e verificare nuovamente tutti i passaggi. Ad esempio, potrebbe accadere che i permessi di proprietà per "local_root" non siano impostati sull'utente "vsftpd" e sul gruppo "nogroup".

## Conclusione

`vsftpd` è un server FTP popolare e comune e può essere un server indipendente o parte di un [Apache Hardened Web Server](../web/apache_hardened_webserver/index.md). È abbastanza sicuro se impostato per utilizzare utenti virtuali e un certificato.

Questa procedura prevede molti passaggi per l'impostazione di `vsftpd`. Dedicando un po' di tempo in più alla sua corretta configurazione, il vostro server sarà il più sicuro possibile.
