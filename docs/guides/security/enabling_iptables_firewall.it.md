---
title: Abilitazione del Firewall `iptables`
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - iptables
  - deprecated
---

# Abilitazione del Firewall iptables

## Prerequisiti

* Un ardente, inestinguibile desiderio di disabilitare l'applicazione di default _firewalld_ e abilitare _iptables_.

!!! warning "Questo Processo È Deprecato"

    A partire da Rocky Linux 9.0, `iptables` e tutte le utilità ad esso associate sono deprecate. Ciò significa che le future versioni del sistema operativo rimuoveranno `iptables`. Per questo motivo, si consiglia vivamente di non utilizzare questo processo. Se hai familiarità con iptables, ti consigliamo di utilizzare [`iptables` Guida A `firewalld`](firewalld.md). Se sei nuovo ai concetti del firewall, ti consigliamo [`firewalld` per Principianti](firewalld-beginners.md).

## Introduzione

_firewalld_ è ora il firewall predefinito su Rocky Linux. _firewalld_ **era** nient'altro che un'applicazione dinamica di _iptables_ che utilizzando i file xml caricava le modifiche senza il flushing delle regole in CentOS 7/RHEL 7.  Con CentOS 8/RHEL 8/Rocky 8, _firewalld_ è ora un wrapper intorno a _nftables_. È ancora possibile, tuttavia, installare e utilizzare direttamente _iptables_ se questa è la tua preferenza. Per installare ed eseguire direttamente _iptables_ senza _firewalld_ puoi farlo seguendo questa guida. Ciò che questa guida **non** ti dirà è come scrivere le regole per _iptables_. Si presume che se vuoi sbarazzarti di _firewalld_, devi già sapere come scrivere regole per _iptables_.

## Disabilitare firewalld

Non è possibile eseguire la vecchia utility _iptables_ accanto a _firewalld_. Semplicemente non sono compatibili. Il modo migliore per ovviare a questo problema è quello di disabilitare completamente _firewalld_ (non è necessario disinstallarlo a meno che non lo si voglia fare) e reinstallare le utility _iptables_. Disabilitare _firewalld_ può essere fatto utilizzando questi comandi:

Arrestare _firewalld_:

`systemctl stop firewalld`

Disabilitare _firewalld_ in modo che non parta all'avvio:

`systemctl disable firewalld`

Mascherare il servizio in modo che non possa essere trovato:

`systemctl mask firewalld`

## Installazione e Abilitazione dei Servizi iptables

Successivamente, è necessario installare i vecchi servizi e utilità _iptables_. Ciò è fatto con quanto segue:

`dnf install iptables-services iptables-utils`

Questo installerà tutto ciò che è necessario per eseguire una regola _iptables_ impostata.

Ora abbiamo bisogno di abilitare il servizio _iptables_ per assicurarsi che parta all'avvio:

`systemctl enable iptables`

## Conclusione

È possibile ritornare a utilizzare _iptables_ se lo si preferisce al posto di _firewalld_. Puoi tornare a usare il _firewalld_ predefinito semplicemente invertendo queste modifiche.
