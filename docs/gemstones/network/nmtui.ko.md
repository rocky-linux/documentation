---
title: nmtui - 네트워크 관리 도구
author: tianci li
contributors: Steven Spencer, Neil Hanlon
update: 2021-10-23
---

# 소개

GNU/Linux에 처음 접하는 초보 사용자를 위해 운영 체제를 설치한 후 기계를 인터넷에 연결하는 방법을 고려해야 합니다. 이 문서에서는 IP 주소, 서브넷 마스크, 게이트웨이 및 DNS를 구성하는 방법을 안내합니다. 참고할 몇 가지 방법이 있습니다. 초보자든 익숙한 사용자든 빠르게 시작할 수 있다고 믿습니다.

## nmtui

`NetworkManager`는 서버와 데스크톱 환경을 지원하는 표준 Linux 네트워크 구성 도구 모음입니다. 최근 대부분의 인기있는 배포판에서 지원됩니다. 이 네트워크 구성 도구 세트는 Rocky Linux 8 이상의 버전에 적합합니다. 그래픽으로 네트워크 정보를 구성하려면(`nmtui` 명령 줄) 다음과 같이 수행하면 됩니다:

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI |          |
| ------------------ | -------- |
| 연결 편집              |          |
| 연결 활성화             |          |
| 시스템 호스트 이름 설정      |          |
| 종료                 |          |
|                    | \<OK\> |

<kbd>Tab</kbd> 키 또는 <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd> 키를 사용하여 특정 항목을 선택할 수 있습니다. 특정 네트워크 정보를 변경하려면 **Edit a connection**을 선택한 다음 <kbd>Enter</kbd>키를 누릅니다. 다른 네트워크 카드를 선택하고 **Edit..**을 선택하여 편집합니다.

### DHCP IPv4

IPv4의 경우 DHCP 방식을 사용하여 네트워크 정보를 얻으려면 *IPv4 CONFIGURATION*를 **&lt;Automatic&gt;**로 선택한 다음 `systemctl restart NetworkManager.service`에서 터미널을 실행하기만 하면 됩니다. 드문 경우이지만 네트워크 카드를 전환해야 적용할 수 있습니다. 드문 경우이지만 네트워크 카드를 사용하려면 변경 사항이 적용되려면 네트워크 카드를 비활성화하고 다시 활성화해야 할 수도 있습니다. 예를 들어, `nmcli connection down ens33`, `nmcli connection up ens33`.


### 수동으로 네트워크 정보 수정하기

모든 IPv4 네트워크 정보를 수동으로 수정하려면 *IPv4 CONFIGURATION* 다음에 **&lt;Manual&gt;**를 선택하고 줄마다 정보를 추가해야 합니다. 예를 들어, 다음과 같이 입력하세요: 예를 들어, 저는 이것을 좋아합니다:

| 항목          | 값                |
| ----------- | ---------------- |
| Addresses   | 192.168.100.4/24 |
| Gateway     | 192.168.100.1    |
| DNS servers | 8.8.8.8          |

그런 다음 \< OK \>을 클릭하고 단계별로 터미널 인터페이스로 돌아가서 `systemctl restart NetworkManager.service`를 실행합니다. 마찬가지로 드문 경우지만 적용하려면 네트워크 카드를 켜고 꺼야 합니다.

## 구성 파일 방식 변경

업스트림이든 다운스트림이든 모든 RHEL <font color="red">7.x</font> 또는 <font color="red">8.x</font> 배포는 동일한 방식으로 구성됩니다. 네트워크 정보의 설정 파일은 **/etc/sysconfig/network-scripts/** 디렉토리에 저장되며 하나의 네트워크 카드는 하나의 설정 파일에 해당합니다. 구성 파일에는 다음 표와 같이 많은 매개변수가 있습니다. 꼭 기억하세요! 매개변수는 대문자여야 합니다.

!!! 주의

    RHEL 9.x 배포판에서 NIC 구성 파일이 저장되는 디렉토리의 위치가 변경되었습니다(예: **/etc/NetworkManager/system-connections/**). 자세한 내용은 [여기](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index)를 참조하십시오.

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

| 파라미터 이름:             | 뜻                                                                                                                                              | 예시                                  |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| DEVICE               | 시스템 논리 장치 이름                                                                                                                                   | DEVICE=ens33                        |
| ONBOOT               | 네트워크 카드가 시스템과 함께 자동으로 시작되는지 여부, yes 또는 no로 선택할 수 있습니다.                                                                                         | ONBOOT=yes                          |
| TYPE                 | 네트워크 카드 인터페이스 유형(일반적으로 이더넷)                                                                                                                    | TYPE=Ethernet                       |
| BOOTPROTO            | IP를 얻는 방법은 DHCP 동적 수집, 또는 정적을 사용한 정적 수동 구성일 수 있습니다                                                                                             | BOOTPROTO=static                    |
| IPADDR               | 네트워크 카드의 IP 주소, BOOTPROTO=static일 때 이 매개변수가 적용됩니다.                                                                                             | IPADDR=192.168.100.4                |
| HWADDR               | 하드웨어 주소(예: MAC 주소)                                                                                                                             | HWADDR=00:0C:29:84:F6:9C            |
| NETMASK              | 10진수 서브넷 마스크                                                                                                                                   | NETMASK=255.255.255.0               |
| PREFIX               | 숫자로 표시되는 서브넷 마스크                                                                                                                               | PREFIX=24                           |
| GATEWAY              | 게이트웨이, 네트워크 카드가 여러 개인 경우 이 매개 변수는 한 번만 나타날 수 있습니다                                                                                              | GATEWAY=192.168.100.1               |
| PEERDNS              | yes인 경우 여기에 정의된 DNS 매개변수는 /etc/resolv.conf를 수정합니다. no인 경우 /etc/resolv.conf가 수정되지 않습니다. DHCP를 사용하는 경우 기본값은 yes입니다.                              | PEERDNS=yes                         |
| DNS1                 | 기본 DNS가 선택되며 PEERDNS=no인 경우에만 적용됩니다.                                                                                                           | DNS1=8.8.8.8                        |
| DNS2                 | 대체 DNS, PEERDNS=no인 경우에만 유효                                                                                                                    | DNS2=114.114.114.114                |
| BROWSER_ONLY         | 브라우저만 허용할지 여부                                                                                                                                  | BROWSER_ONLY=no                     |
| USERCTL              | 일반 사용자가 네트워크 카드 장치를 제어할 수 있는지 여부, yes는 허용을 의미하고 no 는 허용되지 않음을 의미합니다.                                                                           | USERCTL=no                          |
| UUID                 | 범용 고유 식별 코드, 주요 기능은 하드웨어를 식별하는 것입니다. 일반적으로, 입력할 필요가 없습니다                                                                                       |                                     |
| PROXY_METHOD         | 프록시 메서드(일반적으로 없음) 는 비워 둘 수 있습니다                                                                                                                |                                     |
| IPV4_FAILURE_FATAL | Yes인 경우 ipv4 구성이 실패한 후 장치가 비활성화됨을 의미합니다. no는 비활성화되지 않음을 의미합니다.                                                                                 | IPV4_FAILURE_FATAL=no             |
| IPV6INIT             | IPV6를 사용할지 여부, 사용하려면 yes, 사용하지 않으면 no. IPV6INIT=yes인 경우 두 매개변수 IPV6ADDR 및 IPV6_DEFAULTGW도 활성화할 수 있습니다. 전자는 IPV6 주소를 나타내고 후자는 지정된 게이트웨이를 나타냅니다. | IPV6INIT=yes                        |
| IPV6_AUTOCONF        | IPV6 자동 구성을 사용할지 여부, yes는 사용을 의미하며, no는 사용하지 않음을 의미합니다                                                                                         | IPV6_AUTOCONF=yes                   |
| IPV6_DEFROUTE        | IPV6에 기본 경로를 제공할지 여부                                                                                                                           | IPV6_DEFROUTE=yes                   |
| IPV6_FAILURE_FATAL | IPV6 구성 실패 후 장치 비활성화 여부                                                                                                                        | IPV6_FAILURE_FATAL=no             |
| IPV6_ADDR_GEN_MODE | IPV6 주소 모델 생성, 선택적 값은 stable-privacy 및 eui64입니다.                                                                                               | IPV6_ADDR_GEN_MODE=stable-privacy |

구성 파일이 성공적으로 수정된 후 네트워크 카드 서비스 `systemctl restart NetworkManager.service`를 다시 시작해야 합니다.

### IPV4에 대한 권장 구성

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
IPV4_FAILURE_FATAL=no
BROWSER_ONLY=no
BOOTPROTO=static
PEERDNS=no
IPADDR=192.168.100.4
PREFIX=24
GATEWAY=192.168.100.1
DNS1=8.8.8.8
DNS2=114.114.114.114
```

### IPV6에 대한 권장 구성

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

## 네트워크 정보 보기

`ip a` 또는 `nmcli device show`
