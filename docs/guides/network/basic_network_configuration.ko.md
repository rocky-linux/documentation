---
title: 네트워크 구성
author: unknown
contributors: Steven Spencer, Hayden Young
tested_with: 8.5, 8.6, 9.0
tags:
  - networking
  - configuration
  - network
---

# 소개

You can't do much with a computer these days without network connectivity. 서버의 패키지를 업데이트하거나 노트북에서 외부 웹사이트를 탐색하려면 네트워크 접속이 필요합니다! 이 가이드는 Rocky Linux 사용자들에게 네트워크 연결 설정에 대한 기본 지식을 제공하기 위해 작성되었습니다.

## 필요 사항

* 명령줄에서 작동하는 어느 정도의 편안함
* 시스템의 슈퍼관리자 권한 (예: root, `sudo` 등)
* 선택 사항: 네트워킹 개념 숙지

=== "9"

    ## 네트워크 구성 - Rocky Linux 9
    
    Rocky Linux 9의 네트워크 구성은 많은 변화가 있었습니다. 주요 변경 사항 중 하나는 Network-Scripts에서 Network Manager와 `keyfiles`을 사용하는 방식으로 변경되었습니다. (아직 설치할 수 있지만 사실상 사용되지 않음) `NetworkManager`는 이제 'ifcfg' 기반 파일보다 key 파일에 우선 순위를 둡니다. 이것이 이제 기본값이므로 네트워크를 구성하는 작업은 최신 변경 사항으로 인해 오래된 유틸리티의 점진적 폐지 및 제거가 의미하는 바와 같이 이제 기본값을 적절한 방법으로 수행해야 합니다. 이 가이드는 Network Manager의 사용법과 Rocky Linux 9 내 최신 변경 사항을 설명하는 데 노력할 것입니다. 
    
    ## 전제 조건

    * 명령줄에서 작동하는 어느 정도의 편안함
    * 시스템의 슈퍼관리자 권한 (예: root, `sudo` 등)
    * 선택 사항: 네트워킹 개념에 숙지


    ## NetworkManager 서비스 사용

    사용자 수준에서 네트워킹 스택은 `NetworkManager`에서 관리합니다. 이 도구는 서비스로 실행되며 다음 명령을 사용하여 해당 상태를 확인할 수 있습니다:

    ```bash
    systemctl status NetworkManager
    ```


    ## 구성 파일

    초기 설정대로 구성 파일은 이제 기본적으로 key 파일입니다. 다음 명령을 실행하여 `NetworkManager`가 이러한 파일에 우선순위를 둘지 확인할 수 있습니다.

    ```
    NetworkManager --print-config
    ```

    이렇게 하면 다음과 같은 출력이 나타납니다.

    ```
    [main]
    # plugins=keyfile,ifcfg-rh
    # rc-manager=auto
    # auth-polkit=true
    # iwd-config-path=
    dhcp=dhclient
    configure-and-quit=no

    [logging]
    # backend=journal
    # audit=false

    [device]
    # wifi.backend=wpa_supplicant

    # no-auto-default file "/var/lib/NetworkManager/no-auto-default.state"
    ```

    구성 파일 상단에 `keyfile`이라는 참조와 `ifcfg-rh`이라는 것을 참고하세요. 이는 `keyfile`이 기본값임을 의미합니다. `NetworkManager` 도구(예: nmcli`또는`nmtui`)를 사용하여 인터페이스를 구성할 때마다 자동으로 key 파일을 빌드하거나 업데이트합니다.

    !!! tip "구성 저장 위치"

        tip "구성 저장 위치" Rocky Linux 8에서는 네트워크 구성의 저장 위치가 `/etc/sysconfig/Network-Scripts/`에 있었습니다. 하지만 Rocky Linux 9에서는 새로운 기본 저장 위치가 `/etc/NetworkManager/system-connections/`에 있는 key 파일입니다.

    주된 (하지만 유일한 것은 아닙니다) 네트워크 인터페이스 구성 유틸리티는 `nmtui` 명령입니다. `nmtui` 명령으로도 이를 수행할 수 있지만 훨씬 직관적이지 않습니다. 다음은 `nmtui`을 사용하여 현재 구성된 인터페이스를 표시하는 방법입니다.

    ```
    nmcli device show enp0s3
    GENERAL.DEVICE:                         enp0s3
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         08:00:27:BA:CE:88
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connected)
    GENERAL.CONNECTION:                     enp0s3
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               on
    IP4.ADDRESS[1]:                         192.168.1.151/24
    IP4.GATEWAY:                            192.168.1.1
    IP4.ROUTE[1]:                           dst = 192.168.1.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.1.1, mt = 100
    IP4.DNS[1]:                             8.8.8.8
    IP4.DNS[2]:                             8.8.4.4
    IP4.DNS[3]:                             192.168.1.1
    IP6.ADDRESS[1]:                         fe80::a00:27ff:feba:ce88/64
    IP6.GATEWAY:                            --
    IP6.ROUTE[1]:                           dst = fe80::/64, nh = ::, mt = 1024
    ```


    !!! tip "**프로 팁:**"

        시스템에 IP 구성 정보를 할당할 수 있는 몇 가지 방법 또는 메커니즘이 있습니다. 가장 일반적인 두 가지 방법은 **정적 IP 구성** 체계(Static IP configuration scheme)와 **동적 IP 구성** 체계(Dynamic IP configuration scheme)입니다.

        정적 IP 구성 체계는 주로 서버 클래스 시스템이나 네트워크에서 많이 사용됩니다.

        동적 IP 구성 체계는 가정 및 사무실 네트워크나 비즈니스 환경에서 워크스테이션 및 데스크톱 클래스 시스템에서 일반적으로 사용됩니다.  동적 방식은 일반적으로 로컬에서 사용 가능하며, 요청하는 워크스테이션과 데스크톱에 적절한 IP 구성 정보를 제공할 수 있는 기능이 필요합니다. 이 기능을 동적 호스트 구성 프로토콜(Dynamic Host Configuration Protocol, DHCP)이라고 합니다. 가정 네트워크 및 대부분의 비즈니스 네트워크에서는 이 서비스가 DHCP 서버로 구성되어 제공됩니다. 이는 독립적인 서버이거나 라우터 구성의 일부일 수 있습니다.


    ## IP 주소

    이전 섹션에서 표시된 인터페이스 'enp0s3'의 구성은 '.ini' 파일인 '/etc/NetworkManager/system-connections/enp0s3.nmconnection'에서 생성되었습니다. 이는 IP4.ADDRESS[1]이 정적으로 구성되어 있음을 보여줍니다. 만약 이 인터페이스를 동적으로 할당된 주소로 변경하려면 가장 쉬운 방법은 `nmtui` 명령을 사용하는 것입니다.

    1. 먼저, 명령 줄에서 `nmtui` 명령을 실행하면 다음과 같은 내용을 보여줄 것입니다.

        ![nmtui](images/nmtui_first.png)

    2. "Edit a connection"을 선택해야 하므로 <kbd>TAB</kbd> 키를 눌러서 "OK"가 강조되도록 하고 <kbd>ENTER</kbd> 키를 누릅니다.

    3. 이렇게 하면 기기의 이더넷 연결을 보여주는 화면이 나타나며 연결을 선택할 수 있게 됩니다. 이 경우, *하나*의 연결만 있으므로 이미 강조되어 있습니다. 따라서 "Edit"이 강조되도록 <kbd>TAB</kbd> 키를 누르고 <kbd>ENTER</kbd> 키를 누릅니다.

        ![nmtui_edit](images/nmtui_edit.png)

    4. 이렇게 하면 현재 구성이 표시되는 화면으로 이동하게 됩니다. 우리가 해야 할 작업은 "Manual"에서 "Automatic"으로 전환하는 것이므로 "Manual"이 강조되도록 여러 번 <kbd>TAB</kbd> 키를 누르고 <kbd>ENTER</kbd> 키를 누릅니다.

        ![nmtui_manual](images/nmtui_manual.png)

    5. "Automatic"이 강조되도록 화살표 키를 위로 이동한 다음 <kbd>ENTER</kbd> 키를 누릅니다.

        ![nmtui_automatic](images/nmtui_automatic.png)

    6. 인터페이스를 "Automatic"으로 전환한 후에는 정적으로 할당된 IP를 제거해야 합니다. 따라서 IP 주소 옆의 "Remove"가 강조되도록 여러 번 <kbd>TAB</kbd> 키를 누르고 <kbd>ENTER</kbd> 키를 누릅니다.

        ![nmtui_remove](images/nmtui_remove.png)

    7. 마지막으로, `nmtui` 화면 하단으로 여러 번 <kbd>TAB</kbd> 키를 눌러 "OK"가 강조되도록 한 다음 <kbd>ENTER</kbd> 키를 누릅니다.

    인터페이스를 `nmtui`로 비활성화 및 다시 활성화할 수도 있지만, 대신 `nmcli`로 이 작업을 수행해 보겠습니다. 이렇게 하면 인터페이스가 긴 시간 동안 비활성화되지 않도록 인터페이스 비활성화와 인터페이스 재활성화를 연결할 수 있습니다:

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    이는 예전 버전의 OS에서 사용되던 `ifdown enp0s3 && ifup enp0s3`와 유사한 것으로 생각하면 됩니다.

    이것이 작동했는지 확인하려면 `ip addr` 명령이나 이전에 사용한 `nmcli device show enp0s3` 명령을 사용하여 확인하세요.

    ```
    ip addr
    ```

    성공적이라면, 정적 IP가 제거되고 동적으로 할당된 주소가 추가된 것을 확인할 수 있을 것입니다. 다음과 유사한 결과가 표시될 것입니다:

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.137/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 6342sec preferred_lft 6342sec
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```


    ### `nmcli`로 IP 주소 변경

    `nmtui`를 사용하는 것도 좋지만, 화면 간의 시간을 모두 기다리지 않고도 빠르게 네트워크 인터페이스를 재구성하고 싶다면 'nmcli'만 사용하는 것이 좋습니다. 위에서 설명한 예시인 정적으로 할당된 IP를 DHCP로 다시 구성하는 방법을 'nmcli'만 사용하여 살펴보겠습니다.

    시작하기 전에 인터페이스를 DHCP로 재구성하기 위해 다음 작업을 수행해야 합니다.

    * IPv4 게이트웨이 제거
    * 정적으로 할당한 IPv4 주소 제거
    * IPv4 방식을 자동으로 변경
    * 인터페이스 비활성화 및 활성화

    또한, -ipv4.address 등을 사용하는 예제는 사용하지 않습니다. 이러한 예제는 인터페이스를 완전히 변경하지 않습니다. 이러한 작업을 수행하려면 ipv4.address 및 ipv4.gateway를 빈 문자열로 설정해야 합니다. 우리의 명령을 최대한 빠르게 하기 위해 이 모든 작업을 한 줄에 묶어서 실행합니다.

    ```
    nmcli con mod enp0s3 ipv4.gateway '' && nmcli con mod enp0s3 ipv4.address '' && nmcli con mod enp0s3 ipv4.method auto && nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    다시 `ip addr` 명령을 실행하면, `nmtui`로 변경한 결과와 동일한 결과가 나타날 것입니다. 물론 모든 작업을 반대로 수행할 수도 있습니다(동적 IP를 정적으로 변경하는 방법). 이 경우, `ipv4.method`를 manual로 변경하여 시작하고, `ipv4.gateway`를 설정한 다음 `ipv4.address`를 설정해야 합니다. 이러한 예제에서 인터페이스를 완전히 재구성하고 값을 추가하거나 제거하지 않기 때문에 위에서 사용한 예제들과 같이 `+ipv4.method`,`+ipv4.gateway`, 및 `+ipv4.address`를 사용하지 않을 것입니다. 위의 명령 대신 이러한 명령을 사용하면 DHCP로 할당된 주소와 정적으로 할당된 주소가 모두 있는 인터페이스가 생성됩니다. 그렇기 때문에 경우에 따라서는 아주 유용할 수 있습니다. 예를 들어, 하나의 IP에서 웹 서비스를 수신하고 다른 IP에서 SFTP 서버를 수신한다고 가정해 보겠습니다. 여러 개의 IP를 인터페이스에 할당하는 방법은 매우 유용합니다.


    ## DNS 확인

    DNS 서버를 설정하는 방법은 `nmtui` 또는 `nmcli` 둘 다 사용할 수 있습니다. `nmtui` 인터페이스는 탐색하기 쉽고 훨씬 직관적이지만, 더 느린 과정을 거칩니다. `nmcli`를 사용하는 것이 훨씬 빠릅니다. DHCP로 할당된 주소의 경우 보통 DNS 서버를 설정할 필요가 없으므로 일반적으로 DHCP 서버에서 자동으로 전달됩니다. 그러나 DHCP 인터페이스에 *정적으로 DNS 서버를 추가*할 수도 있습니다. 정적으로 할당된 인터페이스의 경우 DNS 값이 설정되어 있어야 하며 자동으로 할당되지 않을 것입니다.

    이 모든 것을 정적으로 할당된 IP에 대한 가장 좋은 예로 돌아가 봅시다. 예시 인터페이스(enp0s3)에서 이미 설정한 DNS 서버를 제거하고 다른 값으로 바꾸기 전에 현재 설정된 값들을 확인해야 합니다. 적절한 이름 해결을 위해 먼저 이미 설정된 DNS 서버를 제거하고 다른 값으로 추가해 보겠습니다. 현재 `ipv4.dns`가 `8.8.8.8,8.8.4.4,192.168.1.1`로 설정되어 있습니다. 이 경우, 우리는 먼저 ipv4.dns를 빈 문자열로 설정할 필요가 없습니다. 간단히 다음 명령을 사용하여 값을 대체할 수 있습니다.

    ```
    nmcli con mod enp0s3 ipv4.dns '208.67.222.222,208.67.220.220,192.168.1.1'
    ```

    `nmcli con show enp0s3 | grep ipv4.dns`를 실행하면 DNS 서버를 성공적으로 변경한 것을 확인할 수 있습니다. 모든 변경 사항이 활성화되도록 인터페이스를 다운하고 다시 업하도록 합시다.

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    이제 *이름 해결이 잘 되는지 확인하기 위해* 알려진 호스트에 핑을 시도해 보세요. 예시로 google.com을 사용해 보겠습니다.

    ```bash
    ping google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=14.6 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.4 ms
    ^C
    ```


    ## `ip` 유틸리티 사용

    `ip` 유틸리티(*iproute2* 패키지에서 제공)는 Rocky Linux와 같은 현대적인 리눅스 시스템의 네트워크 정보를 얻거나 구성하는 데 강력한 도구입니다.

    이 예에서는 다음 매개변수를 가정합니다:

    * 인터페이스 이름: enp0s3
    * 아이피 주소: 192.168.1.151
    * 서브넷 마스크: 24
    * 게이트웨이: 192.168.1.1


    ### 일반 정보 얻기

    모든 인터페이스의 상세 상태를 확인하려면 다음 명령을 사용하세요.

    ```bash
    ip a
    ```

    !!! tip "**프로 팁:**"

        * 더 가독성이 좋은 컬러 출력을 얻으려면 `-c` 플래그를 사용하세요: `ip -c a`.
        * `ip`는 `ip a`, `ip addr` 및 `ip address`를 동등하게 인식합니다.


    ### 인터페이스를 활성화 또는 비활성화하기

    !!! 참고사항

        Rocky Linux 9에서 인터페이스를 활성화 및 비활성화하는 방법으로 이 방법을 여전히 사용할 수 있지만, 이 명령은 이전 예제에서 사용한 `nmcli` 명령보다 훨씬 느리게 작동합니다.

    *enp0s3*을 비활성화하고 다시 활성화하려면 간단히 다음 명령을 사용할 수 있습니다.

    ```
    ip link set enp0s3 down && ip link set enp0s3 up
    ```


    ### 인터페이스에 정적 주소 할당

    현재 enp0s3 인터페이스는 IP 주소가 192.168.1.151입니다. 이를 192.168.1.152로 변경하려면 이전 IP를 제거합니다.

    ```bash
    ip addr delete 192.168.1.151/24 dev enp0s3 && ip addr add 192.168.1.152/24 dev enp0s3
    ```

    인터페이스에 두 번째 IP를 할당하려면 192.168.1.151 주소를 제거하지 않고 두 번째 주소를 간단히 추가합니다.

    ```bash
    ip addr add 192.168.1.152/24 dev enp0s3
    ```

    IP 주소가 추가되었는지 확인할 수 있습니다.

    ```bash
    ip a show dev enp0s3
    ```

    다음을 출력합니다:

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.151/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.152/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```

    인터페이스를 활성화하거나 비활성화하는 것은 `nmcli`보다 느립니다만, 새로운 또는 추가 IP 주소를 설정할 때 `ip` 의 장점은 인터페이스를 비활성화하고 다시 활성화하지 않고도 실시간으로 변경할 수 있다는 점입니다.


    ### 게이트웨이 구성


    이제 인터페이스에 주소가 있으므로 기본 경로를 설정해야 합니다. 이 작업은 다음과 같이 수행할 수 있습니다:

    ```bash
    ip route add default via 192.168.1.1 dev enp0s3
    ```

    커널 라우팅 테이블은 다음 명령으로 확인할 수 있습니다.

    ```bash
    ip route
    ```

    또는 줄여서 `ip r`을 사용할 수 있습니다.

    다음과 같이 출력되어야 합니다:

    ```bash
    default via 192.168.1.1 dev enp0s3 
    192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.151 metric 100
    ```


    ## 네트워크 연결 확인

    위의 예제에서 우리는 몇 가지 테스트를 수행했습니다. 테스트는 기본 게이트웨이에 핑을 시도하여 시작하는 것이 가장 좋습니다. 이것은 항상 작동해야 합니다:

    ```bash
    ping -c3 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.437 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.879 ms
    64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.633 ms
    ```

    다음으로, 로컬 네트워크의 호스트에 대해 핑하여 LAN 라우팅이 완전히 작동하는지 확인합니다.

    ```bash
    ping -c3 192.168.1.10
    PING 192.168.1.10 (192.168.1.10) 56(84) bytes of data.
    64 bytes from 192.168.1.10: icmp_seq=2 ttl=255 time=0.684 ms
    64 bytes from 192.168.1.10: icmp_seq=3 ttl=255 time=0.676 ms
    ```

    마지막으로, 네트워크 외부의 도달 가능한 호스트를 확인합니다. 아래 테스트에서는 Google의 공개 DNS 서버를 사용합니다.

    ```bash
    ping -c3 8.8.8.8
    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=19.8 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=20.2 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=20.1 ms
    ```

    최종 테스트로 DNS 해결이 작동하는지 확인합니다. 이 예제에서는 google.com을 사용합니다.

    ```bash
    ping -c3 google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=15.1 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.6 ms
    ```

    여러 인터페이스가 있는 경우 특정 인터페이스에서 테스트하려면 ping과 함께 `-I` 옵션을 사용하면 됩니다.

    ```bash
    ping -I enp0s3 -c3 192.168.1.10
    ```


    ## 결론

    결론적으로 Rocky Linux 9에서 네트워킹 스택에는 많은 변경 사항이 있습니다. 그 중 하나는 Network-Scripts에 사용되던 `ifcfg` 파일보다 `keyfile`을 우선시하는 것입니다. 앞으로 나올 Rocky Linux의 버전에서는 Network-Scripts를 완전히 폐기하고 제거할 것으로 보이므로 네트워크 구성에는 `nmcli`, `nmtui`, 그리고 경우에 따라 `ip`와 같은 방법을 주로 사용하는 것이 가장 좋습니다.

=== "8"

    ## 네트워크 구성 - Rocky Linux 8
    
    ## NetworkManager 서비스 사용
    
    사용자 수준에서는 네트워킹 스택이 *NetworkManager*로 관리됩니다. 이 도구는 서비스로 실행되며, 다음 명령으로 상태를 확인할 수 있습니다.

    ```bash
    systemctl status NetworkManager
    ```


    ### 구성 파일
    
    NetworkManager는 단순히 `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>` 경로에 있는 파일에서 읽은 구성을 적용합니다.
    각 네트워크 인터페이스에는 해당하는 구성 파일이 있습니다. 다음은 서버의 기본 구성 예제입니다.

    ```bash
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=enp1s0
    UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
    DEVICE=enp1s0
    ONBOOT=yes
    IPADDR=10.0.0.10
    PREFIX=24
    GATEWAY=10.0.0.1
    DNS1=10.0.0.1
    DNS2=1.1.1.1
    IPV6_DISABLED=yes
    ```


    인터페이스의 이름은 **enp1s0**이므로 이 파일의 이름은 `/etc/sysconfig/network-scripts/ifcfg-enp1s0`이 됩니다.
    
    !!! tip "**팁:**"  
    
        시스템은 IP 구성 정보를 할당받는 몇 가지 방법이나 메커니즘이 있습니다. 가장 일반적인 두 가지 방법은 **정적 IP 구성** 방식과 **동적 IP 구성** 방식입니다.
    
        정적 IP 구성 체계는 서버 클래스 시스템이나 네트워크에서 매우 널리 사용됩니다.
    
        동적 IP 방식은 가정 및 사무실 네트워크 또는 워크스테이션 및 데스크톱 클래스 시스템에서 많이 사용됩니다.  동적 방식은 보통 워크스테이션 및 데스크톱에서 요청한 IP 구성 정보를 제공할 수 있는 로컬에서 사용 가능한 무언가가 필요합니다. 이를 동적 호스트 구성 프로토콜(DHCP)이라고 합니다.
    
        대부분의 경우, 가정/사무실 사용자는 DHCP에 대해 걱정할 필요가 없습니다. 이것은 누군가 또는 무언가가 백그라운드에서 자동으로 처리하기 때문입니다. 최종 사용자가 해야 할 일은 올바른 네트워크에 물리적 또는 무선으로 연결하는 것뿐입니다(물론 시스템이 켜져 있어야 합니다)!
    
    ### IP 주소
    
    이전 `/etc/sysconfig/network-scripts/ifcfg-enp1s0` 목록에서 `BOOTPROTO` 매개변수 또는 키의 값이 `none`으로 설정되어 있습니다. 이는 구성하려는 시스템이 정적 IP 주소 방식으로 설정되어 있음을 의미합니다.
    
    대신 동적 IP 주소 방식으로 시스템을 구성하려면 `BOOTPROTO` 매개변수의 값을 `none`에서 `dhcp`로 변경하고 `IPADDR`, `PREFIX` 및 `GATEWAY` 라인을 모두 제거해야 합니다. 이것은 가능한 모든 정보가 DHCP 서버에서 자동으로 얻어질 것이기 때문에 필요합니다.
    
    정적 IP 주소 특성을 구성하려면 다음과 같이 설정하세요.

    * IPADDR: 인터페이스를 할당할 IP 주소
    * PREFIX: [CIDR 표기법](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)으로 된 서브넷 마스크
    * GATEWAY: 기본 게이트웨이

    `ONBOOT` 매개변수가 `yes`로 설정되어 있으면 이 연결은 부팅 시에 활성화됩니다.


    ### DNS 확인

    올바른 이름 해결을 위해 다음과 같은 매개변수를 설정해야 합니다.

    * DNS1: 기본 이름 서버 IP 주소
    * DNS2: 보조 이름 서버 IP 주소


    ### 구성 확인

    다음 `nmcli` 명령으로 구성이 올바르게 적용되었는지 확인할 수 있습니다.

    ```bash
    [user@server ~]$ sudo nmcli device show enp1s0
    ```

    위 명령은 다음과 같은 출력을 제공해야 합니다.

    ```conf
    GENERAL.DEVICE:                         enp1s0
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connecté)
    GENERAL.CONNECTION:                     enp1s0
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               marche
    IP4.ADDRESS[1]:                         10.0.0.10/24
    IP4.GATEWAY:                            10.0.0.1
    IP4.ROUTE[1]:                           dst = 10.0.0.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 10.0.0.1, mt = 100
    IP4.DNS[1]:                             10.0.0.1
    IP4.DNS[2]:                             1.1.1.1
    IP6.GATEWAY:                            --
    ```


    ### CLI

    NetworkManager의 주요 기능은 물리적 장치를 IP 주소 및 DNS 설정과 같은 더 논리적인 네트워크 구성 요소에 매핑하는 "연결"을 관리하는 것입니다. NetworkManager가 유지하는 기존 연결을 확인하려면 `nmcli connection show`를 사용할 수 있습니다.

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    위 출력에서 우리는 NetworkManager가 `enp1s0`이라는 이름의 연결(`NAME`)을 관리하고 해당 연결이 물리적 장치(`DEVICE`) `enp1s0`에 매핑되어 있음을 확인할 수 있습니다.

    !!! tip "연결 이름"

        tip "연결 이름" 이 예제에서는 연결과 장치가 동일한 이름을 공유하지만 항상 그렇지는 않습니다. 예를 들어, 일반적으로 연결 이름이 `System eth0`으로 설정되어 있고 해당 연결이 `eth0`이라는 장치에 매핑되는 것을 볼 수 있습니다.

    이제 우리가 연결의 이름을 알았으므로 해당 설정을 확인할 수 있습니다. 이를 위해 `nmcli connection show [connection]` 명령을 사용하면 지정한 연결에 대해 NetworkManager가 등록한 모든 설정을 출력합니다.

    ```bash
    [user@server ~]$ sudo nmcli connection show enp1s0
    ...
    ipv4.method:                            auto
    ipv4.dns:                               --
    ipv4.dns-search:                        --
    ipv4.dns-options:                       --
    ipv4.dns-priority:                      0
    ipv4.addresses:                         --
    ipv4.gateway:                           --
    ipv4.routes:                            --
    ipv4.route-metric:                      -1
    ipv4.route-table:                       0 (unspec)
    ipv4.routing-rules:                     --
    ipv4.ignore-auto-routes:                no
    ipv4.ignore-auto-dns:                   no
    ipv4.dhcp-client-id:                    --
    ipv4.dhcp-iaid:                         --
    ipv4.dhcp-timeout:                      0 (default)
    ipv4.dhcp-send-hostname:                yes
    ...
    ```

    왼쪽 열에는 설정의 이름이 나열되고 오른쪽에는 해당 값이 표시됩니다.

    예를 들어, 여기서 `ipv4.method`가 현재 `auto`로 설정되어 있는 것을 볼 수 있습니다. `ipv4.method` 설정에는 많은 허용 값이 있지만 가장 자주 볼 수 있는 값은 다음 두 가지입니다.

    * `auto`: 인터페이스에 적절한 자동 방법(DHCP, PPP 등)이 사용되며 대부분의 다른 속성은 설정하지 않아도 됩니다.
    * `manual`: 정적 IP 주소를 사용하며 'addresses' 속성에 적어도 하나의 IP 주소를 지정해야 합니다.

    대신 시스템을 정적 IP 주소 방식으로 구성하려면 `ipv4.method` 값을 `manual`로 변경하고 `ipv4.gateway` 및 `ipv4.addresses`를 지정해야 합니다.

    설정을 수정하려면 nmcli 명령 `nmcli connection modify [connection] [setting] [value]`을 사용할 수 있습니다.

    ```bash
    # 10.0.0.10을 정적 ipv4 주소로 설정
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.addresses 10.0.0.10

    # ipv4 게이트웨이로 10.0.0.1 설정
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.gateway 10.0.0.1

    # ipv4 메소드를 정적 할당 사용으로 변경 (이전 두 명령에서 설정한 값으로 설정)
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.method manual
    ```

    !!!tip "연결은 언제 업데이트되나요?"

        `nmcli connection modify`는 *런타임* 구성을 수정하지 않고 `nmcli`가 구성할 값에 따라 `/etc/sysconfig/network-scripts` 구성 파일을 업데이트합니다.

    CLI를 통해 NetworkManager를 사용하여 DNS 서버를 구성하려면 `ipv4.dns` 설정을 수정할 수 있습니다.

    ```bash
    # 10.0.0.1과 1.1.1.1을 기본 및 보조 DNS 서버로 설정
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.dns '10.0.0.1 1.1.1.1'
    ```


    ### 구성 적용

    네트워크 구성을 적용하려면 `nmcli connection up [connection]` 명령을 사용할 수 있습니다.

    ```bash
    [user@server ~]$ sudo nmcli connection up enp1s0
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
    ```

    연결 상태를 얻으려면 다음을 사용하십시오:

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    `ifup` 및 `ifdown` 명령을 사용하여 인터페이스를 위아래로 가져올 수도 있습니다(이들은 `nmcli`를 둘러싼 간단한 래퍼입니다).

    ```bash
    [user@server ~]$ sudo ifup enp1s0
    [user@server ~]$ sudo ifdown enp1s0
    ```


    ## ip 유틸리티 사용

    `ip` 명령(*iproute2* 패키지에서 제공)은 정보를 얻고 Rocky Linux와 같은 최신 Linux 시스템의 네트워크를 구성하는 강력한 도구입니다.

    이 예에서는 다음 매개변수를 가정합니다:

    * 인터페이스 이름: ens19
    * 아이피 주소: 192.168.20.10
    * 서브넷 마스크: 24
    * 게이트웨이: 192.168.20.254


    ### 일반 정보 얻기

    모든 인터페이스의 상세 상태를 보려면 다음 명령을 사용하세요.

    ```bash
    ip a
    ```

    !!! tip "**프로 팁:**"

        * 더 가독성 있는 색상 출력을 얻으려면 `-c` 플래그를 사용하세요: `ip -c a`.
        * `ip`는 약어를 허용하므로 `ip a`, `ip addr` 및 `ip address`는 동일한 명령입니다.


    ### 인터페이스를 위 또는 아래로 가져오기

    *ens19* 인터페이스를 활성화하려면 간단히 다음 명령을 사용하세요: `ip link set ens19 up`, 인터페이스를 비활성화하려면 `ip link set ens19 down`을 사용하세요.


    ### 인터페이스에 정적 주소 할당

    다음 형식의 명령을 사용합니다.

    ```bash
    ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>
    ```

    위의 예제 매개변수를 할당하려면 다음과 같이 사용합니다.

    ```bash
    ip a add 192.168.20.10/24 dev ens19
    ```

    그런 다음, 다음을 사용하여 결과를 확인합니다:

    ```bash
    ip a show dev ens19
    ```

    다음과 같이 출력됩니다.

    ```bash
    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever
    ```

    인터페이스는 활성화되고 설정되었지만 무언가 부족합니다!


    ### ifcfg 유틸리티 사용

    새로운 예제 IP 주소 *ens19* 인터페이스를 추가하려면 다음 명령을 사용하십시오:

    ```bash
    ifcfg ens19 add 192.168.20.10/24
    ```

    주소를 제거하려면 다음을 사용합니다.

    ```bash
    ifcfg ens19 del 192.168.20.10/24
    ```

    이 인터페이스에서 IP 주소 할당을 완전히 비활성화하려면 다음과 같이 합니다.

    ```bash
    ifcfg ens19 stop
    ```

    *인터페이스가 중단되는 것이 아니라 단순히 인터페이스에서 모든 IP 주소 할당이 해제된다는 점에 유의하십시오.*


    ### 게이트웨이 구성

    이제 인터페이스에 주소가 있으므로 기본 경로를 설정해야 합니다. 이를 다음 명령으로 수행할 수 있습니다.

    ```bash
    ip route add default via 192.168.20.254 dev ens19
    ```

    커널 라우팅 테이블은 다음과 같이 표시할 수 있습니다.

    ```bash
    ip route
    ```

    또는 줄여서 줄여서 `ip r`로 표시됩니다.


    ## 네트워크 연결 확인

    이 시점에서 네트워크 인터페이스를 설정하고 적절하게 구성해야 합니다. 연결을 확인하는 방법에는 여러 가지가 있습니다.

    동일한 네트워크에 있는 다른 IP 주소를 *ping*하여 다음을 수행합니다(예를 들어 '192.168.20.42'를 사용):

    ```bash
    ping -c3 192.168.20.42
    ```

    이 명령은 3개의 *ping*(ICMP 요청이라고 함)을 실행하고 응답을 기다립니다. 모든 것이 정상적으로 진행되면 다음과 같은 출력이 표시됩니다:

    ```bash
    PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
    64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
    64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
    64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

    --- 192.168.20.42 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 5ms
    rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
    ```

    그런 다음 라우팅 구성이 정상인지 확인하기 위해 다음과 같이 잘 알려진 공개 DNS 리졸버로 외부 호스트를 핑해 보세요.

    ```bash
    ping -c3 8.8.8.8
    ```

    만약 여러 네트워크 인터페이스가 있고 특정 인터페이스를 통해 ICMP 요청을 보내려면 `-I` 플래그를 사용하세요.

    ```bash
    ping -I ens19 -c3 192.168.20.42
    ```

    이제 DNS 해결이 정확히 작동하는지 확인할 시간입니다. DNS 해결은 인간 친화적인 기계 이름을 해당 IP 주소로 변환하고 그 반대(역 DNS)로 변환하는 메커니즘을 사용합니다.

    `/etc/resolv.conf` 파일이 접근 가능한 DNS 서버를 나타내면 다음이 작동해야 합니다.

    ```bash
    host rockylinux.org
    ```

    결과는 다음과 같아야 합니다:

    ```bash
    rockylinux.org has address 76.76.21.21
    ```


    ## 결론

    Rocky Linux 8은 명령 줄에서 네트워크를 구성하기 위한 도구를 갖추고 있습니다. 이 문서를 통해 이러한 도구들을 빠르게 활용하실 수 있습니다.
