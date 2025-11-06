---
title: Metodo Incus
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6
tags:
  - contribute
  - local environment LXD
  - local environment incus
---

!!! info

    Sebbene questo metodo funzioni ancora per LXD, l'autore preferisce invece Incus. Il motivo è che, dal punto di vista dello sviluppo, Incus sembra essere più avanti rispetto a LXD, anche per quanto riguarda le immagini disponibili. Con Incus, a partire da settembre 2025, sono disponibili immagini per Rocky Linux 10 e altre immagini RHEL rebuild 10. Le immagini LXD includono attualmente solo 9 build. Ciò potrebbe essere dovuto al [cambiamento di licenza](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) annunciato dal responsabile del progetto Linux Containers, Stéphane Graber, nel dicembre 2023.
    
    Inoltre, questa procedura funziona ancora con l'attuale versione della documentazione. Se un documento viene creato o modificato su uno qualsiasi dei branch di versione (main, rocky-9 e rocky-8), il documento sincronizzato con il contenitore mostrerà il contenuto corretto. Ciò significa che è possibile continuare a utilizzare questa procedura così com'è. Sono incluse alcune note aggiuntive importanti per il controllo delle versioni.

!!! tip CONSIGLIO

    Se si utilizza Rocky Linux 10 come workstation, si deve tenere presente che, al momento della riscrittura di questo documento, `lsyncd` non è disponibile da EPEL. Dovrai utilizzare il metodo di installazione dal sorgente.

## Introduzione

Ci sono diversi modi per eseguire una copia di `mkdocs` per vedere esattamente come apparirà il documento Rocky Linux, una volta unito sul sistema live. Questo documento specifico tratta dell'utilizzo di un container `incus` sulla workstation locale per separare il codice Python in `mkdocs` dagli altri progetti su cui si sta lavorando.

Si consiglia di mantenere i progetti separati per evitare di causare problemi con il codice della workstation.

## Prerequisiti e presupposti

- Familiarità e comfort con la riga di comando
- Essere a proprio agio con l'uso di strumenti per l'editing, SSH e la sincronizzazione, o essere disposti a seguire e imparare
- Riferimento Incus - qui è disponibile un lungo documento sulla [creazione e l'utilizzo di `incus` su un server](../../../books/incus_server/00-toc.md), ma sulla nostra workstation Linux utilizzerete solo un'installazione di base
- Utilizzo di `lsyncd` per il mirroring dei file. Vedere [documentazione in merito qui](../../backup/mirroring_lsyncd.md)
- Avrete bisogno di chiavi pubbliche generate per il vostro utente e per l'utente "root" sulla vostra postazione locale usando [questo documento](../../security/ssh_public_private_keys.md)
- Nella nostra interfaccia bridge è in esecuzione su 10.56.233.1, mentre nel nostro container è in esecuzione su 10.56.233.189. Tuttavia, gli indirizzi IP del bridge e del container saranno diversi.
- "youruser" in questo documento rappresenta l'ID dell'utente
- Il presupposto è che si stia già sviluppando la documentazione con un clone del repository della documentazione sulla propria workstation

## Il container `mkdocs`

### Creare il container

Il nostro primo passo è creare il contenitore `incus`. L'uso delle impostazioni predefinite del container (interfaccia del bridge) vanno benissimo in questo caso.

Si aggiungerà un container Rocky alla nostra workstation per `mkdocs`. Chiamatelo semplicemente "mkdocs":

```bash
incus launch images:rockylinux/10 mkdocs
```

Il container deve essere un proxy. Per impostazione predefinita, quando `mkdocs serve` si avvia, viene gestito all'indirizzo 127.0.0.1:8000. Questo va bene quando ci si trova sulla propria workstation locale senza un container. Tuttavia, quando si trova in un `incus` **container** sulla workstation locale, è necessario configurare il container con una porta proxy. Eseguire questa operazione con:

```bash
incus config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

Nella riga sopra, "mkdocs" è il nome del nostro contenitore, "mkdocsport" è un nome arbitrario che stai assegnando alla porta proxy, il tipo è "proxy" e stai ascoltando su tutte le interfacce TCP sulla porta 8000 e ti stai connettendo a localhost sulla porta 8000.

!!! Note "Nota"

    Se stai eseguendo un'istanza `incus` su un altro computer della tua rete, ricordati di assicurarti che la porta 8000 sia aperta nel firewall.

### Installazione dei pacchetti

Per prima cosa, entrare nel container con:

```bash
incus shell mkdocs bash
```

Per Rocky Linux 10 si avrà bisogno di alcuni pacchetti:

```bash
dnf install git openssh-server python3-pip rsync
```

Una volta installato, è necessario abilitare e avviare `sshd`:

```bash
systemctl enable --now sshd
```

### Utenti del container

È necessario impostare una password per l'utente root, quindi aggiungere il proprio utente (quello utilizzato sul computer locale) all'elenco sudoers. Al momento siete l'utente "root". Per modificare la password, inserire:

```text
passwd
```

Impostare una password sicura e memorizzabile.

Quindi, aggiungiete il vostro utente e impostate una password:

```bash
adduser youruser
passwd youruser
```

Aggiungete il vostro utente al gruppo sudoers:

```bash
usermod -aG wheel youruser
```

Dovreste essere in grado di accedere al container con l'utente root o con l'utente della vostra workstation e di inserire una password. Assicuratevi di poterlo fare prima di continuare.

## SSH per root e per il vostro utente

In questa procedura, l'utente root (come minimo) deve essere in grado di accedere al container tramite SSH senza inserire una password. Questo è dovuto al processo `lsyncd` che si implementerà. Il presupposto è che sia possibile eseguire il comando `sudo` come utente root sulla workstation locale:

```bash
sudo -s
```

Si presume inoltre che l'utente root disponga di una chiave `id_rsa.pub` nella directory `./ssh`. In caso contrario, generarne uno con [questa procedura](../../security/ssh_public_private_keys.md):

```bash
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

Per ottenere l'accesso SSH sul nostro container senza dover inserire una password, purché esista la chiave `id_rsa.pub`, è sufficiente eseguire:

```bash
ssh-copy-id root@10.56.233.189
```

Per l'utente, tuttavia, è necessario copiare l'intera directory `.ssh/` nel container. Mantieni tutto invariato per questo utente, in modo che il vostro accesso a GitHub tramite SSH rimanga lo stesso.

Per copiare tutto nel vostro contenitore, si deve solo farlo come utente, **non** `sudo`:

```bash
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Successivamente, accedere al container tramite SSH come utente:

```bash
ssh -l youruser 10.56.233.189
```

È necessario assicurarsi che le cose siano identiche. Lo si farà con `ssh-add`. È inoltre necessario assicurarsi di avere a disposizione `ssh-agent`:

```bash
eval "$(ssh-agent)"
ssh-add
```

## Clonare i repository

È necessario clonare due repository, ma non è necessario aggiungere alcun remote `git`. Il repository della documentazione qui visualizzerà solo la documentazione corrente (copiata dalla tua workstation) e i documenti.

Il repository rockylinux.org serve per eseguire `mkdocs serve` e utilizzerà il mirror come fonte. Eseguite tutti questi passaggi come utente non root. Se non si riesce a clonare i repository con il proprio userid, allora **c'è** un problema con la propria identità per quanto concerne `git` e occorre rivedere gli ultimi passi per ricreare la chiave d'ambiente (sopra).

Per prima cosa, clonare la documentazione:

```bash
git clone git@github.com:rocky-linux/documentation.git
```

Successivamente, clonare docs.rockylinux.org:

```bash
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

Se vengono visualizzati degli errori, tornare ai passaggi precedenti e assicurarsi che siano tutti corretti prima di continuare.

## Configurazione di `mkdocs`

L'installazione dei plugin richiesti viene eseguita con `pip3` utilizzando il file "requirements.txt" nella directory docs.rockylinux.org. Sebbene questo processo ti contesterà l'uso dell'utente root per scrivere le modifiche nelle directory di sistema, dovrai comunque eseguirlo come root.

Lo si fa con `sudo` qui.

Entrare nella directory:

```bash
cd docs.rockylinux.org
```

Quindi eseguire:

```bash
sudo pip3 install -r requirements.txt
```

Successivamente è necessario impostare `mkdocs` con una cartella aggiuntiva.  `mkdocs` richiede la creazione di una directory docs e quindi della directory `documentation/docs` collegata al suo interno. Eseguire questa operazione con:

```bash
mkdir docs
cd docs
ln -s ../../documentation/docs
```

### Testare `mkdocs`

Ora che avete configurato `mkdocs`, provate ad avviare il server. Ricordate che questo processo sosterrà che si tratta di una produzione. Non lo è, quindi ignorate l'avvertimento. Avviare `mkdocs serve` con:

```bash
mkdocs serve -a 0.0.0.0:8000
```

Nella console verrà visualizzato questo o qualcosa di simile:

```bash
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

Se avete fatto tutto correttamente, dovreste essere in grado di aprire un browser web e andare all'IP del vostro container sulla porta :8000 e vedere il sito della documentazione.

Nel nostro esempio, inserite quanto segue nell'indirizzo del browser (**NOTA** Per evitare URL non funzionanti, l'IP qui è "your-server-ip". È sufficiente sostituire l'IP):

```bash
http://your-server-ip:8000
```

## `lsyncd`

Se avete visualizzato la documentazione nel browser web, ci siete quasi. L'ultimo passo consiste nel mantenere la documentazione nel contenitore sincronizzata con quella presente sulla workstation locale.

Come già detto, qui lo state facendo con `lsyncd`.

L'installazione di `lsyncd` varia a seconda della versione di Linux in uso. [Questo documento](../../backup/mirroring_lsyncd.md) illustra le modalità di installazione su Rocky Linux con un RPM da EPEL (Extra Packages for Enterprise Linux) e dal sorgente. Se si utilizzano altri tipi di Linux (ad esempio Ubuntu), questi hanno generalmente i propri pacchetti, ma con alcune sfumature.

Ubuntu, ad esempio, denomina il file di configurazione in modo diverso. Si tenga presente che se si utilizza un altro tipo di workstation Linux diverso da Rocky Linux e non si vuole installare dai sorgenti, probabilmente sono disponibili pacchetti per la propria piattaforma.

Per ora, supponiamo che si stia utilizzando una workstation Rocky Linux e il metodo di installazione RPM descritto nel documento allegato.

!!! note NOTA

    Al momento della stesura di questo articolo, `lsyncd` non è disponibile su EPEL per Rocky Linux 10. Se questa è la versione della vostra workstation, si dovrà utilizzare il metodo di installazione da sorgente.

### Configurazione

!!! Note "Nota"

    L'utente root deve eseguire il demone, quindi è necessario essere root per creare i file di configurazione e i log. Per questo, stiamo supponendo `sudo -s.

È necessario disporre di alcuni log su cui `lsyncd` possa scrivere:

```bash
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

È inoltre necessario creare un file di esclusione, anche se in questo caso non si sta escludendo nulla:

```bash
touch /etc/lsyncd.exclude
```

Infine, è necessario creare il file di configurazione. In questo esempio, usiamo `vi` come editor, ma potete usare qualsiasi editor con cui vi sentite a vostro agio:

```bash
vi /etc/lsyncd.conf
```

Quindi inserire questo contenuto nel file e salvarlo. Assicuratevi di sostituire "youruser" con il vostro attuale utente, e l'indirizzo IP con il vostro IP del container:

```bash
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

```bash
systemctl restart lsyncd
```

Per assicurarsi che tutto funzioni correttamente, controllare i log, in particolare il file `lsyncd.log`, che dovrebbe mostrare un contenuto simile al seguente se tutto è stato avviato correttamente:

```bash
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Note sulla Versione

È necessario un clone del repository della documentazione da [Repository della documentazione di Rocky Linux](https://github.com/rocky-linux/documentation). Questo aspetto è importante, perché se invece si è clonato un fork del repository, non si potrà eseguire il comando `git checkout` sui rami `rocky-8` e `rocky-9`. Sarà disponibile solo il ramo `main`.

### Configurazione della workstation GitHub

Questi passaggi non riguardano il vostro container, ma la copia della documentazione presente sulla vostra workstation:

1. Clonare il repository della documentazione di Rocky Linux:

    ```bash
    git clone git@github.com:rocky-linux/documentation.git
    ```

2. Il nome `git remote` sarà “upstream” anziché “origin”. Controllare il nome del remote con:

    ```bash
    git remote -v
    ```

    Subito dopo la clonazione, verrà visualizzato quanto segue:

    ```bash
    origin git@github.com:rocky-linux/documentation.git (fetch)
    origin git@github.com:rocky-linux/documentation.git (push)
    ```

    Rinominare il telecomando con:

    ```bash
    git remote rename origin upstream
    ```

    Eseguire nuovamente `git remote -v` e si vedrà:

    ```bash
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

3. Aggiungere il fork come remoto con il nome “origin”. Sostituire con il vostro nome utente effettivo in GitHub:

    ```bash
    git remote add origin git@github.com:[your-github-user-name]/documentation.git
    ```

    Eseguire nuovamente `git remote -v` e si vedrà:

    ```bash
    origin git@github.com:[your-github-user-name]/documentation.git (fetch)
    origin git@github.com:[your-github-user-name]/documentation.git (push)
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

4. È necessario popolare il fork con i branch di versione (diversi da `main`). Il branch `main` contiene attualmente le informazioni relative alla versione 10. Si vuole popolare il fork con i branch `rocky-8` e `rocky-9` in modo da essere pronti a modificare i documenti in quelle precedenti versioni. Il primo passo è eseguire il comando `git checkout` per questi branch name:

    ```bash
    git checkout rocky-8
    ```

    La prima volta che lo si fa, si vedrà:

    ```bash
    branch 'rocky-8' set up to track 'upstream/rocky-8'.
    Switched to a new branch 'rocky-8'
    ```

    Successivamente, fare il push del branch al fork:

    ```bash
    git push origin rocky-8
    ```

    Questo agisce come se stesse creando una nuova richiesta pull, ma quando si controlla il contenuto del branch fork, si vedrà che `rocky-8` è ora uno dei branch.

    Ripetere i medesimi passaggi con il ramo `rocky-9`.

### Come ciò si applica a questa procedura

Una volta creati i branch, se si desidera modificare il file `README.md` solo per `rocky-9`, si deve creare un nuovo branch basato sul branch della versione `rocky-9`:

```bash
git checkout -b fixes_for_rocky9_readme rocky-9
```

Quindi modificare il documento normalmente. Quando si salva il lavoro, il container documenti verrà aggiornato e, eseguendo `mkdocs serve` come descritto in questo documento, verrà visualizzato tale contenuto.

Una volta terminato e inviati i cambiamenti al fork per creare una richiesta pull, si può controllare di nuovo il branch `main`. Poiché tutto il lavoro era all'interno del ramo rocky-9 sottoposto a check-out, la documentazione sincronizzata nel container torna allo stato precedente all'avvio del processo. In questo modo, si potrà sempre tenere traccia del lavoro indipendentemente dalla versione con cui si sta lavorando. Il container rimarrà sincronizzato con il contenuto della workstation locale.

## Conclusione

E' possibile lavorare sulla documentazione della vostra workstation mentre si visualizza le modifiche nella copia sincronizzata nel vostro contenitore. La prassi raccomandata è che tutto il Python venga eseguito separatamente da qualsiasi altro codice Python che si sta sviluppando. L'uso dei container `incus` semplifica questa operazione.
