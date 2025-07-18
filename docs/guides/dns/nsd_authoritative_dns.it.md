---
title: NSD DNS autoritativo
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Un'alternativa a BIND, [NSD](https://www.nlnetlabs.nl/projects/nsd/about/) (Name Server Daemon) è un moderno server DNS authoritative-only gestito da [NLnet Labs](https://www.nlnetlabs.nl/).

## Prerequisiti e presupposti

- Un server con Rocky Linux
- In grado di utilizzare `firewalld` per la creazione di regole firewall
- Un nome di dominio o un server DNS ricorsivo interno che punta al server DNS autoritativo.

## Introduzione

I server DNS esterni, o pubblici, mappano gli hostname in indirizzi IP e, nel caso dei record PTR (noti come “pointer” o “reverse”), mappano gli indirizzi IP in hostname. È una parte essenziale di Internet. Fa sì che il server di posta, il server web, il server FTP o molti altri server e servizi funzionino come previsto, indipendentemente da dove ci si trovi.

## Installazione e abilitazione di NSD

Per prima cosa, installare EPEL:

```bash
dnf install epel-release
```

Successivamente, installare NSD:

```bash
dnf install nsd
```

## Configurazione di NSD

Prima di apportare modifiche a qualsiasi file di configurazione, copiare il file originale installato e funzionante, `nsd.conf`:

```bash
cp /etc/nsd/nsd.conf /etc/nsd/nsd.conf.orig
```

Questo aiuterà in futuro se si verificano errori nel file di configurazione. È _sempre_ una buona idea fare una copia di backup prima di apportare modifiche.

Modificare il file _nsd.conf_. L'autore usa _vi_, ma si può sostituirlo con l'editor a riga di comando preferito:

```bash
vi /etc/nsd/nsd.conf
```

Andare in fondo al file e inserire quanto segue:

```bash
zone:
    name: example.com
    zonefile: /etc/nsd/example.com.zone
```

Sostituire `example.com` con il nome del dominio per il quale si gestisce un nameserver.

Quindi, creare i file di zona:

```bash
vi /etc/nsd/example.com.zone
```

I file DNS zone sono compatibili con BIND. Nel file, inserire:

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

Se avete bisogno di aiuto per personalizzare i file di zona in stile BIND, Oracle ha [una buona introduzione ai zone file](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Salvare le modifiche.

## Abilitare NSD

Quindi, consentire le porte DNS in `firewalld` e abilitare NSD:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now nsd
```

Verificare che il DNS riesca a risolvere l'host-name con il comando `host`:

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

## Server DNS secondario

La gestione di uno o più server DNS autoritativi secondari è generalmente la norma. Questo è particolarmente utile quando il server primario si guasta. La funzione NSD consente di sincronizzare i record DNS da un server primario a uno o più server di backup.

Per abilitare un server di backup, generare le chiavi di firma sulla zona primaria:

```bash
nsd-control-setup
```

È necessario copiare i seguenti file sul server di backup nella directory `/etc/nsd/`:

- `nsd_control.key`
- `nsd_control.pem`
- `nsd_server.key`
- `nsd_server.pem`

Su tutti i server DNS, aggiungere quanto segue prima della direttiva `zone:`:

```bash
remote-control:
        control-enable: yes
        control-interface: 0.0.0.0
        control-port: 8952
        server-key-file: "/etc/nsd/nsd_server.key"
        server-cert-file: "/etc/nsd/nsd_server.pem"
        control-key-file: "/etc/nsd/nsd_control.key"
        control-cert-file: "/etc/nsd/nsd_control.pem"
```

Inoltre, attivare le voci del firewall:

```bash
firewall-cmd --zone=public --add-port=8952/tcp
firewall-cmd --runtime-to-permanent
```

Sul server primario, modificare la zone in modo che corrisponda a quanto segue:

```bash
zone:
    name: example.com
    zonefile: /etc/nsd/example.com.zone
    allow-notify: NS2_IP NOKEY
    provide-xfr: NS2_IP NOKEY
    outgoing-interface: NS1_IP
```

Sostituire `NS1_IP1` e `NS2_IP2` con gli indirizzi IP pubblici dei nameserver primario e secondario.

Sul server secondario, aggiungere la zone:

```bash
zone:
    name: fourplex.net
    notify: NS1_IP NOKEY
    request-xfr: NS1_IP NOKEY
    outgoing-interface: NS2_IP
```

Sostituire `NS1_IP1` e `NS2_IP2` con gli indirizzi IP pubblici dei nameserver primario e secondario.

Riavviare NSD su entrambi i server dei nomi:

```bash
NS1# systemctl restart --now nsd
```

Per scaricare il file di zona sul nameserver secondario da quello primario:

```bash
nsd-control notify -s NS2_IP
```

Sostituire `NS2_IP2` con gli indirizzi IP pubblici del server dei nomi secondario.

## Conclusione

La maggior parte delle persone utilizza servizi DNS di terze parti. Tuttavia, ci sono scenari in cui è auspicabile un DNS self-hosting. Ad esempio, le società di telecomunicazioni, hosting e social media mantengono le proprie voci DNS quando i servizi DNS di terze parti sono indesiderati.

NSD è uno dei tanti strumenti open source che rendono possibile l'hosting DNS.
