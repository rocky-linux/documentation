---
title: Documentazione Locale - LXD
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6
tags:
  - contribute
  - local environment lxd
---

# Introduzione

Ci sono diversi modi per eseguire una copia di `mkdocs` per vedere esattamente come apparirà il documento Rocky Linux una volta unito sul sistema live. Questo particolare documento tratta l'uso di un container LXD sulla vostra postazione locale per separare il codice python in `mkdocs` da altri progetti su cui potreste lavorare.

Si consiglia di tenere i progetti separati per evitare di creare problemi con il codice della propria workstation.

Questo è anche un documento di accompagnamento alla versione [Docker qui](rockydocs_web_dev.md).

## Prerequisiti e presupposti

* Familiarità e comfort con la riga di comando
* Essere a proprio agio con l'uso di strumenti per l'editing, SSH e la sincronizzazione, o essere disposti a seguire e imparare
* Riferimento a LXD - c'è un lungo documento su [costruzione e utilizzo di LXD su un server qui](../../books/lxd_server/00-toc.md), ma si userà solo un'installazione di base sulla nostra workstation Linux
* Utilizzo di `lsyncd` per il mirroring dei file. Vedere [documentazione in merito qui](../backup/mirroring_lsyncd.md)
* Avrete bisogno di chiavi pubbliche generate per il vostro utente e per l'utente "root" sulla vostra postazione locale usando [questo documento](../security/ssh_public_private_keys.md)
* L'interfaccia del bridge è in esecuzione su 10.56.233.1 e il container è in esecuzione su 10.56.233.189 nei nostri esempi, tuttavia i vostri IP per il bridge e il container potrebbero essere diversi
* "youruser" in questo documento rappresenta l'id dell'utente
* Il presupposto è che si stia già sviluppando la documentazione con un clone del repository della documentazione sulla propria workstation

## Il container `mkdocs`

### Creare il container

Il primo passo è creare il contenitore LXD. L'uso delle impostazioni predefinite (interfaccia bridge) per il proprio container va benissimo.

Si aggiungerà un container Rocky alla nostra workstation per `mkdocs`. Chiamatelo semplicemente "mkdocs":

```
lxc launch images:rockylinux/8 mkdocs
```

Il container deve essere un proxy . Per impostazione predefinita, quando `mkdocs serve` si avvia, viene gestito all'indirizzo 127.0.0.1:8000. Questo va bene quando ci si trova sulla propria workstation locale senza un container. Tuttavia, quando si trova in un **container** LXD sulla workstation locale, è necessario impostare il container con una porta proxy. Eseguire questa operazione con:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

Nella riga precedente, "mkdocs" è il nome del nostro container, "mkdocsport" è un nome arbitrario che si dà alla porta proxy, il tipo è "proxy" e si è in ascolto su tutte le interfacce TCP sulla porta 8000 e ci si connette al localhost per quel container sulla porta 8000.

!!! Note "Nota"

    Se si esegue l'istanza di lxd su un'altra macchina della rete, assicurarsi che la porta 8000 sia aperta nel firewall.

### Installazione dei pacchetti

Per prima cosa, entrare nel container con:

```
lxc exec mkdocs bash
```

!!! warning "Modifiche al file requirements.txt per 8.x"

    L'attuale `requirements.txt' richiederà una versione di Python più recente di quella installata di default in Rocky Linux 8.5 o 8.6. Per poter installare tutte le altre dipendenze, procedere come segue:

    ```
    sudo dnf module enable python38
    sudo dnf install python38
    ```


    Si può quindi saltare l'installazione di `python3-pip` nei pacchetti che si trovano di seguito.

Avrete bisogno di alcuni pacchetti per fare quanto necessario:

```
dnf install git openssh-server python3-pip rsync
```

Una volta installato, è necessario abilitare e avviare `sshd`:


```
systemctl enable --now sshd
```
### Utenti del container

È necessario impostare una password per l'utente root e quindi aggiungere il nostro utente (l'utente utilizzato sulla macchina locale) all'elenco dei sudoer. In questo momento siete l'utente "root". Per modificare la password, inserire:


```
passwd
```

Impostate una password sicura e memorizzabile.

Quindi, aggiungete il vostro utente e impostate una password:

```
adduser youruser
passwd youruser
```

Aggiungete il vostro utente al gruppo sudoers:

```
usermod -aG wheel youruser
```

A questo punto, dovreste essere in grado di entrare nel container con l'utente root o con l'utente della vostra postazione di lavoro, inserendo una password. Assicuratevi di poterlo fare prima di continuare.

## SSH per root e per il vostro utente

In questa procedura, l'utente root (come minimo) deve essere in grado di entrare in SSH nel container senza inserire una password; questo a seguito del processo `lsyncd` che verrà implementato. Il presupposto è che si possa usare sudo come utente root sulla propria stazione di lavoro locale:

```
sudo -s
```

Si presuppone inoltre che l'utente root abbia una chiave `id_rsa.pub` nella directory `./ssh`. In caso contrario, generarne una con [questa procedura](.../security/ssh_public_private_keys.md):

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

Per ottenere l'accesso SSH al nostro container senza dover inserire una password, a condizione che la chiave `id_rsa.pub` esista, come sopra, basta eseguire:

```
ssh-copy-id root@10.56.233.189
```

Per il nostro utente, invece, è necessario copiare l'intera cartella `.ssh/` nel nostro container. Il motivo è che si manterrà tutto uguale per questo utente, in modo che l'accesso a GitHub tramite SSH sia lo stesso.

Per copiare tutto nel nostro container, basta farlo come utente, **non** sudo:

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Quindi, accedere al container con SSH come utente:

```
ssh -l youruser 10.56.233.189
```

È necessario che le cose siano identiche. Lo si fa con `ssh-add`. Per farlo, è necessario assicurarsi di avere a disposizione il <code>ssh-agent</code>:

```
eval "$(ssh-agent)"
ssh-add
```

## Clonare i repository

È necessario clonare due repository, ma non è necessario aggiungere alcun <code>git</code> remote. Il repository della documentazione qui visualizzerà solo la documentazione corrente ( in mirroring dalla propria postazione di lavoro) e i documenti.

Il repository rockylinux.org serve per eseguire `mkdocs serve` e userà il mirror come sorgente. Eseguite tutti questi passaggi come utente non root. Se non si riesce a clonare i repository con il proprio userid, allora **c'è** un problema con la propria identità per quanto concerne `git` e occorre rivedere gli ultimi passi per ricreare la chiave d'ambiente (sopra).

Per prima cosa, clonare la documentazione:

```
git clone git@github.com:rocky-linux/documentation.git
```

Successivamente, clonare docs.rockylinux.org:

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

Se si verificano degli errori, tornare ai passaggi precedenti e assicurarsi che siano tutti corretti prima di continuare.

## Configurazione di `mkdocs`

L'installazione dei plugin necessari si effettua con `pip3` e il file "requirements.txt" nella directory docs.rockylinux.org. Anche se questo processo contesterà l'uso dell'utente root per scrivere le modifiche alle directory di sistema, è necessario eseguirlo come root.

Lo si fa con `sudo` qui.

Entrare nella directory:

```
cd docs.rockylinux.org
```

Quindi eseguire:

```
sudo pip3 install -r requirements.txt
```

Successivamente è necessario impostare `mkdocs` con una cartella aggiuntiva.  `mkdocs` richiede la creazione di una cartella docs e di una cartella documentation/docs collegata ad essa. Eseguire questa operazione con:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### Testare `mkdocs`

Ora che avete configurato `mkdocs`, provate ad avviare il server. Ricordate che questo processo sosterrà che si tratta di una produzione. Non lo è, quindi ignorate l'avvertimento. Avviare `mkdocs serve` con:

```
mkdocs serve -a 0.0.0.0:8000
```

Nella console verrà visualizzato qualcosa di simile a questo:

```
INFO     -  Building documentation...
WARNING  -  Config value: 'dev_addr'. Warning: The use of the IP address '0.0.0.0' suggests a production environment or the use of a
            proxy to connect to the MkDocs server. However, the MkDocs' server is intended for local development purposes only. Please
            use a third party production-ready server instead.
INFO     -  Adding 'sv' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'pt' to the 'plugins.search.lang' option
WARNING  -  Language 'zh' is not supported by lunr.js, not setting it in the 'plugins.search.lang' option
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Building en documentation
INFO     -  Building de documentation
INFO     -  Building fr documentation
INFO     -  Building es documentation
INFO     -  Building it documentation
INFO     -  Building ja documentation
INFO     -  Building zh documentation
INFO     -  Building sv documentation
INFO     -  Building pt documentation
INFO     -  [14:12:56] Reloading browsers
```

Ora il momento della verità! Se avete fatto tutto correttamente, dovreste essere in grado di aprire un browser web e andare all'IP del vostro container sulla porta :8000 e vedere il sito della documentazione.

Nel nostro esempio, inserite quanto segue nell'indirizzo del browser (**NOTA** Per evitare URL non funzionanti, l'IP è stato modificato in "your-server-ip". È sufficiente sostituire l'IP):

```
http://your-server-ip:8000
```
## `lsyncd`

Se avete visto la documentazione nel browser web, ci siete quasi. L'ultimo passo consiste nel mantenere la documentazione del container sincronizzata con quella della workstation locale.

Lo si fa qui con `lsyncd` come indicato sopra.

L'installazione di`lsyncd` è diversa a seconda della versione di Linux in uso. [Questo documento](../backup/mirroring_lsyncd.md) descrive i modi per installarlo su Rocky Linux e anche dai sorgenti. Se si utilizzano altri tipi di Linux (ad esempio Ubuntu), in genere hanno i loro pacchetti, ma ci sono delle differenze.

Ubuntu, ad esempio, denomina il file di configurazione in modo diverso. Si tenga presente che se si utilizza un altro tipo di workstation Linux diverso da Rocky Linux e non si vuole installare dai sorgenti, probabilmente sono disponibili pacchetti per la propria piattaforma.

Per ora, si presume che si stia usando una workstation Rocky Linux e che si stia usando il metodo di installazione RPM del documento incluso.

### Configurazione

!!! Note "Nota"

    L'utente root deve eseguire il demone, quindi è necessario essere root per creare i file di configurazione e i registri. Per questo si presuppone `sudo -s`.

È necessario avere a disposizione dei file di registro su cui `lsyncd` possa scrivere:

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

È inoltre necessario creare un file di esclusione, anche se in questo caso non si sta escludendo nulla:

```
touch /etc/lsyncd.exclude
```

Infine, è necessario creare il file di configurazione. In questo esempio, usiamo `vi` come editor, ma potete usare qualsiasi editor con cui vi sentite a vostro agio:

```
vi /etc/lsyncd.conf
```

Quindi inserire questo contenuto nel file e salvarlo. Assicuratevi di sostituire "youruser" con il vostro attuale utente, e l'indirizzo IP con il vostro IP del container:

```
settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home/youruser/documentation",
   host="root@10.56.233.189",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home/youruser/documentation",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Supponendo di aver abilitato `lsyncd` al momento dell'installazione, a questo punto è sufficiente avviare o riavviare il processo:

```
systemctl restart lsyncd
```

Per assicurarsi che le cose funzionino, controllare i log, in particolare `lsyncd.log`, che dovrebbe mostrare qualcosa di simile se tutto è stato avviato correttamente:

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Conclusione

Ora mentre lavorate alla vostra documentazione sulla stazione di lavoro, sia che si tratti di un `git pull` o di un ramo che create per fare un documento (come questo!), vedrete le modifiche apparire nella vostra documentazione sul container, e `mkdocs serve` vi mostrerà il contenuto nel vostro browser web.

La prassi raccomandata è che tutto il Python venga eseguito separatamente da qualsiasi altro codice Python che si sta sviluppando. I container LXD possono facilitare questo compito. Provate questo metodo e vedete se funziona per voi.
