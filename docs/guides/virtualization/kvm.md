---
title: KVM
author: David Hensley
contributors:
date: 
tested with: 8.5, 8.6, 8.7
tags:
  - KVM
  - virtualization
---

# KVM

## Preamble/Intro:
  Goal, What to achieve
  Why to achieve, desired results/benefits
  measurable desired results/benefits
  General process to be followed
  Concerns, Warnings, Notes, Caveats

## Prerequsites:

## Special Terminology:

## Process:
  1. Plan your install:
     
     These are some options to consider when planning for KVM usage:
     
     - Host filesystems:
       
       - Decide how you want to partition the host partitions for isolation and ease of maintenance, future expansion
       - What backup software and strategies will you use?
       
         - Will you use snapshots? If so where do you plan to store them, and how much space should you dedicate?
			     Will you use a dedicated partition or device for storing snapshots?
       
       - Will you leave unallocated storage space for later expansion of RAID/LVM/Filesystem Pools/Snapshots etc?
       - Will you dedicate a partition/device to storing images for VM, VE?
       - RAID (hardware vs software), LVM, zfs, ceph, glusterfs, ext4, reiserfs, xfs, nfs/cifs/nas
       - [RHEL recommendations](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9-beta/html/configuring_and_managing_virtualization/proc_enabling-virtualization-in-rhel-9_configuring-and-managing-virtualization)
         
         6 GB free disk space for the host, plus another 6 GB for each intended VM.
         
         2 GB of RAM for the host, plus another 2 GB for each intended VM. 
     
     - Will you be migrating VM's from physical host to physical host?
       If so, will the host machines be identical setups software and hardware, or of differing platforms?
     - Will you be accessing shared drive space via nfs, afs, cifs/smb?
     - Will you need to support "Nested" VMs to allow using say Virtualbox within a VM guest itself?
     - Will you be running "Containers" on the same host as the KVM?
       If so, will you need support for "Rootless" Containers? (needs cgroups v2)

## Dependencies:
  The instructions your particular CPU supports influences how you will set things up.

## Going Further:
  [RedHat KVM Optimizing](html/configuring_and_managing_virtualization/optimizing-virtual-machine-performance-in-rhel_configuring-and-managing-virtualization#doc-wrapper)

## Conclusions:
  Optimal KVM setups require some research and planning, which takes some time to do properly.


---


## GLOSSARY:

cgroups: Linux kernel mechanism to allow grouping and assigning of resources
VT-d
VT-X		[Intel VMX (Virtual Machine Extensions)](https://en.wikipedia.org/wiki/X86_virtualization#Intel-VT-x)
VT-c		Intel Virtualization Technology for Connectivity for network virtualization
IOMMU		[I/O Memory Management Unit](https://en.wikipedia.org/wiki/X86_virtualization#I/O_MMU_virtualization_(AMD-Vi_and_Intel_VT-d))
SMMU    (System Memory Management Unit) ARM IOMMU
RMRR		Reserved Memory Region Reporting: Used during early boot for legacy devices until the OS can provide drivers using IOMMU.
NUMA		Non-uniform memory access
DMA			Direct Memory Access
SR-IOV	[Single Root Input/Output Virtualization](https://en.wikipedia.org/wiki/Single-root_input/output_virtualization)
        Used to share/isolate PCIe devices among VMs
        https://www.intel.com/content/www/us/en/developer/articles/technical/configure-sr-iov-network-virtual-functions-in-linux-kvm.html
MR-IOV	Multi Root Input/Output Virtualization
        Allows I/O PCI Express to share resources among VMs on different physical machines
APIC		[Advanced Programmable Interrupt Controller](https://en.wikipedia.org/wiki/Advanced_Programmable_Interrupt_Controller)
        I/O APIC: one per bus, replaced by msi (Message Signaled Interrupts)
        LAPIC: Local Advanced Programmable Interrupt Controller, one per cpu
        [XAPIC/X2APIC](https://en.wikipedia.org/wiki/Advanced_Programmable_Interrupt_Controller#Variants)
IPIs		[Inter-Processor Interrupts](https://en.wikipedia.org/wiki/Inter-processor_interrupt)
AMD AVIC/Intel APICv [Interrupt virtualization](https://en.wikipedia.org/wiki/X86_virtualization#Interrupt_virtualization_.28AMD_AVIC_and_Intel_APICv.29)
AMD SME (Secure Memory Encryption)
AMD SEV (Secure Encrypted Virtualization)


## REFERENCES:
1. Footnotes/Reference links (URLs, manpage websites, etc)
2. Links to scripts, code and custom programs (for posterity in some cases if the originals might disappear )

---

TODO:

	BIOS:
		Verify BIOS virutalization capable and/or enabled:
		"HV" is "Hardware Virtualization" : uses processors that support Fault Tolerance
	
	Intel: VT-D (Intel® Virtualization Technology for Directed I/O)
			 VT-X (Intel® Virtual Machine Extensions)
			 VT-c
			 cpuflag: vmx
			 kernel boot option to enable: intel_iommu=on
	
	AMD: SVM (Secure Virtual Machine but later changed to AMD-V (AMD Virtualization))
				cpuflag: svm
			  Note: Not to be confused with svm which can also mean "Shared Virtual Memory")
			           https://www.mimuw.edu.pl/~vincent/lecture6/sources/amd-pacifica-specification.pdf
			 
			 SME (Secure Memory Encryption) https://www.kernel.org/doc/html/latest/x86/amd-memory-encryption.html
				grep -w sme /proc/cpuinfo
			 
			 SEV (Secure Encrypted Virtualization) https://libvirt.org/kbase/launch_security_sev.html
				`grep -w sev /proc/cpuinfo`
				These have to be supported in cpu and possibly BIOS/UEFI and enabled, you may have to pass `mem_encrypt=on kvm_amd.sev=1' on kernel cmd line.
					edit /etc/default/grub
					`grub2-mkconfig -o /boot/efi/EFI/<distro>/grub.cfg`
					or SEV can be put into a module config under `/etc/modprobe.d/`
						`/etc/modprobe.d/sev.conf`
							`options kvm_amd sev=1`
						
						`cat /sys/module/kvm_amd/parameters/sev` should yield `1` or `Y` after a reboot/module reload
						`ls -lh /dev/sev` will exist if cpu is SEV capable and it's in kernel and kvm stack (libvirt,)
						`virsh domcapabilities | grep -i sev`
					`mem_encrypt=on` turns on the SME memory encryption feature on the host which protects against the physical attack on the hypervisor memory.
					The `kvm_amd.sev` parameter actually enables SEV in the kvm module.

			 kernel boot option to enable: `amd_iommu=on`

	HPET, IOMMU, xapic/x2apic, apicv,
	HPET (High Precision Event Timer):
	TSC
	LAPIC	<-- Preferred timer on host
	
	`cat /proc/cpuinfo | egrep --color "vmx|svm|0xc0f"`
	`cat /proc/cpuinfo | egrep "vmx|svm"`
	`grep -E --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo`
	`lscpu | grep -i Virtualization`
	`egrep -c '(vmx|svm)' /proc/cpuinfo` <-- will show you the number of cpu's cores reporting
	`dmesg | grep -i AMD-Vi`
	
	use cpusets rather than isolcpus for kernel
		To see if it is enabled in a currently running system:
			`grep -i hpet /proc/timer_list`
			`cat /proc/timer_list | grep -i hpet`
			`ls -lh /dev/hpet`
			HPET_MMAP kernel option is not enabled by default on many distrobutions, may need to recompile kernel.
			[adrotate group=”1″] will enhance performance
			
			`dmesg | grep -i tsc`
			`cat /proc/timer_list | grep -i tsc`
			
			`dmesg | grep -i lapic`
			`cat /proc/timer_list | grep -i lapic`
			
			
	Iommu (Input Output Memory Management Unit)
	https://www.kernel.org/doc/html/latest/x86/intel-iommu.html
		hardware component which provides:
		  Address Translation for DMA requests (referred as DMA remapping)
		  Interrupt Remapping (from IOxAPIC and MSI)
		Allows older devices access to memory
		Requires these options enabled in the kernel:
    
    ```
			IOMMU_SUPPORT
			IOMMU_API
			INTEL_IOMMU / AMD_IOMMU
			INTEL_IOMMU_DEFAULT_ON / AMD_IOMMU_DEFAULT_ON
		```
    
		See if iommu groups are populated:
			`ls -l /sys/kernel/iommu_groups/`
			`dmesg | grep -i iommu`
			`journalctl -k | grep -i iommu`
		
		See if DMA Remapping is enabled:
			 `dmesg | grep -i dmar`
			What mode is it in:
				 `dmesg | grep -i "DMAR-IR: Enabled IRQ remapping"`

		`dnf install @virt` (see what this installs: need virt, virt-install, virt-viewer, libvirt-daemon-config-network,
				libvirt-nss, libguestfs-rescue)
			`dnf -y install bridge-utils virt-top libvirt-devel libguestfs libguestfs-tools sysfsutils perf`
			`dnf install virt-manager` (if you want the GUI manager)
		`dnf grouplist`
			Install these if wanted: Virtualization Host, Container Management
				`dnf groupinstall 'Virtualization Host'`
				Or update the whole group if already set:
					`dnf groupupdate 'Virtualization Host'`
					
			Verify your system is ready:
				`virt-host-validate` <-- you can correct the FAIL and WARN notices
					list of checks example:
          
          ```
          
						QEMU: Checking for hardware virtualization                                       : PASS
						QEMU: Checking if device /dev/kvm exists                                         : PASS
						QEMU: Checking if device /dev/kvm is accessible                              : PASS
						QEMU: Checking if device /dev/vhost-net exists                                 : PASS
						QEMU: Checking if device /dev/net/tun exists                                     : PASS
						QEMU: Checking for cgroup 'cpu' controller support                           : WARN (Enable 'cpu' in kernel Kconfig file or mount/enable cgroup controller in your system)
						QEMU: Checking for cgroup 'cpuacct' controller support                    : PASS
						QEMU: Checking for cgroup 'cpuset' controller support                      : WARN (Enable 'cpuset' in kernel Kconfig file or mount/enable cgroup controller in your system)
						QEMU: Checking for cgroup 'memory' controller support                    : WARN (Enable 'memory' in kernel Kconfig file or mount/enable cgroup controller in your system)
						QEMU: Checking for cgroup 'devices' controller support                     : PASS
						QEMU: Checking for cgroup 'blkio' controller support                          : WARN (Enable 'blkio' in kernel Kconfig file or mount/enable cgroup controller in your system)
						QEMU: Checking for device assignment IOMMU support                    : PASS
						QEMU: Checking if IOMMU is enabled by kernel                                 : PASS
						QEMU: Checking for secure guest support                                          : WARN (Unknown if this platform has Secure Guest support)
            
          ```


			Verify network is ready:
				`virsh net-list --all`
				If not, activate the default network and set it to auto-start:
					`virsh net-autostart default`
					`virsh net-start default`
					if errors, use 'virsh net-edit default' to correct
					
	AMD/Intel iommu, iommu=pt (if passthru needed (gpu, network, etc))
		Intel: intel_iommu=on iommu=pt
			verify: `dmesg | grep -e DMAR -e IOMMU`
			To overide the BIOS x2apic override bit:
				add boot parameter: 'intremap=no_x2apic_optout'
		AMD: amd_iommu=on iommu=pt modprobe.blacklist=nouveau LANG=en_US.UTF-8
			verify: `dmesg | grep -e DMAR -e IOMMU -e AMD-Vi`
			cpu: extapic, extd_apicid
			
		`lspci -v` can show you what the iommu groups and dma channels are used for each device
		
		Regarding RMRR exclusions:
		https://access.redhat.com/articles/1434873
		
Check if kernel modules loaded:
	`lsmod | grep kvm`
	`modinfo <driver-Name-Here>`

	Need virtio for kvm(lxc as well?)
		`modprobe kvm_intel`
		780  man modprobe
		781  modprobe -c
		791  modprobe vfio
		869  modprobe vfio-pci
		1167  ls -lha /lib/modprobe.d/
		1170  ls -lha /etc/modprobe.d/
		1171  vim /etc/modprobe.d/tuned.conf
		1172  cat /etc/modprobe.d/truescale.conf
		1173  cat /etc/modprobe.d/vhost.conf
		1174  cat /etc/modprobe.d/kvm.conf

Check apic/x2apic/vapic/apicv:
  `cat /sys/module/kvm_intel/parameters/enable_apicv`

https://listman.redhat.com/archives/vfio-users/2016-June/msg00055.html
	`cat /proc/cpuinfo | grep -i apic` <-- to see if cpu supports any of
		Intel: apic, x2apic
		AMD: apic, extd_apicid,  extapic
	APIC Virtualization extension (APICv/vAPIC) relies on x2apic
	x2apic relies on "Interrupt Remapping support" (part of IOMMU)
	`dmesg | grep 'remapping'` to see if it's enabled
		If your system doesn't support interrupt remapping, you can allow unsafe interrupts with:
			`echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf`
	Verify IOMMU Isolation groups:
		Requires BIOS ACS (Access Control Services) support
		`find /sys/kernel/iommu_groups/ -type l`
		
	`cat /proc/cpuinfo | grep -i x2apic` (or `grep -i x2apic /proc/cpuinfo`)
	`dmesg | grep -i x2apic`
	If it returns something like "x2apic enabled", its working.
	Check if your BIOS has the x2apic disable bit, since some firmware tell the OS to **NOT** use x2APIC.
		on R720 it is disabled:
    
    ```
    
			[root@hostname ~]# dmesg | grep -i x2apic
			[    0.001000] DMAR-IR: x2apic is disabled because BIOS sets x2apic opt out bit.
			[    0.001000] DMAR-IR: Use 'intremap=no_x2apic_optout' to override the BIOS setting.
			[    0.001000] x2apic: IRQ remapping doesn't support X2APIC mode
      
    ```

VMs also supports an emulated form of x2APIC, which performs better than the previous alternative (Very old APIC emulation?? Not sure).
You do not need host or Processor support for to use x2APIC within VM guests,
  gives pretty much free performance - so much so that a QEMU dev decided to include the x2APIC CPU Flag in nearly
  ALL Processors models (-cpu whatever), so you can use in QEMU `-cpu core2duo` and it will by default expose the
  emulated x2APIC via the CPU Flag even though that platform didn't have it.

You can check in a Linux VM if x2APIC exist as CPU Flag using:
  `grep x2apic /proc/cpuinfo`

For cgroups v2 : (needed for rootless containers (Docker, lxc? Podman?)
		`systemd.unified_cgroup_hierarchy=1` (may need cgroup_no_v1=all)
			'sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1"'
			"cgroup_no_v1=all" may be needed also
			Does one still need to mnt the path, or is it automatic?
			
Check if libvirt or ovirt is loaded/enabled:
  NOTE: Neil pointed out ovirt isn't being maintained anymore.
	`systemctl status libvirtd`
	`systemctl enable libvirtd`
	`systemctl start libvirtd`

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/optimizing-virtual-machine-performance-in-rhel_configuring-and-managing-virtualization#optimizing-virtual-machine-i-o-performance_optimizing-virtual-machine-performance-in-rhel
Check for vhost_net:
	`lsmod | grep -i vhost`
	`modprobe vhost_net`

Check for virtio-net:
	`kmod list | grep -i virt`
	`modprobe virtio-net`
	
Create network bridge: virbr0
https://computingforgeeks.com/how-to-create-a-linux-network-bridge-on-rhel-centos-8/
	`brctl show`

Setup nested virtual machines support:
	`cat /sys/module/kvm_intel/parameters/nested`
	`cat /sys/module/kvm_intel/parameters/nested_early_check`

Setup NUMA: systemctl status numad
	`virsh nodeinfo`
	
Tuned setup for vm/ve:
  There are tuned profiles for virtual-host and virtual-guest ( `tuned-adm list` )
		/etc/modprobe.d/tuned.conf
  How do the kvm host tuned profiles affect containers running on the same host?

---

KVM:

Steps to follow
	Enable BIOS svm, vt-d
	Decide to use cgroup v1 or v2 (can affect Docker, rootless containers)
	Adjust kernel boot parameters:
	  AMD/Intel iommu=on, iommu=pt (if passthru needed (gpu, network, etc))
		apic settings, x2apic/vapic/apicv, --args="systemd.unified_cgroup_hierarchy=1"
		or 'sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all"'
	Set up/modify SELinux (policies, enforcement)
	Set Up a Network Bridge
	Install KVM
	Enable/Start KVM service/deamon
	Download/create ISOs
	Create a VM
	Start Virt-Manager (GUI through MobaXterm) or cli (virsh, etc)

How to Set Up a Network Bridge
	Begin by creating a file at /etc/sysconfig/network-scripts/ifcfg-br0.
	Next, edit the file and modify it as you need to fit your network.
		#`vi /etc/sysconfig/network-scripts/ifcfg-br0`
    
    ```
    
			DEVICE=br0
			TYPE=Bridge
			IPADDR=192.168.1.100
			NETMASK=255.255.255.0
			GATEWAY=192.168.1.1
			DNS=8.8.8.8
			ONBOOT=yes
			BOOTPROTO=static
			DELAY=0
      
    ```

	configure the bridge interface:
		If you have just one network interface you have to remove it (or rename it) and you have to recreate a new file with the same name at /etc/sysconfig/network-scripts/.
		For example:
			#`vi /etc/sysconfig/network-scripts/ifcfg- eth0`
      
      ```
      
			DEVICE=eth0
			TYPE=Ethernet
			HWADDR=AA:BB:CC:DD:EE:FF
			BOOTPROTO=none
			ONBOOT=yes
			BRIDGE=br0
      
      ```
      
			and Save it

	Restart networking for the bridge to take effect.
		`systemctl reload NetworkManager`
		or
		`/etc/sysconfig/network-scripts/ifcfg-etho stop`
		then
		`/etc/sysconfig/network-scripts/ifcfg-etho start
		(would just `/etc/sysconfig/network-scripts/ifcfg-etho restart` work?)
		
Install KVM
	`dnf install qemu-kvm qemu-img libvirt virt-install libvirt-client virt-manager edk2-ovmf`
	verify modules present:
	  `lsmod | grep kvm`

Enable/Start KVM
		Enable/start libvirtd service.
			`systemctl enable libvirtd`
			`systemctl start libvirtd` (unless systemctl status libvirtd shows it's running)
		Verify: `systemctl status libvirtd`

Create a VM
	Store the ISOs you want to use for VM Guests
		Notes on storage locations here
		Ex: https://download.rockylinux.org/pub/rocky/8.5/images/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2
			https://download.rockylinux.org/pub/rocky/8.5/Minimal/x86_64/iso/Rocky-8.5-x86_64-minimal.iso
			
			`virt-sysprep` and `cloud-init` tools to set ssh keys or passwd for user
			
GUI to setup/modify VM:
	'osinfo-query os' will show you the label names to use
	`virt-manager` &
	cockpit:

Text mode installation
	`virt-install –virt-type=kvm –name Rocky8.5GC –ram 4096 –vcpus=4 –os-variant=rocky8.5 \
		–cdrom=/path/to/install.iso --boot uefi –network=bridge=br0,model=virtio –graphics none \
		–disk path=/var/lib/libvirt/images/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2,size=20,bus=virtio,format=qcow2`
		Options to set root user and user so it will set keys up, etc

Extras:
`guestfish` command to mount and make changes to qcow2 image, it should be part of libguestfs tools and it can be used to change the password or add a new user etc

`dmesg`, `journalctl -k -l` (They should be the same, or `journalctl -t kernel`; can customize journald.conf) :
  Check to make sure no errors, and all needed are enabled

---

Rootless Containers:
	https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics#example__using_rootless_containers
	https://thenewstack.io/linux-cgroups-v2-brings-rootless-containers-superior-memory-management/

---

Look at what software groups are available:
`dnf grouplist`
	"Virtualization Host", "Container Management"
	`dnf grouplist "Virtualization Host"`
	To install the mandatory and default packages in the "Virtualization Host" group:
		`dnf install @"Virtualization Host"`
	To install the mandatory, default, and optional packages:
		`dnf group install --with-optional "Virtualization Host"`
	
Kernel Modules for KVM:
	You should load/test on your system first, passing kernel params if needed but don't set them for persistence yet.
	You can do this by using `e` on the kernel boot menu in Grub when booting. These changes will not persist across
	boots until you add them to the Grub2 cmdline parameter `/etc/default/grub` and/or edit `/etc/modprobe.d/<module-name>.conf
	
	Once you've determined what you will require, then set them for persistence by editing
	`/etc/modprobe.d/<module-name>.conf`
	and editing the Grub2 cmdline `/etc/default/grub` and running `grub2 -o /etc/efi....
	
	Just keep notes as you go so you can remember to pass all params you need
	for the kernel, modules, etc
	
	See your current default module loads at boot time, examine the files for options enabled:
	ls -lha /etc/modprobe.d/
	ls -lha /etc/modules-load.d/
	
lshw will show devices on all buses (pci,usb, etc)
	use it to enumerate devices, and to get more detailed info
	it will show "capabilities", "driver" for each device detected.
	You will need this info for PassThrough (video, network, usb devices) or to attach
	devices like usb drives.

lsmod (list all currently loaded modules, pretty-prints /proc/modules)
	Module                  	Size  Used by
	kvm_intel             323584  0
	kvm                     880640  121 kvm_intel
	irqbypass               16384  1 kvm

List all installed modules for currently running kernel:
	cat /lib/modules/$(uname -r)/modules.builtin
	cat /lib/modules/$(uname -r)/modules.alias

Show what the current kernel was built/configured for:
	cat /boot/config-4.18.0-348.12.2.el8_5.x86_64 | grep -i nat
 
modprobe -n ( or --dry-run or --show; -v increases debug output) <module>
	shows what it would do without doing it
	
modinfo <module>
	will show the params available, these can be set in the /etc/modprobe.d/ files too
systool -v -m <module>
	systool is in the `sysfsutils` pkg
	will show the options set for that module

modprobe --show-depends <module>
	Shows dependencies
	
Set modules to load at boot time:
	Make sure systemd modules load is enabled:
		systemctl status systemd-modules-load
			Note the PID and last few lines
			journalctl -b _PID=<pid> will show:
				[root@vavatch ~]# journalctl -b _PID=1025
				-- Logs begin at Thu 2022-02-24 17:40:59 EST, end at Fri 2022-02-25 11:40:01 EST. --
				Feb 24 17:41:03 vavatch systemd-modules-load[1025]: Module 'msr' is builtin

	Create files in /etc/modules-load.d/<module>.conf
	If you need persisting module parameters:
		options <module> [parameter=value]
		On kernel cmd line at boot:
			module_name.parameter_name=parameter_value
			
	Make sure all deps/symbols are met:
		depmod -n -v -w
		depmod 
		
	Network info:
	lspci -v | grep -i ethernet
	lspci -vk | grep -A 6 -i ethernet
		-A 6 = number of lines after match to show
	ethtool -i <nic-name>
	find /sys | grep drivers.*<pcibusnum>
	
	Set option for nested vm's in /etc/modprobe.d/kvm.conf
	Set options for vhost in /etc/modprobe.d/vhost.conf
	
	systemctl reboot
	confirm modules where loaded:
		lsmod | grep -i <module>
		journalctl -b _PID=<pid>
	If some of the modules are missing, it might have been removed by another module:
		grep -ri "blacklist <module>" /etc/module*
			to see if your desired module was blacklisted by another module
			/etc/modprobe.d/*.conf
			/usr/lib/modprobe.d/*.conf
			/run/modprobe.d/*.conf


Optimizing module parameters:
systool -v -m <module>
	Examine the "Parameters:" list
		Ex: systool -v -m kvm_intel
				enable_apicv        = "N" <-- this can be enabled as apicv depends on x2apic which is enabled for guests
															and the performance is better
	
	To test a paramater for a module:
	Unload the module if needed:
		modprobe -r <module> (NOTE: this unloads dep modules as well if not used by other modules)
		rmmod <module> This will not unload dep modules
		
	modprobe <module_name> <parameter_name=parameter_value>
	

dnf install https://resources.ovirt.org/pub/yum-repo/ovirt-release44.rpm

dnf search ovirt


