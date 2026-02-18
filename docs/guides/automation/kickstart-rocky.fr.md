---
title: Les fichiers Kickstart et Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 10, 9, 8
tags:
  - fichier
  - install
  - kickstart
  - linux
  - rocky
---

# Les fichiers Kickstart et Rocky Linux

**Connaissances** : :star: :star:  
**Temps de lecture** : 15 minutes

## Introduction

Les fichiers Kickstart sont un outil indispensable pour installer et configurer Rocky Linux sur une ou plusieurs machines à la fois. Vous pouvez les utiliser pour tout mettre en œuvre rapidement, que ce soit votre ordinateur de jeu préféré ou bien dans le cadre d'un déploiement de centaines de machines dans une entreprise. Ils permettent d'économiser le temps et les efforts qui seraient nécessaires pour configurer chaque machine l'une après l'autre.

À la fin de cet article, vous comprendrez comment les fichiers `kickstart` fonctionnent, comment créer et appliquer votre propre fichier `kickstart` à une ISO Rocky Linux et vous serez en mesure de provisionner votre propre machine.

## Qu'est-ce qu'une configuration Kickstart ?

Les fichiers Kickstart sont un ensemble de fichiers de configuration que les utilisateurs peuvent utiliser pour déployer rapidement et facilement une distribution Linux. Les fichiers Kickstart fonctionnent non seulement sur Rocky Linux mais également sur CentOS Stream, Fedora et de nombreuses autres distributions.

## Comment les configurations Kickstart sont appliquées à une ISO ?

En utilisant la commande `mkkiso`, un fichier Kickstart est copié dans le répertoire `root` d'une ISO Linux. À partir de là, `mkkiso` édite le fichier `/isolinux/isolinux.cfg` et place le fichier `kickstart` à cet endroit en tant que paramètre cmdline (`inst.ks`) :

```bash
sudo mount -o ro,loop rocky-linux10-dvd-shadow.iso /mnt/
cat /mnt/EFI/BOOT/grub.cfg | grep shadow | head -1
linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-10-1-x86_64-dvd quiet inst.ks=hd:LABEL=Rocky-10-1-x86_64-dvd:/rocky_linux10_shadow.ks
```

Ceci fait, `mkkiso` produit une nouvelle ISO avec la configuration `kickstart` à l'intérieur. Lorsque l'ISO démarre, `anaconda` exécute les instructions listées dans le fichier `kickstart`.

## Prérequis

- Optionnel - pour déployer votre ISO `kickstart` grâce à un serveur PXE référez-vous au guide [Comment configurer un serveur PXE sur Rocky Linux 9.x](https://kb.ciq.com/article/rocky-linux/rl-pxe-boot-kickstart-file) afin d'en apprendre plus.

- Une clé USB type 3.0+ pour l'installation via USB.

- Une image ISO minimale de Rocky Linux 8, 9 ou 10 téléchargée depuis https://rockylinux.org/download (l'ISO DVD n'est pas nécessaire).

- Suivez le guide [Création d'image ISO Rocky Linux perso](https://docs.rockylinux.org/10/guides/isos/iso_creation/) afin d'installer le paquet `lorax` et d'apprendre comment générer une ISO Rocky Linux `kickstart`.

## Exemples

\=== "10"

    ````
    ```
    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$0oXug1vTr7TO3kJu$/kvm.lctWsLDHaeak/YuUaEu26LzvNuE1L/tvUC4G91ZroChjDTUDwQDEkQfGhwQw4doiDcZc2P6et.zzRqOZ/ --allow-ssh
    user --name howard --password $6$8wzUW5ipTdTs.MbM$1F6mPfqQAXPeSVArqT2r/GL6QljXs2dQWCcNGjQq5cpEPGWhNvOCAiVCDJRA0FZQpoTXJSBtNON2ZqvEMBUNX/ --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/'
    bootloader --location=boot --append="ro crashkernel=2G-64G:256M,64G-:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=nvme0n1
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=480000
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp4s0 --hostname=shadow --bootproto=static --ip=192.168.1.102 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end
    
    %post
    mkdir -p /mnt/storage1
    mkdir -p /mnt/storage2
    mkfs.xfs /dev/nvme0n1
    mkfs.xfs /dev/sda
    sync
    udevadm settle
    sleep 2
    UUID_NVME0N1=$(blkid -s UUID -o value /dev/nvme0n1)
    UUID_SDA=$(blkid -s UUID -o value /dev/sda)
    if [ -n "$UUID_NVME0N1" ]; then
        echo "UUID=$UUID_NVME0N1 /mnt/storage1 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    if [ -n "$UUID_SDA" ]; then
        echo "UUID=$UUID_SDA /mnt/storage2 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    mount -U $UUID_NVME0N1 /mnt/storage1
    mount -U $UUID_SDA /mnt/storage2
    chown -R howard:howard /mnt/storage1
    chown -R howard:howard /mnt/storage2
    %end
    ```
    ````

\=== "9"

    ````
    ```
    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$IjIs0nEufTOaj2cZ$EnZKdrjHQ9OmhePUMVWUcaJmmC0vU2L.b02lBMKmRMLq/VZOhnrgBO64ru29rFnB8HQsGo0cQLqBoLIpL7PbS1 --allow-ssh
    user --name howard --groups wheel --password $6$OdZuQb9owvkol5gv$6X7w0VraE7hDSrrHS5oz9BvNACB.PcrNt5Ulka9/g1Sgxdzl93LAuGT3GH8a.4ZUpqzchKU3glgRyCWXhSN68. --iscrypted
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/'
    bootloader --location=boot --append="crashkernel=1G-4G:192M,4G-64G:256M,64G:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=sda
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=120012
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp2s0 --hostname=mighty --bootproto=static --ip=192.168.1.104 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end
    ```
    ````

\=== "8"

    ````
    ```
    lang en_GB
    keyboard jp106
    timezone Asia/Tokyo --utc
    rootpw <ROOT_PASSWORD_HERE> --iscrypted
    user --name=howard --password=<USER_PASSWORD_HERE> --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/'
    bootloader --append="rhgb quiet crashkernel=auto"
    zerombr
    clearpart --all --initlabel
    autopart
    network --device=enp1s0 --hostname=rocky-linux8-slurm-controller-node --bootproto=static --ip=192.168.1.120 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end 
    ```
    ````

**Les éléments importants sont détaillés ci-dessous avec une attention particulière sur un fichier `kickstart` pour Rocky Linux 10. Les différences entre fichiers `kickstart`y seront aussi mentionnées :**

### Détail du fichier kickstart pour Rocky Linux 10

#### rootpw

!!! warning

    Utilisez toujours l'option `--iscrypted` pour le mot de passe root afin d'être sûr qu'il ne soit pas affiché en clair.

Pour générer un hashage du mot de passe que vous souhaitez, utilisez la commande `openssl` suivante et saisissez le mot de passe lorsque demandé :

```bash
openssl passwd -6
```

Pour permettre l'accès par `ssh` au compte `root`, ajoutez l'option `--allow-ssh` à la ligne `rootpw`.

#### user

De la même façon, utilisez l'option `--iscrypted` pour vous assurez que vos mots de passe ne sont pas affichés en clair.

Si vous souhaitez que votre utilisateur soit administrateur, ajoutez-le au groupe `wheel` avec l'option `--groups=wheel`

#### URL

Utiliser l'option `cdrom` avec `ignoredisk` pose problème : Anaconda ne peut pas accéder au support USB et reste bloqué durant la configuration du stockage. Utilisez `url --url` contourne le problème en téléchargeant l'installation depuis `BaseOS`.

#### Bootloader

Définit l'emplacement du chargeur de démarrage et ajoute au noyau les paramètres cmdline nécessaires.

#### Zerombr

S'assure de la destruction des tables de partitions ou autres options de formatage qu'Anaconda ne reconnaît par sur le disque choisi.

#### Clearpart

Efface toutes les partitions sur le disque cible et définit l'étiquette du disque à `gpt`.

#### Ignoredisk

Si `ignoredisk` n'est pas spécifié, `anaconda` aura accès à tous les disques du système. Si cette option est spécifiée, `anaconda` utilisera uniquement le disque choisi par l'utilisateur.

#### Part

`part` permet à l'utilisateur d'indiquer les partitions qu'il souhaite créer. L'exemple ci-dessus présente une configuration avec `/boot`, `/boot/efi` et LVM (Logical Volume Management). C'est ce que vous obtenez lorsque vous faites une installation automatisée de Rocky Linux.

#### Volgroup

`volgroup` crée le groupe LVM. Cet exemple montre le choix du nom de groupe `rl` et d'une taille de Physical Extents (`pesize`) de `4096 KiB`.

#### Logvol

Crée les volumes logiques au sein du groupe LVM. Il convient de noter l'usage de l'option `--grow` pour le volume `/home` permettant de s'assurer que la totalité de l'espace du groupe LVM est utilisé.

#### Network

C'est ici que vous pouvez choisir de définir statiquement ou dynamiquement votre configuration réseau.

#### Skipx

Arrête la configuration du serveur X sur le système.

#### Firstboot

Dans le cas présent, nous définissons le drapeau `--disable`qui empêche Setup Agent de démarrer au démarrage du système.

#### Firewall

Permettre l'accès `ssh` dans le pare-feu avec l'option `--ssh` est important afin que vous puissiez vous connecter à votre machine dans le cas où l'accès en console n'est pas disponible.

#### %packages

Liste les paquets que vous souhaitez installer. Dans cet exemple, le groupe de paquets `@^server-product-environment` est candidat à l'installation. Ce groupe installe tous les paquets nécessaires à un serveur Rocky Linux stable.

De plus, vous pouvez aussi sélectionner individuellement les paquets à installer, exclure l'installation de certains paquets et plus encore.

#### %post

Vous pouvez lister ici les tâches supplémentaires qui seront réalisées après l'installation du système d'exploitation. Dans notre exemple, l'auteur configure et monte les espaces de stockage supplémentaires disponibles sur son système.

D'autres options sont également disponibles, telles que `%pre`, `%pre-install`, `%onerror`, et `%traceback`. Vous pourrez en apprendre plus sur ces options dans les références fournies à la fin de ce document.

### Différences entre les fichiers kickstart de Rocky Linux

Rocky Linux 9 et 10 définissent la disposition du clavier de la façon suivante (exemple avec un clavier Japonais) :

```
keyboard --xlayouts='jp'
```

Cependant, Rocky Linux 8 définit la disposition de clavier comme suit :

```
keyboard jp106
```

Pour l'accès par `ssh` au compte `root`, le fichier `kickstart` de Rocky Linux 8 n'a **pas** besoin que le drapeau `--allow-ssh` soit ajouté .

Le paramètre de ligne de commande du noyau `crashkernel` diffère entre les trois versions de Rocky Linux. Veuillez en tenir compte lors du paramétrage.

Dans l'exemple de fichier `kickstart` Rocky Linux 8 (et cela s'applique à toutes les versions de Rocky Linux), si vous souhaitez partitionner automatiquement votre disque, utilisez simplement l'option `autopart`.

## Conclusion

Si vous voulez automatiser vos installations de Rocky Linux les fichiers `kickstart` sont la méthode à choisir. Ce guide n'est que la partie émergée de l'iceberg de ce que vous pouvez accomplir avec des fichiers `kickstart`. Pour obtenir plus d'informations sur toutes les options `kickstart` existantes avec leurs exemples, référez-vous à la documentation `kickstart` de Chris Lumens et de l'équipe de l'installateur Anaconda^2^.

Pour celles et ceux d'entre vous qui souhaitent aller plus loin dans l'automatisation du déploiement de machines virtuelles et approfondir leur connaissance de `kickstart`, Antoine Le Morvan a rédigé un excellent guide^1^ sur la façon d'y parvenir avec `packer`.

L'équipe Rocky Linux Release Engineering dispose également de multiples exemples de fichier `kickstart` disponible dans le dépôt Rocky Linux^4^.

Enfin, si vous avez accès à un compte Red Hat, il existe un générateur Kickstart fourni par Red Hat vous permettant de créer rapidement et facilement des fichiers `kickstart` à l'aide d'une interface.

## Références

1. "Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment" par Antoine Le Morvan [https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/](https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/)
2. "Extensive kickstart documentation" par Chris Lumens et l'équipe de l'installateur Anaconda [https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
3. "Red Hat Kickstart Generator (nécessite un compte Red Hat)" fourni par Red Hat [https://access.redhat.com/labsinfo/kickstartconfig](https://access.redhat.com/labsinfo/kickstartconfig)
4. "Rocky Linux Kickstart Repository" par l'équipe Rocky Linux Release Engineering [https://github.com/rocky-linux/kickstarts/tree/main](https://github.com/rocky-linux/kickstarts/tree/main)
   Footer

