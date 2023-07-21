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

도커(Docker는 VM 시스템이 *아닌* 또 다른 컨테이너 기반 시스템임)의 경우 Linux 컨테이너는 익숙한 것보다 덜 일시적입니다. 모든 컨테이너 인스턴스의 모든 데이터는 영구적이며 변경 사항은 백업으로 되돌리지 않는 한 영구적입니다. 즉, 컨테이너를 종료해도 도입한 문제들이 사라지지는 않습니다.

특히, LXD는 리눅스 컨테이너를 설정하고 관리하는 데 도움이 되는 명령줄 애플리케이션입니다. 오늘 우리는 Rocky Linux 호스트 서버에 이것을 설치할 것입니다. 그러나 구식 문서들에서는 주로 LXC만 언급하기 때문에, LXC/LXD 모두를 자주 언급할 것입니다. 이렇게 하면 업데이트된 가이드를 쉽게 찾을 수 있도록 돕기 위함입니다.

특히 LXD는 Linux 컨테이너를 설정하고 관리하는 데 도움이 되는 명령줄 애플리케이션입니다. 그것이 오늘 Rocky Linux 호스트 서버에 설치할 것입니다.

    "LXC"라고도 하는 LXD의 선구자 앱이 있었습니다. 오늘날에는 LXC가 기술이고, LXD가 앱입니다.

우리는 이 둘을 함께 사용하여 다음과 같은 환경을 만들어 볼 것입니다:

![원하는 리눅스 컨테이너 구조의 다이어그램](../images/lxd-web-server-02.png)

구체적으로, 서버 컨테이너 내에서 간단한 Nginx와 Apache 웹 서버를 설정하는 방법을 보여드리고, 다른 컨테이너에는 Nginx를 리버스 프록시로 사용할 것입니다. 이러한 설정은 로컬 네트워크부터 가상 개인 서버까지 모든 환경에서 작동해야 합니다.

!!! Note "참고 사항"

    리버스 프록시는 인터넷(또는 로컬 네트워크)에서 들어오는 연결을 가져와 올바른 서버, 컨테이너 또는 앱으로 라우팅하는 프로그램입니다. 이 작업을 전담하는 HaProxy와 같은 전용 도구도 있습니다. 하지만 저는 Nginx가 훨씬 쉽다고 생각합니다.

## 전제 조건 및 가정

* Linux 명령줄 인터페이스에 대한 기본적인 지식이 필요합니다. 원격 서버에 LXC/LXD를 설치하는 경우 SSH 사용법을 알고 있어야 합니다.
* Rocky Linux가 이미 실행 중인 물리적 또는 가상의 인터넷 연결 서버가 필요합니다.
* 두 개의 도메인 이름이 A 레코드로 서버를 바로 가리킵니다.
    * 두 개의 하위 도메인도 마찬가지로 작동해야합니다. 와일드카드 서브도메인 레코드를 가진 하나의 도메인이나 사용자 정의 로컬 영역 네트워크(LAN) 도메인도 사용할 수 있습니다.
* 명령줄 텍스트 편집기. *nano*도 가능하고 *micro*가 제가 가장 좋아하는 것이지만 편안하게 사용할 수 있는 것을 사용하세요.
* 루트 사용자로 전체 튜토리얼을 *따라할 수는 있지만*, 이는 좋은 방법이 아닙니다. LXC/LXD 초기 설치 후 LXD 명령을 실행하기 위한 권한 없는 사용자를 생성하는 방법을 안내해 드립니다.
* 컨테이너를 기반으로하는 Rocky Linux 이미지가 이미 제공됩니다.
* Nginx 또는 Apache에 대해 익숙하지 않다면, 완전한 프로덕션 서버를 설정하려면 다른 가이드를 **확인해야 합니다**. 걱정하지 마세요. 아래에 링크하겠습니다.

## 호스트 서버 환경 설정

### EPEL 저장소 설치

LXD는 EPEL(Enterprise Linux용 Extra Packages) 저장소가 필요합니다. 다음 명령을 사용하여 간단히 설치할 수 있습니다.

```bash
dnf install epel-release
```

설치가 완료되면 업데이트를 확인합니다.

```bash
dnf update
```

업데이트 과정에서 커널 업데이트가 있는 경우 서버를 재부팅합니다.

### snapd 설치

Rocky Linux용 LXD는 snap\* 패키지에서 설치해야 합니다. 이를 위해 다음 명령을 사용하여 snapd를 설치합니다.

```bash
dnf install snapd
```

snapd 서비스가 서버가 재부팅될 때 자동으로 시작되도록 하고, 지금 실행하도록 설정합니다.

```bash
systemctl enable snapd
```

그리고 실행합니다.

```bash
systemctl start snapd
```

계속하기 전에 서버를 재부팅합니다. 이는 `reboot` 명령을 사용하거나 VPS/클라우드 호스팅 관리 패널에서 수행할 수 있습니다.

\* *snap*은 응용 프로그램을 패키징하는 방법으로, 필요한 모든 종속성을 포함하여 거의 모든 Linux 시스템에서 실행할 수 있습니다.

### LXD 설치

LXD 설치에는 snap 명령을 사용해야 합니다. 이 단계에서는 설치만 진행하고 설정은 하지 않습니다:

```bash
snap install lxd
```

만약 물리적 서버(또는 "베어 메탈" 서버)에서 LXD를 실행하고 있다면, 다른 가이드로 돌아가서 "환경 설정" 섹션을 읽어보는 것이 좋습니다. 커널과 파일 시스템 등에 대한 유용한 정보가 많이 있으니 참고하시기 바랍니다.

가상 환경에서 LXD를 실행하고 있다면, 그냥 재부팅하고 계속 읽어주세요.

### LXD 초기화

환경이 모두 설정되었으므로, 이제 LXD를 초기화할 준비가 되었습니다. 이는 자동화된 스크립트로서 LXD 인스턴스를 시작하기 위해 일련의 질문을 하게 됩니다:

```bash
lxd init
```

다음은 스크립트에 대한 질문과 우리의 답변, 필요한 경우에는 간단한 설명이 포함되어 있습니다:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

클러스터링에 관심이 있다면, [여기](https://linuxcontainers.org/lxd/docs/master/clustering/)에서 추가적인 연구를 해보시기 바랍니다. 그렇지 않다면, 기본 옵션을 허용하기 위해 "Enter"를 누르세요.

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

 기본 옵션을 허용하세요.

```
Name of the new storage pool [default=default]: server-storage
```

스토리지 풀의 이름을 선택하세요. 일반적으로 LXD가 실행 중인 서버 이름을 사용하는 것이 좋습니다. (스토리지 풀은 기본적으로 컨테이너에 할당된 하드 드라이브 공간의 집합입니다.)

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]: lvm
```

위의 질문은 스토리지에 사용할 파일 시스템 유형에 관한 것이며, 기본값은 시스템에서 사용 가능한 것에 따라 다를 수 있습니다. 베어 메탈 서버에서 ZFS를 사용하려면, 다시 한 번 위에서 링크된 가이드를 참조하세요.

가상 환경에서 나는 "LVM"이 잘 작동한다는 것을 알았고, 보통 내가 사용하는 것입니다. 다음 질문에서 기본값을 수락할 수 있습니다.

```
Create a new LVM pool? (yes/no) [default=yes]:
```

전체 스토리지 풀에 사용할 특정한 하드 드라이브 또는 파티션이 있으면 "예"를 선택하세요. VPS에서 모든 작업을 수행하고 있다면 "아니오"를 *선택해야 합니다*.

```
`Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:`
```

Metal As A Service (MAAS)는 이 문서의 범위를 벗어납니다. 이 다음의 내용은 기본값을 허용하세요.

```
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

그리고 더 많은 기본값이 있습니다. 모두 좋습니다.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:

What should the new bridge be called? [default=lxdbr0]: `

What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

LXD 컨테이너에서 IPv6을 사용하려면 다음 옵션을 활성화할 수 있습니다. 이는 사용자에 따라 달라질 수 있지만, 대부분은 필요하지 않습니다. 제 생각에는요. 귀찮음 때문에 그냥 기본값으로 둡니다.

```
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

서버를 쉽게 백업하고 다른 컴퓨터에서 LXD 설치를 관리할 수 있도록 필요합니다. 이 모든 내용이 괜찮다면, 여기서 "예"로 답변하세요.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

만약 앞서의 질문에 "예"라고 답변했다면, 여기서도 기본값을 사용하세요:

```
Address to bind LXD to (not including port) [default=all]:

Port to bind LXD to [default=8443]:
```

이제 신뢰 암호를 입력해야 합니다. 이렇게 하면 다른 컴퓨터와 서버에서 LXC 호스트 서버에 연결할 수 있으므로 환경에 적합한 것으로 설정합니다. 환경에 맞는 암호를 설정하고, 이를 비밀번호 관리자와 같은 안전한 위치에 저장하세요.

```
Trust password for new clients:

Again:
```

이후로는 기본값을 계속 선택하세요:

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]

Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

#### 사용자 권한 설정

진행하기 전에, 우리는 "lxdadmin" 사용자를 생성하고 필요한 권한을 갖도록 해야 합니다. "lxdadmin" 사용자는 _sudo_ 를 사용하여 root 명령에 접근할 수 있어야 하며, "lxd" 그룹의 구성원이 되어야 합니다. 사용자를 추가하고 양 그룹에 멤버로 추가하려면 다음을 실행하세요:

```bash
useradd -G wheel,lxd lxdadmin
```

그리고 비밀번호를 설정하세요:

```bash
passwd lxdadmin
```

다른 비밀번호와 마찬가지로, 이 비밀번호도 안전한 위치에 저장하세요.

## 방화벽 설정

컨테이너와 관련하여 다른 작업을 하기 전에, 외부에서 프록시 서버에 접근할 수 있어야 합니다. 방화벽이 포트 80(HTTP/웹 트래픽에 사용되는 기본 포트) 또는 포트 443(HTTPS/*보안* 웹 트래픽에 사용되는 포트)을 차단하고 있다면, 서버와 관련된 많은 작업을 수행할 수 없습니다.

다른 LXD 가이드에서는 *iptables* 방화벽을 사용하는 방법을 보여줄 것입니다. 그것이 원하는 방법인 경우에는 해당 가이드를 따르시면 됩니다. 제가 사용하는 것은 CentOS의 기본 방화벽인 *firewalld*입니다. 이것이 바로 우리가 이번에 할 일입니다.

`firewalld`는 `firewall-cmd` 명령을 통해 구성됩니다. **우리가 하는 첫 번째 작업은** 포트가 자동으로 할당될 수 있도록 컨테이너를 설정하는 것입니다:

```bash
firewall-cmd --zone=trusted --permanent --change-interface=lxdbr0
```

!!! warning "주의"

    마지막 단계를 수행하지 않으면 컨테이너가 인터넷 또는 서로 간에 제대로 액세스할 수 없습니다. 이것은 미친 듯이 필수적이며, 그것을 알면 좌절의 *시대**를 구할 수 있습니다.

이제 새로운 포트를 추가하기 위해 다음을 실행하세요:

```bash
firewall-cmd --permanent --zone=public --add-port=80/tcp
```

이것을 자세히 살펴보겠습니다:

* `-–permanent` 플래그는 방화벽이 다시 시작될 때마다 그리고 서버 자체가 다시 시작될 때 이 구성이 사용되는지 확인하도록 방화벽에 지시합니다.
* `–-zone=public`은 모든 사람으로부터 이 포트로 들어오는 연결을 받아들이도록 방화벽에 지시합니다.
* 마지막으로 `–-add-port=80/tcp`는 방화벽이 전송 제어 프로토콜을 사용하는 한 포트 80을 통해 들어오는 연결을 수락하도록 지시합니다. 이 경우 원하는 것입니다.

HTTPS 트래픽에 대해 동일한 작업을 반복하려면 명령을 다시 실행하고 숫자를 변경하면 됩니다.

```bash
firewall-cmd --permanent --zone=public --add-port=443/tcp
```

이러한 구성은 변경 사항을 적용하기 전에 강제로 실행해야 합니다. 이를 위해 *firewalld*에게 구성을 다시 로드하도록 지시하세요:

```bash
firewall-cmd --reload
```

이 매우 작은 확률로 작동하지 않을 수 있습니다. 그런 경우, *firewalld*에게 권한을 부여하려면 전형적인 재부팅 방식으로 해결할 수 있습니다.

```bash
systemctl restart firewalld
```

포트가 올바르게 추가되었는지 확인하려면 `firewall-cmd --list-all` 명령을 실행하세요. 올바르게 구성된 방화벽은 다음과 같이 보일 것입니다 (로컬 서버에 여러 개의 추가 포트가 열려 있습니다. 이것들은 무시하세요):

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

실제로 컨테이너를 관리하는 것은 매우 쉽습니다. 명령어를 내려 컴퓨터 전체를 마치 마법처럼 생성하고 원하는 때에 시작하거나 중지시킬 수 있습니다. 또한 호스트 서버와 마찬가지로 해당 "컴퓨터"에 로그인하여 원하는 명령을 실행할 수 있습니다.

!!! Note "참고 사항"

    여기서부터 모든 명령은 `lxdadmin` 사용자 또는 사용자가 호출하기로 결정한 대로 실행해야 하지만 일부는 임시 루트 권한을 위해 *sudo*를 사용해야 합니다.

이 튜토리얼에서는 3개의 컨테이너가 필요합니다: 리버스 프록시 서버, 테스트용 Nginx 서버, 테스트용 Apache 서버가 모두 Rocky 기반 컨테이너에서 실행될 것입니다.

특정 이유로 완전히 권한을 갖춘 컨테이너가 필요한 경우(대부분은 필요하지 않음) 이 명령을 모두 root로 실행할 수 있습니다.

이 튜토리얼에서는 세 개의 컨테이너가 필요합니다:

이들을 "proxy-server"(다른 두 컨테이너로 웹 트래픽을 지시할 컨테이너), "nginx-server" 및 "apache-server"라고 부릅니다. 네, 리버스 프록시를 사용하여 *nginx* 및 *apache* 기반 서버로 지시하는 방법을 보여드리겠습니다. *docker*나 NodeJS 앱과 같은 다른 작업은 내가 직접 알아내기 전까지는 보류할 것입니다.

먼저 어떤 이미지를 기반으로 컨테이너를 생성할지 결정해야 합니다. 이 튜토리얼에서는 단순히 Rocky Linux를 사용합니다. 예를 들어, Alpine Linux를 사용하면 훨씬 작은 컨테이너가 생성될 수 있지만(저장 공간이 문제인 경우), 이 특정 문서의 범위를 벗어납니다.

### 원하는 이미지 찾기

Rocky Linux를 사용하여 컨테이너를 빠르게 시작하는 방법은 다음과 같습니다.

```bash
lxc launch images:rockylinux/8/amd64 my-container
```

물론, 끝에 있는 "my-container" 부분은 컨테이너 이름을 원하는 대로 변경해야 합니다. 예를 들면 "proxy-server"와 같이 변경할 수 있습니다. "/amd64" 부분은 무언가 Raspberry Pi와 같은 것에서 모두 수행하고 있는 경우 "arm64"로 변경해야 합니다.

이제 긴 버전을 보겠습니다. 원하는 이미지를 찾으려면 다음 명령을 사용하여 주요 LXC 저장소에 있는 모든 사용 가능한 이미지를 나열할 수 있습니다.

```bash
lxc image list images: | more
```

그런 다음 "Enter"를 눌러 대량의 이미지 목록을 스크롤하고 목록 보기 모드에서 빠져나가려면 "Control-C"를 누르세요.

또는 더 간단하게 생각하여 원하는 종류의 Linux를 지정할 수 있습니다.

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

!!! Note "참고 사항"

    아래는 이러한 모든 컨테이너를 만드는 빠른 방법입니다. 프록시 서버 컨테이너를 만들기 전에 기다릴 수 있습니다. 시간을 절약할 수 있는 요령이 아래에서 보여 드리겠습니다.

원하는 이미지를 찾은 후, 위에 설명된대로 `lxc launch` 명령을 사용합니다. 이 튜토리얼에서 필요한 컨테이너를 만들기 위해 다음 명령을 연속적으로 실행하세요(필요에 따라 수정하면 됩니다).

```bash
lxc launch images:rockylinux/8/amd64 proxy-server
lxc launch images:rockylinux/8/amd64 nginx-server
lxc launch images:rockylinux/8/amd64 apache-server
```

각 명령을 실행할 때 컨테이너가 생성되었는지 확인해야 합니다. 그러면, 당신은 그들 모두를 확인하고 싶을 것입니다.

이 명령을 실행하여 모든 명령이 실행되고 있는지 확인합니다:

```bash
lxc list
```

그러면 다음과 같이 출력이 나타날 것입니다(다만, IPv6를 사용한 경우 텍스트가 더 많아질 수 있습니다).

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

컨테이너 네트워킹에 대해 간단히 언급하자면, 이 가이드 맨 처음에 링크된 다른 가이드에서 Macvlan을 사용하여 LXC/LXD를 설정하는 방법에 대한 자습서가 있습니다. 이 방법은 로컬 서버에서 실행 중인 경우에 특히 유용하며 각 컨테이너가 로컬 네트워크에서 볼 수 있는 IP 주소를 갖도록 설정하는 데 유용합니다.

VPS에서 실행 중인 경우 이러한 옵션이 없을 수 있습니다. 사실, 한 개의 IP 주소만 사용할 수 있는 경우도 있을 수 있습니다. 별것 아닙니다. 기본 네트워킹 구성은 이러한 제한 사항을 수용하도록 설계되었습니다. 위에서 지정한 대로 `lxd init` 질문에 응답하면 *모든 것이 처리됩니다*.

기본적으로 LXD는 브리지(일반적으로 "lxdbr0"이라는 이름)라는 가상 네트워크 장치를 생성하고 모든 컨테이너를 기본적으로 해당 브리지에 연결합니다. 이를 통해 컨테이너는 호스트의 기본 네트워크 장치(이더넷, Wi-Fi 또는 VPS에서 제공하는 가상 네트워크 장치)를 통해 인터넷에 연결할 수 있습니다. 조금 더 중요한 점은 모든 컨테이너가 서로 연결될 수 있다는 것입니다.

이러한 컨테이너 간 연결을 보장하기 위해 *각 컨테이너에는 내부 도메인 이름이 할당됩니다*. 기본적으로 이는 컨테이너 이름에 ".lxd"를 추가한 것입니다. 예를 들어, "proxy-server" 컨테이너는 다른 모든 컨테이너에서 "proxy-server.lxd"로 사용할 수 있습니다. 하지만 이제 알아야 할 *정말* 중요한 점은 **기본적으로 ".lxd" 도메인은 컨테이너 자체에서만 사용 가능하다는 것입니다**.

호스트 OS(또는 다른 장소)에서 `ping proxy-server.lxd`를 실행하면 아무 것도 표시되지 않습니다. 이러한 내부 도메인은 나중에 매우 유용하게 사용될 것입니다.

이를 기술적으로 변경하여 컨테이너의 내부 도메인을 호스트에서 사용할 수 있도록 만들 수 있지만, 실제로는 이해하지 못했습니다. 역방향 프록시 서버를 컨테이너에 두는 것이 좋으므로 간편하게 스냅샷을 찍고 백업할 수 있습니다.

### 컨테이너 관리

계속하기 전에 알아야 할 몇 가지 사항이 있습니다.

#### 시작 및 중지

모든 컨테이너는 다음과 같은 명령으로 필요에 따라 시작, 중지 및 재시작할 수 있습니다.

```bash
lxc start mycontainer
lxc stop mycontainer
lxc restart mycontainer
```

리눅스도 때로는 재부팅해야 합니다. 심지어 모든 컨테이너를 한 번에 시작, 중지 및 재시작할 수도 있습니다.

```bash
lxc start --all
lxc stop --all
lxc restart --all
```

이 `restart --all` 옵션은 어떤 더 이상한 일시적인 버그 때문에 매우 유용합니다.

#### 컨테이너 내부에서 작업 수행

컨테이너 내부의 운영 체제를 제어하는 두 가지 방법이 있습니다: 호스트 OS에서 컨테이너 내부에서 명령을 실행하거나 쉘을 열 수 있습니다.

즉, 예를 들어 *Apache*를 설치하는 등 컨테이너 내부에서 명령을 실행하려면 `lxc exec`를 사용합니다.

```bash
lxc exec my-container dnf install httpd -y
```

이 명령은 *Apache*를 자동으로 설치하고 호스트의 터미널에 명령의 출력이 표시됩니다.

쉘을 열어(쉘 내에서 필요한 모든 명령을 root로 실행할 수 있습니다) 다음과 같이 실행하세요.

```bash
lxc exec my-container bash
```

저와 같이 편의성을 가치있게 생각하며 모든 컨테이너에 대해 *fish*와 같은 대체 쉘을 설치한 경우 다음과 같이 명령을 변경하세요.

```bash
lxc exec my-container fish
```

거의 모든 경우에 기본적으로 root 계정으로 `/root` 디렉토리에 배치됩니다.

마지막으로, 컨테이너의 쉘을 열었으면 나가기 위해 간단한 `exit` 명령으로 나올 수 있습니다.

#### 컨테이너 복사

컨테이너를 최소한의 노력으로 복제하려면 새로운 컨테이너를 시작하고 기본 응용 프로그램을 다시 설치할 필요가 없습니다. 그러면 어리석게 느껴질 것입니다. 그냥 다음 명령을 실행하세요.

```bash
lxc copy my-container my-other-container
```

"my-container"의 정확한 복사본이 "my-other-container"라는 이름으로 생성됩니다. 그러나 자동으로 시작되지 않을 수 있으므로 새 컨테이너의 구성을 원하는 대로 변경한 다음 다음 명령을 실행하세요.

```bash
lxc start my-other-container
```

이 시점에서 내부 호스트 이름을 변경하거나 기타 변경을 수행할 수도 있습니다.

#### 스토리지 구성 & CPU 제한

LXC/LXD는 일반적으로 컨테이너가 얼마나 많은 스토리지 공간을 할당 받을지 정의하고 일반적으로 자원을 관리하지만 제어를 원할 수도 있습니다. 컨테이너를 작게 유지하는 것이 걱정되는 경우 컨테이너 크기를 조절하고 변경하려면 `lxc config` 명령을 사용할 수 있습니다.

다음 명령은 컨테이너에 "소프트" 제한 2GB를 설정합니다. 소프트 제한은 실제로 "최소 스토리지"라고 생각할 수 있으며 컨테이너가 사용 가능한 경우 더 많은 스토리지를 사용할 수 있습니다. 컨테이너 이름 "my-container"를 실제 컨테이너 이름으로 변경하십시오.

```bash
lxc config set my-container limits.memory 2GB
```

다음과 같이 하드 제한을 설정할 수도 있습니다.

```bash
lxc config set my-container limits.memory.enforce 2GB
```

또한 컨테이너가 서버에서 사용 가능한 모든 처리 능력을 독점할 수 없도록 하려면 다음 명령으로 CPU 코어에 대한 액세스 권한을 제한할 수 있습니다. 적절한 CPU 코어 수를 변경하십시오.

```bash
lxc config set my-container limits.cpu 2
```

#### 컨테이너 삭제(및 이를 방지하는 방법)

마지막으로, 다음 명령을 실행하여 컨테이너를 삭제할 수 있습니다.

```bash
lxc delete my-container
```

실행 중인 컨테이너는 삭제할 수 없으므로 먼저 중지하거나 `-–force` 플래그를 사용하여 이 부분을 건너뛸 수 있습니다.

```bash
lxc delete my-container --force
```

지금 탭 -command-completion, 사용자 오류, 그리고 키보드에서 "d"가 "s" 옆에 있기 때문에 컨테이너를 실수로 삭제할 수 있습니다. 이것은 비즈니스에서 THE BIG OOPS로 알려져 있습니다. (아니면 적어도 여기에서 끝나면 THE BIG OOPS로 알려질 것입니다.)

이를 방지하기 위해 다음 명령으로 모든 컨테이너를 "보호"로 설정하여 삭제 프로세스를 추가 단계로 만들 수 있습니다.

```bash
lxc config set my-container security.protection.delete true
```

컨테이너를 보호 해제하려면 명령을 다시 실행하지만 "true"를 "false"로 변경하면 됩니다.

## 서버 설정

컨테이너가 실행 중인 상태에서는 필요한 것을 설치해야 합니다. 우선 다음 명령으로 모든 컨테이너를 업데이트하세요("proxy-server" 컨테이너를 아직 생성하지 않은 경우 이 명령은 건너뛰세요).

```bash
lxc exec proxy-server dnf update -y
lxc exec nginx-server dnf update -y
lxc exec apache-server dnf update -y
```

그런 다음 각 컨테이너로 이동하여 설정을 시작하세요.

또한 각 컨테이너에 텍스트 편집기가 필요합니다. 기본적으로 Rocky Linux에는 *vi*가 설치되어 있지만 편의를 위해 *nano*를 설치할 수 있습니다. 열기 전에 각 컨테이너에 nano를 설치하세요.

```bash
lxc exec proxy-server dnf install nano -y
lxc exec nginx-server dnf install nano -y
lxc exec apache-server dnf install nano -y
```

그런 다음 각 컨테이너로 이동하여 크래킹하십시오.

### Apache 웹사이트 서버

학습 및 테스트 목적으로 간단히 유지합니다. 전체 아파치 가이드에 대한 링크는 아래에서 확인하십시오.

먼저 컨테이너로 쉘을 엽니다. 기본적으로 컨테이너는 root 계정으로 들어갑니다. 우리의 목적을 위해 그대로 두지만 실제 제품 용도의 경우 별도의 웹 서버 사용자를 생성하는 것이 좋습니다.

```bash
lxc exec apache-server bash
```

로그인한 후 간단하게 *Apache*를 설치하세요.

```bash
dnf install httpd
```

이제 여기서부터 [아파치 웹 서버 다중 사이트 설정 가이드](../web/apache-sites-enabled.md)를 따라 할 수 있지만 우리의 목적에는 실제로 너무 많은 작업입니다. 이러한 컨테이너화된 환경에서 일반적으로 여러 웹 사이트를 위해 아파치를 설정하길 원하지 않습니다. 결국 컨테이너의 목적은 업무를 분리하는 것이니까요.

또한 SSL 인증서는 프록시 서버에 설치되므로 간단하게 유지합니다.

*아파치*가 설치되면 실행되고 부팅시 유지되도록 하세요.

```bash
systemctl enable --now httpd
```

`--now` 플래그를 사용하면 실제 서버를 시작하는 명령을 건너 뛸 수 있습니다. 참고로 시작 명령은 다음과 같습니다.

```bash
systemctl start httpd
```

서버 호스트에 `curl`이 설치되어 있으면 기본 웹 페이지가 작동하는지 확인할 수 있습니다.

```bash
curl [container-ip-address]
```

기억하세요. `lxc list`에서 모든 컨테이너 IP를 볼 수 있습니다. 모든 컨테이너에 curl을 설치하면 다음과 같이 *실행할 수도 있습니다*.

```bash
curl localhost
```

#### 프록시 서버에서 실제 사용자 IP 가져오기

이제 Apache를 역방향 프록시 사용에 맞게 준비하기 위해 수행해야 할 단계입니다. 기본적으로 웹 서버 컨테이너에 있는 서버들은 사용자의 실제 IP 주소를 로그에 기록하지 않습니다. 특정 웹 앱에서는 사용자 IP를 사용하여 모디레이션, 차단 및 문제 해결과 같은 기능을 위해 IP 주소가 필요합니다.

방문자의 IP 주소를 프록시 서버를 통과시키기 위해서는 두 부분이 필요합니다: 프록시 서버에서 올바른 설정(나중에 다루겠습니다)과 Apache 서버를 위한 간단한 구성 파일이 필요합니다.

감사의 말씀을 Linode와 [그들의 LXD 가이드](https://www.linode.com/docs/guides/beginners-guide-to-lxd-reverse-proxy)에 전해드립니다. 이 구성 파일의 템플릿을 제공해주셨습니다.

새로운 구성 파일을 만듭니다.

```bash
nano /etc/httpd/conf.d/real-ip.conf
```

그리고 다음 텍스트를 추가하세요.

```
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy proxy-server.lxd
```

필요한 경우 `proxy-server.lxd`를 실제 프록시 컨테이너 이름으로 변경하세요. **Apache 서버를 아직 재시작하지 마세요**. 추가한 구성 파일로 인해 프록시 서버를 실행할 때 문제가 발생할 수 있습니다.

지금은 일단 쉘을 나가서 Nginx 서버에서 작업을 시작합시다.

필요한 경우 `proxy-server.lxd`를 실제 프록시 컨테이너라고 부르는 것으로 변경해야 합니다. note  "참고사항"

    이 기술이 *작동*하는 동안(귀하의 웹 앱과 웹사이트는 사용자의 실제 IP를 얻습니다), Apache의 자체 액세스 로그는 *올바른 IP를 표시하지 않습니다.* 일반적으로 리버스 프록시가 있는 컨테이너의 IP를 표시합니다. 이것은 분명히 Apache가 사물을 기록하는 방법에 대한 문제입니다.
    
    저는 Google에서 많은 솔루션을 찾았지만 그 중 어느 것도 실제로 저에게 효과가 없었습니다. 나보다 훨씬 똑똑한 사람이 있는지 이 공간을 살펴보세요. 그동안 IP 주소를 직접 확인해야 하는 경우 프록시 서버의 액세스 로그를 확인하거나 설치 중인 웹 앱의 로그를 확인할 수 있습니다.

### Nginx 웹사이트 서버

다시 말하지만 간단하게 유지합니다. 실제 운영에서 최신(권장) 버전의 Nginx를 사용하려면 [Nginx 설치하기 입문 가이드](../web/nginx-mainline.md)를 확인하세요. 전체 설치 가이드와 서버 구성에 대한 몇 가지 최선의 방법을 다룹니다.

테스트 및 학습을 위해 일반적으로 Nginx를 *설치할 수 있지만* 저는 "mainline" 브랜치라고 불리는 최신 버전을 설치하는 것을 추천합니다.

먼저 컨테이너의 쉘에 로그인하세요.

```bash
lxc exec nginx-server bash
```

그런 다음 최신 버전의 Nginx를 설치할 수 있도록 `epel-release` 저장소를 설치하세요.

```bash
dnf install epel-release
```

이제 다음 명령으로 최신 버전의 Nginx를 검색하세요.

```bash
dnf module list nginx
```

다음과 같은 목록이 표시됩니다.

```bash
Rocky Linux 8 - AppStream
Name       Stream        Profiles        Summary
nginx      1.14 [d]      common [d]      nginx webserver
nginx      1.16          common [d]      nginx webserver
nginx      1.18          common [d]      nginx webserver
nginx      1.20          common [d]      nginx webserver
nginx      mainline      common [d]      nginx webserver
```

원하는 것은, 맞추셨겠죠: mainline 브랜치입니다. 다음 명령으로 이 모듈을 사용하도록 설정하세요.

```bash
dnf enable module nginx:mainline
```

이 작업을 진행하겠냐는 질문이 나올 텐데, 보통처럼 `Y`를 선택하세요. 그런 다음 기본 명령을 사용하여 Nginx를 설치하세요.

```bash
dnf install nginx
```

그리고 Nginx를 활성화하고 시작하세요.

```bash
dnf enable --now nginx
```

이 작업을 수행할 것인지 묻는 메시지가 표시되므로 평소와 같이 `Y`를 선택하십시오. note "참고사항"

    프록시 컨테이너를 생성하기 전에 기다리라고 말했던 것을 기억하십니까? 이유는 다음과 같습니다. 이 시점에서 "nginx-server" 컨테이너를 그대로 두고 복사하여 "proxy-server" 컨테이너를 만들어 시간을 절약할 수 있습니다.

    ```bash
    lxc copy nginx-server proxy-server
    ```


    `lxc start proxy-server`로 프록시 컨테이너를 시작했는지 확인하고 아래 설명된 대로 컨테이너에 프록시 포트를 추가합니다.

다시 한번 말씀드리지만, 호스트에서 컨테이너가 작동하는지 확인하려면 다음 명령을 실행하세요.

```bash
curl [your-container-ip]
```

#### 프록시 서버에서 실제 사용자 IP 가져오기(다시)

이번에는 로그가 *작동*해야 합니다.   이 작업을 수행하기 위해 `/etc/nginx/conf.d` 디렉토리에 매우 유사한 파일을 만듭니다.

```bash
nano /etc/nginx/conf.d/real-ip.conf
```

그리고 다음 텍스트를 추가하세요.

```bash
real_ip_header    X-Real-IP;
set_real_ip_from  proxy-server.lxd;
```

마지막으로 **서버를 아직 재시작하지 마세요**. 이 구성 파일은 프록시 서버가 설정될 때까지 문제를 일으킬 수 있습니다.

### 리버스 프록시 서버

리버스 프록시 서버를 위해 두 개의 도메인 또는 서브도메인이 필요하다고 말씀드렸죠? 이곳에서 필요합니다. 이 튜토리얼에서 사용하는 서브도메인은 다음과 같습니다:

* apache.server.test
* nginx.server.test

필요에 따라 모든 파일과 지시사항에서 이들을 변경하세요.

"proxy-server" 컨테이너를 "nginx-server" 컨테이너에서 복사했으며 프록시 디바이스를 추가했다면, 이제 컨테이너 쉘로 이동하세요. 이전에 컨테이너를 만들었다면 "proxy-server" 컨테이너에서 Nginx 설치에 대한 모든 단계를 반복해야 합니다.

설치가 완료되고 정상적으로 실행됨을 확인했다면, 선택한 도메인으로부터 트래픽을 실제 웹사이트 서버로 전달하기 위해 몇 가지 구성 파일을 설정해야 합니다.

이를 하기 전에 두 서버 모두 내부 도메인을 통해 접근할 수 있는지 확인하세요.

```bash
curl apache-server.lxd
curl nginx-server.lxd
```

위 두 명령으로 터미널에서 기본 서버 환영 페이지의 HTML이 로드되면, 모든 것이 올바르게 설정된 것입니다.

#### *필수 단계:* "proxy-server" 컨테이너가 모든 수신 서버 트래픽을 처리하도록 구성

실제로 프록시 서버를 생성할 때 이 단계를 나중에 수행할 수도 있습니다. 그러나 이는 여기에 설명되어 있는 단계입니다.

이전에 방화벽에서 80번 및 443번 포트를 열었던 기억하시나요? 여기서는 "proxy-server" 컨테이너가 해당 포트를 수신하고 해당 포트로 전송하는 것으로 설정합니다.

이 두 명령을 순서대로 실행하세요.

```bash
lxc config device add proxy-server myproxy80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxy-server myproxy443 proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

이해를 돕기 위해 설명하겠습니다. 각 명령은 "proxy-server" 컨테이너에 가상 "device"를 추가합니다. 이들 장치는 호스트 OS의 80번 및 443번 포트에서 수신하고, 컨테이너의 80번 및 443번 포트에 바인딩합니다. 각 장치에는 이름이 필요하므로 "myproxy80" 및 "myproxy443"를 선택했습니다.

"listen" 옵션은 호스트 OS의 포트이며, 잘 기억한다면 0.0.0.0은 "lxdbr0" 브리지의 호스트의 IP 주소입니다. "connect" 옵션은 연결되는 로컬 IP 주소와 포트입니다.

!!! note "참고사항"

    이러한 장치가 설정되면 확실히 하기 위해 모든 컨테이너를 재부팅해야 합니다.

이러한 가상 장치는 이상적으로는 유일해야합니다. 현재 실행 중인 다른 컨테이너에 "myport80" 장치를 추가하는 것은 좋지 않습니다. 다른 이름으로 설정해야 합니다.

*또한 특정 호스트 OS 포트를 수신하는 컨테이너는 하나만 있을 수 있습니다.*

#### Apache 서버로 트래픽 전달

"proxy-server" 컨테이너에서 `/etc/nginx/conf.d/` 디렉토리에 `apache-server.conf`라는 구성 파일을 생성하세요.

```bash
nano /etc/nginx/conf.d/apache-server.conf
```

그런 다음 아래 텍스트를 붙여넣고 필요한 대로 도메인 이름을 변경한 후 저장하세요.

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

이제 자세히 살펴보겠습니다.

* `upstream` 섹션은 리버스 프록시가 모든 트래픽을 보낼 위치를 정확히 정의합니다. 특히 "apache-server" 컨테이너의 내부 도메인 이름인 `apache-server.lxd`로 트래픽을 보내고 있습니다.
* `listen`으로 시작하는 두 줄은 프록시 프로토콜을 사용하여 포트 80에서 들어오는 트래픽을 수신하도록 서버에 지시합니다. 첫 번째는 IPv4를 통해, 두 번째는 IPv6을 통해.
* `server_name` 함수는 특별히 "apache.server.test"로 들어오는 모든 트래픽을 가져와 리버스 프록시를 통해 라우팅합니다.
* `proxy-pass` 기능은 `server_name` 변수에 의해 캡처된 모든 트래픽을 실제로 지시하여 `upstream` 섹션에 정의된 서버로 보내는 부분입니다.
* `proxy_redirect` 기능은 분명히 리버스 프록시를 방해할 수 있으므로 이 기능이 꺼져 있는지 확인하고 있습니다.
* 모든 `proxy-set-header` 옵션은 사용자의 IP 등의 정보를 웹 서버로 전송합니다.

!!! warning "경고"

    `listen` 변수의 `proxy_protocol` 비트는 프록시 서버가 작동하는 데 *필수*입니다. 절대 빼놓지 마세요.

모든 LXD/웹사이트 구성 파일마다 `upstream`, `server`, `server_name`, 그리고 `proxy_pass` 설정을 적절히 변경해야 합니다. `proxy-pass`의 "http://" 다음 텍스트는 `upstream` 텍스트 다음에 오는 텍스트와 일치해야 합니다.

` systemctl restart nginx `로 서버를 다시 로드한 다음 브라우저가 `apache.server.test ` 대신 사용 중인 도메인을 가리킵니다. 다음과 같은 페이지가 표시되면 성공한 것입니다.

![기본 Rocky 리눅스 Apache 시작 페이지 스크린샷](../images/lxd-web-server-03.png)

`systemctl restart nginx`를 사용하여 서버를 다시 로드한 다음 브라우저에서 `apache.server.test` 대신 사용 중인 도메인을 가리킵니다. note "참고사항"

    원하는 대로 구성 파일의 이름을 지정할 수 있습니다. 나는 자습서에 대해 단순화된 이름을 사용하고 있지만 일부 시스템 관리자는 실제 도메인을 기반으로 하지만 그 반대인 이름을 권장합니다. 알파벳 순서 기반 조직입니다.
    
    eg. "apache.server.test"는 `test.server.apache.conf`라는 구성 파일을 가져옵니다.
#### Nginx 서버로 트래픽 전달

이전과 유사한 방법으로 진행합니다. 이전과 동일한 방식으로 파일을 생성합니다.

```bash
nano /etc/nginx/conf.d/nginx-server.conf
```

다음과 같은 내용을 추가합니다.

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

다시 프록시 서버를 재로드하고, 브라우저에서 적절한 주소를 입력하면 다음과 같은 화면을 보게 될 것입니다:

![기본 Rocky Linux Nginx 시작 페이지 스크린샷](../images/lxd-web-server-04.png)

#### 웹 서버 컨테이너에서 서버를 다시 시작하십시오.

"proxy-server" 컨테이너를 빠져나와서 다음 간단한 명령어로 다른 두 컨테이너의 서버를 재시작하세요.

```bash
lxc exec apache-server systemctl restart httpd && lxc exec nginx-server restart nginx
```

이 명령은 "real-ip.conf" 파일들을 각각의 서버 구성에 적용할 것입니다.

#### 웹사이트용 SSL 인증서 받기
올바르고 공식적인 SSL 인증서를 얻는 가장 쉬운 방법은 Let's Encrypt와 certbot이라는 작은 애플리케이션을 사용하는 것입니다. certbot은 자동으로 웹사이트를 감지하고 해당 웹사이트를 위한 SSL 인증서를 얻어서 사이트를 구성합니다. 또한 인증서를 약 30일마다 자동으로 갱신해줍니다. 사용자의 개입이나 cron 작업 없이 자동으로 처리됩니다.

이 모든 작업은 "proxy-server" 컨테이너에서 수행되어야 하므로 해당 쉘에 로그인하세요. 호스트에서 설치한 것처럼 EPEL 저장소를 설치합니다. 컨테이너가 먼저 업데이트되었는지 확인합니다:

```bash
dnf update
```

그런 다음 EPEL 저장소를 추가하세요.

```bash
dnf install epel-release
```

그런 다음 certbot과 그의 Nginx 모듈을 설치해야 합니다.

```bash
dnf install certbot python3-certbot-nginx
```

설치가 완료되면, 이미 몇 개의 웹사이트를 구성한 상태라면, 다음 명령을 실행하세요.

```bash
certbot --nginx
```

Certbot은 Nginx 구성을 읽어 웹사이트의 수와 SSL 인증서의 필요 여부를 자동으로 감지합니다. 이 시점에서 몇 가지 질문을 받게 됩니다. 약관에 동의하는지, 이메일을 받을지 등의 내용이 포함됩니다.

가장 중요한 질문은 다음과 같습니다. 이 때 이메일 주소를 입력하세요.

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel):
```

여기서 인증서를 받을 웹사이트를 선택할 수 있습니다. 모든 웹사이트에 인증서를 받으려면 그냥 엔터를 누르세요.

```
어떤 이름에 대해 HTTPS를 활성화하시겠습니까?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: apache.server.test
2: nginx.server.test
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

여러분은 여러 확인 텍스트들을 볼 수 있고, 완료됩니다. 하지만 웹사이트로 이동하면 작동하지 않을 수도 있습니다. 이는 certbot이 업데이트된 구성을 생성할 때 꼭 필요한 한 가지를 잊어버렸기 때문입니다.

`apache-server.conf`와 `nginx-server.conf` 파일로 가서 다음 두 줄을 찾으세요.

```
listen [::]:443 ssl ipv6only=on; # managed by Certbot
listen 443 ssl; # managed by Certbot
```

네, 그들은 `proxy_protocol` 설정이 빠져 있고, 이것은 나쁘다. 직접 추가해 주세요.

```
listen proxy_protocol [::]:443 ssl ipv6only=on; # managed by Certbot
listen proxy_protocol 443 ssl; # managed by Certbot
```

파일을 저장하고 서버를 재시작하면 웹사이트가 문제 없이 로드될 것입니다.

## 참고 사항

1. 이 튜토리얼에서는 실제 웹 서버 구성에 대해 많이 언급하지 않았습니다. 프로덕션 환경에서 최소한 해야 할 일은 프록시 컨테이너뿐만 아니라 실제 웹 서버 컨테이너의 서버 구성 파일에서 도메인 이름을 변경하는 것입니다. 그리고 각각에 웹 서버 사용자를 설정할 수도 있습니다.
2. SSL 인증서 및 SSL 서버 구성을 수동으로 관리하는 방법에 대해 자세히 알아보려면 [certbot 설치 및 SSL 인증서 생성 가이드](../security/generating_ssl_keys_lets_encrypt.md)를 확인하세요.
3. Nextcloud와 같은 앱은 프록시 뒤의 LXD 컨테이너에 배치하는 경우 보안상의 이유로 몇 가지 추가 구성이 필요합니다.

## 결론

LXC/LXD, 컨테이너화, 웹 서버 및 웹 사이트 운영에 대해 더 알아야 할 사항이 많지만, 이로 인해 충분히 출발할 수 있을 것입니다. 모든 것이 어떻게 설정되어야 하는지, 원하는 대로 구성하는 방법을 배우면 자동화하는 것도 가능합니다.

Ansible을 사용할 수도 있고, 저와 같이 모든 것을 빠르게 진행하도록 스크립트를 작성할 수도 있습니다. 심지어는 모든 좋아하는 소프트웨어가 미리 설치된 "템플릿 컨테이너"를 만들고, 필요에 따라 복사하여 저장 용량을 확장할 수 있습니다.

좋아요. 이제 끝났습니다. 저는 비디오 게임을 하러 갑니다. 즐거운 시간 보내세요!
