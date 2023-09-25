---
title: firewalld per Principianti
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

# `firewalld` per Principianti

## Introduzione

Molto tempo fa, ero un piccolo utente di computer alle prime armi che aveva sentito dire che avere un firewall *doveva* essere super buono. Mi permetterebbe di decidere cosa entra e cosa esce dal mio computer, giusto? Ma sembrava soprattutto che impedisse ai miei videogiochi di accedere a Internet; non ne ero *felice*.

Naturalmente, se siete qui, probabilmente avete un'idea migliore di me su cosa sia un firewall e cosa faccia. Ma se la vostra esperienza con il firewall consiste nel dire a Windows Defender che la vostra nuova applicazione è autorizzata a utilizzare Internet, non preoccupatevi. Come indicato nel titolo del documento, questa guida è destinata a voi (e ad altri principianti)!

Parliamo quindi del motivo per cui siamo qui. `firewalld` è l'applicazione firewall predefinita fornita con Rocky Linux ed è stata progettata per essere piuttosto semplice da usare. È necessario conoscere un po' i firewall e non avere paura di usare la riga di comando.

Qui imparerete:

* Le basi del funzionamento di `firewalld`
* Come usare `firewalld` per limitare o permettere le connessioni in entrata e in uscita
* Come permettere solo alle persone di certi indirizzi IP o luoghi di accedere alla tua macchina da remoto
* Come gestire alcune caratteristiche `specifiche di firewalld` come le Zone.

Si noti che questa *non* vuole essere una guida completa o esaustiva sul firewall; di conseguenza, copre solo le basi.

### Una nota sull'uso della riga di comando per la gestione del firewall

Beh... ci *sono* le opzioni di configurazione grafica del firewall. Sul desktop, c'è `firewall-config` che può essere installato dai repo, mentre sui server si può [installare Cockpit](https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/) per gestire i firewall e un sacco di altre cose. **Tuttavia, in questo tutorial vi insegnerò il modo di procedere da riga di comando per un paio di motivi:**

1. Se state gestendo un server, userete comunque la riga di comando per la maggior parte di queste cose. Molti tutorial e guide per il server Rocky forniranno istruzioni a riga di comando per la gestione del firewall, e dovreste comprendere tali istruzioni piuttosto che copiare e incollare qualsiasi cosa vediate.
2. Capire come funzionano i comandi `firewalld` potrebbe aiutarvi a capire meglio come funziona il software del firewall.  Se in futuro deciderete di utilizzare un'interfaccia grafica, potrete applicare gli stessi principi appresi qui e comprendere meglio ciò che state facendo.

## Prerequisiti e presupposti
Avrete bisogno di:

* Una macchina Rocky Linux di qualsiasi tipo, locale o remota, fisica o virtuale
* Accesso al terminale e volontà di usarlo
* Avete bisogno dell'accesso root, o almeno della capacità di usare `sudo` sul vostro account utente. Per semplicità, assumo che tutti i comandi siano eseguiti come root
* Una comprensione di base di SSH non sarebbe male per la gestione di macchine remote.

## Uso di Base

### Comandi di Servizio del Sistema

`firewalld` viene eseguito come servizio sulla macchina. Si avvia quando lo fa la macchina, o almeno dovrebbe. Se per qualche motivo `firewalld` non è già abilitato sulla vostra macchina, potete farlo con un semplice comando:

```bash
systemctl enable --now firewalld
```

L'opzione `--now` avvia il servizio non appena viene abilitato e consente di saltare il passaggio `systemctl start firewalld`.

Come per tutti i servizi su Rocky Linux, è possibile verificare se il firewall è in esecuzione con:

```bash
systemctl status firewalld
```

Per fermarlo del tutto:

```bash
systemctl stop firewalld
```

E per riavviare il servizio:

```bash
systemctl restart firewalld
```

### Comandi di base per la configurazione e la gestione di `firewalld`

`firewalld` viene configurato con il comando `firewall-cmd`. È possibile, ad esempio, controllare lo stato di `firewalld` con:

```bash
firewall-cmd --state
```

Dopo ogni modifica *permanente* al firewall, è necessario ricaricarlo per vederne le modifiche. È possibile eseguire un "riavvio morbido" delle configurazioni del firewall con:

```bash
firewall-cmd --reload
```

!!! Note "Nota"

    Se ricarichi le tue configurazioni che non sono state rese permanenti, ti scompariranno.

È possibile visualizzare tutte le configurazioni e le impostazioni in una sola volta con:

```bash
firewall-cmd --list-all
```

Questo comando produrrà un risultato simile a questo:

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

!!! Warning "Attenzione: Seriamente, leggete la prossima parte."

    Per impostazione predefinita, tutte le modifiche alla configurazione di `firewalld` sono temporanee. Se riavviate l'intero servizio `firewalld`, o riavviate la vostra macchina, nessuna delle vostre modifiche al firewall sarà salvata a meno che non facciate una delle due cose molto specifiche.

 È consigliabile testare le modifiche singolarmente, ricaricando la configurazione del firewall man mano che si procede. Se ci si blocca accidentalmente, è possibile riavviare il servizio (o la macchina) e tutte le modifiche vengono eliminate, come già detto in precedenza.

Ma una volta ottenuta una configurazione funzionante, è possibile salvare le modifiche in modo permanente con:

```bash
firewall-cmd --runtime-to-permanent
```

Tuttavia, se si è assolutamente sicuri di ciò che si sta facendo e si vuole solo aggiungere la regola e andare avanti con la propria attività, si può aggiungere la flag `--permanent` a qualsiasi comando di configurazione:

```bash
firewall-cmd --permanent [resto del tuo comando]
```

## Gestire le Zone

Prima di ogni altra cosa, devo spiegare le zone. Le zone sono una funzione che consente di definire diverse serie di regole per situazioni diverse. Le zone sono una parte importante di `firewalld`, quindi è bene capire come funzionano.

Se il computer dispone di più modi per connettersi a reti diverse (ad esempio, Ethernet e Wi-Fi), è possibile decidere che una connessione sia più affidabile dell'altra. Si potrebbe impostare la connessione Ethernet nella zona "trusted" se è connessa solo a una rete locale realizzata da voi, e mettere il Wi-Fi (che potrebbe essere connesso a Internet) nella zona "public" con restrizioni più severe.

!!! Note "Nota"

    Una zona può *solo* essere in uno stato attivo se ha una di queste due condizioni:

    1. La zona è assegnata a un'interfaccia di rete
    2. Alla zona vengono assegnati IP di origine o intervalli di rete (maggiori informazioni in seguito)

Le zone predefinite includono le seguenti (ho preso questa spiegazione da [Guida di DigitalOcean a `firewalld`](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8), che dovreste leggere):

> **drop:** Il livello più basso di fiducia. Tutte le connessioni in entrata sono abbandonate senza risposta e solo le connessioni in uscita sono possibili.

> **block:** Simile al precedente, ma invece di abbandonare semplicemente le connessioni, le richieste in entrata sono rifiutate con un messaggio icmp-host-prohibited o icmp6-adm-prohibited.

> **public:** Rappresenta le reti pubbliche, non fidate. Non ti fidi degli altri computer, ma puoi permettere connessioni in entrata selezionate caso per caso.

> **internal:** L'altro lato della zona esterna, usata per la parte interna di un gateway. I computer sono abbastanza affidabili e sono disponibili alcuni servizi aggiuntivi.

> **dmz:** utilizzato per i computer situati in una DMZ (computer isolati che non avranno accesso al resto della vostra rete). I computer sono abbastanza affidabili e sono disponibili alcuni servizi aggiuntivi.

> **work:** Usato per le macchine da lavoro. Fidatevi della maggior parte dei computer della rete.

> **home:** Un ambiente domestico. Generalmente implica che vi fidate della maggior parte degli altri computer e che qualche servizio in più sarà accettato. Qualche altro servizio potrebbe essere permesso.

> **trusted:** Fidati di tutte le macchine della rete. La più aperta delle opzioni disponibili e dovrebbe essere usata con parsimonia.

> **trusted:** Fidati di tutte le macchine della rete. La più aperta delle opzioni disponibili e dovrebbe essere usata con parsimonia.

Ok, alcune di queste spiegazioni sono complicate, ma onestamente? Il principiante medio può cavarsela con la comprensione di "trusted", "home" e "public" e quando usarli.

### Comandi di gestione della zona

Per visualizzare la zona predefinita, eseguire:

```bash
firewall-cmd --get-default-zone
```

Per vedere quali zone sono attive e stanno facendo qualcosa, eseguire:

```bash
firewall-cmd --get-active-zones
```

!!! Note "Nota: alcune di queste cose potrebbero essere state fatte per voi"

     Se state eseguendo Rocky Linux su un VPS, probabilmente è stata impostata una configurazione di base per voi. In particolare, dovreste essere in grado di accedere al server via SSH, e l'interfaccia di rete sarà già stata aggiunta alla zona "public".

Per modificare la zona predefinita:

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

Per chi non lo sapesse, le porte (in questo contesto) sono solo endpoint virtuali a cui i computer si collegano per inviare informazioni avanti e indietro. Consideratele come porte Ethernet o USB fisiche del vostro computer, ma invisibili, e potete averne fino a 65.535 tutte attive contemporaneamente.

Io non lo farei, ma voi potete farlo.

Un numero identifica ogni porta. Alcune porte sono riservate a servizi specifici. Ad esempio, se avete mai lavorato con i server web per costruire un sito, potreste avere familiarità con le porte 80 e 443. Queste porte consentono la trasmissione dei dati delle pagine web.

In particolare, la porta 80 consente di trasferire dati tramite il protocollo HTTP (Hypertext Transfer Protocol), mentre la porta 443 è riservata ai dati HTTPS (Hypertext Transfer Protocol Secure).

La porta 22 è riservata al protocollo Secure Shell (SSH) che consente di accedere e gestire altri computer tramite la riga di comando (vedere [la nostra breve guida](ssh_public_private_keys.md) sull'argomento). Un server remoto nuovo di zecca potrebbe consentire solo connessioni sulla porta 22 per SSH e nient'altro.

Altri esempi sono FTP (porte 20 e 21), SSH (porta 22) e molti altri. È anche possibile impostare porte personalizzate da utilizzare per le nuove applicazioni che si potrebbero installare e che non hanno già un numero standard.

!!! Nota "Nota: non si dovrebbero usare le porte per tutto."

    Per cose come SSH, HTTP/S, FTP, e altro, si raccomanda di aggiungerli alla vostra zona firewall come *servizi*, e non come numeri di porta. Vi mostrerò come funziona qui sotto. Detto questo, devi comunque sapere come aprire le porte manualmente.

\* Per i principianti assoluti, l'HTTPS è fondamentalmente (più o meno) la stessa cosa dell'HTTP, ma criptata.

### Comandi di gestione della porta

Per questa sezione, userò `--zone=public`... e la porta 9001 come esempio casuale, perché è più di 9.000.

Per vedere tutte le porte aperte:

```bash
firewall-cmd --list-ports
```

Per aggiungere una porta alla zona del firewall (aprendola così all'uso), basta eseguire questo comando:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
```

!!! Note "Nota"

    Riguardo alla parte `/tcp`:
    
    Quel bit `/tcp` alla fine dice al firewall che le connessioni arriveranno attraverso il Transfer Control Protocol, che è quello che userai per la maggior parte delle cose relative al server-e-ospite.
    
     Alternative come UDP servono per il debug o per altri tipi particolari di cose che non rientrano nello scopo di questa guida. Fate riferimento alla documentazione di qualsiasi applicazione o servizio per cui volete specificamente aprire una porta.

Per rimuovere una porta, è sufficiente invertire il comando cambiando una sola parola:

```bash
firewall-cmd --zone=public --remove-port=9001/tcp
```

## Gestione dei servizi

Come si può immaginare, i servizi sono programmi piuttosto standardizzati che vengono eseguiti sul computer. `firewalld` è impostato in modo da poter essere utilizzato per fornire facilmente l'accesso ai servizi comuni in esecuzione sull'host.

Questo è il modo preferito per aprire le porte di questi servizi comuni e di molti altri:

* HTTP e HTTPS: per i server web
* FTP: per spostare i file avanti e indietro (alla vecchia maniera)
* SSH: per controllare macchine remote e spostare file avanti e indietro nel nuovo modo
* Samba: Per la condivisione di file con macchine Windows.

!!! Warning "Attenzione"

    **Non rimuovere mai il servizio SSH dal firewall di un server remoto!**
    
    Ricordate, SSH è quello che usate per accedere al vostro server. A meno che non abbiate un altro modo per accedere al server fisico, o alla sua shell (cioè tramite. un pannello di controllo fornito dall'host), la rimozione del servizio SSH vi bloccherà permanentemente.
    
    Dovrete contattare l'assistenza per riavere l'accesso o reinstallare completamente il sistema operativo.

## Comandi di gestione del servizio

Per visualizzare un elenco di tutti i servizi disponibili che si possono aggiungere al firewall, eseguire:

```bash
firewall-cmd --get-services
```

Per vedere quali servizi sono attualmente attivi sul firewall, utilizzare:

```bash
firewall-cmd --list-services
```

Per aprire un servizio nel firewall (ad esempio HTTP nella zona pubblica), utilizzare:

```bash
firewall-cmd --zone=public --add-service=http
```

Per rimuovere/chiudere un servizio sul firewall, è sufficiente cambiare nuovamente una parola:

```bash
firewall-cmd --zone=public --remove-service=http
```

!!! Note "Nota: è possibile aggiungere i propri servizi."

    E personalizzarli anche. Tuttavia, questo è un argomento che diventa piuttosto complesso. Prima di tutto, familiarizzate con `firewalld` e poi proseguite da lì.

## Limitare l'accesso

Supponiamo che abbiate un server e non vogliate renderlo pubblico. Se si desidera definire chi può accedervi tramite SSH o visualizzare alcune pagine web/app private, è possibile farlo.

Esistono un paio di metodi per raggiungere questo obiettivo. In primo luogo, per un server più chiuso, si può scegliere una delle zone più restrittive, assegnarvi il dispositivo di rete, aggiungervi il servizio SSH come illustrato sopra e quindi inserire nella whitelist il proprio indirizzo IP pubblico come segue:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< insert your IP here]
```

È possibile creare un intervallo di indirizzi IP aggiungendo un numero più alto alla fine, in questo modo:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< insert your IP here]
```

Anche in questo caso, basta cambiare `--add-source` con `--remove-source` per invertire il processo.

Tuttavia, avete alcune opzioni se state gestendo un server remoto con un sito web che deve essere pubblico e volete aprire SSH solo per un indirizzo IP o per un piccolo intervallo di indirizzi. Entrambi gli esempi assegnano l'unica interfaccia di rete alla zona pubblica.

In primo luogo, è possibile utilizzare una "rich rule" per la zona pubblica, con un aspetto simile a questo:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'
```

Una volta che la rich rule è stata inserita, *non rendere le regole permanenti*. Per prima cosa, rimuovete il servizio SSH dalla configurazione della zona pubblica e testate la connessione per assicurarvi di poter accedere al server tramite SSH.

La configurazione dovrebbe ora apparire come segue:

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


In secondo luogo, è possibile utilizzare due zone diverse alla volta. Se l'interfaccia è vincolata alla zona pubblica, è possibile attivare una seconda zona (la zona "trusted", ad esempio) aggiungendo un IP sorgente o un intervallo di IP, come mostrato sopra. Quindi, aggiungere il servizio SSH alla zona trusted e rimuoverlo dalla zona public.

Al termine, l'output dovrebbe essere simile a questo:

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

Se si viene bloccati, riavviare il server (la maggior parte dei pannelli di controllo VPS ha un'opzione per questo) e riprovare.

!!! Warning "Attenzione"

    Queste tecniche funzionano solo se avete un indirizzo IP statico.
    
    Se siete bloccati con un provider di servizi internet che cambia il vostro indirizzo IP ogni volta che il modem si riavvia, non usate queste regole (almeno non per SSH) fino a quando non avrete una soluzione per questo. Ti chiuderai fuori dal tuo server
    
    Vi chiuderete fuori dal vostro server
    
    O aggiornate il vostro piano/provider internet o prendete una VPN che vi fornisca un IP dedicato e che non lo perda *mai e poi mai*.
    
    Nel frattempo, [installare e configurare fail2ban](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8), che può aiutare a ridurre gli attacchi di brute force.
    
    Ovviamente, su una rete locale che controllate (e dove potete impostare manualmente l'indirizzo IP di ogni macchina), potete usare tutte queste regole quanto volete.

## Note Finali

Questa è una guida tutt'altro che esaustiva e si può imparare molto di più con la documentazione [ufficiale di `firewalld`](https://firewalld.org/documentation/). Su Internet sono disponibili anche guide specifiche per le applicazioni che vi mostreranno come impostare il firewall per quelle specifiche applicazioni.

Per i fan di `iptables` (se siete arrivati fin qui...), [abbiamo una guida](firewalld.md) che illustra in dettaglio alcune differenze nel funzionamento di `firewalld` e `iptables`. Questa guida potrebbe aiutarvi a capire se volete rimanere con `firewalld` o tornare alle Vecchie Abitudini<sup> (TM)</sup>. In questo caso, c'è qualcosa da dire riguardo ai Vecchie Abitudini<sup> (TM)</sup>.

## Conclusione

E questo è `firewalld` nel minor numero di parole possibili, pur spiegando tutte le nozioni di base. Fate le cose con calma, sperimentate con attenzione e non rendete permanente nessuna regola finché non siete sicuri che funzioni.

E, insomma, divertitevi. Una volta acquisite le nozioni di base, la configurazione di un firewall decente e funzionante può richiedere 5-10 minuti.
