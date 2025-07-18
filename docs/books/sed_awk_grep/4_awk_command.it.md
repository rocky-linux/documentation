---
title: Comando awk
author: tianci li
contributors:
tags:
  - awk
---

# Comando `awk`

Nel 1977 nacque ai Bell Labs un tool di programmazione per l'elaborazione di testi language-level, denominato `awk`.
Il nome proviene dalle prime lettere dei cognomi di tre persone famose:

- Alfred **A**ho
- Peter **W**einberger
- Brian **K**ernighan

Proprio come shell (bash, csh, zsh e ksh), nel tempo sono state sviluppate altre versioni di `awk`:

- `awk`: Nato nel 1977 nei Bell Labs.
- `nawk` (new awk): Sviluppato nel 1985, è una versione aggiornata e migliorata di `awk`. Si diffuse ampiamente con il rilascio della release 3.1 di Unix System V (1987). `oawk` si riferisce alle vecchie versioni di `awk`.
- \`gawk' (GNU awk): Scritto da Paul Rubin nel 1986. Il progetto GNU è nato nel 1984.
- `mawk`: Scritto nel 1996 da Mike Brennan, è l'interprete del linguaggio di programmazione `awk`.
- `jawk`: Implementazione di `awk` in JAVA

Nel sistema operativo GNU/Linux, di solito `awk` si riferisce a `gawk`. Tuttavia, alcune distribuzioni, come Ubuntu o Debian, utilizzano `mawk` come `awk` predefinito.

In tutte le versioni recenti di Rocky Linux, `awk` si riferisce a `gawk`.

```bash
Shell > whereis awk
awk: /usr/bin/awk /usr/libexec/awk /usr/share/awk /usr/share/man/man1/awk.1.gz

Shell > ls -l /usr/bin/awk
lrwxrwxrwx. 1 root root 4 4月  16 2022 /usr/bin/awk -> gawk

Shell > rpm -qf /usr/bin/awk
gawk-4.2.1-4.el8.x86_64
```

Per le informazioni non trattate, consultare il [manuale gawk] (https://www.gnu.org/software/gawk/manual/ "manuale gawk").

Sebbene \`awk' sia uno strumento per l'elaborazione del testo, possiede alcune caratteristiche di un linguaggio di programmazione:

- variabile
- controllo del processo (ciclo)
- tipo di dati
- operazione logica
- funzione
- array
- ...

\*\*Il principio di funzionamento di `awk**: Simile ai database relazionali, supporta l'elaborazione di campi (colonne) e record (righe). Per impostazione predefinita, `awk\` tratta ogni riga di un file come un record e colloca questi record in memoria per l'elaborazione riga per riga, con una parte di ogni riga trattata come un campo del record. Per impostazione predefinita, i delimitatori per separare i diversi campi utilizzano spazi e tabulazioni, mentre i numeri rappresentano i diversi campi del record di riga. Per fare riferimento a più campi, separarli con virgole o tabulazioni.

Un esempio semplice e di facile comprensione：

```bash
Shell > df -hT
| 1             |     2        |  3    |  4   |  5    |   6   |   7            | 8       |
|Filesystem     |    Type      | Size  | Used | Avail | Use%  | Mounted        | on      |←← 1 (first line)
|devtmpfs       |    devtmpfs  | 1.8G  |   0  | 1.8G  |  0%   | /dev           |         |←← 2
|tmpfs          |    tmpfs     | 1.8G  |    0 | 1.8G  |  0%   | /dev/shm       |         |←← 3
|tmpfs          |    tmpfs     | 1.8G  | 8.9M | 1.8G  |  1%   | /run           |         |←← 4
|tmpfs          |    tmpfs     | 1.8G  |   0  | 1.8G  |  0%   | /sys/fs/cgroup |         |←← 5
|/dev/nvme0n1p2 |    ext4      | 47G   | 2.6G |  42G  |  6%   | /              |         |←← 6
|/dev/nvme0n1p1 |    xfs       | 1014M | 182M | 833M  |  18%  | /boot          |         |←← 7
|tmpfs          |    tmpfs     | 364M  |   0  | 364M  |  0%   | /run/user/0    |         |←← 8  (end line)

Shell > df -hT | awk '{print $1,$2}'
Filesystem  Type
devtmpfs devtmpfs
tmpfs tmpfs
tmpfs tmpfs
tmpfs tmpfs
/dev/nvme0n1p2 ext4
/dev/nvme0n1p1 xfs
tmpfs tmpfs

# $0: Reference the entire text content.
Shell > df -hT | awk '{print $0}'
Filesystem     Type      Size   Used  Avail Use% Mounted on
devtmpfs       devtmpfs  1.8G     0  1.8G    0%  /dev
tmpfs          tmpfs     1.8G     0  1.8G    0%  /dev/shm
tmpfs          tmpfs     1.8G  8.9M  1.8G    1%  /run
tmpfs          tmpfs     1.8G     0  1.8G    0%  /sys/fs/cgroup
/dev/nvme0n1p2 ext4       47G  2.6G   42G    6%  /
/dev/nvme0n1p1 xfs      1014M  182M  833M   18%  /boot
tmpfs          tmpfs     364M     0  364M    0%  /run/user/0
```

## Istruzioni per l'uso di `awk`

L'uso di `awk` è - `awk option 'pattern {action}' FileName`

**pattern**: Trovare contenuti specifici nel testo
**action**: Istruzioni per l'azione
**{ }**: Raggruppare alcune istruzioni secondo schemi specifici

| opzione                                                                     | descrizione                                                                                                                                                                 |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -f program-file  --file program-file                                        | Lettura dei file sorgente del programma `awk` da file                                                                                                                       |
| -F FS                                                                       | Specificare il separatore per separare i campi. 'FS' è una variabile incorporata in `awk`, con valori predefiniti di spazi o tabulazioni                    |
| -v var=value                                                                | assegnazione delle variabili                                                                                                                                                |
| --posix                                                                     | Attivare la modalità di compatibilità                                                                                                                                       |
| --dump-variables=[file] | Scrive le variabili globali in `awk` in un file. Se non viene specificato alcun file, il file predefinito è awkvars.out                     |
| --profile=[file]        | Scrivere i dati dell'analisi delle prestazioni in un file specifico. Se non viene specificato alcun file, il file predefinito è awkprof.out |

| pattern                                                    | descrizione                                                                                           |
| :--------------------------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| BEGIN{ }                                                   | Un'azione che viene eseguita prima della lettura di tutti i record di riga                            |
| END{ }                                                     | Un'azione che viene eseguita dopo la lettura di tutti i record di riga                                |
| /regular  expression/                                      | Corrisponde all'espressione regolare per ogni record della riga di input                              |
| pattern && pattern | Logica e funzionamento                                                                                |
| pattern \\|\\| pattern                                   | Logica o funzionamento                                                                                |
| !pattern                                                   | Operazione di negazione logica                                                                        |
| pattern1,pattern2                                          | Specificare l'intervallo di pattern per trovare tutti i record di riga all'interno di tale intervallo |

`awk` è potente e implica molte conoscenze, quindi alcuni contenuti saranno spiegati in seguito.

### Comandi `printf`

Prima di imparare formalmente `awk`, i principianti devono comprendere il comando `printf`.

`printf`：formatta e stampa i dati. Il suo utilizzo è -`printf FORMAT [ARGUMENT]...`

**FORMAT**：Utilizzato per controllare il contenuto dell'output. Sono supportate le seguenti sequenze di interpretazione comuni：

- **\a** - avviso (BEL)
- **\b** - backspace
- **\f** - alimentazione del modulo
- **\n** - nuova linea
- **\r** - ritorno a capo
- **\t** - tabulazione orizzontale
- **\v** - tabulazione verticale
- **%Ns** - La stringa del risultato. N rappresenta il numero di stringhe, ad esempio: `%s %s %s`
- **%Ni** - Numeri interi in uscita. N rappresenta il numero di numeri interi dell'output, ad esempio: `%i %i`
- **%m\.nf** - Numero in virgola mobile in uscita. Il valore m rappresenta il numero totale di cifre emesse e il valore n rappresenta il numero di cifre dopo la virgola. Ad esempio: `%8.5f`

**ARGUMENT**: Se si tratta di un file, è necessario eseguire una preelaborazione per ottenere un output corretto.

```bash
Shell > cat /tmp/printf.txt
ID      Name    Age     Class
1       Frank   20      3
2       Jack    25      5
3       Django  16      6
4       Tom     19      7

# Example of incorrect syntax:
Shell > printf '%s %s $s\n' /tmp/printf.txt
/tmp/printf.txt

# Change the format of the text
Shell > printf '%s' $(cat /tmp/printf.txt)
IDNameAgeClass1Frank2032Jack2553Django1664Tom197
# Change the format of the text
Shell > printf '%s\t%s\t%s\n' $(cat /tmp/printf.txt)
ID      Name    Age
Class   1       Frank
20      3       2
Jack    25      5
3       Django  16
6       4       Tom
19      7

Shell > printf "%s\t%s\t%s\t%s\n" a b c d 1 2 3 4
a       b       c       d
1       2       3       4
```

Nel sistema operativo RockyLinux non esiste il comando `print`. Si può usare `print` solo in `awk` e la sua differenza rispetto a `printf` è che aggiunge automaticamente una newline alla fine di ogni riga. Ad esempio:

```bash
Shell > awk '{printf $1 "\t" $2"\n"}' /tmp/printf.txt
ID      Name
1       Frank
2       Jack
3       Django
4       Tom

Shell > awk '{print $1 "\t" $2}' /tmp/printf.txt
ID      Name
1       Frank
2       Jack
3       Django
4       Tom
```

## Esempio di utilizzo di base

1. Lettura dei file sorgente del programma `awk` da file

  ```bash
  Shell > vim /tmp/read-print.awk
  #!/bin/awk
  {print $6}

  Shell > df -hT | awk -f /tmp/read-print.awk
  Use%
  0%
  0%
  1%
  0%
  6%
  18%
  0%
  ```

2. Specificare il delimitatore

  ```bash
  Shell > awk -F ":" '{print $1}' /etc/passwd
  root
  bin
  daemon
  adm
  lp
  sync
  ...

  Shell > tail -n 5 /etc/services | awk -F "\/" '{print $2}'
  awk: warning: escape sequence `\/' treated as plain `/'
  axio-disc       35100
  pmwebapi        44323
  cloudcheck-ping 45514
  cloudcheck      45514
  spremotetablet  46998
  ```

  Si possono usare anche parole come delimitatori. Le parentesi indicano che si tratta di un delimitatore generale e "|" significa o.

  ```bash
  Shell > tail -n 5 /etc/services | awk -F "(tcp)|(udp)" '{print $1}'
  axio-disc       35100/
  pmwebapi        44323/
  cloudcheck-ping 45514/
  cloudcheck      45514/
  spremotetablet  46998/
  ```

3. Assegnazione delle variabili

  ```bash
  Shell > tail -n 5 /etc/services | awk -v a=123 'BEGIN{print a}{print $1}'
  123
  axio-disc
  pmwebapi
  cloudcheck-ping
  cloudcheck
  spremotetablet
  ```

  Assegna il valore delle variabili definite dall'utente in bash alle variabili di awk.

  ```bash
  Shell > ab=123
  Shell > echo ${ab}
  123
  Shell > tail -n 5 /etc/services | awk -v a=${ab} 'BEGIN{print a}{print $1}'
  123
  axio-disc
  pmwebapi
  cloudcheck-ping
  cloudcheck
  spremotetablet
  ```

4. Scrivere le variabili globali di awk in un file

  ```bash
  Shell > seq 1 6 | awk --dump-variables '{print $0}'
  1
  2
  3
  4
  5
  6

  Shell > cat /root/awkvars.out
  ARGC: 1
  ARGIND: 0
  ARGV: array, 1 elements
  BINMODE: 0
  CONVFMT: "%.6g"
  ENVIRON: array, 27 elements
  ERRNO: ""
  FIELDWIDTHS: ""
  FILENAME: "-"
  FNR: 6
  FPAT: "[^[:space:]]+"
  FS: " "
  FUNCTAB: array, 41 elements
  IGNORECASE: 0
  LINT: 0
  NF: 1
  NR: 6
  OFMT: "%.6g"
  OFS: " "
  ORS: "\n"
  PREC: 53
  PROCINFO: array, 20 elements
  RLENGTH: 0
  ROUNDMODE: "N"
  RS: "\n"
  RSTART: 0
  RT: "\n"
  SUBSEP: "\034"
  SYMTAB: array, 28 elements
  TEXTDOMAIN: "messages"
  ```

  In seguito, sarà introdotto il significato di queste variabili. Per rivederli ora, [saltare alle variabili](#VARIABILI).

5. BEGIN{ } ed END{ }

  ```bash
  Shell > head -n 5 /etc/passwd | awk 'BEGIN{print "UserName:PasswordIdentification:UID:InitGID"}{print $0}END{print "one\ntwo"}'
  UserName:PasswordIdentification:UID:InitGID
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
  one
  two
  ```

6. Opzione --profile

  ```bash
  Shell > df -hT | awk --profile 'BEGIN{print "start line"}{print $0}END{print "end line"}'
  start line
  Filesystem     Type      Size  Used Avail Use% Mounted on
  devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
  tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
  tmpfs          tmpfs     1.8G  8.9M  1.8G   1% /run
  tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
  /dev/nvme0n1p2 ext4       47G  2.7G   42G   6% /
  /dev/nvme0n1p1 xfs      1014M  181M  834M  18% /boot
  tmpfs          tmpfs     363M     0  363M   0% /run/user/0
  end line

  Shell > cat /root/awkprof.out
      # gawk profile, created Fri Dec  8 15:12:56 2023

      # BEGIN rule(s)

      BEGIN {
   1          print "start line"
      }

      # Rule(s)

   8  {
   8          print $0
      }

      # END rule(s)

      END {
   1          print "end line"
      }
  ```

  Modificare il file awkprof.out.

  ```bash
  Shell > vim /root/awkprof.out
  BEGIN {
      print "start line"
  }

  {
      print $0
  }

  END {
      print "end line"
  }

  Shell > df -hT | awk -f /root/awkprof.out
  start line
  Filesystem     Type      Size  Used Avail Use% Mounted on
  devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
  tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
  tmpfs          tmpfs     1.8G  8.9M  1.8G   1% /run
  tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
  /dev/nvme0n1p2 ext4       47G  2.7G   42G   6% /
  /dev/nvme0n1p1 xfs      1014M  181M  834M  18% /boot
  tmpfs          tmpfs     363M     0  363M   0% /run/user/0
  end line
  ```

7. Corrispondenza di righe (record) tramite espressioni regolari <a id="RE"></a>

  ```bash
  Shell > cat /etc/services | awk '/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'
  sunrpc          111/tcp         portmapper rpcbind      # RPC 4.0 portmapper TCP
  auth            113/tcp         authentication tap ident
  sftp            115/tcp
  uucp-path       117/tcp
  nntp            119/tcp         readnews untp   # USENET News Transfer Protocol
  ntp             123/tcp
  netbios-ns      137/tcp                         # NETBIOS Name Service
  netbios-dgm     138/tcp                         # NETBIOS Datagram Service
  netbios-ssn     139/tcp                         # NETBIOS session service
  ...
  ```

8. Operazioni logiche (AND, OR, inverso)

  logical AND: &&
  logical OR: ||
  reverse: !

  ```bash
  Shell > cat /etc/services | awk '/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ && /175/ {print $0}'
  vmnet           175/tcp                 # VMNET
  ```

  ```bash
  Shell > cat /etc/services | awk '/[^0-9a-zA-Z]9[1-9]{2}\/tcp/ || /91{2}\/tcp/ {print $0}'
  telnets         992/tcp
  imaps           993/tcp                         # IMAP over SSL
  pop3s           995/tcp                         # POP-3 over SSL
  mtp             1911/tcp                        #
  rndc            953/tcp                         # rndc control sockets (BIND 9)
  xact-backup     911/tcp                 # xact-backup
  apex-mesh       912/tcp                 # APEX relay-relay service
  apex-edge       913/tcp                 # APEX endpoint-relay service
  ftps-data       989/tcp                 # ftp protocol, data, over TLS/SSL
  nas             991/tcp                 # Netnews Administration System
  vsinet          996/tcp                 # vsinet
  maitrd          997/tcp                 #
  busboy          998/tcp                 #
  garcon          999/tcp                 #
  #puprouter      999/tcp                 #
  blockade        2911/tcp                # Blockade
  prnstatus       3911/tcp                # Printer Status Port
  cpdlc           5911/tcp                # Controller Pilot Data Link Communication
  manyone-xml     8911/tcp                # manyone-xml
  sype-transport  9911/tcp                # SYPECom Transport Protocol
  ```

  ```bash
  Shell > cat /etc/services | awk '!/(tcp)|(udp)/ {print $0}'
  discard         9/sctp                  # Discard
  discard         9/dccp                  # Discard SC:DISC
  ftp-data        20/sctp                 # FTP
  ftp             21/sctp                 # FTP
  ssh             22/sctp                 # SSH
  exp1            1021/sctp                # RFC3692-style Experiment 1 (*)                [RFC4727]
  exp1            1021/dccp                # RFC3692-style Experiment 1 (*)                [RFC4727]
  exp2            1022/sctp                # RFC3692-style Experiment 2 (*)                [RFC4727]
  exp2            1022/dccp                # RFC3692-style Experiment 2 (*)                [RFC4727]
  ltp-deepspace   1113/dccp               # Licklider Transmission Protocol
  cisco-ipsla     1167/sctp               # Cisco IP SLAs Control Protocol
  rcip-itu        2225/sctp               # Resource Connection Initiation Protocol
  m2ua            2904/sctp               # M2UA
  m3ua            2905/sctp               # M3UA
  megaco-h248     2944/sctp               # Megaco-H.248 text
  ...
  ```

9. Individua le righe consecutive per stringa e le stampa

  ```bash
  Shell > cat /etc/services | awk '/^ntp/,/^netbios/ {print $0}'
  ntp             123/tcp
  ntp             123/udp                         # Network Time Protocol
  netbios-ns      137/tcp                         # NETBIOS Name Service
  ```

  !!! info "Informazione"

  ```
   Intervallo iniziale: interrompe l'abbinamento quando la prima corrispondenza è riscontrata.
   Intervallo finale: interrompe l'abbinamento quando la prima corrispondenza è riscontrata.
  ```

## Variabile incorporata {#VARIABLES}

| Nome della variabile | Descrizione                                                                                                                                                             |
| :------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|          FS          | Il delimitatore del campo di input. Il valore predefinito è spazio o tabulazione                                                                        |
|          OFS         | Il delimitatore del campo di uscita. L'impostazione predefinita è spazio                                                                                |
|          RS          | Il delimitatore del record della riga di ingresso. L'impostazione predefinita è un carattere newline (\n)                            |
|          ORS         | Il delimitatore del record di riga in uscita. L'impostazione predefinita è un carattere newline (\n)                                 |
|          NF          | Conta il numero di campi nel record della riga corrente                                                                                                                 |
|          NR          | Conta il numero di record di riga. Dopo l'elaborazione di ogni riga di testo, il valore di questa variabile sarà +1                                     |
|          FNR         | Conta il numero di record di riga. Quando il secondo file viene elaborato, la variabile NR continua a sommarsi, ma la variabile FNR viene riconteggiata |
|         ARGC         | Il numero di argomenti della riga di comando                                                                                                                            |
|         ARGV         | Un array di argomenti della riga di comando, con il pedice che inizia con 0 e ARGV[0] che rappresenta `awk`         |
|        ARGIND        | Il valore dell'indice del file in corso di elaborazione. Il primo file è 1, il secondo è 2 e così via                                                   |
|        ENVIRON       | Variabili d'ambiente del sistema corrente                                                                                                                               |
|       FILENAME       | Visualizza il nome del file attualmente elaborato                                                                                                                       |
|      IGNORECASE      | Ignora maiuscole e minuscole                                                                                                                                            |
|        SUBSEP        | Il delimitatore del pedice nell'array, predefinito a "\034"                                                                                                             |

1. FS e OFS

  ```bash
  Shell > cat /etc/passwd | awk 'BEGIN{FS=":"}{print $1}'
  root
  bin
  daemon
  adm
  lp
  sync
  ```

  Si può anche usare l'opzione -v per assegnare valori alle variabili.

  ```bash
  Shell > cat /etc/passwd | awk -v FS=":" '{print $1}'
  root
  bin
  daemon
  adm
  lp
  sync
  ```

  Il delimitatore di output predefinito è uno spazio quando si usano le virgole per fare riferimento a più campi. È tuttavia possibile specificare separatamente il delimitatore di uscita.

  ```bash
  Shell > cat /etc/passwd | awk 'BEGIN{FS=":"}{print $1,$2}'
  root x
  bin x
  daemon x
  adm x
  lp x
  ```

  ```bash
  Shell > cat /etc/passwd | awk 'BEGIN{FS=":";OFS="\t"}{print $1,$2}'
  # or
  Shell > cat /etc/passwd | awk -v FS=":" -v OFS="\t" '{print $1,$2}'
  root    x
  bin     x
  daemon  x
  adm     x
  lp      x
  ```

2. RS e ORS

  Per impostazione predefinita, `awk` utilizza i caratteri di newline per distinguere ogni record di riga

  ```bash
  Shell > echo -e "https://example.com/books/index.html\ntitle//tcp"
  https://example.com/books/index.html
  title//tcp

  Shell > echo -e "https://example.com/books/index.html\ntitle//tcp" | awk 'BEGIN{RS="\/\/";ORS="%%"}{print $0}'
  awk: cmd. line:1: warning: escape sequence `\/' treated as plain `/'
  https:%%example.com/books/index.html
  title%%tcp
  %%             ← Why? Because "print"
  ```

3. NF

  Conta il numero di campi per riga nel testo corrente

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print NF}'
  7
  7
  7
  7
  7
  ```

  Stampa il quinto campo

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $(NF-2)}'
  root
  bin
  daemon
  adm
  lp
  ```

  Stampa l'ultimo campo

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $NF}'
  /bin/bash
  /sbin/nologin
  /sbin/nologin
  /sbin/nologin
  /sbin/nologin
  ```

  Escludere gli ultimi due campi

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$NF=" ";$(NF-1)=" ";print $0}'
  root x 0 0 root
  bin x 1 1 bin
  daemon x 2 2 daemon
  adm x 3 4 adm
  lp x 4 7 lp
  ```

  Escludere il primo campo

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$1=" ";print $0}' | sed -r 's/(^  )//g'
  x 0 0 root /root /bin/bash
  x 1 1 bin /bin /sbin/nologin
  x 2 2 daemon /sbin /sbin/nologin
  x 3 4 adm /var/adm /sbin/nologin
  x 4 7 lp /var/spool/lpd /sbin/nologin
  ```

4. NR e FNR

  ```bash
  Shell > tail -n 5 /etc/services | awk '{print NR,$0}'
  1 axio-disc       35100/udp               # Axiomatic discovery protocol
  2 pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  3 cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  4 cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  5 spremotetablet  46998/tcp               # Capture handwritten signatures
  ```

  Stampa il numero totale di righe del contenuto del file

  ```bash
  Shell > cat /etc/services | awk 'END{print NR}'
  11473
  ```

  Stampa il contenuto della riga 200

  ```bash
  Shell > cat /etc/services | awk 'NR==200'
  microsoft-ds    445/tcp
  ```

  Stampa il secondo campo alla riga 200

  ```bash
  Shell > cat /etc/services | awk 'BEGIN{RS="\n";ORS="\n"} NR==200 {print $2}'
  445/tcp
  ```

  Stampa di contenuti entro un intervallo specifico

  ```bash
  Shell > cat /etc/services | awk 'BEGIN{RS="\n";ORS="\n"} NR<=10 {print NR,$0}'
  1 # /etc/services:
  2 # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
  3 #
  4 # Network services, Internet style
  5 # IANA services version: last updated 2016-07-08
  6 #
  7 # Note that it is presently the policy of IANA to assign a single well-known
  8 # port number for both TCP and UDP; hence, most entries here have two entries
  9 # even if the protocol doesn't support UDP operations.
  10 # Updated from RFC 1700, ``Assigned Numbers'' (October 1994).  Not all ports
  ```

  Confronto tra NR e FNR

  ```bash
  Shell > head -n 3 /etc/services > /tmp/a.txt

  Shell > cat /tmp/a.txt
  # /etc/services:
  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
  #

  Shell > cat /etc/resolv.conf
  # Generated by NetworkManager
  nameserver 8.8.8.8
  nameserver 114.114.114.114

  Shell > awk '{print NR,$0}' /tmp/a.txt /etc/resolv.conf
  1 # /etc/services:
  2 # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
  3 #
  4 # Generated by NetworkManager
  5 nameserver 8.8.8.8
  6 nameserver 114.114.114.114

  Shell > awk '{print FNR,$0}' /tmp/a.txt /etc/resolv.conf
  1 # /etc/services:
  2 # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
  3 #
  1 # Generated by NetworkManager
  2 nameserver 8.8.8.8
  3 nameserver 114.114.114.114
  ```

5. ARGC e ARGV

  ```bash
  Shell > awk 'BEGIN{print ARGC}' log dump long
  4
  Shell > awk 'BEGIN{print ARGV[0]}' log dump long
  awk
  Shell > awk 'BEGIN{print ARGV[1]}' log dump long
  log
  Shell > awk 'BEGIN{print ARGV[2]}' log dump long
  dump
  ```

6. ARGIND

  Questa variabile è usata principalmente per determinare il file su cui sta lavorando il programma `awk`.

  ```bash
  Shell > awk '{print ARGIND,$0}' /etc/hostname /etc/resolv.conf
  1 Master
  2 # Generated by NetworkManager
  2 nameserver 8.8.8.8
  2 nameserver 114.114.114.114
  ```

7. ENVIRON

  Nei programmi `awk` è possibile fare riferimento a sistemi operativi o a variabili definite dall'utente.

  ```bash
  Shell > echo ${SSH_CLIENT}
  192.168.100.2 6969 22

  Shell > awk 'BEGIN{print ENVIRON["SSH_CLIENT"]}'
  192.168.100.2 6969 22

  Shell > export a=123
  Shell > env | grep -w a
  a=123
  Shell > awk 'BEGIN{print ENVIRON["a"]}'
  123
  Shell > unset a
  ```

8. FILENAME

  ```bash
  Shell > awk 'BEGIN{RS="\n";ORS="\n"} NR=FNR {print ARGIND,FILENAME"---"$0}' /etc/hostname /etc/resolv.conf /etc/rocky-release
  1 /etc/hostname---Master
  2 /etc/resolv.conf---# Generated by NetworkManager
  2 /etc/resolv.conf---nameserver 8.8.8.8
  2 /etc/resolv.conf---nameserver 114.114.114.114
  3 /etc/rocky-release---Rocky Linux release 8.9 (Green Obsidian)
  ```

9. IGNORECASE

  Questa variabile è utile se si vogliono usare le espressioni regolari in `awk` e ignorare il caso.

  ```bash
  Shell > awk 'BEGIN{IGNORECASE=1;RS="\n";ORS="\n"} /^(SSH)|^(ftp)/ {print $0}' /etc/services
  ftp-data        20/tcp
  ftp-data        20/udp
  ftp             21/tcp
  ftp             21/udp          fsp fspd
  ssh             22/tcp                          # The Secure Shell (SSH) Protocol
  ssh             22/udp                          # The Secure Shell (SSH) Protocol
  ftp-data        20/sctp                 # FTP
  ftp             21/sctp                 # FTP
  ssh             22/sctp                 # SSH
  ftp-agent       574/tcp                 # FTP Software Agent System
  ftp-agent       574/udp                 # FTP Software Agent System
  sshell          614/tcp                 # SSLshell
  sshell          614/udp                 #       SSLshell
  ftps-data       989/tcp                 # ftp protocol, data, over TLS/SSL
  ftps-data       989/udp                 # ftp protocol, data, over TLS/SSL
  ftps            990/tcp                 # ftp protocol, control, over TLS/SSL
  ftps            990/udp                 # ftp protocol, control, over TLS/SSL
  ssh-mgmt        17235/tcp               # SSH Tectia Manager
  ssh-mgmt        17235/udp               # SSH Tectia Manager
  ```

  ```bash
  Shell > awk 'BEGIN{IGNORECASE=1;RS="\n";ORS="\n"} /^(SMTP)\s/,/^(TFTP)\s/ {print $0}' /etc/services
  smtp            25/tcp          mail
  smtp            25/udp          mail
  time            37/tcp          timserver
  time            37/udp          timserver
  rlp             39/tcp          resource        # resource location
  rlp             39/udp          resource        # resource location
  nameserver      42/tcp          name            # IEN 116
  nameserver      42/udp          name            # IEN 116
  nicname         43/tcp          whois
  nicname         43/udp          whois
  tacacs          49/tcp                          # Login Host Protocol (TACACS)
  tacacs          49/udp                          # Login Host Protocol (TACACS)
  re-mail-ck      50/tcp                          # Remote Mail Checking Protocol
  re-mail-ck      50/udp                          # Remote Mail Checking Protocol
  domain          53/tcp                          # name-domain server
  domain          53/udp
  whois++         63/tcp          whoispp
  whois++         63/udp          whoispp
  bootps          67/tcp                          # BOOTP server
  bootps          67/udp
  bootpc          68/tcp          dhcpc           # BOOTP client
  bootpc          68/udp          dhcpc
  tftp            69/tcp
  ```

## Operatore

| Operatore                                                                | Descrizione                                          |
| ------------------------------------------------------------------------ | ---------------------------------------------------- |
| (...) | Raggruppamento                                       |
| $n                                                                       | Riferimento di campo                                 |
| ++                                                                       | Incrementale                                         |
| --                                                                       | Decrementale                                         |
| +                                                                        | Segno matematico più                                 |
| -                                                                        | Segno matematico meno                                |
| !                                                                        | Negazione                                            |
| \*                                                                       | Segno di moltiplicazione matematica                  |
| /                                                                        | Segno di divisione matematica                        |
| %                                                                        | Modulo operation                                     |
| in                                                                       | Elementi di una matrice                              |
| &&                               | Logica e operazioni                                  |
| \\|\\|                                                                 | Operazione OR logica                                 |
| ?:                                                       | Abbreviazione delle espressioni condizionali         |
| ~                                                        | Un'altra rappresentazione delle espressioni regolari |
| !~                                                       | Espressione regolare inversa                         |

!!! note "Nota"

````
Nel programma `awk`, le seguenti espressioni saranno giudicate **false**:

* Il numero è 0;
* Stringa vuota;
* Valore non definito.

```bash
Shell > awk 'BEGIN{n=0;if(n) print "Ture";else print "False"}'
False
Shell > awk 'BEGIN{s="";if(s) print "True";else print "False"}'
False
Shell > awk 'BEGIN{if(t) print "True";else print "Flase"}'
False
```
````

1. Punto esclamativo

  Stampa le righe dispari:

  ```bash
  Shell > seq 1 10 | awk 'i=!i {print $0}'
  1
  3
  5
  7
  9
  ```

  !!! domanda

  ```
   **Perché?**
   **Leggi la prima riga**: Perché "i" non ha un valore assegnato, quindi "i=!i" indica TRUE.
   **Leggi la seconda riga**: A questo punto, "i=!i" indica FALSE.
   E così via, la riga stampata finale è un numero dispari.
  ```

  Stampare le righe pari:

  ```bash
  Shell > seq 1 10 | awk '!(i=!i)'
  # or
  Shell > seq 1 10 | awk '!(i=!i) {print $0}'
  2
  4
  6
  8
  10
  ```

  !!! note "Nota"

  ```
   Come si può vedere, a volte si può ignorare la sintassi della parte "action", che per impostazione predefinita è equivalente a "{print $0}".
  ```

2. Inversione

  ```bash
  Shell > cat /etc/services | awk '!/(tcp)|(udp)|(^#)|(^$)/ {print $0}'
  http            80/sctp                         # HyperText Transfer Protocol
  bgp             179/sctp
  https           443/sctp                        # http protocol over TLS/SSL
  h323hostcall    1720/sctp                       # H.323 Call Control
  nfs             2049/sctp       nfsd shilp      # Network File System
  rtmp            1/ddp                           # Routing Table Maintenance Protocol
  nbp             2/ddp                           # Name Binding Protocol
  echo            4/ddp                           # AppleTalk Echo Protocol
  zip             6/ddp                           # Zone Information Protocol
  discard         9/sctp                  # Discard
  discard         9/dccp                  # Discard SC:DISC
  ...
  ```

3. Operazioni di base in matematica

  ```bash
  Shell > echo -e "36\n40\n50" | awk '{print $0+1}'
  37
  41

  Shell > echo -e "30\t5\t8\n11\t20\t34"
  30      5       8
  11      20      34
  Shell > echo -e "30\t5\t8\n11\t20\t34" | awk '{print $2*2+1}'
  11
  41
  ```

  Può essere utilizzato anche nel "modello":

  ```bash
  Shell > cat -n /etc/services | awk  '/^[1-9]*/ && $1%2==0 {print $0}'
  ...
  24  tcpmux          1/udp                           # TCP port service multiplexer
  26  rje             5/udp                           # Remote Job Entry
  28  echo            7/udp
  30  discard         9/udp           sink null
  32  systat          11/udp          users
  34  daytime         13/udp
  36  qotd            17/udp          quote
  ...

  Shell > cat -n /etc/services | awk  '/^[1-9]*/ && $1%2!=0 {print $0}'
  ...
  23  tcpmux          1/tcp                           # TCP port service multiplexer
  25  rje             5/tcp                           # Remote Job Entry
  27  echo            7/tcp
  29  discard         9/tcp           sink null
  31  systat          11/tcp          users
  ...
  ```

4. Simbolo pipe

  È possibile utilizzare il comando bash nel programma awk, ad esempio:

  ```bash
  Shell > echo -e "6\n3\n9\n8" | awk '{print $0 | "sort"}'
  3
  6
  8
  9
  ```

  !!! info "Informazione"

  ```
   Fate attenzione! È necessario utilizzare le doppie virgolette per includere il comando.
  ```

5. Espressione regolare

  [Qui](#RE), vengono trattati esempi di base di espressioni regolari. È possibile utilizzare le espressioni regolari sui record di riga.

  ```bash
  Shell > cat /etc/services | awk '/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'

  # Equivalente a:

  Shell > cat /etc/services | awk '$0~/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'
  ```

  Se il file contiene una grande quantità di testo, è possibile utilizzare le espressioni regolari anche per i campi, per migliorare l'efficienza dell'elaborazione. L'esempio di utilizzo è il seguente:

  ```bash
  Shell > cat /etc/services | awk '$0~/^(ssh)/ && $2~/tcp/ {print $0}'
  ssh             22/tcp                          # The Secure Shell (SSH) Protocol
  sshell          614/tcp                 # SSLshell
  ssh-mgmt        17235/tcp               # SSH Tectia Manager

  Shell > cat /etc/services | grep -v -E "(^#)|(^$)" | awk '$2!~/(tcp)|(udp)/ {print $0}'
  http            80/sctp                         # HyperText Transfer Protocol
  bgp             179/sctp
  https           443/sctp                        # http protocol over TLS/SSL
  h323hostcall    1720/sctp                       # H.323 Call Control
  nfs             2049/sctp       nfsd shilp      # Network File System
  rtmp            1/ddp                           # Routing Table Maintenance Protocol
  nbp             2/ddp                           # Name Binding Protocol
  ...
  ```

## Controllo del flusso

1. Istruzione **if**

  Il formato della sintassi di base è: `dichiarazione if (condizione) [ dichiarazione else ]`

  Esempio di utilizzo di un ramo singolo di un'istruzione if:

  ```bash
  Shell > cat /etc/services | awk '{if(NR==110) print $0}'
  pop3            110/udp         pop-3
  ```

  La condizione viene determinata come espressione regolare:

  ```bash
  Shell > cat /etc/services | awk '{if(/^(ftp)\s|^(ssh)\s/) print $0}'
  ftp             21/tcp
  ftp             21/udp          fsp fspd
  ssh             22/tcp                          # The Secure Shell (SSH) Protocol
  ssh             22/udp                          # The Secure Shell (SSH) Protocol
  ftp             21/sctp                 # FTP
  ssh             22/sctp                 # SSH
  ```

  Ramo doppio:

  ```bash
  Shell > seq 1 10 | awk '{if($0==10) print $0 ; else print "False"}'
  False
  False
  False
  False
  False
  False
  False
  False
  False
  10
  ```

  Rami multipli:

  ```bash
  Shell > cat /etc/services | awk '{ \ 
  if($1~/netbios/) 
      {print $0} 
  else if($2~/175/) 
      {print "175"} 
  else if($2~/137/) 
      {print "137"} 
  else {print "no"} 
  }'
  ```

2. Istruzione **while**

  Il formato della sintassi di base è - `while (condizione) statement`

  Eseguire l'attraversamento e la stampa dei campi di tutti i record di riga.

  ```bash
  Shell > tail -n 2 /etc/services
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures

  Shell > tail -n 2 /etc/services | awk '{ \
  i=1;
  while(i<=NF){print $i;i++}
  }'

  cloudcheck
  45514/tcp
  #
  ASSIA
  CloudCheck
  WiFi
  Management
  System
  spremotetablet
  46998/tcp
  #
  Capture
  handwritten
  signatures
  ```

3. Istruzione **for**

  Il formato della sintassi di base è - `for (expr1; expr2; expr3) dichiarazione`

  Eseguire l'attraversamento e la stampa dei campi di tutti i record di riga.

  ```bash
  Shell > tail -n 2 /etc/services | awk '{ \
  for(i=1;i<=NF;i++) print $i
  }'
  ```

  Stampa i campi di ogni riga di record in ordine inverso.

  ```bash
  Shell > tail -n 2 /etc/services | awk '{ \
  for(i=NF;i>=1;i--) print $i
  }'

  System
  Management
  WiFi
  CloudCheck
  ASSIA
  #
  45514/tcp
  cloudcheck
  signatures
  handwritten
  Capture
  #
  46998/tcp
  spremotetablet
  ```

  Stampa ogni riga di record in direzione opposta.

  ```bash
  Shell > tail -n 2 /etc/services | awk  '{ \
  for(i=NF;i>=1;i--) {printf $i" "};
  print ""
  }'

  System Management WiFi CloudCheck ASSIA # 45514/tcp cloudcheck
  signatures handwritten Capture # 46998/tcp spremotetablet
  ```

4. Dichiarazione **break** e dichiarazione **continue**.<a id="bc"></a>

  Il confronto tra i due è il seguente:

  ```bash
  Shell > awk 'BEGIN{  \
  for(i=1;i<=10;i++)
    {
      if(i==3) {break};
      print i
    }
  }'

  1
  2
  ```

  ```bash
  Shell > awk 'BEGIN{  \
  for(i=1;i<=10;i++)
    {
      if(i==3) {continue};
      print i
    }
  }'

  1                                                                                                                           
  2                                                                                                                                         
  4                                                                                                                                         
  5                                                                                                                                         
  6                                                                                                                                         
  7                                                                                                                                         
  8                                                                                                                                         
  9                                                                                                                                         
  10
  ```

5. Istruzione **exit**

  È possibile specificare un valore di ritorno nell'intervallo [0,255].

  Il formato della sintassi di base è - `exit [espressione]`

  ```bash
  Shell > seq 1 10 | awk '{
    if($0~/5/) exit "135"
  }'

  Shell > echo $?
  135
  ```

## Array

**array**: Un insieme di dati dello stesso tipo disposti in un certo ordine. Ogni dato di una matrice è chiamato elemento.

Come la maggior parte dei linguaggi di programmazione, `awk` supporta anche gli array, che si dividono in **array indicizzati (con numeri come pedici)** e **array associativi (con stringhe come pedici)**.

`awk` ha molte funzioni e quelle relative agli array sono:

- **length(Array_Name)** - Ottiene la lunghezza dell'array.

1. Array personalizzato

  Formato - \`Nome_array[Indice]=Valore'

  ```bash
  Shell > awk 'BEGIN{a1[0]="test0" ; a1[1]="s1"; print a1[0]}'
  test0
  ```

  Ottiene la lunghezza dell'array:

  ```bash
  Shell > awk 'BEGIN{name[-1]="jimcat8" ; name[3]="jack" ; print length(name)}'
  2
  ```

  Memorizza tutti gli utenti GNU/Linux in un array:

  ```bash
  Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[2]}'
  bin
  Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[1]}'
  root
  ```

  !!! info "Informazione"

  ````
   Il pedice numerico di un array `awk` può essere un intero positivo, un intero negativo, una stringa o 0, quindi il pedice numerico di un array `awk` non ha il concetto di valore iniziale. Non è la stessa cosa degli array in `bash`.

   ```bash
   Shell > arr1=(2 10 30 string1)
   Shell > echo "${arr1[0]}"
   2
   Shell > unset arr1
   ```
  ````

2. Eliminare l'array

  Formato `delete Array_Name`

3. Eliminare un elemento da un array

  Formato `delete Array_Name[Index]`

4. Array di attraversamento

  È possibile utilizzare l'istruzione **for**, adatta ai casi in cui il pedice della matrice è sconosciuto:

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" ' \
  {
    username[NR]=$1
  }
  END {
    for(i in username)
    print username[i],i
  }
  '

  root 1
  bin 2
  daemon 3
  adm 4
  lp 5
  ```

  Se il pedice di una matrice è regolare, è possibile utilizzare questa forma dell'istruzione **for**:

  ```bash
  Shell > cat /etc/passwd | awk -F ":" ' \
  {
    username[NR]=$1
  }
  END{
    for(i=1;i<=NR;i++)
    print username[i],i
  }
  '

  root 1
  bin 2
  daemon 3
  adm 4
  lp 5
  sync 6
  shutdown 7
  halt 8
  ...
  ```

5. Utilizzare "++" come pedice della matrice

  ```bash
  Shell > tail -n 5 /etc/group | awk -F ":" '\
  {
    a[x++]=$1
  }
  END{
    for(i in a)
    print a[i],i
  }
  '

  slocate 0
  unbound 1
  docker 2
  cgred 3
  redis 4
  ```

6. Utilizzare un campo come pedice di un array

  ```bash
  Shell > tail -n 5 /etc/group | awk -F ":" '\
  {
    a[$1]=$3
  }
  END{
    for(i in a)
    print a[i],i
  }
  '

  991 docker
  21 slocate
  989 redis
  992 unbound
  990 cgred
  ```

7. Conta il numero di occorrenze dello stesso campo

  Conta il numero di occorrenze dello stesso indirizzo IPv4. Idea di base:

  - Utilizzare innanzitutto il comando `grep` per filtrare tutti gli indirizzi IPv4
  - Poi lo si consegna al programma `awk` per l'elaborazione

  ```bash
  Shell > cat /var/log/secure | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | awk ' \
  {
    a[$1]++
  } 
  END{
    for(v in a) print a[v],v
  }
  '

  4 0.0.0.0
  4 192.168.100.2
  ```

  !!! info "Informazione"

  ```
   `a[$1]++` equivale a `a[$1]+=1`
  ```

  Conta il numero di occorrenze delle parole, indipendentemente dal caso. Idea di base:

  - Dividere tutti i campi in più righe di record
  - Poi lo si consegna al programma `awk` per l'elaborazione

  ```bash
  Shell > cat /etc/services | awk -F " " '{for(i=1;i<=NF;i++) print $i}'

  Shell > cat /etc/services | awk -F " " '{for(i=1;i<=NF;i++) print $i}' | awk '\
  BEGIN{IGNORECASE=1;OFS="\t"} /^netbios$/  ||  /^ftp$/  {a[$1]++}  END{for(v in a) print a[v],v}
  '

  3       NETBIOS
  18      FTP
  7       ftp

  Shell > cat /etc/services | awk -F " " '{ for(i=1;i<=NF;i++) print $i }' | awk '\
  BEGIN{IGNORECASE=1;OFS="\t"}  /^netbios$/  ||  /^ftp$/   {a[$1]++}  END{for(v in a)  \
  if(a[v]>=5) print a[v],v}
  '

  18      FTP
  7       ftp
  ```

  È possibile prima filtrare record di riga specifici e poi eseguire statistiche, ad esempio:

  ```bash
  Shell > ss -tulnp | awk -F " "  '/tcp/ {a[$2]++} END{for(i in a) print a[i],i}'
  2 LISTEN  
  ```

8. Stampa delle righe in base al numero di occorrenze di un campo specifico

  ```bash
  Shell > tail /etc/services
  aigairserver    21221/tcp               # Services for Air Server
  ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
  edi_service     34567/udp               # dhanalakshmi.org EDI Service
  axio-disc       35100/tcp               # Axiomatic discovery protocol
  axio-disc       35100/udp               # Axiomatic discovery protocol
  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures

  Shell > tail /etc/services | awk 'a[$1]++ {print $0}'
  axio-disc       35100/udp               # Axiomatic discovery protocol
  ```

  Inverso:

  ```bash
  Shell > tail /etc/services | awk '!a[$1]++ {print $0}'
  aigairserver    21221/tcp               # Services for Air Server
  ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
  edi_service     34567/udp               # dhanalakshmi.org EDI Service
  axio-disc       35100/tcp               # Axiomatic discovery protocol
  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures
  ```

9. Array multidimensionale

  Il programma \`awk' non supporta gli array multidimensionali, ma il supporto per gli array multidimensionali è ottenibile attraverso la simulazione. Per impostazione predefinita, "\034" è il delimitatore per il pedice di una matrice multidimensionale.

  Tenere presente le seguenti differenze quando si utilizzano array multidimensionali:

  ```bash
  Shell > awk 'BEGIN{ a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
  200 20
  300 30
  100 1,0
  ```

  Ridefinire il delimitatore:

  ```bash
  Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
  300 3----0
  200 2----0
  100 1,0
  ```

  Riordina：

  ```bash
  Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i | "sort" }'
  100 1,0
  200 2----0
  300 3----0
  ```

  Contare il numero di volte in cui il campo appare:

  ```bash
  Shell > cat c.txt
  A 192.168.1.1 HTTP
  B 192.168.1.2 HTTP
  B 192.168.1.2 MYSQL
  C 192.168.1.1 MYSQL
  C 192.168.1.1 MQ
  D 192.168.1.4 NGINX

  Shell > cat c.txt | awk 'BEGIN{SUBSEP="----"} {a[$1,$2]++} END{for(i in a) print a[i],i}'
  1 A----192.168.1.1
  2 B----192.168.1.2
  2 C----192.168.1.1
  1 D----192.168.1.4
  ```

## Funzione integrata

| Nome della funzione                                                                                                                                                                                                      | Descrizione                                                                                                                                                                                                                                                                                                                 |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| int(expr)                                                                                                                                                                                             | Tronca come numero intero                                                                                                                                                                                                                                                                                                   |
| sqrt(expr)                                                                                                                                                                                            | Radice quadrata                                                                                                                                                                                                                                                                                                             |
| rand()                                                                                                                                                                                                | Restituisce un numero casuale N con un intervallo di (0,1). Il risultato non è che ogni corsa è un numero casuale, ma che rimane lo stesso.                                                                                                                              |
| srand([expr])                                                                                                                                     | Utilizzare "expr" per generare numeri casuali. Se "expr" non è specificato, per impostazione predefinita viene utilizzata l'ora corrente come seme; se esiste un seme, viene utilizzato il numero casuale generato.                                                                         |
| asort(a,b)                                                                                                                                                                                            | Gli elementi della matrice "a" vengono riordinati (in modo lessicografico) e memorizzati nella nuova matrice "b", con il pedice della matrice "b" che inizia con 1. Questa funzione restituisce il numero di elementi della matrice.                                     |
| asorti(a,b)                                                                                                                                                                                           | Riordinare i pedici della matrice "a" e memorizzare il pedice ordinato nella nuova matrice "b" come elemento, con il pedice della matrice "b" che inizia a 1.                                                                                                                                               |
| sub(r,s[,t])                                                                                                                                      | Utilizza l'espressione regolare "r" per confrontare i record in ingresso e sostituisce il risultato corrispondente con "s". "t" è opzionale e indica la sostituzione di un determinato campo. La funzione restituisce il numero di sostituzioni - 0 o 1. Simile a `sed s//` |
| gsub(r,s[,t])                                                                                                                                     | Sostituzione globale. "t" è opzionale e indica la sostituzione di un determinato campo. Se "t" viene ignorato, indica una sostituzione globale. Simile a `sed s///g`                                                                                                        |
| gensub(r,s,h[,t])                                                                                                                                 | L'espressione regolare "r" corrisponde ai record di input e sostituisce il risultato della corrispondenza con "s". "t" è opzionale e indica la sostituzione di un determinato campo. "h" rappresenta la sostituzione della posizione di indice specificata                                  |
| index(s,t)                                                                                                                                                                                            | Restituisce la posizione dell'indice della stringa "t" nella stringa "s" (l'indice della stringa parte da 1). Se la funzione restituisce 0, significa che non esiste                                                                                                                     |
| length([s])                                                                                                                                       | Restituisce la lunghezza di "s"                                                                                                                                                                                                                                                                                             |
| match(s,r[,a])                                                                                                                                    | Verifica se la stringa "s" contiene la stringa "r". Se inclusa, restituisce la posizione dell'indice di "r" al suo interno (indice di stringa a partire da 1). In caso contrario, restituire 0                                                                           |
| split(s,a[,r[,seps]])                                                                         | Divide la stringa "s" in un array "a" in base al delimitatore "seps". Il pedice della matrice inizia con 1.                                                                                                                                                                                 |
| substr(s,i[,n])                                                                                                                                   | Intercettare la stringa. "s" rappresenta la stringa da elaborare; "i" indica la posizione dell'indice della stringa; "n" è la lunghezza. Se non si specifica "n", significa intercettare tutte le parti rimanenti                                                                           |
| tolower(str)                                                                                                                                                                                          | Converte tutte le stringhe in minuscolo                                                                                                                                                                                                                                                                                     |
| toupper(str)                                                                                                                                                                                          | Converte tutte le stringhe in maiuscolo                                                                                                                                                                                                                                                                                     |
| systime()                                                                                                                                                                                             | Timestamp corrente                                                                                                                                                                                                                                                                                                          |
| strftime([format[,timestamp[,utc-flag]]]) | Formattazione dell'ora di uscita. Converte il timestamp in una stringa                                                                                                                                                                                                                                      |

1. Funzione **int**

  ```bash
  Shell > echo -e "qwer123\n123\nabc\n123abc123\n100.55\n-155.27"
  qwer123
  123
  abc
  123abc123
  100.55
  -155.27

  Shell > echo -e "qwer123\n123\nabc\n123abc123\n100.55\n-155.27" | awk '{print int($1)}'
  0
  123
  0
  123
  100
  -155
  ```

  Come si può notare, la funzione int funziona solo per i numeri e, quando incontra una stringa, la converte a 0. Quando incontra una stringa che inizia con un numero, la tronca.

2. Funzione **sqrt**

  ```bash
  Shell > awk 'BEGIN{print sqrt(9)}'
  3
  ```

3. Funzioni **rand** e **srand**

  L'esempio di utilizzo della funzione rand è il seguente:

  ```bash
  Shell > awk 'BEGIN{print rand()}'
  0.924046
  Shell > awk 'BEGIN{print rand()}'
  0.924046
  Shell > awk 'BEGIN{print rand()}'
  0.924046
  ```

  L'esempio di utilizzo della funzione srand è il seguente:

  ```bash
  Shell > awk 'BEGIN{srand() ; print rand()}'
  0.975495
  Shell > awk 'BEGIN{srand() ; print rand()}'
  0.99187
  Shell > awk 'BEGIN{srand() ; print rand()}'
  0.069002
  ```

  Genera un numero intero compreso nell'intervallo (0,100):

  ```bash
  Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
  56
  Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
  33
  Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
  42
  ```

4. Funzioni **asort** e **asorti**

  ```bash
  Shell > cat /etc/passwd | awk -F ":" '{a[NR]=$1} END{anu=asort(a,b) ; for(i=1;i<=anu;i++) print i,b[i]}'
  1 adm
  2 bin
  3 chrony
  4 daemon
  5 dbus
  6 ftp
  7 games
  8 halt
  9 lp
  10 mail
  11 nobody
  12 operator
  13 polkitd
  14 redis
  15 root
  16 shutdown
  17 sshd
  18 sssd
  19 sync
  20 systemd-coredump
  21 systemd-resolve
  22 tss
  23 unbound

  Shell > awk 'BEGIN{a[1]=1000 ; a[2]=200 ; a[3]=30 ; a[4]="admin" ; a[5]="Admin" ; \
  a[6]="12string" ; a[7]=-1 ; a[8]=-10 ; a[9]=-20 ; a[10]=-21 ;nu=asort(a,b) ; for(i=1;i<=nu;i++) print i,b[i]}'
  1 -21
  2 -20
  3 -10
  4 -1
  5 30
  6 200
  7 1000
  8 12string
  9 Admin
  10 admin
  ```

  !!! info "Informazione"

  ```
   Regole di ordinamento:

  * I numeri hanno una priorità maggiore rispetto alle stringhe e sono disposti in ordine crescente.
  * Disporre le stringhe in ordine crescente nel dizionario
  ```

  Se si utilizza la funzione **asorti**, l'esempio è il seguente:

  ```bash
  Shell > awk 'BEGIN{ a[-11]=1000 ; a[-2]=200 ; a[-10]=30 ; a[-21]="admin" ; a[41]="Admin" ; \
  a[30]="12string" ; a["root"]="rootstr" ; a["Root"]="r1" ; nu=asorti(a,b) ; for(i in b) print i,b[i] }'
  1 -10
  2 -11
  3 -2
  4 -21
  5 30
  6 41
  7 Root
  8 root
  ```

  !!! info "Informazione"

  ```
   Regole di ordinamento:

  * I numeri hanno la priorità sulle stringhe
  * Se si incontra un numero negativo, viene confrontata la prima cifra da sinistra. Se è uguale, viene confrontata la seconda cifra e così via.
  * Se viene incontrato un numero positivo, verrà disposto in ordine crescente.
  * Disporre le stringhe in ordine crescente nel dizionario
  ```

5. Funzioni **sub** e **gsub**

  ```bash
  Shell > cat /etc/services | awk '/netbios/ {sub(/tcp/,"test") ; print $0 }'
  netbios-ns      137/test                         # NETBIOS Name Service
  netbios-ns      137/udp
  netbios-dgm     138/test                         # NETBIOS Datagram Service
  netbios-dgm     138/udp
  netbios-ssn     139/test                         # NETBIOS session service
  netbios-ssn     139/udp

  Shell > cat /etc/services |  awk '/^ftp/ && /21\/tcp/  {print $0}'
  ftp             21/tcp
    ↑                  ↑
  Shell > cat /etc/services |  awk 'BEGIN{OFS="\t"}  /^ftp/ && /21\/tcp/   {gsub(/p/,"P",$2) ; print $0}'
  ftp     21/tcP
               ↑
  Shell > cat /etc/services |  awk 'BEGIN{OFS="\t"}  /^ftp/ && /21\/tcp/   {gsub(/p/,"P") ; print $0}'
  ftP             21/tcP
    ↑                  ↑
  ```

  Come per il comando \`sed', è possibile utilizzare il simbolo "&" per fare riferimento a stringhe già abbinate.

  ```bash
  Shell > vim /tmp/tmp-file1.txt
  A 192.168.1.1 HTTP
  B 192.168.1.2 HTTP
  B 192.168.1.2 MYSQL
  C 192.168.1.1 MYSQL
  C 192.168.1.1 MQ
  D 192.168.1.4 NGINX

  # Add a line of text before the second line
  Shell > cat /tmp/tmp-file1.txt | awk 'NR==2 {gsub(/.*/,"add a line\n&")} {print $0}'
  A 192.168.1.1 HTTP
  add a line
  B 192.168.1.2 HTTP
  B 192.168.1.2 MYSQL
  C 192.168.1.1 MYSQL
  C 192.168.1.1 MQ
  D 192.168.1.4 NGINX

  # Add a string after the IP address in the second line
  Shell > cat /tmp/tmp-file1.txt | awk 'NR==2 {gsub(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/,"&\tSTRING")} {print $0}'
  A 192.168.1.1 HTTP
  B 192.168.1.2   STRING HTTP
  B 192.168.1.2 MYSQL
  C 192.168.1.1 MYSQL
  C 192.168.1.1 MQ
  D 192.168.1.4 NGINX
  ```

6. Funzione **index**

  ```bash
  Shell > tail -n 5 /etc/services
  axio-disc       35100/udp               # Axiomatic discovery protocol
  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures

  Shell > tail -n 5 /etc/services | awk '{print index($2,"tcp")}'
  0
  7
  0
  7
  7
  ```

7. Funzione **length**

  ```bash
  # La lunghezza del campo di output
  Shell > tail -n 5 /etc/services | awk '{print length($1)}'
  9
  8
  15
  10
  14

  # La lunghezza dell'insieme di output
  Shell > cat /etc/passwd | awk -F ":" 'a[NR]=$1 END{print length(a)}'
  22
  ```

8. Funzione **match**

  ```bash
  Shell > echo -e "1592abc144qszd\n144bc\nbn"
  1592abc144qszd
  144bc
  bn

  Shell > echo -e "1592abc144qszd\n144bc\nbn" | awk '{print match($1,144)}'
  8
  1
  0
  ```

9. Funzione **split**

  ```bash
  Shell > echo "365%tmp%dir%number" | awk '{split($1,a1,"%") ; for(i in a1) print i,a1[i]}'
  1 365
  2 tmp
  3 dir
  4 number
  ```

10. Funzione **substr**

  ```bash
  Shell > head -n 5 /etc/passwd
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

  # I need this part of the content - "emon:/sbin:/sbin/nologin"
  Shell > head -n 5 /etc/passwd | awk '/daemon/ {print substr($0,16)}'
  emon:/sbin:/sbin/nologin

  Shell > tail -n 5 /etc/services
  axio-disc       35100/udp               # Axiomatic discovery protocol
  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures

  # I need this part of the content - "tablet"
  Shell > tail  -n 5 /etc/services | awk '/^sp/ {print substr($1,9)}'
  tablet
  ```

11. Funzioni **tolower** e **toupper**

  ```bash
  Shell > echo -e "AbcD123\nqweR" | awk '{print tolower($0)}'
  abcd123
  qwer

  Shell > tail -n 5 /etc/services | awk '{print toupper($0)}'
  AXIO-DISC       35100/UDP               # AXIOMATIC DISCOVERY PROTOCOL
  PMWEBAPI        44323/TCP               # PERFORMANCE CO-PILOT CLIENT HTTP API
  CLOUDCHECK-PING 45514/UDP               # ASSIA CLOUDCHECK WIFI MANAGEMENT KEEPALIVE
  CLOUDCHECK      45514/TCP               # ASSIA CLOUDCHECK WIFI MANAGEMENT SYSTEM
  SPREMOTETABLET  46998/TCP               # CAPTURE HANDWRITTEN SIGNATURES
  ```

12. Funzioni che trattano l'ora e la data

  \*\*Che cos'è un timestamp UNIX?
  Secondo la storia dello sviluppo di GNU/Linux, UNIX V1 è nato nel 1971 e il libro "UNIX Programmer's Manual" è stato pubblicato il 3 novembre dello stesso anno, il che definisce il 1970-01-01 come data di riferimento dell'inizio di UNIX.

  La conversione tra un timestamp e una data naturale in giorni:

  ```bash
  Shell > echo "$(( $(date --date="2024/01/06" +%s)/86400 + 1 ))"
  19728

  Shell > date -d "1970-01-01 19728days"
  Sat Jan  6 00:00:00 CST 2024
  ```

  La conversione tra un timestamp e una data naturale in secondi:

  ```bash
  Shell > echo "$(date --date="2024/01/06 17:12:00" +%s)"
  1704532320

  Shell > echo "$(date --date='@1704532320')"
  Sat Jan  6 17:12:00 CST 2024
  ```

  La conversione tra la data naturale e il timestamp UNIX nel programma `awk`:

  ```bash
  Shell > awk 'BEGIN{print systime()}'
  1704532597

  Shell > echo "1704532597" | awk '{print strftime("%Y-%m-%d %H:%M:%S",$0)}'
  2024-01-06 17:16:37
  ```

## Istruzione I/O

| Istruzione                                                                     | Descrizione                                                                                                                                                                                                                                                                                                                                                                                                          |
| :----------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| getline                                                                        | Leggere il successivo record di riga corrispondente e assegnarlo a "$0". Il valore di ritorno è 1: indica che sono stati letti i record di riga pertinenti. Il valore di ritorno è 0: indica che è stata letta l'ultima riga. Il valore di ritorno è negativo: Indica che si è verificato un errore. |
| getline var                                                                    | Leggere il prossimo record di riga corrispondente e assegnarlo alla variabile "var"                                                                                                                                                                                                                                                                                                                                  |
| command \\| getline [var] | Assegnare il risultato a "$0" o alla variabile "var"                                                                                                                                                                                                                                                                                                                                                                 |
| next                                                                           | Interrompere il record di input corrente ed eseguire le seguenti azioni                                                                                                                                                                                                                                                                                                                                              |
| print                                                                          | Stampare il risultato                                                                                                                                                                                                                                                                                                                                                                                                |
| printf                                                                         | Vedere la sezione relativa a questo comando in questo documento                                                                                                                                                                                                                                                                                                                                                      |
| system(cmd-line)                                            | Esegue il comando e restituisce il codice di stato. 0 indica che il comando è stato eseguito con successo; non-0 indica che l'esecuzione non è riuscita                                                                                                                                                                                                                                              |
| print ... >> file              | Redirezione output                                                                                                                                                                                                                                                                                                                                                                                                   |
| print ... \\| command         | Stampare l'output e utilizzarlo come input per il comando                                                                                                                                                                                                                                                                                                                                                            |

1. getline

  ```bash
  Shell > seq 1 10 | awk '/3/ || /6/ {getline ; print $0}'
  4
  7

  Shell > seq 1 10 | awk '/3/ || /6/ {print $0 ; getline ; print $0}'
  3
  4
  6
  7
  ```

  Utilizzando le funzioni che abbiamo imparato in precedenza e il simbolo "&", possiamo:

  ```bash
  Shell > tail -n 5 /etc/services | awk '/45514\/tcp/ {getline ; gsub(/.*/ , "&\tSTRING1") ; print $0}'
  spremotetablet  46998/tcp               # Capture handwritten signatures        STRING1

  Shell > tail -n 5 /etc/services | awk '/45514\/tcp/ {print $0 ; getline; gsub(/.*/,"&\tSTRING2") } {print $0}'
  axio-disc       35100/udp               # Axiomatic discovery protocol
  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  spremotetablet  46998/tcp               # Capture handwritten signatures        STRING2
  ```

  Stampa le righe pari e dispari:

  ```bash
  Shell > tail -n 10 /etc/services | cat -n | awk '{ if( (getline) <= 1) print $0}'
  2  ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
  4  edi_service     34567/udp               # dhanalakshmi.org EDI Service
  6  axio-disc       35100/udp               # Axiomatic discovery protocol
  8  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
  10  spremotetablet  46998/tcp               # Capture handwritten signatures

  Shell > tail -n 10 /etc/services | cat -n | awk '{if(NR==1) print $0} { if(NR%2==0) {if(getline > 0) print $0} }'
  1  aigairserver    21221/tcp               # Services for Air Server
  3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
  5  axio-disc       35100/tcp               # Axiomatic discovery protocol
  7  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
  9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
  ```

2. getline var

  Aggiungere ogni riga del file b alla fine di ogni riga del file C:

  ```bash
  Shell > cat /tmp/b.txt
  b1
  b2
  b3
  b4
  b5
  b6

  Shell > cat /tmp/c.txt
  A 192.168.1.1 HTTP
  B 192.168.1.2 HTTP
  B 192.168.1.2 MYSQL
  C 192.168.1.1 MYSQL
  C 192.168.1.1 MQ
  D 192.168.1.4 NGINX

  Shell > awk '{getline var1 <"/tmp/b.txt" ; print $0 , var1}' /tmp/c.txt
  A 192.168.1.1 HTTP b1
  B 192.168.1.2 HTTP b2
  B 192.168.1.2 MYSQL b3
  C 192.168.1.1 MYSQL b4
  C 192.168.1.1 MQ b5
  D 192.168.1.4 NGINX b6
  ```

  Sostituisce il campo specificato del file c con la riga del contenuto del file b:

  ```bash
  Shell > awk '{ getline var2 < "/tmp/b.txt" ; gsub($2 , var2 , $2) ; print $0 }' /tmp/c.txt
  A b1 HTTP
  B b2 HTTP
  B b3 MYSQL
  C b4 MYSQL
  C b5 MQ
  D b6 NGINX
  ```

3. command | getline &#91;var&#93;

  ```bash
  Shell > awk 'BEGIN{ "date +%Y%m%d" | getline datenow ; print datenow}'
  20240107
  ```

  !!! tip "Suggerimento"

  ```
   Utilizzare le doppie virgolette per includere il comando Shell.
  ```

4. next

  In precedenza abbiamo introdotto l'istruzione **break** e l'istruzione **continue**, la prima utilizzata per terminare il ciclo e la seconda per uscire dal ciclo corrente. Vedi [qui](#bc). Per **next**, quando le condizioni sono soddisfatte, interrompe la registrazione dell'ingresso che soddisfa le condizioni e continua con le azioni successive.

  ```bash
  Shell > seq 1 5 | awk '{if(NR==3) {next} print $0}'
  1
  2
  4
  5

  # equivalent to
  Shell > seq 1 5 | awk '{if($1!=3) print $0}'
  ```

  Saltare i record di linea ammissibili:

  ```bash
  Shell > cat /etc/passwd | awk -F ":" 'NR>5 {next} {print $0}'
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

  # equivalent to
  Shell > cat /etc/passwd | awk -F ":" 'NR>=1 && NR<=5 {print $0}'
  ```

  !!! tip "Suggerimento"

  ```
   "**next**" non può essere usato in "BEGIN{}" e "END{}".
  ```

5. Funzione **system**

  Questa funzione può essere utilizzata per richiamare comandi nella shell, come ad esempio:

  ```bash
  Shell > awk 'BEGIN{ system("echo nginx http") }'
  nginx http
  ```

  !!! tip "Suggerimento"

  ````
   Si noti di aggiungere le doppie virgolette quando si utilizza la funzione **system**. Se non vengono aggiunte, il programma `awk` la considererà una variabile del programma `awk`.

   ```bash
   Shell > awk 'BEGIN{ cmd1="date +%Y" ; system(cmd1)}'
   2024
   ```
  ````

  \*\*Cosa succede se il comando stesso della shell contiene doppi apici? \*\* Utilizzando i caratteri di escape - "\", come ad esempio:

  ```bash
  Shell > egrep "^root|^nobody" /etc/passwd
  Shell > awk 'BEGIN{ system("egrep \"^root|^nobody\" /etc/passwd") }'
  root:x:0:0:root:/root:/bin/bash
  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
  ```

  Un altro esempio:

  ```bash
  Shell > awk 'BEGIN{ if ( system("xmind &> /dev/null") == 0 ) print "True"; else print "False" }'
  False
  ```

6. Scrivere l'output del programma `awk` su un file

  ```bash
  Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{OFS="\t"} {print $1,$2 > "/tmp/user.txt"}'
  Shell > cat /tmp/user.txt
  root    x
  bin     x
  daemon  x
  adm     x
  lp      x
  ```

  !!! tip "Suggerimento"

  ```
   "**>**" indica la scrittura sul file come sovrapposizione. Se si desidera scrivere sul file come append, utilizzare "**>>**". Si ricorda ancora una volta di usare le doppie virgolette per includere il percorso del file.
  ```

7. carattere della pipe

8. Funzioni personalizzate

  sintassi - `funzione NOME(elenco di parametri) { corpo della funzione }`. Come ad esempio:

  ```bash
  Shell > awk 'function mysum(a,b) {return a+b} BEGIN{print mysum(1,6)}'
  7
  ```

## Osservazioni conclusive

Se si dispone di competenze specifiche nel linguaggio di programmazione, `awk` è relativamente facile da imparare. Tuttavia, per la maggior parte dei sysadmin con scarse conoscenze dei linguaggi di programmazione (incluso l'autore), `awk` può essere molto complicato da imparare. Per le informazioni non trattate, consultare [qui] (https://www.gnu.org/software/gawk/manual/ "manuale di gawk").

Grazie ancora per la lettura.
