---
title: Awk command
author: tianci li
contributors:
tags:
  - awk
---

# `awk` command

In 1977, a programming language-level tool for processing text, named' awk', was born at Bell Labs.
The name comes from the first letters of the last names of three famous people:

* Alfred **A**ho
* Peter **W**einberger
* Brian **K**ernighan

Similar to shell (bash, csh, zsh, and ksh), `awk` has derivatives with the development of history:

* `awk`: Born in 1977 Bell Labs.
* `nawk` (new awk): It was born in 1985 and is an updated and enhanced version of `awk`. It was widely used with Unix System V Release 3.1 (1987). The old version of `awk` is called `oawk` (old awk).
* `gawk` (GNU awk): It was written by Paul Rubin in 1986. The GNU Project was born in 1984.
* `mawk`: was written in 1996 by Mike Brennan, the interpreter of the awk programming language.
* `jawk`: Implementation of `awk` in JAVA

In the GNU/Linux operating system, the usual `awk` refers to `gawk`.  However, some distributions, such as Ubuntu or Debian, use `mawk` as their default `awk`.

In the Rocky Linux 8.8, `awk` refers to `gawk`.

```bash
Shell > whereis awk
awk: /usr/bin/awk /usr/libexec/awk /usr/share/awk /usr/share/man/man1/awk.1.gz

Shell > ls -l /usr/bin/awk
lrwxrwxrwx. 1 root root 4 4月  16 2022 /usr/bin/awk -> gawk

Shell > rpm -qf /usr/bin/awk
gawk-4.2.1-4.el8.x86_64
```

For information not covered, see the [gawk manual](https://www.gnu.org/software/gawk/manual/ "gawk manual").

Although `awk` is a tool for processing text, it has some programming language features:

* variable
* process control (loop)
* data type
* logical operation
* function
* array
* ...

**The working principle of `awk`**: Similar to relational databases, it supports processing fields (columns) and records (rows). By default, `awk` treats each line of a file as a record and places these records in memory for line-by-line processing, with a portion of each line treated as a field in the record. By default, delimiters to separate different fields use spaces and tabs, while numbers represent different fields in the row record. To reference multiple fields, separate them with commas or tabs.

A simple example that is easy to understand：

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

## Instructions for using `awk`

The usage of `awk` is - `awk option  'pattern {action}'  FileName`

**pattern**: Find specific content in the text
**action**: Action instruction
**{ }**: Group some instructions according to specific patterns

| option | description |
| :---   | :---        |
| -f program-file<br/>--file program-file | Reading `awk` program source files from files |
| -F FS  | Specify the separator for separating fields. The 'FS' here is a built-in variable in `awk`, with default values of spaces or tabs |
| -v var=value | variable assignment |
| --posix | Turn on compatibility mode |
| --dump-variables=[file] | Write global variables in `awk` to a file. If no file is specified, the default file is awkvars.out |
| --profile=[file] | Write performance analysis data to a specific file. If no file is specified, the default file is awkprof.out |

| pattern                | description |
| :---                   | :---        |
| BEGIN{ }               | An action that is performed before all row records are read |
| END{ }                 | An action that is performed after all row records are read|
| /regular  expression/  | Match the regular expression for each input line record |
| pattern && pattern     | Logic and operation |
| pattern \|\| pattern   | Logic or operation |
| !pattern               | Logical negation operation|
| pattern1,pattern2      | Specify the pattern range to match all row records within that range |

`awk` is powerful and involves a lot of knowledge, so some of the content will be explained later.

### `printf` commands

Before formally learning `awk`, beginners need to understand the command `printf`.

`printf`：format and print data. Its usage is -`printf FORMAT [ARGUMENT]...`

**FORMAT**：Used to control the content of the output. The following common interpretation sequences are supported：

* **\a** - alert (BEL)
* **\b** - backspace
* **\f** - form feed
* **\n** - new line
* **\r** - carriage return
* **\t** - horizontal tab
* **\v** - vertical tab
* **%Ns** - The output string. The N represents the number of strings, for example: `%s %s %s`
* **%Ni** - Output integers. The N represents the number of integers of the output, for example: `%i %i`
* **%m\.nf** - Output Floating Point Number. The m represents the total number of digits output, and the n represents the number of digits after the decimal point. For example: `%8.5f`

**ARGUMENT**: If it is a file, you need to do some preprocessing to output correctly.

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

No `print` command exists in RockyLinux OS. You can only use `print` in `awk`, and its difference from `printf` is that it automatically adds a newline at the end of each line. For example:

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

## Basic usage example

1. Reading `awk` program source files from files

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

2. Specify delimiter

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

    You can also use words as delimiters. Parentheses indicate this is an overall delimiter, and "|" means or.

    ```bash
    Shell > tail -n 5 /etc/services | awk -F "(tcp)|(udp)" '{print $1}'
    axio-disc       35100/
    pmwebapi        44323/
    cloudcheck-ping 45514/
    cloudcheck      45514/
    spremotetablet  46998/
    ```

3. Variable assignment

    ```bash
    Shell > tail -n 5 /etc/services | awk -v a=123 'BEGIN{print a}{print $1}'
    123
    axio-disc
    pmwebapi
    cloudcheck-ping
    cloudcheck
    spremotetablet
    ```

    Assign the value of user-defined variables in bash to awk's variables.

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

4. Write awk's global variables to a file

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

    Later, we will introduce what these variables mean. To review them now, [jump to variables](#VARIABLES).

5. BEGIN{ } and END{ }

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

6. --profile option

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

    Modify the awkprof.out file.

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

7. Match rows (records) through regular expressions <a id="RE"></a>

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

8. Logical operations (logical and, logical OR, reverse)

    logical and: &&
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

9. Locates consecutive lines by string and prints them

    ```bash
    Shell > cat /etc/services | awk '/^ntp/,/^netbios/ {print $0}'
    ntp             123/tcp
    ntp             123/udp                         # Network Time Protocol
    netbios-ns      137/tcp                         # NETBIOS Name Service
    ```

    !!! info

        Start range: stop matching when the first match is encountered.
        End range: stop matching when the first match is encountered.

## Built-in variable {#VARIABLES}

| Variable name | Description |
| :---:         | :---        |
| FS         | The delimiter of the input field. The default is space or tab  |
| OFS        | The delimiter of the output field. The default is space        |
| RS         | The delimiter of the input row record. The default is a newline character (\n) |
| ORS        | The delimiter of output row record. The default is a newline character (\n)|
| NF         | Count the number of fields in the current row record |
| NR         | Count the number of row records. After each line of text is processed, the value of this variable will be +1 |
| FNR        | Count the number of row records. When the second file is processed, the NR variable continues to add up, but the FNR variable is recounted|
| ARGC       | The number of command line arguments |
| ARGV       | An array of command line arguments, with subscript starting at 0 and ARGV[0] representing `awk`|
| ARGIND     | The index value of the file currently being processed. The first file is 1, the second file is 2, and so on|
| ENVIRON    | Environment variables of the current system|
| FILENAME   | Output the currently processed file name|
| IGNORECASE | Ignore case |
| SUBSEP     | The delimiter of the subscript in the array, which defaults to "\034"|

1. FS and OFS

    ```bash
    Shell > cat /etc/passwd | awk 'BEGIN{FS=":"}{print $1}'
    root
    bin
    daemon
    adm
    lp
    sync
    ```

    You can also use the -v option to assign values to variables.

    ```bash
    Shell > cat /etc/passwd | awk -v FS=":" '{print $1}'
    root
    bin
    daemon
    adm
    lp
    sync
    ```

    The default output delimiter is a space when using commas to reference multiple fields. You can, however, specify the output delimiter separately.

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

2. RS and ORS

    By default, `awk` uses newline characters to distinguish each line record

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

    Count the number of fields per line in the current text

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print NF}'
    7
    7
    7
    7
    7
    ```

    Print the fifth field

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $(NF-2)}'
    root
    bin
    daemon
    adm
    lp
    ```

    Print the last field

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $NF}'
    /bin/bash
    /sbin/nologin
    /sbin/nologin
    /sbin/nologin
    /sbin/nologin
    ```

    Exclude the last two fields

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$NF=" ";$(NF-1)=" ";print $0}'
    root x 0 0 root
    bin x 1 1 bin
    daemon x 2 2 daemon
    adm x 3 4 adm
    lp x 4 7 lp
    ```

    Exclude the first field

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$1=" ";print $0}' | sed -r 's/(^  )//g'
    x 0 0 root /root /bin/bash
    x 1 1 bin /bin /sbin/nologin
    x 2 2 daemon /sbin /sbin/nologin
    x 3 4 adm /var/adm /sbin/nologin
    x 4 7 lp /var/spool/lpd /sbin/nologin
    ```

4. NR and FNR

    ```bash
    Shell > tail -n 5 /etc/services | awk '{print NR,$0}'
    1 axio-disc       35100/udp               # Axiomatic discovery protocol
    2 pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
    3 cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
    4 cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
    5 spremotetablet  46998/tcp               # Capture handwritten signatures
    ```

    Print the total number of lines in the file content

    ```bash
    Shell > cat /etc/services | awk 'END{print NR}'
    11473
    ```

    Print the content of line 200

    ```bash
    Shell > cat /etc/services | awk 'NR==200'
    microsoft-ds    445/tcp
    ```

    Print the second field on line 200

    ```bash
    Shell > cat /etc/services | awk 'BEGIN{RS="\n";ORS="\n"} NR==200 {print $2}'
    445/tcp
    ```

    Print content within a specific range

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

    Comparison between NR and FNR

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

5. ARGC and ARGV

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

    This variable is mainly used to determine the file the `awk` program is working on.

    ```bash
    Shell > awk '{print ARGIND,$0}' /etc/hostname /etc/resolv.conf
    1 Master
    2 # Generated by NetworkManager
    2 nameserver 8.8.8.8
    2 nameserver 114.114.114.114
    ```

7. ENVIRON

    You can reference operating systems or user-defined variables in `awk` programs.

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

    This variable is useful if you want to use regular expressions in `awk` and ignore case.

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

## Operator

| Operator  | Description |
| :---:     | :---        |
| (...)     | Grouping    |
| $n        | Field reference |
| ++<br/>--      | Incremental<br/>Decreasing |
| +<br/>-<br/>!  | Mathematical plus sign<br/>Mathematical minus sign<br/>Negation|
| *<br/>/<br/>%  | Mathematical multiplication sign<br/>Mathematical division sign<br/>Modulo operation |
| in             | Elements in an array |
| &&<br/>\|\|    | Logic and Operations<br/>Logical OR operation |
| ?:  |  Abbreviation of conditional expressions |
| ~   | Another representation of regular expressions |
| !~  | Reverse Regular Expression |

!!! note

    In the `awk` program, the following expressions will be judged as **false**:

    * The number is 0;
    * Empty string;
    * Undefined value.

    ```bash
    Shell > awk 'BEGIN{n=0;if(n) print "Ture";else print "False"}'
    False
    Shell > awk 'BEGIN{s="";if(s) print "True";else print "False"}'
    False
    Shell > awk 'BEGIN{if(t) print "True";else print "Flase"}'
    False
    ```

1. Exclamation point

    Print odd rows:

    ```bash
    Shell > seq 1 10 | awk 'i=!i {print $0}'
    1
    3
    5
    7
    9
    ```

    !!! question

        **Why?**
        **Read the first line**: Because "i" is not assigned a value, so "i=!i" indicates TRUE.
        **Read the second line**: At this point, "i=!i" indicates FALSE.
        And so on, the final printed line is an odd number.

    Print even rows:

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

    !!! note

        As you can see, sometimes you can ignore the syntax for the "action" part, which by default is equivalent to "{print $0}".

2. Reversal

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

3. Basic operations in mathematics

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

    It can also be used in the "pattern":

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

4. Pipe symbol

    You can use the bash command in the awk program, for example:

    ```bash
    Shell > echo -e "6\n3\n9\n8" | awk '{print $0 | "sort"}'
    3
    6
    8
    9
    ```

    !!! info

        Please pay attention! You must use double quotes to include the command.

5. Regular expression

    [Here](#RE), we cover basic examples of regular expressions. You can use regular expressions on row records.

    ```bash
    Shell > cat /etc/services | awk '/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'

    # Be equivalent to:

    Shell > cat /etc/services | awk '$0~/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'
    ```

    If the file has a large amount of text, regular expressions can also be used for fields, which will help improve processing efficiency. The usage example is as follows:

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

## Flow control

1. **if** statement

    The basic syntax format is - `if (condition) statement [ else statement ]`

    Example of a single branch use of an if statement:

    ```bash
    Shell > cat /etc/services | awk '{if(NR==110) print $0}'
    pop3            110/udp         pop-3
    ```

    The condition is determined as a regular expression:

    ```bash
    Shell > cat /etc/services | awk '{if(/^(ftp)\s|^(ssh)\s/) print $0}'
    ftp             21/tcp
    ftp             21/udp          fsp fspd
    ssh             22/tcp                          # The Secure Shell (SSH) Protocol
    ssh             22/udp                          # The Secure Shell (SSH) Protocol
    ftp             21/sctp                 # FTP
    ssh             22/sctp                 # SSH
    ```

    Double branch:

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

    Multiple branches:

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

2. **while** statement

    The basic syntax format is - `while (condition) statement`

    Traverse and print out the fields of all row records.

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

3. **for** statement

    The basic syntax format is - `for (expr1; expr2; expr3) statement`

    Traverse and print out the fields of all row records.

    ```bash
    Shell > tail -n 2 /etc/services | awk '{ \
    for(i=1;i<=NF;i++) print $i
    }'
    ```

    Print the fields for each row of records in reverse order.

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

    Print each line of records in the opposite direction.

    ```bash
    Shell > tail -n 2 /etc/services | awk  '{ \
    for(i=NF;i>=1;i--) {printf $i" "};
    print ""
    }'

    System Management WiFi CloudCheck ASSIA # 45514/tcp cloudcheck
    signatures handwritten Capture # 46998/tcp spremotetablet
    ```

4. **break** statement and **continue** statement<a id="bc"></a>

    The comparison between the two is as follows:

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

5. **exit** statement

    You can specify a return value in the range of [0,255]

    The basic syntax format is - `exit [expression]`

    ```bash
    Shell > seq 1 10 | awk '{
      if($0~/5/) exit "135"
    }'

    Shell > echo $?
    135
    ```

## Array

**array**: A collection of data with the same data type arranged in a certain order. Each data in an array is called an element.

Like most programming languages, `awk` also supports arrays, which are divided into **indexed arrays (with numbers as subscripts)** and **associative arrays (with strings as subscripts)**.

`awk` has a lot of functions, and the functions related to arrays are:

* **length(Array_Name)** - Get the length of the array.

1. Custom array

    Format - `Array_Name[Index]=Value`

    ```bash
    Shell > awk 'BEGIN{a1[0]="test0" ; a1[1]="s1"; print a1[0]}'
    test0
    ```

    Get the length of the array:

    ```bash
    Shell > awk 'BEGIN{name[-1]="jimcat8" ; name[3]="jack" ; print length(name)}'
    2
    ```

    Store all GNU/Linux users in an array:

    ```bash
    Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[2]}'
    bin
    Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[1]}'
    root
    ```

    !!! info

        The numeric subscript of an `awk` array can be a positive integer, a negative integer, a string, or 0, so the numeric subscript of an `awk` array has no concept of an initial value. This is not the same as arrays in `bash`.

        ```bash
        Shell > arr1=(2 10 30 string1)
        Shell > echo "${arr1[0]}"
        2
        Shell > unset arr1
        ```

2. Delete array

    Format - `delete Array_Name`

3. Delete an element from an array

    Format - `delete Array_Name[Index]`

4. Traversal array

    You can use the **for** statement, which is suitable for cases where the array subscript is unknown:

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

    If the subscript of an array is regular, you can use this form of the **for** statement:

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

5. Use "++" as the subscript of the array

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

6. Use a field as the subscript of an array

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

7. Count the number of occurrences of the same field

    Count the number of occurrences of the same IPv4 address. Basic idea:

    * First use the `grep` command to filter out all IPv4 addresses
    * Then hand it over to the `awk` program for processing

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

    !!! info

        `a[$1]++` is equivalent to `a[$1]+=1`

    Count the number of occurrences of words regardless of case. Basic idea:

    * Split all fields into multiple rows of records
    * Then hand it over to the `awk` program for processing

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

    You can first filter specific row records and then perform statistics, such as:

    ```bash
    Shell > ss -tulnp | awk -F " "  '/tcp/ {a[$2]++} END{for(i in a) print a[i],i}'
    2 LISTEN
    ```

8. Print lines based on the number of occurrences of a specific field

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

    Reverse:

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

9. Multidimensional array

    The `awk` program does not support multi-dimensional arrays, but support for multi-dimensional arrays is achievable through simulation. By default, "\034" is the delimiter for the subscript of a multidimensional array.

    Please note the following differences when using multidimensional arrays:

    ```bash
    Shell > awk 'BEGIN{ a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
    200 20
    300 30
    100 1,0
    ```

    Redefine the delimiter:

    ```bash
    Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
    300 3----0
    200 2----0
    100 1,0
    ```

    Reorder：

    ```bash
    Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i | "sort" }'
    100 1,0
    200 2----0
    300 3----0
    ```

    Count the number of times the field appears:

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

## Built-in function

| Function name | Description |
| :---          | :---        |
| int(expr)     | Truncate as an integer |
| sqrt(expr)    | Square root|
| rand()        | Returns a random number N with a range of (0,1). The result is not that every run is a random number, but that it remains the same.|
| srand([expr]) | Use "expr" to generate random numbers. If "expr" is not specified, the current time is used as the seed by default, and if there is a seed, the generated random number is used.|
| asort(a,b)    | The elements of the array "a" are reordered (lexicographically) and stored in the new array "b", with the subscript in the array "b" starting at 1. This function returns the number of elements in the array.|
| asorti(a,b)   | Reorder the subscript of the array "a" and store the sorted subscript in the new array "b" as an element, with the subscript of the array "b" starting at 1. |
| sub(r,s[,t])  | Use the "r" regular expression to match the input records, and replace the matching result with "s". "t" is optional, indicating a replacement for a certain field. The function returns the number of replacements - 0 or 1. Similar to `sed s//`|
| gsub(r,s[,t]) | Global replacement. "t" is optional, indicating the replacement of a certain field. If "t" is ignored, it indicates global replacement. Similar to `sed s///g` |
| gensub(r,s,h[,t])  | The "r" regular expression matches the input records and replaces the matching result with "s". "t" is optional, indicating a replacement for a certain field. "h" represents replacing the specified index position|
| index(s,t)    | Returns the index position of the string "t" in the string "s" (the string index starts from 1). If the function returns 0, it means it does not exist |
| length([s])   | Returns the length of "s" |
| match(s,r[,a])| Test whether the string "s" contains the string "r". If included, return the index position of "r" within it (string index starting from 1). If not, return 0 |
| split(s,a[,r[,seps]])| Split string "s" into an array "a" based on the delimiter "seps". The subscript of the array starts with 1.|
| substr(s,i[,n])  | Intercept the string. "s" represents the string to be processed; "i" indicates the index position of the string; "n" is the length. If you do not specify "n", it means to intercept all remaining parts|
| tolower(str)  | Converts all strings to lowercase |
| toupper(str)  | Converts all strings to uppercase |
| systime()     | Current timestamp |
| strftime([format[,timestamp[,utc-flag]]]) | Format the output time. Converts the timestamp to a string |

1. **int** function

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

    As you can see, the int function only works for numbers, and when encountering a string, converts it to 0. When encountering a string starting with a number, truncates it.

2. **sqrt** function

    ```bash
    Shell > awk 'BEGIN{print sqrt(9)}'
    3
    ```

3. **rand** function and **srand** function

    The example of using the rand function is as follows:

    ```bash
    Shell > awk 'BEGIN{print rand()}'
    0.924046
    Shell > awk 'BEGIN{print rand()}'
    0.924046
    Shell > awk 'BEGIN{print rand()}'
    0.924046
    ```

    The example of using the srand function is as follows:

    ```bash
    Shell > awk 'BEGIN{srand() ; print rand()}'
    0.975495
    Shell > awk 'BEGIN{srand() ; print rand()}'
    0.99187
    Shell > awk 'BEGIN{srand() ; print rand()}'
    0.069002
    ```

    Generate an integer within the range of (0,100):

    ```bash
    Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
    56
    Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
    33
    Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
    42
    ```

4. **asort** function and **asorti** function

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

    !!! info

        Sorting rules:

        * Numbers have higher priority than strings and are arranged in ascending order.
        * Arrange strings in ascending dictionary order

    If you are using the **asorti** function, the example is as follows:

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

    !!! info

        Sorting rules:

        * Numbers have priority over strings
        * If a negative number is encountered, the first digit from the left will be compared. If it is the same, the second digit will be compared, and so on
        * If a positive number is encountered, it will be arranged in ascending order
        * Arrange strings in ascending dictionary order

5. **sub** function and **gsub** function

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

    Just like the `sed` command, you can also use the "&" symbol to reference already matched strings.

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

6. **index** function

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

7. **length** function

    ```bash
    # The length of the output field
    Shell > tail -n 5 /etc/services | awk '{print length($1)}'
    9
    8
    15
    10
    14

    # The length of the output array
    Shell > cat /etc/passwd | awk -F ":" 'a[NR]=$1 END{print length(a)}'
    22
    ```

8. **match** function

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

9. **split** function

    ```bash
    Shell > echo "365%tmp%dir%number" | awk '{split($1,a1,"%") ; for(i in a1) print i,a1[i]}'
    1 365
    2 tmp
    3 dir
    4 number
    ```

10. **substr** function

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

11. **tolower** function and **toupper** function

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

12. Functions that deal with time and date

    **What is a UNIX timestamp?**
    According to the development history of GNU/Linux, UNIX V1 was born in 1971, and the book "UNIX Programmer's Manual" was published on November 3 of the same year, which defines 1970-01-01 as the reference date of the start of UNIX.

    The conversion between a timestamp and a natural date time in days:

    ```bash
    Shell > echo "$(( $(date --date="2024/01/06" +%s)/86400 + 1 ))"
    19728

    Shell > date -d "1970-01-01 19728days"
    Sat Jan  6 00:00:00 CST 2024
    ```

    The conversion between a timestamp and a natural date time in seconds:

    ```bash
    Shell > echo "$(date --date="2024/01/06 17:12:00" +%s)"
    1704532320

    Shell > echo "$(date --date='@1704532320')"
    Sat Jan  6 17:12:00 CST 2024
    ```

    The conversion between natural date time and UNIX timestamp in `awk` program:

    ```bash
    Shell > awk 'BEGIN{print systime()}'
    1704532597

    Shell > echo "1704532597" | awk '{print strftime("%Y-%m-%d %H:%M:%S",$0)}'
    2024-01-06 17:16:37
    ```

## I/O statement

| Statement                 | Description |
| :---                      | :---        |
| getline                   | Read the next matching row record and assign it to "$0". <br/>The return value is 1: Indicates that relevant row records have been read. <br/>The return value is 0: Indicates that the last line has been read <br/>The return value is negative: Indicates encountering an error |
| getline var               | Read the next matching row record and assign it to the variable "var" |
| command \| getline [var]  | Assign the result to "$0" or the variable "var" |
| next                      | Stop the current input record and perform the following actions|
| print                     | Print the result |
| printf                    | See [here](#printf-commands)|
| system(cmd-line)          | Execute the command and return the status code. 0 indicates that the command was executed successfully; non-0 indicates that the execution failed |
| print ... >> file         | Output redirection |
| print ... \| command      | Print the output and use it as input to the command |

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

    Using the functions we learned earlier and the "&" symbol, we can:

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

    Print even and odd lines:

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

    Add each line of the b file to the end of each line of the C file:

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

    Replace the specified field of the c file with the content line of the b file:

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

    !!! tip

        Use double quotes to include Shell command.

4. next

    Earlier, we introduced the **break** statement and the **continue** statement, the former used to terminate the loop, and the latter used to jump out of the current loop. See [here](#bc). For **next**, when the conditions are met, it will stop the input recording that meets the conditions and continue with subsequent actions.

    ```bash
    Shell > seq 1 5 | awk '{if(NR==3) {next} print $0}'
    1
    2
    4
    5

    # equivalent to
    Shell > seq 1 5 | awk '{if($1!=3) print $0}'
    ```

    Skip eligible line records:

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

    !!! tip

        "**next**" cannot be used in "BEGIN{}" and "END{}".

5. **system** function

    You can use this function to call commands in the Shell, such as:

    ```bash
    Shell > awk 'BEGIN{ system("echo nginx http") }'
    nginx http
    ```

    !!! tip

        Please note to add double quotes when using the **system** function. If not added, the `awk` program will consider it a variable of the `awk` program.

        ```bash
        Shell > awk 'BEGIN{ cmd1="date +%Y" ; system(cmd1)}'
        2024
        ```

    **What if the Shell command itself contains double quotes?**
    Using escape characters - "\\", such as:

    ```bash
    Shell > egrep "^root|^nobody" /etc/passwd
    Shell > awk 'BEGIN{ system("egrep \"^root|^nobody\" /etc/passwd") }'
    root:x:0:0:root:/root:/bin/bash
    nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
    ```

    Another example:

    ```bash
    Shell > awk 'BEGIN{ if ( system("xmind &> /dev/null") == 0 ) print "True"; else print "False" }'
    False
    ```

6. Write the output of the `awk` program to a file

    ```bash
    Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{OFS="\t"} {print $1,$2 > "/tmp/user.txt"}'
    Shell > cat /tmp/user.txt
    root    x
    bin     x
    daemon  x
    adm     x
    lp      x
    ```

    !!! tip

        "**>**" indicates writing to the file as an overlay. If you want to write to the file as an append, please use "**>>**". Reminder again, you should use double quotation marks to include the file path.

7. pipe character

8. Custom functions

    syntax - `function NAME(parameter list) { function body }`. Such as:

    ```bash
    Shell > awk 'function mysum(a,b) {return a+b} BEGIN{print mysum(1,6)}'
    7
    ```

## Concluding remarks

If you have specialized programming language skills, `awk` is relatively easy to learn. However, for most sysadmins with weak programming language skills (including the author), `awk` can be very complicated to learn. For information not covered, please refer to [here](https://www.gnu.org/software/gawk/manual/ "gawk manual").

Thank you again for reading.
