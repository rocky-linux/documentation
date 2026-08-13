---
title: Rocky Linux Errata
---

This page goes over general information about the Rocky Linux errata and its backend system.

## Errata Resources

* [Errata Browser](https://errata.build.resf.org/)
* [Errata API Endpoint](https://apollo.build.resf.org/)
* [Errata API Endpoint OpenAPI Specs](https://gist.github.com/mstg/16dec9f3f63ce16bce79816575ab9791)
* [Errata RSS Endpoint](https://apollo.build.resf.org/v2/advisories:rss)

## General Errata Information

Errata is generated via a system called "Apollo" together with the build system peridot. The Apollo system replaces the old errata system "secparse" and effectively generates the updateinfo.xml data that will appear in repositories. This provides information such as:

* Security advisories (RLSA)
* Bugfix advisories (RLBA)
* Enhancement advisories (RLEA)

This information generally attempts to match the advisories provided by Red Hat. Errata for your system can be found by running `dnf updateinfo`.

```
# dnf updateinfo
Last metadata expiration check: 1:41:31 ago on Thu 22 Sep 2022 10:00:23 PM MST.
Updates Information Summary: available
    1 New Package notice(s)
    5 Security notice(s)
        4 Important Security notice(s)
        1 Moderate Security notice(s)
    1 Bugfix notice(s)
    1 Enhancement notice(s)
Security: kernel-core-4.18.0-372.19.1.el8_6.x86_64 is an installed security update
Security: kernel-core-4.18.0-372.9.1.el8.x86_64 is the currently running version
```

You can also run `dnf updateinfo list` to see the full list that applies to your system. If you use EPEL, you may see `FEDORA-EPEL` advisories as well.

```
# dnf updateinfo list
RLSA-2022:6159              Moderate/Sec.  curl-7.61.1-22.el8_6.4.x86_64
FEDORA-EPEL-2022-232803ed1b enhancement    distribution-gpg-keys-1.77-1.el8.noarch
RLSA-2022:5564              Important/Sec. kernel-4.18.0-372.16.1.el8_6.x86_64
RLSA-2022:5819              Important/Sec. kernel-4.18.0-372.19.1.el8_6.x86_64
RLSA-2022:5564              Important/Sec. kernel-core-4.18.0-372.16.1.el8_6.x86_64
RLSA-2022:5819              Important/Sec. kernel-core-4.18.0-372.19.1.el8_6.x86_64
RLSA-2022:5564              Important/Sec. kernel-modules-4.18.0-372.16.1.el8_6.x86_64
RLSA-2022:5819              Important/Sec. kernel-modules-4.18.0-372.19.1.el8_6.x86_64
FEDORA-EPEL-2022-42c9410b12 bugfix         koji-1.30.0-1.el8.noarch
RLSA-2022:6159              Moderate/Sec.  libcurl-7.61.1-22.el8_6.4.x86_64
FEDORA-EPEL-2022-42c9410b12 bugfix         python3-koji-1.30.0-1.el8.noarch
FEDORA-EPEL-2022-42c9410b12 bugfix         python3-koji-cli-plugins-1.30.0-1.el8.noarch
FEDORA-EPEL-2019-6adf1e0ef3 newpackage     python3-psutil-5.6.3-5.el8.x86_64
RLSA-2022:6180              Important/Sec. rsync-3.1.3-14.el8_6.3.x86_64
RLSA-2022:6206              Important/Sec. systemd-239-58.el8_6.4.x86_64
RLSA-2022:6206              Important/Sec. systemd-container-239-58.el8_6.4.x86_64
RLSA-2022:6206              Important/Sec. systemd-libs-239-58.el8_6.4.x86_64
RLSA-2022:6206              Important/Sec. systemd-pam-239-58.el8_6.4.x86_64
RLSA-2022:6206              Important/Sec. systemd-udev-239-58.el8_6.4.x86_64
```
