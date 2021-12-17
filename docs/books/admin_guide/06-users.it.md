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

Gli utenti possono appartenere ad altri gruppi. Questi utenti sono *invitati* a questi **gruppi secondari**.

!!! Note "Nota"  
Ogni utente ha un gruppo primario e può essere invitato in uno o più gruppi secondari.

I gruppi e gli utenti sono gestiti dai loro identificatori numerici unici `GID` e `UID`.

I file di dichiarazione dell'account e del gruppo si trovano in `/etc`.
* `UID`: _User IDentifier_. ID utente unico..
* `GID`: _Group IDentifier_. Identificatore di gruppo unico..

!!! Danger "Pericolo"  
È necessario utilizzare sempre i comandi di amministrazione invece di modificare manualmente i file.

## Gestione del gruppo

File modificati, linee aggiunte:

* `/etc/group`
* `/etc/gshadow`

### comando `groupadd`

Il comando `groupadd` aggiunge un gruppo al sistema.
```
groupadd [-f] [-g GID] group
```

Esempio:

```
$ sudo groupadd -g 1012 GroupeB
```

| Opzione  | Descrizione                                                                                                                        |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `-g GID` | `GID` del gruppo da creare.                                                                                                        |
| `-f`     | Il sistema sceglie un`GID` se quello specificato dall'opzione `-g` esiste già.                                                     |
| `-r`     | Crea un gruppo di sistema con un `GID` tra `SYS_GID_MIN` e `SYS_GID_MAX`. Queste due variabili sono definite in `/etc/login.defs`. |

Regole di denominazione del gruppo:

* Nessun accento o caratteri speciali;
* Diverso dal nome di un utente o file di sistema esistenti.

; Nota Sotto **Debian**, l'amministratore dovrebbe usare, tranne che negli script destinati ad essere portatili per tutte le distribuzioni Linux, i comandi `addgroup` e `delgroup` come specificato nell' `man`:

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. They are friendlier front ends to the low level tools like useradd, groupadd and usermod programs,
    by default choosing Debian policy conformant UID and GID values, creating a home directory with skeletal configuration,
    running a custom script, and other features. They are friendlier front ends to the low level tools like useradd, groupadd and usermod programs,
    by default choosing Debian policy conformant UID and GID values, creating a home directory with skeletal configuration,
    running a custom script, and other features.
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

Il comando `groupdel` è usato per eliminare un gruppo esistente sul sistema.

```
groupdel group
```

Esempio:

```
$ sudo groupdel GroupC
```

!!! Tip "Suggerimento"  
Per essere cancellato, un gruppo non deve più contenere utenti.

L'eliminazione dell'ultimo utente di un gruppo omonimo causerà l'eliminazione del gruppo stesso dal sistema.

!!! Tip "Suggerimento"  
Ogni gruppo ha un unico `GID`. Un gruppo può essere duplicato. Per convenzione, il `GID` dei gruppi di sistema vanno da 0 (`root`) a 999.

!!! Tip "Suggerimento"  
Dal momento che un utente è necessariamente parte di un gruppo, È meglio creare i gruppi prima di aggiungere gli utenti. Pertanto, un gruppo inizialmente potrebbe non avere membri.

### file `/etc/group`

Questo file contiene le informazioni del Gruppo (divisi da `:`).

```
$ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1: Nome del gruppo.
* 2: Password (`x` se definita in `/etc/gshadow`).
* 3: GID.
* 4: Membri ospiti (separati da virgole, non contiene membri di base).

!!! Note "Nota"  
Ogni linea nel file `/etc/group` corrisponde a un gruppo. Gli utenti il cui gruppo è il loro gruppo principale non è elencato a questo livello. Questa informazione è infatti già fornita dal file `/etc/passwd` ...

### file `/etc/gshadow`

Questo file contiene le informazioni di sicurezza sui gruppi (divisi da `:`).

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1: Nome del gruppo.
* 2: Password crittografata.
* 3: Amministratore del gruppo.
* 4: Membri ospiti (separati da virgole, non contiene membri di base).

!!! Warning "Avvertimento"  
Per ogni linea nel file `/etc/group` ci deve essere una linea corrispondente nel file `/etc/gshadow`.

Un `!` nella password indica che la password è bloccata. Quindi nessun utente può utilizzare la password per accedere al gruppo (dal momento che i membri del gruppo non ne hanno bisogno).

## Gestione utenti

### Definizione

Un utente è definito come segue nel file  `/etc/passwd`:

* 1: Login;
* 2: Password;
* 3: UID;
* 4: GID del gruppo principale;
* 5: Commenti;
* 6: Home directory;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

Ci sono tre tipi di utenti:

* **root**: L'amministratore di sistema ;
* **utenti di sistema**: Utilizzato dal sistema per gestire i diritti di accesso alle applicazioni ;
* **utente normale**: Altro account per accedere al sistema.

File modificati, linee aggiunte:

* `/etc/passwd`
* `/etc/shadow`

### comando `useradd`

Il comando `useradd` è usato per aggiungere un utente.

```
useradd [-u UID] [-g GID] [-d directory] [-s shell] login
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

È necessario assegnare una password per sbloccare l'account.

Regole di denominazione dell'account:

* Nessun accento, lettere maiuscole o caratteri speciali;
* Diverso dal nome di un gruppo o file di sistema esistente;
* Imposta le opzioni `-u`, `-g`, `-d` e `-s` alla creazione.

!!! Warning "Avvertimento"  
L'albero della directory home deve essere già creato tranne per l'ultima directory.

L'ultima directory è creata dal comando `useradd`, che coglie l'occasione per copiare i file da `/etc/skel` dentro di essa.

**Un utente può appartenere a diversi gruppi oltre al proprio gruppo principale.**

Per gruppi secondari, deve essere usata l'opzione `-G`.

Esempio:

```
$ sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note "Nota"  
In **Debian**, dovrai specificare l'opzione `-m` per forzare la creazione della directory di accesso o impostare la variabile `CREATE_HOME` nel file `/etc/login.defs`. In tutti i casi, l'amministratore dovrebbe usare i comandi `adduser` e `deluser` come specificato nelle pagine `man`, tranne per gli script destinati ad essere portabili su tutte le distribuzioni Linux:

    ```
    $ man useradd
    DESCRIPTION
    **useradd** is a low level utility for adding users. On Debian, administrators should usually use **adduser(8)**
     instead.
    ```

#### Valori predefiniti per la creazione dell'utente.

Modifica del file `/etc/default/useradd`.

```
useradd -D [-b directory] [-g group] [-s shell]
```

Esempio:

```
$ sudo useradd -D -g 1000 -b /home -s /bin/bash
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

Il comando `usermod` permette di modificare un utente.

```
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

Esempio:

```
$ sudo usermod -u 1044 carine
```

Opzioni identiche al comando `useradd`.

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
Per essere modificato, un utente deve essere disconnesso e non avere processi in esecuzione.

Dopo aver cambiato l'identificatore, i file appartenenti all'utente hanno un `UID` sconosciuto . Il nuovo `UID` deve essere riassegnato.

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Dove `1000` è il vecchio `UID` e `1044` il nuovo.

È possibile invitare un utente in uno o più sottogruppi con le opzioni *-a* e *-G*.

Esempio:

```
$ sudo usermod -aG GroupP,GroupC albert
```

Il comando `usermod` agisce come una modifica e non come una aggiunta.

Per un utente invitato a un gruppo da questo comando e già posizionato come ospite in altri gruppi secondari, sarà necessario indicare nel comando di gestione del gruppo tutti i gruppi a cui appartiene altrimenti verrà eliminato dagli altri gruppi.

L'opzione *-a* cambia questo comportamento.

Esempi:

* Invitare `albert` nel gruppo `GroupP`.

```
$ sudo usermod -G GroupP albert
```

* Invita `albert` nel gruppo `GroupG`, ma lo rimuove dal gruppo elenco degli ospiti `GroupP` .

```
$ sudo usermod -G GroupG albert
```

* Quindi entrambi :

```
$ sudo usermod -G GroupP,GroupG albert
```

* O :

```
$ sudo usermod -aG GroupG albert
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
Per essere cancellato, un utente deve essere disconnesso e non avere processi in esecuzione.

`userdel` rimuove la linea dell'utente dal file `/etc/passwd` e da `/etc/gshadow`.

### file `/etc/passwd`

Questo file contiene le informazioni utente (divise da `:`).

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1: Login.
* 2: Password (`x` se definita in `/etc/shadow`).
* 3: UID.
* 4: GID del gruppo principale.
* 5: Commenti.
* 6: Home directory.
* 7: Shell.

### file `/etc/shadow`

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Login.
* 2: Password crittografata.
* 3: Data dell'ultima modifica.
* 4: Durata minima della password.
* 5: Durata massima della password.
* 6: Numero di giorni prima dell'avviso.
* 7: Ora di disattivazione dell'account dopo la scadenza.
* 8: Tempo di scadenza dell'account.
* 9: Riservato per un uso futuro.

!!! Danger "Pericolo"  
Per ogni linea nel file `/etc/passwd` ci deve essere una linea corrispondente nel file `/etc/shadow`.

## Proprietari dei file

!!! Danger "Pericolo"  
Tutti i file appartengono necessariamente a un utente e un gruppo.

Il gruppo principale dell'utente che crea il file è, per impostazione predefinita, il gruppo che possiede il file.

### Comandi di modifica

#### comando `chown`

Il comando `chown` ti consente di modificare i proprietari di un file.
```
chown [-R] [-v] login[:group] file
```

Esempi:
```
$ sudo chown root myfile
$ sudo chown albert:GroupA myfile
```

| Opzione | Descrizione                                                |
| ------- | ---------------------------------------------------------- |
| `-R`    | Cambia i proprietari della directory e dei suoi contenuti. |
| `-v`    | Visualizza le modifiche eseguite.                          |

Per cambiare solo l'utente proprietario:

```
$ sudo chown albert file
```

Per cambiare solo il gruppo proprietario:

```
$ sudo chown :GroupA file
```

Per cambiare il gruppo proprietario e l'utente proprietario:

```
$ sudo chown albert:GroupA file
```

Nell'esempio seguente il gruppo assegnato sarà il gruppo principale dell'utente specificato.

```
$ sudo chown albert: file
```

### comando `chgrp` command

Il comando `chgrp` ti consente di modificare il gruppo proprietario di un file.

```
chgrp [-R] [-v] group file
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
È possibile applicare a un file un proprietario e un gruppo proprietario prendendo come riferimento quelli di un altro file:

```
chown [options] --reference=RRFILE FILE
```

Per esempio:

```
chown --reference=/etc/groups /etc/passwd
```

## Gestione degli ospiti

### comando `gpasswd`

Il comando `gpasswd` permette di gestire un gruppo.

```
gpasswd [-a login] [-A login] [-d login] [-M login] group
```

Esempi:

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
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
New Password :
Re-enter new password :
```

### comando `id`

Il comando `id` visualizza i nomi del gruppo di un utente.
```
id login
```
Esempio:
```
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```

### comando `newgrp`

Il comando `newgrp` consente di utilizzare temporaneamente un gruppo secondario per la creazione di file.
```
newgrp [secondarygroups]
```
Esempio:
```
[alain]$ newgrp GroupB
```

!!! Note "Nota"  
Dopo aver usato questo comando, i file verranno creati con il `GID` del suo sottogruppo.

Il comando `newgrp` senza parametri riassegna al gruppo principale.

## Protezione

### commando `passwd`

Il comando `passwd` è usato per gestire una password.
```
passwd [-d] [-l] [-S] [-u] [login]
```
Esempi:
```
$ sudo passwd -l albert
$ sudo passwd -n 60 -x 90 -w 80 -i 10 patrick
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
[alain]$ passwd
```

* root cambia la password di Alain

```
$ sudo passwd alain
```

!!! Note "Nota"  
Il comando `passwd` è disponibile per gli utenti per cambiare la propria password (la vecchia password è richiesta). L'amministratore può modificare le password di tutti gli utenti senza restrizioni.

Dovranno rispettare le restrizioni di sicurezza.

Quando gestisci gli account utente da una shell script, potrebbe essere utile impostare una password predefinita dopo aver creato l'utente.

Questo può essere fatto passando la password al comando `passwd`.

Esempio:
```
$ sudo echo "azerty,1" | passwd --stdin philippe
```
!!! Warning "Avvertimento"  
La password è inserita in chiaro, `passwd` si prende cura di crittografarla.

### comando `chage`

Il comando `chage` è usato per gestire la strategia dell'account.
```
chage [-d date] [-E date] [-I days] [-l] [-m days] [-M days] [-W days] [login]
```
Esempio:
```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
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
Se nessun utente è specificato, l'ordine riguarderà l'utente che entra.

![User account management with chage](images/chage-timeline.png)

## Gestione avanzata

File di configurazione.:
* `/etc/default/useradd`
* `/etc/login.defs`
* `/etc/skel`

!!! Note "Nota"  
La modifica del file `/etc/default/useradd` è fatta con il comando `useradd`.

    Gli altri file devono essere modificati con un editor di testo.

### file `/etc/default/useradd`

Questo file contiene le impostazioni dei dati predefinite.

!!! Tip "Suggerimento"  
Quando si crea un utente, se le opzioni non sono specificate, il sistema utilizza i valori predefiniti definiti in `/etc/default/useradd`.

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

!!! Warning "Avvertimento"  
Senza l'opzione `-g`, il comando `useradd` crea un gruppo dal nome dell'utente e il gruppo diventa il gruppo principale dell'utente.

In ordine al comando `useradd` per poter recuperare il valore del campo `GROUP` dal file `/etc/default/useradd`, devi specificare l'opzione `-N`.

Esempio:
```
$ sudo useradd -u 501 -N GroupeA
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

Quando viene creato un utente, vengono creati anche la home directory e i file d'ambiente.

Questi file vengono automaticamente copiati dalla directory `/etc/skel`.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

Tutti i file e le directory inseriti in questa directory verranno copiati nell'albero utente alla creazione dello stesso.

## Cambiamento di identità

### comando `su`

Il comando `su` consente di modificare l'identità dell'utente connesso.

```
su [-] [-c command] [login]
```

Esempi:

```
$ sudo su - alain
[albert]$ su -c "passwd alain"
```

| Opzione      | Descrizione                                                 |
| ------------ | ----------------------------------------------------------- |
| `-`          | Carica l'ambiente completo dell'utente.                     |
| `-c` comando | Esegue il comando sotto l'identità dell'utente specificato. |

Se il login non è specificato, sarà `root`.

Gli utenti standard dovranno digitare la password per la nuova identità.

!!! Tip "Suggerimento"  
Ci sono "strati" creati in successione (una pila di ambienti `bash`). Per passare da un utente all'altro, devi prima digitare il comando `exit` per riprendere la tua identità e poi il comando `su` per prendere un'altra identità.

#### Caricamento del profilo

`root` approva l'identità dell'utente `alain` insieme a `su`:

```
...
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

`root` assume l'identità dell'utente `alain` with `su -`:

```
...
/home/GroupA/alain/.bash_profile
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

Un utente può temporaneamente (per un altro comando o per un'intera sessione) assumere l'identità di un altro account.

Se nessun utente è specificato, il comando sarà per `root` (`su -`).

È necessario conoscere la password dell'utente la cui identità viene approvata a meno che non sia `root` che esegue il comando.

Un amministratore può quindi lavorare su un account utente standard e utilizzare i diritti dell'account `root` solo occasionalmente.
