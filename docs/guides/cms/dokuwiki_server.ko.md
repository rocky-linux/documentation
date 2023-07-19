---
title: DokuWiki
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - 위키
  - 문서
---

# 도쿠위키 서버

## 전제 조건 및 가정

* 서버, 컨테이너 또는 가상 머신에 설치된 Rocky Linux 인스턴스.
* 편집기를 사용하여 명령줄에서 구성 파일을 수정하는 것이 편합니다(여기서 예제에서는 _vi_를 사용하지만 선호하는 편집기로 대체할 수 있습니다).
* 웹 애플리케이션 및 설정에 대한 약간의 지식.
* 이 예에서는 설정을 위해 [Apache Sites Enabled](../web/apache-sites-enabled.md)를 사용하므로 따라갈 계획이라면 해당 루틴을 검토하는 것이 좋습니다.
* 이 예에서는 "example.com"을 도메인 이름으로 사용합니다.
* 이 문서 전체에서 귀하가 루트 사용자이거나 _sudo_를 사용하여 루트 사용자로 이동할 수 있다고 가정합니다.
* OS를 새로 설치한다고 가정하고 있지만 이것이 요구 사항이 **아닙니다**.

## 소개

문서화는 조직에서 다양한 형태를 취할 수 있습니다. 해당 문서에 대해 참조할 수 있는 리포지토리가 있다는 것은 매우 중요합니다. Wiki(하와이어로 _빠른_를 의미)는 문서, 프로세스 노트, 기업 지식 기반, 심지어 코드 예제까지 중앙 위치에 보관하는 방법입니다. 비밀리에 위키를 유지 관리하는 IT 전문가에게는 모호한 루틴을 잊어버리는 것에 대한 보험 정책이 내장되어 있습니다.

DokuWiki는 데이터베이스 없이 실행되고 보안 기능이 내장되어 있으며 상대적으로 배포하기 쉬운 성숙하고 빠른 위키입니다. DokuWiki가 할 수 있는 작업에 대한 자세한 내용은 [웹페이지](https://www.dokuwiki.org/dokuwiki)를 확인하세요.

DokuWiki는 사용 가능한 많은 위키 중 하나일 뿐이지만 꽤 좋은 위키입니다. 한 가지 큰 장점은 DokuWiki가 상대적으로 가볍고 사용 가능한 공간과 메모리가 있는 경우 이미 다른 서비스를 실행 중인 서버에서 실행할 수 있다는 것입니다.

## 의존성 설치

DokuWiki의 최소 PHP 버전은 이제 Rocky Linux 8과 함께 제공되는 7.2입니다. Rocky Linux 9.0은 완전히 지원되는 PHP 버전 8.0과 함께 제공됩니다. 이미 설치되어 있을 수 있는 패키지를 지정하고 있습니다:

`dnf install tar wget httpd php php-gd php-xml php-json php-mbstring`

설치될 추가 의존성 목록과 다음 프롬프트가 표시됩니다.

`Is this ok [y/N]:`

계속해서 "y"로 답하고 'Enter'를 눌러 설치하십시오.

## 디렉토리 생성 및 구성 수정

### Apache 구성

[Apache 사이트 활성화](../web/apache-sites-enabled.md) 절차를 읽었다면 몇 개의 디렉토리를 생성해야 한다는 것을 알고 계실 것입니다. _httpd_ 구성 디렉토리 추가부터 시작하겠습니다.

`mkdir -p /etc/httpd/{sites-available,sites-enabled}`

httpd.conf 파일을 편집해야 합니다.

`vi /etc/httpd/conf/httpd.conf`

그리고 파일 맨 아래에 다음을 추가합니다.

`Include /etc/httpd/sites-enabled`

sites-available에 사이트 구성 파일을 만듭니다.

`vi /etc/httpd/sites-available/com.example`

해당 구성 파일은 다음과 같아야 합니다.

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

위의 "AllowOverride All"은 .htaccess(디렉토리별 보안) 파일이 작동하도록 허용합니다.

계속해서 구성 파일을 사이트 활성화에 연결하되 아직 웹 서비스를 시작하지 마십시오.

`ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/`

### Apache DocumentRoot

_DocumentRoot_도 생성해야 합니다. 이렇게 하려면 다음을 실행하십시오:

`mkdir -p /var/www/sub-domains/com.example/html`

## Installing DokuWiki

서버에서 루트 디렉토리로 변경하십시오.

`cd /root`

이제 환경이 준비되었으므로 DokuWiki의 안정적인 최신 버전을 얻습니다. [다운로드 페이지](https://download.dokuwiki.org/)로 이동하면 페이지 왼쪽의 "Version" 아래에 "Stable (Recommended) (direct link)"이 표시됩니다.

이 중 "(direct link)" 부분을 마우스 오른쪽 버튼으로 클릭하고 링크 주소를 복사합니다. DokuWiki 서버의 콘솔에서 "wget"과 공백을 입력한 다음 복사한 링크를 터미널에 붙여넣습니다. 다음과 같은 결과를 얻어야 합니다.

`wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`

아카이브의 압축을 풀기 전에 아카이브의 내용을 보려면 `tar ztf`를 사용하여 내용을 살펴보십시오.

`tar ztvf dokuwiki-stable.tgz`

이와 같이 보이는 다른 모든 파일보다 앞서 명명된 날짜가 지정된 디렉토리를 주목하십시오.

```
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```
우리는 아카이브를 압축 해제할 때 맨 앞에 이름이 지정된 디렉토리를 원하지 않으므로 tar와 함께 몇 가지 옵션을 사용하여 제외할 것입니다. 첫 번째 옵션은 선행 디렉토리를 제거하는 "--strip-components=1"입니다.

두 번째 옵션은 "-C" 옵션이며 압축을 풀고 싶은 위치를 tar에 알려줍니다. 따라서 다음 명령을 사용하여 아카이브의 압축을 풉니다.

`tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/`

이 명령을 실행하면 모든 DokuWiki가 _DocumentRoot_에 있어야 합니다.

DokuWiki와 함께 제공되는 _.htaccess.dist_파일의 복사본을 만들고 나중에 원본으로 되돌려야 할 경우를 대비하여 이전 파일도 보관해야 합니다.

그 과정에서 우리는 이 파일의 이름을 _apache_가 찾고 있는 단순히 _.htaccess_로 변경할 것입니다. 이렇게 하려면 다음을 실행하십시오:

`cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}`

이제 새 디렉터리와 해당 파일의 소유권을 _apache_ 사용자 및 그룹으로 변경해야 합니다.

`chown -Rf apache.apache /var/www/sub-domains/com.example/html`

## DNS 또는 /etc/hosts 설정

DokuWiki 인터페이스에 액세스하기 전에 이 사이트에 대한 이름 확인을 설정해야 합니다. 테스트 목적으로 _/etc/hosts_ 파일을 사용할 수 있습니다.

이 예에서는 DokuWiki가 10.56.233.179의 개인 IPv4 주소에서 실행된다고 가정합니다. 또한 Linux 워크스테이션에서 _/etc/hosts_ 파일을 수정한다고 가정해 보겠습니다. 이렇게 하려면 다음을 실행하십시오:

`sudo vi /etc/hosts`

그런 다음 호스트 파일을 다음과 같이 수정합니다(아래 예에서 위의 IP 주소 참고).

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

테스트를 마치고 모든 사람을 위해 라이브로 사용할 준비가 되면 이 호스트를 DNS 서버에 추가해야 합니다. [비공개 DNS 서버](../dns/private_dns_server_using_bind.md) 또는 공용 DNS 서버를 사용하여 이 작업을 수행할 수 있습니다.

## httpd 시작하기

_httpd_를 시작하기 전에 구성이 올바른지 테스트해 보겠습니다.

`httpd -t`

다음을 받아야 합니다.

`Syntax OK`

그렇다면 _httpd_를 시작한 다음 설정을 마칠 준비가 된 것입니다. _httpd_가 부팅 시 시작되도록 활성화하여 시작하겠습니다.

`systemctl enable httpd`

그런 다음 시작하십시오.

`systemctl start httpd`

## Testing DokuWiki

이제 호스트 이름이 테스트용으로 설정되고 웹 서비스가 시작되었으므로 다음 단계는 웹 브라우저를 열고 주소 표시줄에 다음을 입력하는 것입니다.

`http://example.com/install.php`

또는

`http://example.com/install.php`

호스트 파일을 위와 같이 설정하면 둘 중 하나가 작동합니다. 설정을 완료할 수 있도록 설정 화면으로 이동합니다.

* "위키 이름" 필드에 위키 이름을 입력합니다. 예: "기술 문서"
* "수퍼유저" 필드에 관리 사용자 이름을 입력합니다. 예: "관리자"
* "Real name" 필드에 관리 사용자의 실명을 입력하십시오.
* "E-Mail" 필드에 관리 사용자의 이메일 주소를 입력합니다.
* "Password" 필드에 관리 사용자의 보안 비밀번호를 입력하십시오.
* "한 번 더" 필드에 동일한 비밀번호를 다시 입력하십시오.
* "Initial ACL Policy" 드롭다운에서 환경에 가장 적합한 옵션을 선택합니다.
* 콘텐츠를 넣을 라이선스에 해당하는 확인란을 선택합니다.
* "한 달에 한 번 DokuWiki 개발자에게 익명의 사용 데이터 보내기" 확인란을 선택된 상태로 둡니다(원하는 경우 선택하지 않음).
* "저장" 버튼 클릭

이제 위키에 콘텐츠를 추가할 준비가 되었습니다.

## DokuWiki 보안

방금 생성한 ACL 정책 외에 다음을 고려하십시오.

### 당신의 방화벽

!!! 참고사항

    이러한 방화벽 예제 중 어느 것도 Dokuwiki 서버에서 허용해야 할 다른 서비스에 대해 어떤 종류의 가정도 하지 않습니다. 이러한 규칙은 테스트 환경을 기반으로 하며 **오직** 로컬 네트워크 IP 블록에 대한 액세스 허용을 처리합니다. 프로덕션 서버에 허용되는 더 많은 서비스가 필요합니다.

모든 작업을 완료하기 전에 보안에 대해 생각해야 합니다. 먼저 서버에서 방화벽을 실행해야 합니다. 아래 방화벽 중 하나를 사용하고 있다고 가정합니다.

모든 사람이 위키에 액세스할 수 있는 대신, 10.0.0.0/8 네트워크의 모든 사람이 개인 LAN에 있고 사이트에 액세스해야 하는 유일한 사람이라고 가정합니다.

#### `iptables` 방화벽(더 이상 사용되지 않음)

!!! warning "주의"

    여기서 'iptables' 방화벽 프로세스는 Rocky Linux 9.0에서 더 이상 사용되지 않습니다(여전히 사용 가능하지만 Rocky Linux 9.1과 같은 향후 릴리스에서 사라질 가능성이 있음). 이러한 이유로 9.0 이상에서 이 작업을 수행하는 경우 아래의 `firewalld` 절차로 건너뛸 것을 권장합니다.

이 서버의 다른 서비스에 대한 다른 규칙이 필요할 수 있으며 이 예제에서는 웹 서비스만 고려합니다.

먼저 _/etc/firewall.conf_ 파일을 수정하거나 생성합니다.

`vi /etc/firewall.conf`

```
#IPTABLES=/usr/sbin/iptables

# 지정하지 않으면 OUTPUT의 기본값은 ACCEPT입니다.
# FORWARD 및 INPUT의 기본값은 DROP입니다.
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
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

Then execute the script:

`/etc/firewall.conf`

이렇게 하면 규칙이 실행되고 저장되어 다음에 _iptables_를 시작하거나 부팅할 때 다시 로드됩니다.

#### `firewalld` Firewall

`firewalld`를 방화벽으로 사용하고 있다면(지금쯤이면 아마 *해야* 할 것입니다) `firewalld's firewall-cmd` 구문을 사용하여 동일한 개념을 적용할 수 있습니다.

`firewalld` 규칙을 사용하여 `iptables` 규칙(위)을 복제합니다.

```
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

위의 규칙을 추가하고 firewalld 서비스를 다시 로드했으면 영역을 나열하여 필요한 모든 항목이 있는지 확인합니다.

```
firewall-cmd --zone=trusted --list-all
```

위의 모든 것이 올바르게 작동하면 다음과 같이 표시됩니다.

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

최상의 보안을 위해 모든 웹 트래픽이 암호화되도록 SSL 사용을 고려해야 합니다. SSL 공급자로부터 SSL을 구매하거나 [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)를 사용할 수 있습니다.

## 결론

프로세스, 회사 정책, 프로그램 코드 등을 문서화해야 하는 경우 wiki는 이를 수행하는 데 좋은 방법입니다. DokuWiki는 안전하고 유연하며 사용하기 쉽고 상대적으로 설치 및 배포가 쉬운 제품이며 수년 동안 존재해 온 안정적인 프로젝트입니다.  
