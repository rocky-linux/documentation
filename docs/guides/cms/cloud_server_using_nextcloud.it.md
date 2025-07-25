---
title: Server Cloud con Nextcloud
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - cloud
  - nextcloud
---

# Server Cloud con Nextcloud

!!! note "Riguardo a Rocky Linux 9.x o 10.x"

    Questa procedura dovrebbe funzionare per Rocky Linux 9.x o 10.x. La differenza è che potrebbe essere necessario cambiare i riferimenti di versione per alcuni repository per aggiornarli alla versione 9 o 10. Se state usando Rocky Linux 9.x o 10.x, sappiate che questo è stato testato sia con la 8.6 che con la 9.0, ma è stato scritto originariamente per la 8.6.

## Prerequisiti E Presupposti

- Server con Rocky Linux (è possibile installare Nextcloud su qualsiasi distribuzione Linux, ma questa procedura presuppone l'utilizzo di Rocky).
- Un elevato grado di comfort nell'operare dalla riga di comando per l'installazione e la configurazione.
- Conoscenza di un editor a riga di comando. Per questo esempio utilizziamo _vi_, ma potete usare il vostro editor preferito, se ne avete uno.
- Anche se Nextcloud può essere installato tramite un'applicazione snap, documenteremo solo l'installazione del file .zip.
- Per l'impostazione delle directory applicheremo i concetti del documento Apache _sites enabled_ (a cui si rimanda in basso).
- Utilizzeremo anche la procedura di hardening di _mariadb-server_ (anch'essa linkata più avanti) per la configurazione del database.
- In questo documento si presuppone che siate root, o che possiate esserlo usando _sudo_.
- Nella configurazione utilizziamo un dominio di esempio <yourdomain.com>.

## Introduzione

Se siete responsabili di un ambiente server per una grande (o anche piccola) azienda, potreste essere tentati dalle applicazioni cloud. L'utilizzo del cloud può liberare risorse per altre attività, ma c'è un aspetto negativo: la perdita di controllo dei dati aziendali. Se l'applicazione cloud è compromessa, anche i dati della vostra azienda potrebbero esserlo.

Riportare il cloud nel proprio ambiente è un modo per recuperare la sicurezza dei dati a scapito di tempo ed energia. A volte è un costo che vale la pena pagare.

Nextcloud offre un cloud open source che tiene conto della sicurezza e della flessibilità. Si noti che la creazione di un server Nextcloud è un buon esercizio, anche se alla fine si sceglie di portare il cloud fuori sede. La procedura seguente riguarda l'impostazione di Nextcloud su Rocky Linux.

## Installazione di Nextcloud

### Installazione e configurazione di Repository e Moduli

Per questa installazione sono necessari due repository. È necessario installare EPEL (Extra Packages for Enterprise Linux) e il repository Remi per PHP 8.3

!!! note "Nota"

    È richiesta una versione minima di PHP 7.3 o 7.4 e la versione Rocky Linux 7.4 non contiene tutti i pacchetti necessari a Nextcloud. Utilizzeremo invece PHP 8.3 dal repository Remi.

Per installare  EPEL esegui:

```bash
dnf install epel-release
```

Per installare il repository Remi, eseguite (nota: se state usando Rocky Linux 9.x o 10.x, sostituite 9 o 10 accanto a `release`):

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```

Quindi eseguire nuovamente `dnf upgrade`.

Eseguire il seguente comando per visualizzare l'elenco dei moduli php che possono essere abilitati:

```bash
dnf module list php
```

che fornisce questo risultato per Rocky Linux 8.x (un risultato simile verrà mostrato per Rocky Linux 9.x o 10.x):

```bash
Rocky Linux 8 - AppStream
Name                    Stream                     Profiles                                     Summary                                 
php                     7.2 [d]                    common [d], devel, minimal                   PHP scripting language                  
php                     7.3                        common [d], devel, minimal                   PHP scripting language                  
php                     7.4                        common [d], devel, minimal                   PHP scripting language               
php                     7.4                        common [d], devel, minimal                   PHP scripting language                  
Remi's Modular repository for Enterprise Linux 8 - x86_64
Name                    Stream                     Profiles                                     Summary                                 
php                     remi-7.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.3                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.4                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.0                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.1                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.3                   common [d], devel, minimal                   PHP scripting language                  
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Vogliamo prendere il PHP più recente con cui Nextcloud è compatibile, che in questo momento è l'8.3, quindi abiliteremo il modulo:

```bash
dnf module enable php:remi-8.3
```

Per vedere come cambia l'output dell'elenco dei moduli, eseguite di nuovo il comando module list e vedrete la scritta "[e]" accanto a 8.3:

```bash
dnf module list php
```

L'output è di nuovo lo stesso, tranne che per questa riga:

```bash
php                    remi-8.3 [e]                   common [d], devel, minimal                  PHP scripting language
```

### Installazione dei Pacchetti

Il nostro esempio utilizza Apache e mariadb, quindi per installare ciò di cui abbiamo bisogno, dobbiamo semplicemente procedere come segue:

```bash
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php83-php php83-php-ctype php83-php-curl php83-php-gd php83-php-iconv php83-php-json php83-php-libxml php83-php-mbstring php83-php-openssl php83-php-posix php83-php-session php83-php-xml php83-php-zip php83-php-zlib php83-php-pdo php83-php-mysqlnd php83-php-intl php83-php-bcmath php83-php-gmp
```

### Configurazione

#### Configurazione di Apache

Impostare l'avvio di _apache_ all'avvio del sistema:

```bash
systemctl enable httpd
```

Poi avviatelo:

```bash
systemctl start httpd
```

#### Creare la Configurazione

Nella sezione _Prerequisiti e presupposti_, abbiamo detto che per la nostra configurazione utilizzeremo la procedura [Apache Sites Enabled](../web/apache-sites-enabled.md). Fate clic su quella procedura e impostate le basi lì, quindi tornate a questo documento per continuare.

Per Nextcloud, è necessario creare il seguente file di configurazione.

```bash
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

Il file di configurazione dovrebbe essere simile a questo:

```bash
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.yourdomain.nextcloud/html/
  ServerName  nextcloud.yourdomain.com
  <Directory /var/www/sub-domains/com.yourdomain.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

Una volta fatto, salvate le modifiche (con ++shift+colon+"w "+"q "+exclam++ per _vi_).

Quindi, creare un collegamento a questo file in /etc/httpd/sites-enabled:

```bash
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### Creazione della Directory

Come indicato nella configurazione precedente, è necessario creare la _DocumentRoot_. Questo può essere fatto da:

```bash
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

È qui che verrà installata la nostra istanza Nextcloud.

#### Configurazione di PHP

È necessario impostare il fuso orario per PHP. Per farlo, aprire php.ini con il proprio editor di testo:

```bash
vi /etc/opt/remi/php83/php.ini
```

Trovate quindi la riga che dice:

```php
;date.timezone =
```

È necessario rimuovere l'annotazione (++semicolon++) e impostare il fuso orario. Per il nostro esempio di fuso orario, dovremmo inserire:

```php
date.timezone = "America/Chicago"
```

O

```php
date.timezone = "US/Central"
```

Quindi salvare e uscire dal file php.ini.

Si noti che per mantenere le cose invariate, il fuso orario nel file _php.ini_ dovrebbe corrispondere a quello della macchina. Per sapere a quale valore è impostato, procedere come segue:

```bash
ls -al /etc/localtime
```

Questo dovrebbe mostrare qualcosa di simile, supponendo che abbiate impostato il fuso orario quando avete installato Rocky Linux e che viviate nel fuso orario centrale:

```bash
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### Configurazione di mariadb-server

Impostare l'avvio di _mariadb-server_ all'avvio del sistema:

```bash
systemctl enable mariadb
```

E poi avviarlo:

```bash
systemctl restart mariadb
```

Anche in questo caso, come indicato in precedenza, per la configurazione iniziale si utilizzerà la procedura di configurazione per l'hardening di _mariadb-server_ che si trova [qui](../database/database_mariadb-server.md).

### Installazione da .zip

I prossimi passi presuppongono che siate connessi in remoto al vostro server Nextcloud tramite _ssh_ e che abbiate una console remota aperta:

- Accedere al [sito web](https://nextcloud.com/) di [Nextcloud](https://nextcloud.com/).
- Passate il mouse su `Get Nextcloud`, che farà apparire un menu a discesa.
- Fare clic su `Server Packages`.
- Fate clic con il tasto destro del mouse su `Download Nextcloud` e copiate l'indirizzo del link (la sintassi esatta è diversa da browser a browser).
- Nella console remota del server Nextcloud, digitate `wget`, quindi uno spazio e incollate il testo appena copiato. Si dovrebbe ottenere qualcosa di simile a quanto segue: `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip` (si noti che la versione potrebbe essere diversa).
- Una volta premuto il tasto Invio, il download del file .zip inizierà e si concluderà abbastanza rapidamente.

Una volta completato il download, decomprimere il file zip di Nextcloud utilizzando la seguente procedura:

```bash
unzip nextcloud-21.0.1.zip
```

### Copiare il contenuto e modificare i permessi

Dopo aver completato la fase di decompressione, si dovrebbe avere una nuova directory in _/root_ chiamata "nextcloud". Passare a questa directory:

```bash
cd nextcloud
```

E copiare o spostare il contenuto nella nostra _DocumentRoot_:

```bash
cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

O

```bash
mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

Ora che tutto è al suo posto, il passo successivo è assicurarsi che apache possieda la directory. Per farlo, eseguire:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

Per motivi di sicurezza, vogliamo anche spostare la cartella _data_ dall'interno all'esterno della _DocumentRoot_. Per farlo, utilizzate il seguente comando:

```bash
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```

### Configurazione di Nextcloud

Ora arriva il divertimento! Innanzitutto, assicuratevi che i vostri servizi siano attivi. Se avete seguito i passaggi precedenti, dovrebbero essere già in funzione. Ci sono stati diversi passaggi tra questi avvii iniziali del servizio, quindi andiamo avanti e riavviamoli, per essere sicuri:

```bash
systemctl restart httpd
systemctl restart mariadb
```

Se tutto si riavvia e non ci sono problemi, siete pronti a proseguire.

Per effettuare la configurazione iniziale, dobbiamo caricare il sito in un browser web:

<http://your-server-hostname/> (sostituire con l'attuale hostname)

Supponendo di aver fatto tutto correttamente fino a questo momento, dovrebbe apparire la schermata di configurazione di Nextcloud:

![nextcloud login screen](../images/nextcloud_screen.jpg)

Ci sono un paio di cose che vogliamo fare in modo diverso rispetto alle impostazioni predefinite:

- Nella parte superiore della pagina web, dove è scritto `Crea un account amministratore`, impostare l'utente e la password. Ai fini di questo documento, inseriamo `admin` e impostiamo una password forte. Ricordate di salvarla in un posto sicuro (come un gestore di password) per non perderla! Anche se avete digitato in questo campo, non premete ++enter++ finché non sono stati completati tutti i campi di impostazione!
- Nella sezione `Archiviazione & database`, cambiare la posizione della `cartella Dati` dalla radice predefinita del documento, alla posizione in cui abbiamo spostato la cartella dati in precedenza: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
- Nella sezione `Configura il database`, passare da `SQLite` a `MySQL/MariaDB` facendo clic su questo pulsante.
- Nei campi `Utente del database` e `Password del database` digitate l'utente root di MariaDB e la password impostata in precedenza.
- Nel campo `Nome del database`, digitare `nextcloud`.
- Nel campo `localhost` digitare: <localhost:3306> (3306 è la porta predefinita di _mariadb_).

Una volta fatto tutto questo, fate clic su `Fine dell'installazione` e sarete subito operativi.

La finestra del browser si aggiorna per un po' e poi di solito non ricarica il sito. Inserite nuovamente l'URL nella finestra del browser e vi troverete di fronte alle prima pagina predefinita.

A questo punto l'utente amministrativo è già (o dovrebbe essere) loggato, e ci sono diverse pagine informative pensate per farvi acquisire familiarità. La "Dashboard" è ciò che gli utenti vedranno al primo accesso. L'utente amministrativo può ora creare altri utenti, installare altre applicazioni e svolgere molte altre attività.

Il file "Nextcloud Manual.pdf" è il manuale d'uso, in modo che gli utenti possano familiarizzare con ciò che è disponibile. L'utente amministrativo dovrebbe leggere o almeno scansionare i punti salienti del manuale di amministrazione [sul sito web di Nextcloud.](https://docs.nextcloud.com/server/21/admin_manual/)

## Passi successivi

A questo punto, non dimenticate che si tratta di un server su cui memorizzerete i dati aziendali. È importante bloccare il sito con un firewall, [impostare](../backup/rsnapshot_backup.md) il [backup](../backup/rsnapshot_backup.md), proteggere il sito con un [SSL](../security/generating_ssl_keys_lets_encrypt.md) e qualsiasi altra operazione necessaria per mantenere i dati al sicuro.

## Conclusioni

La decisione di portare il cloud aziendale all'interno dell'azienda è una decisione che deve essere valutata attentamente. Per coloro che decidono che mantenere i dati aziendali in locale è preferibile rispetto a un host cloud esterno, Nextcloud è una buona alternativa.
