- - -
title: LibreNMS 모니터링 서버 author: Steven Spencer contributors: Ezequiel Bruni tested with: 8.5, 8.6, 9.0 tags:
  - monitoring
  - network
- - -

# LibreNMS 모니터링 서버

## 소개

네트워크 및 시스템 관리자는 대부분 항상 어떤 형태의 모니터링이 필요합니다. 이는 라우터 엔드 포인트의 대역폭 사용량을 그래프로 표시하거나 다양한 서버에서 실행 중인 서비스의 업/다운 상태를 모니터링하고 그 밖에 다양한 작업을 포함할 수 있습니다. 다양한 모니터링 옵션이 있지만, 하나의 지붕 아래 많거나 거의 모든 모니터링 구성 요소를 제공하는 매우 우수한 옵션은 LibreNMS입니다.

이 문서는 LibreNMS를 시작하는 데 도움이 되지만, 더 나아가기 위해 프로젝트의 훌륭하고 광범위한 문서를 참조하도록 안내합니다. Nagios와 Cacti와 같은 다른 모니터링 옵션도 있으며, 이 작성자가 이전에 사용한 두 가지 모니터링 시스템이지만, LibreNMS는 이 두 프로젝트가 개별적으로 제공하는 것을 하나의 지점에서 제공합니다.

설치는 [여기](https://docs.librenms.org/Installation/Install-LibreNMS/)에 있는 공식 설치 지침을 거의 따르지만 몇 가지 설명과 약간의 변경 사항을 추가했습니다. 이 절차가 우수한 문서보다 더 좋습니다.

## 전제 조건, 가정 및 규약

* Rocky Linux가 설치된 서버 또는 컨테이너(네트워크를 많이 모니터링하는 경우, 고유한 하드웨어에 설치하는 것이 가장 좋습니다.)를 사용합니다. 모든 명령은 Rocky Linux의 새로운 설치를 기준으로 합니다.
* 가정: 루트 사용자로 명령을 실행하거나 _sudo_를 사용하여 실행할 수 있다고 가정합니다.
* _vi_와 같은 텍스트 편집기를 포함하여 명령 줄 도구에 대한 작업 지식이 있어야 합니다.
* SNMP v2의 사용을 가정합니다. SNMP v3를 사용하려면 LibreNMS에서 지원하며 작동합니다. v3와 일치하도록 장치의 SNMP 구성 및 옵션을 전환하기만 하면 됩니다.
* SELinux 프로시저를 포함했지만, 실험실에서 사용하는 컨테이너에는 기본적으로 포함되어 있지 않습니다. 이러한 이유로 SELinux 프로시저는 실험실에서 **테스트되지 않았습니다**.
* 이 문서에서 예제는 언급된대로 _vi_ 편집기를 사용합니다. 변경 사항을 저장하고 나가는 방법은 `SHIFT:wq!`로 수행됩니다.
* 로그 모니터링, 웹 테스트 및 기타 일부 문제 해결 기술이 필요합니다.

## 패키지 설치

이러한 명령은 루트 사용자로 입력되어야 합니다. 시작하기 전에 설치 프로세스가 nginx보다는 httpd에 초점을 맞추고 있음을 알려드립니다. 만약 후자를 사용하고 싶다면[Librenms 설치 지침](https://docs.librenms.org/Installation/Install-LibreNMS/)로 이동하여 가이드를 따르세요.

우리는 새로운 설치를 가정하므로 계속하기 전에 저장소를 사용하여 몇 가지 작업을 수행해야 합니다. 먼저 EPEL 저장소(Extra Packages for Enterprise Linux)를 설치해야 합니다.

```
dnf install -y epel-release
```

현재 버전의 LibreNMS는 최소 PHP 버전이 8.1이 필요합니다. Rocky Linux 9.0의 기본 패키지는 PHP 8.0이므로 이 더 높은 버전을 위해 서드파티 저장소를 사용해야 합니다.

이를 위해 REMI 저장소를 설치합니다. 설치할 저장소 버전은 사용 중인 Rocky Linux 버전에 따라 다릅니다. 아래는 버전 9를 가정하고 있지만, 사용 중인 버전에 맞게 변경하십시오.

```
dnf install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

EPEL과 REMI 저장소가 모두 설치되면 필요한 패키지를 설치할 준비가 되었습니다.

```
dnf install bash-completion cronie fping git httpd ImageMagick mariadb-server mtr net-snmp net-snmp-utils nmap php81-php-fpm php81-php-cli php81-php-common php81-php-curl php81-php-gd php81-php-json php81-php-mbstring php81-php-process php81-php-snmp php81-php-xml php81-php-zip php81-php-mysqlnd python3 python3-PyMySQL python3-redis python3-memcached python3-pip python3-systemd rrdtool unzip wget
```

이 모든 패키지는 LibreNMS 기능 집합의 일부를 나타냅니다.

## librenms 사용자 설정

이를 위해 다음을 복사하여 붙여넣기(또는 입력)하세요.

```
useradd librenms -d /opt/librenms -M -r -s "$(which bash)"
```

이 명령에서는 새 사용자의 기본 디렉토리를 "/opt/librenms"로 설정하지만 "-M" 옵션은 "디렉토리를 생성하지 마세요"라고 지시합니다. 이유는 물론 LibreNMS를 설치할 때 이를 생성할 것이기 때문입니다. "-r"은 이 사용자를 시스템 계정으로 만들라는 의미이며, "-s"는 셸을 설정하라는 것입니다. (이 경우 "bash"로 설정됨)

## LibreNMS 다운로드 및 권한 설정

다운로드는 모두 git을 통해 이루어집니다. 이제 git을 사용하는 프로세스에 익숙할 수 있습니다. 먼저 /opt 디렉토리로 전환하세요.

```
cd /opt
```

이제 리포지토리를 복제합니다.

```
git clone https://github.com/librenms/librenms.git
```

그다음 디렉토리에 대한 권한을 변경하세요.

```
chown -R librenms:librenms /opt/librenms
chmod 771 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
```

_setfacl_ 명령은 "파일 접근 제어 목록 설정"의 약어로 다른 방법으로 디렉토리와 파일을 보호하는 방법입니다.

## librenms 사용자로 PHP 종속성 설치

위의 모든 명령은 루트 또는 _sudo_로 실행되었지만, LibreNMS 내의 PHP 종속성은 librenms 사용자로 설치해야 합니다. 이를 위해 다음을 실행하세요.

```
su - librenms
```

그리고 다음을 입력합니다:

```
./scripts/composer_wrapper.php install --no-dev
```

스크립트가 완료되면 루트로 다시 종료합니다:

```
exit
```

### PHP 종속성 설치 오류 해결 방법

LibreNMS 문서에 따르면 프록시 서버 뒤에 있는 경우 위의 프로시저가 실패할 수 있다고 합니다. 다른 이유로도 실패할 수 있음을 발견했습니다. 이 프로시저는 다른 이유로 실패할 수 있으므로 나중에 Composer 설치 프로세스를 추가하는 프로시저를 추가했습니다.

## 시간대 설정

먼저 시스템 및 PHP에 올바른 시간대가 설정되어 있는지 확인해야 합니다. PHP의 유효한 시간대 설정 목록은 [여기](https://php.net/manual/en/timezones.php)에서 찾을 수 있습니다. 예를 들어 Central 시간대의 경우 일반적인 항목은 "America/Chicago"입니다. 우리는 php.ini 파일을 편집하여 시작하겠습니다.

```
vi /etc/opt/remi/php81/php.ini
```

`date.timezone` 라인을 찾아 수정합니다. 주석 처리되어 있으므로 줄의 시작 부분의 ";"를 제거하고 "=" 기호 뒤에 시간대를 추가합니다. Central 시간대 예제를 사용하여 다음과 같이 합니다.

```
date.timezone = America/Chicago
```

변경 사항을 저장하고 php.ini 파일을 종료합니다.

시스템 시간대가 올바른지도 확인해야 합니다. 다시 Central 시간대를 예로 들면 다음과 같이 수행합니다.

```
timedatectl set-timezone America/Chicago
```

## MariaDB 설정

LibreNMS에 필요한 데이터베이스 설정에 앞서 [MariaDB 프로시저](../database/database_mariadb-server.md) 및 특히 "Securing mariadb-server" 섹션을 실행한 후 이곳으로 돌아옵니다. 먼저 mariadb-server.cnf 파일을 수정해야 합니다.

```
vi /etc/my.cnf.d/mariadb-server.cnf
```

그리고 "[Mysqld]" 섹션에 다음 줄을 추가합니다.

```
innodb_file_per_table=1
lower_case_table_names=0
```

그런 다음 mariadb 서버를 활성화하고 다시 시작합니다.

```
systemctl enable mariadb
systemctl restart mariadb
```

이제 root 사용자로 mariadb에 액세스합니다. 위의 "Securing mariadb-server" 섹션을 따를 때 만든 비밀번호를 사용하세요.


```
mysql -u root -p
```

다음으로 LibreNMS를 위해 몇 가지 특정 변경사항을 해야 합니다. 아래 명령을 실행할 때 "password"를 안전한 장소(비밀번호 관리자와 같은 곳)에 기록하여 나중에 필요할 때를 대비하세요.

mysql 프롬프트에서 실행합니다.

```
CREATE DATABASE librenms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';
FLUSH PRIVILEGES;
```

이 작업을 완료한 후 "exit"를 입력하여 mariadb에서 나옵니다.

## PHP-FPM 구성

이 섹션은 공식 문서와 크게 다르지 않습니다. 파일 경로만 다릅니다. 먼저 www.conf 파일을 복사합니다.

```
cp /etc/opt/remi/php81/php-fpm.d/www.conf /etc/opt/remi/php81/php-fpm.d/librenms.conf
```

다음으로 librenms.conf 파일을 수정합니다.

```
vi /etc/opt/remi/php81/php-fpm.d/librenms.conf
```

"[www]"를 ["librenms]"로 변경합니다.

사용자 및 그룹을 "librenms"로 변경합니다:

```
user = librenms
group = librenms
```

마지막으로 "listen" 라인을 고유한 이름으로 변경합니다.

```
listen = /run/php-fpm-librenms.sock
```

변경 사항을 저장하고 파일을 종료합니다. 이 머신에서 실행될 유일한 웹 서비스인 경우 기존의 www.conf 파일을 삭제해도 무방합니다.

```
rm -f /etc/opt/remi/php81/php-fpm.d/www.conf
```

## Apache 구성

일반적으로 [Apache 사이트 활성화](../web/apache-sites-enabled.md) 프로시저를 사용하여 웹 서비스를 설정하지만 이 경우 기본 설정으로 진행합니다.

이 절차를 사용하려면 구성 파일을 /etc/httpd/sites-available에 배치한 다음 절차에 따라 사이트 활성화에 연결하면 됩니다. 그러나 기본 문서 루트는 /var/www/sub-domains/librenms/html이 **아닌** 대신 /opt/librenms/html이 됩니다.

다시 말하지만 이 경우에는 해당 절차를 사용하지 않고 기본 제안 설정을 사용합니다. 이렇게 하려면 다음 파일을 생성하여 시작합니다:

```
vi /etc/httpd/conf.d/librenms.conf
```

그리고 해당 파일에 다음을 배치합니다:

```
<VirtualHost *:80>
  DocumentRoot /opt/librenms/html/
  ServerName  librenms.example.com

  AllowEncodedSlashes NoDecode
  <Directory "/opt/librenms/html/">
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
  </Directory>

  # Enable http authorization headers
  <IfModule setenvif_module>
    SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1
  </IfModule>

  <FilesMatch ".+\.php$">
    SetHandler "proxy:unix:/run/php-fpm-librenms.sock|fcgi://localhost"
  </FilesMatch>
</VirtualHost>
```

이전 기본 사이트인 welcome.conf도 제거해야 합니다:

```
rm /etc/httpd/conf.d/welcome.conf
```

마지막으로 _httpd_ 및 _php-fpm_을 모두 활성화해야 합니다:

```
systemctl enable --now httpd
systemctl enable --now php81-php-fpm
```

## SELinux

SELinux를 사용하지 않을 계획이라면 이 부분은 건너뛰고 다음 섹션으로 이동하시기 바랍니다. 또한 SELinux를 지원하지 않는 컨테이너에서 LibreNMS를 사용하거나 기본적으로 포함되어 있지 않은 경우 이 부분이 적용될 수 있습니다.

SELinux로 모든 것을 설정하려면 추가 패키지를 설치해야 합니다:

```
dnf install policycoreutils-python-utils
```

### LibreNMS 컨텍스트 구성

LibreNMS의 컨텍스트를 구성해야 SELinux와 제대로 작동하도록 설정해야 합니다.

```
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/html(/.*)?' semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/(logs|rrd|storage)(/.*)?' restorecon -RFvv /opt/librenms
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_execmem 1
chcon -t httpd_sys_rw_content_t /opt/librenms/.env
```

### fping 허용

`http_fping.tt`라는 파일을 만들고 나중에 명령을 통해 설치됩니다. 이 파일의 내용은 다음과 같습니다.

```
module http_fping 1.0;

require {
type httpd_t;
class capability net_raw;
class rawip_socket { getopt create setopt write read };
}

#============= httpd_t ==============
allow httpd_t self:capability net_raw;
allow httpd_t self:rawip_socket { getopt create setopt write read };
```

다음 명령을 사용하여 이 파일의 내용을 설치합니다.

```
checkmodule -M -m -o http_fping.mod http_fping.tt
semodule_package -o http_fping.pp -m http_fping.mod
semodule -i http_fping.pp
```

SELinux 문제로 인한 문제가 발생하는 경우 다음 명령을 실행하여 원인을 추적하세요.

```
audit2why < /var/log/audit/audit.log
```

## 방화벽 구성 - `firewalld`

공식 문서에서 _firewalld_ 지침을 포함하겠습니다.

_firewalld_를 사용하는 방화벽 허용 규칙의 명령어는 다음과 같습니다.

```
firewall-cmd --zone public --add-service http --add-service https
firewall-cmd --permanent --zone public --add-service http --add-service https
```

저자는 이러한 단순한 _firewalld_ 규칙 세트를 사용하는 것에 문제가 있습니다. 이 규칙은 웹 서비스를 전 세계에 공개하기 때문에 모니터링 서버로는 적합하지 않을 수 있습니다.

일반적으로 **그렇지 않을 것**으로 보입니다. 더 구체적인 _firewalld_ 접근 방식을 원하면 [이 문서](../security/firewalld.md)를 확인한 다음 필요에 따라 _firewalld_ 규칙을 변경하세요.

## 심볼릭 링크 및 lnms 명령어 자동 완성 활성화

먼저, _lnms_ 명령어에 대한 심볼릭 링크가 필요하므로 아래와 같이 실행하여 어디서든 실행될 수 있도록 합니다.

```
ln -s /opt/librenms/lnms /usr/bin/lnms
```

다음으로 자동 완성을 위해 설정해야 합니다:

```
cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/
```

## snmpd 구성

_SNMP_는 "Simple Network Management Protocol"의 약자로, 많은 모니터링 프로그램에서 데이터를 가져오는 데 사용됩니다. 우리가 여기서 사용하는 버전 2에서는 환경에 특정한 "community string"이 포함됩니다.

네트워크 기기에 이 "community string"을 할당하여 모니터링하려는 기기를 지정해야 합니다. 이렇게 하면 _snmpd_ (여기서 "d"는 데몬을 의미합니다)가 해당 기기를 찾을 수 있습니다. 기존에 "community string"이 이미 있는 경우도 있을 수 있습니다.

먼저 LibreNMS에서 snmp.conf 파일을 복사합니다:

```
cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf
```

다음으로, 이 파일을 편집하고 "RANDOMSTRINGGOESHERE"를 사용하고 있는 기존 "community string"으로 변경합니다. 예를 들어, 우리의 예시에서는 이를 "LABone"으로 변경합니다:

```
vi /etc/snmp/snmpd.conf
```

그리고 다음 줄을 변경합니다:

```
com2sec readonly  default         RANDOMSTRINGGOESHERE
```

to

```
com2sec readonly  default         LABone
```

변경 사항을 저장하고 종료합니다.

## 크론(Cron) 작업으로 자동화하기

cron 작업을 설정하려면 다음 명령을 실행합니다:

```
cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms
```

웹 설정 절차를 실행하기 전에 최소한 한 번은 폴러(poller)가 실행된 것이 중요합니다. 실제로 폴링할 것이 없을지라도, 이렇게 한 번 실행하는 것이 유효성 검사 부분에서 폴러 오류를 겪을 때 무엇이 문제인지를 찾는 데 도움이 됩니다.

폴러는 "librenms" 사용자로 실행되며, 이 사용자로 전환하여 크론 파일을 실행할 수도 있지만, 폴러가 스스로 실행하도록 하는 것이 좋습니다. 따라서 이 섹션과 아래의 "웹 설정" 섹션 사이에 최소한 5분이 지났는지 확인해주세요.

## 로그 로테이션(Log Rotation) 설정하기

LibreNMS는 시간이 지남에 따라 큰 로그 집합을 생성합니다. 이로 인해 디스크 공간이 많이 차지되지 않도록 로그 로테이션을 설정해야 합니다. 이를 위해 다음 명령을 실행하세요:

```
cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms
```

## Composer 설치하기

PHP Composer는 현재 설치에 필요한 도구입니다 (앞서 언급한 절차에서 언급됨). 이전에 실행한 설치가 실패한 경우 이 단계를 수행해야 합니다.

시작하기 전에 현재 버전의 `PHP` 바이너리를 경로에 링크해야 합니다. REMI 설치를 사용하여 올바른 버전의 PHP를 얻었기 때문에 경로에 설치되지 않은 상태입니다.

이를 해결하기 위해 심볼릭 링크를 생성하는 것이 간단하며, 나머지 단계를 진행하는 동안 더욱 편리합니다:

```
ln -s /opt/remi/php81/root/usr/bin/php /usr/bin/php
```

이제 [Composer 웹사이트](https://getcomposer.org/download/)로 이동하여 다음 단계가 변경되지 않았는지 확인합니다. 그렇다면 다음 명령을 어딘가에서 실행하세요 (위치는 중요하지 않습니다. 작업이 완료되면 composer를 이동시킬 것입니다):

```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

그리고 이를 경로 내의 특정 위치로 이동합니다. 우리는 여기서 `/usr/local/bin/`을 사용합니다:

```
mv composer.phar /usr/local/bin/composer
```

## 웹 설정

이제 모든 구성 요소가 설치되고 설정되었으므로, 웹을 통해 설치를 마무리해야 합니다. 랩 용 버전에서는 호스트 이름이 설정되어 있지 않으므로 설치를 완료하려면 IP 주소로 웹 서버에 접속해야 합니다.

랩 용 머신의 IP는 192.168.1.140이므로 다음 주소로 웹 브라우저에 접속하여 설치를 완료합니다:

`http://192.168.1.140/librenms`

올바르게 작동한다면, 사전 설치 점검으로 리디렉션될 것입니다. 이러한 점검 항목이 모두 녹색으로 표시된다면 계속 진행할 수 있어야 합니다.

![LibreNMS Prechecks](../images/librenms_prechecks.png)

LibreNMS 로고 아래에는 네 개의 버튼이 있습니다. 제일 왼쪽의 첫 번째 버튼은 사전 점검을 위한 것입니다. 다음 버튼은 데이터베이스에 대한 것입니다. 앞서 프로세스에서 "librenms" 데이터베이스 사용자의 비밀번호를 설정했다면 해당 비밀번호가 필요합니다.

열심히 따라오셨다면 안전한 장소에 비밀번호를 저장해두셨을 것입니다. "Database" 버튼을 클릭하세요. "User"와 "Password"만 채우면 됩니다. 채우고 나면 "Check Credentials" 버튼을 클릭하세요.

![LibreNMS Database](../images/librenms_configure_database.png)

클릭하면 녹색으로 표시된다면, "Build Database" 버튼을 클릭할 준비가 된 것입니다.

![LibreNMS Database Status](../images/librenms_configure_database_status.png)

완료되면 세 번째 버튼인 "Create Admin User"가 활성화됩니다. 이 버튼을 클릭하여 관리자 사용자를 만드세요. 관리용 사용자 이름을 입력해야 합니다. 우리의 실험용에서는 간단히 "admin"을 사용하겠습니다. 그리고 해당 사용자를 위한 비밀번호도 설정하세요.

비밀번호가 안전한지 확인하고, 다시 말하지만, 비밀번호 관리자와 같은 안전한 장소에 로그해두세요. 관리자 사용자의 이메일 주소도 입력해야 합니다. 이 모든 작업이 완료되면 "Add User" 버튼을 클릭하세요.

![LibreNMS Administrative User](../images/librenms_administrative_user.png)

이제 "Finish Install" 화면이 나타날 것입니다. 설치를 완료하기 위해 남은 작업은 "validate your install"이라는 항목 한 가지 뿐입니다.

해당 링크를 클릭하세요. 성공적으로 모든 작업을 완료하면 로그인 페이지로 리디렉션될 것입니다. 관리자 사용자 이름과 비밀번호로 로그인하세요.

## 장치 추가하기

다시 한 번 강조하지만, 가정하에 사용한 것은 SNMP v2를 사용하고 있다고 가정합니다. 추가하는 각 장치는 반드시 "community string"의 구성원이어야 합니다. 여기서는 예로 두 개의 장치를 추가하고 있습니다 : Ubuntu 워크스테이션 및 CentOS 서버. 여기서는 예시로 Ubuntu 워크스테이션과 CentOS 서버를 두 대 추가합니다.

일반적으로 관리 스위치, 라우터 및 기타 장치를 추가할 수 있습니다. 저자는 과거 경험으로 스위치와 라우터를 추가하는 것이 워크스테이션과 서버를 추가하는 것보다 훨씬 쉽다고 말할 수 있으며, 이로 인해 더 어려운 예제를 포함하고 있습니다.

### Ubuntu 워크스테이션 설정

먼저, 안전을 위해 패키지를 업데이트하면서 워크스테이션에 _snmpd_를 설치하세요:

```
sudo update && sudo apt-get upgrade && sudo apt-get install snmpd
```

다음으로, snmpd.conf 파일을 수정해야 합니다:

```
sudo vi /etc/snmpd/snmpd.conf
```

워크스테이션을 설명하는 줄을 찾아 해당하는 정보로 변경하세요. 아래에 해당 줄들을 보여드리겠습니다:

```
sysLocation    Desktop
sysContact     Username <user@mydomain.com>
```

기본적으로 Ubuntu에 snmpd를 설치하면 로컬 주소에만 바인딩됩니다. 머신 IP 주소에서는 수신하지 않습니다. 이렇게 하면 LibreNMS가 연결할 수 없습니다. 이 줄을 주석 처리해야 합니다:

```
agentaddress  127.0.0.1,[::1]
```

그리고 다음과 같은 새로운 줄을 추가하세요: (이 예시에서 워크스테이션의 IP 주소는 192.168.1.122이며, 설정하는 UDP 포트는 "161"입니다)

```
agentAddress udp:127.0.0.1:161,udp:192.168.1.122:161
```

다음으로, 읽기 전용 접근 "community string"을 지정해야 합니다. 아래 줄들을 찾아 주석 처리하세요. (아래에 주석 처리된 상태로 보여드리겠습니다.)

```
#rocommunity public default -V systemonly
#rocommunity6 public default -V systemonly
```

새로운 줄을 추가하세요:

```
rocommunity LABone
```

변경 사항을 저장하고 파일을 종료합니다.

_snmpd_ 활성화하고 시작하세요:

```
sudo systemctl enable snmpd
sudo systemctl start snmpd
```

내부 워크스테이션에서 방화벽을 실행 중이라면, 모니터링 서버 또는 네트워크에서 오는 UDP 트래픽을 허용하도록 방화벽을 수정해야 합니다. LibreNMS는 장치에 "ping"을 보낼 수 있어야 하므로 서버에서 icmp 포트 8을 허용하도록 해주세요.

### CentOS 또는 Rocky Linux 서버 설정

여기서는 root 사용자 또는 _sudo_를 통해 root 권한을 얻을 수 있다고 가정합니다. 먼저 몇 가지 패키지를 설치해야 합니다:

```
dnf install net-snmp net-snmp-utils
```

다음으로, snmpd.conf 파일을 만들어야 합니다. 기본으로 제공되는 파일을 탐색하려 하지 않고, 이 파일을 이름을 바꾸기 위해 이동하고 새로운 빈 파일을 생성합니다:

```
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
```

그리고

```
vi /etc/snmp/snmpd.conf
```

새 파일에 아래 내용을 복사하세요:

```
# Map 'LABone' community to the 'AllUser'
# sec.name source community
com2sec AllUser default LABone
# Map 'ConfigUser' to 'ConfigGroup' for SNMP Version 2c
# Map 'AllUser' to 'AllGroup' for SNMP Version 2c
# sec.model sec.name
group AllGroup v2c AllUser
# Define 'SystemView', which includes everything under .1.3.6.1.2.1.1 (or .1.3.6.1.2.1.25.1)
# Define 'AllView', which includes everything under .1
# incl/excl subtree
view SystemView included .1.3.6.1.2.1.1
view SystemView included .1.3.6.1.2.1.25.1.1
view AllView included .1
# Give 'ConfigGroup' read access to objects in the view 'SystemView'
# Give 'AllGroup' read access to objects in the view 'AllView'
# context model level prefix read write notify
access AllGroup "" any noauth exact AllView none none
```

CentOS 및 Rocky는 매핑 컨벤션을 사용하여 방향을 지정합니다. 위 파일은 설명이 잘 되어 있으므로 어떤 작업을 수행하는지 알 수 있지만, 원래 파일의 불필요한 세부사항은 포함되지 않았습니다.

변경 사항을 저장하고 파일을 종료합니다.

이제 _snmpd_를 활성화하고 시작하세요:

```
systemctl enable snmpd
systemctl start snmpd
```

#### 방화벽

서버를 실행 중이라면 **방화벽을 실행 중**이겠죠?  _firewalld_을 실행 중이라면 기본적으로 "trusted" 영역을 사용한다고 가정하고 모니터링 서버인 192.168.1.140에서 오는 모든 트래픽을 허용하도록 합니다:

```
firewall-cmd --zone=trusted --add-source=192.168.1.140 --permanent
```

다시 한 번 말하지만, 여기서는 "trusted" 영역을 가정했습니다. 원하시는 다른 영역, 심지어 "public"을 사용할 수도 있습니다. 규칙을 추가하기 전에 규칙과 그 영향을 고려해주세요.

## Librenms에 장치 추가

이제 샘플 장치들은 LibreNMS 서버에서 SNMP 트래픽을 받아들이도록 구성되었습니다. 다음 단계는 LibreNMS에 이러한 장치들을 추가하는 것입니다. 이미 LibreNMS의 웹 인터페이스가 열려 있고, 장치가 추가되지 않았다는 메시지와 함께 장치 추가하기를 요청할 것입니다.

그러니 그렇게 하세요. 장치 추가를 클릭하면 다음 화면이 나타납니다:

![LibreNMS 장치 추가하기](../images/librenms_add_device.png)

테스트 장치에 사용한 정보를 입력하세요. 저희의 경우에는 Ubuntu 워크스테이션의 IP를 사용하겠습니다. 이 예제에서는 192.168.1.122입니다. "Community" 필드에는 "LABone"이라고 입력해야 합니다.

이제 "Add Device" 버튼을 클릭하세요. 장치 추가 작업을 진행하는 데 모든 것을 올바르게 수행했다면, 장치가 성공적으로 추가될 것입니다.

"추가 실패" 오류가 발생하면 워크스테이션의 SNMP 설정 또는 방화벽 설정을 확인하세요. 이후에 CentOS 서버에 대해 "Add Device" 작업을 반복합니다.

## 알림 받기

처음부터 말씀드린 것처럼, 이 문서는 LibreNMS를 시작하는 데 도움이 될 것입니다. 추가 구성 항목이 많이 있으며, 확장 가능한 API (Application Programming Interface)와 "Transports"라고 불리는 다양한 알림 전송 옵션이 있습니다.

우리는 알림 규칙을 생성하지 않고, 기본으로 미리 설정되어 있는 "Device Down! Due to no ICMP response"라는 내장 알림 규칙을 수정할 것입니다. 또한 "Transports"로 "Mail"을 사용하여 이메일로 알림을 받도록 설정할 것입니다. 당신이 제한적이지 않다는 것만 알아두세요.

그러나 알림을 이메일로 전송하려면 서버에서 메일을 작동시켜야 합니다. 이를 위해 [Postfix 절차](../email/postfix_reporting.md)를 사용하겠습니다.

postfix를 구성하려면 그 프로세스를 따라가서 메시지의 출처를 정확히 식별하도록 설정하지만, 설정 프로세스가 끝난 후에 여기로 돌아와도 됩니다.

### 전송

알림을 전송할 방법이 필요합니다. 앞서 언급했듯이 LibreNMS는 많은 수의 전송을 지원합니다. 우리는 이메일을 통해 알림을 받도록 설정할 것이며, "Mail" 전송으로 정의됩니다. 전송 설정 방법:

1. 대시보드로 이동
2. "Alerts" 위로 마우스를 가져갑니다.
3. "Alert Transports"로 이동하여 클릭합니다.
4. "Create alert transport" 버튼을 클릭합니다("Create transport group" 버튼에 유의하십시오. 이 버튼을 사용하여 경고를 여러 개인에게 보낼 수 있습니다).
5. "Transport name:" 필드에 "Alert By Email"을 입력합니다.
6. "Transport type:" 필드에서 드롭다운을 사용하여 "Mail"을 선택합니다.
7. "Default alert:" 필드가 "On"로 설정되어 있는지 확인합니다.
8. "Email:" 필드에 관리자의 이메일 주소를 입력합니다.

### 장치를 그룹으로 구성

알림을 설정하기 전에 먼저 장치를 어떤 논리적인 순서로 구성할지 결정하는 것이 좋습니다. 현재 장치로 "workstation"과 "server"가 있습니다. 보통 두 장치를 하나로 합치고 싶지 않을 수도 있지만, 이 예시를 위해서는 함께 합칠 것입니다.

이 예시는 또한 중복적입니다. "All Devices" 그룹이 이 역할을 충분히 할 수 있기 때문입니다. 장치 그룹을 설정하는 방법:

1. 대시보드로 이동
2. "Devices" 위로 마우스를 가져갑니다.
3. "Manage Groups"로 이동하여 클릭합니다.
4. "+ New Device Group" 버튼을 클릭합니다.
5. "Name" 필드에 "ICMP Group"을 입력합니다.
6. 설명 필드에 그룹을 설명하는 데 도움이 될 것이라고 생각하는 것을 입력하십시오.
7. "Type" 필드를 "Dynamic"에서 "Static"으로 변경합니다.
8. 두 장치를 "Select Devices" 필드에 추가한 다음 변경 사항을 저장하세요.

### 알림 규칙 설정하기

전송과 장치 그룹을 설정했으니 이제 알림 규칙을 구성해보겠습니다. 기본적으로 LibreNMS에는 여러 개의 알림 규칙이 이미 미리 생성되어 있습니다.

1. 대시보드로 이동
2. "Alerts" 위로 마우스를 가져갑니다.
3. "Alert Rules"으로 이동하여 클릭합니다.
4. 상단에 표시된 활성 규칙 중 "Device Down! Due to no ICMP response"입니다. Due to no ICMP response."를 찾고 규칙을 편집하기 위해 "Action" (가장 오른쪽 열)의 연필 아이콘을 클릭하세요.
5. 상단의 모든 필드를 그대로 두고, "Match devices, groups and locations list:" 필드로 이동하여 클릭하세요.
6. 목록에서 "ICMP Group"을 선택합니다.
7. "All devices except in list:"  필드가 "Off"인지 확인합니다.
8. "Transports:" 필드 내부를 클릭하고 "Mail: Alert By Email"을 선택하고 규칙을 저장합니다.

저장하기 전에 규칙은 다음과 같아야 합니다.

![LibreNMS 알림 규칙](../images/librenms_alert_rule.png)

이제 이 두 장치가 다운되거나 복구되면 이메일로 알림을 받게 될 것입니다.

## 결론

LibreNMS는 한 애플리케이션에서 모든 기능이 갖추어진 강력한 모니터링 도구입니다. 우리는 여기서 그 기능의 _일부_만 살펴보았습니다. 일부 자명한 화면은 보여드리지 않았습니다.

예를 들어, 장치를 추가하면 모든 SNMP 속성이 올바르게 설정되었다면 대역폭, 메모리 사용률 및 CPU 사용률 그래프를 각 장치에서 즉시 받아보게 될 것입니다. "Mail" 이외에도 사용 가능한 다양한 전송 방법에 대해 설명하지 않았습니다.

그럼에도 불구하고 이 문서에서는 환경을 모니터링하는 데 충분한 내용을 보여드렸습니다. LibreNMS는 모든 요소를 마스터하는 데 시간이 걸립니다. 추가 정보는 프로젝트의 [우수 문서](https://docs.librenms.org/)를 참조해 주세요.
