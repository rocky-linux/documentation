---
title: Server DokuWiki
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - wiki
  - documentation
---

## Prerequisiti e presupposti

- Un'istanza di Rocky Linux installata su un server, un container o una macchina virtuale.
- Dimestichezza con la modifica dei file di configurazione dalla riga di comando con un editor (gli esempi qui riportati utilizzano `vi`, ma è possibile sostituirlo con il proprio editor preferito)
- Conoscenza delle applicazioni web e della loro configurazione
- Il nostro esempio utilizzerà [Apache Sites Enabled](../web/apache-sites-enabled.md) per l'impostazione. Se necessario, rivederlo.
- Questo documento utilizzerà "example.com" come nome di dominio in tutto il documento
- È necessario essere root o in grado di eseguire `sudo` per elevare i privilegi
- Tuttavia, supponendo una nuova installazione del sistema operativo, questo non è un requisito

## Introduzione

La documentazione può assumere diverse forme in un'organizzazione. Avere un repository a cui fare riferimento per la documentazione è inestimabile. Un wiki (che in hawaiano significa _veloce_) è un modo per conservare documentazione, note sui processi, basi di conoscenza aziendale e persino esempi di codice in un unico luogo centralizzato. I professionisti IT che tengono un wiki, anche di nascosto, hanno una polizza assicurativa integrata contro la dimenticanza di una routine oscura.

DokuWiki è un wiki maturo e veloce che funziona senza database, ha funzioni di sicurezza integrate e non è complesso da distribuire. Per ulteriori informazioni, consultate la loro [pagina web](https://www.dokuwiki.org/dokuwiki).

DokuWiki è uno dei tanti wiki disponibili, anche se è un buon wiki. Un grande vantaggio è che DokuWiki è relativamente leggero e può essere eseguito su un server in cui sono già in esecuzione altri servizi, a condizione che si disponga di spazio e memoria.

## Installazione delle Dipendenze

La versione minima di PHP per DokuWiki è ora 8. Rocky Linux 10 ha PHP 8.3 come impostazione predefinita. Si noti che alcuni dei pacchetti elencati potrebbero già esistere:

```bash
dnf install tar wget httpd php php-gd php-xml php-json php-mbstring
```

Accettare e installare tutte le dipendenze aggiuntive elencate che vengono fornite con questi pacchetti.

## Creare directory e modificare la configurazione

### Configurazione di Apache

Se si è letta la procedura [Apache Sites Enabled](../web/apache-sites-enabled.md), sapete che è necessario creare alcune directory. Iniziare con aggiungere alla directory di configurazione _htpd_:

```bash
mkdir -p /etc/httpd/{sites-available,sites-enabled}
```

È necessario modificare il file `httpd.conf`:

```bash
vi /etc/httpd/conf/httpd.conf
```

Aggiungetelo in fondo al file:

```bash
Include /etc/httpd/sites-enabled
```

Creare il file di configurazione del sito in sites-available:

```bash
vi /etc/httpd/sites-available/com.example
```

Il file di configurazione sarà simile a questo:

```apache
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

Si noti che "AllowOverride All" consente il funzionamento del file `.htaccess` (sicurezza specifica della directory).

Procedere con il collegamento del file di configurazione in sites-enabled, ma non avviare ancora i servizi web:

```bash
ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/
```

### Apache _DocumentRoot_

È necessario creare la _DocumentRoot_. Per farlo eseguire:

```bash
mkdir -p /var/www/sub-domains/com.example/html
```

## Installazione di DokuWiki

Nel server, passare alla root directory.

```bash
cd /root
```

Scarica l'ultima versione stabile di DokuWiki. Puoi trovarla andando alla [pagina di download](https://download.dokuwiki.org/). Sul lato sinistro della pagina, sotto “Versione”, si vedrà “Stabile (consigliata) (link diretto)”.

Cliccare con il tasto destro del mouse su "(link diretto)" e copiare il link. Nella console del vostro server DokuWiki, digitate `wget` e uno spazio e poi incollate il link copiato nel terminale. Si dovrebbe ottenere qualcosa di simile a questo:

```bash
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
```

Prima di decomprimere l'archivio, esaminare il contenuto con `tar ztf`:

```bash
tar ztvf dokuwiki-stable.tgz
```

Notate il nome della directory datata davanti a tutti gli altri file che hanno un aspetto simile a questo:

```text
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```

Non si vuole che questa directory con nome principale venga decompressa durante la decompressione dell'archivio, quindi si useranno alcune opzioni con `tar` per escluderla. La prima opzione è “--strip-components=1” che rimuove la directory principale. La seconda opzione è l'opzione “-C”, che indica a `tar` dove si vuole decomprimere l'archivio. La decompressione sarà simile a questa:

```bash
tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/
```

Una volta eseguito questo comando, tutto DokuWiki dovrebbe trovarsi nella _DocumentRoot_.

È necessario fare una copia del file `.htaccess.dist` fornito con DokuWiki e conservare quello vecchio, nel caso in cui sia necessario tornare all'originale.

In questo processo, il nome del file verrà modificato in `.htaccess`. Questo è ciò che _apache_ cercherà. Per ottenere questo:

```bash
cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}
```

È necessario cambiare la proprietà della nuova directory e dei suoi file all'utente e al gruppo _apache_:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.example/html
```

## Impostazione del DNS o di `/etc/hosts`

Prima di poter accedere all'interfaccia di DokuWiki, è necessario impostare il nome per questo sito. È possibile utilizzare il file `/etc/hosts` a scopo di test.

In questo esempio, supponiamo che DokuWiki venga eseguito su un indirizzo IPv4 privato di 10.56.233.179. Supponiamo che tu stia modificando anche il file `/etc/hosts` su una workstation Linux. Per farlo, eseguire:

```bash
sudo vi /etc/hosts
```

Modificate quindi il file host in modo che abbia un aspetto simile a questo (notare l'indirizzo IP sopra nell'esempio):

```bash
127.0.0.1 localhost
127.0.1.1 myworkstation-home
10.56.233.179 example.com     example

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Una volta terminati i test e pronti a rendere il tutto live, è necessario aggiungere questo host a un server DNS. Si può utilizzare un [Server DNS privato](../dns/private_dns_server_using_bind.md) o un server DNS pubblico.

## Avviare `httpd`

Prima di avviare <`httpd`, verificare che la configurazione sia corretta:

```bash
httpd -t
```

Dovresti ottenere:

```text
Syntax OK
```

In caso affermativo, si dovrebbe essere pronti ad avviare `httpd` e a terminare la configurazione. Iniziare abilitando `htpd` all'avvio:

```bash
systemctl enable httpd
```

Quindi avviarlo:

```bash
systemctl start httpd
```

## Testare DokuWiki

Il passo successivo consiste nell'aprire un browser web e digitare questo indirizzo nella barra degli indirizzi:

<http://example.com/install.php>

Si accede così alla schermata di impostazione:

- Nel campo "Nome del wiki", digitare il nome del vostro wiki. Esempio "Documentazione tecnica"
- Nel campo "Superuser", digitare il nome utente amministrativo. Esempio "admin"
- Nel campo " Real name", digitare il nome reale dell'utente amministrativo.
- Nel campo "E-Mail", digitare l'indirizzo e-mail dell'utente amministrativo.
- Nel campo "Password", digitare la password sicura dell'utente amministrativo.
- Nel campo "once again", digitare nuovamente la stessa password.
- Nel menu a tendina "Initial ACL Policy", scegliere l'opzione più adatta all'ambiente
- Scegliere la casella di controllo appropriata della licenza sotto la quale si desidera inserire i propri contenuti
- Lasciare selezionata o deselezionare la casella di controllo "Una volta al mese, invia i dati anonimi di utilizzo agli sviluppatori di DokuWiki"
- Fare clic sul pulsante "Salva"

Il wiki è ora pronto per l'aggiunta di contenuti.

## Mettere in sicurezza DokuWiki

Oltre alla politica ACL appena creata, considerate quanto segue:

### Il tuo firewall `firewalld`

!!! note

    Questo esempio di firewall non tiene conto di quali altri servizi sia necessario consentire sul server DokuWiki. Queste regole si basano sull'ambiente di test e si occupano **SOLO** di consentire l'accesso a un blocco IP di rete LOCALE. Avrete bisogno di consentire più servizi per un server di produzione.

Prima di definire il tutto, è necessario pensare alla sicurezza. Innanzitutto, il server dovrebbe essere dotato di un firewall.

Il presupposto è che chiunque si trovi sulla rete 10.0.0.0/8 sia sulla vostra rete locale privata e che queste siano le uniche persone che devono accedere al sito.

Se si utilizza `firewalld` come firewall, utilizzare la seguente sintassi di regole:

```bash
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Una volta aggiunte le regole di cui sopra e ricaricato il servizio `firewalld`, elencare la zona per assicurarsi che ci sia tutto ciò che serve:

```bash
firewall-cmd --zone=trusted --list-all
```

L'aspetto sarà simile a questo, se tutto funziona correttamente:

```bash
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

### SSL/TLS

Per garantire la massima sicurezza, è consigliabile utilizzare un protocollo SSL/TLS per crittografare il traffico web. È possibile acquistare un certificato SSL/TLS da un provider SSL/TLS oppure utilizzare [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).

## Conclusione

Che tu debba documentare processi, politiche aziendali, codice di programmazione o altro, un wiki è un ottimo strumento per farlo. DokuWiki è un prodotto sicuro, flessibile e facile da usare, semplice da installare e implementare. È anche un progetto stabile che esiste da molti anni.
