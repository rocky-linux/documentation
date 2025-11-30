---
author: Wale Soyinka
title: 'Lab 6: Gestione Utenti e Gruppi'
contributors: Steven Spencer, Ganna Zhyrnova, Franco Colussi
tested on: Tutte le versioni
tags:
  - introduction system administration
  - lab exercise
  - users
  - groups
---

## Obiettivi

Dopo aver completato questo laboratorio, si sarà in grado di:

- Aggiungere e rimuovere utenti dal sistema
- Aggiungere e rimuovere gruppi dal sistema
- Modificare utenti e gruppi sul sistema
- Cambiare la password

Tempo stimato per terminare il laboratorio: 40 minuti

## Account utente

La gestione degli utenti è importante in qualsiasi sistema operativo di rete multiutente. Linux è un sistema operativo di rete multiutente. Senza gli utenti, non ci sarebbe bisogno di un sistema operativo di rete multiutente!

La gestione degli utenti su un sistema è strettamente legata alla sicurezza del sistema stesso. C'è un vecchio proverbio che dice:

> Un sistema è tanto sicuro quanto il suo utente più debole.

Linux eredita la vecchia tradizione UNIX di governare l'accesso a file, programmi e altre risorse in base ad utente e gruppi.

Proprio come tutte le altre configurazioni in Linux, la gestione degli utenti può essere effettuata modificando i file di configurazione che possono essere trovati nella gerarchia del file system. Questo laboratorio esplorerà la gestione degli utenti attraverso il metodo manuale e anche con l'uso delle utility di sistema.

Esamineremo anche in breve la proprietà e i permessi dei file.

Di seguito i file importanti per la gestione di utenti e gruppi. Vengono discussi anche alcuni campi o voci dei file.

### `/etc/passwd`

- **Scopo:** informazioni sull'account utente
- **Contenuto:**
    - username
    - password criptata
    - id utente (UID)
    - id del gruppo (GID)
    - nome completo dell'utente
    - home directory dell'utente
    - shell di default

### `/etc/shadow`

- **Scopo:** proteggere le informazioni dell'account utente
- **Contenuto:**
    - nome di login
    - hash della password
    - numero di giorni relativi all'ultimo cambio password, a partire dal 01/01/1970
    - giorni prima dei quali la password non può essere modificata. Generalmente è pari a zero.
    - numero di giorni dopo i quali la password deve essere cambiata
    - numero di giorni antecedenti alla scadenza della password in cui l'utente viene avvertito che la password sta per scadere
    - numero di giorni successivi alla scadenza della password, in cui l'account è considerato inattivo e disabilitato
    - giorni a partire dal 1/01/1970 di quando l'account sarà disabilitato
    - riservato

### `/etc/group`

- **Scopo:** informazioni sui gruppi
- **Contenuto:**
    - nome del gruppo
    - password del gruppo
    - id del gruppo (GID)
    - elenco degli utenti appartenenti al gruppo

### `/etc/skel`

- **Scopo:** contiene dei template da applicare ai nuovi account

## Utilità comuni

Di seguito sono elencate alcune utilità comunemente utilizzate nelle attività quotidiane di gestione degli utenti e dei gruppi:

### `useradd`

- Il comando `useradd` è uno strumento di gestione degli utenti che consente agli amministratori di sistema di creare nuovi account utente direttamente dalla riga di comando.

    ```bash
    Usage: useradd [options] LOGIN
        useradd -D
        useradd -D [options]

    Options:
        --badname                 do not check for bad names
        -b, --base-dir BASE_DIR       base directory for the home directory of the new account
            --btrfs-subvolume-home    use BTRFS subvolume for home directory
        -c, --comment COMMENT         GECOS field of the new account
        -d, --home-dir HOME_DIR       home directory of the new account
        -D, --defaults                print or change default useradd configuration
        -e, --expiredate EXPIRE_DATE  expiration date of the new account
        -g, --gid GROUP               name or ID of the primary group of the new account
        -G, --groups GROUPS           list of supplementary groups of the new account
        -h, --help                    display this help message and exit
        -k, --skel SKEL_DIR           use this alternative skeleton directory
        -K, --key KEY=VALUE           override /etc/login.defs defaults
        -l, --no-log-init             do not add the user to the lastlog and faillog databases
        -m, --create-home             create the user's home directory
        -M, --no-create-home          do not create the user's home directory
        -N, --no-user-group           do not create a group with the same name as the user
        -o, --non-unique              allow to create users with duplicate (non-unique) UID
        -p, --password PASSWORD       encrypted password of the new account
        -r, --system                  create a system account
        -R, --root CHROOT_DIR         directory to chroot into
        -P, --prefix PREFIX_DIR       prefix directory where are located the /etc/* files
        -s, --shell SHELL             login shell of the new account
        -u, --uid UID                 user ID of the new account
        -U, --user-group              create a group with the same name as the user
        -Z, --selinux-user SEUSER     use a specific SEUSER for the SELinux user mapping
    ```

### `groupadd`

- Il comando `groupadd` è un'utilità per la gestione dei gruppi di utenti sul sistema. Disponibile nella maggior parte delle distribuzioni Linux, questo comando consente agli amministratori di creare nuovi gruppi, specificando opzioni quali il GID (Group ID), il nome del gruppo e altre proprietà.

    ```bash
    Usage: groupadd [options] GROUP

    Options:
        -f, --force                   exit successfully if the group already exists, and cancel -g if the GID is already used
        -g, --gid GID                 use GID for the new group
        -h, --help                    display this help message and exit
        -K, --key KEY=VALUE           override /etc/login.defs defaults
        -o, --non-unique              allow to create groups with duplicate (non-unique) GID
        -p, --password PASSWORD       use this encrypted password for the new group
        -r, --system                  create a system account
        -R, --root CHROOT_DIR         directory to chroot into
        -P, --prefix PREFIX_DIR        directory prefix
        -U, --users USERS             list of user members of this group
    ```

### `passwd`

- Il comando `passwd` è uno strumento per la gestione delle password degli utenti. Consente agli utenti di modificare le proprie password, mentre gli amministratori (root) possono reimpostare le password di altri account, gestire la scadenza delle password e configurare le politiche di sicurezza.

    ```bash
    Usage: passwd [OPTION...] <accountName>

    Options:
        -k, --keep-tokens       keep non-expired authentication tokens
        -d, --delete            delete the password for the named account (root only); also removes password lock if any
        -l, --lock              lock the password for the named account (root only)
        -u, --unlock            unlock the password for the named account (root only)
        -e, --expire            expire the password for the named account (root only)
        -f, --force             force operation
        -x, --maximum=DAYS      maximum password lifetime (root only)
        -n, --minimum=DAYS      minimum password lifetime (root only)
        -w, --warning=DAYS      number of days warning users receives before password expiration (root only)
        -i, --inactive=DAYS     number of days after password expiration when an account becomes disabled (root only)
        -S, --status            report password status on the named account (root only)
            --stdin             read new tokens from stdin (root only)

    Help options:
        -?, --help          Show this help message
        --usage             Display brief usage message
    ```

## Esercizi

### 1. Creare manualmente un nuovo utente

Finora, durante i laboratori precedenti, si è utilizzato il sistema come utente con i privilegi più elevati, ovvero l'utente **root**. Questa non è una buona pratica in un sistema di produzione perché rende il sistema vulnerabile dal punto di vista della sicurezza. L'utente root può causare danni illimitati al sistema, sia in modo permanente che temporaneo.

Ad eccezione del superutente, tutti gli altri utenti hanno un accesso limitato ai file e alle directory. Utilizzare sempre il computer come un utente normale. Due concetti confusi saranno chiariti qui.

- In primo luogo, la directory home dell'utente root è  `/root`.
- In secondo luogo, la directory principale è la directory più alta, nota come directory `/`  (barra). (`/root` è diverso da  `/` “)

In questo laboratorio si creerà un nuovo utente chiamato "Me Mao". Il nome utente per "Me Mao" sarà il nome proprio - “**me**”. Questo nuovo utente apparterrà al gruppo “**me**”. La password sarà “**a1b2c3**”

!!! warning "Attenzione"

    Le configurazioni di sistema sono solitamente conformi a un formato specifico. È sempre importante attenersi a questo formato quando si modificano manualmente i file di configurazione. Un modo per farlo è trovare e copiare una voce esistente nel file, quindi modificare la riga/sezione copiata con le nuove modifiche. Questo aiuterà a ridurre le possibilità di commettere errori.

1. Log in nel computer come root

2. Utilizzare il comando `tail` per visualizzare le ultime 4 voci nella parte inferiore del file `/etc/passwd`.

    ```bash
    [root@localhost root]# tail -n 4 /etc/passwd
    apache:x:48:48:Apache:/var/www:/sbin/nologin
    xfs:x:43:43:X Font Server:/etc/X11/fs:/sbin/nologin
    ntp:x:38:38::/etc/ntp:/sbin/nologin
    gdm:x:42:42::/var/gdm:/sbin/nologin    
    ```

Modificare il file *passwd* utilizzando il formato sopra riportato.

#### Creare l'utente

1. Sarà necessario modificare il file `/etc/passwd`.

    Avviare l'editor preferito e aprire il file `/etc/passwd`

    Aggiungere il testo sottostante alla fine del file:

    ```bash
    me:x:500:500:me mao:/home/me:/bin/bash    
    ```

2. Salvare le modifiche e chiudere il file passwd.

3. Successivamente modificheremo il file `/etc/shadow`.  
   Avviare l'editor e aprire il file `/etc/shadow`.  
   Aggiungere una nuova voce come quella riportata di seguito alla fine del file, inserendo un asterisco  (*) nel campo della password. Digitare:

    ```bash
    me:x:11898:11898:99999:7
:::   
    ```

4. Salvare le modifiche e chiudere il file shadow.

5. Modificare ora il file `/etc/group`. Avviare l'editor e aprire il file `/etc/group`. Alla fine del file aggiungere una nuova voce:

    ```bash
    me:x:1000:me
    ```

6. Salvare le modifiche e chiudere il *file group*.

7. È ora di creare la directory home.

    Copiare l'intero contenuto della directory `/etc/skel` nella directory `/home`, rinominando la nuova directory con il nome dell'utente, ovvero `/home/me`. Digitare:

    ```bash
    [root@localhost root]# cp -r /etc/skel /home/me
    ```

8. L'utente root è il proprietario della directory che hai appena creato, perché è stato lui a crearla. Affinché l'utente "me mao" possa utilizzare la directory, si dovranno modificare i permessi/proprietà della cartella. Digitare:

    ```bash
    [root@localhost root]# chown -R me:me /home/me
    ```

9. Creare una password per l'utente. Impostare il valore della password su **a!b!c!d!**. Si utilizzerà l'utility `passwd`. Digitare “**passwd me**” e seguire le istruzioni

    ```bash
    [root@localhost root]# passwd me
    Changing password for user me.
        New password:
        Retype new password:
        passwd: all authentication tokens updated successfully.
    ```

10. Uscire dal sistema una volta finito.

### 2. Creazione automatica di un nuovo utente

Esistono numerose utility disponibili per semplificare tutte le attività/passaggi che abbiamo eseguito manualmente nell'esercizio precedente. Abbiamo approfondito soltanto il procedimento manuale di creazione di un utente, così che tu possa vedere ciò che realmente avviene in background.

In questo esercizio verranno utilizzate alcune utility comuni per gestire e semplificare il processo. Creerai un altro account utente per l'utente “**Ying Yang**” con nome di accesso **ying**.  
La password per **ying** sarà **y@i@n@g@**.  
Creerai anche un gruppo chiamato “**common**” e aggiungerai gli utenti **me** e **ying** al gruppo.

#### Creare automaticamente un nuovo account

1. Accedere al sistema come root.

2. Creare l'utente **ying** utilizzando tutte le impostazioni predefinite del comando `useradd`. Digitare:

    ```bash
    [root@localhost root]# useradd -c "Ying Yang" ying
    ```

3. Utilizzare il comando `tail` per esaminare l'inserimento appena effettuato al file `/etc/passwd`. Digitare:

    ```bash
    flatpak:x:982:982:User for flatpak system helper:/:/sbin/nologin
    pesign:x:981:981:Group for the pesign signing daemon:/run/pesign:/sbin/nologin
    me:x:1000:1000:99999:7
:::
    ying:x:1001:1001:Ying Yang:/home/ying:/bin/bash
    ```

    !!! question "Domanda"

     Elencare qui la nuova voce?

4. L'utente **ying**  non potrà accedere al sistema finché non sarà stata creata una password per l'utente. Impostare la password di Ying su **y@i@n@g@**. Digitare:

    ```bash
    [root@localhost root]# passwd ying
    Changing password for user ying.
        New password:   **********
        Retype new password: **********
        passwd: all authentication tokens updated successfully.
    ```

5. Utilizzare l'utilità `id` per visualizzare rapidamente le informazioni relative ai nuovi utenti appena creati. Digitare:

    ```bash
    [root@localhost root]# id me
        uid=1000(me) gid=1000(me) groups=1000(me)
    ```

6. Fare la stessa cosa per l'utente **ying**. Digitare:

    ```bash
    [root@localhost root]# id ying
        uid=501(ying) gid=501(ying) groups=501(ying)
    ```

#### Creazione automatica di un nuovo gruppo

1. Utilizzare il programma `groupadd` per creare il nuovo gruppo **common**.

    ```bash
    [root@localhost root]# groupadd common
    ```

2. Esaminare la parte finale del file `/etc/group` per vedere il nuovo inserimento.

    !!! question "Domanda"
   
        Qual è il comando per farlo?

3. Utilizzare il comando `usermod` per aggiungere un utente esistente a un gruppo esistente. Si aggiunge l'utente **ying** al gruppo **common** appena creato nel passaggio 1. Digitare:

    ```bash
    [root@localhost root]# usermod -G common -a ying
    ```

4. Fare le stessa cosa per l'utente **me**. Digitare:

    ```bash
    [root@localhost root]# usermod -G common -a me
    ```

5. Eseguire nuovamente il comando `id` sugli utenti **ying** e **me**.

    !!! question "Domanda"
   
        Cosa è cambiato?

6. Utilizzare il comando `grep` per visualizzare le modifiche apportate alla voce del gruppo **common** nel file. Digitare:

    ```bash
    [root@localhost root]# grep common /etc/group
        common:x:1002:ying,me
    ```

#### Modifica del profilo di un utente

1. Utilizzare il comando `usermod` per modificare il campo commento dell'utente **me**. Il nuovo commento che si aggiungerà sarà “`first last`”. Digitare:

    ```bash
    [root@localhost root]# usermod -c "first last" me
    ```

    Utilizzare il comando `tail` per esaminare le modifiche apportate al file `/etc/passwd`.

    !!! question "Domanda"

     Scrivi la riga modificata qui sotto.

    !!! question "Domanda"

     Qual è la shell di login dell'utente me?

2. Utilizzare nuovamente il comando `usermod` per modificare la shell di login di **me** in shell `csh` . Digitare:

    ```bash
    [root@localhost root]# usermod -s /bin/csh me
    ```

3. Infine, utilizzare il comando `usermod` per annullare tutte le modifiche apportate all'utente "me" sopra.

    Ripristina i valori (shell di login ecc.) ai valori originali.

    !!! question "Domanda"
   
        Quali sono i comandi per farlo?

### 3. Impostazione utente

Non sempre è conveniente uscire completamente dal sistema per accedere con un altro utente. Questo potrebbe essere dovuto al fatto che sono in esecuzione determinate attività che non si desidera terminare. Il programma `su` (*set user*) viene utilizzato per diventare temporaneamente un altro utente. È possibile passare da un account utente normale all'account root o viceversa utilizzando il comando "su".

Cambia l'utente corrente in modo che abbia i diritti di accesso dell'utente temporaneo.

Le variabili di ambiente *HOME*, *LOGNAME* e *USER* saranno impostate di default su quelle dell'utente temporaneo.

#### Per diventare temporaneamente un altro utente

1. Dopo aver effettuato l'accesso come utente root, passare all'utente "me". Digitare:

    ```bash
    [root@localhost root]# su me
    [me@localhost root]$
    ```

    Il comando `su` non ha richiesto la password dell'utente **me** perché siete root

2. Passare alla directory home di **me**.

    ```bash
    [me@localhost root]$ cd
    [me@localhost me]$ cd
    ```

3. Mentre si è temporaneamente connessi come **me**, usare `su` per effettuare il login come utente **ying**. Digitare:

    ```bash
    [me@localhost me]$ su  ying
    password:
    [ying@localhost me]$
    ```

4. Per uscire dall'account di **ying**, digitare:

    ```bash
    [ying@localhost me]$ exit
    ```

    Questo vi riporterà all'account **me**.

5. Uscire dall'account di **me** per tornare all'account root.

    !!! question "Domanda"
   
        Qual è il comando?

#### Ereditare tutte le variabili ambientali del nuovo utente con `su`

1. Per forzare `su` a utilizzare tutte le variabili ambientali dell'utente temporaneo. Digitare:

    ```bash
    [root@system1 root]# su - me
    [me@system1 me]$
    ```

    La differenza è immediatamente evidente. Notare la *directory di lavoro* corrente.

2. Uscire completamente dal sistema e riavviare il computer.

3. Tutto fatto con Lab 6!
