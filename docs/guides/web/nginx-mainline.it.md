---
title: Nginx
author: Ezequiel Bruni
contributors: Antoine Le Morvan, Steven Spencer
tested with: 8.5
---

# Come installare il più recente Nginx su Rocky Linux

## Introduzione

Per dare credito a ciò che è dovuto, non mi è venuto in mente niente di tutto questo. In particolare, questa guida è fortemente basata su [quella di Joshua James](https://www.linuxcapable.com/how-to-install-latest-nginx-mainline-on-rocky-linux-8/) su [LinuxCapable](https://www.linuxcapable.com). Andate a leggere il suo sito qualche volta, c'è un sacco di roba interessante. Adesso, su questa guida (beginner-friendly):

*Nginx* è un server web progettato per essere veloce, efficiente e compatibile con qualsiasi cosa si possa immaginare. Personalmente lo uso un po' e — una volta che ci si prende la mano — è in realtà abbastanza facile da impostare e configurare. Ecco un breve riassunto delle caratteristiche principali; Nginx è/ha/può essere:

* Un server web di base (si spera)
* Un reverse proxy per dirigere il traffico verso più siti
* Un bilanciatore di carico integrato per gestire il traffico verso più siti web
* Caching dei file incorporato per la velocità
* WebSockets
* Supporto FastCGI
* E, naturalmente, IPv6

È fantastico! Quindi basta `sudo dnf install nginx`, giusto? Beh, non esattamente. **I repository di Rocky Linux non hanno l'ultima versione pronta per la produzione di Nginx.** Poiché l'obiettivo di Rocky Linux è quello di essere compatibile bug per bug con Red Hat Enterprise Linux, si può sempre chiedere a Red Hat di aggiornare i loro repository. O chiedere alla gente di *Nginx* potrebbe funzionare meglio (vedrete cosa intendo).

Quello che *tu* puoi fare, in questo momento, è installare il ramo "mainline" di Nginx da solo. Ha tutti gli ultimi aggiornamenti e strumenti, e (a mio avviso) una struttura di directory più semplice per i suoi file di configurazione. Ecco come vedere tutto questo da soli:

!!! Note "Nota"

    C'è un altro ramo chiamato "stable", ma in realtà è un po' superato per la maggior parte dei casi d'uso. Non riceverà nuove caratteristiche man mano che vengono sviluppate, e solo le correzioni di bug e gli aggiornamenti di sicurezza più urgenti.
    
    Gli sviluppatori di Nginx considerano il ramo "mainline" ben testato e stabile per l'uso generale, *in quanto ottiene tutte le nuove funzionalità, tutte le correzioni di sicurezza e tutte le correzioni di bug.*
    
    Le uniche ragioni per usare il ramo "stable" sono:
    * vuoi *veramente* essere sicuro che le nuove caratteristiche e le correzioni importanti non interrompano il codice di terze parti o il tuo codice personalizzato.
    * Volete attenervi solo ai repository software di Rocky Linux.
    
    Ci sarà un tutorial alla fine di questa guida che spiega in dettaglio come abilitare e installare il ramo "stable" con il minimo sforzo.

## Prerequisiti e presupposti

Avrai bisogno di:

* Una macchina o un server Rocky Linux connesso a internet.
* Una familiarità di base con la riga di comando.
* La capacità di eseguire comandi come root, sia come utente root che con `sudo`.
* Un editor di testo a tua scelta, sia grafico che a riga di comando. Per questo tutorial, sto usando `nano`.

## Installazione del repository

Questa parte non è così semplice come lo è di solito l'installazione di un repository extra. Dovremo creare un file repo personalizzato per `dnf` da usare, e scaricare *Nginx* da lì. Tecnicamente, siamo una sorta di repurposing di repository per CentOS che sono stati fatti e ospitati da *Nginx* stesso. Questa soluzione può o non può essere praticabile a lungo termine, ma per ora funziona benissimo.

Per prima cosa, assicuratevi che la vostra macchina sia aggiornata:

```bash
sudo dnf update
```

Ora, assicurati che il pacchetto `dnf-utils` sia installato, e qualsiasi editor di testo a riga di comando tu voglia:

```bash
sudo dnf install dnf-utils
```

Una volta che è tutto installato, apri il tuo editor di testo preferito. Vorrai creare un file chiamato (per semplicità) `nginx.repo`, e metterlo in `/etc/yum.repos.d/`. Potete farlo molto velocemente in questo modo:

```bash
sudo nano /etc/yum.repos.d/nginx.repo
```

In quel file, incollate questo pezzo di codice, non modificato:

```bash
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

Questo codice fondamentalmente ti permette di usare i repository *Nginx* fatti e ospitati per CentOS, e se vuoi ti permette di usare il ramo "stable" menzionato in precedenza. Voglio dire, non farlo. Ma si potrebbe.

Salva il file con <kbd>Control</kbd>-<kbd>S</kbd> (se stai usando `nano`) ed esci con <kbd>Control</kbd>-<kbd>X</kbd>.

## Installare ed eseguire Nginx

Ora, abilitiamo il file del repository che avete appena fatto con un semplice comando:

```bash
sudo yum-config-manager --enable nginx-mainline
```

Poi, installa il pacchetto `nginx` dal repository aggiunto in precedenza:

```bash
sudo dnf install nginx
```

Il terminale ti chiederà se ti va bene installare la chiave GPG del repository. Ne hai bisogno, quindi scegli `Y` per sì.

Una volta che l'installazione è fatta, avviate il servizio `nginx` e abilitatelo per avviarsi automaticamente al riavvio tutto in una volta con:

```bash
sudo systemctl enable --now nginx
```

Per verificare che l'ultima versione di *Nginx* sia stata installata, eseguire:

```bash
nginx -v
```

Da lì, si potrebbe semplicemente iniziare ad inserire i file HTML nella directory `/usr/share/nginx/html/` per costruire un semplice sito web statico. Il file di configurazione per il sito web/virtual host predefinito si chiama "default.conf" ed è in `/etc/nginx/conf.d/`.

## Configurare il firewall

!!! Note "Nota"

    Se state installando Nginx su un container come LXD/LXC o Docker, potete saltare questa parte per ora. Il firewall dovrebbe essere gestito dal sistema operativo host.

Se provate a visualizzare una pagina web all'indirizzo IP o al nome di dominio della vostra macchina da un altro computer, probabilmente non otterrete un bel niente. Beh, sarà così finché avrete un firewall attivo e funzionante.

Ora per aprire le porte necessarie per vedere effettivamente le vostre pagine web con `firewalld`, il firewall di default di Rocky Linux con il comando `firewall-cmd`. Ci sono due modi per farlo: quello ufficiale e quello manuale. *In questo caso, il modo ufficiale è il migliore,* ma dovresti conoscerli entrambi per riferimento futuro.

Il modo ufficiale apre il firewall al servizio `http`, che è ovviamente il servizio che gestisce le pagine web. Basta eseguire questo:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
```

Scomponiamo il tutto:

* La flag `--permanent` dice al firewall di assicurarsi che questa configurazione sia usata ogni volta che il firewall viene riavviato, e quando il server stesso viene riavviato.
* `--zone=public` dice al firewall di accettare connessioni in entrata a questa porta da chiunque.
* Infine, `--add-service=http` dice a `firewalld` di lasciar passare tutto il traffico HTTP verso il server.

Ora ecco il modo manuale di farlo. È più o meno la stessa cosa, tranne che stai aprendo specificamente la porta 80, che è quella che usa l'HTTP.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
```

* `--add-port=80/tcp` dice al firewall di accettare le connessioni in entrata sulla porta 80, purché stiano usando il Transmission Control Protocol, che è quello che vuoi in questo caso.

Per ripetere il processo per il traffico SSL/HTTPS, basta eseguire nuovamente il comando e cambiare il servizio e/o il numero di porta.

```bash
sudo firewall-cmd --permanent --zone=public --add-service=https
# Or, in some other cases:
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
```

Queste configurazioni non avranno effetto finché non forzerete la questione. Per farlo, dite a `firewalld` di rilasciare le sue configurazioni, così:

```bash
sudo firewall-cmd --reload
```

!!! Note "Nota"

    Ora, c'è una piccolissima possibilità che questo non funzioni. In quei rari casi, fai in modo che `firewalld` faccia il suo invito con il vecchio "turn-it-off-and-turn-it-on-again".

    ```bash
    systemctl restart firewalld
    ```

Per assicurarsi che le porte siano state aggiunte correttamente, eseguire `firewall-cmd --list-all`. Un firewall correttamente configurato avrà un aspetto simile a questo:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

E questo dovrebbe essere tutto ciò di cui avete bisogno, a livello di firewall.

*Ora* dovresti essere in grado di vedere una pagina web che assomiglia a questa:

![La pagina di benvenuto di Nginx](nginx/images/welcome-nginx.png)

Non è molto, ma significa che il server funziona. Puoi anche testare che la tua pagina web funzioni dalla linea di comando con:

```bash
curl -I http://[your-ip-address]
```

## Creare un Utente del server e Cambiare la Cartella Radice del sito Web

Mentre voi *potreste* semplicemente mettere il vostro sito web nella directory predefinita e andare (e questo potrebbe andare bene per *Nginx* quando è in esecuzione all'interno di un container, o su un server di test/sviluppo), non è ciò che noi chiamiamo best practice. Invece, è una buona idea creare un utente Linux specifico sul tuo sistema per il tuo sito web, e mettere i file del tuo sito web in una directory fatta solo per quell'utente.

Se volete costruire più siti web, è effettivamente una buona idea creare più utenti e directory di root, sia per il bene dell'organizzazione che per il bene della sicurezza.

In questa guida, avrò solo un utente: un bel diavolo di nome "www". Decidere dove mettere i file del tuo sito web diventa più complicato.

A seconda della configurazione del tuo server, puoi mettere i file del tuo sito web in un paio di posti diversi. Se siete su un server bare-metal (fisico), o state installando `nginx` direttamente su un VPS, probabilmente avete Security Enhanced Linux (SELinux) in esecuzione. SELinux è uno strumento che fa molto per proteggere la vostra macchina, ma detta anche dove potete mettere certe cose, come le pagine web.

Quindi se stai installando `nginx` direttamente sulla tua macchina, allora vorrai mettere i tuoi siti web nelle sottodirectory della cartella principale predefinita. In questo caso, la root predefinita è `/usr/share/nginx/html`, quindi il sito web per l'utente "www" potrebbe andare in `/usr/share/nginx/html/www`.

Se state eseguendo `nginx` in un contenitore come LXD/LXC, tuttavia, SELinux probabilmente *non* sarà installato, e potete mettere i vostri file dove volete. In questo caso, mi piace mettere tutti i file del sito web di un utente sotto una directory in una normale cartella home, così: `/home/www/`.

Continuerò questa guida come se SELinux fosse installato, comunque. Cambia solo quello che ti serve in base al tuo caso d'uso. Potete anche imparare di più su come funziona SELinux in [la nostra guida sull'argomento](../security/learning_selinux.md).

### Creazione dell'utente

Per prima cosa, creiamo la cartella che useremo:

```bash
sudo mkdir /usr/share/nginx/html/www
```

Poi, create il gruppo www:

```bash
sudo groupadd www
```
Quindi, creiamo l'utente:

```bash
sudo adduser -G nginx -g www -d /usr/share/nginx/html/www www --system --shell=/bin/false
```

Questo comando dice alla macchina di:

* Creare un utente chiamato "www" (come da testo centrale),
* mettere tutti i suoi file in `/usr/share/nginx/html/www`,
* e aggiungerlo ai seguenti gruppi: "nginx" come supplementare, "www" come primario.
* Il flag `--system` dice che l'utente non è un utente umano, è riservato al sistema. Se volete creare account utente umani per gestire diversi siti web, questa è tutta un'altra guida.
* `--shell=/bin/false` si assicura che nessuno possa anche solo *tentare* di accedere come utente "www".

Il gruppo "nginx" fa una vera magia. Permette al server web di leggere e modificare i file che appartengono all'utente "www" e al gruppo di utenti "www". Vedere [guida alla gestione degli utenti](../../books/admin_guide/06-users.md) di Rocky Linux per maggiori informazioni.

### Cambiare la Cartella Radice del Server

Ora che hai il tuo nuovo e fantasioso account utente, è il momento di fare in modo che `nginx` cerchi i file del tuo sito web in quella cartella. Prendete di nuovo il vostro editor di testo preferito.

Per ora, basta eseguire:

```bash
sudo nano /etc/nginx/conf.d/default.conf
```

Quando il file è aperto, cerca la linea che assomiglia a `root /usr/share/nginx/html;`. Cambialo nella cartella principale del tuo sito web scelto, ad esempio. `root /usr/share/nginx/html/www;` (o `/home/www` se stai eseguendo `nginx` in un container come faccio io). Salvate e chiudete il file, poi testate la vostra configurazione `nginx` per assicurarvi di non aver saltato un punto e virgola o altro:

```bash
nginx -t
```

Se si ottiene il seguente messaggio di successo, tutto è andato bene:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Poi, date al server un riavvio morbido con:

```bash
sudo systemctl reload nginx
```

!!! Note "Nota"

    Nel caso improbabile che il riavvio morbido non funzioni, date un calcio nei pantaloni a `nginx` con:

    ```bash
    sudo systemctl restart nginx
    ```

Tutti i file HTML nella tua nuova cartella principale dovrebbero ora essere navigabili da... il tuo browser.

### Cambiare i Permessi ai File

Per assicurarsi che *`nginx` possa leggere, scrivere ed eseguire qualsiasi file nella directory del sito web, i permessi devono essere impostati correttamente.

Per prima cosa, assicuratevi che tutti i file nella cartella principale siano di proprietà dell'utente del server e del suo gruppo di utenti con:

```bash
sudo chown -R www:www /usr/share/nginx/html/www
```

E poi, per assicurarsi che gli utenti che vogliono effettivamente navigare il tuo sito web possano effettivamente vedere le pagine, dovresti fare in modo di poter eseguire questi comandi (e sì, quei punti e virgola contano):

```bash
sudo find /usr/share/nginx/html/www -type d -exec chmod 555 "{}" \;
sudo find /usr/share/nginx/html/www -type f -exec chmod 444 "{}" \;
```

Questo in pratica dà a tutti il diritto di guardare i file sul server, ma non di modificarli. Solo gli utenti root e del server possono farlo.

## Ulteriori Opzioni di Configurazione e Guide

* Se vuoi vedere come far funzionare *Nginx* con PHP, e PHP-FPM in particolare, controlla la nostra [guida PHP su Rocky Linux](../web/php.md).
* Le istruzioni sulla configurazione multi-sito sono in arrivo in un'altra guida. Stanno arrivando anche le istruzioni per i certificati SSL, e questa guida sarà aggiornata con i link quando saranno pronti.

## Installare il Ramo Stabile dai propri repo di Rocky

Se volete usare il ramo "stable" di `nginx`, anche con le sue limitazioni, ecco come fare. Per prima cosa, assicuratevi che il vostro sistema operativo sia aggiornato:

```bash
sudo dnf update
```

Poi, cercate l'ultima versione `nginx` disponibile nei repo predefiniti con:

```bash
sudo dnf module list nginx
```

Questo dovrebbe darvi una lista che assomiglia a questa:

```bash
Rocky Linux 8 - AppStream
Name       Stream        Profiles        Summary
nginx      1.14 [d]      common [d]      nginx webserver
nginx      1.16          common [d]      nginx webserver
nginx      1.18          common [d]      nginx webserver
nginx      1.20          common [d]      nginx webserver
```

Scegliete il numero più alto della lista e abilitate il suo modulo in questo modo:

```bash
sudo dnf module enable nginx:1.20
```

Ti verrà chiesto se sei sicuro di volerlo fare, quindi scegli `Y` come al solito. Poi, usate il comando predefinito per installare `nginx`:

```bash
sudo dnf install nginx
```

Poi puoi abilitare il servizio e configurare il tuo server come descritto sopra.

!!! Note "Nota"

    Il file di configurazione predefinito, in questo caso, è nella cartella di configurazione base di `nginx` in `/etc/nginx/nginx.conf`. La cartella principale del sito web è la stessa, però.

## Conclusione

L'installazione e la configurazione di base di `nginx` sono facili, anche se è più complicato di quanto dovrebbe essere ottenere l'ultima versione. Ma, basta seguire i passi, e avrete una delle migliori opzioni di server là fuori pronta e funzionante rapidamente.

Ora devi solo andare a costruirti un sito web? Cosa potrebbe volerci, altri dieci minuti? *Sobs quietly in Web Designer*
