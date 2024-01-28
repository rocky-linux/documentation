---
title: Tor Relay
author: Neel Chauhan
contributors: Spencer Steven
tested_with: 8.7, 9.2
tags:
  - proxy
  - proxies
---

# Tor relay

## Introduzione

[Tor](https://www.torproject.org/) è un servizio e un software di anonimato che instrada il traffico attraverso tre server gestiti da volontari e chiamati relay. Il design a tre hop serve a garantire la privacy contrastando i tentativi di sorveglianza.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- Un indirizzo IP pubblico, direttamente sul server o con il port forwarding.
- Un sistema in grado di funzionare 24 ore su 24, 7 giorni su 7, per servire la rete Tor.
- La possibilità di eseguire comandi come utente root o di usare `sudo` per elevare i privilegi.
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma potete sostituirlo con il vostro editor preferito.
- Familiarità con la modifica delle impostazioni di SELinux e del firewall.
- Una connessione senza contatore o una connessione con un limite di larghezza di banda elevato.

## Installazione di Tor

Per installare Tor, è necessario prima installare EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti:

```bash
dnf -y install epel-release && dnf -y update
```

Quindi installare Tor:

```bash
dnf -y install tor
```

## Configurazione di Tor

Una volta installati i pacchetti, è necessario configurare Tor. L'autore usa `vi` per questo, ma se preferite `nano` o qualcos'altro, sostituitelo pure:

```bash
vi /etc/tor/torrc
```

Il file `torrc` predefinito è abbastanza descrittivo, ma può diventare lungo se si vuole solo un relay Tor. Una configurazione minima di relè è simile a questa:

```bash
Nickname TorRelay
ORPort 9001
ContactInfo you@example.com
Log notice syslog
```

### Uno sguardo più approfondito

- Il "Nickname" è un soprannome (non univoco) per il proprio relay Tor.
- La "ORPort" è la porta TCP su cui il relay Tor è in ascolto. Quella predefinita è "9001".
- Il "ContactInfo" è il vostro recapito, nel caso in cui ci siano problemi con il vostro relay Tor. Impostate questo campo con il vostro indirizzo e-mail.
- Il "Log" è la severità e la destinazione dei log del relay Tor. Stiamo registrando "notice" per evitare che le informazioni sensibili vengano registrate e "syslog" per inviare l'output al log di `systemd`.

### Configurazione del sistema

Se si è scelta una porta TCP/IP diversa da "9001" (quella predefinita), è necessario regolare la `tor_port_t` di SELinux per inserire nella whitelist la porta del relay Tor. Per farlo:

```bash
semanage port -a -t tor_port_t -p tcp 12345
```

Sostituire "12345" con la porta TCP impostata in "ORPort".

È inoltre necessario aprire la porta "ORPort" nel firewall. Per farlo:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
firewall-cmd --runtime-to-permanent
```

Sostituire "9001" con la porta TCP impostata in "ORPort".

## Limitare la larghezza di banda

Se non volete dedicare tutta la vostra larghezza di banda a Tor, ad esempio se avete una politica di uso equo presso il vostro ISP, potete limitare la vostra larghezza di banda. È possibile limitare la larghezza di banda (ad esempio, 100 megabit) o il traffico in un periodo di tempo (ad esempio, 5 Gb al giorno).

Per farlo, modificare il file `torrc`:

```bash
vi /etc/tor/torrc
```

Se si desidera limitare la larghezza di banda, è necessario aggiungere la seguente riga al file `torrc`:

```bash
RelayBandwidthRate 12500 KB
```

Ciò consentirà di ottenere 12500 KB al secondo di larghezza di banda, pari a circa 100 megabit al secondo.

Se si preferisce trasferire una quantità specifica di traffico in un periodo di tempo, ad esempio al giorno, si può aggiungere il seguente valore:

```bash
AccountingStart day 00:00
AccountingMax 20 GB
```

Questi valori implicano che:

- Il periodo di contabilizzazione della larghezza di banda è ogni giorno a partire dalle 00:00 ora del sistema. È anche possibile cambiare "day" in " week " o " month ", oppure sostituire " 00:00 " con un altro orario.
- Nel periodo di contabilizzazione della larghezza di banda, sarà possibile trasferire 20 GB. Aumentare o diminuire il valore se si desidera consentire una maggiore o minore larghezza di banda per il relay.

Cosa succede dopo aver utilizzato la larghezza di banda specificata? Il relay bloccherà i tentativi di connessione fino alla fine del periodo. Se il relay non ha utilizzato la larghezza di banda specificata nel periodo, il contatore si azzera senza alcun tempo di inattività.

## Test e avvio

Una volta impostata la configurazione del relay Tor, il passo successivo è quello di attivare il demone Tor:

```bash
systemctl enable --now tor
```

Nei log di systemd si dovrebbe trovare una riga come:

```bash
Jan 14 15:46:36 hostname tor[1142]: Jan 14 15:46:36.000 [notice] Self-testing indicates your ORPort A.B.C.D:9001 is reachable from the outside. Excellent. Publishing server descriptor.
```

Questo indica che il relay è accessibile.

Entro poche ore, il vostro relay sarà elencato su [Tor Relay Status](https://metrics.torproject.org/rs.html) digitando il vostro nickname o l'indirizzo IP pubblico.

## Considerazioni sul relay

È inoltre possibile estendere la configurazione per rendere il relay Tor un relay di uscita o un relay di ponte.

I relay di uscita sono l'ultimo hop di un circuito Tor che si collega direttamente ai siti web. I relay bridge sono relay non elencati che aiutano gli utenti che subiscono la censura di Internet a connettersi a Tor.

Le opzioni per il file `torrc` si trovano nella [pagina del manuale](https://2019.www.torproject.org/docs/tor-manual.html.en).

È inoltre possibile impostare un massimo di 8 relay per indirizzo IP pubblico. Il file dell'unità Tor systemd in EPEL non è stato progettato per più di un'istanza, ma il file dell'unità può essere copiato e modificato per adattarsi a una configurazione multi-relay.

!!! warning "Attenzione"

```
Se si intende gestire un exit relay, assicurarsi che il proprio ISP o società di hosting sia d'accordo. I reclami per abusi da parte degli exit relay sono molto comuni, poiché si tratta dell'ultimo nodo di un circuito Tor che si connette direttamente ai siti web per conto degli utenti Tor. Per questo motivo, molte società di hosting non accettano i relay di uscita Tor.

Se non siete sicuri che il vostro ISP permetta i relay di uscita Tor, consultate i termini di servizio o chiedete al vostro ISP. Se il vostro ISP dice di no, cercate un altro ISP o una società di hosting, oppure prendete in considerazione un relay intermedio.
```

## Conclusione

A differenza di un servizio VPN convenzionale, Tor si avvale di relay gestiti da volontari per garantire la privacy e l'anonimato, che avete appena impostato.

Sebbene il funzionamento di un relay Tor richieda un sistema affidabile e, per le uscite, un ISP di supporto, l'aggiunta di più relay aiuta la privacy e rende Tor più veloce con meno punti di debolezza.
