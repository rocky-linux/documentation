- - -
Title: Lab 8 - iptables author: Wale Soyinka contributors:
- - -


# Lab 8: `iptables`

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- configurare le regole di base del filtro IP
- configurare il forwarding IP

Tempo stimato per completare questo laboratorio: 60 minuti

> Uso sempre iptables sui miei sistemi Linux. Anche se non volete tenere lontani gli hacker, potete bloccare i siti pubblicitari come* doubleclick.com e altri siti malvagi. O forse volete semplicemente fare un po' di logging in più? ... Iptables è la regola!

-- George W.Bush

## `iptables`

`iptables` è uno strumento utilizzato per gestire il sottosistema di filtraggio dei pacchetti IPv4 e NAT del kernel Linux. Il sottosistema è noto come netfilter.

L'utilità a riga di comando `iptables` fornisce gli strumenti front-end (user-land) per gestire questo sottosistema. Viene utilizzato per impostare, mantenere e ispezionare le tabelle delle regole di filtraggio dei pacchetti IP nel kernel. È possibile definire diverse tabelle.

Di seguito vengono descritte alcune terminologie comuni utilizzate nelle discussioni su `iptables`:

### TABELLE

Nella maggior parte dei kernel Linux sono definite tre tabelle indipendenti. Le tabelle presenti in qualsiasi momento dipendono dalle opzioni di configurazione del kernel e dai moduli presenti. Le tabelle sono:

* filter: Questa è la tabella principale e predefinita (se non viene passata l'opzione -t). Contiene le concatenazioni incorporate:

    * **INPUT** (per i pacchetti che entrano nella sistema)
    * **FORWARD** (per i pacchetti che vengono instradati attraverso il sistema)
    * **OUTPUT** (per i pacchetti generati localmente).

* nat: Questa tabella viene consultata quando si incontra un pacchetto che crea una nuova connessione. Si compone delle seguenti tre concatenazioni integrate:

    * **PREROUTING** (per modificare i pacchetti non appena arrivano)
    * **OUTPUT** (per alterare i pacchetti generati localmente prima dell'instradamento)
    * **POSTROUTING** (per modificare i pacchetti quando stanno per essere spediti)

* mangle: Questa tabella viene utilizzata per l'alterazione specializzata dei pacchetti. Dispone delle seguenti 5 concatenazioni integrate:

    * **PREROUTING** (per alterare i pacchetti in arrivo prima dell'instradamento)
    * **OUTPUT** (per alterare i pacchetti generati localmente prima dell'instradamento)
    * **INPUT** (per i pacchetti che entrano nel sistema)
    * **FORWARD** (per alterare i pacchetti che vengono instradati attraverso il sistema)
    * **POSTROUTING**  (per modificare i pacchetti quando stanno per essere spediti)


### CONCATENAZIONI

Una concatenazione è un elenco di regole che possono corrispondere a un insieme di pacchetti. Ogni regola specifica cosa fare con un pacchetto che soddisfa i requisiti. Ogni tabella contiene un certo numero di concatenazioni incorporate e può contenere anche concatenazioni definite dall'utente.

### OBIETTIVI

Una regola del firewall specifica i criteri per un pacchetto e un obiettivo.  Se il pacchetto non corrisponde, viene esaminata la regola successiva della concatenazione; se invece corrisponde, la regola successiva è specificata dal valore dell'obiettivo, che può essere il nome di una concatenazione definita dall'utente o uno dei valori speciali ACCEPT, DROP, QUEUE o RETURN.

```

Usage: iptables -[ACD] chain rule-specification [options]
       iptables -I chain [rulenum] rule-specification [options]
       iptables -R chain rulenum rule-specification [options]
       iptables -D chain rulenum [options]
       iptables -[LS] [chain [rulenum]] [options]
       iptables -[FZ] [chain] [options]
       iptables -[NX] chain
       iptables -E old-chain-name new-chain-name
       iptables -P chain target [options]
       iptables -h (print this help information)

Commands:
Either long or short options are allowed.
  --append  -A chain        Append to chain
  --check   -C chain        Check for the existence of a rule
  --delete  -D chain        Delete matching rule from chain
  --delete  -D chain rulenum
                Delete rule rulenum (1 = first) from chain
  --insert  -I chain [rulenum]
                Insert in chain as rulenum (default 1=first)
  --replace -R chain rulenum
                Replace rule rulenum (1 = first) in chain
  --list    -L [chain [rulenum]]
                List the rules in a chain or all chains
  --list-rules -S [chain [rulenum]]
                Print the rules in a chain or all chains
  --flush   -F [chain]      Delete all rules in  chain or all chains
  --zero    -Z [chain [rulenum]]
                Zero counters in chain or all chains
  --new     -N chain        Create a new user-defined chain
  --delete-chain
            -X [chain]      Delete a user-defined chain
  --policy  -P chain target
                Change policy on chain to target
  --rename-chain
            -E old-chain new-chain
                Change chain name, (moving any references)

Options:
    --ipv4  -4      Nothing (line is ignored by ip6tables-restore)
    --ipv6  -6      Error (line is ignored by iptables-restore)
[!] --protocol  -p proto    protocol: by number or name, eg. `tcp'
[!] --source    -s address[/mask][...]
                source specification
[!] --destination -d address[/mask][...]
                destination specification
[!] --in-interface -i input name[+]
                network interface name ([+] for wildcard)
 --jump -j target
                target for rule (may load target extension)
  --goto      -g chain
                   jump to chain with no return
  --match   -m match
                extended match (may load extension)
  --numeric -n      numeric output of addresses and ports
[!] --out-interface -o output name[+]
                network interface name ([+] for wildcard)
  --table   -t table    table to manipulate (default: `filter')
  --verbose -v      verbose mode
  --wait    -w [seconds]    maximum wait to acquire xtables lock before give up
  --line-numbers        print line numbers when listing
  --exact   -x      expand numbers (display exact values)
[!] --fragment  -f      match second or further fragments only
  --modprobe=<command>      try to insert modules using this command
  --set-counters -c PKTS BYTES  set the counter during insert/append
[!] --version   -V      print package version.

```

### Esercizio 1

`iptables` elementi essenziali

Questo esercizio vi insegnerà alcuni elementi essenziali di `iptables`. In particolare, si apprenderà come visualizzare o elencare le regole di `iptables`, creare regole di filtraggio di base, eliminare regole, creare/eliminare concatenazioni personalizzate e così via.

Senza ulteriori indugi, passiamo subito all'uso di `iptables`.

#### Per visualizzare le regole attuali

1. Mentre si è connessi come superutente, elencare tutte le regole nella tabella dei filtri. Digitare:

    ```
    [root@serverXY root]# iptables -L
    ```

2.  Per visualizzare un output più dettagliato, digitare:

    ```
    [root@serverXY root]# iptables -L -v
    ```

3.  Visualizzare solo le regole della concatenazione INPUT. Digitare:

    ```
    [root@serverXY root]# iptables -v  -L INPUT
    ```

4.  Visualizzare tutte le regole della tabella mangle. Digitare:

    ```
    [root@serverXY root]#  iptables  -L  -t   mangle
    ```

5.  Visualizzare tutte le regole della tabella nat. Digitare:

    ```
    [root@serverXY root]# iptables -L -t nat
    ```

#### Per eliminare tutte le regole attuali

1. Pulisce (o elimina) tutte le regole che "potrebbero" essere attualmente caricate. Digitare:

    ```
    [root@serverXY root]# iptables --flush
    ```

#### Per creare la propria concatenazione

1.  Create la vostra concatenazione personalizzata e chiamatela "mychain". Digitare:

    ```
    [root@serverXY root]# iptables  -N  mychain
    ```

2. Elencare le regole della concatenazione creata in precedenza. Digitare:

    ```
    [root@serverXY root]# iptables  -L mychain

    Chain mychain (0 references)

    target     prot opt source               destination
    ```

#### Per eliminare le concatenazioni

1. Per prima cosa, provare a eliminare la concatenazione INPUT incorporata. Digitare:

    ```
    [root@serverXY root]# iptables -X INPUT
    ```

    Qual è stato il risultato?

2. Successivamente, provare a eliminare la concatenazione creata in precedenza. Digitare:

    ```
    [root@serverXY root]# iptables -X mychain
    ```

3.  Riprovate a elencare le regole della concatenazione che avete appena eliminato.  Digitare:

    ```
    [root@serverXY root]# iptables -L  mychain
    ```

### Esercizio 2

Basi sul filtraggio dei pacchetti

Questo esercizio vi insegnerà a creare regole di filtraggio dei pacchetti leggermente più avanzate. In particolare, si bloccheranno tutti i tipi di pacchetti ICMP provenienti dal sistema partner.

#### Per filtrare i pacchetti di tipo ICMP

1. Prima di iniziare, accertatevi di poter eseguire il ping del vostro sistema partner e che anche quest'ultimo possa eseguire il ping con successo. Digitare:

    ```
    [root@serverXY root]# ping -c 2 serverPR

    <SNIP>

    --- serverPR ping statistics ---

    2 packets transmitted, 2 received, 0% packet loss, time 1005ms

    ...............................................
    ```

2.  Eliminare tutte le regole esistenti. Digitare:

    ```
    [root@serverXY root]# iptables -F
    ```

3. Creare una regola per bloccare tutti i pacchetti di tipo icmp in uscita verso qualsiasi destinazione. Digitare:

    ```
    [root@serverXY root]# iptables  -A  OUTPUT  -o  eth0 -p  icmp  -j  DROP
    ```

    In parole povere, il comando precedente può essere interpretato come: "*Applica una regola alla concatenazione OUTPUT nella tabella dei filtri. Questa regola lascerà cadere ogni pacchetto di tipo ICMP in uscita dall'interfaccia eth0*"

4. Verificate l'effetto della regola precedente provando a eseguire il ping del serverPR. Digitare:

    ```
    [root@serverXY root]# ping -c 2 serverPR

    PING serverPR (10.0.5.8) 56(84) byte di dati.

    ping: sendmsg: Operation not permitted

    ping: sendmsg: Operation not permitted
    ```

5.  Visualizzare la regola appena creata. Digitare:

    ```
    [root@serverXY root]# iptables  -vL OUTPUT

    Chain OUTPUT (policy ACCEPT 21221 packets, 2742K byte)

    pkts bytes target     prot   opt    in         out         source             destination

    93  7812 DROP     icmp    --  any         eth0    anywhere          anywhere
    ```

6. Cancellare tutte le regole e riprovare il comando ping da entrambi i sistemi. Successo o fallimento?

7. Ora create un'altra regola che elimini i pacchetti icmp provenienti da uno specifico indirizzo IP indesiderato (ad esempio 172.16.0.44). Digitare:

    ```
    [root@serverXY root]# iptables -A INPUT -i eth0 -p icmp --source 172.16.0.44 -j DROP
    ```

    Il comando di cui sopra, in parole povere, si legge come: *"Aggiungi una regola alla concatenazione INPUT nella tabella dei filtri. Questa regola lascia cadere tutti i pacchetti di tipo ICMP con indirizzo sorgente 172.16.0.44"*

8. Per verificare l'effetto di questa regola, potete chiedere a chiunque altro nel vostro laboratorio [a cui non è stato assegnato l'indirizzo IP 172.16.0.44] di provare a pingarvi. Successo o fallimento?

9. Invece di eliminare tutte le regole nella tua tabella. Eliminare solo la regola creata in precedenza. A tal fine è necessario conoscere il numero della regola. Per conoscere il numero della regola, digitare:

    ```
    [root@serverXY root]# iptables -vL  INPUT --line-numbers

    Chain INPUT (policy ACCEPT 31287 packets, 9103K bytes)

    num   pkts  bytes   target        prot opt     in     out       source               destination

    1        486   40824  DROP       icmp --    eth0   any     serverPR             anywhere

    ```

    La colonna contenente il numero della regola è stata evidenziata nell'output di esempio qui sopra.

10. Utilizzando il numero di riga che corrisponde alla regola che si desidera eliminare, è possibile eliminare la regola specifica (riga numero 1) nella catena INPUT eseguendo:

    ```
    [root@serverXY root]# iptables -D INPUT 1
    ```

#### Per filtrare altri tipi di traffico

In questo esercizio imparerai come filtrare il traffico di tipo tcp.

Il popolare protocollo ftp è un servizio basato su TCP. Ciò significa che viene trasportato su pacchetti di tipo TCP.

Nei passi successivi esamineremo l'individuazione e il filtraggio del traffico di tipo FTP proveniente da un determinato indirizzo IP.

1. Avviare il server ftp configurato e abilitato in uno dei laboratori precedenti. Digitare:

    ```
    [root@serverXY root]# *service vsftpd restart*

    Shutting down vsftpd: [  OK  ]

    Starting vsftpd for vsftpd: [  OK  ]
    ```

2. Chiedete al vostro partner di provare ad accedere come utente anonimo al vostro server ftp. Assicuratevi che il vostro partner sia in grado di accedere con successo dal serverPR: fatelo *prima* di passare alla fase successiva.

3.  Mentre il partner è ancora connesso, creare una regola per disabilitare tutto il traffico di tipo ftp proveniente dal serverPR. Digitare:

    ```
    [root@serverXY root]# iptables -A INPUT -i  eth0 -s 172.16.0.z  -p tcp  --dport 21 -j DROP*
    ```

    In parole povere, la regola/comando di cui sopra si traduce in: *Applica una regola alla concatenazione INPUT nella tabella dei filtri. Facciamo in modo che questa regola ELIMINI tutti i pacchetti con indirizzo sorgente 172.16.0.z destinati alla porta 21 del nostro sistema locale.*

4. Non appena si esegue il comando precedente, lo stack netfilter lo mette in atto immediatamente. Per verificarlo, chiedete al vostro interlocutore di provare qualsiasi comando ftp mentre è ancora connesso al vostro server ftp, ad esempio `ls`. Successo o fallimento?

    Se non riesce, chiedete al vostro interlocutore di provare a disconnettersi e di provare ad accedere di nuovo da zero. Successo o fallimento?

5. Chiedete a un'altra persona che NON sia il vostro partner di provare ad accedere al vostro server ftp in modo anonimo. Si può anche chiedere a qualcuno di hq.example.org di provare a connettersi al sito ftp. Successo o fallimento?

6.  Abilitare e avviare il server web sul serverXY.

7.  Assicuratevi che altre persone possano visitare il vostro sito web utilizzando un browser. Creare una regola per bloccare il traffico http da hq.example.org al computer locale.

### Esercizio 3

Basi sull'Inoltro del Pacchetto

In questo esercizio imparerete a impostare una regola di base per l'inoltro dei pacchetti.

La regola impostata consentirà al vostro sistema di fungere da router per il sistema partner.

Il sistema instrada tutto il traffico proveniente dal sistema del partner verso Internet o verso il proprio gateway predefinito. Si tratta del cosiddetto masquerading IP o NAT (Network address translation).

Per essere pignoli, l'IP masquerading e il NAT-ing sono in realtà entità leggermente diverse e di solito vengono utilizzate per ottenere risultati diversi. Nei prossimi esercizi non ci soffermeremo troppo sulle differenze specifiche.

Questo esercizio presuppone quanto segue, quindi si prega di apportare le dovute modifiche in base alla propria configurazione:

ServerXY

i. Il sistema ha due schede di rete: eth0 e eth1.

ii. La prima interfaccia, eth0, sarà considerata l'interfaccia esterna (o rivolta verso Internet)

iii. La seconda interfaccia eth1 sarà considerata come interfaccia interna (o rivolta verso la LAN)

iv. L'interfaccia eth0 ha un indirizzo IP di 172.16.0.z

v. L'interfaccia eth1 ha un indirizzo IP di 10.0.0.z con una maschera di rete di 255.0.0.0

vi. Di aver completato con successo il "Laboratorio 2" e di aver compreso i concetti di base in esso contenuti.


ServerPR

Si fanno le seguenti ipotesi sul sistema del partner.

i. Ha solo una scheda di NIC: eth0

ii. eth0 ha l'indirizzo IP 10.0.0.y con una maschera di rete di 255.0.0.0

iii. Il router o gateway predefinito per il serverPR è 10.0.0.z (es. l'indirizzo IP per l'eth1 del serverXY)

iv. Di aver completato con successo il "Laboratorio 2" e di aver compreso i concetti di base in esso contenuti.

Cablate la rete in modo che assomigli alla configurazione illustrata di seguito:

Le consuete icone per serverXY e serverPR sono state sostituite con le icone di un router.

#### Per creare la regola di inoltro

1.  Assicurarsi che la rete sia cablata fisicamente come illustrato sopra.

2. Assegnare a tutte le interfacce l'indirizzo IP, la netmask e il gateway appropriati.

3.  Pulire tutte le regole di iptables attualmente caricate.

    !!! note "Nota"
   
        Eliminare le tabelle non è sempre essenziale od obbligatorio. Avrete notato che all'inizio di alcuni degli esercizi svolti finora, abbiamo specificato che è necessario pulire le tabelle esistenti. Questo per garantire che si parta da zero e che non ci siano regole errate nascoste da qualche parte nelle tabelle che potrebbero non funzionare correttamente. Normalmente si possono caricare centinaia di regole contemporaneamente, con funzioni diverse.

4.  Chiedete al vostro partner del serverPR di provare a pingare 172.16.0.100 (hq.example.org); l'operazione dovrebbe fallire perché ora siete il gateway predefinito del serverPR e *non avete* ancora abilitato il routing sul vostro sistema.

5.  Come root sul serverXY digitare:

    ```
    [root@serverXY root]# *iptables --table  nat  -A  POSTROUTING -o eth0  -j  MASQUERADE*
    ```

6.  Ripetere ora il passaggio 4. Successo o fallimento?

7.  Quanto sopra dovrebbe essere fallito. Occorre anche abilitare l'inoltro dei pacchetti nel kernel in esecuzione. Digitare:

    ```
    [root@serverXY root]#  *echo 1   >   /proc/sys/net/ipv4/ip_forward*
    ```

8.  Per rendere permanente la modifica al kernel tra un riavvio e l'altro, creare la voce seguente nel file "/etc/sysctl.conf":

    ```
    net.ipv4.ip_forward = 0
    ```

#### Per salvare le regole di `iptables`

Finora, tutte le regole e le concatenazioni `iptables` create sono state effimere o non permanenti. Ciò significa che se si dovesse riavviare il sistema in qualsiasi momento, tutte le regole e le modifiche apportate andrebbero perse.

Per evitare ciò, è necessario un meccanismo per scrivere o salvare le regole temporanee di run-time `iptables` nel sistema, in modo che siano sempre disponibili al riavvio del sistema.

1. Usate il comando `iptables-save` per salvare tutte le modifiche al file /etc/sysconfig/iptables. Digitare:

    ```
    [root@serverXY root]# *iptables-save   >   /etc/sysconfig/iptables*
    ```


    !!! tip "Suggerimento"

     Le cose che si possono fare con `iptables` sono limitate solo dalla propria immaginazione. In questo laboratorio abbiamo appena scalfito la superficie. Speriamo di aver scalfito abbastanza la superficie per permettervi di dare sfogo alla vostra immaginazione.

# Punti Aggiuntivi

1. Quale opzione è necessaria per ottenere una versione più dettagliata di questo comando? *iptables -L  -t   nat* ?

2. Qual è il comando per visualizzare le regole della concatenazione OUTPUT?

3. Su quale porta è in "normalmente" in ascolto il servizio ftp?

4. Qual è il comando per creare una concatenazione chiamata "mynat-chain" nella tabella nat?

5. Fate una ricerca online ed elencate i nomi di alcuni strumenti o applicazioni di facile utilizzo che possono essere usati per gestire il sottosistema firewall sui sistemi basati su Linux.

6a. Creare una regola `iptables` per bloccare il traffico http da hq.example.org alla macchina locale.

6b. Qual è la nota porta di ascolto dei server web?

6c. Scrivete il comando completo per raggiungere questo obiettivo?

6d. Convertire o tradurre il comando che hai scritto qui sopra nel suo equivalente in parole povere?
