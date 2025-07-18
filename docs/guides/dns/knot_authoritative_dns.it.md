---
title: Knot Authoritative DNS
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Un'alternativa a BIND, [Knot DNS](https://www.knot-dns.cz/), è un moderno server DNS autoritativo gestito dal registry dei domini ceco [CZ.NIC](https://www.nic.cz/).

## Prerequisiti e presupposti

- Un server con Rocky Linux
- In grado di utilizzare _firewalld_ per la creazione di regole firewall
- Un nome di dominio o un server DNS ricorsivo interno che punta al server DNS autoritativo.

## Introduzione

I server DNS esterni, o pubblici, mappano gli hostname in indirizzi IP e, nel caso dei record PTR (noti come “pointer” o “reverse”), mappano gli indirizzi IP in hostname. È una parte essenziale di Internet. Fa sì che il server di posta, il server web, il server FTP o molti altri server e servizi funzionino come previsto, indipendentemente da dove ci si trovi.

## Installazione e abilitazione di Knot

Per prima cosa, installare EPEL:

```bash
dnf install epel-release
```

Quindi, installare Knot:

```bash
dnf install knot
```

## Configurazione di `Knot`

Prima di apportare modifiche a qualsiasi file di configurazione, spostare il file originale installato e funzionante, `knot.conf`:

```bash
mv /etc/knot/knot.conf /etc/knot/knot.conf.orig
```

Questo aiuterà in futuro se si verificano errori nel file di configurazione. È _sempre_ una buona idea fare una copia di backup prima di apportare modifiche.

Modificare il file _knot.conf_. L'autore usa _vi_, ma potete sostituirlo con il vostro editor a riga di comando preferito:

```bash
vi /etc/knot/knot.conf
```

Inserire quanto segue:

```bash
server:
    listen: 0.0.0.0@53
    listen: ::@53

zone:
  - domain: example.com
    storage: /var/lib/knot/zones
    file: example.com.zone

log:
  - target: syslog
    any: info
```

Sostituire `example.com` con il nome del dominio per il quale si gestisce un nameserver.

Quindi, creare i file di zona:

```bash
mkdir /var/lib/knot/zones
vi /var/lib/knot/zones/example.com.zone
```

I file di zona DNS sono compatibili con BIND. Nel file, inserire:

```bash
$TTL    86400 ; How long should records last?
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com. ; Define our domain name
@  1D  IN  SOA ns1.example.com. hostmaster.example.com. (
                              2024061301 ; serial
                              3h ; refresh duration
                              15 ; retry duration
                              1w ; expiry duration
                              3h ; nxdomain error ttl
                             )
       IN  NS     ns1.example.com. ; in the domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  A      172.20.0.100 ; default A record
; server host definitions
ns1    IN  A      172.20.0.100 ; name server definition     
www    IN  A      172.20.0.101 ; web server definition
mail   IN  A      172.20.0.102 ; mail server definition
```

Se avete bisogno di aiuto per personalizzare i file di zona in stile BIND, Oracle ha [una buona introduzione ai file di zona](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Salvare le modifiche.

## Abilitare Knot

Quindi, consentire le porte DNS in `firewalld` e abilitare Knot DNS:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now knot
```

Verificare la risoluzione DNS con il comando `host`:

```bash
% host example.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases: 

example.com has address 172.20.0.100
example.com mail is handled by 10 mail.another.com.
%
```

## Conclusione

Sebbene la maggior parte delle persone utilizzi servizi di terze parti per il DNS, ci sono scenari in cui si desidera un DNS self-hosting. Ad esempio, le società di telecomunicazioni, hosting e social media ospitano molte voci DNS in cui i servizi ospitati sono indesiderati.

Knot è uno dei tanti strumenti open-source che rendono possibile l'hosting DNS. Congratulazioni, avete il vostro server DNS personale!
