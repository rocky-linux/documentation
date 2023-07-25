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

    이 절차는 Rocky Linux 9.x에서 작동해야 합니다. 차이점은 저장소의 일부 버전 참조를 버전 9로 업데이트해야 할 수도 있습니다.  Rocky Linux 9.x를 사용하는 경우에는 이 절차가 8.6과 9.0에서 테스트되었으며 원래는 8.6용으로 작성되었음을 유념하세요.

## 전제 조건 및 가정

* Rocky Linux에서 서버 실행(Nextcloud는 다른 Linux 배포판에도 설치할 수 있지만 이 절차에서는 Rocky Linux를 사용한다고 가정합니다).
* 설치 및 구성에 대한 명령줄 작업에 대한 높은 수준의 편안함.
* 명령줄 편집기 사용 방법에 대한 지식. 이 예제에서는 _vi_를 사용하지만, 알맞은 에디터를 사용할 수 있습니다.
* Nextcloud는 스냅 응용 프로그램을 통해 설치할 수 있지만, 여기에서는 .zip 파일 설치만 문서화합니다.
* 아파치 "sites enabled" 문서(아래 링크 참조)의 개념을 따르겠습니다.
* 데이터베이스 설정을 위해 _mariadb-server_ 강화 절차(이후 링크 참조)를 사용하겠습니다.
* 이 문서 전반에 걸쳐 root로 작업하거나 _sudo_를 사용하여 root가 될 수 있다고 가정합니다.
* 구성에서 "yourdomain.com" 예제 도메인을 사용합니다.

## 소개

큰 회사(또는 작은 회사)의 서버 환경을 담당하고 있다면 클라우드 애플리케이션에 유혹받을 수 있습니다. 클라우드에서 작업하면 자원을 다른 작업에 사용할 수 있지만, 단점이 있습니다. 바로 회사 데이터의 통제를 잃을 수 있다는 점입니다. 클라우드 애플리케이션이 침해당하면 회사의 데이터도 침해당할 수 있습니다.

클라우드를 자체 환경으로 다시 가져오면 시간과 에너지를 희생함으로써 데이터의 보안을 회복할 수 있습니다. 때로는 그 비용이 가치 있는 경우도 있습니다.

Nextcloud는 보안과 유연성을 고려하여 개방형 클라우드를 제공합니다. Nextcloud 서버를 구축하는 것은 클라우드를 최종적으로 오프 사이트로 가져가더라도 좋은 연습이 됩니다. 다음 절차에서는 Rocky Linux에서 Nextcloud를 설정하는 방법에 대해 다룹니다.


## Nextcloud 설치

### 리포지토리 및 모듈 설치 및 구성

이 설치를 위해 두 가지 저장소가 필요합니다. EPEL (Enterprise Linux용 추가 패키지) 및 PHP 8.0용 Remi 저장소를 설치해야 합니다.

!!! 참고사항

    Nextcloud에서 필요로 하는 최소 PHP 버전은 7.3 또는 7.4이며 Rocky Linux 버전 7.4에는 Nextcloud에서 필요한 모든 패키지가 포함되어 있지 않습니다. 따라서 Remi 저장소에서 제공하는 PHP 8.0을 사용할 것입니다.

EPEL을 설치하려면 다음을 실행하십시오.

```
dnf install epel-release
```

Remi 저장소 설치(만약 Rocky Linux 9.x를 사용하는 경우 "release-" 다음에 "9"로 변경하세요):

```
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```

그런 다음 `dnf upgrade`를 실행하세요:

활성화할 수 있는 PHP 모듈 목록을 확인합니다:

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

현재 Nextcloud와 호환되는 최신 PHP 버전은 8.0이므로 8.0 모듈을 활성화합니다:

```
dnf module enable php:remi-8.0
```

모듈 목록을 다시 확인하면 8.0 옆에 "[e]"가 표시되는 것을 확인할 수 있습니다:

```
dnf module list php
```

그리고 출력은 다음 줄을 제외하고 동일합니다.

```
php                    remi-8.0 [e]                   common [d], devel, minimal                  PHP scripting language
```

### 패키지 설치

이제 필요한 패키지들을 설치합니다. 아파치와 마리아디비를 사용하는 예제이므로 다음을 실행하세요:

```
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php80-php php80-php-ctype php80-php-curl php80-php-gd php80-php-iconv php80-php-json php80-php-libxml php80-php-mbstring php80-php-openssl php80-php-posix php80-php-session php80-php-xml php80-php-zip php80-php-zlib php80-php-pdo php80-php-mysqlnd php80-php-intl php80-php-bcmath php80-php-gmp
```

### 구성

#### 아파치 구성

_아파치_를 부팅시 자동으로 시작하도록 설정합니다:

```
systemctl enable httpd
```

그리고 아파치를 시작합니다:

```
systemctl start httpd
```

#### 구성 만들기

"전제조건 및 가정" 섹션에서 [Apache 사이트 활성화](../web/apache-sites-enabled.md) 절차를 사용할 것이라고 언급했습니다. 해당 절차로 이동하여 기본 구성을 설정한 다음 이 문서로 돌아와 계속 진행하세요.

Nextcloud를 위해 다음과 같은 구성 파일을 생성해야 합니다.

```
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

구성 파일은 다음과 같은 형태여야 합니다.

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

구성이 완료되면 변경 사항을 저장합니다(_vi_에서는 `SHIFT:wq!`를 사용합니다).

다음으로 /etc/httpd/sites-enabled에 이 파일에 대한 링크를 만듭니다.

```
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### 디렉토리 생성

위의 구성에서 언급한 대로 _DocumentRoot_를 생성해야 합니다. 이는 다음과 같이 수행할 수 있습니다.

```
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

Nextcloud 인스턴스가 설치될 위치입니다.


#### PHP 구성

PHP의 시간대를 설정해야 합니다. 이를 위해 원하는 텍스트 편집기로 php.ini 파일을 엽니다.

```
vi /etc/opt/remi/php80/php.ini
```

그런 다음 다음 줄을 찾습니다.

```
;date.timezone =
```

이 주석 부호 (;)를 제거하고 시간대를 설정해야 합니다. 예를 들어, 우리의 예제 시간대인 경우 다음 중 하나를 입력합니다.

```
date.timezone = "America/Chicago"
```

또는

```
date.timezone = "US/Central"
```

그런 다음 php.ini 파일을 저장하고 종료합니다.

참고로, 일관성을 유지하기 위해 _php.ini_ 파일의 시간대는 머신의 시간대 설정과 일치해야 합니다. 이를 확인하려면 다음을 실행하여 설정된 시간대를 확인할 수 있습니다.

```
ls -al /etc/localtime
```

Rocky Linux를 설치하고 중부 시간대에 거주하는 경우:

```
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### mariadb 서버 구성

_mariadb-server_가 부팅시 자동으로 시작하도록 설정합니다.

```
systemctl enable mariadb
```

그런 다음 시작하십시오.

```
systemctl restart mariadb
```

앞에서 설명한 것처럼 초기 구성을 위해 [여기](../database/database_mariadb-server.md)에 있는 _mariadb-server_를 강화하기 위한 설정 절차를 다시 사용할 것입니다.

### .zip 설치

다음 단계는 원격 콘솔을 통해 Nextcloud 서버에 _ssh_로 연결되었다고 가정합니다:

* [Nextcloud 웹사이트](https://nextcloud.com/)로 이동합니다.
* 마우스를 "Get Nextcloud" 위로 가져가면 드롭다운 메뉴가 나타납니다.
* "Server Packages"를 클릭합니다.
* "Download Nextcloud"를 마우스 오른쪽 버튼으로 클릭하고 링크 주소를 복사합니다(실제 구문은 브라우저마다 다릅니다).
* Nextcloud 서버의 원격 콘솔에서 "wget"을 입력한 다음 공백을 추가하고 방금 복사한 내용을 붙여넣습니다. 다음과 같은 내용이 표시됩니다: `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip`(버전이 다를 수 있음).
* Enter를 누르면 .zip 파일의 다운로드가 시작되며 빠르게 완료됩니다.

다운로드가 완료되면 다음을 사용하여 Nextcloud zip 파일을 압축 해제합니다.

```
unzip nextcloud-21.0.1.zip
```

### 콘텐츠 복사 및 권한 변경

unzip 단계를 완료한 후에는 /root 디렉토리에 "nextcloud"라는 새 디렉토리가 생성된 것을 확인할 수 있습니다. 이 디렉토리로 이동합니다.

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

이제 모든 파일이 올바른 위치에 있으므로, 다음 단계는 아파치가 해당 디렉토리를 소유하도록 하는 것입니다. 이를 위해 다음 명령을 실행합니다.

```
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

보안상의 이유로 "data" 폴더도 _DocumentRoot_  바깥으로 이동시키려 합니다. 이를 위해 다음 명령을 사용합니다.

```
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```


### Nextcloud 구성

이제 재미있는 부분입니다! 우선 서비스가 실행 중인지 확인합니다. 위의 단계를 따라했다면 이미 실행 중이어야 합니다. 초기 서비스 시작 사이에 여러 단계를 거쳤으므로 다시 시작하여 확실하게 합시다.

```
systemctl restart httpd
systemctl restart mariadb
```

모든 것이 다시 시작되고 문제가 없다면, 계속 진행할 준비가 되었습니다.

초기 구성을 위해 웹 브라우저에서 실제로 사이트를 불러옵니다.

```
http://nextcloud.yourdomain.com/
```

여러분이 지금까지 모두 정확하게 수행했다면, Nextcloud 설정 화면이 표시됩니다.

![nextcloud login screen](../images/nextcloud_screen.jpg)

다음과 같이 몇 가지 기본 설정을 변경하려 합니다:

* 웹 페이지 상단의 "관리자 계정 만들기"에서 사용자 이름과 암호를 설정합니다. 이 문서를 위해 "admin"이라고 입력하고 강력한 암호를 설정했습니다. 이 정보를 안전한 장소(암호 관리자 등)에 저장하여 분실하지 않도록 주의하세요! 이 필드에 입력을 완료했더라도 'Enter'를 누르기 전까지 모든 설정 필드를 완료하지 마세요!
* "저장소 및 데이터베이스" 섹션에서 "Data folder" 위치를 기본 문서 루트에서 이전에 데이터 폴더를 이동한 위치로 변경합니다: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
* "데이터베이스 구성" 섹션에서 해당 버튼을 클릭하여 "SQLite"에서 "MySQL/MariaDB"로 변경합니다.
* 이전에 설정한 MariaDB 루트 사용자 및 비밀번호를 "데이터베이스 사용자" 및 "데이터베이스 비밀번호" 필드에 입력하십시오.
* "데이터베이스 이름" 필드에 "nextcloud"를 입력합니다.
* "localhost" 필드에 "localhost:3306"을 입력합니다(3306은 기본 _mariadb_ 연결 포트임).

이 모든 작업을 완료한 후 `설정 완료`를 클릭하면 실행됩니다.

브라우저 창이 잠시 동안 새로 고침되고 일반적으로 사이트가 다시로드되지 않습니다. 브라우저 창에 URL을 다시 입력하면 기본 첫 페이지가 표시됩니다.

이 시점에서 관리자 사용자는 이미 로그인되어 있으며, 사용자가 익숙해질 수 있는 여러 정보 페이지가 있습니다. "대시보드"는 사용자가 처음 로그인할 때 보는 화면입니다. 관리자 사용자는 이제 다른 사용자를 만들고, 다른 애플리케이션을 설치하고, 기타 많은 작업을 수행할 수 있습니다.

"Nextcloud Manual.pdf" 파일은 사용자 매뉴얼이므로 사용자가 사용 가능한 내용에 익숙해지도록 합니다. 관리자 사용자는 [Nextcloud 웹 사이트](https://docs.nextcloud.com/server/21/admin_manual/)에서  관리자 매뉴얼을 읽거나 적어도 중요한 부분을 살펴봐야 합니다.

## 다음 단계

이 시점에서 기업 데이터를 저장할 서버임을 잊지 마세요. 방화벽을 설정하고, [백업을 설정](../backup/rsnapshot_backup.md)하고, [SSL](../security/generating_ssl_keys_lets_encrypt.md)로 사이트를 보호하고, 데이터를 안전하게 보관하기 위해 필요한 다른 작업들을 수행하는 것이 중요합니다.

## 결론
회사 클라우드를 자체 운영하는 것은 신중하게 평가해야 할 결정입니다. 회사 데이터를 외부 클라우드 호스트보다 지역에서 유지하는 것이 선호되는 경우, Nextcloud는 좋은 대안입니다.
