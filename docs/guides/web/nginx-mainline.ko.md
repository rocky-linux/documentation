---
title: Nginx
author: Ezequiel Bruni
contributors: Antoine Le Morvan, Steven Spencer
tested_with: 8.5
tags:
  - nginx
  - web
---

# Rocky Linux에 최신 Nginx 설치 방법

## 소개

*Nginx*는 빠르고 효율적이며 상상할 수 있는 거의 모든 환경과 호환되는 웹 서버입니다. 개인적으로 자주 사용하며, 사용법을 익히면 설정과 설치가 꽤 쉽습니다. 이에 따라 초보자를 위한 이 가이드를 작성했습니다.

다음은 Nginx의 주요 기능입니다:

* 기본 웹 서버 기능
* 다중 사이트로 트래픽을 연결하는 역방향 프록시
* 다중 웹 사이트의 트래픽을 관리하는 내장 로드 밸런서
* 속도를 위한 내장 파일 캐싱
* 웹 소켓
* FastCGI 지원
* 물론 IPv6

정말 훌륭합니다! 그러면 `sudo dnf install nginx`만 하면 되는 걸까요? 사실은 그렇지 않습니다. 먼저 "mainline" 브랜치를 활성화하여 최신 버전의 Nginx를 사용할 수 있도록 올바른 모듈을 활성화해야 합니다.

!!! note "참고 사항"

    "stable" 브랜치라는 다른 브랜치가 있지만, 대부분의 사용 사례에는 조금 오래된 상태입니다. 이 브랜치는 개발 중인 새로운 기능을 받지 않으며, 가장 긴급한 버그 수정과 보안 업그레이드만 받습니다.
    
    Nginx 개발자는 "mainline" 브랜치가 *모든 새로운 기능, 모든 보안 수정 및 모든 버그 수정*을 제공하므로 일반적인 사용을 위해 잘 테스트되고 안정적이라고 생각합니다.
    
    "stable" 브랜치를 사용하는 유일한 이유는 다음과 같습니다:
    * 당신은 *진짜** 새로운 기능과 큰 수정 사항이 타사 코드나 사용자 정의 코드를 손상시키지 않는지 확인하고 싶습니다.
    * Rocky Linux 소프트웨어 저장소만 사용하고 싶을 때
    
    이 가이드의 끝에는 "stable" 브랜치를 최소한의 노력으로 활성화하고 설치하는 방법에 대한 튜토리얼이 있습니다.

## 전제 조건 및 가정

다음이 필요합니다:

* 인터넷에 연결된 Rocky Linux 장치 또는 서버
* 명령 줄에 대한 기본적인 이해
* root 사용자 또는 `sudo`를 사용하여 명령을 실행할 수 있는 권한
* 그래픽 또는 명령 줄 기반의 텍스트 편집기. 이 튜토리얼에서는 `nano`를 사용합니다.

## 저장소 설치 & 모듈 활성화

먼저, 시스템을 업데이트합니다:

```bash
sudo dnf update
```

그런 다음 `epel-release` 소프트웨어 저장소를 설치합니다:

```bash
sudo dnf install epel-release
```

그리고 최신 버전의 `nginx`에 대한 올바른 모듈을 활성화합니다. 이 모듈은 항상 `nginx:manline`이라고 불립니다. 따라서 다음과 같이 `dnf`를 사용하여 활성화합니다:

```bash
sudo dnf module enable nginx:mainline
```

이것은 Gary Gygax가 직접 참여하는 2판 D&D가 아니므로, 예를 선택하세요. 물론입니다. 확인하려면 <kbd>y</kbd>를 누르세요.

## Nginx 설치 및 실행

그런 다음 이전에 추가한 저장소에서 `nginx` 패키지를 설치합니다:

```bash
sudo dnf install nginx
```

터미널에서 저장소의 GPG 키를 설치하겠냐는 메시지가 표시됩니다. 필요하므로 `Y`를 선택하세요.

설치가 완료되면, 다음 명령을 사용하여 `nginx` 서비스를 시작하고 부팅 시 자동으로 시작되도록 설정합니다:

```bash
sudo systemctl enable --now nginx
```

최신 버전의 *Nginx*가 설치되었는지 확인하려면 다음 명령을 실행하세요:

```bash
nginx -v
```

그런 다음, 간단한 정적 웹 사이트를 구축하기 위해 HTML 파일을 `/usr/share/nginx/html/` 디렉토리에 넣을 수 있습니다. 기본 웹사이트/가상 호스트의 설정 파일은 "nginx.conf"로, `/etc/nginx/`에 있습니다. 이 파일에는 기본 Nginx 서버 설정 외에도 다른 여러 가지 설정이 포함되어 있습니다. 실제 웹 사이트 설정을 다른 파일로 이동하더라도 "nginx.conf"의 나머지 부분은 그대로 두는 것이 좋습니다.

## 방화벽 구성

!!! note "참고 사항"

    LXD/LXC 또는 Docker와 같은 컨테이너에 Nginx를 설치하는 경우, 일단이 부분은 건너뛰어도 됩니다. 방화벽은 호스트 운영 체제에서 처리해야 합니다.

다른 컴퓨터에서 해당 장치의 IP 주소 또는 도메인 이름으로 웹 페이지를 보려고 시도하면 아무것도 표시되지 않을 것입니다. 왜냐하면 방화벽이 실행 중이기 때문입니다.

실제로 웹 페이지를 "보기" 위해 필요한 포트를 열기 위해 Rocky Linux의 내장 방화벽인 `firewalld`를 사용할 것입니다. 이를 수행하는 `firewalld` 명령은 `firewall-cmd`입니다. 두 가지 방법이 있습니다: 공식 방법과 메뉴얼 방법. 이 경우에는 공식 방법이 가장 좋지만, 차후 참고를 위해 두 가지 방법을 알아두는 것이 좋습니다.

공식 방법은 방화벽을 `http` 서비스에 개방하며, 당연히 웹 페이지를 처리하는 서비스입니다. 다음 명령을 실행하세요:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
```

이것을 자세히 살펴보겠습니다:

* `-–permanent` 플래그는 방화벽이 재시작되거나 서버 자체가 재시작될 때마다 이 구성이 사용되도록 방화벽에 알려줍니다.
* `–-zone=public`는 이 포트로 들어오는 연결을 모든 사용자로부터 받도록 방화벽에 지시합니다.
* 마지막으로, `--add-service=http`는 `firewalld`가 모든 HTTP 트래픽을 서버로 전달하도록 합니다.

Now here's the manual way to do it. 거의 동일하지만 HTTP가 사용하는 포트인 80번을 명시적으로 열어줍니다.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
```

* `–-add-port=80/tcp`  이 경우에 원하는 대로, 포트 80을 통해 들어오는 연결을 받아들이도록 방화벽에 지시합니다.

SSL/HTTPS 트래픽에 대해 위와 동일한 프로세스를 반복하려면 명령을 다시 실행하고 서비스 및/또는 포트 번호를 변경하세요.

```bash
sudo firewall-cmd --permanent --zone=public --add-service=https
# 또는 다른 경우에는:
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
```

이러한 구성은 강제로 적용되기 전까지는 적용되지 않습니다. 이를 위해 `firewalld`에게 구성을 다시 불러오도록 알려야 합니다.

```bash
sudo firewall-cmd --reload
```

!!! 참고 사항

    이제 이것이 작동하지 않을 가능성이 매우 적습니다. 드물게 발생하는 경우에는 예전 방식으로 "끄고 켜기"를 하여 `firewalld`에게 원하는 대로 동작하도록 할 수 있습니다.

    ```bash
    systemctl restart firewalld
    ```

포트가 제대로 추가되었는지 확인하려면 `firewall-cmd --list-all`을 실행하세요. 올바르게 구성된 방화벽은 다음과 같이 표시됩니다:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

이것이 방화벽 측면에서 필요한 모든 것입니다.

*이제* 웹 페이지를 볼 수 있어야합니다. 다음과 같은 모습의 웹 페이지를 볼 수 있을 것입니다:

![The Nginx welcome page](nginx/images/welcome-nginx.png)

It’s not much at all, but it means the server is working. 또한 다음 명령을 사용하여 명령 줄에서 웹 페이지가 작동하는지 테스트할 수 있습니다:

```bash
curl -I http://[your-ip-address]
```

## 서버 사용자 생성 및 웹 사이트 루트 폴더 변경

기본 디렉토리에 웹 사이트 파일을 놓고 가는 것도 *가능*하지만 (이는 컨테이너 내에서 실행되거나 테스트/개발 서버에서 실행될 때 *Nginx*에 대해서는 괜찮을 수 있습니다), 이는 우리가 베스트 프랙티스라고 부르지 않습니다. 대신, 웹 사이트를 위해 시스템에 특정한 Linux 사용자를 생성하고 해당 사용자를 위해 디렉토리를 만드는 것이 좋습니다.

여러 웹 사이트를 구축하려는 경우 조직화 및 보안을 위해 여러 사용자 및 루트 디렉토리를 생성하는 것이 좋습니다.

이 가이드에서는 "www"라는 멋진 사용자 하나만 만들 것입니다. 웹 사이트 파일을 어디에 둘지 결정하는 것은 더 복잡해집니다.

서버 설정에 따라 웹 사이트 파일을 여러 가지 위치에 둘 수 있습니다. 물리적인 서버 (bare-metal)에 있거나 VPS에 직접 `nginx`를 설치하는 경우 보안 강화된 Linux (SELinux)가 실행 중인 경우가 있습니다. SELinux는 기계를 보호하기 위해 많은 작업을 수행하지만 웹 페이지와 같은 특정 항목을 둘 수 있는 위치를 결정하기도 합니다.

따라서 기계에 직접 `nginx`를 설치하는 경우 웹 사이트를 기본 루트 폴더의 하위 디렉토리에 두는 것이 좋습니다. 이 경우 기본 루트는 `/usr/share/nginx/html`이므로 "www" 사용자의 웹 사이트는 `/usr/share/nginx/html/www`로 들어갈 수 있습니다.

그러나 LXD/LXC와 같은 컨테이너에서 `nginx`를 실행하는 경우 SELinux가 설치되지 않을 가능성이 높으며 파일을 원하는 위치에 둘 수 있습니다. 이 경우 일반적인 홈 폴더의 디렉토리 아래에 사용자의 모든 웹 사이트 파일을 두는 것이 좋습니다. 예를 들어 `/home/www/`와 같이 하위 디렉토리에 사용자의 웹 사이트 파일을 모두 두는 방식입니다.

하지만 이 가이드에서는 SELinux가 설치된 것으로 가정하고 진행하겠습니다. 사용 사례에 따라 필요한 부분을 변경하십시오. SELinux의 작동 방식에 대한 자세한 내용은 [SELinux 학습 가이드](../security/learning_selinux.md)에서 자세히 알아볼 수 있습니다.

### 사용자 생성

먼저 사용할 폴더를 만듭니다:

```bash
sudo mkdir /usr/share/nginx/html/www
```

그런 다음 www 그룹을 생성합니다:

```bash
sudo groupadd www
```

그런 다음 사용자를 생성합니다:

```bash
sudo adduser -G nginx -g www -d /usr/share/nginx/html/www www --system --shell=/bin/false
```

해당 명령은 다음과 같이 작동합니다:

* "www"라는 사용자를 생성합니다 (중간 텍스트 부분에 따라),
* 모든 파일을 `/usr/share/nginx/html/www`에 저장합니다,
* 다음 그룹에 추가합니다: 보충적으로 "nginx", 주로 "www"로 설정합니다.
* `--system` 플래그는 사용자가 인간 사용자가 아닌 시스템에 예약된 사용자임을 나타냅니다. 다른 웹 사이트를  관리하기 위해 인간 사용자 계정을 생성하려면 별도의 가이드가 필요합니다.
* `--shell=/bin/false`는 누구도 "www" 사용자로 로그인을 시도할 수 없도록 합니다.

"nginx" 그룹은 실제로 매우 중요한 역할을 수행합니다. 이 그룹은 웹 서버가 "www" 사용자와 "www" 사용자 그룹에 속하는 파일을 읽고 수정할 수 있도록 합니다. 자세한 내용은 Rocky Linux의 [사용자 관리 가이드](../../books/admin_guide/06-users.md)에서 확인할 수 있습니다.

### 서버 루트 폴더 변경

새로운 멋진 사용자 계정을 갖게 되었으므로 `nginx`가 해당 폴더에서 웹 사이트 파일을 찾도록 설정해야 합니다. 즐겨 사용하는 텍스트 편집기를 다시 사용하십시오.

지금은 다음 명령을 실행하십시오:

```bash
sudo nano /etc/nginx/conf.d/default.conf
```

파일이 열리면 `root /usr/share/nginx/html;`과 비슷한 라인을 찾으세요. 이를 원하는 웹사이트 루트 폴더로 변경합니다. 예를 들어, `root   /usr/share/nginx/html/www;` 로 변경하거나 (또는 저처럼 `nginx`를 컨테이너에서 실행 중인 경우 `/home/www`로 변경합니다.) 파일을 저장하고 닫은 다음 `nginx` 구성을 테스트하여 세미콜론을 누락하지 않았는지 등을 확인합니다.

```bash
nginx -t
```

다음과 같은 성공 메시지가 표시되면 모든 것이 올바르게 진행된 것입니다:

```nginx
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

그런 다음 다음 명령으로 서버에 소프트 재시작을 수행하십시오:

```bash
sudo systemctl reload nginx
```

!!! note "참고 사항"

    소프트 재시작이 작동하지 않을 경우 다음 명령으로 `nginx`를 강제로 재시작할 수 있습니다:

    ```bash
    sudo systemctl restart nginx
    ```

새 루트 폴더에 있는 HTML 파일은 이제 브라우저에서 탐색할 수 있어야 합니다.

### 파일 권한 변경

`nginx`가 웹사이트 디렉토리의 모든 파일을 읽고 쓰고 실행할 수 있도록 하려면 파일 권한을 올바르게 설정해야 합니다.

먼저, 루트 폴더의 모든 파일이 서버 사용자와 사용자 그룹에게 소유되도록 다음 명령을 실행합니다:

```bash
sudo chown -R www:www /usr/share/nginx/html/www
```

그리고 실제로 웹사이트를 탐색하려는 사용자가 페이지를 볼 수 있도록 다음 명령을 실행해야 합니다 (네, 세미콜론이 중요합니다):

```bash
sudo find /usr/share/nginx/html/www -type d -exec chmod 555 "{}" \;
sudo find /usr/share/nginx/html/www -type f -exec chmod 444 "{}" \;
```

That basically gives everyone the right to look at files on the server, but not modify them. 루트 사용자와 서버 사용자만이 수정할 수 있습니다.

## 사이트에 대한 SSL 인증서 가져오기

현재, `nginx`를 사용하여 SSL 인증서를 가져오는 방법에 대한 [certbot을 사용한 SSL 인증서 생성 가이드](../security/generating_ssl_keys_lets_encrypt.md)가 일부 기본 지침으로 업데이트되었습니다. certbot 설치 및 인증서 생성에 대한 자세한 지침이 포함되어 있으므로 확인하시기 바랍니다.

인증서가 없으면 브라우저에서 사이트를 볼 수 없게 될 수도 있으므로 모든 사이트에 대해 인증서를 획득하는 것이 좋습니다.

## 추가 구성 옵션 및 가이드

* *Nginx*를 PHP와 특히 PHP-FPM과 함께 사용하는 방법을 알고 싶다면 [Rocky Linux에서 PHP 설정 가이드](../web/php.md)를 확인해보세요.
* 여러 웹사이트를 위해 *Nginx*를 설정하는 방법을 배우고 싶다면 [해당 주제에 대한 가이드](nginx-multisite.md)를 참조하세요.

## Rocky의 공식 저장소에서 안정 버전 설치

"stable" 브랜치의 `nginx`를 사용하려면 다음과 같이 진행하세요. 먼저, 운영 체제를 최신 상태로 업데이트합니다:

```bash
sudo dnf update
```

그런 다음 다음 명령을 사용하여 기본 저장소에서 사용 가능한 최신 `nginx` 버전을 찾습니다:

```bash
sudo dnf module list nginx
```

이렇게 하면 다음과 같은 목록이 표시됩니다:

```bash
Rocky Linux 8 - AppStream
Name       Stream        Profiles        Summary
nginx      1.14 [d]      common [d]      nginx webserver
nginx      1.16          common [d]      nginx webserver
nginx      1.18          common [d]      nginx webserver
nginx      1.20          common [d]      nginx webserver
```

리스트에서 가장 높은 숫자를 선택하고 다음과 같이 해당 모듈을 활성화합니다:

```bash
sudo dnf module enable nginx:1.20
```

이 작업을 수행하겠냐는 확인 메시지가 나타날 것이므로 일반적으로 `Y`를 선택합니다. 그런 다음 다음 명령을 사용하여 `nginx`를 설치합니다:

```bash
sudo dnf install nginx
```

그런 다음 서비스를 활성화하고 위에서 설명한 대로 서버를 구성할 수 있습니다.

!!! note "참고 사항"

    이 경우, 기본 구성 파일은 `/etc/nginx/nginx.conf`에 있는 기본 `nginx` 구성 폴더에 있습니다. 루트 웹사이트 폴더는 동일합니다.

## SELinux 규칙

강제 적용된 경우 nginx proxy_pass 지시문은 "502 Bad Gateway" 오류가 발생합니다.

개발 목적으로 setenforce를 비활성화할 수 있습니다.

```bash
sudo setenforce 0
```

또는 `/var/log/audit/audit.log`에서 nginx와 관련된 `http_d` 또는 다른 서비스를 활성화할 수 있습니다.

```bash
sudo setsebool httpd_can_network_connect 1 -P
```

## 결론

`nginx`의 기본 설치 및 구성은 최신 버전을 얻기 위해 해야 할 작업이 조금 복잡할 수 있지만 쉽습니다. 단계를 따르기만 하면 빠르게 사용할 수 있는 최고의 서버 옵션 중 하나를 구축할 수 있습니다.

이제 웹사이트를 구축하기만 하면 됩니다. 또 다른 10분 정도 걸릴까요? *웹 디자이너로서 조용히 웁니다*
