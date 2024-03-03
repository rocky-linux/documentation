---
title: Apache 다중 사이트
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - web
  - apache
  - multiple site
---

# Apache 웹 서버 다중 사이트 설정

## 필요한 것

* Rocky Linux를 실행하는 서버
* 명령 줄 및 텍스트 편집기에 대한 지식. 이 예제에서는 *vi*를 사용하지만 원하는 편집기를 사용해도 됩니다.

    !!! tip "팁"
  
        vi 텍스트 편집기에 대해 배우고 싶다면 [여기](https://www.tutorialspoint.com/unix/unix-vi-editor.htm)에 유용한 튜토리얼이 있습니다.

* 웹 서비스 설치 및 실행에 대한 기본 지식

## 소개

Rocky Linux에는 웹 사이트를 설정하는 다양한 방법이 있습니다. 이것은 Apache를 사용하여 단일 서버에서 실행하는 방법 중 하나입니다. 이 방법은 하드웨어 하나에 여러 서버를 설치하는 것을 목표로 하지만 단일 사이트 서버의 기본 구성으로도 사용할 수 있습니다.

역사적 사실: 이 서버 설정은 Debian 기반 시스템에서 시작되었을 것으로 보이지만 Apache를 실행하는 모든 Linux 운영 체제에 적용할 수 있습니다.

Nginx에 대한 유사한 설정을 찾고 있다면, [이 가이드를 살펴보세요](nginx-multisite.md).

## Apache 설치

아마도 웹 사이트를 위해 PHP, 데이터베이스 또는 기타 패키지와 함께 다른 패키지가 필요할 것입니다. `http`와 함께 PHP를 설치하면 Rocky Linux 저장소에서 가장 최신 버전을 얻을 수 있습니다.

다만, `php-bcmath` 또는 `php-mysqlind`와 같은 모듈이 필요할 수 있습니다. 웹 응용 프로그램의 요구 사항에 따라 필요한 패키지를 설치할 수 있습니다. 필요할 때 설치할 수 있습니다. 일단, 거의 필수적인 요소인 `http`와 PHP를 설치하겠습니다:

명령 줄에서 다음을 실행하세요:

```bash
dnf install httpd php
```

## 추가 디렉터리 추가

이 방법은 몇 가지 추가 디렉터리를 사용하지만 현재 시스템에는 존재하지 않습니다. */etc/httpd/*에 "sites-available"과 "sites-enabled"라는 두 개의 디렉터리를 추가해야 합니다.

명령 줄에서 다음을 입력하세요:

```bash
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
```

이렇게 하면 필요한 두 디렉터리가 생성됩니다.

또한 웹 사이트가 설치될 디렉토리가 필요합니다. 이것은 어디에나 위치할 수 있지만 "sub-domains"라는 디렉토리를 만드는 것이 조직을 유지하는 좋은 방법입니다. 복잡성을 줄이기 위해 이 디렉토리를 /var/www에 만듭니다: `mkdir /var/www/sub-domains/`

## 구성

`httpd.conf` 파일의 맨 아래에 한 줄을 추가해야 합니다. 이를 위해 다음을 입력하세요:

```bash
vi /etc/httpd/conf/httpd.conf
```

파일의 맨 아래로 이동하여 다음을 추가하세요:

```bash
Include /etc/httpd/sites-enabled
```

실제 구성 파일은 */etc/httpd/sites-available*에 있으며, */etc/httpd/sites-enabled*에 대한 심볼릭 링크를 생성합니다.

**왜 이렇게 하는 걸까요?**

동일한 서버에서 다른 IP 주소로 실행되는 10개의 웹 사이트가 있다고 가정해 보세요. 사이트 B에 중요한 업데이트가 있어 해당 사이트의 구성을 변경해야 할 경우를 가정해 보세요. 또한 변경 사항으로 인해 문제가 발생하고 변경 사항을 읽어들이려고 `httpd`를 재시작하면 `httpd`가 시작되지 않습니다. 작업 중인 사이트뿐만 아니라 나머지 사이트도 시작되지 않습니다. 이 방법을 사용하면 문제를 일으킨 사이트의 심볼릭 링크를 제거하고 `httpd`를 재시작할 수 있습니다. 그러면 다시 정상적으로 작동하며, 문제가 발생한 사이트 구성을 수정하는 작업을 할 수 있습니다.

이렇게 하면 서비스가 오프라인 상태로 인해 고객이나 상사로부터 불만 전화가 올 것에 대한 압박을 덜을 수 있습니다.

### 사이트 구성

이 방법의 다른 이점은 기본 `httpd.conf` 파일 외부에서 모든 것을 완전히 지정할 수 있다는 점입니다. 기본 `httpd.conf` 파일은 기본값을 로드하고, 사이트 구성은 나머지 모든 작업을 수행합니다. 멋지죠? 게다가 고장난 사이트 구성을 해결하기도 더욱 쉽습니다.

위키를 로드하는 웹사이트가 있다고 가정해 보겠습니다. 해당 사이트를 80번 포트에서 사용할 수 있도록 하는 구성 파일이 필요합니다.

SSL/TLS를 사용하여 웹사이트를 제공하려면 (대부분의 경우 그렇습니다), 포트 443에서 사용할 수 있도록 해당 파일에 다른 (거의 동일한) 섹션을 추가해야 합니다.

아래의 [SSL/TLS 인증서를 사용한 `https` 구성](#https) 섹션에서 이를 자세히 살펴볼 수 있습니다.

먼저 *sites-available*에 이 구성 파일을 생성해야 합니다:

```bash
vi /etc/httpd/sites-available/com.wiki.www
```

구성 파일 내용은 다음과 같습니다:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

    CustomLog "/var/log/httpd/your-server-hostname-access_log" combined
    ErrorLog  "/var/log/httpd/your-server-hostname-error_log"

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

생성된 후, 저장하기 위해 <kbd>Shift</kbd>+<kbd>:</kbd>+<kbd>wq</kbd>를 눌러야 합니다.

예를 들어, 위에서 생성한 경로인 _/var/www_에서 _your-server-hostname_의 "html" 하위 디렉토리를 통해 위키 사이트를 로드합니다. 이는 다음 명령을 통해 해당 경로를 생성해야 함을 의미합니다:

```bash
mkdir -p /var/www/sub-domains/your-server-hostname/html
```

이 명령은 한 번에 전체 경로를 생성합니다. 다음으로, 웹사이트를 실행할 실제 디렉토리에 파일을 설치해야 합니다. 이는 직접 만든 것이거나 다운로드한 설치 가능한 웹 응용 프로그램(이 경우 위키)일 수 있습니다.

생성한 경로로 파일을 복사합니다:

```bash
cp -Rf wiki_source/* /var/www/sub-domains/your-server-hostname/html/
```

## SSL/TLS 인증서를 사용한 `https` 구성

앞서 언급했듯이, 현재 모든 웹 서버는 SSL/TLS(보안 소켓 레이어)를 *사용해야 합니다*.

certificate signing request 이 과정은 개인 키와 CSR(certificate signing request - 인증서 서명 요청)를 생성하고 CSR을 인증 기관에 제출하여 SSL/TLS 인증서를 구입하는 것으로 시작됩니다. 이러한 키를 생성하는 과정은 다소 복잡합니다.

SSL/TLS 키 생성에 익숙하지 않다면, 다음을 살펴보세요 : [SSL 키 생성](../security/ssl_keys_https.md)

[Let's Encrypt의 SSL 인증서](../security/generating_ssl_keys_lets_encrypt.md)를 사용하여 이 대체 프로세스를 사용할 수도 있습니다.

### SSL/TLS 키와 인증서의 위치

키와 인증서 파일을 가지고 있으므로, 이를 웹 서버의 파일 시스템에 논리적으로 배치해야 합니다. 예제 구성 파일에서 보았듯이, 웹 파일을 _/var/www/sub-domains/your-server-hostname/html_에 배치하고 있습니다.

인증서와 키 파일을 도메인과 함께, 그러나 문서 루트인 *html* 폴더 외부에 배치하고 싶습니다.

인증서와 키를 웹에 노출시키는 것은 절대로 원치 않습니다. 그렇게 된다면 안 좋은 일이 벌어질 수 있습니다!

대신, 문서 루트 외부에 SSL/TLS 파일을 위한 디렉토리 구조를 생성합니다:

```bash
mkdir -p /var/www/sub-domains/your-server-hostname/ssl/{ssl.key,ssl.crt,ssl.csr}`
```

"tree" 문법에 대해 처음 듣는다면, 위의 내용은 다음과 같습니다:

""ssl"이라는 디렉토리를 만들고 내부에 ssl.key, ssl.crt 및 ssl.csr이라는 세 개의 디렉토리를 만듭니다."

미리 알려드립니다: 인증서 서명 요청(CSR) 파일을 트리에 저장하는 것은 필수적이지는 않지만, 몇 가지를 간소화하는 데 도움이 됩니다. 다른 제공자로부터 인증서를 다시 발급해야 할 경우, CSR 파일의 저장된 사본을 가지고 있는 것이 좋습니다. 그렇다면 어디에 저장해야 기억할까요? 웹 사이트의 트리 내에 저장하는 것이 논리적입니다.

키, csr 및 crt(인증서) 파일을 사이트 이름으로 지정하고, 해당 파일을 _/root_에 저장했다고 가정하고, 해당 위치로 복사하면 됩니다.

```bash
cp /root/com.wiki.www.key /var/www/sub-domains/your-server-hostname/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/your-server-hostname/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/
```

### 사이트 구성 - `https`

키를 생성하고 SSL/TLS 인증서를 구매한 후, 이제 키를 사용하여 웹 사이트의 구성을 진행할 수 있습니다.

우선, 구성 파일의 시작 부분을 살펴보겠습니다. 예를 들어, 여전히 표준 `http`  포트인 포트 80에서 들어오는 요청을 수신하긴 하지만, 실제로는 이러한 요청을 포트 80으로 보내고 싶지 않습니다.

대신에 이러한 요청을 포트 443(또는 SSL/TLS 또는 `https`로 알려진 "안전한 `http`")로 보내고 싶습니다. 포트 80의 구성 섹션은 최소한으로 유지하겠습니다:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
```

위 구성은 일반 웹 요청을 `https` 구성으로 보내라는 것을 의미합니다. 표시된 Apache "Redirect" 옵션은 일시적인 것입니다. 테스트가 완료되고 사이트가 예상대로 작동하는 것을 확인하면 이를 "Redirect permanent"로 변경할 수 있습니다.

곧, 검색 엔진에서 발생하는 사이트로의 모든 트래픽은 포트 80 (`http`)을 거치지 않고 오직 포트 443 (`https`)로만 이동하게 됩니다.

다음으로, 구성 파일에서 `https` 부분을 정의해야 합니다:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<Virtual Host *:443>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

    CustomLog "/var/log/`http`d/your-server-hostname-access_log" combined
    ErrorLog  "/var/log/`http`d/your-server-hostname-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/your-server-hostname/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

따라서 이 구성을 더 자세히 살펴보면, 일반 구성 부분 이후부터 SSL/TLS 섹션까지 다음과 같습니다:

* SSLEngine on - SSL/TLS을 사용하도록 지정합니다.
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - 사용 가능한 모든 프로토콜을 사용하되 취약점이 있는 프로토콜은 사용하지 않도록 지정합니다. 주기적으로 사용 가능한 프로토콜을 조사해야 합니다.
* SSLHonorCipherOrder on - 다음 줄에서 지정된 암호 조합에 대해 지정된 순서대로 처리하도록 지정합니다. 이는 암호 조합을 주기적으로 검토해야 하는 다른 영역입니다.
* SSLCertificateFile - 새로 구매하고 적용한 인증서 파일과 그 위치입니다.
* SSLCertificateKeyFile - 인증서 서명 요청 생성 시 생성한 키입니다.
* SSLCertificateChainFile - 인증서 제공자로부터 받은 인증서, 일반적으로 중간 인증서라고도 합니다.

다음으로, 모든 것을 적용하고 웹 서비스를 시작하는데 오류가 없으며, 웹사이트에 접속할 때 오류 없이 `https`가 표시된다면 준비가 끝난 것입니다.

## 실제 서비스 적용

*httpd.conf* 파일은 파일의 끝에 */etc/httpd/sites-enabled*을 포함하고 있습니다. `httpd`를 다시 시작하면 해당 *sites-enabled* 디렉토리에 있는 구성 파일을 로드할 것입니다. 그런데 우리의 모든 구성 파일은 *sites-available*에 있습니다.

이것은 의도된 것으로, `httpd`가 재시작하지 못할 경우에는 구성 파일을 제거할 수 있도록 합니다. 구성 파일을 활성화하려면 *sites-enabled*에 해당 파일에 대한 심볼릭 링크를 생성하고 웹 서비스를 시작 또는 재시작해야 합니다. 이를 위해 다음 명령을 사용합니다:

```bash
ln -s /etc/httpd/sites-available/your-server-hostname /etc/httpd/sites-enabled/
```

이것은 우리가 원하는 대로 *sites-enabled*에 구성 파일에 대한 링크를 만들 것입니다.

이제 `systemctl start httpd`를 사용하여 `httpd`를 시작하세요. 이미 실행 중인 경우에는 재시작하세요: `systemctl restart httpd`. 그리고 웹 서비스가 재시작되는 경우, 이제 사이트에서 일부 테스트를 진행할 수 있습니다.
