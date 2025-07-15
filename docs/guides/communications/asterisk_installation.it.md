---
title: Installazione di Asterisk
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - asterisk
  - pbx
  - communications
---

!!! note "Nota"

    L'ultima versione di Rocky Linux su cui è stata testata questa procedura è stata la versione 8.5. Poiché la maggior parte di questa procedura si basa sulla compilazione dei sorgenti direttamente da Asterisk e su un semplice set di strumenti di sviluppo di Rocky Linux, dovrebbe funzionare su tutte le versioni. Se riscontrate un problema, fatecelo sapere!

# Installazione di Asterisk su Rocky Linux

**Che cos'è Asterisk?**

Asterisk è un framework open-source per la creazione di applicazioni di comunicazione. Inoltre, Asterisk trasforma un normale computer in un server di comunicazione, alimenta sistemi PBX IP, gateway VoIP, server per conferenze e altre soluzioni personalizzate. È utilizzato da piccole imprese, grandi aziende, call center, vettori e agenzie governative in tutto il mondo.

Asterisk è gratuito e open source ed è sponsorizzato da [Sangoma](https://www.sangoma.com/). Sangoma offre anche prodotti commerciali che utilizzano Asterisk sotto il cofano e, a seconda della vostra esperienza e del vostro budget, l'utilizzo di questi prodotti potrebbe essere più vantaggioso rispetto alla creazione di un proprio sistema. Solo voi e la vostra organizzazione conoscete la risposta.

Va notato che questa guida richiede che l'amministratore faccia una discreta quantità di ricerche per conto proprio. L'installazione di un server di comunicazione non è difficile, ma la sua gestione può essere piuttosto complicata. Sebbene questa guida renda il vostro server operativo, non sarà pronto per l'uso in produzione.

## Prerequisiti

Per completare questa guida sono necessarie almeno le seguenti competenze e strumenti:

- Una macchina con Rocky Linux
- Un livello di comfort nella modifica dei file di configurazione e nell'emissione di comandi dalla riga di comando
- Conoscenza dell'uso di un editor a riga di comando (qui usiamo `vi`, ma potete sostituirlo con il vostro editor preferito)
- È necessario avere accesso a root e, idealmente, essere registrati come utente root nel proprio terminale
- I repository EPEL di Fedora
- La possibilità di accedere come root o di eseguire comandi di root con `sudo`. Tutti i comandi qui riportati presuppongono un utente con diritti `sudo`. Tuttavia, i processi di configurazione e compilazione vengono eseguiti con `sudo -s`.
- Per ottenere l'ultima versione di Asterisk, è necessario utilizzare `curl` o `wget`. Questa guida utilizza `wget`, ma se preferite potete sostituire la stringa `curl` appropriata.

## Aggiornare Rocky Linux e installare `wget`

```bash
sudo dnf -y update
```

In questo modo il server sarà aggiornato con tutti i pacchetti rilasciati o aggiornati dall'ultimo aggiornamento o installazione. Quindi eseguire:

```bash
sudo dnf install wget
```

## Impostare il nome dell'host

Impostate il vostro hostname sul dominio che userete per Asterisk.

```bash
sudo hostnamectl set-hostname asterisk.example.com
```

## Aggiungere i repository necessari

Per prima cosa, installare EPEL (Extra Packages for Enterprise Linux):

```bash
sudo dnf -y install epel-release
```

Quindi, attivare i PowerTools di Rocky Linux:

```bash
sudo dnf config-manager --set-enabled powertools
```

## Installare gli strumenti di sviluppo

```bash
sudo dnf group -y install "Development Tools"
sudo dnf -y install git wget  
```

## Installare Asterisk

### Scaricare e configurare la build di Asterisk

Prima di scaricare questo script, assicuratevi di avere la versione più recente. Per farlo, visitate il [link per il download di Asterisk qui](http://downloads.asterisk.org/pub/telephony/asterisk/) e cercate l'ultima versione di Asterisk. Quindi copiate la posizione del link. Al momento della stesura di questo documento, la build più recente era la seguente:

```bash
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz 
tar xvfz asterisk-20-current.tar.gz
cd asterisk-20.0.0/
```

Prima di eseguire il comando `install_prereq` (e gli altri comandi), è necessario essere superutente o root. A questo punto è molto più facile entrare in `sudo` in modo permanente per un po'. Si uscirà da `sudo` più avanti nel processo:

```bash
sudo -s
contrib/scripts/install_prereq install
```

Al termine dello script si dovrebbe vedere quanto segue:

```text
#############################################
## install completed successfully
#############################################
```

Ora che avete tutti i pacchetti necessari, il prossimo passo è configurare e costruire Asterisk:

```bash
./configure --libdir=/usr/lib64 --with-jansson-bundled=yes
```

Supponendo che la configurazione venga eseguita senza problemi, si otterrà un grande simbolo ASCII di Asterisk, seguito dal seguente messaggio su Rocky Linux:

```bash
configure: Package configured for:
configure: OS type  : linux-gnu
configure: Host CPU : x86_64
configure: build-cpu:vendor:os: x86_64 : pc : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : pc : linux-gnu :
```

### Set Asterisk menu options [For more options]

Questa è una delle fasi in cui l'amministratore deve fare i compiti a casa. Esistono molte opzioni di menu che potrebbero non essere necessarie. Eseguire il seguente comando:

```bash
make menuselect
```

si aprirà una schermata di selezione del menu:

![menuselect screen](../images/asterisk_menuselect.png)

Esaminate attentamente queste opzioni e scegliete in base alle vostre esigenze. Come già detto, questo richiederà un ulteriore lavoro a casa.

### Compilare ed installare Asterisk

Per compilare, eseguire i seguenti comandi in successione:

```bash
make
make install
```

L'installazione della documentazione non è obbligatoria, ma a meno che non siate esperti di server di comunicazione, dovrete installarla:

```bash
make progdocs
```

Quindi, installare il PBX di base e configurarlo. Il PBX di base è proprio questo, molto semplice! Probabilmente sarà necessario apportare delle modifiche per far funzionare il PBX come si desidera.

```bash
make basic-pbx
make config
```

## Configurazione di Asterisk

### Creare un utente e un gruppo

Avrete bisogno di un utente e di un gruppo specifici solo per Asterisk. Createli ora:

```bash
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
restorecon -vr {/etc/asterisk,/var/lib/asterisk,/var/log/asterisk,/var/spool/asterisk}
```

Dal momento che la maggior parte del lavoro di compilazione è stato completato, si può uscire dal comando `sudo -s`. Questo richiederà che la maggior parte dei comandi rimanenti utilizzino nuovamente `sudo`:

```bash
exit
```

### Impostare l'utente e il gruppo predefiniti

```bash
sudo vi /etc/sysconfig/asterisk
```

Rimuovere i commenti nelle due righe sottostanti e salvare:

```bash
AST_USER="asterisk"
AST_GROUP="asterisk"
```

```bash
sudo vi /etc/asterisk/asterisk.conf
```

Rimuovere i commenti nelle due righe sottostanti e salvare:

```bash
runuser = asterisk ; The user to run as.
rungroup = asterisk ; The group to run as.
```

### Configurare il servizio Asterisk

```bash
sudo systemctl enable asterisk
```

### Configurare il firewall

Questo esempio utilizza `firewalld` per il firewall, che è quello predefinito in Rocky Linux. L'obiettivo è quello di aprire le porte SIP al mondo e di aprire RTP (Realtime Transport Protocol) al mondo sulle porte 10000-20000, come raccomandato dalla documentazione di Asterisk.

Quasi certamente saranno necessarie altre regole del firewall per altri servizi forward-facing (HTTP/HTTPS), che probabilmente vorrete limitare ai vostri indirizzi IP. Ciò esula dallo scopo di questo documento:

```bash
sudo firewall-cmd --zone=public --add-service sip --permanent
sudo firewall-cmd --zone=public --add-port=10000-20000/udp --permanent
```

Poiché i comandi `firewalld` sono stati resi permanenti, è necessario riavviare il server. È possibile farlo con:

```bash
sudo shutdown -r now
```

## Test

### La console Asterisk

Per verificare, collegarsi alla console Asterisk:

```bash
sudo asterisk -r
```

Questo vi porterà al client a riga di comando di Asterisk. Dopo aver visualizzato le informazioni di base di Asterisk, viene visualizzato questo prompt:

```bash
asterisk*CLI>
```

Per modificare la verbosità della console, utilizzare la seguente procedura:

```bash
core set verbose 4
```

Che mostrerà quanto segue nella console di Asterisk:

```bash
Console verbose was OFF and is now 4.
```

### Mostra esempi di autenticazioni end-point

Al prompt del client a riga di comando Asterisk, digitare:

```bash
pjsip show auth 1101
```

Questo restituisce informazioni sul nome utente e sulla password che possono essere utilizzate per connettersi a qualsiasi client SIP.

## Conclusione

Quanto sopra vi consentirà di essere operativi con il server, ma sarete voi a dover completare la configurazione, collegare i dispositivi e risolvere ulteriori problemi.

La gestione di un server di comunicazione Asterisk richiede tempo e impegno e richiede la ricerca da parte di un amministratore. Per ulteriori informazioni sulla configurazione e sull'uso di Asterisk, consultare il [Wiki Asterisk qui.](https://docs.asterisk.org/Configuration/)
