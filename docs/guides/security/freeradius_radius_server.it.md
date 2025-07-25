---
title: RADIUS Server FreeRADIUS
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - security
---

# FreeRADIUS 802.1X Server

## Introduzione

RADIUS è un protocollo AAA (autenticazione, autorizzazione e registrazione) per la gestione dell'accesso alla rete. [FreeRADIUS](https://www.freeradius.org/) è il server RADIUS di fatto per Linux e altri sistemi Unix-like.

## Prerequisiti

I requisiti minimi per questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Un client RADIUS, ad esempio un router, uno switch o un punto di accesso Wi-Fi

## Installazione di FreeRADIUS

È possibile installare FreeRADIUS dai repository `dnf`:

```bash
dnf install -y freeradius
```

## Configurazione di FreeRADIUS

Una volta installati i pacchetti, è necessario generare i certificati di crittografia TLS per FreeRADIUS:

```bash
cd /etc/raddb/certs
./bootstrap
```

Successivamente, sarà necessario aggiungere gli utenti da autenticare. Aprire il file `users`:

```bash
cd ..
vi users
```

Nel file, inserire quanto segue:

```bash
user    Cleartext-Password := "password"
```

Sostituire `user` e `password` con il nome utente e la password desiderati.

Sappiate che la password non è sottoposta a hash, quindi se un malintenzionato entra in possesso del file `users` potrebbe ottenere un accesso non autorizzato alla vostra rete protetta.

È anche possibile utilizzare una password con hash `MD5` o `Crypt`. Per generare una password con hash MD5, eseguire:

```bash
echo -n password | md5sum | awk '{print $1}'
```

Sostituire `password` con la password desiderata.

Si otterrà un hash di `5f4dcc3b5aa765d61d8327deb882cf99`. Nel file `users`, inserire invece quanto segue:

```bash
user    MD5-Password := "5f4dcc3b5aa765d61d8327deb882cf99"
```

È inoltre necessario definire i client. Questo per evitare accessi non autorizzati al nostro server RADIUS. Modificare il file `clients.conf`:

```bash
vi clients.conf
```

Inserire quanto segue:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Sostituire `172.20.0.254` e `secret123` con l'indirizzo IP e il valore segreto che utilizzeranno i client. Ripetere l'operazione per altri client.

## Abilitazione di FreeRADIUS

Dopo la configurazione iniziale, è possibile avviare `radiusd`:

```bash
systemctl enable --now radiusd
```

## Configurazione di RADIUS su uno switch

Dopo aver configurato il server FreeRADIUS, si configura un client RADIUS sullo switch MikroTik dell'autore come client 802.1X cablato:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Sostituire `172.20.0.12` con l'indirizzo IP del server FreeRADIUS e `secret123` con il codice segreto impostato in precedenza.
