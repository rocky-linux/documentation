- - -
title: LibreNMS Monitoring Server author: Steven Spencer contributors: Ezequiel Bruni, Franco Colussi testato con: 8.5, 8.6, 9.0 tags:
  - monitoring
  - network
- - -

# LibreNMS Monitoring Server

## Introduzione

Gli amministratori di rete e di sistema hanno quasi sempre bisogno di una forma di monitoraggio. Ciò può includere il grafico dell'utilizzo della larghezza di banda ai punti finali del router, il monitoraggio dell'up/down dei servizi in esecuzione su vari server e molto altro ancora. Esistono molte opzioni di monitoraggio, ma un'opzione molto valida e con molti, se non tutti, i componenti di monitoraggio disponibili sotto lo stesso profilo è LibreNMS.

Questo documento vi permetterà solo di iniziare a usare LibreNMS, ma vi indicheremo l'eccellente (e vasta) documentazione del progetto per proseguire. Ci sono molte altre opzioni per il monitoraggio che questo autore ha già utilizzato in passato, come Nagios e Cacti, ma LibreNMS offre ciò che questi due progetti offrono singolarmente, in un unico ambiente.

Sebbene l'installazione segua abbastanza fedelmente le istruzioni ufficiali che si trovano [qui](https://docs.librenms.org/Installation/Install-LibreNMS/), abbiamo aggiunto alcune spiegazioni e anche alcune piccole modifiche che rendono questa procedura preferibile a quell'eccellente documento.

## Prerequisiti, Presupposti e Convenzioni

* Un server o un container (sì, LibreNMS viene eseguito in un container, ma se avete molte cose da monitorare, la cosa migliore è installarlo sul proprio hardware) che esegue Rocky Linux. Tutti i comandi presuppongono una nuova installazione di Rocky Linux.
* Presupposto: che siate in grado di eseguire i comandi come root o che possiate farlo con _sudo_
* Conoscenza di strumenti a riga di comando, inclusi editor di testo come _vi_
* Si presuppone l'uso di SNMP v2. Se si desidera utilizzare SNMP v3, questo è supportato da LibreNMS e funzionerà. È sufficiente modificare la configurazione e le opzioni SNMP dei dispositivi per adeguarli alla versione v3.
* Anche se abbiamo incluso la procedura SELinux in questo documento, il container che stiamo usando nel laboratorio non la include di default. Per questo motivo, la procedura SELinux **non è stata** testata in laboratorio.
* In tutto il documento, gli esempi utilizzano l'editor _vi_ come indicato. Quando il documento dice di salvare le modifiche e di uscire, lo si fa con `SHIFT:wq!`
* Sono richieste alcune capacità di risoluzione dei problemi, tra cui il monitoraggio dei log, i test web e altro ancora.

## Installazione dei Pacchetti

Questi comandi devono essere inseriti come utente root. Prima di iniziare, si noti che questa procedura di installazione si concentra su *httpd*, piuttosto che su *nginx*. Se preferite usare quest'ultima, visitate il sito [Istruzioni per l'installazione di Librenms](https://docs.librenms.org/Installation/Install-LibreNMS/) e seguite la guida.

Stiamo ipotizzando una nuova installazione, quindi dobbiamo fare alcune cose con i repository prima di poter continuare. Per prima cosa, è necessario installare il repository EPEL (Extra Packages for Enterprise Linux):

```
dnf install -y epel-release
```

La versione attuale di LibreNMS richiede una versione minima di PHP pari a 8.1. Il pacchetto predefinito di Rocky Linux 9.0 è PHP 8.0, quindi è necessario abilitare un repository di terze parti (come per Rocky Linux 8.6) per questa nuova versione.

Per questo installeremo il repository REMI. La versione del repository da installare dipende dalla versione di Rocky Linux in uso. Di seguito si ipotizza la versione 9, ma si consiglia di modificare questa impostazione in base alla versione in uso:

```
dnf install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Una volta installati i repository EPEL e REMI, è il momento di installare i pacchetti necessari:

```
dnf install bash-completion cronie fping git httpd ImageMagick mariadb-server mtr net-snmp net-snmp-utils nmap php81-php-fpm php81-php-cli php81-php-common php81-php-curl php81-php-gd php81-php-json php81-php-mbstring php81-php-process php81-php-snmp php81-php-xml php81-php-zip php81-php-mysqlnd python3 python3-PyMySQL python3-redis python3-memcached python3-pip python3-systemd rrdtool unzip wget
```

Tutti questi pacchetti rappresentano una parte delle funzionalità di LibreNMS.

## Impostare l'utente Librenms

A tal fine, copiare e incollare (o digitare) quanto segue:

```
useradd librenms -d /opt/librenms -M -r -s "$(which bash)"
```

Con questo comando, impostiamo la directory predefinita per il nostro nuovo utente a "/opt/librenms", ma l'opzione "-M" dice "non creare la directory" Il motivo, ovviamente, è che la creeremo quando installeremo LibreNMS. Il "-r" dice di rendere questo utente un account di sistema e il "-s" dice di impostare la shell (in questo caso, su "bash")

## Scaricare LibreNMS e impostare i Permessi

Il download viene effettuato tramite git. Il processo potrebbe esservi familiare, visto che oggi viene utilizzato per molti progetti. Per prima cosa, passate alla directory /opt:

```
cd /opt
```

Quindi clonare il repository:

```
git clone https://github.com/librenms/librenms.git
```

Quindi modificate le autorizzazioni per la directory:

```
chown -R librenms:librenms /opt/librenms
chmod 771 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
```

Il comando _setfacl_ sta per "set file access control lists" ed è un altro modo per proteggere directory e file.

## Installare le dipendenze di PHP in librenms

Tutti i comandi precedenti sono stati eseguiti come root o _sudo_, ma le dipendenze PHP di LibreNMS devono essere installate come utente librenms. A tal fine, eseguire:

```
su - librenms
```

Quindi inserire quanto segue:

```
./scripts/composer_wrapper.php install --no-dev
```

Una volta completato lo script, uscire di nuovo a root:

```
exit
```

### Problema di installazione delle dipendenze di PHP

La documentazione di LibreNMS dice che se ci si trova dietro un server proxy, la procedura sopra descritta potrebbe fallire. Abbiamo scoperto che può fallire anche per altri motivi. Per questo motivo, ho aggiunto una procedura per installare Composer in un secondo momento.

## Impostare il Fuso Orario

Dobbiamo assicurarci che sia impostato correttamente, sia per il sistema che per PHP. È possibile trovare un elenco di impostazioni di fuso orario valide per PHP [qui](https://php.net/manual/en/timezones.php). Ad esempio, per il fuso orario Central, una voce comune sarebbe "America/Chicago". Iniziamo modificando il file php.ini:

```
vi /etc/opt/remi/php81/php.ini
```

Trovare la riga `date.timezone` e modificarla. Si noti che è annotato, quindi rimuovere il ";" dall'inizio della riga e aggiungere il proprio fuso orario dopo il segno "=". Per il nostro esempio di fuso orario Central utilizzeremo:

```
date.timezone = America/Chicago
```

Salvare le modifiche e uscire dal file php.ini.

Occorre anche verificare che il fuso orario del sistema sia corretto. Ancora una volta, utilizzando come esempio il fuso orario Central, si può procedere con:

```
timedatectl set-timezone America/Chicago
```

## Impostazione di MariaDB

Prima di passare alla configurazione del database necessaria per LibreNMS, si consiglia di consultare la procedura [MariaDB](../database/database_mariadb-server.md) e in particolare la sezione "Messa in sicurezza di mariadb-server", per poi tornare qui per queste impostazioni specifiche. La prima cosa da fare è modificare il file mariadb-server.cnf:

```
vi /etc/my.cnf.d/mariadb-server.cnf
```

Aggiungere le seguenti righe alla sezione "[Mysqld]":

```
innodb_file_per_table=1
lower_case_table_names=0
```

Quindi abilitare e riavviare il server mariadb:

```
systemctl enable mariadb
systemctl restart mariadb
```

Ora accedere a mariadb come utente root. Ricordarsi di utilizzare la password creata durante la sezione "Messa in sicurezza di mariadb-server", eseguita in precedenza:


```
mysql -u root -p
```

La prossima cosa da fare è apportare alcune modifiche specifiche per LibreNMS. Con il comando qui sotto, ricordatevi di cambiare la password "password" con qualcosa di sicuro e di memorizzarla in un luogo sicuro, ad esempio in un gestore di password, in modo da averla a disposizione in seguito.

Al prompt di mysql eseguire:

```
CREATE DATABASE librenms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';
FLUSH PRIVILEGES;
```

Una volta fatto questo, digitare "exit" per uscire da mariadb.

## Configurare PHP-FPM

Questa sezione è sostanzialmente invariata rispetto alla documentazione ufficiale, tranne che per il percorso dei file. Per prima cosa, copiare il file www.conf:

```
cp /etc/opt/remi/php81/php-fpm.d/www.conf /etc/opt/remi/php81/php-fpm.d/librenms.conf
```

Modificare quindi il file librenms.conf:

```
vi /etc/opt/remi/php81/php-fpm.d/librenms.conf
```

Cambiare "[www]" con ["librenms]"

Cambiare l'utente e il gruppo in "librenms":

```
user = librenms
group = librenms
```

Infine, modificare la riga "listen" in modo che rifletta un nome univoco:

```
listen = /run/php-fpm-librenms.sock
```

Salvare le modifiche e uscire dal file. Se questo è l'unico servizio web che verrà eseguito su questa macchina, si può rimuovere il vecchio file www.conf che abbiamo copiato:

```
rm -f /etc/opt/remi/php81/php-fpm.d/www.conf
```

## Configurare Apache

Normalmente, per configurare i servizi web si utilizza la procedura [Siti Apache abilitati](../web/apache-sites-enabled.md), ma in questo caso si utilizza la configurazione predefinita.

Si noti che se si vuole usare questa procedura, è sufficiente inserire il file di configurazione in /etc/httpd/sites-available e poi seguire la procedura per collegarlo a sites-enabled. La radice predefinita del documento, tuttavia, **non** sarà /var/www/sottodomini/librenms/html, bensì /opt/librenms/html.

Anche in questo caso, non utilizziamo questa procedura e ci limitiamo a seguire l'impostazione predefinita e suggerita. A tal fine, è necessario creare questo file:

```
vi /etc/httpd/conf.d/librenms.conf
```

E inserendo in quel file quanto segue:

```
<VirtualHost *:80>
  DocumentRoot /opt/librenms/html/
  ServerName  librenms.example.com

  AllowEncodedSlashes NoDecode
  <Directory "/opt/librenms/html/">
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
  </Directory>

  # Enable http authorization headers
  <IfModule setenvif_module>
    SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1
  </IfModule>

  <FilesMatch ".+\.php$">
    SetHandler "proxy:unix:/run/php-fpm-librenms.sock|fcgi://localhost"
  </FilesMatch>
</VirtualHost>
```

È necessario rimuovere anche il vecchio sito predefinito, welcome.conf:

```
rm /etc/httpd/conf.d/welcome.conf
```

Infine, occorre abilitare sia _httpd_ che _php-fpm_:

```
systemctl enable --now httpd
systemctl enable --now php81-php-fpm
```

## SELinux

Se non avete intenzione di usare SELinux, saltate questa sezione e passate a quella successiva. Questo potrebbe valere anche per chi usa LibreNMS su un container che non supporta SELinux a livello di container o non lo include per default.

Per configurare tutto con SELinux, è necessario installare un pacchetto aggiuntivo:

```
dnf install policycoreutils-python-utils
```

### Configurare i contesti LibreNMS

Affinché LibreNMS funzioni correttamente con SELinux, è necessario impostare i seguenti contesti:

```
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/html(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/(logs|rrd|storage)(/.*)?'
restorecon -RFvv /opt/librenms
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_execmem 1
chcon -t httpd_sys_rw_content_t /opt/librenms/.env
```

### Permettere il fping

Creare un file chiamato `http_fping.tt` ovunque e verrà installato in seguito tramite un comando. I contenuti di questo file sono:

```
module http_fping 1.0;

require {
type httpd_t;
class capability net_raw;
class rawip_socket { getopt create setopt write read };
}

#============= httpd_t ==============
allow httpd_t self:capability net_raw;
allow httpd_t self:rawip_socket { getopt create setopt write read };
```

Ora installate il contenuto di questo file con i seguenti comandi:

```
checkmodule -M -m -o http_fping.mod http_fping.tt
semodule_package -o http_fping.pp -m http_fping.mod
semodule -i http_fping.pp
```

Se si verificano problemi e si sospetta che possano essere dovuti a un problema di SELinux, eseguire quanto segue:

```
audit2why < /var/log/audit/audit.log
```

## Configurazione del firewall - `firewalld`

Includeremo le istruzioni di _firewalld_ dalla documentazione ufficiale.

Il comando da utilizzare per le regole di autorizzazione di _firewalld_ è il seguente:

```
firewall-cmd --zone public --add-service http --add-service https
firewall-cmd --permanent --zone public --add-service http --add-service https
```

L'autore ha problemi con questo tipo di regole semplificate di _ firewalld_. Questa regola permette ai servizi web di essere aperti al mondo, ma è questo che si vuole per un server di monitoraggio?

Direi che di solito questo **non** è il caso. Se si desidera un approccio più granulare all'uso di _firewalld_, consultare [questo documento](../security/firewalld.md) e modificare di conseguenza le regole di _firewalld_.

## Abilitazione del link simbolico e del completamento automatico del Tab per i comandi lnms

Per prima cosa, abbiamo bisogno di un collegamento simbolico al nostro comando _lnms_, in modo che possa essere eseguito da qualsiasi punto:

```
ln -s /opt/librenms/lnms /usr/bin/lnms
```

Successivamente, occorre impostare il completamento automatico:

```
cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/
```

## Configurare snmpd

_SNMP_ è l'acronimo di "Simple Network Management Protocol" ed è utilizzato in molti programmi di monitoraggio per estrarre dati. Nella versione 2, che stiamo utilizzando, si tratta di una " community string" specifica per il vostro ambiente.

È necessario assegnare questa " community string" ai dispositivi di rete che si desidera monitorare, in modo che _snmpd_ (la "d" qui sta per il demone) sia in grado di trovarli. Se la vostra rete è attiva da tempo, potreste già avere una " community string" che state utilizzando.

Per prima cosa, copiare il file snmp.conf da LibreNMS:

```
cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf
```

Quindi, modificare questo file e cambiare la community string da "RANDOMSTRINGGOESHERE" a quella che è o sarà la vostra community string. Nel nostro esempio, lo cambiamo in "LABone":

```
vi /etc/snmp/snmpd.conf
```

E modificare questa riga:

```
com2sec readonly  default         RANDOMSTRINGGOESHERE
```

in

```
com2sec readonly  default         LABone
```

Ora salvate le modifiche e uscite.

## Automatizzare con un Cron Job

Eseguire i seguenti comandi per impostare i lavori di cron:

```
cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms
```

È importante che il poller sia stato eseguito una volta, anche se non ci sarà nulla da interrogare, prima di eseguire la procedura di configurazione web. In questo modo si evita di doversi arrovellare la testa per capire cosa c'è di sbagliato quando si ottengono errori di polling nella sezione di convalida.

Il poller viene eseguito dall'utente "librenms" e, sebbene sia possibile passare a questo utente ed eseguire i file di cron, è meglio lasciare che il poller lo faccia da solo, quindi assicurarsi che siano passati almeno 5 minuti tra questa sezione e la sezione "Impostazione del Web" che segue.

## Rotazione del Registro

LibreNMS creerà nel tempo un'ampia serie di registri. È necessario impostare la rotazione dei registri in modo che non occupino troppo spazio su disco. Per farlo, è sufficiente eseguire ora questo comando:

```
cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms
```

## Installazione di Composer

PHP Composer è necessario per l'installazione corrente (menzionato nella procedura precedente). Se l'installazione eseguita in precedenza non è andata a buon fine, è necessario eseguire questa operazione.

Prima di iniziare, dobbiamo collegare la nostra versione corrente del binario `php` a una posizione nel path. Poiché abbiamo usato l'installazione REMI per ottenere la versione corretta di PHP, questa non è installata nel path.

Questo è abbastanza facile da risolvere con un collegamento simbolico e vi renderà la vita molto più facile durante i passaggi rimanenti:

```
ln -s /opt/remi/php81/root/usr/bin/php /usr/bin/php
```

Ora andate sul [sito di Composer](https://getcomposer.org/download/) e assicuratevi che i seguenti passaggi non siano stati modificati. In caso contrario, eseguire questi comandi da qualche parte sulla macchina (la posizione non è importante, perché sposteremo il composer quando avremo finito):

```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

Spostatelo in un punto del nostro path. Per questo useremo `/usr/local/bin/`:

```
mv composer.phar /usr/local/bin/composer
```

## Impostazione Web

Ora che tutti i componenti sono stati installati e configurati, il prossimo passo è completare l'installazione via web. Nella nostra versione di laboratorio, non abbiamo impostato alcun hostname, quindi per completare la configurazione, dobbiamo accedere al server web tramite l'indirizzo IP.

L'IP della nostra macchina di laboratorio è 192.168.1.140, quindi dobbiamo navigare al seguente indirizzo in un browser web per completare l'installazione:

`http://192.168.1.140/librenms`

Se tutto funziona correttamente, si dovrebbe essere reindirizzati ai controlli di pre-installazione. Supponendo che siano tutti contrassegnati dal colore verde, dovremmo essere in grado di continuare.

![Precontrolli LibreNMS](../images/librenms_prechecks.png)

Ci sono quattro pulsanti sotto il logo LibreNMS. Il primo pulsante a sinistra è per i controlli preliminari. Il prossimo pulsante è per il database. È necessaria la password impostata in precedenza per l'utente del database "librenms".

Se ci avete seguito diligentemente, avete già salvato questo dato in un posto sicuro. Procedete facendo clic sul pulsante "Database". I campi " User " e " Password " dovrebbero essere tutto ciò che è necessario compilare. Una volta fatto ciò, fare clic sul pulsante " Check Credentials".

![Database LibreNMS](../images/librenms_configure_database.png)

Una volta fatto clic su questo pulsante, se il colore diventa verde, si è pronti a fare clic sul pulsante " Build Database".

![LibreNMS Database Status](../images/librenms_configure_database_status.png)

Una volta completato, il terzo pulsante sarà attivo: " Create Admin User", quindi fate clic su questo pulsante. Verrà richiesto il nome di un utente amministratore. Nel nostro laboratorio utilizzeremo semplicemente "admin" e una password per questo utente.

Assicuratevi che la password sia sicura e, anche in questo caso, registratela in un luogo sicuro, come un gestore di password. È inoltre necessario inserire l'indirizzo e-mail dell'utente amministrativo. Una volta completato tutto ciò, è sufficiente fare clic sul pulsante " Add User".

![LibreNMS Administrative User](../images/librenms_administrative_user.png)

Una volta fatto questo, si aprirà una schermata con la richiesta di " Finish Install" Dovrebbe rimanere solo un elemento per completare l'installazione, ovvero una riga che chiede di "validate your install".

Fare clic sul link. Una volta eseguita questa operazione e se tutto è andato a buon fine, si verrà reindirizzati alla pagina di accesso. Accedere con l'utente amministrativo e la password.

## Aggiungere i dispositivi in Librenms

Anche in questo caso, una delle nostre ipotesi è che si stia utilizzando SNMP v2. Ricordate che ogni dispositivo aggiunto deve essere membro della vostra community string. Qui aggiungiamo due dispositivi come esempio. Una workstation Ubuntu e un server CentOS.

È più che probabile che si debbano aggiungere switch, router e altri dispositivi gestiti. L'autore può dire per esperienza che l'aggiunta di switch e router tende a essere molto più semplice dell'aggiunta di workstation e server, ed è per questo che includiamo gli esempi più difficili.

### Configurazione della workstation Ubuntu

Per prima cosa, installate _snmpd_ sulla workstation aggiornando anche i pacchetti, per sicurezza:

```
sudo update && sudo apt-get upgrade && sudo apt-get install snmpd
```

Successivamente, è necessario modificare il file snmpd.conf:

```
sudo vi /etc/snmpd/snmpd.conf
```

Trovate le righe che descrivono la vostra workstation e cambiatele con altre che la identificano. Queste righe sono mostrate di seguito:

```
sysLocation    Desktop
sysContact     Username <user@mydomain.com>
```

Per impostazione predefinita, quando si installa snmpd su Ubuntu, si collega solo all'indirizzo locale. Non ascolta l'indirizzo IP del vostro computer. Questo non permetterà a LibreNMS di connettersi ad esso. Dobbiamo commentare questa linea:

```
agentaddress  127.0.0.1,[::1]
```

E aggiungere una nuova riga che assomigli a quella che segue: (In questo esempio, l'indirizzo IP della nostra workstation è 192.168.1.122 e la porta UDP che stiamo impostando è "161")

```
agentAddress udp:127.0.0.1:161,udp:192.168.1.122:161
```

Successivamente, occorre specificare la community per l'accesso in sola lettura. Trovate le righe sottostanti e commentatele. (Si noti che li mostriamo come sono stati commentati di seguito)

```
#rocommunity public default -V systemonly
#rocommunity6 public default -V systemonly
```

Quindi, aggiungere una nuova riga:

```
rocommunity LABone
```

Ora salvate le modifiche e uscite.

Abilitare e avviare _snmpd_:

```
sudo systemctl enable snmpd
sudo systemctl start snmpd
```

Se si utilizza un firewall sulle stazioni di lavoro interne, è necessario modificarlo per consentire il traffico UDP dal server di monitoraggio o dalla rete. LibreNMS vuole anche essere in grado di "pingare" il dispositivo, quindi assicuratevi che la porta icmp 8 sia consentita dal server.

### Configurazione del server Linux CentOS o Rocky

Si presume che siate root o che possiate diventarlo con _sudo_. Per prima cosa, dobbiamo installare alcuni pacchetti:

```
dnf install net-snmp net-snmp-utils
```

Successivamente, si deve creare un file snmpd.conf. Piuttosto che cercare di navigare nel file incluso, spostate questo file per rinominarlo e create un nuovo file vuoto:

```
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
```

e

```
vi /etc/snmp/snmpd.conf
```

Quindi copiare il testo sottostante nel nuovo file:

```
# Map 'LABone' community to the 'AllUser'
# sec.name source community
com2sec AllUser default LABone
# Map 'ConfigUser' to 'ConfigGroup' for SNMP Version 2c
# Map 'AllUser' to 'AllGroup' for SNMP Version 2c
# sec.model sec.name
group AllGroup v2c AllUser
# Define 'SystemView', which includes everything under .1.3.6.1.2.1.1 (or .1.3.6.1.2.1.25.1)
# Define 'AllView', which includes everything under .1
# incl/excl subtree
view SystemView included .1.3.6.1.2.1.1
view SystemView included .1.3.6.1.2.1.25.1.1
view AllView included .1
# Give 'ConfigGroup' read access to objects in the view 'SystemView'
# Give 'AllGroup' read access to objects in the view 'AllView'
# context model level prefix read write notify
access AllGroup "" any noauth exact AllView none none
```

CentOS e Rocky utilizzano una convenzione di mappatura per indirizzare le cose. Il file qui sopra è commentato in modo da poter capire cosa sta succedendo, ma non include tutto il disordine del file originale.

Una volta apportate le modifiche, salvarle e uscire dal file.

Ora dobbiamo abilitare e avviare _snmpd_:

```
systemctl enable snmpd
systemctl start snmpd
```

#### Firewall

Se state gestendo un server, allora **state** gestendo un firewall, giusto?  Se si sta utilizzando _firewalld_ (come dovrebbe essere), si presuppone che si stia utilizzando la zona "trusted" e che si voglia semplicemente consentire tutto il traffico dal nostro server di monitoraggio, 192.168.1.140:

```
firewall-cmd --zone=trusted --add-source=192.168.1.140 --permanent
```

Anche in questo caso, abbiamo ipotizzato l'area "trusted", ma potreste volere qualcos'altro, anche "public", è sufficiente considerare le proprie regole e i loro effetti prima di aggiungerle.

## Aggiunta di dispositivi in Librenms

Ora che i nostri dispositivi di esempio sono configurati per accettare il traffico snmp dal nostro server LibreNMS, il passo successivo è aggiungere questi dispositivi a LibreNMS. Si presume che l'interfaccia web di LibreNMS sia aperta e, in tal caso, mostrerà che non sono stati aggiunti dispositivi e chiederà di aggiungerne uno.

Quindi, procedete a farlo. Una volta fatto clic per aggiungere un dispositivo, ci si troverà di fronte a questa schermata:

![LibreNMS Add Device](../images/librenms_add_device.png)

Inserite le informazioni utilizzate per i nostri dispositivi di prova. Nel nostro caso, utilizziamo l'IP della workstation Ubuntu per cominciare, nel nostro esempio è 192.168.1.122. L'unica cosa che dovremo aggiungere è la community string nel campo "Community", per cui dovremo digitare "LABone".

A questo punto, fare clic sul pulsante " Add Device". Supponendo di aver eseguito correttamente tutte le operazioni sopra descritte per l'aggiunta del dispositivo, il dispositivo dovrebbe essere stato aggiunto con successo.

Se si verifica un errore di " failure to add", rivedere l'impostazione SNMP della workstation o del firewall, se esiste. Ripetiamo quindi il processo " Add Device" per il nostro server CentOS.

## Ricevere Avvisi

Come abbiamo detto fin dall'inizio, questo documento serve solo per iniziare a usare LibreNMS. Ci sono un gran numero di voci di configurazione aggiuntive, un'ampia API (Application Programming Interface), un sistema di avvisi che fornisce un gran numero di opzioni per la consegna, chiamate "Transports", e molto altro ancora.

Non creeremo alcuna regola di avviso, ma modificheremo la regola di avviso incorporata "Device Down! Due to no ICMP response", che è preconfigurato in partenza, e per i " Transports" ci atterremo a "Mail", che è solo un'e-mail. Sappiate solo che non siete limitati.

Per poter utilizzare la posta elettronica per il nostro sistema di trasporto, tuttavia, è necessario che la posta funzioni sul nostro server. Per farlo, utilizzeremo questa [Procedura Postfix](../email/postfix_reporting.md).

Eseguite la procedura per configurare postfix in modo che identifichi correttamente la provenienza dei messaggi, ma potete fermarvi dopo il processo di configurazione e tornare qui.

### Transports

Abbiamo bisogno di un modo per inviare i nostri avvisi. Come già detto, LibreNMS supporta un numero enorme di servizi di trasporto. Il nostro avviso avverrà tramite posta elettronica, definita come trasporto "Mail". Per impostare il trasporto:

1. Vai al cruscotto
2. Passare il mouse su "Alerts"
3. Scendere fino a " Alert Transports" e fare clic su di esso
4. Cliccare sul pulsante "Create alert transport" (Notate il pulsante "Create transport group". È possibile utilizzare questa opzione per inviare avvisi a più persone)
5. Nel campo "Transport name:", digitare "Alert By Email"
6. Nel campo "Transport type:", utilizzare il menu a tendina per selezionare "Mail"
7. Assicurarsi che il campo " Default alert:" sia impostato su "On"
8. Nel campo "Email:", digitare l'indirizzo email dell'amministratore

### Configurazione del server CentOS o Rocky Linux

Il modo migliore per impostare gli avvisi è quello di organizzare i dispositivi in un ordine logico. Attualmente abbiamo una workstation e un server in dispositivi. Anche se normalmente non vorremmo combinare le due cose, lo faremo per questo esempio.

Tenete presente che il nostro esempio è anche ridondante, poiché esiste un gruppo " All Devices" che può essere utilizzato per questo scopo. Per impostare un gruppo di dispositivi:

1. Vai al cruscotto
2. Passare il mouse su "Devices"
3. Scendere fino a "Manage Groups" e fare clic su di esso
4. Cliccare sul pulsante "+ New Device Group"
5. Nel campo "Name", scrivere "ICMP Group"
6. Nel campo della descrizione scrivete ciò che ritenete utile per descrivere il gruppo
7. Cambiare il campo "Type" da "Dynamic" a "Static"
8. Aggiungere entrambi i dispositivi al campo " Select Devices" e poi salvare le modifiche

### Impostare le regole di Avviso

Ora che abbiamo impostato il trasporto e il gruppo di dispositivi, configuriamo la regola di avviso. Per impostazione predefinita, LibreNMS ha diverse regole di avviso già create per voi:

1. Vai al cruscotto
2. Passare il mouse su "Alerts"
3. Scendere fino a "Alert Rules" e fare clic sopra
4. La regola attiva più in alto sul display sarà "Device Down! Due to no ICMP response." Andare su "Action" (colonna all'estrema destra) e fare clic sull'icona della matita per modificare la regola.
5. Lasciate invariati tutti i campi in alto e scendete fino al campo " Match devices, groups and locations list:" e fate clic all'interno del campo
6. Selezionare "ICMP Group" dalla lista
7. Assicurarsi che il campo "All devices except in list:" sia "Off"
8. Fare clic nel campo " Transports:" e selezionare "Mail: Alert By Email" e salvare la regola.

Prima di salvare, la regola dovrebbe avere un aspetto simile a questo:

![LibreNMS Alert Rule](../images/librenms_alert_rule.png)

Questi due dispositivi dovrebbero ora avvisare l'utente tramite e-mail se sono inattivi e quando si ripristinano.

## Conclusioni

LibreNMS è un potente strumento di monitoraggio con una serie completa di funzioni in un'unica applicazione. Abbiamo solo _appena_ scalfito la superficie delle potenzialità. Non vi abbiamo mostrato alcune delle schermate più ovvie.

Ad esempio, non appena si aggiungono dispositivi, supponendo che tutte le proprietà SNMP siano state impostate correttamente, si inizieranno a ricevere i grafici della larghezza di banda, dell'utilizzo della memoria e della CPU di ciascun dispositivo. Non vi abbiamo mostrato la ricchezza dei trasporti disponibili oltre alla " Mail ".

Detto questo, in questo documento vi abbiamo mostrato abbastanza per iniziare a monitorare il vostro ambiente. LibreNMS richiede un po' di tempo per padroneggiare tutti gli elementi. Per ulteriori informazioni, visitate la [eccellente documentazione](https://docs.librenms.org/) del progetto.
