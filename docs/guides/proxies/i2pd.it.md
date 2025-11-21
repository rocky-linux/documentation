---
title: i2pd Anonymous Network
author: Neel Chauhan
contributors: Steven Spencer
tags:
  - proxy
  - proxies
---

## Introduzione

[I2P](https://geti2p.net/en/) è una anonymous overlay network, concorrente della più popolare rete Tor, che si concentra sui siti web nascosti chiamati eepsites. [`i2pd`](https://i2pd.website/) (I2P Daemon) è un'implementazione lightweight in C++ del protocollo I2P.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- Un indirizzo IPv4 o IPv6 pubblico, direttamente sul server, con port forwarding o UPnP/NAT-PMP.

## Installazione di `i2pd`

Per installare `i2pd`, è necessario prima installare i repository EPEL (Extra Packages for Enterprise Linux) e `i2pd` copr (Cool Other Package Repo):

```bash
curl -s https://copr.fedorainfracloud.org/coprs/supervillain/i2pd/repo/epel-10/supervillain-i2pd-epel-10.repo -o /etc/yum.repos.d/i2pd-epel-10.repo
dnf install -y epel-release
```

Quindi installare `i2pd`:

```bash
dnf install -y i2pd
```

## Configurare `i2pd` (opzionale)

Una volta installati i pacchetti, è possibile configurare `i2pd` se necessario. L'autore usa `vim` per questo esempio, ma è possibilie usare qualsiasi altro editor come`nano`:

```bash
vim /etc/i2pd/i2pd.conf
```

Il file \`i2pd.conf' predefinito è abbastanza descrittivo, ma può diventare lungo, se si vuole solo una configurazione di base, lo si può lasciare così com'è.

Tuttavia, se si desidera abilitare IPv6 e UPnP e impostare la porta proxy HTTP in ascolto su `12345`, ecco una configurazione che lo consente:

```bash
ipv6 = true
[httpproxy]
port = 12345
[upnp]
enabled = true
```

Se si desidera impostare altre opzioni, il file di configurazione è autoesplicativo su tutte le opzioni possibili.

## Abilitare `i2pd`

E' possibile ora abilitare `i2pd`

```bash
systemctl enable --now i2pd
```

## Visitare i siti web I2P

Questo esempio utilizza Firefox su Rocky Linux. Se non utilizzi Firefox, consulta la documentazione della tua applicazione per impostare un proxy HTTP.

Aprire Firefox, fare clic sull'icona del menu ad hamburger e andare su **Impostazioni**:

![Firefox menu dropdown](../images/i2p_proxy_ff_1.png)

Spostarsi su **Network Settings** e quindi premere **Settings**

![Firefox Network Settings section](../images/i2p_proxy_ff_2.png)

Selezionare quindi **Manual proxy connection** , inserire `localhost` e `4444` (o la porta selezionata), selezionare **Also use this proxy for HTTPS** e selezionare **OK**.

![Firefox Connection Settings dialog](../images/i2p_proxy_ff_3.png)

Ora è possibile consultare i siti web I2P. Ad esempio, si vada su `http://planet.i2p` (Nota: il `http://` è importante per impedire a Firefox di impostare un motore di ricerca predefinito):

![Firefox viewing planet.i2p](../images/i2p_proxy_ff_4.png)

## Conclusione

Con tanti utenti di Internet preoccupati per la privacy online, I2P è l'unico modo per accedere ai siti web nascosti in modo sicuro. `i2pd` è un software leggero che consente di navigare sui siti web I2P e di condividere la propria connessione come relay.
