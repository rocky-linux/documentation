---
title: Server web Apache Protetto
author: Steven Spencer, Franco Colussi
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.8, 9.2
tags:
  - apache
  - web
  - security
---

# Server web Apache Protetto

## Prerequisiti e presupposti

* Un server web Rocky Linux con Apache
* Un buon livello di confidenza con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* Un livello di confidenza con un editor a riga di comando (i nostri esempi utilizzano `vi`, che di solito esegue l'editor `vim`, ma si può sostituire con il proprio editor preferito)
* Assume `firewalld` per il firewall del filtro dei pacchetti
* Presuppone l'uso di un firewall hardware gateway dietro il quale si collocheranno i dispositivi fidati
* Presuppone un indirizzo IP pubblico applicato direttamente al server web. (Utilizzando un indirizzo IP privato per i nostri esempi)

## Introduzione

Che si tratti dell'hosting di molti siti web per i clienti o di un singolo sito importante per la propria azienda, l'hardening del server web garantisce la massima tranquillità a costo di un po' di lavoro iniziale in più per l'amministratore.

Con molti siti web caricati dai vostri clienti, c'è un'alta probabilità che uno di loro carichi un sistema di gestione dei contenuti (CMS) con la possibilità di vulnerabilità. La maggior parte dei clienti si concentra sulla facilità d'uso, non sulla sicurezza, e ciò che accade è che l'aggiornamento del proprio CMS diventa un processo che esce completamente dall'elenco delle priorità.


Se per un'azienda con un grande staff IT è possibile notificare ai clienti le vulnerabilità del loro CMS, per un piccolo team IT questo potrebbe non essere realistico. La migliore difesa è un server Web protetto.

L'hardening del server Web può assumere diverse forme, che possono includere uno o tutti gli strumenti qui descritti ed eventualmente altri non definiti.

Potreste decidere di utilizzare un paio di questi strumenti e non gli altri. Per chiarezza e leggibilità, questo documento è suddiviso in documenti separati per ogni strumento. L'eccezione sarà il firewall basato sui pacchetti`(firewalld`) di cui al presente documento principale.

* Un buon firewall con filtro dei pacchetti basato sulle porte (iptables, firewalld, o firewall hardware - utilizzaremo `firewalld` per i nostri esempi) [procedura`firewalld`](#iptablesstart)
* Un sistema di rilevamento delle intrusioni basato su host (HIDS), in questo caso _ossec-hids_ [Apache Hardened Web Server - ossec-hids](ossec-hids.md)
* Un firewall per applicazioni basate sul Web (WAF), con regole `mod_security` [Apache Hardened Web Server - mod_security](modsecurity.md)
* Rootkit Hunter`(rkhunter`): Uno strumento di scansione che controlla il malware Linux [Apache Hardened Web Server - rkhunter](rkhunter.md)
* Sicurezza del database (utilizzeremo qui `mariadb-server` ) [Server di database MariaDB](../../database/database_mariadb-server.md)
* Un server FTP o SFTP sicuro (utilizzeremo `vsftpd` qui) [Server FTP sicuro - vsftpd](../../file_sharing/secure_ftp_server_vsftpd.md) Potete anche utilizzare le [procedure di blocco_sftp_ e SSH qui](../../file_sharing/sftp.md)

Questa procedura non sostituisce l'[Impostazione di siti multipli del server Web Apache](../apache-sites-enabled.md), ma vi aggiunge questi elementi di sicurezza. Se non l'avete letto, prendetevi un po' di tempo per rivederlo prima di procedere.

## Altre considerazioni

Alcuni degli strumenti qui descritti hanno opzioni gratuite e a pagamento. A seconda delle vostre esigenze o dei requisiti di assistenza, potreste prendere in considerazione le versioni a pagamento. La ricerca di ciò che è disponibile e la decisione da prendere dopo aver valutato tutte le opzioni è la politica migliore.

Per molte di queste opzioni è possibile anche acquistare un dispositivo hardware. Se si preferisce evitare l'installazione e la manutenzione del proprio sistema, sono disponibili altre opzioni oltre a quelle qui descritte.

In questo documento si utilizza un firewall `firewalld`. sono disponibili guide per `firewalld`. Uno che permette a chi ha conoscenze di `iptables` di [trasferire ciò che sa a `firewalld`](../../security/firewalld.md) e uno più [dedicato ai principianti](../../security/firewalld-beginners.md). Prima di iniziare, si consiglia di rivedere una di queste procedure.

È necessario mettere a punto tutti questi strumenti per i propri sistemi. Per ottenere questo risultato è necessario un attento monitoraggio dei log e delle esperienze web riportate dai clienti. Inoltre, sarà necessaria una continua messa a punto.

Questi esempi utilizzano un indirizzo IP privato per simulare un indirizzo pubblico, ma si potrebbe fare la stessa cosa con un NAT uno a uno sul firewall hardware e collegando il server web a tale firewall hardware, anziché al router gateway, con un indirizzo IP privato.

Per spiegarlo è necessario approfondire il tema del firewall hardware, che non rientra nello scopo di questo documento.

## Convenzioni

* **Indirizzi IP:** simulare l'indirizzo IP pubblico con un blocco privato: 192.168.1.0/24 e utilizzare il blocco di indirizzi IP della LAN 10.0.0.0/24. L'instradamento di questi blocchi IP su Internet non è possibile perché sono per uso privato, ma la simulazione di blocchi IP pubblici non è possibile senza l'uso di un indirizzo IP reale assegnato a qualche azienda o organizzazione. Ricordate che per i nostri scopi, il blocco 192.168.1.0/24 è il blocco IP "pubblico" e il blocco 10.0.0.0/24 è il blocco IP "privato".

* **Firewall hardware:** È il firewall che controlla l'accesso ai dispositivi della sala server dalla rete fidata. Questo non è lo stesso firewall basato su pacchetti, anche se potrebbe essere un'altra istanza di `firewalld` in esecuzione su un'altra macchina. Questo dispositivo consente l'accesso ICMP (ping) e SSH (secure shell) ai nostri dispositivi affidabili. La definizione di questo dispositivo non rientra nell'ambito di questo documento. L'autore ha utilizzato [PfSense](https://www.pfsense.org/) e [OPNSense](https://opnsense.org/), installati su hardware dedicato a questo dispositivo, con grande successo. A questo dispositivo verranno assegnati due indirizzi IP. Uno che si collega all'IP pubblico simulato del router Internet (192.168.1.2) e uno che si collega alla nostra rete locale, 10.0.0.1.
* **IP del router Internet:** simulazione con 192.168.1.1/24
* **IP del server web:** è l'indirizzo IP "pubblico" assegnato al nostro server web. Ancora una volta, simulando questo con l'indirizzo IP privato 192.168.1.10/24

![Hardened web server](images/hardened_webserver_figure1.jpeg)

Il diagramma mostra la nostra disposizione generale. Il `firewalld`, basato sui pacchetti, viene eseguito sul server web.

## Installare i pacchetti

In ogni sezione del pacchetto sono elencati i file di installazione necessari e le procedure di configurazione.

## <a name="iptablesstart"></a>Configurazione di `firewalld`

```
firewall-cmd --zone=trusted --add-source=192.168.1.2 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --zone=public --add-service=dns --permanent
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --zone=public --add-port=20/tcp --permanent
firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent
firewall-cmd --reload
```
Ecco cosa sta succedendo:

* impostare la nostra zona fidata sull'indirizzo IP del firewall hardware
* accettare SSH (porta 22) dalla nostra rete fidata, i dispositivi dietro al firewall hardware (solo un indirizzo IP)
* accettare DNS dalla zona pubblica (è possibile limitare ulteriormente questa possibilità specificando gli indirizzi IP dei server o i server DNS locali, se si dispone di questi ultimi)
* accettare il traffico web da qualsiasi luogo attraverso le porte 80 e 443.
* accettano l'FTP standard (porte 20-21) e le porte passive necessarie per lo scambio di comunicazioni bidirezionali in FTP (7000-7500). Queste porte possono essere modificate arbitrariamente in altre porte in base alla configurazione del server ftp.

    !!! note "Nota"
  
        L'uso di SFTP è il metodo migliore al giorno d'oggi. È possibile scoprire come [utilizzare in modo sicuro SFTP da questo documento](../../file_sharing/sftp.md).

* infine ricaricare il firewall

## Conclusione

Esistono molti modi per rendere più sicuro un server web Apache. Ognuno di essi opera in modo indipendente dall'altro, rendendo possibile l'installazione e la selezione di ciò che si desidera.

Ognuno di essi richiede una configurazione e una messa a punto per soddisfare le vostre esigenze specifiche. Poiché i servizi Web sono costantemente oggetto di attacchi da parte di soggetti senza scrupoli, l'implementazione di almeno alcune di queste misure aiuterà l'amministratore a dormire la notte.
