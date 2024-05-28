---
title: Pound
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 8.5, 8.6
tags:
  - proxy
  - proxies
---

# Server proxy pound

!!! warning "Pound mancante in EPEL-9"

    Al momento, su Rocky Linux 9.0, Pound non può essere installato dal repository EPEL. Sebbene esistano fonti per i pacchetti SRPM, non possiamo verificarne l'integrità. Per questo motivo, al momento non è consigliabile installare il server proxy Pound su Rocky Linux 9.0. La situazione potrebbe cambiare se l'EPEL tornasse ad occuparsi di Pound.  Utilizzare questa procedura specificamente per le versioni Rocky Linux 8.x.

## Introduzione

Pound è un reverse proxy e load balancer indipendente dal server web, semplice da configurare e gestire. Non utilizza un servizio web, ma ascolta le porte del servizio web (http, https).

Esistono molte opzioni di server proxy, alcune delle quali sono citate in queste pagine di documentazione. Un documento sull'uso di [HAProxy è qui](haproxy_apache_lxd.md) e riferimenti all'applicazione di Nginx come reverse proxy esistono in altri documenti.

I servizi di bilanciamento del carico sono molto utili in un ambiente di server web molto trafficato. Esistono molti server proxy, tra cui il già citato HAProxy, e vengono utilizzati per molti tipi di servizi.

Nel caso di Pound, è utilizzabile solo per i servizi web, ma è efficace in ciò che fa.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- Il desiderio di bilanciare il carico tra alcuni siti web o la volontà di imparare un nuovo strumento per fare lo stessa cosa.
- La possibilità di eseguire comandi come utente root o di usare `sudo` per elevare i privilegi.
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma potete sostituirlo con il vostro editor preferito.
- La comodità di cambiare le porte di ascolto su alcuni tipi di server web.
- Supponendo l'installazione precedente dei server Nginx e Apache.
- Supponendo che si stiano usando server Rocky Linux o container per ogni cosa.
- Sebbene in questo documento siano presenti tutti i tipi di dichiarazioni relative a `https`, questa guida si occupa solo del servizio `http`. Per utilizzare correttamente l'`https`, è necessario configurare il server pound con un vero certificato di una vera autorità di certificazione.

!!! tip "Suggerimento"

    Se non avete installato nessuno di questi server, potete farlo su un ambiente di container (LXD o Docker) o su una macchina fisica e metterli in funzione. Per questa procedura, è necessario installarli con i rispettivi pacchetti e abilitare e avviare i servizi. Non li modificheremo in modo significativo.

    ```
    dnf -y install nginx && systemctl enable --now nginx
    ```


    o

    ```
    dnf -y install httpd && systemctl enable --now httpd
    ```

## Convenzioni

Per questa procedura, utilizzeremo due server web (noti come server back end), uno con Nginx (192.168.1.111) e uno con Apache (192.168.1.108).

Il nostro server Pound (192.168.1.103) è il gateway.

Le porte di ascolto dei server back end saranno 8080 per il server Nginx e 8081 per il server Apache. (In basso viene presentato tutto.)

!!! note "Nota"

    Ricordate di cambiare gli IP associati con quelli del vostro ambiente e di sostituirli, se necessario, nel corso di questa procedura.

## Installazione del server Pound

Per installare Pound, è necessario installare prima EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti:

```bash
dnf -y install epel-release && dnf -y update
```

Quindi installare Pound. (Sì, è una "P" maiuscola):

```bash
dnf -y install Pound
```

## Configurazione di Pound

Una volta installati i pacchetti, è necessario configurare Pound. L'autore usa `vi` per aggiornare questo documento, ma se preferite `nano` o qualcos'altro, sostituitelo pure:

```bash
vi /etc/pound.cfg
```

Il file contiene informazioni predefinite, che rendono facile individuare la maggior parte dei componenti predefiniti di Pound:

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

- Lo "User" e il "Group" - inseriti durante l'installazione
- Il file "Control" non viene utilizzato da nessuna parte
- La sezione "ListenHTTP" rappresenta il servizio `http` (Porta 80) e l'"Address" su cui il proxy ascolterà. Si cambierà questo indirizzo con l'IP effettivo del nostro server Pound.
- La sezione "ListenHTTPS" rappresenta il servizio `https` (Porta 443) e l'"Address" su cui il proxy ascolterà. Si cambierà questo indirizzo con l'IP del server Pound.
- L'opzione "Cert" è il certificato autofirmato fornito dal processo di installazione di Pound. In un ambiente di produzione, si desidera sostituire questo certificato con un certificato reale utilizzando una delle seguenti procedure: [Generazione di chiavi SSL](../security/ssl_keys_https.md) or [Chiavi SSL con Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).
- La sezione "Service" configura i server "BackEnd" con le loro porte di ascolto. È possibile avere quanti server "BackEnd" si desiderano.

### Modifica della configurazione

- cambiare l'indirizzo IP in ciascuna opzione di ascolto con l'indirizzo IP del nostro server Pound, 192.168.1.103
- cambiare gli indirizzi IP e le porte nelle sezioni "BackEnd" in modo che corrispondano alla nostra configurazione trovata in "Convenzioni" sopra (IP e porte)

Una volta terminata la modifica della configurazione, il file avrà un aspetto simile a questo:

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

Poiché nella nostra configurazione di Pound la porta di ascolto di Nginx è stata impostata su 8080, è necessario apportare questa modifica anche al server Nginx in uso. Per farlo, modificare il file `nginx.conf`:

```bash
vi /etc/nginx/nginx.conf
```

È sufficiente modificare la riga "listen" con il nuovo numero di porta:

```bash
listen       8080 default_server;
```

Salvare le modifiche e riavviare il servizio nginx:

```bash
systemctl restart nginx
```

## Configurazione di Apache in ascolto su 8081

Poiché nella configurazione di Pound è stata impostata la porta di ascolto per Apache a 8081, è necessario apportare questa modifica anche al server Apache in esecuzione. Per farlo, è necessario modificare il file `httpd.conf`:

```bash
vi /etc/httpd/conf/httpd.conf
```

Si desidera modificare la riga "Listen" con il nuovo numero di porta:

```bash
Listen 8081
```

Salvate le modifiche e riavviate il servizio httpd:

```bash
systemctl restart httpd
```

## Test e avvio

Una volta che i servizi web sono attivi e funzionanti e in ascolto sulle porte giuste su ciascuno dei server, il passo successivo è quello di attivare il servizio pound sul server Pound:

```bash
systemctl enable --now pound
```

!!! warning "Attenzione"

    Utilizzando Nginx e Apache, come fatto qui a titolo dimostrativo, il server Nginx risponderà quasi sempre per primo. Per questo motivo, per eseguire un test efficace, è necessario assegnare una priorità bassa al server Nginx, in modo da poter vedere entrambe le schermate. Questo la dice lunga sulla velocità di Nginx rispetto ad Apache. Per modificare la priorità del server Nginx, basta aggiungere una priorità (da 1 a 9, dove 9 è la priorità più bassa) nella sezione "BackEnd" del server Nginx, in questo modo:

    ```
    BackEnd
        Address 192.168.1.111
        Port    8080
        Priority 9
    End
    ```

Quando si apre l'IP del server proxy in un browser web, viene visualizzata una di queste due schermate:

![Pound Nginx](images/pound_nginx.jpg)

Oppure

![Pound Apache](images/pound_apache.jpg)

## Utilizzare Emergency

Una cosa che potrebbe essere necessario fare quando si utilizza un bilanciatore di carico come Pound, è di mettere fuori linea i server di produzione per la manutenzione o di avere un "BackEnd" di riserva per un'interruzione completa. Questo viene fatto con la dichiarazione "Emergency" nel file `pound.conf`. È possibile avere una sola dichiarazione di "Emergency" per servizio. Nel nostro caso, questo comparirà alla fine della sezione "Service" del nostro file di configurazione:

```bash
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

Questo server potrebbe mostrare solo un messaggio che dice "Down for Maintenance".

## Considerazioni sulla sicurezza

Un aspetto che la maggior parte dei documenti che trattano il bilanciamento del carico dei server proxy non affronta è quello della sicurezza. Ad esempio, se si tratta di un server web pubblico, è necessario che i servizi `http` e `https` siano aperti al mondo sul proxy di bilanciamento del carico. Ma che dire dei server "BackEnd"?

È necessario accedere a queste porte solo dal server Pound, ma poiché il server Pound reindirizza a 8080 o 8081 sui server BackEnd e poiché i server BackEnd hanno `http` in ascolto su queste porte successive, è possibile utilizzare i nomi dei servizi per i comandi del firewall su questi server BackEnd.

Questa sezione si occuperà di questi problemi e dei comandi `firewalld` necessari per bloccare tutto.

!!! warning "Attenzione"

    Il presupposto è che abbiate accesso diretto ai server in questione e che non siate in remoto. Se siete in remoto, fate molta attenzione quando rimuovete i servizi da una zona `firewalld`!
    
    Potreste chiudervi accidentalmente fuori dal vostro server.

### Firewall - server Pound

Per il server Pound, si desidera consentire `http` e `https` dal mondo. È meglio valutare se è necessario consentire `ssh` dal mondo o meno. Se si lavora in locale sul server, questo probabilmente **NON** è il caso. L'autore ipotizza che il server sia disponibile attraverso la rete locale e che si abbia accesso diretto ad esso, quindi si bloccherà `ssh` agli IP della propria LAN.

Per farlo, si utilizzerà il firewall integrato di Rocky Linux, `firewalld` e la struttura di comandi `firewall-cmd`. Si utilizzeranno anche due zone integrate, "public" e "trusted", per non complicare le cose.

Iniziare aggiungendo i nostri IP di origine alla zona "trusted". Questa è la nostra LAN (nel nostro esempio: 192.168.1.0/24):

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

Aggiungiamo quindi il servizio `ssh` alla zona:

```bash
firewall-cmd --zone=trusted --add-service=ssh --permanent
```

E ricaricare il firewall con:

```bash
firewall-cmd --reload
```

Elencate la zona in modo da poter vedere tutto con `firewall-cmd --zone=trusted --list-all` che vi darà qualcosa di simile a questo:

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

Successivamente è necessario apportare le modifiche alla zona "public", che per impostazione predefinita ha il servizio `ssh` abilitato. Questo deve essere accuratamente rimosso (ancora una volta, l'autore presume che **NON** siate in remoto sul server!) con quanto segue:

```bash
firewall-cmd --zone=public --remove-service=ssh --permanent
```

Dobbiamo anche aggiungere i servizi `http` e `https`:

```bash
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

Quindi è necessario ricaricare il firewall prima di poter vedere le modifiche:

```bash
firewall-cmd --reload
```

Elencare la zona pubblica con `firewall-cmd --zone=public --list-all` che mostrerà qualcosa di simile a questo:

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

Queste sono le uniche modifiche necessarie al nostro bilanciatore di carico del server pound nell'ambiente di laboratorio.

### Firewall - server di back end

Per i server "BackEnd", non è necessario consentire l'accesso dal mondo per nessun motivo. È necessario consentire `ssh` dagli IP della LAN e `http` e `https` dal nostro bilanciatore di carico Pound.

Questo è praticamente tutto.

Anche in questo caso, si aggiungerà il servizio `ssh` alla zona "trusted", con gli stessi comandi utilizzati per il server pound. Aggiungete quindi una zona chiamata "balance" che userete per i restanti `http` e `https` e impostate gli IP di origine su quelli del bilanciatore di carico.

Per semplificare le cose, utilizzare tutti i comandi utilizzati per la zona "trusted" in un'unica serie di comandi:

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

Dopo, la zona "trusted " avrà il seguente aspetto:

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

Ancora una volta, testate la regola `ssh` da un IP della LAN e poi rimuovete il servizio `ssh` dalla zona "public". **Ricordate l'avvertimento precedente e fatelo solo se avete accesso locale al server!**

```bash
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

La zona pubblica avrà ora il seguente aspetto:

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

Aggiungere una nuova zona per gestire `http` e `https`. Ricordate che l'IP di origine deve essere solo il vostro bilanciatore di carico (nel nostro esempio: 192.168.1.103):

!!! note "Nota"

    Una nuova zona deve essere aggiunta con l'opzione `--permanent` e non può essere utilizzata finché il firewall non viene ricaricato. Inoltre, non dimenticare di impostare `-set-target=ACCEPT` per questa zona!

```bash
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

Ripetere questi passaggi sull'altro back end del server web.

Una volta aggiunte le regole del firewall al tutto, testate nuovamente il vostro server Pound dal browser della vostra workstation.

## Altre informazioni

Sono *molte* le opzioni utilizzabili nel file `pound.conf`, tra cui le direttive per i messaggi di errore, le opzioni di registrazione, i valori di time out e altro ancora. Per conoscere la disponibilità si può consultare il sito [guardando qui.](https://linux.die.net/man/8/pound)

Convenientemente, Pound capisce automaticamente se uno dei server "BackEnd" è off-line e lo disabilita in modo che i servizi web possano continuare senza ritardi. Inoltre, li rivede automaticamente quando tornano in linea.

## Conclusione

Pound offre un'altra opzione per chi non vuole usare HAProxy o Nginx per il bilanciamento del carico.

Pound come server di bilanciamento del carico è molto facile da installare, configurare e utilizzare. Come si è detto, è possibile usare Pound come reverse proxy, ed esistono molte opzioni di proxy e bilanciamento del carico.

Inoltre, è necessario tenere sempre presente la sicurezza quando si configura qualsiasi servizio, compreso un server proxy di bilanciamento del carico.
