---
title: Rocky Linux Repositories
---

There are several repositories that are provided by Rocky Linux and may differ between major releases. There are also community approved repositories as well, installable typically from the extras repository.

## About 'enabled' and 'disabled' repository configuration files

Please read `man 5 dnf.conf`, in particular the section of `enabled` under the `REPO` section. A line containing `enabled=0` or `enabled=1` will disable or enable a repository. This can also be modified using `dnf config-manager --set-enabled` or `--set-disabled`. When this is done, it is recommended to run `dnf clean all`.

## Version Policy

During a Rocky Linux minor release lifecycle as a package receives updates, the previous version will coexist in the repositories to allow a user to downgrade in case of a regression or other use cases (such as security only updates). Upon new minor release, all previous updates/versions that are *not* the latest are not carried over.

Rocky Linux 9 does not currently support this policy and can be expected in a future Rocky Linux 9 version. Please see [Peridot Issue #18](https://github.com/rocky-linux/peridot/issues/18).

A more detailed explanation of the version policy can be found in our [Version Guide](../version).

### Notes on: Difference between X and X.Y in mirrors

You may notice that on mirrors or our [primary download location](https://dl.rockylinux.org/pub/rocky) that there are X and X.Y directories. Rocky Linux sets the `releasever` dnf variable to the major version (e.g., 8, 9) rather than a minor version (8.6, 9.0, and so on). This effectively means that it will ask the mirror manager or configured baseurl for that version, which will always point to the latest available release at a given time. This helps simplify the user experience when installing software and updating systems throughout the life of a release.

In the event a new release is available, the symlink is changed to point to the new directory, and mirror manager also undergoes changes to accomodate the new release, which should be transparent to most users.

## Base Repositories

Each major release has a set of repositories that come default with the distribution. Below is a list of common repositories for each major release, including their repo id.

| Repository       | repoid                    | Rocky 8 | Rocky 9 | Rocky 10 | Enabled |
|------------------|---------------------------|---------|---------|----------|---------|
| BaseOS           | baseos                    | Yes     | Yes     | Yes      | Yes     |
| AppStream        | appstream                 | Yes     | Yes     | Yes      | Yes     |
| PowerTools       | powertools                | Yes     | No      | No       | No      |
| CRB              | crb                       | No      | Yes     | Yes      | No      |
| HighAvailability | ha (8) / highavailibility | Yes     | Yes     | Yes      | No      |
| ResilientStorage | rs (8) / resilientstorage | Yes     | Yes     | No       | No      |

### Notes on: CRB

CRB is "Code Ready Builder" - PowerTools was a carryover from CentOS, which is still the equivalent of CRB in RHEL. `crb` will be the repository name going forward in Rocky Linux and other derivatives starting with version 9. Rocky Linux 8 matches CentOS's use of PowerTools in order to be as compatible as possible with what users expect.

### Notes on: Lack of "updates" repo

In older major versions, it was normal to have an "updates" repo. Fedora for example still follows this. However, in EL8, EL9, and likely so on, there is no "updates" repository. This means all updates happen as is in the same repository. So if `bash` receives an update, it will land in `baseos` as there is no updates repository.

## Extra Repositories

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

### Notes on: Extras

This repository contains packages that provide some additional functionality to Rocky without breaking upstream compatibility. For example, `rpaste` used for sending logs, configuration, or system information to our paste bin.

These are not tested by upstream nor available in the upstream product.

### Notes on: Plus

This repository contains packages that may fit into one of the following:

* A) replace a core component via patched functionality
* B) build a component that was originally exclusive for one architecture (e.g., open-vm-tools built for x86_64 but not aarch64 in Rocky 8)
* C) providing packages that were built but not traditionally provided by upstream, and requested to be available by the community
* D) providing packages that may be seen as a net benefit to both maintainers and users that deserves a more proper place

Packages that fall under A and B will have a `.plus` added to their version tag. These are not tested nor available in the upstream product.

Packages that fall under C and D are rare, but will occasionally happen from time to time.

### Notes on: Security

This repository allows the Rocky Linux project to provide urgent security updates in situations where a critical vulnerability exists, public exploitation is available, and upstream Enterprise Linux releases may not yet be available.

The security repository is intended to provide hot-fixes as a temporary solution for urgent circumstances involving critical security exposure and immediate risk mitigation. Versioning of these packages is designed such that the official upstream packages will always update our hot-fixes. It is not a replacement for the normal Rocky Linux release process and should not be interpreted as a broader change in our commitment to upstream Enterprise Linux compatibility.

### Notes on: Devel

The devel (development) repository are packages that are not normally provided in the base nor extra repositories for the purposes of providing dependencies or devel packages that may not be provided by upstream. As such, it is treated as a "buildroot" repository, as this repository may contain *all* packages that are provided for Rocky Linux. Additionally, the i686 architecture is provided for the cases of building multilib, as it is not a primary architecture released.

This repository should only be enabled for package building/development purposes and **should not** be permanently enabled.

### Notes on: SIG repositories

Some Special Interest Groups provide additional repositories that enhance the Enterprise Linux experience. These repositories are installable via `rocky-release-*` and `centos-release-*` packages found in the `extras` repository.

All SIG repositories can be found [here](https://dl.rockylinux.org/pub/sig)

## Vault

The vault is a historic archive of previous Rocky Linux releases. These previous releases, including ISOs and other images, are typically moved into the vault area of our tier 0 mirror between a day and a week once a new minor release version is available. The vault can be found [here](https://dl.rockylinux.org/vault/rocky).

!!! warning
    The vault is meant as a historic archive of previous releases of Rocky Linux and not for general use. These are versions that are NOT supported and are NOT recommended for general use as they contain unfixed bugs and unpatched security vulnerabilities.

    The community may not be able to assist you with issues with these releases, so it is recommended that you keep your systems up to date.

## Community Approved Repositories

As with Enterprise Linux and Fedora, there are additional community approved repositories for Rocky Linux. Below are repositories that are approved by Rocky Linux as well as the community.

| |
| - |
| **Extra Packages for Enterprise Linux (EPEL)** - [EPEL](https://docs.fedoraproject.org/en-US/epel/) is by far the most commonly used repository for Enterprise Linux. EPEL provides rebuilds of Fedora packages for every supported enterprise linux. Packages in this repository do not replace the base. You can install EPEL by running `dnf install epel-release` and the package will be installed from the extras repository. The package will automatically have EPEL enabled. Support for EPEL can be found in `#epel` on Libera. |
| **Community Enterprise Linux Repository (ELRepo)** - [ELRepo](http://elrepo.org/) focuses on newer kernels and kmod driver packages to enhance hardware support for currently supported Enterprise Linux versions. This includes display, filesystem, network, storage drivers. You can install the necessary repo files by running `dnf install elrepo-release`. Note that the kernel repositories will have to be enabled. |
| **RPM Fusion** - [RPM Fusion](https://rpmfusion.org/) provides software that the Fedora Project or Red Hat does not want to ship in Enterprise Linux and Fedora. These repositories do rely on EPEL. The policy is to **not** replace EPEL nor base packages. The free repository can be installed by running `dnf install rpmfusion-free-release`. |
| **Remi Repository** - [Remi](http://rpms.remirepo.net/) maintains a large collection of RPMs, including latest versions of PHP, among other things. His FAQ can be found [here](http://blog.remirepo.net/pages/English-FAQ). This is a collection of repositories. Using the `-safe` series of repositories will ensure that nothing from the base will be replaced or overwritten. However, be aware that these repositories do **not** play well with other third party repositories. You will need to use caution as you enable more repositories on your system. |
| **GhettoForge** - [GhettoForge](http://ghettoforge.net/) provides packages not in other third party repositories. Packages that overwrite the base would be in the `gf-plus` repository. Please see [usage](http://ghettoforge.net/index.php/Usage) for more information. |
| **Trinity Desktop Environment (TDE)** - [TDE](http://www.trinitydesktop.org/about.php) provides Enterprise Linux packages for a KDE 3.5 style desktop environment. As of this writing, EL8 and EL9 repositories exist. You can find TDE support resources [here](https://www.trinitydesktop.org/support.php). |
| **ZFS On Linux** - The [ZFS on Linux](http://www.zfsonlinux.org/) project is an implementation of OpenZFS, designed to work in a Linux environment. While this filesystem is very popular, it receives no testing or support from Rocky Release Engineering or Testing. Use at your own risk. |
| **Upstream centos-release-*** - In the extras repository, there are `centos-release-*` packages that provide additional repositories from the Special Interest Groups of CentOS. As they are available in extras and should work on Rocky Linux, they are considered approved and community supported. |

### Notes on: EPEL

Using **EPEL** requires that the `CRB` or `PowerTools` repository is enabled on your system, as some EPEL packages depend on packages from that repo. There are multiple ways to enable the repository:

* Using `dnf`

    * Rocky 8: `dnf config-manager --set-enabled powertools`
    * Rocky 9+: `dnf config-manager --set-enabled crb`

* Modifying the repo files and setting `enabled=1`

    * Rocky 8: `/etc/yum.repos.d/Rocky-PowerTools.repo` under `[powertools]`
    * Rocky 9+: `/etc/yum.repos.d/rocky.repo` under `[crb]`

* Running `dnf install epel-release` and then running `crb enable`

We recommend checking out the [EPEL Quickstart Guide](https://docs.fedoraproject.org/en-US/epel/#_quickstart) for more information.

### Notes on: Unlisted Repositories

If there is a repository that you use (or maintain) and you do not see it here, it is likely that we may not know of it. Unfortunately, this happens. If there are popular repositories that are used in the Enterprise Linux community that should be added to the list, you may drop us a line in Mattermost, IRC, or an issue to the wiki git repository.
