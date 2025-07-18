---
title: DNS ricorsivo Unbound
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Un'alternativa a BIND, [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) è un moderno server DNS di convalida, ricorsivo e di caching gestito da [NLnet Labs](https://www.nlnetlabs.nl/).

## Prerequisiti e presupposti

- Un server con Rocky Linux
- In grado di utilizzare `firewalld` per la creazione di regole firewall

## Introduzione

Esistono due tipi di server DNS: autoritario e ricorsivo. Laddove i server DNS autoritativi pubblicizzano una zona DNS, i server ricorsivi risolvono le query per conto dei client inoltrandole a un ISP o a un resolver DNS pubblico o alle zone radice dei server più grandi.

Ad esempio, il router di casa probabilmente esegue un resolver DNS ricorsivo incorporato che inoltra al vostro ISP o a un noto server DNS pubblico, che è anche un server DNS ricorsivo.

## Installazione e abilitazione di Unbound

Installare Unbound:

```bash
dnf install unbound
```

## Configurazione di Unbound

Prima di apportare modifiche a qualsiasi file di configurazione, spostare il file originale installato e funzionante, `unbound.conf`:

```bash
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.orig
```

Questo aiuterà in futuro se si verificano errori nel file di configurazione. È _sempre_ una buona idea fare una copia di backup prima di apportare modifiche.

Modificare il file _unbound.conf_. L'autore usa _vi_, ma potete sostituirlo con l'editor a riga di comando preferito:

```bash
vi /etc/unbound/unbound.conf
```

Inserire quanto segue:

```bash
server:
    interface: 0.0.0.0
    interface: ::
    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8::/64 allow
    chroot: ""

forward-zone:
    name: "."
    forward-addr: 1.0.0.1@53
    forward-addr: 1.1.1.1@53
```

Sostituire `192.168.0.0/16` e `2001:db8::/64` con le sottoreti per le quali si risolvono le query DNS. Salvare le modifiche.

### Osservare da più vicino

- L'opzione `interface` indica le interfacce (IPv4 o IPv6) su cui si desidera ascoltare le query DNS. Siamo in ascolto su tutte le interfacce con `0.0.0.0` e `::`.
- L'opzione `access-control` indica le sottoreti (IPv4 o IPv6) da cui si desidera consentire le query DNS. Sono consentite richieste da `192.168.0.0/16` e `2001:db8::/64`.
- Il `forward-addr` definisce i server a cui effettuare l'inoltro. Stiamo inoltrando a `1.1.1.1` e `1.0.0.1` di Cloudflare.

## Abilitare Unbound

Quindi, aprire le porte DNS in `firewalld` e abilitare Unbound:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now unbound
```

Verificare la risoluzione DNS con il comando `host`:

```bash
$ host google.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases:

google.com has address 142.251.215.238
google.com has IPv6 address 2607:f8b0:400a:805::200e
google.com mail is handled by 10 smtp.google.com.
```

%

## Conclusione

La maggior parte delle persone utilizza il resolver DNS del router di casa o i resolver DNS pubblici gestiti da ISP e aziende tecnologiche. Nei laboratori domestici e nelle reti di grandi dimensioni, è consuetudine eseguire un resolver a livello di rete per ridurre la latenza e il carico di rete mettendo in cache le richieste DNS per i siti web comunemente richiesti, come Google. Un resolver a livello di rete consente anche di utilizzare servizi intranet come SharePoint e Active Directory.

Unbound è uno dei tanti strumenti open-source che rendono possibile la risoluzione dei DNS. Congratulazioni, avete il vostro resolver DNS personale!
