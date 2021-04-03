# Enabling iptables Firewall

## Prerequisites

* A burning, unquenchable desire to disable the default _firewalld_ application, and enable _iptables_.

## Introduction

_firewalld_ is now the default firewall on Rocky Linux. _firewalld_ is nothing more than a dynamic application of _iptables_ using xml files, and it loads changes without flushing the rules. 

However, using straight _iptables_ may be something that you are more comfortable with. If so, it is still possible to run _iptables_ without _firewalld_ by following this guide. What this guide will _not_ tell you is how to write rules for _iptables_. 

It is assumed that if you want to get rid of _firewalld_, you must already know how to write rules for _iptables_.

## Disabling firewalld

You can't really run the old _iptables_ utilities alongside _firewalld_. They're just not compatible. The best way to get around this is to disable _firewalld_ entirely (no need to unistall it unless you want to), and reinstall the _iptables_ utilities. Disabling _firewalld_ can be done using these commands:

Stop _firewalld_:

`systemctl stop firewalld`

Disable _firewalld_ so it won't start on boot:

`systemctl disable firewalld`

Mask the service so that it can't be found:

`systemctl mask firewalld`

## Installing And Enabling iptables Services

Next we need to install the old _iptables_ services and utilities. This is done with the following:

`dnf install iptables-services iptables-utils`

This will install everything that is needed to run a straight _iptables_ rule set.

Now we need to enable the _iptables_ service to make sure that it starts on boot:

`dnf enable iptables`

## Conclusion

You can return to using straight _iptables_ if you prefer it over _firewalld_. You can return to using the default _firewalld_ by simply reversing these changes.


