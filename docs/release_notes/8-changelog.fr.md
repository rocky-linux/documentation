---
title: Change Log
author: Louis Abel
contributors: Steven Spencer, tianci li
tags:
  - rocky changelog
  - changelog
---

# Rocky Linux 8 Change Log

Rocky Linux 8 recevra, au fil du temps, des mises à jour incrémentielles et des mises à jour mineures, lorsque leurs versions en amont seront mises à jour et pousseront les leurs. Cette page fournira des détails et des informations sur les changements au fur et à mesure des évolutions. Un système exécutant Rocky Linux peut mettre à jour son système à tout moment en exécutant `dnf update`. La mise à jour de ce document peut parfois être retardée. Pour vérifier la présence de nouvelles mises à jour, vous pouvez visiter les archives de la liste de diffusion [Annonces de Rocky](https://lists.resf.org/archives/list/rocky-announce@lists.resf.org/).

### Mises à jour

Les mises à jour publiées depuis la distribution en amont sont publiées sur nos architectures. Nous recommandons fortement à tous les utilisateurs d'appliquer *toutes* les mises à jour, y compris le contenu publié aujourd'hui, sur vos machines Rocky Linux. Cela peut être fait en exécutant la commande `dnf update`.

Tous les composants de Rocky Linux sont construits à partir des sources hébergées sur [git.rockylinux.org](https://git.rockylinux.org). En outre, les SRPMs sont publiés à côté des dépôts dans un répertoire "source" correspondant. Vous pouvez les trouver sur n'importe lequel de nos miroirs. Ces paquets sources correspondent aux RPM binaires que nous publions.

## 8.5 - 2022-03-15

Les paquets suivants ont été mis à jour depuis le 15 mars 2022 :

* firefox: firefox-91.4.0-1.el8_5 -> firefox-91.5.0-1.el8_5
* tzdata-2022a-1.el8
* httpd-2.4.37-43.module+el8.5.0+747+83fae388.3
* openssl-1.1.1k-6.el8_5

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* dotnet6.0: dotnet6.0-6.0.100-0.10.el8_5 -> dotnet6.0-6.0.101-2.el8_5

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* grafana: grafana-7.5.9-4.el8 -> grafana-7.5.9-5.el8_5
* CVE-2022-25235
* virt-rhel-8050020211221163306.b4937e53
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

### Notes techniques de version

Nous voudrions nous excuser pour le manque d'annonces au cours des deux dernières semaines. Actuellement ces annonces sont manuelles et il y a des plans en cours pour les rendre plus automatisés avec moins d'interaction humaine.

Avec la sortie du RHEL 8. bêta, nous examinerons ce qui est en train de changer et ce que et comment nous devrons faire nos constructions dans les semaines à venir avant son éventuelle GA fin avril ou mai. Pendant ce temps, nous avons également travaillé sur l'amorçage des paquets RHEL 9 bêta pour éventuellement être importés, reconstruit, et testé dans notre nouveau système de compilation.

## 8.5 - 2022-01-03

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* CVE-2021-44716
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

Les modules suivants ont été mis à jour :

* 389-ds-base: 389-ds-base-1.4.3.23-10.module+el8.5.0+700+370e33d5 -> 389-ds-base-1.4.3.23-12.module+el8.5.0+722+e2a0b219
* dotnet6.0: dotnet6.0-6.0.100-0.10.el8_5 -> dotnet6.0-6.0.101-2.el8_5
* virt
* dévelope-viral

## 8.5 - 2021-12-22

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* CVE-2021-20321
* thunderbird: thunderbird-91.6.0-1.el8_5.plus -> thunderbird-91.7.0-2.el8_5.plus

Les paquets suivants ont été mis à jour depuis le 16 décembre 2021 :

* virt-rhel-8050020211221163306.b4937e53
* CVE-2022-25235
* grafana: grafana-7.5.9-4.el8 -> grafana-7.5.9-5.el8_5

## 8.5 - 2021-12-17

Les modules suivants ont été mis à jour :

* selinux-policy: selinux-policy-3.14.3-80.el8 -> selinux-policy-3.14.3-80.el8_5.2
* dotnet5.0: dotnet5.0-5.0.211-1.el8_5 -> dotnet5.0-5.0.212-1.el8_5
* dotnet6.0: dotnet6.0-6.0.102-1.el8_5 -> dotnet6.0-6.0.103-4.el8_5
* firefox: firefox-91.6.0-1.el8_5 -> firefox-91.7.0-3.el8_5
* kernel: kernel-4.18.0-348.12.2.el8_5 -> kernel-4.18.0-348.20.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.12.2.rt7.143.el8_5 -> kernel-rt-4.18.0-348.20.1.rt7.150.el8_5

CVE associés :

* dotnet5.0: dotnet5.0-5.0.209-1.el8_5 -> dotnet5.0-5.0.210-1.el8_5
* CVE-2022-0847

## 8.5 - 2021-12-16

Les modules suivants ont été mis à jour :

* CVE-2020-25717

Suite à une demande, le paquet kernel-rt-kvm a été ajouté au dépôt RT.

* go-toolset-rhel8-8050020211215173118-8aa62369

## 8.5 - 2021-12-13

Les modules suivants ont été mis à jour :

* samba: samba-4.14.5-2.el8 -> samba-4.14.5-7.el8_5

CVE associés :

* CVE-2016-2124
* CVE-2022-22816
* CVE-2022-22817

## 8.5 - 2021-12-12

Les paquets suivants ont été mis à jour depuis le 10 décembre 2021 :

* WALinuxAgent: WALinuxAgent-2.3.0.2-2.el8 -> WALinuxAgent-2.3.0.2-2.el8.rocky.0
* ruby-2.6-8050020220216165459.b4937e53

## 8.5 - 2021-12-10

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* python27
* thunderbird: thunderbird-91.5.0-1.el8.plus -> thunderbird-91.6.0-1.el8_5.plus

## 8.5 - 2021-12-09

Suite à une demande, le paquet kernel-rt-kvm a été ajouté au dépôt RT.

* WALinuxAgent -> Nous avons ajouté le soutient direct à Rocky ici ainsi que dans une PR amont à Microsoft
* dotnet5.0: dotnet5.0-5.0.210-1.el8_5 -> dotnet5.0-5.0.211-1.el8_5
* dotnet6.0: dotnet6.0-6.0.101-2.el8_5 -> dotnet6.0-6.0.102-1.el8_5
* firefox: firefox-91.5.0-1.el8_5 -> firefox-91.6.0-1.el8_5

## 8.5 - 2021-12-03

Les paquets suivants ont été mis à jour depuis le 09 décembre 2021 :

* thunderbird: thunderbird-91.3.0-2.el8_4 ->

CVE associés :

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0

## 8.5 - 2021-12-02

Les paquets suivants ont été mis à jour depuis le 03 décembre 2021 :

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* mailman: CVE-2021-44227

## 8.5 - Supplémentaire - 2021-11-30

Les paquets suivants ont été mis à jour :

* mailman-2.1-8050020211202160117.fd901a62
* cockpit: cockpit-251.1-1.el8 -> cockpit-251.3-1.el8_5
* cryptsetup: cryptsetup-2.3.3-4.el8 -> cryptsetup-2.3.3-4.el8_5.1
* dnf-plugins-core: dnf-plugins-core-4.0.21-3.el8 -> dnf-plugins-core-4.0.21-4.el8_5
* frr: frr-7.5-4.el8 -> frr-7.5-4.el8_5.2
* gnome-control-center: gnome-control-center-3.28.2-28.el8 -> gnome-control-center-3.28.2-29.el8_5
* nispor: nispor-1.1.1-1.el8 -> nispor-1.1.1-2.el8_5
* nmstate: nmstate-1.1.0-3.el8 -> nmstate-1.1.0-5.el8_5
* ostre: ostree-2021.3-1.el8 -> ostree-2021.3-2.el8_5
* resource-agents: resource-agents-4.1.1-98.el8 -> resource-agents-4.1.1-98.el8_5.2
* rpm: rpm-4.14.3-19.el8 -> rpm-4.14.3-19.el8_5.2
* sos: sos-4.1-5.el8.rocky.3 -> sos-4.1-9.el8_5.rocky.3
* spirv-tools: spirv-tools-2021.3-1.20210825.git1fbed83.el8 -> spirv-tools-2021.4-3.20211110.git21e3f68.el8_5
* sssd: sssd-2.5.2-2.el8_5.3 -> sssd-2.5.2-2.el8_5.4
* tcpdump: tcpdump-14:4.9.3-2.el8 -> tcpdump-14:4.9.3-2.el8_5.1
* tigervnc: tigervnc-1.11.0-9.el8 -> tigervnc-1.11.0-10.el8_5
* vim: vim-2:8.0.1763-16.el8 -> vim-2:8.0.1763-16.el8_5.4
* virtio-win: virtio-win-1.9.19-1.el8 -> virtio-win-1.9.24-2.el8_5
* header-vulkan-headers: vulkan-headers-1.2.189.0-1.el8 -> vulkan-headers-1.2.198.0-1.el8_5
* vulkan-loader: vulkan-loader-1.2.189.0-1.el8 -> vulkan-loader-1.2.198.0-2.el8_5
* vulkan-tools: vulkan-tools-1.2.189.0-1.el8 ->vulkan-tools-1.2.198.0-1.el8_5
* vulkan-validation-layers: vulkan-validation-layers-1.2.189.0-2.el8 ->vulkan-validation-layers-1.2.198.0-4.el8_5

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* ncurses-static
* freeradius
* nodejs
* pki-core
* virt
* dévelope-viral

## 8.5 - 2021-11-29

Les paquets suivants ont été mis à jour :

* open-vm-tools (version spécifique aarch64 uniquement)
* nginx: nginx-1:1.20.0-2.module+el8.5.0+669+b11495b0 -> nginx-1:1.20.1-1.module+el8.5.0+729+3f70613e
* samba: samba-4.14.5-7.el8_5 -> samba-4.14.5-9.el8_5

Les paquets suivants ont été mis à jour :

* openldap-servers (toutes architectures)

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5
* CVE-2021-23017

## 8.5 - 2021-11-24

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* nss-3.67.0-7.el8_5: CVE-2021-43527

## 8.5 - 2021-11-22

CVE associés :

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1

Les paquets actuels dans plus (à partir du 30-11-2021) sont :

* mailman-2.1-8050020211123230959.fd901a62

## 8.5 - 2021-11-16

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* CVE-2021-42096
* polkit: polkit-0.115-12.el8 -> polkit-0.115-13.el8_5.1

Les paquets suivants ont été mis à jour depuis le 17 décembre 2021 :

* clang: clang-12.0.1-2.module+el8.5.0+692+8756646f -> clang-12.0.1-4.module+el8.5.0+715+58f51d49

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* llvm-toolset-rhel8-8050020211122023437.b4937e53
* CVE-2021-4034

## 8.5 - 2021-11-14

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* annobin: annobin-9.65-1.el8 -> annobin-9.72-1.el8_5.2

## 8.5 - 2022-01-12

CVE associés :

* insights-client: insights-client-3.1.5-1.el8 (Groupe Standard)
* java-17-openjdk: java-17-openjdk-1:17.0.1.0.12-2.el8_5 -> java-17-openjdk-1:17.0.2.0.8-4.el8_5
* kernel: kernel-4.18.0-348.7.1.el8_5 -> kernel-4.18.0-348.12.2.el8_5
* kernel-rt: kernel-rt-4.18.0-348.7.1.rt7.137.el8_5 -> kernel-rt-4.18.0-348.12.2.rt7.143.el8_5
* libarchive: libarchive-3.3.3-1.el8 -> libarchive-3.3.3-1.el8_5
* libreswan: libreswan-4.4-1.el8 -> libreswan-4.4-4.el8_5

Les paquets suivants ont été mis à jour depuis le 17 décembre 2021 :

* rust-toolset-rhel8-8050020211112021616.f73640c0
* CVE-2021-45463
* CVE-2021-4155

## 8.5 - 2022-01-11

CVE associés :

* kernel: kernel-4.18.0-305.19.1 (9-15)
* thunderbird: thunderbird-91.4.0-2.el8_5 -> thunderbird-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8.plus -> thunderbird-91.5.0-1.el8.plus

## 8.5 - 2022-01-03

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* thunderbird: mis à jour en 78.14.0
* insights-client: insights-client-3.1.5-1.el8 (Groupe Standard)

## 8.5 - 2021-12-22

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* extras -> Les paquets CentOS sig release ont été ajoutés

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4

## 8.5 - 2021-12-17

Les paquets suivants ont été mis à jour depuis le 17 décembre 2021 :

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

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* 389-ds-base: 389-ds-base-1.4.3.16-16.module+el8.4.0+596+159889e5 -> 389-ds-base-1.4.3.16-19.module+el8.4.0+636+837ee950
* extras -> Les paquets CentOS sig release ont été ajoutés
* CVE-2021-20257
* CVE-2021-3712

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* virt-rhel-8050020211221163306.b4937e53
* virt-devel-rhel-8050020211221163306.b4937e53
* postgresql-13-8050020211221161313.b4937e53
* postgresql-12-8050020211221161311.b4937e53
* freeradius-3.0-8050020211221161359.ab0f257b
* 389-ds-1.4-8050020211221162652.1a75f91c

### Notes techniques de version

Le paquet rocky-release a été mis à jour pour ajouter le countme=1 aux dépôts de base pour Rocky Linux, à la manière des dépots epel. Si vous avez modifié les fichiers des dépôts, vous aurez des fichiers .rpmnew générés, pour ne pas écraser vos modifications.

## 8.5 - 2021-12-16

Les paquets suivants ont été mis à jour depuis le 16 décembre 2021 :

* selinux-policy: selinux-policy-3.14.3-80.el8 -> selinux-policy-3.14.3-80.el8_5.2
* systemd: systemd-239-51.el8 -> systemd-239-51.el8_5.3

## 8.5 - 2021-12-13

CVE associés :

* thunderbird -> thunderbird-78.12.0-3.el8_4
* go-toolset: go-toolset-1.16.7-1.module+el8.5.0+694+f77f0bfd -> go-toolset-1.16.12-1.module+el8.5.0+720+c057d5cf
* golang: golang-1.16.7-1.module+el8.5.0+694+f77f0bfd -> golang-1.16.12-1.module+el8.5.0+720+c057d5cf
* ipa: ipa-4.9.6-6.module+el8.5.0+675+61f67439 -> ipa-4.9.6-10.module+el8.5.0+719+4f06efb6
* nodejs: nodejs-1:16.8.0-1.module+el8.5.0+702+221f14e6 -> nodejs-1:16.13.1-3.module+el8.5.0+721+4c107270
* nodejs-nodemon: nodejs-nodemon-2.0.7-1.module+el8.5.0+702+221f14e6 -> nodejs-nodemon-2.0.15-1.module+el8.5.0+721+4c107270

* kernel-rt: kernel-rt-kvm added to RT

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* go-toolset-rhel8-8050020211215173118-8aa62369
* idm-DL1-8050020211215093947-3d2c466f
* nodejs-16-8050020211215195043-b4937e53


### Notes techniques de version

Suite à une demande, le paquet kernel-rt-kvm a été ajouté au dépôt RT.

## 8.5 - 2021-12-12

Les paquets suivants ont été mis à jour depuis le 12 décembre 2021 :

* python36

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* CVE-2016-2124
* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909
* CVE-2021-23192

## 8.5 - 2021-12-10

Les paquets suivants ont été mis à jour depuis le 10 décembre 2021 :

* NetworkManager -> NetworkManager-11.30.0-9.el8_4
* libreoffice: libreoffice-1:6.4.7.2-5.el8.1 -> libreoffice-1:6.4.7.2-5.el8.2.rocky
* openscap: openscap-1.3.5-6.el8 -> openscap-1.3.5-6.el8.rocky.0.1
* pcs: pcs-0.10.10-4.el8 -> pcs-0.10.10-4.el8.rocky.0
* python2: python2-2.7.18-7.module+el8.5.0+706+735ec4b3.rocky.0.1 -> python2-2.7.18-7.module+el8.5.0+718+67e45b5f.rocky.0.2
* rocky-release: rocky-release-8.5-1.el8 -> rocky-release-8.5-2.el8

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* python27

### Notes techniques de version

Ces mises à jour sont principalement cosmétiques par nature et n'affectent pas les fonctionnalités.

* WALinuxAgent -> Nous avons ajouté le soutient direct à Rocky ici ainsi que dans une PR amont à Microsoft
* libreoffice -> Il y a eu une marque red hat trouvé. Cette mise à jour concerne la marque.
* openscap -> Il manquait des informations pour Rocky Linux.
* pcs -> Le logo avait une marque qui n'a pas été retirée
* rocky-release -> simplifies CPE_NAME
* python2 -> ajoute rocky aux distributions supportées

## 8.5 - 2021-12-09

Les paquets suivants ont été mis à jour depuis le 09 décembre 2021 :

* thunderbird: thunderbird-91.3.0-2.el8_4 ->
* thunderbird-91.4.0-2.el8_5
* thunderbird: thunderbird-91.3.0-2.el8.plus ->
* thunderbird-91.4.0-2.el8.plus

### Notes techniques de version

Thunderbird : Ceci est une mise à jour normale de la version ESR pour thunderbird. Cette mise à jour concerne les dépôts base et Plus. Le dépôt Plus contient une version de thunderbird avec support PGP.

## 8.5 - 2021-12-03

CVE associés :

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0
* firefox: firefox-91.3.0-1.el8_4 -> firefox-91.4.0-1.el8_5
* sos: sos-4.1-5.el8 -> sos-4.1-5.el8.rocky.2

### Notes supplémentaires

Les paquets suivants ont été mis à jour :

abrt : Il s'agit d'un changement presque cosmétique. Il supprime la dépendance aux plugins libreport-rhel* et rhtsupport. Ces paquets peuvent être supprimés en toute sécurité après la mise à jour du nouveau paquet abrt.

sos : Il s'agit d'un changement presque cosmétique. Elle casse la politique upstream de Rocky. Voir [cette PR pour plus de détails](https://github.com/sosreport/sos/pull/2784)

## 8.5 - 2021-12-02

Les paquets suivants ont été mis à jour depuis le 02 décembre 2021 :

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->
* mailman-3:2.1.29-12.module+el8.5.0+717+27fd1ba7.2

Les paquets suivants ont été mis à jour depuis le 22 décembre 2021 :

* mailman: CVE-2021-44227

Les paquets suivants ont été mis à jour depuis le 02 décembre 2021 :

* mailman-2.1-8050020211202160117.fd901a62


## 8.5 - Supplémentaire - 2021-11-30

Les paquets suivants ont été ajoutés au dépôt devel :

* ncurses-static

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* open-vm-tools (version spécifique aarch64 uniquement)

### Notes de développement

Le dépôt plus contient des éléments qui ne sont pas fournis dans les dépôts de base, soit parce qu'ils ne sont pas disponibles en raison de la configuration de comps et de pungi (basé sur les dépôts RHEL), soit parce qu'ils sont demandés comme versions alternatives avec des correctifs ou des fonctionnalités supplémentaires qui ne sont pas trouvées dans le dépôt de base. Le dépôt plus devrait être sécurisé pour pouvoir le conserver activé.

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* openldap-servers (toutes architectures)
* thunderbird avec support PGP (toutes architectures)
* ncurses-static (toutes architectures)
* open-vm-tools (version spécifique aarch64 uniquement)

### Problèmes connus

Le dépôt devel doit être utilisé avec précaution. Il est destiné à des fins de koji ou de buildroot et ne doit pas être activé à 100% du temps. Si vous trouvez un paquet que vous souhaitez voir dans le dépôt des développements, envoyer un mail sur rocky-devel et/ou ouvrir un rapport de bug sur https://bugs. ockylinux.org

## 8.5 - 2021-11-29

CVE associés :

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5
* nss: nss-3.67.0-6.el8_4 -> nss-3.67.0-7.el8_5

Les paquets suivants ont été mis à jour :

* nss-3.67.0-7.el8_5: CVE-2021-43527

## 8.5 - 2021-11-24

Les paquets suivants ont été mis à jour depuis le 24 novembre 2021 :

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5
* dotnet5.0-build-reference-packages: dotnet5.0-build-reference-packages-0-11.20210607git5f10a4b.el8 -> dotnet5.0-build-reference-packages-0-12.20211117git6ce5818.el8_5


## 8.5 - 2021-11-22

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1

Les paquets suivants ont été mis à jour depuis le 23 novembre 2021 :

* mailman-2.1-8050020211123230959.fd901a62

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* CVE-2021-42096
* CVE-2021-42097

## 8.5 - 2021-11-16

Les paquets suivants ont été mis à jour depuis le 16 novembre 2021 (y compris les paquets de modules mis à jour) :

* clang: clang-12.0.1-2.module+el8.5.0+692+8756646f -> clang-12.0.1-4.module+el8.5.0+715+58f51d49
* llvm-toolset: llvm-toolset-12.0.1-1.module+el8.5.0+692+8756646f -> llvm-toolset-12.0.1-1.module+el8.5.0+715+58f51d49

Les paquets suivants ont été mis à jour :

* llvm-toolset-rhel8-8050020211122023437.b4937e53

## 8.5 - 2021-11-14

Les paquets suivants ont été mis à jour depuis la version 8.5 du 14 novembre 2021 (y compris les paquets de modules mis à jour) :

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

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* insights-client: insights-client-3.1.5-1.el8 (Groupe Standard)

Les paquets suivants ont été mis à jour :

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* rust-toolset-rhel8-8050020211112021616.f73640c0
* httpd-2.4-8050020211115030420.b4937e53

### Changements supplémentaires

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

Nous sommes également au courant que notre système miroir rapporte le mauvais répertoire pour faire des mises à jour. Il allait à `kickstart` au lieu de `os`. Cela devrait être résolu et les mises à jour devraient fonctionner normalement.

## 8.4 - 2021-09-21

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

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

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* thunderbird: mis à jour en 78.14.0
* firefox: mis à jour en 78.14.0
* cyrus-imapd: mis à jour en 3.0.7-20.el8_4.1 (concerne CVE-2021-33582)
* systemtap recompilé avec dyninst 10.2 pour résoudre un rapport de bug
* rocky-release -> Mis à jour pour permettre "centos" comme identifiant

Les paquets suivants ont été mis à jour :

* extras -> Les paquets CentOS sig release ont été ajoutés

## 8.4 - 2021-08-24

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4
* libsndfile: libsndfile-1.0.28-10.el8_4 -> libsndfile-1.0.28-10.el8_4.1 -- Addresses

  * Adresse un dépassement de tampon de tas qui permettait l'exécution de code arbitraire à partir d'un fichier wav

* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.1

  * Adresses RLBZ#108

Les paquets suivants ont été mis à jour :

* RT (temps réel) - Activé en exécutant `dnf config-manager --set-enabled rt`

  * kernel-rt (realtime kernel)

## 8.4 - 2021-08-11

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

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

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* varnish -> varnish-0:6.0.6-2.module+el8.4.0+628+e1687553.1 -> Addresses CVE-2021-36740

Ajout d'un repos kickstart pour les dépôts suivants :

* BaseOS
* AppStream
* PowerTools
* High Availability
* Resilient Storage

## 8.4 - 2021-07-27

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* thunderbird -> thunderbird-78.12.0-3.el8_4

## 8.4 - 2021-07-21

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909
* systemd -> systemd-239-45.el8_4.2 -> Addresses CVE-2021-33910
* firefox
* java-1.8.0-openjdk
* java-11-openjdk

## 8.4 - 2021-07-12

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* rocky-release
* linuxptp
* rpaste
* ovn2.13 (NFV)

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* python36

### Prochainement...

La signature de métadonnées de référentiel expérimentales a été implémentée. Si vous souhaitez essayer ceci, définissez l'option suivante dans les fichiers Rocky-X.repo :

```
repo_gpgcheck=1
```

### Mises à jour des paquets

* Dépôts d'addon de stockage :

  * Support Glusterfs 9

## 8.4 - 2021-06-30

### Contexte

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

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

Les paquets suivants ont été mis à jour depuis le 3 janvier 2022 :

* PyYAML -> PyYAML-5.4.1-1.module+el8.4.0+595+c96abaa2
* 389-ds -> 1.4.3.16-16
* go-toolset -> go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3
* golang -> golang-1.15.13-3.module+el8.4.0+591+0da41cc3
* idm:DL1 -> ipa-4.9.2-4
* idm:client -> (rebuilt with ipaplatform=rhel to sync with DL1 module)
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


### Contexte

Certains modules et paquets ont été mis à jour de façon routinière par amont.

Les paquets rocheux réguliers ont été mis à jour pour répondre aux questions suivantes :

* rocky-release

  * Ajouter les dépôts devel et debuginfo pour le futur état
  * Ceci est fourni à des fins de mock/buildroot

* rocky-logos

  * Améliorer les icônes pour les futures images officielles en direct


### Prochainement...

Le dépôt d'extras pour aarch64 a été mis à jour pour inclure divers paquets qui ne sont pas inclus par amont. Des exemples de ceci serait libreoffice et d'autres applications gnome. Comme ils ne sont pas dans BaseOS ou AppStream, le dépôt d'extras est l'endroit approprié pour ces paquets.

* Un dépôt « Développement» est maintenant fourni à des fins de mock/buildroot
* Le dépôt d'extras pour aarch64 a été mis à jour pour inclure les paquets manquants non fournis par le serveur amont pour une utilisation sur le bureau
* rpaste a été mis à jour pour accepter l'entrée stdin
* Les paquets plus anciens seront fournis dans le repos pendant la durée de vie d'une version ponctuelle.

  * Cela permet de déclasser les paquets dans le cas de régressions en amont ou de dépannage.
