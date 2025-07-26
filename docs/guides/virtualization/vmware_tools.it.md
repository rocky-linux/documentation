---
title: Installazione VMware Tools™
author: Emre Camalan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.9, 9.3
tags:
  - VMware
  - Tools
---

# Installazione VMware Tools™

VMware Tools™ è una suite di utility che migliora le prestazioni e la gestione delle macchine virtuali (VM) in esecuzione su piattaforme di virtualizzazione VMware come VMware vSphere, VMware Workstation e VMware Fusion. I VMware Tools™ migliorano l'interazione tra il sistema operativo guest e l'ambiente host.

## Prerequisiti e presupposti

- desiderio di gestire le istanze VMware con VMware Tools™
- la possibilità di aumentare i privilegi con `sudo`
- si presume che si parta da un'installazione minimale di Rocky Linux.

## Installazione dei pacchetti necessari

Installare il driver X11 VMware:

```bash
sudo dnf install xorg-x11-drv-vmware
```

Installare kernel-devel e kernel-headers:

```bash
sudo dnf install kernel-devel kernel-headers
```

Installare `perl` se non è già installato:

```bash
sudo dnf install perl
```

Riavviare il sistema:

```bash
sudo shutdown -r now
```

## Mounting VMware Tools™

### Montare VMware Tools™ nell'interfaccia grafica

Fare clic con il tasto destro del mouse su VM nel menu della macchina virtuale, quindi fare clic su Guest > Install/Upgrade VMware Tools™.

> VM Tab => Select Install VMware Tools

Montaggio del CD-ROM di VMware Tools completato.

### Montaggio di VMware Tools™ da riga di comando

Creare un mount point per VMware Tools™ e montarlo:

```bash
sudo mkdir /mnt/cdrom 
sudo mount /dev/cdrom /mnt/cdrom
mount: /mnt/cdrom: WARNING: source write-protected, mounted read-only.
```

Controllare se \`/dev/cdrom' è montato o meno:

```bash
sudo df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                1.8G     0  1.8G   0% /dev/shm
tmpfs                724M  9.3M  715M   2% /run
/dev/mapper/rl-root   37G  3.5G   34G  10% /
/dev/nvme0n1p1       960M  342M  619M  36% /boot
/dev/mapper/rl-home   19G  163M   18G   1% /home
tmpfs                362M   84K  362M   1% /run/user/1001
/dev/sr0              56M   56M     0 100% /mnt/CDROM
[root@localhost ecamalan]# cd /mnt/cdrom/
[root@localhost cdrom]# ls
manifest.txt  run_upgrader.sh  VMwareTools-10.3.23-16594550.tar.gz  vmware-tools-upgrader-32  vmware-tools-upgrader-64
```

## Installare VMWare Tools™

Copiare il file gzip di VMware Tools™ nella directory locale `/tmp` con questo comando:

```bash
cp /mnt/cdrom/VMwareTools-10.3.23-16594550.tar.gz /tmp/
```

Estrarre il file `tar.gz` in una nuova directory chiamata `/tmp/vmware-tools-distrib`:

```bash
[root@localhost cdrom]# cd /tmp/
[root@localhost tmp]# tar -zxvf VMwareTools-10.3.23-16594550.tar.gz vmware-tools-distrib/
vmware-tools-distrib/
vmware-tools-distrib/bin/
vmware-tools-distrib/bin/vm-support
vmware-tools-distrib/bin/vmware-config-tools.pl
vmware-tools-distrib/bin/vmware-uninstall-tools.pl
vmware-tools-distrib/vgauth/
vmware-tools-distrib/vgauth/schemas/
vmware-tools-distrib/vgauth/schemas/xmldsig-core-schema.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema.xsd
vmware-tools-distrib/vgauth/schemas/saml-schema-assertion-2.0.xsd
vmware-tools-distrib/vgauth/schemas/catalog.xml
vmware-tools-distrib/vgauth/schemas/XMLSchema.dtd
vmware-tools-distrib/vgauth/schemas/xml.xsd
vmware-tools-distrib/vgauth/schemas/xenc-schema.xsd
vmware-tools-distrib/vgauth/schemas/datatypes.dtd
vmware-tools-distrib/vgauth/schemas/XMLSchema-instance.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema-hasFacetAndProperty.xsd
vmware-tools-distrib/caf/

... (some packages not shown)

vmware-tools-distrib/lib/plugins64/common/
vmware-tools-distrib/lib/plugins64/common/libvix.so
vmware-tools-distrib/lib/plugins64/common/libhgfsServer.so
vmware-tools-distrib/doc/
vmware-tools-distrib/doc/INSTALL
vmware-tools-distrib/doc/open_source_licenses.txt
vmware-tools-distrib/doc/README
vmware-tools-distrib/vmware-install.pl
```

!!! Warning

````
Prima di iniziare, è necessario verificare se la directory `/etc/init.d` esiste o meno.
In caso contrario, potrebbe apparire il seguente errore:

>What is the directory that contains the init directories (rc0.d/ to rc6.d/)?

Soluzione:

```bash
sudo su
[root@localhost etc]# clear
[root@localhost etc]# cd /etc/
[root@localhost etc]# mkdir init.d
[root@localhost etc]# cd init.d
[root@localhost etc]# for i in {0,1,2,3,4,5,6}
> do
> mkdir rc$i.d
> done
[root@localhost etc]# cd /tmp/vmware-tools-distrib/
[root@localhost vmware-tools-distrib]# ./vmware-install.pl 
```
````

!!! Warning

```
Fare attenzione a cambiare la directory predefinita degli script di init, che dovrebbe essere `/etc/init.d/`.

>Qual è la directory che contiene le directory di init (da rc0.d/ a rc6.d/)? 
>[/etc] /etc/init.d

>INPUT: [/etc/init.d]

>Il percorso “/etc/init.d” è una directory che non contiene una directory rc0.d.


>Qual è la directory che contiene le directory di init (da rc0.d/ a rc6.d/)? 
>**[/etc] /etc/init.d/**

>INPUT: [/etc/init.d/]

>Qual è la directory che contiene gli script di avvio? 
>[/etc/init.d]

>INPUT: [/etc/init.d] default
```

Per eseguire lo script PERL, spostarsi nella directory vmware-tools-distrib ed eseguire `vmware-install.pl`:

```bash
sudo cd /tmp/vmware-tools-distrib/
sudo ./vmware-install.pl

A previous installation of VMware Tools has been detected.

The previous installation was made by the tar installer (version 4).

Keeping the tar4 installer database format.

You have a version of VMware Tools installed.  Continuing this install will 
first uninstall the currently installed version.  Do you wish to continue? 
(yes/no) [yes] 

INPUT: [yes]  default

Uninstalling the tar installation of VMware Tools™.

Can't exec "/etc/vmware-caf/pme/install/preupgrade.sh": No such file or directory at /usr/bin/vmware-uninstall-tools.pl line 4421.
The removal of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully.

Installing VMware Tools™.

In which directory do you want to install the binary files? 
[/usr/bin] 

INPUT: [/usr/bin]  default

What is the directory that contains the init directories (rc0.d/ to rc6.d/)? 
[/etc] 

INPUT: [/etc]  default

What is the directory that contains the init scripts? 
[/etc/init.d] 

INPUT: [/etc/init.d]  default

In which directory do you want to install the daemon files? 
[/usr/sbin] 

INPUT: [/usr/sbin]  default

In which directory do you want to install the library files? 
[/usr/lib/vmware-tools] 

INPUT: [/usr/lib/vmware-tools]  default

The path "/usr/lib/vmware-tools" does not exist currently. This program is 
going to create it, including needed parent directories. Is this what you want?
[yes] 

INPUT: [yes]  default

In which directory do you want to install the common agent library files? 
[/usr/lib] 

INPUT: [/usr/lib]  default

In which directory do you want to install the common agent transient files? 
[/var/lib] 

INPUT: [/var/lib]  default

In which directory do you want to install the documentation files? 
[/usr/share/doc/vmware-tools] 

INPUT: [/usr/share/doc/vmware-tools]  default

The path "/usr/share/doc/vmware-tools" does not exist currently. This program 
is going to create it, including needed parent directories. Is this what you 
want? [yes] 

INPUT: [yes]  default

The installation of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully. You can decide to remove this software from your system at any 
time by invoking the following command: "/usr/bin/vmware-uninstall-tools.pl".

Before running VMware Tools for the first time, you need to configure it by 
invoking the following command: "/usr/bin/vmware-config-tools.pl". Do you want 
this program to invoke the command for you now? [yes] 

INPUT: [yes]  default

Initializing...


Making sure services for VMware Tools are stopped.

Failed to stop vmware-tools.service: Unit vmware-tools.service not loaded.
Stopping VMware Tools services in the virtual machine:
   Guest operating system daemon:                                      done
   VMware User Agent (vmware-user):                                    done
   Unmounting HGFS shares:                                             done
   Guest filesystem driver:                                            done


sh: line 1: : command not found
The installation status of vmsync could not be determined. 
Skippinginstallation.

The installation status of vmci could not be determined. Skippinginstallation.

The installation status of vsock could not be determined. Skippinginstallation.


The installation status of vmxnet3 could not be determined. 
Skippinginstallation.

The installation status of pvscsi could not be determined. 
Skippinginstallation.

The installation status of vmmemctl could not be determined. 
Skippinginstallation.

The VMware Host-Guest Filesystem allows for shared folders between the host OS 
and the guest OS in a Fusion or Workstation virtual environment.  Do you wish 
to enable this feature? [yes] 

INPUT: [yes]  default

The vmxnet driver is no longer supported on kernels 3.3 and greater. Please 
upgrade to a newer virtual NIC. (e.g., vmxnet3 or e1000e)

The vmblock enables dragging or copying files between host and guest in a 
Fusion or Workstation virtual environment.  Do you wish to enable this feature?
[yes] 

INPUT: [yes]  default


Skipping configuring automatic kernel modules as no drivers were installed by 
this installer.

Do you want to enable Guest Authentication (vgauth)? Enabling vgauth is needed 
if you want to enable Common Agent (caf). [yes] 

INPUT: [yes]  default

Do you want to enable Common Agent (caf)? [no] 

INPUT: [no]  default



Detected X server version 1.20.11



Distribution provided drivers for Xorg X server are used.

Skipping X configuration because X drivers are not included.


Skipping rebuilding initrd boot image for kernel as no drivers to be included 
in boot image were installed by this installer.

Generating the key and certificate files.
Successfully generated the key and certificate files.
Failed to start vmware-tools.service: Unit vmware-tools.service not found.
Unable to start services for VMware Tools

Execution aborted.

Warning no default label for /tmp/vmware-block-restore-5339.0/tmp_file
Enjoy,

--the VMware team
```

Se si utilizza l'interfaccia grafica, è necessario riavviare il sistema:

```bash
sudo shutdown -r now
```

## Controllare l'installazione VMware

```bash
  sudo /etc/init.d/vmware-tools start
    Checking acpi hot plug                                              done
  Starting VMware Tools services in the virtual machine:
    Switching to guest configuration:                                   done
    Guest filesystem driver:                                            done
    Mounting HGFS shares:                                               done
    Blocking file system:                                               done
    Guest operating system daemon:                                      done
    VGAuthService:   
```

```bash
    sudo /etc/init.d/vmware-tools status
    vmtoolsd is running
```

## Conclusione

Abbiamo iniziato con un'installazione minimale di Rocky Linux, che ha portato a molte carenze ed errori lungo il percorso. Nonostante ciò, siamo riusciti a installare ed eseguire VMware Tools™, anche se con qualche difficoltà.
