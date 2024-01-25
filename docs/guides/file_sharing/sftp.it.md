---
title: Server sicuro - sftp
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - file transfer
  - sftp
  - ssh
  - web
  - multisite
---

# Server sicuro - SFTP con procedure di blocco SSH

## Introduzione

Quando il protocollo SSH stesso è sicuro, può sembrare strano avere un documento dedicato all'uso "sicuro" di SFTP (una parte del pacchetto openssh-server). Ma la maggior parte degli amministratori di sistema non vuole aprire SSH a tutti per implementare SFTP per tutti. Questo documento descrive l'implementazione di un jail di change root (**chroot**) per SFTP che limita l'accesso a SSH.

Molti documenti trattano la creazione di un jail chroot SFTP, ma la maggior parte non considera un caso d'uso in cui l'utente potrebbe accedere a una directory web su un server con molti siti web. Questo documento se ne occupa. Se questo non è il vostro caso d'uso, potete adattare rapidamente questi concetti a situazioni diverse.

L'autore ritiene inoltre che sia necessario, nel redigere il documento sul jail chroot per SFTP, discutere anche delle altre cose che dovreste fare come amministratori di sistema per ridurre al minimo l'obiettivo che offrite al mondo tramite SSH. Per questo motivo, il presente documento è suddiviso in quattro parti:

1. La prima riguarda le informazioni generali che verranno utilizzate per l'intero documento.
2. Il secondo riguarda la configurazione di chroot. Se vi fermate qui è una scelta che spetta a voi.
3. La terza parte riguarda l'impostazione dell'accesso SSH a chiave pubblica/privata per gli amministratori di sistema e la disattivazione dell'autenticazione remota basata su password.
4. La quarta e ultima sezione di questo documento tratta la disattivazione dei login di root da remoto.

Tutti questi passaggi vi permetteranno di offrire un accesso SFTP sicuro ai vostri clienti, riducendo al minimo la possibilità che un malintenzionato comprometta la porta 22 (quella riservata all'accesso SSH).

!!! Note "chroot jails per i principianti:"

    le jail di chroot sono un modo per limitare le attività di un processo e di tutti i suoi vari processi figli sul computer. Consente di scegliere una directory o una cartella specifica sul computer e di renderla la directory "principale" per qualsiasi processo o programma.
    
    Da quel momento in poi, quel processo o programma può accedere *solo* a quella cartella e alle sue sottocartelle.

!!! tip "Aggiornamenti per Rocky Linux 8.x e 9.x"

    Questo documento è stato aggiornato per includere le nuove modifiche apportate dalla versione 8.6 che renderanno questa procedura ancora più sicura. Se si utilizza la versione 8.6 o più recente, o una qualsiasi versione della 9.x, questa procedura dovrebbe funzionare. Le sezioni specifiche per Rocky Linux 8.5 sono state rimosse, in quanto l'attuale versione di 8 (8.8 al momento della riscrittura) dovrebbe essere al punto in cui si trova qualsiasi versione di 8.x dopo l'aggiornamento dei pacchetti.

## Parte 1: Informazioni generali

### Presupposti e convenzioni

I presupposti sono che:

* si è a proprio agio nell'eseguire i comandi dalla riga di comando.
* si può usare un editor a riga di comando, come `vi` (usato qui), `nano`, `micro`, ecc.
* si conoscono i comandi di base di Linux utilizzati per l'aggiunta di gruppi e utenti, o si è in grado di seguirli bene.
* il vostro sito web multisito è come questo: [Apache Multi Sito](../web/apache-sites-enabled.md)
* avete già installato `httpd` (Apache) sul server.

!!! note "Nota"

    Questi concetti possono essere applicati a qualsiasi server e a qualsiasi demone web. Anche se qui si ipotizza Apache, si può usare anche per Nginx.

### Siti, utenti, amministratori

Si tratta di scenari fittizi. Qualsiasi somiglianza con persone o siti reali è puramente casuale:

**Siti:**

* mybrokenaxel = (site1.com) user = mybroken
* myfixedaxel = (site2.com) user = myfixed

**Amministratori**

* Steve Simpson = ssimpson
* Laura Blakely = lblakely

## Parte 2: SFTP chroot jail

### Installazione

L'installazione non è difficile. È sufficiente avere installato `openssh-server`, che probabilmente è già installato. Inserisci questo comando per essere sicuro:

```
dnf install openssh-server
```

### Impostazione

#### Directories

La struttura del percorso della directory sarà `/var/www/sub-domains/[ext.domainname]/html` e la directory `html` in questo percorso sarà la chroot jail per l'utente SFTP.

Creare le directory di configurazione:

```
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
```

Creare le directory web:

```
mkdir -p /var/www/sub-domains/com.site1/html
mkdir -p /var/www/sub-domains/com.site2/html
```
La proprietà di queste directory verrà gestita in seguito nell'applicazione di script.

### Configurazione `httpd`

È necessario modificare il file integrato `httpd.conf` per fargli caricare i file di configurazione nella directory `/etc/httpd/sites-enabled`. Per farlo, aggiungete una riga in fondo al file `httpd.conf`.

Modificare il file con l'editor preferito. L'autore utilizza `vi` qui:

```
vi /etc/httpd/conf/httpd.conf
```

e aggiungere questo in fondo al file:

```
Include /etc/httpd/sites-enabled
```

Salvare il file e uscire.

### Configurazione del sito web

È necessario creare due siti. Si creeranno le configurazioni in `/etc/httpd/sites-available` e si collegheranno a `../sites-enabled`:

```
vi /etc/httpd/sites-available/com.site1
```

!!! note "Nota"

    L'esempio utilizza solo il protocollo HTTP. Qualsiasi sito web reale necessita della configurazione del protocollo HTTPS, dei certificati SSL e di molto altro ancora.

```
<VirtualHost *:80>
        ServerName www.site1.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site1/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site1.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site1.www-error_log"

        <Directory /var/www/sub-domains/com.site1/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
Salva questo file ed esci.

```
vi /etc/httpd/sites-available/com.site2
```

```
<VirtualHost *:80>
        ServerName www.site2.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site2/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site2.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site2.www-error_log"

        <Directory /var/www/sub-domains/com.site2/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
Salvare il file e uscire.

Una volta terminata la creazione dei due file di configurazione, collegarli all'interno di `/etc/httpd/sites-enabled`:

```
ln -s ../sites-available/com.site1
ln -s ../sites-available/com.site2
```
Abilitare e avviare il processo `httpd`:

```
systemctl enable --now httpd
```

### Creazione dell'utente

Per il nostro ambiente di esempio, si presume che nessuno degli utenti sia ancora esistente. Iniziate dagli utenti amministrativi. A questo punto del processo, è ancora possibile accedere come utente root per aggiungere gli altri utenti e configurarli nel modo desiderato. Quando gli utenti sono stati configurati e testati, è possibile rimuovere i login di root.

#### Amministratori

```
useradd -g wheel ssimpson
useradd -g wheel lblakely
```
Aggiungendo i nostri utenti al gruppo "wheel" si concede loro l'accesso `sudo`.

È comunque necessaria una password per l'accesso `sudo`. Ci sono modi per aggirare questo problema, ma nessuno è così sicuro. Francamente, se avete problemi di sicurezza usando `sudo` sul vostro server, allora avete problemi molto più grandi con la vostra intera configurazione. Impostare le due password amministrative con password sicure:

```
passwd ssimpson
Changing password for user ssimpson.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

passwd lblakely
Changing password for user lblakely.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

Testate l'accesso al server con `ssh` per i due utenti amministrativi. Dovreste essere in grado di:

* utilizzare `ssh` per accedere come uno degli utenti amministrativi del server. (Esempio: `ssh lblakely@192.168.1.116` o `ssh lblakely@mywebserver.com`)
* si dovrebbe poter accedere a root con `sudo -s` inserendo la password dell'utente amministrativo.

Se questo funziona per tutti gli utenti amministrativi, sarete pronti per la fase successiva.

#### Utenti web (SFTP)

È necessario aggiungere i nostri utenti web. La struttura della cartella `../html` esiste già, quindi non si vuole crearla quando si aggiunge l'utente, ma *si vuole* specificarla. Inoltre, non si vuole effettuare alcun login se non con SFTP, quindi è necessario utilizzare una shell che neghi i login.

```
useradd -M -d /var/www/sub-domains/com.site1/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.site2/html -g apache -s /usr/sbin/nologin myfixed
```

Scomponiamo un po' questi comandi:

* L'opzione `-M` dice di *non* creare la directory home standard per l'utente.
* `-d` specifica che ciò che viene dopo è la directory *effettiva*.
* `-g` dice che il gruppo a cui appartiene questo utente è `apache`.
* `-s` dice che la shell assegnata è `/usr/sbin/nologin`
* Alla fine si trova il nome utente effettivo dell'utente.

**Nota:** Per un server Nginx, si usa `nginx` come gruppo.

I nostri utenti SFTP hanno ancora bisogno di password. Impostare una password sicura per ciascuno di essi. L'output del comando è già stato visualizzato sopra:

```
passwd mybroken
passwd myfixed
```

### Configurazione SSH

!!! warning "Attenzione"

    Prima di iniziare questo processo, si consiglia di fare un backup del file di sistema che si intende modificare: `/etc/ssh/sshd_config`. La compromissione di questo file e l'impossibilità di tornare all'originale potrebbero causare un sacco di problemi!

    ```
    vi /etc/ssh/sshd_config
    ```

È necessario apportare una modifica al file `/etc/ssh/sshd_config`. Si costruirà un modello per apportare le modifiche alla cartella web al di fuori del file di configurazione e si scriveranno le aggiunte necessarie.

Per prima cosa, effettuare la modifica manuale necessaria:

```
vi /etc/ssh/sshd_config
```

In fondo al file si trova questo:

```
# override default of no subsystems
Subsystem     sftp    /usr/libexec/openssh/sftp-server
```

Si desidera modificare il testo come segue:

```
# override default of no subsystems
# Subsystem     sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```
Salvare e uscire dal file.

Il `sftp-server` e l'`internal-sftp` fanno parte di OpenSSH. L'`internal-sftp`, pur non essendo molto diverso dallo `sftp-server`, semplifica le configurazioni usando `ChrootDirectory` per forzare una diversa root del file system sui client. Ecco perché si usa `internal-sftp`.

### Il template e lo script

Perché state creando un modello e uno script per la parte successiva? Il motivo è evitare il più possibile l'errore umano. Non avete ancora finito di modificare il file `/etc/ssh/sshd_config`, ma volete eliminare il maggior numero possibile di errori ogni volta che dovete fare queste modifiche. Tutto questo verrà creato in `/usr/local/sbin`.

#### Il template

Per prima cosa, create il vostro template:

```
vi /usr/local/sbin/sshd_template
```

Questo template avrà le seguenti caratteristiche:

```
Match User replaceuser
  PasswordAuthentication yes
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```

!!! note "Nota"

    La `PasswordAuthentication yes` non è normalmente richiesta per il jail chroot. Tuttavia, in seguito si disattiverà `PasswordAuthentication` per tutti gli altri, quindi è essenziale avere questa riga nel template.

Si vuole anche una cartella per i file utente che verranno creati dal template:

```
mkdir /usr/local/sbin/templates
```


#### Lo script e le modifiche di `sshd_config`

Con i rilasci di Rocky Linux 8.6 e 9.0, una nuova opzione per il file `sshd_config` consente di effettuare configurazioni drop-in. Si tratta di un **GRANDE** cambiamento. Ciò significa che si apporterà una singola modifica aggiuntiva al file `sshd_config` e il nostro script costruirà le modifiche a sftp in un file di configurazione separato. Questa nuova modifica rende le cose ancora più sicure. La sicurezza è buona!!

Grazie alle modifiche introdotte per il file `sshd_config` in Rocky Linux 8.6 e 9.0, il nostro script utilizzerà un nuovo file di configurazione: `/etc/ssh/sftp/sftp_config`.

Per iniziare, creare la directory:

```
mkdir /etc/ssh/sftp
```

Ora fate una copia di backup di `sshd_config`:

```
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Infine, modificate il file `sshd_config`, scorrete fino in fondo al file e aggiungete questa riga:

```bash
Include /etc/ssh/sftp/sftp_config
```

Salvare le modifiche e uscire dal file. È necessario riavviare `sshd`, ma il nostro script lo farà per noi dopo aver aggiornato il file `sftp_config`, quindi create lo script ed eseguitelo.

```
vi /usr/local/sbin/webuser
```

E inserite questo codice:

```
#!/bin/bash
    # script to populate the SSHD configuration for web users.

    # Set variables

    tempfile="/usr/local/sbin/sshd_template"
    dompath="/var/www/sub-domains/"

    # Prompt for user and domain in reverse (ext.domainname):

    clear

    echo -n "Enter the web sftp user: "
    read sftpuser
    echo -n "Enter the domain in reverse. Example: com.domainname: "
    read dom
    echo -n "Is all of this correct: sftpuser = $sftpuser and domain = $dom (Y/N)? "
    read yn
    if [ "$yn" = "n" ] || [ "$yn" = "N" ]
    then
        exit
    fi
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]
    then
        /usr/bin/cat $tempfile > /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replaceuser,$sftpuser,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replacedirectory,$dompath$dom,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/chown -R $sftpuser.apache $dompath$dom/html
        # Ensure directory permissions are correct
        # The root user owns all directories except the chroot, which is owned by the sftpuser
        # when connecting, you will end up one directory down, and you must actually change to the html directory
        # With a graphical SFTP client, this will be visible to you, you just need to double-click on the html 
        # directory before attmpting to drop in files.
        chmod 755 $dompath
        chmod 755 $dompath$dom
        chmod 755 $dompath$dom/html
        chmod 744 -R $dompath$dom/html/
    fi

    ## Make a backup of /etc/ssh/sftp/sftp_config

    /usr/bin/rm -f /etc/ssh/sftp/sftp_config.bak

    /usr/bin/cp /etc/ssh/sftp/sftp_config /etc/ssh/sftp/sftp_config.bak

    ## Now append our new user information to to the file

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sftp/sftp_config

    ## Restart sshd

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added by doing a more of the sftp_config"
    echo "A backup of the working sftp_config was created when this script was run: sftp_config.bak"
```

### Modifiche finali e note sullo script

!!! tip "Suggerimento"

    Se si dà un'occhiata allo script qui sopra, si noterà il cambiamento del delimitatore che `sed` usa di default da `/` a `,`. `sed` consente di utilizzare qualsiasi carattere a singolo byte come delimitatore. Il file che si sta cercando contiene una serie di caratteri "/" e per cercare e sostituire queste stringhe è necessario eseguire l'escape di ciascuno di essi (aggiungendo una "\" davanti). Cambiare il delimitatore rende questa operazione infinitamente più semplice, perché elimina la necessità di eseguire gli escape.

Un paio di cose sono degne di nota sullo script e su una chroot SFTP in generale. In primo luogo, si richiedono le informazioni necessarie e le si ripropone all'utente per la verifica. Se si risponde "N" alla domanda di conferma, lo script si blocca e non fa nulla. Lo script per 8.5 crea un backup di `sshd_config` (`/etc/ssh/sshd_config.bak`) come era prima dell'esecuzione dello script. Lo script 8.6 o 9.0 fa lo stesso per il file `sftp_config` (`/etc/ssh/sftp/sftp_config.bak`). In questo modo, se si commettono errori in una voce, è possibile ripristinare il file di backup appropriato e riavviare `sshd` per far funzionare nuovamente le cose.

Il chroot SFTP richiede che il percorso indicato in `sshd_config` sia di proprietà di root. Per questo motivo, non è necessario aggiungere la cartella `html` alla fine del percorso. Una volta che l'utente si è autenticato, il chroot cambierà la directory home dell'utente, in questo caso la directory `../html`, con il dominio inserito. Il vostro script ha opportunamente cambiato il proprietario della directory `../html` con l'utente sftp e il gruppo apache.

Rendere lo script eseguibile:

```
chmod +x /usr/local/sbin/webuser
```

Eseguire lo script per i due domini di prova.

### Verifica del rifiuto di SSH e dell'accesso SFTP

Per prima cosa, eseguire un test con `ssh` da un'altra macchina alla nostra macchina host come uno degli utenti SFTP. Si dovrebbe ricevere questo messaggio dopo aver inserito la password:

```
This service allows sftp connections only.
```
#### Test con strumenti grafici

Se *ricevete* questo messaggio, la prossima cosa da fare è testare l'accesso SFTP. Per facilitare i test, è possibile utilizzare un'applicazione FTP grafica che supporti SFTP, come Filezilla. In questi casi, i campi avranno un aspetto simile a questo:

* **Host:** sftp://hostname_o_IP_del_server
* **Username:** (Esempio: myfixed)
* **Password:** (la password dell'utente SFTP)
* **Port:** Se si utilizzano SSH e SFTP sulla porta 22 predefinita, immettere tale porta

Una volta compilato, si può fare clic sul pulsante "Quickconnect" (Filezilla) e ci si collegherà alla directory `../html` del sito appropriato. Fare doppio clic sulla directory "html" per posizionarsi al suo interno e provare a inviare un file nella directory. Se il risultato è positivo, tutto funziona correttamente.

#### Test con strumenti a riga di comando

È possibile eseguire tutte queste operazioni dalla riga di comando su una macchina con SSH installato (la maggior parte delle installazioni Linux). Ecco una breve panoramica del metodo di connessione da riga di comando e di alcune opzioni:

* sftp username (Esempio: myfixed@ hostname o IP del server: sftp myfixed@192.168.1.116)
* Immettere la password quando viene richiesta
* cd html (passare alla directory html)
* pwd (dovrebbe mostrare che ci si trova nella directory html)
* lpwd (dovrebbe mostrare la directory di lavoro locale)
* lcd PATH (dovrebbe cambiare la propria directory di lavoro locale in qualcosa che si vuole utilizzare)
* put filename (copierà un file nella directory `..html`.)

Per un elenco esaustivo delle opzioni e altro ancora, consultare la pagina del manuale [SFTP](https://man7.org/linux/man-pages/man1/sftp.1.html).

### File di test per il web

Per i nostri domini fittizi, vogliamo creare un paio di file `index.html` con cui popolare la directory `../html`. Una volta creati, è necessario inserirli nella directory di ciascun dominio con le credenziali SFTP di quel dominio. Questi file sono semplicistici. Si vuole solo verificare che i siti siano attivi e funzionanti e che SFTP funzioni come previsto. Ecco un esempio di questo file. Se lo si desidera, è possibile modificarlo:

```
<!DOCTYPE html>
<html>
<head>
<title>My Broken Axel</title>
</head>
<body>

<h1>My Broken Axel</h1>
<p>A test page for the site.</p>

</body>
</html>
```

### Test sul web

È necessario modificare il file _hosts_ sulla propria workstation per verificare che questi file vengano visualizzati e caricati come previsto. Per Linux sarà `sudo vi /etc/hosts` e aggiungete gli IP e i nomi degli host con cui state facendo i test in questo modo:

```
127.0.0.1   localhost
192.168.1.116   www.site1.com site1.com
192.168.1.116   www.site2.com site2.com
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

!!! tip "Suggerimento"

    Per i domini reali, si consiglia di popolare i server DNS con gli host di cui sopra. Tuttavia, è possibile utilizzare questo *Poor Man's DNS* per testare qualsiasi dominio, anche se non è stato attivato sui server DNS reali.

Aprite il browser web e assicuratevi che il file `index.html` per ogni dominio venga visualizzato inserendo l'URL nella barra degli indirizzi del browser. (Esempio: "http://site1.com") Se i file index di prova vengono caricati, tutto funziona correttamente.

## Parte 3: Accesso amministrativo con coppie di chiavi SSH

Si noti che qui si utilizzeranno i concetti discussi nel documento [SSH Public and Private Keys](../security/ssh_public_private_keys.md), migliorandoli però. Se siete alle prime armi, leggete quell'articolo prima di continuare.

### Creazione delle coppie di chiavi pubbliche/private

Dalla riga di comando di una delle stazioni di lavoro dell'utente amministrativo (esempio: lblakely), eseguire le seguenti operazioni:

```
ssh-keygen -t rsa
```

Che vi darà questo risultato:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/lblakely/.ssh/id_rsa):
```

Premete invio per creare la chiave privata nella posizione indicata. Si aprirà questa finestra di dialogo:

```
Enter passphrase (empty for no passphrase):
```

Dovrete decidere personalmente se avete bisogno di una passphrase per questo passaggio. L'autore si limita sempre a premere invio qui.

```
Enter same passphrase again:
```

Ripetere la passphrase immessa in precedenza o non immetterla.

A questo punto esistono le chiavi pubbliche e private. Ripetete questo passaggio per l'altro utente amministratore di sistema di esempio.

### Trasferimento della chiave pubblica al server SFTP

Il passo successivo consiste nell'esportare la nostra chiave sul server. In realtà, un amministratore di sistema responsabile della gestione di più server trasferirà la propria chiave pubblica a tutti i server di cui è responsabile.

L'utente può inviare la chiave al server in modo sicuro con `ssh-id-copy` al momento della creazione:

```
ssh-id-copy lblakely@192.168.1.116
```

Il server richiederà una volta la password dell'utente e copierà la chiave in _authorized_keys_. Riceverete anche voi questo messaggio:

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lblakely@192.168.1.116'"
and check to make sure that only the key(s) you wanted were added.
```

Se si riesce ad accedere con questo account, ripetere la procedura con l'altro amministratore.

### Consentire SOLO login basati su chiavi

Se tutto ha funzionato come previsto e le chiavi per gli amministratori sono state inserite nel server SFTP, è necessario disattivare l'autenticazione tramite password sul server. Per sicurezza, assicuratevi di avere due connessioni al server per invertire qualsiasi modifica in caso di conseguenze indesiderate.

Per eseguire questo passaggio, è necessario modificare nuovamente `sshd_config` e, come in precedenza, è necessario eseguire prima un backup del file:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Quindi, modificare il file `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Si desidera disattivare le password con tunnel. Trovate questa riga nella configurazione:

```
PasswordAuthentication yes
```

Cambiatelo in "no" - notate che la semplice annotazione di questa riga fallirà, poiché l'impostazione predefinita è sempre "sì".

```
PasswordAuthentication no
```

L'autenticazione a chiave pubblica è attiva per impostazione predefinita, ma è bene assicurarsi che lo sia rimuovendo il commento davanti a questa riga:

```
#PubkeyAuthentication yes
```

In modo che si legga:

```
PubkeyAuthentication yes
```

Questo rende il nostro file `sshd_config` in qualche modo autodocumentante.

Salvare le modifiche. Incrociate le dita e riavviate `sshd`:

```
systemctl restart sshd
```

Il tentativo di accedere al server come uno degli utenti amministrativi utilizzando le loro chiavi dovrebbe funzionare come prima. In caso contrario, ripristinare il backup, assicurarsi di aver seguito tutti i passaggi e riprovare.

## Parte 4: Disattivare l'accesso root da remoto

In pratica l'avete già fatto. Se si tenta di accedere al server con l'utente root, si otterrà il seguente risultato:

```
root@192.168.1.116: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

Ma si vuole garantire che qualcuno non possa creare una chiave pubblica/privata per l'utente root e accedere così al server. A tal fine, è necessario un ultimo passo. Farete questo cambiamento... Avete indovinato! ... nel file `sshd_config`.

Come per tutti gli altri passaggi, quando si modifica il file `sshd_config`, è necessario fare una copia di backup del file prima di continuare:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Modificare `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Trovate questa linea:

```
PermitRootLogin yes
```

Cambiarlo in "no":

```
PermitRootLogin no
```

Salvate, uscite dal file e riavviate `sshd`:

```
systemctl restart sshd
```

Un accesso come utente root da remoto tramite `ssh` riceverà lo stesso messaggio di rifiuto di prima, ma **ancora** non sarà in grado di accedere al server anche se possiede una coppia di chiavi pubbliche/private per root.

## Addendum: Nuovi amministratori di sistema

Non è ancora stato discusso cosa succede quando si aggiunge un altro amministratore di sistema. `ssh-copy-id` non funziona con l'autenticazione tramite password disattivata. Ecco cosa consiglia l'autore in queste situazioni. Si noti che esiste più di una soluzione. Oltre ai metodi qui menzionati, un amministratore esistente può generare e distribuire le chiavi per un altro amministratore.

### Soluzione uno - sneaker net

Questa soluzione presuppone l'accesso fisico al server e che il server sia hardware fisico e non virtuale (container o VM):

* Aggiungere l'utente al gruppo "wheel" sul server SFTP
* Chiedete all'utente di generare le sue chiavi pubbliche e private SSH
* Utilizzando un'unità USB, copiate la chiave pubblica sull'unità, portatela fisicamente sul server e installatela manualmente nella directory del nuovo amministratore di sistema `/home/[nomeutente]/.ssh`

### Soluzione due - modifica temporanea di `sshd_config`

Questa soluzione è soggetta all'errore umano, ma poiché non è praticata spesso, è probabilmente accettabile se eseguita con cura:

* Aggiungere l'utente al gruppo "wheel" sul server SFTP
* Chiedete a un altro amministratore di sistema, che ha già un'autenticazione basata su chiavi, di attivare temporaneamente "PasswordAuthentication yes" nel file `sshd_config` e di riavviare `sshd`
* Chiedete al nuovo amministratore di sistema di eseguire `ssh-copy-id` utilizzando la propria password per copiare la chiave ssh sul server.

### Soluzione tre - script del processo

Questo processo utilizza un amministratore di sistema che ha già un accesso basato su chiavi e uno script che deve essere eseguito con `bash [nome-script]` per ottenere lo stesso risultato della "Soluzione due" di cui sopra:

* modificare manualmente il file `sshd_config` e rimuovere la riga rimarcata che assomiglia a questa: `#PasswordAuthentication no`. Questa riga documenta il processo di disattivazione dell'autenticazione tramite password, ma sarà d'intralcio allo script sottostante, perché il nostro script cercherà la prima occorrenza di `PasswordAuthentication no` e successivamente la prima occorrenza di `PasswordAuthentication yes`. Se si rimuove questa riga, lo script funzionerà correttamente.
* creare uno script sul server SFTP chiamato "quickswitch", o come lo si vuole chiamare. Il contenuto di questo script è il seguente:

```
#!/bin/bash
# for use in adding a new system administrator

/usr/bin/cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

/usr/bin/sed -i '0,/PasswordAuthentication no/ s/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Have the user send his keys, and then hit enter."
read yn
/usr/bin/sed -i '0,/PasswordAuthentication yes/ s/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Changes reversed"
```
Spiegazione dello script: Non rendere questo script eseguibile. Il motivo è che non si vuole che venga eseguito accidentalmente. Lo script viene eseguito (come indicato sopra) in questo modo: `bash /usr/local/sbin/quickswitch`. Questo script crea una copia di backup del file `sshd_config` proprio come tutti gli altri esempi precedenti. Quindi modifica il file `sshd_config` esistente e cerca nel file la *PRIMA* presenza di `PasswordAuthentication no` e la modifica in `PasswordAuthentication yes` quindi riavvia `sshd` e attende che l'utente dello script prema <kbd>INVIO</kbd> prima di proseguire. L'amministratore di sistema che esegue lo script sarebbe in comunicazione con il nuovo amministratore di sistema e, una volta che quest'ultimo esegue `ssh-copy-id` per copiare la sua chiave sul server, l'amministratore di sistema che sta eseguendo lo script preme invio e inverte la modifica.

In breve, esistono molti modi per aggiungere un altro amministratore di sistema dopo l'implementazione delle procedure di blocco SSH.

## Conclusione

Questo documento è molto esteso. Rende un server web multisito più sicuro e meno soggetto a vettori di attacco su SSH quando si attiva SFTP per l'accesso dei clienti. SFTP è molto più sicuro di FTP, anche se si usa un server FTP veramente *BUONO* e lo si configura nel modo più sicuro possibile, come indicato in questo [documento su VSFTPD](secure_ftp_server_vsftpd.md). Implementando *tutti* i passaggi di questo documento, potrete sentirvi tranquilli nell'aprire la porta 22 (SSH) alla vostra zona pubblica, sapendo che il vostro ambiente è sicuro.
