---
title: "Router OpenBGPD BGP "
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.3
tags:
  - network
---

# Router OpenBGPD BGP

## Introduzione

Il Border Gateway Protocol (BGP) è il protocollo di routing che tiene insieme Internet. È il modo in cui è possibile visualizzare questo documento indipendentemente dal provider di servizi Internet.

[OpenBGPD](http://openbgpd.org/) è l'implementazione BGP multipiattaforma di [OpenBSD](https://www.openbsd.org/). L'autore lo utilizza personalmente sulla propria rete.

## Prerequisiti

- Un server, una macchina virtuale o una rete di laboratorio con connettività BGP
- Un numero AS dal [Regional Internet Registry](https://www.nro.net/about/rirs/)
- Un blocco IPv4 o IPv6 di proprietà o noleggiato
- Conoscenze nell'amministrazione di rete

## Installarezione dei package

Poiché OpenBGPD non è presente nei repository predefiniti, installare prima il repository EPEL (Extra Packages for Enterprise Linux):

```bash
dnf install -y epel-release
```

Successivamente, installare OpenBGPD:

```bash
dnf install -y openbgpd
```

## Configurazione di OpenBGPD

Iniziamo con una nuova configurazione di OpenBGPD:

```bash
rm /etc/bgpd.conf
touch /etc/bgpd.conf
chmod 0600 /etc/bgpd.conf
```

Quindi, aggiungere quanto segue a `/etc/bgpd.conf`:

```bash
AS YOUR_ASN
router-id YOUR_IPV4

listen on 127.0.0.1
listen on YOUR_IPV4
listen on ::1
listen on YOUR_IPV6
log updates
network IPV4_TO_ADVERTISE/MASK
network IPV6_TO_ADVERTISE/MASK

allow to ebgp prefix { IPV4_TO_ADVERTISE/MASK IPV6_TO_ADVERTISE/MASK }

neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
}
```

Sostituire i seguenti parametri:

- **YOUR_ASN** con il vostro numero AS.
- **YOUR_IPV4** con l'indirizzo IPv4 del vostro server.
- **YOUR_IPV6** con l'indirizzo IPv6 del vostro server.
- **PEER_ASN** con il numero AS del vostro ISP a monte.
- **PEER_IPV4** con l'indirizzo IPv4 del vostro ISP
- **PEER_IPV6** con l'indirizzo IPv6 del vostro ISP upstream.

Le righe precedenti significano quanto segue:

- La riga `AS` contiene il numero AS del BGP.
- La riga `router-id` contiene l'ID del router BGP. Si tratta di un indirizzo IPv4, ma può essere un indirizzo fittizio non instradabile (ad esempio 169.254.x.x) se si utilizza un BGP solo IPv6.
- La riga `listen on` indica quali interfacce ascoltare. Dovremmo ascoltare tutte le interfacce che parlano di BGP.
- Le righe `network` aggiungono le reti che vogliamo pubblicizzare.
- La riga `allow to ebgp prefix` aggiunge la conformità [RFC8212](https://datatracker.ietf.org/doc/html/rfc8212) per la sicurezza del routing. Alcune società di hosting, come BuyVM, lo richiedono.
- I blocchi `neighbor` specificano ogni peer IPv4 e IPv6.
- La riga `remote-as` specifica il numero AS dell'upstream.
- La riga `announce IPv4` specifica se annunciare le rotte IPv4 `unicast` o `none`. Dovrebbe essere `none` su un upstream IPv6.
- La riga `announce IPv6` specifica se annunciare le rotte IPv6 `unicast` o `none`. Dovrebbe essere `none` su un upstream IPv4.
- La riga `local-address` è l'indirizzo IPv4 o IPv6 dell'upstream.

Alcuni upstream possono utilizzare una password MD5 o BGP multihop. In questo caso, i blocchi \`neighbor' avranno l'aspetto seguente:

```bash
neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
    multihop                2
    local-address           203.0.113.123
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
    multihop                2
    local-address           2001:DB8:1000::1
}
```

È necessario abilitare l'inoltro IP impostando i valori di `sysctl`:

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Ora è necessario abilitare OpenBGPD e l'inoltro:

```bash
sysctl -p /etc/sysctl.conf
systemctl enable --now bgpd
```

## Controllo dello stato di BGP

Una volta abilitato OpenBGPD, è possibile vedere lo stato di BGP:

```bash
bgpctl show
```

Verrà visualizzato il risultato:

```bash
Neighbor                   AS    MsgRcvd    MsgSent  OutQ Up/Down  State/PrfRcvd
BGP_PEER             PEER_ASN       164         68     0 00:32:04      0
```

È anche possibile vedere le rotte pubblicizzate da BGP:

```bash
bgpctl show rib
```

Se funziona correttamente, si dovrebbe vedere la tabella di routing BGP:

```bash
flags: * = Valid, > = Selected, I = via IBGP, A = Announced,
       S = Stale, E = Error
origin validation state: N = not-found, V = valid, ! = invalid
aspa validation state: ? = unknown, V = valid, ! = invalid
origin: i = IGP, e = EGP, ? = Incomplete

flags  vs destination          gateway          lpref   med aspath origin
AI*>  N-? YOUR_IPV4/24         0.0.0.0           100     0 i
AI*>  N-? YOUR_IPV6::/48       ::                100     0 i
```

## Conclusione

Anche se inizialmente il BGP può sembrare scoraggiante, una volta acquisita la padronanza, è possibile ottenere una parte della tabella di routing di Internet. La semplicità di OpenBGPD rende ancora più facile avere un router software o un server anycast. Divertitevi!
