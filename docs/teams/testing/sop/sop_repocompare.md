---
title: 'SOP: Repocompare'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

This SOP covers how to perform the repocompare process, to ensure that Rocky's package repositories are up-to-date with the RHEL package repositories.

{% include "teams/testing/contacts_top.md" %}

To identify which packages may need updates, visit the appropriate [RepoCompare](https://repocompare.rockylinux.org){target=_blank} page, focusing on the **SRPM Repo Comparison** page for each version.
Packages where the **Rocky** version is **lower** than the **RHEL** version likely require an update - you can do a manual comparison to be sure.

## Setup

From a **RHEL8 machine with a valid entitlement**, obtain the repocompare repository:

``` bash linenums="1"
git clone https://git.resf.org/testing/repocompare
cd repocompare/
```

Import the RPM GPG keys for both Rocky and RHEL

``` bash linenums="1"
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-8
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
rpm --import RPM-GPG-KEY-Rocky-8
rpm --import RPM-GPG-KEY-Rocky-9
rpm --import /etc/pki/rpm-gpg/redhat-official
```

## Comparing a package

If the Name/Epoch/Version/Release (NEVR) for the RHEL package is newer than the one for the Rocky package, the package requires an update. In this situation, there will also likely be a newer entry in the changelog for the RHEL package, as shown below:

``` bash linenums="1"
./manual_compare.sh 9 AppStream golang
Rocky Linux 9.2    golang 1.19.9 2.el9_2 * Tue May 23 2023 Alejandro Sáez <asm@redhat.com> - 1.19.9-2
Red Hat            golang 1.19.10 1.el9_2 * Tue Jun 06 2023 David Benoit <dbenoit@redhat.com> - 1.19.10-1
```

Notice that the Red Hat golang package has a higher version than the Rocky Linux 9.2 package. It also has a newer entry in its changelog.

## Gotchas

Some packages are not considered relevant for repocompare purposes. These include:

``` bash linenums="1"
rhc
shim-unsigned
# Any package that exists in RHEL but not in Rocky (denoted by **DOES NOT EXIST** in the Rocky column on the repocompare website)
```

{% include "teams/testing/content_bottom.md" %}
