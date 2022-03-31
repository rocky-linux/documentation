---
title: ログの変更
author: ルイ・アベル
contributors: Steven Spencer, tianci li
tags:
  - '♪rocky changelog ♪'
  - 更新履歴
---

# Rocky Linux 8 変更ログ

Rocky Linux 8は、アップストリームのビルドとプッシュの間に、インクリメンタルアップデートとマイナーバージョンアップグレードを受け取ります。 このページでは、変更内容の詳細や変更内容をご案内します。 Rocky Linuxを実行しているシステムは、 `dnf update` を実行することで、いつでもシステムを完全に更新することができます。 この文書の更新が遅れることがあります。 新しいアップデートを確認するには、 [Rocky Announce](https://lists.resf.org/archives/list/rocky-announce@lists.resf.org/) メーリングリストのアーカイブを参照してください。

### 更新

アップストリーム以降にリリースされたアップデートは、現在のアーキテクチャに掲載されます。 既存の Rocky Linux マシンには、本日リリースされたコンテンツを含め、すべてのユーザーが ** すべてのアップデートを適用することを強くお勧めします。 これは `dnf update` を実行することで行うことができます。

すべての Rocky Linux コンポーネントは、 [git.rockylinux.org](https://git.rockylinux.org) でホストされるソースから構築されています。 さらに、SRPMは、対応する「source」ディレクトリのリポジトリとともに公開されています。 あなたは私たちのミラーのいずれかにこれらを見つけることができます。 これらのソースパッケージは私たちがリリースするすべてのバイナリRPMと一致します。

## 8.5 - 2022-03-15

2022年3月15日以降、以下のパッケージが更新されました。

* expat-2.2.5-4.el8_5.3
* tzdata-2022a-1.el8
* httpd-2.4.37-43.module+el8.5.0+747+83fae388.3
* openssl-1.1.1k-6.el8_5

以下のモジュールが更新されました：

* httpd

関連付けられた CVE:

* CVE-2022-25236
* CVE-2022-25235
* CVE-2022-25315
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

### 追加情報

2週間以内にお知らせがなかったことをお詫び申し上げます。 現在、これらの発表は手作業で行われており、人とのやり取りが少なく、より自動化される計画が進行中です。

RHEL 8のリリースと。 ベータ! 私たちは、何が変化しているのか、そして4月下旬または5月にその潜在的なGAの前に、今後数週間のために私たちのビルドを行う必要がある方法を検討します。 この間、RHEL 9ベータパッケージの起動にも取り組んでおり、最終的にインポートされるようになりました。 新しいビルドシステムで再構築テストを行いました

## 8.5 - 2022-03-14

2022年3月14日以降、以下のパッケージが更新されました。

* 389-ds-base: 389-ds-base-1.4.3.23-12.module+el8.5.0+722+e2a0b219 -> 389-ds-base-1.4.3.23-14.module+el8.5.0+745+c5be6847
* cloud-init: cloud-init-21.1-7.el8_5.3 -> cloud-init-21.1-7.el8_5.4
* fence-agents: fence-agents-4.2.1-75.el8 -> fence-agents-4.2.1-75.el8_5.2
* firewalld: firewalld-0.9.3-7.el8 -> firewalld-0.9.3-7.el8_5.1
* gdm: gdm-1:40.0-15.el8 -> gdm-1:40.0-15.el8_5.1
* glibc: glibc-2.28-164.el8 -> glibc-2.28-164.el8_5.3
* httpd: httpd-2.4.37-43.module+el8.5.0+727+743c5577.1 -> httpd-2.4.37-43.module+el8.5.0+746+b6ce3176.2
* java-11-openjdk: java-11-openjdk-1:11.0.14.0.9-2.el8_5 -> java-11-openjdk-1:11.0.14.1.1-2.el8_5
* libarchive: libarchive-3.3.3-1.el8_5 -> libarchive-3.3.3-3.el8_5
* libxml2: libxml2-2.9.7-11.el8 -> libxml2-2.9.7-12.el8_5
* linux-firmware: linux-firmware-20210702-103.gitd79c2677.el8 -> linux-firmware-20210702-104.gitd79c2677.el8_5
* lvm2: lvm2-8:2.03.12-10.el8 -> lvm2-8:2.03.12-11.el8_5
* nmstate: nmstate-1.1.0-5.el8_5 -> nmstate-1.1.0-6.el8_5
* pcs: pcs-0.10.10-4.el8.rocky.0 -> pcs-0.10.10-4.el8_5.1.rocky.0
* plymouth: plymouth-0.9.4-10.20200615git1e36e30.el8 -> plymouth-0.9.4-10.20200615git1e36e30.el8_5.1
* qemu-kvm: qemu-kvm-15:4.2.0-59.module+el8.5.0+726+ce09ee88.1 -> qemu-kvm-15:4.2.0-59.module+el8.5.0+744+67293bef.2
* redhat-support-lib-python: redhat-support-lib-python-0.11.3-1.el8 -> redhat-support-lib-python-0.13.0-0.el8_5
* redhat-support-tool: redhat-support-tool-0.11.3-2.el8 -> redhat-support-tool-0.13.0-0.el8_5
* samba: samba-4.14.5-9.el8_5 -> samba-4.14.5-10.el8_5
* subscription-manager: subscription-manager-1.28.21-3.el8 -> subscription-manager-1.28.21-5.el8_5
* systemd: systemd-239-51.el8_5.3 -> systemd-239-51.el8_5.5
* vim: vim-2:8.0.1763-16.el8_5.4 -> vim-2:8.0.1763-16.el8_5.12

以下のモジュールが更新されました：

* 389-ds
* httpd
* virt
* virt-devel

## 8.5 - 2022-03-10

2022年3月10日以降、以下のパッケージが更新されました。

* thunderbird: thunderbird-91.6.0-1.el8_5 -> thunderbird-91.7.0-2.el8_5
* thunderbird: thunderbird-91.6.0-1.el8_5.plus -> thunderbird-91.7.0-2.el8_5.plus

関連付けられた CVE:

* CVE-2022-25315
* CVE-2022-25235
* CVE-2022-25236

## 8.5 - 2022-02-24

2022年2月24日以降、以下のパッケージが更新されました。

* dotnet3.1: dotnet3.1-3.1.416-3.el8_5 -> dotnet3.1-3.1.417-1.el8_5
* dotnet5.0: dotnet5.0-5.0.211-1.el8_5 -> dotnet5.0-5.0.212-1.el8_5
* dotnet6.0: dotnet6.0-6.0.102-1.el8_5 -> dotnet6.0-6.0.103-4.el8_5
* firefox: firefox-91.6.0-1.el8_5 -> firefox-91.7.0-3.el8_5
* kernel: kernel-4.18.0-348.12.2.el8_5 -> kernel-4.18.0-348.20.1.el8_5
* kernel-rt: kernel-rt-4.18.0-348.12.2.rt7.143.el8_5 -> kernel-rt-4.18.0-348.20.1.rt7.150.el8_5

関連付けられた CVE:

* CVE-2022-0435
* CVE-2022-0847

## 8.5 - 2022-02-22

2022年2月22日以降、以下のパッケージが更新されました。

* cyrus-sasl: cyrus-sasl-2.1.27-5.el8 -> cyrus-sasl-2.1.27-6.el8_5

関連付けられた CVE:

* CVE-2022-24407

## 8.5 - 2022-02-16

2022年2月16日以降、以下のパッケージが更新されました。

* python-pillow: python-pillow-5.1.1-16.el8 -> python-pillow-5.1.1-18.el8_5

関連付けられた CVE:

* CVE-2022-22815
* CVE-2022-22816
* CVE-2022-22817

## 8.5 - 2022-02-15

以下のモジュールは2022年2月15日から更新されました。

* ruby-2.5-8050020216182135.b4937e53
* ruby-2.6-8050020216165459.b4937e53

## 8.5 - 2022-02-14

2022年2月14日以降、以下のパッケージが更新されました。

* thunderbird: thunderbird-91.5.0-1.el8_5 -> thunderbird-91.6.0-1.el8_5
* thunderbird: thunderbird-91.5.0-1.el8.plus -> thunderbird-91.6.0-1.el8_5.plus

## 8.5 - 2022-02-09

2022年2月9日以降、以下のパッケージが更新されました。

* dotnet3.1: dotnet3.1-3.1.120-2.el8_5 -> dotnet3.1-3.1.416-3.el8_5
* dotnet5.0: dotnet5.0-5.0.210-1.el8_5 -> dotnet5.0-5.0.211-1.el8_5
* dotnet6.0: dotnet6.0-6.0.101-2.el8_5 -> dotnet6.0-6.0.102-1.el8_5
* firefox: firefox-91.5.0-1.el8_5 -> firefox-91.6.0-1.el8_5

## 8.5 - 2022-02-04

2022年2月4日以降、以下のパッケージが更新されました。

* aide: aide-0.16-14.el8 -> aide-0.16-14.el8_5.1

関連付けられた CVE:

* CVE-2021-45417

## 8.5 - 2022-02-02

2022年2月02日以降、以下のモジュール/パッケージが更新されました。

* varnish-6.0.8-1.module+el8.5.0+677+2a78a869 -> varnish-6.0.8-1.module+el8.5.0+736+fec10e21.1

関連付けられた CVE:

* CVE-2022-23959

## 8.5 - 2022-02-01

2022年2月1日以降、以下のパッケージが更新されました。

* clevis: clevis-15-1.el8 -> clevis-15-1.el8_5.1
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

以下のモジュールが更新されました：

* containertools
* フリーラディウス
* nodejs
* pki-core
* virt
* virt-devel

## 8.5 - 2022-01-27

2022年1月27日以降、以下のパッケージが更新されました。

* dotnet-build-reference-packages: dotnet-build-reference-packages-0-10.20200608gitcd5a8c6.el8 ->dotnet-build-reference-packages-0-11.20211215git045b288.el8_5
* nginx: nginx-1:1.20.0-2.module+el8.5.0+669+b11495b0 -> nginx-1:1.20.1-1.module+el8.5.0+729+3f70613e
* samba: samba-4.14.5-7.el8_5 -> samba-4.14.5-9.el8_5

以下のモジュールが更新されました：

* nginx

関連付けられた CVE:

* CVE-2021-44142
* CVE-2021-23017

## 8.5 - 2022-01-26

2022年1月26日以降、以下のパッケージが更新されました。

* java-1.8.0-openjdk: java-1.8.0-openjdk-1:1.8.0.312.b07-2.el8_5 -> java-1.8.0-openjdk-1:1.8.0.322.b06-2.el8_5

## 8.5 - 2022-01-25

2022年1月25日以降、以下のパッケージが更新されました。

* parfait: parfait-0.5.4-2.module+el8.3.0+214+edf13b3f -> parfait-0.5.4-4.module+el8.5.0+728+553fbdb8

次のパッケージがドロップされました：

* log4j12: log4j12-1.2.17-22.module+el8.3.0+214+edf13b3f

以下のモジュールが更新されました：

* parfait

## 8.5 - 2022-01-24

2022年1月24日以降、以下のパッケージが更新されました。

* httpd: httpd-2.4.37-43.module+el8.5.0+714+5ec56ee8 -> httpd-2.4.37-43.module+el8.5.0+727+743c5577.1
* polkit: polkit-0.115-12.el8 -> polkit-0.115-13.el8_5.1

以下のモジュールが更新されました：

* httpd

関連付けられた CVE:

* CVE-2021-44790
* CVE-2021-4034

## 8.5 - 2022-01-19

以下のパッケージは2022年1月19日から更新されました。

* java-11-openjdk: java-11-openjdk-1:11.0.13.0.8-4.el8_5 -> java-11-openjdk-1:11.0.14.0.9-2.el8_5

## 8.5 - 2022-01-12

2022年1月12日以降、以下のパッケージが更新されました。

* gegl04: gegl04-0.4.4-6.el8 -> gegl04-0.4.4-6.el8_5.2
* java-17-openjdk: java-17-openjdk-1:17.0.1.0.12-2.el8_5 -> java-17-openjdk-1:17.0.2.0.8-4.el8_5
* kernel: kernel-4.18.0-348.7.1.el8_5 -> kernel-4.18.0-348.12.2.el8_5
* kernel-rt: kernel-rt-4.18.0-348.7.1.rt7.137.el8_5 -> kernel-rt-4.18.0-348.12.2.rt7.143.el8_5
* libarchive: libarchive-3.3.3-1.el8 -> libarchive-3.3.3-1.el8_5
* libreswan: libreswan-4.4-1.el8 -> libreswan-4.4-4.el8_5

関連付けられた CVE:

* CVE-2022-0185
* CVE-2021-45463
* CVE-2021-4155

## 8.5 - 2022-01-11

2022年1月11日以降、以下のパッケージが更新されました。

* firefox: firefox-91.4.0-1.el8_5 -> firefox-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8_5 -> thunderbird-91.5.0-1.el8_5
* thunderbird: thunderbird-91.4.0-2.el8.plus -> thunderbird-91.5.0-1.el8.plus

## 8.5 - 2022-01-03

以下のパッケージは2022年1月3日から更新されました。

* dotnet6.0: dotnet6.0-6.0.100-0.10.el8_5 -> dotnet6.0-6.0.101-2.el8_5
* rpaste: rpaste-0.1-3.el8.2 -> rpaste-0.2.0-1.el8

## 8.5 - 2021-12-22

2021年12月22日以降、以下のパッケージが更新されました。

* grafana: grafana-7.5.9-4.el8 -> grafana-7.5.9-5.el8_5

関連付けられた CVE:

* CVE-2021-44716

## 8.5 - 2021-12-17

2021年12月17日以降、以下のパッケージが更新されました。

* 389-ds-base: 389-ds-base-1.4.3.23-10.module+el8.5.0+700+370e33d5 -> 389-ds-base-1.4.3.23-12.module+el8.5.0+722+e2a0b219
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

関連付けられた CVE:

* CVE-2021-20321
* CVE-2021-3930
* CVE-2021-20257
* CVE-2021-3712

フォローモジュールが更新されました：

* virt-rhel-8050020211221163306.b4937e53
* virt-devel-rhel-8050020211221163306.b4937e53
* postgresql-13-8050020211221161313.b4937e53
* postgresql-12-8050020211221161311.b4937e53
* freeradius-3.0-8050020211221161359.ab0f257b
* 389-ds-1.4-8050020211221162652.1a75f91c

### エンジニアリングノート

rocky-release パッケージが更新され、epel のリポジトリと同様に、Rocky Linux のベース リポジトリに countme=1 を追加します。 でリポジトリファイルを変更した場合、変更を上書きしないように .rpmnew ファイルが生成されます。

## 8.5 - 2021-12-16

2021年12月16日以降、以下のパッケージが更新されました。

* selinux-policy: selinux-policy-3.14.3-80.el8 -> selinux-policy-3.14.3-80.el8_5.2
* systemd: systemd-239-51.el8 -> systemd-239-51.el8_5.3

## 8.5 - 2021-12-13

2021年12月13日以降、以下のパッケージが更新されました。

* dotnet5.0: dotnet5.0-5.0.209-1.el8_5 -> dotnet5.0-5.0.210-1.el8_5
* go-toolset: go-toolset-1.16.7-1.module+el8.5.0+694+f77f0bfd -> go-toolset-1.16.12-1.module+el8.5.0+720+c057d5cf
* golang: golang-1.16.7-1.module+el8.5.0+694+f77f0bfd -> golang-1.16.12-1.module+el8.5.0+720+c057d5cf
* ipa: ipa-4.9.6-6.module+el8.5.0+675+61f67439 -> ipa-4.9.6-10.module+el8.5.0+719+4f06efb6
* nodejs: nodejs-1:16.8.0-1.module+el8.5.0+702+221f14e6 -> nodejs-1:16.13.1-3.module+el8.5.0+721+4c107270
* nodejs-nodemon: nodejs-nodemon-2.0.7-1.module+el8.5.0+702+221f14e6 -> nodejs-nodemon-2.0.15-1.module+el8.5.0+721+4c107270

* kernel-rt: kernel-rt-kvm を RT に追加しました

関連付けられた CVE:

* CVE-2020-25717

フォローモジュールが更新されました：

* go-toolset-rhel8-8050020211215173118-8aa62369
* idm-DL1-8050020211215093947-3d2c466f
* nodejs-16-8050020211215195043-b4937e53


### エンジニアリングノート

リクエストに基づいて、kernel-rt-kvm パッケージが RT リポジトリに追加されました。

## 8.5 - 2021-12-12

2021年12月12日以降、以下のパッケージが更新されました。

* samba: samba-4.14.5-2.el8 -> samba-4.14.5-7.el8_5

関連付けられた CVE:

* CVE-2016-2124
* CVE-2020-25717
* CVE-2021-23192

## 8.5 - 2021-12-10

2021年12月10日以降、以下のパッケージが更新されました。

* WALinuxAgent: WALinuxAgent-2.3.0.2-2.el8 -> WALinuxAgent-2.3.0.2-2.el8.rocky.0
* libreoffice: libreoffice-1:6.4.7.2-5.el8.1 -> libreoffice-1:6.4.7.2-5.el8.2.rocky
* openscap: openscap-1.3.5-6.el8 -> openscap-1.3.5-6.el8.rocky.0.1
* pcs: pcs-0.10.10-4.el8 -> pcs-0.10.10-4.el8.rocky.0
* python2: python2-2.7.18-7.module+el8.5.0+706+735ec4b3.rocky.0.1 -> python2-2.7.18-7.module+el8.5.0+718+67e45b5f.rocky.0.2
* rocky-release: rocky-release-8.5-1.el8 -> rocky-release-8.5-2.el8

フォローモジュールが更新されました：

* python27

### エンジニアリングノート

これらのアップデートはほとんどが自然の中で化粧品であり、機能には影響しません。

* WALinuxAgent -> マイクロソフトのPRアップストリームに直接Rockyサポートを追加しました。
* libreoffice -> 赤い帽子のブランディングが見つかりました。 このアップデートはブランディングに対応しています。
* openscap -> Rocky Linuxの情報がありませんでした。
* pcs -> ロゴには削除されなかった商標がありました
* rocky-release -> CPE_NAME を簡略化
* python2 -> サポートされているdistsにrockyを追加

## 8.5 - 2021-12-09

2021年12月9日以降、以下のパッケージが更新されました。

* thunderbird: thunderbird-91.3.0-2.el8_4 ->
* thunderbird-91.4.0-2.el8_5
* thunderbird: thunderbird-91.3.0-2.el8.plus ->
* thunderbird-91.4.0-2.el8.plus

### エンジニアリングノート

Thunderbird:これは、サンダーバードの通常のESRビルドアップデートです。 このアップデートは、ベースリポジトリと Plus の両方に対応しています。 Plusリポジトリには、PGP対応の雷鳥バージョンが含まれています。

## 8.5 - 2021-12-03

2021年12月3日以降、以下のパッケージが更新されました。

* abrt: abrt-2.10.9-21.el8 -> abrt-2.10.9-21.el8.rocky.0
* firefox: firefox-91.3.0-1.el8_4 -> firefox-91.4.0-1.el8_5
* sos: sos-4.1-5.el8 -> sos-4.1-5.el8.rocky.2

### エンジニアリングノート

Firefox: これはFirefox用の更新されたESRビルドです。

abrt: これはほとんどが化粧品の変化です。 libreport-rhel* と rhtsupport プラグインへの依存を削除します。 これらのパッケージは、新しい擦り付けパッケージにアップデートした後、安全に削除できます。

これはほとんどが化粧品の変化です それは上流のロッキー政策をダウンさせる。 詳細は [この PR を参照してください](https://github.com/sosreport/sos/pull/2784)

## 8.5 - 2021-12-02

2021年12月02日以降、以下のパッケージが更新されました。

* mailman: mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1 ->
* mailman-3:2.1.29-12.module+el8.5.0+717+27fd1ba7.2

関連付けられた CVE:

* mailman: CVE-2021-44227

followモジュールは2021年12月02日から更新されました。

* mailman-2.1-8050020211202160117.fd901a62


## 8.5 - 補足-2021-11-30

以下のパッケージが devel リポジトリに追加されました:

* ncurses-static

plus リポジトリに次のパッケージが追加されました:

* open-vm-tools（aarch64固有のビルドのみ）

### 追加メモ

プラスリポジトリには、ベース リポジトリに提供されていないアイテムが含まれています。 コンプと pungi の設定 (RHEL リポジトリに基づく) のために利用できないか、ベースにはパッチ/機能がない追加のビルドとして要求されます。 プラスリポジトリは安全に有効にしておく必要があります。

現在のパッケージプラス(2021-11-30)は次のとおりです。

* openldap-servers (すべてのアーキテクチャ)
* sunderbird with PGP support (all architures)
* ncurses-static (すべてのアーキテクチャ)
* open-vm-tools（aarch64固有のビルドのみ）

### Devel Notes

devel リポジトリは注意深く使われるべきです。 これは麹やビルドルートの目的のためのもので、100%有効にしないでください。 あなたが見つけた場合は、あなたがdevel repoで見たいパッケージがあります。 rock-devel にメールを送ったり、バグ報告を https://bugs で開いてください。 ockylinux.org

## 8.5 - 2021-11-29

2021年11月29日以降、以下のパッケージが更新されました。

* kronosnet: kronosnet-1.18-2.el8 -> kronosnet-1.18-4.el8_5
* nss: nss-3.67.0-6.el8_4 -> nss-3.67.0-7.el8_5

関連付けられた CVE:

* nss-3.67.0-7.el8_5: CVE-2021-43527

## 8.5 - 2021-11-24

2021年11月24日以降、以下のパッケージが更新されました。

* dotnet5.0: dotnet5.0-5.0.208-2.el8_5 -> dotnet5.0-5.0.209-1.el8_5
* dotnet5.0-build-reference-packages: dotnet5.0-build-reference-packages-0-11.20210607git5f10a4b.el8 -> dotnet5.0-build-reference-packages-0-12.20211117git6ce5818.el8_5


## 8.5 - 2021-11-22

2021年11月22日以降、以下のパッケージが更新されました(更新されたモジュールパッケージを含む):

* mailman: mailman-3:2.1.29-12.module+el8.5.0+703+19300c10 -> mailman-3:2.1.29-12.module+el8.5.0+716+66d1ab43.1

次のモジュールは2021年11月23日から更新されました。

* mailman-2.1-8050020211123230959.fd901a62

関連付けられた CVE:

* CVE-2021-42096
* CVE-2021-42097

## 8.5 - 2021-11-16

2021年11月16日以降、以下のパッケージが更新されました(更新されたモジュールパッケージを含む):

* clang: clang-12.0.1-2.module+el8.5.0+692+8756646f -> clang-12.0.1-4.module+el8.5.0+715+58f51d49
* llvm-toolset: llvm-toolset-12.0.1-1.module+el8.5.0+692+8756646f -> llvm-toolset-12.0.1-1.module+el8.5.0+715+58f51d49

次のモジュールは2021年11月16日から更新されました。

* llvm-toolset-rhel8-8050020211122023437.b4937e53

## 8.5 - 2021-11-14

2021 年 11 月 8 日リリース以降、以下のパッケージが更新されました (更新されたモジュールパッケージを含む):

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
* gcc-toolset-11-dyninst: gcc-toolset-11-dyninst-11.0.0-1.el8 -> gcc-toolset-11.0.0-2.el8
* gcc-toolset-11-gcc: gcc-toolset-11-gcc-11.1.1-3.el8 -> gcc-toolset-11.2.1-1.2.el8_5
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

以下のパッケージが削除され、dnfグループからも削除されました。

* insights-client: insights-client-3.1.5-1.el8 (Standard Group)

削除されたパッケージの場合、 `dnf remove` を使用して削除しても安全です。

以下のモジュールは2021年11月14日の8.5リリースから更新されました。

* rust-toolset-rhel8-80500202112021616.f73640c0
* httpd-2.4-805002021115030420.b4937e53

### 既知の問題

[バグ 174](https://bugs.rockylinux.org/show_bug.cgi?id=174) - ESXi などの vmware システムでは、 `kdump` が動作しない問題を認識しています。

また、ミラーシステムがアップデートを行うために間違ったディレクトリを報告していることも認識しています。 `os` ではなく、 `kickstart` にしようとしていました。 これは解決されるべきであり、更新は正常に動作するはずです。

## 8.4 - 2021-09-21

次のパッケージが更新されました:

* kernel: kernel-4.18.0-305.19.1 (9-15)
* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.2
* golang: 1.15.14-2
* nss: 3.67.0-6
* ca証明書: 2021.2.50-80.0
* opencryptoki: 3.15.1-7
* krb5: 1.18.2-8.3
* platform-python: 3.6.8-38
* libdb: 5.3.28-42
* rng-tools: 6.8-4
* sos: 4.0-12
* python-ldap: 3.3.1-1.1
* subscription-manager: 1.28.13-4
* pcp: 5.2.5-6
* ストリング: 5.7-2.1
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

次のパッケージが更新されました:

* サンダーバード：78.14.0に更新
* firefox:78.14.0に更新
* cyrus-imapd: 3.0.7-20.el8_4.1 (アドレス CVE-2021-33582) に更新
* systemtapはdynst 10.2に対して再構築されたバグレポートに対処します
* rocky-release -> "centos" を ID として許可するように更新されました

次のリポジトリが更新されました:

* 追加機能 -> CentOS sig リリースパッケージが追加されました

## 8.4 - 2021-08-24

次のパッケージが更新されました:

* dotnet: dotnet-2.1.525.el8_4 -> dotnet-2.1.526.el8_4
* libsndfile: libsndfile-1.0.28-10.el8_4 -> libsndfile-1.0.28-10.el8_4.1 -- アドレス

  * wavファイルから任意のコードを実行できるヒープバッファオーバーフローに対応します。

* scap-security-guide: scap-security-guide-0.1.54-5.el8.rocky.1

  * アドレス RLBZ#108

次のリポジトリ/パッケージが追加されました:

* RT (リアルタイム) - `dnf config-manager --set-enabled rt`

  * kernel-rt (リアルタイムカーネル)

## 8.4 - 2021-08-11

次のパッケージが更新されました:

* 389-ds-base: 389-ds-base-1.4.3.16-16.module+el8.4.0+596+159889e5 -> 389-ds-base-1.4.3.16-19.module+el8.4.0+636+837ee950
* NetworkManager: NetworkManager-1:1.30.0-9.el8_4 -> NetworkManager-1:1.30.0-10.el8_4
* autofs: autofs-1:5.1.4-48.el8 -> autofs-1:5.1.4-48.el8_4.1
* buildah: buildah-1.19.7-2.module+el8.4.0+556+40122d08 -> buildah-1.21.4-1.module+el8.4.0+643+525e162a
* cloud-init: cloud-init-20.3-10.el8_4.3 -> cloud-init-20.3-10.el8_4.5
* cockpit-podman: cockpit-podman-29-2.module+el8.4.0+556+40122d08 -> cockpit-podman-32-2.module+el8.4.0+643+525e162a
* conmon: conmon-2:2.0.26-3.module+el8.4.0+556+40122d08 -> conmon-2:2.0.29-1.module+el8.4.0+643+525e162a
* container-selinux: container-selinux-2:2.162.0-1.module+el8.4.0+556+40122d08 -> container-selinux-2:2.164.1-1.module+el8.0+643+525e162a
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
* virt-who-1.30.5-1.el8 -> virt-who-1.30.5-2.el8_4
* virtio-win: virtio-win-1.9.16-2.el8 -> virtio-win-1.9.17-4.el8_4
* vulkan-headers: vulkan-headers-1.2.162.0-1.el8 -> vulkan-headers-1.2.182.0-1.el8_4
* vulkan-loader: vulkan-loader-1.2.162.0-1.el8 -> vulkan-loader-1.2.182.0-1.el8_4
* vulkan-tools: vulkan-tools-1.2.162.0-1.el8 -> vulkan-tools-1.2.182.0-1.el8_4
* vulkan-validation-layers: vulkan-validation-layers-1.2.162.0-1.el8 -> vulkan-validation-layers-1.2.182.0-1.el8_4

## 8.4 - 2021-08-02

次のパッケージが更新されました:

* varnish -> varnish-0:6.0.6-2.module+el8.4.0+628+e1687553.1 -> アドレス CVE-2021-36740

次のリポジトリに kickstart リポジトリを追加しました:

* BaseOS
* AppStream
* PowerTools
* 高可用性あり
* 弾力性のあるストレージ

## 8.4 - 2021-07-27

次のパッケージが更新されました:

* thunderbird -> thunderbird-78.12.0-3.el8_4

## 8.4 - 2021-07-21

次のパッケージが更新されました:

* kanner -> kernel-4.18.0-305.10.2.el8_4 -> Addresses CVE-2021-33909
* systemd -> systemd-239-45.el8_4.2 -> Addresses CVE-2021-33910
* firefox
* java-1.8.0-openjdk
* java-11-openjdk

## 8.4 - 2021-07-12

次のパッケージが更新されました:

* rocky-release
* linuxptp
* rpaste
* ovn2.13 (NFV)

以下のモジュールが更新されました：

* python36

### 追加の変更

実験的なリポジトリメタデータ署名が実装されました。 これを試してみたい場合は、Rocky-X.repoファイルで次のオプションを設定してください。

```
repo_gpgcheck=1
```

### 近日登場...

* ストレージアドオンリポジトリ:

  * Glusterfs 9のサポート

## 8.4 - 2021-06-30

### パッケージの更新

次のパッケージが更新されました:

* NetworkManager -> NetworkManager-11.30.0-9.el8_4
* cloud-init -> cloud-init-20.3-10.el8_4.3
* cmake -> cmake-3.18.2-11.el8_4
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

以下のモジュールが更新されました：

* PyYAML -> PyYAML-5.4.1-1.module+el8.4.0+595+c96abaa2
* 389-ds -> 1.4.3.16-16
* go-toolset -> go-toolset-1.15.13-1.module+el8.4.0+591+0da41cc3
* golang -> golang-1.15.13-3.module+el8.4.0+591+0da41cc3
* idm:DL1 -> ipa-4.9.2-4
* idm:client -> (DL1モジュールと同期するためにipaplatform=rhelで再構築)
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


### コンテキスト

いくつかのモジュールとパッケージは、上流によって定期的に更新されています。

通常の岩石パッケージは以下の対応のために更新されました:

* rocky-release

  * devel と debuginfo リポジトリを将来の状態に追加します。
  * これはmock/buildroot 目的のために提供されています

* rocky-logos

  * 今後の公式ライブ画像のためのアイコンを改善する


### 追加の変更

aarch64 用の extras リポジトリが更新され、上流に含まれていない様々なパッケージが含まれるようになりました。 これの例はlibreofficeや他のノームアプリです。 これらのリポジトリは BaseOS または AppStream に含まれていないため、これらのパッケージに適した場所となります。

* mock/buildroot 目的のために「devel」リポジトリが提供されました。
* aarch64 用の追加リポジトリは、デスクトップで使用するためのアップストリームで提供されていない不足しているパッケージを含むように更新されました
* rpasteは標準入力を受け付けるように更新されました
* 古いパッケージは、ポイントリリースの期間中にリポジトリに提供されます。

  * これにより、上流からの回帰やトラブルシューティングの場合にパッケージをダウングレードすることができます。
