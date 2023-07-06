---
title: Pound
author: Steven Spencer
contributors:
tested_with: 8.5, 8.6
tags:
  - proxy
  - proxies
---

# Server Proxy Pound

!!! warning "Pound mancante in EPEL-9"

    Al momento, su Rocky Linux 9.0, Pound non può essere installato dal repository EPEL. Sebbene esistano fonti per i pacchetti SRPM, non possiamo verificarne l'integrità. Per questo motivo, al momento non è consigliabile installare il server proxy Pound su Rocky Linux 9.0. La situazione potrebbe cambiare se l'EPEL tornasse ad occuparsi di Pound.  Utilizzare questa procedura specificamente per le versioni Rocky Linux 8.x.

## Introduzione

Pound è un reverse proxy e load balancer indipendente dal server web, molto facile da configurare e gestire. Non utilizza un servizio web, ma ascolta le porte del servizio web (http, https).

Esistono molte opzioni di server proxy, alcune delle quali sono citate in queste pagine di documentazione. [Qui](haproxy_apache_lxd.md) si trova un documento sull'uso di [HAProxy](haproxy_apache_lxd.md) e in altri documenti si fa riferimento all'uso di Nginx come reverse proxy.

I servizi di bilanciamento del carico sono molto utili in un ambiente di server web molto trafficato. Molti server proxy, tra cui il già citato HAProxy, possono essere utilizzati per molti tipi di servizi.

Nel caso di Pound, può essere utilizzato solo per i servizi web, ma è ottimo per quello che fa.

## Prerequisiti e Presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

* Il desiderio di bilanciare il carico di alcuni siti web o il desiderio di imparare un nuovo strumento fanno lo stesso.
* La possibilità di eseguire comandi come utente root o di usare `sudo` per arrivarci.
* Familiarità con un editor a riga di comando. In questo caso utilizziamo `vi` o `vim`, ma potete sostituirlo con il vostro editor preferito.
* La comodità di cambiare le porte di ascolto su alcuni tipi di server web.
* Si presume che i server Nginx e Apache siano già installati.
* Si presume che qui si utilizzino server Rocky Linux o container per ogni cosa.
* Sebbene di seguito si facciano dichiarazioni di ogni tipo su `https`, questa guida si occupa solo del servizio `http`. Per utilizzare correttamente l'`https`, è necessario configurare il server pound con un vero certificato di una vera autorità di certificazione.

!!! tip "Suggerimento"

    Se non avete installato nessuno di questi server, potete farlo su un ambiente di container (LXD o Docker) o su una macchina fisica e metterli in funzione. Per questa procedura, è sufficiente installarli con i rispettivi pacchetti e abilitare e avviare i servizi. Non li modificheremo in modo significativo.

    ```
    dnf -y install nginx && systemctl enable --now nginx
    ```


    o

    ```
    dnf -y install httpd && systemctl enable --now httpd
    ```

## Convenzioni

Per questa procedura, utilizzeremo due server web (noti come server back end), uno con Nginx (192.168.1.111) e uno con Apache (192.168.1.108).

Il nostro server Pound (192.168.1.103) sarà considerato il gateway.

We will be switching our listen ports on both of the back end servers to 8080 for the Nginx server and 8081 for the Apache server. Tutto sarà dettagliato di seguito, quindi per il momento non c'è bisogno di preoccuparsi.

!!! note "Nota"

    Ricordate di cambiare gli IP associati con quelli del vostro ambiente e di sostituirli, se necessario, nel corso di questa procedura.

## Installazione del server Pound

Per installare Pound, dobbiamo prima installare EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti nel caso in cui ci siano novità con EPEL:

```
dnf -y install epel-release && dnf -y update
```

Poi basta installare Pound. (Sì, è una "P" maiuscola):

```
dnf -y install Pound
```

## Configurazione di Pound

Ora che i pacchetti sono installati, dobbiamo configurare Pound. Per l'aggiornamento useremo `vi`, ma se preferite `nano` o qualcos'altro, sostituitelo pure:

```bash
vi /etc/pound.cfg
```

Il file è impostato con informazioni predefinite, il che rende facile vedere la maggior parte dei componenti predefiniti di Pound:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 0.0.0.0
    Port 80
End

ListenHTTPS
    Address 0.0.0.0
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 127.0.0.1
        Port    8000
    End

    BackEnd
        Address 127.0.0.1
        Port    8001
    End
End
```

### Uno sguardo più approfondito

* Lo "User" e il "Group" sono stati gestiti durante l'installazione
* Il file "Control" non sembra essere utilizzato da nessuna parte.
* La sezione "ListenHTTP" rappresenta il servizio `http` (Porta 80) e l'"Address" su cui il proxy ascolterà. Cambieremo questo indirizzo con l'IP effettivo del nostro server Pound.
* La sezione "ListenHTTPS" rappresenta il servizio `https` (Porta 443) e l'"Address" su cui il proxy ascolterà. Come nel caso precedente, cambieremo l'IP con quello del server Pound. L'opzione "Cert" è il certificato autofirmato fornito dal processo di installazione di Pound. In un ambiente di produzione, si consiglia di sostituirlo con un certificato reale utilizzando una delle seguenti procedure: [Generazione di chiavi SSL](../security/ssl_keys_https.md) o [Chiavi SSL con Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).
* Nella sezione "Service" si configurano i server "BackEnd" e le loro porte di ascolto. È possibile avere il numero di server "BackEnd" necessario.

### Modifica della Configurazione

* cambiare l'indirizzo IP in entrambe le opzioni di ascolto con l'IP del nostro server Pound, 192.168.1.103
* cambiare gli indirizzi IP e le porte nelle sezioni "BackEnd" in modo che corrispondano alla nostra configurazione trovata in "Convenzioni" sopra (IP e porte)

Una volta terminata la modifica della configurazione, si dovrebbe avere un file modificato che assomiglia a questo:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 192.168.1.103
    Port 80
End

ListenHTTPS
    Address 192.168.1.103
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 192.168.1.111
        Port    8080
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
End
```

## Configurazione di Nginx per l'ascolto su 8080

Poiché nella nostra configurazione di Pound abbiamo impostato la porta di ascolto per Nginx su 8080, dobbiamo apportare questa modifica anche al nostro server Nginx in esecuzione. Per farlo, si modifica il file `nginx.conf:`

```bash
vi /etc/nginx/nginx.conf
```

È sufficiente modificare la riga "listen" con il nuovo numero di porta:

```bash
listen       8080 default_server;
```

Salvare le modifiche e riavviare il servizio nginx:

```
systemctl restart nginx
```

## Configurazione di Apache in ascolto su 8081

Poiché nella nostra configurazione di Pound abbiamo impostato la porta di ascolto per Apache a 8081, dobbiamo apportare questa modifica anche al nostro server Apache in esecuzione. Per farlo, si modifica il file `httpd.conf:`

```bash
vi /etc/httpd/conf/httpd.conf
```

Si desidera modificare la riga "Listen" con il nuovo numero di porta:

```bash
Listen 8081
```

Salvate le modifiche e riavviate il servizio httpd:

```
systemctl restart httpd
```

## Test e Avvio

Una volta che i servizi web sono attivi e funzionanti e in ascolto sulle porte giuste di ciascuno dei nostri server, il passo successivo è quello di attivare il servizio Pound sul server Pound:

```
systemctl enable --now pound
```

!!! warning "Attenzione"

    Utilizzando Nginx e Apache, come facciamo qui a titolo dimostrativo, il server Nginx risponderà quasi sempre per primo. Per questo motivo, per eseguire un test efficace, è necessario assegnare una priorità bassa al server Nginx, in modo da poter vedere entrambe le schermate. Questo la dice lunga sulla velocità di Nginx rispetto ad Apache. Per modificare la priorità del server Nginx, basta aggiungere una priorità (da 1 a 9, dove 9 è la priorità più bassa) nella sezione "BackEnd" del server Nginx, in questo modo:

    ```
    BackEnd
        Address 192.168.1.111
        Port    8080
        Priority 9
    End
    ```

Quando si apre l'ip del server proxy in un browser web, ci si dovrebbe trovare di fronte a una di queste due schermate:

![Pound Nginx](images/pound_nginx.jpg)

Oppure

![Pound Apache](images/pound_apache.jpg)

## Utilizzare Emergency

Una cosa che potrebbe essere necessario fare quando si utilizza un bilanciatore di carico come Pound, è di mettere fuori linea i server di produzione per la manutenzione o di avere un "BackEnd" di riserva per un'interruzione completa. Questo viene fatto con la dichiarazione "Emergency" nel file `pound.conf`. È possibile avere una sola dichiarazione di "Emergency" per servizio. Nel nostro caso, questo appare alla fine della sezione "Service" del nostro file di configurazione:

```
...
Service
    BackEnd
        Address 192.168.1.117
        Port    8080
    Priority 9
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
    Emergency
       Address 192.168.1.104
       Port 8000
   End
End
```

Questo server potrebbe visualizzare solo un messaggio che dice "Down for Maintenance".

## Considerazioni sulla Sicurezza

Un aspetto che la maggior parte dei documenti che trattano il bilanciamento del carico dei server proxy non affronta sono i problemi di sicurezza. Ad esempio, se si tratta di un server web pubblico, è necessario che i servizi `http` e `https` siano aperti al mondo sul proxy di bilanciamento del carico. Ma che dire dei server "BackEnd"?

Dovrebbe essere necessario accedere alle loro porte solo dal server Pound stesso, ma poiché il server Pound esegue il reindirizzamento a 8080 o 8081 sui server BackEnd e poiché i server BackEnd hanno l'ascolto `http` in ascolto sulle porte successive, è possibile utilizzare i nomi dei servizi per i comandi del firewall su questi server BackEnd.

In questa sezione ci occuperemo di questi problemi e dei comandi `firewalld` necessari per bloccare tutto.

!!! warning "Attenzione"

    Presumiamo che abbiate accesso diretto ai server in questione e che non siate in remoto. Se siete in remoto, fate molta attenzione quando rimuovete i servizi da una zona `firewalld`!
    
    Potreste chiudervi accidentalmente fuori dal vostro server.

### Firewall - Server Pound

Per il server Pound, come già detto, vogliamo consentire `http` e `https` dal mondo. È necessario considerare se `ssh` deve essere consentito dal mondo o meno. Se si è in locale sul server, questo probabilmente **NON** è il caso. Si presuppone che il server sia disponibile attraverso la rete locale e che si abbia accesso diretto ad esso, quindi si bloccherà `ssh` agli IP della LAN.

Per realizzare quanto sopra, utilizzeremo il firewall integrato in Rocky Linux, `firewalld` e la struttura di comandi `firewall-cmd`. Per semplicità, utilizzeremo anche due delle zone integrate, "public" e "trusted".

Iniziamo aggiungendo i nostri IP di origine alla zona "trusted". Questa è la nostra LAN (nel nostro esempio: 192.168.1.0/24):

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

Aggiungiamo quindi il servizio `ssh` alla zona:

```
firewall-cmd --zone=trusted --add-service=ssh --permanent
```

Una volta completata questa operazione, ricaricare il firewall con:

```
firewall-cmd --reload
```

Quindi elencare la zona in modo da poter vedere tutto con `firewall-cmd --zone=trusted --list-all`, che dovrebbe dare un risultato simile a questo:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

```

Successivamente è necessario apportare le modifiche alla zona "public", che per impostazione predefinita ha il servizio `ssh` abilitato. Questo deve essere accuratamente rimosso (ancora una volta, si presuppone che **non** siate in remoto sul server!) con il seguente metodo:

```
firewall-cmd --zone=public --remove-service=ssh --permanent
```
Dobbiamo anche aggiungere i servizi `http` e `https`:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

Quindi è necessario ricaricare il firewall prima di poter vedere le modifiche:

```
firewall-cmd --reload
```

Quindi elencare la zona pubblica con `firewall-cmd --zone=public --list-all`, che dovrebbe mostrare qualcosa di simile:

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Nel nostro ambiente di laboratorio, queste sono le uniche modifiche da apportare al nostro bilanciatore di carico del server pound.

### Firewall - Server Back End

Per i server "BackEnd", non abbiamo bisogno di consentire l'accesso dal mondo per nessun motivo e sicuramente non per le nostre porte di ascolto che il bilanciatore di carico utilizzerà. Dovremo consentire `ssh` dagli IP della LAN e `http` e `https` dal nostro bilanciatore di carico pound.

Questo è praticamente tutto.

Anche in questo caso, aggiungeremo il servizio `ssh` alla nostra zona "trusted", con gli stessi comandi che abbiamo usato per il nostro server pound. Quindi aggiungeremo una zona chiamata "balance" che utilizzeremo per i restanti `http` e `https` e imposteremo gli IP di origine su quello del bilanciatore di carico. Vi state già divertendo?

Per essere veloci, utilizziamo tutti i comandi che abbiamo usato per la zona "trusted" in un'unica serie di comandi:

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

Dopo, la zona "trusted" dovrebbe avere il seguente aspetto:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Ancora una volta, testate la regola `ssh` da un IP della LAN e poi rimuovete il servizio `ssh` dalla zona "public". **Ricordate l'avvertimento di cui sopra e fatelo solo se avete accesso locale al server!**

```
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

La zona pubblica dovrebbe ora apparire come segue:

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Now let's add that new zone to deal with `http` and `https`. Ricordate che l'IP di origine deve essere solo il nostro bilanciatore di carico (nel nostro esempio: 192.168.1.103):

!!! note "Nota"

    Una nuova zona deve essere aggiunta con l'opzione `--permanent` e non può essere utilizzata finché il firewall non viene ricaricato. Inoltre, non dimenticare di `-set-target=ACCEPT` per questa zona!

```
firewall-cmd --new-zone=balance --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --set-target=ACCEPT
firewall-cmd --zone=balance --add-source=192.168.1.103 --permanent
firewall-cmd --zone=balance --add-service=http --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --list-all
```

Il risultato:

```bash
balance (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.103
  services: http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Ora ripetete questi passaggi sull'altro server web di backend.

Una volta aggiunte le regole del firewall a tutto, testate nuovamente il server pound dal browser della vostra workstation.

## Altre informazioni

Ci sono *MOLTE* opzioni che possono essere incluse nel file `pound.conf`, tra cui le direttive per i messaggi di errore, le opzioni di registrazione, i valori di time out, ecc. Per saperne di più su ciò che è disponibile, [consultate qui.](https://linux.die.net/man/8/pound)

Convenientemente, Pound capisce automaticamente se uno dei server "BackEnd" è off-line e lo disabilita in modo che i servizi web possano continuare senza ritardi. Inoltre, li rivede automaticamente quando tornano in linea.

## Conclusione

Pound offre un'altra opzione per chi non vuole usare HAProxy o Nginx per il bilanciamento del carico.

Pound come server di bilanciamento del carico è molto facile da installare, configurare e utilizzare. Come già detto, Pound può essere usato anche come reverse proxy e sono disponibili molte opzioni di proxy e bilanciamento del carico.

Inoltre, è necessario tenere sempre presente la sicurezza quando si configura qualsiasi servizio, compreso un server proxy di bilanciamento del carico.
