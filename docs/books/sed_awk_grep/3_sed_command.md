---
title: Sed command
author: tianci li
contributors: 
tags:
  - sed
---

# `sed` command

`sed`: Stream EDitor

**Working principle**: The `sed` command will read the currently processed row and place it in the "pattern space" for processing. After processing, the result will be output and the "pattern space" will be cleared. Next, read the next line and place it in the "pattern space" for processing, and so on, until the last line. Some documents also mention a term called "hold space" (also known as "temporary-storage space"), which can temporarily store some processed data and output it through "pattern space".

**"pattern space" and "hold space"**: An area of memory where data is processed and stored.

For information not covered, review [the `sed` manual](https://www.gnu.org/software/sed/manual/ "sed manual").

The usage of the command is:

```bash
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

| options | description |
| :---: | :--- |
| -n    | Output text lines that will only be processed by the `sed` command to the screen |
| -e    | Apply multiple `sed` operation commands to the input text line data |
| -f    | Call and execute `sed` script command file |
| -i    | Modify the original file |
| -r    | Regular expression |

| Operation command<br/>(sometimes called operation instruction)| description |
| :---:                  | :--- |
| s/regexp/replacement/  | Replacement string |
|  p                     | Print the current "pattern space". Often used with the -n option, for example: `cat -n /etc/services \| sed -n '3,5p'` |
|  d                     | Delete "pattern space". Start next cycle    |
|  D                     | Delete the first line of the "pattern space" and start next  cycle |
|  =                     | Print Line Number |
| a \text                | Add one or more lines of content after the matching line. When adding multiple lines, all lines except the last line need to use "\" to indicate that the content has not ended
 |
| i \text                | Add one or more lines of content before the matching line. When adding multiple lines, all lines except the last line need to use "\" to indicate that the content is not ended |
| c \text                | Replace matching lines with new text |
| q                      | Immediately exit the `sed` script    |
| r                      | Append text read from file |
| : label                | Label for b and t commands |
| b label                | Branch to label; if label is omitted, branch to end of script |
| t label                | If "s///" is a successful replacement, then jump to the label |
| h H                    | Copy/append "pattern space" to "hold space"  |
| g G                    | Copy/append "hold space" to "pattern space"  |
| x                      | Exchange the contents of the hold and pattern spaces |
| l                      | List out the current line in a "visually unambiguous" form |
| n N                    | Read/append the next line of input into the "pattern space" |
| w FILENAME             | Write the current pattern space to FILENAME       |
| !                      | negation |
| &                      | Referencing a string that already matches |

| Addresses    | description |
| :---:        |  :---       |
| first~step   | Use "first" to specify the first line, and 'step' to specify the step size. For example, outputting odd lines of text with `sed -n "1~2p" /etc/services` |
| $            | Match the last line of text |
| /regexp/     | Using regular expressions to match text lines |
| number       | Specify line number  |
| addr1,addr2  | Use line number positioning to match all lines from "addr1" to "addr2" |
| addr1,+N     | Use line number positioning to match addr1 and the N lines following addr1  |

## Examples of usage

1. Match and print (`p`)

    * Print a line that begins with a netbios string

      ```bash
      Shell > cat /etc/services | sed -n '/^netbios/p'
      netbios-ns      137/tcp                         # NETBIOS Name Service
      netbios-ns      137/udp
      netbios-dgm     138/tcp                         # NETBIOS Datagram Service
      netbios-dgm     138/udp
      netbios-ssn     139/tcp                         # NETBIOS session service
      netbios-ssn     139/udp
      ```

    !!! tip

        As we all know, double and single quotation marks in a shell play different roles. The **$**, **\`**, and **\\** in double quotes have a special meaning. The recommendation is to use single quotes more often when using the `sed` command.

    * Print the text from lines 23 to 26

      ```bash
      Shell > cat -n /etc/services | sed -n '23,26p'
      23  tcpmux          1/tcp                           # TCP port service multiplexer
      24  tcpmux          1/udp                           # TCP port service multiplexer
      25  rje             5/tcp                           # Remote Job Entry
      26  rje             5/udp                           # Remote Job Entry
      ```

    * Print odd lines

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

    * Print line 10 to the last line

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

    * Lines 10 to the last do not print

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

    * Print the line number and content of the matched string

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

    * Match string range and print it

      Use commas to separate string ranges

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

    !!! info

        **Start of range**: Match the line where the string is located, only matching the first string that appears.
        **End of range**: Match the line where the string is located, only matching the first string that appears.

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

      In other words, the content printed above is lines 123 to 129

    * Print the line where the string is located and until the last line

      ```bash
      Shell > cat /etc/services | sed -n '/^netbios/,$p'
      ```

    * Using variables in bash scripts

      ```bash
      Shell > vim test1.sh
      #!/bin/bash
      a=10

      sed -n ''${a}',$!p' /etc/services
      # or
      sed -n "${a},\$!p" /etc/services
      ```

    * Regular expression

      Matches only "Three Digits" + "/udp".

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

2. Match and delete (`d`)

    It is similar to printing, except that the operation command is replaced with `d` and the -n option is not required.

    * Delete all lines that match the udp string, and delete all comment lines, and delete all Blank line

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

    * Delete consecutive lines of text

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

    * Regular expression

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

3. Replace strings(`s///g`)

    | Syntax                               | Syntax description|
    | :---                                 | :---              |
    | `sed 's/string/replace/g' FILENAME`  | **s**: All lines representing the content of the file. You can also specify the range of lines, for example: `sed '20,200s/netbios/TMP/g' /etc/services`<br/>**g** (Global): If there is no g, This means that when multiple matching strings appear on a single line, only the first matching string will be replaced.<br/> **/**: Delimiter style. You can also specify other styles, for example: `sed '20,200s?netbios?TMP?g' /etc/services` |

    !!! tip

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

    * Replace and print

      ```bash
      Shell > sed -n '44,45s/ssh/SSH/gp' /etc/services
      SSH             22/tcp
      SSH             22/udp
      ```

    * Use the "&" symbol to reference a string<a id="symbol"></a>

      ```bash
      Shell > sed -n '44,45s/ssh/&-SSH/gp' /etc/services
      ssh-SSH             22/tcp
      ssh-SSH             22/udp
      ```

    * Use a string to locate one or more lines and replace the specified string within the line range

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

    * String replacement for consecutive lines

      ```bash
      Shell > sed '10,30s/tcp/TCP/g' /etc/services
      ```

    * Multiple matches and replacements

      ```bash
      Shell > cat /etc/services | sed 's/netbios/test1/g ; s/^#//d ; s/dhcp/&t2/g'
      ```

    * Group replacement of regular expressions

      In regular expressions, a "()" is a grouping. \1 represents reference group 1, \2 represents reference group 2, and so on.

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

      **\t**: That is, a tab

    * Replace all comment lines with blank space

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

    * Replace one of the lowercase letters of a word with a capital letter

      ```bash
      Shell > echo -e "hello,world\nPOSIX" | sed -r 's/(.*)w/\1W/g'
      hello,World
      POSIX
      ```

    * String position swapping

      ```bash
      Shell > cat /etc/services
      ...
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

      We can divide this file into five parts:

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

    * Remove any blank characters

      ```bash
      Shell > echo -e "abcd\t1 2 3 4\tWorld"
      abcd    1 2 3 4 World
      Shell > echo -e "abcd\t1 2 3 4\tWorld" | sed -r 's/(\s)*//g'
      abcd1234World
      ```

4. Execute multiple times using the -e option

    The following example:

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

5. Add content above or below a specific line (`i` and `a`)

    * Add two lines of content above the specified line number

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

    * Add three lines below the specified line number

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

    * Match a specific line based on a string and add 2 lines of content above it

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

6. Replace lines (`c`)

    * Locate one or more lines based on a string and replace these lines of text

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

    * Single line replacement

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

    * Replace consecutive lines of text

      ```bash
      Shell > cat /root/test.txt | sed '2,$c REPLACE1 \
      replace2'
      aigairserver    21221/tcp               # Services for Air Server
      REPLACE1
      replace2
      ```

    * Replace even numbered lines

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

7. Read the contents of the file and append its contents below the matching line (`r`)

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

8. Write matching lines to other files (`w`)

    ```bash
    Shell > cat /root/test.txt | sed '/axio/w /root/storage.txt'

    Shell > cat /root/storage.txt
    axio-disc       35100/tcp               # Axiomatic discovery protocol
    axio-disc       35100/udp               # Axiomatic discovery protocol
    ```

9. Read/append the next line of input into the "pattern space" (`n` and `N`)

    * Print the next line of the matching line

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

    !!! tip

        Multiple `sed` operation commands may affect each other, and you can use "**{ }**" to reduce this effect.

    * Print even text lines

      First, read the first line, as an n command is present; the second line will be printed out, and so on.

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

    * Print odd text lines

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

    * Print 3n lines

      ```bash
      Shell > cat -n /root/test.txt | sed -n '{n;n;p}'
      # or
      Shell > cat -n /root/test.txt | sed -n '3~3p'
      3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      6  axio-disc       35100/udp               # Axiomatic discovery protocol
      9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      ```

    * `N`

      Read the first line and append one line after encountering the `N` command. In this example, the "pattern space" is "1\n2". Finally, execute the `q` command to exit.

      ```bash
      Shell > seq 1 10 | sed 'N;q'
      1
      2
      ```

      Because there is no additional line after line 9, the output is as follows:

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

      When the last line is read, the `N` command is not executed and the output is as follows:

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

      Merge two lines into one line. Replace the "\n" of the "pattern space" with a blank character.

      ```bash
      Shell > seq 1 6 | sed 'N;{s/\n//g}'
      12
      34
      56
      ```

10. Ignore case (`I`)

      There seems to be no information about ignoring case in `man 1 sed`.

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

11. Gets the total number of lines in a file

      ```bash
      Shell > cat /etc/services | sed -n '$='
      # or
      Shell > cat /etc/services | wc -l

      11473
      ```
