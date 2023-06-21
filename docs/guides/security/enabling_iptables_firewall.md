---
title: Enabling `iptables` Firewall
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
 - security
 - iptables
 - deprecated
---

# Enabling iptables Firewall

## Prerequisites

* A burning, unquenchable desire to disable the default _firewalld_ application, and enable _iptables_.

!!! warning "This Process Is Deprecated"

    As of Rocky Linux 9.0, `iptables` and all of the utilities associated with it, are deprecated. This means that future releases of the OS will be removing `iptables`. For that reason, it is highly recommended that you do not use this process. If you are familiar with iptables, we recommend using [`iptables` Guide To `firewalld`](firewalld.md). If you are new to firewall concepts, then we recommend [`firewalld` For Beginners](firewalld-beginners.md).

## Introduction

_firewalld_ is now the default firewall on Rocky Linux. _firewalld_ **was** nothing more than a dynamic application of _iptables_ using xml files that loaded changes without flushing the rules in CentOS 7/RHEL 7.  With CentOS 8/RHEL 8/Rocky 8, _firewalld_ is now a wrapper around _nftables_. It is still possible, however, to install and use straight _iptables_ if that is your preference. To install and run straight _iptables_ without _firewalld_ you can do so by following this guide. What this guide will **not** tell you is how to write rules for _iptables_. It is assumed that if you want to get rid of _firewalld_, you must already know how to write rules for _iptables_.

## Disabling firewalld

You can't really run the old _iptables_ utilities alongside _firewalld_. They're just not compatible. The best way to get around this is to disable _firewalld_ entirely (no need to uninstall it unless you want to) , and reinstall the _iptables_ utilities. Disabling _firewalld_ can be done using these commands:

Stop _firewalld_:

`systemctl stop firewalld`

Disable _firewalld_ so it won't start on boot:

`systemctl disable firewalld`

Mask the service so that it can't be found:

`systemctl mask firewalld`

## Installing And Enabling iptables Services

Next, we need to install the old _iptables_ services and utilities. This is done with the following:

`dnf install iptables-services iptables-utils`

This will install everything that is needed to run a straight _iptables_ rule set.

Now we need to enable the _iptables_ service to make sure that it starts on boot:

`systemctl enable iptables`

## Conclusion

You can return to using straight _iptables_ if you prefer it over _firewalld_. You can return to using the default _firewalld_ by simply reversing these changes.
