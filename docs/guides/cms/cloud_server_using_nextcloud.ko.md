---
title: Nextcloud를 사용하는 클라우드 서버
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - 클라우드
  - nextcloud
---

# Nextcloud를 사용하는 클라우드 서버

!!! 참고 "Rocky Linux 9.x에 관하여"

    이 절차는 Rocky Linux 9.x에서 작동합니다. 차이점은 버전 9로 업데이트하려면 일부 리포지토리에 대한 버전 참조를 변경해야 할 수도 있다는 것입니다.  Rocky Linux 9.x를 사용하는 경우 8.6과 9.0 모두에서 테스트되었지만 원래는 8.6용으로 작성되었습니다.

## 전제 조건 및 가정

* Rocky Linux를 실행하는 서버(모든 Linux 배포판에 Nextcloud를 설치할 수 있지만 이 절차에서는 Rocky를 사용한다고 가정합니다).
* 설치 및 구성을 위해 명령줄에서 작동하는 높은 수준의 편안함.
* 명령줄 편집기에 대한 지식. 이 예에서는 _vi_를 사용하고 있지만 선호하는 편집기가 있으면 사용할 수 있습니다.
* Nextcloud는 스냅 애플리케이션을 통해 설치할 수 있지만 .zip 파일 설치만 문서화할 것입니다.
* 디렉토리 설정을 위해 Apache "활성화된 사이트" 문서(아래에 링크됨)의 개념을 적용할 것입니다.
* 또한 데이터베이스 설정을 위해 _mariadb-server_ 강화 절차(나중에 링크됨)를 사용할 것입니다.
* 이 문서 전체에서 우리는 귀하가 루트이거나 _sudo_를 사용하여 루트일 수 있다고 가정합니다.
* 구성에서 "yourdomain.com"의 예제 도메인을 사용하고 있습니다.

## 소개

대기업(또는 중소기업)의 서버 환경을 담당하고 있다면 클라우드 애플리케이션에 유혹을 받을 수 있습니다. 클라우드에서 일을 하면 다른 일을 위해 자신의 리소스를 확보할 수 있지만 여기에는 회사 데이터에 대한 통제력을 상실한다는 단점이 있습니다. 클라우드 애플리케이션이 손상되면 회사 데이터도 손상될 수 있습니다.

클라우드를 다시 자신의 환경으로 가져오는 것은 시간과 에너지를 희생하여 데이터의 보안을 되찾는 방법입니다. 때때로 그것은 지불할 가치가 있는 비용입니다.

Nextcloud는 보안과 유연성을 염두에 둔 오픈 소스 클라우드를 제공합니다. 결국 클라우드를 오프사이트로 가져가기로 선택하더라도 Nextcloud 서버를 구축하는 것은 좋은 연습입니다. 다음 절차는 Rocky Linux에서 Nextcloud를 설정하는 방법을 다룹니다.


## Nextcloud 설치

### 리포지토리 및 모듈 설치 및 구성

이 설치에는 두 개의 리포지토리가 필요합니다. EPEL(Enterprise Linux용 추가 패키지) 및 PHP 8.0용 Remi 저장소를 설치해야 합니다.

!!! 참고사항

    최소 PHP 버전 7.3 또는 7.4가 필요하며 Rocky Linux 버전 7.4에는 Nextcloud에 필요한 모든 패키지가 포함되어 있지 않습니다. 대신 Remi 저장소의 PHP 8.0을 사용할 것입니다.

EPEL을 설치하려면 다음을 실행하십시오.

```
dnf install epel-release
```

Remi 리포지토리를 설치하려면 다음을 수행합니다(Rocky Linux 9.x를 사용하는 경우 아래 "release-" 옆에 있는 9에서 대체):

```
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```

그런 다음 `dnf upgrade`를 다시 실행하십시오.

활성화할 수 있는 PHP 모듈 목록을 보려면 다음을 실행하십시오.

```
dnf module list php
```

Rocky Linux 8.x에 대해 다음 출력을 제공합니다(Rocky Linux 9.x에 대해서도 유사한 출력이 표시됨).

```
Rocky Linux 8 - AppStream
Name                    Stream                     Profiles                                     Summary                                 
php                     7.2 [d]                    common [d], devel, minimal                   PHP scripting language                  
php                     7.3                        common [d], devel, minimal                   PHP scripting language                  
php                     7.4                        common [d], devel, minimal                   PHP scripting language               
php                     7.4                        common [d], devel, minimal                   PHP scripting language                  
Remi's Modular repository for Enterprise Linux 8 - x86_64
Name                    Stream                     Profiles                                     Summary                                 
php                     remi-7.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.3                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.4                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.0                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.1                   common [d], devel, minimal                   PHP scripting language                  
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Nextcloud와 호환되는 최신 PHP(현재 8.0)를 가져오려면 다음을 수행하여 해당 모듈을 활성화합니다.

```
dnf module enable php:remi-8.0
```

이것이 모듈 목록의 출력을 어떻게 변경하는지 확인하려면 모듈 목록 명령을 다시 실행하면 8.0 옆에 "[e]"가 표시됩니다.

```
dnf module list php
```

그리고 출력은 다음 줄을 제외하고 동일합니다.

```
php                    remi-8.0 [e]                   common [d], devel, minimal                  PHP scripting language
```

### 패키지 설치

여기 예제에서는 Apache와 mariadb를 사용하므로 필요한 것을 설치하려면 다음을 수행하기만 하면 됩니다.

```
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php80-php php80-php-ctype php80-php-curl php80-php-gd php80-php-iconv php80-php-json php80-php-libxml php80-php-mbstring php80-php-openssl php80-php-posix php80-php-session php80-php-xml php80-php-zip php80-php-zlib php80-php-pdo php80-php-mysqlnd php80-php-intl php80-php-bcmath php80-php-gmp
```

### 구성

#### 아파치 구성

부팅 시 시작하도록 _apache_를 설정합니다.

```
systemctl enable httpd
```

그런 다음 시작하십시오.

```
systemctl start httpd
```

#### 구성 만들기

"전제 조건 및 가정" 섹션에서 구성을 위해 [Apache 사이트 활성화](../web/apache-sites-enabled.md) 절차를 사용할 것이라고 언급했습니다. 해당 절차를 클릭하고 기본 사항을 설정한 다음 이 문서로 돌아와 계속 진행합니다.

Nextcloud의 경우 다음 구성 파일을 만들어야 합니다.

```
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

구성 파일은 다음과 같아야 합니다.

```
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.yourdomain.nextcloud/html/
  ServerName  nextcloud.yourdomain.com
  <Directory /var/www/sub-domains/com.yourdomain.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

완료되면 변경 사항을 저장합니다(_vi_의 경우 `SHIFT:wq!` 사용).

다음으로 /etc/httpd/sites-enabled에서 이 파일에 대한 링크를 만듭니다.

```
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### 디렉토리 생성

위 구성에서 설명한 것처럼 _DocumentRoot_를 만들어야 합니다. 이는 다음과 같이 수행할 수 있습니다.

```
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

Nextcloud 인스턴스가 설치될 위치입니다.


#### PHP 구성

PHP의 시간대를 설정해야 합니다. 이렇게 하려면 선택한 텍스트 편집기로 php.ini를 엽니다.

```
vi /etc/opt/remi/php80/php.ini
```

그런 다음 줄을 찾으십시오.

```
;date.timezone =
```

주석(;)을 제거하고 시간대를 설정해야 합니다. 예제 시간대의 경우 다음 중 하나를 입력합니다.

```
date.timezone = "America/Chicago"
```

또는

```
date.timezone = "US/Central"
```

그런 다음 php.ini 파일을 저장하고 종료합니다.

동일하게 유지하기 위해 _php.ini_ 파일의 시간대는 시스템의 시간대 설정과 일치해야 합니다. 다음을 수행하여 이것이 무엇으로 설정되어 있는지 확인할 수 있습니다.

```
ls -al /etc/localtime
```

Rocky Linux를 설치할 때 시간대를 설정하고 중부 시간대에 살고 있다고 가정하면 다음과 같이 표시됩니다.

```
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### mariadb 서버 구성

부팅 시 시작하도록 _mariadb-server_를 설정합니다.

```
systemctl enable mariadb
```

그런 다음 시작하십시오.

```
systemctl restart mariadb
```

앞에서 설명한 것처럼 초기 구성을 위해 [여기](../database/database_mariadb-server.md)에 있는 _mariadb-server_를 강화하기 위한 설정 절차를 다시 사용할 것입니다.

### .zip 설치

다음 몇 단계에서는 원격 콘솔이 열린 상태에서 _ssh_를 통해 Nextcloud 서버에 원격으로 연결되어 있다고 가정합니다.

* [Nextcloud 웹사이트](https://nextcloud.com/)로 이동합니다.
* 마우스를 "Get Nextcloud" 위로 가져가면 드롭다운 메뉴가 나타납니다.
* "서버 패키지"를 클릭합니다.
* "Nextcloud 다운로드"를 마우스 오른쪽 버튼으로 클릭하고 링크 주소를 복사합니다(정확한 구문은 브라우저마다 다름).
* Nextcloud 서버의 원격 콘솔에서 "wget"을 입력한 다음 공백을 입력하고 방금 복사한 내용을 붙여넣습니다. 다음과 같이 표시되어야 합니다. `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip`(버전이 다를 수 있음).
* Enter 키를 누르면 .zip 파일 다운로드가 시작되고 상당히 빠르게 완료됩니다.

다운로드가 완료되면 다음을 사용하여 Nextcloud zip 파일의 압축을 풉니다.

```
unzip nextcloud-21.0.1.zip
```

### 콘텐츠 복사 및 권한 변경

압축 해제 단계를 완료하면 /root에 "nextcloud"라는 새 디렉토리가 있어야 합니다. 다음 디렉토리로 변경하십시오.

```
cd nextcloud
```

그리고 콘텐츠를 _DocumentRoot_로 복사하거나 이동합니다.

```
cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

또는

```
mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

이제 모든 것이 제자리에 있으므로 다음 단계는 Apache가 디렉토리를 소유하는지 확인하는 것입니다. 이렇게 하려면 다음을 실행하십시오:

```
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

보안상의 이유로 "data" 폴더도 _DocumentRoot_ 내부에서 외부로 이동하려고 합니다. 다음 명령으로 이를 수행하십시오.

```
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```


### Nextcloud 구성

이제 즐거움이 찾아옵니다! 먼저 서비스가 실행 중인지 확인하십시오. 위의 단계를 따랐다면 이미 실행 중이어야 합니다. 초기 서비스 시작 사이에 여러 단계가 있었으므로 계속 진행하여 다시 시작하겠습니다.

```
systemctl restart httpd
systemctl restart mariadb
```

모든 것이 다시 시작되고 문제가 없으면 계속 진행할 수 있습니다.

초기 구성을 수행하기 위해 실제로 웹 브라우저에서 사이트를 로드하려고 합니다.

```
http://nextcloud.yourdomain.com/
```

지금까지 모든 작업을 올바르게 수행했다고 가정하면 Nextcloud 설정 화면이 표시되어야 합니다.

![nextcloud login screen](../images/nextcloud_screen.jpg)

표시되는 기본값과 다르게 수행하려는 몇 가지 사항이 있습니다.

* 웹 페이지 상단의 "관리자 계정 만들기"에서 사용자와 비밀번호를 설정합니다. 이 문서에서는 "admin"을 입력하고 강력한 암호를 설정합니다. 잃어버리지 않도록 안전한 곳에(예: 암호 관리자) 저장하는 것을 잊지 마십시오! 이 필드에 입력했더라도 모든 설정 필드를 완료할 때까지 'Enter'를 누르지 마십시오!
* "Storage & database" 섹션에서 "Data folder" 위치를 기본 문서 루트에서 이전에 데이터 폴더를 이동한 위치로 변경합니다: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
* "데이터베이스 구성" 섹션에서 해당 버튼을 클릭하여 "SQLite"에서 "MySQL/MariaDB"로 변경합니다.
* 이전에 설정한 MariaDB 루트 사용자 및 비밀번호를 "데이터베이스 사용자" 및 "데이터베이스 비밀번호" 필드에 입력하십시오.
* "데이터베이스 이름" 필드에 "nextcloud"를 입력합니다.
* "localhost" 필드에 "localhost:3306"을 입력합니다(3306은 기본 _mariadb_ 연결 포트임).

이 모든 작업을 완료한 후 `설정 완료`를 클릭하면 실행됩니다.

브라우저 창은 잠시 새로고침된 후 일반적으로 사이트를 다시 로드하지 않습니다. 브라우저 창에 URL을 다시 입력하면 기본 첫 페이지가 표시됩니다.

관리 사용자는 이 시점에서 이미 로그인되어 있거나 로그인되어 있어야 하며, 최신 정보를 얻을 수 있도록 설계된 여러 정보 페이지가 있습니다. "대시보드"는 사용자가 처음 로그인할 때 보게 되는 것입니다. 관리 사용자는 이제 다른 사용자를 생성하고 다른 응용 프로그램 및 기타 많은 작업을 설치할 수 있습니다.

"Nextcloud Manual.pdf" 파일은 사용자 매뉴얼로 제공되는 내용을 숙지할 수 있습니다. 관리 사용자는 [Nextcloud 웹 사이트](https://docs.nextcloud.com/server/21/admin_manual/)에서 관리 설명서의 요점을 읽거나 최소한 스캔해야 합니다.

## 다음 단계

이 시점에서 이것이 회사 데이터를 저장할 서버라는 것을 잊지 마십시오. 방화벽으로 잠그고, [backup set up](../backup/rsnapshot_backup.md)를 받고, [SSL](../security/generating_ssl_keys_lets_encrypt.md)로 사이트를 보호하고, 데이터를 안전하게 유지하는 데 필요한 다른 모든 작업이 중요합니다.

## 결론
회사 클라우드를 사내로 가져가기로 한 결정은 신중하게 평가해야 하는 결정입니다. 회사 데이터를 로컬에 보관하는 것이 외부 클라우드 호스트보다 선호되는 경우 Nextcloud가 좋은 대안입니다.
