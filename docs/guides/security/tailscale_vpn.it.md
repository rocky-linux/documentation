---
title: Tailscale VPN
author: Neel Chauhan
contributors: Steven Spencer, Franco Colussi
tested_with: 9.3
tags:
  - security
  - VPN
---

# Tailscale VPN

## Introduzione

[Tailscale](https://tailscale.com/) è una VPN peer-to-peer a configurazione zero, con crittografia end-to-end, basata su Wireguard. Tailscale supporta tutti i principali sistemi operativi desktop e mobili.

Rispetto ad altre soluzioni VPN, Tailscale non richiede porte TCP/IP aperte e può funzionare dietro al Network Address Translation o ad un firewall.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Un account Tailscale

## Installare Tailscale

Per installare Tailscale, è necessario aggiungere il repository `dnf` (nota: se si utilizza Rocky Linux 8.x, sostituire con 8):

```bash
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
```

Quindi, installare Tailscale:

```bash
dnf install tailscale
```

## Configurare Tailscale

Una volta installati i pacchetti, è necessario abilitare e configurare Tailscale. Per abilitare il daemon Tailscale:

```bash
systemctl enable --now tailscaled
```

Successivamente, ci si autenticherà con Tailscale:

```bash
tailscale up
```

Si otterrà un URL per l'autenticazione. Visitatelo in un browser e accedete a Tailscale:

![Schermata d'accesso di Tailscale](../images/tailscale_1.png)

Successivamente, si concederà l'accesso al server. Cliccare su **Connect** per farlo:

![Finestra di dialogo per la concessione dell'accesso a Tailscale](../images/tailscale_2.png)

Una volta autorizzato l'accesso, verrà visualizzata una finestra di dialogo di successo:

![Finestra di dialogo di accesso a Tailscale](../images/tailscale_3.png)

Una volta che il vostro server è stato autenticato con Tailscale, otterrà un indirizzo IPv4 Tailscale:

```bash
tailscale ip -4
```

Inoltre, otterrà un indirizzo IPv6 RFC 4193 (Unique Local Address) di Tailscale:

```bash
tailscale ip -6
```

## Conclusione

I servizi VPN tradizionali che utilizzano un gateway VPN sono centralizzati. Ciò richiede una configurazione manuale, l'impostazione del firewall e l'assegnazione di account utente. Tailscale risolve questo problema grazie al suo modello peer-to-peer combinato con un controllo degli accessi a livello di rete.
