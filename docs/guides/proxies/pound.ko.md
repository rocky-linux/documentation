---
title: Pound
author: Steven Spencer
contributors:
tested_with: 8.5, 8.6
tags:
  - proxy
  - proxies
---

# 파운드 프록시 서버

!!! 경고 "EPEL-9에서 파운드 누락"

    현재 기록된 시점에서 Rocky Linux 9.0에서는 EPEL 저장소에서 Pound를 설치할 수 없습니다. SRPM 패키지에 대한 소스는 다른 곳에서 찾을 수 있지만, 이러한 소스들의 무결성을 검증할 수 없습니다. 따라서 현재는 Rocky Linux 9.0에 Pound 프록시 서버를 설치하는 것을 권장하지 않습니다. EPEL이 다시 Pound를 지원하기 시작하면 상황이 달라질 수 있습니다.  이 프로시저는 특히 Rocky Linux 8.x 버전을 대상으로 합니다.

## 소개

Pound는 웹 서버에 구애받지 않는 리버스 프록시 및 로드 밸런서로서 설정과 관리가 매우 간단합니다. Pound 자체로는 웹 서비스를 사용하지 않지만 웹 서비스 포트 (http, https)에서 수신합니다.

이제 많은 프록시 서버 옵션이 있으며 일부는 이 설명서 페이지에서 참조됩니다. [HAProxy here](haproxy_apache_lxd.md) 사용에 대한 문서가 있으며 다른 문서에는 리버스 프록시에 Nginx를 사용하는 참조가 있습니다.

로드 밸런싱 서비스는 활발한 웹 서버 환경에 매우 유용합니다. 이전에 언급한 HAProxy를 비롯한 많은 프록시 서버는 다양한 서비스 유형에 사용될 수 있습니다.

Pound의 경우 웹 서비스에만 사용할 수 있지만 자신의 역할을 잘 수행합니다.

## 전제 조건 및 가정

이 프로시저를 사용하기 위해 다음이 최소 요구 사항입니다:

* 일부 웹 사이트 간 로드 밸런싱을 하려는 의도, 또는 새로운 도구를 배우려는 의도
* root 사용자로 명령을 실행하거나 `sudo`를 사용하여 root 권한 획득할 수 있는 능력
* 커맨드 라인 에디터에 익숙합니다. 우리는 여기서 `vi` 또는 `vim`을 사용하고 있지만, 원하는 에디터로 대체해도 좋습니다.
* 일부 종류의 웹 서버의 수신 포트를 변경하는 데 편안함
* Nginx와 Apache 서버가 모두 이미 설치되어 있다고 가정합니다.
* Rocky Linux 서버 또는 컨테이너를 사용하고 있다고 가정합니다.
* 아래에서 설명하는 `https`에 대한 다양한 선언을 기억하세요. 이 가이드는 오로지 `http` 서비스에 대해서만 다룹니다. `https`를 제대로 구성하려면 실제 인증 기관에서 받은 실제 인증서로 Pound 서버를 구성해야 합니다.

!!! tip "팁"

    아직 이 두 서버 중 하나도 설치하지 않았다면, 컨테이너 환경(LXD 또는 Docker) 또는 베어 메탈에서 설치하고 실행할 수 있습니다. 이 프로시저에서는 해당 패키지로 설치하고 서비스를 활성화하고 시작하는 것만 필요합니다. 우리는 이들을 현저하게 변경하지 않을 것입니다.

    ```
    dnf -y install nginx && systemctl enable --now nginx
    ```


    또는

    ```
    dnf -y install httpd && systemctl enable --now httpd
    ```

## 규칙

이 프로시저에서는 두 개의 웹 서버(백엔드 서버라고 함)를 사용할 예정이며, 하나는 Nginx(192.168.1.111), 다른 하나는 Apache(192.168.1.108)가 실행됩니다.

Pound 서버(192.168.1.103)가 게이트웨이 역할을 합니다.

We will be switching our listen ports on both of the back end servers to 8080 for the Nginx server and 8081 for the Apache server. 아래에서 모두 자세히 설명하니 현재는 걱정할 필요가 없습니다.

!!! note

    연관된 IP를 환경에 따라 실제 IP로 변경하고 이를 해당 프로시저 내에서 적용하십시오.

## 파운드 서버 설치

Pound를 설치하려면 먼저 EPEL(Extra Packages for Enterprise Linux)을 설치하고 EPEL에 새로운 사항이 있는 경우에 대비하여 업데이트를 실행해야 합니다:

```
dnf -y install epel-release && dnf -y update
```

그런 다음 단순히 Pound를 설치합니다. (네, "P"는 대문자로 해야 합니다.):

```
dnf -y install Pound
```

## 파운드 구성

패키지가 설치되면 Pound를 구성해야 합니다. `vi`를 사용하여 업데이트할 것입니다만, `nano` 또는 다른 것을 선호하는 경우 해당 에디터로 대체하세요:

```bash
vi /etc/pound.cfg
```

파일은 기본 정보로 설정되어 있어 Pound의 대부분의 기본 구성 요소를 쉽게 확인할 수 있습니다:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 0.0.0.0
    Port 80
End

ListenHTTPS
    Address 0.0.0.0
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 127.0.0.1
        Port    8000
    End

    BackEnd
        Address 127.0.0.1
        Port    8001
    End
End
```

### 자세히 살펴 보기

* "User"와 "Group"은 설치할 때 처리되었습니다.
* "Control" 파일은 어디에서도 사용되지 않는 것으로 보입니다.
* "ListenHTTP" 섹션은 서비스 `http` (포트 80)를 나타내며 프록시가 수신 대기할 "Address"입니다. 이를 실제 Pound 서버의 IP로 변경할 것입니다.
* "ListenHTTPS" 섹션은 서비스 `https` (포트 443)를 나타내며 프록시가 수신 대기할 "Address"입니다. 위와 마찬가지로 Pound 서버의 IP로 변경할 것입니다. "Cert" 옵션은 Pound 설치 프로세스에서 제공하는 자체 서명된 인증서입니다. 실제 환경에서는 이를 실제 인증서로 대체해야 합니다. 이를 위해 다음 중 하나의 프로시저를 사용할 수 있습니다: [SSL 키 생성](../security/ssl_keys_https.md) 또는 \[Let's Encrypt를 사용한 SSL 키\](../security/ generation_ssl_keys_lets_encrypt.md).
* "Service" 섹션에서는 "BackEnd" 서버가 구성되고 수신 포트가 설정됩니다. 필요에 따라 여러 "BackEnd" 서버를 가질 수 있습니다.

### 구성 변경

* 두 수신 옵션에서 IP 주소를 파운드 서버 IP인 192.168.1.103으로 변경합니다.
* 위의 "Conventions"(IP 및 포트)에 있는 구성과 일치하도록 "BackEnd" 섹션 아래의 IP 주소 및 포트를 변경합니다.

구성을 모두 수정한 후 다음과 같은 변경된 파일이 있어야 합니다:

```bash
User "pound"
Group "pound"
Control "/var/lib/pound/pound.cfg"

ListenHTTP
    Address 192.168.1.103
    Port 80
End

ListenHTTPS
    Address 192.168.1.103
    Port    443
    Cert    "/etc/pki/tls/certs/pound.pem"
End

Service
    BackEnd
        Address 192.168.1.111
        Port    8080
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
End
```

## 8080에서 수신 대기하도록 Nginx 구성

Pound 구성에서 Nginx의 수신 포트를 8080으로 설정했으므로 실행 중인 Nginx 서버에서도 해당 변경을 수행해야 합니다. 이를 위해 `nginx.conf`를 수정합니다.

```bash
vi /etc/nginx/nginx.conf
```

"listen" 라인을 새 포트 번호로 변경합니다.

```bash
listen       8080 default_server;
```

변경 사항을 저장한 다음 nginx 서비스를 다시 시작합니다.

```
systemctl restart nginx
```

## 8081에서 수신 대기하도록 Apache 구성

Pound 구성에서 Apache의 수신 포트를 8081로 설정했으므로 실행 중인 Apache 서버에서도 해당 변경을 수행해야 합니다. 이를 위해 `httpd.conf`를 수정합니다.

```bash
vi /etc/httpd/conf/httpd.conf
```

"Listen" 라인을 새 포트 번호로 변경합니다.

```bash
Listen 8081
```

변경 사항을 저장한 후 httpd 서비스를 다시 시작합니다.

```
systemctl restart httpd
```

## 테스트 및 켜기

각 웹 서비스가 올바른 포트로 실행되고 수신하도록 설정한 후, 다음 단계는 Pound 서버에서 pound 서비스를 시작하는 것입니다.

```
systemctl enable --now pound
```

!!! 주의

    여기서 데모하듯이 Nginx와 Apache를 사용하는 경우 대부분의 경우 Nginx 서버가 항상 먼저 응답할 것입니다. 따라서 효과적으로 테스트하려면 Nginx 서버에 낮은 우선순위를 할당하여 두 개의 화면을 모두 볼 수 있어야 합니다. 이는 Apache에 비해 Nginx의 속도를 보여주는 것입니다. Nginx 서버의 우선순위를 변경하려면 다음과 같이 "BackEnd" 섹션에서 우선순위(1-9, 9가 가장 낮은 우선순위)를 추가하면 됩니다.

    ```
    BackEnd
        Address 192.168.1.111
        Port    8080
        Priority 9
    End
    ```

웹 브라우저에서 프록시 서버 IP를 열면 두 가지 중 하나의 화면을 볼 수 있어야 합니다:

![Pound Nginx](images/pound_nginx.jpg)

또는

![Pound Apache](images/pound_apache.jpg)

## 긴급 사용

예를 들어, Pound와 같은 로드 밸런서를 사용하는 경우, 프로덕션 서버를 유지 보수하거나 완전한 중단 시 "BackEnd"에 대한 후퇴 백엔드를 가져야 할 수 있습니다. 이를 `pound.conf` 파일의 "Emergency" 선언으로 수행할 수 있습니다. 한 번에 하나의 "Emergency" 선언만 허용됩니다. 우리의 경우, 이것은 구성 파일의 "Service" 섹션의 끝에 나타날 것입니다.

```
...
Service
    BackEnd
        Address 192.168.1.117
        Port    8080
    Priority 9
    End

    BackEnd
        Address 192.168.1.108
        Port    8081
    End
    Emergency
       Address 192.168.1.104
       Port 8000
   End
End
```

이 서버는 "Down For Maintenance"라는 메시지만 표시할 수 있습니다.

## 보안 고려 사항

로드 밸런싱 프록시 서버와 관련하여 대부분의 문서에서 다루지 않는 보안 문제도 있습니다. 예를 들어, 이것이 공개적으로 공개되는 웹 서버인 경우, 프록시가 전 세계에서 `http` 및 `https` 서비스를 사용할 필요가 있습니다. 그러나 "BackEnd" 서버는 어떻게 해야 할까요?

"BackEnd" 서버는 Pound 서버 자체에서만 해당 포트로 액세스해야 하지만, Pound 서버가 BackEnd 서버로 8080 또는 8081로 리디렉션하고 BackEnd 서버가 해당 후속 포트에서 `http`를 수신하기 때문에 방화벽 명령에 서비스 이름을 사용할 수 있습니다.

이 섹션에서는 이러한 고려 사항과 모든 것을 제한하는 데 필요한 `firewalld` 명령을 다룰 것입니다.

!!! !!!

    여기서는 서버에 직접 액세스할 수 있으며 원격에 있지 않다고 가정합니다. 원격으로 접속 중인 경우 `firewalld` 영역에서 서비스를 제거할 때 매우 조심해야 합니다!
    
    실수로 서버에 접속할 수 없게 될 수 있습니다.

### 방화벽 - Pound 서버

위에서 언급한 대로 Pound 서버의 경우, 전 세계에서 `http` 와 `https`를 허용하려고 합니다. `ssh`도 전 세계에서 허용해야 할지 고려해야 합니다. 서버에 로컬인 경우에는 아마 **NOT** 일 것입니다. 여기에 있는 서버는 로컬 네트워크를 통해 사용할 수 있고 직접 액세스할 수 있다고 가정하므로 LAN IP에`ssh` 를 잠글 것입니다.

이를 위해 Rocky Linux에 내장된 방화벽인 `firewalld`와 `firewall-cmd` 명령 구조를 사용합니다. 간단하게 하기 위해 "public" 및 "trusted"라는 두 개의 내장된 zone도 사용합니다.

먼저 "trusted" zone에 소스 IP를 추가하여 우리의 LAN을 추가합니다. 이것이 우리의 LAN입니다(예: 192.168.1.0/24).

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

다음으로 `ssh` 서비스를 zone에 추가합니다:

```
firewall-cmd --zone=trusted --add-service=ssh --permanent
```

모든 작업이 완료되면 방화벽을 다시 로드하고 변경 사항을 확인합니다:

```
firewall-cmd --reload
```

그런 다음 "trusted" zone을 보려면 `firewall-cmd --zone=trusted --list-all`를 사용하여 다음과 같은 결과를 얻을 수 있습니다:

```bash
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

다음으로 기본적으로 `ssh` 서비스가 활성화된 "public" 영역을 변경해야 합니다. 이를 조심스럽게 제거해야 합니다(다시 말씀드리지만, 여기서는 사용자가 서버에 원격이 **아니라고** 가정합니다!):

```
firewall-cmd --zone=public --remove-service=ssh --permanent
```
또한 `http` 및 `https` 서비스를 추가해야 합니다.

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

그런 다음 변경 사항을 확인하려면 방화벽을 다시 로드해야 합니다.

```
firewall-cmd --reload
```

그런 다음 `firewall-cmd --zone=public --list-all`l을 사용하여 public zone을 확인하면 다음과 같은 결과가 표시됩니다:

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

우리의 lab 환경에서는 이것으로 Pound 서버 로드 밸런서를 모두 제한합니다.

### 방화벽 - 백엔드 서버

"백엔드" 서버에 대해선, 전체적으로 세계에서 접근할 필요가 없으며, 리스닝 포트는 로드 밸런서에서 사용할 예정입니다. LAN IP에서 `ssh`를 허용해야 하며, pound 로드 밸런서로부터 `http` 및 `https`를 허용해야 합니다.

거의 다 됐습니다.

위의 방법과 거의 동일한 명령어로 "trusted" zone에 `ssh` 서비스를 추가합니다. 그런 다음 "balance"라는 새로운 zone을 추가하고  `http` 및 `https`를 처리할 것입니다. 아직 재밌게 하고 있나요?

빨리 하기 위해 단일 명령 집합에서 "trusted" 영역에 사용한 모든 명령을 사용하겠습니다.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

이후 "trusted" 영역은 다음과 같아야 합니다.

```bash
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

다시 LAN의 IP에서 `ssh` 규칙을 테스트한 다음 "public" 영역에서 `ssh`서비스를 제거합니다. **위의 경고를 기억하고 서버에 대한 로컬 액세스 권한이 있는 경우에만 이 작업을 수행하십시오!**

```
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

public zone은 이제 다음과 같아야 합니다.

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

Now let's add that new zone to deal with `http` and `https`. 이때 소스 IP는 로드 밸런서만 포함해야 합니다 (예: 192.168.1.103).

!!! 주의

    새로운 zone은 반드시 `--permanent` 옵션으로 추가해야 하며, 방화벽이 다시 로드되기 전까지 사용할 수 없습니다. 또한 이 zone에 대해 `--set-target=ACCEPT` 를 사용하는 것을 잊지 마세요!

```
firewall-cmd --new-zone=balance --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --set-target=ACCEPT
firewall-cmd --zone=balance --add-source=192.168.1.103 --permanent
firewall-cmd --zone=balance --add-service=http --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --list-all
```

결과는 다음과 같아야 합니다:

```bash
balance (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.103
  services: http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

다른 웹 서버 백엔드에서도 동일한 단계를 반복합니다.

모든 서버에 방화벽 규칙을 추가한 후 워크스테이션 브라우저에서 pound 서버를 다시 테스트합니다.

## 기타 정보

`pound.conf` 파일에는 에러 메시지 지시문, 로깅 옵션, 타임아웃 값 등이 포함될 수 있는 *많은* 옵션이 있습니다. 이용 가능한 자세한 정보는 [여기를 참조](https://linux.die.net/man/8/pound)하세요.

Pound는 자동으로 "BackEnd" 서버 중 하나가 오프라인인 경우 이를 비활성화하여 웹 서비스를 지연 없이 계속 실행합니다. 다시 온라인이 되면 자동으로 인식합니다.

## 결론

Pound는 HAProxy 또는 Nginx를 사용하고 싶지 않은 사용자들을 위해 로드 밸런싱으로 사용할 수 있는 다른 옵션을 제공합니다.

Pound는 로드 밸런싱 서버로서 매우 쉽게 설치, 설정 및 사용할 수 있습니다. 여기에서 설명한 대로 Pound는 리버스 프록시로서도 사용할 수 있으며, 프록시 및 로드 밸런싱에 대한 다양한 옵션이 있습니다.

서비스를 설정할 때 보안을 항상 염두에 두는 것이 중요합니다. 로드 밸런싱 프록시 서버를 포함하여 모든 서비스를 설정할 때도 보안에 유의해야 합니다.
