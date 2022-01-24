# Applicazione Firewall basato sul web (WAF)

## Prerequisiti

* Un Rocky Linux con in esecuzione un Web Server Apache
* Competenza con un editor a riga di comando (stiamo usando _vi_ in questo esempio)
* Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, registri di visualizzazione e altri compiti generali di amministratore di sistema
* Una comprensione che l'installazione di questo strumento richiede anche il monitoraggio delle azioni e la messa a punto del vostro ambiente
* Un account sul sito WAF di Comodo
* Tutti i comandi sono eseguiti come utente root o sudo

## Introduzione

_mod\_security_ è un firewall applicativo basato su web open-source (WAF). È solo un possibile componente di una configurazione di server Apache rinforzato e può essere utilizzato con o senza altri strumenti.

Se si desidera utilizzare questo insieme ad altri strumenti per il rafforzamento, fare riferimento alla guida [Apache Web Server Rinforzato](index.md). Il presente documento utilizza anche tutte le ipotesi e le convenzioni delineate in tale documento originale, quindi è una buona idea rivederlo prima di continuare.

Una cosa che manca con _mod\_security_ quando viene installato dai repository generici di Rocky Linux, è che le regole installate sono minime nella migliore delle ipotesi. Per ottenere un pacchetto più esteso di regole di mod_security gratuite, stiamo usando [la procedura di installazione WAF di Comodo](https://www.comodo.com/) dopo aver installato il pacchetto base.

Si noti che Comodo è un'azienda che vende molti strumenti per aiutare a proteggere le reti. Gli strumenti gratuiti _mod\_security_ potrebbero non essere gratuiti per sempre e richiedono di impostare un login con Comodo per accedere alle regole.

## Installazione mod_security

Per installare il pacchetto base, utilizzare questo comando che installerà le dipendenze mancanti. Abbiamo anche bisogno di _wget_ quindi se non l'avete installato, fate anche quello:

`dnf install mod_security wget`

## Impostazione del tuo account Comodo

Per impostare il tuo account gratuito, vai al [sito WAF di Comodo](https://waf.comodo.com/), e clicca sul link "Signup" nella parte superiore della pagina. Vi sarà richiesto di impostare le informazioni del nome utente e della password, ma non sarà effettuata alcuna fatturazione con carta di credito o altro.

Le credenziali che si utilizzano per accedere al sito web saranno utilizzate nella configurazione del software di Comodo e anche per ottenere le regole, quindi dovrai tenerli al sicuro in un gestore di password da qualche parte.

Si prega di notare che la sezione "Termini e condizioni" del modulo che è necessario compilare per utilizzare Comodo Web Application Firewall (CWAF) è scritta per coprire tutti i loro prodotti e servizi. Detto questo, dovresti leggerlo attentamente prima di accettare i termini!

## Installazione CWAF

Prima di iniziare, affinché lo script possa effettivamente essere eseguito dopo il download, hai bisogno di alcuni strumenti di sviluppo. Installare il pacchetto con:

`dnf group install 'Development Tools'`

Inoltre, dovrete avere il vostro server web in funzione affinché Comodo veda _mod\_security_ correttamente. Quindi avvialo se non è già in esecuzione:

`systemctl start httpd`

Dopo esserti iscritto a Comodo, riceverai un'email con le istruzioni su cosa fare dopo. In sostanza, ciò che devi fare è accedere al sito web con le tue nuove credenziali e quindi scaricare lo script di installazione del client.

Dalla directory radice del server, utilizzare il comando wget per scaricare l'installatore:

`wget https://waf.comodo.com/cpanel/cwaf_client_install.sh`

Eseguire il programma di installazione digitando:

`bash cwaf_client_install.sh`

Questo estrarrà il programma di installazione e inizierà il processo, con un'eco sullo schermo. Riceverai un messaggio a metà strada:

`No web host management panel found, continue in 'standalone' mode? [y/n]:`

Digita "y" e lascia che lo script continui.

Puoi anche ricevere questa nota:

`Some required perl modules are missed. Install them? This can take a while. [y/n]:`

Se è così digitate "y" e permettete l'installazione dei moduli mancanti.

```
Enter CWAF login: username@domain.com
Enter password for 'username@domain.com' (will not be shown): *************************
Confirm password for 'username@domain.com' (will not be shown): ************************
```

Notate qui che probabilmente dovrete scaricare le regole e installarle nella posizione corretta, poiché il campo della password richiede una punteggiatura o un carattere speciale, ma il file di configurazione apparentemente ha problemi con questo quando lo si invia al sito di Comodo dal programma di installazione o dallo script di aggiornamento.

Questi script falliranno sempre con un errore delle credenziali. Questo probabilmente non influisce sugli amministratori che hanno server web in esecuzione con un front-end GUI (Cpanel / Plesk), ma se si sta eseguendo il programma standalone come nel nostro esempio, lo fa. [Puoi trovare la soluzione sotto](#cwaf_fix).

```
Enter absolute CWAF installation path prefix (/cwaf will be appended): /usr/local
Install into '/usr/local/cwaf' ? [y/n]:
```

Basta accettare il percorso come indicato e quindi digitare "y" nel campo successivo per il percorso di installazione.

Se hai un percorso non standard per il file di configurazione di Apache/nginx, devi inserirlo qui, altrimenti premi semplicemente 'Invio' per non apportare modifiche:

`Se hai un percorso di configurazione Apache/nginx non standard, inseriscilo qui:`

È qui che entra in gioco il fallimento, e l'unico rimedio è quello di scaricare e installare manualmente le regole. Rispondere alle richieste come mostrato di seguito:

```
Do you want to use HTTP GUI to manage CWAF rules? [y/n]: n
Do you want to protect your server with default rule set? [y/n]: y
```

Ma aspettatevi anche di ottenere il prossimo messaggio:

```
 Warning! Rules have not been updated. Check your credentials and try again later manually
+------------------------------------------------------
| LOG : Warning! Rules have not been updated. Check your credentials and try again later manually
+------------------------------------------------------
| Installation complete!
| Please add the line:
|   Include "/usr/local/cwaf/etc/modsec2_standalone.conf"
| to Apache config file.
| To update ModSecurity ruleset run
|   /usr/local/cwaf/scripts/updater.pl
| Restart Apache after that.
| You may find useful utility /usr/local/cwaf/scripts/cwaf-cli.pl
| Also you may examine file
|   /usr/local/cwaf/INFO.TXT
| for some useful software information.
+------------------------------------------------------
| LOG : All Done!
| LOG : Exiting
```

È un po' frustrante. Puoi andare al tuo account sul sito web di Comodo e cambiare la tua password e rieseguire lo script d'installazione, MA, non cambierà nulla. Le credenziali falliranno ancora.

### <a name="cwaf_fix"></a> File Delle Regole Cwaf Soluzione Temporanea

Per risolvere questo problema, dobbiamo installare manualmente le regole dal sito web. Questo viene fatto accedendo al tuo account su https://waf.comodo.com e cliccando sul link "Download Full Rule Set". Dovrai quindi copiare le regole sul tuo server web usando scp'

Esempio: `scp cwaf_rules-1.233.tgz root@mywebserversdomainname.com:/root/`

Una volta che il file gzip tar è stato copiato, spostare il file nella directory delle regole:

`mv /root/cwaf_rules-1.233.tgz /usr/local/cwaf/rules/`

Quindi vai alla directory delle regole:

`cd /usr/local/cwaf/rules/`

E decomprimi le regole:

`tar xzvf cwaf_rules-1.233.tgz`

Eventuali aggiornamenti parziali delle regole dovranno essere trattati nello stesso modo.

È qui che il pagamento delle regole e del supporto può essere utile. Tutto dipende dal vostro budget.

### Configurazione CWAF

Quando abbiamo installato _mod\_security_, il file di configurazione predefinito è stato installato in `/etc/httpd/conf.d/mod_security.conf`. La prossima cosa che dobbiamo fare è modificare questo in due punti. Inizia modificando il file:

`vi /etc/httpd/conf.d/mod_security.conf`

Nella parte superiore del file, vedrai:

```
<IfModule mod_security2.c>
    # Default recommended configuration
    SecRuleEngine On
```

Sotto la linea `SecRuleEngine On` aggiungi `SecStatusEngine On` in modo che la parte superiore del file ora assomigli a questo:

```
<IfModule mod_security2.c>
    # Default recommended configuration
    SecRuleEngine On
    SecStatusEngine On
```

Successivamente vai in fondo a questo file di configurazione. Dobbiamo dire a _mod\_security_ da dove caricare le regole. Dovresti vedere questo in fondo al file prima di fare delle modifiche:

```
    # ModSecurity Core Rules Set and Local configuration
    IncludeOptional modsecurity.d/*.conf
    IncludeOptional modsecurity.d/activated_rules/*.conf
    IncludeOptional modsecurity.d/local_rules/*.conf 
</IfModule>
```

Dobbiamo aggiungere una riga in basso per aggiungere la configurazione CWAF, che a sua volta carica le regole CWAF. Quella riga è `Include "/usr/local/cwaf/etc/cwaf.conf"`. Il parte inferiore di questo file dovrebbe apparire così quando avete finito:

```
    # ModSecurity Core Rules Set and Local configuration
    IncludeOptional modsecurity.d/*.conf
    IncludeOptional modsecurity.d/activated_rules/*.conf
    IncludeOptional modsecurity.d/local_rules/*.conf
    Include "/usr/local/cwaf/etc/cwaf.conf" 
</IfModule>
```

Ora salva le tue modifiche (con vi è `SHIFT+:+wq!`) e riavvia httpd:

`systemctl restart httpd`

Se httpd inizia OK, allora sei pronto per iniziare a usare _mod\_security_ con il CWAF.

## Conclusione

_mod\_security_ con CWAF è un altro strumento che può essere utilizzato per rendere più robusto un server web Apache. Perché le password di CWAF richiedono punteggiatura e perché l'installazione standalone non invia la punteggiatura correttamente, la gestione delle regole CWAF richiede l'accesso al sito CWAF e il download di regole e modifiche.

_mod\_security_, come altri strumenti di rinforzo, ha il potenziale di risposte false-positive, così si deve essere pronti a sintonizzare questo strumento per la vostra installazione.

Come altre soluzioni menzionate nella guida [Irrobustire Apache Web Server](index.md), ci sono altre soluzioni gratuite e a pagamento per le regole _mod\_security_, e per questo, altre applicazioni WAF disponibili. Puoi dare un'occhiata a uno di questi sul sito di [_Atomicorp_ mod\_security](https://atomicorp.com/atomic-modsecurity-rules/).
