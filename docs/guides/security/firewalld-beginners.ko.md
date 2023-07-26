---
title: 초보자를 위한 firewalld
author: Ezequiel Bruni
contributors: Steven Spencer
---

# 초보자를 위한 `firewalld`

## 소개

오래 전에 나는 작고 새내기 컴퓨터 사용자로서 방화벽을 가지는 것이 아주 좋다는 얘기를 들었습니다. 내 컴퓨터로 무엇이 들어오고 무엇이 나가는지 내가 결정할 수 있을 거라고 말이에요. 그런데 대부분은 내 비디오 게임이 인터넷에 접속하지 못하게 막는 것처럼 보였습니다. 나는 기분이 좋지 않았습니다.

물론 여기 오신 분들은 아마도 내가 그 때 그냥 이해하지 못했던 방화벽이 무엇이고 어떻게 작동하는지에 대해 더 잘 아시고 계실 것입니다. 그러나 방화벽 경험이 Windows Defender에게 새로운 앱이 인터넷을 사용할 수 있도록 허용한다고 알려주는 것에 지나지 않는다면 걱정하지 마십시오. 맨 위에 "초보자용"이라고 되어 있습니다. 제가 잘 설명해드리겠습니다.

다른 말로 하자면, 제 동료들은 많은 설명이 있을 것이라는 것을 알아야 합니다.

그래서, 우리가 여기 온 이유에 대해 이야기해 보겠습니다. `firewalld`는 Rocky Linux에 기본으로 제공되는 방화벽 앱으로서, 사용하기 매우 간단하게 설계되었습니다. 방화벽이 어떻게 작동하는지 약간 알아야 하고, 명령 줄을 사용하는 데 두려워하지 않아야 합니다.

여기서 다음을 배울 수 있습니다:

* `firewalld`의 매우 기본적인 작동 방식
* `firewalld`를 사용하여 들어오는 및 나가는 연결을 제한하거나 허용하는 방법
* 특정 IP 주소나 위치에서만 원격으로 로그인할 수 있도록 허용하는 방법
* Zone과 같은 `firewalld` 특정 기능 관리하는 방법

이것은 완전하거나 전체적인 가이드가 *아닙니다*.

### 명령 줄을 사용하여 방화벽을 관리하는 것에 대한 참고사항

음... 그래픽 방화벽 구성 옵션이 *있습니다*. 데스크톱에는 저장소에서 설치할 수 있는 `firewall-config`가 있고, 서버에는 [Cockpit을 설치](https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/)하여 방화벽 및 기타 여러 항목을 관리하는 데 도움이 됩니다. **그러나 이 튜토리얼에서는 몇 가지 이유로 명령 줄 방식을 가르쳐 드리겠습니다**.

1. 서버를 실행하는 경우 대부분의 작업을 명령 줄로 수행할 것입니다. 많은 Rocky 서버용 튜토리얼과 가이드에서 방화벽 관리를 위한 명령 줄 지시문을 제공하므로 그 지시문을 이해하는 것이 최선입니다. 단순히 보기만 하고 복사해 붙여넣기를 하지 말고 지시사항을 이해하는 것이 좋습니다.
2. `firewalld` 명령어가 작동하는 방식을 이해하면 방화벽 소프트웨어가 어떻게 작동하는지 더 잘 이해할 수 있습니다. 여기서 배우는 원칙을 동일하게 적용하여 미래에 그래픽 인터페이스를 사용할 때 더 잘 이해할 수 있습니다.

## 전제 조건 및 가정
다음이 필요합니다:

* 현지 또는 원격, 물리 또는 가상인 어떤 종류의 Rocky Linux 장치
* 터미널 접속 가능하며, 사용하기를 원하는 마음가짐
* 루트 액세스가 필요하거나 적어도 사용자 계정에서 `sudo`를 사용할 수 있어야 합니다. 간단함을 위해 모든 명령은 루트로 실행되는 것으로 가정합니다.
* 원격 머신 관리를 위한 기본적인 SSH 이해도 도움이 될 수 있습니다.

## 기본 사용법

### 시스템 서비스 명령

`firewalld`는 시스템에서 서비스로 실행됩니다. 기기가 시작될 때 시작되거나 그렇게 되어야 합니다. 무슨 이유에서인지 `firewalld`가 기기에서 이미 활성화되어 있지 않다면 다음 명령을 사용하여 활성화할 수 있습니다:

```bash
systemctl enable --now firewalld
```

`--now` 플래그는 서비스를 활성화하는 동시에 시작하도록 하며, `systemctl start firewalld` 단계를 건너뛸 수 있습니다.

Rocky Linux의 모든 서비스와 마찬가지로 다음 명령으로 방화벽이 실행 중인지 확인할 수 있습니다:

```bash
systemctl status firewalld
```

전체 중지하려면:

```bash
systemctl stop firewalld
```

그리고 서비스를 강제로 다시 시작하려면:

```bash
systemctl restart firewalld
```

### `firewalld` 기본 구성 및 관리 명령어

`firewalld`는 `firewall-cmd` 명령으로 구성됩니다. 예를 들어, 다음 명령으로 `firewalld`의 상태를 확인할 수 있습니다:

```bash
firewall-cmd --state
```

*영구적인 변경* 후에는 변경 사항을 확인하려면 방화벽을 다시 로드해야 합니다. 방화벽 구성에 "소프트 리스타트"를 제공할 수 있습니다:

```bash
firewall-cmd --reload
```

!!! note "참고사항"

    영구적으로 적용되지 않은 구성을 다시 로드하면 해당 변경 사항이 사라집니다.

모든 구성 및 설정을 한 번에 보려면 다음 명령을 사용할 수 있습니다:

```bash
firewall-cmd --list-all
```

이 명령은 다음과 유사한 결과를 출력합니다:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
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

### 변경 사항 저장

!!! 경고 "경고: 진지하게 다음 비트를 읽으십시오."

    기본적으로 `firewalld`의 구성 변경 사항은 일시적입니다. 전체 `firewalld` 서비스를 다시 시작하거나 기기를 다시 시작하면 방화벽에 대한 변경 사항이 저장되지 않습니다.

작업하시는 모든 변경 사항을 하나씩 테스트하고 방화벽 구성을 다시 로드하는 것이 좋습니다. 이렇게 하면 실수로 어떤 것에 대한 액세스를 차단하더라도 서비스를 다시 시작(또는 장치를 다시 시작)하면 이전에 언급한대로 변경 사항이 사라집니다.

작동하는 구성이 있다면 다음 명령으로 변경 사항을 영구적으로 저장할 수 있습니다:

```bash
firewall-cmd --runtime-to-permanent
```

그러나 무엇을 하는지 확실하다면 굳이 변경할 필요 없이 다음과 같이 `--permanent` 플래그를 구성 명령어 뒤에 추가하여 바로 규칙을 추가할 수 있습니다:

```bash
firewall-cmd --permanent [the rest of your command]
```

## Zone 관리

먼저, Zone에 대해 설명해야 합니다. Zone은 기본적으로 다른 상황에 다른 규칙 세트를 정의할 수 있도록 해주는 기능입니다. Zone은 `firewalld`의 주요 구성 요소이므로 어떻게 작동하는지 이해하는 것이 중요합니다.

기기가 여러 네트워크에 연결할 수 있는 경우(예: 이더넷과 Wi-Fi), 한 연결이 다른 연결보다 신뢰할 수 있는지를 결정할 수 있습니다. 이더넷 연결이 빌드한 로컬 네트워크에만 연결되어 있으며 Wi-Fi(인터넷에 연결되었을 수도 있는)를 "public" 존에 더 강력한 제한 사항을 적용할 수 있습니다.

!!! note "참고사항"

    Zone은 다음 두 가지 조건 중 *하나를 만족하는 경우*에만 활성 상태가 될 수 있습니다:

    1. Zone이 네트워크 인터페이스에 할당되어 있는 경우
    2. Zone이 소스 IP나 네트워크 범위에 할당되어 있는 경우(자세한 내용은 아래에서 설명합니다)

기본 Zone은 다음과 같습니다(\[DigitalOcean의 'firewalld' 가이드\](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using- firewalld-on-centos-8)에서 가져온 설명입니다. 해당 가이드도 읽어보시기 바랍니다):

> **drop:** 가장 낮은 신뢰 수준. 모든 들어오는 연결을 응답 없이 삭제하고, 나가는 연결만 허용됩니다.

> **block:** 위와 유사하지만, 연결을 간단히 삭제하는 대신, 들어오는 요청은 icmp-host-prohibited 또는 icmp6-adm-prohibited 메시지와 함께 거부됩니다.

> **public:** 공개, 믿을 수 없는 네트워크를 나타냅니다. 다른 컴퓨터를 신뢰하지 않지만 필요한 경우 선택적으로 들어오는 연결을 허용합니다.

> **external:** 게이트웨이로 방화벽을 사용하는 경우 외부 네트워크를 나타냅니다. NAT 매스커레이딩이 구성되어 내부 네트워크는 비공개로 유지되지만 도달 가능합니다.

> **internal:** external 존의 다른 쪽으로 게이트웨이의 내부 부분에 사용됩니다. 컴퓨터는 상당히 신뢰할 수 있으며 추가 서비스를 사용할 수 있습니다.

> **dmz:** 네트워크의 나머지 부분에 액세스할 수 없는 격리된 컴퓨터에 사용됩니다. 특정 들어오는 연결만 허용됩니다.

> **work:** 작업용 컴퓨터에 사용됩니다. 네트워크의 대부분의 컴퓨터를 신뢰합니다. 추가 서비스를 허용할 수 있습니다.

> **home:** 가정 환경에 사용됩니다. 일반적으로 대부분의 다른 컴퓨터를 신뢰하며 몇 가지 서비스를 더 허용합니다.

> **trusted:** 네트워크의 모든 기기를 신뢰합니다. 사용 가능한 옵션 중에서 가장 개방적이며 절제해서 사용해야 합니다.

좋아요, 그래서 그 설명들 중 일부는 복잡해요, 하지만 솔직히요? 그래서 일부 설명은 복잡할 수 있지만, 솔직히 초보자는 "trusted", "home", "public"을 이해하고 언제 어떤 것을 사용해야 하는지 알고 있으면 충분합니다.

### Zone 관리 명령

기본 Zone을 확인하려면 다음 명령을 실행합니다:

```bash
firewall-cmd --get-default-zone
```

활성화되어 작동 중인 Zone을 확인하려면 다음 명령을 실행합니다:

```bash
firewall-cmd --get-active-zones
```

!!! 참고 "참고: 이 중 일부는 이미 설정되어 있을 수 있습니다."

    VPS에서 Rocky Linux를 실행 중이라면 기본 구성이 이미 설정되어 있을 수 있습니다. 특히 SSH를 통해 서버에 액세스하고, 네트워크 인터페이스가 이미 "public" Zone에 추가되어 있어야 합니다.

기본 Zone을 변경하려면:

```bash
firewall-cmd --set-default-zone [your-zone]
```

네트워크 인터페이스를 Zone에 추가하려면:

```bash
firewall-cmd --zone=[your-zone] --add-interface=[your-network-device]
```

네트워크 인터페이스의 Zone을 변경하려면:

```bash
firewall-cmd --zone=[your-zone] --change-interface=[your-network-device]
```

인터페이스를 Zone에서 완전히 제거하려면:

```bash
firewall-cmd --zone=[your-zone] --remove-interface=[your-network-device]
```

완전히 사용자 정의된 새 Zone을 만들고 제대로 추가되었는지 확인하려면:

```bash
firewall-cmd --new-zone=[your-new-zone]
firewall-cmd --get-zones
```

## 포트 관리

처음 접하는 사람들을 위해 포트(이 문맥에서)는 컴퓨터가 서로 연결되어 정보를 주고받을 수 있는 가상의 끝점입니다. 이해하기 쉽게 말하면 컴퓨터의 물리적인 이더넷이나 USB 포트와 비슷하지만 보이지 않으며, 한 번에 최대 65,535개의 포트를 모두 사용할 수 있습니다.

나는 그렇게 하지 않겠지만 당신은 할 수 있습니다.

모든 포트는 번호로 정의되며, 일부 포트는 특정 서비스와 정보의 유형을 위해 예약되어 있습니다. 웹 서버로 웹 사이트를 만드는 경험이 있다면, 예를 들어 포트 80과 포트 443에 대해 익숙할 수 있습니다. 이러한 포트는 웹 페이지 데이터의 전송을 가능하게 합니다.

구체적으로, 포트 80은 HTTP(Hypertext Transfer Protocol)를 통한 데이터 전송을 허용하고, 포트 443은 HTTPS(Hypertext Transfer Protocol Secure) 데이터에 예약되어 있습니다.

포트 22는 Secure Shell 프로토콜(SSH)에 예약되어 있으며, 이를 통해 명령 줄을 통해 다른 기기에 로그인하고 관리할 수 있습니다 (해당 주제에 대해 [간단한 가이드](ssh_public_private_keys.md)를 참조하십시오). 새로운 원격 서버는 SSH의 포트 22를 통한 연결만 허용하고 있을 수 있으며, 다른 어떤 연결도 허용하지 않을 수 있습니다.

다른 예로 FTP(포트 20 및 21), SSH(포트 22) 등이 있습니다. 또한 기존의 표준 번호가 없는 새로운 앱에 대해 사용자 정의 포트를 설정할 수도 있습니다.

!!! 참고 "참고: 모든 것에 포트를 사용해서는 안 됩니다."

    SSH, HTTP/S, FTP 등의 경우 실제로는 포트 번호보다 *서비스*로 방화벽 Zone에 추가하는 것이 권장됩니다. 이하에서 그 작동 방식을 보여드리겠습니다. 그렇지만 포트를 수동으로 열 방법을 알아야 합니다.

\* 초보자를 위해 HTTPS는 기본적으로 HTTP와 거의 동일하지만 암호화된 것입니다.

### 포트 관리 명령

이 섹션에서는 `--zone=public`... 을 사용하고 무작위로 9001 포트를 예시로 사용하겠습니다.

모든 열려있는 포트를 확인하려면:

```bash
firewall-cmd --list-ports
```

포트를 방화벽 Zone에 추가하여(따라서 사용 가능하게) 포트를 열려면, 다음 명령을 실행합니다:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
```

!!! 참고 사항

    해당 `/tcp` 비트 정보:
    
    마지막에 붙는 `/tcp` 부분은 방화벽에 들어오는 연결이 대부분 서버 및 홈 관련 작업에 사용되는 전송 제어 프로토콜(TCP)을 통해 온다는 것을 방화벽에 알려줍니다.
    
    UDP와 같은 대체 프로토콜은 디버깅이나 이 가이드의 범위를 벗어나는 매우 특정한 종류의 작업에 사용됩니다. 특정 앱이나 서비스에 대해 포트를 열려면 해당 문서를 참조하십시오.

포트를 제거하려면 한 단어를 바꾸는 것만으로 명령을 반대로 실행합니다:

```bash
firewall-cmd --zone=public --remove-port=9001/tcp
```

## 서비스 관리

서비스는 상당히 표준화된 프로그램으로, 컴퓨터에서 실행됩니다. `firewalld`는 일반적인 서비스에 필요한 포트를 필요할 때마다 열도록 설정되어 있습니다.

다음은 이러한 일반적인 서비스와 훨씬 더 많은 서비스를 위한 포트를 열기 위한 우선 방법입니다.

* HTTP 및 HTTPS: 웹 서버용
* FTP: 파일을 앞뒤로 이동(구식 방식)
* SSH: 원격 시스템 제어 및 새로운 방식으로 파일 이동
* Samba: Windows 시스템과 파일 공유용

!!! 주의

    **원격 서버의 방화벽에서 SSH 서비스를 제거하지 마십시오!**
    
    기억하세요, SSH는 서버에 로그인하는 데 사용합니다. 물리적 서버에 다른 방법이나 셸에 액세스하는 다른 방법이 없는 경우 (예: 호스트가 제공하는 제어판을 통해) SSH 서비스를 제거하면 영구적으로 기기에 액세스할 수 없게 됩니다. 호스트에서 제공하는 제어판) SSH 서비스를 제거하면 영구적으로 잠깁니다.
    
    액세스 권한을 되찾기 위해 지원팀에 문의하거나 OS를 완전히 재설치해야 할 수 있습니다.

## 서비스 관리 명령어

방화벽에 추가할 수 있는 모든 사용 가능한 서비스 목록을 확인하려면 다음 명령을 실행합니다:

```bash
firewall-cmd --get-services
```

방화벽에서 현재 활성화된 서비스를 확인하려면 다음 명령을 사용하세요:

```bash
firewall-cmd --list-services
```

방화벽에서 서비스를 열려면(예: 공개 영역의 HTTP) 다음을 사용합니다.

```bash
firewall-cmd --zone=public --add-service=http
```

방화벽에서 서비스를 제거하려면 단어를 변경하면 됩니다.

```bash
firewall-cmd --zone=public --remove-service=http
```

!!! 참고 "참고: 사용자 정의 서비스를 추가할 수 있습니다."

    그리고 그 서비스를 완전히 사용자 정의할 수도 있습니다. 그러나 이것은 꽤 복잡한 주제입니다. 먼저 `firewalld`를 익힌 다음에 추가로 공부하세요.

## 액세스 제한

서버가 있고 공개하고 싶지 않다고 가정해 보겠습니다. 예를 들어 서버가 있고 공개적으로 접근하고 싶지 않다면, SSH로 접근을 허용할 수 있는 사람들이나 개인 웹 페이지/앱을 볼 수 있는 사람들을 정의할 수 있습니다.

이를 위한 몇 가지 방법이 있습니다. 먼저 더 제한된 서버를 원한다면, 더 제한적인 Zone 중 하나를 선택하고 네트워크 장치를 할당한 다음, 위에서 보여준대로 SSH 서비스를 추가하고, 자신의 공인 IP 주소를 화이트리스트로 추가할 수 있습니다:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< insert your IP here]
```

IP 주소의 범위를 지정하려면 끝에 높은 숫자를 추가하면 됩니다:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< insert your IP here]
```

다시 말하지만, 이 과정을 반대로 하기 위해 `--add-source`를 `--remove-source`로 바꿔주면 됩니다.

그러나 원격 서버를 관리하고 여전히 하나의 IP 주소나 소량의 IP 범위만을 위해 SSH를 열고 싶다면 두 가지 방법이 있습니다. 이 두 예제에서는 단일 네트워크 인터페이스가 공개 Zone에 할당되어 있습니다.

첫 번째로, "rich rule"을 공개 Zone에 추가할 수 있으며, 다음과 같이 보일 것입니다:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'
```

리치 규칙이 있는 경우, 규칙을 영구적으로 *만들지 마세요*. 먼저, 공개 Zone 구성에서 SSH 서비스를 제거하고, 연결이 여전히 SSH를 통해 서버에 접근할 수 있는지 확인하기 위해 연결을 테스트합니다.

이제 구성이 다음과 같아야 합니다.

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept
```


두 번째로, 두 가지 다른 Zone을 동시에 사용할 수 있습니다. 인터페이스를 공개 Zone에 바인딩한 경우, 두 번째 Zone(예: "trusted" Zone)을 활성화하려면 IP 또는 IP 범위를 추가하여 사용할 수 있습니다. 그런 다음 SSH 서비스를 trusted Zone에 추가하고, public Zone에서 제거합니다.

작업을 마치면 출력은 다음과 같아야 합니다:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
your@server ~# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/24
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

만약 잠겨서 접근하지 못하게 되었다면 서버를 재시작하고 (대부분의 VPS 제어판에 이 옵션이 있음) 다시 시도하세요.

!!! 주의

    이 기법은 정적 IP 주소를 가지고 있는 경우에만 작동합니다.
    
    모뎀이 재부팅될 때마다 IP 주소를 변경하는 인터넷 서비스 제공업체를 사용하고 있다면 문제를 해결할 때까지 이러한 규칙을 사용하지 마십시오(적어도 SSH는 제외). 그렇게 하면 서버에 접근할 수 없게 될 수 있습니다. 인터넷 요금제/제공자를 업그레이드하거나 전용 IP를 제공하는 VPN을 사용하고, 절대로 IP를 잃지 마세요.
    
    그 동안은 Brute Force 공격을 줄이는 데 도움이 되는 [fail2ban 설치 및 구성](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8)하세요.
    
    당연하지만, 직접 IP 주소를 수동으로 설정할 수 있는 로컬 네트워크에서는 이러한 규칙을 자유롭게 사용할 수 있습니다.

## 최종 참고 사항

이것은 더 상세한 가이드가 필요한 부분이며, [공식 `firewalld` 문서](https://firewalld.org/documentation/)에서 많은 것을 배울 수 있습니다. 또한 인터넷에는 특정 앱에 대해 방화벽을 설정하는 방법을 보여주는 유용한 가이드도 많이 있습니다.

`iptables`의 팬이신 경우(지금까지 왔다면...), `firewalld`와 `iptables`의 작동 방식에 대한 차이에 대해 설명한 [가이드](firewalld.md)가 있습니다. 그 가이드를 통해 `firewalld`를 계속 사용할지 아니면 The Old Ways<sup>(TM)</sup>으로 돌아갈지 결정할 수 있을 것입니다. 이 경우에는 The Old Ways<sup>(TM)</sup>으로 돌아가는 것도 생각해볼만합니다.

## 결론

위에 언급한 기본사항들을 설명하는 데에 최대한 많은 단어를 사용하여 `firewalld`에 대해 설명해 보았습니다. 천천히 진행하고, 조심스럽게 실험하며, 확실하게 작동하는 규칙을 영구적으로 만들기 전까지는 영구적으로 만들지 마세요.

그리고 물론, 즐기세요. 기본사항을 익히고 나면, 실제로 제대로 작동하는 방화벽을 설정하는 데에 5-10분이 걸릴 수 있습니다.
