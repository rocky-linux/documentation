---
title: Abilitazione del Firewall `iptables`
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested*with: 8.5, 8.6, 9.0
tags:
  - security
  - iptables
  - deprecated
---

# Abilitazione del Firewall iptables

## Prerequisiti

- Un desiderio ardente e inestinguibile di disabilitare l'applicazione predefinita *firewalld* e abilitare *iptables*.

!!! warning "Questo Processo È Deprecato"

    A partire da Rocky Linux 9.0, `iptables` e tutte le utilità ad esso associate sono deprecate. Ciò significa che le future versioni del sistema operativo rimuoveranno `iptables`. Per questo motivo, si consiglia vivamente di non utilizzare questo processo. Se hai familiarità con iptables, ti consigliamo di utilizzare [`iptables` Guida A `firewalld`](firewalld.md). Se sei nuovo ai concetti del firewall, ti consigliamo [`firewalld` per Principianti](firewalld-beginners.md).

## Introduzione

*firewalld* è ora il firewall predefinito su Rocky Linux. *firewalld* non **era** altro che un'applicazione dinamica di *iptables* che utilizzava file xml e che caricava le modifiche senza eseguire il flussaggio delle regole in CentOS 7/RHEL 7.  Con CentOS 8/RHEL 8/Rocky 8, *firewalld* è ora un wrapper attorno a *nftables*. È comunque possibile installare e utilizzare direttamente <em x-id=“3”>iptables</em>, se lo si preferisce. Per installare ed eseguire *iptables* senza *firewalld* è possibile seguire questa guida. Questa guida **non** spiega come scrivere le regole per *iptables*. Si presume che se ci si vuole sbarazzare di *firewalld*, si deve già sapere come scrivere le regole per *iptables*.

## Disabilitare firewalld

Non è possibile eseguire la vecchia utility *iptables* insieme a *firewalld*. Semplicemente non sono compatibili. Il modo migliore per ovviare a questo problema è disabilitare completamente *firewalld* (non è necessario disinstallarlo, a meno che non lo si voglia fare) e reinstallare le utility *iptables*. La disabilitazione di *firewalld* può essere eseguita con questi comandi:

Arrestare *firewalld*:

`systemctl stop firewalld`

Disabilitare *firewalld* in modo che non si avvii all'avvio:

`systemctl disable firewalld`

Mascherare il servizio in modo che non possa essere trovato:

`systemctl mask firewalld`

## Installazione e Abilitazione dei Servizi iptables

Successivamente, è necessario installare i vecchi servizi e utilità di *iptables*. Ciò è fatto con quanto segue:

`dnf install iptables-services iptables-utils`

Questo installerà tutto ciò che è necessario per eseguire un set di regole *iptables*.

Ora dobbiamo abilitare il servizio *iptables* per assicurarci che si avvii all'avvio:

`systemctl enable iptables`

## Conclusione

Se preferisci, puoi tornare a utilizzare direttamente <em x-id=“3”>iptables</em> invece di <em x-id=“3”>firewalld</em>. È possibile tornare a utilizzare il *firewalld* predefinito semplicemente invertendo queste modifiche.
