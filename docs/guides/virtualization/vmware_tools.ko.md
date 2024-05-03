---
title: VMware Tools™ Installation
author: Emre Camalan
contributors: Steven Spencer
tested_with: 8.9, 9.3
tags:
  - VMware
  - Tools
---

# VMware Tools™ 설치

VMware Tools™는 VMware vSphere, VMware Workstation, VMware Fusion과 같은 VMware 가상화 플랫폼에서 실행되는 가상 머신(VM)의 성능과 관리를 향상시키는 유틸리티 모음입니다. VMware Tools™는 게스트 운영 체제와 호스트 환경 사이의 상호 작용을 개선합니다.

## 전제 조건 및 가정

- VMware 인스턴스를 VMware Tools™로 관리하고자 하는 욕구
- `sudo`를 사용하여 권한을 상승시킬 수 있는 능력
- Rocky Linux 최소 설치로 시작한다고 가정

## 필요한 패키지 설치

X11 VMware 드라이버 설치:

```bash
sudo dnf install xorg-x11-drv-vmware
```

kernel-devel 및 kernel-headers 설치:

```bash
sudo dnf install kernel-devel kernel-headers
```

`perl`이 이미 설치되어 있지 않다면 설치:

```bash
sudo dnf install perl
```

시스템 재부팅

```bash
sudo shutdown -r now
```

## VMware Tools™ 마운트

### 그래픽 인터페이스에서 VMware Tools™ 마운트

가상 머신 메뉴에서 VM을 마우스 오른쪽 버튼으로 클릭한 다음, 게스트 > VMware Tools™ 설치/업그레이드 클릭.

> VM 탭 => VMware Tools 설치 선택

VMware Tools CDROM 마운트 완료.

### 명령줄에서 VMware Tools™ 마운트

VMware Tools™를 위한 마운트 포인트를 생성하고 마운트:

```bash
sudo mkdir /mnt/cdrom 
sudo mount /dev/cdrom /mnt/cdrom
mount: /mnt/cdrom: 경고: 소스 쓰기 보호됨, 읽기 전용으로 마운트됨.
```

`/dev/cdrom`이 마운트되었는지 확인:

```bash
sudo df -h
파일시스템           크기  사용  남음 사용% 마운트 위치
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                1.8G     0  1.8G   0% /dev/shm
tmpfs                724M  9.3M  715M   2% /run
/dev/mapper/rl-root   37G  3.5G   34G  10% /
/dev/nvme0n1p1       960M  342M  619M  36% /boot
/dev/mapper/rl-home   19G  163M   18G   1% /home
tmpfs                362M   84K  362M   1% /run/user/1001
/dev/sr0              56M   56M     0 100% /mnt/CDROM
[root@localhost ecamalan]# cd /mnt/cdrom/
[root@localhost cdrom]# ls
manifest.txt  run_upgrader.sh  VMwareTools-10.3.23-16594550.tar.gz  vmware-tools-upgrader-32  vmware-tools-upgrader-64
```

## VMware Tools™ 설치

이 명령을 사용하여 VMware Tools™ gzip 파일을 로컬 `/tmp` 디렉토리로 복사:

```bash
cp /mnt/cdrom/VMwareTools-10.3.23-16594550.tar.gz /tmp/
```

`tar.gz` 파일을 `/tmp/vmware-tools-distrib`라는 새 디렉토리로 압축 해제:

```bash
[root@localhost cdrom]# cd /tmp/
[root@localhost tmp]# tar -zxvf VMwareTools-10.3.23-16594550.tar.gz vmware-tools-distrib/
vmware-tools-distrib/
vmware-tools-distrib/bin/
vmware-tools-distrib/bin/vm-support
vmware-tools-distrib/bin/vmware-config-tools.pl
vmware-tools-distrib/bin/vmware-uninstall-tools.pl
vmware-tools-distrib/vgauth/
vmware-tools-distrib/vgauth/schemas/
vmware-tools-distrib/vgauth/schemas/xmldsig-core-schema.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema.xsd
vmware-tools-distrib/vgauth/schemas/saml-schema-assertion-2.0.xsd
vmware-tools-distrib/vgauth/schemas/catalog.xml
vmware-tools-distrib/vgauth/schemas/XMLSchema.dtd
vmware-tools-distrib/vgauth/schemas/xml.xsd
vmware-tools-distrib/vgauth/schemas/xenc-schema.xsd
vmware-tools-distrib/vgauth/schemas/datatypes.dtd
vmware-tools-distrib/vgauth/schemas/XMLSchema-instance.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema-hasFacetAndProperty.xsd
vmware-tools-distrib/caf/

... (some packages not shown)

vmware-tools-distrib/lib/plugins64/common/
vmware-tools-distrib/lib/plugins64/common/libvix.so
vmware-tools-distrib/lib/plugins64/common/libhgfsServer.so
vmware-tools-distrib/doc/
vmware-tools-distrib/doc/INSTALL
vmware-tools-distrib/doc/open_source_licenses.txt
vmware-tools-distrib/doc/README
vmware-tools-distrib/vmware-install.pl
```

!!! warning "주의"

````
시작하기 전에 `/etc/init.d` 디렉토리가 있는지 확인해야 합니다.
없다면 다음과 같은 오류를 볼 수 있습니다:

> init 디렉토리(rc0.d/부터 rc6.d/)가 포함된 디렉토리는 어디인가요?

해결책:

```bash
sudo su
[root@localhost etc]# clear
[root@localhost etc]# cd /etc/
[root@localhost etc]# mkdir init.d
[root@localhost etc]# cd init.d
[root@localhost etc]# for i in {0,1,2,3,4,5,6}
> do
> mkdir rc$i.d
> done
[root@localhost etc]# cd /tmp/vmware-tools-distrib/
[root@localhost vmware-tools-distrib]# ./vmware-install.pl 
```
````

!!! warning "주의"

```
기본 init 스크립트 디렉토리를 변경할 때 주의하세요. 해당 디렉토리는 `/etc/init.d/`여야 합니다.

> init 디렉토리(rc0.d/부터 rc6.d/)가 포함된 디렉토리는 어디인가요? 
>[/etc] /etc/init.d

>입력: [/etc/init.d]

>"etc/init.d" 경로는 rc0.d 디렉토리가 없는 디렉토리입니다.


> init 디렉토리(rc0.d/부터 rc6.d/)가 포함된 디렉토리는 어디인가요? 
>**[/etc] /etc/init.d/**

>입력: [/etc/init.d/]

> init 스크립트가 포함된 디렉토리는 어디인가요? 
>[/etc/init.d] 

>입력: [/etc/init.d]  기본값
```

PERL 스크립트를 실행하려면 vmware-tools-distrib 디렉토리로 변경한 후 `vmware-install.pl`을 실행하세요:

```bash
sudo cd /tmp/vmware-tools-distrib/
sudo ./vmware-install.pl

A previous installation of VMware Tools has been detected.

The previous installation was made by the tar installer (version 4).

Keeping the tar4 installer database format.

You have a version of VMware Tools installed.  Continuing this install will 
first uninstall the currently installed version.  Do you wish to continue? 
(yes/no) [yes] 

입력: [yes] 기본값

Uninstalling the tar installation of VMware Tools™.

Can't exec "/etc/vmware-caf/pme/install/preupgrade.sh": No such file or directory at /usr/bin/vmware-uninstall-tools.pl line 4421.
The removal of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully.

Installing VMware Tools™.

In which directory do you want to install the binary files? 
[/usr/bin] 

입력: [/usr/bin]  기본값

What is the directory that contains the init directories (rc0.d/ to rc6.d/)? 
[/etc] 

입력: [/etc]  기본값

What is the directory that contains the init scripts? 
[/etc/init.d] 

입력: [/etc/init.d]  기본값

In which directory do you want to install the daemon files? 
[/usr/sbin] 

입력: [/usr/sbin]  기본값

In which directory do you want to install the library files? 
[/usr/lib/vmware-tools] 

입력: [/usr/lib/vmware-tools]  기본값

The path "/usr/lib/vmware-tools" does not exist currently. This program is 
going to create it, including needed parent directories. Is this what you want?
[yes] 

입력: [yes] 기본값

In which directory do you want to install the common agent library files? 
[/usr/lib] 

입력: [/usr/lib]  기본값

In which directory do you want to install the common agent transient files? 
[/var/lib] 

입력: [/var/lib]  기본값

In which directory do you want to install the documentation files? 
[/usr/share/doc/vmware-tools] 

입력: [/usr/share/doc/vmware-tools]  기본값

The path "/usr/share/doc/vmware-tools" does not exist currently. This program 
is going to create it, including needed parent directories. Is this what you 
want? [yes] 

입력: [yes] 기본값

The installation of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully. You can decide to remove this software from your system at any 
time by invoking the following command: "/usr/bin/vmware-uninstall-tools.pl".

Before running VMware Tools for the first time, you need to configure it by 
invoking the following command: "/usr/bin/vmware-config-tools.pl". Do you want 
this program to invoke the command for you now? [yes] 

입력: [yes] 기본값

Initializing...


Making sure services for VMware Tools are stopped.

Failed to stop vmware-tools.service: Unit vmware-tools.service not loaded.
Stopping VMware Tools services in the virtual machine:
   Guest operating system daemon:                                      done
   VMware User Agent (vmware-user):                                    done
   Unmounting HGFS shares:                                             done
   Guest filesystem driver:                                            done


sh: line 1: : command not found
The installation status of vmsync could not be determined. 
Skippinginstallation.

The installation status of vmci could not be determined. Skippinginstallation.

The installation status of vsock could not be determined. Skippinginstallation.


The installation status of vmxnet3 could not be determined. 
Skippinginstallation.

The installation status of pvscsi could not be determined. 
Skippinginstallation.

The installation status of vmmemctl could not be determined. 
Skippinginstallation.

The VMware Host-Guest Filesystem allows for shared folders between the host OS 
and the guest OS in a Fusion or Workstation virtual environment.  Do you wish 
to enable this feature? [yes] 

입력: [yes] 기본값

The vmxnet driver is no longer supported on kernels 3.3 and greater. Please 
upgrade to a newer virtual NIC. (e.g., vmxnet3 or e1000e)

The vmblock enables dragging or copying files between host and guest in a 
Fusion or Workstation virtual environment.  Do you wish to enable this feature?
[yes] 

입력: [yes] 기본값


Skipping configuring automatic kernel modules as no drivers were installed by 
this installer.

Do you want to enable Guest Authentication (vgauth)? Enabling vgauth is needed 
if you want to enable Common Agent (caf). [yes] 

입력: [yes] 기본값

Do you want to enable Common Agent (caf)? [no] 

입력: [no]  기본값



Detected X server version 1.20.11



Distribution provided drivers for Xorg X server are used.

Skipping X configuration because X drivers are not included.


Skipping rebuilding initrd boot image for kernel as no drivers to be included 
in boot image were installed by this installer.

Generating the key and certificate files.
Successfully generated the key and certificate files.
Failed to start vmware-tools.service: Unit vmware-tools.service not found.
Unable to start services for VMware Tools

Execution aborted.

Warning no default label for /tmp/vmware-block-restore-5339.0/tmp_file
Enjoy,

--the VMware team
```

GUI를 실행 중인 경우 시스템을 다시 시작해야 합니다:

```bash
sudo shutdown -r now
```

## Check VMware installation

```bash
  sudo /etc/init.d/vmware-tools start
    Checking acpi hot plug                                              done
  Starting VMware Tools services in the virtual machine:
    Switching to guest configuration:                                   done
    Guest filesystem driver:                                            done
    Mounting HGFS shares:                                               done
    Blocking file system:                                               done
    Guest operating system daemon:                                      done
    VGAuthService:   
```

```bash
    sudo /etc/init.d/vmware-tools status
    vmtoolsd is running
```

## 결론

Rocky Linux의 최소 설치로 시작했는데, 이로 인해 많은 결핍이 발생하고 여러 오류를 마주쳤습니다. 그럼에도 불구하고, 일부 도전과제가 있었음에도 VMware Tools™를 설치하고 실행하는 데에 성공했습니다.
