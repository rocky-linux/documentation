---
title: Appendice A - Configurazione Workstation
author: Spencer Steven
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - workstation
---

# Appendice A - Configurazione Workstation

Anche se non fa parte dei capitoli per un server Incus, questa procedura aiuterà coloro che desiderano avere un ambiente di prova o un sistema operativo e un'applicazione semi-permanente in esecuzione su una workstation o un laptop Rocky Linux.

## Prerequisiti

- a proprio agio alla riga di comando
- essere in grado di utilizzare fluentemente un editor a riga di comando, come `vi` o \`nano
- necessità di un ambiente di test stabile da utilizzare quotidianamente o secondo necessità
- essere in grado di accedere come root o di avere privilegi `sudo`

## Installazione

Dalla riga di comando, installare il repository EPEL:

```bash
sudo dnf install epel-release -y
```

Al termine dell'installazione, eseguire un aggiornamento:

```bash
sudo dnf upgrade
```

Installare le altre repositories:

```bash
sudo dnf config-manager --enable crb
sudo dnf copr enable neil/incus
```

Installare pacchetti necessari:

```bash
sudo dnf install dkms vim kernel-devel bash-completion
```

Installare e abilitare Incus:

```bash
sudo dnf install incus incus-tools
sudo systemctl enable incus
```

Riavviare il notebook o la workstation prima di continuare.

## Inizializzazione di Incus

Se avete letto i capitoli sul server di produzione, questa procedura è quasi identica a quella di inizializzazione del server di produzione.

```bash
sudo incus admin init
```

Si aprirà una finestra di dialogo a domande e risposte.

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

```text
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: storage
```

Facoltativamente, è possibile accettare l'impostazione predefinita.

```text
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Si noti che `dir` è un po' più lento di `zfs`. Se si può lasciare un disco vuoto, si può usare quel dispositivo (ad esempio: /dev/sdb) per il dispositivo `zfs` e poi selezionare `zfs`.

```text
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

È possibile attivare questa opzione se si desidera utilizzare IPv6 sui propri container Incus.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Questa operazione è necessaria per eseguire lo snapshot della workstation. Rispondere "sì" in questo caso.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Questa trust password è il modo in cui ci si connette o si torna indietro dal server snapshot. Impostatela con qualcosa che abbia senso nel vostro ambiente. Salvare questa voce in un luogo sicuro, ad esempio in un gestore di password.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Privilegi dell'utente

La prossima cosa da fare è aggiungere il proprio utente al gruppo `incus-admin`. Anche in questo caso, è necessario utilizzare `sudo` o essere root:

```text
sudo usermod -a -G incus-admin [username]
```

Dove [username] è l'utente del sistema.

## Impostazione dei valori `subuid` e `subgid` per `root`

È necessario impostare sia il valore del `subuid` che del `subgid` dell'utente root (l'intervallo di ID degli utenti e dei gruppi subordinati). I parametri dovrebbero essere:

```bash
root:1000000:1000000000
```

Per farlo, modificare `/etc/subuid` e aggiungere questa riga. Quando completo, il file dovrebbe essere:

```bash
root:1000000:1000000000
```

Aggiungere nuovamente questa riga al file `/etc/subgid`. Il file avrà un aspetto simile a questo:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

A questo punto saranno state apportate una serie di modifiche. Quindi prima di procedere oltre, riavviare il computer.

## Verifica dell'installazione

Per assicurarsi che `incus` sia stato avviato e che il vostro utente abbia i privilegi, dal prompt della shell eseguire:

```text
incus list
```

Si noti che qui non è stato usato `sudo`. L'utente può inserire questi comandi. Vedrete qualcosa di simile a questo:

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

Se lo fate, avete un bell'aspetto!

## Il resto

A questo punto, è possibile utilizzare i capitoli del nostro “Incus Production Server” per continuare. Ci sono alcuni aspetti della configurazione di una workstation a cui è necessario prestare meno attenzione. Ecco i capitoli consigliati per iniziare:

- [Capitolo 5 - Impostazione e gestione delle immagini](05-incus_images.md)
- [Capitolo 6 - Profili](06-profiles.md)
- [Capitolo 8 - Container Snapshots](08-snapshots.md)

## Ulteriori informazioni

- [Panoramica e documentazione ufficiale di Incus](https://linuxcontainers.org/incus/docs/main/)

## Conclusione

Incus è un potente strumento per aumentare la produttività di workstation e server. È ottimo per i test di prova su una workstation e può anche mantenere istanze semi-permanenti di sistemi operativi e applicazioni disponibili nel loro spazio privato.
