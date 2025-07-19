---
title: accel-ppp PPPoE Server
author: Neel Chauhan
contributors:
tested_with: 9.3
tags:
  - network
---

# accel-ppp PPPoE Server

## Introduzione

Il PPPoE è un protocollo utilizzato principalmente dagli ISP DSL e fiber-to-the-home in cui i clienti vengono autenticati con una combinazione di nome utente e password. Il PPPoE è utilizzato nei Paesi in cui un ISP storico deve condividere la propria rete con altri ISP, in quanto i clienti possono essere indirizzati all'ISP desiderato tramite un nome di dominio.

[accel-ppp](https://accel-ppp.org/) è un'implementazione accelerata del kernel Linux di PPPoE e dei protocolli correlati come PPTP, L2TP e altri.

## Prerequisiti

- Un server con due interfacce di rete
- Un router o un computer client che utilizza il protocollo PPPoE

## Installare accel-ppp

Per prima cosa installare EPEL:

```bash
dnf install -y epel-release
```

Successivamente, installare accel-ppp:

```bash
dnf install -y accel-ppp
```

## Impostare accel-ppp

Per prima cosa, dobbiamo abilitare il forwarding IP:

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

Quindi, aggiungere quanto segue a `/etc/accel-ppp.conf`:

```bash
[modules]
log_file
pppoe
auth_mschap_v2
auth_mschap_v1
auth_chap_md5
auth_pap
chap-secrets
ippool

[core]
log-error=/var/log/accel-ppp/core.log
thread-count=4

[ppp]
ipv4=require

[pppoe]
interface=YOUR_INTERFACE

[dns]
dns1=YOUR_DNS1
dns2=YOUR_DNS2

[ip-pool]
gw-ip-address=YOUR_GW
YOUR_IP_RANGE

[chap-secrets]
gw-ip-address=YOUR_GW
chap-secrets=/etc/chap-secrets
```

Cambiare le seguenti impostazioni:

- **YOUR_INTERFACE** con l'interfaccia in ascolto per i client PPPoE.
- **YOUR_DNS1** e **YOUR_DNS2** con i server DNS da distribuire ai client.
- **YOUR_GW** è l'indirizzo IP del server per i client PPPoE. Questo **deve** essere diverso dall'indirizzo IP del server rivolto alla WAN o dal gateway predefinito.
- **YOUR_IP_RANGE** con gli intervalli IP da distribuire ai clienti. Può essere un intervallo IP come X.X.X.Y-Z o in formato CDIR come X.X.X.X/MASK.

Successivamente, aggiungiamo un file “barebones” `/etc/chap-secrets`:

```bash
user	*	password	*
```

È possibile aggiungere altri utenti con altre righe, sostituendo `user` e `password` con il nome utente e la password desiderati.

## Configurazione di un client PPPoE

Una volta configurato il server PPPoE, si può iniziare ad aggiungere i client PPPoE. All'autore piace usare [MikroTik CHR](https://help.mikrotik.com/docs/display/ROS/Cloud+Hosted+Router%2C+CHR) come client PPPoE di prova, quindi useremo quello.

Una volta installato MikroTik CHR su un sistema collegato alla stessa rete Ethernet dell'interfaccia di ascolto del server PPPoE, configureremo PPPoE:

```bash
[admin@MikroTik] > /interface pppoe-client
[admin@MikroTik] > add add-default-route=yes disabled=no interface=ether1 name=pppoe-out1 \
    password=password user=user
```

Se tutto funziona correttamente, dovremmo ottenere un indirizzo IPv4:

```bash
[admin@MikroTik] > /ip/address/print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE
#   ADDRESS      NETWORK   INTERFACE 
0 D 10.0.0.1/32  10.0.0.0  pppoe-out1
```

## Conclusione

Il PPPoE viene spesso malvisto ed è facile capire perché: è necessario configurare manualmente nomi utente e password. Ciononostante, consente di garantire la sicurezza quando ci si connette a un dominio di broadcast Layer 2 in scenari ISP in cui la richiesta di 802.1X o MACsec non sarebbe auspicabile, ad esempio per consentire l'utilizzo di router di proprietà del cliente o di indirizzi IP statici. E ora avete il vostro mini-ISP, congratulazioni!
