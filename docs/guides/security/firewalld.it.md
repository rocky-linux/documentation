---
title: firewalld da iptables
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, qyecst, Franco Colussi
update: 22-Jun-2023
tags:
  - security
  - firewalld
---

# Guida da `iptables` a `firewalld` - Introduzione

Da quando `firewalld` è uscito come firewall di default (credo sia stato con CentOS 7, anche se è stato introdotto nel 2011), ho fatto la mia missione di vita di tornare a tutti i costi a `iptables`. C'erano due ragioni per questo. In primo luogo, la documentazione che era disponibile all'epoca usava regole semplicistiche che non mostravano adeguatamente come il server fosse protetto *fino al livello dell'IP*. Secondo, e probabilmente la ragione principale: avevo una lunga storia con `iptables` che andava indietro di molti anni, ed era francamente più facile continuare a usare `iptables`. Ogni server che ho distribuito, che fosse pubblico o interno, usava un set di regole del firewall `iptables`. È stato facile adattare semplicemente un set di regole predefinite per il server con cui avevamo a che fare e distribuire. Per fare questo su CentOS 7, CentOS 8, e ora Rocky Linux 8, ho dovuto usare [questa procedura](enabling_iptables_firewall.md).

Allora perché sto scrivendo questo documento? In primo luogo, per affrontare le limitazioni della maggior parte dei riferimenti di `firewalld` e, in secondo luogo, per costringermi a trovare modi per usare `firewalld` per imitare quelle regole del firewall più granulari.

E, naturalmente, per aiutare i principianti a gestire il firewall di default di Rocky Linux.

Dalla pagina del manuale:`"firewalld` fornisce un firewall gestito dinamicamente con supporto per zone di rete/firewall per definire il livello di fiducia delle connessioni o delle interfacce di rete. Ha il supporto per le impostazioni firewall IPv4, IPv6 e per i bridge Ethernet e ha una separazione delle opzioni di configurazione runtime e permanente. Supporta anche un'interfaccia per i servizi o le applicazioni per aggiungere direttamente le regole del firewall"

Curiosità: `firewalld` in Rocky Linux è in realtà un front end per i sottosistemi del kernel netfilter e nftables.

Questa guida si concentra sull'applicazione di regole da un firewall `iptables` a un firewall `firewalld`. Se sei davvero all'inizio del tuo viaggio nel firewall, [questo documento](firewalld-beginners.md) potrebbe aiutarti di più. Considerate di leggere entrambi i documenti per ottenere il massimo da `firewalld`.

## Prerequisiti e presupposti

* In questo documento si presuppone che siate l'utente root o che abbiate usato `sudo` per diventarlo.
* Una conoscenza di base delle regole del firewall, in particolare di `iptables` o, come minimo, il desiderio di imparare qualcosa su `firewalld`.
* Ti senti a tuo agio nell'inserire i comandi dalla riga di comando.
* Tutti gli esempi qui riportati riguardano gli IP IPv4.

## Zone

Per capire veramente `firewalld`, è necessario comprendere l'uso delle zone. Le zone sono dove viene applicata la granularità dei set di regole del firewall.

`firewalld` ha diverse zone integrate:

| zona     | esempio di utilizzo                                                                                                                                                                                            |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| drop     | abbandona le connessioni in entrata senza risposta - sono consentiti solo i pacchetti in uscita.                                                                                                               |
| block    | le connessioni in entrata vengono rifiutate con un messaggio icmp-host-prohibited per IPv4 e icmp6-adm-prohibited per IPv6 - sono possibili solo le connessioni di rete avviate all'interno di questo sistema. |
| public   | per l'uso in aree pubbliche - sono accettate solo connessioni in entrata selezionate.                                                                                                                          |
| external | per l'uso in aree pubbliche - sono accettate solo connessioni in entrata selezionate.                                                                                                                          |
| dmz      | per i computer della zona demilitarizzata accessibili al pubblico con accesso limitato alla rete interna: vengono accettate solo le connessioni in entrata selezionate.                                        |
| work     | per i computer nelle aree di lavoro (no, non capisco nemmeno questo): vengono accettate solo le connessioni in entrata selezionate.                                                                            |
| home     | per l'uso in aree domestiche (no, non capisco nemmeno questo) - vengono accettate solo le connessioni in entrata selezionate.                                                                                  |
| internal | per l'accesso al dispositivo di rete interno - vengono accettate solo le connessioni in entrata selezionate.                                                                                                   |
| trusted  | tutte le connessioni di rete sono accettate.                                                                                                                                                                   |

!!! Note "Nota"

    `firewall-cmd` è il programma a riga di comando per gestire il demone `firewalld`.

Per elencare le zone esistenti sul vostro sistema, digitate:

`firewall-cmd --get-zones` !!! Warning "Attenzione"

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

Ad essere onesti, odio soprattutto i nomi di queste zone. drop, block, public e trusted sono perfettamente chiari, ma alcuni non sono abbastanza efficaci per una perfetta sicurezza granulare. Prendiamo questa sezione di regole `iptables` come esempio:

`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

Qui abbiamo un singolo indirizzo IP al quale viene permesso il SSH (porta 22) nel server. Se decidiamo di usare le zone integrate, potremmo usare "trusted" per questo. In primo luogo, aggiungiamo l'IP alla zona e in secondo luogo, applichiamo la regola alla zona:

```
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service=ssh --permanent
```

Ma cosa succede se su questo server abbiamo anche una intranet che è accessibile solo ai blocchi IP assegnati alla nostra organizzazione?  Useremmo ora la zona "internal" per applicarla a questa regola? Francamente, preferirei creare una zona che si occupi degli IP degli utenti admin (quelli autorizzati a fare secure-shell nel server). A dire il vero, preferirei aggiungere tutte le mie zone, ma questo potrebbe essere ridicolo da fare.

### Aggiungere zone

Per aggiungere una zona, dobbiamo usare il `firewall-cmd` con il parametro `--new-zone`. Aggiungeremo "admin" (per amministrativo) come zona:

`firewall-cmd --new-zone=admin --permanent`

!!! Note "Nota"

    Abbiamo usato molto la flag `--permanent` in tutto il tempo. Per i test, si raccomanda di aggiungere la regola senza la flag `--permanent`, testarla, e se funziona come ci si aspetta, allora usare il `firewall-cmd --runtime-to-permanent` per spostare la regola live prima di eseguire il `firewall-cmd --reload`. Se il rischio è basso (in altre parole, non vi chiuderete fuori), potete aggiungere il flag `--permanent` come ho fatto qui.

Prima che questa zona possa essere effettivamente utilizzata, dobbiamo ricaricare il firewall:

`firewall-cmd --reload`

!!! tip "Suggerimento"

    Una nota sulle zone personalizzate: Se avete bisogno di aggiungere una zona che sarà una zona fidata, ma conterrà solo un particolare IP sorgente o interfaccia e nessun protocollo o servizio, e la zona "fidata" non funziona per voi, probabilmente perché l'avete già usata per qualcos'altro, ecc.  Potete aggiungere una zona personalizzata per fare questo, ma dovete cambiare l'obiettivo della zona da "default" ad "ACCEPT" (si può anche usare REJECT o DROP, a seconda dei vostri obiettivi). Ecco un esempio che usa un'interfaccia bridge (lxdbr0 in questo caso) su una macchina LXD.
    
    Per prima cosa, aggiungiamo la zona e la ricarichiamo per poterla utilizzare:

    ```
    firewall-cmd --new-zone=bridge --permanent
    firewall-cmd --reload
    ```


    Poi, cambiamo il target della zona da "default" a "ACCEPT" (**notare che l'opzione "--permanent" è richiesta per cambiare un target**) poi assegniamo l'interfaccia e ricarichiamo:

    ```
    firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
    firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
    firewall-cmd --reload
    ```


    Questo dice al firewall che voi:

    1. state cambiando l'obiettivo della zona in ACCEPT
    2. state aggiungendo l'interfaccia bridge "lxdbr0" alla zona
    3. ricaricate il firewall

    Tutto questo dice che state accettando tutto il traffico dall'interfaccia di bridge.

### Elencazione delle Zone

Prima di andare avanti, dobbiamo dare un'occhiata al processo di elencazione delle zone. Piuttosto che un output tabellare fornito da `iptables -L`, si ottiene una singola colonna di output con intestazioni. L'elenco di una zona è fatto con il comando `firewall-cmd --zone=[nome_zona] --list-all.`. Ecco come appare quando elenchiamo la zona "admin" appena creata:

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

### Rimozione di un IP e di un Servizio da una Zona

Se avete effettivamente seguito le istruzioni precedenti aggiungendo l'IP alla zona "trusted", ora dobbiamo rimuoverlo da quella zona. Ricordate la nostra nota sull'uso del flag `--permanent`? Questo è un buon posto per evitare di usarla mentre si fanno dei test adeguati prima di portare live questa regola:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122`

Vogliamo anche rimuovere il servizio ssh dalla zona:

`firewall-cmd --zone=trusted --remove-service ssh`

Quindi prova. Vorrete assicurarvi di avere un modo per entrare via `ssh` da un'altra zona prima di fare gli ultimi due passi. (Vedere l'**avvertimento** qui sotto!). Se non avete fatto altri cambiamenti, allora la zona "public" avrà ancora il permesso per ssh, poiché è lì per default.

Una volta che siete soddisfatti, spostate le regole di runtime su permanente:

`firewall-cmd --runtime-to-permanent`

e ricaricare:

`firewall-cmd --reload`

!!! Warning "Attenzione"

    Se stai lavorando su un server remoto o su un VPS, rimanda l'ultima istruzione! *NON rimuovere MAI il servizio `ssh` da un server remoto* a meno che tu non abbia un altro modo per accedere alla shell (vedi sotto).
    
    Se ti chiudi fuori dall'accesso `ssh` tramite il firewall, dovrai (nel peggiore dei casi) andare a riparare il tuo server di persona, contattare il supporto, o eventualmente reinstallare il sistema operativo dal tuo pannello di controllo (a seconda che il server sia fisico o virtuale).

### Utilizzo di una Nuova Zona - Aggiunta di IP Amministrativi

Ora basta ripetere i nostri passi originali usando la zona "admin":

```
firewall-cmd --zone=admin --add-source=192.168.1.122
firewall-cmd --zone admin --add-service=ssh
```

Ora elenca la zona per assicurarti che la zona risulti corretta e che il servizio sia stato aggiunto correttamente:

`firewall-cmd --zone=admin --list-all`

Testate la vostra regola per assicurarvi che funzioni. Per testare:

1. SSH come root, o come utente in grado di eseguire sudo, dall'IP di origine (sopra è 192.168.1.122) (*l'utente root è usato qui perché stiamo per eseguire comandi sull'host che lo richiedono. Se si utilizza l'utente sudo, ricordarsi di inserire `sudo -s` una volta connessi*)
2. Una volta connessi, eseguite `tail /var/log/secure` e dovreste ottenere un output simile a questo:

```bash
Feb 14 22:02:34 serverhostname sshd[9805]: Accepted password for root from 192.168.1.122 port 42854 ssh2
Feb 14 22:02:34 serverhostname sshd[9805]: pam_unix(sshd:session): session opened for user root by (uid=0)
```
Questo mostra che l'IP sorgente per la nostra connessione SSH era effettivamente lo stesso IP che abbiamo appena aggiunto alla zona "admin". Quindi dovremmo essere al sicuro nello spostare questa regola in modo permanente:

`firewall-cmd --runtime-to-permanent`

Quando hai finito di aggiungere regole, non dimenticarti di ricaricare:

`firewall-cmd --reload`

Ci sono ovviamente altri servizi che potrebbero aver bisogno di essere aggiunti alla zona "admin", ma ssh è il più logico per ora.

!!! Warning "Attenzione"

    Per default la zona "public" ha il servizio `ssh` abilitato; questo può essere un problema di sicurezza. Una volta che hai creato la tua zona amministrativa, assegnata a `ssh`, e testata, puoi rimuovere il servizio dalla zona pubblica.

Se avete più di un IP amministrativo da aggiungere (molto probabile), allora aggiungetelo semplicemente alle fonti della zona. In questo caso, stiamo aggiungendo un IP alla zona "admin":

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

!!! Note "Nota"

    Tenete a mente che se state lavorando su un server remoto o VPS, e avete una connessione internet che non usa sempre lo stesso IP, potreste voler aprire il vostro servizio `ssh` a una gamma di indirizzi IP usati dal vostro provider di servizi internet o regione geografica. Questo, di nuovo, è per non essere bloccati dal proprio firewall.
    
    Molti ISP fanno pagare un extra per gli indirizzi IP dedicati, se vengono offerti, quindi è una vera preoccupazione.
    
    Gli esempi qui presuppongono che stiate usando degli IP sulla vostra rete privata per accedere a un server che è anche locale.

## Regole ICMP

Guardiamo un'altra linea nel nostro firewall `iptables` che vogliamo emulare in `firewalld` - La nostra regola ICMP:

`iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

Per i neofiti, ICMP è un protocollo di trasferimento dati progettato per la segnalazione di errori. Fondamentalmente, ti dice quando c'è stato un qualsiasi tipo di problema di connessione a una macchina.

In realtà, lasceremmo probabilmente ICMP aperto a tutti i nostri IP locali (in questo caso 192.168.1.0/24). Tenete a mente, però, che le nostre zone "public" e "admin" avranno l'ICMP attivo per impostazione predefinita, quindi la prima cosa da fare per limitare l'ICMP a quell'unico indirizzo di rete è bloccare queste richieste su "public" e "admin".

Di nuovo, questo è a scopo dimostrativo. Vorrete sicuramente che i vostri utenti amministrativi abbiano ICMP per i vostri server, e probabilmente lo avranno ancora, poiché sono membri della rete LAN IP.

Per disattivare l'ICMP sulla zona "public", dovremmo:

`firewall-cmd --zone=public --add-icmp-block={echo-request,echo-reply} --permanent`

E poi fare la stessa cosa sulla nostra zona "trusted":

`firewall-cmd --zone=trusted --add-icmp-block={echo-request,echo-reply} --permanent`

Abbiamo introdotto qualcosa di nuovo qui: Le parentesi graffe "{}" ci permettono di specificare più di un parametro.  Come sempre, dopo aver fatto modifiche come questa, dobbiamo ricaricare:

`firewall-cmd --reload`

Fare dei test usando il ping da un IP non autorizzato vi darà:

```bash
ping 192.168.1.104
PING 192.168.1.104 (192.168.1.104) 56(84) bytes of data.
From 192.168.1.104 icmp_seq=1 Packet filtered
From 192.168.1.104 icmp_seq=2 Packet filtered
From 192.168.1.104 icmp_seq=3 Packet filtered
```

## Porte del Server Web

Ecco lo script `iptables` per permettere a livello pubblico `http` e `https`, i protocolli di cui avete bisogno per servire le pagine web:

```
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

Ed ecco l'equivalente di `firewalld` che probabilmente avete già visto molte volte:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

OK, tutto ciò va bene, ma cosa succede se state eseguendo, per esempio, un servizio Nextcloud su http/https e volete che solo la vostra rete fidata vi abbia accesso?  Non è insolito! Questo genere di cose succedono di continuo, e permettere solo pubblicamente il traffico, senza considerare chi ha effettivamente bisogno di accedere, è un enorme buco di sicurezza.

In realtà non possiamo usare le informazioni della zona "trusted" che abbiamo usato sopra. Quello era per i test. Dobbiamo presumere che abbiamo almeno il nostro blocco IP LAN aggiunto a "trusted". Sarebbe così:

`firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent`

Poi dobbiamo aggiungere i servizi alla zona:

`firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent`

Se avete aggiunto anche questi servizi alla zona "public", dovrete rimuoverli:

`firewall-cmd --zone=public --remove-service=http --remove-service=https --permanent`

Ora ricarica:

`firewall-cmd --reload`

## Porte FTP

Torniamo al nostro script `iptables`. Abbiamo le seguenti regole che riguardano l'FTP:

```
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
```

Questa parte dello script si occupa delle porte FTP standard (20 e 21) e dell'apertura di alcune porte passive aggiuntive. Questo tipo di set di regole è spesso necessario per server ftp come [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md). Generalmente, questo tipo di regola starebbe su un server web pubblico, ed è lì per permettere connessioni ftp dai vostri clienti.

Non esiste un servizio ftp-data (porta 20) con `firewalld`. Le porte da 7000 a 7500 elencate qui sono per connessioni FTP passive, e di nuovo, non c'è un modo diretto per farlo in `firewalld`. Potresti passare a SFTP, che semplificherebbe qui le regole di autorizzazione della porta, ed è probabilmente il modo raccomandato in questi giorni.

Quello che stiamo cercando di dimostrare qui, tuttavia, è la conversione di un insieme di regole di `iptables` in `firewalld`. Per aggirare tutti questi problemi, possiamo fare quanto segue.

Per prima cosa, aggiungete il servizio ftp alla zona che ospita anche i servizi web. Questo sarà probabilmente "public" in questo esempio:

`firewall-cmd --zone=public --add-service=ftp --permanent`

Poi aggiungiamo la porta ftp-data:

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

Quindi aggiungiamo le porte di connessione passive:

`firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent`

E poi, avete indovinato, ricaricare:

`firewall-cmd --reload`

## Porte del Database

Se avete a che fare con un server web, avete quasi certamente a che fare con un database. L'accesso a questo database dovrebbe essere gestito con la stessa cura che si applica agli altri servizi. Se l'accesso non è necessario al mondo, applicate la vostra regola a qualcosa di diverso da "public".  L'altra considerazione è: è necessario offrire l'accesso a tutti? Di nuovo, questo probabilmente dipende dal vostro ambiente. Dove lavoravo prima, gestivamo un server web ospitato per i nostri clienti. Molti avevano siti Wordpress, e nessuno di loro aveva davvero bisogno o richiesto l'accesso a qualsiasi front-end per `MariaDB`. Se un cliente aveva bisogno di più accesso, creavamo un container LXD per il loro server web, impostavamo il firewall nel modo in cui il cliente voleva, e lo lasciavamo responsabile di ciò che accadeva sul server. Tuttavia, se il tuo server è pubblico, potresti aver bisogno di offrire l'accesso a `phpmyadmin` o qualche altro front-end a `MariaDB`. In questo caso, dovete preoccuparvi dei requisiti della password per il database e impostare l'utente del database su qualcosa di diverso da quello predefinito. Per me, la lunghezza della password è la [considerazione principale quando si creano le password](https://xkcd.com/936/).

Ovviamente, la sicurezza delle password è una discussione per un altro documento che tratta proprio di questo, quindi assumeremo che abbiate una buona politica di password per l'accesso al vostro database e la linea `iptables` nel vostro firewall che tratta con il database assomiglia a questa:

`iptables -A INPUT -p tcp -m tcp --dport=3600 -j ACCEPT`

 In questo caso, aggiungiamo semplicemente il servizio alla zona "public" per una conversione `firewalld`:

`firewall-cmd --zone=public --add-service=mysql --permanent`

### Considerazioni su Postgresql

Postgresql usa la propria porta di servizio. Ecco un esempio di regola delle tabelle IP:

`iptables -A INPUT -p tcp -m tcp --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

Mentre è meno comune sui server web rivolti al pubblico, potrebbe essere più comune come risorsa interna. Si applicano le stesse considerazioni sulla sicurezza. Se hai un server sulla tua rete fidata (192.168.1.0/24 nel nostro esempio), potresti non voler o dover dare accesso a tutti su quella rete. Postgresql ha una lista di accesso disponibile per prendersi cura dei diritti di accesso più granulari. La nostra regola `firewalld` sarebbe qualcosa del genere:

`firewall-cmd --zone=trusted --add-service=postgresql`

## Porte DNS

Avere un server DNS privato o pubblico significa anche prendere precauzioni nelle regole che si scrivono per proteggere questi servizi. Se avete un server DNS privato, con regole iptables che assomigliano a questa (notate che la maggior parte dei servizi DNS sono UDP, piuttosto che TCP, ma non sempre):

`iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT`

allora permettere solo la vostra zona "trusted" sarebbe corretto. Abbiamo già impostato le fonti della nostra zona "trusted", quindi tutto quello che dovrete fare sarà aggiungere il servizio alla zona:

`firewall-cmd --zone=trusted --add-service=dns`

Con un server DNS pubblico, avrete solo bisogno di aggiungere lo stesso servizio alla zona "public":

`firewall-cmd --zone=public --add-service=dns`

## Per saperne di più sull'Elencazione delle Regole

!!! Note "Nota"

    Se si vuole si *può* elencare tutte le regole, elencando le regole di nftables. È brutto, e non lo consiglio, ma se proprio dovete, potete fare un `nft list ruleset`.

Una cosa che non abbiamo ancora fatto molto è elencare le regole. Questa è una cosa che si può fare per zona. Ecco degli esempi con le zone che abbiamo usato. Si noti che è possibile elencare la zona prima di spostare una regola permanente, il che è una buona idea.

`firewall-cmd --list-all --zone=trusted`

Qui possiamo vedere ciò che abbiamo applicato sopra:

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

Questo può essere applicato a qualsiasi zona. Per esempio, ecco la zona "public" ancora:

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
Si noti che abbiamo rimosso l'accesso "ssh" dai servizi e bloccato icmp "echo-reply" e "echo-request".

Nella nostra zona "admin" ancora, si presenta così:

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

## Regole Correlate Stabilite

Anche se non riesco a trovare alcun documento che lo affermi specificamente, sembra che `firewalld` gestisca internamente la seguente regola `iptables` per impostazione predefinita (se sai che questo non è corretto, per favore correggilo!):

`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

## Interfacce

Per impostazione predefinita, `firewalld` ascolterà su tutte le interfacce disponibili. Su un server fisico con più interfacce che si affacciano su più reti, sarà necessario assegnare un'interfaccia a una zona in base alla rete su cui si affaccia.

Nei nostri esempi, non abbiamo aggiunto alcuna interfaccia, perché stiamo lavorando con un contenitore LXD per i test di laboratorio. Abbiamo solo un'interfaccia con cui lavorare. Diciamo che la vostra zona "public" deve essere configurata per utilizzare la porta Ethernet enp3s0 poiché questa porta ha l'IP pubblico, e diciamo che le vostre zone "trusted" e "admin" sono sull'interfaccia LAN, che potrebbe essere enp3s1.

Per assegnare queste zone all'interfaccia appropriata, dovremmo usare i seguenti comandi:

```
firewall-cmd --zone=public --change-interface=enp3s0 --permanent
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent
firewall-cmd --reload
```
## Comandi Comuni di firewall-cmd

Abbiamo già usato alcuni comandi. Ecco alcuni comandi più comuni e cosa fanno:

| Comando                                      | Risultato                                                                                                          |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `firewall-cmd --list-all-zones`              | simile a `firewall-cmd --list-all --zone=[zone]` eccetto che elenca *tutte* le zone e i loro contenuti.            |
| `firewall-cmd --get-default-zone`            | mostra la zona predefinita, che è "public" a meno che non sia stata cambiata.                                      |
| `firewall-cmd --list-services --zone=[zone]` | mostra tutti i servizi abilitati per la zona.                                                                      |
| `firewall-cmd --list-ports --zone=[zone]`    | mostra tutte le porte aperte sulla zona.                                                                           |
| `firewall-cmd --get-active-zones`            | mostra le zone attive sul sistema, le loro interfacce attive, i servizi e le porte.                                |
| `firewall-cmd --get-services`                | mostra tutti i servizi disponibili possibili per l'uso.                                                            |
| `firewall-cmd --runtime-to-permanent`        | se sono state inserite molte regole senza l'opzione `--permanent`, eseguire questa operazione prima di ricaricare. |

Ci sono molte opzioni di `firewall-cmd` non coperte qui, ma questo vi dà i comandi più usati.

## Conclusione

Poiché `firewalld` è il firewall raccomandato e incluso in Rocky Linux, è una buona idea capire come funziona. Regole semplicistiche, incluse nella documentazione per l'applicazione di servizi utilizzando `firewalld`, spesso non tengono conto di ciò per cui il server viene utilizzato, e non offrono altre opzioni che permettere pubblicamente il servizio. Questo è uno svantaggio che si accompagna a buchi di sicurezza che non hanno bisogno di essere lì.

Quando vedete queste istruzioni, pensate per cosa viene usato il vostro server e se il servizio in questione deve essere aperto al mondo o meno. In caso contrario, considerate l'uso di una maggiore granularità nelle vostre regole come descritto sopra. Mentre l'autore non è ancora 100% a suo agio con il passaggio a `firewalld`, è altamente probabile che userò `firewalld` nella documentazione futura.

Il processo di scrittura di questo documento e la prova di laboratorio dei risultati sono stati molto utili per me. Speriamo che siano utili anche a qualcun altro. Questa non vuole essere una guida esaustiva di `firewalld`, ma piuttosto un punto di partenza.                                         
