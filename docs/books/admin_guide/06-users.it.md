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

| Opzione             | Descrizione                                                                                                                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-u UID`            | `UID` dell'utente da creare.                                                                                                                                                                                   |
| `-g GID`            | `GID` del gruppo primario. Il `GID` qui può anche essere un `nome del gruppo`.                                                                                                                                 |
| `-G GID1,[GID2]...` | `GID` dei gruppi supplementari. Il `GID` qui può anche essere un `nome del gruppo`. Si possono specificare più gruppi supplementari, separati da virgole.                                                      |
| `-s shell`          | Shell.                                                                                                                                                                                                         |
| `-c`                | Aggiungi un commento.                                                                                                                                                                                          |
| `-U`                | Aggiunge l'utente a un gruppo con lo stesso nome creato simultaneamente.                                                                                                                                       |
| `-M`                | Aggiunge l'utente a un gruppo con lo stesso nome creato simultaneamente. Se questa opzione non è scritta per impostazione predefinita, verrà creato un gruppo con lo stesso nome quando l'utente viene creato. |
| `-M`                | Non creare la directory home dell'utente.                                                                                                                                                                      |
| `-r`                | Crea un account di sistema.                                                                                                                                                                                    |

Alla creazione, l'account non ha una password ed è bloccato.

Per sbloccare l'account è necessario assegnare una password.

Regole di denominazione dell'account:

* Niente accenti, lettere maiuscole o caratteri speciali;
* Diverso dal nome di un gruppo o file di sistema esistente;
* La shell predefinita è bash;
* L'utente `uid` e il gruppo primario `gid` vengono automaticamente registrati da 1000, e di solito uid e gid sono gli stessi.

```bash
Shell > useradd test1

Shell > tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

Shell > tail -n 1 /etc/shadow
test1:!!:19253:0:99999:7:::

Shell > tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

Regole di denominazione dell'account:

* Niente accenti, lettere maiuscole o caratteri speciali;
* Diverso dal nome di un gruppo o file di sistema esistente;
* Opzionale: imposta le opzioni `-u`, `-g`, `-d` e `-s` alla creazione.

!!! Warning "Attenzione"

    L'albero delle home directory deve essere creato tranne che per l'ultima directory.

L'ultima directory è creata dal comando `useradd`, che coglie l'occasione per copiare i file da `/etc/skel` dentro di essa.

**Un utente può appartenere a diversi gruppi oltre al proprio gruppo primario.**

Esempio:

```
$ sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note "Nota"

    Sotto **Debian**, dovrai specificare l'opzione `-m` per forzare la creazione della directory di login o impostare la variabile `CREATE_HOME` nel file `/etc/login.defs`. In tutti i casi, l'amministratore dovrebbe usare i comandi `adduser` e `deluser` come specificato in `man`, tranne che negli script destinati a essere trasferiti a tutte le distribuzioni Linux:

    ```
    $ man useradd
    DESCRIPTION
        **useradd** is a low level utility for adding users. Su Debian, gli amministratori dovrebbero di solito utilizzare **adduser(8)**
         al suo posto.
    ```

#### Valori predefiniti per la creazione dell'utente.

Modifica del file `/etc/default/useradd`.

```
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

Esempio:

```
$ sudo usermod -u 1044 carine
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

| Opzione         | Descrizione                                                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `-m`            | Associato all'opzione`-d`, sposta il contenuto della vecchia directory di accesso a quello nuova.                                    |
| `-l login`      | Nuovo nome login. Dopo aver modificato il nome di accesso, è anche necessario modificare il nome della directory home per abbinarlo. |
| `-e AAAA-MM-JJ` | Data di scadenza dell'account.                                                                                                       |
| `-L`            | Blocca permanentemente l'account. Cioè, un `!` viene aggiunto all'inizio del campo password `/etc/shadow`                            |
| `-U`            | Sblocca l'account.                                                                                                                   |
| `-a`            | Previene l'utente dal essere eliminato da un sottogruppo quando viene aggiunto ad un altro sottogruppo.                              |
| `-G`            | Specifica più sottogruppi durante l'aggiunta.                                                                                        |

!!! Tip "Suggerimento"

    Per essere modificato, un utente deve essere disconnesso e non avere processi in corso.

After changing the identifier, the files belonging to the user have an unknown `UID`. Deve essere riassegnato il nuovo `UID`.

Dopo aver cambiato l'identificatore, i file appartenenti all'utente hanno un `UID` sconosciuto . Gli esempi sono i seguenti:

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Blocco e sblocco dell'account utente, gli esempi sono i seguenti:

```
$ sudo usermod -G GroupG albert
```

La differenza tra l'opzione `-aG` e l'opzione `-G` può essere spiegata dal seguente esempio:

```bash
$ sudo usermod -G GroupP,GroupG albert
```

### comando `userdel`

Il comando `userdel` consente di eliminare l'account di un utente.

```
$ sudo usermod -aG GroupG albert
```

| Opzione | Descrizione                                             |
| ------- | ------------------------------------------------------- |
| `-r`    | Elimina la directory di connessione e i file contenuti. |

!!! Tip "Suggerimento"

    Per essere eliminato, un utente deve essere disconnesso e non avere processi in esecuzione.

Per un utente invitato a un gruppo da questo comando e già posizionato come ospite in altri gruppi supplementari, sarà necessario indicare nel comando di gestione dei gruppi tutti i gruppi a cui appartiene, altrimenti scomparirà da essi.

### file `/etc/passwd`

Il comando `userdel` ti consente di eliminare l'account di un utente.

```
$ sudo userdel -r carine
```

* Invita `albert` nel gruppo `GroupG`, ma lo rimuove dall'elenco degli ospiti di `GroupP`.
* 2: Password (`x` se definita in `/etc/shadow`).
* 3: UID.
* 4: GID del gruppo primario.
* 5: Commenti.
* 6: Home directory.
* 7: Shell.

### file `/etc/shadow`

Questo file contiene le informazioni di sicurezza degli utenti (separate da `:`).
```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
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

    $ sudo tail -1 /etc/shadow
    root:$6$...:15399:0:99999:7:::
     (1)    (2)  (3) (4) (5) (6)(7,8,9)

## Proprietari dei file

!!! Tip "Suggerimento"

    Per ogni riga del file `/etc/passwd` deve esserci una riga corrispondente nel file `/etc/shadow`.

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).

### Comandi di modifica

#### comando `chown`

Questo file contiene le informazioni sulla sicurezza degli utenti (divisi da `:`).
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
$ sudo chown root myfile
$ sudo chown albert:GroupA myfile
```

Per modificare solo il gruppo proprietario:

```
$ sudo chown albert file
```

Modifica dell'utente e del gruppo proprietario:

```
$ sudo chown :GroupA file
```

Il comando `chown` consente di cambiare i proprietari di un file.

```
$ sudo chown albert:GroupA file
```

### comando `chgrp` command

Il comando `chgrp` consente di cambiare il gruppo proprietario di un file.

```
$ sudo chown albert: file
```

Per cambiare il gruppo proprietario e l'utente proprietario:
```
chgrp [-R] [-v] group file
```

| Opzione | Descrizione                                                                     |
| ------- | ------------------------------------------------------------------------------- |
| `-R`    | Modifica i gruppi proprietari della directory e dei suoi contenuti (ricorsivo). |
| `-v`    | Visualizza le modifiche eseguite.                                               |

!!! Note "Nota"

    È possibile applicare a un file un proprietario e un gruppo di proprietari prendendo come riferimento quelli di un altro file:

```
$ sudo chgrp group1 file
```

Modifica dell'utente e del gruppo proprietario:

```
chown --reference=/etc/groups /etc/passwd
```

## Gestione degli ospiti

### comando `gpasswd`

Nell'esempio seguente, il gruppo assegnato sarà il gruppo primario dell'utente specificato.

```
chown --reference=/etc/groups /etc/passwd
```

Esempi:

```
gpasswd [-a login] [-A login] [-d login] [-M login] group
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
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GruppoA
```
Esempi:
```
# gpasswd GroupeA
Nuova password :
Reinserire la nuova password :
```

### comando `newgrp`

Il comando `gpasswd -M` agisce come una modifica, non come un'aggiunta.
```
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```
Esempi:
```
newgrp [secondarygroups]
```

!!! Note "Nota"

    Dopo aver usato questo comando, i file saranno creati con il `GID` del suo sottogruppo.

Il comando `newgrp` consente di utilizzare temporaneamente un gruppo secondario per la creazione di file.

## Protezione

### commando `passwd`

Il comando `passwd` viene utilizzato per gestire una password.
```
[alain]$ newgrp GruppoB
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

Con il comando `passwd`, il blocco di un account si ottiene aggiungendo `!!` prima della password nel file `/etc/shadow`.

Using the command `usermod -U` command only removes one of the `!`. Quindi l'account rimane bloccato.

Esempi:

* Oppure :

```
$ sudo passwd -l albert
$ sudo passwd -n 60 -x 90 -w 80 -i 10 patrick
```

* root cambia la password di Alain

```
[alain]$ passwd
```

!!! Note "Nota"

    Il comando `passwd` è disponibile per gli utenti per modificare la loro password (è richiesta la vecchia password). L'amministratore può modificare le password di tutti gli utenti senza restrizioni.

Dovranno rispettare le restrizioni di sicurezza.

Con il comando `passwd`, bloccare un account è ottenuto aggiungendo `!!` prima della password nel file `/etc/shadow`.

Questo può essere fatto passando la password al comando `passwd`.

Esempio:
```
[alain]$ passwd
```
!!! Note "Nota"

    La password viene inserita in chiaro, `passwd` si occupa di crittografarla.

### comando `chage`

Questo può essere fatto passando la password al comando `passwd`.
```
chage [-d date] [-E date] [-I days] [-l] [-m days] [-M days] [-W days] [login]
```
Esempi:
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

Questo può essere fatto passando la password al comando `passwd`.

L'opzione `-d` forza la modifica della password all'accesso.

Esempi:
```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

!!! Note "Nota"

    Se non viene specificato alcun utente, l'ordine riguarderà l'utente che lo inserisce.

![User account management with chage](images/chage-timeline.png)

## Gestione avanzata

File di configurazione:
* `/etc/skel/`
* `/etc/default/useradd`
* `/etc/skel`

!!! Note "Nota"

    La modifica del file `/etc/default/useradd` viene eseguita con il comando `useradd`.
    
    Gli altri file devono essere modificati con un editor di testo.

### file `/etc/default/useradd`

Questo file contiene le impostazioni predefinite dei dati.

!!! Note "Nota"

    Se non viene specificato alcun utente, l'ordine riguarderà l'utente che lo inserisce.

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

    Se non viene specificato alcun utente, l'ordine riguarderà l'utente che lo inserisce.

In ordine al comando `useradd` per poter recuperare il valore del campo `GROUP` dal file `/etc/default/useradd`, devi specificare l'opzione `-N`.

Esempi:
```
$ sudo useradd -u 501 -N GroupeA
```

### file `/etc/login.defs`

This file contains many default parameters useful for creating or modifying users. Queste informazioni sono raggruppate per paragrafo in base al loro utilizzo:

* Mailboxes;
* Password ;
* UID e GID ;
* Umask ;
* Connessioni;
* 6: Numero di giorni prima dell'avviso.

### directory `/etc/skel`

Questo file è modificato dal comando `useradd -D` (`useradd -D` inserito senza nessun'altra opzione visualizza il contenuto del file `/etc/default/useradd`).

Questi file vengono automaticamente copiati dalla directory `/etc/skel`.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

In ordine al comando `useradd` per poter recuperare il valore del campo `GROUP` dal file `/etc/default/useradd`, devi specificare l'opzione `-N`.

## Cambiamento di identità

### comando `su`

Il comando `su` consente di cambiare l'identità dell'utente connesso.

```
su [-] [-c command] [login]
```

Esempi:

```
su [-] [-c command] [login]
```

| Opzione      | Descrizione                                                 |
| ------------ | ----------------------------------------------------------- |
| `-`          | Carica l'ambiente completo dell'utente.                     |
| `-c` comando | Esegue il comando sotto l'identità dell'utente specificato. |

Tutti i file e le directory inseriti in questa directory verranno copiati nell'albero utente alla creazione dello stesso.

Il comando `su` consente di modificare l'identità dell'utente connesso.

!!! Tip "Suggerimento"

    Vengono creati dei 'layers' successivi (una pila di ambienti `bash`). Per passare da un utente all'altro, devi prima digitare il comando `exit` per riprendere la tua identità e quindi il comando `su` per prendere un'altra identità.

#### Caricamento del profilo

`root` approva l'identità dell'utente `alain` con `su`:

```
...
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

Esempi:

```
...
/home/GroupA/alain/.bash_profile
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

Gli utenti standard dovranno digitare la password per la nuova identità.

Gli utenti standard dovranno digitare la password per la nuova identità.

È necessario conoscere la password dell'utente la cui identità viene approvata a meno che non sia `root` che esegue il comando.

Un amministratore può quindi lavorare con un account utente standard e utilizzare i diritti dell'account `root` solo occasionalmente.
