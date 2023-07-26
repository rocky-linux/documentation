---
title: iptables에서 방화벽
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni
update: 17-Feb-2022
tags:
  - security
  - firewalld
---

# `iptables` 가이드 - `firewalld` 소개

`firewalld`가 기본 방화벽으로 등장한 이후로(아마 CentOS 7에서였을 것으로 생각됩니다. 2011년에 소개되었습니다.), 저는 어떤 비용이든 `iptables`로 돌아가는 것을 삶의 목표로 삼아왔습니다. 이에는 두 가지 이유가 있었습니다. 첫째, 당시 사용 가능한 문서들은 서버가 IP 수준까지 어떻게 보호되고 있는지 제대로 보여주지 않는 단순한 규칙을 사용했습니다. 둘째이자 주된 이유는, 저는 오랜 기간 동안 `iptables`와 함께한 경험이 있었으며, 솔직히 `iptables`를 계속 사용하는 것이 더 편했습니다. 공개 또는 내부를 막론하고 배포한 모든 서버에는 `iptables` 방화벽 규칙 집합을 사용했습니다. 해당 서버에 맞는 기본 규칙 집합을 간단히 조정하고 배포하는 것이 쉬웠습니다. CentOS 7, CentOS 8 및 이제 Rocky Linux 8에서 이를 수행하려면 [이 절차](enabling_iptables_firewall.md)를 사용해야 했습니다.

그렇다면 이 문서를 작성하는 이유는 무엇일까요? 첫째, 대부분의 `firewalld` 참조 자료들의 한계를 해결하고, 둘째로, 더 세부적인 방화벽 규칙을 모방하기 위해 `firewalld` 사용 방법을 찾아내기 위함입니다.

물론, 초보자들이 Rocky Linux의 기본 방화벽을 이해하는 데 도움이 되기도 합니다.

매뉴얼 페이지에 따르면, "`firewalld`는 네트워크/방화벽 존을 정의하여 네트워크 연결 또는 인터페이스의 신뢰 수준을 지원하는 동적으로 관리되는 방화벽을 제공합니다. IPv4, IPv6 방화벽 설정 및 이더넷 브리지를 지원하며 런타임 및 영구 구성 옵션을 분리합니다. 또한 서비스 또는 응용 프로그램용 인터페이스를 지원하여 방화벽 규칙을 직접 추가할 수 있습니다."

재미있는 사실: `firewalld`는 실제로 Rocky Linux에서 netfilter와 nftables 커널 하위 시스템의 프론트 엔드입니다.

이 가이드는 `iptables` 방화벽에서 `firewalld` 방화벽으로 규칙을 적용하는 데 초점을 맞추고 있습니다. 방화벽에 대한 처음 단계라면, [이 문서](firewalld-beginners.md)가 도움이 될 수 있습니다. 두 문서를 읽어 `firewalld`를 최대한 활용해보세요.

## 전제 조건 및 가정

* 이 문서에서는 사용자가 루트 사용자이거나 `sudo`를 사용하여 루트 사용자로 전환한 것으로 가정합니다.
* 방화벽 규칙에 대한 기본 지식, 특히 `iptables` 또는 최소한 `firewalld`에 대해 학습하고자 하는 의지가 있어야 합니다.
* 명령 줄에서 명령어를 입력하는 데 편안함을 느끼셔야 합니다.
* 여기에 제시된 모든 예제는 IPv4 IP를 다룹니다.

## 존 (Zones)

`firewalld`를 완전히 이해하기 위해서는 존(Zone)의 사용 방법을 이해해야 합니다. 존은 방화벽 규칙 집합의 세분성이 적용되는 곳입니다.

`firewalld`에는 다음과 같은 몇 가지 내장된 존이 있습니다:

| zone     | 사용 예                                                                                                                     |
| -------- | ------------------------------------------------------------------------------------------------------------------------ |
| drop     | 들어오는 연결을 응답 없이 삭제합니다 - 발신 패킷만 허용됩니다                                                                                      |
| block    | 들어오는 연결을 거부하며, IPv4의 경우 icmp-host-prohibited 메시지, IPv6의 경우 icmp6-adm-prohibited 메시지로 거부됩니다 - 이 시스템에서 시작된 네트워크 연결만 가능합니다. |
| public   | 공개 영역에서 사용하기 위해 선택된 들어오는 연결만 허용됩니다.                                                                                      |
| external | 외부 네트워크에서 사용하기 위해 마스커레이딩이 활성화된 선택된 들어오는 연결만 허용됩니다.                                                                       |
| dmz      | 비무장 지대에 있는 컴퓨터로, 내부 네트워크에 제한적인 접근을 허용하며 공개적으로 접근 가능합니다 - 선택된 들어오는 연결만 허용됩니다.                                             |
| work     | 작업 영역의 컴퓨터를 위해 (저도 이해하지 못합니다) 선택된 들어오는 연결만 허용됩니다.                                                                        |
| home     | 홈 영역에서 사용하기 위해 (저도 이해하지 못합니다) 선택된 들어오는 연결만 허용됩니다.                                                                        |
| internal | 내부 네트워크 기기 접근을 위해 선택된 들어오는 연결만 허용됩니다.                                                                                    |
| trusted  | 모든 네트워크 연결이 허용됩니다.                                                                                                       |

!!! !!!

    `firewall-cmd`는 `firewalld` 데몬을 관리하기 위한 명령줄 프로그램입니다.

시스템에서 기존 존을 나열하려면 다음과 같이 입력합니다:

`firewall-cmd --get-zones` !!! 주의

    firewall-cmd 명령어:

    ```
    $ firewall-cmd --state
    running
    ```


    systemctl 명령:

    ```
    $ systemctl status firewalld
    ```

솔직히 말해서 나는 대부분이 영역의 이름을 싫어합니다. 삭제, 차단, 공개 및 신뢰는 완벽하게 명확하지만 일부는 완벽한 세분화된 보안을 위해 충분하지 않습니다. 이 `iptables` 규칙 섹션을 예로 들어 보겠습니다.

`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

여기서 우리는 단일 IP 주소가 SSH (포트 22)를 통해 서버에 접근하는 것을 허용합니다. 내장된 존을 사용하기로 결정한다면 이를 위해 "trusted"를 사용할 수 있을 것입니다. 먼저, 해당 IP를 존에 추가하고, 두 번째로 존에 규칙을 적용합니다:

```
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service=ssh --permanent
```

그러나 만약 이 서버에 우리 조직에 할당된 IP 블록만 액세스할 수 있는 이너넷이 있는 경우는 어떻게 될까요?  이제 "internal" 존을 이 규칙에 적용해야 할까요? 솔직히 말해서, 저는 관리자 사용자의 IP (서버에 SSH로 접근을 허용하는 IP)를 다루는 존을 만들기를 원합니다. 사실 말하자면, 나만의 모든 존을 추가하는 것이 좋겠지만, 그렇게 하면 말도 안 될 수 있습니다.

### 영역 추가

존을 추가하려면 `firewall-cmd`를 `--new-zone` 매개변수와 함께 사용해야 합니다. "admin" (관리용)을 존으로 추가해보겠습니다:

`firewall-cmd --new-zone=admin --permanent`

!!! note "참고사항"

    저희는 지금까지 `--permanent` 플래그를 많이 사용했습니다. 테스트할 때는 `--permanent` 플래그 없이 규칙을 추가한 다음, 예상대로 작동하는지 테스트한 후 `firewall-cmd --runtime-to-permanent`을 사용하여 규칙을 적용하고, `firewall-cmd --reload`를 실행하기 전에 실제 규칙을 추가하는 것이 좋습니다. 위험이 적다면 (다시 말해, 자체적으로 잠금 걸릴 위험이 없다면), 여기서처럼 `--permanent` 플래그를 추가할 수 있습니다.

이 존을 실제로 사용하기 전에 방화벽을 재로드해야 합니다:

`firewall-cmd --reload`

!!! !!!

    사용자 정의 존에 대한 참고 사항: 특정 소스 IP 또는 인터페이스만 포함하고 프로토콜 또는 서비스를 포함하지 않는 신뢰할 수 있는 존을 추가해야 할 경우, "trusted" 존을 이미 다른 용도로 사용했기 때문에 제대로 작동하지 않는 경우 등, 이를 위해 사용자 정의 존을 추가할 수 있습니다. 그러나 이때 "default" 대신 "ACCEPT" (목표에 따라 REJECT 또는 DROP도 사용 가능)로 존의 대상을 변경해야 합니다. 다음은 LXD 머신에서 브리지 인터페이스 (이 경우 lxdbr0)를 사용하는 예제입니다. 다음은 LXD 머신에서 브리지 인터페이스 (이 경우 lxdbr0)를 사용하는 예제입니다.
    
    먼저 영역을 추가하고 사용할 수 있도록 다시 로드합니다.

    ```
    firewall-cmd --new-zone=bridge --permanent
    firewall-cmd --reload
    ```


    다음으로 존의 대상을 "default"에서 "ACCEPT"로 변경한 다음 인터페이스를 할당하고 방화벽을 재로드합니다:

    ```
    firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
    firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
    firewall-cmd --reload
    ```


    이는 방화벽에 다음을 알려줍니다.

    1. 존의 대상을 ACCEPT로 변경합니다.
    2. 브리지 인터페이스 "lxdbr0"을 존에 추가합니다.
    3. 방화벽 재로드합니다.

    이는 브리지 인터페이스에서 모든 트래픽을 허용한다는 것을 의미합니다.

### 목록 영역

더 나아가기 전에, 존을 나열하는 방법을 살펴보아야 합니다. `iptables -L`에서 제공되는 표 형식 출력과 달리, 하나의 열과 헤더가 포함된 단일 열이 출력됩니다. 존을 나열하려면 다음 명령을 사용합니다: `firewall-cmd --zone=[zone_name] --list-all`. 이렇게 하면 새로 만든 "admin" 존을 나열하는 결과는 다음과 같습니다:

`firewall-cmd --zone=admin --list-all`

```bash
admin
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
시스템에서 활성 존을 나열하려면 다음 명령을 사용합니다:

`firewall-cmd --get-active-zones`

!!! "중요: 활성 zone" 참고

    존은 다음 두 가지 조건 중 *하나를 갖추었을 때*만 활성 상태가 될 수 있습니다:

    1. 존이 네트워크 인터페이스에 할당되었습니다.
    2. 존에 소스 IP 또는 네트워크 범위가 할당되었습니다.

### 존에서 IP 및 서비스 제거

이전 지침에 따라 "trusted" 존에 IP를 추가한 경우, 이제 해당 존에서 IP를 제거해야 합니다. `--permanent` 플래그를 사용하는 데 관한 우리의 참고 사항을 기억하세요. 여기서는 실제로 규칙을 적용하기 전에 제대로 테스트하기 위해 이 플래그를 사용하지 않는 것이 좋습니다:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122`

또한 해당 존에서 ssh 서비스를 제거하고 싶습니다:

`firewall-cmd --zone=trusted --remove-service ssh`

그런 다음 테스트합니다. 최종 두 단계를 실행하기 전에 다른 존에서 `ssh`를 통해 접근할 수 있는지 확인하십시오. (아래의 **경고** 참조!) 다른 변경 사항을 가하지 않았다면, "public" 존에는 여전히 ssh가 허용되어 있을 것입니다.

만족하셨다면, 런타임 규칙을 영구 규칙으로 이동합니다:

`firewall-cmd --runtime-to-permanent`

그리고 다시 로드합니다:

`firewall-cmd --reload`

!!! 주의

    원격 서버 또는 VPS에서 작업 중이라면 마지막 명령을 실행하지 마세요! 원격 서버에서 `ssh` 서비스를 제거하지 마세요. 다른 방법으로 쉘에 접근할 수 있는 경우에만 이 작업을 수행하세요. (아래 참조).
    
    방화벽으로부터 `SSH` 서비스 접근을 차단할 경우, 방화벽을 통한 SSH 접근 방법이 없는 상태가 될 수 있으며, 이 경우 최악의 경우 서버를 직접 고치거나 지원팀에 문의하거나 제어판을 통해 OS를 재설치해야 할 수 있습니다 (서버가 물리적 또는 가상인지에 따라 다릅니다).

### 새로운 존 사용 - 관리 IP 추가

이제 "admin" 영역을 사용하여 원래 단계를 반복하십시오.

```
firewall-cmd --zone=admin --add-source=192.168.1.122
firewall-cmd --zone admin --add-service=ssh
```

이제 존을 나열하여 존이 올바르게 보이고 서비스가 제대로 추가되었는지 확인합니다:

`firewall-cmd --zone=admin --list-all`

규칙이 제대로 작동하는지 테스트합니다. 테스트를 위해:

1. 상기한 IP (위에서는 192.168.1.122)를 사용하여 root 또는 sudo 권한이 있는 사용자로 SSH합니다 (*root 사용자를 여기서 사용하는 이유는 해당 호스트에서 실행해야 하는 명령을 위해 사용됩니다. sudo 사용자를 사용하는 경우, 연결 후 `sudo -s`를 기억하세요*).
2. 연결한 후, `tail /var/log/secure`을 실행하면 다음과 같이 비슷한 출력이 표시됩니다:

```bash
Feb 14 22:02:34 serverhostname sshd[9805]: Accepted password for root from 192.168.1.122 port 42854 ssh2
Feb 14 22:02:34 serverhostname sshd[9805]: pam_unix(sshd:session): session opened for user root by (uid=0)
```
이를 통해 SSH 연결의 출발지 IP가 방금 "admin" 존에 추가한 IP와 동일한 IP임을 확인할 수 있습니다. 따라서 이 규칙을 영구적으로 적용할 수 있습니다:

`firewall-cmd --runtime-to-permanent`

규칙을 추가한 후 잊지 말고 재로드합니다:

`firewall-cmd --reload`

물론 "admin" 존에 추가해야 할 다른 서비스들도 있을 수 있습니다만, 지금은 ssh가 가장 논리적인 선택입니다.

!!! 주의

    기본적으로 "public" 존에는 `ssh` 서비스가 활성화되어 있습니다. 이는 보안상의 위험이 될 수 있습니다. "admin" 존을 생성하고, `ssh`를 할당하고, 테스트한 후, public 존에서 서비스를 제거할 수 있습니다.

추가해야 할 관리용 IP가 여러 개인 경우 (매우 가능성이 높음), 해당 존에 소스를 추가하기만 하면 됩니다. 이 경우 "admin" 존에 IP를 추가합니다:

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

!!! 참고 사항

    원격 서버 또는 VPS에서 작업하는 경우, 언제나 같은 IP를 사용하지 않는 인터넷 연결이 있는 경우, `SSH` 서비스를 자신의 인터넷 서비스 제공업체 또는 지역의 IP 주소 범위에 열어두는 것이 좋습니다. 이렇게 하면 자체 방화벽에 의해 잠금이 걸릴 위험을 줄일 수 있습니다.
    
    많은 ISP들은 전용 IP 주소에 대해 추가 요금을 부과하며, 제공하지 않는 경우도 있으므로 신중하게 고려해야 합니다.
    
    여기서 제시된 예제는 자체 개인 네트워크의 IP를 사용하여 로컬 서버에 접근하는 것으로 가정합니다.

## ICMP 규칙

이제 `iptables` 방화벽의 다른 줄을 살펴보고 `firewalld`에서 모방해야 할 것입니다 - ICMP 규칙입니다:

`iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

신입자들을 위해 말씀드리면, ICMP는 오류 보고를 위해 설계된 데이터 전송 프로토콜입니다. 기본적으로 머신과 연결하는 데 문제가 발생했을 때 알려줍니다.

실제로 우리는 ICMP를 로컬 IP(이 경우 192.168.1.0/24)에 대해 열어두는 것이 좋을 것입니다. 하지만 "public" 및 "admin" 존은 기본적으로 ICMP가 켜져 있으므로 첫 번째로 "public" 및 "admin" 존에서 해당 네트워크 주소로의 ICMP를 제한하는 것이 좋습니다.

다시 말하지만, 이는 데모 목적으로 제공된 것입니다. 관리 사용자가 서버에 대한 ICMP를 할당받아야 하는 것은 당연하며, LAN 네트워크 IP의 구성원이기 때문에 아마도 할당받을 것입니다.

"public" 존에서 ICMP를 비활성화하려면 다음과 같이 실행합니다:

`firewall-cmd --zone=public --add-icmp-block={echo-request,echo-reply} --permanent`

그런 다음 "trusted" 영역에서 동일한 작업을 수행합니다.

`firewall-cmd --zone=trusted --add-icmp-block={echo-request,echo-reply} --permanent`

여기서 중괄호 "{}"를 소개했습니다. 중괄호를 사용하여 두 개 이상의 매개변수를 지정할 수 있습니다.  항상 이러한 변경 사항을 적용한 후에는 리로드해야 합니다:

`firewall-cmd --reload`

비허용 IP에서 ping을 사용하여 테스트하면 다음과 같은 결과가 나타납니다:

```bash
ping 192.168.1.104
PING 192.168.1.104 (192.168.1.104) 56(84) bytes of data.
From 192.168.1.104 icmp_seq=1 Packet filtered
From 192.168.1.104 icmp_seq=2 Packet filtered
From 192.168.1.104 icmp_seq=3 Packet filtered
```

## 웹 서버 포트

여기에는 웹 페이지를 제공하는 데 필요한 프로토콜인 `http` 및 `https`를 허용하는 `iptables` 스크립트가 있습니다:

```
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

그리고 이전에 여러 번 본 적이 있는 `firewalld`에 해당하는 항목은 다음과 같습니다.

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

이 모든 것은 좋지만, 예를 들어 Nextcloud 서비스를 http/https로 실행하고 신뢰된 네트워크만 해당 서비스에 액세스하도록 하려면 어떻게 해야 할까요?  이는 일반적인 상황입니다! 이러한 상황은 항상 발생하며, 실제로 공개적으로 트래픽을 허용하되 실제로 액세스해야 하는 사용자를 고려하지 않는 것은 큰 보안 취약점입니다.

이전에 사용한 "trusted" 존 정보를 사용할 수 없습니다. 그것은 테스트를 위한 것이었습니다. 최소한 우리의 LAN IP 블록이 "trusted"에 추가된 것으로 가정해야 합니다. 이렇게 보일 것입니다:

`firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent`

그런 다음 존에 서비스를 추가해야 합니다:

`firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent`

만약 해당 서비스를 "public" 존에 추가했다면, 제거해야 합니다:

`firewall-cmd --zone=public --remove-service=http --remove-service=https --permanent`

이제 새로고침 합니다:

`firewall-cmd --reload`

## FTP 포트

이제 `iptables` 스크립트로 돌아가봅시다. 다음은 FTP와 관련된 규칙입니다:

```
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
```

이 부분의 스크립트는 표준 FTP 포트(20 및 21)와 몇 가지 추가적인 패시브 포트를 다룹니다. 이러한 종류의 규칙은 일반적으로 [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md)와 같은 ftp 서버에서 필요합니다. 일반적으로 이러한 규칙은 고객으로부터의 ftp 연결을 허용하기 위해 공개적으로 공개적인 웹 서버에 적용됩니다.

`firewalld`에는 ftp-data 서비스(포트 20)가 없습니다. 여기에 나열된 7000에서 7500 포트는 패시브 FTP 연결을 위한 것입니다. 다시 말하지만, `firewalld`에서는 이를 직접 처리할 방법이 없습니다. SFTP로 전환하여 여기서 포트 허용 규칙을 단순화할 수 있으며, 현재에는 추천되는 방법일 수도 있습니다.

그러나 여기서 우리는 `iptables` 규칙을 `firewalld`로 변환하는 것을 보여주려고 합니다. 이러한 문제를 해결하기 위해 다음과 같이 진행할 수 있습니다.

먼저, 웹 서비스를 호스트하는 존에 ftp 서비스를 추가합니다. 이 예제에서는 "public"일 것으로 예상됩니다:

`firewall-cmd --zone=public --add-service=ftp --permanent`

그런 다음 ftp-data 포트를 추가합니다:

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

다음으로 패시브 연결 포트를 추가합니다:

`firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent`

그리고 마지막으로, 리로드합니다:

`firewall-cmd --reload`

## 데이터베이스 포트

웹 서버를 다루면 거의 항상 데이터베이스도 다루게 됩니다. 데이터베이스에 대한 액세스는 다른 서비스에 적용한 것과 동일한 주의가 필요합니다. 액세스가 전 세계에서 필요하지 않다면 "public" 이외의 다른 곳에 규칙을 적용하세요.  또 하나의 고려사항은 귀사가 액세스를 제공해야 하는지 여부입니다. 이 또한 귀사의 환경에 따라 다를 수 있습니다. 저는 이전에 일한 곳에서 고객들을 위해 호스팅된 웹 서버를 운영했습니다. 많은 고객이 워드프레스 사이트를 사용했고, 그 중 아무도 `MariaDB`에 대한 프런트엔드 액세스를 필요로 하거나 요청하지 않았습니다. 고객이 더 많은 액세스를 필요로 할 경우, 고객의 웹 서버를 위해 LXD 컨테이너를 생성하고 고객이 원하는대로 방화벽을 구성하고 서버에서 발생하는 일에 대해 책임을 넘겨줬습니다. 그래도 공개 서버인 경우, `phpmyadmin` 또는 `MariaDB`에 대한 기타 프런트엔드 액세스를 제공해야 할 수 있습니다. 이 경우 데이터베이스의 암호 요구 사항을 고려하고 기본값이 아닌 데이터베이스 사용자로 설정해야 합니다. 나에게 있어서 암호 길이가 암호를 만들 때 [주요 고려 사항](https://xkcd.com/936/)입니다.

물론 암호 보안은 다른 문서에서 다루어야 할 주제이므로 여기서는 데이터베이스 액세스에 대한 `iptables` 라인이 다음과 같다고 가정합니다:

`iptables -A INPUT -p tcp -m tcp --dport=3600 -j ACCEPT`

 이 경우 `firewalld` 변환을 위해 서비스를 "public" 영역에 추가하기만 하면 됩니다.

`firewall-cmd --zone=public --add-service=mysql --permanent`

### PostgreSQL 고려 사항

Postgresql은 자체 서비스 포트를 사용합니다. 다음은 IP 테이블 규칙 예제입니다:

`iptables -A INPUT -p tcp -m tcp --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

공개적으로 알려진 웹 서버에서는 덜 흔할 수 있지만, 내부 리소스로 더 흔할 수 있습니다. 동일한 보안 고려 사항이 적용됩니다. 신뢰된 네트워크에 서버가 있으면(우리의 예에서는 192.168.1.0/24) 아마 모두에게 액세스할 필요가 없을 수 있습니다. Postgresql에는 보다 상세한 액세스 권한을 다루기 위한 액세스 목록이 있습니다. 우리의 `firewalld` 규칙은 다음과 같이 보일 것입니다:

`firewall-cmd --zone=trusted --add-service=postgresql`

## DNS 포트

사설 또는 공개 DNS 서버를 운영한다는 것은 이 서비스를 보호하기 위해 작성하는 규칙에 주의해야 한다는 것을 의미합니다. 사설 DNS 서버가 있다면 이러한 iptables 규칙과 같을 수 있습니다(대부분의 DNS 서비스는 UDP 대신 TCP를 사용합니다. 그러나 항상 그렇지 않을 수 있습니다):

`iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT`

이러한 경우, "trusted" 존에만 허용해야 합니다. 우리는 이미 "trusted" 존의 소스를 설정했으므로 해당 서비스를 존에 추가하기만 하면 됩니다:

`firewall-cmd --zone=trusted --add-service=dns`

공개적으로 공개 DNS 서버의 경우, 동일한 서비스를 "public" 존에 추가하면 됩니다:

`firewall-cmd --zone=public --add-service=dns`

## 등록 규칙에 대해 자세히 알아보기

!!! 참고 사항

    원하는 경우 nftables 규칙을 나열하여 모든 규칙을 *나열할 수* 있습니다. 이를 위해서는 nftables 규칙을 나열하는 명령어인 `nft list ruleset`을 사용할 수 있습니다. 이 방법은 권장하지 않지만 필요한 경우에만 사용하시기 바랍니다.

우리가 아직 많이 하지 않았던 하나는 규칙을 나열하는 것입니다. 이것은 존(zone)별로 할 수 있습니다. 다음은 사용한 존들을 사용하는 예제입니다. 규칙을 영구적으로 이동하기 전에 존을 먼저 나열하는 것도 좋은 아이디어입니다.

`firewall-cmd --list-all --zone=trusted`

위에서 적용한 내용을 볼 수 있습니다.

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: dns
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```

이는 모든 존에 적용될 수 있습니다. 예를 들어, 다음은 현재까지의 "public" 존입니다.

`firewall-cmd --list-all --zone=public`

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client ftp http https
  ports: 20/tcp 7000-7500/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```
"ssh" 액세스를 서비스에서 제거하고 ICMP "echo-reply" 및 "echo-request"를 차단했습니다.

현재까지 "admin" 존은 다음과 같습니다:

`firewall-cmd --list-all --zone=admin`

```bash
  admin (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.122 192.168.1.151
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

## 관련 규정 제정

구체적으로 명시한 문서를 찾지 못했지만, 기본적으로 `firewalld`는 아래의 `iptables` 규칙을 내부적으로 처리하는 것으로 보입니다(이에 대해 잘못된 사항을 알고 계신다면 이를 수정해주시기 바랍니다!):

`iptables -A INPUT -m state --state ESTABLISHED, RELATED -j ACCEPT`

## 인터페이스

기본적으로 `firewalld`는 모든 사용 가능한 인터페이스에서 수신대기하도록 설정되어 있습니다. 여러 인터페이스가 있는 bare-metal 서버의 경우 해당 인터페이스를 해당 네트워크를 바라보도록 존에 할당해야 할 필요가 있을 것입니다.

우리의 예제에서는 인터페이스를 추가하지 않았습니다. 실험용으로 LXD 컨테이너를 사용하고 있기 때문에 사용 가능한 인터페이스가 하나뿐입니다. 작업할 인터페이스는 하나뿐입니다. 예를 들어, "public" 존이 Ethernet 포트 enp3s0을 사용하도록 구성되어야 하며 해당 포트에 공개 IP가 있습니다. 그리고 "trusted" 및 "admin" 존은 LAN 인터페이스에 위치할 것입니다.

이러한 영역을 적절한 인터페이스에 할당하려면 다음 명령을 사용합니다.

```
firewall-cmd --zone=public --change-interface=enp3s0 --permanent
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent
firewall-cmd --reload
```
## 일반적인 방화벽 cmd 명령

이미 몇 가지 명령어를 사용해 보았습니다. 여기에 더 많은 일반적인 명령어와 그에 대한 결과를 정리하였습니다.

| 명령                                           | 결과                                                                |
| -------------------------------------------- | ----------------------------------------------------------------- |
| `firewall-cmd --list-all-zones`              | `firewall-cmd --list-all --zone=[zone]`와 비슷하지만 모든 존과 그 내용을 나열합니다. |
| `firewall-cmd --get-default-zone`            | 기본 존을 보여줍니다. 변경하지 않은 경우 "public"입니다.                              |
| `firewall-cmd --list-services --zone=[zone]` | 존에 활성화된 모든 서비스를 나열합니다.                                            |
| `firewall-cmd --list-ports --zone=[zone]`    | 존에서 열린 모든 포트를 나열합니다.                                              |
| `firewall-cmd --get-active-zones`            | 시스템에서 활성화된 존, 해당 활성화된 인터페이스, 서비스 및 포트를 보여줍니다.                     |
| `firewall-cmd --get-services`                | 사용 가능한 모든 서비스를 보여줍니다.                                             |
| `firewall-cmd --runtime-to-permanent`        | --permanent 옵션 없이 입력한 많은 규칙이 있는 경우 재로드하기 전에 이 명령어를 사용하세요.         |

여기에서 다루지 않은 많은 `firewall-cmd` 옵션이 있지만, 가장 많이 사용되는 명령어만 다루었습니다.

## 결론

Rocky Linux에서는 `firewalld`가 권장되고 포함되어 있으므로 `firewalld`가 어떻게 동작하는지 이해하는 것이 좋습니다. `firewalld`를 사용하여 서비스를 적용하는 문서에 포함된 간단한 규칙들은 종종 서버가 사용되는 용도를 고려하지 않으며 해당 서비스를 세계에 공개적으로 허용하는 것 외에 다른 옵션을 제공하지 않습니다. 이는 보안 결함을 가지게 됩니다.

이러한 지침을 볼 때, 서버가 사용되는 용도와 해당 서비스가 전 세계에 공개적으로 허용되어야 하는지 여부를 고려하세요. 그렇지 않으면 위에서 설명한 대로 더 많은 세분화된 규칙을 사용하는 것을 고려하십시오. 작성자는 여전히 `firewalld`로 전환하는 것이 100% 편하지는 않지만 향후 문서에서 `firewalld`를 사용할 가능성이 높습니다.

작성한 문서와 결과를 실험하는 과정이 저에게 매우 도움이 되었습니다. 다른 누군가에게도 도움이 될 것입니다. 이것은 `firewalld`에 대한 완벽한 가이드가 아니라 시작점으로 생각하시기 바랍니다.                                         
