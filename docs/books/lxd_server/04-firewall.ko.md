---
title: 4 방화벽 설정
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd 보안
---

# 4장: 방화벽 설정

이 장에서는 루트가 되거나 루트가 되려면 `sudo`가 가능해야 합니다.

서버와 마찬가지로 외부 세계와 로컬 네트워크에서 보안이 보장되어야 합니다. 예시 서버에는 LAN 인터페이스만 있지만, LAN 및 WAN 네트워크를 각각 직면한 두 개의 인터페이스를 가질 수도 있습니다.

!!! 참고 "Rocky Linux 9.0에 관한 참고 사항"

    Rocky Linux 9.0부터 `iptables` 및 모든 관련 유틸리티는 공식적으로 사용되지 않습니다. 따라서 향후 버전의 운영 체제에서는 완전히 사라질 예정입니다. 따라서 계속하기 전에 아래의 `firewalld` 절차로 건너뛰어야 합니다. 
    
    Rocky Linux 8.6에도 `firewalld`를 사용하는 것이 실제로 좋은 생각이지만 실제로 원하는 경우 `iptables`를 사용할 수 있는 옵션을 제공합니다.

## 방화벽 설정 - `firewalld`

_firewalld_규칙을 사용하려면 이 [기본 절차](../../guides/security/firewalld.md)를 사용하거나 해당 개념에 익숙해야 합니다. 우리의 가정은 다음과 같습니다: LAN 네트워크는 192.168.1.0/24이고 브리지는 lxdbr0입니다. 명확하게 말하자면, LXD 서버에는 WAN을 바라보는 인터페이스를 포함하여 여러 인터페이스가 있을 수 있습니다. 또한 브리지 및 로컬 네트워크를 위한 영역을 생성할 것입니다. 이는 단순히 영역을 명확하게 구분하기 위한 것입니다. 다른 영역 이름은 실제로 적용되지 않습니다. 이 절차는 이미 firewalld의 기본 개념을 알고 있다고 가정합니다.

```
firewall-cmd --new-zone=bridge --permanent
```

영역을 추가한 후 방화벽을 다시 로드해야 합니다.

```
firewall-cmd --reload
```

또한 브리지된 인터페이스에서 모든 트래픽을 수락하고 있습니다. 그런 다음 로컬 인터페이스에 대한 소스 IP를 추가하고 대상을 "ACCEPT"로 변경하면 됩니다.

!!! 주의

    `firewalld` 영역의 대상을 변경하는 것은 *무조건* `--permanent` 옵션을 사용하여 수행해야 합니다. 따라서 다른 명령어에서도 `--runtime-to-permanent` 옵션을 사용하지 않고 단지 해당 플래그를 입력하면 됩니다.

!!! 참고 사항

    인터페이스 또는 소스에 대한 모든 액세스를 허용하려면 프로토콜이나 서비스를 지정하지 않으려면 대상을 "default"에서 "ACCEPT"로 변경해야 합니다. 사용자 정의 영역에 대한 특정 IP 블록의 경우 "DROP" 및 "REJECT"도 마찬가지입니다. 명확히 말하면, 사용자 정의 영역을 사용하지 않는 한 "drop" 영역이 자동으로 처리해줄 것입니다.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
오류가 없고 모든 것이 여전히 작동한다고 가정하면 새로고침을 수행합니다.

```
firewall-cmd --reload
```
이제 `firewall-cmd --zone=bridge --list-all`을 사용하여 규칙을 나열하면 다음과 같이 표시됩니다.

```
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: lxdbr0
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
참고로 로컬 인터페이스도 허용해야 합니다. 위에서 설명한 것과 같이 내장된 영역 이름은 이에 적합하지 않습니다. 로컬 인터페이스에 대한 소스 IP 범위를 사용하여 영역을 생성하고 액세스를 보장하기 위해 다음 명령어를 실행합니다.

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
로컬 인터페이스의 소스 IP를 추가하고 대상을 "ACCEPT"로 변경합니다.

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
계속해서 "로컬" 영역을 나열하여 `firewall-cmd --zone=local --list all`과 함께 규칙이 있는지 확인하면 다음과 같이 표시됩니다.

```
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
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

신뢰하는 네트워크에서 SSH를 허용해야 합니다. 여기에서 소스 IP와 기본 "trusted" 영역을 사용합니다. 이 영역의 대상은 기본적으로 "ACCEPT"로 설정되어 있습니다.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
영역에 서비스를 추가합니다.

```
firewall-cmd --zone=trusted --add-service=ssh
```
모든 것이 작동하는 경우 규칙을 영구적으로 이동하고 규칙을 다시 로드합니다.

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
"trusted" 영역을 나열하여 다음과 같은 결과가 나오는지 확인합니다.

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
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

기본적으로 "public" 영역은 활성 상태이며 SSH가 허용되어 있습니다. 보안을 위해 "public" 영역에서 SSH를 허용하지 않아야 합니다. 서버에 대한 액세스가 LAN IP 중 하나로 이루어지고 있는지 확인하여 올바른 영역을 사용하는지 확인하세요 (우리 예제에서는). 계속하기 전에 이를 확인하지 않으면 서버에서 잠금이 발생할 수 있습니다. 올바른 인터페이스로부터 액세스할 수 있는지 확실할 때, "public" 영역에서 SSH를 제거하세요.

```
firewall-cmd --zone=public --remove-service=ssh
```

액세스를 테스트하고 잠금 상태가 아닌지 확인합니다. 그렇지 않은 경우 규칙을 영구적으로 설정하고 다시 로드하고 "public" 영역을 나열하여 SSH가 제거되었는지 확인합니다.

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

서버에는 고려해야 할 다른 인터페이스가 있을 수 있습니다. 필요한 경우 내장된 영역을 사용할 수 있지만, 이름이 논리적으로 보이지 않는 경우 영역을 추가할 수도 있습니다. 다만, 특정하게 허용하거나 거부해야 할 서비스나 프로토콜이 없는 경우에는 영역 대상을 변경해야 함을 기억하세요. 브리지와 같은 인터페이스 사용이 작동한다면 그렇게 사용할 수 있습니다. 서비스에 대해 더 정밀한 액세스가 필요한 경우 소스 IP를 사용하세요.
