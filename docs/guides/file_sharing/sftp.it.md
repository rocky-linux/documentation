---
title: Server sicuro - sftp
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - file transfer
  - sftp
  - ssh
  - web
  - multisite
---

# Server sicuro - SFTP con procedure SSH Lock Down

## Introduzione

Può sembrare strano avere un documento dedicato all'uso "sicuro" di SFTP (una parte del pacchetto openssh-server) quando il protocollo SSH è di per sé sicuro. Capisco cosa state pensando. Ma la maggior parte degli amministratori di sistema non vuole aprire SSH a tutti per implementare SFTP per tutti. Questo documento descrive come implementare una change root jail<sup>1</sup> modificata per SFTP mantenendo l'accesso SSH limitato.

Esistono molti documenti che trattano la creazione di una SFTP change root jail, ma la maggior parte non tiene conto di un caso d'uso in cui l'utente impostato accede a una directory web su un server con più siti web. Il presente documento si occupa di questo. Se questo non è il vostro caso d'uso, potete facilmente adattare questi concetti per utilizzarli in situazioni diverse.

L'autore ritiene inoltre che sia necessario, nell'ambito della modifica del documento di change root jail per SFTP, discutere anche delle altre cose che dovreste fare come amministratori di sistema per ridurre al minimo l'obiettivo che offrite al mondo tramite SSH. Per questo motivo, il presente documento è suddiviso in quattro parti:

1. La prima riguarda le informazioni generali che utilizzeremo per l'intero documento.
2. La seconda si occupa della configurazione della change root jail e se si decide di fermarsi qui, è una decisione che spetta a voi.
3. La terza parte riguarda l'impostazione dell'accesso SSH a chiave pubblica/privata per gli amministratori di sistema e la disattivazione dell'autenticazione remota basata su password.
4. La quarta e ultima sezione di questo documento riguarda la disattivazione del login di root da remoto.

L'adozione di tutte queste misure vi consentirà di offrire ai vostri clienti un accesso SFTP sicuro, riducendo al contempo al minimo la possibilità che la porta 22 (quella riservata all'accesso SSH) venga compromessa da un malintenzionato.

!!! Nota "<sup>1</sup> Change root jails per principianti:"

    Le jail di change root (o chroot) sono un modo per limitare le attività di un processo e di tutti i suoi vari processi figli sul computer. Consente essenzialmente di scegliere una directory/cartella specifica sul computer e di renderla la directory "radice" per qualsiasi processo o programma.
    
    Da quel momento in poi, quel processo o programma può accedere *solo* a quella cartella e alle sue sottocartelle.

!!! tip "Aggiornamenti per Rocky Linux 8.6"

    Questo documento è stato aggiornato per includere le nuove modifiche introdotte con la versione 8.6, che renderanno questa procedura ancora più sicura. Se si utilizza la versione 8.6, il documento contiene sezioni specifiche, precedute da "8.6 -". Per chiarezza, le sezioni specifiche di Rocky Linux 8.5 sono state precedute da "8.5 - ". A parte le sezioni con prefisso specifico, questo documento è generico per entrambe le versioni del sistema operativo.

## Parte 1: Informazioni Generali

### Presupposti e Convenzioni

Partiamo dal presupposto che:

* si è a proprio agio nell'eseguire i comandi dalla riga di comando.
* si può usare un editor a riga di comando, come `vi` (usato qui), `nano`, `micro`, ecc.
* si conoscono i comandi di base di Linux utilizzati per l'aggiunta di gruppi e utenti, o si è in grado di seguirli bene.
* il vostro sito web multisito è impostato in questo modo: [Apache Multi Sito](../web/apache-sites-enabled.md)
* `httpd` (Apache) è già stato installato sul server.

!!! note "Nota"

    Questi concetti possono essere applicati a qualsiasi server e a qualsiasi demone web. Anche se qui si ipotizza Apache, si può sicuramente usare anche per Nginx.

### Siti, Utenti, Amministratori

Tutto è messo insieme qui. Qualsiasi somiglianza con persone o siti reali è puramente casuale:

**Siti:**

* mybrokenaxel = (site1.com) user = mybroken
* myfixedaxel = (site2.com) user = myfixed

**Amministratori**

* Steve Simpson = ssimpson
* Laura Blakely = lblakely

## Parte 2: SFTP Change Root Jail

### Installazione

L'installazione è semplice. Hai solo bisogno di avere openssh-server installato, che probabilmente è già installato. Inserisci questo comando per essere sicuro:

```
dnf install openssh-server
```

### Impostazione

#### Directories

* La struttura del percorso della directory sarà `/var/www/sottodomini/[ext.domainname]/html` e la directory `html` in questo percorso sarà la change root jail per l'utente SFTP.

Creazione delle directory di configurazione:

```
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
```

Creazione delle directory web:

```
mkdir -p /var/www/sub-domains/com.site1/html
mkdir -p /var/www/sub-domains/com.site2/html
```
Ci occuperemo delle proprietà di queste directory nell'applicazione di script che si trova di seguito.

### Configurazione `httpd`

Dobbiamo modificare il file `httpd.conf` integrato per fargli caricare i file di configurazione della directory `/etc/httpd/sites-enabled`. Questo viene fatto con una riga in fondo al file `httpd.conf`.

Modifica il file con il tuo editor preferito. Sto usando `vi` qui:

```
vi /etc/httpd/conf/httpd.conf
```
e aggiungere questo in fondo al file:

```
Include /etc/httpd/sites-enabled
```
Quindi salvare il file e uscire.

### Configurazione del Sito Web

We need two sites created. Creeremo le configurazioni in `/etc/httpd/sites-available` e poi le collegheremo a `../sites-enabled`:

```
vi /etc/httpd/sites-available/com.site1
```

!!! note "Nota"

    Stiamo utilizzando solo il protocollo HTTP per il nostro esempio. Qualsiasi sito web reale avrebbe bisogno di una configurazione del protocollo HTTPS, di certificati SSL e forse anche di altro.

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
Salva questo file ed esci.

Una volta creati i due file di configurazione, si può procedere a collegarli all'interno di `/etc/httpd/sites-enabled`:

```
ln -s ../sites-available/com.site1
ln -s ../sites-available/com.site2
```
Ora abilita e avvia il processo `httpd`:

```
systemctl enable --now httpd
```

### Creazione Utente

Per il nostro ambiente di esempio, assumiamo che nessuno degli utenti sia configurato. Cominciamo con i nostri utenti amministrativi. Si noti che a questo punto del processo, possiamo ancora accedere come utente root per aggiungere gli altri utenti e configurarli nel modo desiderato. Rimuoveremo i login di root una volta configurati e testati gli utenti.

#### Amministratori

```
useradd -g wheel ssimpson
useradd -g wheel lblakely
```
Aggiungendo i nostri utenti al gruppo "wheel", diamo loro l'accesso `sudo`.

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

Ora verificate l'accesso al server tramite ssh per i due utenti amministrativi. Dovreste essere in grado di:

* utilizzare `ssh` per accedere al server come uno degli utenti amministrativi. (Esempio: `ssh lblakely@192.168.1.116` o `ssh lblakely@mywebserver.com`)
* una volta che si accede al server, si dovrebbe essere in grado di accedere a root con `sudo -s` e inserendo la password dell'utente amministrativo.

Se questo funziona per entrambi gli utenti amministrativi, si dovrebbe essere pronti per passare alla fase successiva.

#### Utenti Web (SFTP)

Dobbiamo aggiungere i nostri utenti web. La struttura della cartella `../html` esiste già, quindi non vogliamo crearla quando aggiungiamo l'utente, ma *vogliamo* specificarla. Inoltre, non vogliamo effettuare alcun accesso se non tramite SFTP, quindi dobbiamo utilizzare una shell che neghi i login.

```
useradd -M -d /var/www/sub-domains/com.site1/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.site2/html -g apache -s /usr/sbin/nologin myfixed
```

Vediamo di scomporre un po' questi comandi:

* L'opzione `-M` dice di *non* creare la directory home standard per l'utente.
* `-d` specifica che ciò che viene dopo è la directory *effettiva*.
* `-g` dice che il gruppo a cui appartiene questo utente è `apache`.
* `-s` dice che la shell assegnata all'utente è `/usr/sbin/nologin`
* Alla fine si trova il nome utente effettivo dell'utente.

**Note:** Per un server Nginx, si usa `nginx` come gruppo.

Our SFTP users still need a password. Procediamo quindi con l'impostazione di una password sicura per ciascuno di essi. Poiché abbiamo già visto l'output del comando sopra, non lo ripeteremo qui:

```
passwd mybroken
passwd myfixed
```

### Configurazione SSH

!!! warning "Attenzione"

    Prima di iniziare questo processo, si raccomanda di fare un backup del file di sistema che modificheremo: `/etc/ssh/sshd_config`. La rottura di questo file e l'impossibilità di tornare all'originale potrebbero causare un sacco di problemi!

    ```
    vi /etc/ssh/sshd_config
    ```

Dobbiamo apportare una modifica al file `/etc/ssh/sshd_config` e poi costruiremo un template in modo da poter apportare le modifiche alla nostra directory web al di fuori del file di configurazione e scrivere le aggiunte di cui avremo bisogno.

Per prima cosa, apportiamo la modifica manuale necessaria:

```
vi /etc/ssh/sshd_config
```

In fondo al file si trova questo:

```
# override default of no subsystems
Subsystem     sftp    /usr/libexec/openssh/sftp-server
```

Vogliamo modificarlo come segue:

```
# override default of no subsystems
# Subsystem     sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```
Salvare e uscire dal file.

Come in precedenza, descriviamo un po' cosa stiamo facendo. Sia il `sftp-server` che `internal-sftp` fanno parte di OpenSSH. L'`internal-sftp`, pur non essendo molto diverso da `sftp-server`, semplifica le configurazioni usando `ChrootDirectory` per forzare una diversa root del file system sui client. Ecco perché vogliamo usare `internal-sftp`.

### Il Template e lo Script

Perché stiamo creando un template e uno script per questa parte successiva? Il motivo è semplicemente quello di evitare il più possibile l'errore umano. Non abbiamo ancora finito di modificare il file `/etc/ssh/sshd_config`, ma vogliamo eliminare il maggior numero possibile di errori ogni volta che dobbiamo fare queste modifiche. Creeremo tutto questo in `/usr/local/sbin`.

#### Il Template

In primo luogo, creiamo il nostro template:

```
vi /usr/local/sbin/sshd_template
```

Questo template dovrebbe avere le seguenti caratteristiche:

```
Match User replaceuser
  PasswordAuthentication yes
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```

!!! note "Nota"

    La `PasswordAuthentication yes` non è normalmente richiesta per il change root jail, ma in seguito verrà disattivata la `PasswordAuthentication` per tutti gli altri, quindi è importante che questa riga sia presente nel template.

Vogliamo una directory per i nostri file utente, che creeremo dal template:

```
mkdir /usr/local/sbin/templates
```


=== "8.6 & 9.0"

    #### 8.6 & 9.0 - Lo script e i cambiamenti di `sshd_config`
    
    Con i rilasci di Rocky Linux 8.6 e 9.0, è disponibile una nuova opzione per il file `sshd_config` che consente di inserire le configurazioni. Si tratta di un **GRANDE** cambiamento. Ciò significa che per queste versioni verrà apportata una singola modifica aggiuntiva al file `sshd_config` e poi il nostro script costruirà le modifiche a sftp in un file di configurazione separato. Questa nuova modifica rende le cose ancora più sicure. La sicurezza è buona!!
    
    A causa delle modifiche consentite per il file `sshd_config` in Rocky Linux 8.6 e 9.0, il nostro script utilizzerà un nuovo file di configurazione: `/etc/ssh/sftp/sftp_config`.
    
    Per iniziare, creare la directory:

    ```
    mkdir /etc/ssh/sftp
    ```


    Ora fate una copia di backup di `sshd_config`:

    ```
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```


    Infine, modificare il file `sshd_config`, scorrere fino alla fine del file e aggiungere questa riga:

    ```bash
    Include /etc/ssh/sftp/sftp_config
    ```


    Salvare le modifiche e uscire dal file. Dovremo riavviare `sshd` ma il nostro script lo farà per noi dopo aver aggiornato il file `sftp_config`, quindi creiamo lo script ed eseguiamolo.

    ```
    vi /usr/local/sbin/webuser
    ```


    E inserire questo codice:

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
=== "8.5"

    #### 8.5 - Lo script
    
    Ora creiamo il nostro script:

    ```
    vi /usr/local/sbin/webuser
    ```


    E inserire questo codice:

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
    fi

    ## Make a backup of /etc/ssh/sshd_config

    /usr/bin/rm -f /etc/ssh/sshd_config.bak

    /usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    ## Now append our new user information to the file

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sshd_config

    ## Restart sshd

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added to the sshd_config by doing a more of the sshd_config"
    echo "A backup of the working sshd_config was created when this script was run: sshd_config.bak"
    ```


### Modifiche finali e note sullo Script

!!! tip "Suggerimento"

    Se si dà un'occhiata a uno degli script precedenti, si noterà che abbiamo cambiato il delimitatore che `sed` usa di default da `/` a `,`. `sed` consente di utilizzare qualsiasi carattere a singolo byte come delimitatore. Quello che stiamo cercando nel file contiene una serie di caratteri "/" e avremmo dovuto fare l'escape di ciascuno di essi (aggiungendo una "\" davanti) per cercare e sostituire queste stringhe. Cambiare il delimitatore rende questa operazione infinitamente più semplice, perché elimina la necessità di eseguire gli escape.

Un paio di cose da sapere sullo script e su una modifica SFTP di root in generale. Per prima cosa, chiediamo le informazioni necessarie e poi le facciamo riecheggiare all'utente, in modo che possa verificarle. Se si risponde "N" alla domanda di conferma, lo script si blocca e non fa nulla. Lo script per 8.5 crea un backup di `sshd_config` (`/etc/ssh/sshd_config.bak`) come era prima dell'esecuzione dello script. Lo script 8.6 o 9.0 fa lo stesso per il file `sftp_config` (`/etc/ssh/sftp/sftp_config.bak`). In questo modo, se si sbaglia qualcosa con una voce, si può semplicemente ripristinare il file di backup appropriato e poi riavviare `sshd` per far funzionare di nuovo le cose.

La modifica SFTP di root richiede che il percorso indicato in `sshd_config` sia di proprietà di root. Per questo motivo, non è necessario aggiungere la cartella `html` alla fine del percorso. Una volta che l'utente è stato autenticato, il change root cambierà la home directory dell'utente, in questo caso la directory `../html`, in quella del dominio che stiamo inserendo. Il nostro script ha opportunamente cambiato il proprietario della directory `../html` con l'utente sftp e il gruppo apache.

!!! warning "Compatibilità dello Script"

    Mentre è possibile utilizzare con successo lo script creato per Rocky Linxux 8.5 su 8.5, 8.6 o 9.0, non si può dire lo stesso per lo script per 8.6 e 9.0. Poiché l'opzione "drop in" del file di configurazione (direttiva `Include`) non era abilitata nella versione 8.5, il tentativo di usare lo script scritto per queste nuove versioni in Rocky Linux 8.5 fallirà.

Ora che il nostro script è stato creato, rendiamolo eseguibile:

```
chmod +x /usr/local/sbin/webuser
```

Quindi eseguire lo script per i due domini di prova.

### Verifica del rifiuto di SSH e dell'accesso SFTP

Per prima cosa, si può provare a utilizzare `ssh` da un'altra macchina al nostro computer host come uno degli utenti SFTP. Si dovrebbe ricevere questo messaggio dopo aver inserito la password:

```
This service allows sftp connections only.
```
#### Test con strumenti grafici

Se *ricevete* questo messaggio, la prossima cosa da fare è testare l'accesso SFTP. Se volete fare le cose in modo semplice, potete usare un'applicazione FTP grafica che supporti SFTP, come Filezilla. In questi casi, i vostri campi avranno un aspetto simile a questo:

* **Host:** sftp://hostname_o_IP_del_server
* **Username:** (Esempio: myfixed)
* **Password:** (la password dell'utente SFTP)
* **Port:** (Non dovrebbe essere necessario inserirne una, a condizione che si utilizzino SSH e SFTP sulla porta 22 predefinita.)

Una volta compilato, si può fare clic sul pulsante "Quickconnect" (Filezilla) e ci si dovrebbe collegare alla directory `../html` del sito appropriato. Quindi fare doppio clic sulla directory "html" per posizionarsi al suo interno e provare a inserire un file nella directory. Se avete successo, allora siete a posto.

#### Test con gli strumenti a riga di comando

È ovviamente possibile eseguire tutte queste operazioni dalla riga di comando su una macchina che abbia installato SSH (la maggior parte delle installazioni Linux). Ecco una breve panoramica del metodo di connessione da riga di comando e di alcune opzioni:

* sftp username (Esempio: myfixed@hostname o IP del server: sftp myfixed@192.168.1.116)
* Inserite la password quando vi viene richiesto
* cd html (passare alla directory html)
* pwd (dovrebbe mostrare che sei nella directory html)
* lpwd (dovrebbe mostrare la directory di lavoro locale)
* lcd PATH (dovrebbe cambiare la propria directory di lavoro locale in qualcosa che si vuole utilizzare)
* put filename (copierà un file nella directory `..html`.)

Per un elenco esaustivo delle opzioni e altro ancora, consultate la pagina del manuale [SFTP](https://man7.org/linux/man-pages/man1/sftp.1.html).

### File di test per il web

Per i nostri domini fittizi, vogliamo creare un paio di file `index.html` con cui popolare la cartella `../html`. Una volta creati, è sufficiente inserirli nella directory di ciascun dominio utilizzando le credenziali SFTP del dominio stesso. Questi file sono molto semplici. Vogliamo solo qualcosa che ci permetta di vedere definitivamente che i nostri siti sono attivi e funzionanti e che la parte SFTP funziona come previsto. Ecco un esempio di questo file. Ovviamente puoi modificarlo come vuoi:

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

### Test sul Web

Per verificare che questi file vengano visualizzati e caricati come previsto, è sufficiente modificare il file hosts della propria workstation. Per Linux, si tratta di `sudo vi /etc/hosts` e poi si aggiungono semplicemente gli IP e i nomi degli host con cui si sta facendo il test in questo modo:

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

A questo punto, aprite il vostro browser web e verificate che il file `index.html` per ogni dominio venga visualizzato inserendo l'URL nella barra degli indirizzi del browser. (Esempio: "http://site1.com") Se i file di indice di prova vengono caricati, tutto funziona correttamente.

## Parte 3: Accesso amministrativo con coppie di chiavi SSH

Si noti che in questa sezione si utilizzeranno i concetti discussi nel documento [SSH Public and Private Keys](../security/ssh_public_private_keys.md), migliorandoli. Se siete alle prime armi, leggete questo articolo prima di continuare.

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

Ripetete la passphrase immessa in precedenza o premete invio per non immetterla.

A questo punto sono state create sia la chiave pubblica che quella privata. Ripetete questo passaggio per l'altro utente amministratore di sistema di esempio.

### Trasferimento della chiave pubblica al server SFTP

Il passo successivo consiste nell'esportare la nostra chiave sul server. In realtà, un amministratore di sistema responsabile della gestione di più server trasferisce la propria chiave pubblica a tutti i server di cui è responsabile.

Una volta creata la chiave, l'utente può inviarla al server in modo sicuro con `ssh-id-copy`:

```
ssh-id-copy lblakely@192.168.1.116
```

Il server richiederà una volta la password dell'utente e poi copierà la chiave in authorized_keys. Verrà visualizzato anche questo messaggio:

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lblakely@192.168.1.116'"
and check to make sure that only the key(s) you wanted were added.
```

Se si riesce ad accedere con questo account, ripetere la procedura con l'altro amministratore.

### Consentire SOLO login basati su chiavi

Supponendo che tutto quanto sopra abbia funzionato come previsto e che le chiavi per i nostri amministratori siano ora al loro posto sul server SFTP, disattiviamo l'autenticazione con password sul server. Per sicurezza, assicuratevi di avere due connessioni al server, in modo da poter annullare qualsiasi modifica in caso di conseguenze indesiderate.

Per realizzare questo passo, dobbiamo modificare ancora una volta `sshd_config` e, come in precedenza, vogliamo prima fare un backup del file:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Quindi, modificare il file `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Vogliamo disattivare le password in tunnel, quindi troviamo questa riga nella configurazione:

```
PasswordAuthentication yes
```

E modificarlo in modo che sia "no" - si noti che la semplice annotazione di questa riga fallirà, poiché l'impostazione predefinita è sempre "yes".

```
PasswordAuthentication no
```

L'autenticazione a chiave pubblica è attiva per impostazione predefinita, ma assicuriamoci che sia evidente quando si guarda il file, rimuovendo il commento davanti a questa riga:

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

## Parte 4: Disattivare l'accesso root remoto

In sostanza, l'abbiamo già fatto funzionalmente. Se si tenta di accedere al server con l'utente root, si otterrà il seguente risultato:

```
root@192.168.1.116: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

Ma vogliamo assicurarci che qualcuno non possa creare una chiave pubblica/privata per l'utente root e accedere così al server. Quindi c'è un ultimo passo da compiere e dobbiamo farlo... Avete indovinato! ... nel file `sshd_config`.

Poiché stiamo apportando una modifica a questo file, come in ogni altro passaggio, vogliamo fare una copia di backup del file prima di continuare:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Anche in questo caso, vogliamo modificare `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Quindi vogliamo trovare questa linea:

```
PermitRootLogin yes
```

E cambiarlo in "no" in modo che si legga:

```
PermitRootLogin no
```

Quindi salvare e uscire dal file e riavviare `sshd`:

```
systemctl restart sshd
```

Ora chiunque tenti di accedere come utente root da remoto tramite `ssh` riceverà lo stesso messaggio di rifiuto di prima, ma non sarà **ancora** in grado di accedere al server anche se possiede una coppia di chiavi pubbliche/private per root.

## Addendum: Nuovi Amministratori Di Sistema

Una cosa che non abbiamo ancora discusso è cosa succede quando arriva un nuovo amministratore di sistema? Con l'autenticazione tramite password disattivata, `ssh-copy-id` non funziona. Ecco cosa consiglia l'autore per queste situazioni. Si noti che esiste più di una soluzione:

### Soluzione Uno - Sneaker Net

Questa soluzione presuppone l'accesso fisico al server e che il server sia hardware fisico e non virtuale (container o VM):

* Aggiungere l'utente al gruppo "wheel" sul server SFTP
* Chiedete all'utente di generare le sue chiavi pubbliche e private SSH
* Utilizzando un'unità USB, copiate la chiave pubblica sull'unità, portatela fisicamente sul server e installatela manualmente nella directory del nuovo amministratore di sistema `/home/[nomeutente]/.ssh`

### Soluzione due - Modifica temporanea di `sshd_config`

Questa soluzione è soggetta all'errore umano, ma poiché non viene eseguita spesso, probabilmente sarebbe corretta se eseguita con cura:

* Aggiungere l'utente al gruppo "wheel" sul server SFTP
* Chiedete a un altro amministratore di sistema, che ha già un'autenticazione basata su chiavi, di attivare temporaneamente "PasswordAuthentication yes" nel `file sshd_config` e di riavviare `sshd`
* Chiedete al nuovo amministratore di sistema di eseguire `ssh-copy-id` utilizzando la sua password per copiare la chiave ssh sul server.

### Soluzione tre - Script del processo

Questo è il preferito dall'autore. Utilizza un amministratore di sistema che ha già un accesso basato su chiavi e uno script che deve essere eseguito con `bash [nome-script]` per ottenere lo stesso risultato della "Soluzione due" di cui sopra:

* modificare manualmente il file `sshd_config` e rimuovere la riga commentata che assomiglia a questa: `#PasswordAuthentication no`. Questa riga documenta il processo di disattivazione dell'autenticazione tramite password, ma intralcia lo script sottostante, perché il nostro script cercherà la prima occorrenza di `PasswordAuthentication no` e successivamente la prima occorrenza di `PasswordAuthentication yes`. Se si rimuove questa riga, lo script funzionerà correttamente.
* creare uno script sul server SFTP chiamato "quickswitch", o come lo si vuole chiamare. Il contenuto di questo script è simile a questo:

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
Spiegazione dello script: Non rendiamo questo script eseguibile. La ragione è che non lo vogliamo eseguire accidentalmente. Lo script deve essere eseguito (come indicato sopra) in questo modo: `bash /usr/local/sbin/quickswitch`. Questo script crea una copia di backup del file `sshd_config` proprio come tutti gli altri esempi precedenti. Quindi modifica il file `sshd_config` sul posto e cerca la *PRIMA* occorrenza di `PasswordAuthentication no` e la cambia in `PasswordAuthentication yes`, quindi riavvia `sshd` e attende che l'utente dello script prema <kbd>INVIO</kbd> prima di continuare. L'amministratore di sistema che esegue lo script sarebbe in comunicazione con il nuovo amministratore di sistema e, una volta che quest'ultimo esegue `ssh-copy-id` per copiare la sua chiave sul server, l'amministratore di sistema che sta eseguendo lo script preme invio e la modifica viene invertita.

## Conclusione

In questo documento abbiamo trattato molti aspetti, ma tutti sono stati pensati per rendere un server web multisito più sicuro e meno soggetto a vettori di attacco su SSH quando si attiva SFTP per l'accesso dei clienti. L'attivazione e l'uso di SFTP è molto più sicuro dell'uso di FTP, anche se si utilizzano server ftp veramente *BUONI* e li si è impostati nel modo più sicuro possibile, come indicato in questo [documento su VSFTPD](secure_ftp_server_vsftpd.md). Implementando *tutti* i passaggi di questo documento, potrete sentirvi tranquilli nell'aprire la porta 22 (SSH) alla vostra zona pubblica, sapendo che il vostro ambiente è sicuro.
