---
title: Tor 릴레이
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 8.7, 9.2
tags:
  - proxy
  - proxies
---

# Tor 릴레이

## 소개

[Tor](https://www.torproject.org/)는 트래픽을 세 개의 자원봉사자가 운영하는 서버(릴레이라고 함)를 통해 경유시켜주는 익명성 서비스 및 소프트웨어입니다. 세 개의 홉(hop) 디자인은 감시 시도에 저항하여 프라이버시를 보장하기 위한 것입니다.

## 전제 조건 및 가정

이 절차를 사용하기 위한 최소 요구 사항은 다음과 같습니다:

- 서버에 직접 또는 포트 포워딩을 통해 공개 IPv4 주소가 있어야 합니다.
- Tor 네트워크에 유용하려면 24/7 운영할 수 있는 시스템이 필요합니다.
- root 사용자로 명령을 실행하거나 권한을 높이기 위해 `sudo`를 사용할 수 있어야 합니다.
- 커맨드 라인 에디터에 익숙해야 합니다. 저자는 여기서 `vi` 또는 `vim`을 사용하지만, 선호하는 에디터로 대체하십시오.
- SELinux 및 방화벽 설정 변경에 대해 편안해야 합니다.
- 계량되지 않은 연결 또는 높은 대역폭 제한이 있는 연결이 필요합니다.
- 선택 사항: 이중 스택 연결성을 위한 공개 IPv6 주소

## Tor 설치

Tor를 설치하려면 먼저 EPEL(Extra Packages for Enterprise Linux)을 설치하고 업데이트를 실행해야 합니다:

```bash
dnf -y install epel-release && dnf -y update
```

그런 다음 Tor를 설치합니다:

```bash
dnf -y install tor
```

## Tor 구성

패키지가 설치되면 Tor를 구성해야 합니다. 저자는 이를 위해 `vi`를 사용하지만, `nano`나 다른 것을 선호한다면 그것으로 대체하십시오:

```bash
vi /etc/tor/torrc
```

기본 `torrc` 파일은 상당히 설명적이지만, 단순히 Tor 릴레이를 원한다면 길어질 수 있습니다. 최소 릴레이 구성은 다음과 유사합니다:

```bash
Nickname TorRelay
ORPort 9001
ContactInfo you@example.com
Log notice syslog
```

### Taking a closer look

- The `Nickname` is a (non-unique) nickname for your Tor relay.
- The `ORPort` is the TCP port your Tor relay listens on. The default is `9001`.
- The `ContactInfo` is your contact information, in case there's issues with your Tor relay. 이를 이메일 주소로 설정하십시오.
- The `Log` is the severity and destination of your Tor relay logs. We are logging `notice` to prevent sensitive information from being logged, and `syslog` to output to the `systemd` log.

### 시스템 구성

If you have chosen another TCP/IP port than `9001` (the default), you will need to adjust the SELinux `tor_port_t` to whitelist your Tor relay's port. 그렇게 하려면:

```bash
semanage port -a -t tor_port_t -p tcp 12345
```

Replace `12345` with the TCP Port you set in your `ORPort`.

You will also need to open your `ORPort` port in the firewall. 그렇게 하려면:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
firewall-cmd --runtime-to-permanent
```

Replace `9001` with the TCP Port you set in your `ORPort`.

## 대역폭 제한하기

ISP에서 공정 이용 정책이 있어 Tor에 모든 대역폭을 할당하고 싶지 않다면, 대역폭을 제한할 수 있습니다. 예를 들어, 대역폭(예: 100메가비트) 또는 시간당 트래픽(예: 하루 5GB)으로 제한할 수 있습니다.

이를 위해 `torrc` 파일을 편집하세요:

```bash
vi /etc/tor/torrc
```

대역폭을 제한하려면, 다음 줄을 `torrc` 파일에 추가하세요:

```bash
RelayBandwidthRate 12500 KB
```

이는 초당 12500 KB의 대역폭을 허용하는 것으로, 약 100메가비트입니다.

시간당 특정 양의 트래픽을 전송하고 싶다면, 대신 다음을 추가하세요:

```bash
AccountingStart day 00:00
AccountingMax 20 GB
```

이 값들은 다음을 의미합니다:

- 대역폭 회계 기간이 매일 00:00 시스템 시간에 시작합니다. You can also change `day` to `week` or `month`, or replace `00:00` with another time.
- 대역폭 회계 기간 동안 20 GB를 전송합니다. 릴레이에 더 많거나 적은 대역폭을 허용하려면 값을 증가시키거나 감소시키세요.

지정된 대역폭을 사용한 후에는 어떻게 될까요? 릴레이는 기간이 끝날 때까지 새 연결 시도를 차단합니다. 릴레이가 기간 동안 지정된 대역폭을 사용하지 않은 경우, 카운터는 다운타임 없이 리셋됩니다.

## 테스트 및 켜기

Tor 릴레이 구성을 설정한 후, 다음 단계는 Tor 데몬을 켜는 것입니다:

```bash
systemctl enable --now tor
```

systemd 로그에서 다음과 같은 줄을 받아야 합니다:

```bash
Jan 14 15:46:36 hostname tor[1142]: Jan 14 15:46:36.000 [notice] Self-testing indicates your ORPort A.B.C.D:9001 is reachable from the outside. Excellent. Publishing server descriptor.
```

이는 릴레이가 접근 가능함을 나타냅니다.

몇 시간 내에, [Tor Relay Status](https://metrics.torproject.org/rs.html)에서 닉네임이나 공개 IP 주소를 입력하여 릴레이를 확인할 수 있습니다.

## 릴레이 고려 사항

Tor 릴레이를 출구 또는 브리지 릴레이로 확장할 수도 있습니다. 또한, 공용 IP 주소당 최대 8개의 릴레이를 설정할 수 있습니다. EPEL의 Tor systemd 단위 파일은 여러 인스턴스에 대해 설계되지 않았지만, 단위 파일을 복사하고 수정하여 다중 릴레이 설정을 수용할 수 있습니다.

출구 릴레이는 Tor 사용자를 대신하여 직접 웹사이트에 연결하는 Tor 회로의 마지막 홉입니다. 브리지 릴레이는 인터넷 검열로 고생하는 사용자가 Tor에 연결하는 데 도움이 되는 목록에 없는 릴레이입니다.

`torrc` 파일의 옵션은 [매뉴얼 페이지](https://2019.www.torproject.org/docs/tor-manual.html.en)에 있습니다. 여기에서는 출구 및 브리지 릴레이에 대한 기본 구성을 설명합니다.

### 출구 릴레이 운영

!!! warning

    If you plan to run an exit relay, make sure your ISP or hosting company is comfortable with it. Abuse complaints from exit relays are very common, as it is the last node of a Tor circuit that connects directly to websites on behalf of Tor users. Many ISPs and hosting companies disallow Tor exit relays for this reason.
    
    If you are unsure your ISP allows Tor exit relays, look at the terms of service or ask your ISP. If your ISP says no, look at another ISP or hosting company or consider a middle or bridge relay instead.

출구 릴레이를 운영하려면, `torrc`에 다음을 추가해야 합니다:

```bash
ExitRelay 1
```

그러나, 이는 다음의 기본 출구 정책을 사용하게 됩니다:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:119
ExitPolicy reject *:135-139
ExitPolicy reject *:445
ExitPolicy reject *:563
ExitPolicy reject *:1214
ExitPolicy reject *:4661-4666
ExitPolicy reject *:6346-6429
ExitPolicy reject *:6699
ExitPolicy reject *:6881-6999
ExitPolicy accept *:*
```

이 출구 정책은 BitTorrent와 SSH와 같은 남용을 허용하는 매우 작은 TCP 포트 집합만 차단합니다.

[축소된 출구 정책](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/ReducedExitPolicy)을 사용하고 싶다면, `torrc`에 설정할 수 있습니다:

```bash
ReducedExitPolicy 1
```

DNS, HTTP 및 HTTPS 트래픽만 허용하는 더 제한적인 출구 정책을 사용할 수도 있습니다. 이는 다음과 같이 설정할 수 있습니다:

```bash
ExitPolicy accept *:53
ExitPolicy accept *:80
ExitPolicy accept *:443
ExitPolicy reject *:*
```

이 값들은 다음을 의미합니다:

- We allow exit traffic to TCP ports 53 (DNS), 80 (HTTP), and 443 (HTTPS) with our `ExitPolicy accept` lines
- We disallow exit traffic to any other TCP port with our wildcard `ExitPolicy reject` lines

SMTP 트래픽만 차단하는 제한이 없는 출구 정책을 원한다면, 다음과 같이 설정할 수 있습니다:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:465
ExitPolicy reject *:587
ExitPolicy accpet *:*
```

이러한 값은 다음을 의미합니다:

- We disallow exit traffic to the standard SMTP TCP ports of 25, 465, and 587 in our `ExitPolicy reject` lines
- We allow exit traffic to all other TCP ports in our wildcard `ExitPolicy accept` line

다음과 같이 다양한 포트를 허용하거나 차단할 수도 있습니다:

```bash
ExitPolicy accept *:80-81
ExitPolicy reject *:993-995
```

이 값들은 다음을 의미합니다:

- TCP 포트 80-81로의 출구 트래픽을 허용합니다.
- SSL로 보안된 IMAP, IRC, POP3 변종에 사용되는 TCP 포트 993-995로의 출구 트래픽을 거부합니다.

서버가 듀얼 스택 연결성을 가정할 경우 IPv6 주소로의 출구 트래픽도 허용할 수 있습니다:

```bash
IPv6Exit 1
```

### obfs4 브릿지 실행

전 세계 여러 지역, 특히 중국, 이란, 러시아, 투르크메니스탄에서는 Tor에 대한 직접 연결이 차단됩니다. 이러한 국가에서는 Tor 클라이언트가 목록에 없는 브리지 릴레이를 사용합니다.

이 시스템은 Tor 트래픽을 다른 프로토콜, 예를 들어 식별할 수 없는 더미 트래픽(obfs4), WebRTC(snowflake), 또는 Microsoft 서비스로의 HTTPS 연결(meek)로 가장하게 합니다.

그 다양성으로 인해, obfs4는 가장 인기 있는 플러그 가능한 전송입니다.

obfs4 브리지를 설정하기 위해서는 EPEL 리포지토리에 obfs4가 없기 때문에 처음부터 컴파일해야 합니다. 먼저 필요한 패키지를 설치합니다:

```bash
dnf install git golang policycoreutils-python-utils
```

다음으로, obfs4 소스 코드를 다운로드하고 압축을 풉니다:

```bash
wget https://gitlab.com/yawning/obfs4/-/archive/obfs4proxy-0.0.14/obfs4-obfs4proxy-0.0.14.tar.bz2
tar jxvf obfs4-obfs4proxy-0.0.14.tar.bz2
cd obfs4-obfs4proxy-0.0.14/obfs4proxy/
```

You can also get obfs4 directly from `git clone`, but that depends on a newer version of Go than what exists in AppStream so we will not use that.

그 다음, obfs4를 컴파일하고 설치합니다:

```bash
go build
cp -a obfs4proxy /usr/local/bin/
```

obfs4가 설치되면, 우리의 `torrc`에 다음을 추가합니다:

```bash
ServerTransportPlugin obfs4 exec /usr/local/bin/obfs4proxy
ServerTransportListenAddr obfs4 0.0.0.0:12345
ExtORPort auto
```

이 값들은 다음을 의미합니다:

- 우리는 `/usr/local/bin/obfs4proxy`에 위치한 obfs4 플러그 가능한 전송을 `ServerTransportPlugin` 줄에서 실행하고 있습니다.
- `ServerTransportListenAddr`은 우리의 플러그 가능한 전송이 12345 포트에서 듣도록 합니다.
- 우리의 `ExtORPort` 줄은 Tor와 우리의 플러그 가능한 전송 사이의 연결을 위해 임의로 선택된 포트에서 듣게 됩니다. 일반적으로, 이 줄은 변경되어서는 안 됩니다.

If you want to listen on another TCP port, change `12345` with your desired TCP port.

We will also allow our chosen TCP port `12345` (or the port you chose) in SELinux and `firewalld`:

```bash
semanage port -a -t tor_port_t -p tcp 12345
firewall-cmd --zone=public --add-port=12345/tcp
firewall-cmd --runtime-to-permanent
```

## 여러 릴레이 운영하기

앞서 언급했듯이, 공용 IP 주소당 최대 8개의 Tor 릴레이를 설정할 수 있습니다. 예를 들어, 우리가 5개의 공용 IP 주소를 가지고 있다면, 우리 서버에 최대 40개의 릴레이를 설정할 수 있습니다.

그러나, 우리는 운영하는 각 릴레이마다 사용자 정의 systemd 단위 파일이 필요합니다.

이제 `/usr/lib/systemd/system/torX`에 두 번째 systemd 단위 파일을 추가합시다:

```bash
[Unit]
Description=TCP를 위한 익명화 오버레이 네트워크
After=syslog.target network.target nss-lookup.target
PartOf=tor-master.service
ReloadPropagatedFrom=tor-master.service

[Service]
Type=notify
NotifyAccess=all
ExecStartPre=/usr/bin/tor --runasdaemon 0 -f /etc/tor/torrcX --DataDirectory /var/lib/tor/X --DataDirectoryGroupReadable 1 --User toranon --verify-config
ExecStart=/usr/bin/tor --runasdaemon 0 -f /etc/tor/torrcX --DataDirectory /var/lib/tor/X --DataDirectoryGroupReadable 1 --User toranon
ExecReload=/bin/kill -HUP ${MAINPID}
KillSignal=SIGINT
TimeoutSec=30
Restart=on-failure
RestartSec=1
WatchdogSec=1m
LimitNOFILE=32768

# 보안 강화
PrivateTmp=yes
DeviceAllow=/dev/null rw
DeviceAllow=/dev/urandom r
ProtectHome=yes
ProtectSystem=full
ReadOnlyDirectories=/run
ReadOnlyDirectories=/var
ReadWriteDirectories=/run/tor
ReadWriteDirectories=/var/lib/tor
ReadWriteDirectories=/var/log/tor
CapabilityBoundingSet=CAP_SETUID CAP_SETGID CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH
PermissionsStartOnly=yes

[Install]
WantedBy=multi-user.target
```

`tor`/`torrc` 뒤의 `X` 접미사를 원하는 이름으로 교체하세요. 저자는 간단함을 위해 숫자를 선호하지만, 어떤 것이든 될 수 있습니다.

이후, 인스턴스의 `torrc` 파일을 `/etc/tor/torrcX`에 추가합니다. 각 인스턴스가 별도의 포트 및/또는 IP 주소를 가지고 있는지 확인하세요.

We will also allow our chosen TCP port `12345` (or the port in `torrcX`) in SELinux and `firewalld`:

```bash
semanage port -a -t tor_port_t -p tcp 12345
firewall-cmd --zone=public --add-port=12345/tcp
firewall-cmd --runtime-to-permanent
```

그 후, `torX` systemd 단위를 활성화합니다:

```bash
systemctl enable --now torX
```

운영하고자 하는 각 릴레이에 대해 이 단계들을 반복하세요.

## 결론

일반적인 VPN 서비스와 달리, Tor는 프라이버시와 익명성을 보장하기 위해 자원봉사자가 운영하는 릴레이를 활용합니다.

Tor 릴레이를 운영하는 것은 신뢰할 수 있는 시스템과 지원하는 ISP가 필요하지만, 더 많은 릴레이를 추가함으로써 프라이버시를 도우며 Tor를 더 빠르고 실패 지점이 적게 만듭니다.
