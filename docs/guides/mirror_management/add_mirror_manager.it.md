---
title: Aggiungere un Mirror Rocky
contributors: Amin Vakil, Steven Spencer, Franco Colussi
---

# Aggiunta di un mirror pubblico al gestore di mirror di Rocky

## Requisiti minimi per un mirror pubblico

Accogliamo sempre con favore nuovi mirrors pubblici. Ma dovrebbero essere ben mantenuti e ospitati in un centro dati 24/7 come ambiente. La larghezza di banda disponibile deve essere di almeno 1 GBit/s. Preferiamo i mirrors che offrono il doppio stack (IPv4 & IPv6). Si prega di non inserire mirror configurati utilizzando il DNS dinamico. Accetteremo anche velocità più basse se vi trovate in una regione con pochi mirror.

Si prega di non inviare mirror ospitati in un Anycast-CDN come Cloudflare, ecc. poiché ciò può portare a prestazioni non ottimali con la selezione del mirror più veloce in `dnf`.

Si ricorda che non è possibile accettare mirror pubblici in paesi soggetti alle normative statunitensi sull'esportazione. L'elenco di questi Paesi è disponibile qui: [https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations](https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations)

Al momento in cui scriviamo (fine 2022), lo spazio di archiviazione richiesto per il mirroring di tutte le versioni attuali e passate di Rocky Linux è di circa 2 TB.

Il nostro mirror master è `rsync://msync.rockylinux.org/rocky/mirror/pub/rocky/`. Per la prima sincronizzazione utilizzate un mirror vicino a voi. Potete trovare tutti i mirror ufficiali [qui](https://mirrors.rockylinux.org).

Si noti che in futuro potremmo limitare l'accesso al master mirror ufficiale ai mirror pubblici ufficiali. Per questo motivo, se gestite un mirror privato, prendete in considerazione l'opzione `rsyncing` da un mirror pubblico vicino a voi. Inoltre i mirror locali potrebbero essere più veloci da sincronizzare.

## Configurare il tuo mirror

Si prega di impostare un cron job per sincronizzare periodicamente il mirror e eseguirlo circa 6 volte al giorno. Ma assicurati di sincronizzare l'ora per aiutare a distribuire il carico nel tempo. Se si controlla solo le modifiche di `fullfiletimelist-rocky` e si esegue una sincronizzazione completa solo se questo file è cambiato, è possibile sincronizzare ogni ora.

Ecco alcuni esempi di crontab per voi:

```
#This will synchronize your mirror at 0:50, 4:50, 8:50, 12:50, 16:50, 20:50
50 */6  * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror at 2:25, 6:25, 10:25, 14:25, 18:25, 22:25
25 2,6,10,14,18,22 * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror every hour at 15 minutes past the hour.
#Only use if you are using our example script
15 * * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1
```

Per una semplice sincronizzazione si può usare il seguente comando `rsync`:

```
rsync -aqH --delete source-mirror destination-dir
```
Considerare l'uso di un meccanismo di blocco per evitare l'esecuzione simultanea di più lavori `rsync` quando si rilascia una nuova release.

È inoltre possibile utilizzare e modificare il nostro esempio di implementazione dello script di blocco e sincronizzazione completa, se necessario. Può essere trovato su [https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh](https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh).

Dopo la prima sincronizzazione completa controllare che tutto vada bene con il tuo mirror. La cosa più importante è verificare che tutti i file e le directory siano stati sincronizzati, che il cron job funzioni correttamente e che il mirror sia raggiungibile da Internet. Doppio controllo delle regole del tuo firewall! Per evitare problemi, non applicare il reindirizzamento da http a https.

Per qualsiasi domanda riguardante la configurazione del tuo mirror unisciti a https://chat.rockylinux.org/rocky-linux/channels/infrastructure

Quando avete finito, passate alla sezione successiva e proponete il vostro mirror per renderlo pubblico!

## Cosa Ti Serve
* Un account su https://accounts.rockylinux.org/

## Creare un sito

Rocky utilizza il Mirror Manager di Fedora per organizzare i mirror della comunità.

Accedi a Rocky's Mirror Manager qui: https://mirrors.rockylinux.org/mirrormanager/

Dopo un accesso riuscito, il tuo profilo sarà in alto a destra. Selezionare il menu a tendina quindi fare clic su "My sites".

Verrà caricata una nuova pagina con l'elenco di tutti i siti dell'account. La prima volta sarà vuota. Clicca su "Register a new site".

Verrà caricata una nuova pagina con un'importante dichiarazione di Conformità alle Esportazioni da leggere. Quindi compilare le seguenti informazioni:

* "Site Name"
* "Site Password" - utilizzato dallo script `report_mirrors`, si può utilizzare ciò che si preferisce
* "Organization URL" - URL dell'Azienda/Scuola/Organizzazione
* "Private" - Selezionando questa casella si nasconde il proprio mirror all'uso pubblico.
* "User active" - Deselezionare questa casella per disabilitare temporaneamente questo sito, che verrà rimosso dagli elenchi pubblici.
* "All sites can pull from me?" - Consentire a tutti i siti mirror di attingere da me senza aggiungerli esplicitamente al mio elenco.
* "Comments for downstream siteadmins. Includere qui la fonte di sincronizzazione per evitare cicli di dipendenze."

Facendo clic su "Submit" si torna alla pagina principale dei mirror.

## Configurazione del sito

Selezionare il menu a tendina dalla pagina principale del mirror, quindi fare clic su " My sites".

Verrà caricata la pagina dell'account e il sito dovrebbe essere elencato. Fare clic su di esso per accedere alle Information Site.

Tutte le opzioni dell'ultima sezione sono elencate di nuovo. In fondo alla pagina ci sono tre nuove opzioni: Admin, Hosts e Delete site. Clicca su "Hosts [add]".

## Creare un nuovo host

Compila le seguenti opzioni appropriate per il sito:

* "Host name" - richiesto: FQDN del server visto da un utente finale pubblico
* "User active" - Deselezionare questa casella per disabilitare temporaneamente questo host, che verrà rimosso dagli elenchi pubblici.
* "Country" - richiesto: Codice paese ISO a 2 lettere
* "Bandwidth" - richiesto: numero intero di megabit/sec, la quantità di larghezza di banda che questo host può servire
* "Private" - ad esempio, non disponibile al pubblico, un mirror privato interno
* "Internet2" - su Internet2
* "Internet2 clients" - serve i client di Internet2, anche se privati
* "ASN - Autonomous System Number, utilizzato nelle tabelle di routing BGP. Solo se siete un ISP.
* " ASN Clients" - Serve tutti i client dello stesso ASN. Utilizzato per ISP, aziende o scuole, non per reti personali.
* "Robot email" - indirizzo di posta elettronica, riceverà una notifica degli aggiornamenti dei contenuti upstream
* "Comment" - testo, qualsiasi altra cosa vogliate che un utente finale pubblico sappia sul vostro mirror
* "Max connections" - Connessioni massime di download parallelo per client, suggerite tramite metalinks.

Fare clic su "Create" e si verrà reindirizzati al sito informativo dell'host.

## Aggiornamento host

Nella parte inferiore di Information site, l'opzione "Hosts" dovrebbe ora visualizzare il titolo dell'host accanto ad essa. Fare clic sul nome per caricare la pagina dell'host. Vengono riproposte tutte le stesse opzioni del passo precedente. Ci sono nuove opzioni in basso.

* "Site-local Netblocks":  I Netblocks sono utilizzati per cercare di guidare l'utente finale verso un mirror specifico del sito. Ad esempio, un'università potrebbe elencare i propri netblocks e il CGI mirrorlist restituirà il mirror locale dell'università piuttosto che quello del paese. Il formato è uno dei seguenti: 18.0.0.0/255.0.0.0, 18.0.0.0/8, un prefisso/lunghezza IPv6 o un nome host DNS. I valori devono essere indirizzi IP pubblici (non indirizzi di spazio privati RFC1918). Utilizzare solo se si è un ISP e/o si possiede un blocco di rete instradabile pubblicamente!

* "Peer ASN":  I peer ASN sono utilizzati per guidare un utente finale su reti vicine verso il nostro mirror. Ad esempio, un'università potrebbe elencare i propri peer ASN e il CGI mirrorlist restituirà il mirror locale dell'università piuttosto che quello del paese. Per creare nuove voci in questa sezione è necessario far parte del gruppo di amministratori di MirrorManager.

* "Countries Allowed":  Alcuni mirror devono limitarsi a servire solo gli utenti finali del proprio paese. Se siete tra questi, elencate il codice ISO di 2 lettere per i paesi da cui consentite agli utenti finali di provenire. La mirrorlist CGI lo rispetterà.

* "Categories Carried":  Gli host trasportano categorie di software. Le categorie di Fedora includono Fedora e Fedora Archive.

Fare clic sul link "[add]" sotto "Categories Carried".

### Categories Carried

Per la Categoria, selezionare "Rocky Linux" e poi "Create" per caricare la pagina dell'URL. Quindi fare clic su "[add]" per caricare la pagina "Add host category URL". C'è una opzione. Ripetere l'operazione per ciascuno dei protocolli supportati dai mirrors.

* "URL" - URL (rsync, https, http) che punta alla directory superiore

Esempi:
* `http://rocky.example.com`
* `https://rocky.example.com`
* `rsync://rocky.example.com`


## Conclusione

Una volta compilate le informazioni, il sito dovrebbe apparire nell'elenco dei mirror non appena si verifica il successivo aggiornamento dei mirror.
