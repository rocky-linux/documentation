---
title: VPN WireGuard
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - security
  - vpn
---

## Introduzione

[WireGuard](https://www.wireguard.com/) è una rete privata virtuale (VPN) peer-to-peer (P2P) gratuita e open-source. È un'alternativa moderna, leggera e sicura alle VPN convenzionali con grandi basi di codice che si basano su connessioni TCP. Poiché WireGuard è una VPN P2P, ogni computer aggiunto alla rete WireGuard comunica direttamente con gli altri. Questa guida utilizza un modello hub-spoke, con un peer WireGuard a cui viene assegnato un indirizzo IP pubblico come gateway per il passaggio di tutto il traffico. Ciò consente al traffico WireGuard di bypassare Carrier Grade NAT (CGNAT) senza abilitare il port-forwarding sul router. Ciò richiede un sistema Rocky Linux con un indirizzo IP pubblico. Il modo più semplice per raggiungere questo obiettivo è quello di creare un server privato virtuale (VPS) attraverso un provider cloud di vostra scelta. Al momento in cui scriviamo, Google Cloud Platform offre un livello gratuito per le sue istanze e2-micro.

## Prerequisiti

I requisiti minimi per questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Un sistema Rocky Linux con un indirizzo IP accessibile pubblicamente

## Installazione di WireGuard

Installare i pacchetti extra per Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

Aggiornare i pacchetti di sistema:

```bash
sudo dnf upgrade -y
```

Installare WireGuard:

```bash
sudo dnf install wireguard-tools -y
```

## Configurazione di server WireGuard

Creare una cartella in cui inserire i file di configurazione e le chiavi di WireGuard:

```bash
sudo mkdir -p /etc/wireguard
```

Creare un file di configurazione con un nome a scelta che termini con l'estensione `.conf`:

!!! Note

```
È possibile creare più tunnel VPN WireGuard sullo stesso computer, ognuno dei quali utilizza un file di configurazione, un indirizzo di rete e una porta UDP diversi.
```

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generare una nuova coppia di chiavi private e pubbliche per il server WireGuard:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Modificare il file di configurazione con l'editor preferito.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Incollare quanto segue:

```bash
[Interface]
PrivateKey = server_privatekey
Address = x.x.x.x/24
ListenPort = 51820
```

È necessario sostituire `server_privatekey` con la chiave privata generata in precedenza. È possibile visualizzare la chiave privata con:

```bash
sudo cat /etc/wireguard/wg0
```

Successivamente, è necessario sostituire `x.x.x.x/24` con un indirizzo di rete compreso nell'intervallo di indirizzi IP privati definito da [RFC 1918] (https://datatracker.ietf.org/doc/html/rfc1918). L'indirizzo di rete utilizzato in questa guida è `10.255.255.0/24`.

Infine, è possibile scegliere qualsiasi porta UDP per accettare le connessioni con WireGuard VPN. Per gli scopi di questa guida si utilizza la porta UDP `51820`.

## Abilita l'inoltro IP

L'inoltro IP consente l'instradamento dei pacchetti tra le reti. Ciò consente ai dispositivi interni di comunicare tra loro attraverso il tunnel WireGuard:

Attivare l'inoltro IP per IPv4 e IPv6:

```bash
sudo sysctl -w net.ipv4.ip_forward=1 && sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

## Configurazione di `firewalld`

Installazione di `firewalld`:

```bash
sudo dnf install firewalld -y
```

Dopo aver installato `firewalld`, abilitarlo:

```bash
sudo systemctl enable --now firewalld
```

Creare una regola permanente del firewall che consenta il traffico sulla porta UDP 51820 nella zona pubblica:

```bash
sudo firewall-cmd --permanent --zone=public --add-port=51820/udp
```

Successivamente, il traffico dall'interfaccia WireGuard sarà consentito ad altre interfacce della zona interna.

```bash
sudo firewall-cmd --permanent --add-interface=wg0 --zone=internal
```

Aggiungere una regola del firewall per abilitare il masquerading IP sul traffico interno. Ciò significa che i pacchetti inviati tra peer sostituiranno l'indirizzo IP del pacchetto con l'indirizzo IP del server:

```bash
sudo firewall-cmd --permanent --zone=internal --add-masquerade
```

Infine, ricaricare `firewalld`:

```bash
sudo firewall-cmd --reload
```

## Configurazione del peer WireGuard

Poiché tutti i computer di una rete WireGuard sono tecnicamente dei peer, questa procedura è quasi identica alla configurazione del server WireGuard, ma con leggere differenze.

Creare una cartella in cui inserire i file di configurazione e le chiavi di WireGuard:

```bash
sudo mkdir -p /etc/wireguard
```

Creare un file di configurazione, dandogli un nome a scelta, che termini con l'estensione `.conf`:

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generare una nuova coppia di chiavi private e pubbliche:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Modificare il file di configurazione con il proprio editor, aggiungendo questo contenuto:

```bash
[Interface]
PrivateKey = peer_privatekey
Address = 10.255.255.2/24

[Peer]
PublicKey = server_publickey
AllowedIPs = 10.255.255.1/24
Endpoint = serverip:51820
PersistentKeepalive = 25
```

Sostituire `peer_privatekey` con la chiave privata del peer memorizzata in `/etc/wireguard/wg0` sul peer.

È possibile utilizzare questo comando per visualizzare la chiave in modo da poterla copiare:

```bash
sudo cat /etc/wireguard/wg0
```

Sostituire `server_publickey` con la chiave pubblica del server memorizzata in `/etc/wireguard/wg0.pub` sul server.

È possibile utilizzare questo comando per visualizzare la chiave in modo da poterla copiare:

```bash
sudo cat /etc/wireguard/wg0.pub
```

Sostituire `serverip` con l'IP pubblico del server WireGuard.

È possibile trovare l'indirizzo IP pubblico del server utilizzando il seguente comando sul server:

```bash
ip a | grep inet
```

Il file di configurazione del peer ora include una regola `PersistentKeepalive = 25`. Questa regola indica al peer di eseguire il ping del server WireGuard ogni 25 secondi per mantenere la connessione del tunnel VPN. Senza questa impostazione, il tunnel VPN si interrompe dopo l'inattività.

## Abilitare WireGuard VPN

Per abilitare WireGuard, eseguire il seguente comando sia sul server che sul peer:

```bash
sudo systemctl enable wg-quick@wg0
```

Avviare quindi la VPN eseguendo questo comando sia sul server che sul peer:

```bash
sudo systemctl start wg-quick@wg0
```

## Aggiungere la chiave client alla configurazione del server WireGuard

Emettere la chiave pubblica del peer e copiarla:

```bash
sudo cat /etc/wireguard/wg0.pub
```

Sul server, eseguire il comando seguente, sostituendo `peer_publickey` con la chiave pubblica del peer:

```bash
sudo wg set wg0 peer peer_publickey allowed-ips 10.255.255.2
```

L'uso di `wg set` apporta solo modifiche temporanee all'interfaccia di WireGuard. Per le modifiche permanenti della configurazione, è possibile modificare manualmente il file di configurazione e aggiungere il peer. È necessario ricaricare l'interfaccia WireGuard dopo aver apportato qualsiasi modifica permanente alla configurazione.

Modificare il file di configurazione del server con l'editor preferito.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Aggiungere il peer al file di configurazione. Il contenuto dovrebbe essere simile a quello riportato di seguito:

```bash
[Interface]
PrivateKey = +Eo5oVjt+d3XWvFWYcOChaLroGj5vapdXKH8UZ2T2Fc=
Address = 10.255.255.1/24
ListenPort = 51820

[Peer]
PublicKey = 1vSho8NvECkG1PVVk7avZWDmrd2VGZ2xTPaNe5+XKSg=
AllowedIps = 10.255.255.2/32
```

Disattivare l'interfaccia:

```bash
sudo wg-quick down wg0
```

Attivare l'interfaccia:

```bash
sudo wg-quick up wg0
```

## Visualizzazione delle interfacce WireGuard e test della connettività

È possibile visualizzare le informazioni di WireGuard sia sul server che sul peer:

```bash
sudo wg
```

È possibile verificare la connettività inviando un ping al server dal peer:

```bash
ping 10.255.255.1
```

## Conclusione

Seguendo questa guida, si è riusciti a configurare una VPN WireGuard utilizzando il modello hub-spoke. Questa configurazione offre un modo sicuro, moderno ed efficiente per collegare più dispositivi attraverso Internet. Controllare il [sito web ufficiale di WireGuard](https://www.wireguard.com/).
