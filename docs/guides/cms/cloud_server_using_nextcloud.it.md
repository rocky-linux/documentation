---
title: Server Cloud con Nextcloud
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - cloud
  - nextcloud
---


## Prerequisiti E Presupposti

- Server con Rocky Linux (è possibile installare Nextcloud su qualsiasi distribuzione Linux, ma questa procedura presuppone l'utilizzo di Rocky).
- Un elevato grado di comfort nell'operare dalla riga di comando per l'installazione e la configurazione.
- Conoscenza di un editor a riga di comando. Per questo esempio utilizziamo `vi`, ma potete usare il vostro editor preferito, se ne avete uno.
- Questa procedura riguarda il metodo d'installazione con file `.zip`. È anche possibile installare Nextcloud con un'applicazione snap.
- Per la configurazione della directory applicheremo i concetti del documento Apache _sites enabled_ (a cui si rimanda in basso).
- Utilizzeremo anche la procedura di hardening di _mariadb-server_ (anch'essa linkata più avanti) per la configurazione del database.
- In questo documento si presuppone che siate root, o che possiate esserlo usando `sudo`.
- Nella configurazione utilizziamo un dominio di esempio "yourdomain.com".

## Introduzione

Se si è responsabile dell'ambiente server di un'azienda di grandi (o anche piccole) dimensioni, si potrebbe prendere in considerazione l'utilizzo di applicazioni cloud. L'utilizzo del cloud può liberare risorse per altre attività, ma c'è un aspetto negativo: la perdita di controllo dei dati aziendali. Se si verifica una compromissione nell'applicazione cloud, si potrebbe mettere a rischio anche i dati dell'azienda.

Riportare il cloud nel proprio ambiente è un modo per recuperare la sicurezza dei dati a scapito di tempo ed energia. A volte, questo è un costo che vale la pena pagare.

Nextcloud offre un cloud open source che tiene conto della sicurezza e della flessibilità. Si noti che la creazione di un server Nextcloud è un buon esercizio, anche se alla fine si sceglie di esternalizzare il cloud. La procedura seguente riguarda l'impostazione di Nextcloud su Rocky Linux.

## Installazione di Nextcloud

### Installazione e configurazione di Repository e Moduli

Per questa installazione sono necessari due repository. È necessario installare EPEL (Extra Packages for Enterprise Linux) e il repository Remi per la versione 10.

!!! note "Nota"

    Sebbene Rocky Linux 10 contenga la versione minima richiesta di PHP 8.3, il repository Remi contiene altri pacchetti PHP necessari per Nextcloud.

Per installare EPEL eseguire:

```bash
dnf install epel-release
```

Per installare il repository Remi, eseguire:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Quindi eseguire nuovamente `dnf upgrade`.

Esegui il seguente comando per visualizzare un elenco dei moduli PHP disponibili:

```bash
dnf module list php
```

Questo comando su Rocky Linux 10 vi dà come risultato:

```bash
Remi's Modular repository for Enterprise Linux 10 - x86_64
Name                   Stream                      Profiles                                      Summary                                  
php                    remi-7.4                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.0                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.1                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.2                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.3                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.4                    common [d], devel, minimal                    PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Utilizzare l'ultima versione di PHP compatibile con Nextcloud. Al momento è 8.4. Abilitare quel modulo con:

```bash
dnf module enable php:remi-8.4
```

Per vedere come cambia l'output dell'elenco dei moduli, eseguire di nuovo il comando module list e vedrete la scritta "[e]" accanto a 8.3:

```bash
dnf module list php
```

L'output è lo stesso tranne che per questa riga:

```bash
php                    remi-8.4 [e]                   common [d], devel, minimal                  PHP scripting language
```

### Installazione dei Pacchetti

L'esempio qui riportato utilizza Apache e mariadb. Per installare i pacchetti necessari, procedere come segue:

```bash
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php84-php php84-php-ctype php84-php-curl php84-php-gd php84-php-iconv php84-php-json php84-php-libxml php84-php-mbstring php84-php-openssl php84-php-posix php84-php-session php84-php-xml php84-php-zip php84-php-zlib php84-php-pdo php84-php-mysqlnd php84-php-intl php84-php-bcmath php84-php-gmp
```

### Configurazione

#### Configurazione di Apache

Impostare l'esecuzione di _apache_ all'avvio del sistema:

```bash
systemctl enable httpd
```

Quindi fatelo partire:

```bash
systemctl start httpd
```

#### Creare la Configurazione

Nella sezione _Prerequisiti e presupposti_, era presente un'affermazione secondo cui per la configurazione sarebbe stata utilizzata la procedura [Apache Sites Enabled](../web/apache-sites-enabled.md). Fate clic su quella procedura e impostate le basi lì, quindi tornate a questo documento per continuare.

Per Nextcloud, si dovrà creare il seguente file di configurazione:

```bash
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

Con questi parametri:

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

Una volta fatto, salvate le modifiche (con ++shift+due punti+"w "+"q "+esclamativo++ per _vi_).

Successivamente, creare un collegamento a questo file in `/etc/httpd/sites-enabled`:

```bash
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### Creazione della Directory

Come indicato nella configurazione precedente, è necessario creare il _DocumentRoot_. Fare questo con:

```bash
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

Qui è dove si installerà la nuova istanza Nextcloud.

#### Configurazione di PHP

È necessario impostare il fuso orario per PHP. Per farlo, aprire `php.ini` con l'editor di testo preferito:

```bash
vi /etc/opt/remi/php84/php.ini
```

Trovate quindi la riga che dice:

```php
;date.timezone =
```

Rimuovere il commento (++punto e virgola++) e impostare il fuso orario corretto. Per questo fuso orario di esempio, è possibile inserire:

```php
date.timezone = "America/Chicago"
```

OPPURE

```php
date.timezone = "US/Central"
```

Quindi salvare ed uscire dal file `php.ini`.

Si noti che, per mantenere la coerenza, il fuso orario nel file `php.ini` deve corrispondere all'impostazione del fuso orario del computer. Si può scoprire quale sia eseguendo il comando che segue:

```bash
ls -al /etc/localtime
```

Si dovrebbe vedere qualcosa di simile, supponendo che si abbia impostato il fuso orario durante l'installazione di Rocky Linux e che si viva nel fuso orario dell'America Centrale:

```bash
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### Configurazione di mariadb-server

Impostare l'avvio di `mariadb-server` in fase di boot:

```bash
systemctl enable mariadb
```

E quindi avviarlo:

```bash
systemctl restart mariadb
```

Come indicato in precedenza, utilizzare la procedura di configurazione per [hardening `mariadb-server`](../database/database_mariadb-server.md) per la configurazione iniziale.

### Installazione da .zip

I passaggi successivi presuppongono che si sia connessi in remoto al vostro server Nextcloud tramite `ssh` con una console remota aperta:

- Accedere al [sito web di Nextcloud](https://nextcloud.com/).
- Passate con il mouse su “Download” per aprire un menu a tendina.
- Fare clic su 'Nextcloud server'.
- Cliccare su 'Download server archive'.
- Cliccare con il tasto destro su “Get ZIP file” e copiare il link.
- Nella console remota del server Nextcloud, digitate `wget`, quindi uno spazio e incollate il testo appena copiato. Si dovrebbe ottenere qualcosa di simile al seguente: `wget https://download.nextcloud.com/server/releases/latest.zip`.
- Una volta premuto Invio, il download del file .zip inizierà e verrà completato rapidamente.

Una volta completato il download, estrarre il file .zip di Nextcloud così:

```bash
unzip latest.zip
```

### Copiare il contenuto e modificare i permessi

Dopo aver completato la fase di estrazione del file .zip, si dovrebbe ora avere una nuova directory in `/root` chiamata “nextcloud”. Entrare nella directory:

```bash
cd nextcloud
```

Copiare o spostare il contenuto in locale su _DocumentRoot_:

```bash
cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

OPPURE

```bash
mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

Il passo successivo è assicurarsi che Apache sia il proprietario della directory. Fare questo con:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

Per motivi di sicurezza, è consigliabile spostare anche la cartella _data_ fuori dalla _DocumentRoot _ . Per farlo, utilizzate il seguente comando:

```bash
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```

### Configurazione di Nextcloud

Assicurarsi che i servizi stiano girando. Se si sono seguiti i passaggi precedenti, dovrebbero già essere in esecuzione. Sono state eseguite diverse operazioni dopo l'avvio iniziale dei servizi, quindi riavviarli per sicurezza:

```bash
systemctl restart httpd
systemctl restart mariadb
```

Se si riavviano tutti e non ci sono problemi, siete pronti per proseguire.

Per eseguire la configurazione iniziale, è necessario caricare il sito in un browser web:

<http://your-server-hostname/> (sostituire con l'attuale hostname)

Supponendo che finora si abbia fatto tutto correttamente, si dovrebbe vedere una schermata di configurazione di Nextcloud:

![nextcloud login screen](../images/nextcloud_screen.jpg)

Ci sono un paio di cose che si vuole fare in modo diverso rispetto alle impostazioni predefinite:

- Nella parte superiore della pagina web, dove è scritto `Crea un account amministratore`, impostare l'utente e la password. Ai fini di questo esempio, inseriamo `admin` e impostiamo una password sicura. Ricordate di salvarla in un posto sicuro (come un gestore di password) per non perderla! Anche se avete digitato in questo campo, non premete ++enter++ finché non sono stati completati  **tutti** i campi di impostazione!
- Nella sezione `Storage & database`, cambiare la posizione della `cartella Data` dalla radice predefinita del documento, alla posizione in cui abbiamo spostato la cartella dati in precedenza: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
- Nella sezione `Configura il database`, passare da `SQLite` a `MySQL/MariaDB` facendo clic su questo pulsante.
- Nei campi `Utente del database` e `Password del database` digitate l'utente root di MariaDB e la password impostata in precedenza.
- Nel campo `Nome del database`, digitare `nextcloud`.
- Nel campo `localhost` digitare: <localhost:3306> (3306 è la porta predefinita di _mariadb_).

Una volta fatto tutto questo, fate clic su `Finish Setup` e sarete subito operativi.

La finestra del browser si aggiorna per un po' e poi di solito non ricarica il sito. Inserendo nuovamente l'URL nella finestra del browser si dovrebbe vedere le prime pagine predefinite.

A questo punto l'utente amministratore è già (o dovrebbe essere) loggato, e ci sono diverse pagine informative pensate per farvi acquisire familiarità. La "Dashboard" è ciò che gli utenti vedranno al primo accesso. L'utente amministrativo può ora creare altri utenti, installare altre applicazioni e svolgere molte altre attività.

Il file "Nextcloud Manual.pdf" è il manuale d'uso, in modo che gli utenti possano familiarizzare con ciò che è disponibile. L'utente amministratore dovrebbe leggere attentamente o almeno dare un'occhiata ai punti salienti del manuale di amministrazione [sul sito web di Nextcloud](https://docs.nextcloud.com/server/21/admin_manual/).

## Passi successivi

A questo punto, non si dimentichi che si tratta di un server su cui verranno archiviati i dati aziendali. È importante proteggerlo con un firewall, configurare il [backup](../backup/rsnapshot_backup.md), proteggere il sito con [SSL](../security/generating_ssl_keys_lets_encrypt.md) e completare qualsiasi altra operazione necessaria per garantire la sicurezza dei dati.

## Conclusioni

È necessario valutare attentamente qualsiasi decisione di portare on-premise il cloud aziendale. Per coloro che decidono che mantenere i dati aziendali in locale è preferibile rispetto a un host cloud esterno, Nextcloud è una buona alternativa.
