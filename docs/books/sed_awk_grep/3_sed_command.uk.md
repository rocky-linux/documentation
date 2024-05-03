---
title: Команда Sed
author: tianci li
contributors: null
tags:
  - sed
---

# Команда `sed`

`sed`: Stream Editor

**Принцип роботи**: команда `sed` прочитає поточний оброблений рядок і помістить його в "простір шаблону" для обробки. Після обробки буде виведений результат, а «простір шаблону» очищено. Далі прочитайте наступний рядок і помістіть його в «простір шаблону» для обробки і так далі до останнього рядка. Деякі документи також згадують термін під назвою «простір для зберігання» (також відомий як «простір для тимчасового зберігання»), який може тимчасово зберігати деякі оброблені дані та виводити їх через «простір шаблону».

**"простір шаблону" та "простір утримання"**: область пам’яті, де обробляються та зберігаються дані.

Для отримання додаткової інформації перегляньте [посібник `sed`](https://www.gnu.org/software/sed/manual/ "посібник sed").

Використання команди:

```bash
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

| опції | опис                                                                         |
| :---: | :--------------------------------------------------------------------------- |
|   -n  | Виводить на екран рядки тексту, які будуть оброблені лише командою `sed`     |
|   -e  | Застосовує кілька операційних команд `sed` до вхідних даних текстового рядка |
|   -f  | Викликає та виконує командний файл сценарію `sed`                            |
|   -i  | Змінює вихідний файл                                                         |
|   -r  | Регулярний вираз                                                             |

| Операційна команда<br/>(іноді називається операційною інструкцією) | опис                                                                                                                                                                                                              |
| :-----------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                                 s/regexp/replacement/                                 | Рядок заміни                                                                                                                                                                                                      |
|                                           p                                           | Друкує поточний "простір шаблону". Часто використовується з параметром -n, наприклад: `cat -n /etc/services \\| sed -n '3,5p'`                                                   |
|                                           d                                           | Видаляє «простір шаблону». Починає наступний цикл                                                                                                                                                 |
|                                           D                                           | Видаляє перший рядок «шаблону» та починає наступний цикл                                                                                                                                                          |
|                                           =                                           | Друкує номер рядка                                                                                                                                                                                                |
|                                        a \text                                        | Додає один або кілька рядків вмісту після відповідного рядка. Під час додавання кількох рядків у всіх рядках, крім останнього, потрібно використовувати "\", щоб вказати, що вміст не закінчився |
|                                                                                       |                                                                                                                                                                                                                   |
|                                        i \text                                        | Додає один або кілька рядків вмісту перед відповідним рядком. Під час додавання кількох рядків у всіх рядках, крім останнього, потрібно використовувати "\", щоб вказати, що вміст не закінчено  |
|                                        c \text                                        | Замінює відповідні рядки новим текстом                                                                                                                                                                            |
|                                           q                                           | Негайний вихід зі сценарію `sed`                                                                                                                                                                                  |
|                                           r                                           | Додає текст, прочитаний із файлу                                                                                                                                                                                  |
|                                : label                                | Мітка для команд b і t                                                                                                                                                                                            |
|                                        b label                                        | Гілка до етикетки; якщо мітку опущено, розгалужується до кінця сценарію                                                                                                                                           |
|                                        t label                                        | Якщо "s///" є успішною заміною, відбувається перехід до мітки                                                                                                                                                     |
|                                          h H                                          | Копіює/додає "простір шаблону" до "простір утримання"                                                                                                                                                             |
|                                          g G                                          | Копіює/додає "пробіл для утримання" до "простір шаблону"                                                                                                                                                          |
|                                           x                                           | Обмінюється вмістом просторів утримання та шаблонів                                                                                                                                                               |
|                                           l                                           | Виводить поточний рядок у «візуально однозначній» формі                                                                                                                                                           |
|                                          n N                                          | Читає/додає наступний рядок введення в "простір шаблону"                                                                                                                                                          |
|                                       w FILENAME                                      | Записує поточний простір шаблону до FILENAME                                                                                                                                                                      |
|                                           !                                           | заперечення                                                                                                                                                                                                       |
|                                 &                                 | Посилання на рядок, який уже збігається                                                                                                                                                                           |

|           Адреси           | опис                                                                                                                                                                                         |
| :------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| first~step | Використовуйте «first», щоб указати перший рядок, і «step», щоб вказати розмір кроку. Наприклад, виведення непарних рядків тексту за допомогою `sed -n "1~2p" /etc/services` |
|              $             | Відповідає останньому рядку тексту                                                                                                                                                           |
|          /regexp/          | Використання регулярних виразів для зіставлення рядків тексту                                                                                                                                |
|           number           | Визначає номер рядка                                                                                                                                                                         |
|         addr1,addr2        | Використовує позиціонування номерів рядків, щоб відповідати всім рядкам від "addr1" до "addr2"                                                                                               |
|          addr1,+N          | Використовує позиціонування номерів рядків для відповідності addr1 і N рядків після addr1                                                                                                    |

## Приклади використання

1. Зіставлення та друк (`p`)

   - Надрукуйте рядок, який починається з рядка NetBIOS

     ```bash
     Shell > cat /etc/services | sed -n '/^netbios/p'
     netbios-ns      137/tcp                         # NETBIOS Name Service
     netbios-ns      137/udp
     netbios-dgm     138/tcp                         # NETBIOS Datagram Service
     netbios-dgm     138/udp
     netbios-ssn     139/tcp                         # NETBIOS session service
     netbios-ssn     139/udp
     ```

   !!! tip "Підказка"

   ```
    Як ми всі знаємо, подвійні та одинарні лапки в оболонці відіграють різну роль. **$**, **\`** і **\\** у подвійних лапках мають особливе значення. Рекомендовано використовувати одинарні лапки частіше під час використання команди `sed`.
   ```

   - Вивести текст з 23 по 26 рядки

     ```bash
     Shell > cat -n /etc/services | sed -n '23,26p'
     23  tcpmux          1/tcp                           # TCP port service multiplexer
     24  tcpmux          1/udp                           # TCP port service multiplexer
     25  rje             5/tcp                           # Remote Job Entry
     26  rje             5/udp                           # Remote Job Entry
     ```

   - Друкувати непарні рядки

     ```bash
     Shell > cat -n /etc/services | sed -n '1~2p'
     1  # /etc/services:
     3  #
     5  # IANA services version: last updated 2016-07-08
     7  # Note that it is presently the policy of IANA to assign a single well-known
     9  # even if the protocol doesn't support UDP operations.
     11  # are included, only the more common ones.
     13  # The latest IANA port assignments can be gotten from
     15  # The Well Known Ports are those from 0 through 1023.
     17  # The Dynamic and/or Private Ports are those from 49152 through 65535
     19  # Each line describes one service, and is of the form:
     ...
     ```

   - Вивести рядок 10 до останнього рядка

     ```bash
     Shell > cat -n /etc/services | sed -n '10,$p'
     10  # Updated from RFC 1700, ``Assigned Numbers'' (October 1994).  Not all ports
     11  # are included, only the more common ones.
     12  #
     13  # The latest IANA port assignments can be gotten from
     14  #       http://www.iana.org/assignments/port-numbers
     15  # The Well Known Ports are those from 0 through 1023.
     16  # The Registered Ports are those from 1024 through 49151
     17  # The Dynamic and/or Private Ports are those from 49152 through 65535
     ...
     ```

   - Рядки з 10 до останнього не друкувати

     ```bash
     Shell > cat -n /etc/services | sed -n '10,$!p'
     1  # /etc/services:
     2  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
     3  #
     4  # Network services, Internet style
     5  # IANA services version: last updated 2016-07-08
     6  #
     7  # Note that it is presently the policy of IANA to assign a single well-known
     8  # port number for both TCP and UDP; hence, most entries here have two entries
     9  # even if the protocol doesn't support UDP operations.
     ```

   - Надрукуйте номер рядка та вміст відповідного рядка

     ```bash
     Shell > sed -n -e '/netbios/=' -e '/netbios/p' /etc/services
     123
     netbios-ns      137/tcp                         # NETBIOS Name Service
     124
     netbios-ns      137/udp
     125
     netbios-dgm     138/tcp                         # NETBIOS Datagram Service
     126
     netbios-dgm     138/udp
     127
     netbios-ssn     139/tcp                         # NETBIOS session service
     128
     netbios-ssn     139/udp
     ```

   - Зіставте діапазон рядків і надрукуйте його

     Використовуйте коми для розділення діапазонів рядків

     ```bash
     Shell > cat  /etc/services | sed -n '/^netbios/,/^imap/p'
     netbios-ns      137/tcp                         # NETBIOS Name Service
     netbios-ns      137/udp
     netbios-dgm     138/tcp                         # NETBIOS Datagram Service
     netbios-dgm     138/udp
     netbios-ssn     139/tcp                         # NETBIOS session service
     netbios-ssn     139/udp
     imap            143/tcp         imap2           # Interim Mail Access Proto v2
     ```

   !!! info "примітка"

   ```
    **Початок діапазону**: відповідність рядку, де розташований рядок, лише збігання з першим рядком, який з’являється.
     **Кінець діапазону**: збігається з рядком, у якому розташований рядок, лише з першим рядком, який з’являється.
   ```

   ```bash
   Shell > grep -n ^netbios /etc/services
   123:netbios-ns      137/tcp                         # NETBIOS Name Service
   124:netbios-ns      137/udp
   125:netbios-dgm     138/tcp                         # NETBIOS Datagram Service
   126:netbios-dgm     138/udp
   127:netbios-ssn     139/tcp                         # NETBIOS session service
   128:netbios-ssn     139/udp

   Shell > grep -n ^imap /etc/services
   129:imap            143/tcp         imap2           # Interim Mail Access Proto v2
   130:imap            143/udp         imap2
   168:imap3           220/tcp                         # Interactive Mail Access
   169:imap3           220/udp                         # Protocol v3
   260:imaps           993/tcp                         # IMAP over SSL
   261:imaps           993/udp                         # IMAP over SSL
   ```

   Іншими словами, вміст, надрукований вище, це рядки з 123 по 129

   - Надрукуйте рядок, де знаходиться рядок, і до останнього рядка

     ```bash
     Shell > cat /etc/services | sed -n '/^netbios/,$p'
     ```

   - Використання змінних у сценаріях bash

     ```bash
     Shell > vim test1.sh
     #!/bin/bash
     a=10

     sed -n ''${a}',$!p' /etc/services
     # or
     sed -n "${a},\$!p" /etc/services
     ```

   - Регулярний вираз

     Відповідає лише "Три цифри" + "/udp".

     ```bash
     Shell > cat /etc/services | sed -r -n '/[^0-9]([1-9]{3}\/udp)/p'
     sunrpc          111/udp         portmapper rpcbind      # RPC 4.0 portmapper UDP
     auth            113/udp         authentication tap ident
     sftp            115/udp
     uucp-path       117/udp
     nntp            119/udp         readnews untp   # USENET News Transfer Protocol
     ntp             123/udp                         # Network Time Protocol
     netbios-ns      137/udp
     netbios-dgm     138/udp
     netbios-ssn     139/udp
     ...
     ```

2. Зіставити та видалити (`d`)

   Це схоже на друк, за винятком того, що команду операції замінено на `d`, а параметр -n не потрібен.

   - Видалити всі рядки, які відповідають рядку udp, видалити всі рядки коментарів і видалити всі порожні рядки

     ```bash
     Shell > sed -e '/udp/d' -e '/^#/d' -e '/^$/d' /etc/services
     tcpmux          1/tcp                           # TCP port service multiplexer
     rje             5/tcp                           # Remote Job Entry
     echo            7/tcp
     discard         9/tcp           sink null
     systat          11/tcp          users
     daytime         13/tcp
     qotd            17/tcp          quote
     chargen         19/tcp          ttytst source
     ftp-data        20/tcp
     ftp             21/tcp
     ssh             22/tcp                          # The Secure Shell (SSH) Protocol
     telnet          23/tcp
     ...
     ```

   - Видалити послідовні рядки тексту

     ```bash
     Shell > cat -n /etc/services | sed '10,$d'
     1  # /etc/services:
     2  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
     3  #
     4  # Network services, Internet style
     5  # IANA services version: last updated 2016-07-08
     6  #
     7  # Note that it is presently the policy of IANA to assign a single well-known
     8  # port number for both TCP and UDP; hence, most entries here have two entries
     9  # even if the protocol doesn't support UDP operations.
     ```

   - Регулярний вираз

     ```bash
     Shell > cat  /etc/services | sed -r '/(tcp)|(udp)|(^#)|(^$)/d'
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

3. Замінити рядки (`s///g`)

   | Синтаксис                           | Опис синтаксису                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
   | :---------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | `sed 's/string/replace/g' FILENAME` | **s**: усі рядки, що представляють вміст файлу. Ви також можете вказати діапазон рядків, наприклад: `sed '20,200s/netbios/TMP/g' /etc/services`<br/>**g** (Глобальний): якщо g немає, це означає що коли кілька відповідних рядків з’являються в одному рядку, буде замінено лише перший відповідний рядок.<br/> **/**: стиль розділювача. Ви також можете вказати інші стилі, наприклад: `sed '20,200s?netbios?TMP?g' /etc/services` |

   !!! tip "Підказка"

   ````
    Example in the bash script:

    ```bash
    Shell > vim /root/sedReplace.sh
    #!/bin/bash
    a="SELINUX=enforcing"
    b="SELINUX=disabled"

    sed -i 's/'${a}'/'${b}'/g' /etc/selinux/config
    # or
    sed -i "s/${a}/${b}/g" /etc/selinux/config
    ```
   ````

   - Замініть і роздрукуйте

     ```bash
     Shell > sed -n '44,45s/ssh/SSH/gp' /etc/services
     SSH             22/tcp
     SSH             22/udp
     ```

   - Використовуйте символ "&", щоб посилатися на рядок<a id="symbol"></a>

     ```bash
     Shell > sed -n '44,45s/ssh/&-SSH/gp' /etc/services
     ssh-SSH             22/tcp
     ssh-SSH             22/udp
     ```

   - Використовуйте рядок, щоб знайти один або кілька рядків і замінити вказаний рядок у діапазоні рядків

     ```bash
     Shell > grep ssh /etc/services -n
     44:ssh             22/tcp                          # The Secure Shell (SSH) Protocol
     45:ssh             22/udp                          # The Secure Shell (SSH) Protocol
     551:x11-ssh-offset  6010/tcp                        # SSH X11 forwarding offset
     593:ssh             22/sctp                 # SSH
     1351:sshell          614/tcp                 # SSLshell
     1352:sshell          614/udp                 #       SSLshell
     1607:netconf-ssh     830/tcp                 # NETCONF over SSH
     1608:netconf-ssh     830/udp                 # NETCONF over SSH
     7178:sdo-ssh         3897/tcp                # Simple Distributed Objects over SSH
     7179:sdo-ssh         3897/udp                # Simple Distributed Objects over SSH
     7791:netconf-ch-ssh  4334/tcp                # NETCONF Call Home (SSH)
     8473:snmpssh         5161/tcp                # SNMP over SSH Transport Model
     8474:snmpssh-trap    5162/tcp                # SNMP Notification over SSH Transport Model
     9126:tl1-ssh         6252/tcp                # TL1 over SSH
     9127:tl1-ssh         6252/udp                # TL1 over SSH
     10796:ssh-mgmt        17235/tcp               # SSH Tectia Manager
     10797:ssh-mgmt        17235/udp               # SSH Tectia Manager

     Shell > sed '/ssh/s/tcp/TCP/gp' -n  /etc/services
     ssh             22/TCP                          # The Secure Shell (SSH) Protocol
     x11-ssh-offset  6010/TCP                        # SSH X11 forwarding offset
     sshell          614/TCP                 # SSLshell
     netconf-ssh     830/TCP                 # NETCONF over SSH
     sdo-ssh         3897/TCP                # Simple Distributed Objects over SSH
     netconf-ch-ssh  4334/TCP                # NETCONF Call Home (SSH)
     snmpssh         5161/TCP                # SNMP over SSH Transport Model
     snmpssh-trap    5162/TCP                # SNMP Notification over SSH Transport Model
     tl1-ssh         6252/TCP                # TL1 over SSH
     ssh-mgmt        17235/TCP               # SSH Tectia Manager
     ```

   - Заміна рядка для послідовних рядків

     ```bash
     Shell > sed '10,30s/tcp/TCP/g' /etc/services
     ```

   - Кілька збігів і замін

     ```bash
     Shell > cat /etc/services | sed 's/netbios/test1/g ; s/^#//d ; s/dhcp/&t2/g'
     ```

   - Групова заміна регулярних виразів

     У регулярних виразах "()" є групуванням. \1 представляє референтну групу 1, \2 представляє референтну групу 2 і так далі.

     ```bash
     Shell > cat /etc/services
     ...
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     axio-disc       35100/udp               # Axiomatic discovery protocol
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures

     Shell > cat /etc/services | sed -r 's/([0-9]*\/tcp)/\1\tCONTENT1/g ; s/([0-9]*\/udp)/\1\tADD2/g'
     ...
     axio-disc       35100/tcp       CONTENT1               # Axiomatic discovery protocol
     axio-disc       35100/udp       ADD2               # Axiomatic discovery protocol
     pmwebapi        44323/tcp       CONTENT1               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp       ADD2               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp       CONTENT1               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp       CONTENT1               # Capture handwritten signatures
     ```

     **\t**: тобто вкладка

   - Замініть усі рядки коментарів порожніми

     ```bash
     Shell > cat /etc/services | sed -r 's/(^#.*)//g'
     ...
     chargen         19/udp          ttytst source
     ftp-data        20/tcp
     ftp-data        20/udp

     ftp             21/tcp
     ftp             21/udp          fsp fspd
     ssh             22/tcp                          # The Secure Shell (SSH) Protocol
     ssh             22/udp                          # The Secure Shell (SSH) Protocol
     ...
     ```

   - Замініть одну з малих літер слова великою

     ```bash
     Shell > echo -e "hello,world\nPOSIX" | sed -r 's/(.*)w/\1W/g'
     hello,World
     POSIX
     ```

   - Зміна позиції рядка

     ```bash
     Shell > cat /etc/services
     ...
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

     Ми можемо розділити цей файл на п'ять частин:

     ```txt
     cloudcheck-ping    45514       /     udp        # ASSIA CloudCheck WiFi Management keepalive
      ↓                   ↓         ↓      ↓               ↓
     (.*)           (\<[0-9]+\>)   \/   (tcp|udp)         (.*)
      ↓                   ↓                ↓               ↓ 
      \1                 \2               \3              \4
     ```

     ```bash
     Shell > cat /etc/services | sed -r 's/(.*)(\<[0-9]+\>)\/(tcp|udp)(.*)/\1\3\/\2\4/g'
     ...
     edi_service     udp/34567               # dhanalakshmi.org EDI Service
     axio-disc       tcp/35100               # Axiomatic discovery protocol
     axio-disc       udp/35100               # Axiomatic discovery protocol
     pmwebapi        tcp/44323               # Performance Co-Pilot client HTTP API
     cloudcheck-ping udp/45514               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      tcp/45514               # ASSIA CloudCheck WiFi Management System
     spremotetablet  tcp/46998               # Capture handwritten signatures
     ```

   - Видаліть усі пробіли

     ```bash
     Shell > echo -e "abcd\t1 2 3 4\tWorld"
     abcd    1 2 3 4 World
     Shell > echo -e "abcd\t1 2 3 4\tWorld" | sed -r 's/(\s)*//g'
     abcd1234World
     ```

4. Виконайте кілька разів за допомогою параметра -e

   Наступний приклад:

   ```bash
   Shell > tail -n 10 /etc/services
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

   Shell > tail -n 10 /etc/services | sed  -e '1,3d' -e '/cloud/s/ping/PING/g'
   # or
   Shell > tail -n 10 /etc/services | sed  '1,3d ; /cloud/s/ping/PING/g'      
   edi_service     34567/udp               # dhanalakshmi.org EDI Service
   axio-disc       35100/tcp               # Axiomatic discovery protocol
   axio-disc       35100/udp               # Axiomatic discovery protocol
   pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
   cloudcheck-PING 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
   cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
   spremotetablet  46998/tcp               # Capture handwritten signatures
   ```

5. Додайте вміст над або під певним рядком («i» і «a»)

   - Додайте два рядки вмісту над вказаним номером рядка

     ```bash
     Shell > tail -n 10 /etc/services > /root/test.txt
     Shell > cat /root/test.txt
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

     Shell > cat /root/test.txt | sed '3i 123\
     abc'
     aigairserver    21221/tcp               # Services for Air Server
     ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     123
     abc
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     edi_service     34567/udp               # dhanalakshmi.org EDI Service
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     axio-disc       35100/udp               # Axiomatic discovery protocol
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

   - Додайте три рядки під вказаним номером рядка

   ```bash
   Shell > cat /root/test.txt | sed '5a 123\
   comment yes\
   tcp or udp'
   aigairserver    21221/tcp               # Services for Air Server
   ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
   ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
   edi_service     34567/udp               # dhanalakshmi.org EDI Service
   axio-disc       35100/tcp               # Axiomatic discovery protocol
   123
   comment yes
   tcp or udp
   axio-disc       35100/udp               # Axiomatic discovery protocol
   pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
   cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
   cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
   spremotetablet  46998/tcp               # Capture handwritten signatures
   ```

   - Зіставте певний рядок на основі рядка та додайте 2 рядки вмісту над ним

     ```bash
     Shell > cat /root/test.txt | sed '/tcp/iTCP\
     UDP'
     TCP
     UDP
     aigairserver    21221/tcp               # Services for Air Server
     ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     TCP
     UDP
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     edi_service     34567/udp               # dhanalakshmi.org EDI Service
     TCP
     UDP
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     axio-disc       35100/udp               # Axiomatic discovery protocol
     TCP
     UDP
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     TCP
     UDP
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     TCP
     UDP
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

6. Замінити рядки (`c`)

   - Знайдіть один або кілька рядків на основі рядка та замініть ці рядки тексту

     ```bash
     Shell > cat /root/test.txt | sed '/ser/c\TMP1 \
     TMP2'
     TMP1
     TMP2
     ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     TMP1
     TMP2
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     axio-disc       35100/udp               # Axiomatic discovery protocol
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

   - Заміна однієї лінії

     ```bash
     Shell > cat /root/test.txt | sed '7c REPLACE'
     aigairserver    21221/tcp               # Services for Air Server
     ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     edi_service     34567/udp               # dhanalakshmi.org EDI Service
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     axio-disc       35100/udp               # Axiomatic discovery protocol
     REPLACE
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

   - Замінити послідовні рядки тексту

     ```bash
     Shell > cat /root/test.txt | sed '2,$c REPLACE1 \
     replace2'
     aigairserver    21221/tcp               # Services for Air Server
     REPLACE1
     replace2
     ```

   - Замініть парні рядки

     ```bash
     Shell > cat /root/test.txt | sed '2~2c replace'
     aigairserver    21221/tcp               # Services for Air Server
     replace
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     replace
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     replace
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     replace
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     replace
     ```

7. Прочитайте вміст файлу та додайте його вміст під відповідним рядком (`r`)

   ```bash
   Shell > cat /root/app.txt
   append1
   POSIX
   UNIX

   Shell > cat /root/test.txt | sed '/ping/r /root/app.txt'
   aigairserver    21221/tcp               # Services for Air Server
   ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
   ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
   edi_service     34567/udp               # dhanalakshmi.org EDI Service
   axio-disc       35100/tcp               # Axiomatic discovery protocol
   axio-disc       35100/udp               # Axiomatic discovery protocol
   pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
   cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
   append1
   POSIX
   UNIX
   cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
   spremotetablet  46998/tcp               # Capture handwritten signatures
   ```

8. Записати відповідні рядки в інші файли (`w`)

   ```bash
   Shell > cat /root/test.txt | sed '/axio/w /root/storage.txt'

   Shell > cat /root/storage.txt
   axio-disc       35100/tcp               # Axiomatic discovery protocol
   axio-disc       35100/udp               # Axiomatic discovery protocol
   ```

9. Читання/додавання наступного рядка введення в "простір шаблону" (`n` і `N`)

   - Надрукуйте наступний рядок відповідного рядка

     ```bash
     Shell > cat /root/test.txt
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

     Shell > cat /root/test.txt | sed '/ping/{n;p}' -n
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     ```

   !!! tip "Підказка"

   ```
    Кілька команд операції `sed` можуть впливати одна на одну, і ви можете використовувати "**{ }**", щоб зменшити цей вплив.
   ```

   - Друк рівних рядків тексту

     Спочатку прочитайте перший рядок, оскільки присутня команда `n`; буде роздруковано другий рядок і так далі.

     ```bash
     Shell > cat -n /root/test.txt | sed -n '{n;p}'
     # or
     Shell > cat -n /root/test.txt | sed -n '2~2p'
     2  ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     4  edi_service     34567/udp               # dhanalakshmi.org EDI Service
     6  axio-disc       35100/udp               # Axiomatic discovery protocol
     8  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     10  spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

   - Друк непарних рядків тексту

     ```bash
     Shell > cat -n /root/test.txt | sed -n '{p;n}'
     # or
     Shell > cat -n /root/test.txt | sed -n '1~2p'
     # or
     Shell > cat -n /root/test.txt | sed 'n;d'
     1  aigairserver    21221/tcp               # Services for Air Server
     3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     5  axio-disc       35100/tcp               # Axiomatic discovery protocol
     7  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     ```

   - Вивести 3n рядків

     ```bash
     Shell > cat -n /root/test.txt | sed -n '{n;n;p}'
     # or
     Shell > cat -n /root/test.txt | sed -n '3~3p'
     3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     6  axio-disc       35100/udp               # Axiomatic discovery protocol
     9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     ```

   - `N`

     Прочитайте перший рядок і додайте один рядок після зустрічі з командою `N`. У цьому прикладі «простір шаблону» — «1\n2». Нарешті, виконайте команду `q`, щоб вийти.

     ```bash
     Shell > seq 1 10 | sed 'N;q'
     1
     2
     ```

     Оскільки після рядка 9 немає додаткового рядка, результат буде таким:

     ```bash
     Shell > seq 1 9 | sed -n 'N;p'
     1
     2
     3
     4
     5
     6
     7
     8
     ```

     Коли зчитується останній рядок, команда `N` не виконується, і виводиться наступне:

     ```bash
     Shell > seq 1 9 | sed -n '$!N;p'
     1
     2
     3
     4
     5
     6
     7
     8
     9
     ```

     Об’єднати два рядки в один. Замініть "\n" у "шаблоні" пробілом.

     ```bash
     Shell > seq 1 6 | sed 'N;{s/\n//g}'
     12
     34
     56
     ```

10. Ігнорувати регістр ('I')

    Здається, немає інформації про ігнорування регістру в `man 1 sed`.

    ```bash
    Shell > echo -e "abc\nAbc" | sed -n 's/a/X/Igp'
    Xbc
    XBC
    ```

    ```bash
    Shell > cat /etc/services | sed '/OEM/Ip' -n
    oem-agent       3872/tcp                # OEM Agent
    oem-agent       3872/udp                # OEM Agent
    oemcacao-jmxmp  11172/tcp               # OEM cacao JMX-remoting access point
    oemcacao-rmi    11174/tcp               # OEM cacao rmi registry access point
    oemcacao-websvc 11175/tcp               # OEM cacao web service access point
    ```

    ```bash
    Shell > cat /etc/services | sed -r '/(TCP)|(UDP)/Id'
    ```

    ```bash
    Shell > cat /etc/services | sed -r '/(TCP)|(UDP)/Ic TMP'
    ```

11. Отримує загальну кількість рядків у файлі

    ```bash
    Shell > cat /etc/services | sed -n '$='
    # or
    Shell > cat /etc/services | wc -l

    11473
    ```
