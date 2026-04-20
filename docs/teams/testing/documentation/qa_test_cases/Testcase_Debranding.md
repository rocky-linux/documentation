---
title: QA:Testcase Debranding
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria - Debranding](../../guidelines/release_criteria/r9/9_release_criteria.md#debranding) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
The Rocky Linux [Release Engineering Team](https://sig-core.rocky.page/) builds and maintains tools to manage the debranding of packages received from the upstream vendor. They have published a comprehensive [debranding guide](https://sig-core.rocky.page/documentation/patching/debrand_info/) and maintain a [list of packages](https://git.rockylinux.org/rocky/metadata/-/blob/main/patch.yml) requiring debranding patches.

This testcase will verify that all packages available on released media that Rocky Linux Release Engineering has identified as requiring debranding are debranded successfully per their specification.

## Setup
1. Obtain access to an environment with the `dnf`, and `koji` commands and access to [Rocky Linux Gitlab](https://git.rockylinux.org) and [Rocky Linux Koji](https://koji.rockylinux.org)
2. Download the ISO to be tested to test machine.
3. Configure `/etc/koji.conf` to access the [Rocky Linux Koji](https://koji.rockylinux.org).
4. Download a recent copy the [patch.yml](https://git.rockylinux.org/rocky/metadata/-/blob/main/patch.yml) from [Rocky Linux Gitlab](https://git.rockylinux.org).

!!! info "patch.yml"
    Packages listed in `patch.yml` are names of source RPMs. Binary RPMs containing content produced by building the patched source RPMs need to be validated. The easiest way to get the list of all possible binary RPMs for a particular package and arch is to ask obtain that information in koji.

## How to test
1. Mount the ISO to be tested locally.
    - Example:
    ```
    $ mount -o loop Rocky-8.5-x86_64-dvd1.iso /media
    ```
2. Determine the path(s) to the `repodata` directory(ies) on the ISO.
    - Example:
    ```
    $ find /media -name repodata
    ```
3. For each package to be validated get the names of the `noarch` and `<arch>` specific packages created from it.
    - Example:
    ```
    $ koji --quiet latest-build --arch=x86_64 dist-rocky8-compose <package>
    $ koji --quiet latest-build --arch=noarch dist-rocky8-compose <package>
    ```
4. Use `dnf` to obtain the paths to the binary packages requiring debranding.
    - Example:
    ```
    $ dnf download --urls --repofrompath BaseOS,/media/BaseOS --repo BaseOS \
        --repofrompath Minimal,/media/Minimal --repo Minimal \
        <binary_package>
    ```
5. Copy the `<binary_package>` from the media and examine it's metadata and/or contents to determine if it has obviously been patched.
    - Example:
    ```
    $ rpm -q --changelog -p <path_to_binary_package> | head | \
        grep "Release Engineering <releng@rockylinux.org>" -C2 | \
        grep -Eq "<pattern_to_find>"

    $ rpm2cpio <path_to_binary_package> |
        cpio --quiet --extract --to-stdout .<file_to_examine> | \
        grep -Eq "<pattern_to_find>"
    ```

    !!! info "NOTE"
        Note all debranding patches will patch files directly and leave very obvious traces, some patches don't even add changelog messages to use as an indicator that the package has been patched or debranded. Sometimes the only solution is to extract the binary package and examine the contents directly to find something to test.

6. Unmount the ISO.
    - Example:
    ```
    $ umount /media
    ```

## Expected Results
1. Packages tracked by Release Engineering as requiring debranding and published on installation media are, in fact, debranded per their specification.

<h3>Sample Output</h3>

=== "Success"

    ```
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

=== "Failure"

    ```
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
