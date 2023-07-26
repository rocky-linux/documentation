---
title: 도쿠 위키
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - 위키
  - 문서
---

# 도쿠 위키 서버

## 전제 조건 및 가정

* 서버, 컨테이너 또는 가상 머신에 설치된 Rocky Linux 인스턴스.
* 에디터를 사용하여 명령 줄에서 구성 파일을 수정하는 데 익숙함 (이 예제에서는 _vi_를 사용하지만 좋아하는 에디터로 대체할 수 있습니다).
* 웹 애플리케이션과 설정에 대한 일부 지식.
* 이 예제에서는 [Apache Sites Enabled](../web/apache-sites-enabled.md)를 사용하여 설정을 수행할 예정이므로 해당 루틴을 따를 계획인 경우 이를 검토하는 것이 좋습니다.
* 이 예제에서는 "example.com"을 도메인 이름으로 사용할 것입니다.
* 이 문서 전체에서 여러분이 root 사용자이거나 _sudo_ 를 사용하여 root 사용자 권한을 얻을 수 있다고 가정합니다.
* OS의 새로운 설치를 전제로 하고 있지만, 이는 필수 사항은 **아닙니다**.

## 소개

조직에서 문서화는 여러 가지 형태로 이루어질 수 있습니다. 문서를 참조할 수 있는 리포지토리를 갖고 있다는 것은 매우 귀중합니다. 위키(하와이어로 빠른 뜻)는 문서, 프로세스 노트, 기업 지식 베이스, 심지어 코드 예제를 하나로 모아 놓는 방법입니다. 위키를 운영하는 IT 전문가는 빠져 나가기 쉬운 루틴을 잊어버릴 경우에 대비하여 내장된 보험 청구서를 갖고 있습니다.

DokuWiki는 성숙하고 빠른 위키로 데이터베이스 없이 작동하며 내장된 보안 기능이 있으며 비교적 쉽게 배포할 수 있습니다. DokuWiki의 기능에 대해 자세히 알아보려면 해당 [웹 페이지](https://www.dokuwiki.org/dokuwiki)를 확인하십시오.

DokuWiki는 다양한 위키 중 하나에 불과하지만, 상당히 좋은 위키 중 하나입니다. 하나의 큰 장점은 DokuWiki가 비교적 가볍고 기존에 다른 서비스가 이미 실행 중인 서버에서도 실행될 수 있다는 것입니다. 필요한 경우 공간과 메모리가 있어야 합니다.

## 의존성 설치

DokuWiki의 최소 PHP 버전은 이제 7.2로, 이는 Rocky Linux 8이 제공하는 버전과 정확히 일치합니다. Rocky Linux 9.0은 PHP 버전 8.0을 제공하며 이 역시 완전히 지원됩니다. 여기에는 이미 설치되어 있는 패키지가 지정되어 있습니다.

`dnf install tar wget httpd php php-gd php-xml php-json php-mbstring`

설치될 추가 의존성 목록과 다음 프롬프트가 표시됩니다.

`Is this ok [y/N]:`

계속해서 "y"로 답하고 'Enter'를 눌러 설치를 진행합니다.

## 디렉토리 생성 및 구성 수정

### Apache 구성

[Apache 사이트 활성화](../web/apache-sites-enabled.md) 절차를 읽어보았다면, 몇 가지 디렉토리를 생성해야 한다는 것을 알고 있을 것입니다. 먼저 _httpd_ 구성 디렉토리를 추가합니다.

`mkdir -p /etc/httpd/{sites-available,sites-enabled}`

httpd.conf 파일을 편집해야 합니다.

`vi /etc/httpd/conf/httpd.conf`

그리고 파일의 가장 아래에 다음을 추가합니다.

`Include /etc/httpd/sites-enabled`

sites-available에 사이트 구성 파일을 생성합니다.

`vi /etc/httpd/sites-available/com.example`

구성 파일은 다음과 같은 형태여야 합니다.

```
<VirtualHost *>
    ServerName    example.com
    DocumentRoot  /var/www/sub-domains/com.example/html

    <Directory ~ "/var/www/sub-domains/com.example/html/(bin/|conf/|data/|inc/)">
        <IfModule mod_authz_core.c>
                AllowOverride All
            Require all denied
        </IfModule>
        <IfModule !mod_authz_core.c>
            Order allow,deny
            Deny from all
        </IfModule>
    </Directory>

    ErrorLog   /var/log/httpd/example.com_error.log
    CustomLog  /var/log/httpd/example.com_access.log combined
</VirtualHost>
```

위의 "AllowOverride All"은 .htaccess(디렉토리별 보안) 파일이 작동할 수 있도록 합니다.

그런 다음 구성 파일을 sites-enabled에 링크하지만 아직 웹 서비스를 시작하지는 마십시오.

`ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/`

### Apache DocumentRoot 설정하기

_DocumentRoot_를 생성해야 합니다. 다음 명령을 사용하여 생성합니다.

`mkdir -p /var/www/sub-domains/com.example/html`

## DokuWiki 설치하기

서버에서 루트 디렉토리로 이동합니다.

`cd /root`

환경이 준비되었으므로 DokuWiki의 최신 안정 버전을 받아오겠습니다. [다운로드 페이지](https://download.dokuwiki.org/)로 이동하여 페이지 왼쪽에 "Version" 아래에서 "Stable (Recommended) (direct link)"을 찾을 수 있습니다.

이 "direct link" 부분을 마우스 오른쪽 버튼으로 클릭하여 링크 주소를 복사합니다. DokuWiki 서버 콘솔에서 "wget"을 입력하고 공백을 하나 둔 다음 복사한 링크를 터미널에 붙여넣습니다. 다음과 같이 보일 것입니다.

`wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`

압축 파일을 해제하기 전에 `tar ztf`를 사용하여 아카이브의 내용을 확인해보세요.

`tar ztvf dokuwiki-stable.tgz`

위와 같이 날짜가 지정된 디렉토리가 다른 파일들 앞에 나타납니다.

```
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```
우리는 이러한 선도 디렉토리가 아카이브를 해제할 때 나타나지 않도록 몇 가지 tar 옵션을 사용할 것입니다. 첫 번째 옵션은 "--strip-components=1"로, 이는 해당 선도 디렉토리를 제거합니다.

두 번째 옵션은 "-C" 옵션으로, 이는 tar가 아카이브를 해제할 위치를 지정합니다. 따라서 다음 명령으로 아카이브를 해제합니다.

`tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/`

이 명령을 실행하면 모든 DokuWiki가 _DocumentRoot_ 에 있어야 합니다.

DokuWiki와 함께 제공된 _.htaccess.dist_ 파일의 사본을 만들고 필요할 경우 원래 파일로 복원할 수 있도록 해당 파일을 그대로 두어야 합니다.

이 과정에서 이 파일의 이름을 _.htaccess_로 바꿉니다. 이 이름으로 _apache_가 찾을 것입니다. 이 작업을 위해 다음과 같이 실행합니다.

`cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}`

이제 새 디렉터리와 해당 파일의 소유권을 _apache_ 사용자 및 그룹으로 변경해야 합니다.

`chown -Rf apache.apache /var/www/sub-domains/com.example/html`

## DNS 또는 /etc/hosts 설정

DokuWiki 인터페이스에 액세스하려면 사이트에 대한 이름 해결을 설정해야 합니다. 테스트를 위해 _/etc/hosts_ 파일을 사용할 수 있습니다.

이 예에서는 DokuWiki가 개인 IPv4 주소인 10.56.233.179에서 실행된다고 가정합니다. 또한 이것을 Linux 워크스테이션의 _/etc/hosts_ 파일을 수정하고 있다고 가정합니다. 다음과 같이 실행하여 이 작업을 수행할 수 있습니다.

`sudo vi /etc/hosts`

그런 다음 호스트 파일을 다음과 같이 수정합니다(아래 예에서 위의 IP 주소를 참고하세요).

```
127.0.0.1   localhost
127.0.1.1   myworkstation-home
10.56.233.179   example.com     example 

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

테스트가 완료되고 모든 사용자를 위해 라이브로 전환할 준비가 되었다면, 이 호스트를 DNS 서버에 추가해야 합니다. [개인 DNS 서버](../dns/private_dns_server_using_bind.md) 또는 공개 DNS 서버를 사용하여 이 작업을 수행할 수 있습니다.

## httpd 시작하기

_httpd_를 시작하기 전에 설정이 올바른지 테스트해 봅시다.

`httpd -t`

다음을 받아야 합니다.

`Syntax OK`

그렇다면 _httpd_를 시작하고 설정을 완료해 봅시다. _httpd_를 부팅 시 자동으로 시작하도록 설정합니다.

`systemctl enable httpd`

그런 다음 시작합니다.

`systemctl start httpd`

## DokuWiki 테스트하기

이제 호스트 이름이 테스트를 위해 설정되었으며, 웹 서비스가 시작되었습니다. 다음 단계는 웹 브라우저를 열고 주소 표시 줄에 다음을 입력하는 것입니다.

`http://example.com/install.php`

또는

`http://example.com/install.php`

위의 호스트 파일을 설정한 경우 어느 쪽이든 동작할 것입니다. 이렇게 하면 설치 화면이 표시되어 설치를 완료할 수 있습니다.

* "Wiki Name" 필드에 위키 이름을 입력합니다. 예를 들어 "기술 문서"
* "Superuser" 필드에 관리자 사용자 이름을 입력합니다. 예를 들어 "admin"
* "Real name" 필드에 관리자 사용자의 실제 이름을 입력합니다.
* "E-Mail" 필드에 관리 사용자의 이메일 주소를 입력합니다.
* "Password" 필드에 관리 사용자의 보안 비밀번호를 입력하십시오.
* "once again" 필드에 동일한 비밀번호를 다시 입력합니다.
* "Initial ACL Policy" 드롭다운에서 환경에 가장 적합한 옵션을 선택합니다.
* 컨텐츠에 적용할 라이선스의 체크 박스를 선택합니다.
* "Once a month, send anonymous usage data to the DokuWiki developers" 체크박스를 체크한 상태로 둡니다. (원하지 않는 경우 해제)
* "Save" 버튼을 클릭합니다.

이제 위키를 사용하여 컨텐츠를 추가할 준비가 되었습니다.

## DokuWiki 보안

위에서 생성한 ACL 정책 외에도 다음 사항을 고려하세요:

### 당신의 방화벽

!!! 참고사항

    이러한 방화벽 예제 중 어느 것도 Dokuwiki 서버에서 허용해야 할 다른 서비스에 대해 어떤 종류의 가정도 하지 않습니다. 이러한 규칙은 테스트 환경을 기반으로 하며 **오직** 로컬 네트워크 IP 블록에 대한 액세스 허용을 처리합니다. 프로덕션 서버에 허용되는 더 많은 서비스가 필요합니다.

모든 작업을 완료하기 전에 보안에 대해 생각해야 합니다. 작업을 마무리하기 전에 서버에서 방화벽을 실행하는 것이 좋습니다. 아래 방화벽 중 하나를 사용한다고 가정합니다.

모든 사람이 위키에 액세스할 수 있는 대신, 10.0.0.0/8 네트워크의 모든 사람이 개인 LAN에 있고 사이트에 액세스해야 하는 유일한 사람이라고 가정합니다.

#### `iptables` 방화벽(더 이상 사용되지 않음)

!!! warning "주의"

    Rocky Linux 9.0에서는 (아직 사용 가능하지만 Rocky Linux 9.1 등의 릴리스에서 사라질 가능성이 높음) `iptables`` 방화벽 프로세스가 중지되었습니다. 이 때문에 9.0 이상 버전에서는 `firewalld` 절차로 건너뛰기를 권장합니다.

이 예제는 웹 서비스에만 대한 예시입니다. 다른 서비스에 대한 규칙도 필요할 수 있습니다.

먼저 _/etc/firewall.conf_ 파일을 수정하거나 생성합니다.

`vi /etc/firewall.conf`

```
#IPTABLES=/usr/sbin/iptables

# 지정하지 않으면 OUTPUT의 기본값은 ACCEPT입니다. # FORWARD 및 INPUT의 기본값은 DROP입니다. #
echo "   clearing any existing rules and setting default policy.." iptables -F INPUT
iptables -P INPUT DROP
# 웹 포트
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 443 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

스크립트가 생성되면 실행 가능한지 확인합니다.

`chmod +x /etc/firewall.conf`

그런 다음 스크립트를 실행합니다.

`/etc/firewall.conf`

이렇게 하면 규칙이 실행되고 저장되어 다음에 _iptables_를 시작하거나 부팅할 때 다시 로드됩니다.

#### `firewalld` 방화벽

`firewalld`를 방화벽으로 사용하는 경우 (이 시점에서 이미 사용하고 있을 가능성이 높습니다), `firewalld`의 `firewall-cmd` 문법을 사용하여 동일한 개념을 적용할 수 있습니다.

위의 `firewalld` 규칙을 사용하여 `iptables` 규칙으로 복제합니다.

```
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

위의 규칙을 추가하고 firewalld 서비스를 다시 로드한 후 필요한 모든 규칙이 포함되어 있는지 확인하기 위해 zone 목록을 표시합니다.

```
firewall-cmd --zone=trusted --list-all
```

모든 작업이 정확하게 수행되었다면 다음과 같이 표시됩니다.

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.0.0.0/8
  services: http https
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

### SSL

최고의 보안을 위해 모든 웹 트래픽을 암호화하기 위해 SSL을 사용하는 것이 좋습니다. SSL을 SSL 공급자에서 구입하거나 [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)를 사용할 수 있습니다.

## 결론

프로세스, 회사 정책, 프로그램 코드 또는 기타 내용을 문서화해야 할 때 위키는 이를 수행하기에 좋은 방법입니다. DokuWiki는 안전하고 유연하며 사용하기 쉽고, 설치와 배포가 비교적 쉬우며 오랫동안 안정적으로 사용된 프로젝트입니다.  
