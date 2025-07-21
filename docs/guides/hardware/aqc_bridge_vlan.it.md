---
title: Abilitare VLAN Passthrough su Marvell AQC-series NIC
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.6
tags:
  - hardware
---

## Introduzione

L'autore utilizza una NIC (network inteface card) basata su Marvell AQC107 sul proprio server, che ha una macchina virtuale utilizzata per un firewall virtualizzato. Purtroppo, il driver stock Rocky Linux Marvell AQC esclude le VLAN dalle interfacce bridge. Questo è ciò che è successo alla macchina virtuale OPNsense dell'autore. Fortunatamente è risolvibile.

## Prerequisiti e presupposti

A seguire i requisiti minimi per seguire questa procedura:

- Un server Rocky Linux con una scheda NIC Marvell serie AQC
- Utilizzo di NetworkManager per configurare la rete

## Disabilitazione dei filtri su VLAN

È possibile disattivare il filtraggio VLAN con un solo comando:

    nmcli con modify enp1s0 ethtool.feature-rx-vlan-filter off

Sostituire `enp1s0` con il nome della NIC basata su AQC.

Infine, è necessario riavviare il sistema.
