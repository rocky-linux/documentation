# Irrobustire il Webserver Apache

## Prerequisiti e presupposti

* Un web server Rocky Linux con in esecuzione Apache
* Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, registri di visualizzazione e altri compiti generali di amministratore di sistema
* Un livello di comfort con un editor a riga di comando (i nostri esempi usano _vi_ che di solito invoca l'editor _vim_, ma puoi sostituirlo con il tuo editor preferito)
* Suppone un firewall _iptables_, piuttosto che _firewalld_ o un firewall hardware.
* Suppone l'uso di un firewall hardware gateway dietro il quale si troveranno i nostri dispositivi fidati.
* Presume un indirizzo IP pubblico applicato direttamente al server web. Lo sostituiremo con un indirizzo IP privato per tutti i nostri esempi.

## Introduzione

Che voi stiate ospitando più siti web per i clienti, o uno singolo, molto importante, per la vostra azienda, irrobustire il vostro server web vi darà la pace interiore, al costo di un po' più di lavoro iniziale per l'amministratore.

Con più siti web caricati dai vostri clienti, potete essere quasi sicuri che uno di loro caricherà un Content Management System (CMS) con la possibilità di vulnerabilità. La maggior parte dei clienti sono focalizzati sulla facilità d'uso, non sulla sicurezza, e ciò che accade è che l'aggiornamento del proprio CMS diventa un processo che esce del tutto dalla loro lista di priorità.

Mentre notificare ai clienti le vulnerabilità nel loro CMS può essere possibile per un'azienda con un grande staff IT, potrebbe non essere possibile per un piccolo dipartimento. La migliore difesa è un web server rinforzato.

Il rafforzamento del server web può assumere molte forme, che possono includere uno o tutti gli strumenti seguenti, e possibilmente altri non definiti qui.

Si potrebbe scegliere di utilizzare un paio di questi strumenti, e non gli altri, quindi per chiarezza e leggibilità il presente documento è suddiviso in documenti distinti per ogni strumento. L'eccezione sarà il firewall basato su pacchetti (_iptables_) che sarà incluso in questo documento principale.

* Un buon firewall di filtraggio dei pacchetti basato sulle porte (iptables, firewalld, o firewall hardware - useremo _iptables_ per il nostro esempio) [procedura _iptables_](#iptablesstart)
* Un sistema di rilevamento di intrusione basato sull'host (HIDS) Host-based Intrusion Detection System, in questo caso _ossec-hids_ [Rafforzamento Apache Web Server - ossec-hids](ossec-hids.md)
* Un Web based Application Firewall (WAF), con regole _mod\_security_ [Rafforzamento Apache Web Server - mod_security](modsecurity.md)
* Rootkit Hunter (rkhunter): uno strumento di scansione che controlla i malware di Linux [Rafforzammento Apache Web Server - rkhunter](rkhunter.md)
* Sicurezza del database (qui stiamo usando _mariadb-server_) [Server database MariaDB](../../database/database_mariadb-server.md)
* Un server FTP o SFTP sicuro (qui stiamo usando _vsftpd_) [Server FTP Secure - vsftpd](../../file_sharing/secure_ftp_server_vsftpd.md)

Questa procedura non sostituisce l'impostazione [Impostazione Multi-Sito Apache](../apache-sites-enabled.md), ma aggiunge semplicemente questi elementi di sicurezza. Se non lo hai letto, prenditi del tempo per guardarlo prima di procedere.

## Altre Considerazioni

Alcuni degli strumenti delineati qui hanno l'opzione sia gratuita che a pagamento. A seconda delle vostre esigenze o dei requisiti di supporto, potreste voler considerare le versioni a pagamento. Dovreste ricercare quello che c'è là fuori e prendere una decisione dopo aver soppesato tutte le vostre opzioni.

Sappiate anche che la maggior parte di queste opzioni possono essere acquistate come apparecchiature hardware. Se preferisci non preoccuparti d'installare e mantenere il tuo sistema, ci sono altre opzioni disponibili oltre a quelle descritte qui.

Questo documento usa un firewall _iptables_ diretto e richiede [questa procedura su Rocky Linux per disabilitare firewalld e abilitare i servizi iptables](../../security/enabling_iptables_firewall.md).

Se preferisci usare _firewalld_, salta semplicemente questo passaggio e applica le regole necessarie. Il firewall nei nostri esempi qui, non ha bisogno di catene OUTPUT o FORWARD, solo INPUT. Le tue esigenze possono essere diverse!

Tutti questi strumenti devono essere adattati al vostro sistema. Questo può essere fatto solo con un attento monitoraggio dei registri, e l'esperienza web riportata dai vostri clienti. Inoltre, scoprirete che ci sarà bisogno di una messa a punto continua nel tempo.

Anche se stiamo usando un indirizzo IP privato per simularne uno pubblico, tutto questo _potrebbe_ essere fatto usando un NAT one-to-one sul firewall hardware e collegando l'indirizzo IP privato del server web a quel firewall hardware, piuttosto che al router gateway.

Spiegare ciò richiede di approfondire nel firewall hardware mostrato di seguito, e poiché ciò è al di fuori dello scopo di questo documento, è meglio attenersi al nostro esempio di un indirizzo IP pubblico simulato.

## Convenzioni

* **Indirizzi IP:** Qui stiamo simulando l'indirizzo IP pubblico con un blocco privato: 192.168.1.0/24 e stiamo usando il blocco di indirizzi IP della LAN come 10.0.0.0/24 In altre parole, non può essere instradato su Internet. In realtà, nessuno dei due blocchi IP può essere instradato su Internet perché sono entrambi riservati all'uso privato, ma non c'è un buon modo per simulare il blocco IP pubblico, senza usare un indirizzo IP reale che è assegnato a qualche azienda. Basta ricordare che per i nostri scopi, il blocco 192.168.1.0/24 è il blocco IP "pubblico" e il 10.0.0.0/24 è il blocco IP "privato".
* **Hardware Firewall:** Questo è il firewall che controlla l'accesso ai vostri dispositivi della sala server dalla vostra rete fidata. Questo non è lo stesso del nostro firewall _iptables_, anche se potrebbe essere un'altra istanza di _iptables_ in esecuzione su un'altra macchina. Questo dispositivo permetterà a ICMP (ping) e SSH (shell sicura) di utilizzare i nostri dispositivi affidabili. La definizione di questo dispositivo non rientra nel campo di applicazione del presente documento. L'autore ha usato sia [PfSense](https://www.pfsense.org/) che [OPNSense](https://opnsense.org/) e installato su hardware dedicato a questo dispositivo con grande successo. Questo dispositivo avrà due indirizzi IP assegnati. Uno che si collegherà all'IP pubblico simulato del router Internet (192.168.1.2) e uno che si collegherà alla nostra rete locale, 10.0.0.1.
* **Internet Router IP:** Lo stiamo simulando con 192.168.1.1/24
* **Web Server IP:** Questo è l'indirizzo IP "pubblico" assegnato al nostro server web. Ancora una volta, stiamo simulando questo con l'indirizzo IP privato 192.168.1.10/24

![Webserver Rinforzato](images/hardened_webserver_figure1.jpeg)

Il diagramma sopra mostra il nostro layout generale. Il firewall basato su pacchetti _iptables_ viene eseguito sul server web (mostrato sopra).


## Installare Pacchetti

Ogni singola sezione del pacchetto ha i file d'installazione necessari e qualsiasi procedura di configurazione elencata. Le istruzioni di installazione di _iptables_ fanno parte della procedura [disabilitare firewalld e abilitare i servizi iptables](../../security/enabling_iptables_firewall.md).

## <a name="iptablesstart"></a>Configurazione di iptables

Questa parte della documentazione presuppone che abbiate scelto di installare i servizi e le utilità _iptables_ e che non stiate pensando di usare _firewalld_.

Se hai intenzione di usare _firewalld_, puoi usare questo script _iptables_ per guidarti nella creazione delle regole appropriate nel formato _firewalld_. Una volta che lo script è mostrato qui, lo scomporremo per descrivere ciò che sta accadendo. Qui è necessaria solo la catena INPUT. Lo script viene posizionato nella directory /etc/ e per il nostro esempio, viene chiamato firewall.conf:

`vi /etc/firewall.conf`

e il contenuto sarà:

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
iptables -A INPUT -p tcp -m tcp -s 192.168.1.2 --dport 22 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.2 -j ACCEPT
# dns rules
iptables -A INPUT -p udp -m udp -s 8.8.8.8 --sport 53 -d 0/0 -j ACCEPT
iptables -A INPUT -p udp -m udp -s 8.8.4.4 --sport 53 -d 0/0 -j ACCEPT
# web ports
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# ftp ports
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```
Ecco quindi cosa sta succedendo sopra:

* Quando iniziamo, puliamo tutte le regole
* Abbiamo quindi impostato la policy di default per la nostra catena INPUT a DROP, che dice: "Ehi, se non ti abbiamo esplicitamente permesso qui, allora ti stiamo abbandonando!"
* Quindi permettiamo SSH (porta 22) dalla nostra rete affidabile, i dispositivi dietro il firewall hardware
* Consentiamo DNS da alcuni risolutori DNS pubblici. (questi possono anche essere server DNS locali, se li hai)
* Permettiamo al nostro traffico web di entrare da qualsiasi punto sulla porta 80 e 443.
* Permettiamo FTP standard (porte 20-21) e le porte passive necessarie per scambiare comunicazioni bidirezionali in FTP (7000-7500). Queste porte possono essere modificate arbitrariamente in altre porte in base alla configurazione del server ftp.
* Permettiamo qualsiasi traffico sull'interfaccia locale (127.0.0.1)
* Poi diciamo che ogni traffico che si è connesso con successo in base alle regole, dovrebbe essere permesso ad altro traffico (porte) e di mantenere la loro connessione (ESTABLISHED,RELATED).
* E infine, rifiutiamo tutto l'altro traffico e impostiamo lo script per salvare le regole dove _iptables_ prevede di trovarle.

Una volta che questo script è lì, abbiamo bisogno di renderlo eseguibile:

`chmod +x /etc/firewall.conf`

Abbiamo bisogno di abilitare _iptables_ se non lo è ancora:

`systemctl enable iptables`

Abbiamo bisogno di avviare _iptables_:

`systemctl start iptables`

Dobbiamo eseguire /etc/firewall.conf:

`/etc/firewall.conf`

Se aggiungiamo nuove regole al file /etc/firewall.conf, basta eseguirlo di nuovo per rendere quelle regole attive. Tenete a mente che con una politica DROP di default per la catena INPUT, se fate un errore, potreste chiudervi fuori da remoto.

È sempre possibile risolvere questo problema, tuttavia, dalla console sul server. Poiché il servizio _iptables_ è abilitato, un riavvio ripristinerà tutte le regole che sono state aggiunte con `/etc/firewall.conf`.

## Conclusione

Ci sono diversi modi per rinforzare un server web Apache per renderlo più sicuro. Ognuno di essi funziona indipendentemente dalle altre opzioni, quindi potete scegliere d'installarne una qualsiasi o tutte in base alle vostre esigenze.

Ognuna richiede una certa configurazione con varie regolazioni necessarie per alcune per soddisfare le vostre esigenze specifiche. Dal momento che i servizi web sono costantemente sotto attacco 24/7 da parte di attori senza scrupoli, l'attuazione di almeno alcuni di questi aiuterà un amministratore a dormire di notte.
