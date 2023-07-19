---
title: LXD 초보자 가이드 - 다중 서버
author: Ezequiel Bruni
contributors: Steven Spencer
update: 28-Feb-2022
---

# 초보자를 위한 LXD로 웹사이트/웹 서버 네트워크 구축

## 소개

좋습니다. 그래서, 우리는 이미 [Rocky Linux에 LXD/LXC를 설치하는 방법에 대한 가이드](../../books/lxd_server/00-toc.md)가 있습니다. 하지만 이 가이드는 자신이 무엇을 하는지 알고 있는 사람이 작성한 것으로, 로컬 네트워크의 물리적 시스템에 컨테이너형 서버 및/또는 애플리케이션 네트워크를 구축하고자 했습니다. 이는 훌륭합니다. 저는 그것의 일부를 훔쳐서 많은 것을 쓸 필요가 없도록 할 것입니다.

그러나 Linux 컨테이너에 대해 방금 들었고 아직 어떻게 작동하는지 이해하지 못하지만 일부 웹 사이트를 호스팅하려는 경우 이 가이드가 적합합니다. *이 튜토리얼에서는 가상 사설 서버 및 클라우드 호스팅을 포함한 모든 시스템에서 LXD 및 LXC를 사용하여 기본 웹사이트를 호스팅하는 방법을 알려줍니다.*

먼저 Linux 컨테이너란 무엇입니까? 글쎄요, 완전 초심자에게는 한 대의 컴퓨터가 실제로 훨씬 더 많은 컴퓨터인 것처럼 보이게 하는 방법입니다. 이러한 "컨테이너"에는 각각 사용자가 선택한 운영 체제의 기본 버전(일반적으로 간소화된 버전)이 들어 있습니다. 각 컨테이너를 개별 서버처럼 사용할 수 있습니다. 한 컨테이너에는 *nginx*, 다른 컨테이너에는 *Apache*를 배치하고 세 번째 컨테이너는 데이터베이스 서버로 사용할 수도 있습니다.

기본적인 이점은 자체 컨테이너에 있는 하나의 앱 또는 웹사이트에 심각한 버그, 해킹 또는 기타 문제가 발생하더라도 나머지 서버나 다른 앱 및 웹사이트에 영향을 미칠 가능성이 낮다는 것입니다. 또한 컨테이너는 스냅샷, 백업 및 복원이 매우 쉽습니다.

이 경우 Rocky Linux인 "호스트" 시스템 위에 있는 컨테이너에서 Rocky Linux를 실행합니다.

개념적으로는 다음과 같습니다.

![하나의 컴퓨터가 여러 대인 것처럼 가장할 수 있는 방법을 보여주는 그래프](../images/lxd-web-server-01.png)

일부 Windows 앱을 실행하기 위해 VirtualBox를 사용해 본 적이 있다면 그와 비슷하지만 그렇지는 않습니다. 가상 머신과 달리 Linux 컨테이너는 각 컨테이너에 대한 전체 하드웨어 환경을 시뮬레이션하지 않습니다. 대신 네트워킹 및 스토리지를 위해 기본적으로 몇 개의 가상 장치를 공유하지만 더 많은 가상 장치를 추가할 수 있습니다. 결과적으로 가상 머신보다 훨씬 적은 오버헤드(처리 능력 및 RAM)가 필요합니다.

도커(Docker는 VM 시스템이 *아닌* 또 다른 컨테이너 기반 시스템임)의 경우 Linux 컨테이너는 익숙한 것보다 덜 일시적입니다. 모든 컨테이너 인스턴스의 모든 데이터는 영구적이며 변경 사항은 백업으로 되돌리지 않는 한 영구적입니다. 즉, 컨테이너를 종료해도 죄가 지워지지 않습니다.

하하.

특히 LXD는 Linux 컨테이너를 설정하고 관리하는 데 도움이 되는 명령줄 애플리케이션입니다. 그것이 오늘 Rocky Linux 호스트 서버에 설치할 것입니다. 하지만 LXC만 언급하는 오래된 문서가 많기 때문에 LXC/LXD를 많이 작성할 예정이며 사람들이 이와 같은 업데이트된 가이드를 쉽게 찾을 수 있도록 노력하고 있습니다.

!!! 참고 사항

    "LXC"라고도 하는 LXD의 선구자 앱이 있었습니다. 현재의 상태로는: LXC는 기술이고 LXD는 앱입니다.

다음과 같이 작동하는 환경을 만들기 위해 둘 다 사용할 것입니다.

![의도된 Linux 컨테이너 구조의 다이어그램](../images/lxd-web-server-02.png)

Specifically, I’m going to show you how to set up simple Nginx and Apache web servers inside of your server containers, and use another container with Nginx as a reverse proxy. 다시 말하지만 이 설정은 로컬 네트워크에서 가상 사설 서버에 이르기까지 모든 환경에서 작동해야 합니다.

!!! 참고 사항

    리버스 프록시는 인터넷(또는 로컬 네트워크)에서 들어오는 연결을 가져와 올바른 서버, 컨테이너 또는 앱으로 라우팅하는 프로그램입니다. HaProxy와 같은 이 작업을 위한 전용 도구도 있지만 이상하게도 Nginx가 훨씬 사용하기 쉽습니다.

## 전제 조건 및 가정

* Linux 명령줄 인터페이스에 대한 기본적인 지식이 필요합니다. 원격 서버에 LXC/LXD를 설치하는 경우 SSH 사용 방법을 알아야 합니다.
* Rocky Linux가 이미 실행 중인 물리적 또는 가상의 인터넷 연결 서버가 필요합니다.
* 두 개의 도메인 이름이 A 레코드로 서버를 바로 가리킵니다.
    * 두 개의 하위 도메인도 마찬가지로 작동해야합니다. 와일드카드 하위 도메인 레코드가 있는 도메인 하나 또는 사용자 지정 LAN 도메인... 그림을 얻습니다.
* 명령줄 텍스트 편집기. *nano*도 가능하고 *micro*가 제가 가장 좋아하는 것이지만 편안하게 사용할 수 있는 것을 사용하세요.
* 루트 사용자로 이 전체 튜토리얼을 따를 수는 *있지만* 그렇게 해서는 안 됩니다. LXC/LXD 초기 설치 후 LXD 명령을 실행하기 위한 권한 없는 사용자를 생성하는 방법을 안내해 드립니다.
* 이제 우리는 컨테이너의 기반이 될 Rocky Linux 이미지를 갖게 되었으며 정말 훌륭합니다.
* Nginx 또는 Apache에 익숙하지 않은 경우 전체 프로덕션 서버를 시작하고 실행하려면 다른 가이드를 확인해야 **합니다**. 걱정하지 마세요. 아래에 링크하겠습니다.

## 호스트 서버 환경 설정

그래서 여기에 귀하와 저를 위해 다른 LXD 가이드의 일부를 복사하여 붙여넣을 것입니다. 이 부분의 대부분에 대한 모든 크레딧은 Steven Spencer에게 돌아갑니다.

### EPEL 저장소 설치

LXD에는 다음을 사용하여 쉽게 설치할 수 있는 EPEL(Extra Packages for Enterprise Linux) 리포지토리가 필요합니다.

```bash
dnf install epel-release
```

설치가 완료되면 업데이트를 확인하십시오.

```bash
dnf update
```

위의 업데이트 프로세스 중에 커널 업데이트가 있었다면 서버를 재부팅하십시오.

### snapd 설치

LXD는 Rocky Linux용 snap\* 패키지에서 설치해야 합니다. 이러한 이유로 다음을 사용하여 snapd를 설치해야 합니다.

```bash
dnf install snapd
```

이제 서버가 재부팅될 때 자동으로 시작되도록 snapd 서비스를 활성화하고 지금 실행을 시작합니다.

```bash
systemctl enable snapd
```

다음을 실행합니다.

```bash
systemctl start snapd
```

여기에서 계속하기 전에 서버를 재부팅하십시오. `reboot` 명령을 사용하거나 VPS/클라우드 호스팅 관리자 패널에서 이 작업을 수행할 수 있습니다.

\* *snap*은 필요한 모든 의존성과 함께 제공되고 거의 모든 Linux 시스템에서 실행될 수 있도록 응용 프로그램을 패키징하는 방법입니다.

### LXD 설치

LXD를 설치하려면 snap 명령을 사용해야 합니다. 이 시점에서 우리는 설치만 하고 설정은 하지 않습니다:

```bash
snap install lxd
```

물리적("베어 메탈") 서버에서 LXD를 실행하는 경우 다른 가이드로 돌아가서 "환경 설정" 섹션을 읽어야 합니다. 커널과 파일 시스템 등에 대한 유용한 정보가 많이 있습니다.

가상 환경에서 LXD를 실행하는 경우 재부팅하고 계속 읽으십시오.

### LXD 초기화

이제 환경이 모두 설정되었으므로 LXD를 초기화할 준비가 되었습니다. 이것은 LXD 인스턴스를 시작하고 실행하기 위해 일련의 질문을 하는 자동화된 스크립트입니다.

```bash
lxd init
```

다음은 필요한 경우 약간의 설명과 함께 스크립트에 대한 질문과 답변입니다.

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

클러스터링에 관심이 있다면 [여기](https://linuxcontainers.org/lxd/docs/master/clustering/)에서 추가 조사를 해보세요. 그렇지 않으면 "Enter"를 눌러 기본 옵션을 수락하십시오.

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

 기본값을 수락합니다.

```
Name of the new storage pool [default=default]: server-storage
```

스토리지 풀의 이름을 선택하십시오. 서버 LXD가 실행 중인 이름을 따서 이름을 짓고 싶습니다. (스토리지 풀은 기본적으로 컨테이너용으로 따로 설정된 하드 드라이브 공간입니다.)

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]: lvm
```

위의 질문은 스토리지에 사용할 파일 시스템 종류에 관한 것이며 기본값은 시스템에서 사용 가능한 항목에 따라 다를 수 있습니다. 베어메탈 서버에 있고 ZFS를 사용하려면 위에 링크된 가이드를 다시 참조하세요.

가상 환경에서 나는 "LVM"이 잘 작동한다는 것을 알았고, 보통 내가 사용하는 것입니다. 다음 질문에서 기본값을 수락할 수 있습니다.

```
Create a new LVM pool? (yes/no) [default=yes]:
```

전체 스토리지 풀에 사용하려는 특정 하드 드라이브나 파티션이 있는 경우 다음에 "yes"라고 쓰십시오. VPS에서 이 모든 작업을 수행하는 경우 "no"를 선택해야 *해야 합니다*.

```
`Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:`
```

MAAS(Metal As A Service)는 이 문서의 범위를 벗어납니다. 이 다음 비트에 대한 기본값을 수락합니다.

```
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

그리고 더 많은 기본값이 있습니다. 모두 좋습니다.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:

What should the new bridge be called? [default=lxdbr0]: `

What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

LXD 컨테이너에서 IPv6를 사용하려면 다음 옵션을 켤 수 있습니다. 그것은 당신에게 달려 있지만 대부분 그럴 필요는 없습니다. 제 생각에는. 게으름 때문에 그대로 두는 경향이 있습니다.

```
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

이는 서버를 쉽게 백업하는 데 필요하며 다른 컴퓨터에서 LXD 설치를 관리할 수 있습니다. 모든 것이 당신에게 좋게 들리면 여기에 "yes"라고 대답하십시오.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

마지막 질문에 예라고 대답했다면 여기에서 기본값을 사용하십시오.

```
Address to bind LXD to (not including port) [default=all]:

Port to bind LXD to [default=8443]:
```

이제 신뢰 암호를 묻는 메시지가 나타납니다. 이것이 다른 컴퓨터 및 서버에서 LXC 호스트 서버에 연결하는 방법이므로 사용자 환경에 적합한 것으로 설정하십시오. 이 암호를 암호 관리자와 같은 안전한 위치에 저장하십시오.

```
Trust password for new clients:

Again:
```

그런 다음 여기서부터 계속 기본값을 사용합니다.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]

Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

#### 사용자 권한 설정

계속하기 전에 "lxdadmin" 사용자를 생성하고 필요한 권한이 있는지 확인해야 합니다. 루트 명령에 액세스하기 위해 _sudo_를 사용할 수 있으려면 "lxdadmin" 사용자가 필요하며 "lxd" 그룹의 구성원이어야 합니다. 사용자를 추가하고 두 그룹의 구성원인지 확인하려면 다음을 실행하십시오.

```bash
useradd -G wheel,lxd lxdadmin
```

그런 다음 비밀번호를 설정합니다.

```bash
passwd lxdadmin
```

다른 암호와 마찬가지로 안전한 위치에 저장하십시오.

## 방화벽 설정

컨테이너에 대해 다른 작업을 수행하기 전에 외부에서 프록시 서버에 액세스할 수 있어야 합니다. 방화벽이 포트 80(HTTP/웹 트래픽에 사용되는 기본 포트) 또는 포트 443(HTTPS/*보안* 웹 트래픽에 사용됨)을 차단하는 경우 서버 측면에서 많은 작업을 수행하지 않을 것입니다.

The other LXD guide will show you how to do this with the *iptables* firewall, if that’s what you want to do. 저는 CentOS 기본 방화벽인 *firewalld*를 사용하는 경향이 있습니다. 이것이 바로 우리가 이번에 할 일입니다.

`firewalld` is configured via the `firewall-cmd` command. 포트를 열기 전에 **가장 먼저 해야 할 일**은 컨테이너에 IP 주소가 자동으로 할당될 수 있는지 확인하는 것입니다.

```bash
firewall-cmd --zone=trusted --permanent --change-interface=lxdbr0
```

!!! !!!

    마지막 단계를 수행하지 않으면 컨테이너가 인터넷 또는 서로 간에 제대로 액세스할 수 없습니다. 이것은 미친 듯이 필수적이며, 그것을 알면 좌절의 *시대**를 구할 수 있습니다.

이제 새 포트를 추가하려면 다음을 실행하십시오.

```bash
firewall-cmd --permanent --zone=public --add-port=80/tcp
```

차근차근 알아보겠습니다.

* `-–permanent` 플래그는 방화벽이 다시 시작될 때마다 그리고 서버 자체가 다시 시작될 때 이 구성이 사용되는지 확인하도록 방화벽에 지시합니다.
* `–-zone=public`은 모든 사람으로부터 이 포트로 들어오는 연결을 받아들이도록 방화벽에 지시합니다.
* 마지막으로 `–-add-port=80/tcp`는 방화벽이 전송 제어 프로토콜을 사용하는 한 포트 80을 통해 들어오는 연결을 수락하도록 지시합니다. 이 경우 원하는 것입니다.

HTTPS 트래픽에 대한 프로세스를 반복하려면 명령을 다시 실행하고 번호를 변경하십시오.

```bash
firewall-cmd --permanent --zone=public --add-port=443/tcp
```

이러한 구성은 문제를 강제로 적용할 때까지 적용되지 않습니다. 이렇게 하려면 다음과 같이 *firewalld*에 구성을 다시 로드하도록 지시합니다.

```bash
firewall-cmd --reload
```

이제 이것이 작동하지 않을 가능성이 매우 적습니다. 드문 경우지만 *firewalld*가 이전의 끄고 다시 켜는 방법을 사용하도록 하십시오.

```bash
systemctl restart firewalld
```

포트가 제대로 추가되었는지 확인하려면 `firewall-cmd --list-all`을 실행하세요. 적절하게 구성된 방화벽은 다음과 같이 보일 것입니다(로컬 서버에 몇 개의 추가 포트가 열려 있으므로 무시하십시오).

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 81/tcp 444/tcp 15151/tcp 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

이것이 방화벽 측면에서 필요한 모든 것입니다.

## 컨테이너 설정

Actually managing containers is pretty easy. 명령에 따라 전체 컴퓨터를 구성하고 마음대로 시작하거나 중지할 수 있다고 생각하십시오. 호스트 서버와 마찬가지로 "컴퓨터"에 로그인하여 원하는 명령을 실행할 수도 있습니다.

!!! 참고 사항

    여기서부터 모든 명령은 `lxdadmin` 사용자 또는 사용자가 호출하기로 결정한 대로 실행해야 하지만 일부는 임시 루트 권한을 위해 *sudo*를 사용해야 합니다.

이 튜토리얼에서는 3개의 컨테이너가 필요합니다. 리버스 프록시 서버, 테스트 Nginx 서버, 테스트 Apache 서버가 모두 Rocky 기반 컨테이너에서 실행됩니다.

어떤 이유로 완전한 권한을 가진 컨테이너가 필요한 경우(대부분 그렇지 않은 경우) 이러한 모든 명령을 루트로 실행할 수 있습니다.

이 튜토리얼에서는 3개의 컨테이너가 필요합니다.

"proxy-server"(웹 트래픽을 다른 두 컨테이너로 보낼 컨테이너의 경우), "nginx-server" 및 "apache-server"라고 합니다. 맞습니다, *nginx* 및 *apache* 기반 서버 모두에 역방향 프록시를 사용하는 방법을 알려드리겠습니다. *docker* 또는 NodeJS 앱과 같은 것들은 내가 스스로 알아낼 때까지 기다릴 수 있습니다.

컨테이너의 기반이 될 이미지를 파악하는 것부터 시작하겠습니다. 이 튜토리얼에서는 Rocky Linux를 사용하고 있습니다. 예를 들어 Alpine Linux를 사용하면 컨테이너가 훨씬 작아질 수 있지만(스토리지가 문제인 경우) 이는 이 특정 문서의 범위를 벗어납니다.

### 원하는 이미지 찾기

다음은 Rocky Linux로 컨테이너를 시작하는 짧고 짧은 방법입니다.

```bash
lxc launch images:rockylinux/8/amd64 my-container
```

물론 끝에 있는 "my-container" 비트는 원하는 컨테이너 이름으로 이름을 바꿔야 합니다. “proxy-server”. Raspberry Pi와 같은 장치에서 이 모든 작업을 수행하는 경우 "/amd64" 부분을 "arm64"로 변경해야 합니다.

이제 긴 버전이 있습니다. 원하는 이미지를 찾으려면 이 명령을 사용하여 기본 LXC 리포지토리에서 사용 가능한 모든 이미지를 나열할 수 있습니다.

```bash
lxc image list images: | more
```

그런 다음 "Enter"를 눌러 방대한 이미지 목록을 아래로 스크롤하고 "Ctrl-C"를 눌러 목록 보기 모드를 종료합니다.

또는 생활을 단순화하고 다음과 같이 원하는 Linux 종류를 지정할 수 있습니다.

```bash
lxc image list images: | grep rockylinux
```

그러면 다음과 같이 훨씬 더 짧은 목록이 출력됩니다.

```bash
| rockylinux/8 (3 more)                    | 4e6beda70200 | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | VIRTUAL-MACHINE | 612.19MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8 (3 more)                    | c04dd2bcf20b | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | CONTAINER       | 127.34MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/arm64 (1 more)              | adc0561d6330 | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 124.03MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | 2591d9716b04 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | CONTAINER       | 147.04MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | c963253fcea9 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | VIRTUAL-MACHINE | 630.56MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud/arm64                 | 9f49e80afa5b | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 143.15MB  | Jan 29, 2022 at 12:00am (UTC) |
```

### 컨테이너 만들기

!!! 참고 사항

    아래는 이러한 모든 컨테이너를 만드는 빠른 방법입니다. 프록시 서버 컨테이너를 만들기 전에 기다릴 수 있습니다. 시간을 절약할 수 있는 요령이 아래에서 보여 드리겠습니다.

원하는 이미지를 찾으면 위와 같이 `lxc launch` 명령을 사용합니다. 이 자습서에서 원하는 컨테이너를 만들려면 다음 명령을 연속적으로 실행합니다(필요에 따라 수정).

```bash
lxc launch images:rockylinux/8/amd64 proxy-server
lxc launch images:rockylinux/8/amd64 nginx-server
lxc launch images:rockylinux/8/amd64 apache-server
```

각 명령을 실행할 때 컨테이너가 생성되었고 심지어 시작되었다는 알림을 받아야 합니다. 그런 다음 모든 항목을 확인하고 싶을 것입니다.

다음 명령을 실행하여 모두 실행 중인지 확인합니다.

```bash
lxc list
```

이렇게 하면 다음과 같은 출력이 제공됩니다(그러나 IPv6를 사용하기로 선택한 경우 훨씬 더 많은 텍스트가 됩니다).

```bash
+---------------+---------+-----------------------+------+-----------+-----------+
|     NAME      |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+---------------+---------+-----------------------+------+-----------+-----------+
| proxy-server  | RUNNING | 10.199.182.231 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| nginx-server  | RUNNING | 10.199.182.232 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| apache-server | RUNNING | 10.199.182.233 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
```

#### 컨테이너 네트워킹에 대한 설명

따라서 이 가이드의 시작 부분에 링크된 다른 가이드에는 Macvlan과 작동하도록 LXC/LXD를 설정하는 방법에 대한 전체 자습서가 있습니다. 이는 로컬 서버를 실행 중이고 각 컨테이너가 로컬 네트워크에서 볼 수 있는 IP 주소를 갖기를 원할 때 특히 유용합니다.

VPS에서 실행할 때 해당 옵션이 없는 경우가 많습니다. 실제로 작업할 수 있는 단일 IP 주소만 있을 수 있습니다. 별것 아닙니다. 기본 네트워킹 구성은 이러한 종류의 제한을 수용하도록 설계되었습니다. 위에서 지정한 대로 `lxd init` 질문에 답하면 모든 것이 *반드시* 처리되어야 합니다.

기본적으로 LXD는 브리지(일반적으로 "lxdbr0"라고 함)라는 가상 네트워크 장치를 생성하고 모든 컨테이너는 기본적으로 해당 브리지에 연결됩니다. 이를 통해 호스트의 기본 네트워크 장치(이더넷, Wi-Fi 또는 VPS에서 제공하는 가상 네트워크 장치)를 통해 인터넷에 연결할 수 있습니다. 더 중요한 것은 모든 컨테이너가 서로 연결할 수 있다는 것입니다.

To ensure this inter-container connection, *every container gets an internal domain name*. 기본적으로 이것은 컨테이너의 이름에 ".lxd"를 더한 것입니다. 따라서 "proxy-server" 컨테이너는 "proxy-server.lxd"에 있는 다른 모든 컨테이너에서 사용할 수 있습니다. 하지만 *정말* 알아야 할 중요한 사항이 있습니다: **기본적으로 ".lxd" 도메인은 컨테이너 내부에서만 사용할 수 있습니다.**

호스트 OS(또는 다른 곳)에서 `ping proxy-server.lxd`를 실행하면 아무 것도 얻을 수 없습니다. 그러나 이러한 내부 도메인은 나중에 매우 편리하게 사용할 수 있습니다.

기술적으로 이것을 변경하고 컨테이너의 내부 도메인을 호스트에서 사용할 수 있도록 할 수 있습니다. 하지만 실제로는 알아내지 못했습니다. 어쨌든 리버스 프록시 서버를 컨테이너에 두는 것이 가장 좋을 것이므로 쉽게 스냅샷을 작성하고 백업할 수 있습니다.

### 컨테이너 관리

계속 진행하기 전에 알아야 할 몇 가지 사항:

#### Starting & Stopping

다음 명령을 사용하여 필요에 따라 모든 컨테이너를 시작, 중지 및 다시 시작할 수 있습니다.

```bash
lxc start mycontainer
lxc stop mycontainer
lxc restart mycontainer
```

Linux도 가끔 재부팅이 필요합니다. 그리고 실제로 다음 명령을 사용하여 모든 컨테이너를 한 번에 시작, 중지 및 다시 시작할 수 있습니다.

```bash
lxc start --all
lxc stop --all
lxc restart --all
```

이 `restart --all` 옵션은 좀 더 모호한 임시 버그에 매우 유용합니다.

#### 컨테이너 내부에서 작업 수행

두 가지 방법으로 컨테이너 내부의 운영 체제를 제어할 수 있습니다. 호스트 OS에서 컨테이너 내부의 명령을 실행하거나 셸을 열 수 있습니다.

이것이 내가 의미하는 바입니다. 컨테이너 내에서 명령을 실행하려면 *Apache*를 설치하려면 다음과 같이 `lxc exec`를 사용하면 됩니다.

```bash
lxc exec my-container dnf install httpd -y
```

이렇게 하면 *Apache*가 자체적으로 설치되고 호스트 터미널에서 명령의 출력을 볼 수 있습니다.

쉘을 열려면(루트로 원하는 모든 명령을 실행할 수 있음) 다음을 사용하십시오.

```bash
lxc exec my-container bash
```

저장 공간보다 편리함을 중시하고 모든 컨테이너에 *fish*와 같은 대체 셸을 설치한 경우 다음과 같이 명령을 변경하면 됩니다.

```bash
lxc exec my-container fish
```

거의 모든 경우에 루트 계정과 `/root` 디렉터리에 자동으로 배치됩니다.

마지막으로 쉘을 컨테이너로 연 경우 쉘을 종료하는 것과 동일한 방식으로 간단한 `exit` 명령을 사용하여 종료합니다.

#### 컨테이너 복사

이제 최소한의 노력으로 복제하려는 컨테이너가 있는 경우 새 컨테이너를 시작하고 모든 기본 애플리케이션을 다시 설치할 필요가 없습니다. 그것은 어리석은 일입니다. 그냥 실행하십시오:

```bash
lxc copy my-container my-other-container
```

"my-container"의 정확한 복사본이 "my-other-container"라는 이름으로 생성됩니다. 하지만 자동으로 시작되지 않을 수 있으므로 새 컨테이너의 구성을 원하는 대로 변경한 후 다음을 실행하세요.

```bash
lxc start my-other-container
```

이 시점에서 컨테이너의 내부 호스트 이름을 변경하는 것과 같은 몇 가지 사항을 변경할 수 있습니다.

#### 스토리지 구성 & CPU Limits

LXC/LXD는 일반적으로 컨테이너가 가져오는 저장 공간의 양을 정의하고 일반적으로 리소스를 관리하지만 이를 제어할 수 있습니다. 컨테이너를 작게 유지하는 것이 걱정된다면 `lxc config` 명령을 사용하여 필요에 따라 축소 및 확장할 수 있습니다.

다음 명령은 컨테이너에서 2GB의 "소프트" 제한을 설정합니다. 소프트 제한은 실제로 "최소 스토리지"에 가깝고 컨테이너는 사용 가능한 경우 더 많은 스토리지를 사용합니다. 항상 그렇듯이 "my-container"를 실제 컨테이너의 이름으로 변경합니다.

```bash
lxc config set my-container limits.memory 2GB
```

다음과 같이 하드 제한을 설정할 수 있습니다.

```bash
lxc config set my-container limits.memory.enforce 2GB
```

그리고 특정 컨테이너가 서버에서 사용할 수 있는 모든 처리 능력을 차지할 수 없도록 하려면 이 명령으로 액세스할 수 있는 CPU 코어를 제한할 수 있습니다. 적절하다고 생각되는 대로 마지막에 CPU 코어 수를 변경하기만 하면 됩니다.

```bash
lxc config set my-container limits.cpu 2
```

#### 컨테이너 삭제(및 이를 방지하는 방법)

마지막으로 다음 명령을 실행하여 컨테이너를 삭제할 수 있습니다.

```bash
lxc delete my-container
```

실행 중인 컨테이너는 삭제할 수 없으므로 먼저 중지하거나 `-–force` 플래그를 사용하여 해당 부분을 건너뛸 수 있습니다.

```bash
lxc delete my-container --force
```

이제 탭 명령 완성, 사용자 오류 및 대부분의 키보드에서 "d"가 "s" 옆에 있다는 사실 덕분에 실수로 컨테이너를 삭제할 수 있습니다. 이것은 비즈니스에서 THE BIG OOPS로 알려져 있습니다. (아니면 적어도 여기에서 끝나면 THE BIG OOPS로 알려질 것입니다.)

이를 방지하기 위해 다음 명령을 사용하여 모든 컨테이너를 "보호"되도록 설정할 수 있습니다(삭제 프로세스에 추가 단계가 필요함).

```bash
lxc config set my-container security.protection.delete true
```

컨테이너 보호를 해제하려면 명령을 다시 실행하되 "true"를 "false"로 변경하십시오.

## 서버 설정

자, 이제 컨테이너가 실행 중이므로 필요한 것을 설치할 차례입니다. 먼저 다음 명령으로 모든 항목이 업데이트되었는지 확인합니다(아직 생성하지 않은 경우 "proxy-server" 컨테이너 건너뛰기).

```bash
lxc exec proxy-server dnf update -y
lxc exec nginx-server dnf update -y
lxc exec apache-server dnf update -y
```

그런 다음 각 컨테이너로 이동하여 크래킹하십시오.

또한 모든 컨테이너에 대해 텍스트 편집기가 필요합니다. 기본적으로 Rocky Linux는 *vi*와 함께 제공되지만 삶을 단순화하려면 *nano*가 적합합니다. 열기 전에 각 컨테이너에 설치할 수 있습니다.

```bash
lxc exec proxy-server dnf install nano -y
lxc exec nginx-server dnf install nano -y
lxc exec apache-server dnf install nano -y
```

앞으로 저는 모든 텍스트 편집기 관련 명령에서 *nano*를 사용하겠지만 당신도 그렇게 할 것입니다.

### Apache 웹사이트 서버

우리는 학습 및 테스트 목적으로 이것을 짧게 유지할 것입니다. 전체 Apache 가이드에 대한 링크는 아래를 참조하십시오.

먼저 컨테이너에 셸을 엽니다. 기본적으로 컨테이너는 루트 계정으로 연결됩니다. 실제 프로덕션 목적을 위해 특정 웹 서버 사용자를 만들고 싶을 수도 있지만 우리의 목적으로는 괜찮습니다.

```bash
lxc exec apache-server bash
```

로그인한 후 *Apache*를 쉬운 방법으로 설치하십시오.

```bash
dnf install httpd
```

이제, 당신은 여기서부터 우리의 [Apache 웹 서버 다중 사이트 설정 가이드](../web/apache-sites-enabled.md)를 따를 수 있지만, 그것은 사실 우리의 목적을 위한 다소 지나친 작업입니다 우리는 일반적으로 이와 같은 컨테이너화된 환경에서 여러 웹사이트에 대해 Apache를 설정하고 싶지 않습니다. 결국 컨테이너의 요점은 관심사의 분리입니다.

또한 SSL 인증서는 프록시 서버에서 진행되므로 간단하게 유지하겠습니다.

*Apache*가 설치되면 실행 중이고 재부팅 시 계속 실행될 수 있는지 확인합니다.

```bash
systemctl enable --now httpd
```

`--now` 플래그를 사용하면 실제 서버를 시작하는 명령을 건너뛸 수 있습니다. 참고로 다음과 같습니다.

```bash
systemctl start httpd
```

서버 호스트에 `curl`이 설치되어 있는 경우 다음을 사용하여 기본 웹 페이지가 실행 중인지 확인할 수 있습니다.

```bash
curl [container-ip-address]
```

`lxc 목록`을 사용하여 모든 컨테이너 IP를 볼 수 있음을 기억하십시오. 모든 컨테이너에 curl을 설치하면 다음을 *실행*할 수 있습니다.

```bash
curl localhost
```

#### 프록시 서버에서 실제 사용자 IP 가져오기

이제 리버스 프록시를 사용하기 위해 Apache를 준비하기 위해 수행해야 하는 단계가 있습니다. 기본적으로 사용자의 실제 IP 주소는 웹 서버 컨테이너의 서버에서 기록하지 않습니다. 일부 웹 앱은 검토, 금지 및 문제 해결과 같은 작업을 위해 사용자 IP가 필요하기 때문에 해당 IP 주소를 통과해야 합니다.

방문자의 IP 주소가 프록시 서버를 통과하도록 하려면 프록시 서버의 올바른 설정(나중에 다룰 것임)과 Apache 서버의 간단한 구성 파일의 두 부분이 필요합니다.

이러한 구성 파일의 템플릿에 대한 Linode 및 [자체 LXD 가이드](https://www.linode.com/docs/guides/beginners-guide-to-lxd-reverse-proxy)에 큰 감사를 드립니다.

새 구성 파일을 만듭니다.

```bash
nano /etc/httpd/conf.d/real-ip.conf
```

그리고 다음 텍스트를 추가합니다.

```
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy proxy-server.lxd
```

필요한 경우 `proxy-server.lxd`를 실제 프록시 컨테이너라고 부르는 것으로 변경해야 합니다. **아직 Apache 서버를 다시 시작하지 마십시오.** 우리가 추가한 구성 파일은 프록시 서버를 가동하고 실행할 *때까지* 문제를 일으킬 수 있습니다.

지금은 셸을 종료하고 Nginx 서버에서 시작하겠습니다.

!!! 참고 사항

    이 기술이 *작동*하는 동안(귀하의 웹 앱과 웹사이트는 사용자의 실제 IP를 얻습니다), Apache의 자체 액세스 로그는 *올바른 IP를 표시하지 않습니다.* 일반적으로 리버스 프록시가 있는 컨테이너의 IP를 표시합니다. 이것은 분명히 Apache가 사물을 기록하는 방법에 대한 문제입니다.
    
    저는 Google에서 많은 솔루션을 찾았지만 그 중 어느 것도 실제로 저에게 효과가 없었습니다. 나보다 훨씬 똑똑한 사람이 있는지 이 공간을 살펴보세요. 그동안 IP 주소를 직접 확인해야 하는 경우 프록시 서버의 액세스 로그를 확인하거나 설치 중인 웹 앱의 로그를 확인할 수 있습니다.

### Nginx 웹사이트 서버

다시 말하지만, 우리는 이것을 짧게 유지하고 있습니다. 프로덕션 환경에서 Nginx의 최신(권장) 버전을 사용하려면 [Nginx 설치 초보자 가이드](../web/nginx-mainline.md)를 확인하세요. 여기에는 전체 설치 가이드와 서버 구성을 위한 몇 가지 모범 사례가 포함됩니다.

테스트 및 학습을 위해 Nginx를 정상적으로 *설치할 수 있지만* "mainline" 브랜치라고 하는 최신 버전을 설치하는 것이 좋습니다.

먼저 컨테이너의 셸에 로그인합니다.

```bash
lxc exec nginx-server bash
```

그런 다음 최신 버전의 Nginx를 설치할 수 있도록 `epel-release` 리포지토리를 설치합니다.

```bash
dnf install epel-release
```

완료되면 다음을 사용하여 최신 버전의 Nginx를 검색합니다.

```bash
dnf module list nginx
```

그러면 다음과 같은 목록이 표시됩니다.

```bash
Rocky Linux 8 - AppStream
Name       Stream        Profiles        Summary
nginx      1.14 [d]      common [d]      nginx webserver
nginx      1.16          common [d]      nginx webserver
nginx      1.18          common [d]      nginx webserver
nginx      1.20          common [d]      nginx webserver
nginx      mainline      common [d]      nginx webserver
```

당신이 원하는 것은 다음과 같습니다: 메인라인 브랜치입니다. 다음 명령으로 모듈을 활성화합니다.

```bash
dnf enable module nginx:mainline
```

이 작업을 수행할 것인지 묻는 메시지가 표시되므로 평소와 같이 `Y`를 선택하십시오. 그런 다음 기본 명령을 사용하여 Nginx를 설치합니다.

```bash
dnf install nginx
```

그런 다음 Nginx를 활성화하고 시작합니다.

```bash
dnf enable --now nginx
```

!!! 참고 사항

    프록시 컨테이너를 생성하기 전에 기다리라고 말했던 것을 기억하십니까? 이유는 다음과 같습니다. 이 시점에서 "nginx-server" 컨테이너를 그대로 두고 복사하여 "proxy-server" 컨테이너를 만들어 시간을 절약할 수 있습니다.

    ```bash
    lxc copy nginx-server proxy-server
    ```


    `lxc start proxy-server`로 프록시 컨테이너를 시작했는지 확인하고 아래 설명된 대로 컨테이너에 프록시 포트를 추가합니다.

다시 말하지만 다음을 사용하여 컨테이너가 호스트에서 작동하는지 확인할 수 있습니다.

```bash
curl [your-container-ip]
```

#### 프록시 서버에서 실제 사용자 IP 가져오기(다시)

이번에는 로그가 *작동해야 합니다*. 해야 합니다. 이를 위해 `/etc/nginx/conf.d`에 매우 유사한 파일을 넣습니다.

```bash
nano /etc/nginx/conf.d/real-ip.conf
```

그런 다음 이 텍스트를 입력합니다.

```bash
real_ip_header    X-Real-IP;
set_real_ip_from  proxy-server.lxd;
```

마지막으로 **아직 서버를 다시 시작하지 마세요**. 다시 말하지만 해당 구성 파일은 프록시 서버가 설정될 때까지 문제를 일으킬 수 있습니다.

### 리버스 프록시 서버

두 개의 도메인 또는 하위 도메인이 필요하다고 말한 것을 기억하십니까? 이것이 그들이 필요한 곳입니다. 이 튜토리얼에서 사용하는 하위 도메인은 다음과 같습니다.

* apache.server.test
* nginx.server.test

필요에 따라 모든 파일과 지침에서 변경하십시오.

"nginx-server" 컨테이너에서 "proxy-server" 컨테이너를 복사하고 여기에 프록시 장치를 추가한 경우 셸로 바로 이동합니다. 이전에 컨테이너를 만든 경우 "proxy-server" 컨테이너에 Nginx를 설치하기 위한 모든 단계를 반복해야 합니다.

일단 설치되고 제대로 실행된다는 것을 알게 되면 선택한 도메인에서 실제 웹 사이트 서버로 트래픽을 보내도록 몇 가지 구성 파일을 설정하기만 하면 됩니다.

그렇게 하기 전에 내부 도메인을 통해 두 서버에 모두 액세스할 수 있는지 확인하십시오.

```bash
curl apache-server.lxd
curl nginx-server.lxd
```

이 두 명령이 기본 서버 시작 페이지의 HTML을 터미널에 로드하면 모든 것이 올바르게 설정된 것입니다.

#### *필수 단계:* "proxy-server" 컨테이너가 모든 수신 서버 트래픽을 처리하도록 구성

다시 말하지만 나중에 실제로 프록시 서버를 만들 때 이 작업을 수행할 수 있지만 필요한 지침은 다음과 같습니다.

방화벽에서 포트 80과 443을 열었을 때를 기억하십니까? 여기에서 "proxy-server" 컨테이너가 해당 포트를 수신하고 해당 포트로 향하는 모든 트래픽을 수신하도록 합니다.

다음 두 명령을 연속으로 실행하십시오.

```bash
lxc config device add proxy-server myproxy80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxy-server myproxy443 proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Let’s break that down. 각 명령은 가상 "장치"를 프록시 서버 컨테이너에 추가합니다. 이러한 장치는 호스트 OS의 포트 80 및 포트 443에서 수신하도록 설정되어 있으며 컨테이너의 포트 80 및 포트 443에 바인딩됩니다. 각 장치에는 이름이 필요하므로 "myproxy80" 및 "myproxy443"을 선택했습니다.

The “listen” option is the port on the host OS, and if I’m not mistaken, 0.0.0.0 is the IP address for the host on the “lxdbr0” bridge. "연결" 옵션은 연결되는 로컬 IP 주소 및 포트입니다.

!!! 참고 사항

    이러한 장치가 설정되면 확실히 하기 위해 모든 컨테이너를 재부팅해야 합니다.

이러한 가상 장치는 고유해야 합니다. 일반적으로 "myport80" 장치는 현재 실행 중인 다른 컨테이너에 추가하지 않는 것이 좋습니다. 다른 장치라고 해야 합니다.

*마찬가지로 한 번에 하나의 컨테이너만 특정 호스트 OS 포트에서 수신 대기할 수 있습니다.*

#### Apache 서버로 트래픽 전달

"proxy-server" 컨테이너에서 `/etc/nginx/conf.d/`에 `apache-server.conf`라는 구성 파일을 만듭니다.

```bash
nano /etc/nginx/conf.d/apache-server.conf
```

그런 다음 이 테스트를 붙여넣고 필요에 따라 도메인 이름을 변경한 후 저장합니다.

```
upstream apache-server {
    server apache-server.lxd:80;
}

server {
    listen 80 proxy_protocol;
    listen [::]:80 proxy_protocol;
    server_name apache.server.test; #< Your domain goes here

    location / {
        proxy_pass http://apache-server;

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

조금 분석해 보겠습니다.

* `upstream` 섹션은 리버스 프록시가 모든 트래픽을 보낼 위치를 정확히 정의합니다. 특히 "apache-server" 컨테이너의 내부 도메인 이름인 `apache-server.lxd`로 트래픽을 보내고 있습니다.
* `listen`으로 시작하는 두 줄은 프록시 프로토콜을 사용하여 포트 80에서 들어오는 트래픽을 수신하도록 서버에 지시합니다. 첫 번째는 IPv4를 통해, 두 번째는 IPv6을 통해.
* `server_name` 함수는 특별히 "apache.server.test"로 들어오는 모든 트래픽을 가져와 리버스 프록시를 통해 라우팅합니다.
* `proxy-pass` 기능은 `server_name` 변수에 의해 캡처된 모든 트래픽을 실제로 지시하여 `upstream` 섹션에 정의된 서버로 보내는 부분입니다.
* `proxy_redirect` 기능은 분명히 리버스 프록시를 방해할 수 있으므로 이 기능이 꺼져 있는지 확인하고 있습니다.
* 모든 `proxy-set-header` 옵션은 사용자의 IP 등의 정보를 웹 서버로 전송합니다.

!!! warning "주의"

    `listen` 변수의 `proxy_protocol` 비트는 프록시 서버가 작동하는 데 *필수*입니다. 절대 빼놓지 마세요.

모든 LXD/웹 사이트 구성 파일에 대해 그에 따라 `upstream`, `server`, `server_name`, 및 `proxy_pass` 설정을 변경해야 합니다. `proxy-pass`에서 "http://" 뒤의 텍스트는 `업스트림` 텍스트 뒤에 오는 텍스트와 일치해야 합니다.

`systemctl restart nginx`를 사용하여 서버를 다시 로드한 다음 브라우저에서 `apache.server.test` 대신 사용 중인 도메인을 가리킵니다. 다음과 같은 페이지가 표시되면 정상입니다.

![기본 Rocky Linux Apache 시작 페이지의 스크린샷](../images/lxd-web-server-03.png)

!!! 참고 사항

    원하는 대로 구성 파일의 이름을 지정할 수 있습니다. 나는 자습서에 대해 단순화된 이름을 사용하고 있지만 일부 시스템 관리자는 실제 도메인을 기반으로 하지만 그 반대인 이름을 권장합니다. 알파벳 순서 기반 조직입니다.
    
    eg. "apache.server.test"는 `test.server.apache.conf`라는 구성 파일을 가져옵니다.
#### Nginx 서버로 트래픽 전달

과정을 반복하면 됩니다. 이전과 같이 파일을 만듭니다.

```bash
nano /etc/nginx/conf.d/nginx-server.conf
```

적절한 텍스트를 추가합니다.

```
upstream nginx-server {
    server rocky-nginx.lxd:80;
}

server {
    listen 80 proxy_protocol;
    listen [::]:80 proxy_protocol;
    server_name nginx.server.test; #< Your domain goes here

    location / {
        proxy_pass http://nginx-server;

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

다시 프록시 서버를 다시 로드하고 브라우저에서 적절한 주소를 가리키고 원하는 신이 무엇이든 다음을 보기를 바랍니다.

![기본 Rocky Linux Nginx 시작 페이지의 스크린샷](../images/lxd-web-server-04.png)

#### 웹 서버 컨테이너에서 서버를 다시 시작하십시오.

"proxy-server" 컨테이너를 다시 종료하고 간단한 명령 하나로 다른 두 컨테이너의 서버를 다시 시작합니다.

```bash
lxc exec apache-server systemctl restart httpd && lxc exec nginx-server restart nginx
```

그러면 우리가 만든 "real-ip.conf" 파일이 각각의 서버 구성에 적용됩니다.

#### 웹사이트용 SSL 인증서 받기
Let's Encrypt와 certbot이라는 작은 애플리케이션을 사용하면 공식적이고 적절한 SSL 인증서를 가장 쉽게 얻을 수 있습니다. certbot은 자동으로 웹 사이트를 감지하고 SSL 인증서를 가져오고 사이트 자체를 구성합니다. 사용자 또는 크론 작업의 개입 없이 30일 정도마다 인증서를 갱신합니다.

이 모든 작업은 "proxy-server" 컨테이너에서 수행해야 하므로 해당 셸에 로그인합니다. 그런 다음 호스트에서와 마찬가지로 EPEL 리포지토리를 설치합니다. 컨테이너가 먼저 업데이트되었는지 확인합니다.

```bash
dnf update
```

그런 다음 EPEL 저장소를 추가합니다.

```bash
dnf install epel-release
```

그런 다음 certbot과 해당 Nginx 모듈을 설치하기만 하면 됩니다.

```bash
dnf install certbot python3-certbot-nginx
```

일단 설치되면 이미 몇 개의 웹사이트가 구성되어 있는 한 다음을 실행하십시오.

```bash
certbot --nginx
```

Certbot은 Nginx 구성을 읽고 보유하고 있는 웹사이트 수와 SSL 인증서가 필요한지 파악합니다. 이 시점에서 몇 가지 질문을 받게 됩니다. 서비스 약관에 동의하십니까, 이메일 등을 원하십니까?

가장 중요한 질문은 다음과 같습니다. 다음과 같이 표시되면 이메일 주소를 입력하세요.

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel):
```

여기에서 인증서를 받을 웹사이트를 선택할 수 있습니다. 모두에 대한 인증서를 얻으려면 Enter 키를 누르십시오.

```
어떤 이름에 대해 HTTPS를 활성화하시겠습니까?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: apache.server.test
2: nginx.server.test
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

많은 확인 텍스트가 표시되고 완료됩니다. 그러나 웹 사이트를 방문하면 작동하지 않는다는 것을 알 수 있습니다. 이는 certbot이 업데이트된 구성을 생성할 때 매우 중요한 한 가지를 잊기 때문입니다.

`apache-server.conf` 및 `nginx-server.conf` 파일로 이동하여 다음 두 줄을 찾습니다.

```
listen [::]:443 ssl ipv6only=on; # managed by Certbot
listen 443 ssl; # managed by Certbot
```

예, `proxy_protocol` 설정이 누락되어 있습니다. 직접 추가하십시오.

```
listen proxy_protocol [::]:443 ssl ipv6only=on; # managed by Certbot
listen proxy_protocol 443 ssl; # managed by Certbot
```

파일을 저장하고 서버를 다시 시작하면 웹 사이트가 문제 없이 로드됩니다.

## 참고 사항

1. 이 튜토리얼에서는 실제 웹 서버 구성에 대해 많이 언급하지 않았습니다. 프로덕션 환경에서 최소한 해야 할 일은 프록시 컨테이너뿐만 아니라 실제 웹 서버 컨테이너의 서버 구성 파일에서 도메인 이름을 변경하는 것입니다. 그리고 각각에 웹 서버 사용자를 설정할 수도 있습니다.
2. SSL 인증서 및 SSL 서버 구성을 수동으로 관리하는 방법에 대해 자세히 알아보려면 [certbot 설치 및 SSL 인증서 생성 가이드](../security/generating_ssl_keys_lets_encrypt.md)를 확인하세요.
3. Nextcloud와 같은 앱은 프록시 뒤의 LXD 컨테이너에 배치하는 경우 보안상의 이유로 몇 가지 추가 구성이 필요합니다.

## 결론

LXC/LXD, 컨테이너화, 웹 서버 및 실행 중인 웹 사이트에 대해 더 많은 것을 배울 수 있지만 솔직히 좋은 시작이 될 것입니다. 모든 것을 설정하는 방법과 원하는 방식으로 구성하는 방법을 배우면 프로세스 자동화를 시작할 수도 있습니다.

여러분은 Ansible을 사용할 수도 있고 저와 같을 수도 있으며 모든 것을 더 빠르게 하기 위해 실행하는 사용자 지정 스크립트 세트를 가지고 있을 수도 있습니다. 좋아하는 모든 소프트웨어가 미리 설치된 작은 "템플릿 컨테이너"를 만든 다음 복사하고 필요에 따라 저장 용량을 확장할 수도 있습니다.

좋습니다. 끝났습니다. 저는 비디오 게임을 하러 갑니다. 재미있게 즐기세요!
