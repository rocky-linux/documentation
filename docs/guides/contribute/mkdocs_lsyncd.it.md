---
title: Documentazione Locale - LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6
tags:
  - contribute
  - local envirmonent lxd
---

# Introduzione

Ci sono diversi modi per eseguire una copia di `mkdocs` in modo da poter vedere esattamente come apparirà il vostro documento Rocky Linux quando sarà incorporato nel sistema live. Questo particolare documento tratta l'uso di un container LXD sulla vostra postazione locale per separare il codice python in `mkdocs` da altri progetti su cui potreste lavorare.

È consigliabile mantenere i progetti separati per evitare di causare problemi con il codice della vostra stazione di lavoro.

Questo è anche un documento partner della versione Docker [qui](rockydocs_web_dev.md).

## Prerequisiti e presupposti

Alcune cose che dovresti avere/conoscere/essere:

* Familiarità e comfort con la riga di comando
* Essere a proprio agio con l'uso di strumenti per l'editing, SSH e la sincronizzazione, o essere disposti a seguire e imparare
* Faremo riferimento a LXD - c'è un lungo documento su [costruzione e utilizzo di LXD su un server qui](../../books/lxd_server/00-toc.md), ma noi useremo solo un'installazione di base sulla nostra workstation Linux. Questo documento presuppone che stiate già usando LXD per altre cose, e non copre la costruzione e l'inizializzazione di LXD.
* Useremo `lsyncd` per il mirroring dei file, e puoi trovare la documentazione a riguardo [qui](../backup/mirroring_lsyncd.md)
* Avrete bisogno di chiavi pubbliche generate per il vostro utente e per l'utente "root" sulla vostra postazione locale usando [questo documento](../security/ssh_public_private_keys.md)
* La nostra interfaccia bridge è in esecuzione su 10.56.233.1 e il nostro container è in esecuzione nei nostri esempi qui sotto su 10.56.233.189.
* "youruser" in questo documento rappresenta il tuo id utente, quindi sostituiscilo con il tuo.
* Diamo per scontato che tu stia già sviluppando la documentazione con un clone del repository della documentazione sulla tua stazione di lavoro.

## Il container mkdocs

### Creare il Container

Il nostro primo passo è creare il container LXD. Non c'è bisogno di usare qualcosa di diverso dai valori predefiniti qui, quindi lasciate che il vostro container sia costruito usando l'interfaccia bridge.

Aggiungeremo un container Rocky alla nostra stazione di lavoro per `mkdocs`, quindi lo chiameremo semplicemente "mkdocs":

```
lxc launch images:rockylinux/8 mkdocs
```

Il container deve essere impostato con un proxy. Per impostazione predefinita, quando `mkdocs serve` viene avviato, viene eseguito su 127.0.0.1:8000. Questo va bene quando è sulla vostra stazione di lavoro locale senza un container. Tuttavia, quando è in un **container** LXD sulla vostra postazione locale, dovete impostare il container con una porta proxy. Questo viene fatto con:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

Nella riga sopra, "mkdocs" è il nome del nostro contenitore, "mkdocsport" è un nome arbitrario che stiamo dando alla porta proxy, il tipo è "proxy", e poi siamo in ascolto su tutte le interfacce tcp sulla porta 8000 e ci stiamo connettendo al localhost per quel container sulla porta 8000.

!!! Note "Nota"

    Se stai eseguendo l'istanza di lxd su un'altra macchina nella tua rete, ricordati di assicurarti che la porta 8000 sia aperta nel firewall.

### Installazione dei pacchetti

In primo luogo, entrare nel container con:

```
lxc exec mkdocs bash
```

!!! warning "Cambiamenti nel requirements.txt per 8.x"

    L'attuale `requirements.txt' richiederà una versione di Python più recente di quella installata di default in Rocky Linux 8.5 o 8.6. Per poter installare tutte le altre dipendenze, procedere come segue:

    ```
    sudo dnf module enable python38
    sudo dnf install python38
    ```


    Si può quindi saltare l'installazione di `python3-pip` nei pacchetti che si trovano di seguito.

Avremo bisogno di alcuni pacchetti per realizzare ciò che dobbiamo fare:

```
dnf install git openssh-server python3-pip rsync
```

Una volta installato, dobbiamo abilitare e avviare `sshd`:

```
systemctl enable --now sshd
```
### Utenti del container

Dobbiamo impostare una password per il nostro utente root, e poi aggiungere il nostro utente (l'utente che usate sulla vostra macchina locale) e aggiungerlo alla lista sudoers. Dovremmo essere l'utente "root" al momento, quindi per cambiare la password digitate:

```
passwd
```

E imposta la password su qualcosa di sicuro e memorizzabile.

Poi, aggiungi il tuo utente e imposta una password:

```
adduser youruser
passwd youruser
```

E aggiungete il vostro utente al gruppo sudoers:

```
usermod -aG wheel youruser
```

A questo punto, dovresti essere in grado di fare SSH nel container usando l'utente root o il tuo utente dalla tua stazione di lavoro e inserendo una password. Assicuratevi di poterlo fare prima di continuare.

## SSH per root e il Tuo utente

In questa procedura, l'utente root (come minimo) deve essere in grado di fare SSH nel container senza inserire una password; questo a causa del processo `lsyncd` che implementeremo. Stiamo assumendo qui che potete fare sudo all'utente root sulla vostra stazione di lavoro locale:

```
sudo -s
```

Stiamo anche assumendo che l'utente root abbia una chiave `id_rsa.pub` nella directory `./ssh`. In caso contrario, generatene una usando [questa procedura](../security/ssh_public_private_keys.md):

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

Per ottenere l'accesso SSH sul nostro container senza dover inserire una password, finché la chiave `id_rsa.pub` esiste, come sopra, tutto quello che dobbiamo fare è eseguire:

```
ssh-copy-id root@10.56.233.189
```

Nel caso del nostro utente, però, abbiamo bisogno dell'intera directory .ssh/ copiata nel nostro container. La ragione è che manterremo tutto identico per questo utente in modo che il nostro accesso a GitHub su SSH sia lo stesso.

Per copiare tutto nel nostro container, abbiamo solo bisogno di farlo come utente, **non** sudo:

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Successivamente, SSH nel container come tuo utente:

```
ssh -l youruser 10.56.233.189
```

Dobbiamo rendere le cose identiche, e questo viene fatto con `ssh-add`. Per fare questo, però, dobbiamo assicurarci di avere il `ssh-agent` disponibile. Inserire quanto segue:

```
eval "$(ssh-agent)"
ssh-add
```

## Clonare i repository

Abbiamo bisogno di due repository clonati, ma non c'è bisogno di aggiungere alcun `git` remoto. Il repository della documentazione qui sarà utilizzato solo per visualizzare la documentazione corrente (replicata sulla tua stazione di lavoro) e i documenti.

Il repository di rockylinux.org sarà usato per eseguire `mkdocs serve` e userà il mirror come sorgente. Tutti questi passaggi dovrebbero essere fatti come utente non root. Se non sei in grado di clonare i repository con il tuo userid, significa che **Hai** un problema con la tua identità per quanto riguarda `git` e dovrai rivedere gli ultimi passi per ricreare le tue chiavi dell'ambiente (sopra).

Per prima cosa, clonate la documentazione:

```
git clone git@github.com:rocky-linux/documentation.git
```

Supponendo che questo abbia funzionato, allora clonate il docs.rockylinux.org:

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

Se tutto ha funzionato come previsto, allora si può andare avanti.

## Impostare mkdocs

L'installazione dei plugin necessari viene fatta con `pip3` e il file "requirements.txt" nella directory docs.rockylinux.org. Mentre questo processo chiederà di usare l'utente root per farlo, al fine di scrivere le modifiche alle directory di sistema, dovrete praticamente eseguirlo come root.

Qui lo stiamo facendo con `sudo`.

Entrare nella directory:

```
cd docs.rockylinux.org
```

Quindi eseguire:

```
sudo pip3 install -r requirements.txt
```

Poi abbiamo bisogno di impostare `mkdocs` con una directory aggiuntiva. Al momento, `mkdocs` richiede la creazione di una directory docs e poi la directory documentation/docs collegata sotto di essa. Tutto questo viene fatto con:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### Testare mkdocs

Ora che abbiamo `mkdocs` impostato, proviamo ad avviare il server. Ricordate, questo processo sosterrà che sembra che si tratti di produzione. Non lo è, quindi ignorate l'avvertimento. Avviare `mkdocs serve` con:

```
mkdocs serve -a 0.0.0.0:8000
```

Dovreste vedere qualcosa di simile a questo nella console:

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

E ora il momento della verità!  Se avete fatto tutto correttamente sopra, dovreste essere in grado di aprire un browser web e andare all'IP del vostro container sulla porta :8000, e vedere il sito della documentazione.

Nel nostro esempio, inseriamo quanto segue nell'indirizzo del browser (**NOTA** Per evitare URL interrotti, l'IP è stato modificato in "your-server-ip". È sufficiente sostituire l'IP):

```
http://your-server-ip:8000
```
## lsyncd

Se avete visto la documentazione nel browser web, ci siamo quasi. L'ultimo passo è quello di mantenere la documentazione che è nel vostro container in sincronia con quella sulla vostra stazione di lavoro locale.

Lo stiamo facendo qui con `lsyncd` come indicato sopra.

A seconda della versione di Linux che state usando, `lsyncd` è installato in modo diverso. [Questo documento](../backup/mirroring_lsyncd.md) copre i modi per installarlo su Rocky Linux, e anche da sorgente. Se state usando qualche altro tipo di Linux (Ubuntu per esempio) generalmente hanno i loro propri pacchetti, ma ci sono delle sfumature.

Ubuntu, per esempio, nomina il file di configurazione in modo diverso. Siate solo consapevoli che se state usando un altro tipo di workstation Linux diverso da Rocky Linux, e non volete installare dai sorgenti, probabilmente ci sono pacchetti disponibili per la vostra piattaforma.

Per ora, assumiamo che stiate usando una workstation Rocky Linux e che stiate usando il metodo di installazione RPM dal documento incluso.

### Configurazione

!!! Note "Nota"
    L'utente root deve eseguire il demone, quindi è necessario essere root per creare i file di configurazione e i log. Per questo stiamo impiegando `sudo -s`.

Abbiamo bisogno di avere dei file di log disponibili per `lsyncd` per scriverci:

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

Dobbiamo anche creare un file di esclusione, anche se in questo caso non stiamo escludendo nulla:

```
touch /etc/lsyncd.exclude
```

Infine dobbiamo creare il file di configurazione. In questo esempio, stiamo usando `vi` come editor, ma potete usare qualsiasi editor con cui vi sentite a vostro agio:

```
vi /etc/lsyncd.conf
```

E poi mettete questo contenuto in quel file e salvatelo. Assicuratevi di sostituire "youruser" con il vostro attuale utente, e l'indirizzo IP con il vostro IP del container:

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

Presumiamo che abbiate abilitato `lsyncd` quando lo avete installato, quindi a questo punto dobbiamo solo avviare o riavviare il processo:

```
systemctl restart lsyncd
```

Per assicurarsi che le cose stiano funzionando, controllate i log, in particolare il `lsyncd.log`, che dovrebbe mostrarvi qualcosa del genere se tutto è stato avviato correttamente:

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Conclusione

Ora mentre lavorate alla vostra documentazione sulla stazione di lavoro, sia che si tratti di un `git pull` o di un ramo che create per fare un documento (come questo!), vedrete le modifiche apparire nella vostra documentazione sul container, e `mkdocs serve` vi mostrerà il contenuto nel vostro browser web.

È una pratica consigliata che tutto il codice Python venga eseguito separatamente da qualsiasi altro codice Python che si potrebbe sviluppare. I container LXD possono renderlo molto più facile; provate questo metodo e vedete se funziona per voi.
