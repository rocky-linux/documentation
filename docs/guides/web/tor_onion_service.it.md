---
title: Servizio Tor Onion
author: Neel Chauhan
contributors: Ganna Zhrynova
tested_with: 9.3
tags:
  - web
  - proxy
  - proxies
---

!!! warning “Temporaneamente in Sospeso”

```
`tor` è attualmente assente dall'EPEL. Probabilmente verrà compilato. Il team Docs continuerà a testarne la disponibilità nell'EPEL non appena possibile. Per ora, l'unica opzione è compilare `tor` dal sorgente, ma le istruzioni per farlo non sono attualmente disponibili qui.
```

## Introduzione

[Tor](https://www.torproject.org/) è un servizio e un software di anonimato che instrada il traffico attraverso tre server gestiti da volontari e chiamati relay. Il design a tre hop serve a garantire la privacy resistendo ai tentativi di sorveglianza.

Una caratteristica di Tor è la possibilità di eseguire siti web nascosti, esclusivi di Tor, chiamati [onion services](https://community.torproject.org/onion-services/). Tutto il traffico verso un servizio onion è quindi privato e crittografato.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma è possibile sostituirli con il proprio editor preferito
- Un server web in esecuzione su localhost o su un'altra porta TCP/IP

## Installare Tor

Per installare Tor, è necessario prima installare EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti:

```bash
dnf -y install epel-release && dnf -y update
```

Quindi installare Tor:

```bash
dnf -y install tor
```

## Configurare Tor

Una volta installati i pacchetti, è necessario configurare Tor. L'autore usa `vi` per questo, ma se preferite `nano` o qualcos'altro, sostituitelo pure:

```bash
vi /etc/tor/torrc
```

Il file `torrc` predefinito è abbastanza descrittivo, ma può diventare lungo se si vuole solo un servizio onion. Una configurazione minima del servizio onion è simile a questa:

```bash
HiddenServiceDir /var/lib/tor/onion-site/
HiddenServicePort 80 127.0.0.1:80
```

### Osservare da più vicino

- "HiddenServiceDir" è la posizione del nome host e delle chiavi crittografiche del servizio onion. Le chiavi sono memorizzate in `/var/lib/tor/onion-site/`
- La "HiddenServicePort" è l'inoltro della porta dal server locale al servizio onion. Si sta inoltrando 127.0.0.1:80 alla porta 80 del nostro servizio Tor

!!! warning

```
Se si intende utilizzare una directory per le chiavi di firma del servizio onion al di fuori di `/var/lib/tor/`, è necessario assicurarsi che i permessi siano `0700` e che il proprietario sia `toranon:toranon`.
```

## Configurare un server web

Avrete anche bisogno di un server web sulla nostra macchina per servire i clienti del vostro servizio onion. È possibile utilizzare qualsiasi server web (Caddy, Apache o Nginx). L'autore preferisce Caddy. Per semplicità, installare Caddy:

```bash
dnf -y install caddy
```

Quindi, si inserisce quanto segue in `/etc/caddy/Caddyfile`:

```bash
http:// {
    root * /usr/share/caddy
    file_server
}
```

## Test e avvio

Una volta impostata la configurazione del relay Tor, il passo successivo è quello di attivare i demoni Tor e Caddy:

```bash
systemctl enable --now tor caddy
```

È possibile ottenere il nome host del servizio onion con questo comando:

```bash
cat /var/lib/tor/onion-site/hostname
```

Entro pochi minuti, il vostro servizio onion si propagherà attraverso la rete Tor e potrete visualizzare il vostro nuovo servizio onion nel browser Tor:

![Tor Browser showing our Onion Service](../images/onion_service.png)

## Conclusione

I servizi onion sono uno strumento prezioso se si ospita un sito web privatamente o se si ha bisogno di bypassare il Carrier Grade NAT del proprio ISP utilizzando solo software open source.

Sebbene i servizi onion non siano veloci come l'hosting diretto di un sito web (comprensibile a causa del design di Tor orientato alla privacy), sono molto più sicuri e privati rispetto all'Internet pubblico.
