---
title: Autorizzazioni Speciali
author: tianci li
contributors: Serge Croisé, Colussi Franco
tags:
  - advanced permissions
  - access control
---

<font color=red>Tutti gli esempi in questo documento usano le azioni di root, con le azioni ordinarie degli utenti commentate separatamente. Nel blocco di codice markdown, la descrizione del comando sarà indicata con # sulla riga precedente.</font>

# Rivedere le autorizzazioni di base

È noto che i permessi di base di GNU/Linux possono essere visualizzati utilizzando `ls -l`:

```bash
Shell > ls -l 
-  rwx  r-x  r-x  1  root  root    1358  Dec 31 14:50  anaconda-ks.cfg
↓   ↓    ↓    ↓   ↓   ↓     ↓       ↓        ↓            ↓
1   2    3    4   5   6     7       8        9            10
```

I loro significati sono i seguenti:

| Parte | Descrizione                                                                                                                                                                                    |
| ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Tipo di file. `-` indica che si tratta di un file ordinario. In seguito verranno introdotti sette tipi di file.                                                                                |
| 2     | Permessi dell'utente proprietario, il significato di rwx significa, rispettivamente, leggere, scrivere, eseguire.                                                                              |
| 3     | Permessi del gruppo proprietario.                                                                                                                                                              |
| 4     | Permessi di altri utenti.                                                                                                                                                                      |
| 5     | Numero di sottodirectory. (`.` e `..` incluse). Per un file, rappresenta il numero di collegamenti diretti e 1 rappresenta se stesso.                                                          |
| 6     | Nome dell'utente proprietario.                                                                                                                                                                 |
| 7     | Nome del gruppo proprietario.                                                                                                                                                                  |
| 8     | Per i file, mostra la dimensione del file. Per le directory, mostra il valore fisso di 4096 byte occupati dal nome del file. Per calcolare la dimensione totale di una directory, usa `du -sh` |
| 9     | Ultima data di modifica.                                                                                                                                                                       |
| 10    | Il nome del file (o directory).                                                                                                                                                                |

## Sette tipi di file

| Tipi di file | Descrizione                                                                                                                                                                                                                  |
|:------------:| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|    **-**     | Rappresenta un file ordinario. Compresi i file di testo semplice (ASCII); file binari (binario); file in formato dati (dati); vari file compressi.                                                                           |
|    **d**     | Rappresenta un file di directory. Per impostazione predefinita, ce n'è una in ogni directory `.` e `..`.                                                                                                                     |
|    **b**     | File del dispositivo a blocchi. Compresi tutti i tipi di dischi rigidi, unità USB e così via.                                                                                                                                |
|    **c**     | File del dispositivo a caratteri. Dispositivo di interfaccia della porta seriale, come il mouse, la tastiera, ecc.                                                                                                           |
|    **s**     | File Socket. Si tratta di un file appositamente utilizzato per la comunicazione di rete.                                                                                                                                     |
|    **p**     | File Pipe. Si tratta di un tipo di file speciale, il cui scopo principale è quello di risolvere gli errori causati da più programmi che accedono a un file contemporaneamente. FIFO è l'abbreviazione di first-in-first-out. |
|    **l**     | I file soft link, chiamati anche file di collegamento simbolico, sono simili ai collegamenti di Windows. File di collegamento rigido, noto anche come file di collegamento fisico.                                           |

## Il significato dei permessi di base

Per il file:

| Rappresentazione digitale | Permessi    | Descrizione                                                                                                    |
|:-------------------------:| ----------- | -------------------------------------------------------------------------------------------------------------- |
|             4             | r(lettura)  | Indica che puoi leggere questo file. Si possono usare comandi come `cat`, `head`, `more`, `less`, `tail`, etc. |
|             2             | w(scrivere) | Indica che il file può essere modificato. È possibile utilizzare comandi come `vim`.                           |
|             1             | x(eseguire) | Permessi per file eseguibili (come script o binari).                                                           |

Per la directory:

| Rappresentazione digitale | Permessi    | Descrizione                                                                                                                |
|:-------------------------:| ----------- | -------------------------------------------------------------------------------------------------------------------------- |
|             4             | r(lettura)  | Indica che i contenuti della directory possono essere elencati, come `ls -l`.                                              |
|             2             | w(scrivere) | Indica che è possibile creare, eliminare e rinominare i file in questa directory, es. comandi `mkdir`, `touch`, `rm`, ecc. |
|             1             | x(eseguire) | Indica che è possibile entrare nella directory, come con il comando `cd`.                                                  |

!!! info "Informazione"

    Per le directory, i permessi **r** e **x** di solito appaiono contemporaneamente.

## Autorizzazioni Speciali

In GNU/Linux, oltre ai permessi di base menzionati sopra, esistono anche alcuni permessi speciali, che presenteremo uno per uno.

### Autorizzazioni ACL

Che cos'è l'ACL? ACL (Access Control List), il cui scopo è quello di risolvere il problema delle tre identità in Linux che non riescono a soddisfare le esigenze di allocazione delle risorse.

Ad esempio, l'insegnante impartisce lezioni agli studenti e crea una directory sotto la directory principale del sistema operativo. Solo gli studenti di questa classe possono caricare e scaricare, gli altri non possono farlo. A questo punto, le autorizzazioni per la directory sono 770. Un giorno, uno studente di un'altra scuola è venuto ad ascoltare l'insegnante: come dovrebbero essere assegnati i permessi? Se si inserisce questo studente nel **gruppo proprietario**, avrà gli stessi permessi degli studenti di questa classe - **rwx**. Se lo studente viene inserito tra gli **altri utenti**, non avrà alcun permesso. In questo momento, l'allocazione dei permessi di base non è in grado di soddisfare i requisiti ed è necessario utilizzare le ACL.

Una funzione simile è presente nel sistema operativo Windows. Ad esempio, per assegnare le autorizzazioni a un utente per un file, per una directory/file definita dall'utente, fare **clic con il pulsante destro del mouse** ---&gt; **Proprietà** ---&gt; **Sicurezza** ---&gt; **Modifica** ---&gt; **Aggiungi** ---&gt; **Avanzate** ---&gt; **Trova ora**, trovare l'utente/gruppo corrispondente ---&gt; assegnare le autorizzazioni specifiche ---&gt; **Applica** e completare.

<!--Screenshots of the English interface are required-->

Lo stesso vale per GNU/Linux: aggiungete l'utente/gruppo specificato al file/directory e concedete i permessi appropriati per completare l'assegnazione dei permessi ACL.

Come si abilita una ACL? È necessario trovare il nome del file del dispositivo in cui si trova il punto di montaggio e il suo numero di partizione. Ad esempio, sulla mia macchina, si può fare qualcosa di simile:

```bash
Shell > df -hT
Filesystem     Type      Size  Used  Avail Use% Mounted on
devtmpfs       devtmpfs  3.8G     0  3.8G    0% /dev
tmpfs          tmpfs     3.8G     0  3.8G    0% /dev/shm
tmpfs          tmpfs     3.8G  8.9M  3.8G    1% /run
tmpfs          tmpfs     3.8G     0  3.8G    0% /sys/fs/cgroup
/dev/nvme0n1p2 ext4       47G   11G   35G   24% /
/dev/nvme0n1p1 xfs      1014M  187M  828M   19% /boot
tmpfs          tmpfs     774M     0  774M    0% /run/user/0

Shell > dumpe2fs /dev/nvme0n1p2 | head -n 10
dumpe2fs 1.45.6 (20-Mar-2020)
Filesystem volume name:   <none>
Last mounted on:          /
Filesystem UUID:          c8e6206d-2892-4c22-a10b-b87d2447a885
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file dir_nlink extra_isize metadata_csum
Filesystem flags:         signed_directory_hash 
Default mount options:    user_xattr acl
Filesystem state:         clean
Errors behavior:          Continue
```

Quando viene visualizzata la riga **"Default mount options: user_xattr acl"**, indica che l'ACL è stato abilitato. Se non è abilitato, puoi anche attivarlo temporaneamente -- `mount -o remount,acl /`. Può anche essere attivato in modo permanente:

```bash
Shell > vim /etc/fstab
UUID=c8e6206d-2892-4c22-a10b-b87d2447a885  /   ext4    defaults,acl        1 1

Shell > mount -o remount /
# or
Shell > reboot
```

#### Visualizzazione e impostazione di ACL

Per visualizzare l'ACL, è necessario utilizzare il comando `getfacle` -- `getfacle NOME_FILE`

Se si desidera impostare i permessi ACL, è necessario utilizzare il comando `setfacl`.

```bash
Shell > setfacl <option> <FILE_NAME>
```

| Opzione | Descrizione                                     |
| ------- | ----------------------------------------------- |
| -m      | modificare l'ACL corrente di uno o più file     |
| -x      | rimuove le voci dalla/e ACL dei file            |
| -b      | rimuovere tutte le voci ACL estese              |
| -d      | le operazioni si applicano alla ACL predefinita |
| -k      | rimuovere la ACL predefinita                    |
| -R      | ricorreggere nelle sottodirectory               |

Utilizzate l'esempio di insegnamento dell'insegnante citato all'inizio dell'articolo per illustrare l'uso dell'ACL.

```bash
# The teacher is the root user
Shell > groupadd class1
Shell > mkdir /project
Shell > chown root:class1 /project
Shell > chmod 770 /project
Shell > ls -ld /project/
drwxrwx--- 2 root class1 4096 Jan  12 12:58 /project/

# Put the students in the class into the class1 group
Shell > useradd frank
Shell > passwd frank
Shell > useradd aron
Shell > passwd aron
Shell > gpasswd -a frank class1
Shell > gpasswd -a aron class1

# A student from another school came to listen to the teacher
Shell > useradd tom
Shell > passwd tom
# If it is a group, "u" here should be replaced by "g"
Shell > setfacle -m u:tom:rx  /project

# "+" sign is added in the output message
Shell > ls -ld /project/
drwxrwx---+ 2 root class1 4096 Jan  12 12:58 /project/

Shell > getfacl -p /project/
# file: /project/
# owner: root
# group: class1
user::rwx
user:tom:r-x
group::rwx
mask::rwx
other::---
```

#### Autorizzazioni massime valide di ACL

Quando si utilizza il comando `getfacl`, cosa significa "mask:: rwx" nel messaggio di output? La **maschera** viene utilizzata per specificare i permessi massimi validi. I permessi dati all'utente non sono permessi reali, i permessi reali possono essere ottenuti solo utilizzando i permessi "logici and" dell'utente e le autorizzazioni di maschera.

!!! info "Informazione"

    "Logica and" significa: se tutti sono veri, il risultato è vero; se ce n'è uno falso, il risultato è falso.
    
    | Permissions set by users | Mask permissions | Result |
    |:---:|:---:|:---:|
    | r | r | r |
    | r | - | - |
    | - | r | - |
    | - | - | - |

!!! info "Informazione"

    Poiché la maschera predefinita è rwx, per i permessi ACL di qualsiasi utente, il risultato è il proprio permesso.

È inoltre possibile regolare le autorizzazioni della maschera:

```bash
Shell > setfacl -m u:tom:rwx /project
Shell > setfacl -m m:rx /project

Shell > getfacl  -p /project/
# file: project/
# owner: root
# group: class1
user::rwx
user:tom:rwx                    #effective:r-x
group::rwx                      #effective:r-x
mask::r-x
other::---
```

#### Cancellare l'autorizzazione ACL

```bash
# Delete the ACL permissions of user/group in the specified directory
Shell > setfacl -x u:USER_NAME FILE_NAME
Shell > setfacl -x g:GROUP_NAME FILE_NAME

# Removes all ACL permissions for the specified directory
Shell > setfacl -b FILE_NAME
```

#### Predefinito e ricorsivo dei permessi ACL

Qual è la ricorsione dei permessi ACL? Per i permessi ACL, ciò significa che quando la directory principale imposta i permessi ACL, tutte le sottodirectory e i file secondari avranno gli stessi permessi ACL.

!!! info "Informazione"

    La ricorsione si applica a file/directory già esistenti.

Osservate il seguente esempio:

```bash
Shell > setfacl -m m:rwx /project
Shell > setfacl -m u:tom:rx /project

Shell > cd /project
Shell > touch file1 file2
# Because there is no recursion, the file here does not have ACL permission. 
Shell > ls -l
-rw-r--r-- 1 root root 0 Jan  12 14:35 file1
-rw-r--r-- 1 root root 0 Jan  12 14:35 file2

Shell > setfacl -m u:tom:rx -R /project
Shell > ls -l /project
-rw-r-xr--+ 1 root root 0 Jan  12 14:35 file1
-rw-r-xr--+ 1 root root 0 Jan  12 14:35 file2
```

Ora c'è una domanda: se creo un nuovo file in questa directory, ha i permessi ACL? La risposta è no, perché il file è stato creato dopo l'esecuzione dell comando `setfacl-m u:tom:rx -R / project`.

```bash
Shell > touch /project/file3
Shell > ls -l /project/file3
-rw-r--r-- 1 root root 0 Jan  12 14:52 /project/file3
```

Se si desidera che la nuova directory/file abbia anche i permessi ACL, è necessario utilizzare i permessi ACL predefiniti.

```bash
Shell > setfacl -m d:u:tom:rx  /project
Shell > cd /project && touch file4 && ls -l 
-rw-r-xr--+ 1 root root 0 Jan  12 14:35 file1
-rw-r-xr--+ 1 root root 0 Jan  12 14:35 file2
-rw-r--r--  1 root root 0 Jan  12 14:52 file3
-rw-rw----+ 1 root root 0 Jan  12 14:59 file4

Shell > getfacl -p /project
# file: /project
# owner: root
# group: class1
user::rwx
user:tom:r-x
group::rwx
mask::rwx
other::---
default:user::rwx
default:user:tom:r-x
default:group::rwx
default:mask::rwx
default:other::---
```

### SetUID

Il ruolo di "SetUID":

* Solo i binari eseguibili possono impostare i permessi SUID.
* L'esecutore del comando deve avere i permessi x per il programma.
* L'esecutore del comando ottiene l'identità del proprietario del file del programma durante l'esecuzione del programma stesso.
* Il cambiamento di identità è valido solo durante l'esecuzione, e una volta terminato il programma binario, l'identità dell'esecutore viene ripristinata all'identità originale.

Perché GNU/Linux ha bisogno di queste strane autorizzazioni? Prendiamo ad esempio il comando più comune `passwd`:

![SetUID1](./images/SetUID1.png)

Come si può vedere, l'utente ordinario ha solo r e x, ma la x del proprietario diventa s, dimostrando che il comando `passwd` ha i permessi SUID.

È noto che gli utenti ordinari (uid >= 1000) possono cambiare la propria password. La vera password è memorizzata nel file **/etc/shadow** , ma il permesso del file shadows è di 000, e gli utenti ordinari non hanno alcun permesso.

```bash
Shell > ls -l /etc/shadow
---------- 1 root root 874 Jan  12 13:42 /etc/shadow
```

Poiché gli utenti ordinari possono cambiare la loro password, devono aver scritto la password nel file **/etc/shadow**. Quando un utente ordinario esegue il comando `passwd` , cambierà temporaneamente al proprietario del file -- **root**. Per il file **shadow** , **root** non può essere limitato dai permessi. Questo è il motivo per cui il comando `passwd` necessita dell'autorizzazione SUID.

Come accennato in precedenza, i permessi di base possono essere rappresentati da numeri, come 755, 644, e così via. Il SUID è rappresentato da **4**. Per i binari eseguibili, è possibile impostare permessi come questo -- **4755**.

```bash
# Set SUID permissions
Shell > chmod 4755 FILE_NAME
# or
Shell > chmod u+s FILE_NAME

# Remove SUID permission
Shell > chmod 755 FILE_NAME
# or
Shell > chmod u-s FILE_NAME
```

!!! warning "Attenzione"

    Quando il proprietario di un file/programma binario eseguibile non ha **x**, l'uso di **S** maiuscola significa che il file non può utilizzare i permessi SUID.


    ```bash
    # Suppose this is an executable binary file
    Shell > vim suid.sh
    #!/bin/bash
    cd /etc && ls

    Shell > chmod 4644 suid.sh
    ```


    ![SUID2](./images/SetUID2.png)

!!! warning "Attenzione"

    Poiché SUID può temporaneamente cambiare gli utenti ordinari in root, è necessario prestare particolare attenzione con i file con questo permesso durante la manutenzione del server. È possibile trovare file con permessi SUID utilizzando il seguente comando:

    ```bash
    Shell > find / -perm -4000 -a -type f -exec ls -l  {} \;
    ```

### SetGID

Il ruolo di "SetGID":

* Solo i binari eseguibili possono impostare i permessi SGID.
* L'esecutore del comando dovrebbe avere il permesso x al programma.
* L'esecutore del comando ottiene l'identità del gruppo proprietario del file di programma durante l'esecuzione del programma.
* Il cambio di identità è valido solo durante l'esecuzione e, una volta terminato il programma binario, l'identità dell'esecutore viene ripristinata a quella originale.

Prendiamo ad esempio il comando `locate`:

```
Shell > rpm -ql mlocate
/usr/bin/locate
...
/var/lib/mlocate/mlocate.db

Shell > ls -l /var/lib/mlocate/mlocate.db
-rw-r----- 1 root slocate 4151779 1月  14 11:43 /var/lib/mlocate/mlocate.db

Shell > ll /usr/bin/locate 
-rwx--s--x. 1 root slocate 42248 4月  12 2021 /usr/bin/locate
```

Il comando `locate` utilizza il file di database **mlocate.db** per cercare rapidamente i file.

Poiché il comando `locate` ha il permesso SGID, quando l'esecutore (utenti ordinari) esegue il comando `locate`, il gruppo proprietario passa a **slocate**. `slocate` ha i permessi r per il file **/var/lib/mlocate/mlocate.db**.

Lo SGID è indicato dal numero **2**, quindi il comando `locate` ha un permesso di 2711.

```bash
# Set SGID permissions
Shell > chmod 2711 FILE_NAME
# or
Shell > chmod g+s FILE_NAME

# Remove SGID permission
Shell > chmod 711 FILE_NAME
# or
Shell > chmod g-s FILE_NAME
```

!!! warning "Attenzione"

    Quando il gruppo proprietario di un file/programma binario eseguibile non ha **x**, utilizzare **S** maiuscolo per indicare che i permessi SGID del file non possono essere utilizzati correttamente.

    ```bash
    # Suppose this is an executable binary file
    Shell > touch sgid

    Shell > chmod 2741 sgid
    Shell > ls -l sgid
    -rwxr-S--x  1 root root         0 Jan  14 12:11 sgid
    ```

SGID può essere utilizzato non solo per i file/programmi binari eseguibili, ma anche per le directory, ma viene usato raramente.

* Gli utenti ordinari devono avere i permessi rwx sulla directory.
* Per i file creati dagli utenti ordinari in questa directory, il gruppo proprietario predefinito è il gruppo proprietario della directory.

Per esempio:

```bash
Shell > mkdir /SGID_dir
Shell > chmod 2777 /SGID_dir
Shell > ls -ld /SGID_dir
drwxrwsrwx  2 root root      4096 Jan 14 12:17 SGID_dir

Shell > su - tom
Shell(tom) > cd /SGID_dir && touch tom_file && ls -l
-rw-rw-r-- 1 tom root 0 Jan  14 12:26 tom_file
```

!!! warning "Attenzione"

    Poiché SGID può temporaneamente cambiare il gruppo proprietario degli utenti ordinari in root, è necessario prestare particolare attenzione ai file con questo permesso durante la manutenzione del server. È possibile trovare i file con permessi SGID tramite il seguente comando:

    ```bash
    Shell > find / -perm -2000 -a -type f -exec ls -l  {} \;
    ```

### Sticky BIT

Il ruolo di "Sticky BIT":

* Valido solo per la directory.
* Gli utenti ordinari hanno i permessi w e x in questa directory.
* Se non c'è Sticky Bit, gli utenti ordinari con il permesso w possono eliminare tutti i file in questa directory (inclusi i file creati da altri utenti). Una volta che la directory riceve l'autorizzazione SBIT, solo l'utente root può eliminare tutti i file. Anche se gli utenti ordinari hanno l'autorizzazione w, possono eliminare solo i file creati da loro stessi (i file creati da altri utenti non possono essere eliminati).

Lo SBIT è rappresentato dal numero **1**.

Il file/directory può avere il permesso **7755**? No, sono rivolti a oggetti diversi. SUID è per i file binari eseguibili; SGID è usato per i file binari eseguibili e le directory; SBIT è solo per le directory. È quindi necessario impostare queste autorizzazioni speciali in base ai diversi oggetti.

La directory **/tmp** ha il permesso SBIT. Un esempio è il seguente:

```bash
# The permissions of the /tmp directory are 1777
Shell > ls -ld /tmp
drwxrwxrwt. 8 root root 4096 Jan  14 12:50 /tmp

Shell > su - tom 
Shell > cd /tmp && touch tom_file1 
Shell > exit

Shell > su - jack 
Shell(jack) > cd /tmp && rm -rf tom_file1
rm: cannot remove 'tom_file1': Operation not permitted
Shell(jack) > exit

# The file has been deleted
Shell > su - tom 
Shell(tom) > rm -rf /tmp/tom_file1
```

!!! info "Informazione"

    gli utenti root (uid=0) non sono limitati dai permessi di SUID, SGID e SBIT.

### chattr

La funzione del permesso chattr: serve a proteggere i file o le directory importanti del sistema dall'eliminazione per errore.

Uso del comando `chattr` -- `chattr [ -RVf ] [ -v version ] [ -p project ] [ mode ] file...`

Il formato di una modalità simbolica è +-=[aAcCdDeFijPsStTu].

* "+" significa aumentare le autorizzazioni;
* "-" significa ridurre le autorizzazioni;
* "=" significa uguale a un permesso.

I permessi più comunemente usati (chiamati anche attributi) sono **a** e **i**.

#### Descrizione dell'attributo i:

|           |                      Elimina                      |          Modifica libera           |  Aggiungere il contenuto del file  |             Visualizza             | Crea file |
|:---------:|:-------------------------------------------------:|:----------------------------------:|:----------------------------------:|:----------------------------------:|:---------:|
|   file    |                         ×                         |                 ×                  |                 ×                  |                 √                  |     -     |
| directory | x <br>(Directory e file sotto la directory) | √ <br>(File nella directory) | √ <br>(File nella directory) | √ <br>(File nella directory) |     x     |

Esempi per i file:

```bash
Shell > touch /tmp/filei
Shell > vim /tmp/filei
123

Shell > chattr +i /tmp/filei
Shell > lsattr -a /tmp/filei
----i---------e----- /tmp/filei

Shell > rm -rf /tmp/filei
rm: cannot remove '/tmp/filei': Operation not permitted

# Cannot be modified freely
Shell > vim /tmp/file1

Shell > echo "adcd" >> /tmp/filei 
-bash: /tmp/filei: Operation not permitted

Shell > cat /tmp/filei
123
```

Esempi per le directory:

```bash
Shell > mkdir /tmp/diri
Shell > cd /tmp/diri && echo "qwer" > f1

Shell > chattr +i /tmp/diri
Shell > lsattr -ad /tmp/diri
----i---------e----- /tmp/diri

Shell > rm -rf /tmp/diri
rm: cannot remove '/tmp/diri/f1': Operation not permitted

# Allow modification
Shell > vim /tmp/diri/f1
qwer-tom

Shell > echo "jim" >> /tmp/diri/f1
Shell > cat /tmp/diri/f1
qwer-tom
jim

Shell > touch /tmp/diri/file2
touch: settng time of '/tmp/diri/file2': No such file or directory
```

Rimuovere l'attributo i dall'esempio precedente:

```bash
Shell > chattr -i /tmp/filei /tmp/diri
```

#### Descrizione dell'attributo a:

|           |                      Elimina                      |          Modifica libera           |  Aggiungere il contenuto del file  |             Visualizza             | Crea file |
|:---------:|:-------------------------------------------------:|:----------------------------------:|:----------------------------------:|:----------------------------------:|:---------:|
|   file    |                         ×                         |                 ×                  |                 √                  |                 √                  |     -     |
| directory | x <br>(Directory e file sotto la directory) | √ <br>(File nella directory) | √ <br>(File nella directory) | √ <br>(File nella directory) |     √     |

Esempi per i file:

```bash
Shell > touch /etc/tmpfile1
Shell > echo "zxcv" > /etc/tmpfile1

Shell > chattr +a /etc/tmpfile1
Shell > lsattr -a /etc/tmpfile1
-----a--------e----- /etc/tmpfile1

Shell > rm -rf /etc/tmpfile1
rm: cannot remove '/etc/tmpfile1': Operation not permitted

# Cannot be modified freely
Shell > vim /etc/tmpfile1

Shell > echo "new line" >> /etc/tmpfile1
Shell > cat /etc/tmpfile1
zxcv
new line
```

Esempi per le directory:

```bash
Shell > mkdir /etc/dira
Shell > cd /etc/dira && echo "asdf" > afile

Shell > chattr +a /etc/dira
Shell > lsattr -a /etc/dira
-----a--------e----- /etc/dira/

Shell > rm -rf /etc/dira
rm: cannot remove '/etc/dira/afile': Operation not permitted

# Allow modification
Shell > vim /etc/dira/afile
asdf-bcd

Shell > echo "new line" >> /etc/dira/afile
Shell > cat /etc/dira/afile
asdf-bcd
new line

# Allow creation of new files
Shell > touch /etc/dira/newfile
```

Rimuovere l'attributo a dall'esempio precedente:

```bash
Shell > chattr -a /etc/tmpfile1 /etc/dira/
```

!!! domanda

    Cosa succede quando ho impostato l'attributo ai su un file? 
    Non è possibile fare nulla con il file, se non visualizzarlo.
    
    Che dire della directory?
    Sono consentite: la modifica libera, l'aggiunta del contenuto del file e la visualizzazione.
    Non consentito: eliminare e creare file.

### sudo

Il ruolo di "sudo":

* Tramite l'utente root, assegnare i comandi che possono essere eseguiti solo dall'utente root (uid=0) agli utenti ordinari per l'esecuzione.
* L'oggetto dell'operazione di "sudo" è il comando di sistema.

Sappiamo che solo l'amministratore root ha il permesso di usare i comandi sotto **/sbin/** e **/usr/sbin/** nella directory GNU/Linux. In generale, un'azienda dispone di un team per la manutenzione di una serie di server. Questo insieme di server può riferirsi a una singola sala computer in un'unica località geografica, oppure a una sala computer in più località geografiche. Il team leader utilizza i permessi dell'utente root, mentre gli altri membri del team possono avere solo i permessi dell'utente ordinario. Poiché il responsabile ha molto lavoro, non ha il tempo di occuparsi del lavoro quotidiano del server e la maggior parte del lavoro deve essere svolto dagli utenti comuni. Tuttavia, gli utenti ordinari hanno molte restrizioni sull'uso dei comandi e, a questo punto, è necessario utilizzare i permessi sudo.

Per concedere i permessi agli utenti ordinari, è **necessario utilizzare l'utente root (uid=0)**.

Puoi abilitare gli utenti normali usando il comando `visudo` , quello che stai effettivamente cambiando è il file **/etc/sudoers**.

```bash
Shell > visudo
...
88 Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
89 
90 ## Next comes the main part: which users can run what software on
91 ## which machines (the sudoers file can be shared between multiple
92 ## systems).
93 ## Syntax:
94 ##
95 ##      user    MACHINE=COMMANDS
96 ##
97 ## The COMMANDS section may have other options added to it.
98 ##
99 ## Allow root to run any commands anywhere
100 root    ALL=(ALL)       ALL
     ↓       ↓    ↓          ↓
     1       2    3          4
...
```

| Parte | Descrizione                                                                                                                                                                                              |
|:-----:| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   1   | Nome utente o nome del gruppo proprietario. Si riferisce all'utente/gruppo a cui vengono concessi i permessi. Se si tratta di un gruppo di proprietari, è necessario scrivere "%", ad esempio **%root**. |
|   2   | Quali macchine sono autorizzate a eseguire i comandi. Può essere un singolo indirizzo IP, un segmento di rete o TUTTO.                                                                                   |
|   3   | Indica in quali identità è possibile trasformarsi.                                                                                                                                                       |
|   4   | Il comando autorizzato, che deve essere rappresentato da un percorso assoluto.                                                                                                                           |

Per esempio:

```bash
Shell > visudo
...
101 tom  ALL=/sbin/shutdown  -r now 
...

# You can use the "-c" option to check for errors in /etc/sudoers writing.
Shell > visudo -c

Shell > su - tom
# View the available sudo commands.
Shell(tom) > sudo -l

# To use the available sudo command, ordinary users need to add sudo before the command.
Shell(tom) > sudo /sbin/shutdown -r now
```

Se il comando di autorizzazione è `/sbin/shutdown`, significa che gli utenti autorizzati possono utilizzare qualsiasi opzione del comando.

!!! warning "Attenzione"

    Poiché sudo è un'operazione "ultra vires", occorre fare attenzione quando si ha a che fare con i file **/etc/sudoers**!
