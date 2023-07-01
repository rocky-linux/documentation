---
title: Automatic Template Creation - Packer - Ansible - VMware vSphere
author: Antoine Le Morvan
contributors: Steven Spencer, Ryan Johnson, Pedro Garcia
---

# Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment

**Knowledge**: :star: :star: :star:   
**Complexity**: :star: :star: :star:   

**Reading time**: 30 minutes

## Prerequisites, Assumptions, and General Notes

* A vSphere environment available, and a user with granted access.
* An internal web server to store files.
* Web access to the Rocky Linux repositories.
* An ISO of Rocky Linux.
* An Ansible environment available.
* It is assumed that you have some knowledge on each product mentioned. If not, dig into that documentation before you begin.
* Vagrant is **not** in use here. It was pointed out that with Vagrant, an SSH key that was not self-signed would be provided. If you want to dig into that you can do so, but it is not covered in this document.

## Introduction

This document covers the vSphere virtual machine template creation with Packer and how to deploy the artifact as new virtual machines with Ansible.

## Possible adjustments

Of course, you can adapt this how-to for other hypervisors.

Although we are using the minimal ISO image here, you could choose to use the DVD image (much bigger and perhaps too big) or the boot image (much smaller and perhaps too small). This choice is up to you. It impacts in particular the bandwidth you will need for the installation, and thus the provisioning time. We will discuss next the impact of the default choice and how to remedy it.

You can also choose not to convert the virtual machine into a template, in this case you will use Packer to deploy each new VM, which is still quite feasible (an installation starting from 0 takes less than 10 minutes without human interaction).

## Packer

### Introduction to Packer

Packer is an open-source virtual machine imaging tool, released under the MPL 2.0 license, and created by HashiCorp. It will help you automate the process of creating virtual machine images with pre-configured operating systems and installed software from a single source configuration in both, cloud and on-prem virtualized environments. 

With Packer you can create images to be used on the following platforms:

* [Amazon Web Services](https://aws.amazon.com). 
* [Azure](https://azure.microsoft.com).
* [GCP](https://cloud.google.com).
* [DigitalOcean](https://www.digitalocean.com). 
* [OpenStack](https://www.openstack.org).
* [VirtualBox](https://www.virtualbox.org/).
* [VMware](https://www.vmware.com).

You can have a look at these resources for additional information:

* The [Packer website](https://www.packer.io/)
* [Packer documentation](https://www.packer.io/docs)
* The builder `vsphere-iso`'s [documentation](https://www.packer.io/docs/builders/vsphere/vsphere-iso)

### Installing Packer

There are two ways to install Packer on your Rocky Linux system.

#### Installing Packer from the HashiCorp repo

HashiCorp maintains and signs packages for different Linux distributions. To install packer in our Rocky Linux system, please follow the next steps:


#### Download and install from the Packer website

1. Install dnf-config-manager:

```bash
$ sudo dnf install -y dnf-plugins-core
```

2. Add the HashiCorp repository to the available repos in our Rocky Linux system:

```bash
$ sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```

3. Install Packer:

```bash
$ sudo dnf -y install packer
```

#### Download and install from the Packer website


You can start by downloading the binaries for you own platform with [Packer downloads](https://www.packer.io/downloads).

1. In the download page, copy the download link in the Linux Binary Download section that corresponds to your system architecture.

2. From a shell or terminal download it using ```wget``` tool:

```bash
$ wget https://releases.hashicorp.com/packer/1.8.3/packer_1.8.3_linux_amd64.zip
```
This will download a .zip file.

3.  To decompress the downloaded archive, run the following command in the shell:

```bash
$ unzip packer_1.8.3_linux_amd64.zip
```

!!! tip "Attention"

    If you get an error and you don’t have the unzip app installed on your system, you can install it by executing this command ```sudo dnf install unzip```

4. Move the Packer app to the bin folder:

```bash
$ sudo mv packer /usr/local/bin/
```

####  Verification of the correct installation of Packer

If all the steps of the previous procedures have been completed correctly, we can proceed to verify the installation of Packer on our system.

To verify that Packer has been installed correctly, run the `packer` command and you will get the result shown below:

```bash
$ packer 
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            install missing plugins or upgrade plugins
    inspect         see components of a template
    plugins         interact with Packer plugins and catalog
    validate        check that a template is valid
    version         prints the Packer version
```

### Template creation with Packer

It is assumed that you are on Linux to perform the following tasks.

As we will connect to a VMware vCenter Server to send our commands via Packer, we need to store our credentials outside the configuration files which we will create next.

Let us create a hidden file with our credentials in our home directory. This is a json file:

```
$ vim .vsphere-secrets.json {
    "vcenter_username": "rockstar",
    "vcenter_password": "mysecurepassword"
  }
```

Those credentials need some grant access to your vSphere environment.

Let us create a json file (in the future, the format of this file will change to the HCL):

```
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
Next, we will describe each section of this file.

### Variables section

In a first step, we declare variables, mainly for the sake of readability:

```
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```

We will use the variable `version` later in the template name we will create. You can easily increment this value to suit your needs.

We will also need our booting virtual machine to access a `ks.cfg` (Kickstart) file.

A Kickstart file contains the answers to the questions asked during the installation process. This file passes all its contents to Anaconda (the installation process), which allows you to fully automate the creation of the template.

The author likes to store his `ks.cfg` file in an internal web server accessible from his template, but other possibilities exists that you may choose to use instead.

For example, the `ks.cfg` file is accessible from the VM at this URL in our lab: http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg. You would need to set up something similar to use this method.

Since we want to keep our password private, it is declared as a sensitive variable. Example:

```
  "sensitive-variables": ["vcenter_password"],
```

### Provisioners section

Next part is interesting, and will be covered later by providing you the script for `requirements.sh`:

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

After the installation is finished, the VM will reboot. As soon as Packer detects an IP address (thanks to the VMware Tools), it will copy the `requirements.sh` and execute it. It is a nice feature to clean the VM after the installation process (remove SSH keys, clean the history, etc.) and install some extra package.

### The builders section

You can declare one or more builders to target something other than your vSphere environment (perhaps a Vagrant template).

But here we are using the `vsphere-iso` builder:


```
"builders": [
  {
    "type": "vsphere-iso",
```

This builder lets us configure the hardware we need:

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

!!! note "Note"

    You will never forget again to include CPU_hot_plug as it is automatic now!

You can do more cool things with the disk, cpu, etc. You should refer to the documentation if you are interested in making other adjustments.

To start the installation, you need an ISO image of Rocky Linux. Here is an example of how to use an image located in a vSphere content library. You can of course store the ISO elsewhere, but in the case of a vSphere content library, you have to get the full path to the ISO file on the server hosting the Content Library (in this case it is a Synology, so directly on the DSM explorer).

```
  "iso_paths": [
    "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
  ],
```

Then you have to provide the complete command to be entered during the installation process: configuration of the IP and transmission of the path to the Kickstart response file.

!!! note "Note"

    This example takes the most complex case: using a static IP. If you have a DHCP server available, the process will be much easier.

This is the most amusing part of the procedure: I'm sure you will go and admire the VMware console during the generation, just to see the automatic entry of the commands during the boot.

```
"boot_command": [
"<up><tab> text ip=192.168.1.11::192.168.1.254:255.255.255.0:template:ens192:none nameserver=192.168.1.254 inst.ks=http://{{ user `HTTP_IP` }}/{{ user `HTTP_PATH` }}<enter><wait><enter>"
],
```

After the first reboot, Packer will connect to your server by SSH. You can use the root user, or another user with sudo rights, but in any case, this user must correspond to the user that is defined in your ks.cfg file.

```
"ssh_password": "mysecurepassword",
"ssh_username": "root",
```

At the end of the process, the VM must be stopped. It is a little bit more complicated with a non-root user, but it is well documented:

```
"shutdown_command": "/sbin/halt -h -p",
```

Next, we deal with the vSphere configuration. The only notable things here are the use of the variables defined at the beginning of the document in our home directory, as well as the `insecure_connection` option, because our vSphere uses a self-signed certificate (see note in Assumptions at the top of this document):

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

And finally, we will ask vSphere to convert our stopped VM to a template.

At this stage, you could also elect to just use the VM as is (not converting it to a template). In this case, you can decide to take a snapshot instead:

```
"convert_to_template": true,
"create_snapshot": false,
```

## The ks.cfg file

As noted above, we need to provide a kickstart response file that will be used by Anaconda.

Here's an example of that file:

```
# Use CD-ROM installation media
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

As we have chosen to use the minimal iso, instead of the Boot or DVD, not all required installation packages will be available.

As Packer relies on VMware Tools to detect the end of the installation, and the `open-vm-tools` package is only available in the AppStream repos, we have to specify to the installation process that we want to use as source both the CD-ROM and this remote repo:

!!! note "Note"

    If you do not have access to the external repos, you can use either a mirror of the repo, a squid proxy, or the DVD.

```
# Use CD-ROM installation media
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

Let us jump to the network configuration, as once again, in this example we are not using a DHCP server:

```
# Network information
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

Remember we specified the user to connect via SSH with to Packer at the end of the installation. This user and password must match:

```
# Root password
rootpw mysecurepassword
```

!!! warning "Warning"

    You can use an insecure password here, as long as you make sure that this password will be changed immediately after the deployment of your VM, for example with Ansible.

Here is the selected partition scheme. Much more complex things can be done. You can define a partition scheme that suits your needs, adapting it to the disk space defined in Packer, and which respects the security rules defined for your environment (dedicated partition for `/tmp`, etc.):

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

The next section concerns the packages that will be installed. A "best practice" is to limit the quantity of installed packages to only those you need, which limits the attack surface, especially in a server environment.

!!! note "Note"

    The author likes to limit the actions to be done in the installation process and to defer installing what is needed in the post installation script of Packer. So, in this case, we install only the minimum required packages.

The `openssh-clients` package seems to be required for Packer to copy its scripts into the VM.

The `open-vm-tools` is also needed by Packer to detect the end of the installation, this explains the addition of the AppStream repository. The packages `perl` and `perl-File-Temp` will also be required by VMware Tools during the deployment part. This is a shame because it requires a lot of other dependent packages. `python3` (3.6) will also be required in the future for Ansible to work (if you won't use Ansible or python, remove them!).

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

You can not only add packages but also remove them. Since we control the environment in which our hardware will work, we can remove any of the firmware that will be useless to us:

```
# unnecessary firmware
-aic94xx-firmware
-atmel-firmware
...
```

The next part adds some users. It is interesting in our case to create an `ansible` user, without password but with a public key. This allows all of our new VMs to be accessible from our Ansible server to run the post-install actions:

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

Now we need to enable and start `vmtoolsd` (the process that manages open-vm-tools). vSphere will detect the IP address after the reboot of the VM.

```
systemctl enable vmtoolsd
systemctl start vmtoolsd
```

The installation process is finished and the VM will reboot.

## The provisioners

Remember, we declared in Packer a provisioner, which in our case corresponds to a `.sh` script, to be stored in a subdirectory next to our json file.

There are different types of provisioners, we could also have used Ansible. You are free to explore these possibilities.

This file can be completely changed, but this provides an example of what can be done with a script, in this case `requirements.sh`:

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

Some explanations are necessary:

```
echo "Installing cloud-init..."
dnf -y install cloud-init

# see https://bugs.launchpad.net/cloud-init/+bug/1712680
# and https://kb.vmware.com/s/article/71264
# Virtual Machine customized with cloud-init is set to DHCP after reboot
echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

Since vSphere now uses cloud-init via the VMware Tools to configure the network of a centos8 guest machine, it must be installed. However, if you do nothing, the configuration will be applied on the first reboot, and everything will be fine. But on the next reboot, cloud-init will not receive any new information from vSphere. In these cases, without information about what to do, cloud-init will reconfigure the VM's network interface to use DHCP, and you will lose your static configuration.

As this is not the behavior we want, we need to specify to cloud-init not to delete its cache automatically, and therefore to reuse the configuration information it received during its first reboot and each reboot after that.

For this, we create a file `/etc/cloud/cloud.cfg.d/99-manual.cfg` with the `manual_cache_clean: True` directive.

!!! note "Note"

    This implies that if you need to re-apply a network configuration via vSphere guest customizations (which, in normal use, should be quite rare), you will have to delete the cloud-init cache yourself.

The rest of the script is commented and does not require more details.

You can check the [Bento project](https://github.com/chef/bento/tree/master/packer_templates) to get more ideas of what can be done in this part of the automation process.

## Template creation

Now it is time to launch Packer and check that the creation process, which is completely automatic, works well.

Simply enter this at the command line:

```
./packer build -var-file=~/.vsphere-secrets.json rockylinux8/template.json
```

You can quickly go to vSphere and admire the work.

You will see the machine being created, started, and if you launch a console, you will see the automatic entry of commands and the installation process.

At the end of the creation, you will find your template ready to use in vSphere.

## Deployment part

This documentation would not be complete without the automatic deployment part of the template.

For this, we will use a simple Ansible playbook, which uses the `vmware_guest` module.

This playbook that we provide you, must be adapted to your needs and your way of doing things.

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

You can store sensitive data in the `./vars/credentials.yml`, which you will obviously have encrypted beforehand with `ansible-vault` (especially if you use git for your work). As everything uses a variable, you can easily make it suit your needs.

If you do not use something like Rundeck or Awx, you can launch the deployment with a command line similar to this one:

```
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

It is at this point that you can launch the final configuration of your virtual machine using Ansible. Do not forget to change the root password, secure SSH, register the new VM in your monitoring tool and in your IT inventory, etc.

## In summary

As we have seen, there are now fully automated DevOps solutions to create and deploy VMs.

At the same time, this represents an undeniable saving of time, especially in cloud or data center environments. It also facilitates a standard compliance across all of the computers in the company (servers and workstations), and an easy maintenance / evolution of templates.

## Other References

For a detailed project that also covers the deployment of Rocky Linux and other operating systems using the latest in vSphere, Packer, and the Packer Plugin for vSphere, please visit [this project](https://github.com/vmware-samples/packer-examples-for-vsphere). 
