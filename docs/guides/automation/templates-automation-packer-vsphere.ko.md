---
title: 자동 템플릿 생성 - Packer - Ansible - VMware vSphere
author: Antoine Le Morvan
contributors: Steven Spencer, Ryan Johnson, Pedro Garcia
---

# Packer와 Ansible을 사용하여 VMware vSphere 환경에서 자동 템플릿 생성 및 배포하기

**지식**: :star: :star: :star:   
**복잡성**: :star: :star: :star:

**소요 시간**: 30분

## 전제 조건, 가정 및 일반 참고 사항

* 사용 가능한 vSphere 환경 및 액세스 권한이 부여된 사용자.
* 파일을 저장하는 내부 웹 서버.
* Rocky Linux 리포지토리에 대한 웹 액세스.
* Rocky Linux의 ISO 파일.
* Ansible 환경을 사용 가능.
* 언급된 각 제품에 대한 어느 정도의 지식이 있는 것으로 가정합니다. 그렇지 않다면 시작하기 전에 해당 문서를 찾아보세요.
* 여기서 Vagrant는 사용하지 **않습니다**. Vagrant를 사용하면 자체 서명되지 않은 SSH 키가 제공됩니다. 이에 대해 알아보고 싶다면 자세히 살펴볼 수 있지만, 이 문서에서 다루지는 않습니다.

## 소개

이 문서에서는 Packer를 사용하여 vSphere 가상 머신 템플릿을 생성하고, Ansible을 사용하여 아티팩트를 새 가상 머신으로 배포하는 과정을 다룹니다.

## 가능한 조정

물론, 이 가이드를 다른 하이퍼바이저에 맞게 조정할 수 있습니다.

여기에서는 최소 ISO 이미지를 사용하지만, DVD 이미지(훨씬 더 크고 아마도 너무 큼) 또는 부트 이미지(훨씬 작고 아마도 너무 작음)를 선택할 수도 있습니다. 이 선택은 사용자의 몫입니다. 이는 설치에 필요한 대역폭과 따라서 프로비저닝 시간에 영향을 미칩니다. 다음에서는 기본 선택의 영향과 그 해결 방법에 대해 논의하겠습니다.

또한 가상 머신을 템플릿으로 변환하지 않을 수도 있습니다. 이 경우 Packer를 사용하여 각 새 VM을 배포할 수 있으며, 이는 여전히 꽤 실행 가능한 방법입니다. 0에서 시작하는 설치는 인간의 개입 없이 10분 이내에 완료됩니다.

## Packer

### Packer 소개

Packer는 HashiCorp에서 개발한 오픈 소스 가상 머신 이미징 도구로, MPL 2.0 라이선스로 출시되었습니다. Packer를 사용하면 클라우드 및 온프레미스 가상화 환경 모두에서 사전 구성된 운영 체제와 설치된 소프트웨어가 포함된 가상 머신 이미지를 자동화하여 생성할 수 있습니다.

Packer를 사용하여 다음 플랫폼에 사용할 이미지를 생성할 수 있습니다:

* [Amazon Web Services](https://aws.amazon.com).
* [Azure](https://azure.microsoft.com).
* [GCP](https://cloud.google.com).
* [DigitalOcean](https://www.digitalocean.com).
* [OpenStack](https://www.openstack.org).
* [VirtualBox](https://www.virtualbox.org/).
* [VMware](https://www.vmware.com).

추가 정보를 위해 다음 리소스를 확인할 수 있습니다:

* https://www.packer.io/
* [Packer documentation](https://www.packer.io/docs)
* 빌더 `vsphere-iso`의 [문서](https://www.packer.io/docs/builders/vsphere/vsphere-iso)

### Packer 설치

Rocky Linux 시스템에 Packer를 설치하는 방법에는 두 가지가 있습니다.

#### Hashicorp 저장소에서 Packer 설치

HashiCorp는 다른 Linux 배포판을 위한 패키지를 유지 관리하고 서명합니다. Rocky Linux 시스템에 packer를 설치하려면 다음 단계를 따르세요.


#### Packer 웹 사이트에서 다운로드 및 설치

1. dnf-config-manager 설치합니다:

```bash
$ sudo dnf install -y dnf-plugins-core
```

2. Rocky Linux 시스템에서 사용 가능한 저장소에 HashiCorp 저장소를 추가합니다.

```bash
$ sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```

3. Packer 설치합니다:

```bash
$ sudo dnf -y install packer
```

#### Packer 웹 사이트에서 다운로드 및 설치


[Packer 다운로드](https://www.packer.io/downloads)를 통해 자체 플랫폼용 바이너리를 다운로드하여 시작할 수 있습니다.

1. 다운로드 페이지에서 시스템 아키텍처에 해당하는 Linux 바이너리 다운로드 섹션의 다운로드 링크를 복사합니다.

2. 셸 또는 터미널에서 `wget` 도구를 사용하여 다운로드합니다.

```bash
$ wget https://releases.hashicorp.com/packer/1.8.3/packer_1.8.3_linux_amd64.zip
```
그러면 .zip 파일이 다운로드됩니다.

3.  다운로드한 아카이브를 압축 해제하려면 셸에서 다음 명령을 실행합니다.

```bash
$ unzip packer_1.8.3_linux_amd64.zip
```

!!! tip "팁"

    만약 오류가 발생하여 시스템에 unzip 앱이 설치되어 있지 않다면, 다음 명령 ```sudo dnf install unzip```를 실행하여 설치할 수 있습니다.

4. Packer 앱을 bin 폴더로 이동합니다.

```bash
$ sudo mv packer /usr/local/bin/
```

#### Packer의 올바른 설치 확인

이전 절차의 모든 단계를 올바르게 완료한 경우 시스템에 Packer가 올바르게 설치되었는지 확인할 수 있습니다.

Packer가 올바르게 설치되었는지 확인하려면 `packer` 명령을 실행하면 다음과 같은 결과가 표시됩니다:

```bash
$ packer 
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           템플릿에서 이미지 빌드
    console         변수 보간을 테스트하기 위한 콘솔 생성
    fix             이전 버전의 packer 템플릿 수정
    fmt             HCL2 구성 파일을 표준 형식으로 재작성
    hcl2_upgrade    JSON 템플릿을 HCL2 구성으로 변환
    init            누락된 플러그인 설치 또는 플러그인 업그레이드
    inspect         템플릿의 구성 요소 확인
    plugins         Packer 플러그인 및 카탈로그와 상호 작용
    validate        템플릿이 유효성 검사
    version         Packer 버전 출력
```

### Packer로 템플릿 생성

!!! note "Note"

    $ vim .vsphere-secrets.json {
        "vcenter_username": "rockstar",
        "vcenter_password": "mysecurepassword"
      }

Packer를 통해 VMware vCenter Server에 연결하여 Packer를 통해 명령을 전송하기 위해, 다음으로 설명할 구성 파일 외부에 자격 증명을 저장해야 합니다.

홈 디렉토리에 자격 증명을 저장하는 숨겨진 파일을 만듭니다. 이는 json 파일입니다:

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

이러한 자격 증명은 vSphere 환경에 액세스하는 데 필요한 권한을 갖고 있어야 합니다.

다음은 json 파일을 생성합니다 (향후 이 파일의 형식은 HCL로 변경될 예정입니다):

```
"variables": {
  "version": "0.0.X",
  "HTTP_IP": "fileserver.rockylinux.lan",
  "HTTP_PATH": "/packer/rockylinux/8/ks.cfg"
},
```
다음으로 이 파일의 각 섹션에 대해 설명합니다.

### Variables 섹션

첫 번째 단계에서 가독성을 위해 변수를 선언합니다:

```
"sensitive-variables": ["vcenter_password"],
```

나중에 생성할 템플릿 이름에 `version` 변수를 사용할 것입니다. 필요에 따라 이 값을 쉽게 증가시킬 수 있습니다.

`ks.cfg`(Kickstart) 파일에 액세스하려면 부팅 가상 머신도 필요합니다.

Kickstart 파일에는 설치 프로세스 중에 묻는 질문에 대한 답변이 포함되어 있습니다. 이 파일은 모든 내용을 Anaconda(설치 프로세스)에 전달하여 템플릿의 완전 자동화를 가능하게 합니다.

작성자는 내부 웹 서버에 `ks.cfg` 파일을 저장하는 것을 좋아합니다. 그러나 이 대신 사용할 수 있는 다른 방법도 있습니다.

예를 들어 `ks.cfg` 파일은 VM의 연구소 이 URL 에서 액세스할 수 있습니다: http://fileserver.rockylinux.lan/packer/rockylinux/8/ks.cfg 이 메서드를 사용하려면 비슷한 방식으로 설정해야 합니다.

암호를 비공개로 유지하기 위해 민감한 변수로 선언됩니다. 예시:

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

### Provisioners 섹션

다음 부분은 흥미로우며, 나중에 `requirements.sh` 스크립트를 제공함으로써 다루겠습니다:

```
"builders": [
  {
    "type": "vsphere-iso",
```

설치가 완료되면 VM이 재부팅됩니다. Packer가 IP 주소를 감지하면(requirements.sh를 실행하는 데 필요한 VMware Tools 덕분에), `requirements.sh`를 복사하고 실행합니다. 이는 설치 프로세스 이후 VM을 정리(SSH 키 제거, 히스토리 삭제 등)하고 추가 패키지를 설치하는 데 유용한 기능입니다.

### Builders 섹션

vSphere 환경 이외의 대상을 지정하기 위해 하나 이상의 빌더를 선언할 수 있습니다(예: Vagrant 템플릿).

하지만 여기서는 `vsphere-iso` 빌더를 사용합니다.


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

이 빌더를 사용하여 필요한 하드웨어를 구성할 수 있습니다:

```
  이제 자동으로 CPU_hot_plug를 포함하는 것을 다시는 잊지 못할 것입니다!
```

!!! 참고 사항

    이제 CPU_hot_plug를 포함하지 않는 것을 잊지 않을 것입니다. 이제 자동으로 포함됩니다!

디스크, CPU 등을 사용하여 더 멋진 작업을 수행할 수 있습니다. 다른 조정을 하려면 문서를 참조하면 됩니다.

설치를 시작하려면 Rocky Linux의 ISO 이미지가 필요합니다. 다음은 vSphere 콘텐츠 라이브러리에 있는 이미지를 사용하는 예입니다. 물론 ISO를 다른 위치에 저장할 수도 있습니다. vSphere 콘텐츠 라이브러리의 경우, 콘텐츠 라이브러리를 호스트하는 서버에서 ISO 파일의 전체 경로를 얻어야 합니다. 이 예에서는 Synology에서 직접 DSM 탐색기에서 가져옵니다.

```
  "iso_paths": [
    "[datasyno-contentlibrary-mylib] contentlib-a86ad29a-a43b-4717-97e6-593b8358801b/3a381c78-b9df-45a6-82e1-3c07c8187dbe/Rocky-8.4-x86_64-minimal_72cc0cc6-9d0f-4c68-9bcd-06385a506a5d.iso"
  ],
```

그런 다음 설치 프로세스 중에 입력해야 할 완전한 명령을 제공해야 합니다: IP 구성 및 Kickstart 응답 파일의 경로 전달.

!!! note "Note" 

    이 예제는 가장 복잡한 경우인 정적 IP 사용을 사용합니다. DHCP 서버를 사용할 수 있는 경우 프로세스가 훨씬 간단해집니다.

이것은 절차에서 가장 재미있는 부분입니다. 부팅하는 동안 명령이 자동으로 입력되는 것을 보기 위해 생성하는 동안 VMware 콘솔에 가서 감탄할 것이라고 확신합니다.

```
# 시스템 부로더 구성
bootloader --location=mbr --boot-drive=sda
# 파티션 정리 정보
clearpart --all --initlabel --drives=sda
# 디스크 파티션 정보
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root
```

첫 번째 재부팅 후, Packer가 SSH를 통해 서버에 연결합니다. root 사용자 또는 sudo 권한이 있는 다른 사용자를 사용할 수 있지만, 이 사용자는 ks.cfg 파일에 정의된 사용자와 일치해야 합니다.

```
"shutdown_command": "/sbin/halt -h -p",
```

프로세스의 끝에서 VM은 중지되어야 합니다. root 사용자가 아닌 경우 약간 더 복잡하지만, 문서에서 잘 설명되어 있습니다.

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

다음으로 vSphere 구성을 다룹니다. 여기서 중요한 것은 문서 상단의 가정 사항에서 언급된 내용과 같이 홈 디렉토리에 정의된 변수의 사용, 그리고 `insecure_connection` 옵션입니다. 이는 vSphere가 자체 서명된 인증서를 사용하는 경우입니다.

```
"convert_to_template": true,
"create_snapshot": false,
```

마지막으로, vSphere에 중지된 VM을 템플릿으로 변환하도록 요청합니다.

이 단계에서 VM을 그대로 사용할 수도 있으며(템플릿으로 변환하지 않음), 이 경우 스냅샷을 찍을 수도 있습니다. 이 경우 대신 스냅샷을 찍기로 결정할 수 있습니다.

```
# CD-ROM 설치 미디어 사용
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
# 텍스트 설치 사용
text
# 처음 부팅할 때 설정 에이전트를 실행하지 마십시오.
firstboot --disabled
eula --agreed
ignoredisk --only-use=sda
# 키보드 레이아웃
keyboard --vckeymap=us --xlayouts='us'
# 시스템 언어
lang en_US.UTF-8

# 네트워크 정보
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate

# 루트 암호
rootpw mysecurepassword

# 시스템 서비스
selinux --permissive
firewall --enabled
services --enabled="NetworkManager,sshd,chronyd"
# 시스템 시간대
timezone Europe/Paris --isUtc
# 시스템 부로더 구성
bootloader --location=mbr --boot-drive=sda
# 파티션 정리 정보
clearpart --all --initlabel --drives=sda
# 디스크 파티션 정보
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

# 불필요한 펌웨어
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

# Ansible 액세스 관리
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

## The ks.cfg file

위에서 언급한 대로, Anaconda에서 사용할 Kickstart 응답 파일을 제공해야 합니다.

다음은 해당 파일의 예시입니다:

```
# CD-ROM 설치 미디어 사용
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
# 텍스트 설치 사용
text
# 처음 부팅할 때 설정 에이전트를 실행하지 마십시오. firstboot --disabled
eula --agreed
ignoredisk --only-use=sda
# 키보드 레이아웃
keyboard --vckeymap=us --xlayouts='us'
# 시스템 언어
lang en_US.UTF-8

# 네트워크 정보
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate

# 루트 암호
rootpw mysecurepassword

# 시스템 서비스
selinux --permissive
firewall --enabled
services --enabled="NetworkManager,sshd,chronyd"
# 시스템 시간대
timezone Europe/Paris --isUtc
# 시스템 부로더 구성
bootloader --location=mbr --boot-drive=sda
# 파티션 정리 정보
clearpart --all --initlabel --drives=sda
# 디스크 파티션 정보
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

# 불필요한 펌웨어
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

# Ansible 액세스 관리
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

이 경우, 최소한의 iso를 사용하기로 선택했으므로 부팅 또는 DVD 대신 AppStream 리포지토리에만 포함된 필수 설치 패키지만 사용할 수 있습니다.

Packer는 설치 종료를 감지하기 위해 VMware Tools에 의존하며, `open-vm-tools` 패키지는 AppStream 리포지토리에만 존재하므로 설치 프로세스에서 CD-ROM과 이 원격 리포지토리를 모두 사용하도록 지정해야 합니다.

!!! 참고 사항

    외부 리포지토리에 액세스할 수 없는 경우 리포지토리의 미러, squid 프록시 또는 DVD를 사용할 수 있습니다.

```
# CD-ROM 설치 미디어 사용
repo --name="AppStream" --baseurl="http://download.rockylinux.org/pub/rocky/8.4/AppStream/x86_64/os/"
cdrom
```

네트워크 구성으로 이동하겠습니다. 이 예제에서는 DHCP 서버를 사용하지 않으므로 다시 한번 기억해 주세요.

```
# 네트워크 정보
network --bootproto=static --device=ens192 --gateway=192.168.1.254 --ip=192.168.1.11 --nameserver=192.168.1.254,4.4.4.4 --netmask=255.255.255.0 --onboot=on --ipv6=auto --activate
```

설치가 끝날 때 SSH를 통해 Packer에 연결할 사용자를 지정했음을 기억하십시오. 이 사용자와 암호가 일치해야 합니다.

```
# 루트 암호
rootpw mysecurepassword
```

!!! warning "주의"

    예를 들어 Ansible을 사용하여 VM을 배포한 직후 이 암호가 변경되는지 확인하는 한 여기에서 안전하지 않은 암호를 사용할 수 있습니다.

선택한 파티션 구성입니다. 더 복잡한 설정도 가능합니다. Packer에서 정의된 디스크 공간에 맞게 파티션 구성을 정의하고 환경에 정의된 보안 규칙(예: `/tmp`용 별도 파티션)을 준수하도록 설정을 맞출 수 있습니다.

```
# 시스템 부트로더 구성
bootloader --location=mbr --boot-drive=sda
# 파티션 초기화 정보
clearpart --all --initlabel --drives=sda
# 디스크 파티션 정보
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.01 --fstype="lvmpv" --ondisk=sda --grow
volgroup vg_root --pesize=4096 pv.01
logvol /home --fstype="xfs" --size=5120 --name=lv_home --vgname=vg_root
logvol /var --fstype="xfs" --size=10240 --name=lv_var --vgname=vg_root
logvol / --fstype="xfs" --size=10240 --name=lv_root --vgname=vg_root
logvol swap --fstype="swap" --size=4092 --name=lv_swap --vgname=vg_root
```

다음 섹션은 설치될 패키지에 관한 것입니다. "Best practice(최선의 방법)"는 필요한 패키지만 설치하여 공격 표면을 최소화하는 것입니다. 특히 서버 환경에서는 매우 중요합니다.

!!! 참고 사항

    작성자는 설치 프로세스에서 수행할 작업을 제한하고 Packer의 후설치 스크립트에서 필요한 것을 설치하는 것을 선호합니다. 따라서 이 경우에는 최소한의 필수 패키지만 설치합니다.

Packer가 해당 스크립트를 VM에 복사하려면 `openssh-clients` 패키지가 필요한 것 같습니다.

`open-vm-tools`도 Packer가 설치 종료를 감지하는 데 필요하며, 이를 위해 AppStream 리포지토리가 추가되었습니다. 패키지 `perl`과 `perl-File-Temp`은 VMware Tools이 배포 단계에서 필요합니다. 그러나 이로 인해 많은 종속 패키지가 필요하게 됩니다. 또한 미래에 Ansible이 작동하려면 `python3` (3.6)도 필요합니다. (Ansible이나 python을 사용하지 않을 경우에는 제거하십시오!)

```
# 불필요한 펌웨어
-aic94xx-firmware
-atmel-firmware
...
```

패키지를 추가하는 것뿐만 아니라 제거할 수도 있습니다. 하드웨어가 작동할 환경을 제어하므로 필요 없는 firmware도 제거할 수 있습니다.

```
# 불필요한 펌웨어
-aic94xx-firmware
-atmel-firmware
...
```

다음 섹션은 몇 명의 사용자를 추가합니다. 우리 경우에는 암호 없이 공개 키를 가진 `ansible` 사용자를 만드는 것이 흥미로워 보입니다. 이렇게 하면 새로운 VM에는 Ansible 서버에서 접근하여 후설치 작업을 실행할 수 있습니다.

```
# Ansible 액세스 관리
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

이제 `vmtoolsd`(오픈-vm-tools를 관리하는 프로세스)를 활성화하고 시작해야 합니다. VM이 재부팅되면 vSphere에서 IP 주소를 감지합니다.

```
#!/bin/sh -eux

echo "Updating the system..."
dnf -y update

echo "Installing cloud-init..."
dnf -y install cloud-init

# https://bugs.launchpad.net/cloud-init/+bug/1712680 참조
# 및 https://kb.vmware.com/s/article/71264
# cloud-init로 사용자 정의된 가상 머신은 재부팅 후 DHCP로 설정됩니다.
echo "manual_cache_clean: True " > /etc/cloud/cloud.cfg.d/99-manual.cfg

echo "Disable NetworkManager-wait-online.service"
systemctl disable NetworkManager-wait-online.service

# 현재 SSH 키를 정리하여 템플릿 VM이 새 키를 얻도록 합니다.
rm -f /etc/ssh/ssh_host_*

# 우리가 필요로 하지 않는 ~200메가 펌웨어 패키지를 피하십시오
# 이것은 KS 파일에서 수행할 수 없으므로 여기에서 수행합니다.
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

설치 프로세스가 완료되고 VM이 재부팅됩니다.

## The provisioners

기억해 주세요, 우리는 Packer에서 `.sh` 스크립트에 해당하는 Provisioner를 선언했습니다. 이 스크립트는 json 파일과 동일한 서브디렉토리에 저장됩니다.

다양한 유형의 Provisioner가 있으며, Ansible을 사용할 수도 있습니다. 이러한 가능성들을 자유롭게 탐색할 수 있습니다.

이 파일은 완전히 변경할 수 있지만, 이 부분의 자동화 과정에서 무엇을 할 수 있는지의 예시로 제공되는 것입니다. 이 경우 `requirements.sh`라는 스크립트의 내용입니다:

```
#!/bin/sh -eux

echo "Updating the system..." dnf -y update

echo "Installing cloud-init..." dnf -y install cloud-init

# https://bugs.launchpad.net/cloud-init/+bug/1712680 참조
# 및 https://kb.vmware.com/s/article/71264
# cloud-init로 사용자 정의된 가상 머신은 재부팅 후 DHCP로 설정됩니다. echo "manual_cache_clean: True " > /etc/cloud/cloud.cfg.d/99-manual.cfg

echo "Disable NetworkManager-wait-online.service"
systemctl disable NetworkManager-wait-online.service

# 현재 SSH 키를 정리하여 템플릿 VM이 새 키를 얻도록 합니다. rm -f /etc/ssh/ssh_host_*

# 우리가 필요로 하지 않는 ~200메가 펌웨어 패키지를 피하십시오
# 이것은 KS 파일에서 수행할 수 없으므로 여기에서 수행합니다. echo "Removing extra firmware packages"
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

몇 가지 설명이 필요합니다.

```
echo "Installing cloud-init..." dnf -y install cloud-init

# https://bugs.launchpad.net/cloud-init/+bug/1712680 참조
# 및 https://kb.vmware.com/s/article/71264
# cloud-init로 사용자 정의된 가상 머신은 재부팅 후 DHCP로 설정됩니다. echo "manual_cache_clean: True" > /etc/cloud/cloud.cfg.d/99-manual.cfg
```

vSphere는 이제 VMware Tools를 통해 cloud-init을 사용하여 centos8 게스트 머신의 네트워크를 구성하므로 cloud-init을 설치해야 합니다. 그러나 아무것도 하지 않으면 설정은 첫 번째 재부팅 시 적용되며 모든 것이 정상적으로 작동할 것입니다. 그러나 다음 재부팅에서는 cloud-init이 vSphere에서 새 정보를 받지 못하게 됩니다. 이 경우 cloud-init은 자신의 캐시를 자동으로 삭제하지 않도록 지정해야 하며, 따라서 첫 번째 재부팅 시 받은 구성 정보를 재사용하고 각 재부팅 이후에도 계속 사용할 수 있습니다.

이것은 우리가 원하는 동작이 아니므로 캐시를 자동으로 삭제하지 않도록 cloud-init에 지정해야 합니다. 따라서 첫 번째 재부팅과 이후 재부팅할 때마다 받은 구성 정보를 재사용합니다.

이를 위해 `manual_cache_clean: True` 지시문을 사용하여 `/etc/cloud/cloud.cfg.d/99-manual.cfg` 파일을 생성합니다.

!!! 참고사항

    이는 vSphere 게스트 사용자 지정을 통해 네트워크 구성을 다시 적용해야 하는 경우(일반적인 사용에서는 매우 드물어야 함) cloud-init 캐시를 직접 삭제해야 함을 의미합니다.

스크립트의 나머지 부분은 주석 처리되어 더 자세한 설명이 필요하지 않습니다.

[Bento 프로젝트](https://github.com/chef/bento/tree/master/packer_templates)를 확인하여 자동화 프로세스의 이 부분에서 수행할 수 있는 작업에 대한 자세한 아이디어를 얻을 수 있습니다.

## 템플릿 생성

이제 Packer를 실행하고 완전히 자동화된 생성 프로세스가 잘 작동하는지 확인할 시간입니다.

간단히 다음과 같이 명령 줄에 입력하면 됩니다.

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

vSphere로 빠르게 이동하여 작업을 감상할 수 있습니다.

머신이 생성되고 시작되는 것을 볼 수 있으며, 콘솔을 시작하면 자동으로 명령이 입력되고 설치 프로세스가 표시될 것입니다.

생성이 완료되면 vSphere에서 사용할 준비가 된 템플릿을 찾을 수 있습니다.

## 배포 부분

이 문서는 템플릿의 자동 배포 부분을 빠뜨릴 수 없습니다.

이를 위해 `vmware_guest` 모듈을 사용하는 간단한 Ansible 플레이북을 사용합니다.

우리가 제공하는 이 playbook은 당신의 요구 사항과 방식에 맞게 조정해야 합니다.

```
ansible-playbook -i ./inventory/hosts -e '{"comments":"mes commentaires","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"templates-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns
```

위 playbook에서는 ``./vars/credentials.yml`에 민감한 데이터를 저장할 수 있습니다. 물론 먼저`ansible-vault`로 암호화해야 합니다 (특히 git을 사용하는 경우). 모든 것이 변수를 사용하므로 필요에 맞게 쉽게 변경할 수 있습니다.

Rundeck나 Awx와 같은 도구를 사용하지 않는다면 다음과 비슷한 명령 줄로 배포를 시작할 수 있습니다.

```
ansible-playbook -i ./inventory/hosts  -e '{"comments":"my comments","cluster_name":"CS_NAME","esxi_hostname":"ESX_NAME","state":"started","storage_folder":"PROD","datacenter_name":"DC_NAME}","datastore_name":"DS_NAME","template_name":"template-rockylinux8-0.0.1","vm_name":"test_vm","network_name":"net_prod","network_ip":"192.168.1.20","network_gateway":"192.168.1.254","network_mask":"255.255.255.0","memory_mb":"4","num_cpu":"2","domain":"rockylinux.lan","dns_servers":"192.168.1.254","guest_id":"centos8_64Guest"}' ./vmware/create_vm.yml --vault-password-file /etc/ansible/vault_pass.py
```

여기까지 왔으면 Ansible을 사용하여 가상 머신의 최종 구성을 시작할 수 있습니다. 루트 암호를 변경하고 SSH를 보안하며 새 VM을 모니터링 도구 및 IT 인벤토리에 등록하는 것을 잊지 마십시오.

## 요약

지금까지 살펴본 바와 같이 VM을 만들고 배포하기 위한 완전히 자동화된 DevOps 솔루션이 있습니다.

동시에 이는 특히 클라우드 또는 데이터 센터 환경에서 부인할 수 없는 시간 절약을 나타냅니다. 또한 회사의 모든 컴퓨터(서버 및 워크스테이션)에서 표준 준수와 템플릿의 손쉬운 유지 관리/발전을 용이하게 합니다.

## 기타 참조

최신 vSphere, Packer 및 Packer Plugin for vSphere을 사용하여 Rocky Linux 및 다른 운영 체제를 최신화하는 자세한 프로젝트 정보를 보려면 [이 프로젝트](https://github.com/vmware-samples/packer-examples-for-vsphere) 사이트를 방문하십시오. 
