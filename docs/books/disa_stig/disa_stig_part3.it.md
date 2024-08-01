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

Nella prima parte di questa serie abbiamo spiegato come costruire il nostro server web con la STIG RHEL8 DISA di base applicata e nella seconda parte abbiamo imparato a testare la conformità STIG con lo strumento OpenSCAP. Ora faremo qualcosa con il sistema, costruendo una semplice applicazione web e applicando la STIG del server web DISA: <https://www.stigviewer.com/stig/web_server/>

Per prima cosa confrontiamo ciò che stiamo affrontando: la STIG DISA di RHEL 8 è indirizzata a una piattaforma molto specifica, quindi i controlli sono abbastanza facili da capire in quel contesto, da testare e da applicare.  Le STIG delle applicazioni devono essere portabili su più piattaforme, quindi il contenuto è generico per funzionare su diverse distribuzioni Linux (RHEL, Ubuntu, SuSE, ecc.) **. Ciò significa che strumenti come OpenSCAP non ci aiuteranno a verificare/rimediare la configurazione, dovremo farlo manualmente. Questi STIG sono:

* Apache 2.4 V2R5 - Server; che si applica al server web stesso
* Apache 2.4 V2R5 - Sito; Che si applica all'applicazione web/sito web

Per la nostra guida, creeremo un semplice server web che non fa altro che servire contenuti statici. Possiamo usare le modifiche apportate qui per creare un'immagine di base e poi usare questa immagine di base quando costruiamo server web più complessi in seguito.

## Avvio rapido del server Apache 2.4 V2R5

Prima di iniziare, è necessario fare riferimento alla Parte 1 e applicare il profilo di sicurezza DISA STIG. Considerate questo passo 0.

1.) Installare `apache` e `mod_ssl`

```bash
dnf install httpd mod_ssl
```

2.) Modifiche alla configurazione

```bash
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

```bash
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
**Fix:**  Nessuno, controlla che solo gli utenti privilegiati possano accedere ai file del server web

**(V-214242)** Il server web Apache deve fornire opzioni di installazione per escludere l'installazione di documentazione, codice di esempio, applicazioni di esempio ed esercitazioni.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214253)** Il server Web Apache deve generare un ID di sessione utilizzando la maggior parte possibile del set di caratteri per ridurre il rischio di brute force.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:**  Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214273** ) Il software del server Web Apache deve essere una versione supportata dal fornitore.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214271)** L'account utilizzato per eseguire il server Web Apache non deve avere una shell e una password di accesso valide.

**Severity:** Cat I High  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214245)** Il server web Apache deve avere il Web Distributed Authoring (WebDAV) disabilitato.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214264)** Il server Web Apache deve essere configurato per integrarsi con l'infrastruttura di sicurezza dell'organizzazione.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, inoltrare i log del server web al SIEM

**(V-214243)** Il server Web Apache deve avere le mappature delle risorse impostate per disabilitare il servizio di alcuni tipi di file.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214240)** Il server web Apache deve contenere solo i servizi e le funzioni necessarie al funzionamento.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
dnf remove httpd-manual
```

**(V-214238)** I moduli di espansione devono essere completamente rivisti, testati e firmati prima di poter esistere su un server web Apache di produzione.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, disattivare tutti i moduli non necessari per l'applicazione

**(V-214268)** I cookie scambiati tra il server Web Apache e il client, come i cookie di sessione, devono avere le proprietà dei cookie impostate in modo da impedire agli script lato client di leggere i dati dei cookie.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
dnf install mod_session
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214269)** Il server web Apache deve rimuovere tutti i cifrari di esportazione per proteggere la riservatezza e l'integrità delle informazioni trasmesse.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8 Profilo di sicurezza DISA STIG

**(V-214260)** Il server web Apache deve essere configurato per disconnettere o disabilitare immediatamente l'accesso remoto alle applicazioni ospitate.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuna, si tratta di una procedura per arrestare il server web

**(V-214249)** Il server web Apache deve separare le applicazioni ospitate dalla funzionalità di gestione del server web Apache ospitato.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, questo è relativo alle applicazioni web piuttosto che al server

**(V-214246)** Il server Web Apache deve essere configurato per utilizzare un indirizzo IP e una porta specifici.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, il server web deve essere configurato per ascoltare solo su un IP/port specifico

**(V-214247)** Gli account del server web Apache che accedono all'albero delle directory, alla shell o ad altre funzioni e utilità del sistema operativo devono essere solo account amministrativi.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, tutti i file e le directory serviti dal server web devono essere di proprietà degli utenti amministrativi e non dell'utente del server web.

**(V-214244)** Il server Web Apache deve consentire la rimozione dei mapping agli script inutilizzati e vulnerabili.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, qualsiasi cgi-bin o altre mappature Script/ScriptAlias non utilizzate devono essere rimosse

**(V-214263)** Il server web Apache non deve impedire la possibilità di scrivere il contenuto di un record di registro specificato su un server di registro di audit.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, collaborare con l'amministratore del SIEM per consentire la possibilità di scrivere il contenuto specificato dei record di registro su un server di registro di audit.

**(V-214228)** Il server web Apache deve limitare il numero di richieste di sessione simultanee consentite.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214229)** Il server web Apache deve eseguire la gestione della sessione lato server.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
```

**(V-214266)** Il server web Apache deve vietare o limitare l'uso di porte, protocolli, moduli e/o servizi non sicuri o non necessari.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Assicurarsi che il sito web applichi l'uso delle porte conosciute da IANA per HTTP e HTTPS.

**(V-214241)** Il server Web Apache non deve essere un server proxy.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
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
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214256)** I messaggi di avviso e di errore visualizzati ai client devono essere modificati per minimizzare l'identità del server web Apache, delle patch, dei moduli caricati e dei percorsi delle directory.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Utilizzare la direttiva "ErrorDocument" per abilitare pagine di errore personalizzate per i codici di stato HTTP 4xx o 5xx.

**(V-214237)** È necessario eseguire il backup dei dati e dei record di registro del server Web Apache su un sistema o un supporto diverso.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuna, documentare le procedure di backup del server web

**(V-214236)** Le informazioni di registro del server web Apache devono essere protette da modifiche o cancellazioni non autorizzate.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuna, documentare le procedure di backup del server web

**(V-214261)** Gli account non privilegiati sul sistema di hosting devono accedere alle informazioni e alle funzioni rilevanti per la sicurezza del server web Apache solo attraverso un account amministrativo separato.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Limitare l'accesso allo strumento di amministrazione web solo all'Amministratore di sistema, al Web Manager o a chi ne fa le veci.

**(V-214235)** I file di registro del server Web Apache devono essere accessibili solo da utenti privilegiati.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Per proteggere l'integrità dei dati acquisiti nei file di registro, assicurarsi che solo i membri del gruppo Auditori, gli Amministratori e l'utente assegnato all'esecuzione del software del server Web ricevano l'autorizzazione a leggere i file di registro.

**(V-214234)** Il server web Apache deve utilizzare un meccanismo di registrazione configurato per avvisare il responsabile della sicurezza del sistema informativo (ISSO) e l'amministratore di sistema (SA) in caso di errori di elaborazione.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, collaborare con l'amministratore del SIEM per configurare un avviso quando non vengono ricevuti dati di audit da Apache in base alla pianificazione delle connessioni definita.

**(V-214233)** Un server Web Apache, dietro un bilanciatore di carico o un server proxy, deve produrre record di registro contenenti le informazioni IP del client come origine e destinazione e non le informazioni IP del bilanciatore di carico o del proxy per ogni evento.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, accedere al server proxy attraverso il quale viene passato il traffico web in entrata e configurare le impostazioni per passare il traffico web al server web Apache in modo trasparente.

Fare riferimento a <https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html> per ulteriori informazioni sulle opzioni di registrazione in base alla configurazione del proxy/bilanciamento del carico.

**(V-214231)** Il server web Apache deve avere la registrazione di sistema abilitata.

**Severity:** Cat II Medium   
**Type:** Technical   
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214232)** Il server web Apache deve generare, come minimo, registrazioni di log per l'avvio e l'arresto del sistema, l'accesso al sistema e gli eventi di autenticazione del sistema.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214251)** I cookie scambiati tra il server web Apache e il client, come i cookie di sessione, devono avere impostazioni di sicurezza che impediscano l'accesso ai cookie al di fuori del server web Apache e dell'applicazione ospitata.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214250)** Il server web Apache deve invalidare gli identificatori di sessione al momento del logout dell'utente dell'applicazione ospitata o al termine di un'altra sessione.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214252)** Il server Web Apache deve generare un ID di sessione sufficientemente lungo da non poter essere indovinato con la forza bruta.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214255)** Il server web Apache deve essere regolato per gestire i requisiti operativi dell'applicazione ospitata.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214254)** Il server web Apache deve essere costruito in modo da fallire in uno stato sicuro noto se l'inizializzazione del sistema fallisce, lo spegnimento fallisce o le interruzioni falliscono.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Preparare la documentazione per i metodi di ripristino di emergenza per il server web Apache 2.4 in caso di necessità di rollback.

**(V-214257)** Le informazioni di debug e di tracciamento utilizzate per la diagnosi del server web Apache devono essere disattivate.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214230)** Il server Web Apache deve utilizzare la crittografia per proteggere l'integrità delle sessioni remote.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
sed -i "s/^#SSLProtocol.*/SSLProtocol -ALL +TLSv1.2/g" /etc/httpd/conf.d/ssl.conf
```

**(V-214258)** Il server web Apache deve impostare un timeout di inattività per le sessioni.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**

```bash
echo "RequestReadTimeout 120" >> /etc/httpd/conf.d/disa-stig-apache.conf
```

**(V-214270)** Il server web Apache deve installare gli aggiornamenti software rilevanti per la sicurezza entro il periodo di tempo configurato e indicato da una fonte autorevole (ad esempio, IAVM, CTO, DTM e STIG).

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Installare la versione corrente del software del server web e mantenere i service pack e le patch appropriate.

**(V-214239)** Il server web Apache non deve eseguire la gestione degli utenti per le applicazioni ospitate.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:**  Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214274)** I file htpasswd del server web Apache (se presenti) devono riflettere la proprietà e i permessi corretti.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Assicurarsi che l'account SA o Web Manager sia proprietario del file "htpasswd". Assicurarsi che le autorizzazioni siano impostate su "550".

**(V-214259)** Il server web Apache deve limitare le connessioni in entrata da zone non sicure.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, Configurare il file "http.conf" per includere le restrizioni.

Esempio:

```bash
Require not ip 192.168.205
Require not host phishers.example.com
```

**(V-214267)** Il server Web Apache deve essere protetto dall'arresto da parte di un utente non privilegiato.

**Severity:** Cat II Medium  
**Type:** Technical  
**Fix:** Nessuno, corretto per impostazione predefinita in Rocky Linux 8

**(V-214262)** Il server Web Apache deve utilizzare un meccanismo di registrazione configurato in modo da allocare una capacità di memorizzazione dei record di registro sufficientemente grande da soddisfare i requisiti di registrazione del server Web Apache.

**Severity:** Cat II Medium  
**Type:** Operational  
**Fix:** Nessuno, collaborare con l'amministratore del SIEM per determinare se il SIEM è configurato per allocare una capacità di archiviazione dei record di registro sufficientemente grande da soddisfare i requisiti di registrazione del server web Apache.

**(V-214272)** Il server web Apache deve essere configurato in conformità con le impostazioni di sicurezza basate sulla configurazione di sicurezza del DoD o sulla guida all'implementazione, comprese le STIG, le guide di configurazione dell'NSA, le CTO e i DTM.

**Severity:** Cat III Low  
**Type:** Operational  
**Fix:**  Nessuna

## Informazioni sull'autore

Scott Shinn è il CTO per Atomicorp e fa parte del team Rocky Linux Security. Dal 1995 si occupa di sistemi informativi federali presso la Casa Bianca, il Dipartimento della Difesa e l'Intelligence Community. Parte di questo è stata la creazione degli STIG e l'obbligo di usarli, e mi dispiace molto per questo.
