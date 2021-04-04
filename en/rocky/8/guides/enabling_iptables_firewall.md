# Enabling iptables Firewall

# Introduction

_firewalld_ is now the default firewall on Rocky Linux. _firewalld_ is nothing more than a dynamic application of _iptables_ using xml files. It loads changes without flushing the rules. Using straight _iptables_ may be something that you are more comfortable with. If so, it is still possible to run _iptables_ without _firewalld_ by following this procedure. This procedure does not tell you how to write rules for _iptables_. It is assumed that if you want to get rid of _firewalld_, you must already know how to write rules for _iptables_.

## Prerequisites

* desire to disable the default _firewalld_ and enable _iptables_

### Disabling firewalld

Running the old _iptables_ utilities along side of _firewalld_ is not compatible. The best way to get around this is to disable _firewalld_ and reinstall _iptables_ utilities. Disabling _firewalld_ can be done using these commands:

Stop _firewalld_:

`systemctl stop firewalld`

Disable _firewalld_ so it won't start on boot:

`systemctl disable firewalld`

Mask that so that it can't be found:

`systemctl mask firewalld`

### Installing And Enabling iptables Services

Next we need to install the old _iptables_ services and utilities. This is done with the following:

`dnf install iptables-services iptables-utils`

This will install everything that is needed to run a straight _iptables_ rule set.

Now we need to enable the _iptables_ service to make sure that it starts on boot:

`dnf enable iptables`

# Conclusion

You can return to using straight _iptables_ if you prefer it over _firewalld_. You can return to using the default _firewalld_ by reversing these changes.


