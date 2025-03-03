---
title: Hurricane Electric IPv6 Tunnel
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.5
tags:
  - réseau
---

# Hurricane Electric IPv6 Tunnel

IPv6 n'a pas besoin d'être présenté, mais au cas où vous ne le sauriez pas, IPv6 est le remplacement du protocole IPv4 qui utilise des adresses hexadécimales 128 bits au lieu d'adresses décimales 32 bits.

[Hurricane Electric](https://he.net) est un fournisseur de services Internet. Entre autres services, Hurricane Electric gère le service gratuit [Tunnel Broker](https://tunnelbroker.net/) pour offrir une connectivité IPv6 derrière les réseaux uniquement IPv4.

## Introduction

En raison de l'épuisement des adresses IPv4, un besoin d'un espace d'adressage IP étendu est apparu sous la forme d'IPv6. Cependant, de nombreux réseaux ne prennent toujours pas en charge IPv6 en raison de l’omniprésence de la traduction d’adresses réseau (NAT). C'est pour cela qu'Hurricane Electric propose des tunnels IPv6.

## Prérequis

- Un [tunnel IPv6 gratuit de Hurricane Electric](https://tunnelbroker.net/)

- Un serveur Rocky Linux avec une adresse IP publique et un protocole de message de contrôle Internet non filtré (également connu sous le nom d'ICMP).

## Obtention d'un tunnel IPv6

Tout d’abord, créez un compte sur [tunnelbroker.net](https://tunnelbroker.net/).

Lorsque vous disposez d'un compte, sélectionnez **Create Regular Tunnel** dans la barre latérale **User Fonctions** :

![HE.net sidebar](../images/henet_1.png)

Saisissez ensuite votre adresse IPv4 publique, sélectionnez l’emplacement de votre point de terminaison et cliquez sur **Create Tunnel**.

## Mise en place d'un tunnel IPv6

La bonne nouvelle est qu’un tunnel IPv6 n’a besoin que d’une seule commande :

```bash
nmcli connect add type ip-tunnel ifname he-sit mode sit remote IPV4_SERVER ipv4.method disabled ipv6.method manual ipv6.address IPV6_CLIENT ipv6.gateway IPV6_SERVER
```

Remplacez les éléments suivants par les détails de votre portail Hurricane Electric :

- `IPV4_SERVER` avec l'**adresse IPv4 du serveur**
- `IPV6_SERVER` avec l'**adresse IPv6 du serveur**
- `IPV6_CLIENT` avec l'**adresse IPv6 du client**
