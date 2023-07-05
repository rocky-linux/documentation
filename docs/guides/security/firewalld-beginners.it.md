---
title: firewalld per Principianti
author: Ezequiel Bruni
contributors: Steven Spencer, Franco Colussi
---

# `firewalld` per Principianti

## Introduzione

Molto tempo fa, ero un piccolo utente di computer alle prime armi che aveva sentito dire che avere un firewall *doveva* essere super buono. Mi permetterebbe di decidere cosa entra e cosa esce dal mio computer, giusto? Ma sembrava soprattutto impedire ai miei videogiochi di accedere a internet; e *non* ero felice e contento.

Naturalmente, se siete qui, probabilmente avete un'idea migliore di me su cosa sia un firewall e cosa faccia. Ma se la vostra esperienza con il firewall equivale a dire a Windows Defender che sì, per l'amore di tutto ciò che è santo, la vostra nuova applicazione ha il permesso di usare internet, non preoccupatevi. C'è scritto "per Principianti" in alto; ti ho preso.

In altre parole, i miei colleghi nerd devono essere consapevoli che ci saranno molte spiegazioni in arrivo.

Parliamo quindi del motivo per cui siamo qui. `firewalld` è l'applicazione firewall predefinita fornita con Rocky Linux, ed è progettata per essere abbastanza semplice da usare. Dovete solo sapere un po' come funzionano i firewall e non aver paura di usare la riga di comando.

Qui imparerete:

* Le basi del funzionamento di `firewalld`
* Come usare `firewalld` per limitare o permettere le connessioni in entrata e in uscita
* Come permettere solo alle persone di certi indirizzi IP o luoghi di accedere alla tua macchina da remoto
* Come gestire alcune caratteristiche `specifiche di firewalld` come le Zone.

Questa *non* vuole essere una guida completa o esaustiva.

### Una nota sull'uso della riga di comando per la gestione del firewall

Beh... ci *sono* opzioni di configurazione grafica del firewall. Sul desktop, c'è `firewall-config` che può essere installato dai repo, e sui server puoi [installare Cockpit](https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/) per aiutarti a gestire i firewall e un sacco di altre cose. **Tuttavia, in questo tutorial vi insegnerò il modo a riga di comando per fare le cose per un paio di ragioni:**

1. Se state gestendo un server, userete comunque la riga di comando per la maggior parte di queste cose. Molti tutorial e guide per il server Rocky daranno istruzioni a riga di comando per la gestione del firewall, ed è meglio che tu capisca queste istruzioni, piuttosto che copiare e incollare qualsiasi cosa tu veda.
2. Capire come funzionano i comandi `firewalld` potrebbe aiutarvi a capire meglio come funziona il software del firewall. Potete prendere gli stessi principi che imparate qui, e avere un'idea migliore di quello che state facendo se decidete di usare un'interfaccia grafica in futuro.

## Prerequisiti e presupposti
Avrai bisogno di:

* Una macchina Rocky Linux di qualsiasi tipo, locale o remota, fisica o virtuale
* Accesso al terminale e volontà di usarlo
* Avete bisogno dell'accesso root, o almeno della capacità di usare `sudo` sul vostro account utente. Per semplicità, assumo che tutti i comandi siano eseguiti come root
* Una comprensione di base di SSH non sarebbe male per la gestione di macchine remote.

## Uso di Base

### Comandi di Servizio del Sistema

`firewalld` viene eseguito come servizio sulla vostra macchina. Si avvia quando lo fa la macchina, o dovrebbe. Se per qualche motivo `firewalld` non è già abilitato sulla vostra macchina, potete farlo con un semplice comando:

```bash
systemctl enable --now firewalld
```

La flag `--now` avvia il servizio non appena viene abilitato, e ti permette di saltare il passo `systemctl start firewalld`.

Come per tutti i servizi su Rocky Linux, potete controllare se il firewall è in funzione con:

```bash
systemctl status firewalld
```

Per fermarlo del tutto:

```bash
systemctl stop firewalld
```

E per dare al servizio un riavvio forte:

```bash
systemctl restart firewalld
```

### Comandi di base per la configurazione e la gestione di `firewalld`

`firewalld` è configurato con il comando `firewall-cmd`. Potete, per esempio, controllare lo stato di `firewalld` con:

```bash
firewall-cmd --state
```

Dopo ogni modifica *permanente* al tuo firewall, dovrai ricaricarlo per vedere i cambiamenti. Potete dare alle configurazioni del firewall un "riavvio morbido" con:

```bash
firewall-cmd --reload
```

!!! Note "Nota"

    Se ricarichi le tue configurazioni che non sono state rese permanenti, ti scompariranno.

Potete vedere tutte le vostre configurazioni e impostazioni in una volta sola con:

```bash
firewall-cmd --list-all
```

Questo comando produrrà qualcosa che assomiglia a questo:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
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

### Salvare le modifiche

!!! Warning "Attenzione: Seriamente, leggete il prossimo pezzo"

    Per impostazione predefinita, tutte le modifiche alla configurazione di `firewalld` sono temporanee. Se riavviate l'intero servizio `firewalld`, o riavviate la vostra macchina, nessuna delle vostre modifiche al firewall sarà salvata a meno che non facciate una delle due cose molto specifiche.

È una buona pratica testare tutte le modifiche una per una, ricaricando la configurazione del firewall mentre si procede. In questo modo, se si blocca accidentalmente qualcosa, si può riavviare il servizio (o la macchina), tutte quelle modifiche spariscono come detto sopra.

Ma una volta che avete una configurazione funzionante, potete salvare le vostre modifiche in modo permanente con:

```bash
firewall-cmd --runtime-to-permanent
```

Tuttavia, se sei assolutamente sicuro di quello che stai facendo, e vuoi solo aggiungere la regola e andare avanti con la tua vita, puoi aggiungere il flag `--permanent` a qualsiasi comando di configurazione:

```bash
firewall-cmd --permanent [resto del tuo comando]
```

## Gestire le Zone

Prima di ogni altra cosa, devo spiegare le zone. Le zone sono una caratteristica che fondamentalmente permette di definire diversi set di regole per diverse situazioni. Le zone sono una parte enorme di `firewalld`, quindi è utile capire come funzionano.

Se il computer dispone di più modi per connettersi a reti diverse (ad esempio, Ethernet e Wi-Fi), è possibile decidere che una connessione sia più affidabile dell'altra. Si potrebbe impostare la connessione Ethernet nella zona "trusted" se è collegata solo a una rete locale costruita dall'utente, e mettere il Wi-Fi (che potrebbe essere collegato a Internet) nella zona "public" con restrizioni più severe.

!!! Note "Nota"

    Una zona può *solo* essere in uno stato attivo se ha una di queste due condizioni:

    1. La zona è assegnata a un'interfaccia di rete
    2. Alla zona vengono assegnati IP di origine o intervalli di rete (maggiori informazioni in seguito)

Le zone predefinite includono le seguenti (ho preso questa spiegazione dalla [guida di DigitalOcean `firewalld`](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8), che dovreste anche leggere):

> **drop:** Il livello più basso di fiducia. Tutte le connessioni in entrata sono abbandonate senza risposta e solo le connessioni in uscita sono possibili.

> **block:** Simile al precedente, ma invece di abbandonare semplicemente le connessioni, le richieste in entrata sono rifiutate con un messaggio icmp-host-prohibited o icmp6-adm-prohibited.

> **public:** Rappresenta le reti pubbliche, non fidate. Non ti fidi degli altri computer, ma puoi permettere connessioni in entrata selezionate caso per caso.

> **internal:** L'altro lato della zona esterna, usata per la parte interna di un gateway. I computer sono abbastanza affidabili e sono disponibili alcuni servizi aggiuntivi.

> **dmz:** utilizzato per i computer situati in una DMZ (computer isolati che non avranno accesso al resto della vostra rete). I computer sono abbastanza affidabili e sono disponibili alcuni servizi aggiuntivi.

> **work:** Usato per le macchine da lavoro. Fidatevi della maggior parte dei computer della rete.

> **home:** Un ambiente domestico. Generalmente implica che vi fidate della maggior parte degli altri computer e che qualche servizio in più sarà accettato. Qualche altro servizio potrebbe essere permesso.

> **trusted:** Fidati di tutte le macchine della rete. La più aperta delle opzioni disponibili e dovrebbe essere usata con parsimonia.

> **trusted:** Fidati di tutte le macchine della rete. La più aperta delle opzioni disponibili e dovrebbe essere usata con parsimonia.

Ok, alcune di queste spiegazioni sono complicate, ma onestamente? Il principiante medio può cavarsela con la comprensione di "trusted", "home" e "public", e quando usarli.

### Comandi di gestione della zona

Per vedere la vostra zona predefinita, eseguite:

```bash
firewall-cmd --get-default-zone
```

Per vedere quali zone sono attive e fanno cosa, esegui:

```bash
firewall-cmd --get-active-zones
```

!!! Note "Nota: alcune di queste cose potrebbero essere state fatte per voi"

    Se stai eseguendo Rocky Linux su un VPS, è probabile che una configurazione di base sia stata impostata per te. In particolare, dovreste essere in grado di accedere al server via SSH, e l'interfaccia di rete sarà già stata aggiunta alla zona "public".

Per cambiare la zona predefinita:

```bash
firewall-cmd --set-default-zone [tua-zona]
```

Per aggiungere un'interfaccia di rete a una zona:

```bash
firewall-cmd --zone=[tua-zona] --add-interface=[tua-intefaccia-di-rete]
```

Per cambiare la zona di un'interfaccia di rete:

```bash
firewall-cmd --zone=[tua-zona] --change-interface=[tua-interfaccia-di-rete]
```

Per rimuovere completamente un'interfaccia da una zona:

```bash
firewall-cmd --zone=[tua-zona] --remove-interface=[tua-intefaccia-di-rete]
```

Per creare una zona nuova di zecca con un set di regole completamente personalizzate e verificare che sia stata aggiunta correttamente:

```bash
firewall-cmd --new-zone=[tua-nuova-zona]
firewall-cmd --get-zones
```

## Gestione delle Porte

Per chi non lo sapesse, le porte (in questo contesto) sono solo degli endpoint virtuali dove i computer si connettono tra loro per poter inviare informazioni avanti e indietro. Pensate a loro come a delle porte fisiche Ethernet o USB sul vostro computer, ma invisibili, e potete averne fino a 65.535 tutte insieme.

Io non lo farei, ma tu puoi.

Ogni porta è definita da un numero, e alcune porte sono riservate a servizi specifici e a tipi di informazioni. Se hai mai lavorato con i server web per costruire un sito web, per esempio, potresti avere familiarità con la porta 80 e la porta 443. Queste porte permettono la trasmissione dei dati delle pagine web.

In particolare, la porta 80 consente di trasferire dati tramite il protocollo HTTP (Hypertext Transfer Protocol), mentre la porta 443 è riservata ai dati HTTPS (Hypertext Transfer Protocol Secure).

La porta 22 è riservata al protocollo Secure Shell (SSH) che consente di accedere e gestire altri computer tramite la riga di comando (vedere [la nostra breve guida](ssh_public_private_keys.md) sull'argomento). Un server remoto nuovo di zecca potrebbe consentire solo connessioni sulla porta 22 per SSH e nient'altro.

Altri esempi sono FTP (porte 20 e 21), SSH (porta 22), e molti altri. È anche possibile impostare porte personalizzate per essere utilizzate da nuove applicazioni che potreste installare, che non hanno già un numero standard.

!!! Note "Nota: non dovreste usare le porte per tutto"

    Per cose come SSH, HTTP/S, FTP, e altro, si raccomanda di aggiungerli alla vostra zona firewall come *servizi*, e non come numeri di porta. Vi mostrerò come funziona qui sotto. Detto questo, devi comunque sapere come aprire le porte manualmente.

\* Per i principianti assoluti, l'HTTPS è fondamentalmente (più o meno) la stessa cosa dell'HTTP, ma criptata.

### Comandi di gestione della porta

Per questa sezione, userò `--zone=public`... e la porta 9001 come esempio casuale, perché è più di 9.000.

Per vedere tutte le porte aperte:

```bash
firewall-cmd --list-ports
```

Per aggiungere una porta alla vostra zona firewall (aprendola così all'uso), basta eseguire questo comando:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
```

!!! Note "Nota"

    Riguardo alla parte `/tcp`:
    
    Quel bit `/tcp` alla fine dice al firewall che le connessioni arriveranno attraverso il Transfer Control Protocol, che è quello che userai per la maggior parte delle cose relative al server-e-ospite.
    
    Alternative come UDP sono per il debug, o altri tipi di cose molto specifiche che francamente non rientrano nello scopo di questa guida. Fate riferimento alla documentazione di qualsiasi applicazione o servizio per cui volete specificamente aprire una porta.

Per rimuovere una porta, basta invertire il comando con un cambio di una sola parola:

```bash
firewall-cmd --zone=public --remove-port=9001/tcp
```

## Gestione dei servizi

I servizi, come potete immaginare, sono programmi abbastanza standardizzati che girano sul vostro computer. `firewalld` è impostato in modo che possa semplicemente aprire la strada per la maggior parte dei servizi comuni ogni volta che è necessario farlo.

Questo è il modo preferito per aprire le porte per questi servizi comuni, e molto di più:

* HTTP e HTTPS: per i server web
* FTP: per spostare i file avanti e indietro (alla vecchia maniera)
* SSH: per controllare macchine remote e spostare file avanti e indietro nel nuovo modo
* Samba: Per la condivisione di file con macchine Windows.

!!! Warning "Attenzione"

    **Non rimuovere mai il servizio SSH dal firewall di un server remoto!**
    
    Ricordate, SSH è quello che usate per accedere al vostro server. A meno che non abbiate un altro modo per accedere al server fisico, o alla sua shell (cioè tramite. un pannello di controllo fornito dall'host), la rimozione del servizio SSH vi bloccherà permanentemente.
    
    Dovrete contattare l'assistenza per riavere l'accesso o reinstallare completamente il sistema operativo.

## Comandi di gestione del servizio

Per vedere un elenco di tutti i servizi disponibili che potreste potenzialmente aggiungere al vostro firewall, eseguite:

```bash
firewall-cmd --get-services
```

Per vedere quali servizi hai attualmente attivi sul tuo firewall, usa:

```bash
firewall-cmd --list-services
```

Per aprire un servizio nel tuo firewall (ad esempio HTTP nella zona pubblica), usa:

```bash
firewall-cmd --zone=public --add-service=http
```

Per rimuovere/chiudere un servizio sul vostro firewall, basta cambiare ancora una parola:

```bash
firewall-cmd --zone=public --remove-service=http
```

!!! Note "Nota: puoi aggiungere i tuoi servizi"

    E personalizzarli anche. Tuttavia, questo è un argomento che diventa piuttosto complesso. Prima di tutto, familiarizzate con `firewalld` e poi proseguite da lì.

## Limitare l'accesso

Diciamo che avete un server e non volete renderlo pubblico. se volete definire solo chi è autorizzato ad accedere via SSH, o visualizzare alcune pagine web/app private, potete farlo.

Ci sono un paio di metodi per farlo. Per prima cosa, per un server più chiuso, puoi scegliere una delle zone più restrittive, assegnare il tuo dispositivo di rete ad essa, aggiungere il servizio SSH come mostrato sopra, e poi mettere in whitelist il tuo indirizzo IP pubblico in questo modo:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< insert your IP here]
```

Potete renderlo un intervallo di indirizzi IP aggiungendo un numero più alto alla fine, in questo modo:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< insert your IP here]
```

Di nuovo, basta cambiare `--add-source` in `--remove-source` per invertire il processo.

Tuttavia, se state gestendo un server remoto con un sito web su di esso che ha bisogno di essere pubblico, e volete ancora aprire SSH solo per un indirizzo IP o una piccola gamma di essi, avete un paio di opzioni. In entrambi questi esempi, l'unica interfaccia di rete è assegnata alla zona pubblica.

In primo luogo, potete usare una "regola ricca" per la vostra zona pubblica, e sarebbe qualcosa di simile a questo:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'
```

Una volta che la regola ricca è in vigore, *non* rendere le regole ancora permanenti. Per prima cosa, rimuovete il servizio SSH dalla configurazione della zona pubblica, e testate la vostra connessione per assicurarvi di poter ancora accedere al server via SSH.

La vostra configurazione dovrebbe ora assomigliare a questa:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept
```


In secondo luogo, è possibile utilizzare due zone diverse alla volta. Se avete la vostra interfaccia legata alla zona pubblica, potete attivare una seconda zona (la zona "trusted" per esempio) aggiungendovi un IP sorgente o un intervallo IP come mostrato sopra. Poi, aggiungete il servizio SSH alla zona fidata e rimuovetelo dalla zona pubblica.

Quando hai finito, l'output dovrebbe assomigliare un po' a questo:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
your@server ~# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/24
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

Se rimani bloccato, riavvia il server (la maggior parte dei pannelli di controllo VPS hanno un'opzione per questo) e riprova.

!!! Warning "Attenzione"

    Queste tecniche funzionano solo se avete un indirizzo IP statico.
    
    Se siete bloccati con un provider di servizi internet che cambia il vostro indirizzo IP ogni volta che il modem si riavvia, non usate queste regole (almeno non per SSH) fino a quando non avrete una soluzione per questo. Ti chiuderai fuori dal tuo server
    
    Vi chiuderete fuori dal vostro server
    
    O aggiornate il vostro piano/provider internet o prendete una VPN che vi fornisca un IP dedicato e che non lo perda *mai e poi mai*.
    
    Nel frattempo, [installare e configurare fail2ban](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8), che può aiutare a ridurre gli attacchi di brute force.
    
    Ovviamente, su una rete locale che controllate (e dove potete impostare manualmente l'indirizzo IP di ogni macchina), potete usare tutte queste regole quanto volete.

## Note Finali

Questa è lungi dall'essere una guida esaustiva, e si può imparare molto di più con la [documentazione ufficiale](https://firewalld.org/documentation/) di [ `firewalld`](https://firewalld.org/documentation/). Su Internet sono disponibili anche guide specifiche per le applicazioni che vi mostreranno come impostare il firewall per quelle specifiche applicazioni.

Per voi fan di `iptables` (se siete arrivati fin qui...), [abbiamo una guida](firewalld.md) che dettaglia alcune delle differenze nel funzionamento di `firewalld` e `iptables`. Quella guida potrebbe aiutarti a capire se vuoi rimanere con `firewalld` o tornare a The Old Ways<sup>(TM)</sup>. C'è qualcosa da dire per The Old Ways<sup>(TM)</sup>, in questo caso.

## Conclusione

E questo è `firewalld` nel minor numero di parole che ho potuto gestire, pur spiegando tutte le basi. Prendila con calma, sperimenta con attenzione e non rendere permanente nessuna regola finché non sei sicuro che funzioni.

E, insomma, divertitevi. Una volta che avete le basi, impostare effettivamente un firewall decente e funzionante può richiedere 5-10 minuti.
