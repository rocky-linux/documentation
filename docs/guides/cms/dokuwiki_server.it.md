---
title: DokuWiki
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - wiki
  - documentation
---

# Server DokuWiki

## Prerequisiti E Presupposti

* Un'istanza di Rocky Linux installata su un server, un container o una macchina virtuale.
* Abilità nel modificare i file di configurazione dalla riga di comando con un editor (i nostri esempi utilizzeranno _vi_, ma potete sostituire il vostro editor preferito).
* Conoscenza delle applicazioni web e della loro configurazione.
* Il nostro esempio utilizzerà [Apache Sites Enabled](../web/apache-sites-enabled.md) per l'impostazione, quindi è una buona idea rivedere questa routine se si intende seguirla.
* In questo esempio utilizzeremo "example.com" come nome di dominio.
* In questo documento si presuppone che siate l'utente root o che possiate arrivarci con _sudo_.
* Si presuppone una nuova installazione del sistema operativo, ma questo **NON** è un requisito.

## Introduzione

La documentazione può assumere diverse forme in un'organizzazione. Avere un repository a cui fare riferimento per la documentazione è inestimabile. Un wiki (che in hawaiano significa _veloce_ ) è un modo per conservare in una posizione centralizzata la documentazione, le note di processo, le basi di conoscenza aziendale e persino gli esempi di codice. I professionisti IT che mantengono un wiki, anche di nascosto, hanno una polizza assicurativa incorporata contro la dimenticanza di una routine oscura.

DokuWiki è un wiki maturo, veloce, che funziona senza database, ha funzioni di sicurezza integrate ed è relativamente facile da distribuire. Per ulteriori informazioni su cosa può fare DokuWiki, consultate la sua [pagina web](https://www.dokuwiki.org/dokuwiki).

DokuWiki è solo uno dei tanti wiki disponibili, anche se è piuttosto buono. Un grande vantaggio è che DokuWiki è relativamente leggero e può essere eseguito su un server in cui sono già in esecuzione altri servizi, a condizione che si disponga di spazio e memoria.

## Installazione delle Dipendenze

La versione minima di PHP per DokuWiki è ora la 7.2, che è esattamente quella con cui Rocky Linux 8 viene fornito. Rocky Linux 9.0 è fornito della versione 8.0 di PHP, anch'essa pienamente supportata. Qui si specificano pacchetti che potrebbero essere già installati:

`dnf install tar wget httpd php php-gd php-xml php-json php-mbstring`

Verrà visualizzato un elenco di dipendenze aggiuntive che verranno installate e questo prompt:

`Is this ok [y/N]:`

Rispondete con "y" e premete "Invio" per installare.

## Creare Directory e Modificare la Configurazione

### Configurazione di Apache

Se avete letto la procedura [Apache Sites Enabled](../web/apache-sites-enabled.md), sapete che è necessario creare alcune directory. Inizieremo con le aggiunte alla directory di configurazione _httpd_:

`mkdir -p /etc/httpd/{sites-available,sites-enabled}`

È necessario modificare il file httpd.conf:

`vi /etc/httpd/conf/httpd.conf`

E aggiungete questo in fondo al file:

`Include /etc/httpd/sites-enabled`

Creare il file di configurazione del sito in sites-available:

`vi /etc/httpd/sites-available/com.example`

Il file di configurazione dovrebbe essere simile a questo:

```
<VirtualHost *>
    ServerName    example.com
    DocumentRoot  /var/www/sub-domains/com.example/html

    <Directory ~ "/var/www/sub-domains/com.example/html/(bin/|conf/|data/|inc/)">
        <IfModule mod_authz_core.c>
                AllowOverride All
            Require all denied
        </IfModule>
        <IfModule !mod_authz_core.c>
            Order allow,deny
            Deny from all
        </IfModule>
    </Directory>

    ErrorLog   /var/log/httpd/example.com_error.log
    CustomLog  /var/log/httpd/example.com_access.log combined
</VirtualHost>
```

Si noti che l'opzione "AllowOverride All" di cui sopra consente al file .htaccess (sicurezza specifica della directory) di funzionare.

Procedere con il collegamento del file di configurazione in sites-enabled, ma non avviare ancora i servizi web:

`ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/`

### Apache DocumentRoot

Dobbiamo anche creare la nostra _DocumentRoot_. Per ora fare:

`mkdir -p /var/www/sub-domains/com.example/html`

## Installazione di DokuWiki

Nel server, passare alla root directory.

`cd /root`

Ora che il nostro ambiente è pronto, prendiamo l'ultima versione stabile di DokuWiki. Potete trovarlo andando alla [pagina di download](https://download.dokuwiki.org/) e sul lato sinistro della pagina, alla voce "Version", vedrete "Stable (Recommended) (direct link)."

Fare clic con il tasto destro del mouse sulla parte "(link diretto)" e copiare l'indirizzo del link. Nella console del vostro server DokuWiki, digitate "wget" e uno spazio e poi incollate il link copiato nel terminale. Dovresti ottenere qualcosa di simile:

`wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`

Prima di decomprimere l'archivio, si può dare un'occhiata al contenuto usando `tar ztf` per vedere il contenuto dell'archivio:

`tar ztvf dokuwiki-stable.tgz`

Notate la directory datata che precede tutti gli altri file e che ha un aspetto simile a questo?

```
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```
Non vogliamo che questa directory venga decompressa quando decomprimiamo l'archivio, quindi useremo alcune opzioni con tar per escluderla. La prima opzione è "--strip-components=1" che rimuove la directory principale.

La seconda opzione è l'opzione "-C", che indica a tar dove si vuole decomprimere l'archivio. Quindi decomprimere l'archivio con questo comando:

`tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/`

Una volta eseguito questo comando, tutto DokuWiki dovrebbe trovarsi nella nostra _DocumentRoot_.

È necessario fare una copia del file _.htaccess.dist_ fornito con DokuWiki e conservare anche quello vecchio, nel caso in cui si debba tornare all'originale in futuro.

Nel processo, cambieremo il nome di questo file in _.htaccess_, che è quello che _apache_ cercherà. Per ora fare:

`cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}`

Ora dobbiamo cambiare la proprietà della nuova directory e dei suoi file all'utente e al gruppo _apache_:

`chown -Rf apache.apache /var/www/sub-domains/com.example/html`

## Impostazione del DNS o di /etc/hosts

Prima di poter accedere all'interfaccia di DokuWiki, è necessario impostare la risoluzione dei nomi per questo sito. A scopo di test, è possibile utilizzare il file _/etc/hosts_.

In questo esempio, supponiamo che DokuWiki venga eseguito su un indirizzo IPv4 privato di 10.56.233.179. Supponiamo anche che si stia modificando il file _/etc/hosts_ su una workstation Linux. Per farlo, eseguire:

`sudo vi /etc/hosts`

Quindi modificate il vostro file hosts in modo che assomigli a questo (notare l'indirizzo IP in alto nell'esempio seguente):

```
127.0.0.1   localhost
127.0.1.1   myworkstation-home
10.56.233.179   example.com     example 

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Una volta terminati i test e pronti a rendere il tutto operativo per tutti, sarà necessario aggiungere questo host a un server DNS. Si può utilizzare un [server DNS privato](../dns/private_dns_server_using_bind.md) o un server DNS pubblico.

## Avviare httpd

Prima di avviare _httpd_, facciamo un test per verificare che la nostra configurazione sia corretta:

`httpd -t`

Dovresti ottenere:

`Syntax OK`

In caso affermativo, si dovrebbe essere pronti ad avviare _httpd_ e a terminare la configurazione. Iniziamo abilitando l'avvio di _httpd_ all'avvio del sistema:

`systemctl enable httpd`

E poi avviarlo:

`systemctl start httpd`

## Testare DokuWiki

Ora che il nostro nome host è stato impostato per il test e il servizio Web è stato avviato, il passo successivo è aprire un browser Web e digitare questo nella barra degli indirizzi:

`http://example.com/install.php`

O

`http://example.com/install.php`

Entrambi dovrebbero funzionare se si imposta il file hosts come sopra. In questo modo si accede alla schermata di impostazione per completare la configurazione:

* Nel campo "Nome del wiki", digitare il nome del nostro wiki. Esempio "Documentazione tecnica"
* Nel campo "Superuser", digitare il nome utente amministrativo. Esempio "admin"
* Nel campo " Real name", digitare il nome reale dell'utente amministrativo.
* Nel campo "E-Mail", digitare l'indirizzo e-mail dell'utente amministrativo.
* Nel campo "Password", digitare la password sicura dell'utente amministrativo.
* Nel campo "once again", digitare nuovamente la stessa password.
* Nel menu a discesa " Initial ACL Policy", scegliere l'opzione più adatta al proprio ambiente.
* Scegliere la casella di controllo appropriata della licenza sotto la quale si desidera inserire il contenuto.
* Lasciare selezionata o deselezionare la casella di controllo "Una volta al mese, invia i dati anonimi di utilizzo agli sviluppatori di DokuWiki"
* Fare clic sul pulsante "Salva"

Il wiki è ora pronto per l'aggiunta di contenuti.

## Mettere in sicurezza DokuWiki

Oltre al criterio ACL appena creato, si consideri che:

### Il vostro firewall

!!! note "Nota"

    Nessuno di questi esempi di firewall fa alcuna ipotesi su quali altri servizi sia necessario consentire sul server Dokuwiki. Queste regole sono basate sul nostro ambiente di test e si occupano **SOLO** di consentire l'accesso a un blocco ip di rete LOCALE. È necessario un numero maggiore di servizi consentiti per un server di produzione.

Prima di definire il tutto, è necessario pensare alla sicurezza. Innanzitutto, il server dovrebbe essere dotato di un firewall. Si presume che si stia utilizzando uno dei firewall indicati di seguito.

Invece di consentire a tutti l'accesso al wiki, assumeremo che chiunque si trovi sulla rete 10.0.0.0/8 sia sulla vostra rete locale privata e che queste siano le uniche persone che hanno bisogno di accedere al sito.

#### `iptables` Firewall (deprecato)

!!! warning "Attenzione"

    Il processo del firewall `iptables` qui è stato deprecato in Rocky Linux 9. (ancora disponibile, ma probabilmente scomparirà nelle versioni future, forse già come Rocky Linux 9.1). Per questo motivo, si consiglia di passare alla procedura `firewalld` che segue se si sta eseguendo questa operazione su 9.0 o superiore.

Si noti che potrebbero essere necessarie altre regole per altri servizi su questo server e che questo esempio prende in considerazione solo i servizi web.

Per prima cosa, modificare o creare il file _/etc/firewall.conf:_

`vi /etc/firewall.conf`

```
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the default for OUTPUT is ACCEPT
#  The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
# web ports
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 443 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

Una volta creato lo script, assicuratevi che sia eseguibile:

`chmod +x /etc/firewall.conf`

Eseguire quindi lo script:

`/etc/firewall.conf`

Questo eseguirà le regole e le salverà in modo che vengano ricaricate al successivo avvio di _iptables_ o al boot.

#### `firewalld` Firewall

Se si usa `firewalld` come firewall (e a questo punto probabilmente si *dovrebbe*), si possono applicare gli stessi concetti usando la sintassi `firewall-cmd` di firewalld.

Duplicheremo le regole `iptables` (sopra) con `regole firewalld`:

```
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Una volta aggiunte le regole di cui sopra e ricaricato il servizio firewalld, elencare la zona per assicurarsi che ci sia tutto ciò che serve:

```
firewall-cmd --zone=trusted --list-all
```

che dovrebbe mostrarvi qualcosa del genere se tutto quanto sopra ha funzionato correttamente:

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.0.0.0/8
  services: http https
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

### SSL

Per una maggiore sicurezza, dovreste considerare l'utilizzo di un SSL, in modo che tutto il traffico web sia criptato. È possibile acquistare un SSL da un provider SSL o utilizzare [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).

## Conclusione

Che si tratti di documentare processi, politiche aziendali, codici di programma o altro, un wiki è un ottimo modo per farlo. DokuWiki è un prodotto sicuro, flessibile, facile da usare, relativamente semplice da installare e distribuire, ed è un progetto stabile che esiste da molti anni.  
