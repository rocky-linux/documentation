---
title: Creare una ISO Rocky Linux personalizzata
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.5
tags:
  - create
  - custom
  - ISO
---

## Introduction

Potrebbe essere necessario creare una ISO personalizzata per varie ragioni. Si potrebbe voler cambiare il processo di boot, aggiungere pacchetti specifici o aggiornare un file di configurazione.

Questa guida spiega come costruire la propria ISO di Rocky Linux dall'inizio alla fine.

## Prerequisites

- Una macchina 64-bit con Rocky Linux 9
- Un'immagine ISO DVD di Rocky Linux 9
- Un file `kickstart` da applicare alla ISO
- Leggere la documentazione Lorax [Quickstart](https://weldr.io/lorax/lorax.html#quickstart) e [mkksiso](https://weldr.io/lorax/mkksiso.html) per familiarizzare con la creazione di `Anaconda` `boot.iso`.

## Package installation and setup

- Install the `lorax` package:

```bash
sudo dnf install -y lorax
```

## Building the ISO with a kickstart file

- Eseguire il comando `mkksiso` per aggiungere un file `kickstart` e quindi creare una nuova ISO:

```bash
mkksiso --ks <0> <1> <2>
```

- Di seguito è riportato un esempio di file `kickstart`, ovvero `example-ks.cfg`, il quale imposta un ambiente `Server With GUI`  Rocky Linux 9.5:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
%end
```

## Adding a repository with its packages to an ISO image

- Make sure the repository you want to add has the `repodata` directory inside of it. Se così non è, è possibile crearla utilizzando il comando `createrepo_c`, è possibile installarlo con \`sudo dnf install -y createrepo_c
- Add the repository to your `kickstart` file, using the following syntax:

```bash

repo --name=extra-repo --baseurl=file:///run/install/repo/<0>/
```

- Add your repository using the `--add` flag with the `mkksiso` tool:

```bash
mkksiso --add <0> --ks <1> <2> <3>
```

- Si possono vedere dettagli aggiuntivi di questo processo utilizzando il repository  `baseos` nell'esempio a seguire.
- Il repository `base os` sarà scaricato localmente assieme a tutti i suoi pacchetti:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Successivamente aggiungere il repository al file `kickstart`:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Il file `kickstart` ha l'aspetto seguente:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
%end
```

- Then point the `mkksiso` command directly to the repository directory and build the ISO:

```bash
mkksiso --add ~/baseos --ks example-ks.cfg ~/Rocky-9.5-x86_64-dvd.iso ~/Rocky-9.5-x86_64-dvd-new.iso
```

## Conclusion

Qui condivido alcune opzioni per modificare e creare la vostra ISO Rocky Linux. Per ulteriori modi, tra cui la modifica degli argomenti della riga di comando del kernel, l'autore consiglia vivamente di consultare la documentazione di [mkksiso](https://weldr.io/lorax/mkksiso.html) in modo più dettagliato.
