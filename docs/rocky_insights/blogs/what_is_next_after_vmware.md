---
title: What’s Next After VMware
author: Antoine Le Morvan
contributors: 
tags:
  - virtualization
  - vmware
  - opensource
---

Since Broadcom's acquisition of VMware, the virtualization industry has seen significant changes, particularly in licensing pricing. Broadcom's new pricing policy (this is not a judgment) has led to substantial cost increases, particularly for small and medium-sized businesses using VMware. As a result, many organizations have been prompted to reconsider their technological choices.

These price adjustments have pushed impacted companies to explore alternatives, especially open-source solutions.

This post aims to demonstrate the feasibility, advantages, and performance of a virtualization solution based on open-source technologies, offering a viable alternative to VMware.

I would like to clarify that neither I nor the documentation team have any affiliation with the solutions that will be mentioned below.

## What features to expect

Before we begin discussing the available solutions on the market, let’s take a moment to talk about the features we can expect from a virtualization solution.

A key point that came up in many discussions I had on this topic, which is often overlooked at first, is backup. The critical factor when choosing a solution will be: does this solution have a robust backup solution? And I would even specify, if you're already using a solution like Veeam Backup and don’t want to switch (due to cost, acquired skills, or security reasons), is it supported by my current software?

Other features to consider include:

- backup and restore, VM snapshots
- containerization and/or integrated Kubernetes
- managed databases
- IAAS: VPC, network virtualization, and self-service portal
- DevOps integration maturity (Terraform, Ansible) - API
- S3 object storage (Ceph...)
- integrated VPN (especially site-to-site)
- Security Groups (virtual firewall)
- IPAM, managed DHCP, load balancing, SNAT
- Monitoring  

Some solutions also offer:

- Integrated migration from VMware

## Choosing the Hypervisor

Before we dive into the existing solutions, let’s look at the choice of hypervisor from those available:

- **ESXi**, VMware’s hypervisor. If it is considered, it’s likely to simplify migration.
- **KVM (QEMU/libvirt)**: integrated into the kernel, this is one of the most advanced open-source solutions in terms of features and is used extensively.
- **Xen (XCP-ng)**: Citrix’s successor. It’s a robust, older hypervisor that may still have some technical debt but appears to be under active development and will likely catch up soon.
- **AHV (Nutanix)**: we’re moving away from open-source solutions here, but we’ll talk about Nutanix later.
- **Hyper-V**: it’s also worth mentioning because, although proprietary, many small businesses may opt for Microsoft if their pricing is lower than VMware's offerings.

Among the features you can expect from a hypervisor, you may want to verify:

- hot-add CPU and RAM to guests
- hot-add or resize disks on guests
- live migration within or between clusters
- live storage migration

At this point, comparing hypervisors is tricky, as most generally include all these features. The choice really depends on the type of manager you select.

## Choosing the Manager

Now we get to the heart of the matter: choosing the manager of your dreams. Who will be the big winner, the ideal replacement for your trusty vSphere? The one that will seamlessly manage your guests on the most suitable hypervisor?

### Features

Let’s first talk about the features of these solutions, which will help you narrow down your options and set up POCs to assist in your final choice.

A manager should provide:

- cluster management: High Availability (HA), node maintenance, etc.
- self-service portal: welcome to the world of modern private cloud and Infrastructure as a Service
- network virtualization (SDN), VPC
- API management
- support for DevOps tools (Terraform, Ansible, Puppet, etc.)
- cross-cluster migration

### Existing Solutions

In this section, I won’t discuss proprietary solutions like Hyper-V or Nutanix. I’ll just mention that Nutanix offers many features to compete with VMware, with responsive professional support. It still seems to be a more expensive solution compared to the support of the solutions I’ll introduce below, but I’ll leave the price comparison to you.

In my opinion, the most advanced solution to replace something like vSphere is **OpenStack**. Supported by many vendors, it is the foundation for numerous public clouds. But it’s also the most complex to implement. Forget OpenStack if you don’t have a skilled Linux engineering team with time to dedicate to it. But if you can invest that time, it’s the solution for you. Consider looking at derived solutions like **Virtuozzo** for support, or from vendors like RedHat and Suse.

Since I first mentioned **OpenStack**, I must continue with the one I’ve favored for a long time: the famous Top-Level Project of the Apache Foundation (no less), **CloudStack**. With features similar to OpenStack, it offers everything needed for setting up a Private Cloud portal, including VPC support, network virtualization, load balancing, and even **Kubernetes** clusters, all within a well-designed self-service portal. It comes as a Java application in an rpm or deb package, and installation is straightforward. The most complex part is configuring virtual switches on the hosts (RockyLinux is supported), but nothing insurmountable. Hosts can be KVM, Xen, Hyper-V, or ESXi, and recently Proxmox has been supported. As I mentioned, CloudStack is one of the few solutions offering direct guest migration from vSphere through the UI. Behind CloudStack, there’s an active player, ShapeBlue, offering enterprise support. In terms of scalability, CloudStack instances exist with over 35,000 hosts, indicating solid scalability.

Next, I’ll mention Proxmox, the open-source solution that will likely gain the most market share in this space. Based on Debian (no RockyLinux here ^^), I must admit that after reading its well-done administration guide, I was impressed by its features (IPAM, network virtualization, storage management, container support, and especially Ceph storage integration). Proxmox offers an integrated backup solution with the option for external backups, as well as a new data center management solution (for managing multiple Proxmox clusters). If you don’t need a self-service portal like CloudStack offers, are focused on a hyper-converged model (storage is distributed across hosts, not on a dedicated SAN/NAS), and your scope is a few hundred guests, then Proxmox is likely the right choice.

Lastly, I must mention Vates and XCP-ng, based on the Xen hypervisor and the Xen-Orchestra web admin interface. In my opinion, these are solutions to keep an eye on, as they are built on solid foundations and are actively developed (Vates is developed by a French company, which says a lot about the quality of the product!). Note, however, that at Vates, you’ll need to spend more to access hyper-converged storage (XOSTOR) or backup solutions (XO Proxy).

### Cost Control

Given that the subject of this article revolves around the increase in costs driven by Broadcom's licensing changes, it would be remiss of me not to address the financial aspects associated with changing your solution.

Beyond the cost of support, which you will likely want to subscribe to if you are in a business model, it's also essential to factor in the Total Cost of Ownership (TCO), which includes:

- the cost of support,
- maintenance costs,
- update costs,
- training your teams and the time required for solution integration,
- the time spent on migration.

### Support and community

The final point to consider, which can often be a deciding factor, is the support provided both by a company and by an active community. Having access to a responsive support team can be reassuring, as can the ability to rely on a strong community for advice and troubleshooting. However, it's important to note that a lack of community activity or poor support can be a significant drawback.

## Conclusion

This brief article has allowed me to present the main solutions available on the market, and as you can see, making a choice isn’t easy. It all depends on your team’s ability to manage the tool, your backup solution, the features you require, your maturity with DevOps tools and cloud-native approaches, as well as the volume of guests to manage.

While I’ve favored CloudStack for a long time, this Apache project is still relatively unknown (Apache doesn’t promote its projects like other vendors do) and I highly encourage you to consider it when making your choice. Proxmox and Vates are also excellent solutions for small businesses or even larger needs before moving to a solution based on OpenStack (or OpenShift).

I hope this quick overview will help save you time in your search for a VMware replacement solution.
