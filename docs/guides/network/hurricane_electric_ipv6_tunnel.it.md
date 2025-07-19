---
title: Hurricane Electric IPv6 Tunnel
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.5
tags:
  - network
---

# Hurricane Electric IPv6 tunnel

L'IPv6 non ha bisogno di presentazioni, ma per chi non lo sapesse sostituisce il più diffuso protocollo IPv4, che utilizza indirizzi esadecimali a 128 bit anziché decimali a 32 bit.

[Hurricane Electric](https://he.net) è un internet service provider. Tra le diverse funzioni, Hurricane Electric utilizza il servizio gratuito [Tunnel Broker](https://tunnelbroker.net/) per fornire connettività IPv6 sulle reti solo IPv4.

## Introduzione

A causa dell'esaurimento dell'IPv4, è nata l'esigenza di uno spazio di indirizzamento IP ampliato sotto forma di IPv6. Tuttavia, molte reti non supportano ancora l'IPv6 a causa dell'ubiquità della Network Address Translation (NAT). Per questo motivo, Hurricane Electric offre la gestione del tunnel IPv6.

## Prerequisiti

- Un [tunnel Hurricane Electric IPv6 gratuito](https://tunnelbroker.net/)

- Un server Rocky Linux con un indirizzo IP pubblico e un protocollo ICMP (Internet Control Message Protocol) non filtrato.

## Ottenere un tunnel IPv6

Per prima cosa, create un account su [tunnelbroker.net](https://tunnelbroker.net/).

Quando si dispone di un account, selezionare **Create Regular Tunnel** nella barra laterale **User Functions**:

![HE.net sidebar](../images/henet_1.png)

Quindi inserire l'indirizzo IPv4 pubblico, selezionare la posizione dell'endpoint e fare clic su **Create Tunnel**.

## Impostazione del IPv6 tunnel

La buona notizia è che un tunnel IPv6 necessita di un solo comando:

```bash
nmcli connect add type ip-tunnel ifname he-sit mode sit remote IPV4_SERVER ipv4.method disabled ipv6.method manual ipv6.address IPV6_CLIENT ipv6.gateway IPV6_SERVER
```

Sostituire quanto segue con i dati del portale Hurricane Electric:

- `IPV4_SERVER` con l'**indirizzo IPv4 del server**.
- `IPV6_SERVER` con l'**indirizzo IPv6 del server**.
- `IPV6_CLIENT` con l'**indirizzo IPv6 del client**.
