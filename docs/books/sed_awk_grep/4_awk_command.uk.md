---
title: Команда Awk
author: tianci li
contributors: null
tags:
  - awk
---

# Команда `awk`

У 1977 році в Bell Labs народився інструмент на рівні мови програмування для обробки тексту під назвою «awk».
Назва походить від перших літер прізвищ трьох відомих людей:

- Alfred **A**ho
- Peter **W**einberger
- Brian **K**ernighan

Подібно до оболонки (bash, csh, zsh і ksh), awk має похідні з розвитком історії:

- `awk`: Народився в 1977 році Bell Labs.
- `nawk` (новий awk): він народився в 1985 році та є оновленою та вдосконаленою версією `awk`. Він широко використовувався з Unix System V Release 3.1 (1987). Стара версія `awk` називається `oawk` (старий awk).
- `gawk` (GNU awk): це було написано Полом Рубіном у 1986 році. Проект GNU народився в 1984 році.
- `mawk` був написаний у 1996 році Майком Бреннаном, інтерпретатором мови програмування `awk`.
- `jawk`: Реалізація `awk` в JAVA

В операційній системі GNU/Linux звичайний `awk` відноситься до `gawk`.  Однак деякі дистрибутиви, такі як Ubuntu або Debian, використовують `mawk` як типовий `awk`.

У Rocky Linux 8.8 `awk` відноситься до `gawk`.

```bash
Shell > whereis awk
awk: /usr/bin/awk /usr/libexec/awk /usr/share/awk /usr/share/man/man1/awk.1.gz

Shell > ls -l /usr/bin/awk
lrwxrwxrwx. 1 root root 4 4月  16 2022 /usr/bin/awk -> gawk

Shell > rpm -qf /usr/bin/awk
gawk-4.2.1-4.el8.x86_64
```

Для інформації, яка не охоплюється, див. [посібник gawk](https://www.gnu.org/software/gawk/manual/ "посібник gawk").

Хоча `awk` є інструментом для обробки тексту, він має деякі особливості мови програмування:

- variable
- process control (loop)
- data type
- logical operation
- function
- array
- ...

**Принцип роботи `awk`**: подібно до реляційних баз даних, він підтримує обробку полів (стовпців) і записів (рядків). За замовчуванням awk розглядає кожен рядок файлу як запис і розміщує ці записи в пам’яті для построкової обробки, при цьому частина кожного рядка розглядається як поле в записі. За замовчуванням розділювачі для розділення різних полів використовують пробіли та табуляції, тоді як числа представляють різні поля в записі рядка. Щоб посилатися на кілька полів, розділіть їх комами або символами табуляції.

Простий приклад, який легко зрозуміти：

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

## Інструкції з використання `awk`

Використання `awk`: `awk option 'pattern {action}' FileName`

**pattern**: Знаходить у тексті певний зміст
**action**: Інструкція щодо дій
**{ }**: Групує деякі інструкції відповідно до певних шаблонів

| опція                                                                       | опис                                                                                                                                  |
| :-------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| -f program-file<br/>--file program-file                                     | Читання вихідних файлів програми `awk` з файлів                                                                                       |
| -F FS                                                                       | Визначає роздільник для розділення полів. «FS» тут є вбудованою змінною в «awk» зі значеннями за замовчуванням пробілів або табуляції |
| -v var=value                                                                | призначення змінної                                                                                                                   |
| --posix                                                                     | Вмикає режим сумісності                                                                                                               |
| --dump-variables=[file] | Записує глобальні змінні в `awk` у файл. Якщо файл не вказано, типовим є файл awkvars.out                                             |
| --profile=[file]        | Запис даних аналізу продуктивності в певний файл. Якщо файл не вказано, типовим є файл awkprof.out                                    |

| pattern               | опис                                                                               |
| :-------------------- | :--------------------------------------------------------------------------------- |
| BEGIN{ }              | Дія, яка виконується перед читанням усіх записів рядка                             |
| END{ }                | Дія, яка виконується після прочитання всіх записів рядка                           |
| /regular  expression/ | Збігається з регулярним виразом для кожного запису рядка введення                  |
| pattern && pattern    | Логіка та функціонування                                                           |
| pattern \|\| pattern  | Логіка або операція                                                                |
| !pattern              | Операція логічного заперечення                                                     |
| pattern1,pattern2     | Визначає діапазон шаблонів для відповідності всім записам рядків у цьому діапазоні |

`awk` є потужним і вимагає багато знань, тому деякий вміст буде пояснено пізніше.

### Команди `printf`

Перш ніж офіційно вивчити `awk`, новачки повинні зрозуміти команду `printf`.

printf`：формат і друк даних. Його використання -`printf FORMAT [ARGUMENT]...\`

**FORMAT**：Використовується для керування вмістом виведення. Підтримуються такі загальні послідовності інтерпретації：

- **\a** - alert (BEL)
- **\b** - backspace
- **\f** - form feed
- **\n** - нова лінія
- **\r** - повернення каретки
- **\t** - горизонтальна вкладка
- **\v** - вертикальна вкладка
- **%Ns** - Вихідний рядок. N означає кількість рядків, наприклад: `%s %s %s`
- **%Ni** - Виводить цілі числа. N представляє кількість цілих чисел виведення, наприклад: `%i %i`
- **%m.nf** - вихідне число з плаваючою комою. M представляє загальну кількість виведених цифр, а n представляє кількість цифр після коми. Наприклад: `%8.5f`

**ARGUMENT**: Якщо це файл, ви повинні виконати деяку попередню обробку для правильного виведення.

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

В ОС RockyLinux не існує команди `print`. Ви можете використовувати лише `print` в `awk`; його відмінність від `printf` полягає в тому, що він автоматично додає новий рядок у кінці кожного рядка. Наприклад:

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

## Базовий приклад використання

1. Читання вихідних файлів програми `awk` з файлів

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

2. Вкажіть роздільник

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

   Ви також можете використовувати слова як роздільники. Дужки вказують, що це загальний роздільник, а "|" означає або.

   ```bash
   Shell > tail -n 5 /etc/services | awk -F "(tcp)|(udp)" '{print $1}'
   axio-disc       35100/
   pmwebapi        44323/
   cloudcheck-ping 45514/
   cloudcheck      45514/
   spremotetablet  46998/
   ```

3. Присвоєння змінної

   ```bash
   Shell > tail -n 5 /etc/services | awk -v a=123 'BEGIN{print a}{print $1}'
   123
   axio-disc
   pmwebapi
   cloudcheck-ping
   cloudcheck
   spremotetablet
   ```

   Призначте значення визначених користувачем змінних у bash змінним awk.

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

4. Записати глобальні змінні awk у файл

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

   Пізніше ми розповімо, що означають ці змінні. Щоб переглянути їх зараз, [перейдіть до змінних](#VARIABLES).

5. BEGIN{ } та END{ }

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

6. Опція --profile

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

   Змініть файл awkprof.out.

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

7. Зіставте рядки (записи) за допомогою регулярних виразів <a id="RE"></a>

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

8. Логічні операції (логічне та, логічне АБО, зворотне)

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

9. Знаходить послідовні рядки за рядком і друкує їх

   ```bash
   Shell > cat /etc/services | awk '/^ntp/,/^netbios/ {print $0}'
   ntp             123/tcp
   ntp             123/udp                         # Network Time Protocol
   netbios-ns      137/tcp                         # NETBIOS Name Service
   ```

   !!! info

   ```
    Початковий діапазон: припинення збігу, коли знайдено перший збіг.
    Кінцевий діапазон: припинення збігу, коли знайдено перший збіг.
   ```

## Вбудована змінна {#VARIABLES}

| Ім'я змінної | Опис                                                                                                                                                |
| :----------: | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
|      FS      | Роздільник поля введення. За замовчуванням пробіл або табуляція                                                                                     |
|      OFS     | Роздільник поля виведення. Типовим є пробіл                                                                                                         |
|      RS      | Роздільник запису вхідного рядка. Типовим є символ нового рядка (\n)                                                             |
|      ORS     | Роздільник запису вихідного рядка. Типовим є символ нового рядка (\n)                                                            |
|      NF      | Підрахувати кількість полів у поточному записі рядка                                                                                                |
|      NR      | Підраховує кількість записів рядків. Після обробки кожного рядка тексту значення цієї змінної буде +1                                               |
|      FNR     | Підраховує кількість записів рядків. Коли обробляється другий файл, змінна NR продовжує складатися, але змінна FNR перераховується                  |
|     ARGC     | Кількість аргументів командного рядка                                                                                                               |
|     ARGV     | Масив аргументів командного рядка з індексом, що починається з 0, і ARGV[0], що представляє awk |
|    ARGIND    | Значення індексу файлу, який зараз обробляється. Перший файл — 1, другий — 2 і так далі                                                             |
|    ENVIRON   | Змінні середовища поточної системи                                                                                                                  |
|   FILENAME   | Виведіть назву поточного обробленого файлу                                                                                                          |
|  IGNORECASE  | Ігнорує регістр                                                                                                                                     |
|    SUBSEP    | Роздільник нижнього індексу в масиві, який за умовчанням має значення "\034"                                                                        |

1. FS та OFS

   ```bash
   Shell > cat /etc/passwd | awk 'BEGIN{FS=":"}{print $1}'
   root
   bin
   daemon
   adm
   lp
   sync
   ```

   Ви також можете використовувати опцію -v, щоб призначити значення змінним.

   ```bash
   Shell > cat /etc/passwd | awk -v FS=":" '{print $1}'
   root
   bin
   daemon
   adm
   lp
   sync
   ```

   Роздільником виводу за замовчуванням є пробіл у разі використання ком для посилань на кілька полів. Однак ви можете вказати роздільник виведення окремо.

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

2. RS та ORS

   За замовчуванням `awk` використовує символи нового рядка, щоб розрізняти кожен запис рядка

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

   Підрахувати кількість полів на рядок поточного тексту

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print NF}'
   7
   7
   7
   7
   7
   ```

   Виведіть п'яте поле

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $(NF-2)}'
   root
   bin
   daemon
   adm
   lp
   ```

   Роздрукуйте останнє поле

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {print $NF}'
   /bin/bash
   /sbin/nologin
   /sbin/nologin
   /sbin/nologin
   /sbin/nologin
   ```

   Виключіть останні два поля

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$NF=" ";$(NF-1)=" ";print $0}'
   root x 0 0 root
   bin x 1 1 bin
   daemon x 2 2 daemon
   adm x 3 4 adm
   lp x 4 7 lp
   ```

   Виключити перше поле

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{RS="\n";ORS="\n"} {$1=" ";print $0}' | sed -r 's/(^  )//g'
   x 0 0 root /root /bin/bash
   x 1 1 bin /bin /sbin/nologin
   x 2 2 daemon /sbin /sbin/nologin
   x 3 4 adm /var/adm /sbin/nologin
   x 4 7 lp /var/spool/lpd /sbin/nologin
   ```

4. NR та FNR

   ```bash
   Shell > tail -n 5 /etc/services | awk '{print NR,$0}'
   1 axio-disc       35100/udp               # Axiomatic discovery protocol
   2 pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
   3 cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
   4 cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
   5 spremotetablet  46998/tcp               # Capture handwritten signatures
   ```

   Вивести загальну кількість рядків у вмісті файлу

   ```bash
   Shell > cat /etc/services | awk 'END{print NR}'
   11473
   ```

   Вивести вміст рядка 200

   ```bash
   Shell > cat /etc/services | awk 'NR==200'
   microsoft-ds    445/tcp
   ```

   Виведіть друге поле в рядку 200

   ```bash
   Shell > cat /etc/services | awk 'BEGIN{RS="\n";ORS="\n"} NR==200 {print $2}'
   445/tcp
   ```

   Друк вмісту в певному діапазоні

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

   Порівняння між NR і FNR

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

5. ARGC та ARGV

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

   Ця змінна в основному використовується для визначення файлу, з яким працює програма `awk`.

   ```bash
   Shell > awk '{print ARGIND,$0}' /etc/hostname /etc/resolv.conf
   1 Master
   2 # Generated by NetworkManager
   2 nameserver 8.8.8.8
   2 nameserver 114.114.114.114
   ```

7. ENVIRON

   Ви можете посилатися на операційні системи або визначені користувачем змінні в програмах `awk`.

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

   Ця змінна корисна, якщо ви хочете використовувати регулярні вирази в `awk` і ігнорувати регістр.

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

## Оператор

|         Оператор         | Опис                                                                        |
| :----------------------: | :-------------------------------------------------------------------------- |
| (...) | Групування                                                                  |
|            $n            | Польова довідка                                                             |
|         ++<br/>--        | Інкрементний<br/>Зменшення                                                  |
|       +<br/>-<br/>!      | Математичний знак плюс<br/>Математичний знак мінус<br/>Заперечення          |
|      \*<br/>/<br/>%      | Математичний знак множення<br/>Математичний знак ділення<br/>Дія за модулем |
|            in            | Елементи в масиві                                                           |
|        &&<br/>\|\|       | Логіка та операції<br/>Логічна операція АБО                                 |
|            ?:            | Скорочення умовних виразів                                                  |
|            \~            | Інше представлення регулярних виразів                                       |
|            !\~           | Зворотний регулярний вираз                                                  |

!!! note "Примітка"

````
У програмі `awk` наступні вирази будуть оцінені як **false**:

* Число дорівнює 0;
* Порожній рядок;
* Невизначене значення.

```bash
Shell > awk 'BEGIN{n=0;if(n) print "Ture";else print "False"}'
False
Shell > awk 'BEGIN{s="";if(s) print "True";else print "False"}'
False
Shell > awk 'BEGIN{if(t) print "True";else print "Flase"}'
False
```
````

1. Знак оклику

   Вивести непарні рядки:

   ```bash
   Shell > seq 1 10 | awk 'i=!i {print $0}'
   1
   3
   5
   7
   9
   ```

   !!! question "Питання"

   ```
    **Чому?**
    **Прочитайте перший рядок**: оскільки «i» не присвоєно значення, тому «i=!i» означає TRUE.
    **Прочитайте другий рядок**: у цьому місці "i=!i" вказує на FALSE.
    І так далі, останній надрукований рядок є непарним числом.
   ```

   Вивести парні рядки:

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

   !!! note "Примітка"

   ```
    Як бачите, іноді ви можете ігнорувати синтаксис для частини "action", яка за умовчанням еквівалентна "{print $0}".
   ```

2. Розворот

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

3. Основні операції в математиці

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

   Його також можна використовувати в "шаблоні":

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

4. Символ pipe<a id=ps></a>

   Ви можете використовувати команду bash у програмі awk, наприклад:

   ```bash
   Shell > echo -e "6\n3\n9\n8" | awk '{print $0 | "sort"}'
   3
   6
   8
   9
   ```

   !!! info

   ```
    Будь ласка, зверніть увагу! Ви повинні взяти подвійні лапки, щоб включити команду.
   ```

5. Регулярний вираз

   [Тут](#RE) ми розглядаємо основні приклади регулярних виразів. Ви можете використовувати регулярні вирази для записів рядків.

   ```bash
   Shell > cat /etc/services | awk '/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'

   # Be equivalent to:

   Shell > cat /etc/services | awk '$0~/[^0-9a-zA-Z]1[1-9]{2}\/tcp/ {print $0}'
   ```

   Якщо файл містить великий обсяг тексту, регулярні вирази також можна використовувати для полів, що допоможе підвищити ефективність обробки. Приклад використання такий:

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

## Управління потоком

1. оператор **if**

   Основний формат синтаксису - `if (condition) statement [ else statement ]`

   Приклад використання однієї гілки оператора if:

   ```bash
   Shell > cat /etc/services | awk '{if(NR==110) print $0}'
   pop3            110/udp         pop-3
   ```

   Умова визначається як регулярний вираз:

   ```bash
   Shell > cat /etc/services | awk '{if(/^(ftp)\s|^(ssh)\s/) print $0}'
   ftp             21/tcp
   ftp             21/udp          fsp fspd
   ssh             22/tcp                          # The Secure Shell (SSH) Protocol
   ssh             22/udp                          # The Secure Shell (SSH) Protocol
   ftp             21/sctp                 # FTP
   ssh             22/sctp                 # SSH
   ```

   Подвійна гілка:

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

   Кілька гілок:

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

2. оператор **while**

   Основний формат синтаксису - `while (condition) statement`

   Перегляньте та роздрукуйте поля всіх записів рядків.

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

3. оператор **for**

   Основний формат синтаксису - `for (expr1; expr2; expr3) statement`

   Перегляньте та роздрукуйте поля всіх записів рядків.

   ```bash
   Shell > tail -n 2 /etc/services | awk '{ \
   for(i=1;i<=NF;i++) print $i
   }'
   ```

   Виведіть поля для кожного рядка записів у зворотному порядку.

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

   Друкуйте кожен рядок записів у зворотному напрямку.

   ```bash
   Shell > tail -n 2 /etc/services | awk  '{ \
   for(i=NF;i>=1;i--) {printf $i" "};
   print ""
   }'

   System Management WiFi CloudCheck ASSIA # 45514/tcp cloudcheck
   signatures handwritten Capture # 46998/tcp spremotetablet
   ```

4. оператор **break** і оператор **continue**<a id="bc"></a>

   Порівняння між ними виглядає наступним чином:

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

5. оператор **exit**

   Ви можете вказати значення, що повертається, у діапазоні [0,255]

   Основний формат синтаксису - `exit [expression]`

   ```bash
   Shell > seq 1 10 | awk '{
     if($0~/5/) exit "135"
   }'

   Shell > echo $?
   135
   ```

## Масив

**масив**: сукупність даних одного типу, розташованих у певному порядку. Кожні дані в масиві називають елементом.

Як і більшість мов програмування, `awk` також підтримує масиви, які поділяються на **індексовані масиви (з числами як нижні індекси)** та **асоціативні масиви (з рядками як нижні індекси)**.

`awk` має багато функцій, і функції, пов’язані з масивами:

- **length(Array_Name)** - Отримує довжину масиву.

1. Спеціальний масив

   Формат - `Array_Name[Index]=Value`

   ```bash
   Shell > awk 'BEGIN{a1[0]="test0" ; a1[1]="s1"; print a1[0]}'
   test0
   ```

   Отримати довжину масиву:

   ```bash
   Shell > awk 'BEGIN{name[-1]="jimcat8" ; name[3]="jack" ; print length(name)}'
   2
   ```

   Зберігти всіх користувачів GNU/Linux у масиві:

   ```bash
   Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[2]}'
   bin
   Shell > cat /etc/passwd | awk -F ":" '{username[NR]=$1}END{print username[1]}'
   root
   ```

   !!! info

   ````
    Числовий нижній індекс масиву `awk` може бути додатним цілим, від’ємним цілим числом, рядком або 0, тому числовий індекс масиву `awk` не має поняття початкового значення. Це не те саме, що масиви в bash.

    ```bash
    Shell > arr1=(2 10 30 string1)
    Shell > echo "${arr1[0]}"
    2
    Shell > unset arr1
    ```
   ````

2. Видалити масив

   Формат - `delete Array_Name`

3. Видалення елемента з масиву

   Формат - `delete Array_Name[Index]`

4. Обхідний масив

   Ви можете використовувати оператор **for**, який підходить для випадків, коли індекс масиву невідомий:

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

   Якщо нижній індекс масиву звичайний, ви можете використовувати цю форму оператора **for**:

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

5. Використовуйте "++" як нижній індекс масиву

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

6. Використовуйте поле як нижній індекс масиву

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

7. Підрахуйте кількість входжень одного поля

   Підрахуйте кількість випадків однакової адреси IPv4. Основна ідея:

   - Спочатку скористайтеся командою `grep`, щоб відфільтрувати всі адреси IPv4
   - Потім передайте його програмі `awk` для обробки

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

   ```
    `a[$1]++` еквівалентно до `a[$1]+=1`
   ```

   Підрахуйте кількість входжень слів незалежно від регістру. Основна ідея:

   - Розділити всі поля на кілька рядків записів
   - Потім передайте його програмі `awk` для обробки

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

   Ви можете спочатку відфільтрувати певні записи рядків, а потім виконати статистику, наприклад:

   ```bash
   Shell > ss -tulnp | awk -F " "  '/tcp/ {a[$2]++} END{for(i in a) print a[i],i}'
   2 LISTEN  
   ```

8. Вивести рядки на основі кількості входжень певного поля

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

   Зворотний:

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

9. Багатовимірний масив

   Програма `awk` не підтримує багатовимірні масиви, але підтримку багатовимірних масивів можна досягти за допомогою моделювання. За замовчуванням "\034" є роздільником для нижнього індексу багатовимірного масиву.

   Зверніть увагу на наступні відмінності під час використання багатовимірних масивів:

   ```bash
   Shell > awk 'BEGIN{ a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
   200 20
   300 30
   100 1,0
   ```

   Перевизначте роздільник:

   ```bash
   Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i }'
   300 3----0
   200 2----0
   100 1,0
   ```

   Перезамовлення：

   ```bash
   Shell > awk 'BEGIN{ SUBSEP="----" ; a["1,0"]=100 ; a[2,0]=200 ; a["3","0"]=300 ; for(i in a) print a[i],i | "sort" }'
   100 1,0
   200 2----0
   300 3----0
   ```

   Підрахуйте, скільки разів з’являється поле:

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

## Вбудована функція

| Ім'я функції                                                                                                                                                                                                             | Опис                                                                                                                                                                                                                      |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| int(expr)                                                                                                                                                                                             | Обрізається як ціле число                                                                                                                                                                                                 |
| sqrt(expr)                                                                                                                                                                                            | Квадратний корінь                                                                                                                                                                                                         |
| rand()                                                                                                                                                                                                | Повертає випадкове число N із діапазоном (0,1). Результат не те, що кожен запуск є випадковим числом, але він залишається незмінним.                                                                   |
| srand([expr])                                                                                                                                     | Використовує "expr" для генерації випадкових чисел. Якщо «expr» не вказано, поточний час використовується як початкове значення за замовчуванням, а якщо початкове число є, використовується згенероване випадкове число. |
| asort(a,b)                                                                                                                                                                                            | Елементи масиву "a" змінено (лексикографічно) і збережено в новому масиві "b", причому нижній індекс у масиві "b" починається з 1. Ця функція повертає кількість елементів у масиві.                   |
| asorti(a,b)                                                                                                                                                                                           | Змінює порядок нижнього індексу масиву «a» та зберігає відсортований індекс у новому масиві «b» як елемент, причому нижній індекс масиву «b» починається з 1.                                                             |
| sub(r,s[,t])                                                                                                                                      | Регулярний вираз «r» відповідає вхідним записам і замінює відповідний результат на «s». "t" є необов'язковим, вказуючи на заміну для певного поля. Функція повертає кількість замін - 0 або 1. Подібно до `sed s//`       |
| gsub(r,s[,t])                                                                                                                                     | Глобальна заміна. "t" є необов'язковим, вказуючи на заміну певного поля. Якщо "t" ігнорується, це означає глобальну заміну. Подібно до `sed s///g`                                                                        |
| gensub(r,s,h[,t])                                                                                                                                 | Регулярний вираз «r» відповідає вхідним записам і замінює відповідний результат на «s». "t" є необов'язковим, вказуючи на заміну для певного поля. "h" означає заміну зазначеної позиції індексу                          |
| index(s,t)                                                                                                                                                                                            | Повертає позицію індексу рядка "t" у рядку "s" (індекс рядка починається з 1). Якщо функція повертає 0, це означає, що її не існує                                                                     |
| length([s])                                                                                                                                       | Повертає довжину "s"                                                                                                                                                                                                      |
| match(s,r[,a])                                                                                                                                    | Перевіряє, чи містить рядок "s" рядок "r". Якщо включено, повертає позицію індексу " r " у ньому (рядковий індекс починається з 1). Якщо ні, повертає 0                                                |
| split(s,a[,r[,seps]])                                                                         | Розділити рядок "s" на масив "a" на основі роздільника "seps". Індекс масиву починається з 1.                                                                                                                             |
| substr(s,i[,n])                                                                                                                                   | Перехоплює рядок. "s" представляє рядок для обробки; "i" вказує позицію індексу рядка; "n" - довжина. Якщо ви не вказуєте «n», це означає перехоплення всіх частин, що залишилися                                         |
| tolower(str)                                                                                                                                                                                          | Перетворює всі рядки на нижній регістр                                                                                                                                                                                    |
| toupper(str)                                                                                                                                                                                          | Перетворює всі рядки у верхній регістр                                                                                                                                                                                    |
| systime()                                                                                                                                                                                             | Поточна позначка часу                                                                                                                                                                                                     |
| strftime([format[,timestamp[,utc-flag]]]) | Форматує час виведення. Перетворює мітку часу на рядок                                                                                                                                                                    |

1. Функція **int**

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

   Як бачите, функція int працює лише для чисел, а коли зустрічається рядок, вона перетворює його на 0. Зустрівши рядок, що починається з числа, скоротіть його.

2. Функція **sqrt**

   ```bash
   Shell > awk 'BEGIN{print sqrt(9)}'
   3
   ```

3. Функції **rand** та **srand**

   Приклад використання функції rand такий:

   ```bash
   Shell > awk 'BEGIN{print rand()}'
   0.924046
   Shell > awk 'BEGIN{print rand()}'
   0.924046
   Shell > awk 'BEGIN{print rand()}'
   0.924046
   ```

   Приклад використання функції srand такий:

   ```bash
   Shell > awk 'BEGIN{srand() ; print rand()}'
   0.975495
   Shell > awk 'BEGIN{srand() ; print rand()}'
   0.99187
   Shell > awk 'BEGIN{srand() ; print rand()}'
   0.069002
   ```

   Згенеруйте ціле число в діапазоні (0,100):

   ```bash
   Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
   56
   Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
   33
   Shell > awk 'BEGIN{srand() ; print int(rand()*100)}'
   42
   ```

4. Функції **asort** та **asorti**

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

   ```
    Правила сортування:

    * Числа мають вищий пріоритет, ніж рядки, і розташовані в порядку зростання.
    * Розташуйте рядки в порядку зростання словника
   ```

   Якщо ви використовуєте функцію **asorti**, приклад такий:

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

   ```
    Правила сортування:

    * Числа мають пріоритет над рядками
    * Якщо зустрічається від’ємне число, порівнюється перша цифра зліва. Якщо воно однакове, буде порівнюватися друга цифра і так далі
    * Якщо зустрінеться додатне число, воно буде розташовано в порядку зростання
    * Розташуйте рядки в порядку зростання словника
   ```

5. Функції **sub** та **gsub**

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

   Подібно до команди `sed`, ви також можете використовувати символ "&" для посилання на вже збігені рядки.

   [Перегляньте це тут](#symbol).

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

6. Функція **index**

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

7. Функція **length**

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

8. Функція **match**

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

9. Функція **split**

   ```bash
   Shell > echo "365%tmp%dir%number" | awk '{split($1,a1,"%") ; for(i in a1) print i,a1[i]}'
   1 365
   2 tmp
   3 dir
   4 number
   ```

10. Функція **substr**

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

11. Функції **tolower** та **toupper**

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

12. Функції, що працюють з часом і датою

    **Що таке мітка часу UNIX?**
    Згідно з історією розвитку GNU/Linux, UNIX V1 народилася в 1971 році, а книга «Посібник програміста UNIX» була опублікована 3 листопада того ж року, в якій 1970-01-01 є датою початку початку UNIX.

    Перетворення між міткою часу та природною датою та часом у днях:

    ```bash
    Shell > echo "$(( $(date --date="2024/01/06" +%s)/86400 + 1 ))"
    19728

    Shell > date -d "1970-01-01 19728days"
    Sat Jan  6 00:00:00 CST 2024
    ```

    Перетворення між міткою часу та природною датою та часом у секундах:

    ```bash
    Shell > echo "$(date --date="2024/01/06 17:12:00" +%s)"
    1704532320

    Shell > echo "$(date --date='@1704532320')"
    Sat Jan  6 17:12:00 CST 2024
    ```

    Перетворення між природною датою та часом UNIX у програмі `awk`:

    ```bash
    Shell > awk 'BEGIN{print systime()}'
    1704532597

    Shell > echo "1704532597" | awk '{print strftime("%Y-%m-%d %H:%M:%S",$0)}'
    2024-01-06 17:16:37
    ```

## Оператор введення/виведення

| Оператор                                                                     | Опис                                                                                                                                                                                                                                                                                                              |
| :--------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| getline                                                                      | Читає наступний відповідний запис рядка та призначає його "$0". <br/>Повернене значення дорівнює 1: вказує на те, що відповідні записи рядків було прочитано. <br/>Повернене значення дорівнює 0: вказує на те, що останній рядок було прочитано <br/>Повернене значення є від’ємним: вказує на наявність помилки |
| getline var                                                                  | Читає наступний відповідний запис рядка та призначає його змінній "var"                                                                                                                                                                                                                                           |
| command \| getline [var] | Призначає результат "$0" або змінній "var"                                                                                                                                                                                                                                                                        |
| next                                                                         | Зупиняє поточний вхідний запис і виконує наступні дії                                                                                                                                                                                                                                                             |
| print                                                                        | Друкує результат                                                                                                                                                                                                                                                                                                  |
| printf                                                                       | Дивись [тут](#printf-commands)                                                                                                                                                                                                                                                                                    |
| system(cmd-line)                                          | Виконує команду та повертає код стану. 0 означає, що команда була виконана успішно; не-0 означає, що виконання не вдалося                                                                                                                                                                                         |
| print ... >> file                                                            | Перенаправлення виводу                                                                                                                                                                                                                                                                                            |
| print ... \| command                                                         | Друкує вихідні дані та використовує їх як вхідні дані для команди                                                                                                                                                                                                                                                 |

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

   Використовуючи вивчені раніше функції та символ «&», ми можемо:

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

   Вивести парні та непарні рядки:

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

   Додайте кожен рядок b-файлу в кінець кожного рядка C-файлу:

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

   Замініть вказане поле файлу c на рядок вмісту файлу b:

   ```bash
   Shell > awk '{ getline var2 < "/tmp/b.txt" ; gsub($2 , var2 , $2) ; print $0 }' /tmp/c.txt
   A b1 HTTP
   B b2 HTTP
   B b3 MYSQL
   C b4 MYSQL
   C b5 MQ
   D b6 NGINX
   ```

3. command | getline [var\&#93

   ```bash
   Shell > awk 'BEGIN{ "date +%Y%m%d" | getline datenow ; print datenow}'
   20240107
   ```

   !!! tip "Підказка"

   ```
    Використовуйте подвійні лапки, щоб включити команду Shell.
   ```

4. next

   Раніше ми представили оператори **break** і **continue**, перший використовувався для завершення циклу, а другий використовувався для виходу з поточного циклу. Дивись [тут](#bc). Для **наступного**, коли умови виконуються, він зупиняє вхідний запис, який відповідає умовам, і продовжить наступні дії.

   ```bash
   Shell > seq 1 5 | awk '{if(NR==3) {next} print $0}'
   1
   2
   4
   5

   # equivalent to
   Shell > seq 1 5 | awk '{if($1!=3) print $0}'
   ```

   Пропустити придатні записи рядків:

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

   !!! tip "Підказка"

   ```
    "**next**" не можна використовувати в "BEGIN{}" і "END{}".
   ```

5. Функція **system**

   Ви можете використовувати цю функцію для виклику команд в Shell, наприклад:

   ```bash
   Shell > awk 'BEGIN{ system("echo nginx http") }'
   nginx http
   ```

   !!! tip "Підказка"

   ````
    Під час використання функції **system** слід додавати подвійні лапки. Якщо не додати, програма `awk` вважатиме його змінною програми `awk`.

    ```bash
    Shell > awk 'BEGIN{ cmd1="date +%Y" ; system(cmd1)}'
    2024
    ```
   ````

   **Що робити, якщо сама команда Shell містить подвійні лапки?**
   Використовувати символи екранування - "\\", такі як:

   ```bash
   Shell > egrep "^root|^nobody" /etc/passwd
   Shell > awk 'BEGIN{ system("egrep \"^root|^nobody\" /etc/passwd") }'
   root:x:0:0:root:/root:/bin/bash
   nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
   ```

   Інший приклад:

   ```bash
   Shell > awk 'BEGIN{ if ( system("xmind &> /dev/null") == 0 ) print "True"; else print "False" }'
   False
   ```

6. Запишіть вихідні дані програми `awk` у файл

   ```bash
   Shell > head -n 5 /etc/passwd | awk -F ":" 'BEGIN{OFS="\t"} {print $1,$2 > "/tmp/user.txt"}'
   Shell > cat /tmp/user.txt
   root    x
   bin     x
   daemon  x
   adm     x
   lp      x
   ```

   !!! tip "Підказка"

   ```
    "**>**" вказує на запис у файл як накладання. Якщо ви хочете писати у файл як додаток, використовуйте "**>>**". Ще раз нагадуємо, що шлях до файлу слід взяти в подвійні лапки.
   ```

7. pipe символ

   Дивись [тут](#ps)

8. Спеціальні функції

   синтаксис - `function NAME(parameter list) { function body }`. Як от:

   ```bash
   Shell > awk 'function mysum(a,b) {return a+b} BEGIN{print mysum(1,6)}'
   7
   ```

## Заключні зауваження

Якщо ви володієте спеціальними навичками програмування, `awk` відносно легко вивчити. Однак для більшості системних адміністраторів зі слабкими знаннями мови програмування (включно з автором) `awk` може бути дуже складним для вивчення. Для інформації, яка не охоплюється, див. [тут](https://www.gnu.org/software/gawk/manual/ "посібник gawk").

Ще раз дякую за читання.
