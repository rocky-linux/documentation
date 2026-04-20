---
title: QA:Testcase Vagrant Images
author: Bob Robison
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
render_macros: true
---

This page provides information concerning how to boot/test the vagrant images.

## Vagrant File for BIOS Boot
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "custom/rocky10u0-official"
  #config.vm.box = "rockylinux/10"
  config.vm.hostname = "rockylinux10"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.boot_timeout = 7200

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
    vb.cpus = "2"

    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]

    # let vagrant known that the guest does not have the guest additions nor a functional vboxsf or shared folders.
    vb.check_guest_additions = false
    vb.functional_vboxsf = false
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cat /etc/rocky-release
    mokutil --sb-state
  SHELL

end
```

## Vagrant BIOS Boot Example
```
~/boxes/official/rocky10u0 ❯ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'custom/rocky10u0-official'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: rocky10u0_default_1749351226445_30105
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Setting hostname...
==> default: Running provisioner: shell...
    default: Running: inline script
    default: Rocky Linux release 10.0 (Red Quartz)
    default: EFI variables are not supported on this system
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong.

~/boxes/official/rocky10u0 ❯ vagrant ssh
[vagrant@rockylinux10 ~]$ sudo coredumpctl list
No coredumps found.
```

## Vagrant File for UEFI Boot
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "custom/rocky10u0-official"
  #config.vm.box = "rockylinux/10"
  config.vm.hostname = "rockylinux10"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.boot_timeout = 7200

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
    vb.cpus = "2"

    # Boot machine in efi mode
    vb.customize ["modifyvm", :id, "--firmware", "efi64"]

    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]

    # let vagrant known that the guest does not have the guest additions nor a functional vboxsf or shared folders.
    vb.check_guest_additions = false
    vb.functional_vboxsf = false
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cat /etc/rocky-release
    mokutil --sb-state
  SHELL

end
```

## Vagrant UEFI Boot Example
```
~/boxes/official/rocky10u0 ❯ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'custom/rocky10u0-official'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: rocky10u0_default_1749353062773_30641
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Setting hostname...
==> default: Running provisioner: shell...
    default: Running: inline script
    default: Rocky Linux release 10.0 (Red Quartz)
    default: SecureBoot disabled
    default: Platform is in Setup Mode


~/boxes/official/rocky10u0 ❯ vagrant ssh
[vagrant@rockylinux10 ~]$ sudo coredumpctl list
No coredumps found.
```

## Vagrant File for UEFI Secure Boot
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "custom/rocky10u0-official"
  #config.vm.box = "rockylinux/10"
  config.vm.hostname = "rockylinux10"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.boot_timeout = 7200

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
    vb.cpus = "2"

    # Boot machine in efi mode
    vb.customize ["modifyvm", :id, "--firmware", "efi64"]

    # Boot machine with secureboot enabled
    vb.customize ["modifyvm", :id, "‑‑tpm‑type", "2.0"]
    vb.customize ["modifynvram", :id, "inituefivarstore"]
    vb.customize ["modifynvram", :id, "enrollmssignatures"]
    vb.customize ["modifynvram", :id, "enrollorclpk"]
    vb.customize ["modifynvram", :id, "secureboot", "--enable"]

    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]

    # let vagrant known that the guest does not have the guest additions nor a functional vboxsf or shared folders.
    vb.check_guest_additions = false
    vb.functional_vboxsf = false
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cat /etc/rocky-release
    mokutil --sb-state
  SHELL

end
```

## Vagrant UEFI Secure Boot Example
```
~/boxes/official/rocky10u0 ❯ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'custom/rocky10u0-official'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: rocky10u0_default_1749353286744_54694
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Setting hostname...
==> default: Running provisioner: shell...
    default: Running: inline script
    default: Rocky Linux release 10.0 (Red Quartz)
    default: SecureBoot enabled

~/boxes/official/rocky10u0 ❯ vagrant ssh
[vagrant@rockylinux10 ~]$ sudo coredumpctl list
No coredumps found.
```

