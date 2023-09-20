---
title: Sistema di rilevamento delle intrusioni basato su host (HIDS)
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - web
  - security
  - ossec-hids
  - hids
---

# Sistema di rilevamento delle intrusioni basato su host (HIDS)

## Prerequisiti

* Conoscenza di un editor di testo a riga di comando (in questo esempio si utilizza `vi` )
* Un buon livello di confidenza con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* La consapevolezza che l'installazione di questo strumento richiede anche il monitoraggio delle azioni e la messa a punto dell'ambiente
* L'utente root esegue tutti i comandi o un utente regolare con `sudo`

## Introduzione

`ossec-hids` è un sistema di rilevamento delle intrusioni all'host che offre passaggi automatici di azione-risposta per aiutare a mitigare gli attacchi. È solo uno dei possibili elementi di una configurazione di server web Apache protetta. Si può usare con o senza altri strumenti.

Se volete usare questo e altri strumenti di hardening, fate riferimento al documento [Apache Hardened Web Server](index.md). Questo documento utilizza anche tutti i presupposti e le convenzioni delineati nel documento originale. È buona norma rivederlo prima di continuare.

## Installazione del repository di Atomicorp

Per installare `ossec-hids`, abbiamo bisogno di un repository di terze parti di Atomicorp. Atomicorp offre anche una versione supportata a pagamento, a prezzi ragionevoli, per coloro che desiderano un supporto professionale in caso di problemi.

Se si preferisce l'assistenza e si dispone di un budget sufficiente, si consiglia di provare la versione [ `ossec-hids` a pagamento di Atomicorp](https://atomicorp.com/atomic-enterprise-ossec/). Sono sufficienti alcuni pacchetti dal repository gratuito di Atomicorp. Dopo il download, si cambierà il repository.

Il download del repository richiede `wget`. Installatelo prima e installate il repository EPEL, se non lo avete già installato, con:

```
dnf install wget epel-release
```

Scaricare e attivare il repository gratuito di Atomicorp:

```
wget -q -O - http://www.atomicorp.com/installers/atomic | sh
```

Questo script vi chiederà di accettare i termini. Immettere "yes" o <kbd>Invio</kbd> per accettare l'impostazione predefinita.

Successivamente, verrà chiesto se si desidera abilitare il repository per impostazione predefinita e, anche in questo caso, si potrà accettare l'impostazione predefinita o inserire "yes".

### Configurazione del repository Atomicorp

Il repository atomic è necessario solo per un paio di pacchetti. Per questo motivo, si cambierà il repository e si specificheranno solo i pacchetti necessari:

```
vi /etc/yum.repos.d/atomic.repo
```

Aggiungete questa riga sotto "enabled = 1" nella sezione superiore:

```
includepkgs = ossec* GeoIP* inotify-tools
```

Questo è l'unico cambiamento necessario. Salvare le modifiche e uscire dal repository (in `vi` è <kbd>esc</kbd> per entrare in modalità comando, poi <kbd>SHIFT+</kbd><kbd>:</kbd><kbd>+wq</kbd> per salvare e uscire).

Questo limita il repository Atomicorp solo all'installazione e all'aggiornamento di questi pacchetti.

## Installazione di `ossec-hids`

Una volta configurato il repository, è necessario installare i pacchetti:

```
dnf install ossec-hids-server ossec-hids inotify-tools
```

### Configurazione di `ossec-hids`

La configurazione predefinita è in uno stato che richiede molte modifiche. La maggior parte di queste ha a che fare con la notifica dell'amministratore del server e la posizione dei registri.

`ossec-hids` esamina i log per cercare di decidere se è in corso un attacco e se applicare una mitigazione. Invia inoltre rapporti all'amministratore del server con una notifica o un messaggio relativo a una procedura di mitigazione avviata in base a quanto visto da `ossec-hids`.

Per modificare il file di configurazione, immettere:

```
vi /var/ossec/etc/ossec.conf
```

L'autore analizzerà questa configurazione mostrando le modifiche in linea e spiegandole:

```
<global>
  <email_notification>yes</email_notification>  
  <email_to>admin1@youremaildomain.com</email_to>
  <email_to>admin2@youremaildomain.com</email_to>
  <smtp_server>localhost</smtp_server>
  <email_from>ossec-webvms@yourwebserverdomain.com.</email_from>
  <email_maxperhour>1</email_maxperhour>
  <white_list>127.0.0.1</white_list>
  <white_list>192.168.1.2</white_list>
</global>
```

Le notifiche via e-mail sono disattivate per impostazione predefinita e la configurazione `<global>` è sostanzialmente vuota. Si desidera attivare la notifica via e-mail e identificare le persone che riceveranno i rapporti via e-mail in base al loro indirizzo di posta elettronica.

La sezione `<smtp_server>` attualmente mostra localhost, tuttavia è possibile specificare un relay del server di posta elettronica, se si preferisce, o configurare le impostazioni di postfix per l'host locale seguendo [questa guida](../../email/postfix_reporting.md).

È necessario impostare l'indirizzo e-mail "from". È necessario per far fronte ai filtri SPAM del vostro server di posta elettronica, che potrebbero vedere questa e-mail come SPAM. Per evitare di essere sommersi dalle e-mail, impostate la segnalazione delle e-mail su 1 all'ora. È possibile espandere o escludere questo comando iniziando con `ossec-hids`.

Le sezioni `<white_list>` si occupano dell'IP localhost del server e dell'indirizzo IP "pubblico" (ricordate la nostra sostituzione di un indirizzo IP privato) del firewall, dal quale verranno visualizzate tutte le connessioni sulla rete fidata. È possibile aggiungere molte voci di `<white_list>`.

```
<syscheck>
  <!-- Frequency that syscheck is executed -- default every 22 hours -->
  <frequency>86400</frequency>
...
</syscheck>
```

La sezione `<syscheck>` esamina un elenco di directory da includere ed escludere quando si cercano file compromessi. Si tratta di un ulteriore strumento per controllare e proteggere il file system dalle vulnerabilità. È necessario rivedere l'elenco delle directory e aggiungerne altre alla sezione `<syscheck>`.

La sezione `<rootcheck>`, appena sotto la sezione `<syscheck>`, è un ulteriore livello di protezione. Le posizioni che `<syscheck>` e `<rootcheck>` osservano sono modificabili, ma probabilmente non sarà necessario apportarvi alcuna modifica.

La modifica della `<frequency>` per l'esecuzione di `<rootcheck>` a una volta ogni 24 ore (86400 secondi) rispetto all'impostazione predefinita di 22 ore è una modifica opzionale indicata.

```
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*access_log</location>
</localfile>
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*error_log</location>
</localfile>
```

La sezione `<localfile>` riguarda la posizione dei log che si desidera osservare. Sono già presenti voci per il _syslog_ e i log _sicuri_, di cui si deve solo verificare il percorso, ma tutto il resto può rimanere.

È necessario aggiungere le posizioni dei log di Apache e aggiungerle come wild card, perché si potrebbe avere una serie di log per molti clienti web diversi.

```
  <command>
    <name>firewalld-drop</name>
    <executable>firewall-drop.sh</executable>
    <expect>srcip</expect>
  </command>

  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <level>7</level>
  </active-response>
```

Infine, verso la fine del file, è necessario aggiungere la sezione di risposta attiva. Questa sezione ha due parti: la sezione `<command>` e la sezione `<active-response>`.

Lo script "firewall-drop" esiste già nel percorso `ossec-hids`. Indica a `ossec-hids` che se si verifica un livello 7, bisogna aggiungere una regola del firewall per bloccare l'indirizzo IP.

Attivare e avviare il servizio una volta completate tutte le modifiche alla configurazione. Se tutto si avvia correttamente, si è pronti a proseguire:

```
systemctl enable ossec-hids
systemctl start ossec-hids
```

Il file di configurazione `ossec-hids`. È possibile conoscere queste opzioni visitando il [sito ufficiale della documentazione](https://www.ossec.net/docs/).

## Conclusione

`ossec-hids` è solo uno degli elementi di un server web Apache protetto. È possibile ottenere una maggiore sicurezza selezionandola con altri strumenti.

Sebbene l'installazione e la configurazione siano relativamente semplici, **non** si tratta di un'applicazione "installa e dimentica". È necessario adattarlo al proprio ambiente per ottenere la massima sicurezza con il minor numero di risposte false positive.
