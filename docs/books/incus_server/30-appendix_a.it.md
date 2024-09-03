---
title: Appendice A - Configurazione Workstation
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - workstation
---

# Appendice A - Configurazione Workstation

Anche se non fa parte dei capitoli per un server LXD, questa procedura aiuterà coloro che vogliono avere un ambiente di laboratorio, o un sistema operativo e un'applicazione semi-permanente, in esecuzione su una workstation o un notebook Rocky Linux.

## Prerequisiti

* a proprio agio alla riga di comando
* in grado di utilizzare correntemente un editor a riga di comando, come `vi` o `nano`
* disposti a installare `snapd` per installare LXD
* necessità di un ambiente di test stabile da utilizzare quotidianamente o secondo necessità
* in grado di diventare root o di avere privilegi `sudo`

## Installazione

Dalla riga di comando, installare il repository EPEL:

```bash
sudo dnf install epel-release 
```

Al termine dell'installazione, eseguire l'aggiornamento:

```bash
sudo dnf upgrade
```

Installare `snapd`

```bash
sudo dnf install snapd 
```

Abilitare il servizio `snapd`

```bash
sudo systemctl enable snapd
```

Riavviare il notebook o la workstation

Installare lo snap per LXD:

```bash
sudo snap install lxd
```

## Inizializzazione di LXD

Se avete letto i capitoli sul server di produzione, questa procedura è quasi identica alla procedura di avvio del server di produzione.

```bash
sudo lxd init
```

Si aprirà una finestra di dialogo con domande e risposte.

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

```text
Would you like to use LXD clustering? (yes/no) [default=no]:
```

Se siete interessati al clustering, fate ulteriori ricerche su [Linux container qui](https://linuxcontainers.org/lxd/docs/master/clustering/).

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]: storage
```

Facoltativamente, è possibile accettare l'impostazione predefinita.

```text
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Si noti che `dir` è leggermente più lento di `btrfs`. Se si ha l'accortezza di lasciare un disco vuoto, si può usare quel dispositivo (ad esempio: /dev/sdb) per il dispositivo `btrfs` e poi selezionare `btrfs`, ma solo se il computer host ha un sistema operativo che supporta `btrfs`. Rocky Linux e qualsiasi clone di RHEL non supporteranno `btrfs` - non ancora, comunque. la `dir` funzionerà bene in un ambiente di laboratorio.

```text
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Se si desidera utilizzare IPv6 sui propri contenitori LXD, è possibile attivare questa opzione. Questo dipende da voi.

```text
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

Questa operazione è necessaria per eseguire lo snapshot della workstation. Rispondere "sì" in questo caso.

```text
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

Questa password di fiducia è il modo in cui ci si connette al server snapshot o si torna indietro dal server snapshot. Impostate qualcosa che abbia senso nel vostro ambiente. Salvare questa voce in un luogo sicuro, ad esempio in un gestore di password.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## Privilegi dell'utente

La prossima cosa da fare è aggiungere l'utente al gruppo lxd. Anche in questo caso, è necessario usare `sudo` o essere root:

```text
sudo usermod -a -G lxd [username]
```

dove [username] è l'utente del sistema.

A questo punto, sono state apportate diverse modifiche. Prima di proseguire, riavviare il computer.

## Verifica dell'installazione

Per assicurarsi che `lxd` sia stato avviato e che il vostro utente abbia i privilegi, dal prompt della shell fate:

```text
lxc list
```

Si noti che qui non è stato usato `sudo`. L'utente ha la possibilità di inserire questi comandi. Vedrete qualcosa di simile a questo:

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

Se lo fate, avete un bell'aspetto!

## Il resto

Da questo punto, si possono facilmente utilizzare i capitoli del nostro "LXD Production Server" per proseguire. Tuttavia, ci sono alcuni aspetti della configurazione di una workstation a cui dobbiamo prestare meno attenzione. Ecco i capitoli consigliati per iniziare:

* [Capitolo 5 - Impostazione e gestione delle immagini](05-lxd_images.md)
* [Capitolo 6 - Profili](06-profiles.md)
* [Chapter 8 - Container Snapshots](08-snapshots.md)

## Ulteriori informazioni

* [Guida per principianti di LXD](../../guides/containers/lxd_web_servers.md) che vi permetterà di iniziare a usare LXD in modo produttivo.
* [Panoramica e documentazione ufficiale di LXD](https://documentation.ubuntu.com/lxd/en/latest/)

## Conclusione

LXD è uno strumento potente che può essere utilizzato su workstation o server per aumentare la produttività. Su una workstation, è ottimo per i test di laboratorio, ma può anche mantenere snapshot semi-permanenti di sistemi operativi e applicazioni disponibili nel loro spazio privato.
