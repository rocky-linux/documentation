---
title: firewalld da iptables
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, qyecst, Ganna Zhyrnova
update: 22-Jun-2023
tags:
  - security
  - firewalld
---

# Guida da `iptables` a `firewalld` - Introduzione

Quando è stato introdotto `firewalld` come firewall predefinito (l'introduzione è avvenuta nel 2011, ma credo che sia apparso per primo in CentOS 7), l'autore ha continuato a usare `iptables`. C'erano due ragioni per questo. In primo luogo, la documentazione disponibile all'epoca per `firewalld` utilizzava regole semplicistiche e non mostrava come `firewalld` proteggesse il server *fino al livello IP*. In secondo luogo, l'autore aveva più di dieci anni di esperienza con `iptables` ed era più facile continuare ad usare quello invece di imparare `firewalld`.

Questo documento si propone di affrontare le limitazioni della maggior parte dei riferimenti a `firewalld` e di costringere l'autore a usare `firewalld` per replicare le regole più granulari del firewall.

Dalla pagina del manuale: "`firewalld` fornisce un firewall gestito dinamicamente con il supporto di zone di rete/firewall per definire il livello di fiducia delle connessioni o delle interfacce di rete. Supporta le impostazioni dei firewall IPv4 e IPv6, i bridge Ethernet e una separazione delle opzioni di configurazione runtime e permanente. Supporta anche un'interfaccia per i servizi o le applicazioni per aggiungere direttamente le regole del firewall."

`firewalld` è in realtà un front-end per i sottosistemi netfilter e nftables del kernel di Rocky Linux.

Questa guida si concentra sull'applicazione delle regole di un firewall `iptables` a un firewall `firewalld`. Se siete davvero all'inizio del vostro viaggio nel firewall, [questo documento](firewalld-beginners.md) potrebbe aiutarvi di più. Considerate la lettura di entrambi i documenti per ottenere il massimo da `firewalld`.

## Prerequisiti e presupposti

- In questo documento si presuppone che l'utente sia l'utente root o che abbia privilegi elevati con `sudo`.
- Una conoscenza di base delle regole del firewall, in particolare di `iptables` o, come minimo, una conoscenza di `firewalld`.
- Ti senti a tuo agio nell'inserire i comandi dalla riga di comando.
- Tutti gli esempi qui riportati riguardano gli IP IPv4.

## Zone

Per capire bene `firewalld`, è necessario comprendere l'uso delle zone. Le zone forniscono la granularità dei set di regole del firewall.

`firewalld` ha diverse zone integrate:

| zona     | esempio di utilizzo                                                                                                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| drop     | lascia cadere le connessioni in entrata senza risposta - consente solo i pacchetti in uscita.                                                                                                        |
| block    | rifiuta le connessioni in entrata con un messaggio icmp-host-prohibited per IPv4 e icmp6-adm-prohibited per IPv6 - sono possibili solo le connessioni di rete avviate all'interno di questo sistema. |
| public   | per l'uso in aree pubbliche - accetta solo connessioni in entrata selezionate.                                                                                                                       |
| external | accetta solo le connessioni in entrata selezionate per l'uso su reti esterne con masquerading abilitato.                                                                                             |
| dmz      | solo le connessioni in entrata selezionate sono accettate per i computer accessibili al pubblico nella zona demilitarizzata con accesso limitato alla rete interna.                                  |
| work     | per i computer nelle aree di lavoro - accetta solo le connessioni in entrata selezionate.                                                                                                            |
| home     | per l'utilizzo in aree domestiche - accetta solo connessioni in ingresso selezionate                                                                                                                 |
| internal | per l'accesso ai dispositivi della rete interna - accetta solo connessioni in entrata selezionate.                                                                                                   |
| trusted  | accetta tutte le connessioni di rete.                                                                                                                                                                |

!!! Note "Nota"

    `firewall-cmd` è il programma a riga di comando per gestire il demone `firewalld`.

Per elencare le zone esistenti nel sistema, digitare:

`firewall-cmd --get-zones`

!!! Warning "Attenzione"

    Ricordarsi di controllare lo stato del firewall, se il comando `firewalld-cmd` restituisce un errore, con:
    
    il comando `firewall-cmd`:

    ```
    $ firewall-cmd --state
    running
    ```


    il comando `systemctl`:

    ```
    $ systemctl status firewalld
    ```

All'autore non piace la maggior parte di questi nomi di zona. drop, block, public e trusted sono perfettamente chiari, ma alcuni non sono sufficienti per una sicurezza granulare perfetta. Prendiamo come esempio questa sezione di regole `iptables`:

`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

Qui si consente l'accesso al server a un singolo indirizzo IP per SSH (porta 22). Se si decide di utilizzare le zone integrate, si può usare "trusted". In primo luogo, si aggiunge l'IP alla zona e in secondo luogo si applica la regola alla zona:

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service=ssh --permanent
```

Ma cosa succede se, su questo server, avete anche una intranet accessibile solo ai blocchi IP assegnati alla vostra organizzazione? Applichereste ora la zona "internal" a questa regola? L'autore preferisce creare una zona che si occupi degli IP degli utenti admin (quelli autorizzati ad accedere al server tramite secure-shell).

### Aggiungere zone

Per aggiungere una zona, è necessario utilizzare il comando `firewall-cmd` con il parametro `--new-zone`. Si aggiungerà "admin" (per amministrativo) come zona:

`firewall-cmd --new-zone=admin --permanent`

!!! Note "Nota"

    L'autore usa spesso la flag "--permanent" in tutto il testo. Per i test, si raccomanda di aggiungere la regola senza la flag `--permanent`, testarla, e se funziona come ci si aspetta, allora usare il `firewall-cmd --runtime-to-permanent` per spostare la regola live prima di eseguire il `firewall-cmd --reload`. Se il rischio è basso (in altre parole, non ci si chiude fuori), si può aggiungere la flag `--permanent` come fatto qui.

Prima di utilizzare questa zona, è necessario ricaricare il firewall:

`firewall-cmd --reload`

!!! tip "Suggerimento"

    Una nota sulle zone personalizzate: Se avete bisogno di aggiungere una zona che sia una zona attendibile, ma che contenga solo un particolare IP o interfaccia di origine e nessun protocollo o servizio, e la zona "trusted" non vi soddisfa, probabilmente perché l'avete già usata per qualcos'altro, ecc.  A tale scopo è possibile aggiungere una zona personalizzata, ma è necessario cambiare l'obiettivo della zona da "default" ad "ACCEPT" (si possono usare anche REJECT o DROP, a seconda degli obiettivi). Ecco un esempio che utilizza un'interfaccia bridge (in questo caso lxdbr0) su una macchina LXD.
    
    Per prima cosa, si aggiunge la zona e la si ricarica per poterla utilizzare:

    ```
    firewall-cmd --new-zone=bridge --permanent
    firewall-cmd --reload
    ```


    Successivamente, si cambia l'obiettivo della zona da "default" ad "ACCEPT" (**notare che l'opzione "--permanent" è necessaria per cambiare un obiettivo**), quindi si assegna l'interfaccia e si ricarica:

    ```
    firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
    firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
    firewall-cmd --reload
    ```


    Questo dice al firewall che voi:

    1. state cambiando l'obiettivo della zona in ACCEPT
    2. state aggiungendo l'interfaccia bridge "lxdbr0" alla zona
    3. ricaricate il firewall

    Tutto ciò significa che si accetta tutto il traffico dall'interfaccia del bridge.

### Elencazione delle Zone

Prima di proseguire, è necessario esaminare il processo di elencazione delle zone. Si ottiene una singola colonna di produzione piuttosto che un output tabellare fornito da `iptables -L`. Elencare una zona con il comando `firewall-cmd --zone=[zone_name] --list-all`. Ecco come appare quando si elenca la zona "admin" appena creata:

`firewall-cmd --zone=admin --list-all`

```bash
admin
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Puoi elencare le zone attive sul tuo sistema usando questo comando:

`firewall-cmd --get-active-zones`

!!! Nota "Importante: Zone Attive"

    Una zona può *solo* essere in uno stato attivo se ha una di queste due condizioni:

    1. La zona è assegnata a un'interfaccia di rete.
    2. Alla zona vengono assegnati IP sorgente o intervalli di rete.

### Rimozione di un IP e di un servizio da una zona

Se si è seguita l'istruzione precedente per aggiungere un IP alla zona "trusted", è necessario rimuoverlo ora. Ricordate la nostra nota sull'uso del flag `--permanent`? Questo è un buon posto per evitare di usarla mentre si fanno dei test adeguati prima di portare live questa regola:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122`

Si vuole anche rimuovere il servizio SSH dalla zona:

`firewall-cmd --zone=trusted --remove-service ssh`

Quindi prova. Prima di eseguire gli ultimi due passaggi, ci si deve assicurare di avere un accesso via `ssh` da un'altra zona. (Vedere l'**avvertimento** qui sotto!). Se non sono state apportate altre modifiche, la zona "public" continuerà ad avere SSH abilitato, in quanto è presente per impostazione predefinita.

Una volta che siete soddisfatti, spostate le regole di runtime su permanente:

`firewall-cmd --runtime-to-permanent`

e ricaricare:

`firewall-cmd --reload`

!!! Warning "Attenzione"

    Aspettate a dare l'ultima istruzione se state lavorando su un server remoto o su un VPS! *NON rimuovere MAI il servizio `ssh` da un server remoto* a meno che tu non abbia un altro modo per accedere alla shell (vedi sotto).
    
     Supponiamo che ci si blocchi dall'accesso a ssh tramite il firewall. In questo caso, sarà necessario (nel peggiore dei casi) riparare il server di persona, contattare l'assistenza o eventualmente reinstallare il sistema operativo dal pannello di controllo (a seconda che il server sia fisico o virtuale).

### Utilizzo di una nuova zona - Aggiunta di IP amministrativi

Ora basta ripetere i nostri passi originali usando la zona "admin":

```bash
firewall-cmd --zone=admin --add-source=192.168.1.122
firewall-cmd --zone admin --add-service=ssh
```

Elencare la zona per verificare che sia corretta e che il servizio sia stato aggiunto correttamente:

`firewall-cmd --zone=admin --list-all`

Testate la regola per assicurarvi che funzioni. Per verificare:

1. SSH come root, o come utente in grado di eseguire sudo, dall'IP di origine (sopra è 192.168.1.122) (*utilizzare l'utente root perché si eseguiranno comandi sull'host che lo richiedono. Se si utilizza l'utente sudo, ricordarsi di inserire `sudo -s` una volta connessi*)
2. Una volta connessi, eseguire `tail /var/log/secure` e si otterrà un risultato simile a questo:

```bash
Feb 14 22:02:34 serverhostname sshd[9805]: Accepted password for root from 192.168.1.122 port 42854 ssh2
Feb 14 22:02:34 serverhostname sshd[9805]: pam_unix(sshd:session): session opened for user root by (uid=0)
```

Questo mostra che l'IP di origine per la nostra connessione SSH è lo stesso IP appena aggiunto alla zona "admin". Sarà sicuro spostare questa regola in modalità permanente:

`firewall-cmd --runtime-to-permanent`

Una volta terminata l'aggiunta delle regole, ricaricare:

`firewall-cmd --reload`

Potreste aver bisogno di altri servizi da aggiungere alla zona "admin", ma SSH è il più logico per ora.

!!! Warning "Attenzione"

    Per default la zona "public" ha il servizio `ssh` abilitato; questo può essere un problema di sicurezza. Una volta che hai creato la tua zona amministrativa, assegnata a `ssh`, e testata, puoi rimuovere il servizio dalla zona pubblica.

Se si ha più di un IP amministrativo da aggiungere (è molto probabile), basta aggiungerlo alle sorgenti della zona. In questo caso, si aggiunge un IP alla zona "admin":

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

!!! Note "Nota"

    Tenete presente che se state lavorando su un server o un VPS remoto e avete una connessione a Internet che non utilizza sempre lo stesso IP, potreste voler aprire il vostro servizio `ssh` a una serie di indirizzi IP utilizzati dal vostro provider di servizi Internet o dalla vostra regione geografica. Questo, ancora una volta, per evitare di essere bloccati dal proprio firewall.
    
    Molti ISP fanno pagare un extra per gli indirizzi IP dedicati, se vengono offerti, quindi è un problema reale.
    
    Gli esempi qui presuppongono che stiate usando degli IP sulla vostra rete privata per accedere a un server che è anche locale.

## Regole ICMP

Esaminate un'altra riga del nostro firewall `iptables` che volete emulare in `firewalld` - la regola ICMP:

`iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

Per i neofiti, ICMP è un protocollo di trasferimento dati progettato per la segnalazione di errori. Segnala i problemi di connessione a una macchina.

In realtà, probabilmente si lascerà ICMP aperto a tutti gli IP locali (in questo caso 192.168.1.0/24). Le nostre zone "public" e "admin" avranno ICMP attivo per impostazione predefinita, quindi la prima cosa da fare per limitare ICMP a quell'unico indirizzo di rete è bloccare queste richieste su "public" e "admin" .

Anche in questo caso, si tratta di una dimostrazione. Gli utenti amministrativi dovranno sicuramente disporre di ICMP verso i server e probabilmente lo avranno ancora, perché sono membri dell'IP della rete LAN.

Per disattivare ICMP sulla zona "pubblica":

`firewall-cmd --zone=public --add-icmp-block={echo-request,echo-reply} --permanent`

Fare la stessa cosa con la nostra zona "trusted ":

`firewall-cmd --zone=trusted --add-icmp-block={echo-request,echo-reply} --permanent`

Ecco un'introduzione a qualcosa di nuovo: le parentesi graffe "{}" consentono di specificare più di un parametro. Come sempre, dopo aver apportato modifiche di questo tipo, è necessario ricaricare:

`firewall-cmd --reload`

Fare dei test usando il ping da un IP non autorizzato vi darà:

```bash
ping 192.168.1.104
PING 192.168.1.104 (192.168.1.104) 56(84) bytes of data.
From 192.168.1.104 icmp_seq=1 Packet filtered
From 192.168.1.104 icmp_seq=2 Packet filtered
From 192.168.1.104 icmp_seq=3 Packet filtered
```

## Porte del server web

Ecco lo script `iptables` per permettere l'accesso pubblico a `http` e `https`, i protocolli necessari per servire le pagine web:

```bash
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

Ed ecco l'equivalente `firewalld` che probabilmente avete già visto molte volte:

```bash
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

Questo va bene, ma cosa succede se si esegue, ad esempio, un servizio Nextcloud su http/https e si vuole che solo la propria rete fidata vi abbia accesso? Non è insolito! Questo genere di cose accadono continuamente e consentire pubblicamente il traffico, senza considerare chi ha effettivamente bisogno di accedervi, è un enorme rischio per la sicurezza.

Non è possibile utilizzare le informazioni della zona "trusted" che sono state utilizzate in precedenza. Quello era per i test. Si deve presumere che almeno il blocco IP della nostra LAN sia stato aggiunto a "trusted". L'aspetto è il seguente:

`firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent`

Aggiungere i servizi alla zona:

`firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent`

Se questi servizi sono stati aggiunti alla zona "public", è necessario rimuoverli:

`firewall-cmd --zone=public --remove-service=http --remove-service=https --permanent`

Ricaricare:

`firewall-cmd --reload`

## Porte FTP

Torniamo al nostro script `iptables`. Le seguenti regole riguardano l'FTP:

```bash
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
```

Questa parte dello script tratta le porte FTP standard (20 e 21) e alcune porte passive aggiuntive. I server FTP come [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md) hanno spesso bisogno di questo tipo di regole. In genere, questo tipo di regola si trova su un server web pubblico e serve a consentire le connessioni ftp dei clienti.

Non esiste un servizio ftp-data (porta 20) con `firewalld`. Le porte da 7000 a 7500 elencate qui sono per le connessioni FTP passive e, ancora una volta, non esistono come servizio in `firewalld`. Si potrebbe passare a SFTP, che semplifica le regole di autorizzazione delle porte ed è probabilmente il metodo consigliato.

Questo dimostra la conversione di un insieme di regole di `iptables` in `firewalld`. Per ovviare a tutti questi problemi, è possibile procedere come segue.

Per prima cosa, aggiungete il servizio ftp alla zona che ospita anche i servizi web. Questo sarà probabilmente "public" in questo esempio:

`firewall-cmd --zone=public --add-service=ftp --permanent`

Aggiungere la porta ftp-data:

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

Aggiungere le porte di connessione passive:

`firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent`

Quindi ricaricare:

`firewall-cmd --reload`

## Porte del database

Se avete a che fare con un server web, avete quasi certamente a che fare con un database. L'accesso a questo database deve essere gestito con la stessa attenzione che si riserva agli altri servizi. Se l'accesso non è necessario al mondo, applicate la vostra regola a qualcosa di diverso da "public".  L'altra considerazione è: è necessario offrire l'accesso a tutti? Di nuovo, questo probabilmente dipende dal vostro ambiente. Dove l'autore lavorava in precedenza, era in uso un server web ospitato per i nostri clienti. Molti avevano siti Wordpress, e nessuno di loro aveva davvero bisogno o richiesto l'accesso a qualsiasi front-end per `MariaDB`. Se un cliente aveva bisogno di un accesso maggiore, la nostra soluzione consisteva nel creare un container LXD per il suo server web, costruire un firewall nel modo desiderato dal cliente e affidargli la responsabilità di ciò che accadeva su quel server. Tuttavia, se il server è pubblico, potrebbe essere necessario offrire l'accesso a `phpmyadmin` o a qualche altro front-end di `MariaDB`. In questo caso, è necessario preoccuparsi dei requisiti della password per il database e impostare l'utente del database su qualcosa di diverso da quello predefinito. Per l'autore, la lunghezza della password è la [considerazione primaria nella creazione delle password](https://xkcd.com/936/).

La sicurezza delle password è un argomento da trattare in un altro documento. Si presuppone che abbiate una buona politica di password per l'accesso al database e che la linea `iptables` del vostro firewall che si occupa del database abbia questo aspetto:

`iptables -A INPUT -p tcp -m tcp --dport=3600 -j ACCEPT`

 In questo caso, aggiungere il servizio alla zona "public" per una conversione `firewalld`":

`firewall-cmd --zone=public --add-service=mysql --permanent`

### Considerazioni su Postgresql

Postgresql utilizza la sua porta di servizio. Ecco un esempio di regola per le tabelle IP:

`iptables -A INPUT -p tcp -m tcp --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

Mentre è meno comune sui server web rivolti al pubblico, potrebbe essere più comune come risorsa interna. Si applicano le stesse considerazioni sulla sicurezza. Se hai un server sulla tua rete fidata (192.168.1.0/24 nel nostro esempio), potresti non voler o dover dare accesso a tutti su quella rete. Postgresql dispone di un elenco di accesso per ottenere diritti d'accesso più granulari. La nostra regola `firewalld` avrebbe un aspetto simile a questo:

`firewall-cmd --zone=trusted --add-service=postgresql`

## Porte DNS

Avere un server DNS privato o pubblico significa anche prendere precauzioni nelle regole che si scrivono per proteggere questi servizi. Se avete un server DNS privato, con regole iptables che assomigliano a questa (notate che la maggior parte dei servizi DNS sono UDP, piuttosto che TCP, ma non sempre):

`iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT`

allora permettere solo la vostra zona "trusted" sarebbe corretto. Le fonti della zona "trusted" sono già state impostate. È sufficiente aggiungere il servizio alla zona:

`firewall-cmd --zone=trusted --add-service=dns`

Con un server DNS pubblico, avrete solo bisogno di aggiungere lo stesso servizio alla zona "public":

`firewall-cmd --zone=public --add-service=dns`

## Per saperne di più sull'elencazione delle regole

!!! Note "Nota"

    Se si vuole si *può* elencare tutte le regole, elencando le regole di nftables. È un metodo brutto e non lo consiglio, ma se proprio si deve, si può fare un `nft list ruleset`.

Una cosa che non è stata fatta molto finora è l'elenco delle regole. Questa è una cosa che si può fare per zona. Ecco alcuni esempi con le zone utilizzate. Si noti che è possibile elencare la zona anche prima di spostare una regola permanente, il che è una buona idea.

`firewall-cmd --list-all --zone=trusted`

Qui è possibile vedere ciò che è stato applicato sopra:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: dns
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```

Questo vale per qualsiasi zona. Per esempio, ecco la zona "pubblica" per ora:

`firewall-cmd --list-all --zone=public`

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client ftp http https
  ports: 20/tcp 7000-7500/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```

Si noti che è stato rimosso l'accesso SSH dai servizi e bloccato ICMP "echo-reply" e "echo-request".

Nella zona "admin", per il momento, si presenta così:

`firewall-cmd --list-all --zone=admin`

```bash
  admin (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.122 192.168.1.151
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

## Regole correlate definite

Sembra che `firewalld` gestisca internamente la seguente regola di `iptables` per impostazione predefinita:

`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

## Interfacce

Per impostazione predefinita, `firewalld` ascolterà su tutte le interfacce disponibili. Su un server fisico con molte interfacce che si affacciano su diversi gateway di rete, sarà necessario assegnare un'interfaccia a una zona in base alla rete su cui si affaccia.

Le interfacce non vengono aggiunte nei nostri esempi, perché il laboratorio utilizza LXD per i test. In questo caso, è possibile lavorare solo con un'interfaccia. Supponiamo che la zona "public" debba essere configurata in modo da utilizzare la porta Ethernet enp3s0, in quanto questa porta ha l'IP pubblico, e che le zone "trusted" e "admin" si trovino sull'interfaccia LAN, che potrebbe essere enp3s1.

Per assegnare queste zone all'interfaccia corrispondente, si utilizzano i seguenti comandi:

```bash
firewall-cmd --zone=public --change-interface=enp3s0 --permanent
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent
firewall-cmd --reload
```

## Comandi comuni di firewall-cmd

Avete già utilizzato alcuni comandi. Ecco alcuni comandi più comuni e cosa fanno:

| Comando                                      | Risultato                                                                                                          |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `firewall-cmd --list-all-zones`              | simile a `firewall-cmd --list-all --zone=[zone]` eccetto che elenca *tutte* le zone e i loro contenuti.            |
| `firewall-cmd --get-default-zone`            | mostra la zona predefinita, che è "public", a meno che non venga modificata.                                       |
| `firewall-cmd --list-services --zone=[zone]` | mostra tutti i servizi abilitati per la zona.                                                                      |
| `firewall-cmd --list-ports --zone=[zone]`    | mostra tutte le porte aperte sulla zona.                                                                           |
| `firewall-cmd --get-active-zones`            | mostra le zone attive del sistema, le loro interfacce attive, i servizi e le porte.                                |
| `firewall-cmd --get-services`                | mostra tutti i servizi disponibili possibili per l'uso.                                                            |
| `firewall-cmd --runtime-to-permanent`        | se sono state inserite molte regole senza l'opzione `--permanent`, eseguire questa operazione prima di ricaricare. |

Molte opzioni di `firewall-cmd` non sono trattate in questa sede, ma qui si trovano i comandi più utilizzati.

## Conclusione

Poiché `firewalld` è il firewall raccomandato e incluso in Rocky Linux, è una buona idea capire come funziona. Le regole semplicistiche, incluse nella documentazione per l'applicazione dei servizi utilizzando `firewalld`, spesso non tengono conto dell'uso del server e non offrono altre opzioni se non quella di consentire pubblicamente il servizio. Si tratta di un inconveniente legato alle falle di sicurezza che non dovrebbero essere presenti.

Quando vedete queste istruzioni, pensate all'uso del vostro server e se il servizio deve essere aperto al mondo. In caso contrario, si consiglia di applicare una maggiore granularità alle regole, come descritto in precedenza.

Questa non vuole essere una guida esaustiva a `firewalld`, ma piuttosto un punto di partenza.
