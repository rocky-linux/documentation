---
title: Nginx Multisito
author: Ezequiel Bruni
contributors: Steven Spencer, Franco Colussi
tested with: 8.5
tags:
  - web
  - nginx
  - multisite
---

# Come Configurare Nginx per più Siti Web su Rocky Linux

## Introduzione

Ecco, la mia guida promessa per le configurazioni multi sito Nginx su Rocky Linux. Inizierò con una nota per i principianti; il resto di voi sa per cosa è qui, quindi continuate a scorrere.

Hi Newbies! Una delle cose che Nginx fa *molto* bene è dirigere il traffico da un punto centrale a più siti web e applicazioni su un server o su diversi altri server. Questa funzione è chiamata "reverse proxy" e la relativa facilità con cui Nginx la svolge è uno dei motivi per cui ho iniziato a usarlo.

Qui vi mostrerò come gestire più siti web su una singola installazione di Nginx e come farlo in modo semplice e organizzato, consentendovi di apportare modifiche in modo facile e veloce.

Per coloro che cercano una configurazione simile per Apache, dare un'occhiata a [questa guida](apache-sites-enabled.md)

Vi spiegherò *molti* dettagli... ma alla fine, l'intero processo consiste fondamentalmente nell'impostare alcune cartelle e creare alcuni piccoli file di testo. In questa guida non utilizzeremo configurazioni di siti web troppo complicate, quindi rilassatevi con un caffè e divertitevi. Una volta che si sa come fare, ci vorranno solo pochi minuti per farlo ogni volta. Questo è facile.\*

\* Per i valori dati di "facile".

## Prerequisiti e presupposti

Questo è tutto ciò di cui hai bisogno:

* Un server Rocky Linux collegato a internet, con Nginx già in esecuzione. Se non siete arrivati a questo punto, potete seguire prima la nostra [guida all'installazione di Nginx](nginx-mainline.md).
* Una certa familiarità con le operazioni dalla riga di comando e di un editor di testo basato su terminale come `nano`.

    !!! tip "In a pinch"
  
        ... si potrebbe usare qualcosa come Filezilla o WinSCP - e un normale editor di testo basato su GUI - per replicare la maggior parte di questi passaggi, ma in questo tutorial faremo le cose alla maniera dei nerd.

* Almeno un dominio puntato sul vostro server per uno dei siti web di prova. È possibile utilizzare un secondo dominio o un sottodominio per l'altro.

    !!! hint "Suggerimento"
      Se si esegue tutto questo su un server locale, modificare il file hosts come necessario per creare nomi di dominio simulati.
  
        Se si esegue tutto questo su un server locale, modificare il file hosts come necessario per creare nomi di dominio simulati. Istruzioni qui sotto.

* Si presume che Nginx sia in esecuzione su un server bare metal o su un normale VPS e che SELinux sia in esecuzione. Tutte le istruzioni saranno compatibili con SELinux per impostazione predefinita.
* *Tutti i comandi devono essere eseguiti come root,* sia accedendo come utente root, sia usando `sudo`.

## Impostazione delle Cartelle e dei Siti di Test

### Le cartelle del sito web
In primo luogo, hai bisogno di un paio di cartelle per i file del tuo sito web. Quando si installa Nginx per la prima volta, tutti i file del sito web "demo" si trovano in `/usr/share/nginx/html`. Questo va bene se state ospitando un solo sito, ma noi ci stiamo sbizzarrendo. Ignorare la cartella `html` per ora e navigare solo nella sua cartella madre:

```bash
cd /usr/share/nginx
```

I domini di prova per questo tutorial saranno `site1.server.test` e `site2.server.test`, e le cartelle dei siti web verranno nominate di conseguenza. Naturalmente, è necessario cambiare questi domini con quelli che si stanno utilizzando. Tuttavia (e questo è un trucco che ho imparato da Smarter People<sup>TM</sup>), scriveremo i nomi di dominio "al contrario".

es. "yourwebsite.com" andrebbe in una cartella chiamata `com.yourwebsite`. È chiaro che potete *letteralmente* nominare queste cartelle come volete, ma c'è una buona ragione per questo metodo, che ho illustrato di seguito.

Per ora, basta creare le cartelle:

```bash
mkdir -p test.server.site1/html
mkdir -p test.server.site2/html
```

Quindi questo comando creerà, per esempio, la cartella `test.server.site1` e metterà al suo interno un'altra cartella chiamata `html`. È qui che si inseriscono i file effettivi che si vogliono servire tramite il server web. (Si potrebbe anche chiamare "webroot" o qualcosa del genere.)

In questo modo si possono mettere nella directory principale i file relativi al sito web che *non si vogliono rendere pubblici*, pur mantenendo tutto in un unico posto.

!!! Note "Nota"

    Il flag `-p' indica al comando `mkdir' di creare tutte le cartelle mancanti nel percorso appena definito, in modo da non dover creare ogni cartella una alla volta.

Per questo test, manteniamo i "siti web" stessi molto semplici. È sufficiente creare un file HTML nella prima cartella con il vostro editor di testo preferito:

```bash
nano test.server.site1/html/index.html
```

Quindi incollare il seguente codice HTML:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site 1</title>
</head>
<body>
    <h1>This is Site 1</h1>
</body>
</html>
```

Salvate e chiudete il file, quindi ripetete i passaggi con la cartella `test.server.site2`, cambiando "Sito 1" con "Sito 2" nel codice HTML sopra riportato. Questo per essere sicuri che in seguito tutto funzioni come previsto.

I siti web di prova sono terminati, andiamo avanti.

### Le cartelle di configurazione

Ora andiamo nella cartella delle impostazioni e della configurazione di Nginx, dove lavoreremo per il resto di questa guida:

```bash
cd /etc/nginx/
```

Se si esegue il comando `ls` per vedere quali file e cartelle si trovano qui, si vedranno un mucchio di cose diverse, la maggior parte delle quali oggi sono irrilevanti. Quelli da notare sono questi:

* `nginx.conf` è il file che contiene, come avete capito, la configurazione predefinita di Nginx. Lo modificheremo più tardi.
* `conf.d` è una directory in cui si possono inserire i file di configurazione personalizzati. Si *può* usare per i siti web, ma è meglio usarlo per le impostazioni specifiche che si vogliono per tutti i siti web.
* `default.d` è una directory in cui si trova la configurazione del sito web *che potrebbe* gestire un solo sito sul server, o se il server ha un sito web "primario". Per ora lasciate stare.

Vogliamo creare due nuove cartelle chiamate `sites-available` e `sites-enabled`:

```bash
mkdir sites-available
mkdir sites-enabled
```

Quello che faremo è mettere tutti i file di configurazione del nostro sito web nella cartella `sites-available`. Lì si può lavorare sui file di configurazione per tutto il tempo necessario, finché non si è pronti ad attivare i file con un collegamento simbolico alla cartella `sites-enabled`.

Vi mostrerò come funziona qui sotto. Per ora, abbiamo finito di creare cartelle.

!!! Note "Perché (forse) volete scrivere i vostri domini al contrario:"

    In poche parole, si tratta di una funzione organizzativa particolarmente utile quando si utilizza la riga di comando con il completamento delle schede, ma ancora molto utile nelle applicazioni basate sulla GUI. È stato progettato per chi gestisce *molti* siti web o applicazioni su un server.
    
    In pratica, tutte le cartelle del vostro sito web (e i file di configurazione) verranno organizzati in ordine alfabetico: prima il dominio di primo livello (ad esempio, .com, .org, ecc.), poi il dominio principale e infine gli eventuali sottodomini. Quando si cerca in un lungo elenco di domini, può essere più facile restringere il campo di ricerca in questo modo.
    
    Inoltre, rende più facile l'ordinamento delle cartelle e dei file di configurazione tramite gli strumenti della riga di comando. Per elencare tutte le cartelle associate a un particolare dominio, si può eseguire:

    ```bash
    ls /usr/share/nginx/ | grep com.yoursite*
    ```


    Che fornirà un risultato simile a:

    ```
    com.yoursite.site1
    com.yoursite.site2
    com.yoursite.site3
    ```

## Impostazione dei File di Configurazione

### Modificare nginx.conf

Per impostazione predefinita, l'implementazione di Rocky Linux di Nginx è aperta a tutto il traffico HTTP e lo indirizza alla pagina dimostrativa che potreste aver visto nella nostra guida all'installazione di Nginx. Noi non vogliamo questo. Vogliamo che il traffico proveniente dai domini che specifichiamo vada ai siti web che specifichiamo.

Quindi, dalla cartella `/etc/nginx/`, aprite `nginx.conf` nel vostro editor di testo preferito:

```bash
nano nginx.conf
```

Per prima cosa, trovare la linea che assomiglia a questa:

```
include /etc/nginx/conf.d/*.conf;
```

E **aggiungere** questo pezzo appena sotto:

```
include /etc/nginx/sites-enabled/*.conf;
```

Questo caricherà i file di configurazione del nostro sito web quando saranno pronti per la messa in funzione.

Ora scendete fino alla sezione che appare come questa e **commentatela** con il segno di hash <kbd>#</kbd>, oppure cancellatela se preferite:

```
server {
    listen       80;
    listen       [::]:80;
    server_name  _;
    root         /usr/share/nginx/www/html;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
```

Come sarebbe "commentato":

```
#server {
#    listen       80;
#    listen       [::]:80;
#    server_name  _;
#    root         /usr/share/nginx/www/html;
#
#    # Load configuration files for the default server block.
#    include /etc/nginx/default.d/*.conf;
#
#    error_page 404 /404.html;
#    location = /404.html {
#    }
#
#    error_page 500 502 503 504 /50x.html;
#    location = /50x.html {
#    }
#}
```

Se siete alle prime armi, potreste voler tenere il codice commentato come riferimento, e questo vale anche per il codice HTTPS di esempio, già commentato più avanti nel file.

Salva e chiudi il file, quindi riavvia il server con:

```bash
systemctl restart nginx
```

Ora nessuno vedrà la pagina demo, almeno.

### Aggiungere i file di configurazione del sito web

Ora rendiamo disponibili i siti web di prova sul server. Come già accennato in precedenza, si tratta di collegamenti simbolici, in modo da avere un modo semplice per attivare e disattivare i siti web a piacimento.

!!! Note "Nota"

    Per i neofiti, i collegamenti simbolici sono fondamentalmente un modo per far sì che i file fingano di trovarsi in due cartelle contemporaneamente. Se si modifica il file originale (o "target"), questo viene modificato ovunque sia collegato. Se si utilizza un programma per modificare il file tramite un link, l'originale viene modificato.
    
    Tuttavia, se si elimina un collegamento alla destinazione, non succede nulla al file originale. Questo trucco ci permette di mettere i file di configurazione del sito web in una cartella di lavoro (`sites-available`) e poi di "attivarli" collegandosi a quei file da `sites-enabled`.


Vi faccio vedere cosa intendo. Creare un file di configurazione per il primo sito web in questo modo:

```bash
nano sites-available/test.server.site1.conf
```

Ora incollate questo codice. Questa è la configurazione di Nginx più semplice che si possa avere e dovrebbe funzionare bene per la maggior parte dei siti web HTML statici:

```
server {
    listen 80;
    listen [::]:80;

    # virtual server name i.e. domain name #
    server_name site1.server.test;

    # document root #
    root        /usr/share/nginx/test.server.site1/html;

    # log files
    access_log  /var/log/nginx/www_access.log;
    error_log   /var/log/nginx/www_error.log;

    # Directives to send expires headers and turn off 404 error logging. #
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
        access_log off; log_not_found off; expires max;
    }
}
```

E diamine, tutto, dalla radice del documento in giù, è tecnicamente opzionale. Utile e consigliato, ma non strettamente necessario per il funzionamento del sito.

In ogni caso, salvate e chiudete il file, quindi andate nella directory `sites-enabled`:

```bash
cd sites-enabled
```

Ora, create un collegamento simbolico al file di configurazione appena creato nella cartella `sites-available`:

```bash
ln -s ../sites-available/test.server.site1.conf
```

Verificate la configurazione con il comando `nginx -t` e se ricevete un messaggio che dice che tutto è a posto, ricaricate il server:

```bash
systemctl restart nginx
```

Puntate quindi il browser sul dominio che state usando per questo primo sito (nel mio caso: site1.server.test) e cercate il messaggio "Questo è il sito 1" che abbiamo inserito nel file HTML. Se avete installato `curl` sul vostro sistema, potete eseguire `curl site1.server.test` e vedere se il codice HTML viene caricato nel vostro terminale.

!!! Note "Nota"

    Alcuni browser (con tutte le migliori intenzioni) obbligano a utilizzare HTTPS quando si digita il dominio del server nella barra degli indirizzi. Se non è configurato l'HTTPS, si otterranno solo errori.
    
    Assicuratevi di specificare manualmente "http://" nella barra degli indirizzi del browser per evitare questo problema. Se non funziona, cancellate la cache o utilizzate un browser meno esigente per questa parte del test. Io raccomando [Min](https://minbrowser.org).

Se *tutto* va bene, *ripetete i passaggi precedenti, cambiando man mano i nomi dei file e il contenuto dei file di configurazione*. da "sito1" a "sito2" e così via. Una volta che i file di configurazione e i link simbolici per il sito 1 e il sito 2 sono stati riavviati, Nginx dovrebbe avere questo aspetto:

![Una schermata dei due siti web di prova affiancati](nginx/images/multisite-nginx.png)

!!! Note

    È anche possibile creare collegamenti dall'esterno della directory abilitata ai siti con la forma lunga del comando `ln -s`. Il risultato sarà `ln -s [file sorgente] [link]`.
    
    In questo contesto si tratta di:

    ```bash
    ln -s /etc/nginx/sites-available/test.server.site1.conf /etc/nginx/sites-enabled/test.server.site1.conf
    ```

### Disabilitare un sito web

Se è necessario interrompere uno dei siti web per lavorarci su prima di riprenderlo, è sufficiente eliminare il collegamento simbolico in sites-enabled:

```bash
rm /etc/nginx/sites-enabled/test.server.site1.conf
```

Quindi riavviare Nginx come al solito. Per riportare il sito online, dovrai ricreare il link simbolico e riavviare di nuovo Nginx.

## Opzionale: Modificare Il Tuo File Hosts

Questa parte è decisamente per i neofiti. Tutti gli altri possono probabilmente saltare.

Quindi questa sezione si applica *solo* se state provando questa guida in un ambiente di sviluppo locale. Se cioè il server di prova viene eseguito sulla propria workstation o su un'altra macchina della rete locale domestica o aziendale.

Poiché puntare i domini esterni alle macchine locali è una seccatura (e potenzialmente pericoloso se non si sa cosa si sta facendo), è possibile impostare alcuni domini "falsi" che funzioneranno bene sulla rete locale e in nessun altro luogo.

Il modo più semplice per farlo è utilizzare il file hosts del computer. Il file hosts è letteralmente solo un file di testo che può sostituire le impostazioni DNS. In altre parole, è possibile specificare manualmente un nome di dominio da abbinare a qualsiasi indirizzo IP. Tuttavia, funzionerà *solo* su quel computer.

Su Mac e Linux, il file hosts si trova nella directory `/etc/` e può essere modificato dalla riga di comando con estrema facilità (è necessario l'accesso root). Supponendo di lavorare su una workstation Rocky Linux, basta eseguire:

```bash
nano /etc/hosts
```

Su Windows, il file hosts si trova in `C:\Windows\system32\drivers\etc\hosts` e si può usare qualsiasi editor di testo dell'interfaccia grafica, purché si abbia accesso come amministratore.

Quindi, se si lavora su un computer Rocky Linux e si esegue il server Nginx sulla stessa macchina, basta aprire il file e definire i domini/indirizzi IP desiderati. Se la workstation e il server di prova sono in esecuzione sulla stessa macchina, è così:

```
127.0.0.1           site1.server.test
127.0.0.1           site2.server.test
```

Se il server Nginx è in esecuzione su un'altra macchina della rete, è sufficiente utilizzare l'indirizzo di tale macchina, ad es.:

```
192.168.0.45           site1.server.test
192.168.0.45           site2.server.test
```

A questo punto sarà possibile puntare il browser verso questi domini e il tutto dovrebbe funzionare come previsto.

## Impostazione dei Certificati SSL per i Vostri Siti

Consultate [la nostra guida per ottenere certificati SSL con Let's Encrypt e certbot](../security/generating_ssl_keys_lets_encrypt.md). Le istruzioni riportate andranno benissimo.

## Conclusione

Ricordate che la maggior parte delle convenzioni per l'organizzazione e la denominazione delle cartelle e dei file sono tecnicamente facoltative. I file di configurazione del sito web devono per lo più andare ovunque all'interno di `/etc/nginx/` e `nginx.conf` deve sapere dove si trovano questi file.

I file del sito web vero e proprio dovrebbero trovarsi da qualche parte in `/usr/share/nginx/`, e il resto è tutto da scoprire.

Provatelo, fate un po' di Scienza<sup>TM</sup> e non dimenticate di eseguire `nginx -t` prima di riavviare Nginx per assicurarvi di non aver dimenticato un punto e virgola o altro. Vi farà risparmiare molto tempo.
