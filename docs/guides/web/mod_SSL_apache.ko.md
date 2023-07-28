---
title: title:'mod_ssl'를 사용한 Apache
author: Garthus
contributors: Steven Spencer, David Hensley
update: 20-Jan-2022
---

# Rocky Linux의 'mod_ssl'을 사용한 Apache 웹 서버 환경

Apache 웹 서버는 오랫동안 사용되어왔으며, 'mod_ssl'은 웹 서버에 더 큰 보안을 제공하기 위해 사용됩니다. 'mod_ssl'은 Rocky Linux를 포함한 거의 모든 Linux 버전에 설치할 수 있습니다. 'mod_ssl'의 설치는 Rocky Linux의 Lamp-Server 생성의 일부입니다.

이 절차는 Apache 웹 서버 환경에서 Rocky Linux를 사용하여 작동하도록 설계되었습니다.

## 전제조건

* 이미 Rocky Linux가 설치된 워크스테이션 또는 서버
* Root 환경에 있거나 입력하는 모든 명령어 앞에 `sudo`를 입력해야 합니다.

## Rocky Linux Minimal 설치

Rocky Linux를 설치할 때 다음 패키지 세트를 사용했습니다:

* Minimal
* Standard

## 시스템 업데이트 실행

먼저, 시스템 업데이트 명령을 실행하여 서버가 리포지토리 캐시를 다시 빌드하도록 합니다. 이렇게 하면 사용 가능한 패키지를 인식할 수 있습니다.

`dnf update`

## 저장소 활성화

일반적인 Rocky Linux 서버 설치에서는 필요한 모든 저장소가 준비되어 있어야 합니다.

## 사용 가능한 저장소 확인

확실하게 하기 위해 다음 명령으로 저장소 목록을 확인합니다.

`dnf repolist`

다음과 같은 출력을 받아야 합니다. 모든 활성화된 저장소가 표시됩니다.

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## 패키지 설치

'mod_ssl'을 설치하려면 다음 명령을 실행합니다.

`dnf install mod_ssl`

'mod_ssl' 모듈을 활성화하려면 다음 명령을 실행합니다.

`apachectl restart httpd` `apachectl -M | grep ssl`

다음과 같은 출력이 표시되어야 합니다.

  `ssl_module (shared)`

## TCP 포트 443 열기

HTTPS로 들어오는 트래픽을 허용하려면 다음 명령을 실행합니다.

```
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

이 시점에서 Apache 웹 서버에 HTTPS로 액세스할 수 있어야 합니다. `https://your-server-ip` 또는 `https://your-server-hostname`을 입력하여 'mod_ssl' 구성을 확인하세요.

## SSL 인증서 생성

호스트 rocky8에 대한 365일 만료 기간을 가진 새로운 셀프 서명 인증서를 생성하려면 다음 명령을 실행하세요.

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

다음과 같은 출력이 표시됩니다.

```
Generating a RSA private key
................+++++
..........+++++
writing new private key to '/etc/pki/tls/private/httpd.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
입력하려는 항목은 식별 이름 또는 DN입니다.
필드가 꽤 많지만 일부는 비워둘 수 있습니다
일부 필드에는 기본값이 있습니다,
'.'를 입력하면 필드가 공백 상태로 유지됩니다.
-----
Country Name (2 letter code) [XX]:AU
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:LinuxConfig.org
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:rocky8
Email Address []:
```
이 명령이 실행을 완료하면 다음 두 개의 SSL 파일이 생성됩니다.

```
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Apache 웹 서버에 새 SSL 인증서 구성

새로 생성한 SSL 인증서를 Apache 웹 서버 구성에 포함하려면 ssl.conf 파일을 열어 다음 줄을 변경하세요.

`nano /etc/httpd/conf.d/ssl.conf`

다음 줄을 변경합니다.

FROM:
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
TO:
```
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

그런 다음 Apache 웹 서버를 다시 로드하려면 다음 명령을 실행하세요.

`systemctl reload httpd`

## 'mod_ssl' 구성 테스트

웹 브라우저에서 다음을 입력하세요.

`https://your-server-ip` 또는 `https://your-server-hostname`

## 모든 HTTP 트래픽을 HTTPS로 리디렉션하기

다음을 실행하여 새 파일을 만듭니다.

`nano /etc/httpd/conf.d/redirect_http.conf`

다음 내용을 삽입하고 파일을 저장하세요. "your-server-hostname"을 자신의 호스트 이름으로 바꿉니다.

```
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Apache 서비스를 다시 로드할 때 변경 내용을 적용하려면 다음 명령을 실행하세요.

`systemctl reload httpd`

이제 Apache 웹 서버는 `http://your-server-hostname`에서 들어오는 모든 트래픽을 `https://your-server-hostname` URL로 리디렉션하도록 구성됩니다.

## 마무리 단계

We have seen how to install and configure 'mod_ssl'. 'mod_ssl'을 설치하고 구성하는 방법을 살펴보았으며, HTTPS 서비스를 사용하는 웹 서버를 실행하기 위해 새 SSL 인증서를 생성했습니다.

## 결론

이 튜토리얼은 Rocky Linux 버전 8.x에서 LAMP(Linux, Apache 웹 서버, Maria 데이터베이스 서버, PHP 스크립팅 언어) 서버를 설치하는 튜토리얼 중 일부입니다. 나중에 설치를 더 잘 이해하기 위해 이미지를 포함할 예정입니다.
