---
title: QA:Test Debranding
author: Trevor Cooper
contributors: Chris Stackpole
tested_with: 8.10
tags:
  - test logiciel
  - qa
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Critère de publication associé" ""
    This test case is associated with the [Release_Criteria - Debranding](../../guidelines/release_criteria/r9/9_release_criteria.md#debranding) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

L'équipe d'ingénierie des versions de Rocky Linux (https://sig-core.rocky.page/) conçoit et maintient des outils pour gérer le débranding des paquets reçus du fournisseur en amont. Ils ont publié un guide complet de débranding (https://sig-core.rocky.page/documentation/patching/debrand_info/) et tiennent une liste de paquets (https://git.rockylinux.org/rocky/metadata/-/blob/main/patch.yml) nécessitant des correctifs de débranding.

Ce test permettra de vérifier que tous les paquets disponibles sur les supports de distribution que l'équipe d'ingénierie des versions de Rocky Linux a identifiés comme nécessitant un débranding sont bien adaptés conformément à leurs spécifications.

- Tous les éléments de cette catégorie sont considérés comme ❌ - bloqueurs de release. Cela doit être testé et, tant que ce n'est pas fait ou si le test échoue, le problème doit être correctement traité.

## Versions, architectures et fichiers ISO

| Distribution   | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  9 | ❌       | ❌       | N/A     | ❌     | ❌                           |
| Rocky Linux 10 | ❌       | ❌       | ❌       | ❌     | ❌                           |

## Mise en place

1. Obtenez l'accès à un environnement avec les commandes `dnf` et `koji` et l'accès à [Rocky Linux Gitlab](https://git.rockylinux.org) et [Rocky Linux Koji](https://koji.rockylinux.org)
2. Téléchargez le fichier ISO à vérifier sur la machine de test.
3. Configurez `/etc/koji.conf` pour accéder à [Rocky Linux Koji](https://koji.rockylinux.org).
4. Téléchargez une copie récente du [patch.yml](https://git.rockylinux.org/rocky/metadata/-/blob/main/patch.yml) depuis [Rocky Linux Gitlab](https://git.rockylinux.org).

!!! info "patch.yml" "
    "  
    Packages listed in `patch.yml` are names of source RPMs. Binary RPMs containing content produced by building the patched source RPMs need to be validated. The easiest way to get the list of all possible binary RPMs for a particular package and arch is to ask obtain that information in koji.

## Marche à suivre

1. Monter l'image ISO à tester localement.

   - Exemple :

   ```bash
   mount -o loop Rocky-8.5-x86_64-dvd1.iso /media
   ```

2. Déterminez le(s) chemin(s) d'accès au(x) répertoire(s) `repodata` sur l'ISO.

   - Exemple :

   ```bash
   find /media -name repodata
   ```

3. Pour chaque paquet à valider, obtenez les noms des paquets spécifiques `noarch` et `<arch>` créés à partir de celui-ci.

   - Exemple :

   ```bash
   koji --quiet latest-build --arch=x86_64 dist-rocky8-compose <package>
   koji --quiet latest-build --arch=noarch dist-rocky8-compose <package>
   ```

4. Utilisez `dnf` pour obtenir les chemins d'accès aux paquets binaires nécessitant un débranding.

   - Exemple :

   ```bash
   $ dnf download --urls --repofrompath BaseOS,/media/BaseOS --repo BaseOS \
       --repofrompath Minimal,/media/Minimal --repo Minimal \
       <binary_package>
   ```

5. Copiez le `<binary_package>` du média et examinez ses métadonnées et/ou son contenu pour déterminer s'il a manifestement été patché.

   - Exemple :

   ```bash
   $ rpm -q --changelog -p <path_to_binary_package> | head | \
   grep "Release Engineering <releng@rockylinux.org>" -C2 | \
   grep -Eq "<pattern_to_find>"

   $ rpm2cpio <path_to_binary_package> |
   cpio --quiet --extract --to-stdout .<file_to_examine> | \
   grep -Eq "<pattern_to_find>"
   ```

       !!! info "REMARQUE" ""
               Note all debranding patches will patch files directly and leave very obvious traces, some patches don't even add changelog messages to use as an indicator that the package has been patched or debranded. Sometimes the only solution is to extract the binary package and examine the contents directly to find something to test.

6. Unmount the ISO.

   - Exemple :

   ```bash
   umount /media
   ```

## Résultats escomptés

1. Les packages suivis par l'équipe d'ingénierie des versions comme nécessitant un débranding et publiés sur les supports d'installation sont correctement adaptés conformément à leurs spécifications.

### Exemple de résultat

\=== "Success"

```bash
$ sudo mount -o loop Rocky-8.5-aarch64-minimal.iso /media
mount: /media: WARNING: device write-protected, mounted read-only.

$ find /media -name repodata
/media/BaseOS/repodata
/media/Minimal/repodata

$ curl -LOR https://git.rockylinux.org/rocky/metadata/-/raw/main/patch.yml
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
100  3410  100  3410    0     0  20419      0 --:--:-- --:--:-- --:--:-- 20419

$ yq .debrand.all[] patch.yml | column -x -c 100 -o " "
abrt                   anaconda               anaconda-user-help   chrony
cloud-init             cockpit                crash                dhcp
dnf                    firefox                fwupd                gcc
gcc-toolset-9-gcc      gcc-toolset-10-gcc     gcc-toolset-11-gcc   gcc-toolset-12-gcc
gnome-settings-daemon  grub2                  httpd                initial-setup
kernel                 kernel-rt              libdnf               libreoffice
libreport              nginx                  opa-ff               opa-fm
openscap               pesign                 PackageKit           python-pip
python3                redhat-rpm-config      scap-security-guide  shim
shim-unsigned-x64      shim-unsigned-aarch64  sos                  subscription-manager
systemd                thunderbird            WALinuxAgent

$ ./yq .debrand.r8[] patch.yml | column -x -c 100 -o " "
dotnet3.0  fwupdate  gnome-boxes  libguestfs  pcs  plymouth
python2

NOTE: Only a single package will be shown in this Example.

$ koji --quiet latest-build --arch=x86_64 dist-rocky8-compose sos

$ koji --quiet latest-build --arch=noarch dist-rocky8-compose sos
sos-4.1-9.el8_5.rocky.3.noarch
sos-audit-4.1-9.el8_5.rocky.3.noarch

$ dnf download --urls --repofrompath BaseOS,/media/BaseOS --repo BaseOS \
--repofrompath Minimal,/media/Minimal --repo Minimal \
sos sos-audit | grep -E "^file"
file:///media/BaseOS/Packages/s/sos-4.1-5.el8.noarch.rpm
file:///media/BaseOS/Packages/s/sos-audit-4.1-5.el8.noarch.rpm

$ rpm -q --changelog -p /media/BaseOS/Packages/s/sos-4.1-5.el8.noarch.rpm | \
  head | grep "Release Engineering <releng@rockylinux.org>" -C2
* Mon Oct 18 2021 Release Engineering <releng@rockylinux.org> - 4.1-5
- Remove Red Hat branding from sos
$ echo $?
0

$ rpm -q --changelog -p /media/BaseOS/Packages/s/sos-audit-4.1-5.el8.noarch.rpm | \
  head | grep "Release Engineering <releng@rockylinux.org>" -C2
* Mon Oct 18 2021 Release Engineering <releng@rockylinux.org> - 4.1-5
- Remove Red Hat branding from sos
$ echo $?
0

$ umount /media
```

\=== "Failure"

```bash
$ sudo mount -o loop Rocky-8.5-aarch64-minimal.iso /media
mount: /media: WARNING: device write-protected, mounted read-only.

$ find /media -name repodata
/media/BaseOS/repodata
/media/Minimal/repodata

$ curl -LOR https://git.rockylinux.org/rocky/metadata/-/raw/main/patch.yml
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                             Dload  Upload   Total   Spent    Left  Speed
100  3410  100  3410    0     0  20419      0 --:--:-- --:--:-- --:--:-- 20419

$ yq .debrand.all[] patch.yml | column -x -c 100 -o " "
abrt                   anaconda               anaconda-user-help   chrony
cloud-init             cockpit                crash                dhcp
dnf                    firefox                fwupd                gcc
gcc-toolset-9-gcc      gcc-toolset-10-gcc     gcc-toolset-11-gcc   gcc-toolset-12-gcc
gnome-settings-daemon  grub2                  httpd                initial-setup
kernel                 kernel-rt              libdnf               libreoffice
libreport              nginx                  opa-ff               opa-fm
openscap               pesign                 PackageKit           python-pip
python3                redhat-rpm-config      scap-security-guide  shim
shim-unsigned-x64      shim-unsigned-aarch64  sos                  subscription-manager
systemd                thunderbird            WALinuxAgent

$ ./yq .debrand.r8[] patch.yml | column -x -c 100 -o " "
dotnet3.0  fwupdate  gnome-boxes  libguestfs  pcs  plymouth
python2

NOTE: Only a single package will be shown in this Example.

$ koji --quiet latest-build --arch=x86_64 dist-rocky8-compose sos

$ koji --quiet latest-build --arch=noarch dist-rocky8-compose sos
sos-4.1-9.el8_5.rocky.3.noarch
sos-audit-4.1-9.el8_5.rocky.3.noarch

$ dnf download --urls --repofrompath BaseOS,/media/BaseOS --repo BaseOS \
--repofrompath Minimal,/media/Minimal --repo Minimal \
sos sos-audit | grep -E "^file"
file:///media/BaseOS/Packages/s/sos-4.1-5.el8.noarch.rpm
file:///media/BaseOS/Packages/s/sos-audit-4.1-5.el8.noarch.rpm

$ rpm -q --changelog -p /media/BaseOS/Packages/s/sos-4.1-5.el8.noarch.rpm | \
head | grep "Release Engineering <releng@rockylinux.org>" -C2
$ echo $?
1

$ rpm -q --changelog -p /media/BaseOS/Packages/s/sos-audit-4.1-5.el8.noarch.rpm | \
head | grep "Release Engineering <releng@rockylinux.org>" -C2
$ echo $?
1

$ umount /media
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
