---
title: Kickstart-Dateien und Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 10, 9, 8
tags:
  - file
  - install
  - kickstart
  - linux
  - rocky
---

# Kickstart-Dateien und Rocky Linux

**Knowledge**: :star: :star:  
**Reading time**: 15 minutes

## Einleitung

Kickstart-Dateien sind ein unverzichtbares Werkzeug, um Rocky Linux gleichzeitig auf einem oder mehreren Rechnern zu installieren und zu konfigurieren. Sie können damit schnell alles einrichten, von Ihrer bevorzugten Gaming-Workstation bis hin zur Bereitstellung von Hunderten von Maschinen in einem Unternehmen. Sie sparen dadurch stundenlange Zeit und Mühe, da sie nicht jede Maschine einzeln manuell konfigurieren müssen.

Am Ende dieses Artikels werden Sie verstehen, wie `kickstart`-Dateien funktionieren, wie Sie Ihre eigene `kickstart`-Datei erstellen und auf ein Rocky Linux ISO anwenden und anschließend Ihre eigene Maschine bereitstellen können.

## Was sind Kickstart-Konfigurationen?

Kickstart-Dateien sind eine Reihe von Konfigurationen, die vom Benutzer implementiert werden, um eine Linux-Distribution schnell und einfach bereitzustellen. Kickstart-Dateien funktionieren nicht nur unter Rocky Linux, sondern auch unter CentOS Stream, Fedora und vielen anderen Distributionen.

## Wie werden Kickstart-Konfigurationen auf eine ISO-Datei angewendet?

Mit `mkkiso` wird eine Kickstart-Datei in das `root`-Verzeichnis einer Linux-ISO kopiert. Von dort aus bearbeitet `mkkiso` die Datei `/isolinux/isolinux.cfg` und fügt die Datei `kickstart` dort als Kernel-Befehlszeilenparameter (`inst.ks`) ein:

```bash
sudo mount -o ro,loop rocky-linux10-dvd-shadow.iso /mnt/
cat /mnt/EFI/BOOT/grub.cfg | grep shadow | head -1
linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-10-1-x86_64-dvd quiet inst.ks=hd:LABEL=Rocky-10-1-x86_64-dvd:/rocky_linux10_shadow.ks
```

Nach Abschluss des Vorgangs erzeugt `mkkiso` eine neue ISO-Datei mit der integrierten `kickstart`-Konfiguration. Beim Booten der ISO-Datei führt `anaconda` die in der Datei `kickstart` aufgeführten Anweisungen aus.

## Voraussetzungen

- Optional – Sie können Ihre `kickstart`-ISO-Datei über einen PXE-Server bereitstellen: Weitere Informationen finden Sie in der Anleitung [So richten Sie einen PXE-Server unter Rocky Linux 9.x ein](https://kb.ciq.com/article/rocky-linux/rl-pxe-boot-kickstart-file).

- Ein USB-Speicherstick der Generation 3.0+ oder höher für eine USB-Installation.

- Eine Rocky Linux 8, 9 oder 10 Minimal ISO von https://rockylinux.org/download (die DVD ISO ist nicht erforderlich).

- Folgen Sie der Anleitung [Custom Rocky Linux ISO Setup Steps](https://docs.rockylinux.org/10/guides/isos/iso_creation/), um das Paket `lorax` zu installieren und ein Rocky Linux `kickstart`-ISO zu generieren.

## Kickstart — Beispiele

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

**Die wichtigsten Punkte sind unten hervorgehoben, wobei der Schwerpunkt auf der `kickstart`-Datei von Rocky Linux 10 liegt. Etwaige Unterschiede zwischen den `kickstart`-Dateien werden ebenfalls besprochen:**

### Rocky Linux 10 Kickstart-Datei-Aufschlüsselung

#### rootpw

!!! warning

    Verwenden Sie für das Root-Passwort immer die Option `--iscrypted`, um sicherzustellen, dass es nicht im Klartext angezeigt wird.

Um einen Hash des gewünschten Passworts zu generieren, verwenden Sie den folgenden `openssl`-Befehl und geben Sie Ihr Passwort ein, wenn Sie dazu aufgefordert werden:

```bash
openssl passwd -6
```

Für den SSH-Zugriff auf das Root-Konto fügen Sie die Option `--allow-ssh` zur Zeile `rootpw` hinzu.

#### user

Verwenden Sie analog dazu die Option
`--iscrypted`, um sicherzustellen, dass Ihre Passwörter nicht im Klartext angezeigt werden.

Wenn Sie Ihren Benutzer zum Administrator machen möchten, fügen Sie ihn mit `--groups=wheel` der Gruppe `wheel` hinzu.

#### URL

Die Verwendung der Option `cdrom` mit `ignoredisk` führt zu Problemen, da Anaconda nicht auf das USB-Laufwerk zugreifen kann und beim Überprüfen der Speicherkonfiguration hängen bleibt. Die Verwendung von `url --url` umgeht dieses Problem, indem die Installation von `BaseOS` heruntergeladen wird.

#### Bootloader

Legt den Speicherort des Bootloaders fest und fügt die erforderlichen Kernel-Befehlszeilenparameter `cmdline` hinzu.

#### Zerombr

Gewährleistet die Vernichtung aller Partitionstabellen oder anderer Formatierungsoptionen, die Anaconda auf der ausgewählten Festplatte nicht erkennt.

#### Clearpart

Löscht alle Partitionen auf der Zielfestplatte und setzt die Festplattenbezeichnung auf `gpt`.

#### Ignoredisk

Wird `ignoredisk` nicht angegeben, hat `anaconda` Zugriff auf alle Festplatten im System. Falls angegeben, verwendet `anaconda` nur die vom Benutzer ausgewählte Festplatte.

#### Part

Mit `part` kann der Benutzer die Partitionen angeben, die er erstellen möchte. Das obige Beispiel zeigt eine Konfiguration für `/boot`, `/boot/efi` und Logical Volume Management. Das ist das Ergebnis einer automatischen Installation von Rocky Linux.

#### Volgroup

`volgroup` erstellt die LVM-Gruppe. This example shows the selection of the name `rl` and the physical size (`pesize`) of `4096 KiB`.

#### Logvol

Erstellt logische Volumes unter der LVM-Gruppe. Beachten Sie die Option `--grow` für das Volume `/home`, um sicherzustellen, dass der gesamte Speicherplatz der LVM-Gruppe genutzt wird.

#### Netzwerk

Hiermit können Sie Ihre Netzwerkkonfiguration entweder statisch oder dynamisch festlegen.

#### Skipx

Stoppt die X-Server-Konfiguration auf dem System.

#### Firstboot

In diesem Fall setzen wir das Flag `--disable`, wodurch verhindert wird, dass der Setup-Agent beim Systemstart aktiviert wird.

#### Firewall

Es ist wichtig, den SSH-Zugriff durch die Firewall mit `--ssh` zu erlauben, damit Sie sich an Ihrem Rechner anmelden können, wenn kein Konsolen-Zugriff möglich ist.

#### %packages

Listet die Pakete auf, die Sie installieren möchten. Im Beispiel ist die Paketgruppe `@^server-product-environment` der Kandidat für die Installation. Dadurch werden alle notwendigen Pakete für einen stabilen Rocky Linux-Server installiert.

Darüber hinaus können Sie hier auch einzelne Pakete zur Installation auswählen, die Installation bestimmter Pakete ausschließen und vieles mehr.

#### %post

Nach Abschluss der Installation des Betriebssystems können Sie hier auch zusätzliche Aufgaben auflisten. Im gegebenen Beispiel konfiguriert und bindet der Autor den in seinem System verfügbaren zusätzlichen Speicher ein.

Weitere Optionen stehen Ihnen hier ebenfalls zur Verfügung, wie zum Beispiel `%pre`, `%pre-install`, `%onerror` und `%traceback`. Mehr Informationen zu diesen Optionen finden Sie in den am Ende dieses Dokuments angegebenen Referenzen.

### Bedeutungsvolle Unterschiede zwischen den Rocky Linux Kickstarts

Rocky Linux 10 und 9 definieren das Tastaturlayout (Beispiel mit einer japanischen Tastatur) im folgenden Stil:

```
keyboard --xlayouts='jp'
```

Rocky Linux 8 definiert das Tastaturlayout jedoch wie folgt:

```
keyboard jp106
```

Für den `ssh`-Zugriff auf das `root`-Konto muss in der `kickstart`-Datei von Rocky Linux 8 **nicht** das Flag `--allow-ssh` hinzugefügt werden.

Der Kernel-Befehlszeilenparameter `crashkernel` unterscheidet sich zwischen allen drei Rocky Linux-Versionen. Bitte berücksichtigen Sie dies bei der Einstellung dieses Parameters.

Im `kickstart`-Beispiel von Rocky Linux 8 (dies gilt für alle Rocky Linux-Versionen) können Sie Ihre Festplatte automatisch partitionieren, indem Sie die Option `autopart` aktivieren.

## Zusammenfassung

Wenn Sie Ihre Rocky Linux-Installationen automatisieren möchten, dann sind `kickstart`-Dateien die richtige Wahl. Dieser Leitfaden ist nur die Spitze des Eisbergs dessen, was Sie mit `kickstart`-Dateien alles erreichen können. Eine hervorragende Übersicht über alle verfügbaren `kickstart`-Optionen mit Beispielen finden Sie in der `kickstart`-Dokumentation^2^ von Chris Lumens und dem Anaconda-Installer-Team.

Für diejenigen, die die Automatisierung im Bereich der Bereitstellung virtueller Maschinen weiter vorantreiben und auch ihr `kickstart`-Wissen nutzen möchten, hat Antoine Le Morvan eine hervorragende Anleitung^1^ geschrieben, wie man dies mit `packer` macht.

Das Rocky Linux Release Engineering Team stellt außerdem mehrere `kickstart`-Dateibeispiele im Rocky Linux Repository^4^ zur Verfügung.

Falls Sie Zugriff auf ein Red Hat-Konto haben, steht Ihnen der von Red Hat bereitgestellte Kickstart Generator zur Verfügung, mit dem Sie schnell und einfach über eine Benutzeroberfläche `kickstart`-Dateien erstellen können.

## Referenzen

1. "Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment" by Antoine Le Morvan [https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/](https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/)
2. "Extensive kickstart documentation" by Chris Lumens and the Anaconda installer team [https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
3. "Red Hat Kickstart Generator (requires a Red Hat Account)" by Red Hat [https://access.redhat.com/labsinfo/kickstartconfig](https://access.redhat.com/labsinfo/kickstartconfig)
4. "Rocky Linux Kickstart Repository" by the Rocky Linux Release Engineering Team [https://github.com/rocky-linux/kickstarts/tree/main](https://github.com/rocky-linux/kickstarts/tree/main)
   Footer

