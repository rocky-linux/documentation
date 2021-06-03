# Rocky Linux 8.4 Release

Rocky Linux is a community enterprise operating system designed to be 100% bug-for-bug compatible with America's top enterprise Linux distribution. It is under intensive development by the community. As such, the release notes reflect the changes to the upstream packages and to those inclduded in the original Rocky Linux 8.3 release candidate. 

The entire Rocky Linux team is excited to let you know about the first full release of Rocky Linux, Rocky Linux 8.4! If you are new to Rocky Linux, it's great to have you here and we look forward to a long and happy relationship. 

## New Modules

Brand new in Rocky Linux 8.4 are the following new module streams:

* Python 3.9
* SWIG 4.0
* Subversion 1.14
* Redis 6
* PostgreSQL 13
* MariaDB 10.5 

## Major Changes

### Security

* IPsec VPN provided by Libreswan now supports TCP encapsulation and security labels for IKEv2.

* The scap-security-guide packages have been rebased to version 0.1.54, and OpenSCAP has been rebased to version 1.3.4. These updates provide substantial improvements, including: Improved memory management, 

* The `fapolicyd` framework now provides integrity checking, and the RPM plugin now registers any system update that is handled by either the YUM package manager or the RPM Package Manager.

### Networking

* Nmstate is a network API for hosts and fully supported in Rocky Linux 8.4. The `nmstate` packages provide a library and the `nmstatectl` command-line utility to manage host network settings in a declarative manner.

* The Multi-protocol Label Switching (MPLS) is an in-kernel data-forwarding mechanism to route traffic flow across enterprise networks. For example, you can add `tc filters` for managing packets received from specific ports or carrying specific types of traffic, in a consistent way.

* The `iproute2` utility introduces three new traffic control (tc) actions; `mac_push`, `push_eth`, and `pop_eth` to add MPLS labels, build an Ethernet header at the beginning of the packet, and drop the outer Ethernet header respectively.

### Kernel

* **Proactive compaction** regularly initiates memory compaction work **before** a request for allocation is made. Therefore, latency for specific memory allocation requests is lowered.

* A new implementation of slab memory controller for the **control groups** technology is now available in Rocky Linux 8.4. The slab memory controller brings improvement in slab utilization, and enables to shift the memory accounting from the page level to the object level. As a result, you can observe a significant drop in the total kernel memory footprint and positive effects on memory fragmentation.

* The time namespace feature is available in Rocky Linux 8.4. This feature is suited for changing the date and time inside Linux containers. The in-container clock adjustments after restoration from a checkpoint are also now possible.

* Rocky Linux 8.4 supports the Error Detection and Correction (EDAC) kernel module set in 8th and 9th generation Intel Core Processors.

### High Availability and Clusters

* A persistent Pacemaker resource agent that maintains state data can detect failures asynchronously and inject a failure into Pacemaker immediately without waiting for the next monitor interval. A persistent resource agent can also speed up cluster response time for services with a high state overhead, since maintaining state data can reduce the state overhead for cluster actions such as start, stop, and monitor by not invoking the state separately for each action.

### Compilers and Development Tools

* The following compiler toolsets have been updated:

> * GCC Toolset 10
> * LLVM Toolset 11.0.0
> * Rust Toolset 1.49.0
> * Go Toolset 1.15.7

### Identity Management

* Rocky Linux 8.4 provides Ansible modules for automated management of role-based access control (RBAC) in Identity Management (IdM), an Ansible role for backing up and restoring IdM servers, and an Ansible module for location management.

## Known Issues

As with any release, there are sometimes bugs or issues found in the process of building that have not yet been patched or fixed upstream. These are:

(Replace this with a list of known issues)

## Conversion Tools Available for Rocky Linux

You can convert from Rocky Linux 8.3, Centos 8.3 or 8.4, RHEL 8.3 or 8.4, and Alma 8.3 or 8.4 to Rocky Linux 8.4 by using the [migrate2rocky](https://github.com/rocky-linux/rocky-tools/) tool. This tool has been tested and is known to work, however it is to be used **at your own risk**. 
