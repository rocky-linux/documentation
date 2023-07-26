---
title: Bind 개인 DNS 서버
author: Steven Spencer
contributors: Ezequiel Bruni, k3ym0
tested_with: 8.5, 8.6, 9.0
tags:
  - dns
  - bind
---

# 개인 DNS 서버 구성하기: Bind 사용하기

## 전제 조건 및 가정

* Rocky Linux를 실행하는 서버
* 인터넷을 통하지 않고 로컬에서만 액세스해야 하는 여러 내부 서버
* 동일한 네트워크에 존재하는 동일한 서버에 액세스해야 하는 여러 워크스테이션
* 명령 줄에서 명령 입력에 익숙한 수준
* 명령 줄 편집기에 익숙함(이 예에서는 _vi_를 사용함)
* 방화벽 규칙을 생성하기 위해 _firewalld_ 또는 _iptables_를 사용할 수 있음. _iptables_ 방화벽 설정에 대한 옵션과 _firewalld_ 방화벽 설정에 대한 옵션을 모두 제공합니다. _iptables_를 사용할 계획인 경우 [Iptables 방화벽 활성화](../security/enabling_iptables_firewall.md) 절차를 사용하세요.

## 소개

외부 또는 공개 DNS 서버는 인터넷에서 호스트 이름을 IP 주소로 매핑하고 PTR("pointer" 또는 "reverse") 레코드의 경우 IP를 호스트 이름으로 매핑하는 데 사용됩니다. 이것은 인터넷의 필수적인 부분입니다. 이렇게 하면 메일 서버, 웹 서버, FTP 서버 또는 기타 많은 서버와 서비스가 어디에 있든 기대대로 작동합니다.

개인 네트워크, 특히 여러 시스템을 개발하는 데 사용되는 네트워크의 경우 Rocky Linux 워크스테이션의 */etc/hosts* 파일을 사용하여 이름을 IP 주소에 매핑할 수 있습니다.

이것은 워크스테이션에서는 작동하지만 네트워크의 다른 기계에서는 작동하지 않습니다. 모든 기계에 적용하려면 시간을 들여 로컬, 개인 DNS 서버를 만들어 모든 기기에 대해 이를 처리하는 것이 가장 좋은 방법입니다.

공용 DNS 서버 및 리졸버를 생성하는 경우 이 저자는 Production 수준의 보다 견고한 [PowerDNS](https://www.powerdns.com/) 인증 및 재귀 DNS를 권장합니다. PowerDNS는 Rocky Linux 서버에 쉽게 설치할 수 있습니다. 그러나 이는 외부 세계에 DNS 서버를 노출하지 않을 로컬 네트워크에 대해서는 오버킬입니다. 이것이 우리가 이 예제에서 _bind_를 선택한 이유입니다.

### DNS 서버 구성 요소 설명

앞서 언급한대로 DNS는 권한 서버와 재귀 서버로 서비스를 분리합니다. 이 서비스는 이제 서로 다른 하드웨어나 컨테이너에서 동작하는 것이 권장됩니다.

권한 서버는 모든 IP 주소와 호스트 이름의 저장 영역이며 재귀 서버는 주소와 호스트 이름을 조회하는 데 사용됩니다. 개인 DNS 서버의 경우 권한 및 재귀 서버 서비스가 함께 실행됩니다.

## 바인드 설치 및 활성화

첫 번째 단계는 패키지를 설치하는 것입니다. _bind_의 경우 다음 명령을 실행해야 합니다.

```
dnf install bind bind-utils
```

_bind_에 대한 서비스 데몬은 _named_이며, 이를 부팅 시 자동으로 시작하도록 활성화해야 합니다.

```
systemctl enable named
```

그런 다음 시작해야 합니다.

```
systemctl start named
```

## 구성

구성 파일을 변경하기 전에, 원래 설치된 작동 파일의 백업 복사본을 만드는 것이 좋습니다. 이 경우 _named.conf_입니다.

```
cp /etc/named.conf /etc/named.conf.orig
```

그렇게 하면 구성 파일에 오류가 도입되면 나중에 도움이 됩니다. 변경하기 전에 백업 복사본을 만드는 것은 *항상* 좋은 생각입니다.

이러한 변경 사항은 named.conf 파일을 편집해야 합니다. 여기서는 _vi_를 사용하지만, 사용자의 즐겨찾는 명령 줄 편집기로 대체할 수 있습니다(_vi_보다 사용하기 쉬운 `nano` 편집기도 Rocky Linux에 설치되어 있습니다).

```
vi /etc/named.conf
```

먼저 "options" 섹션에 있는 이 두 줄을 "#" 기호로 주석 처리하여 localhost에서의 listening을 비활성화하고 외부로의 연결을 효과적으로 차단합니다. 이것이 하는 일은 외부 세계와의 연결을 효과적으로 차단하는 것입니다.

특히 워크스테이션에 이 DNS를 추가할 때 도움이 됩니다. DNS 서버는 요청하는 IP 주소가 로컬일 때만 응답하고 조회하는 서비스가 인터넷에 있는 서비스인 경우 아예 응답하지 않기를 원합니다.

이렇게 하면 다른 구성된 DNS 서버가 거의 즉시 인터넷 기반 서비스를 조회하게 됩니다.

```
options {
#       listen-on port 53 { 127.0.0.1; };
#       listen-on-v6 port 53 { ::1; };
```

마지막으로 *named.conf* 파일의 맨 아래로 이동하여 네트워크에 대한 섹션을 추가합니다. 우리의 예제에서는 ourdomain을 사용하므로 LAN 호스트에 원하는 이름을 대입하세요.

```
# 기본 순방향 및 역방향 영역
//forward zone
zone "ourdomain.lan" IN {
     type master;
     file "ourdomain.lan.db";
     allow-update { none; };
    allow-query {any; };
};
//reverse zone
zone "1.168.192.in-addr.arpa" IN {
     type master;
     file "ourdomain.lan.rev";
     allow-update { none; };
    allow-query { any; };
};
```

이제 변경 사항을 저장합니다(_vi_의 경우 `SHIFT:wq!`).

## 정방향 및 역방향 레코드

다음으로 `/var/named`에 두 개의 파일을 생성해야 합니다. 이 파일은 DNS에 포함하고 싶은 네트워크의 기계를 추가할 경우 편집할 파일입니다.

첫 번째 파일은 IP 주소를 호스트 이름에 매핑하는 전방 파일입니다. 여기서 다시 "ourdomain"을 예제로 사용합니다. 이 예제에서 로컬 DNS의 IP는 192.168.1.136입니다. 호스트는 이 파일의 끝에 추가됩니다.

```
vi /var/named/ourdomain.lan.db
```

이 파일을 편집한 후 다음과 같이 보일 것입니다.

```
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;IP for Name Server
dns-primary IN A 192.168.1.136

;A Record for IP address to Hostname
wiki IN A 192.168.1.13
www IN A 192.168.1.14
devel IN A 192.168.1.15
```

원하는 만큼 호스트와 그들의 IP 주소를 파일 맨 아래에 추가한 다음 변경 사항을 저장하세요.

그다음, 호스트 이름을 IP 주소에 매핑하는 후방 파일이 필요합니다. 이 경우, IP의 마지막 옥텟만 필요합니다(IPv4 주소에서는 점으로 구분된 각 숫자는 옥텟입니다) 그리고 PTR과 호스트 이름을 추가해야 합니다.

```
vi /var/named/ourdomain.lan.rev
```

완료되면 파일은 다음과 같아야 합니다.:

```
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;Reverse lookup for Name Server
136 IN PTR dns-primary.ourdomain.lan.

;PTR Record IP address to HostName
13 IN PTR wiki.ourdomain.lan.
14 IN PTR www.ourdomain.lan.
15 IN PTR devel.ourdomain.lan.
```

전방 파일에 나타나는 모든 호스트 이름을 추가하고 변경 사항을 저장하세요.

### 이 모든 것이 의미하는 것

이 모든 내용이 추가되었고 _bind_ DNS 서버를 재시작하기 전에, 이 두 파일에서 사용하는 몇 가지 용어에 대해 알아보겠습니다.

각 용어의 의미를 모르면 단순히 기능만 작동하는 것으로는 충분치 않습니다, 그렇지 않나요?

* **TTL**은 두 파일 모두에 나타나며 "Time To Live"를 나타냅니다. TTL은 DNS 서버가 캐시를 유지하는 시간으로, 새로운 복사본을 요청하기 전에 이 캐시를 유지할 시간을 DNS 서버에 알려줍니다. 이 경우 TTL은 특정 레코드 TTL이 설정되지 않으면 모든 레코드의 기본 설정입니다. 여기서는 86400초 또는 24시간입니다.
* **IN**은 "Internet"의 약어입니다. 이 경우 실제로 인터넷을 사용하지 않고, 이를 인트라넷으로 간주하세요.
* **SOA**는 "Start Of Authority(권한시작)"로서 도메인의 기본 DNS 서버를 나타냅니다.
* **NS**는  "name server"의 약어입니다.
* **Serial**은 DNS 서버가 영역 파일의 내용이 최신인지 확인하는 데 사용되는 값입니다.
* **Refresh**는 슬레이브 DNS 서버가 마스터로부터 영역 전송을 얼마나 자주 해야 하는지를 지정합니다.
* **Retry**는 영역 전송이 실패한 후 다시 시도하기까지의 시간을 지정합니다.
* **Expire**는 마스터에 연결할 수 없을 때 슬레이브 서버가 쿼리에 응답해야 하는 대기 시간을 지정합니다.
* **A**는 호스트 주소 또는 전방 레코드를 나타내며 전방 파일에만 사용됩니다(위에 표시됨).
* **PTR**은 "포인터" 또는 "역"으로 더 잘 알려져 있으며 후방 파일에만 사용됩니다(위에 표시됨).

## 구성 테스트

모든 파일을 추가한 후 _bind_ 서비스를 다시 시작하기 전에 구성 파일과 영역이 잘 작동하는지 확인해야 합니다.

주요 구성을 확인하세요:

```
named-checkconf
```

모두 정상이라면 빈 결과를 반환해야 합니다.

그런 다음 정방향 영역을 확인합니다.

```
named-checkzone ourdomain.lan /var/named/ourdomain.lan.db
```

모두 정상이면 다음과 같이 반환됩니다.

```
zone ourdomain.lan/IN: loaded serial 2019061800
OK
```

그리고 마지막으로 역방향 영역을 확인합니다.

```
named-checkzone 192.168.1.136 /var/named/ourdomain.lan.rev
```

모두 정상이면 다음과 같은 결과를 반환해야 합니다.

```
zone 192.168.1.136/IN: loaded serial 2019061800
OK
```

모든 것이 정상으로 보인다면 _bind_를 다시 시작합니다.

```
systemctl restart named
```

=== "9"

    ## 9 LAN에서 IPv4 사용
    
    LAN에서 오직 IPv4만 사용하려면 `/etc/sysconfig/named`에서 하나의 변경사항을 해야 합니다.

    ```
    vi /etc/sysconfig/named
    ```


    그런 다음 파일 맨 아래에 다음을 추가하십시오.

    ```
    OPTIONS="-4"
    ```


    이제 변경 사항을 저장합니다(_vi_의 경우 `SHIFT:wq!`).
    
    ## 9 컴퓨터 테스트
    
    로컬 DNS에 추가한 서버에 액세스하려는 각 시스템에 DNS 서버(예: 192.168.1.136)를 추가해야 합니다. Rocky Linux 워크스테이션에서 이 작업을 수행하는 방법에 대한 예를 보여줄 뿐이지만 Windows 및 Mac 시스템뿐만 아니라 다른 Linux 배포판에도 유사한 방법이 있습니다.
    
    현재 할당된 DNS 서버를 대체하는 대신 DNS 서버를 목록에 추가하면 됩니다. 인터넷 접속을 위해 현재 할당된 DNS 서버가 필요하기 때문입니다. 이러한 DNS 서버는 DHCP(Dynamic Host Configuration Protocol)에 의해 할당되거나 정적으로 할당될 수 있습니다.
    
    `nmcli`를 사용하여 로컬 DNS를 추가한 다음 연결을 재시작하세요. 
    
    ??? "바보같은 프로필 이름" 경고
    
        NetworkManager에서 연결은 장치 이름이 아닌 프로필 이름으로 수정됩니다. 이것은 "유선 연결 1" 또는 "무선 연결 1"과 같은 것일 수 있습니다. 매개변수 없이 `nmcli`를 실행하여 프로파일을 볼 수 있습니다.

        ```
        nmcli
        ```


        그러면 다음과 같은 출력이 표시됩니다.

        ```bash
        enp0s3: connected to Wired Connection 1
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        inet6 fe80::f511:a91b:90b:d9b9/64
        route6 fe80::/64 metric 1024

        lo: unmanaged
            "lo"
            loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

        DNS configuration:
            servers: 192.168.1.1
            domains: localdomain
            interface: enp0s3

        Use "nmcli device show" to get complete information about known devices and
        "nmcli connection show" to get an overview on active connection profiles.
        ```


        연결 수정을 시작하기 전에 인터페이스 이름과 같이 적절한 이름을 지정해야 합니다(**참고사항** 아래의 "\"는 이름의 공백을 이스케이프 처리함).

        ```
        nmcli connection modify Wired\ connection\ 1 con-name enp0s3
        ```


        이 작업을 완료한 후 `nmcli`를 다시 실행하면 다음과 같은 내용이 표시됩니다.

        ```bash
        enp0s3: connected to enp0s3
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        ...
        ```


        이렇게 하면 DNS의 나머지 구성이 훨씬 쉬워집니다!
    
    연결 프로파일 이름이 "enp0s3"인 것으로 가정하고, 이미 구성된 DNS를 유지하면서 로컬 DNS 서버를 추가합니다:

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,192.168.1.1'
    ```


    여러 개의 DNS 서버를 가질 수 있으며, 공용 DNS 서버로 구성된 기기의 경우 구글의 공개 DNS와 같이 다음과 같이 할 수 있습니다:

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,8.8.8.8,8.8.4.4'
    ```


    원하는 DNS 서버를 연결에 추가한 후, 로컬 DNS 서버의 호스트를 *ourdomain.lan*으로 해결할 수 있으며 인터넷 호스트도 해결할 수 있습니다.
    
    ## 9 방화벽 규칙 - `firewalld`
    
    !!! 참고 "기본적으로 `firewalld`"
    
         Rocky Linux 9.0 이상에서는 `iptables`` 규칙 사용이 중지되었습니다. 대신 firewalld를 사용해야 합니다.
    
    네트워크나 서비스에 대해 어떤 가정도 하지 않습니다. 단지 LAN 네트워크에 대한 SSH 액세스와 DNS 액세스를 활성화하려 합니다. 이를 위해 기본 제공되는 `firewalld`` zone인 "trusted"를 사용합니다. 또한 "public" zone에서 SSH 액세스를 LAN에 한정하기 위해 일부 서비스 변경이 필요합니다.
    
    첫 번째 단계는 LAN 네트워크를 "신뢰할 수 있는" 영역에 추가하는 것입니다.

    ```
    firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
    ```


    다음으로, 두 가지 서비스를 "trusted" zone에 추가해야 합니다.

    ```
    firewall-cmd --zone=trusted --add-service=ssh --permanent
    firewall-cmd --zone=trusted --add-service=dns --permanent
    ```


    마지막으로, 기본적으로 활성화된 "public" zone에서 SSH 서비스를 제거해야 합니다.

    ```
    firewall-cmd --zone=public --remove-service=ssh --permanent
    ```


    다음으로 방화벽을 다시 로드하고 변경한 zone을 나열합니다.

    ```
    firewall-cmd --reload
    firewall-cmd --zone=trusted --list-all
    ```


    위와 같이 서비스와 소스 네트워크를 올바르게 추가했다면 다음과 같이 나와야 합니다.

    ```
    trusted (active)
        target: ACCEPT
        icmp-block-inversion: no
        interfaces:
        sources: 192.168.1.0/24
        services: dns ssh
        ports:
        protocols:
        forward: no
        masquerade: no
        forward-ports:
        source-ports:
        icmp-blocks:
        rich rules:
    ```


    "public" zone을 나열하면 SSH 액세스가 허용되지 않은 것을 확인할 수 있습니다.

    ```
    firewall-cmd --zone=public --list-all
    ```


    다음과 같이 표시됩니다:

    ```
    public
        target: default
        icmp-block-inversion: no
        interfaces:
        sources:
        services: cockpit dhcpv6-client
        ports:
        protocols:
        forward: no
        masquerade: no
        forward-ports:
        source-ports:
        icmp-blocks:
        rich rules:
    ```


    이러한 규칙은 192.168.1.0/24 네트워크의 호스트로부터 로컬 DNS 서버의 DNS 해결을 가능하게 합니다. 또한 이러한 호스트에서 로컬 DNS 서버로 SSH를 할 수 있습니다.

=== "8"

    ## 8 LAN에서 IPv4 사용
    
    LAN에서 IPv4만 사용하는 경우 두 가지 변경 사항을 해야 합니다. 첫 번째는 `/etc/named.conf`에 있고 두 번째는 `/etc/sysconfig/named`에 있습니다. 먼저 `vi /etc/named.conf`를 사용하여 `named.conf` 파일에 다음 옵션을 options 섹션 어디든 추가해야 합니다.

    ```
    filter-aaaa-on-v4 yes;
    ```


    이미지 아래에 표시되어 있습니다:
    
    
    
    ![Add Filter IPv6](images/dns_filter.png)
    
    변경했으면 저장하고 `named.conf`(_vi_의 경우 `SHIFT:wq!`)를 종료합니다. 다음으로 옵션 섹션에서 `/etc/sysconfig/named`에서 비슷한 변경을 해야 합니다.

    ```
    vi /etc/sysconfig/named
    ```


    그리고 파일의 맨 아래에 다음을 추가하세요:

    ```
    OPTIONS="-4"
    ```


    이제 변경 사항을 저장합니다(_vi_의 경우 `SHIFT:wq!`). ## 8 컴퓨터 테스트
    
    새로운 로컬 DNS에 추가한 서버에 액세스하려면 DNS 서버(예제에서는 192.168.1.136)를 각 기계에 추가해야 합니다. 우리는 Rocky Linux 워크스테이션에서만 예제를 보여드리겠지만, 다른 Linux 배포판, Windows 및 Mac 기기에도 비슷한 방법이 있습니다.
    
    인터넷 접속이 필요하기 때문에 현재 할당된 DNS 서버를 그대로 유지하면서 DNS 서버만 목록에 추가하면 됩니다. 이러한 DNS 서버는 DHCP(Dynamic Host Configuration Protocol)에 의해 할당되거나 정적으로 할당될 수 있습니다.
    
    Rocky Linux 워크스테이션의 활성화된 네트워크 인터페이스가 eth0인 경우 다음을 사용합니다.

    ```
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    ```


    활성화된 네트워크 인터페이스가 다른 경우 해당 인터페이스 이름으로 대체해야 합니다. 열린 구성 파일은 다음과 같이 정적으로 할당된 IP를 사용하는 경우를 보여줍니다(위에서 언급한 것처럼 DHCP가 아님). 아래 예제에서 우리의 기기 IP 주소는 192.168.1.151입니다.

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=8.8.8.8
    DNS2=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    우리는 DNS1(기본 DNS) 대신 새로운 DNS 서버를 사용하고, 나머지 DNS 서버를 한 칸씩 밀어내도록 변경합니다.

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=192.168.1.136
    DNS2=8.8.8.8
    DNS3=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    변경을 완료한 후에는 기기를 다시 시작하거나 다음 명령으로 네트워킹을 다시 시작합니다.

    ```
    systemctl restart network
    ```


    이제 워크스테이션에서 <em x-id="3">ourdomain.lan</em> 도메인의 모든 것에 접근하고 인터넷 주소를 해결 및 접근할 수 있어야 합니다.
    
    ## 8 방화벽 규칙
    
    ### 방화벽 규칙 추가 - `iptables`
    
    !!! 참고 "`iptables` 관련"
    
         `iptables` 규칙은 Rocky Linux 8.x에서 여전히 작동하지만 아래 섹션의 `firewalld` 규칙으로 이동하는 것이 좋습니다. 참고 "`iptables` 관련"
    
         Rocky Linux 8.x에서 `iptables` 규칙은 여전히 작동하지만, 미래 버전에서는 `iptables`이 폐지되고 제거될 예정입니다. 또한 `firewalld`는 작업을 수행하는 기본 방법입니다. 도움말을 찾을 때 `firewalld` 사용 예시가 더 많으므로 `iptables`` 대신 `firewalld` 규칙으로 이동하는 것이 좋습니다. `iptables` 규칙은 여기에 포함되어 있지만 가장 좋은 결과를 얻고 미래를 대비하기 위해 지금 `firewalld`로 이동하는 것이 권장됩니다.
    
    먼저, 다음 규칙을 포함하는 "/etc/firewall.conf"라는 파일을 */etc*에 만듭니다. 이것은 최소한의 규칙 집합이며, 환경에 맞게 조정해야 할 수도 있습니다.

    ```
    #!/bin/sh
    #
    #IPTABLES=/usr/sbin/iptables

    #  Unless specified, the defaults for OUTPUT is ACCEPT
    #    The default for FORWARD and INPUT is DROP
    #
    echo "   clearing any existing rules and setting default policy.."
    iptables -F INPUT
    iptables -P INPUT DROP
    iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
    # dns rules
    iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
    iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

    /usr/sbin/service iptables save
    ```


    위의 규칙을 평가해 보겠습니다.

    * 첫 번째 "iptables" 라인은 현재 로드된 규칙을 지웁니다(-F).
    * 다음으로, INPUT 체인의 기본 정책을 DROP으로 설정합니다. 즉, 여기서 명시적으로 허용되지 않은 트래픽은 삭제됩니다.
    * 다음으로, 로컬 네트워크의 SSH 규칙을 추가하여 원격으로 DNS 서버에 접속할 수 있게 합니다.
    * 다음으로 로컬 네트워크 전용 DNS 허용 규칙을 추가합니다. DNS는 UDP 프로토콜(User Datagram Protocol)을 사용합니다.
    * 그 다음으로 로컬 인터페이스에서 입력을 허용합니다.
    * 그런 다음 다른 용도로 연결을 설정한 경우, 관련 패킷도 허용합니다.
    * 마지막으로 나머지 모든 것을 거부합니다.
    * 마지막 줄은 iptables에 규칙을 저장하도록 지시하여 기기를 다시 시작할 때 규칙이 로드되도록 합니다.

    firewall.conf  파일을 생성한 후 실행 가능하게 만들어야 합니다:

    ```
    chmod +x /etc/firewall.conf
    ```

    그런 다음 실행합니다.

    ```
    /etc/firewall.conf
    ```

    위와 같은 결과를 반환해야 합니다. 다른 결과가 나오는 경우 스크립트를 확인하고 오류를 찾아보세요.

    ```bash
    clearing any existing rules and setting default policy..
    iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
    ```


    ### 방화벽 규칙 추가 - `firewalld`

    `firewalld`를 사용하면 위에서 강조한 `iptables` 규칙을 복제합니다. 네트워크나 서비스에 대해 어떤 가정도 하지 않습니다. 단지 LAN 네트워크에 대한 SSH 액세스와 DNS 액세스를 활성화하려 합니다. 이를 위해 `firewalld`의 기본 제공 "trusted" zone을 사용합니다. 또한 "public" zone에서 SSH 액세스를 LAN에 한정하기 위해 일부 서비스 변경이 필요합니다.

    먼저, "trusted" zone에 LAN 네트워크를 추가해야 합니다.

    ```
    firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
    ```

    다음으로, 두 가지 서비스를 "trusted" zone에 추가해야 합니다.

    ```
    firewall-cmd --zone=trusted --add-service=ssh --permanent
    firewall-cmd --zone=trusted --add-service=dns --permanent
    ```

    마지막으로, 기본적으로 활성화된 "public" zone에서 SSH 서비스를 제거해야 합니다.

    ```
    firewall-cmd --zone=public --remove-service=ssh --permanent
    ```

    다음으로 방화벽을 다시 로드하고 변경한 zone을 나열합니다.

    ```
    firewall-cmd --reload
    firewall-cmd --zone=trusted --list-all
    ```

    이렇게 하면 서비스와 소스 네트워크를 올바르게 추가한 것을 확인해야 합니다.

    ```bash
    trusted (active)
        target: ACCEPT
        icmp-block-inversion: no
        interfaces:
        sources: 192.168.1.0/24
        services: dns ssh
        ports:
        protocols:
        forward: no
        masquerade: no
        forward-ports:
        source-ports:
        icmp-blocks:
        rich rules:
    ```

    "public" zone을 나열하면 SSH 액세스가 더 이상 허용되지 않은 것을 확인할 수 있습니다.

    ```
    firewall-cmd --zone=public --list-all
    ```

    ```bash
    public
        target: default
        icmp-block-inversion: no
        interfaces:
        sources:
        services: cockpit dhcpv6-client
        ports:
        protocols:
        forward: no
        masquerade: no
        forward-ports:
        source-ports:
        icmp-blocks:
        rich rules:
    ```


    이러한 규칙을 통해 192.168.1.0/24 네트워크의 호스트로부터 로컬 DNS 서버에서 DNS 해결이 가능하게 됩니다. 또한 이러한 호스트에서 로컬 DNS 서버로부터 SSH 접속이 가능해야 합니다.

## 결론

개별 워크스테이션에서 */etc/hosts*를 사용하면 내부 네트워크의 시스템에 액세스할 수 있지만 해당 시스템에서만 사용할 수 있습니다. _bind_를 사용하여 개인 DNS 서버를 추가함으로써 DNS에 호스트를 추가하고, 워크스테이션이 이 개인 DNS 서버에 액세스할 수 있다면 이러한 로컬 서버에 액세스할 수 있습니다.

인터넷에서 기계를 해결해야 하는 필요가 없지만 여러 기기에서 로컬 서버로 로컬 액세스가 필요한 경우, 개인 DNS 서버를 사용하는 것을 고려해 보세요.
