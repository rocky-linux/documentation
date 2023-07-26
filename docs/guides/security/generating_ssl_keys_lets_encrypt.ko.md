---
title: SSL 키 생성 - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen
tested_with: 8.5
tags:
  - security
  - ssl
  - certbot
---

# SSL 키 생성 -  Let's Encrypt

## 전제 조건 및 가정

* 명령 줄 사용에 익숙함
* SSL 인증서를 사용하여 웹 사이트를 보안하는 것에 익숙한 경우 플러스
* 명령 줄 텍스트 편집기를 사용하는 데 익숙함 (이 예제에서는 vi를 사용함)
* 이미 80번 포트(http)로 공개된 웹 서버가 작동 중인 상태
* _ssh_(보안 셸)에 익숙하고 서버에 _ssh_로 액세스할 수 있는 능력
* 모든 명령은 root 사용자이거나 _sudo_를 사용하여 root 액세스 권한을 얻었다고 가정합니다.

## 소개

현재 가장 인기 있는 웹 사이트 보안 방법 중 하나는 무료인 Let's Encrypt SSL 인증서를 사용하는 것입니다.

이는 자체 서명된 또는 snake oil 등이 아닌 실제 인증서이므로 예산이 적은 보안 솔루션으로 훌륭합니다. 이 문서에서는 Rocky Linux 웹 서버에 Let's Encrypt 인증서를 설치하고 사용하는 과정을 안내합니다.

## 설치

다음 단계를 수행하려면 _ssh_를 사용하여 서버에 로그인하십시오. 서버의 완전한 DNS 이름이 www.myhost.com이라면 다음을 사용합니다:

```bash
ssh -l root www.myhost.com
```

또는 권한이 없는 사용자로 서버에 액세스해야하는 경우. 사용자 이름을 사용하세요:

```bash
ssh -l username www.myhost.com
```

그 다음:

```bash
sudo -s
```

이 경우에는 _sudo_ 사용자의 자격 증명이 필요하며 루트로 시스템에 액세스해야합니다.

Let's Encrypt는 EPEL 저장소를 통해 설치되어야하는 _certbot_이라는 패키지를 사용합니다. 먼저 EPEL 저장소를 추가하십시오:

```bash
dnf install epel-release
```

그런 다음 웹 서버로 Apache 또는 Nginx를 사용하는 경우에 따라 적절한 패키지를 설치하십시오. Apache의 경우:

```bash
dnf install certbot python3-certbot-apache
```

Nginx의 경우, 한 가지 부분 단어만 변경하면 됩니다.

```bash
dnf install certbot python3-certbot-nginx
```

필요한 경우 두 서버 모듈 모두 설치할 수 있습니다.

!!! 참고 사항

    참고 사항
        이 가이드의 이전 버전에서는 해당 시기에 필요하다고 판단되어 snap 패키지 버전의 <em x-id="4">certbot</em>을 사용해야 했습니다. 최근에 RPM 버전을 다시 테스트하고 작동되고 있습니다. 그러나 Certbot은 <a href="https://certbot.eff.org/instructions?ws=apache&os=centosrhel8">스냅 설치 절차</a>를 강력히 권장하고 있습니다. Rocky Linux 8과 9 모두 EPEL에 <em x-id="4">certbot</em>이 사용 가능하므로 여기에는 해당 절차를 보여줍니다. Certbot이 권장하는 절차를 따르고 싶다면 해당 절차를 따르세요.


## Apache 서버용 Let's Encrypt 인증서 받기

Let's Encrypt 인증서를 검색하는 방법에는 http 구성 파일을 수정하는 명령을 사용하거나 인증서를 검색하는 두 가지 방법이 있습니다. http 구성 파일을 수정하는 명령을 사용하거나 인증서만 가져오는 방법입니다. [Apache 웹 서버 다중 사이트 설정](../web/apache-sites-enabled.md) 절차에서 하나 이상의 사이트에 대해 권장되는 멀티 사이트 설정 프로시저에서 제안된 방법 중 하나 이상의 사이트에 대해 사용하는 것으로 가정합니다.

우리는 이 절차를 사용하고 있다고 가정하므로 인증서만 가져오겠습니다. 기본 구성을 사용하여 독립 실행형 웹 서버를 실행하는 경우 인증서를 검색하고 구성 파일을 한 번에 수정하는 명령을 사용할 수 있습니다.

```bash
certbot --apache
```

실제로 가장 간단한 방법입니다. 그러나 때로는 더 수동적인 접근 방법을 취하려고 할 때가 있습니다. 그냥 인증서를 가져오고 싶을 수도 있습니다. 인증서만 검색하려면 다음 명령을 사용하십시오.

```bash
certbot certonly --apache
```

두 명령 모두 답할 필요가 있는 일련의 프롬프트를 생성합니다. 첫 번째는 중요한 정보에 대한 이메일 주소를 제공하는 것입니다.

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

다음은 가입자 동의 조건을 읽고 수락하는 것을 요구합니다. 동의서를 읽은 후 계속하려면 'Y'로 답하십시오:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

다음 프롬프트는 이메일을 Electronic Frontier Foundation과 공유할 것인지를 묻습니다. 원하는 대로 'Y' 또는 'N'으로 답하십시오:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

다음 프롬프트에서 인증서를 가져올 도메인을 묻습니다. 실행 중인 웹 서버를 기반으로 목록에 도메인이 표시될 것입니다. 그렇다면, 인증서를 가져올 도메인 옆의 숫자를 입력하십시오. 이 경우에는 하나의 옵션('1')만 있습니다:

```
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: yourdomain.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

모든 것이 순조롭게 진행되면 다음 메시지를 받아야 합니다:

```
Requesting a certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/yourdomain.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/yourdomain.com/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## 사이트 구성 - https

구성 파일을 사이트에 적용하는 것은 다른 공급자로부터 구매한 SSL 인증서를 사용하는 경우(그리고 _certbot_이 자동으로 수행하지 않은 경우)와 약간 다릅니다.

인증서 및 체인 파일은 하나의 PEM(Privacy Enhanced Mail) 파일에 포함되어 있습니다. 이것은 현재 모든 인증서 파일에 대한 일반적인 형식이므로 "Mail"이라는 참조에도 불구하고 단지 인증서 파일 유형일 뿐입니다. 구성 파일을 설명하기 전에 전체적인 내용을 보여드리고 그 후에 무엇이 발생하는지 설명하겠습니다:

```
<VirtualHost *:80>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.yourdomain.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.yourdomain.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.yourdomain.www/cgi-bin/

    CustomLog "/var/log/httpd/com.yourdomain.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.yourdomain.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem

        <Directory /var/www/sub-domains/com.yourdomain.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

위에서 일어나는 일에 대해 설명드리겠습니다. [Apache 웹 서버 다중 사이트 설정](../web/apache-sites-enabled.md)을 검토하여 다른 제공자로부터 구매한 SSL 인증서와 Let's Encrypt 인증서를 적용하는 방법에 대한 차이점을 확인하시기 바랍니다.

* 80번 포트(표준 HTTP)가 듣고 있음에도 불구하고 모든 트래픽을 443번 포트(HTTPS)로 리디렉션합니다.
* SSLEngine on - SSL을 사용하도록 설정합니다.
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - 사용 가능한 모든 프로토콜을 사용하도록 설정하지만 취약점이 발견된 프로토콜은 제외합니다. 주기적으로 사용 가능한 프로토콜을 조사해야 합니다.
* SSLHonorCipherOrder on - 다음 행에 대한 암호 조합과 순서대로 처리하도록 지시합니다. 주기적으로 포함하려는 암호 조합을 검토해야 하는 또 다른 영역입니다.
* SSLCertificateFile - 이것은 사이트 인증서와 중간 인증서가 포함된 PEM 파일입니다. 여전히 구성에서 'SSLCertificateChainFile' 행이 필요하지만 동일한 PEM 파일을 지정할 것입니다.
* SSLCertificateKeyFile - _certbot_ 요청으로 생성된 개인 키의 PEM 파일입니다.
* SSLCertificateChainFile - 인증서 제공업체에서 제공하는 인증서(중간 인증서)입니다. 이 경우 'SSLCertificateFile' 위치와 정확히 같습니다.

모든 변경 사항을 적용한 후에는 _httpd_를 간단히 다시 시작하고 사이트를 테스트하여 유효한 인증서 파일이 표시되는지 확인하면 됩니다. 그렇다면 다음 단계로 넘어갈 준비가 된 것입니다: 자동화.

## Nginx와 함께 _certbot_ 사용

간단히 말해서, Nginx에서 _certbot_을 사용하는 방법은 Apache와 거의 동일합니다. 다음은 빠른 설명서 버전입니다:

다음 명령을 실행하여 시작하세요:

```bash
certbot --nginx
```

위에서 보여준 대로 몇 가지 질문들이 나올 것입니다. 이메일 주소 및 인증서를 얻고자 하는 사이트와 같이 최소한 하나의 사이트가 구성되어 있다고 가정하면 다음과 같은 목록이 나타납니다:

```
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

여러 개의 사이트가 있다면 해당하는 사이트에 해당하는 번호를 누르면 됩니다.

그 외의 텍스트는 위에서 보여준 것과 매우 유사합니다. 결과는 약간 다를 수 있습니다. 물론 간단한 Nginx 구성 파일이 있다면 다음과 같을 수 있습니다:

```
server {
    server_name yourwebsite.com;

    listen 80;
    listen [::]:80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

```

_certbot_을 사용한 후에는 다음과 같이 조금 바뀌게 됩니다:

```
server {
    server_name  yourwebsite.com;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yourwebsite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yourwebsite.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

server {
    if ($host = yourwebsite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  listen [::]:80;
  server_name yourwebsite.com;
    return 404; # managed by Certbot
}
```

일부 경우에는 (예: Nginx를 리버스 프록시로 사용하는 경우) _certbot_이 자체적으로 완벽하게 처리하지 못하는 몇 가지 사항을 수정하려면 새 구성 파일로 들어가야 할 수도 있습니다.

또는 어렵게 직접 구성 파일을 작성하실 수도 있습니다.
## Let's Encrypt 인증서 갱신 자동화

_certbot_ 설치의 장점은 Let's Encrypt 인증서가 자동으로 갱신된다는 것입니다. 이를 위해 별도의 프로세스를 생성할 필요가 없습니다. 갱신을 테스트해야 합니다:

```bash
certbot renew --dry-run
```

위 명령을 실행하면 갱신 과정이 표시되는 멋진 출력을 얻게 됩니다:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/yourdomain.com.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/yourdomain.com/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/yourdomain.com/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

_certbot_을 갱신하는 명령은 다음 방법 중 하나로 찾을 수 있습니다:

* `/etc/crontab/`의 내용을 나열하기
* `/etc/cron.*/*`의 내용을 나열하기
* `systemctl list-timers` 실행

이 예에서는 마지막 옵션을 사용하고 _certbot_이 설치되었으며 `snap` 절차로 설치되었다는 것을 알 수 있습니다:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## 결론

Let's Encrypt SSL 인증서는 웹 사이트를 SSL로 보호하는 또 다른 옵션입니다. 설치된 후 시스템은 인증서를 자동으로 갱신하며 웹 사이트로의 트래픽을 암호화합니다.

Let's Encrypt 인증서는 표준 DV(Domain Validation) 인증서에 사용됩니다. OV(Organization Validation) 또는 EV(Extended Validation) 인증서에는 사용할 수 없음을 주의해야 합니다.
