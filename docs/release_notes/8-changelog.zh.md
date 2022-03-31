---
title: 更改日志
author: Louis Abel
contributors: tianci li, Steven Spencer
tags:
  - 岩石更新日志
  - 更新日志
---

# Rocky Linux 8 更改日志

随着上游的构建和推送自己的版本，Rocky Linux 8 将随着时间的推移逐步接收到增量更新以及次要版本升级。 此页面将提供发生更改时的详细信息。 对于运行着Rocky Linux的系统，可以通过运行`dnf update`命令随时更新他们的系统。 本文档的更新有时可能会延迟， 要检查是否有新的更新，您可以访问邮件列表归档——[Rocky Announce](https://lists.resf.org/archives/list/rocky-announce@lists.resf.org/)。

### 更新说明

因为上游发布的更新是在我们当前的架构中发布的， 所以强烈建议所有用户在您当前的Rocky Linux计算机中应用 *全部* 更新（包括今天发布的内容）， 您可以通过运行`dnf update`来完成更新动作。

所有Rocky Linux组件都是由托管在[git.rockylinux.org](https://git.rockylinux.org) 上的源代码进行构建的。 此外，SRPM与存储库将一起发布在对应的"source"目录中， 您可以在我们的任意镜像网站上找到它们， 镜像网站的源码包与我们发布的每个二进制RPM相同。

## 2022-01-20

以下软件包自2022年2月4日起进行了更新：

* aide: aide-0.16-14.el8 -> aide-0.16-14.el8_5.1
* tzdata-2022a-1.el8
* httpd-2.4.37-43.module+el8.5.0+747+83fae388.3
* openssl-1.1.1k-6.el8_5

关联的CVE：

* CVE-2021-45417

以下软件包自2022年01月11日起进行了更新：

* thunderbird: 更新至78.14.0
* CVE-2022-25235
* cyrus-imapd: 更新至3.0.7-20.el8_4.1(地址 CVE-2021-33582)
* CVE-2022-23852
* CVE-2021-45960
* CVE-2021-46143
* CVE-2022-22827
* CVE-2022-22826
* CVE-2022-22825
* CVE-2022-22824
* CVE-2022-22823
* CVE-2022-22822
* CVE-2022-0778
* CVE-2022-22720

### 发布工程说明

我们要对过去两个星期中没有作出宣布表示歉意。 目前这些公告都是手工发布的，目前正在制定计划，使这些公告更加自动化，并减少人与人之间的互动。

释放了RHEL 8。 beta, 我们将研究正在变化的情况以及我们将需要如何在其可能于4月底或5月举行的大会之前的几个星期内完成我们的工作。 在此期间，我们还一直致力于启动RHEL 9 测试包，最终将被导入， 重建并在我们的新构建系统中测试。

## 8.5 - 2022-01-03

关联的CVE：

* dotnet6.0: dotnet6.0-6.0.100-0.10.el8_5 -> dotnet6.0-6.0.101-2.el8_5
* 云内：云内-21.1-7.el8_5.3 -> 云内-21.1-7.el8_5.4
* fence-agents: fence-agents-4.2.1-75.el8 -> fence-agents-4.2.1-75.el8_5.2
* firewalld: firewalld-0.9.3-7.el8 -> firewalld-0.9.3-7.el8_5.1
* gdm: gdm-1:40.0-15.el8 -> gdm-1:40.0-15.el8_5.1
* glibc: glibc-2.28-164.el8 -> glibc-2.28-164.el8_5.3
* httpd-2.4.37-43.module+el8.5.0+727+743c5577.1 -> httpd-2.4.37-43.module+el8.5.0+746+b6ce3176.2
* java-11-openjdk: java-11-openjdk-1:11.0.14.0.9-2.el8_5 -> java-11-openjdk-1:11.0.14.1.1-2.el8_5
* libarchive: libarchive-3.3.3-1.el8_5 -> libarchive-3.3.3-3.el8_5
* libxml2: libxml2-2.9.7-11.el8 -> libxml2-2.9.7-12.el8_5
* linux-firmware：linux-firmware20210702-103.gitd79c2677.el8 -> linux-firmware20210702-104.gitd79c2677.el8_5
* lvm2: lvm2-8:2.03.12-10.el8 -> lvm2-8:2.03.12-11.el8_5
* nmstate: nmstate-1.1.0-5.el8_5 -> nmstate-1.1.0-6.el8_5
* pcs: pcs-0.10.10-4.el8.rocky.0 -> pcs-0.10.10-4.el8_5.1.rocky.0
* plymouth: plymouth-0.9.4-10.20200615git1e36e30.el8 -> plymouth-0.9.4-10.20200615git1e36e30.el8_5.1
* qemu-kvm: qemu-kvm-15:4.2.0-59.module+el8.5.0+726+ce09ee88.1 -> qemu-kvm-15:4.2.0-59.module+el8.5.0+744+67293bef.2
* redhat-support-lib-python: redhat-support-lib-python-0.11.3-1.el8 -> redhat-support-lib-python-0.13.0-0.el8_5
* redhat-support-tool: redhat-support-tool-0.11.3-2.el8 -> redhat-support-tool-0.13.0-0.el8_5
* samba: samba-4.14.5-9.el8_5 -> samba-4.14.5-10.el8_5
* 订阅管理器: 订阅经理-1.28.21-3.el8 -> 订阅经理-1.28.21-5.el8_5
* systemd: systemd-239-51.el8_5.3 -> systemd-239-51.el8_5.5
* vim: vim-2:8.0.1763-16.el8_5.4 -> vim-2:8.0.1763-16.el8_5.12

以下软件包自2022年1月27日起进行了更新：

* grafana: grafana-7.5.9-4.el8 -> grafana-7.5.9-5.el8_5
* CVE-2021-45417
* virt
* virt-devel

## 8.5 - 2022-02-01

关联的CVE：

* containertools
* thunderbird：thunderbird-91.6.0-1.el8_5.Plus -> thunderbird-91.7.0-2.el8_5.plus

以下模块已更新：

* cyrus-imapd: 更新至3.0.7-20.el8_4.1(地址 CVE-2021-33582)
* CVE-2022-25235
* thunderbird: 更新至78.14.0

## 8.5 - 2022-01-27

关联的CVE：

* CVE-2021-20321
* dotnet5.0: dotnet5.0-5.0.211-1.el8_5 -> dotnet5.0-5.0.212-1.el8_5
* dotnet6.0: dotnet6.0-6.0.102-1.el8_5 -> dotnet6.0-6.0.103-4.el8_5
* firefox: 更新至78.14.0firefox: firefox-91.6.0-1.el8_5 -> firefox-91.7.0-3.el8_5
* kernel: kernel-4.18.0-348.12.2.el8_5 -> kernel-4.18.0-348.20.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.12.2.rt7.143.el8_5 -> kernel-rt-4.18.0-348.20.1.rt7.150.el8_5

以下软件包自2021年12月16日起进行了更新：

* virt-rhel-8050020211221163306.b4937e53
* CVE-2022-0847

## 8.5 - 2022-01-26

以下软件包自2021年12月13日起进行了更新：

* java-1.8.0-openjdk: java-1.8.0-openjdk-1:1.8.0.312.b07-2.el8_5 -> java-1.8.0-openjdk-1:1.8.0.322.b06-2.el8_5

关联的CVE：

* dotnet5.0: dotnet5.0-5.0.209-1.el8_5 -> dotnet5.0-5.0.210-1.el8_5

## 8.5 - 2022-01-25

以下软件包自2021年12月17日起进行了更新：

* CVE-2020-25717

以请求为基础，将 kernel-rt-kvm 软件包添加到 RT 存储库中。

* go-toolset-rhel8-8050020211215173118-8aa62369
* CVE-2022-22816
* CVE-2022-22817

## 8.5 - 2021-12-12

以下软件包自2021年12月12日起进行了更新：

* samba: samba-4.14.5-2.el8 -> samba-4.14.5-7.el8_5
* rubby-2.6-805002202165459.b4937e53

## 8.5 - 2021-12-10

关联的CVE：

* CVE-2016-2124
* thunderbird：thunderbird-91.5.0-1.el8.plus -> thunderbird-91.6.0-1.el8_5.plus

## 8.5 - 2021-12-09

以下软件包自2021年12月10日起进行了更新：

* WALinuxAgent: WALinuxAgent-2.3.0.2-2.el8 -> WALinuxAgent-2.3.0.2-2.el8.rocky.0
* dotnet5.0: dotnet5.0-5.0.210-1.el8_5 -> dotnet5.0-5.0.211-1.el8_5
* dotnet6.0: dotnet6.0-6.0.101-2.el8_5 -> dotnet6.0-6.0.102-1.el8_5
* firefox: 更新至78.14.0firefox: firefox-91.5.0-1.el8_5 -> firefox-91.6.0-1.el8_5

## 8.5 - 2021-12-03

以下模块已更新：

* python27

这些更新主要是外观上的，并不影响功能。

* WALinuxAgent -> 我们在这里以及微软的PR上游中添加了对 Rocky 的直接支持

## 8.5 - 2021-12-02

以下软件包自2021年12月09日起进行了更新：

* thunderbird: thunderbird-91.3.0-2.el8_4 ->

关联的CVE：

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0

## 8.5 - 补充部分 - 2021-11-30

以下软件包自2021年12月03日起进行了更新：

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->
* cockpit: cockpit-251.1-1.el8 -> cockpit-251.3-1.el8_5
* cryptsetup: cryptsetup-2.3.3-4.el8 -> cryptsetup-2.3.3-4.el8_5.1
* dnf-plugins-core: dnf-plugins-core-4.0.21-3.el8 -> dnf-plugins-core-4.0.21-4.el8_5
* frr: frr-7.5-4.el8 -> frr-7.5-4.el8_5.2
* gnome-control-center: gnome-control-center-3.28.2-28.el8 -> gnome-control-center-3.28.2-29.el8_5
* nispor: nispor-1.1.1-1.el8 -> nispor-1.1.1-2.el8_5
* nmstate: nmstate-1.1.0-3.el8 -> nmstate-1.1.0-5.el8_5
* ostree: ostree-2021.3-1.el8 -> ostree-2021.3-2.el8_5
* resource-agents: resource-agents-4.1.1-98.el8 -> resource-agents-4.1.1-98.el8_5.2
* rpm: rpm-4.14.3-19.el8 -> rpm-4.14.3-19.el8_5.2
* sos: sos-4.1-5.el8.rocky.3 -> sos-4.1-9.el8_5.rocky.3
* spirv-tools: spirv-tools-2021.3-1.20210825.git1fbed83.el8 -> spirv-tools-2021.4-3.20211110.git21e3f68.el8_5
* sssd: sssd-2.5.2-2.el8_5.3 -> sssd-2.5.2-2.el8_5.4
* tcpdump: tcpdump-14:4.9.3-2.el8 -> tcpdump-14:4.9.3-2.el8_5.1
* tigervnc: tigervnc-1.11.0-9.el8 -> tigervnc-1.11.0-10.el8_5
* vim: vim-2:8.0.1763-16.el8 -> vim-2:8.0.1763-16.el8_5.4
* virtio-win: virtio-win-1.9.19-1.el8 -> virtio-win-1.9.24-2.el8_5
* vulkan-headers: vulkan-headers-1.2.189.0-1.el8 -> vulkan-headers-1.2.198.0-1.el8_5
* vulkan-loader: vulkan-loader-1.2.189.0-1.el8 -> vulkan-loader-1.2.198.0-2.el8_5
* vulkan-tools: vulkan-tools-1.2.189.0-1.el8 ->vulkan-tools-1.2.198.0-1.el8_5
* vulkan-validation-layers: vulkan-validation-layers-1.2.189.0-2.el8 ->vulkan-validation-layers-1.2.198.0-4.el8_5

Firefox: 这是一个针对 Firefox 的 ESR 构建更新。

* mailman: CVE-2021-44227
* freeradius
* nodejs
* pki-core
* virt
* virt-devel

## 8.5 - 2021-11-29

添加了以下存储库/软件包：

* mailman-2.1-8050020211202160117.fd901a62
* nginx: nginx-1:1.20.0-2.module+el8.5.0+669+b11495b0 -> nginx-1:1.20.1-1.module+el8.5.0+729+3f70613e
* samba: samba-4.14.5-7.el8_5 -> samba-4.14.5-9.el8_5

添加了以下存储库/软件包：

* ncurses-static

以下软件包自2021年12月02日起进行了更新：

* open-vm-tools (仅适用于aarch64的构建)
* CVE-2021-23017

## 8.5 - 2021-11-24

关联的CVE：

* openldap-servers (所有架构)

## 8.5 - 2021-11-22

以下模块自2021年11月02日起已更新：

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5

以下软件包已添加到 devel 存储库中：

* nss-3.67.0-7.el8_5: CVE-2021-43527

以下软件包已添加到 plus 存储库中：

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5

## 8.5 - 2021-11-16

关联的CVE：

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1
* polkit: polkit-0.115-12.el8 -> polkit-0.115-13.el8_5.1

在plus 存储库中的当前软件包是(截至2021-11-30)：

* mailman-2.1-8050020211123230959.fd901a62

关联的CVE：

* CVE-2021-42096
* CVE-2021-4034

## 8.5 - 2021-11-14

以下软件包自2021年11月29日起已更新：

* clang: clang-12.0.1-2.module+el8.5.0+692+8756646f -> clang-12.0.1-4.module+el8.5.0+715+58f51d49

## 8.4 - 2021-09-21

关联的 CVE：

* llvm-toolset-rhel8-8050020211122023437.b4937e53
* java-17-openjdk: java-17-openjdk-1:17.0.1.0.12-2.el8_5 -> java-17-openjdk-1:17.0.2.0.8-4.el8_5
* kernel: kernel-4.18.0-348.7.1.el8_5 -> kernel-4.18.0-348.12.2.el8_5
* kernel-rt: kernel-rt-4.18.0-348.7.1.rt7.137.el8_5 -> kernel-rt-4.18.0-348.12.2.rt7.143.el8_5
* libarchive: libarchive-3.3.3-1.el8 -> libarchive-3.3.3-1.el8_5
* libreswan: libreswan-4.4-1.el8 -> libreswan-4.4-4.el8_5

以下软件包自2021年11月24日起已更新：

* annobin: annobin-9.65-1.el8 -> annobin-9.72-1.el8_5.2
* CVE-2021-45463
* CVE-2021-4155

## 8.4 - 2021-09-13

以下软件包自2021年11月22日起进行了更新(包含更新后的模块软件包)：

* insights-client: insights-client-3.1.5-1.el8 (标准软件包组)
* thunderbird: 更新至78.14.0thunderbird: thunderbird-91.4.0-2.el8_5 -> thunderbird-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8.plus -> thunderbird-91.5.0-1.el8.plus

## 8.4 - 2021-08-24

以下模块自2021年11月23日起已更新：

* rust-toolset-rhel8-8050020211112021616.f73640c0
* llvm-toolset-rhel8-8050020211122023437.b4937e53

## 8.4 - 2021-08-11

以下软件包自2021年12月22日起进行了更新：

* kernel: kernel-4.18.0-305.19.1 (9-15)

以下软件包自2021年11月16日起进行了更新(包含更新后的模块软件包)：

* thunderbird: 更新至78.14.0

## 8.4 - 2021-08-02

以下模块自2021年11月16日起已更新：

* extras -> CentOS SIG(Special Interest Group,特别兴趣小组) 发布包已被添加
* accountsservice: accountsservice-0.6.55-2.el8 -> accountsservice-0.6.55-2.el8_5.2
* cloud-init: cloud-init-21.1-7.el8 -> cloud-init-21.1-7.el8_5.3
* freeradius: freeradius-3.0.20-9.module+el8.5.0+704+21fb769d -> freeradius-3.0.20-10.module+el8.5.0+723+cc9aee6c
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-20.el8_5.1 -> gnome-shell-extensions-3.32.1-22.el8_5
* java-11-openjdk: java-11-openjdk-1:11.0.13.0.8-3.el8_5 -> java-11-openjdk-1:11.0.13.0.8-4.el8_5
* kernel: kernel-4.18.0-348.2.1.el8_5 -> kernel-4.18.0-348.7.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.2.1.rt7.132.el8_5 -> kernel-rt-4.18.0-348.7.1.rt7.137.el8_5
* kexec-tools: kexec-tools-2.0.20-57.el8 -> kexec-tools-2.0.20-57.el8_5.1
* opencryptoki: opencryptoki-3.16.0-5.el8 -> opencryptoki-3.16.0-7.el8_5
* openssl: openssl-1:1.1.1k-4.el8 -> openssl-1:1.1.1k-5.el8_5
* poppler: poppler-20.11.0-3.el8 -> poppler-20.11.0-3.el8_5.1
* postgresql: postgresql-12.7-2.module+el8.5.0+686+20453ecc -> postgresql-12.9-1.module+el8.5.0+724+9de6e501
* qemu-kvm: qemu-kvm-15:4.2.0-59.module+el8.5.0+670+c4aa478c -> qemu-kvm-15:4.2.0-59.module+el8.5.0+726+ce09ee88.1
* rocky-release: rocky-release-8.5-2.el8 -> rocky-release-8.5-3.el8
* sssd: sssd-2.5.2-2.el8_5.1 -> sssd-2.5.2-2.el8_5.3

从2021年11月14日发布 8.5 版本以来，以下软件包已更新(包含更新后的模块软件包)：

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4
* kernel: kernel-4.18.0-305.19.1 (9-15)
* CVE-2021-20257
* CVE-2021-3712

以下软件包已被丢弃，同时也从 dnf 软件包组中删除：

* virt-rhel-8050020211221163306.b4937e53
* virt-devel-rhel-8050020211221163306.b4937e53
* postgresql-13-8050020211221161313.b4937e53
* postgresql-12-8050020211221161311.b4937e53
* freeradius-3.0-8050020211221161359.ab0f257b
* 389-ds-1.4-8050020211221162652.1a75f91c

### 发布工程说明

rocky-release 软件包已经更新，您可以将 countme=1 添加到 Rocky Linux 的 base 存储库中，类似于 epel 的存储库。 如果您已经修改了 repo 文件，将会生成 .rpmnew 文件，这样就不会覆盖您的更改。

## 8.4 - 2021-07-27

从2021年11月14日发布 8.5 版本以来，以下模块已经更新：

* selinux-policy: selinux-policy-3.14.3-80.el8 -> selinux-policy-3.14.3-80.el8_5.2
* extras -> CentOS SIG(Special Interest Group,特别兴趣小组) 发布包已被添加

## 8.4 - 2021-07-21

[bug 174](https://bugs.rockylinux.org/show_bug.cgi?id=174) - 我们注意到一个问题，即`kdump` 在ESXi等VMware系统上不起作用。

* varnish -> varnish-0:6.0.6-2.module+el8.4.0+628+e1687553.1 -> Addresses CVE-2021-36740
* go-toolset: go-toolset-1.16.7-1.module+el8.5.0+694+f77f0bfd -> go-toolset-1.16.12-1.module+el8.5.0+720+c057d5cf
* golang: golang-1.16.7-1.module+el8.5.0+694+f77f0bfd -> golang-1.16.12-1.module+el8.5.0+720+c057d5cf
* ipa: ipa-4.9.6-6.module+el8.5.0+675+61f67439 -> ipa-4.9.6-10.module+el8.5.0+719+4f06efb6
* nodejs: nodejs-1:16.8.0-1.module+el8.5.0+702+221f14e6 -> nodejs-1:16.13.1-3.module+el8.5.0+721+4c107270
* nodejs-nodemon: nodejs-nodemon-2.0.7-1.module+el8.5.0+702+221f14e6 -> nodejs-nodemon-2.0.15-1.module+el8.5.0+721+4c107270

* kernel-rt: kernel-rt-kvm added to RT

以下软件包自2022年01月11日起进行了更新：

* BaseOS

以下软件包已更新：

* go-toolset-rhel8-8050020211215173118-8aa62369
* idm-DL1-8050020211215093947-3d2c466f
* nodejs-16-8050020211215195043-b4937e53


### 发布工程说明

以下软件包已更新：

## 8.4 - 2021-07-12

以下存储库已更新：

* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909

以下软件包自2022年01月11日起进行了更新：

* rocky-release
* BaseOS
* CVE-2021-23192

## 8.4 - 2021-06-30

添加了以下存储库/软件包：

* python36
* libreoffice: libreoffice-1:6.4.7.2-5.el8.1 -> libreoffice-1:6.4.7.2-5.el8.2.rocky
* openscap: openscap-1.3.5-6.el8 -> openscap-1.3.5-6.el8.rocky.0.1
* pcs: pcs-0.10.10-4.el8 -> pcs-0.10.10-4.el8.rocky.0
* python2: python2-2.7.18-7.module+el8.5.0+706+735ec4b3.rocky.0.1 -> python2-2.7.18-7.module+el8.5.0+718+67e45b5f.rocky.0.2
* rocky-release: rocky-release-8.5-1.el8 -> rocky-release-8.5-2.el8

以下软件包已经更新：

* python27

### 发布工程说明

这些更新主要是外观上的，并不影响功能。

* WALinuxAgent -> 我们在这里以及微软的PR上游中添加了对 Rocky 的直接支持
* libreoffice -> 发现有红帽的品牌， 这次更新解决了这个品牌问题。
* openscap -> 缺少有关 Rocky Linux 的信息。
* pcs -> 该logo有一个未被删除的商标
* rocky-release -> 简化了 CPE_NAME
* python2 -> 将 Rocky 添加到支持的 dists 中

## 8.5 - 2021-12-09

以下软件包自2021年12月09日起进行了更新：

* PyYAML -> PyYAML-5.4.1-1.module+el8.4.0+595+c96abaa2
* thunderbird-91.4.0-2.el8_5
* thunderbird: thunderbird-91.3.0-2.el8.plus ->
* thunderbird-91.4.0-2.el8.plus

### 发布工程说明

Thunderbird：这是一个针对 Thunderbird 常规的 ESR 构建更新， 此次更新适用于 base 存储库与 Plus 存储库。 Plus 存储库包含一个支持 PGP 的 Thunderbird 版本。

## 8.5 - 2021-12-03

以下软件包已更新：

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0
* firefox: firefox-91.3.0-1.el8_4 -> firefox-91.4.0-1.el8_5
* sos: sos-4.1-5.el8 -> sos-4.1-5.el8.rocky.2

### 附加注释

为以下存储库添加了kickstart repos：

abrt：主要是外观上的变化。 移除了对 libreport-rhel* 和 rhtsupport 这些插件的依赖， 您可以在更新到新的 abrt 软件包之后，将这些软件包安全的删除。

sos：主要是外观上的变化。 它带来了 Rocky 的策略， 查阅 [this PR for more details](https://github.com/sosreport/sos/pull/2784)

## 8.5 - 2021-12-02

以下软件包自2021年12月02日起进行了更新：

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->
* mailman-3:2.1.29-12.module+el8.5.0+717+27fd1ba7.2

以下模块已更新：

* open-vm-tools (仅适用于aarch64的构建)

以下模块自2021年11月02日起已更新：

* ncurses-static (所有架构)


## 8.5 - 补充部分 - 2021-11-30

常规的 Rocky 软件包已进行更新，以解决以下问题：

* ncurses-static

关联的CVE：

* open-vm-tools (仅适用于aarch64的构建)

### 开发笔记

plus 存储库包含了 base 存储库中没有提供的项目，原因可能是由于comps和pungi配置 (基于 RHEL 存储库) 而无法使用这些项目，或者是在 base 存储库中找不到其他补丁/功能，被要求作为替代构建。 但 plus 存储库应该可以安全地保持启用状态。

关联的CVE：

* openldap-servers (所有架构)
* thunderbird with PGP support (所有架构)
* ncurses-static (所有架构)
* open-vm-tools (仅适用于aarch64的构建)

### 已知问题

应谨慎使用 devel 存储库， 它是被用于 koji 或 buildroot 目的的，不应该100%启用。 如果您希望在 devel 存储库中找到您想要查看的软件包，请在rocky-devel上发送邮件和（或者）在 https://bugs.rockylinux.org 上打开bug报告

## 8.5 - 2021-11-29

以下软件包自2022年01月03日起进行了更新：

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5
* nss: nss-3.67.0-6.el8_4 -> nss-3.67.0-7.el8_5

以下软件包已更新：

* nss-3.67.0-7.el8_5: CVE-2021-43527

## 8.5 - 2021-11-24

以下软件包自2021年11月24日起已更新：

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5
* dotnet5.0-build-reference-packages: dotnet5.0-build-reference-packages-0-11.20210607git5f10a4b.el8 -> dotnet5.0-build-reference-packages-0-12.20211117git6ce5818.el8_5


## 8.5 - 2021-11-22

一些模块和软件包已经被上游以常规方式更新。

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1

以下模块自2021年11月23日起已更新：

* mailman-2.1-8050020211123230959.fd901a62

一些模块和软件包已经被上游以常规方式更新。

* CVE-2021-42096
* CVE-2021-42097

## 8.5 - 2021-11-16

以下软件包自2021年11月16日起进行了更新(包含更新后的模块软件包)：

* insights-client: insights-client-3.1.5-1.el8 (标准软件包组)
* llvm-toolset: llvm-toolset-12.0.1-1.module+el8.5.0+692+8756646f -> llvm-toolset-12.0.1-1.module+el8.5.0+715+58f51d49

以下模块已更新：

* llvm-toolset-rhel8-8050020211122023437.b4937e53

## 8.5 - 2021-11-14

从2021年11月14日发布 8.5 版本以来，以下软件包已更新(包含更新后的模块软件包)：

* annobin: annobin-9.65-1.el8 -> annobin-9.72-1.el8_5.2
* binutils: binutils-2.30-108.el8 -> binutils-2.30-108.el8_5.1
* dotnet-build-reference-packages: dotnet-build-reference-packages-0-9.20200608gitcd5a8c6.el8 -> dotnet-build-reference-packages-0-10.20200608gitcd5a8c6.el8
* dotnet3.1: dotnet3.1-3.1.119-2.el8.0.1 -> dotnet3.1-3.1.120-2.el8_5
* dotnet5.0: dotnet5.0-5.0.207-3.el8.0.1 -> dotnet5.0-5.0.208-2.el8_5
* dotnet6.0: dotnet6.0-6.0.0-0.6.28be3e9a006d90d8c6e87d4353b77882829df718.el8.0.1 -> dotnet6.0-6.0.100-0.10.el8_5
* firefox: firefox-78.13.0-2.el8 -> firefox-91.3.0-1.el8
* flatpak: flatpak-1.8.5-4.el8 -> flatpak-1.8.5-5.el8_5
* freerdp: freerdp-2:2.2.0-2.el8 -> freerdp-2:2.2.0-7.el8_5
* gcc: gcc-8.5.0-3.el8 -> gcc-8.5.0-4.el8_5
* gcc-toolset-10-annobin: gcc-toolset-10-annobin-9.29-1.el8 -> gcc-toolset-10-annobin-9.29-1.el8_5.2
* gcc-toolset-10-binutils: gcc-toolset-10-binutils-2.35-8.el8_4.4 -> gcc-toolset-10-binutils-2.35-8.el8_5.6
* gcc-toolset-10-gcc: gcc-toolset-10-gcc-10.2.1-8.2.el8 -> gcc-toolset-10-gcc-10.3.1-1.2.el8_5
* gcc-toolset-11-annobin: gcc-toolset-11-annobin-9.73-1.el8 -> gcc-toolset-11-annobin-9.85-1.el8_5.1
* gcc-toolset-11-binutils: gcc-toolset-11-binutils-2.36.1-1.el8 -> gcc-toolset-11-binutils-2.36.1-1.el8_5.1
* gcc-toolset-11-dyninst: gcc-toolset-11-dyninst-11.0.0-1.el8 -> gcc-toolset-11-dyninst-11.0.0-2.el8
* gcc-toolset-11-gcc: gcc-toolset-11-gcc-11.1.1-3.el8 -> gcc-toolset-11-gcc-11.2.1-1.2.el8_5
* gcc-toolset-11-systemtap: gcc-toolset-11-systemtap-4.5-3.el8 -> gcc-toolset-11-systemtap-4.5-4.el8
* gcc-toolset-11-valgrind: gcc-toolset-11-valgrind-1:3.17.0-4.el8 -> gcc-toolset-11-valgrind-1:3.17.0-6.el8
* gnome-settings-daemon: gnome-settings-daemon-3.32.0-14.el8 -> gnome-settings-daemon-3.32.0-16.el8
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-20.el8 -> gnome-shell-extensions-3.32.1-20.el8_5.1
* httpd: httpd-2.4.37-41.module+el8.5.0+695+1fa8055e -> httpd-2.4.37-43.module+el8.5.0+714+5ec56ee8
* ibus: ibus-1.5.19-13.el8 -> ibus-1.5.19-14.el8_5
* java-1.8.0-openjdk: java-1.8.0-openjdk-1:1.8.0.302.b08-3.el8 -> java-1.8.0-openjdk-1:1.8.0.312.b07-2.el8_5
* java-11-openjdk: java-11-openjdk-1:11.0.12.0.7-4.el8 -> java-11-openjdk-1:11.0.13.0.8-3.el8_5
* java-17-openjdk: java-17-openjdk-1:17.0.0.0.35-4.el8 -> java-17-openjdk-1:17.0.1.0.12-2.el8_5
* kernel: kernel-4.18.0-348.el8.0.2 -> kernel-4.18.0-348.2.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.rt7.130.el8.0.2 -> kernel-rt-4.18.0-348.2.1.rt7.132.el8_5
* kronosnet: kronosnet-1.18-1.el8 -> kronosnet-1.18-2.el8
* rust: rust-1.54.0-2.module+el8.5.0+678+cf7bc64b -> rust-1.54.0-3.module+el8.5.0+712+d335422a
* rust-toolset: rust-toolset-1.54.0-1.module+el8.5.0+678+cf7bc64b -> rust-toolset-1.54.0-1.module+el8.5.0+712+d335422a
* sssd: sssd-2.5.2-2.el8 -> sssd-2.5.2-2.el8_5.1
* thunderbird: thunderbird-78.13.0-1.el8 -> thunderbird-91.3.0-2.el8
* udftools: udftools-2.2-5.el8 -> udftools-2.3-2.el8

一些模块和软件包已经被上游以常规方式更新。

* firefox: 更新至78.14.0

一些模块和软件包已经被上游以常规方式更新。

一些模块和软件包已经被上游以常规方式更新。

* extras -> CentOS SIG(Special Interest Group,特别兴趣小组) 发布包已被添加
* httpd-2.4-8050020211115030420.b4937e53

### 附加更改

一些模块和软件包已经被上游以常规方式更新。

我们还了解到镜像系统做更新时报告了有错误的目录， 它应该去到`kickstart` 请求应答文件而不是 `OS`(操作系统)。 这个问题应该可以通过更新来解决，使其正常工作。

## 8.4 - 2021-09-21

一些模块和软件包已经被上游以常规方式更新。

* kernel: kernel-4.18.0-305.19.1 (9-15)
* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.2
* golang: 1.15.14-2
* nss: 3.67.0-6
* ca-certificates: 2021.2.50-80.0
* opencryptoki: 3.15.1-7
* krb5: 1.18.2-8.3
* platform-python: 3.6.8-38
* libdb: 5.3.28-42
* rng-tools: 6.8-4
* sos: 4.0-12
* python-ldap: 3.3.1-1.1
* subscription-manager: 1.28.13-4
* pcp: 5.2.5-6
* strace: 5.7-2.1
* nspr: 4.32.0-1
* gcc-toolset-10-elfutils: 0.182-6
* gcc-toolset-10-binutils: 2.35-8.el8_4.4
* maven: maven-3.6.2-6
* mysql: 8.0.26
* selinux-policy: 3.14.3-67.el8_4.2
* grub2: 2.02-99.el8_4.1.1
* resource-agents: 4.1.1-90.el8_4.7
* poppler: 20.11.0-2.el8_4.1
* pacemaker: 2.0.5-9.el8_4.3

## 8.4 - 2021-09-13

一些模块和软件包已经被上游以常规方式更新。

* thunderbird: 更新至78.14.0
* Firefox: 更新至78.14.0
* cyrus-imapd: 更新至3.0.7-20.el8_4.1(地址 CVE-2021-33582)
* systemtap将根据dyinest 10.2进行重新构建，以解决漏洞报告
* rocky-release -> 更新为允许"centos"作为ID

以下模块已更新：

* extras -> CentOS SIG(Special Interest Group,特别兴趣小组) 发布包已被添加

## 8.4 - 2021-08-24

一些模块和软件包已经被上游以常规方式更新。

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4
* libsndfile: libsndfile-1.0.28-10.el8_4 -> libsndfile-1.0.28-10.el8_4.1 -- Addresses

  * Addresses a heap buffer overflow that allowed arbitrary code execution from a wav file

* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.1

  * Addresses RLBZ#108

一些模块和软件包已经被上游以常规方式更新。

* RT (realtime) - 通过运行 `dnf config-manager --set-enabled rt` 来启用

  * kernel-rt (实时内核)

## 8.4 - 2021-08-11

一些模块和软件包已经被上游以常规方式更新。

* 389-ds-base: 389-ds-base-1.4.3.16-16.module+el8.4.0+596+159889e5 -> 389-ds-base-1.4.3.16-19.module+el8.4.0+636+837ee950
* NetworkManager: NetworkManager-1:1.30.0-9.el8_4 -> NetworkManager-1:1.30.0-10.el8_4
* autofs: autofs-1:5.1.4-48.el8 -> autofs-1:5.1.4-48.el8_4.1
* buildah: buildah-1.19.7-2.module+el8.4.0+556+40122d08 -> buildah-1.21.4-1.module+el8.4.0+643+525e162a
* cloud-init: cloud-init-20.3-10.el8_4.3 -> cloud-init-20.3-10.el8_4.5
* cockpit-podman: cockpit-podman-29-2.module+el8.4.0+556+40122d08 -> cockpit-podman-32-2.module+el8.4.0+643+525e162a
* conmon: conmon-2:2.0.26-3.module+el8.4.0+556+40122d08 -> conmon-2:2.0.29-1.module+el8.4.0+643+525e162a
* container-selinux: container-selinux-2:2.162.0-1.module+el8.4.0+556+40122d08 -> container-selinux-2:2.164.1-1.module+el8.4.0+643+525e162a
* crun: crun-0.18-2.module+el8.4.0+556+40122d08 -> crun-0.20.1-1.module+el8.4.0+643+525e162a
* dotnet3.1 dotnet3.1-3.1.117-1.el8_4 -> dotnet3.1-3.1.118-1.el8_4
* edk2: edk2-20200602gitca407c7246bf-4.el8_4.1 -> edk2-20200602gitca407c7246bf-4.el8_4.2
* elfutils: elfutils-0.182-3.el8 -> elfutils-0.182-3.el8_4
* esc: esc-1.1.2-18.el8 -> esc-1.1.2-22.el8_4
* fence-agents: fence-agents-4.2.1-65.el8 -> fence-agents-4.2.1-65.el8_4.1
* fuse-overlayfs: fuse-overlayfs-1.4.0-3.module+el8.4.0+556+40122d08 -> fuse-overlayfs-1.6-1.module+el8.4.0+643+525e162a
* gcc-toolset-10-elfutils: gcc-toolset-10-elfutils-0.182-3.el8 -> gcc-toolset-10-elfutils-0.182-5.el8_4
* gcc-toolset-10-valgrind: gcc-toolset-10-valgrind-1:3.16.0-4.el8 -> gcc-toolset-10-valgrind-1:3.16.0-6.el8_4
* glib2: glib2-2.56.4-10.el8_4 -> glib2-2.56.4-10.el8_4.1
* gnome-shell-extensions: gnome-shell-extensions-3.32.1-14.el8.1 -> gnome-shell-extensions-3.32.1-15.el8_4.1
* go-toolset: go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3 -> go-toolset-1.15.14-1.module+el8.4.0+632+4dba2916
* golang: golang-1.15.13-3.module+el8.4.0+591+0da41cc3 -> golang-1.15.14-1.module+el8.4.0+632+4dba2916
* hivex: hivex-1.3.18-20.module+el8.4.0+534+4680a14e -> hivex-1.3.18-21.module+el8.4.0+642+7e26f5e1
* kernel: kernel-4.18.0-305.10.2.el8_4 -> kernel-4.18.0-305.12.1.el8_4
* kexec-tools: kexec-tools-2.0.20-46.el8_4.1 -> kexec-tools-2.0.20-46.el8_4.2
* libuv: libuv-1:1.40.0-1.el8 -> libuv-1:1.41.1-1.el8_4
* libvirt: libvirt-6.0.0-35.module+el8.4.0+534+4680a14e -> libvirt-6.0.0-35.1.module+el8.4.0+642+7e26f5e1
* libwacom: libwacom-1.6-2.el8 -> libwacom-1.6-2.1.el8_4
* mdadm: mdadm-4.1-15.el8 -> mdadm-4.1-16.el8_4
* nfs-utils: nfs-utils-1:2.3.3-41.el8 -> nfs-utils-1:2.3.3-41.el8_4.2
* nmstate: nmstate-1.0.2-11.el8_4 -> nmstate-1.0.2-14.el8_4
* nodejs: nodejs-1:12.21.0-1.module+el8.3.0+99+3663d81c -> nodejs-1:12.22.3-2.module+el8.4.0+638+5344c6f7
* nodejs-nodemon: nodejs-nodemon-2.0.3-1.module+el8.3.0+100+234774f7 -> nodejs-nodemon-2.0.3-1.module+el8.4.0+638+5344c6f7
* oci-seccomp-bpf-hook: oci-seccomp-bpf-hook-1.2.0-2.module+el8.4.0+556+40122d08 -> oci-seccomp-bpf-hook-1.2.3-2.module+el8.4.0+643+525e162a
* opencryptoki: opencryptoki-3.15.1-5.el8 -> opencryptoki-3.15.1-6.el8_4
* ostree: ostree-2020.7-4.el8 -> ostree-2020.7-5.el8_4
* pcp: pcp-5.2.5-4.el8 -> pcp-5.2.5-5.el8_4
* pcsc-lite: pcsc-lite-1.8.23-3.el8 -> pcsc-lite-1.8.23-4.1.el8_4
* pcsc-lite-ccid: pcsc-lite-ccid-1.4.29-4.el8 -> pcsc-lite-ccid-1.4.29-5.1.el8_4
* perl: perl-4:5.26.3-419.el8 -> perl-4:5.26.3-419.el8_4.1
* perl-IO-String: perl-IO-String-1.08-31.el8 -> perl-IO-String-1.08-32.el8
* podman: podman-3.0.1-7.module+el8.4.0+556+40122d08 -> podman-3.2.3-0.10.module+el8.4.0+643+525e162a
* qemu-kvm: qemu-kvm-15:4.2.0-48.module+el8.4.0+534+4680a14e -> qemu-kvm-15:4.2.0-48.module+el8.4.0+642+7e26f5e1.3
* resource-agents: resource-agents-4.1.1-90.el8_4.5 -> resource-agents-4.1.1-90.el8_4.6
* runc: runc-1.0.0-73.rc93.module+el8.4.0+556+40122d08 -> runc-1.0.0-74.rc95.module+el8.4.0+643+525e162a
* rust: rust-1.49.0-1.module+el8.4.0+416+259a129a -> rust-1.52.1-1.module+el8.4.0+641+ca238f88
* rust-toolset: rust-toolset-1.49.0-1.module+el8.4.0+416+259a129a -> rust-toolset-1.52.1-1.module+el8.4.0+641+ca238f88
* samba: samba-4.13.3-3.el8 -> samba-4.13.3-4.el8_4
* selinux-policy: selinux-policy-3.14.3-67.el8 -> selinux-policy-3.14.3-67.el8_4.1
* skopeo: skopeo-1:1.2.2-10.module+el8.4.0+556+40122d08 -> skopeo-1:1.3.1-5.module+el8.4.0+643+525e162a
* spirv-tools: spirv-tools-2020.5-3.20201208.gitb27b1af.el8 -> spirv-tools-2021.2-1.20210619.git5dd2f76.el8_4
* stalld: stalld-1.9-2.el8 -> stalld-1.10-1.el8_4
* systemd: systemd-239-45.el8_4.2 -> systemd-239-45.el8_4.3
* systemtap: systemtap-4.4-10.el8 -> systemtap-4.4-11.el8_4
* udica: udica-0.2.4-1.module+el8.4.0+556+40122d08 -> udica-0.2.4-2.module+el8.4.0+643+525e162a
* valgrind: valgrind-1:3.16.0-4.el8 -> valgrind-1:3.16.0-4.el8_4
* virt-what: virt-what-1.18-6.el8 -> virt-what-1.18-9.el8_4
* virt-who: virt-who-1.30.5-1.el8 -> virt-who-1.30.5-2.el8_4
* virtio-win: virtio-win-1.9.16-2.el8 -> virtio-win-1.9.17-4.el8_4
* vulkan-headers: vulkan-headers-1.2.162.0-1.el8 -> vulkan-headers-1.2.182.0-1.el8_4
* vulkan-loader: vulkan-loader-1.2.162.0-1.el8 -> vulkan-loader-1.2.182.0-1.el8_4
* vulkan-tools: vulkan-tools-1.2.162.0-1.el8 -> vulkan-tools-1.2.182.0-1.el8_4
* vulkan-validation-layers: vulkan-validation-layers-1.2.162.0-1.el8 -> vulkan-validation-layers-1.2.182.0-1.el8_4

## 8.4 - 2021-08-02

一些模块和软件包已经被上游以常规方式更新。

* varnish -> varnish-0:6.0.6-2.module+el8.4.0+628+e1687553.1 -> Addresses CVE-2021-36740

为以下存储库添加了kickstart repos：

* BaseOS
* AppStream
* PowerTools
* High Availability
* Resilient Storage

## 8.4 - 2021-07-27

一些模块和软件包已经被上游以常规方式更新。

* thunderbird -> thunderbird-78.12.0-3.el8_4

## 8.4 - 2021-07-21

一些模块和软件包已经被上游以常规方式更新。

* kernel -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909
* systemd -> systemd-239-45.el8_4.2 -> Addresses CVE-2021-33910
* firefox
* java-1.8.0-openjdk
* java-11-openjdk

## 8.4 - 2021-07-12

一些模块和软件包已经被上游以常规方式更新。

* rocky-release
* linuxptp
* rpaste
* ovn2.13 (NFV)

关联的CVE：

* python36

### 即将到来

aarch64 的 extras 存储库已更新，以包含上游未包含的各种软件包。 例如 libreoffice 和其他 gnome 应用程序。

```
repo_gpgcheck=1
```

### 软件包更新

* 存储插件库

  * 为未来的情况添加 devel 和 debuginfo 存储库

## 8.4 - 2021-06-30

### 背景

一些模块和软件包已经被上游以常规方式更新。

* 现在提供了一个用于 模拟/构建根 目的的"devel"存储库
* aarch64 的 Extras 存储库已更新，以包含上游未提供给桌面使用的缺失软件包
* rpaste已经更新，可以接受标准输入。
* edk2 -> edk2-20200602gitca407c7246bf-4.el8_4.1
* exiv2 -> exiv2-0.27.3-2.el8
* firewalld -> firewalld-0.8.2-7.el8_4
* fwupd -> fwupd-1.5.9-1.el8_4
* gnome-session -> gnome-session-3.28.1-10.el8_4.1
* kernel -> kernel-4.18.0-305.7.1.el8_4
* kexec-tools -> kexec-tools-2.0.20-46.el8_4.1
* libpq -> libpq-13.3-1.el8_4
* libreport -> libreport-2.9.5-15.el8.rocky.2
* libxml2 -> libxml2-2.9.7-9.el8_4.2
* lz4 -> lz4-1.8.3-3.el8_4
* nmstate -> nmstate-1.0.2-11.el8_4
* nvme-cli -> nvme-cli-1.12-4.el8_4
* openldap -> openldap-2.4.46-17.el8_4
* osbuild-composer -> osbuild-composer-28.6-1.el8_4
* resource-agents -> resource-agents-4.1.1-90.el8_4.5
* rocky-logos -> rocky-logos-84.5-8.el8
* rocky-release -> rocky-release-8.4-29.el8
* rpm -> rpm-4.14.3-14.el8_4
* rsyslog -> rsyslog-8.1911.0-7.el8_4.2
* sanlock -> sanlock-3.8.3-3.el8_4
* sssd -> sssd-2.4.0-9.el8_4.1
* subscription-manager -> subscription-manager-1.28.13-3.el8_4
* systemd -> systemd-239-45.el8_4.1
* tuned -> tuned-2.15.0-2.el8_4.1
* unzip -> unzip-6.0-45.el8_4

关联的CVE：

* PyYAML -> PyYAML-5.4.1-1.module+el8.4.0+595+c96abaa2
* 389-ds -> 1.4.3.16-16
* go-toolset -> go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3
* golang -> golang-1.15.13-3.module+el8.4.0+591+0da41cc3
* idm:DL1 -> ipa-4.9.2-4
* idm:client -> (rebuilt with ipaplatform=rhel to sync with DL1 module)
* pgaudit -> pgaudit-1.4.0-6.module+el8.4.0+587+d46efd10
* postgres-decoderbufs -> postgres-decoderbufs-0.10.0-2.module+el8.4.0+587+d46efd10
* postgresql -> postgresql-12.7-1.module+el8.4.0+587+d46efd10
* python38 -> python38-3.8.6-3.module+el8.4.0+595+c96abaa2
* ruby -> ruby-2.5.9-107.module+el8.4.0+592+03ff458a
* ruby:2.5 -> 2.5.9-107
* ruby:2.6 -> 2.6.7-107
* ruby:2.7 -> 2.7.3-136
* rubygem-abrt -> rubygem-abrt-0.3.0-4 / rubygem-abrt-0.4.0-1
* rubygem-bson -> rubygem-bson-4.3.0-2 / rubygem-bson-4.5.0-1 / rubygem-bson-4.8.1-1
* rubygem-bundler -> rubygem-bundler-1.16.1-3.module+el8.4.0+592+03ff458a
* rubygem-mongo -> rubygem-mongo-2.5.1-2 / rubygem-mongo-2.8.0-1 / rubygem-mongo-2.11.3-1
* rubygem-pg -> rubygem-pg-1.0.0-2 / rubygem-pg-1.1.4-1 / rubygem-pg-1.2.3-1


### 附加更改

一些模块和软件包已经被上游以常规方式更新。

常规的 Rocky 软件包已进行更新，以解决以下问题：

* rocky-release

  * 为未来的情况添加 devel 和 debuginfo 存储库
  * 这是为了 模拟/构建根 目的而提供的

* rocky-logos

  * 改进未来官方的live镜像图标


### 即将到来

aarch64 的 extras 存储库已更新，以包含上游未包含的各种软件包。 例如 libreoffice 和其他 gnome 应用程序。 因为它们不在 BaseOS 或 AppStream 中，所以 extras 存储库是存放这些软件包的合适地方。

* 现在提供了一个用于 模拟/构建根 目的的"devel"存储库
* aarch64 的 Extras 存储库已更新，以包含上游未提供给桌面使用的缺失软件包
* rpaste已经更新，可以接受标准输入。
* 在点发布(point release)的生命周期内，将在 repos 中提供较旧的包。

  * 这将允许在上游软件包回归(regressions)或者需要排查问题的情况下，将其降级到已知的良好版本。
