---
title: Change Log
author: Louis Abel
contributors: Steven Spencer, tianci li, Franco Colussi
tags:
  - rocky changelog
  - changelog
---

# Rocky Linux 8 Change Log

Rocky Linux 8 riceverà aggiornamenti incrementali e aggiornamenti di versione minori nel corso del tempo, man mano che l'upstream svilupperà le proprie versioni. Questa pagina fornirà dettagli e informazioni sui cambiamenti che si verificheranno. Un sistema che esegue Rocky Linux può aggiornare il proprio sistema alla versione completa in qualsiasi momento eseguendo `dnf update`. L'aggiornamento di questo documento può talvolta subire ritardi. Per verificare la presenza di nuovi aggiornamenti, è possibile consultare l'archivio della mailing list [Rocky Announce](https://lists.resf.org/archives/list/rocky-announce@lists.resf.org/).

### Aggiornamenti

Gli aggiornamenti rilasciati dall'upstream sono pubblicati su tutte le nostre architetture attuali. Raccomandiamo vivamente a tutti gli utenti di applicare *tutti gli* aggiornamenti, compresi i contenuti rilasciati oggi, sulle macchine Rocky Linux esistenti. Questo può essere fatto eseguendo `dnf update`.

Tutti i componenti di Rocky Linux sono costruiti a partire dai sorgenti ospitati su [git.rockylinux.org](https://git.rockylinux.org). Inoltre, gli SRPM vengono pubblicati insieme ai repository in una corrispondente directory "source". È possibile trovarli su uno qualsiasi dei nostri mirrors. Questi pacchetti sorgente corrispondono a tutti gli RPM binari che rilasciamo.

## 8.5 - 2022-03-15

I seguenti pacchetti sono stati aggiornati dal 15 marzo 2022:

* expat-2.2.5-4.el8_5.3
* tzdata-2022a-1.el8
* httpd-2.4.37-43.module+el8.5.0+747+83fae388.3
* openssl-1.1.1k-6.el8_5

Sono stati aggiornati i seguenti moduli:

* httpd

CVE associati:

* CVE-2022-25236
* CVE-2022-25235
* CVE-2022-25315
* CVE-2022-23852
* CVE-2021-45960
* CVE-2021-46143
* CVE-2022-22827
* CVE-2022-22826
* CVE-2022-22825
* CVE-2022-22824
* CVE-2022-22823
* CVE-2022-22822
* CVE-2022-0778
* CVE-2022-22720

### Informazioni aggiuntive

Ci scusiamo per la mancanza di annunci nelle ultime due settimane. Attualmente questi annunci sono manuali e sono in corso piani per renderli più automatizzati con una minore interazione umana.

Con il rilascio della beta di RHEL 8.6, analizzeremo cosa sta cambiando e cosa e come dovremo fare le nostre build nelle prossime settimane prima del suo potenziale GA a fine aprile o maggio. Durante questo periodo, abbiamo anche lavorato al bootstrapping dei pacchetti beta di RHEL 9, che saranno poi importati, ricostruiti e testati nel nostro nuovo sistema di compilazione.

## 8.5 - 2022-03-14

I seguenti pacchetti sono stati aggiornati dal 14 marzo 2022:

* 389-ds-base: 389-ds-base-1.4.3.23-12.module+el8.5.0+722+e2a0b219 -> 389-ds-base-1.4.3.23-14.module+el8.5.0+745+c5be6847
* cloud-init: cloud-init-21.1-7.el8_5.3 -> cloud-init-21.1-7.el8_5.4
* fence-agents: fence-agents-4.2.1-75.el8 -> fence-agents-4.2.1-75.el8_5.2
* firewalld: firewalld-0.9.3-7.el8 -> firewalld-0.9.3-7.el8_5.1
* gdm: gdm-1:40.0-15.el8 -> gdm-1:40.0-15.el8_5.1
* glibc: glibc-2.28-164.el8 -> glibc-2.28-164.el8_5.3
* httpd: httpd-2.4.37-43.module+el8.5.0+727+743c5577.1 -> httpd-2.4.37-43.module+el8.5.0+746+b6ce3176.2
* java-11-openjdk: java-11-openjdk-1:11.0.14.0.9-2.el8_5 -> java-11-openjdk-1:11.0.14.1.1-2.el8_5
* libarchive: libarchive-3.3.3-1.el8_5 -> libarchive-3.3.3-3.el8_5
* libxml2: libxml2-2.9.7-11.el8 -> libxml2-2.9.7-12.el8_5
* linux-firmware: linux-firmware-20210702-103.gitd79c2677.el8 -> linux-firmware-20210702-104.gitd79c2677.el8_5
* lvm2: lvm2-8:2.03.12-10.el8 -> lvm2-8:2.03.12-11.el8_5
* nmstate: nmstate-1.1.0-5.el8_5 -> nmstate-1.1.0-6.el8_5
* pcs: pcs-0.10.10-4.el8.rocky.0 -> pcs-0.10.10-4.el8_5.1.rocky.0
* plymouth: plymouth-0.9.4-10.20200615git1e36e30.el8 -> plymouth-0.9.4-10.20200615git1e36e30.el8_5.1
* qemu-kvm: qemu-kvm-15:4.2.0-59.module+el8.5.0+726+ce09ee88.1 -> qemu-kvm-15:4.2.0-59.module+el8.5.0+744+67293bef.2
* redhat-support-lib-python: redhat-support-lib-python-0.11.3-1.el8 -> redhat-support-lib-python-0.13.0-0.el8_5
* redhat-support-tool: redhat-support-tool-0.11.3-2.el8 -> redhat-support-tool-0.13.0-0.el8_5
* samba: samba-4.14.5-9.el8_5 -> samba-4.14.5-10.el8_5
* subscription-manager: subscription-manager-1.28.21-3.el8 -> subscription-manager-1.28.21-5.el8_5
* systemd: systemd-239-51.el8_5.3 -> systemd-239-51.el8_5.5
* vim: vim-2:8.0.1763-16.el8_5.4 -> vim-2:8.0.1763-16.el8_5.12

Sono stati aggiornati i seguenti moduli:

* 389-ds
* httpd
* virt
* virt-devel

## 8.5 - 2022-03-10

I seguenti pacchetti sono stati aggiornati dal 10 marzo 2022:

* thunderbird: thunderbird-91.6.0-1.el8_5 -> thunderbird-91.7.0-2.el8_5
* thunderbird: thunderbird-91.6.0-1.el8_5.plus -> thunderbird-91.7.0-2.el8_5.plus

CVE associati:

* CVE-2022-25315
* CVE-2022-25235
* CVE-2022-25236

## 8.5 - 2022-02-24

I seguenti pacchetti sono stati aggiornati dal 24 febbraio 2022:

* dotnet3.1: dotnet3.1-3.1.416-3.el8_5 -> dotnet3.1-3.1.417-1.el8_5
* dotnet5.0: dotnet5.0-5.0.211-1.el8_5 -> dotnet5.0-5.0.212-1.el8_5
* dotnet6.0: dotnet6.0-6.0.102-1.el8_5 -> dotnet6.0-6.0.103-4.el8_5
* firefox: firefox-91.6.0-1.el8_5 -> firefox-91.7.0-3.el8_5
* kernel: kernel-4.18.0-348.12.2.el8_5 -> kernel-4.18.0-348.20.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.12.2.rt7.143.el8_5 -> kernel-rt-4.18.0-348.20.1.rt7.150.el8_5

CVE associati:

* CVE-2022-0435
* CVE-2022-0847

## 8.5 - 2022-02-22

I seguenti pacchetti sono stati aggiornati dal 22 febbraio 2022:

* cyrus-sasl: cyrus-sasl-2.1.27-5.el8 -> cyrus-sasl-2.1.27-6.el8_5

CVE associati:

* CVE-2022-24407

## 8.5 - 2022-02-16

I seguenti pacchetti sono stati aggiornati dal 16 febbraio 2022:

* python-pillow: python-pillow-5.1.1-16.el8 -> python-pillow-5.1.1-18.el8_5

CVE associati:

* CVE-2022-22815
* CVE-2022-22816
* CVE-2022-22817

## 8.5 - 2022-02-15

I seguenti moduli sono stati aggiornati dal 15 febbraio 2022:

* ruby-2.5-8050020220216182135.b4937e53
* ruby-2.6-8050020220216165459.b4937e53

## 8.5 - 2022-02-14

I seguenti pacchetti sono stati aggiornati dal 14 febbraio 2022:

* thunderbird: thunderbird-91.5.0-1.el8_5 -> thunderbird-91.6.0-1.el8_5
* thunderbird: thunderbird-91.5.0-1.el8.plus -> thunderbird-91.6.0-1.el8_5.plus

## 8.5 - 2022-02-09

I seguenti pacchetti sono stati aggiornati dal 09 febbraio 2022:

* dotnet3.1: dotnet3.1-3.1.120-2.el8_5 -> dotnet3.1-3.1.416-3.el8_5
* dotnet5.0: dotnet5.0-5.0.210-1.el8_5 -> dotnet5.0-5.0.211-1.el8_5
* dotnet6.0: dotnet6.0-6.0.101-2.el8_5 -> dotnet6.0-6.0.102-1.el8_5
* firefox: firefox-91.5.0-1.el8_5 -> firefox-91.6.0-1.el8_5

## 8.5 - 2022-02-04

I seguenti pacchetti sono stati aggiornati dal 04 febbraio 2022:

* aide: aide-0.16-14.el8 -> aide-0.16-14.el8_5.1

CVE associati:

* CVE-2021-45417

## 8.5 - 2022-02-02

I seguenti moduli/pacchetti sono stati aggiornati dal 02 febbraio 2022:

* varnish: varnish-6.0.8-1.module+el8.5.0+677+2a78a869 -> varnish-6.0.8-1.module+el8.5.0+736+fec10e21.1

CVE associati:

* CVE-2022-23959

## 8.5 - 2022-02-01

I seguenti pacchetti sono stati aggiornati dal 01 febbraio 2022:

* clevis: clevis-15-1.el8 -> clevis-15-1.el8_5.1
* cockpit: cockpit-251.1-1.el8 -> cockpit-251.3-1.el8_5
* cryptsetup: cryptsetup-2.3.3-4.el8 -> cryptsetup-2.3.3-4.el8_5.1
* dnf-plugins-core: dnf-plugins-core-4.0.21-3.el8 -> dnf-plugins-core-4.0.21-4.el8_5
* frr: frr-7.5-4.el8 -> frr-7.5-4.el8_5.2
* gnome-control-center: gnome-control-center-3.28.2-28.el8 -> gnome-control-center-3.28.2-29.el8_5
* nispor: nispor-1.1.1-1.el8 -> nispor-1.1.1-2.el8_5
* nmstate: nmstate-1.1.0-3.el8 -> nmstate-1.1.0-5.el8_5
* ostree: ostree-2021.3-1.el8 -> ostree-2021.3-2.el8_5
* resource-agents: resource-agents-4.1.1-98.el8 -> resource-agents-4.1.1-98.el8_5.2
* rpm: rpm-4.14.3-19.el8 -> rpm-4.14.3-19.el8_5.2
* sos: sos-4.1-5.el8.rocky.3 -> sos-4.1-9.el8_5.rocky.3
* spirv-tools: spirv-tools-2021.3-1.20210825.git1fbed83.el8 -> spirv-tools-2021.4-3.20211110.git21e3f68.el8_5
* sssd: sssd-2.5.2-2.el8_5.3 -> sssd-2.5.2-2.el8_5.4
* tcpdump: tcpdump-14:4.9.3-2.el8 -> tcpdump-14:4.9.3-2.el8_5.1
* tigervnc: tigervnc-1.11.0-9.el8 -> tigervnc-1.11.0-10.el8_5
* vim: vim-2:8.0.1763-16.el8 -> vim-2:8.0.1763-16.el8_5.4
* virtio-win: virtio-win-1.9.19-1.el8 -> virtio-win-1.9.24-2.el8_5
* vulkan-headers: vulkan-headers-1.2.189.0-1.el8 -> vulkan-headers-1.2.198.0-1.el8_5
* vulkan-loader: vulkan-loader-1.2.189.0-1.el8 -> vulkan-loader-1.2.198.0-2.el8_5
* vulkan-tools: vulkan-tools-1.2.189.0-1.el8 ->vulkan-tools-1.2.198.0-1.el8_5
* vulkan-validation-layers: vulkan-validation-layers-1.2.189.0-2.el8 ->vulkan-validation-layers-1.2.198.0-4.el8_5

Sono stati aggiornati i seguenti moduli:

* containertools
* freeradius
* nodejs
* pki-core
* virt
* virt-devel

## 8.5 - 2022-01-27

I seguenti pacchetti sono stati aggiornati dal 27 gennaio 2022:

* dotnet-build-reference-packages: dotnet-build-reference-packages-0-10.20200608gitcd5a8c6.el8 ->dotnet-build-reference-packages-0-11.20211215git045b288.el8_5
* nginx: nginx-1:1.20.0-2.module+el8.5.0+669+b11495b0 -> nginx-1:1.20.1-1.module+el8.5.0+729+3f70613e
* samba: samba-4.14.5-7.el8_5 -> samba-4.14.5-9.el8_5

Sono stati aggiornati i seguenti moduli:

* nginx

CVE associati:

* CVE-2021-44142
* CVE-2021-23017

## 8.5 - 2022-01-26

I seguenti pacchetti sono stati aggiornati dal 26 gennaio 2022:

* java-1.8.0-openjdk: java-1.8.0-openjdk-1:1.8.0.312.b07-2.el8_5 -> java-1.8.0-openjdk-1:1.8.0.322.b06-2.el8_5

## 8.5 - 2022-01-25

I seguenti pacchetti sono stati aggiornati dal 25 gennaio 2022:

* parfait: parfait-0.5.4-2.module+el8.3.0+214+edf13b3f -> parfait-0.5.4-4.module+el8.5.0+728+553fbdb8

I seguenti pacchetti sono stati eliminati:

* log4j12: log4j12-1.2.17-22.module+el8.3.0+214+edf13b3f

Sono stati aggiornati i seguenti moduli:

* parfait

## 8.5 - 2022-01-24

I seguenti pacchetti sono stati aggiornati dal 24 gennaio 2022:

* httpd: httpd-2.4.37-43.module+el8.5.0+714+5ec56ee8 -> httpd-2.4.37-43.module+el8.5.0+727+743c5577.1
* polkit: polkit-0.115-12.el8 -> polkit-0.115-13.el8_5.1

Sono stati aggiornati i seguenti moduli:

* httpd

CVE associati:

* CVE-2021-44790
* CVE-2021-4034

## 8.5 - 2022-01-19

I seguenti pacchetti sono stati aggiornati dal 19 gennaio 2022:

* java-11-openjdk: java-11-openjdk-1:11.0.13.0.8-4.el8_5 -> java-11-openjdk-1:11.0.14.0.9-2.el8_5

## 8.5 - 2022-01-12

I seguenti pacchetti sono stati aggiornati dal 12 gennaio 2022:

* gegl04: gegl04-0.4.4-6.el8 -> gegl04-0.4.4-6.el8_5.2
* java-17-openjdk: java-17-openjdk-1:17.0.1.0.12-2.el8_5 -> java-17-openjdk-1:17.0.2.0.8-4.el8_5
* kernel: kernel-4.18.0-348.7.1.el8_5 -> kernel-4.18.0-348.12.2.el8_5
* kernel-rt: kernel-rt-4.18.0-348.7.1.rt7.137.el8_5 -> kernel-rt-4.18.0-348.12.2.rt7.143.el8_5
* libarchive: libarchive-3.3.3-1.el8 -> libarchive-3.3.3-1.el8_5
* libreswan: libreswan-4.4-1.el8 -> libreswan-4.4-4.el8_5

CVE associati:

* CVE-2022-0185
* CVE-2021-45463
* CVE-2021-4155

## 8.5 - 2022-01-11

I seguenti pacchetti sono stati aggiornati dal 11 gennaio 2022:

* firefox: firefox-91.4.0-1.el8_5 -> firefox-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8_5 -> thunderbird-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8.plus -> thunderbird-91.5.0-1.el8.plus

## 8.5 - 2022-01-03

I seguenti pacchetti sono stati aggiornati dal 03 gennaio 2022:

* dotnet6.0: dotnet6.0-6.0.100-0.10.el8_5 -> dotnet6.0-6.0.101-2.el8_5
* rpaste: rpaste-0.1-3.el8.2 -> rpaste-0.2.0-1.el8

## 8.5 - 2021-12-22

I seguenti pacchetti sono stati aggiornati dal 22 dicembre 2021:

* grafana: grafana-7.5.9-4.el8 -> grafana-7.5.9-5.el8_5

CVE associati:

* CVE-2021-44716

## 8.5 - 2021-12-17

I seguenti pacchetti sono stati aggiornati dal 17 dicembre 2021:

* 389-ds-base: 389-ds-base-1.4.3.23-10.module+el8.5.0+700+370e33d5 -> 389-ds-base-1.4.3.23-12.module+el8.5.0+722+e2a0b219
* accountsservice: accountsservice-0.6.55-2.el8 -> accountsservice-0.6.55-2.el8_5.2
* cloud-init: cloud-init-21.1-7.el8 -> cloud-init-21.1-7.el8_5.3
* freeradius: freeradius-3.0.20-9.module+el8.5.0+704+21fb769d -> freeradius-3.0.20-10.module+el8.5.0+723+cc9aee6c
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-20.el8_5.1 -> gnome-shell-extensions-3.32.1-22.el8_5
* java-11-openjdk: java-11-openjdk-1:11.0.13.0.8-3.el8_5 -> java-11-openjdk-1:11.0.13.0.8-4.el8_5
* kernel: kernel-4.18.0-348.2.1.el8_5 -> kernel-4.18.0-348.7.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.2.1.rt7.132.el8_5 -> kernel-rt-4.18.0-348.7.1.rt7.137.el8_5
* kexec-tools: kexec-tools-2.0.20-57.el8 -> kexec-tools-2.0.20-57.el8_5.1
* opencryptoki: opencryptoki-3.16.0-5.el8 -> opencryptoki-3.16.0-7.el8_5
* openssl: openssl-1:1.1.1k-4.el8 -> openssl-1:1.1.1k-5.el8_5
* poppler: poppler-20.11.0-3.el8 -> poppler-20.11.0-3.el8_5.1
* postgresql: postgresql-12.7-2.module+el8.5.0+686+20453ecc -> postgresql-12.9-1.module+el8.5.0+724+9de6e501
* qemu-kvm: qemu-kvm-15:4.2.0-59.module+el8.5.0+670+c4aa478c -> qemu-kvm-15:4.2.0-59.module+el8.5.0+726+ce09ee88.1
* rocky-release: rocky-release-8.5-2.el8 -> rocky-release-8.5-3.el8
* sssd: sssd-2.5.2-2.el8_5.1 -> sssd-2.5.2-2.el8_5.3

CVE associati:

* CVE-2021-20321
* CVE-2021-3930
* CVE-2021-20257
* CVE-2021-3712

I seguenti moduli sono stati aggiornati:

* virt-rhel-8050020211221163306.b4937e53
* virt-devel-rhel-8050020211221163306.b4937e53
* postgresql-13-8050020211221161313.b4937e53
* postgresql-12-8050020211221161311.b4937e53
* freeradius-3.0-8050020211221161359.ab0f257b
* 389-ds-1.4-8050020211221162652.1a75f91c

### Note tecniche di rilascio

il pacchetto rocky-release è stato aggiornato per aggiungere countme=1 ai repository di base per Rocky Linux, in modo simile a come epel ha nei suoi repository. Se avete modificato i file del repo, verranno generati dei file .rpmnew, per non sovrascrivere le modifiche.

## 8.5 - 2021-12-16

I seguenti pacchetti sono stati aggiornati dal 16 dicembre 2021:

* selinux-policy: selinux-policy-3.14.3-80.el8 -> selinux-policy-3.14.3-80.el8_5.2
* systemd: systemd-239-51.el8 -> systemd-239-51.el8_5.3

## 8.5 - 2021-12-13

I seguenti pacchetti sono stati aggiornati dal 13 dicembre 2021:

* dotnet5.0: dotnet5.0-5.0.209-1.el8_5 -> dotnet5.0-5.0.210-1.el8_5
* go-toolset: go-toolset-1.16.7-1.module+el8.5.0+694+f77f0bfd -> go-toolset-1.16.12-1.module+el8.5.0+720+c057d5cf
* golang: golang-1.16.7-1.module+el8.5.0+694+f77f0bfd -> golang-1.16.12-1.module+el8.5.0+720+c057d5cf
* ipa: ipa-4.9.6-6.module+el8.5.0+675+61f67439 -> ipa-4.9.6-10.module+el8.5.0+719+4f06efb6
* nodejs: nodejs-1:16.8.0-1.module+el8.5.0+702+221f14e6 -> nodejs-1:16.13.1-3.module+el8.5.0+721+4c107270
* nodejs-nodemon: nodejs-nodemon-2.0.7-1.module+el8.5.0+702+221f14e6 -> nodejs-nodemon-2.0.15-1.module+el8.5.0+721+4c107270

* kernel-rt: kernel-rt-kvm aggiunto a RT

CVE associati:

* CVE-2020-25717

I seguenti moduli sono stati aggiornati:

* go-toolset-rhel8-8050020211215173118-8aa62369
* idm-DL1-8050020211215093947-3d2c466f
* nodejs-16-8050020211215195043-b4937e53


### Note tecniche di rilascio

In base a una richiesta, il pacchetto kernel-rt-kvm è stato aggiunto al repo di RT.

## 8.5 - 2021-12-12

I seguenti pacchetti sono stati aggiornati dal 12 dicembre 2021:

* samba: samba-4.14.5-2.el8 -> samba-4.14.5-7.el8_5

CVE associati:

* CVE-2016-2124
* CVE-2020-25717
* CVE-2021-23192

## 8.5 - 2021-12-10

I seguenti pacchetti sono stati aggiornati dal 10 dicembre 2021:

* WALinuxAgent: WALinuxAgent-2.3.0.2-2.el8 -> WALinuxAgent-2.3.0.2-2.el8.rocky.0
* libreoffice: libreoffice-1:6.4.7.2-5.el8.1 -> libreoffice-1:6.4.7.2-5.el8.2.rocky
* openscap: openscap-1.3.5-6.el8 -> openscap-1.3.5-6.el8.rocky.0.1
* pcs: pcs-0.10.10-4.el8 -> pcs-0.10.10-4.el8.rocky.0
* python2: python2-2.7.18-7.module+el8.5.0+706+735ec4b3.rocky.0.1 -> python2-2.7.18-7.module+el8.5.0+718+67e45b5f.rocky.0.2
* rocky-release: rocky-release-8.5-1.el8 -> rocky-release-8.5-2.el8

I seguenti moduli sono stati aggiornati:

* python27

### Note tecniche di rilascio

Questi aggiornamenti sono per lo più di natura estetica e non influiscono sulla funzionalità.

* WALinuxAgent -> Abbiamo aggiunto il supporto diretto a Rocky qui e in una PR upstream a Microsoft
* libreoffice -> È stato trovato il marchio Red Hat. Questo aggiornamento riguarda il branding.
* openscap -> Mancano informazioni per Rocky Linux.
* pcs -> Il logo aveva un marchio che non è stato rimosso
* rocky-release -> semplificato CPE_NAME
* python2 -> aggiunge rocky alle dist supportate

## 8.5 - 2021-12-09

I seguenti pacchetti sono stati aggiornati dal 09 dicembre 2021:

* thunderbird: thunderbird-91.3.0-2.el8_4 ->
* thunderbird-91.4.0-2.el8_5
* thunderbird: thunderbird-91.3.0-2.el8.plus ->
* thunderbird-91.4.0-2.el8.plus

### Note tecniche di rilascio

Thunderbird: Si tratta di un aggiornamento regolare della build ESR di thunderbird. Questo aggiornamento riguarda sia i repository di base che Plus. Il repository Plus contiene una versione di thunderbird con supporto PGP.

## 8.5 - 2021-12-03

I seguenti pacchetti sono stati aggiornati dal 03 dicembre 2021:

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0
* firefox: firefox-91.3.0-1.el8_4 -> firefox-91.4.0-1.el8_5
* sos: sos-4.1-5.el8 -> sos-4.1-5.el8.rocky.2

### Note tecniche di rilascio

Firefox: Si tratta di una build ESR aggiornata per Firefox.

abrt: Si tratta di una modifica per lo più estetica. Elimina la dipendenza dai plugin libreport-rhel* e rhtsupport. Questi pacchetti possono essere tranquillamente rimossi dopo l'aggiornamento al nuovo pacchetto abrt.

sos: Si tratta di una modifica per lo più estetica. Abbatte la politica Rocky a monte. Consultare [questo PR  per maggiori dettagli](https://github.com/sosreport/sos/pull/2784)

## 8.5 - 2021-12-02

I seguenti pacchetti sono stati aggiornati dal 02 dicembre 2021:

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->
* mailman-3:2.1.29-12.module+el8.5.0+717+27fd1ba7.2

CVE associati:

* mailman: CVE-2021-44227

I seguenti moduli sono stati aggiornati dal 02 dicembre 2021:

* mailman-2.1-8050020211202160117.fd901a62


## 8.5 - Supplemento - 2021-11-30

I seguenti pacchetti sono stati aggiunti al repository devel:

* ncurses-static

I seguenti pacchetti sono stati aggiunti al repository plus:

* open-vm-tools (solo build specifiche per aarch64)

### Note aggiuntive

Il repository plus contiene elementi che non sono presenti nei repository di base, o perché non sono disponibili a causa della configurazione di comps e pungi (basata sui repository RHEL) o perché sono richiesti come build alternative con patch/caratteristiche aggiuntive non presenti nella base. Il repository plus dovrebbe essere sicuro da tenerlo abilitato.

I pacchetti attuali in più (al 2021-11-30) sono:

* openldap-server (tutte le architetture)
* thunderbird con supporto PGP (tutte le architetture)
* ncurses-static (tutte le architetture)
* open-vm-tools (solo build specifiche per aarch64)

### Note di sviluppo

Il repository devel deve essere usato con attenzione. È pensato per scopi di koji o buildroot e non dovrebbe essere abilitato al 100% del tempo. Se trovate un pacchetto che desiderate vedere nel repo di sviluppo, inviate una mail su rocky-devel e/o aprite una segnalazione di bug su https://bugs.rockylinux.org

## 8.5 - 2021-11-29

I seguenti pacchetti sono stati aggiornati dal 29 novembre 2021:

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5
* nss: nss-3.67.0-6.el8_4 -> nss-3.67.0-7.el8_5

CVE associati:

* nss-3.67.0-7.el8_5: CVE-2021-43527

## 8.5 - 2021-11-24

I seguenti pacchetti sono stati aggiornati dal 24 novembre 2021:

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5
* dotnet5.0-build-reference-packages: dotnet5.0-build-reference-packages-0-11.20210607git5f10a4b.el8 -> dotnet5.0-build-reference-packages-0-12.20211117git6ce5818.el8_5


## 8.5 - 2021-11-22

I seguenti pacchetti sono stati aggiornati dal 22 novembre 2021 (compresi i pacchetti modulo aggiornati):

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1

I seguenti moduli sono stati aggiornati dal 23 novembre 2021:

* mailman-2.1-8050020211123230959.fd901a62

CVE associati:

* CVE-2021-42096
* CVE-2021-42097

## 8.5 - 2021-11-16

I seguenti pacchetti sono stati aggiornati dal 16 novembre 2021 (compresi i pacchetti modulo aggiornati):

* clang: clang-12.0.1-2.module+el8.5.0+692+8756646f -> clang-12.0.1-4.module+el8.5.0+715+58f51d49
* llvm-toolset: llvm-toolset-12.0.1-1.module+el8.5.0+692+8756646f -> llvm-toolset-12.0.1-1.module+el8.5.0+715+58f51d49

I seguenti moduli sono stati aggiornati dal 16 novembre 2021:

* llvm-toolset-rhel8-8050020211122023437.b4937e53

## 8.5 - 2021-11-14

I seguenti pacchetti sono stati aggiornati dal rilascio 8.5 del 14 novembre 2021 (compresi i pacchetti modulo aggiornati):

* annobin: annobin-9.65-1.el8 -> annobin-9.72-1.el8_5.2
* binutils: binutils-2.30-108.el8 -> binutils-2.30-108.el8_5.1
* dotnet-build-reference-packages: dotnet-build-reference-packages-0-9.20200608gitcd5a8c6.el8 -> dotnet-build-reference-packages-0-10.20200608gitcd5a8c6.el8
* dotnet3.1: dotnet3.1-3.1.119-2.el8.0.1 -> dotnet3.1-3.1.120-2.el8_5
* dotnet5.0: dotnet5.0-5.0.207-3.el8.0.1 -> dotnet5.0-5.0.208-2.el8_5
* dotnet6.0: dotnet6.0-6.0.0-0.6.28be3e9a006d90d8c6e87d4353b77882829df718.el8.0.1 -> dotnet6.0-6.0.100-0.10.el8_5
* firefox: firefox-78.13.0-2.el8 -> firefox-91.3.0-1.el8
* flatpak: flatpak-1.8.5-4.el8 -> flatpak-1.8.5-5.el8_5
* freerdp: freerdp-2:2.2.0-2.el8 -> freerdp-2:2.2.0-7.el8_5
* gcc: gcc-8.5.0-3.el8 -> gcc-8.5.0-4.el8_5
* gcc-toolset-10-annobin: gcc-toolset-10-annobin-9.29-1.el8 -> gcc-toolset-10-annobin-9.29-1.el8_5.2
* gcc-toolset-10-binutils: gcc-toolset-10-binutils-2.35-8.el8_4.4 -> gcc-toolset-10-binutils-2.35-8.el8_5.6
* gcc-toolset-10-gcc: gcc-toolset-10-gcc-10.2.1-8.2.el8 -> gcc-toolset-10-gcc-10.3.1-1.2.el8_5
* gcc-toolset-11-annobin: gcc-toolset-11-annobin-9.73-1.el8 -> gcc-toolset-11-annobin-9.85-1.el8_5.1
* gcc-toolset-11-binutils: gcc-toolset-11-binutils-2.36.1-1.el8 -> gcc-toolset-11-binutils-2.36.1-1.el8_5.1
* gcc-toolset-11-dyninst: gcc-toolset-11-dyninst-11.0.0-1.el8 -> gcc-toolset-11-dyninst-11.0.0-2.el8
* gcc-toolset-11-gcc: gcc-toolset-11-gcc-11.1.1-3.el8 -> gcc-toolset-11-gcc-11.2.1-1.2.el8_5
* gcc-toolset-11-systemtap: gcc-toolset-11-systemtap-4.5-3.el8 -> gcc-toolset-11-systemtap-4.5-4.el8
* gcc-toolset-11-valgrind: gcc-toolset-11-valgrind-1:3.17.0-4.el8 -> gcc-toolset-11-valgrind-1:3.17.0-6.el8
* gnome-settings-daemon: gnome-settings-daemon-3.32.0-14.el8 -> gnome-settings-daemon-3.32.0-16.el8
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-20.el8 -> gnome-shell-extensions-3.32.1-20.el8_5.1
* httpd: httpd-2.4.37-41.module+el8.5.0+695+1fa8055e -> httpd-2.4.37-43.module+el8.5.0+714+5ec56ee8
* ibus: ibus-1.5.19-13.el8 -> ibus-1.5.19-14.el8_5
* java-1.8.0-openjdk: java-1.8.0-openjdk-1:1.8.0.302.b08-3.el8 -> java-1.8.0-openjdk-1:1.8.0.312.b07-2.el8_5
* java-11-openjdk: java-11-openjdk-1:11.0.12.0.7-4.el8 -> java-11-openjdk-1:11.0.13.0.8-3.el8_5
* java-17-openjdk: java-17-openjdk-1:17.0.0.0.35-4.el8 -> java-17-openjdk-1:17.0.1.0.12-2.el8_5
* kernel: kernel-4.18.0-348.el8.0.2 -> kernel-4.18.0-348.2.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.rt7.130.el8.0.2 -> kernel-rt-4.18.0-348.2.1.rt7.132.el8_5
* kronosnet: kronosnet-1.18-1.el8 -> kronosnet-1.18-2.el8
* rust: rust-1.54.0-2.module+el8.5.0+678+cf7bc64b -> rust-1.54.0-3.module+el8.5.0+712+d335422a
* rust-toolset: rust-toolset-1.54.0-1.module+el8.5.0+678+cf7bc64b -> rust-toolset-1.54.0-1.module+el8.5.0+712+d335422a
* sssd: sssd-2.5.2-2.el8 -> sssd-2.5.2-2.el8_5.1
* thunderbird: thunderbird-78.13.0-1.el8 -> thunderbird-91.3.0-2.el8
* udftools: udftools-2.2-5.el8 -> udftools-2.3-2.el8

I seguenti pacchetti sono stati eliminati e rimossi anche dai gruppi dnf:

* insights-client: insights-client-3.1.5-1.el8 (Gruppo Standard)

Per i pacchetti che sono stati abbandonati, è sicuro rimuoverli usando `dnf remove`

I seguenti moduli sono stati aggiornati dalla versione 8.5 del 14 novembre 2021:

* rust-toolset-rhel8-8050020211112021616.f73640c0
* httpd-2.4-8050020211115030420.b4937e53

### Problemi noti

[bug 174](https://bugs.rockylinux.org/show_bug.cgi?id=174) - Siamo a conoscenza di un problema per cui `kdump` non funziona su sistemi vmware come ESXi.

Siamo anche consapevoli del fatto che il nostro sistema mirror riporta la directory sbagliata per effettuare gli aggiornamenti. Avrebbe preso il `kickstart` piuttosto che l'`os`. Il problema dovrebbe essere risolto e gli aggiornamenti dovrebbero funzionare normalmente.

## 8.4 - 2021-09-21

Sono stati aggiornati i seguenti pacchetti:

* kernel: kernel-4.18.0-305.19.1 (9-15)
* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.2
* golang: 1.15.14-2
* nss: 3.67.0-6
* ca-certificates: 2021.2.50-80.0
* opencryptoki: 3.15.1-7
* krb5: 1.18.2-8.3
* platform-python: 3.6.8-38
* libdb: 5.3.28-42
* rng-tools: 6.8-4
* sos: 4.0-12
* python-ldap: 3.3.1-1.1
* subscription-manager: 1.28.13-4
* pcp: 5.2.5-6
* strace: 5.7-2.1
* nspr: 4.32.0-1
* gcc-toolset-10-elfutils: 0.182-6
* gcc-toolset-10-binutils: 2.35-8.el8_4.4
* maven: maven-3.6.2-6
* mysql: 8.0.26
* selinux-policy: 3.14.3-67.el8_4.2
* grub2: 2.02-99.el8_4.1.1
* resource-agents: 4.1.1-90.el8_4.7
* poppler: 20.11.0-2.el8_4.1
* pacemaker: 2.0.5-9.el8_4.3

## 8.4 - 2021-09-13

Sono stati aggiornati i seguenti pacchetti:

* thunderbird: aggiornato a 78.14.0
* firefox: aggiornato a 78.14.0
* cyrus-imapd: aggiornato a 3.0.7-20.el8_4.1 (risolve CVE-2021-33582)
* systemtap ricostruito con dyninst 10.2 per risolvere una segnalazione di bug
* rocky-release -> Aggiornato per consentire "centos" come ID

I seguenti repo sono stati aggiornati:

* extras -> Sono stati aggiunti i pacchetti della release CentOS sig

## 8.4 - 2021-08-24

Sono stati aggiornati i seguenti pacchetti:

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4
* libsndfile: libsndfile-1.0.28-10.el8_4 -> libsndfile-1.0.28-10.el8_4.1 -- Addresses

  * Risolve un overflow del buffer heap che consentiva l'esecuzione di codice arbitrario da un file wav

* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.1

  * Addresses RLBZ#108

Sono stati aggiunti i seguenti repository/pacchetti:

* RT (realtime) - Abilitato eseguendo `dnf config-manager --set-enabled rt`

  * kernel-rt (kernel in tempo reale)

## 8.4 - 2021-08-11

Sono stati aggiornati i seguenti pacchetti:

* 389-ds-base: 389-ds-base-1.4.3.16-16.module+el8.4.0+596+159889e5 -> 389-ds-base-1.4.3.16-19.module+el8.4.0+636+837ee950
* NetworkManager: NetworkManager-1:1.30.0-9.el8_4 -> NetworkManager-1:1.30.0-10.el8_4
* autofs: autofs-1:5.1.4-48.el8 -> autofs-1:5.1.4-48.el8_4.1
* buildah: buildah-1.19.7-2.module+el8.4.0+556+40122d08 -> buildah-1.21.4-1.module+el8.4.0+643+525e162a
* cloud-init: cloud-init-20.3-10.el8_4.3 -> cloud-init-20.3-10.el8_4.5
* cockpit-podman: cockpit-podman-29-2.module+el8.4.0+556+40122d08 -> cockpit-podman-32-2.module+el8.4.0+643+525e162a
* conmon: conmon-2:2.0.26-3.module+el8.4.0+556+40122d08 -> conmon-2:2.0.29-1.module+el8.4.0+643+525e162a
* container-selinux: container-selinux-2:2.162.0-1.module+el8.4.0+556+40122d08 -> container-selinux-2:2.164.1-1.module+el8.4.0+643+525e162a
* crun: crun-0.18-2.module+el8.4.0+556+40122d08 -> crun-0.20.1-1.module+el8.4.0+643+525e162a
* dotnet3.1 dotnet3.1-3.1.117-1.el8_4 -> dotnet3.1-3.1.118-1.el8_4
* edk2: edk2-20200602gitca407c7246bf-4.el8_4.1 -> edk2-20200602gitca407c7246bf-4.el8_4.2
* elfutils: elfutils-0.182-3.el8 -> elfutils-0.182-3.el8_4
* esc: esc-1.1.2-18.el8 -> esc-1.1.2-22.el8_4
* fence-agents: fence-agents-4.2.1-65.el8 -> fence-agents-4.2.1-65.el8_4.1
* fuse-overlayfs: fuse-overlayfs-1.4.0-3.module+el8.4.0+556+40122d08 -> fuse-overlayfs-1.6-1.module+el8.4.0+643+525e162a
* gcc-toolset-10-elfutils: gcc-toolset-10-elfutils-0.182-3.el8 -> gcc-toolset-10-elfutils-0.182-5.el8_4
* gcc-toolset-10-valgrind: gcc-toolset-10-valgrind-1:3.16.0-4.el8 -> gcc-toolset-10-valgrind-1:3.16.0-6.el8_4
* glib2: glib2-2.56.4-10.el8_4 -> glib2-2.56.4-10.el8_4.1
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-14.el8.1 -> gnome-shell-extensions-3.32.1-15.el8_4.1
* go-toolset: go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3 -> go-toolset-1.15.14-1.module+el8.4.0+632+4dba2916
* golang: golang-1.15.13-3.module+el8.4.0+591+0da41cc3 -> golang-1.15.14-1.module+el8.4.0+632+4dba2916
* hivex: hivex-1.3.18-20.module+el8.4.0+534+4680a14e -> hivex-1.3.18-21.module+el8.4.0+642+7e26f5e1
* kernel: kernel-4.18.0-305.10.2.el8_4 -> kernel-4.18.0-305.12.1.el8_4
* kexec-tools: kexec-tools-2.0.20-46.el8_4.1 -> kexec-tools-2.0.20-46.el8_4.2
* libuv: libuv-1:1.40.0-1.el8 -> libuv-1:1.41.1-1.el8_4
* libvirt: libvirt-6.0.0-35.module+el8.4.0+534+4680a14e -> libvirt-6.0.0-35.1.module+el8.4.0+642+7e26f5e1
* libwacom: libwacom-1.6-2.el8 -> libwacom-1.6-2.1.el8_4
* mdadm: mdadm-4.1-15.el8 -> mdadm-4.1-16.el8_4
* nfs-utils: nfs-utils-1:2.3.3-41.el8 -> nfs-utils-1:2.3.3-41.el8_4.2
* nmstate: nmstate-1.0.2-11.el8_4 -> nmstate-1.0.2-14.el8_4
* nodejs: nodejs-1:12.21.0-1.module+el8.3.0+99+3663d81c -> nodejs-1:12.22.3-2.module+el8.4.0+638+5344c6f7
* nodejs-nodemon: nodejs-nodemon-2.0.3-1.module+el8.3.0+100+234774f7 -> nodejs-nodemon-2.0.3-1.module+el8.4.0+638+5344c6f7
* oci-seccomp-bpf-hook: oci-seccomp-bpf-hook-1.2.0-2.module+el8.4.0+556+40122d08 -> oci-seccomp-bpf-hook-1.2.3-2.module+el8.4.0+643+525e162a
* opencryptoki: opencryptoki-3.15.1-5.el8 -> opencryptoki-3.15.1-6.el8_4
* ostree: ostree-2020.7-4.el8 -> ostree-2020.7-5.el8_4
* pcp: pcp-5.2.5-4.el8 -> pcp-5.2.5-5.el8_4
* pcsc-lite: pcsc-lite-1.8.23-3.el8 -> pcsc-lite-1.8.23-4.1.el8_4
* pcsc-lite-ccid: pcsc-lite-ccid-1.4.29-4.el8 -> pcsc-lite-ccid-1.4.29-5.1.el8_4
* perl: perl-4:5.26.3-419.el8 -> perl-4:5.26.3-419.el8_4.1
* perl-IO-String: perl-IO-String-1.08-31.el8 -> perl-IO-String-1.08-32.el8
* podman: podman-3.0.1-7.module+el8.4.0+556+40122d08 -> podman-3.2.3-0.10.module+el8.4.0+643+525e162a
* qemu-kvm: qemu-kvm-15:4.2.0-48.module+el8.4.0+534+4680a14e -> qemu-kvm-15:4.2.0-48.module+el8.4.0+642+7e26f5e1.3
* resource-agents: resource-agents-4.1.1-90.el8_4.5 -> resource-agents-4.1.1-90.el8_4.6
* runc: runc-1.0.0-73.rc93.module+el8.4.0+556+40122d08 -> runc-1.0.0-74.rc95.module+el8.4.0+643+525e162a
* rust: rust-1.49.0-1.module+el8.4.0+416+259a129a -> rust-1.52.1-1.module+el8.4.0+641+ca238f88
* rust-toolset: rust-toolset-1.49.0-1.module+el8.4.0+416+259a129a -> rust-toolset-1.52.1-1.module+el8.4.0+641+ca238f88
* samba: samba-4.13.3-3.el8 -> samba-4.13.3-4.el8_4
* selinux-policy: selinux-policy-3.14.3-67.el8 -> selinux-policy-3.14.3-67.el8_4.1
* skopeo: skopeo-1:1.2.2-10.module+el8.4.0+556+40122d08 -> skopeo-1:1.3.1-5.module+el8.4.0+643+525e162a
* spirv-tools: spirv-tools-2020.5-3.20201208.gitb27b1af.el8 -> spirv-tools-2021.2-1.20210619.git5dd2f76.el8_4
* stalld: stalld-1.9-2.el8 -> stalld-1.10-1.el8_4
* systemd: systemd-239-45.el8_4.2 -> systemd-239-45.el8_4.3
* systemtap: systemtap-4.4-10.el8 -> systemtap-4.4-11.el8_4
* udica: udica-0.2.4-1.module+el8.4.0+556+40122d08 -> udica-0.2.4-2.module+el8.4.0+643+525e162a
* valgrind: valgrind-1:3.16.0-4.el8 -> valgrind-1:3.16.0-4.el8_4
* virt-what: virt-what-1.18-6.el8 -> virt-what-1.18-9.el8_4
* virt-who: virt-who-1.30.5-1.el8 -> virt-who-1.30.5-2.el8_4
* virtio-win: virtio-win-1.9.16-2.el8 -> virtio-win-1.9.17-4.el8_4
* vulkan-headers: vulkan-headers-1.2.162.0-1.el8 -> vulkan-headers-1.2.182.0-1.el8_4
* vulkan-loader: vulkan-loader-1.2.162.0-1.el8 -> vulkan-loader-1.2.182.0-1.el8_4
* vulkan-tools: vulkan-tools-1.2.162.0-1.el8 -> vulkan-tools-1.2.182.0-1.el8_4
* vulkan-validation-layers: vulkan-validation-layers-1.2.162.0-1.el8 -> vulkan-validation-layers-1.2.182.0-1.el8_4

## 8.4 - 2021-08-02

Sono stati aggiornati i seguenti pacchetti:

* varnish -> varnish-0:6.0.6-2.module+el8.4.0+628+e1687553.1 -> Addresses CVE-2021-36740

Aggiunti i repository kickstart per i seguenti repository:

* BaseOS
* AppStream
* PowerTools
* High Availability
* Resilient Storage

## 8.4 - 2021-07-27

Sono stati aggiornati i seguenti pacchetti:

* thunderbird -> thunderbird-78.12.0-3.el8_4

## 8.4 - 2021-07-21

Sono stati aggiornati i seguenti pacchetti:

* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909
* systemd -> systemd-239-45.el8_4.2 -> Addresses CVE-2021-33910
* firefox
* java-1.8.0-openjdk
* java-11-openjdk

## 8.4 - 2021-07-12

Sono stati aggiornati i seguenti pacchetti:

* rocky-release
* linuxptp
* rpaste
* ovn2.13 (NFV)

Sono stati aggiornati i seguenti moduli:

* python36

### Modifiche aggiuntive

È stata implementata la firma sperimentale dei metadati del repository. Se si vuole provare, impostare la seguente opzione nei file Rocky-X.repo:

```
repo_gpgcheck=1
```

### Pagina Coming Soon

* Archiviazione dei repository dei componenti aggiuntivi:

  * Supporto per Glusterfs 9

## 8.4 - 2021-06-30

### Aggiornamenti del pacchetto

Sono stati aggiornati i seguenti pacchetti:

* NetworkManager -> NetworkManager-11.30.0-9.el8_4
* cloud-init -> cloud-init-20.3-10.el8_4.3
* cmake -> cmake-3.18.2-11.el8_4
* edk2 -> edk2-20200602gitca407c7246bf-4.el8_4.1
* exiv2 -> exiv2-0.27.3-2.el8
* firewalld -> firewalld-0.8.2-7.el8_4
* fwupd -> fwupd-1.5.9-1.el8_4
* gnome-session -> gnome-session-3.28.1-10.el8_4.1
* kernel -> kernel-4.18.0-305.7.1.el8_4
* kexec-tools -> kexec-tools-2.0.20-46.el8_4.1
* libpq -> libpq-13.3-1.el8_4
* libreport -> libreport-2.9.5-15.el8.rocky.2
* libxml2 -> libxml2-2.9.7-9.el8_4.2
* lz4 -> lz4-1.8.3-3.el8_4
* nmstate -> nmstate-1.0.2-11.el8_4
* nvme-cli -> nvme-cli-1.12-4.el8_4
* openldap -> openldap-2.4.46-17.el8_4
* osbuild-composer -> osbuild-composer-28.6-1.el8_4
* resource-agents -> resource-agents-4.1.1-90.el8_4.5
* rocky-logos -> rocky-logos-84.5-8.el8
* rocky-release -> rocky-release-8.4-29.el8
* rpm -> rpm-4.14.3-14.el8_4
* rsyslog -> rsyslog-8.1911.0-7.el8_4.2
* sanlock -> sanlock-3.8.3-3.el8_4
* sssd -> sssd-2.4.0-9.el8_4.1
* subscription-manager -> subscription-manager-1.28.13-3.el8_4
* systemd -> systemd-239-45.el8_4.1
* tuned -> tuned-2.15.0-2.el8_4.1
* unzip -> unzip-6.0-45.el8_4

Sono stati aggiornati i seguenti moduli:

* PyYAML -> PyYAML-5.4.1-1.module+el8.4.0+595+c96abaa2
* 389-ds -> 1.4.3.16-16
* go-toolset -> go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3
* golang -> golang-1.15.13-3.module+el8.4.0+591+0da41cc3
* idm:DL1 -> ipa-4.9.2-4
* idm:client -> (ricostruito con ipaplatform=rhel per sincronizzarsi con il modulo DL1)
* pgaudit -> pgaudit-1.4.0-6.module+el8.4.0+587+d46efd10
* postgres-decoderbufs -> postgres-decoderbufs-0.10.0-2.module+el8.4.0+587+d46efd10
* postgresql -> postgresql-12.7-1.module+el8.4.0+587+d46efd10
* python38 -> python38-3.8.6-3.module+el8.4.0+595+c96abaa2
* ruby -> ruby-2.5.9-107.module+el8.4.0+592+03ff458a
* ruby:2.5 -> 2.5.9-107
* ruby:2.6 -> 2.6.7-107
* ruby:2.7 -> 2.7.3-136
* rubygem-abrt -> rubygem-abrt-0.3.0-4 / rubygem-abrt-0.4.0-1
* rubygem-bson -> rubygem-bson-4.3.0-2 / rubygem-bson-4.5.0-1 / rubygem-bson-4.8.1-1
* rubygem-bundler -> rubygem-bundler-1.16.1-3.module+el8.4.0+592+03ff458a
* rubygem-mongo -> rubygem-mongo-2.5.1-2 / rubygem-mongo-2.8.0-1 / rubygem-mongo-2.11.3-1
* rubygem-pg -> rubygem-pg-1.0.0-2 / rubygem-pg-1.1.4-1 / rubygem-pg-1.2.3-1


### Contesto

Alcuni moduli e pacchetti sono stati aggiornati di routine dall'upstream.

I pacchetti rocky regolari sono stati aggiornati per risolvere i seguenti problemi:

* rocky-release

  * Aggiungere i repository devel e debuginfo per uno stato futuro
  * Viene fornito per scopi di mock/buildroot

* rocky-logos

  * Migliorate le icone per le future immagini live ufficiali


### Modifiche aggiuntive

Il repository extras per aarch64 è stato aggiornato per includere vari pacchetti non inclusi da upstream. Esempi di questo tipo sono libreoffice e altre applicazioni di Gnome. Poiché non sono presenti in BaseOS o AppStream, il repository extras è il luogo appropriato per questi pacchetti.

* Viene ora fornito un repository "devel" a scopo di mock/buildroot
* Il repository Extras per aarch64 è stato aggiornato per includere i pacchetti mancanti non forniti da upstream per l'uso desktop
* rpaste è stato aggiornato per accettare input da stdin
* I pacchetti più vecchi saranno forniti nei repo durante la vita di un rilascio puntuale.

  * Ciò consente di declassare i pacchetti in caso di regressioni a monte o di risoluzione dei problemi.
