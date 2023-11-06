---
title: Gestione del Software
author: Antoine Le Morvan
contributors: Colussi Franco, Steven Spencer
tested version: 8.5
tags:
  - education
  - software
  - software management
---

# Gestione del software

## Generalità

Su un sistema Linux, è possibile installare il software in due modi:

* Utilizzando un pacchetto di installazione;
* Compilandolo da un file sorgente.

!!! Note "Nota"

    L'installazione da sorgente non è trattata qui. Di norma, è necessario utilizzare il metodo del pacchetto a meno che il software desiderato non sia disponibile tramite il gestore pacchetti. La ragione di ciò è che le dipendenze sono generalmente gestite dal sistema di pacchetti, mentre con il sorgente, è necessario gestire manualmente le dipendenze.

**Il pacchetto**: si tratta di un singolo file contenente tutti i dati necessari per installare il programma. Può essere eseguito direttamente sul sistema da un repository software.

**I file sorgente**: Alcuni software non sono forniti in pacchetti pronti per essere installati, ma tramite un archivio contenente i file sorgente. Spetta all'amministratore preparare questi file e compilarli per installare il programma.

## RPM: Gestione pacchetti RedHat

**RPM** (RedHat Package Manager) è un sistema di gestione software. È possibile installare, disinstallare, aggiornare o controllare il software contenuto nei pacchetti.

**RPM** è il formato utilizzato da tutte le distribuzioni basate su RedHat (RockyLinux, Fedora, CentOS, SuSe, Mandriva, ...). Il suo equivalente nel mondo Debian è DPKG (Debian Package).

Il nome di un pacchetto RPM segue una nomenclatura specifica:

![Illustration of a package name](images/software-001.png)

### comando `rpm`

Il comando rpm consente di installare un pacchetto.

```bash
rpm [-i][-U] package.rpm [-e] package
```

Esempio (per un pacchetto denominato 'package'):

```bash
rpm -ivh package.rpm
```

| Opzione          | Descrizione                                         |
| ---------------- | --------------------------------------------------- |
| `-i package.rpm` | Installa il pacchetto.                              |
| `-U package.rpm` | Aggiorna un pacchetto già installato.               |
| `-e package.rpm` | Disinstalla il pacchetto.                           |
| `-h`             | Visualizza una barra di avanzamento.                |
| `-v`             | Informa sullo stato di avanzamento dell'operazione. |
| `--test`         | Esegue il test del comando senza eseguirlo.         |

Il comando `rpm` consente inoltre di interrogare il database dei pacchetti sul sistema aggiungendo l'opzione `-q`.

È possibile eseguire diversi tipi di ricerche per ottenere informazioni sui pacchetti installati. Il database RPM si trova nella directory `/var/lib/rpm`.

Esempio:

```bash
rpm -qa
```

Questo comando esegue una ricerca su tutti i pacchetti installati nel sistema.

```bash
rpm -q [-a][-i][-l] package [-f] file
```

Esempio:

```bash
rpm -qil package
rpm -qf /path/to/file
```

| Opzione          | Descrizione                                                                                                                   |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `-a`             | Elenca tutti i pacchetti installati nel sistema.                                                                              |
| `-i __package__` | Visualizza le informazioni sul pacchetto.                                                                                     |
| `-l __package__` | Elenca i file contenuti nel pacchetto.                                                                                        |
| `-f`             | Mostra il nome del pacchetto contenente il file specificato.                                                                  |
| `--last`         | L'elenco dei pacchetti è indicato per data di installazione (gli ultimi pacchetti installati vengono visualizzati per primi). |

!!! Warning "Attenzione"

    Dopo l'opzione `-q`, il nome del pacchetto deve essere esatto. I metacaratteri (wildcards) non sono supportati.

!!! Tip "Suggerimento"

    Tuttavia, è possibile elencare tutti i pacchetti installati e filtrarli con il comando `grep`.

Esempio: elencare gli ultimi pacchetti installati:

```bash
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

Esempio: elencare la cronologia di installazione del kernel:

```bash
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Esempio: elencare tutti i pacchetti installati con un nome specifico utilizzando 'grep':

```bash
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF: Dandified Yum

**DNF** (**Dandified Yum**) è un gestore di pacchetti software, successore di **YUM** (**Y**ellow Dog **U**pdater **M**odified). Funziona con pacchetti **RPM** raggruppati in un repository locale o remoto (una directory per l'archiviazione dei pacchetti). Per i comandi più comuni, il suo utilizzo è identico a quello di `yum`.

Il comando `dnf` permette la gestione dei pacchetti confrontando quelli installati sul sistema con quelli nei repository definiti sul server. Installa inoltre automaticamente le dipendenze, se sono presenti anche nei repository.

`dnf` è il gestore utilizzato da molte distribuzioni basate su RedHat (RockyLinux, Fedora, CentOS, ...). Il suo equivalente nel mondo Debian è **APT** (**A**dvanced **P**ackaging **T**ool).

### comando `dnf`

Il comando `dnf` consente di installare un pacchetto specificando solo il nome breve.

```bash
dnf [install][remove][list all][search][info] package
```

Esempio:

```bash
dnf install tree
```

È richiesto solo il nome breve del pacchetto.

| Opzione                   | Descrizione                                                                 |
| ------------------------- | --------------------------------------------------------------------------- |
| `install`                 | Installa il pacchetto.                                                      |
| `remove`                  | Disinstalla il pacchetto.                                                   |
| `list all`                | Elenca i pacchetti già nel repository.                                      |
| `search`                  | Cerca un pacchetto nel repository.                                          |
| `provides */command_name` | Cerca un comando.                                                           |
| `info "Informazione"`     | Visualizza le informazioni sul pacchetto.                                   |
| `autoremove`              | Rimuove tutti i pacchetti installati come dipendenze, ma non più necessari. |


Il comando `dnf install` consente di installare il pacchetto desiderato senza preoccuparsi delle sue dipendenze, che sarà risolto direttamente da `dnf` stesso.

```bash
dnf install nginx
Last metadata expiration check: 3:13:41 ago on Wed 23 Mar 2022 07:19:24 AM CET.
Dependencies resolved.
============================================================================================================================
 Package                             Architecture    Version                                        Repository         Size
============================================================================================================================
Installing:
 nginx                               aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream         543 k
Installing dependencies:
 nginx-all-modules                   noarch          1:1.14.1-9.module+el8.4.0+542+81547229         appstream          22 k
 nginx-mod-http-image-filter         aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          33 k
 nginx-mod-http-perl                 aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          44 k
 nginx-mod-http-xslt-filter          aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          32 k
 nginx-mod-mail                      aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          60 k
 nginx-mod-stream                    aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          82 k

Transaction Summary
============================================================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.2 M
Is this ok [y/N]:
```

Nel caso in cui non ricordi il nome esatto del pacchetto, puoi cercarlo con il comando `dnf nome_di_ricerca`. Come puoi vedere, c'è una sezione che contiene il nome esatto e un'altra che contiene la corrispondenza del pacchetto, tutti i quali sono evidenziati per facilitare la ricerca.

```bash
dnf search nginx
Last metadata expiration check: 0:20:55 ago on Wed 23 Mar 2022 10:40:43 AM CET.
=============================================== Name Exactly Matched: nginx ================================================
nginx.aarch64 : A high performance web server and reverse proxy server
============================================== Name & Summary Matched: nginx ===============================================
collectd-nginx.aarch64 : Nginx plugin for collectd
munin-nginx.noarch : NGINX support for Munin resource monitoring
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-filesystem.noarch : The basic directory layout for the Nginx server
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
pagure-web-nginx.noarch : Nginx configuration for Pagure
pcp-pmda-nginx.aarch64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver
python3-certbot-nginx.noarch : The nginx plugin for certbot
```

Un altro modo per cercare un pacchetto inserendo una chiave di ricerca aggiuntiva è quello di inviare il risultato del comando `dnf` attraverso una pipe al comando grep con la chiave desiderata.

```bash
dnf search nginx | grep mod
Last metadata expiration check: 3:44:49 ago on Wed 23 Mar 2022 06:16:47 PM CET.
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
```


Il comando `dnf remove` rimuove un pacchetto dal sistema e le sue dipendenze. Di seguito è riportato un estratto del comando **dnf remove httpd**.

```bash
dnf remove httpd
Dependencies resolved.
============================================================================================================================
 Package                        Architecture    Version                                            Repository          Size
============================================================================================================================
Removing:
 httpd                          aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         8.9 M
Removing dependent packages:
 mod_ssl                        aarch64         1:2.4.37-43.module+el8.5.0+727+743c5577.1          @appstream         274 k
 php                            aarch64         7.4.19-1.module+el8.5.0+696+61e7c9ba               @appstream         4.4 M
 python3-certbot-apache         noarch          1.22.0-1.el8                                       @epel              539 k
Removing unused dependencies:
 apr                            aarch64         1.6.3-12.el8                                       @appstream         299 k
 apr-util                       aarch64         1.6.1-6.el8.1                                      @appstream         224 k
 apr-util-bdb                   aarch64         1.6.1-6.el8.1                                      @appstream          67 k
 apr-util-openssl               aarch64         1.6.1-6.el8.1                                      @appstream          68 k
 augeas-libs                    aarch64         1.12.0-6.el8                                       @baseos            1.4 M
 httpd-filesystem               noarch          2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         400
 httpd-tools                    aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1
...
```

Il comando `dnf list` elenca tutti i pacchetti installati sul sistema e presenti nel repository. Accetta diversi parametri:

| Parametro   | Descrizione                                                               |
| ----------- | ------------------------------------------------------------------------- |
| `all`       | Elenca i pacchetti installati e quindi quelli disponibili nei repository. |
| `available` | Elenca solo i pacchetti disponibili per l'installazione.                  |
| `updates`   | Elenca i pacchetti che possono essere aggiornati.                         |
| `obsoletes` | Elenca i pacchetti resi obsoleti dalle versioni superiori disponibili.    |
| `recent`    | Elenca i pacchetti più recenti aggiunti al repository.                    |

Il comando `dnf info`, come ci si può aspettare, fornisce informazioni dettagliate su un pacchetto:

```bash
dnf info firewalld
Last metadata expiration check: 15:47:27 ago on Tue 22 Mar 2022 05:49:42 PM CET.
Installed Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8
Architecture : noarch
Size         : 2.0 M
Source       : firewalld-0.9.3-7.el8.src.rpm
Repository   : @System
From repo    : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.

Available Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8_5.1
Architecture : noarch
Size         : 501 k
Source       : firewalld-0.9.3-7.el8_5.1.src.rpm
Repository   : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.
```

A volte si conosce solo l'eseguibile che si desidera utilizzare, ma non il pacchetto che lo contiene, in questo caso è possibile utilizzare il comando `dnf provides */package_name` che cercherà il database per la corrispondenza desiderata.

Esempio di ricerca del comando `semanage`:

```bash
dnf provides */semanage
Last metadata expiration check: 1:12:29 ago on Wed 23 Mar 2022 10:40:43 AM CET.
libsemanage-devel-2.9-6.el8.aarch64 : Header files and libraries used to build policy manipulation tools
Repo        : powertools
Matched from:
Filename    : /usr/include/semanage

policycoreutils-python-utils-2.9-16.el8.noarch : SELinux policy core python utilities
Repo        : baseos
Matched from:
Filename    : /usr/sbin/semanage
Filename    : /usr/share/bash-completion/completions/semanage
```

Il comando `dnf autoremove` non necessita di alcun parametro. Dnf si occupa della ricerca dei pacchetti candidati per la rimozione.

```bash
dnf autoremove
Last metadata expiration check: 0:24:40 ago on Wed 23 Mar 2022 06:16:47 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
```

### Altre utili opzioni `dnf`

| Opzione     | Descrizione                                    |
| ----------- | ---------------------------------------------- |
| `repolist`  | Elenca i repository configurati sul sistema.   |
| `grouplist` | Elenca le collezioni di pacchetti disponibili. |
| `clean`     | Rimuove i file temporanei.                     |

Il comando `dnf repolist` elenca i repository configurati sul sistema. Per impostazione predefinita elenca solo i repository abilitati, ma può essere utilizzato con questi parametri:

| Parametro    | Descrizione                            |
| ------------ | -------------------------------------- |
| `--all`      | Elenca tutti i repository.             |
| `--enabled`  | Default                                |
| `--disabled` | Elenca solo i repository disabilitati. |

Esempio:

```bash
dnf repolist
repo id                                                  repo name
appstream                                                Rocky Linux 8 - AppStream
baseos                                                   Rocky Linux 8 - BaseOS
epel                                                     Extra Packages for Enterprise Linux 8 - aarch64
epel-modular                                             Extra Packages for Enterprise Linux Modular 8 - aarch64
extras                                                   Rocky Linux 8 - Extras
powertools                                               Rocky Linux 8 - PowerTools
rockyrpi                                                 Rocky Linux 8 - Rasperry Pi
```

E un estratto del comando con la flag `--all`.

```bash
dnf repolist --all

...
repo id                                             repo name                                                                                       status
appstream                                           Rocky Linux 8 - AppStream                                                                       enabled
appstream-debug                                     Rocky Linux 8 - AppStream - Source                                                              disabled
appstream-source                                    Rocky Linux 8 - AppStream - Source                                                              disabled
baseos                                              Rocky Linux 8 - BaseOS                                                                          enabled
baseos-debug                                        Rocky Linux 8 - BaseOS - Source                                                                 disabled
baseos-source                                       Rocky Linux 8 - BaseOS - Source                                                                 disabled
devel                                               Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE                                       disabled
epel                                                Extra Packages for Enterprise Linux 8 - aarch64                                                 enabled
epel-debuginfo                                      Extra Packages for Enterprise Linux 8 - aarch64 - Debug                                         disabled
epel-modular                                        Extra Packages for Enterprise Linux Modular 8 - aarch64                                         enabled
epel-modular-debuginfo                              Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug                                 disabled
epel-modular-source                                 Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
...
```

E qui sotto è un estratto dalla lista dei repository disabilitati.

```bash
dnf repolist --disabled
repo id                                 repo name
appstream-debug                         Rocky Linux 8 - AppStream - Source
appstream-source                        Rocky Linux 8 - AppStream - Source
baseos-debug                            Rocky Linux 8 - BaseOS - Source
baseos-source                           Rocky Linux 8 - BaseOS - Source
devel                                   Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
epel-debuginfo                          Extra Packages for Enterprise Linux 8 - aarch64 - Debug
epel-modular-debuginfo                  Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug
epel-modular-source                     Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
epel-source                             Extra Packages for Enterprise Linux 8 - aarch64 - Source
epel-testing                            Extra Packages for Enterprise Linux 8 - Testing - aarch64
...
```

L'utilizzo dell'opzione `-v` migliora la lista con molte informazioni aggiuntive. Qui sotto puoi vedere parte del risultato del comando.

```bash
dnf repolist -v

...
Repo-id            : powertools
Repo-name          : Rocky Linux 8 - PowerTools
Repo-revision      : 8.5
Repo-distro-tags      : [cpe:/o:rocky:rocky:8]:  ,  , 8, L, R, c, i, k, n, o, u, x, y
Repo-updated       : Wed 16 Mar 2022 10:07:49 PM CET
Repo-pkgs          : 1,650
Repo-available-pkgs: 1,107
Repo-size          : 6.4 G
Repo-mirrors       : https://mirrors.rockylinux.org/mirrorlist?arch=aarch64&repo=PowerTools-8
Repo-baseurl       : https://mirror2.sandyriver.net/pub/rocky/8.8/PowerTools/x86_64/os/ (30 more)
Repo-expire        : 172,800 second(s) (last: Tue 22 Mar 2022 05:49:24 PM CET)
Repo-filename      : /etc/yum.repos.d/Rocky-PowerTools.repo
...
```

!!! info "Usare i Gruppi"

    I gruppi sono una raccolta di una serie di pacchetti (si può pensare a loro come pacchetti virtuali) che logicamente raggruppa una serie di applicazioni per realizzare uno scopo (un ambiente desktop, un server, strumenti di sviluppo, ecc.).

Il comando `dnf grouplist` elenca tutti i gruppi disponibili.

```bash
dnf grouplist
Last metadata expiration check: 1:52:00 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   KDE Plasma Workspaces
   Custom Operating System
Available Groups:
   Container Management
   .NET Core Development
   RPM Development Tools
   Development Tools
   Headless Management
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
```

Il comando `dnf groupinstall` consente di installare uno di questi gruppi.

```bash
dnf groupinstall "Network Servers"
Last metadata expiration check: 2:33:26 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Dependencies resolved.
================================================================================
 Package           Architecture     Version             Repository         Size
================================================================================
Installing Groups:
 Network Servers

Transaction Summary
================================================================================

Is this ok [y/N]:
```

Notate che è buona pratica racchiudere il nome del gruppo tra virgolette doppie poiché senza il comando verrà eseguito correttamente solo se il nome del gruppo non contiene spazi.

Quindi un `dnf groupinstall Network Server` produce il seguente errore.

```bash
dnf groupinstall Network Servers
Last metadata expiration check: 3:05:45 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Module or Group 'Network' is not available.
Module or Group 'Servers' is not available.
Error: Nothing to do.
```

Il comando corrispondente per rimuovere un gruppo è `dnf groupremove "name group"`.

Il comando `dnf clean` pulisce tutte le cache e i file temporanei creati da `dnf`. Può essere utilizzato con i seguenti parametri.

| Parametri      | Descrizione                                                        |
| -------------- | ------------------------------------------------------------------ |
| `all`          | Rimuove tutti i file temporanei creati per i repository abilitati. |
| `dbcache`      | Rimuove i file cache per i metadati del repository.                |
| `expire-cache` | Rimuovere i file dei cookie locali.                                |
| `metadata`     | Rimuove tutti i metadati dei repository.                           |
| `packages`     | Rimuove qualsiasi pacchetto nella cache.                           |


### Come funziona DNF

Il gestore DNF si basa su uno o più file di configurazione per indirizzare i repository contenenti i pacchetti RPM.

Questi file si trovano in `/etc/yum.repos.d/` e devono terminare con `.repo` per poter essere utilizzati da DNF.

Esempio:

```bash
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Ogni file `.repo` consiste almeno delle seguenti informazioni, una direttiva per riga.

Esempio:

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

Per impostazione predefinita, la direttiva `enabled` è assente, il che significa che il repository è abilitato. Per disabilitare un repository, è necessario specificare la direttiva `enabled=0`.

## Moduli DNF

I moduli sono stati introdotti in Rocky Linux 8 dall'upstream. Per utilizzare i moduli, il repository AppStream deve esistere ed essere abilitato.

!!! hint "Confusione tra i pacchetti"

    La creazione di flussi di moduli nel repository AppStream ha creato molta confusione. Poiché i moduli sono impacchettati all'interno di un flusso (si vedano i nostri esempi qui sotto), un particolare pacchetto viene visualizzato nei nostri RPM, ma se si tenta di installarlo senza abilitare il modulo, non succede nulla. Ricordate di guardare i moduli se cercate di installare un pacchetto e non lo trovate.

### Cosa sono i moduli

I moduli provengono dal repository AppStream e contengono sia flussi che profili. Questi possono essere descritti come segue:

* **flussi di moduli:** Un flusso di moduli può essere considerato come un repository separato all'interno del repository AppStream che contiene diverse versioni di applicazioni. Questi repository di moduli contengono gli RPM delle applicazioni, le dipendenze e la documentazione per quel particolare flusso. Un esempio di flusso di moduli in Rocky Linux 8 è `postgresql`. Se si installa `postgresql` utilizzando la procedura standard `sudo dnf install postgresql` si otterrà la versione 10. Tuttavia, utilizzando i moduli, è possibile installare le versioni 9.6, 12 o 13.

* **profili dei moduli:** Un profilo del modulo prende in considerazione il caso d'uso del flusso del modulo quando si installa il pacchetto. L'applicazione di un profilo regola i pacchetti RPM, le dipendenze e la documentazione per soddisfare l'uso del modulo. Utilizzando lo stesso flusso `postgresql` del nostro esempio, è possibile applicare un profilo "server" o "client". Ovviamente, non è necessario installare gli stessi pacchetti sul sistema se si intende usare `postgresql` solo come client per accedere a un server.

### Elenco dei moduli

È possibile ottenere un elenco di tutti i moduli eseguendo il seguente comando:

```
dnf module list
```

In questo modo si ottiene un lungo elenco dei moduli disponibili e dei profili che possono essere utilizzati per essi. Il fatto è che probabilmente sapete già a quale pacchetto siete interessati, quindi per scoprire se ci sono moduli per un particolare pacchetto, aggiungete il nome del pacchetto dopo "list". Utilizzeremo di nuovo l'esempio del pacchetto `postgresql`:

```
dnf module list postgresql
```

Si otterrà un risultato simile a questo:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Nell'elenco si noti la dicitura "[d]". Ciò significa che è l'impostazione predefinita. Mostra che la versione predefinita è la 10 e che, indipendentemente dalla versione scelta, se non si specifica un profilo, verrà utilizzato il profilo del server, che è anche quello predefinito.

### Abilitazione dei Moduli

Utilizzando il nostro pacchetto di esempio `postgresql`, supponiamo di voler abilitare la versione 12. Per farlo, è sufficiente utilizzare la seguente procedura:

```
dnf module enable postgresql:12
```

Il comando enable richiede il nome del modulo seguito da un ":" e il nome del flusso.

Per verificare che sia stato abilitato il flusso del modulo `postgresql` versione 12, utilizzare nuovamente il comando list che dovrebbe mostrare il seguente output:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12 [e]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Qui si può notare il simbolo "[e]" per "enabled" accanto allo stream 12, quindi sappiamo che la versione 12 è abilitata.

### Installazione dei pacchetti dal flusso del modulo

Ora che il nostro flusso di moduli è abilitato, il passo successivo è installare `postgresql`, l'applicazione client per il server postgresql. Questo può essere ottenuto eseguendo il seguente comando:

```
dnf install postgresql
```

Che dovrebbe fornire questo risultato:

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k

Transaction Summary
========================================================================================================================================
Install  2 Packages
Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Dopo aver approvato digitando "y", verrà installata l'applicazione.

### Installazione di pacchetti dai profili di flusso del modulo

È anche possibile installare direttamente i pacchetti senza nemmeno dover abilitare il flusso dei moduli! In questo esempio, supponiamo di voler applicare il profilo client solo alla nostra installazione. Per farlo, basta inserire questo comando:

```
dnf install postgresql:12/client
```

Che dovrebbe fornire questo risultato:

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k
Installing module profiles:
 postgresql/client
Enabling module streams:
 postgresql                                        12

Transaction Summary
========================================================================================================================================
Install  2 Packages

Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Rispondendo "y" al prompt, si installerà tutto ciò che serve per utilizzare postgresql versione 12 come client.

### Rimozione e Ripristino del modulo o Commutazione

Dopo l'installazione, si potrebbe decidere che, per qualsiasi motivo, è necessaria una versione diversa dello stream. Il primo passo è rimuovere i pacchetti. Utilizzando di nuovo il nostro pacchetto di esempio `postgresql`, lo faremo con:

```
dnf remove postgresql
```

Questa procedura mostrerà un risultato simile a quello della procedura di installazione precedente, tranne che per la rimozione del pacchetto e di tutte le sue dipendenze. Rispondere "y" alla richiesta e premere invio per disinstallare `postgresql`.

Una volta completata questa fase, è possibile lanciare il comando di reset per il modulo utilizzando:

```
dnf module reset postgresql
```

Che fornirà un risultato come questo:

```
Dependencies resolved.
========================================================================================================================================
 Package                         Architecture                   Version                           Repository                       Size
========================================================================================================================================
Disabling module profiles:
 postgresql/client                                                                                                                     
Resetting modules:
 postgresql                                                                                                                            

Transaction Summary
========================================================================================================================================

Is this ok [y/N]:
```

Rispondendo "y" al prompt, `postgresql` tornerà al flusso predefinito e il flusso che avevamo abilitato (12 nel nostro esempio) non sarà più abilitato:

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Ora è possibile utilizzare l'impostazione predefinita.

Si può anche usare il sottocomando switch-to per passare da un flusso abilitato a un altro. Utilizzando questo metodo non solo si passa al nuovo flusso, ma si installano i pacchetti necessari (sia per il downgrade che per l'upgrade) senza un passaggio separato. Per usare questo metodo per abilitare lo stream `postgresql` versione 13 e usare il profilo "client", si deve usare:

```
dnf module switch-to postgresql:13/client
```

### Disattivare un flusso di moduli

Può capitare che si voglia disabilitare la possibilità di installare pacchetti da un flusso di moduli. Nel caso del nostro esempio di `postgresql`, questo potrebbe essere dovuto al fatto che si vuole usare il repository direttamente da [PostgreSQL](https://www.postgresql.org/download/linux/redhat/), in modo da poter usare una versione più recente (al momento in cui scriviamo, le versioni 14 e 15 sono disponibili da questo repository). La disabilitazione di un flusso di moduli rende impossibile l'installazione di qualsiasi pacchetto senza prima abilitarlo nuovamente.

Per disabilitare i flussi del modulo per `postgresql` è sufficiente fare:

```
dnf module disable postgresql
```

Se si elencano di nuovo i moduli `postgresql`, si vedrà quanto segue, tutte le versioni dei moduli `postgresql` sono disabilitate:

```
Rocky Linux 8 - AppStream
Name                       Stream                   Profiles                          Summary                                           
postgresql                 9.6 [x]                  client, server [d]                PostgreSQL server and client module               
postgresql                 10 [d][x]               client, server [d]                PostgreSQL server and client module               
postgresql                 12 [x]                   client, server [d]                PostgreSQL server and client module               
postgresql                 13 [x]                   client, server [d]                PostgreSQL server and client module
```

## Il repository EPEL

### Che cos’è EPEL e come si usa?

**EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) è un repository contenente pacchetti software aggiuntivi per Enterprise Linux, che include RedHat Enterprise Linux (RHEL), RockyLinux, CentOS, ecc.

Fornisce pacchetti che non sono inclusi nei repository RHEL ufficiali. Questi non sono inclusi perché non sono considerati necessari in un ambiente enterprise o considerati al di fuori del campo di applicazione di RHEL. Non dobbiamo dimenticare che RHEL è una distribuzione di classe enterprise, e le utility desktop o altri software specializzati possono non essere una priorità per un progetto enterpise.

### Installazione

L'installazione dei file necessari può essere effettuata facilmente con il pacchetto fornito di default da Rocky Linux.

Se sei dietro un proxy internet:

```bash
export http_proxy=http://172.16.1.10:8080
```

Quindi:

```bash
dnf install epel-release
```

Una volta installato è possibile controllare che il pacchetto sia stato installato correttamente con il comando `dnf info`.

```bash
dnf info epel-release
Last metadata expiration check: 1:30:29 ago on Thu 24 Mar 2022 09:36:42 AM CET.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 14.el8
Architecture : noarch
Size         : 32 k
Source       : epel-release-8-14.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux
             : (EPEL) repository GPG key as well as configuration for yum.
```

Il pacchetto, come si può vedere dalla descrizione del pacchetto sopra, non contiene eseguibili, librerie, ecc... ma solo i file di configurazione e le chiavi GPG per impostare il repository.

Un altro modo per verificare la corretta installazione è quello di interrogare il database degli rpm.

```bash
rpm -qa | grep epel
epel-release-8-14.el8.noarch
```

Ora è necessario eseguire un aggiornamento per consentire a `dnf` di riconoscere il repository. Ti verrà chiesto di accettare le chiavi GPG dei repository. Chiaramente, è necessario rispondere SÌ per utilizzarli.

```bash
dnf update
```

Una volta completato l'aggiornamento, è possibile verificare che il repository sia stato configurato correttamente con il comando `dnf repolist` che dovrebbe ora elencare i nuovi repository.

```bash
dnf repolist
repo id            repo name
...
epel               Extra Packages for Enterprise Linux 8 - aarch64
epel-modular       Extra Packages for Enterprise Linux Modular 8 - aarch64
...
```

I file di configurazione del repository si trovano in `/etc/yum.repos.d/`.

```
ll /etc/yum.repos.d/ | grep epel
-rw-r--r--. 1 root root 1485 Jan 31 17:19 epel-modular.repo
-rw-r--r--. 1 root root 1422 Jan 31 17:19 epel.repo
-rw-r--r--. 1 root root 1584 Jan 31 17:19 epel-testing-modular.repo
-rw-r--r--. 1 root root 1521 Jan 31 17:19 epel-testing.repo
```

E di seguito possiamo vedere il contenuto del file `epel.repo`.

```bash
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Debug
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place it's address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1
```

### Usare EPEL

A questo punto, una volta configurati, siamo pronti per installare i pacchetti da EPEL. Per iniziare, possiamo elencare i pacchetti disponibili nel repository con il comando:

```bash
dnf --disablerepo="*" --enablerepo="epel" list available
```

E un estratto del comando

```bash
dnf --disablerepo="*" --enablerepo="epel" list available | less
Last metadata expiration check: 1:58:22 ago on Fri 25 Mar 2022 09:23:29 AM CET.
Available Packages
3proxy.aarch64                                                    0.8.13-1.el8                                    epel
AMF-devel.noarch                                                  1.4.23-2.el8                                    epel
AMF-samples.noarch                                                1.4.23-2.el8                                    epel
AusweisApp2.aarch64                                               1.22.3-1.el8                                    epel
AusweisApp2-data.noarch                                           1.22.3-1.el8                                    epel
AusweisApp2-doc.noarch                                            1.22.3-1.el8                                    epel
BackupPC.aarch64                                                  4.4.0-1.el8                                     epel
BackupPC-XS.aarch64                                               0.62-1.el8                                      epel
BibTool.aarch64                                                   2.68-1.el8                                      epel
CCfits.aarch64                                                    2.5-14.el8                                      epel
CCfits-devel.aarch64                                              2.5-14.el8                                      epel
...
```

Dal comando possiamo vedere che per installare da EPEL dobbiamo forzare **dnf** a interrogare il repository richiesto con le opzioni `--disablerepo` e `--enablerepo`, questo perché altrimenti una corrispondenza trovata in altri repository opzionali (RPM Fusion, REMI, ELRepo, ecc.) potrebbe essere più recente e quindi avere la priorità. Queste opzioni non sono necessarie se hai installato EPEL come solo repository opzionale perché i pacchetti nel repository non saranno mai disponibili in quelli ufficiali. Almeno nella stessa versione!

!!! attention "Considerazione sul Supporto"

    Un aspetto da considerare per quanto riguarda il supporto (aggiornamenti, correzioni di bug, patch di sicurezza) è che i pacchetti EPEL non hanno alcun supporto ufficiale da RHEL e tecnicamente la loro vita potrebbe durare lo spazio di uno sviluppo di Fedora (sei mesi) e poi scomparire. Questa è una possibilità remota ma una da considerare.

Quindi, per installare un pacchetto dai repository EPEL si utilizzerà:

```bash
dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 2:01:36 ago on Fri 25 Mar 2022 04:28:04 PM CET.
Dependencies resolved.
==============================================================================================================================================================
 Package                            Architecture                          Version                                    Repository                          Size
==============================================================================================================================================================
Installing:
 nmon                               aarch64                               16m-1.el8                                  epel                                71 k

Transaction Summary
==============================================================================================================================================================
Install  1 Package

Total download size: 71 k
Installed size: 214 k
Is this ok [y/N]:
```

### Conclusione

EPEL non è un repository ufficiale per RHEL, ma può essere utile per gli amministratori e gli sviluppatori che lavorano con RHEL o derivati e hanno bisogno di alcune utility preparate per RHEL da una fonte di cui si possono fidare.

## Plugin DNF

Il pacchetto `dnf-plugins-core` aggiunge plugin a `dnf` che saranno utili per la gestione dei repository.

!!! NOTE "Nota"

    Maggiori informazioni qui: https://dnf-plugins-core.readthedocs.io/en/latest/index.html

Installare il pacchetto sul vostro sistema:

```
dnf install dnf-plugins-core
```

Non tutti i plugin saranno presentati qui, ma si può fare riferimento alla documentazione del pacchetto per un elenco completo dei plugin e per informazioni dettagliate.

### `config-manager` plugin

Gestire le opzioni DNF, aggiungere repository o disabilitarli.

Esempi:

* Scaricare un file `.repo` e utilizzarlo:

```
dnf config-manager --add-repo https://packages.centreon.com/ui/native/rpm-standard/23.04/el8/centreon-23.04.repo
```

* È anche possibile impostare un url come url di base per un repo:

```
dnf config-manager --add-repo https://repo.rocky.lan/repo
```

* Abilitare o disabilitare uno o più repo:

```
dnf config-manager --set-enabled epel centreon
dnf config-manager --set-disabled epel centreon
```

* Aggiungi un proxy al file di configurazione:

```
dnf config-manager --save --setopt=*.proxy=http://proxy.rocky.lan:3128/
```

### `copr` plugin

`copr` è un fork automatico di rpm, che fornisce un repo con i pacchetti compilati.

* Attivare un repo copr:

```
copr enable xxxx
```

### `download` plugin

Scaricare il pacchetto rpm invece di installarlo:

```
dnf download ansible
```

Se si vuole ottenere solo l'url della posizione remota del pacchetto:

```
dnf download --url ansible
```

Oppure se si desidera scaricare anche le dipendenze:

```
dnf download --resolv --alldeps ansible
```

### `needs-restart` plugin

Dopo aver eseguito un `dnf update`, i processi in esecuzione continueranno a funzionare ma con i vecchi binari. Per adottare le modifiche al codice e soprattutto gli aggiornamenti di sicurezza, devono essere riavviati.

Il plugin `needs-restarting` consente di rilevare i processi che si trovano in questo stato.

```
dnf needs-restarting [-u] [-r] [-s]
```

| Opzioni | Descrizione                                                      |
| ------- | ---------------------------------------------------------------- |
| `-u`    | Considera solo i processi appartenenti all'utente in esecuzione. |
| `-r`    | per verificare se è necessario un riavvio.                       |
| `-s`    | per verificare se i servizi devono essere riavviati.             |
| `-s -r` | per fare entrambe le cose in un unico ciclo.                     |

### `versionlock` plugin

A volte è utile proteggere i pacchetti da tutti gli aggiornamenti o escludere alcune versioni di un pacchetto (ad esempio a causa di problemi noti). A questo scopo, il plugin versionlock sarà di grande aiuto.

È necessario installare un pacchetto aggiuntivo:

```
dnf install python3-dnf-plugin-versionlock
```

Esempi:

* Blocca la versione ansibile:

```
dnf versionlock add ansible
Adding versionlock on: ansible-0:6.3.0-2.el9.*
```

* Lista pacchetti bloccati:

```
dnf versionlock list
ansible-0:6.3.0-2.el9.*
```
