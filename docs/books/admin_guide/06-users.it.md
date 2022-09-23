---
title: Gestione utenti
---

# Gestione utenti

In questo capitolo imparerai come gestire l'utente.

****
**Obiettivi** : In questo capitolo, futuri amministratori Linux impareranno come:

:heavy_check_mark: aggiungere, eliminare o modificare un **gruppo**;  
:heavy_check_mark: aggiungere, eliminare o modificare un **utente**;  
:heavy_check_mark: conoscere la sintassi dei file associati alla gestione di gruppi e utenti;  
:heavy_check_mark: cambiare il *proprietario* o il *proprietario del gruppo* di un file;  
:heavy_check_mark: *assicurare* i profili utente;  
:heavy_check_mark: cambiare identità.

:checkered_flag: **utenti**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 30 minuti
****

## Generale

Ogni utente è membro di almeno un gruppo: **questo è il loro gruppo principale**.

Diversi utenti possono far parte dello stesso gruppo.

Un gruppo diverso dal gruppo primario è chiamato **gruppi supplementari dell'utente**.

!!! Note "Nota"

    Ogni utente ha un gruppo primario e può essere invitato in uno o più gruppi secondari.

I gruppi e gli utenti sono gestiti dai loro identificatori numerici unici `GID` e `UID`.

* `UID`: _User IDentifier_. ID utente unico..
* `GID`: _Group IDentifier_. Identificatore di gruppo unico..

I file di dichiarazione dell'account e del gruppo si trovano in `/etc`.

I file relativi agli utenti/gruppi sono:

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/default/
* /etc/skel/
* /etc/default/useradd

!!! Danger "Pericolo"

    Dovresti sempre usare i comandi di amministrazione invece di modificare manualmente i file.

## Gestione del gruppo

File modificati, righe aggiunte:

* `/etc/group`
* `/etc/gshadow`

### comando `groupadd`

Il comando `groupadd` aggiunge un gruppo al sistema.
```
groupadd [-f] [-g GID] group
```

Regole di denominazione del gruppo:

```
$ sudo groupadd -g 1012 GroupeB
```

| Opzione  | Descrizione                                                                                                                        |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `-g GID` | `GID` del gruppo da creare.                                                                                                        |
| `-f`     | Il sistema sceglie un`GID` se quello specificato dall'opzione `-g` esiste già.                                                     |
| `-r`     | Crea un gruppo di sistema con un `GID` tra `SYS_GID_MIN` e `SYS_GID_MAX`. Queste due variabili sono definite in `/etc/login.defs`. |

Regole di denominazione del gruppo:

* Nessun accento o carattere speciale;
* 2: Password (`x` se definita in `/etc/gshadow`).

!!! Note "Nota"

    Sotto **Debian**, l'amministratore dovrebbe usare, tranne che negli script destinati ad essere portabili su tutte le distribuzioni Linux, i comandi `addgroup` e `delgroup` come specificato nel `man`:

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. Sono front ends più intuitivi degli strumenti di basso livello come i programmi useradd, groupadd e usermod,
    per impostazione predefinita scelgono i valori UID e GID conformi ai criteri Debian, creano una home directory con la sua configurazione di base,
    eseguono uno script personalizzato, e altre funzioni.
    ```

### Comando `groupmod`

Il comando `groupmod` consente di modificare un gruppo esistente sul sistema.

```
groupmod [-g GID] [-n nom] group
```

Esempio:

```
$ sudo groupmod -g 1016 GroupP
$ sudo groupmod -n GroupC GroupB
```

| Opzione   | Descrizione                          |
| --------- | ------------------------------------ |
| `-g GID`  | Nuovo`GID` del gruppo da modificare. |
| `-n name` | Nuovo nome.                          |

È possibile cambiare il nome di un gruppo, il  `GID` o entrambi simultaneamente.

Dopo la modifica, i file appartenenti al gruppo hanno un `GID` sconosciuto. Devono essere riassegnati al nuovo `GID`.

```
$ sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### comando `groupdel`

Il comando `groupdel` si usa per eliminare un gruppo esistente sul sistema.

```
groupdel group
```

Esempio:

```
$ sudo groupdel GroupC
```

!!! Tip "Suggerimento"

    Quando si elimina un gruppo, si possono verificare due condizioni:

    * 1: Nome del gruppo.
    * Se un utente appartiene a un gruppo supplementare (non al gruppo primario per l'utente) e tale gruppo non è il gruppo primario per l'utente antoher sul sistema, quindi il comando `groupdel` eliminerà il gruppo senza alcun prompt aggiuntivo.

    Esempi:

    ```bash
    Shell > useradd testa
    Shell > id testa
    uid=1000(testa) gid=1000(testa) group=1000(testa)
    Shell > groupdel testa
    groupdel: cannot remove the primary group of user 'testa'

    Shell > groupadd -g 1001 testb
    Shell > usermod -G testb root
    Shell > id root
    uid=0(root) gid=0(root) group=0(root) group=0(root), 001(testb)
    Shell > groupdel testb
    ```

!!! Tip "Suggerimento"

    Ogni gruppo ha un `GID` unico. Un gruppo può essere duplicato.

!!! Tip "Suggerimento"

    Poiché un utente fa necessariamente parte di un gruppo, è meglio creare i gruppi prima di aggiungere gli utenti. Pertanto, un gruppo potrebbe non avere alcun membro. Per convenzione, il GID del super amministratore è 0. Il GIDS riservato ad alcuni servizi o processi sono 201~999, che sono chiamati gruppi di sistema o gruppi di utenti pseudo. Il GID per gli utenti è solitamente maggiore o uguale a 1000. Questi sono relativi a <font color=red>/etc/login.defs</font>, di cui parleremo più tardi.

    ```bash
    $ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
    ```

!!! Tip "Suggerimento"

    Ogni riga nel file `/etc/group` corrisponde a un gruppo. Gli utenti il cui gruppo è il loro gruppo principale non è elencato a questo livello.

### file `/etc/group`

Questo file contiene le informazioni del Gruppo (divisi da `:`).

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1: Nome del gruppo.
* 2: La password del gruppo è identificata da `x`. La password del gruppo è memorizzata in `/etc/gshadow`.
* 3: GID.
* 4: Utenti supplementari del gruppo (escluso l'utente primario unico).

!!! Note "Nota"

   Ogni riga nel file `/etc/group` corrisponde a un gruppo. Le informazioni principali dell'utente sono memorizzate in `/etc/passwd`.

### file `/etc/gshadow`

Questo file contiene le informazioni di sicurezza sui gruppi (divisi da `:`).

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1: Nome del gruppo.
* 2: Password criptata.
* **utente normale**: Altro account per accedere al sistema.
* 4: Membri ospiti (separati da virgole, non contiene membri del core).

!!! Warning "Attenzione"

    Per ogni riga del file `/etc/group` deve esserci una riga corrispondente nel file `/etc/gshadow`.

Un `!` nella password indica che la password è bloccata. Quindi nessun utente può utilizzare la password per accedere al gruppo (dal momento che i membri del gruppo non ne hanno bisogno).

## Gestione utenti

### Definizione

File modificati, linee aggiunte:

* **root**: L'amministratore di sistema ;
* **utenti di sistema**: Utilizzato dal sistema per gestire i diritti di accesso alle applicazioni ;
* 3: UID;
* 4: GID del gruppo primario;
* 5: Commenti;
* 6: Home directory;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

Esistono tre tipi di utenti:

* **root**: L'amministratore di sistema ;
* **utenti di sistema**: Utilizzato dal sistema per gestire i diritti di accesso alle applicazioni ;
* **utente normale**: Altro account per accedere al sistema.

Esempio:

* `/etc/passwd`
* `/etc/shadow`

### comando `useradd`

Alla creazione, l'account non ha una password ed è bloccato.

```
$ sudo useradd -u 1000 -g 1013 -d /home/GroupC/carine carine
```

Esempio:

```
$ sudo useradd -u 1000 -g 1013 -d /home/GroupC/carine carine
```

| Opzione        | Descrizione                                                              |
| -------------- | ------------------------------------------------------------------------ |
| `-u UID`       | `UID` dell'utente da creare.                                             |
| `-g GID`       | `GID` del gruppo principale.                                             |
| `-d directory` | Home directory.                                                          |
| `-s shell`     | Shell.                                                                   |
| `-c`           | Aggiungi un commento.                                                    |
| `-U`           | Aggiunge l'utente a un gruppo con lo stesso nome creato simultaneamente. |
| `-M`           | Non crea la directory di connessione.                                    |

Alla creazione, l'account non ha una password ed è bloccato.

Per sbloccare l'account è necessario assegnare una password.

Regole di denominazione dell'account:

* Niente accenti, lettere maiuscole o caratteri speciali;
* Diverso dal nome di un gruppo o file di sistema esistente;
* Imposta le opzioni `-u`, `-g`, `-d` e `-s` alla creazione.

!!! Warning "Attenzione"

    L'albero delle home directory deve essere creato tranne che per l'ultima directory.

L'ultima directory è creata dal comando `useradd`, che coglie l'occasione per copiare i file da `/etc/skel` dentro di essa.

**Un utente può appartenere a diversi gruppi oltre al proprio gruppo primario.**

Per i gruppi supplementari, deve essere utilizzata l'opzione `-G`.

Esempio:

```
$ sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note "Nota"

    Sotto **Debian**, dovrai specificare l'opzione `-m` per forzare la creazione della directory di login o impostare la variabile `CREATE_HOME` nel file `/etc/login.defs`. In ogni caso, l'amministratore dovrebbe usare i comandi `adduser` e `deluser` come specificato nel `man`, tranne negli script destinati a essere portabili su tutte le distribuzioni Linux:

    ```
    Sotto **Debian**, dovrai specificare l'opzione `-m` per forzare la creazione della directory di login o impostare la variabile `CREATE_HOME` nel file `/etc/login.defs`. Su Debian, gli amministratori dovrebbero di solito utilizzare **adduser(8)**
         al suo posto.
    ```

#### Valori predefiniti per la creazione dell'utente.

Il comando `usermod` permette di modificare un utente.

```
useradd -D [-b directory] [-g group] [-s shell]
```

Esempio:

```
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

| Opzione        | Descrizione                                                                          |
| -------------- | ------------------------------------------------------------------------------------ |
| `-D`           | Imposta i valori predefiniti per la creazione dell'utente.                           |
| `-b directory` | Imposta la directory di accesso predefinita.                                         |
| `-g group`     | Imposta il gruppo predefinito.                                                       |
| `-s shell`     | Imposta la shell predefinita.                                                        |
| `-f`           | Il numero di giorni di scadenza della password prima che l'account sia disabilitato. |
| `-e`           | La data in cui l'account sarà disabilitato.                                          |

### comando `usermod`

Opzioni identiche al comando `useradd`.

```
$ sudo usermod -u 1044 carine
```

Esempio:

```
$ sudo usermod -u 1044 carine
```

Con il comando `usermod`, bloccare un account di fatto significa inserire un `!` prima della password nel file `/etc/shadow`.

| Opzione         | Descrizione                                                                                             |
| --------------- | ------------------------------------------------------------------------------------------------------- |
| `-m`            | Associato all'opzione`-d`, sposta il contenuto della vecchia directory di accesso a quello nuova.       |
| `-l login`      | Nuovo nome.                                                                                             |
| `-e AAAA-MM-JJ` | Data di scadenza dell'account.                                                                          |
| `-L`            | Blocca l'account.                                                                                       |
| `-U`            | Sblocca l'account.                                                                                      |
| `-a`            | Previene l'utente dal essere eliminato da un sottogruppo quando viene aggiunto ad un altro sottogruppo. |
| `-G`            | Specifica più sottogruppi durante l'aggiunta.                                                           |

Con il comando `usermod`, bloccare un account di fatto significa inserire un `!` prima della password nel file `/etc/shadow`.

!!! Tip "Suggerimento"

    Per essere modificato, un utente deve essere disconnesso e non avere processi in corso.

Dopo aver cambiato l'identificatore, i file appartenenti all'utente hanno un `UID` sconosciuto . Il nuovo `UID` deve essere riassegnato.

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Dove `1000` è il vecchio `UID` e `1044` quello nuovo.

Il comando `usermod` agisce come una modifica e non come una aggiunta.

Esempio:

```
$ sudo usermod -G GroupP albert
```

L'opzione *-a* cambia questo comportamento.

Per un utente invitato a un gruppo da questo comando e già posizionato come ospite in altri gruppi supplementari, sarà necessario indicare nel comando di gestione dei gruppi tutti i gruppi a cui appartiene, altrimenti scomparirà da essi.

Il comando `userdel` ti consente di eliminare l'account di un utente.

Esempi:

* Invitare `albert` nel gruppo `GroupP`.

```
$ sudo usermod -G GroupG albert
```

* Invita `albert` nel gruppo `GroupG`, ma lo rimuove dall'elenco degli ospiti di `GroupP`.

```
$ sudo usermod -G GroupP,GroupG albert
```

* Quindi o :

```
$ sudo usermod -aG GroupG albert
```

* Oppure :

```
$ sudo userdel -r carine
```

### comando `userdel`

Il comando `userdel` ti consente di eliminare l'account di un utente.

```
$ sudo userdel -r carine
```

| Opzione | Descrizione                                             |
| ------- | ------------------------------------------------------- |
| `-r`    | Elimina la directory di connessione e i file contenuti. |

!!! Tip "Suggerimento"

    $ sudo head -1 /etc/passwd
    root:x:0:0:root:/root:/bin/bash
    (1)(2)(3)(4)(5)  (6)    (7)

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).

### file `/etc/passwd`

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).

```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Login.
* 2: Password (`x` se definita in `/etc/shadow`).
* 3: Data dell'ultima modifica.
* 4: Durata minima della password.
* 5: Durata massima della password.
* 6: Numero di giorni prima dell'avviso.
* 7: Ora di disattivazione dell'account dopo la scadenza.

### file `/etc/shadow`

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).
```
Per ogni riga del file `/etc/passwd` deve esserci una riga corrispondente nel file `/etc/shadow`.
```

* 1: Login.
* 2: Password criptata.
* 3: Data dell'ultima modifica.
* 4: Durata minima della password.
* 5: Durata massima della password.
* 6: Numero di giorni prima dell'avviso.
* 7: Ora di disattivazione dell'account dopo la scadenza.
* 8: Tempo di scadenza dell'account.
* 9: Riservato per un uso futuro.

!!! Danger "Pericolo"

    Tutti i file appartengono necessariamente a un utente e a un gruppo.

## Proprietari dei file

!!! Danger "Pericolo"

    Tutti i file appartengono necessariamente a un utente e a un gruppo.

Il gruppo primario dell'utente che crea il file è, per impostazione predefinita, il gruppo proprietario del file.

### Comandi di modifica

#### comando `chown`

Il comando `chown` consente di cambiare i proprietari di un file.
```
$ sudo chown root myfile
$ sudo chown albert:GroupA myfile
```

Per cambiare solo il gruppo proprietario:
```
$ sudo chown albert file
```

| Opzione | Descrizione                                                |
| ------- | ---------------------------------------------------------- |
| `-R`    | Cambia i proprietari della directory e dei suoi contenuti. |
| `-v`    | Visualizza le modifiche eseguite.                          |

Per cambiare il gruppo proprietario e l'utente proprietario:

```
$ sudo chown :GroupA file
```

Per modificare solo il gruppo proprietario:

```
$ sudo chown albert:GroupA file
```

Modifica dell'utente e del gruppo proprietario:

```
$ sudo chown albert: file
```

Nell'esempio seguente, il gruppo assegnato sarà il gruppo primario dell'utente specificato.

```
chgrp [-R] [-v] group file
```

### comando `chgrp` command

Il comando `chgrp` ti consente di modificare il gruppo proprietario di un file.

```
$ sudo chgrp group1 file
```

Esempio:
```
$ sudo chgrp group1 file
```

| Opzione | Descrizione                                                                     |
| ------- | ------------------------------------------------------------------------------- |
| `-R`    | Modifica i gruppi proprietari della directory e dei suoi contenuti (ricorsivo). |
| `-v`    | Visualizza le modifiche eseguite.                                               |

!!! Note "Nota"

    È possibile applicare a un file un proprietario e un gruppo di proprietari prendendo come riferimento quelli di un altro file:

```
chown --reference=/etc/groups /etc/passwd
```

Esempi:

```
gpasswd [-a login] [-A login] [-d login] [-M login] group
```

## Gestione degli ospiti

### comando `gpasswd`

Il comando `gpasswd -M` agisce come una modifica, non come un'aggiunta.

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
```

Esempi:

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GruppoA
```

| Opzione    | Descrizione                               |
| ---------- | ----------------------------------------- |
| `-a login` | Aggiunge l'utente al gruppo.              |
| `-A login` | Imposta l'amministratore del gruppo.      |
| `-d login` | Rimuove l'utente dal gruppo.              |
| `-M login` | Definisce l'elenco completo degli ospiti. |

Il comando `gpasswd -M` agisce come una modifica, non come un'aggiunta.
```
# gpasswd GroupeA
Nuova password :
Reinserire la nuova password :
```

### comando `id`

Il comando `newgrp` consente di utilizzare temporaneamente un gruppo secondario per la creazione di file.
```
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```
Esempio:
```
newgrp [secondarygroups]
```

### comando `newgrp`

Il comando `newgrp` consente di utilizzare temporaneamente un gruppo secondario per la creazione di file.
```
[alain]$ newgrp GroupB
```
Esempio:
```
[alain]$ newgrp GruppoB
```

!!! Note "Nota"

    Dopo aver usato questo comando, i file saranno creati con il `GID` del suo sottogruppo.

Il comando `newgrp` senza parametri riassegna il gruppo primario.

## Protezione

### commando `passwd`

Con il comando `passwd`, bloccare un account è ottenuto aggiungendo `!!` prima della password nel file `/etc/shadow`.
```
$ sudo passwd -l albert
$ sudo passwd -n 60 -x 90 -w 80 -i 10 patrick
```
Esempi:
```
[alain]$ passwd
```

| Opzione   | Descrizione                                                  |
| --------- | ------------------------------------------------------------ |
| `-d`      | Rimuove la password.                                         |
| `-l`      | Blocca l'account.                                            |
| `-S`      | Visualizza lo stato dell'account.                            |
| `-u`      | Sblocca l'account.                                           |
| `-e`      | Scadenza della password.                                     |
| `-n days` | Durata minima della password.                                |
| `-x days` | Durata massima della password.                               |
| `-w days` | Tempo di avvertimento prima della scadenza.                  |
| `-i days` | Ritardo prima della disattivazione quando la password scade. |

Con il comando `passwd`, bloccare un account è ottenuto aggiungendo `!!` prima della password nel file `/etc/shadow`.

Usando il comando `usermod -U` rimuove solo uno dei `!`. Quindi l'account rimane bloccato.

Esempio:

* Alain cambia la sua password:

```
$ sudo passwd alain
```

* root cambia la password di Alain

```
[alain]$ passwd
```

!!! Note "Nota"

    Il comando `passwd` è disponibile per gli utenti per modificare la loro password (è richiesta la vecchia password). L'amministratore può modificare le password di tutti gli utenti senza restrizioni.

Questo può essere fatto passando la password al comando `passwd`.

Quando si gestiscono gli account utente tramite script di shell, può essere utile impostare una password predefinita dopo la creazione dell'utente.

Questo può essere fatto passando la password al comando `passwd`.

Esempio:
```
$ sudo echo "azerty,1" | passwd --stdin philippe
```
!!! Warning "Attenzione"

    La password viene inserita in chiaro, `passwd` si occupa di crittografarla.

### comando `chage`

Il comando `chage` offre anche una modalità interattiva.
```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```
Esempio:
```
$ sudo chage philippe
$ sudo chage -d 0 philippe
```

| Opzione         | Descrizione                                             |
| --------------- | ------------------------------------------------------- |
| `-I days`       | Ritardo prima della disattivazione, a password scaduta. |
| `-l`            | Visualizza i dettagli della politica.                   |
| `-m days`       | Durata minima della password.                           |
| `-M days`       | Durata massima della password.                          |
| `-d AAAA-MM-JJ` | Ultima modifica della password.                         |
| `-E AAAA-MM-JJ` | Data di scadenza dell'account.                          |
| `-W days`       | Tempo di avvertimento prima della scadenza.             |

Il comando `chage` offre anche una modalità interattiva.

L'opzione `-d` costringe alla modifica della password al login.

Esempi:
```
$ sudo chage philippe
$ sudo chage -d 0 philippe
```

!!! Note "Nota"

    Se non viene specificato alcun utente, l'ordine riguarderà l'utente che lo inserisce.

![User account management with chage](images/chage-timeline.png)

## Gestione avanzata

File di configurazione.:
* `/etc/skel/`
* `/etc/default/useradd`
* `/etc/skel`

!!! Note "Nota"

    La modifica del file `/etc/default/useradd` viene eseguita con il comando `useradd`.
    
    Gli altri file devono essere modificati con un editor di testo.

### file `/etc/default/useradd`

Questo file contiene le impostazioni dei dati predefinite.

!!! Tip "Suggerimento"

    Quando si crea un utente, se le opzioni non sono specificate, il sistema utilizza i valori di default definiti in `/etc/default/useradd`.

Questo file è modificato dal comando `useradd -D` (`useradd -D` inserito senza nessun'altra opzione visualizza il contenuto del file `/etc/default/useradd`).

| Valore              | Commento                                                                               |
| ------------------- | -------------------------------------------------------------------------------------- |
| `GROUP`             | Gruppo predefinito..                                                                   |
| `HOME`              | Percorso in cui verrà creata la directory di accesso per il nome dell'utente.          |
| `INACTIVE`          | Numero di giorni dopo la scadenza della password prima che l'account sia disabilitato. |
| `EXPIRE`            | Data di scadenza dell'account.                                                         |
| `SHELL`             | Interprete dei comandi.                                                                |
| `SKEL`              | Skeleton Directory della directory di accesso.                                         |
| `CREATE_MAIL_SPOOL` | Creazione della Mailbox in`/var/spool/mail`.                                           |

!!! Warning "Attenzione"

    Senza l'opzione `-g', il comando `useradd' crea un gruppo con il nome dell'utente e lo colloca lì.

In ordine al comando `useradd` per poter recuperare il valore del campo `GROUP` dal file `/etc/default/useradd`, devi specificare l'opzione `-N`.

Esempio:
```
su [-] [-c command] [login]
```

### file `/etc/login.defs`

Questo file contiene molti parametri predefiniti utili per la creazione o la modifica degli utenti. Queste informazioni sono raggruppate in paragrafi in base al loro uso:

* Mailboxes;
* Passwords ;
* UID e GID ;
* Umask ;
* Collegamenti;
* Terminali.

### directory `/etc/skel`

Tutti i file e le directory inseriti in questa directory verranno copiati nell'albero utente alla creazione dello stesso.

Il comando `su` consente di modificare l'identità dell'utente connesso.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

Tutti i file e le directory collocati in questa directory saranno copiati nell'albero utente al momento della loro creazione.

## Cambiamento di identità

### comando `su`

Se il login non è specificato, sarà `root`.

```
$ sudo su - alain
[albert]$ su -c "passwd alain"
```

Esempi:

```
su [-] [-c command] [login]
```

| Opzione      | Descrizione                                                 |
| ------------ | ----------------------------------------------------------- |
| `-`          | Carica l'ambiente completo dell'utente.                     |
| `-c` comando | Esegue il comando sotto l'identità dell'utente specificato. |

Gli utenti standard dovranno digitare la password per la nuova identità.

Gli utenti standard dovranno digitare la password per la nuova identità.

!!! Tip "Suggerimento"

    Vengono creati dei 'layers' successivi (una pila di ambienti `bash`). Per passare da un utente all'altro, devi prima digitare il comando `exit` per riprendere la tua identità e quindi il comando `su` per prendere un'altra identità.

#### Caricamento del profilo

`root` approva l'identità dell'utente `alain` con `su`:

```
...
/home/GroupA/alain/.bash_profile
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

`root` assume l'identità dell'utente `alain` con `su -`:

```
...
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

È necessario conoscere la password dell'utente la cui identità viene approvata a meno che non sia `root` che esegue il comando.

Un amministratore può quindi lavorare su un account utente standard e utilizzare i diritti dell'account `root` solo occasionalmente.

Un amministratore può quindi lavorare su un account utente standard e utilizzare i diritti dell'account `root` solo occasionalmente.

Un amministratore può quindi lavorare su un account utente standard e utilizzare i diritti dell'account `root` solo occasionalmente.
