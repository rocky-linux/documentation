# LibreNMS Monitoring Server

## Introduzione

Gli amministratori di rete e di sistema hanno quasi sempre bisogno di qualche forma di monitoraggio. Questo può includere il grafico dell'uso della larghezza di banda ai punti finali del router, il monitoraggio dell'up/down dei servizi in esecuzione su vari server e molto, molto di più. Ci sono molte opzioni di monitoraggio là fuori, ma un'opzione che è molto buona e ha molti, se non tutti, i componenti di monitoraggio disponibili sotto lo stesso tetto, è LibreNMS.

Questo documento vi farà solo iniziare con LibreNMS, ma vi indicheremo l'eccellente (ed estesa) documentazione del progetto per farvi andare oltre. Ci sono molte altre opzioni per il monitoraggio là fuori che questo autore ha usato prima, Nagios e Cacti sono due, ma LibreNMS offre quello che questi due progetti offrono individualmente, in un unico punto.

Mentre l'installazione seguirà abbastanza da vicino le istruzioni ufficiali di installazione che si trovano [qui](https://docs.librenms.org/Installation/Install-LibreNMS/), abbiamo aggiunto alcune spiegazioni e anche alcuni cambiamenti minori, che rendono questa procedura preferibile a quell'eccellente documento.

## Prerequisiti, Presupposti e Convenzioni

* Un server o un container (sì, LibreNMS funzionerà in un container, tuttavia se avete molto da monitorare, la cosa migliore sarebbe installarlo sul proprio hardware) con Rocky Linux. Tutti i comandi presuppongono una nuova installazione di Rocky Linux.
* Presupposto: sei in grado di eseguire comandi come root o puoi farlo con _sudo_
* Conoscenza operativa degli strumenti a riga di comando, compresi gli editor, come _vi_
* Si presume l'uso di SNMP v2. Se volete usare SNMP v3, è supportato da LibreNMS e funzionerà. Dovrete solo cambiare la configurazione e le opzioni SNMP sui vostri dispositivi per adattarli alla v3.
* Mentre abbiamo incluso la procedura SELinux in questo documento, il container che stiamo usando nel laboratorio non la include di default. Per questo motivo, la procedura SELinux **non** è stata testata in laboratorio.
* In tutto questo documento, gli esempi usano l'editor _vi_ come menzionato. Quando il documento dice di salvare le modifiche e uscire, questo viene fatto con `SHIFT:wq!`
* Sono richieste alcune capacità di risoluzione dei problemi, tra cui il monitoraggio dei registri, i test sul web e altro.

## Installazione dei pacchetti

Questi comandi dovrebbero essere inseriti come utente root. Prima di iniziare, notate che questa procedura di installazione si concentra su httpd, piuttosto che su nginx. Se preferisci usare quest'ultimo, vai su [Librenms Install Instructions](https://docs.librenms.org/Installation/Install-LibreNMS/) e segui la guida lì. Stiamo assumendo una nuova installazione, quindi abbiamo bisogno di fare alcune cose con i repository prima di poter continuare. Per prima cosa, dobbiamo installare il repository EPEL (Extra Packages for Enterprise Linux):

`dnf install -y epel-release`

Successivamente, dobbiamo dire ai repository di abilitare PHP 7.3 come PHP predefinito:

```
dnf module reset php
dnf module enable php:7.3
```

Questo restituirà un elenco per httpd, nginx e php, basta rispondere "y" al prompt per continuare. Successivamente, abbiamo bisogno di installare un po' di pacchetti:

`dnf install bash-completion cronie fping git httpd ImageMagick mariadb-server mtr net-snmp net-snmp-utils nmap php-fpm php-cli php-common php-curl php-gd php-json php-mbstring php-process php-snmp php-xml php-zip php-mysqlnd python3 python3-PyMySQL python3-redis python3-memcached python3-pip python3-systemd rrdtool unzip`

Tutti questi pacchetti rappresentano una parte del set di funzionalità di LibreNMS.

## Impostare l'Utente Librenms

Per farlo, copiate e incollate (o scrivete) quanto segue:

`useradd librenms -d /opt/librenms -M -r -s "$(which bash)"`

Con questo comando, stiamo impostando la directory predefinita per il nostro nuovo utente su "/opt/librenms", tuttavia l'opzione "-M" dice "non creare la directory". Il motivo, naturalmente, è che la creeremo quando installeremo libreNMS. La "-r" dice di rendere questo utente un account di sistema e la "-s" dice di impostare la shell (in questo caso, a "bash")

## Scaricare LibreNMS e Impostare i Permessi

Il download avviene tutto tramite git. Dovreste avere familiarità con il processo, dato che è usato per molti progetti in questi giorni. Per prima cosa, passate alla directory /opt:

`cd /opt`

Quindi clonate il repository:

`git clone https://github.com/librenms/librenms.git`

Poi cambiate i permessi per la directory:

```
chown -R librenms:librenms /opt/librenms
chmod 771 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
```

Il comando _setfacl_ sta per "set file access control lists" ed è un altro modo per mettere al sicuro directory e file.

## Installare le dipendenze di PHP Come librenms

Tutti i comandi precedenti sono stati eseguiti come root o _sudo_, ma le dipendenze PHP all'interno di LibreNMS devono essere installate come utente librenms. Per fare questo,

`su - librenms`

E poi inserisci il seguente:

`./scripts/composer_wrapper.php install --no-dev`

Una volta che lo script è completato, uscite di nuovo a root:

`exit`

### Fallimento dell'Installazione delle Dipendenze di PHP Soluzione Alternativa

La documentazione di LibreNMS dice che quando si è dietro un server proxy, la procedura di cui sopra può fallire. Se è così, usate questa procedura come soluzione alternativa. Notate anche che questa soluzione alternativa dovrebbe essere eseguita come utente root, perché apporta modifiche a /usr/bin:

```
wget https://getcomposer.org/composer-stable.phar
mv composer-stable.phar /usr/bin/composer
chmod +x /usr/bin/composer
```

## Impostare il Fuso Orario

Dobbiamo assicurarci che questo sia impostato correttamente, sia per il sistema che per PHP. Puoi trovare una lista di impostazioni di fuso orario valide per PHP [qui](https://php.net/manual/en/timezones.php). Per esempio, per il fuso orario italiano, una voce comune sarebbe "Europe/Rome". Iniziamo modificando il file php.ini:

`vi /etc/php.ini`

Trovate la linea `date.timezone` e modificatela. Nota che è commentato, quindi rimuovi il ";" dall'inizio della linea e aggiungi il tuo fuso orario dopo il segno "=". Per il nostro esempio di fuso orario italiano useremo:

`date.timezone = Europe/Rome`

Salvate le modifiche e uscite dal file php.ini.

Dobbiamo anche assicurarci che il fuso orario del sistema sia corretto. Di nuovo, usando il nostro fuso orario italiano come esempio, lo faremmo con:

`timedatectl set-timezone Europe/Rome`

## Impostazione di MariaDB

Prima di addentrarci nella configurazione del database necessaria per LibreNMS, eseguite la procedura [MariaDB](../database/database_mariadb-server.md) e in particolare la sezione "Securing mariadb-server", e poi tornate qui per queste impostazioni specifiche. La prima cosa che dobbiamo fare è modificare il file mariadb-server.cnf:

`vi /etc/my.cnf.d/mariadb-server.cnf`

E aggiungere le seguenti righe alla sezione "[Mysqld]":

```
innodb_file_per_table=1
lower_case_table_names=0
```

Poi abilitare e riavviare il server mariadb:

```
systemctl enable mariadb
systemctl restart mariadb
```

Ora ottenete l'accesso a mariadb come utente root. Ricordatevi di usare la password che avete creato seguendo la sezione "Proteggere mariadb-server" che avete eseguito sopra:

`mysql -u root -p`

La prossima cosa che dobbiamo fare è fare alcune modifiche specifiche per LibreNMS. Con il comando qui sotto, ricordatevi di cambiare la password "password" con qualcosa di sicuro e documentatelo in un posto sicuro, come un gestore di password, in modo da riaverlo in seguito. Nel prompt di mysql fare:

```
CREATE DATABASE librenms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';
FLUSH PRIVILEGES;
```

Una volta fatto questo, digitate "exit" per uscire di nuovo da mariadb.

## Configurare PHP-FPM

Questa sezione è sostanzialmente invariata rispetto alla documentazione ufficiale. Per prima cosa, copiate il www.conf:

`cp /etc/php-fpm.d/www.conf /etc/php-fpm.d/librenms.conf`

Quindi modificate il file librenms.conf:

`vi /etc/php-fpm.d/librenms.conf`

Vicino alla parte superiore, aggiungete queste due righe per risolvere un problema di percorso per l'utente librenms che verrà fuori in seguito:

```
; Set the ENV path to fix broken Centos web page issue
env[PATH] = /usr/local/bin:/usr/bin:/bin
```

Cambiate "[www]" con ["librenms]"

Cambia l'utente e il gruppo in "librenms":

```
user = librenms
group = librenms
```

E infine cambiate la linea "listen" per riflettere un nome univoco:

`listen = /run/php-fpm-librenms.sock`

Salvare le modifiche e uscire dal file. Se questo è l'unico servizio web che verrà eseguito su questa macchina, sentitevi liberi di rimuovere il vecchio file www.conf che abbiamo copiato:

`rm -f /etc/php-fpm.d/www.conf`

## Configurare Apache

Normalmente, useremmo la procedura [Multi-Sito Apache](../web/apache-sites-enabled.md) per impostare qualsiasi servizio web, ma in questo caso, stiamo solo andando con la configurazione predefinita. Notate che se volete usare questa procedura, dovete semplicemente mettere il file di configurazione in /etc/httpd/sites-available e poi seguire la procedura per collegarlo a sites-enabled. La radice predefinita del documento, tuttavia, **non** sarebbe /var/www/sub-domains/librenms/html, ma invece sarebbe /opt/librenms/html.

Di nuovo, in questo caso non stiamo usando quella procedura e andiamo solo con la configurazione predefinita e suggerita. Per farlo, iniziate creando questo file:

`vi /etc/httpd/conf.d/librenms.conf`

E mettendo il seguente in quel file:

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

Dovresti anche rimuovere il vecchio sito predefinito, welcome.conf:

`rm /etc/httpd/conf.d/welcome.conf`

Infine, dobbiamo abilitare sia _httpd_ che _php-fpm_:

```
systemctl enable --now httpd
systemctl enable --now php-fpm
```
## SELinux

Notate che se non pensate di usare SELinux, saltate questo punto e andate alla prossima sezione. Questo potrebbe anche applicarsi se voi usate LibreNMS su un container che non supporta SELinux a livello di container, o non lo include di default.

Per impostare tutto con SELinux, avrete bisogno di un pacchetto aggiuntivo installato:

`dnf install policycoreutils-python-utils`

### Configurare i Contesti LibreNMS

Avrete bisogno di impostare i seguenti contesti perché LibreNMS funzioni correttamente con SELinux:

```
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/html(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/(logs|rrd|storage)(/.*)?'
restorecon -RFvv /opt/librenms
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_execmem 1
chcon -t httpd_sys_rw_content_t /opt/librenms/.env
```

### Permettere il fping

Create un file chiamato `http_fping.tt` ovunque e sarà installato tramite un comando più tardi. Il contenuto di questo file è:

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
Se incontrate problemi e sospettate che possano essere dovuti a un problema di SELinux, eseguite quanto segue:

`audit2why < /var/log/audit/audit.log`

## Configurazione del firewall

Includeremo le istruzioni di _firewalld_ dalla documentazione ufficiale, tuttavia useremo _iptables_ nel laboratorio, quindi includeremo anche quelle istruzioni. Per usare _iptables_ seguite semplicemente [questa procedura](../security/enabling_iptables_firewall.md) e poi usate lo script _iptables_ trovato in questa procedura, e fate delle modifiche per la vostra rete.

### firewalld

Il comando da usare per consentire le regole _firewalld_ è il seguente:

```
firewall-cmd --zone public --add-service http --add-service https
firewall-cmd --permanent --zone public --add-service http --add-service https
```

L'autore ha problemi con la natura semplicistica di _firewalld_. Questa regola permette ai vostri servizi web di essere aperti al mondo, ma è quello che volete per un server di monitoraggio?  Direi che di solito **non** è così. Preferisco le regole di _iptables_, perché è facile vedere a colpo d'occhio ciò che si permette.

### iptables

Creare uno script da eseguire per aggiungere e modificare le regole del firewall chiamato firewall.conf e metterlo in /etc

`vi /etc/firewall.conf`

Inserite nel file quanto segue, sostituendo gli indirizzi IP della vostra rete come necessario. Questo script permette UDP, SSH, HTTP e HTTPS dalla rete locale del laboratorio, 192.168.1.0/24. Permette anche ICMP tipo 8 (che sta per "Echo Request" o più comunemente "ping") dal nostro gateway di rete, 192.168.1.2:

```
#!/bin/sh
#
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 443 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.2 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

Rendere lo script eseguibile:

`chmod +x /etc/firewall.conf`

Eseguire lo script:

`/etc/firewall.conf`

Supponendo che non ci siano errori, dovresti essere pronto a partire.

## Abilitare il Collegamento Simbolico e il Completamento Automatico della scheda per i Comandi lnms

Per prima cosa, abbiamo bisogno di un collegamento simbolico al nostro comando _lnms_ in modo che possa essere eseguito da qualsiasi luogo:

`ln -s /opt/librenms/lnms /usr/bin/lnms`

Poi, abbiamo bisogno di impostarlo per il completamento automatico:

`cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/`

## Configurare snmpd

_SNMP_ sta per "Simple Network Management Protocol" ed è usato in molti programmi di monitoraggio per estrarre dati. Nella versione 2, che stiamo usando qui, si tratta di una "stringa di comunità" che è specifica per il vostro ambiente. Dovrete assegnare questa "stringa di comunità" ai vostri dispositivi di rete che volete monitorare in modo che _snmpd_ (la "d" qui sta per il demone) sia in grado di trovarla. Se la vostra rete esiste da un po' di tempo, potreste già avere una "stringa di comunità" che state usando.

Per prima cosa, copiate il file snmp.conf da LibreNMS:

`cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf`

Poi, modificate questo file e cambiate la stringa di comunità da "RANDOMSTRINGGOESHERE" a qualunque sia la vostra stringa di comunità. Nel nostro esempio, lo cambiamo in "LABone":

`vi /etc/snmp/snmpd.conf`

e cambiare questa linea:

`com2sec readonly  default         RANDOMSTRINGGOESHERE`

a

`com2sec readonly  default         LABone`

Ora salvate le vostre modifiche e uscite.

## Automatizzare Con un Cron Job

Fate quanto segue:

`cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms`

## Rotazione del registro

LibreNMS creerà un grande insieme di registri nel tempo. Avrete bisogno di impostare la rotazione dei log per questo, in modo che non consumi troppo spazio su disco. Per farlo, basta fare ora quanto segue:

`cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms`

## Impostazione Web

Ora che abbiamo tutti i componenti installati e configurati, il nostro prossimo passo è finire l'installazione via web. Nella nostra versione di laboratorio, non abbiamo impostato nessun hostname, quindi per finire la configurazione, abbiamo bisogno di andare al server web per indirizzo IP. L'IP della nostra macchina di laboratorio è 192.168.1.140, quindi abbiamo bisogno di fare quanto segue in un browser web per finire l'installazione:

`http://192.168.1.140/librenms`

Supponendo che tutto funzioni correttamente, dovresti essere reindirizzato ai controlli di pre-installazione. Supponendo che questi siano tutti segnati come verdi, allora dovremmo essere in grado di continuare.

![Precontrolli LibreNMS](../images/librenms_prechecks.png)

Ci sono quattro pulsanti sotto il logo LibreNMS. Il primo pulsante a sinistra è per i controlli preliminari. Il nostro prossimo pulsante è per il database. Avrete bisogno della password che avete impostato in precedenza nel processo per l'utente del database "librenms". Se hai seguito diligentemente, allora l'hai salvato in un posto sicuro. Vai avanti e clicca sul pulsante "Database". Il "User" e la "Password" dovrebbero essere tutto ciò che è necessario compilare qui. Una volta fatto questo, clicca sul pulsante "Check Credentials".

![Database LibreNMS](../images/librenms_configure_database.png)

Una volta cliccato, se torna verde, allora sei pronto a cliccare sul pulsante "Build Database".

![Stato del database di LibreNMS](../images/librenms_configure_database_status.png)

Una volta completato, il terzo pulsante sarà attivo, che è "Create Admin User", quindi vai avanti e clicca su questo. Ti verrà richiesto un nome utente per l'amministratore. Nel nostro laboratorio useremo semplicemente "admin" e una password per questo utente. Assicurati che la password sia sicura e, di nuovo, registrala in un posto sicuro, come un gestore di password. Dovrai anche inserire l'indirizzo e-mail dell'utente amministrativo. Una volta che tutto questo è stato completato, basta cliccare sul pulsante "Add User".

![Utente amministrativo di LibreNMS](../images/librenms_administrative_user.png)

Una volta fatto questo, vi troverete di fronte a una schermata di "Finish Install" Dovrebbe rimanere solo una voce per finire l'installazione ed è una linea che ti chiede di "validate your install"". Clicca sul link. Una volta che hai fatto questo e tutto è andato a buon fine, sarai reindirizzato alla pagina di login. Accedi con il tuo utente amministrativo e la tua password.

## Aggiungere dispositivi

Di nuovo, uno dei nostri presupposti era che state usando SNMP v2. Ricorda che ogni dispositivo che aggiungi deve essere membro della tua stringa di comunità. Qui aggiungiamo due dispositivi come esempi. Una workstation Ubuntu e un server CentOS. Molto probabilmente avrete switch gestiti, router e altri dispositivi da aggiungere. L'autore può dirvi per esperienza passata che l'aggiunta di switch e router tende ad essere molto più facile dell'aggiunta di stazioni di lavoro e server, che è il motivo per cui stiamo usando questi come esempi.

### Impostazione della Stazione di Lavoro Ubuntu

Per prima cosa, installate _snmpd_ sulla workstation mentre aggiornate anche i pacchetti, giusto per essere sicuri:

`sudo update && sudo apt-get upgrade && sudo apt-get install snmpd`

Successivamente, è necessario modificare il file snmpd.conf:

`sudo vi /etc/snmpd/snmpd.conf`

Vai avanti e trova le linee che descrivono la tua stazione di lavoro e cambiale con cose che identificano la stazione di lavoro. Queste linee sono mostrate qui sotto:

```
sysLocation    Desktop
sysContact     Username <user@mydomain.com>
```

Per impostazione predefinita, quando si installa snmpd su Ubuntu, si associa solo all'indirizzo locale. Non ascolta l'indirizzo IP della vostra macchina. Questo non permetterà a LibreNMS di connettersi ad esso. Dobbiamo commentare questa linea:

`agentaddress  127.0.0.1,[::1]`

E aggiungete una nuova linea che assomiglia a quella che segue qui: (In questo esempio, l'indirizzo IP della nostra workstation è 192.168.1.122 e la porta UDP che stiamo impostando è "161")

`agentAddress udp:127.0.0.1:161,udp:192.168.1.122:161`

Successivamente, abbiamo bisogno di specificare la stringa della comunità di accesso in sola lettura. Trova le linee sottostanti e commentale. (si noti che le mostriamo come commentate qui sotto):

```
#rocommunity public default -V systemonly
#rocommunity6 public default -V systemonly
```

Poi, aggiungete una nuova linea:

`rocommunity LABone`

Ora salvate le vostre modifiche e uscite.

Abilita e avvia _snmpd_:

```
sudo systemctl enable snmpd
sudo systemctl start snmpd
```

Se stai usando un firewall sulle tue stazioni di lavoro interne, allora dovrai modificare il firewall per permettere il traffico UDP dal server di monitoraggio o dalla rete. LibreNMS vuole anche essere in grado di "pingare" il vostro dispositivo, quindi assicuratevi che la porta 8 di icmp sia consentita dal server.

### Configurazione del server CentOS o Rocky Linux

Diamo per scontato che qui siate root o che possiate fare _sudo_ per diventarlo. Per prima cosa, abbiamo bisogno di installare alcuni pacchetti:

`dnf installare net-snmp net-snmp-utils`

Successivamente, vogliamo creare un file snmpd.conf. Piuttosto che cercare di navigare nel file che è incluso, spostate questo file per rinominarlo, e create un nuovo file vuoto:

`mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig`

e

`vi /etc/snmp/snmpd.conf`

Poi copiate il seguente nel nuovo file:

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

CentOS e Rocky usano una convenzione di mappatura per dirigere le cose. Il file qui sopra è commentato bene in modo da poter imparare cosa sta succedendo, ma non include tutto il disordine del file originale.

Una volta fatte le modifiche, salvatele e uscite dal file.

Ora abbiamo bisogno di abilitare e avviare _snmpd_:

```
systemctl enable snmpd
systemctl start snmpd
```

#### Firewall

Se state eseguendo un server, allora **state** eseguendo un firewall, giusto?  Stiamo assumendo _iptables_ come notato sopra, quindi abbiamo bisogno di modificare la nostra configurazione del firewall, (in questo caso, /etc/firewall.conf) e aggiungere l'accesso per il traffico UDP e ICMP proveniente dal server di monitoraggio. Se state eseguendo _firewalld_, sostituite semplicemente le regole appropriate per _firewalld_. Ecco un set di regole per il nostro server di esempio:

```
#!/bin/sh
#
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
iptables -A INPUT -p icmp --icmp-type 8 -s 192.168.1.140 -j ACCEPT
iptables -A INPUT -p udp -m udp -s 192.168.1.140 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

Se siete nuovi a questo particolare concetto di _iptables_, il file /etc/firewall.conf è eseguibile, ed è il nostro modo di fare modifiche alle regole _iptables_ salvate che saranno ripristinate all'avvio. Nell'esempio precedente, stiamo permettendo il traffico "ping" e UDP dal nostro server di monitoraggio e SSH dalla nostra rete locale. Molte altre regole possono essere necessarie per le funzioni del vostro server, forse regole http o per permettere regole per la porta mysql, ecc. Una volta apportate le modifiche a /etc/firewall.conf, eseguitelo con:

`/etc/firewall.conf`

## Aggiungere i Dispositivi in Librenms

Ora che i nostri dispositivi di esempio sono configurati per accettare il traffico snmp dal nostro server LibreNMS, il prossimo passo è quello di aggiungere questi dispositivi in LibreNMS. Presumiamo che abbiate l'interfaccia web di LibreNMS aperta, e se è così, vi mostrerà che non avete dispositivi aggiunti e vi chiederà di aggiungerne uno. Quindi vai avanti e fallo. Una volta che hai cliccato per aggiungere un dispositivo, ti troverai di fronte a questa schermata:

![LibreNMS Aggiungi Dispositivo](../images/librenms_add_device.png)

Mettete le informazioni che abbiamo usato per i nostri dispositivi di prova. Nel nostro caso, stiamo usando l'IP della workstation Ubuntu da avviare, nel nostro esempio è 192.168.1.122. L'unica altra cosa che dovremo aggiungere qui è la stringa della comunità nel campo "Community", quindi dovremmo digitare "LABone" qui. Ora clicca sul pulsante "Add Device". Supponendo che tu abbia fatto tutto correttamente quando hai aggiunto il dispositivo, il tuo dispositivo dovrebbe essere aggiunto con successo. Se si verifica un errore di aggiunta, rivedete la configurazione SNMP per la stazione di lavoro o il firewall, se esiste. Quindi ripetiamo il processo "Add Device" per il nostro server CentOS.

## Ottenere Avvisi

Come abbiamo detto dall'inizio, questo documento vi farà solo iniziare con LibreNMS. Ci sono un gran numero di elementi di configurazione aggiuntivi, una vasta API (Application Programming Interface), un sistema di avvisi che fornisce un numero enorme di opzioni per la consegna, chiamato "Transports", e molto altro.  Non creeremo nessuna regola di allarme, ma invece modificheremo la regola di allarme integrata "Device Down! Due to no ICMP response" che è preconfigurata fuori dalla scatola, e per "Trasports" ci atteniamo a "Mail", che è solo email. Sappiate che non siete limitati.

Per poter utilizzare la posta elettronica per il nostro trasporto, però, dobbiamo avere la posta funzionante sul nostro server. Per farlo, useremo questa [procedura Postfix](../email/postfix_reporting.md). Esegui questa procedura per configurare postfix in modo che identifichi correttamente la provenienza dei messaggi, ma puoi fermarti dopo il processo di configurazione e tornare qui.

### Transport

Abbiamo bisogno di un modo per inviare i nostri avvisi. Come notato in precedenza, LibreNMS supporta un numero enorme di trasporti. Faremo il nostro allarme via e-mail, che è definito come il trasporto "Mail". Per impostare il trasporto:

1. Vai al cruscotto
2. Fai passare il tuo mouse su "Alerts"
3. Vai giù a "Alert Transports" e clicca su di esso
4. Cliccate sul pulsante "Create alert transport" (Notate il pulsante "Create transport group"). Puoi usarlo per far arrivare gli avvisi a diverse persone)
5. Nel campo "Transport name:", digitare "Alert By Email"
6. Nel campo "Transport type:", usare il menu a tendina per selezionare "Mail"
7. Assicurati che il campo "Default alert:" sia impostato su "On"
8. Nel campo "Email:", scrivi l'indirizzo email dell'amministratore

### Organizzare i Dispositivi in Gruppi

Il modo migliore per impostare gli avvisi è quello di organizzare prima i tuoi dispositivi in un ordine logico. Attualmente, abbiamo una stazione di lavoro e un server in dispositivi. Anche se normalmente non vorremmo organizzare le due cose insieme, lo faremo per questo esempio. Tenete presente che il nostro esempio è anche ridondante, poiché esiste un gruppo "All Devices" che funzionerebbe anche per questo. Per impostare un gruppo di dispositivi:

1. Vai al cruscotto
2. Fai passare il tuo mouse su "Devices"
3. Vai giù a "Manage Groups" e clicca su di esso
4. Clicca sul pulsante "+ New Device Group"
5. Nel campo "Name", scrivere "ICMP Group"
6. Nel campo della descrizione scrivi quello che pensi possa aiutare a descrivere il gruppo
7. Cambiare il campo "Type" da "Dynamic" a "Static"
8. Aggiungi entrambi i dispositivi al campo "Select Devices" e poi salva le tue modifiche

### Impostare le Regole di Allarme

Ora che abbiamo impostato il trasporto e il gruppo di dispositivi, configuriamo la regola di allarme. Per impostazione predefinita, LibreNMS ha diverse regole di allarme già create per voi:

1. Vai al cruscotto
2. Fai passare il tuo mouse su "Alerts"
3. Vai giù a "Alert Rules" e cliccaci sopra
4. La regola attiva in alto sul display sarà "Device Down! Due to no ICMP response." Vai su "Action" (colonna all'estrema destra) e clicca sull'icona della matita per modificare la regola.
5. Lascia tutti i campi in alto così come sono e vai giù al campo "Match devices, groups and locations list:" e clicca dentro il campo
6. Selezionare "ICMP Group" dalla lista
7. Assicurarsi che il campo "All devices except in list:" sia "Off"
8. Clicca all'interno del campo "Transports:" e seleziona "Mail: Alert By Email" e salva la tua regola.

Prima di salvare, la vostra regola dovrebbe avere un aspetto simile a questo:

![Regola di Allarme di LibreNMS](../images/librenms_alert_rule.png)

Questi due dispositivi dovrebbero ora avvisarti via e-mail se sono fuori uso e quando si ristabiliscono.

## Conclusioni

LibreNMS è un potente strumento di monitoraggio con un set completo di funzioni in un'unica applicazione. Abbiamo _appena_ scalfito la superficie delle capacità. Non vi abbiamo mostrato alcune delle schermate più ovvie. Per esempio, non appena si aggiungono dispositivi, supponendo che tutte le proprietà SNMP siano impostate correttamente, si inizierà a ricevere i grafici di larghezza di banda, utilizzo della memoria e utilizzo della CPU di ogni dispositivo. Non vi abbiamo mostrato la ricchezza dei trasporti disponibili oltre alla "Mail". Detto questo, vi abbiamo mostrato abbastanza in questo documento per iniziare a monitorare il vostro ambiente. LibreNMS richiede un po' di tempo per padroneggiare tutti gli elementi. Dovreste visitare l'[eccellente documentazione](https://docs.librenms.org/) del progetto per ulteriori informazioni.
