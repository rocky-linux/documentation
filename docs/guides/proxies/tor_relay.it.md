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

- Un indirizzo IPv4 pubblico, direttamente sul server o con il port forwarding
- Un sistema in grado di funzionare 24 ore su 24, 7 giorni su 7, per essere utile alla rete Tor
- La possibilità di eseguire comandi come utente root o di usare `sudo` per elevare i privilegi.
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma potete sostituirlo con il vostro editor preferito.
- Familiarità con la modifica delle impostazioni di SELinux e del firewall.
- Una connessione non misurata o una connessione con un limite di larghezza di banda elevato
- Opzionale: Un indirizzo IPv6 pubblico per la connettività dual-stack.

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

- Il `Nickname` è un soprannome (non univoco) per il proprio relay Tor.
- La `ORPort' è la porta TCP su cui il relè Tor è in ascolto. Quella predefinita è `9001\`.
- Il "ContactInfo" è il vostro recapito, nel caso in cui ci siano problemi con il vostro relay Tor. Impostate questo campo con il vostro indirizzo e-mail.
- Il parametro `Log` è la gravità e la destinazione dei log del relè Tor. Stiamo registrando `notice` per evitare che vengano registrate informazioni sensibili e `syslog` per inviare l'output al log di `systemd`.

### Configurazione del sistema

Se si è scelta una porta TCP/IP diversa da `9001` (quella predefinita), è necessario regolare la `tor_port_t` di SELinux per inserire nella whitelist la porta del relè Tor. Per farlo:

```bash
semanage port -a -t tor_port_t -p tcp 12345
```

Sostituire `12345` con la porta TCP impostata in `ORPort`.

È inoltre necessario aprire la porta `ORPort` nel firewall. Per farlo:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
firewall-cmd --runtime-to-permanent
```

Sostituire `9001` con la porta TCP impostata in `ORPort`.

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

- Il periodo di contabilizzazione della larghezza di banda è ogni giorno a partire dalle 00:00 ora del sistema. Si può anche cambiare `giorno` in `settimana` o `mese`, o sostituire `00:00` con un altro orario.
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

È inoltre possibile estendere la configurazione per rendere il relè Tor un relè di uscita o un relè ponte. È inoltre possibile impostare un massimo di 8 relè per indirizzo IP pubblico. Il file dell'unità Tor systemd in EPEL non è stato progettato per più di un'istanza, ma il file dell'unità può essere copiato e modificato per adattarsi a una configurazione multi-relay.

I relè di uscita sono l'ultimo hop di un circuito Tor che si collega direttamente ai siti web. I relay bridge sono relay non elencati che aiutano gli utenti che subiscono la censura di Internet a connettersi a Tor.

Le opzioni per il file \`torrc' sono riportate in [la pagina man](https://2019.www.torproject.org/docs/tor-manual.html.en). Qui descriviamo una configurazione di base per un relè di uscita e di ponte.

### Esecuzione di un relè di uscita

!!! warning

```
Se si intende gestire un relè di uscita, assicurarsi che il proprio ISP o società di hosting sia d'accordo. I reclami per abusi da parte degli exit relay sono molto comuni, in quanto si tratta dell'ultimo nodo di un circuito Tor che si connette direttamente ai siti web per conto degli utenti Tor. Per questo motivo, molti ISP e società di hosting non ammettono i relay di uscita Tor.

Se non siete sicuri che il vostro ISP permetta i relay di uscita Tor, consultate i termini di servizio o chiedete al vostro ISP. Se il vostro ISP dice di no, cercate un altro ISP o una società di hosting o prendete in considerazione un relay intermedio o un bridge.
```

Se si vuole eseguire un relè di uscita, è necessario aggiungere quanto segue al proprio `torrc`:

```bash
ExitRelay 1
```

Tuttavia, si utilizzerà il seguente criterio di uscita predefinito:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:119
ExitPolicy reject *:135-139
ExitPolicy reject *:445
ExitPolicy reject *:563
ExitPolicy reject *:1214
ExitPolicy reject *:4661-4666
ExitPolicy reject *:6346-6429
ExitPolicy reject *:6699
ExitPolicy reject *:6881-6999
ExitPolicy accept *:*
```

Questa exit policy blocca solo un piccolo sottoinsieme di porte TCP, consentendo l'abuso di BitTorrent e SSH, che molti ISP non vedono di buon occhio.

Se si vuole usare una [reduced exit policy](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/ReducedExitPolicy), la si può impostare nel `torrc`:

```bash
ReducedExitPolicy 1
```

È anche possibile avere un criterio di uscita più restrittivo, ad esempio consentire solo il traffico DNS, HTTP e HTTPS. Questo può essere impostato così:

```bash
ExitPolicy accept *:53
ExitPolicy accept *:80
ExitPolicy accept *:443
ExitPolicy reject *:*
```

Questi valori implicano che:

- Si consente il traffico in uscita alle porte TCP 53 (DNS), 80 (HTTP) e 443 (HTTPS) con le nostre linee `ExitPolicy accept`.
- Con le queste linee jolly `ExitPolicy reject`, non si permette il traffico in uscita verso qualsiasi altra porta TCP.

Se si desidera un criterio di uscita non restrittivo, bloccando solo il traffico SMTP, questo può essere impostato così:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:465
ExitPolicy reject *:587
ExitPolicy accpet *:*
```

Questi valori implicano che

- Con le linee `ExitPolicy reject` non è consentito il traffico in uscita verso le porte TCP SMTP standard 25, 465 e 587.
- Si consente il traffico di uscita a tutte le altre porte TCP nella linea jolly `ExitPolicy accept`.

È inoltre possibile consentire o bloccare un intervallo di porte come segue:

```bash
ExitPolicy accept *:80-81
ExitPolicy reject *:993-995
```

Questi valori implicano che:

- Si consente il traffico in uscita alle porte TCP 80-81
- Non è consentito il traffico in uscita verso le porte TCP 993-995, utilizzate per le varianti IMAP, IRC e POP3 protette da SSL.

È inoltre possibile consentire il traffico in uscita verso gli indirizzi IPv6, a condizione che il server disponga di connettività dual-stack:

```bash
IPv6Exit 1
```

### Esecuzione di un bridge obfs4

Le connessioni dirette a Tor sono bloccate in molte parti del mondo, tra cui Cina, Iran, Russia e Turkmenistan. In questi paesi, i bridge relay non elencati sono utilizzati dai client Tor.

Tor opera utilizzando un sistema di [pluggable transports](https://support.torproject.org/glossary/pluggable-transports/), che consente di mascherare il traffico Tor con altri protocolli, come il traffico fittizio non identificabile (obfs4), WebRTC (snowflake) o le connessioni HTTPS ai servizi Microsoft (meek).

Grazie alla sua versatilità, obfs4 è il pluggable transport più diffuso.

Per configurare un bridge obfs4, dato che obfs4 non è presente nei repo di EPEL, si deve compilarlo da zero. Installiamo prima i pacchetti necessari:

```bash
dnf install git golang policycoreutils-python-utils
```

Successivamente, scaricheremo ed estrarremo il codice sorgente di obfs4:

```bash
wget https://gitlab.com/yawning/obfs4/-/archive/obfs4proxy-0.0.14/obfs4-obfs4proxy-0.0.14.tar.bz2
tar jxvf obfs4-obfs4proxy-0.0.14.tar.bz2
cd obfs4-obfs4proxy-0.0.14/obfs4proxy/
```

È anche possibile ottenere obfs4 direttamente da `git clone`, ma questo dipende da una versione di Go più recente di quella presente in AppStream, quindi non la si userà.

Quindi, compileremo e installeremo obfs4:

```bash
go build
cp -a obfs4proxy /usr/local/bin/
```

Una volta installato obfs4, aggiungeremo quanto segue al nostro `torrc`:

```bash
ServerTransportPlugin obfs4 exec /usr/local/bin/obfs4proxy
ServerTransportListenAddr obfs4 0.0.0.0:12345
ExtORPort auto
```

Questi valori implicano che:

- Si sta eseguendo un trasporto inseribile obfs4 che si trova in `/usr/local/bin/obfs4proxy` sulla linea `ServerTransportPlugin`.
- `ServerTransportListenAddr` fa sì che il pluggable transport sia in ascolto sulla porta 12345.
- La linea `ExtORPort` ascolterà su una porta scelta a caso le connessioni tra Tor e il pluggable transport configurato. Normalmente, questa riga non deve essere modificata

Se si desidera ascoltare su un'altra porta TCP, cambiare `12345` con la porta TCP desiderata.

Inoltre, la porta TCP `12345` (o la porta scelta dall'utente) sarà consentita in SELinux e `firewalld`:

```bash
semanage port -a -t tor_port_t -p tcp 12345
firewall-cmd --zone=public --add-port=12345/tcp
firewall-cmd --runtime-to-permanent
```

## Eseguire replays multipli

Come già detto, è possibile impostare fino a 8 relay Tor per ogni indirizzo IP pubblico. Ad esempio, se si ha 5 indirizzi IP pubblici, si può impostare un massimo di 40 relè sul server impostato.

Tuttavia, si richiede un file di unità systemd personalizzato per ogni relè che si esegue.

Si aggiunga ora un file di unità systemd secondario a `/usr/lib/systemd/system/torX`:

```bash
[Unit]
Description=Anonymizing overlay network for TCP
After=syslog.target network.target nss-lookup.target
PartOf=tor-master.service
ReloadPropagatedFrom=tor-master.service

[Service]
Type=notify
NotifyAccess=all
ExecStartPre=/usr/bin/tor --runasdaemon 0 -f /etc/tor/torrcX --DataDirectory /var/lib/tor/X --DataDirectoryGroupReadable 1 --User toranon --verify-config
ExecStart=/usr/bin/tor --runasdaemon 0 -f /etc/tor/torrcX --DataDirectory /var/lib/tor/X --DataDirectoryGroupReadable 1 --User toranon
ExecReload=/bin/kill -HUP ${MAINPID}
KillSignal=SIGINT
TimeoutSec=30
Restart=on-failure
RestartSec=1
WatchdogSec=1m
LimitNOFILE=32768

# Hardening
PrivateTmp=yes
DeviceAllow=/dev/null rw
DeviceAllow=/dev/urandom r
ProtectHome=yes
ProtectSystem=full
ReadOnlyDirectories=/run
ReadOnlyDirectories=/var
ReadWriteDirectories=/run/tor
ReadWriteDirectories=/var/lib/tor
ReadWriteDirectories=/var/log/tor
CapabilityBoundingSet=CAP_SETUID CAP_SETGID CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH
PermissionsStartOnly=yes

[Install]
WantedBy = multi-user.target
```

Sostituire il suffisso `X` dopo `tor`/`torrc` con il nome desiderato. L'autore preferisce numerarlo per semplicità, ma può essere qualsiasi cosa.

Successivamente, si aggiungerà il file `torrc` dell'istanza in `/etc/tor/torrcX`. Assicurarsi che ogni istanza abbia una porta e/o un indirizzo IP separati.

Inoltre, si utilizzerà la porta TCP `12345` (o la porta in `torrcX`) in SELinux e `firewalld`:

```bash
semanage port -a -t tor_port_t -p tcp 12345
firewall-cmd --zone=public --add-port=12345/tcp
firewall-cmd --runtime-to-permanent
```

Successivamente, abilitare l'unità systemd `torX`:

```bash
systemctl enable --now torX
```

Ripetere questi passaggi per ogni relay che si desidera eseguire.

## Conclusione

A differenza di un servizio VPN convenzionale, Tor si avvale di relè gestiti da volontari per garantire la privacy e l'anonimato, che vengono appena impostati.

Sebbene il funzionamento di un relay Tor richieda un sistema affidabile e, per le uscite, un ISP di supporto, l'aggiunta di più relay aiuta la privacy e rende Tor più veloce con meno punti di guasto.
