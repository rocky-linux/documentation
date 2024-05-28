---
title: Enabling `iptables` Firewall
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested*with: 8.5, 8.6, 9.0
tags:
 - security
 - iptables
 - deprecated
---

# Enabling iptables Firewall

## Prerequisites

- A burning, unquenchable desire to disable the default *firewalld* application, and enable *iptables*.

!!! warning "This Process Is Deprecated"

    As of Rocky Linux 9.0, `iptables` and all of the utilities associated with it, are deprecated. This means that future releases of the OS will be removing `iptables`. For that reason, it is highly recommended that you do not use this process. If you are familiar with iptables, we recommend using [`iptables` Guide To `firewalld`](firewalld.md). If you are new to firewall concepts, then we recommend [`firewalld` For Beginners](firewalld-beginners.md).

## Introduction

*firewalld* is now the default firewall on Rocky Linux. *firewalld* **was** nothing more than a dynamic application of *iptables* using xml files that loaded changes without flushing the rules in CentOS 7/RHEL 7.  With CentOS 8/RHEL 8/Rocky 8, *firewalld* is now a wrapper around *nftables*. It is still possible, however, to install and use straight *iptables* if that is your preference. To install and run straight *iptables* without *firewalld* you can do so by following this guide. What this guide will **not** tell you is how to write rules for *iptables*. It is assumed that if you want to get rid of *firewalld*, you must already know how to write rules for *iptables*.

## Disabling firewalld

You can't really run the old *iptables* utilities alongside *firewalld*. They're just not compatible. The best way to get around this is to disable *firewalld* entirely (no need to uninstall it unless you want to) , and reinstall the *iptables* utilities. Disabling *firewalld* can be done using these commands:

Stop *firewalld*:

`systemctl stop firewalld`

Disable *firewalld* so it won't start on boot:

`systemctl disable firewalld`

Mask the service so that it can't be found:

`systemctl mask firewalld`

## Installing And Enabling iptables Services

Next, we need to install the old *iptables* services and utilities. This is done with the following:

`dnf install iptables-services iptables-utils`

This will install everything that is needed to run a straight *iptables* rule set.

Now we need to enable the *iptables* service to make sure that it starts on boot:

`systemctl enable iptables`

## Conclusion

You can return to using straight *iptables* if you prefer it over *firewalld*. You can return to using the default *firewalld* by simply reversing these changes.
