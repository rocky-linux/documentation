---
title: DISA Apache Web server STIG
author: Scott Shinn
contributors: Steven Spencer, Franco Colussi
tested_with: 8.6
tags:
  - DISA
  - STIG
  - security
  - enterprise
---

# Introduzione

Nella prima parte di questa serie abbiamo spiegato come costruire il nostro server web con la STIG RHEL8 DISA di base applicata e nella seconda parte abbiamo imparato a testare la conformità STIG con lo strumento OpenSCAP. Ora faremo qualcosa con il sistema, costruendo una semplice applicazione web e applicando il server web DISA STIG: https://www.stigviewer.com/stig/web_server/

Per prima cosa confrontiamo ciò che stiamo affrontando: la STIG DISA di RHEL 8 è indirizzata a una piattaforma molto specifica, quindi i controlli sono abbastanza facili da capire in quel contesto, da testare e da applicare.  Le STIG delle applicazioni devono essere portabili su più piattaforme, quindi il contenuto è generico per funzionare su diverse distribuzioni Linux (RHEL, Ubuntu, SuSE, ecc.) **. Ciò significa che strumenti come OpenSCAP non ci aiuteranno a verificare/rimediare la configurazione, dovremo farlo manualmente. Questi STIG sono:

* Apache 2.4 V2R5 - Server; che si applica al server web stesso
* Apache 2.4 V2R5 - Sito; Che si applica all'applicazione web/sito web

Per la nostra guida, creeremo un semplice server web che non fa altro che servire contenuti statici. Possiamo usare le modifiche apportate qui per creare un'immagine di base e poi usare questa immagine di base quando costruiamo server web più complessi in seguito.

## Avvio rapido del server Apache 2.4 V2R5

Prima di iniziare, è necessario fare riferimento alla Parte 1 e applicare il profilo di sicurezza DISA STIG. Considerate questo passo 0.

1.) Installare `apache` e `mod_ssl`

```
    dnf install httpd mod_ssl
```

2.) Modifiche alla configurazione

```
    sed -i 's/^\([^#].*\)**/# \1/g' /etc/httpd/conf.d/welcome.conf
    dnf -y remove httpd-manual
    dnf -y install mod_session

    echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-apache-stig.conf

    sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
    sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

  3.) Aggiornare i criteri del firewall e avviare `httpd`

```
    firewall-cmd --zone=public --add-service=https --permanent
    firewall-cmd --zone=public --add-service=https
    firewall-cmd --reload
    systemctl enable httpd
    systemctl start httpd
```

## Panoramica dei Controlli Dettagliati

Se siete arrivati fin qui, probabilmente siete interessati a saperne di più su ciò che la STIG vuole che facciamo. È utile capire l'importanza del controllo e quindi come si applica all'applicazione. A volte il controllo è tecnico (cambiare l'impostazione X in Y) e altre volte è operativo (come lo si usa).  In generale, un controllo tecnico è qualcosa che si può modificare con il codice, mentre un controllo operativo probabilmente no.

### Livelli

* Cat I - (ALTO) - 5 Controlli
* Cat II - (MEDIO) - 41 Controlli
* Cat III - (BASSO) - 1 Controlli

### Tipi

* Tecnico - 24 controlli
* Operativo - 23 controlli

In questo articolo non tratteremo il "perché" di queste modifiche, ma solo ciò che deve accadere se si tratta di un controllo tecnico.  Se non c'è nulla da modificare, come nel caso di un controllo Operational, il campo **Fix:** sarà vuoto. La buona notizia è che in molti di questi casi si tratta già dell'impostazione predefinita di Rocky Linux 8, quindi non è necessario cambiare nulla.

## Apache 2.4 V2R5 - Dettagli del Server

**(V-214248** ) Le directory, le librerie e i file di configurazione delle applicazioni del server Web Apache devono essere accessibili solo agli utenti privilegiati.

**Severity:** Cat I High  
**Type:** Operational  
**Fix:**  None, check to make sure only privileged users can access webserver files

**(V-214242)** Il server web Apache deve fornire opzioni di installazione per escludere l'installazione di documentazione, codice di esempio, applicazioni di esempio ed esercitazioni.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**

```
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214253)** Il server Web Apache deve generare un ID di sessione utilizzando la maggior parte possibile del set di caratteri per ridurre il rischio di brute force.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**  None, Fixed by default in Rocky Linux 8

**(V-214273** ) Il software del server Web Apache deve essere una versione supportata dal fornitore.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214271)** L'account utilizzato per eseguire il server Web Apache non deve avere una shell e una password di accesso valide.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214245)** Il server web Apache deve avere il Web Distributed Authoring (WebDAV) disabilitato. **Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214264)** Il server Web Apache deve essere configurato per integrarsi con l'infrastruttura di sicurezza dell'organizzazione.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, forward web server logs to SIEM


**(V-214243** ) Il server Web Apache deve avere le mappature delle risorse impostate per disabilitare il servizio di alcuni tipi di file.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:** None,  Fixed by default in Rocky Linux 8


**(V-214240** ) Il server web Apache deve contenere solo i servizi e le funzioni necessarie al funzionamento.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**


```
dnf remove httpd-manual
```

**(V-214238)** I moduli di espansione devono essere completamente rivisti, testati e firmati prima di poter esistere su un server web Apache di produzione.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, disable all modules not required for the application


**(V-214268)** I cookie scambiati tra il server Web Apache e il client, come i cookie di sessione, devono avere le proprietà dei cookie impostate in modo da impedire agli script lato client di leggere i dati dei cookie.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
dnf install mod_session 
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214269)** Il server web Apache deve rimuovere tutti i cifrari di esportazione per proteggere la riservatezza e l'integrità delle informazioni trasmesse.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:** None, Fixed by default in Rocky Linux 8 DISA STIG security Profile

**(V-214260)** Il server web Apache deve essere configurato per disconnettere o disabilitare immediatamente l'accesso remoto alle applicazioni ospitate.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, this is a procedure to stop the web server

**(V-214249** ) Il server web Apache deve separare le applicazioni ospitate dalla funzionalità di gestione del server web Apache ospitato.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, this is related to the web applications rather than the server

**(V-214246** ) Il server Web Apache deve essere configurato per utilizzare un indirizzo IP e una porta specifici.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, the web server should be configured to only listen on a specific IP / port

**(V-214247)** Gli account del server web Apache che accedono all'albero delle directory, alla shell o ad altre funzioni e utilità del sistema operativo devono essere solo account amministrativi.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, all files, and directories served by the web server need to be owned by administrative users, and not the web server user.

**(V-214244)** Il server Web Apache deve consentire la rimozione dei mapping agli script inutilizzati e vulnerabili.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, any cgi-bin or other Script/ScriptAlias mappings that are not used must be removed

**(V-214263** ) Il server web Apache non deve impedire la possibilità di scrivere il contenuto di un record di registro specificato su un server di registro di audit.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Work with the SIEM administrator to allow the ability to write specified log record content to an audit log server.

**(V-214228** ) Il server web Apache deve limitare il numero di richieste di sessione simultanee consentite.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214229)** Il server web Apache deve eseguire la gestione della sessione lato server.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
```

**(V-214266)** Il server web Apache deve vietare o limitare l'uso di porte, protocolli, moduli e/o servizi non sicuri o non necessari.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Ensure the website enforces the use of IANA well-known ports for HTTP and HTTPS.

**(V-214241** ) Il server Web Apache non deve essere un server proxy.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

**(V-214265)** Il server Web Apache deve generare record di log che possono essere mappati al Tempo Universale Coordinato (UTC)** o al Tempo Medio di Greenwich (GMT), con una granularità minima di un secondo.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214256** ) I messaggi di avviso e di errore visualizzati ai client devono essere modificati per minimizzare l'identità del server web Apache, delle patch, dei moduli caricati e dei percorsi delle directory.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** Use the "ErrorDocument" directive to enable custom error pages for 4xx or 5xx HTTP status codes.

**(V-214237** ) È necessario eseguire il backup dei dati e dei record di registro del server Web Apache su un sistema o un supporto diverso.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, document the web server backup procedures

**(V-214236** ) Le informazioni di registro del server web Apache devono essere protette da modifiche o cancellazioni non autorizzate.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, document the web server backup procedures

**(V-214261)** Non-privileged accounts on the hosting system must only access Apache web server security-relevant information and functions through a distinct administrative account.      
**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None,  Restrict access to the web administration tool to only the System Administrator, Web Manager, or the Web Manager designees.

**(V-214235** ) I file di registro del server Web Apache devono essere accessibili solo da utenti privilegiati.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, To protect the integrity of the data that is being captured in the log files, ensure that only the members of the Auditors group, Administrators, and the user assigned to run the web server software is granted permissions to read the log files.

**(V-214234)** Il server web Apache deve utilizzare un meccanismo di registrazione configurato per avvisare il responsabile della sicurezza del sistema informativo (ISSO) e l'amministratore di sistema (SA) in caso di errore di elaborazione.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Work with the SIEM administrator to configure an alert when no audit data is received from Apache based on the defined schedule of connections.

**(V-214233)** Un server Web Apache, dietro un bilanciatore di carico o un server proxy, deve produrre record di registro contenenti le informazioni IP del client come origine e destinazione e non le informazioni IP del bilanciatore di carico o del proxy per ogni evento.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Access the proxy server through which inbound web traffic is passed and configure settings to pass web traffic to the Apache web server transparently.

Per ulteriori informazioni sulle opzioni di registrazione in base alla configurazione del proxy/bilanciamento del carico, consultare il sito https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html.

**(V-214231** ) Il server web Apache deve avere la registrazione di sistema abilitata.

**Severity:** Cat II Medium   
**Type:** Technical    
**Fix:** None, Fixed by default in Rocky Linux 8

**(V-214232)** Il server web Apache deve generare, come minimo, registrazioni di log per l'avvio e l'arresto del sistema, l'accesso al sistema e gli eventi di autenticazione del sistema.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**    None, Fixed by default in Rocky Linux 8

V-214251 I cookie scambiati tra il server web Apache e il client, come i cookie di sessione, devono avere impostazioni di sicurezza che impediscano l'accesso ai cookie al di fuori del server web Apache e dell'applicazione ospitata.

**Severity:** Cat II Medium   
**Type:** Technical    
**Fix:**

```
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214250)** Il server web Apache deve invalidare gli identificatori di sessione al momento del logout dell'utente dell'applicazione ospitata o al termine di un'altra sessione.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214252)** Il server Web Apache deve generare un ID di sessione sufficientemente lungo da non poter essere indovinato con la forza bruta.

**Severity:** Cat II Medium   
**Type:** Technical    
**Fix:**

```
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214255** ) Il server web Apache deve essere regolato per gestire i requisiti operativi dell'applicazione ospitata.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214254** ) Il server web Apache deve essere costruito in modo da fallire in uno stato sicuro noto se l'inizializzazione del sistema fallisce, lo spegnimento fallisce o le interruzioni falliscono.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Prepare documentation for disaster recovery methods for the Apache 2.4 web server in the event of the necessity for rollback.

**(V-214257** ) Le informazioni di debug e di tracciamento utilizzate per la diagnosi del server web Apache devono essere disattivate.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214230)** Il server Web Apache deve utilizzare la crittografia per proteggere l'integrità delle sessioni remote.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
sed -i "s/^#SSLProtocol.*/SSLProtocol -ALL +TLSv1.2/g" /etc/httpd/conf.d/ssl.conf
```

**(V-214258** ) Il server web Apache deve impostare un timeout di inattività per le sessioni.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**

```
echo "RequestReadTimeout 120" >> /etc/httpd/conf.d/disa-stig-apache.conf
```

**(V-214270)** The Apache web server must install security-relevant software updates within the configured time period directed by an authoritative source (e.g., IAVM, CTOs, DTMs, and STIGs).

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Install the current version of the web server software and maintain appropriate service packs and patches.

**(V-214239)** Il server web Apache non deve eseguire la gestione degli utenti per le applicazioni ospitate.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:**  None, Fixed by default in Rocky Linux 8

**(V-214274** ) I file htpasswd del server web Apache (se presenti) devono riflettere la proprietà e i permessi corretti.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Ensure the SA or Web Manager account owns the "htpasswd" file.  Assicurarsi che le autorizzazioni siano impostate su "550".

**(V-214259)** Il server web Apache deve limitare le connessioni in entrata da zone non sicure.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** None, Configure the "http.conf" file to include restrictions.   
Example:

```
Non richiedere l'ip 192.168.205
Requisito non host phishers.example.com
```

**(V-214267** ) Il server Web Apache deve essere protetto dall'arresto da parte di un utente non privilegiato.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:** None, Fixed by Rocky Linux 8 by default

**(V-214262)** Il server Web Apache deve utilizzare un meccanismo di registrazione configurato in modo da allocare una capacità di memorizzazione dei record di registro sufficientemente grande da soddisfare i requisiti di registrazione del server Web Apache.

**Severity:** Cat II Medium   
**Type:** Operational   
**Fix:** none, Work with the SIEM administrator to determine if the SIEM is configured to allocate log record storage capacity large enough to accommodate the logging requirements of the Apache web server.

**(V-214272)** Il server web Apache deve essere configurato in conformità con le impostazioni di configurazione della sicurezza basate sulla guida alla configurazione o all'implementazione della sicurezza del Dipartimento della Difesa, comprese le STIG, le guide alla configurazione dell'NSA, le CTO e i DTM.

**Severity:** Cat III Low   
**Type:** Operational   
**Fix:**  None

## Informazioni sull'autore

Scott Shinn è il CTO di Atomicorp e fa parte del team Rocky Linux Security. Dal 1995 si occupa di sistemi informativi federali presso la Casa Bianca, il Dipartimento della Difesa e l'Intelligence Community. Parte di questo è stata la creazione degli STIG e l'obbligo di usarli di usarli e mi dispiace molto per questo.

