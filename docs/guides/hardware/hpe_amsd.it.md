---
title: HPE ProLiant Agentless Management Service
author: Neel Chauhan
contributors: Ganna Zhyrnova
tested_with: 9.3
tags:
  - hardware
---

# HPE ProLiant Agentless Management Service

## Introduzione

I server HPE ProLiant dispongono di un software complementare denominato Agentless Management Service che, secondo HPE:

> utilizza la comunicazione fuori banda per una maggiore sicurezza e stabilità.

Inoltre:

> con Agentless Management, il monitoraggio dello stato di salute e gli avvisi sono integrati nel sistema e iniziano a funzionare nel momento in cui l'alimentazione ausiliaria viene collegata al server.

Questo viene utilizzato, ad esempio, per ridurre la velocità delle ventole su un HPE ProLiant ML110 Gen11 nel home lab dell'autore.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- Un server HP/HPE ProLiant Gen8 o più recente con iLO attivato e visibile sulla rete

## Installazione di `amsd`

Per installare `amsd`, è necessario prima installare EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti:

```bash
dnf -y install epel-release && dnf -y update
```

Aggiungere quindi quanto segue a `/etc/yum.repos.d/spp.repo`:

```bash

[spp]
name=Service Pack for ProLiant
baseurl=https://downloads.linux.hpe.com/repo/spp-gen11/redhat/9/x86_64/current
enabled=1
gpgcheck=1
gpgkey=https://downloads.linux.hpe.com/repo/spp/GPG-KEY-spp 
```

Sostituire `9` con la versione principale di Rocky Linux e `gen11` con la generazione del vostro server. Sebbene l'autore utilizzi un ML110 Gen11, se invece utilizzasse una DL360 Gen10, verrebbe utilizzato `gen10`.

Successivamente, installare e abilitare `amsd`:

```bash
dnf -y update && dnf -y install amsd
systemctl enable --now amsd
```

Per verificare se `amsd` funziona, accedere a iLO tramite il browser web. Se l'installazione è corretta, iLO dovrebbe segnalare che il nostro server sta eseguendo Rocky Linux:

![HPE iLO showing Rocky Linux 9.3](../images/hpe_ilo_amsd.png)

## Conclusione

Una critica comune ai server HPE è l'elevata velocità delle ventole quando si utilizzano componenti di terze parti, come le unità SSD o altre schede PCI Express aggiuntive non ufficialmente approvate da HPE (ad esempio, le schede di acquisizione video). Anche se si utilizzano solo componenti di marca HPE, l'uso di `amsd` consente ai server HPE ProLiant di funzionare in modo più efficiente e silenzioso rispetto al solo utilizzo di Rocky Linux.
