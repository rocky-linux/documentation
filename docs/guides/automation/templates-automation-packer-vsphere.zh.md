---
title: 自动模板创建 - Packer - Ansible - VMWare vSphere
contributors: tianci li
update: 2021-10-26
---

# 在VMWare vSphere环境中使用打包程序自动创建模板，并使用Ansible进行部署

**知识**: :star: :star: :star:   
**复杂度**: :star: :star: :star:   

**阅读时间**: 30 分钟

## 前提条件、假设和一般说明

* 可用的vSphere环境，以及具有授权访问权限的用户。
* 用于存储文件的内部Web服务器。
* 通过web能访问Rcoky的存储库（repositories）
* 一个可用于Ansible的环境
* 假设您对提到的每种产品都有一定的了解。如果没有，请在开始之前仔细阅读该文档。
* 这里**不用**Vagrant。有人指出，对于Vagant，将提供一个非自签名的SSH密钥。如果您想深入了解这一点，您可以这样做，但是本文档中没有涉及到这一点。

## 引言

本文档介绍了如何使用Packer创建VMWare模板，以及如何使用Ansible将工件部署为新的虚拟机。

## 可能需要的调整

当然，您可以将这个“如何操作”应用于其他虚拟机管理程序。

您也可以选择不将虚拟机转换为模板，在这种情况下，您将使用Packer来部署每个新的VM，这仍然是非常可行的(从0开始安装只需不到10分钟，无需人工交互)。

## Packer

Packer是一个自动创建虚拟机的Hashicorp工具。

您可以查看这些资源以了解更多信息：

* [Packer网站](https://www.packer.io/)。
* [Packer文档](https://www.packer.io/docs)。
* builder `vsphere-iso`的[文档](https://www.packer.io/docs/builders/vsphere/vsphere-iso)。
  
您可以通过[Packer downloads](https://www.packer.io/downloads)为您自己的平台下载二进制文件。

您还需要一份Rocky Linux的iso副本。虽然我在这里使用的是最小的ISO镜像，但是您可以选择使用DVD镜像或boot引导镜像。这个选择由你决定。它特别影响到你在安装时需要的带宽，从而影响到配置时间。接下来我们将讨论默认选择的影响以及如何补救。

假设您在Linux上执行以下任务。

由于我们将连接到VMware vCenter服务器，通过Packer发送我们的命令，我们需要将我们的证书存储在我们接下来要创建的配置文件之外。

让我们在主目录中创建一个带有凭据的隐藏文件。这是一个json文件:

```bash
$ vim .vsphere-secrets.json 
  {
    "vcenter_username": "rockstar",
    "vcenter_password": "mysecurepassword"
  }
```

这些凭据需要对您的vSphere环境授予访问权限。

让我们创建一个json文件(将来，该文件的格式将更改为HCL)：

```json
{
  "variables": {
    "version": "0.0.X",
    "HTTP_IP": "fileserver.rockylinux.lan",
    "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
  },
  "sensitive-variables": ["vcenter_password"],
  "provisioners": [
    {
      "type": "shell",
      "expect_disconnect": true,
      "execute_command": "bash '{{.Path}}'",
      "script": "{{template_dir}}/scripts/requirements.sh"
    }
  ],
  "builders": [
    {
      "type": "vsphere-iso",
      "CPUs": 2,
      "CPU_hot_plug": true,
      "RAM": 2048,
      "RAM_hot_plug": true,
      "disk_controller_type": "pvscsi",
      "guest_os_type": "centos8_64Guest",
      "iso_paths": [
        "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
      ],
      "network_adapters": [
        {
          "network_card": "vmxnet3",
          "network": "net_infra"
        }
      ],
      "storage": [
        {
          "disk_size": 40000,
          "disk_thin_provisioned": true
        }
      ],
      "boot_command": [
      "<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
      ],
      "ssh_password": "mysecurepassword",
      "ssh_username": "root",
      "shutdown_command": "/sbin/halt -h -p",
      "insecure_connection": "true",
      "username": "{{ user `vcenter_username` }}",
      "password": "{{ user `vcenter_password` }}",
      "vcenter_server": "vsphere.rockylinux.lan",
      "datacenter": "DC_NAME",
      "datastore": "DS_NAME",
      "vm_name": "template-rockylinux8-{{ user `version` }}",
      "folder": "Templates/RockyLinux",
      "cluster": "CLUSTER_NAME",
      "host": "esx1.rockylinux.lan",
      "notes": "Template RockyLinux version {{ user `version` }}",
      "convert_to_template": true,
      "create_snapshot": false
    }
  ]
}
```
接下来，我们将描述这个文件的每个部分。

### variables部分

在第一步中，我们声明变量，主要是为了可读性：

```json
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```

稍后我们将在将要创建的模板名称中使用变量`version`，您可以轻松地增加此值以满足您的需要。

我们还需要引导虚拟机来访问ks.cfg（Kickstart）文件。

Kickstart文件包含安装过程中提出的问题的答案（即应答文件）。此文件将其所有内容传递给Anaconda（的安装过程），这允许您完全自动创建模板。

作者喜欢将他的ks.cfg文件保存在一个可以从他的模板访问的内部web服务器上，但也有其他的可能性，你可以选择使用。

例如，在我们的实验环境下，ks.cfg文件可以从虚拟机上的这个url访问：http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg 。 您需要进行适当的设置才能达到这种效果。

由于我们希望将密码保持为私有，因此将其声明为敏感变量。示例：

```
  "sensitive-variables": ["vcenter_password"],
```

### Provisioners部分

接下来的部分很有意思，后面将为你提供`requirements.sh`的脚本。

```
"provisioners": [
  {
    "type": "shell",
    "expect_disconnect": true,
    "execute_command": "bash '{{.Path}}'",
    "script": "{{template_dir}}/scripts/requirements.sh"
  }
],
```

安装完成后，VM将重新启动。一旦Packer检测到一个IP地址(多亏了VMWare Tools)，它就会复制' requirements.sh '并执行它。在安装过程之后会清理VM（删除SSH密钥、清理历史记录等）并安装一些额外的包，这是一个不错的功能特性。

### builders部分

您可以以VSphere环境以外的对象为目标（可能是一个Vagrant模板）声明一个或多个 builders。

但这里我们使用的是`vsphere iso` builder：

```
"builders": [
  {
    "type": "vsphere-iso",
```

这个builder需要我们配置需要的硬件:

```
  "CPUs": 2,
  "CPU_hot_plug": true,
  "RAM": 2048,
  "RAM_hot_plug": true,
  "disk_controller_type": "pvscsi",
  "guest_os_type": "centos8_64Guest",
  "network_adapters": [
    {
      "network_card": "vmxnet3",
      "network": "net_infra"
    }
  ],
  "storage": [
    {
      "disk_size": 40000,
      "disk_thin_provisioned": true
    }
  ],
```

!!! note "注意"
    你再也不会忘记加载CPU_hot_plug了，因为现在它是自动的。

您可以使用磁盘、CPU等做更酷的事情。如果您有兴趣进行其他调整，请参阅文档。

要开始安装，您需要一个Rocky Linux的ISO镜像。下面是如何使用VMWare内容库中的镜像的示例。当然，您当然可以把ISO存储在其他地方，但如果是VMWare内容库（VMWare Content Library），您必须在托管内容库的服务器上获得ISO文件的完整路径（本例中是Synology，所以直接在DSM资源管理器上）。

```
  "iso_paths": [
    "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
  ],
```

然后，您必须提供要在安装过程中输入的完整命令：配置IP和传输Kickstart应答文件的路径。

!!! note "注意"
    本例采用最复杂的情况：使用固定的静态IP。如果您有一个可用的DHCP服务器，那么这个过程会容易很多。

这是该过程中最有趣的部分：我相信您会在生成过程中欣赏VMWare控制台，只是为了看到引导时自动输入的命令。

```
"boot_command": [
"<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
],
```

第一次重新启动后，Packer将通过SSH连接到您的服务器。您可以使用root用户或具有sudo权限的其他用户，但在任何情况下，此用户都必须与ks.cfg文件中定义的用户相对应。

```
"ssh_password": "mysecurepassword",
"ssh_username": "root",
```

在这一过程结束时，必须停止虚拟机。对于非root用户来说，这有点复杂，但它有很好的文档记录:

```
"shutdown_command": "/sbin/halt -h -p",
```

接下来，我们处理一下VSphere的配置。这里唯一值得注意的是使用了主目录中文档开头定义的变量，以及`insecure_connection`选项，因为我们的vSphere使用自签名证书(请参见本文档顶部假设中的注释)：

```
"insecure_connection": "true",
"username": "{{ user `vcenter_username` }}",
"password": "{{ user `vcenter_password` }}",
"vcenter_server": "vsphere.rockylinux.lan",
"datacenter": "DC_NAME",
"datastore": "DS_NAME",
"vm_name": "template-rockylinux8-{{ user `version` }}",
"folder": "Templates/RockyLinux",
"cluster": "CLUSTER_NAME",
"host": "esx1.rockylinux.lan",
"notes": "Template RockyLinux version {{ user `version` }}"
```

最后，我们将要求vSphere将停止的VM转换为模板。

在这个阶段，您还可以选择直接使用VM(而不是将其转换为模板)。在这种情况下，你可以选择拍摄一份快照:

```
"convert_to_template": true,
"create_snapshot": false,
```

## ks.cfg文件

如上所述，我们需要提供一个将被Anaconda使用的Kicstart应答文件。

下面是这个文件的一个例子：

```
# Use CDROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
# Use text install
text
# Don't run the Setup Agent on first boot
firstboot --disabled
eula --agreed
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate

# Root password
rootpw mysecurepassword

# System services
selinux --permissive
firewall --enabled
services --enabled="NetworkManager,sshd,chronyd"
# System timezone
timezone Europe/Paris --isUtc
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root

skipx

reboot

%packages --ignoremissing --excludedocs
openssh-clients
curl
dnf-utils
drpm
net-tools
open-vm-tools
perl
perl-File-Temp
sudo
vim
wget
python3

# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
-cockpit
-quota
-alsa-*
-fprintd-pam
-intltool
-microcode_ctl
%end

%addon com_redhat_kdump --disable
%end

%post

# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

systemctl enable vmtoolsd
systemctl start vmtoolsd

%end
```

由于我们选择使用最小的iso，而不是Boot或DVD，因此并不是所有必需的安装包都可用。

由于Packer依赖VMWare tools来检测安装的结束，并且“open-vm-tools”软件包只在AppStream repo中提供，所以我们必须指定安装过程中我们想要使用的cdrom和这个远程repo作为源:

!!! note "注意"
    如果您无法访问外部repo，您可以使用repo的镜像、squid代理或者DVD。

```
# Use CDROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

让我们跳到网络配置，同样，在本例中我们没有使用DHCP服务器：

```
# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

记住，我们在安装结束时指定了要通过SSH连接到Packer的用户，此用户和密码必须匹配:

```
# Root password
rootpw mysecurepassword
```

!!! Warning "警告"
    你可以在这里使用一个不安全的密码，只要你确保这个密码在你的VM部署后会被立即更改，例如使用用Ansible。

以下是选定的分区方案，当然也可以做更复杂的事情。

```
# System booloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitionning information
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root
```

下一节讨论将要安装的包。一种“最佳实践”是将安装的软件包数量限制在您需要的范围内，这就限制了被攻击的面（attack surface），特别是在服务器环境中。

!!! note "笔记"
    作者喜欢限制安装过程中要执行的一些操作，并推迟安装Packer安装后脚本中需要的内容。因此，在这种情况下，我们只安装最小所需的软件包。

Packer似乎需要`openssh clients`包才能将其脚本复制到VM中。

Packer也需要`open-vm-tools`来检测安装的结束，这解释了为什么添加AppStream存储库。在部署阶段，VMWare Tools还需要`perl`和`perl-File-Temp`，这是一个遗憾，因为它需要很多其他依赖包。Ansible将来也需要`python3`（3.6）才能工作（如果您不使用Ansible或python，请删除它们！）。

```
%packages --ignoremissing --excludedocs
openssh-clients
open-vm-tools
python3
perl
perl-File-Temp
curl
dnf-utils
drpm
net-tools
sudo
vim
wget
```

您不仅可以添加软件包，还可以删除它们。由于我们控制了硬件工作的环境，因此我们可以删除对我们毫无用处的任何固件：

```
# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
...
```

下一部分将添加一些用户。在我们的例子中，创建一个`ansible`用户是很有趣的，没有密码，但有一个公钥，这使得所有的新VM都可以从我们的Ansible server上访问，运行安装后的操作:

```
# Manage Ansible access
groupadd -g 1001 ansible
useradd -m -g 1001 -u 1001 ansible
mkdir /home/ansible/.ssh
echo -e "<---- PAST YOUR PUBKEY HERE ---->" >  /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
```

现在我们需要启用并启动`vmtoolsd`（管理open-vm-tools的进程）。VSphere将在VM重启后检测IP地址。

```
systemctl enable vmtoolsd
systemctl start vmtoolsd
```

安装过程完成，虚拟机将重新启动。

## provisioners

请记住，我们在Packer中声明了一个provisioner，在我们的示例中，它对应于一个`.sh`脚本，存储在json文件旁边的子目录中。

有不同类型的provisioner，我们也可以使用Ansible，您可以自由探索这些可能性。

该文件可以完全更改，但它提供了一个脚本执行操作的示例，在本例中为`requirements.sh`：

```
#!/bin/sh -eux

echo "Updating the system..."
dnf -y update

echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True " > /etc/cloud/cloud.cfg.d/99-manual.cfg

echo "Disable NetworkManager-wait-online.service"
systemctl disable NetworkManager-wait-online.service

# cleanup current SSH keys so templated VMs get fresh key
rm -f /etc/ssh/ssh_host_*

# Avoid ~200 meg firmware package we don't need
# this cannot be done in the KS file so we do it here
echo "Removing extra firmware packages"
dnf -y remove linux-firmware
dnf -y autoremove

echo "Remove previous kernels that preserved for rollbacks"
dnf -y remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)
dnf -y clean all  --enablerepo=\*;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "remove the install log"
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "Force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "Wipe netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "Clear the history so our install commands aren't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
```

有必要做一些解释：

```
echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

由于vSphere现在通过VMware tools使用cloud-init来配置centos8来宾计算机的网络，因此必须安装它。但是，如果您什么都不做，配置将在第一次重新启动时应用，一切都将变的正常。但在下次重新启动时，cloud-init将不会收到来自vSphere的任何新信息。如果在不知道该怎么做的情况下，cloud-init 将重新配置VM的网络接口以使用 DHCP，而您将丢失静态配置。

由于这不是我们想要的行为，我们需要指定cloud-init不要自动删除其缓存，因此要重新使用它在第一次重启和之后每次重启时收到的配置信息。

为此，我们使用`manual_cache_clean: True`指令创建了一个`/etc/cloud/cloud.cfg.d/99-manual.cfg`文件。

!!! note "注意"
    这意味着，如果您需要通过VSphere的定制工具重新应用网络配置(正常情况下，这种情况相当少见)，您将不得不自己删除cloud-init缓存。

脚本的其余部分已注释，不需要更多详细信息

您可以查看[Bento project](https://github.com/chef/bento/tree/master/packer_templates)，以获得更多关于在自动化过程中的这一部分可以做什么的想法。

## 创建模板

现在是启动Packer并检查创建过程是否工作正常的时候了，该过程是完全自动的。

只需在命令行中输入以下内容：

```
./packer build -var-file=~/.vsphere-secrets.json rockylinux8/template.json
```

你可以快速进入VSphere，欣赏一下这项工作。

您将看到计算机正在创建、启动，如果启动控制台，您将看到命令的自动输入和安装过程。

在创建结束时，您会发现您的模板已准备好在vSphere中使用。

## 部署部分

如果没有模板的自动部署部分，本文档就不完整。

为此，我们将使用一个简单的Ansible手册，它使用`vmware_guest`模块。

我们提供给您的这本手册必须适应您的需求和您的做事方式。

```
---
- name: Deploy VM from template
  hosts: localhost
  gather_facts: no
  vars_files:
    - ./vars/credentials.yml

  tasks:

  - name: Clone the template
    vmware_guest:
      hostname: "{{ vmware_vcenter_hostname }}"
      username: "{{ vmware_username }}"
      password: "{{ vmware_password }}"
      validate_certs: False
      name: "{{ vm_name }}"
      template: "{{ template_name }}"
      datacenter: "{{ datacenter_name }}"
      folder: "{{ storage_folder }}"
      state: "{{ state }}"
      cluster: "{{ cluster_name | default(omit,true) }}"
      esxi_hostname: "{{ esxi_hostname | default(omit,true) }}"
      wait_for_ip_address: no
      annotation: "{{ comments | default('Deployed by Ansible') }}"
      datastore: "{{ datastore_name | default(omit,true) }}"
      networks:
      - name: "{{ network_name }}"
        ip: "{{ network_ip }}"
        netmask: "{{ network_mask }}"
        gateway: "{{ network_gateway }}"
        device_type: "vmxnet3"
        type: static
      hardware:
        memory_mb: "{{ memory_mb|int * 1024 }}"
        num_cpu: "{{ num_cpu }}"
        hotadd_cpu: True
        hotadd_memory: True
      customization:
        domain: "{{ domain }}"
        dns_servers: "{{ dns_servers.split(',') }}"
      guest_id: "{{ guest_id }}"
    register: deploy_vm
```

您可以将敏感数据存储在`./vars/redentials.yml`中，显然您事先已经使用`ansible-vault`对其进行了加密(特别是在您使用git进行工作的情况下)。由于所有内容都使用变量，因此您可以轻松地使其满足您的需求。

如果您不使用Rundeck或AWX之类的工具，你可以使用类似于下面的命令行启动部署:

```
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

在这一点上，你可以使用Ansible启动虚拟机的最终配置。不要忘记修改root密码，确保SSH安全，在监控工具和IT清单（IT inventory）中注册新的VM等等。

## 总结

正如我们已经看到的，现在有全自动的DevOps解决方案来创建和部署VM。

同时，这无疑节省了时间，特别是在云或数据中心环境中。它还有利于公司所有计算机（服务器和工作站）的标准合规性，以及模板的轻松维护/进步。