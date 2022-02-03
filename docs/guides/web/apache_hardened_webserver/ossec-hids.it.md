- - -
title: Sistema Intrusion Detection System Host-based (HIDS) author: Steven Spencer contributors: Ezequiel Bruni, Franco Colussi update: Feb-01-2022
- - -

# Sistema Intrusion Detection System (HIDS) basato sull'Host

## Prerequisiti

* Competenza con un editor di testo a riga di comando (stiamo usando _vi_ in questo esempio)
* Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, registri di visualizzazione e altri compiti generali di amministratore di sistema
* Una comprensione che l'installazione di questo strumento richiede anche il monitoraggio delle azioni e la messa a punto del vostro ambiente
* Tutti i comandi sono eseguiti come utente root o usando sudo

## Introduzione

Se volete usare questo insieme ad altri strumenti per il rafforzamento, fate riferimento al documento [Apache Web Server Rinforzato](index. md). Il presente documento utilizza anche tutte le ipotesi e le convenzioni delineate in tale documento originale, quindi è una buona idea rivederlo prima di continuare.

Per installare _ossec-hids_, abbiamo bisogno di un repository di terze parti da Atomicorp. Atomicorp offre anche una versione supportata a prezzi ragionevoli per coloro che desiderano un supporto professionale se si trovano in difficoltà.

## Installare il Repository di Atomicorp

Se preferisci il supporto, e hai il budget per farlo, dai un'occhiata alla versione a pagamento di [Atomicorp _ossec-hids_](https://atomicorp.com/atomic-enterprise-ossec/). Atomicorp offre anche una versione supportata a prezzi ragionevoli per coloro che desiderano un supporto professionale se si trovano in difficoltà.

Se preferisci il supporto, e hai il budget per farlo, dai un'occhiata alla versione a pagamento di [Atomicorp _ossec-hids_](https://atomicorp.com/atomic-enterprise-ossec/). Poiché avremo bisogno solo di alcuni pacchetti dal repository gratuito di Atomicorp, modificheremo il repository dopo averlo scaricato.

Scaricare il repository richiede _wget_ quindi installalo prima se non ce l'hai. Installare anche il repository EPEL se non lo avete già installato, con:

`dnf install wget epel-release`

Ora scarica e abilita il repository gratuito di Atomicorp:

`wget -q -O - http://www.atomicorp.com/installers/atomic | sh`

Questo script ti chiederà di accettare i termini. Digita "yes" o premi 'Invio' per accettare "yes" come predefinito.

Successivamente, vi chiederà se volete abilitare il repository di default, e di nuovo vogliamo accettare il default o digitare "yes".

### Configurare il Repository Atomicorp

Abbiamo bisogno del repository atomic solo per un paio di pacchetti. Per questo motivo, modificheremo il repository e specificheremo solo i pacchetti da scegliere:

`vi /etc/yum.repos.d/atomic.repo`

E poi aggiungete questa linea sotto "enabled = 1" nella sezione superiore:

`includepkgs = ossec* inotify-tools`

Questo è l'unico cambiamento di cui abbiamo bisogno, quindi salvate le vostre modifiche e uscite dal repository, (in vi sarebbe <kbd>esc</kbd> per entrare in modalità comando, poi `: wq` per salvare e uscire).

Questo limita il repository di Atomicorp ad installare e aggiornare solo questi pacchetti.

## Installazione ossec-hids

Ora che abbiamo il repository scaricato e configurato, dobbiamo installare i pacchetti:

`dnf install ossec-hids-server ossec-hids inotify-tools`

### Configurare ossec-hids

Ci sono una serie di modifiche che devono essere apportate al file di configurazione _ossec-hids_. La maggior parte di queste hanno a che fare con le notifiche dell'amministratore del server e le posizioni del registro.

_ossec-hids_ guarda i registri per provare a determinare se c'è un attacco, e se applicare la mitigazione. Invia anche rapporti all'amministratore del server, sia solo come notifica, o che una procedura di mitigazione è stata attivata in base a ciò che _ossec-hids_ ha visto.

Per modificare il file di configurazione digita:

`vi /var/ossec/etc/ossec.conf`

Scomponiamo questa configurazione mostrando i cambiamenti alle righe e spiegandoli man mano:

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

Per impostazione predefinita, le notifiche email sono disattivate e la configurazione `<global>` è fondamentalmente vuota. Vorrai attivare la notifica e-mail e identificare le persone che dovrebbero ricevere i rapporti via mail per indirizzo e-mail.

La sezione `<smtp_server>` attualmente mostra localhost, tuttavia puoi specificare un relay di un server email se preferisci, o semplicemente configurare le impostazioni email di postfix per l'host locale seguendo [questa guida](../../email/postfix_reporting.md).

È necessario impostare l'indirizzo "from" in modo da poter trattare con i filtri SPAM sul tuo server di posta elettronica che potrebbe vedere questa email come SPAM. Per evitare di essere inondato di e-mail, imposta la segnalazione delle e-mail a 1 all'ora. Puoi espandere questo o rimarcare questo comando se vuoi mentre stai iniziando con _ossec-hids_ e hai bisogno di vedere le cose velocemente.

Le sezioni `<white_list>` si occupano dell'IP localohost del server e dell'indirizzo "pubblico" (ricordate, stiamo usando un indirizzo privato per la dimostrazione) del firewall, da cui appariranno tutte le connessioni sulla rete fidata. Puoi aggiungere più voci `<white_list>` secondo necessità.

```
<syscheck>
  <!-- Frequency that syscheck is executed -- default every 22 hours -->
  <frequency>86400</frequency>
...
</syscheck>
```

La sezione `<syscheck>` guarda a una lista di directory da includere ed escludere quando si cercano file compromessi. Pensate a questo come a un altro strumento per controllare e proteggere il file system dalle vulnerabilità. Dovresti rivedere la lista delle directory e vedere se ce ne sono altre che vuoi aggiungere nella sezione `<syscheck>`.

La sezione `<rootcheck>` appena sotto la sezione `<syscheck>` è ancora un altro strato di protezione. Le posizioni che sia `<syscheck>` che `<rootcheck>` guardano sono modificabili, ma probabilmente non avrete bisogno di fare alcun cambiamento.

Cambiare il `<frequency>` per l'esecuzione `<rootcheck>` a una volta ogni 24 ore (86400 secondi) dal valore predefinito di 22 ore è un cambiamento opzionale mostrato sopra.

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

La sezione `<localfile>` si occupa delle posizioni dei log che vogliamo guardare. Ci sono già delle voci per i log _syslog_ e _secure_ di cui devi solo verificare il percorso, ma tutto il resto può essere lasciato com'è.

Abbiamo comunque bisogno di aggiungere le posizioni dei log di Apache, e vogliamo aggiungerle come wild_cards, perché potremmo avere un mucchio di log per un sacco di clienti web diversi. Quel formato è mostrato sopra.

```
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop.sh</executable>
    <expect>srcip</expect>
  </command>

  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <level>7</level>
    <timeout>1200</timeout>
  </active-response>
```

Infine, verso la fine del file dobbiamo aggiungere la sezione di risposta attiva. Questa sezione contiene due parti, una sezione `<command>` e la sezione `<active-response>`.

Lo script "firewall-drop" esiste già nel percorso ossec.  Dice a _ossec\_hids_ che se viene raggiunto un livello 7, aggiunge una regola del firewall per bloccare l'indirizzo IP per 20 minuti. Ovviamente, è possibile modificare il valore di timeout. Basta ricordare che i tempi dei file di configurazione sono tutti in secondi.

Una volta fatte tutte le modifiche di configurazione necessarie, basta abilitare e avviare il servizio. Se tutto inizia correttamente, dovreste essere pronti ad andare avanti:

`systemctl enable ossec-hids`

E quindi:

`systemctl start ossec-hids`

Ci sono molte opzioni per il file di configurazione _ossec-hids_. Potete scoprire queste opzioni visitando il [sito della documentazione ufficiale](https://www.ossec.net/docs/).

## Conclusione

_ossec-hids_ è solo un elemento di un server web rinforzato Apache. Può essere utilizzato con altri strumenti per ottenere una migliore sicurezza per il vostro sito web.

Mentre l'installazione e la configurazione sono relativamente semplici, troverete che questa **non è** un'applicazione "installa e dimentica". Dovrete sintonizzarlo sul vostro ambiente per ottenere la massima sicurezza con il minor numero di risposte false-positive.
