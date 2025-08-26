---
title: Comando Sed
author: tianci li
contributors:
tags:
  - sed
---

# Comando `sed`

`sed`: Stream Editor

**Principio di funzionamento**: Il comando `sed` legge la riga elaborata al momento e la inserisce nel "pattern space" per l'elaborazione. Dopo l'elaborazione, il risultato sarà visualizzato in output e il "pattern space" sarà liberato. Poi, legge la riga successiva, la inserisce nel "pattern space" per l'elaborazione e così via, fino all'ultima riga. Alcuni documenti, inoltre, menzionano un termine detto "hold space" (anche noto come "temporary-storage space"), che può memorizzare temporaneamente dei dati elaborati e mostrarli attraverso il "pattern space".

**"pattern space" and "hold space"**: Un'area di memoria dove i dati sono elaborati e memorizzati.

Per ultariori informazioni, consultare [il manuale `sed`](https://www.gnu.org/software/sed/manual/ "sed manual").

L'uso del comando è:

```bash
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

| opzioni | descrizione                                                                  |
| :-----: | :--------------------------------------------------------------------------- |
|    -n   | Visualizza a video le righe di testo che saranno elaborate dal comando `sed` |
|    -e   | Esegue più comandi `sed` ai dati della riga di testo di input                |
|    -t   | Chiama ed esegue il file di script con i comandi per `sed`                   |
|    -i   | Modifica il file di origine                                                  |
|    -r   | Espressione regolare                                                         |

| Comando operativo (talvolta detto istruzione operativa) | descrizione                                                                                                                                                                                                                                 |
| :------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|                            s/regexp/replacement/                           | Stringa di sostituzione                                                                                                                                                                                                                     |
|                                      p                                     | Visualizza il "pattern space" corrente. Utilizzato spesso con l'opzione -n, ad esempio: `cat -n /etc/services \\| sed -n '3,5p'`                                                                           |
|                                      d                                     | Elimina lo "pattern space". Inizia il ciclo successivo                                                                                                                                                                      |
|                                      D                                     | Elimina la prima riga del "pattern space" e avvia il ciclo successivo                                                                                                                                                                       |
|                                      =                                     | Visualizza il numero di riga                                                                                                                                                                                                                |
|                                   a \text                                  | Aggiunge una o più righe di testo dopo la riga in cui è stata trovata una associazione. Per aggiungere più righe, alla fine di ogni riga tranne l'ultima si deve aggiungere "\" per indicare che il contenuto prosegue     |
|                                                                            |                                                                                                                                                                                                                                             |
|                                   i \text                                  | Aggiunge una o più righe di testo prima della riga in cui è stata trovata una associazione. Per aggiungere più righe, alla fine di ogni riga tranne l'ultima si deve aggiungere "\" per indicare che il contenuto prosegue |
|                                   c \text                                  | Sostituisce le righe in cui è presente un match con il nuovo testo                                                                                                                                                                          |
|                                      q                                     | Esce immediatamente dallo script \`sed                                                                                                                                                                                                      |
|                                      r                                     | Aggiungere il testo letto dal file                                                                                                                                                                                                          |
|                           : label                          | Label per i comandi b e t                                                                                                                                                                                                                   |
|                                   b label                                  | Passa al label; se il label viene omesso, passa alla fine dello script                                                                                                                                                                      |
|                                   t label                                  | Se "s///" è sostituita con successo, passa direttamente all'label                                                                                                                                                                           |
|                                     h H                                    | Copia/aggiungi il "pattern space" al "hold space"                                                                                                                                                                                           |
|                                     g G                                    | Copia/aggiungi l' "hold space" al "pattern space"                                                                                                                                                                                           |
|                                      x                                     | Scambia i contenuti tra "hold space" e "pattern space"                                                                                                                                                                                      |
|                                      l                                     | Visualizza la riga corrente in un modulo "visually unambiguous"                                                                                                                                                                             |
|                                     n N                                    | Leggi/aggiungi la riga successiva dell'input nello "pattern space"                                                                                                                                                                          |
|                                 w FILENAME                                 | Salva l'attuale "pattern space" nel file FILENAME                                                                                                                                                                                           |
|                                      !                                     | negazione logica                                                                                                                                                                                                                            |
|                            &                           | Riferimento ad una stringa già trovata                                                                                                                                                                                                      |

|          Indirizzi         | descrizione                                                                                                                                                                                               |
| :------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| first~step | Utilizza "first" per specificare la prima riga e 'step' per specificare il numero di righe da saltare. Ad esempio, visualizza le righe di testo dispari con `sed -n "1~2p" /etc/services` |
|              $             | Associa l'ultima riga di testo                                                                                                                                                                            |
|          /regexp/          | Utilizza espressioni regolari nelle associazioni alle righe del testo                                                                                                                                     |
|           number           | Si specifica il numero di riga                                                                                                                                                                            |
|         addr1,addr2        | Si utilizza per impostare il numero delle righe per la ricerca da "addr1" ad "addr2"                                                                                                                      |
|          addr1,+N          | Si utilizza per impostare il numero di riga di partenza "addr1" e le N righe che seguono per effettuare la ricerca                                                                                        |

## Esempi di utilizzo

1. Associa e visualizza (`p`)

   - Visualizza le righe che iniziano con la stringa netbios

     ```bash
     Shell > cat /etc/services | sed -n '/^netbios/p'
     netbios-ns      137/tcp                         # NETBIOS Name Service
     netbios-ns      137/udp
     netbios-dgm     138/tcp                         # NETBIOS Datagram Service
     netbios-dgm     138/udp
     netbios-ssn     139/tcp                         # NETBIOS session service
     netbios-ssn     139/udp
     ```

   !!! tip "Suggerimento"

   ```
    Come sappiamo bene, le virgolette doppie e singole in una shell ricoprono ruoli differenti. I caratteri **$**, **\`** e **\\** tra virgolette doppie hanno un significato speciale. Il consiglio è utilizzare le virgolette singole più spesso con il comando `sed`.
   ```

   - Visualizza il testo da riga 23 a riga 26

     ```bash
     Shell > cat -n /etc/services | sed -n '23,26p'
     23  tcpmux          1/tcp                           # TCP port service multiplexer
     24  tcpmux          1/udp                           # TCP port service multiplexer
     25  rje             5/tcp                           # Remote Job Entry
     26  rje             5/udp                           # Remote Job Entry
     ```

   - Visualizza solo le righe dispari

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

   - Visualizza dalla riga 10 fino all'ultima riga

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

   - Non visualizzare dalla riga 10 in poi

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

   - Visualizza il numero di riga e il contenuto della stringa corrispondente

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

   - Trova le corrispondenze nell'elenco delle stringhe e lo visualizza

     Utilizzare la virgola per separare l'elenco delle stringhe di ricerca

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

   !!! info "Informazione"

   ```
    **Stringa iniziale**: Abbina la riga in cui si trova la stringa, mostrando solo la prima stringa che compare.
    **Stringa finale**: Abbina la riga in cui si trova la stringa, mostrando solo la prima stringa che compare.
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

   In altre parole, i contenuti sopra visualizzati sono le righe dalla 123 alla 129

   - Visualizza dalla riga in cui si trova la stringa fino all'ultima riga

     ```bash
     Shell > cat /etc/services | sed -n '/^netbios/,$p'
     ```

   - Usare le variabili negli script bash

     ```bash
     Shell > vim test1.sh
     #!/bin/bash
     a=10

     sed -n ''${a}',$!p' /etc/services
     # or
     sed -n "${a},\$!p" /etc/services
     ```

   - Espressione regolare

     Abbina soltanto Tre "Digits" + "/udp".

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

2. Associa ed elimina (`d`)

   È simile alla stampa, tranne per il fatto che il comando operation è sostituito da `d` e l'opzione -n non è richiesta.

   - Elimina tutte le righe corrispondenti alla stringa udp, ed elimina tutte le righe di commento o vuote

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

   - Elimina le righe successive a quella specificata

     ```bash
     Shell > cat -n /etc/services | sed '10,$d'
     1  # /etc/services:
     2  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
     3  #
     4  # Servizi di rete, stile di Internet
     5  # Versione dei servizi di IANA: ultimo aggiornamento 2016-07-08
     6  #
     7  # Nota che al momento la politica di IANA assegna un singolo ben noto
     8  # numero di porta sia per TCP che UDP; dunque, la maggior parte delle voci, qui, contiene due elementi
     9  # anche se il protocollo non supporta le operazioni UDP.
     ```

   - Espressione regolare

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

3. Sostituire stringhe (`s///g`)

   | Sintassi                            | Descrizione della sintassi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
   | :---------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | `sed 's/string/replace/g' FILENAME` | **s**: Tutte le righe da considerare nel file. Si può anche specificare un intervallo di righe, ad esempio: `sed '20,200s/netbios/TMP/g' /etc/services.  **g** (globale): Se non c'è g, significa che quando più stringhe corrispondenti appaiono su una singola riga, viene sostituita solo la prima stringa corrispondente.   **/**: Stile delimitatore. Si possono anche specificare altri stili, ad esempio:`sed '20,200s?netbios?TMP?g' /etc/services\` |

   !!! tip "Suggerimento"

   ````
    Esempio nello script bash:

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

   - Sostituisci e visualizza

     ```bash
     Shell > sed -n '44,45s/ssh/SSH/gp' /etc/services
     SSH             22/tcp
     SSH             22/udp
     ```

   - Si utilizza il simbolo "&" come riferimento a una stringa<a id="symbol"></a>

     ```bash
     Shell > sed -n '44,45s/ssh/&-SSH/gp' /etc/services
     ssh-SSH             22/tcp
     ssh-SSH             22/udp
     ```

   - Utilizza una stringa per individuare una o più righe e sostituire la stringa specificata entro l'intervallo di righe

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

   - Sostituire una stringa per righe consecutive

     ```bash
     Shell > sed '10,30s/tcp/TCP/g' /etc/services
     ```

   - Impostare più match e sostituzioni

     ```bash
     Shell > cat /etc/services | sed 's/netbios/test1/g ; s/^#//d ; s/dhcp/&t2/g'
     ```

   - Sostituzione di gruppo con espressioni regolari

     Nelle espressioni regolari, ogni "()" è un raggruppamento. \1 rappresenta il riferimento al gruppo 1, \2 rappresenta il riferimento al gruppo 2, e così via.

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

     **\t**: è il carattere di tabulazione

   - Sostituisce tutte le righe di commento con il carattere blank space

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

   - Sostituire un carattere alfabetico in minuscolo in maiuscolo

     ```bash
     Shell > echo -e "hello,world\nPOSIX" | sed -r 's/(.*)w/\1W/g'
     hello,World
     POSIX
     ```

   - Scambiare di posizione le stringhe

     ```bash
     Shell > cat /etc/services
     ...
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

     Possiamo strutturare le righe del file in cinque parti:

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

   - Rimuovere tutti i spazi

     ```bash
     Shell > echo -e "abcd\t1 2 3 4\tWorld"
     abcd    1 2 3 4 World
     Shell > echo -e "abcd\t1 2 3 4\tWorld" | sed -r 's/(\s)*//g'
     abcd1234World
     ```

4. Eseguire più volte seq utilizzando l'opzione -e

   Nell'esempio seguente:

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

5. Aggiungere contenuti sopra o sotto una certa riga (`i` e `a`)

   - Aggiungi due righe sopra la riga specificata dal numero di riga

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

   - Aggiungere tre righe sotto la riga specificata dal numero

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

   - Trovare le righe che contengono una stringa e aggiungere 2 righe di testo sopra ognuna

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

6. Sostituire righe (\`c)

   - Individua una o più righe contenenti una stringa e sostituire con righe di testo

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

   - Sostituire una singola riga

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

   - Sostituire righe consecutive di testo

     ```bash
     Shell > cat /root/test.txt | sed '2,$c REPLACE1 \
     replace2'
     aigairserver    21221/tcp               # Services for Air Server
     REPLACE1
     replace2
     ```

   - Sostituire tutte le righe di posizione pari

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

7. Leggere le righe del file e aggiungere del testo sotto la riga corrispondente (`r`)

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

8. Trascrivere le righe con un match in un altro file (`w`)

   ```bash
   Shell > cat /root/test.txt | sed '/axio/w /root/storage.txt'

   Shell > cat /root/storage.txt
   axio-disc       35100/tcp               # Axiomatic discovery protocol
   axio-disc       35100/udp               # Axiomatic discovery protocol
   ```

9. Leggere/aggiungere la riga successiva di input nel "pattern space"(`n` e `N`)

   - Visualizza la riga successiva alla riga trovata

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

   !!! tip "Suggerimento"

   ```
    Più comandi `sed` potrebbero influenzarsi a vicenda, per ridurre questa eventualità utilizzare "**{ }**".
   ```

   - Visualizzare righe di testo pari

     Prima, legge la prima riga, essendo presente un comando `n`, la seconda riga sarà visualizzata, e così via.

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

   - Visualizza righe di testo dispari

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

   - Visualizza le righe multiple di 3

     ```bash
     Shell > cat -n /root/test.txt | sed -n '{n;n;p}'
     # or
     Shell > cat -n /root/test.txt | sed -n '3~3p'
     3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     6  axio-disc       35100/udp               # Axiomatic discovery protocol
     9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     ```

   - `N`

     Legge la prima riga e aggiungi una riga dopo aver incontrato il comando `N`. In questo esempio, il "pattern space" è "1\n2". Infine, esegue il comando `q` per uscire.

     ```bash
     Shell > seq 1 10 | sed 'N;q'
     1
     2
     ```

     Poiché non è presente alcuna riga dopo la riga 9, il risultato sarà il seguente:

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

     Quando l'ultima riga viene letta, il comando `N` non viene eseguito e il risultato è il seguente:

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

     Unire due righe in una. Sostituisce "\n" del "pattern space" con un carattere vuoto.

     ```bash
     Shell > seq 1 6 | sed 'N;{s/\n//g}'
     12
     34
     56
     ```

10. Ignorare un caso (`I`)

    Sembra non esser presente alcuna informazione in merito all'ignorare casi in `man 1 sed`.

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

11. Calcola il numero totale di righe in un file

    ```bash
    Shell > cat /etc/services | sed -n '$='
    # or
    Shell > cat /etc/services | wc -l

    11473
    ```
