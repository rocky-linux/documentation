---
title: Rocky Linux Repositories
author: Release Engineering
contributors: Steven Spencer
---

Rocky Linux provides several repositories that might differ between major releases. Community approved repositories exist and are installable as well, typically from the extras repository.

## About 'enabled' and 'disabled' repository configuration files

Please read `man 5 dnf.conf`, in particular the section of `enabled` under the `REPO` section. A line containing `enabled=0` or `enabled=1` will disable or enable a repository. You can also modify this using `dnf config-manager --set-enabled` or `--set-disabled`. When done, you should run `dnf clean all`.

## Version policy

During a Rocky Linux minor release lifecycle, as a package receives updates, the previous version will coexist in the repositories to allow a user to downgrade in case of a regression or other use cases (such as security only updates). Upon new minor release, all previous updates or versions that are *not* the latest are not carried over.

You can find a more detailed explanation of the version policy in our [version information here](../../releases/index.md).

### Notes on difference between X and X.Y in mirrors

You might notice that on mirrors or our [primary download location](https://dl.rockylinux.org/pub/rocky) that there are X and X.Y directories. Rocky Linux sets the `releasever` `dnf` variable to the major version (such as 8, 9, 10) rather than a minor version (8.6, 9.0, 10.1, and so on). This effectively means that it will ask the mirror manager or configured `baseurl` for that version, which will always point to the latest available release at a given time. This helps simplify the user experience when installing software and updating systems throughout the life of a release.

When a new release is available, the symlink changes to point to the new directory, and mirror manager also undergoes changes to accomodate the new release, which should be transparent to most users.

## Base repositories

Each major release has a set of repositories that come default with the distribution. Below is a list of common repositories for each major release, including their `repoid`.

| Repository       | repoid                    | Rocky 8 | Rocky 9 | Rocky 10 | Enabled |
|------------------|---------------------------|---------|---------|----------|---------|
| BaseOS           | baseos                    | Yes     | Yes     | Yes      | Yes     |
| AppStream        | appstream                 | Yes     | Yes     | Yes      | Yes     |
| PowerTools       | powertools                | Yes     | No      | No       | No      |
| CRB              | crb                       | No      | Yes     | Yes      | No      |
| HighAvailability | ha (8) / highavailibility | Yes     | Yes     | Yes      | No      |
| ResilientStorage | rs (8) / resilientstorage | Yes     | Yes     | No       | No      |

### Notes on code ready builder (CRB)

CRB is "Code Ready Builder" - PowerTools was a carryover from CentOS, which is still the equivalent of CRB in RHEL. `crb` will be the repository name going forward in Rocky Linux and other derivatives starting with version 9. Rocky Linux 8 matches CentOS's use of PowerTools to be as compatible as possible with what users expect.

### Notes on lack of "updates" `repo`

In older major versions, it was normal to have an "updates" `repo`. Fedora for example still follows this. However, in EL8, EL9, and EL10, there is no "updates" repository. This means all updates happen as is in the same repository. So if `bash` receives an update, it will land in `baseos` as there is no updates repository.

## Extra repositories

There are extra repositories offered by Rocky Linux.

| Repository       | repoid           | Rocky 8 | Rocky 9 | Rocky 10 | Enabled |
|------------------|------------------|---------|---------|----------|---------|
| Extras           | extras           | Yes     | Yes     | Yes      | Yes     |
| Plus             | plus             | Yes     | Yes     | Yes      | No      |
| Security         | security         | Yes     | Yes     | Yes      | No      |
| RT (real time)   | rt               | Yes     | Yes     | Yes      | No      |
| NFV              | nfv              | Yes     | Yes     | Yes      | No      |
| SAP / SAP HANA   | sap / saphana    | No      | Yes     | Yes      | No      |
| Devel / devel    | devel            | Yes     | Yes     | Yes      | No      |

### Notes on "Extras"

Extras contains packages providing additional functionality to Rocky, without breaking upstream compatibility. For example, `rpaste` used for sending logs, configuration, or system information to our paste bin.

These are not tested by upstream nor available in the upstream product.

### Notes on "Plus"

Plus contains packages that might fit into one of the following:

* A) replace a core component by way of patched functionality
* B) build a component that was originally exclusive for one architecture (for example, `open-vm-tools` built for x86_64 but not aarch64 in Rocky 8)
* C) providing packages built but not provided by the upstream, but included because of requests for availability from the community
* D) providing packages observed as a net benefit to both maintainers and users that deserves a proper place

Packages that fall under A and B will have a `.plus` added to their version tag. These are not tested nor available in the upstream product.

Packages that fall under C and D are rare, but will occasionally happen from time to time.

### Notes on "Security"

Security contains packages seen as urgent security updates, where a critical vulnerability exists, and public exploitation is available, AND where the upstream might not yet have the package patched.

The intension of the security repository is to provide hot-fixes as a temporary solution for urgent circumstances involving critical security exposure and immediate risk mitigation. The design of the versioning of these packages is such that the official upstream packages will always update our hot-fixes. It is not a replacement for the normal Rocky Linux release process and you should not interpret this as a broader change in our commitment to upstream Enterprise Linux compatibility.

### Notes on "Devel"

The devel (development) repository contains packages that are not normally provided in the base nor extra repositories. The purposes of these packages is providing dependencies or development packages that might not be available upstream. As such, you should treat this as a "buildroot" repository, as this repository might contain *all* packages currently in for Rocky Linux. Additionally, the repository provides i686 architecture for the cases of building multilib, as it is not a primary architecture released.

You should only enable this repository for package building or development purposes, and **should not** be permanently enabled.

### Notes on "SIG" repositories

Some Special Interest Groups provide additional repositories that enhance the Enterprise Linux experience. These repositories are installable via `rocky-release-*` and `centos-release-*` packages found in the `extras` repository.

You can find all [SIG repositories here](https://dl.rockylinux.org/pub/sig).

## Vault

The vault is a historic archive of previous Rocky Linux releases. These previous releases, including ISOs and other images, are typically moved into the vault area of our tier 0 mirror between a day and a week when a new minor release version is available. You can find [the vault here](https://dl.rockylinux.org/vault/rocky).

!!! warning

    The vault is a historic archive of previous releases of Rocky Linux and not for general use. These are versions that are NOT supported and are NOT recommended for general use as they contain unfixed bugs and unpatched security vulnerabilities.

    The community may not be able to assist you with issues with these releases, so you should always keep your systems up to date with `dnf upgrade`.

## Community approved repositories

As with Enterprise Linux and Fedora, there are additional community approved repositories for Rocky Linux:

| **Repository and Details** |
| - |
| **Extra Packages for Enterprise Linux (EPEL)** - [EPEL](https://docs.fedoraproject.org/en-US/epel/) is by far the most commonly used repository for Enterprise Linux. EPEL provides rebuilds of Fedora packages for every supported enterprise linux. Packages in this repository do not replace the base. You can install EPEL by running `dnf install epel-release` and it will install from the extras repository. The package will automatically have EPEL enabled. You can get support for the EPEL in `#epel` on Libera. |
| **Community Enterprise Linux Repository (ELRepo)** - [ELRepo](http://elrepo.org/) focuses on newer kernels and `kmod` driver packages to enhance hardware support for currently supported Enterprise Linux versions. This includes display, filesystem, network, and storage drivers. You can install the necessary repository files by running `dnf install elrepo-release`. Note that you have to enable the kernel repositories. |
| **RPM Fusion** - [RPM Fusion](https://rpmfusion.org/) provides software that the Fedora Project or Red Hat does not want to ship in Enterprise Linux and Fedora. These repositories do rely on EPEL. The policy is to **not** replace EPEL nor base packages. You can install the free repository by running `dnf install rpmfusion-free-release`. |
| **Remi Repository** - [Remi](http://rpms.remirepo.net/) maintains a large collection of RPMs, including latest versions of PHP, among other things. You can find [his FAQ here](http://blog.remirepo.net/pages/English-FAQ). This is a collection of repositories. Using the `-safe` series of repositories will ensure that you will not replace or overwrite anything from the base. However, be aware that these repositories do **not** play well with other third party repositories. You will need to use caution as you enable more repositories on your system. |
| **GhettoForge** - [GhettoForge](http://ghettoforge.net/) provides packages not in other third party repositories. Packages that overwrite the base would be in the `gf-plus` repository. Please see [usage](http://ghettoforge.net/index.php/Usage) for more information. |
| **Trinity Desktop Environment (TDE)** - [TDE](http://www.trinitydesktop.org/about.php) provides Enterprise Linux packages for a KDE 3.5 style desktop environment. As of this writing, EL8 and EL9 repositories exist. You can find [TDE support resources here](https://www.trinitydesktop.org/support.php). |
| **ZFS On Linux** - The [ZFS on Linux](http://www.zfsonlinux.org/) project is an implementation of OpenZFS, designed to work in a Linux environment. While this filesystem is very popular, it receives no testing or support from Rocky Release Engineering or Testing. Use at your own risk. |
| **Upstream centos-release-*** - In the extras repository, there are `centos-release-*` packages that provide additional repositories from the Special Interest Groups of CentOS. As they are available in extras and should work on Rocky Linux, you can  consider them approved and community supported. |

### Notes on "EPEL"

Using **EPEL** requires that you enable the `CRB` or `PowerTools` repository on your system, as some EPEL packages depend on packages from that repository. There are multiple ways to enable the repository:

* Using `dnf`

    * Rocky 8: `dnf config-manager --set-enabled powertools`
    * Rocky 9+: `dnf config-manager --set-enabled crb`

* Modifying the `repo` files and setting `enabled=1`

    * Rocky 8: `/etc/yum.repos.d/Rocky-PowerTools.repo` under `[powertools]`
    * Rocky 9+: `/etc/yum.repos.d/rocky.repo` under `[crb]`

* Running `dnf install epel-release` and then running `crb enable`

We recommend checking out the [EPEL Quickstart Guide](https://docs.fedoraproject.org/en-US/epel/#_quickstart) for more information.

### Notes on unlisted repositories

If there is a repository that you use (or maintain) and you do not see it here, it is likely that we might not know of it. Unfortunately, this happens. If there are popular repositories in use in the Enterprise Linux community that you think we should add to the list, you can drop us a line in Mattermost, IRC, or an issue to the wiki git repository.
