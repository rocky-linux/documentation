---
title: PHP 와 PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - web
  - php
  - php-fpm
---

# PHP 와 PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) 는 웹 애플리케이션 개발을 위해 특별히 설계된 소스 스크립팅 언어입니다. 2021년 기준으로 PHP는 전 세계에서 생성된 웹 페이지의 약 80%를 차지하였습니다. PHP는 오픈 소스이며, 가장 유명한 CMS(WordPress, Drupal, Joomla!, Magento 등)의 핵심입니다.

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) 은 PHP 5.3.3 버전부터 PHP에 통합되었습니다. FastCGI 버전의 PHP는 추가적인 기능을 제공합니다.

## 개요

**CGI** (**C**ommon **G**ateway **I**nterface) 와 **FastCGI**는 웹 서버 (Apache, Nginx 등)와 개발 언어 (Php, Python, Java) 간의 통신을 가능하게 합니다:

* **CGI**의 경우, 각 요청마다 **새로운 프로세스**가 생성되어 성능 측면에서 효율적이지 않습니다.
* **FastCGI**는 클라이언트 요청 처리를 위해 **일정한 수의 프로세스**에 의존합니다.

PHP-FPM은 **더 나은 성능**을 제공하는 것 외에도 다음과 같은 기능을 제공합니다:

* 애플리케이션을 **더 나눠서 관리**할 수 있는 기능: 다른 uid/gid로 프로세스 시작, 사용자 정의 php.ini 파일로 실행,
* 통계 관리,
* 로그 관리,
* 프로세스의 동적 관리 및 서비스 중단 없이 재시작 ('graceful').

!!! note "참고 사항"

    Apache에는 PHP 모듈이 있기 때문에 php-fpm은 Nginx 서버에서 더 일반적으로 사용됩니다.

## PHP 버전 선택

Rocky Linux는 상위 호환성을 유지하면서 언어의 여러 버전을 제공합니다. 일부 버전은 지원 기간이 종료되었지만, 새로운 PHP 버전과 호환되지 않는 기존 애플리케이션을 계속 호스팅하기 위해 유지되고 있습니다. 지원되는 버전을 선택하기 위해 php.net 웹사이트의 [지원되는 버전 ](https://www.php.net/supported-versions.php) 페이지를 참조하십시오

사용 가능한 버전 목록을 얻으려면 다음 명령을 입력하면 됩니다:

```
$ sudo dnf module list php
Rocky Linux 8 - AppStream
Name         Stream          Profiles                           Summary                       
php          7.2 [d]         common [d], devel, minimal         PHP scripting language        
php          7.3             common [d], devel, minimal         PHP scripting language        
php          7.4             common [d], devel, minimal         PHP scripting language        

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Rocky는 AppStream 저장소에서 다양한 PHP 모듈을 제공합니다.

작성 시점에서 Rocky 8.5의 기본 버전은 이미 생명 주기가 종료된 7.2입니다.

다음 명령을 입력하여 새로운 모듈을 활성화할 수 있습니다:

```
sudo dnf module enable php:7.4
==============================================================================================
 Package               Architecture         Version               Repository             Size
==============================================================================================
Enabling module streams:
 httpd                                      2.4                                              
 php                                        7.4                                              

Transaction Summary
==============================================================================================

Is this ok [y/N]: y
Complete!
```

!!! note "참고 사항"

    현재 AppStream 저장소에서는 PHP 8을 설치할 수 없습니다. 이를 위해서는 REMI 저장소를 통해 설치해야 합니다. 이 설치는 이 문서에서 다루지 않습니다.

이제 PHP 엔진을 설치해 보겠습니다.

## PHP CGI 모드

먼저, CGI 모드로 PHP를 설치하고 사용하는 방법을 알아보겠습니다. 이 모드는 Apache 웹 서버와 `mod_php` 모듈과 함께 작동할 수 있습니다. 나중에 이 문서에서는 FastCGI 부분 (php-fpm)에서 PHP를 Nginx에 통합하는 방법도 알아볼 것입니다 (물론 Apache도 가능합니다).

### 설치

PHP의 설치는 매우 간단합니다. 주요 패키지와 필요한 몇 가지 PHP 모듈을 설치하는 것으로 이루어집니다.

아래 예시는 PHP와 일반적으로 함께 설치되는 모듈을 함께 설치하는 방법을 보여줍니다.

```
$ sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

설치된 버전이 기대한 버전과 일치하는지 확인할 수 있습니다:

```
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### 구성

### Apache 통합

CGI 모드에서 php 페이지를 서비스하려면 Apache 서버를 설치하고 구성하고 활성화하고 시작해야 합니다.

* 설치:

```
$ sudo dnf install httpd
```

* 활성화:

```
$ sudo systemctl enable httpd
$ sudo systemctl start httpd
$ sudo systemctl status httpd
```

* 방화벽 구성을 잊지 마세요:

```
$ sudo firewall-cmd --add-service=http --permanent
$ sudo firewall-cmd --reload
```

기본 가상 호스트(vhost)는 기본 설정으로 작동해야 합니다. PHP는 구성에 대한 요약 테이블을 생성하는 `phpinfo()` 함수를 제공합니다. 이 함수는 PHP가 올바르게 작동하는지 테스트하는 데 매우 유용합니다. 그러나 이러한 테스트 파일을 서버에 그대로 두지 않도록 주의해야 합니다. 이러한 파일은 인프라에 대한 엄청난 보안 위험을 표현합니다.

`/var/www/html/info.php` 파일을 생성하세요 (`/var/www/html`은 기본 Apache 구성의 기본 가상 호스트 디렉토리입니다):

```
<?php
phpinfo();
?>
```

웹 브라우저를 사용하여 http://your-server-ip/info.php  페이지로 이동하여 서버가 올바르게 작동하는지 확인하세요.

!!! warning "주의"

    info.php 파일을 서버에 남겨두지 마세요!

## PHP-FPM (FastCGI)

이 문서에서 앞서 언급한 대로, 웹 호스팅을 php-fpm 모드로 전환하는 것에는 많은 장점이 있습니다.

### 설치

설치는 php-fpm 패키지로 제한됩니다:

```
$ sudo dnf install php-fpm
```

php-fpm은 시스템적인 측면에서 서비스이므로 활성화되고 시작되어야 합니다:

```
$ sudo systemctl enable php-fpm
$ sudo systemctl start php-fpm
$ sudo systemctl status php-fpm
```

### 구성

주요 구성 파일은 `/etc/php-fpm.conf`에 저장됩니다.

```
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! 참고 사항

    php-fpm 구성 파일에는 다양한 주석이 달려 있습니다. 확인해 보세요!

`/etc/php-fpm/` 디렉토리에는 `.conf` 확장자를 가진 파일이 항상 포함되어 있습니다.

기본적으로 `/etc/php-fpm.d/www.conf`에 `www`라는 이름의 php 프로세스 풀이 선언됩니다.

```
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

| 명령       | 설명                                                               |
| -------- | ---------------------------------------------------------------- |
| `[pool]` | 프로세스 풀 이름. 구성 파일은 여러 프로세스 풀로 구성될 수 있습니다(대괄호 안의 풀 이름은 새 섹션을 시작함). |
| `listen` | 수신 인터페이스 또는 사용되는 유닉스 소켓을 정의합니다.                                  |

#### php-fpm 프로세스에 접근하는 방법 구성

두 가지 방법으로 연결할 수 있습니다.

인터페이스를 통한 연결(예:):

`listen = 127.0.0.1:9000`.

또는 Unix socket을 통한 연결:

`listen = /run/php-fpm/www.sock`.

!!! note "참고 사항"

    웹 서버와 php 서버가 동일한 기기에 있는 경우 소켓을 사용하면 TCP/IP 레이어를 제거하고 성능을 최적화할 수 있습니다.

인터페이스를 통해 작업하는 경우 `listen.owner`, `listen.group`, `listen.mode`를 구성하여 유닉스 소켓의 소유자, 소유자 그룹 및 권한을 지정해야 합니다. **주의**: 웹 서버와 php 서버 모두 소켓에 대한 액세스 권한이 있어야 합니다.

소켓을 통해 작업하는 경우 `listen.allowed_clients`를 구성하여 특정 IP 주소에서 php 서버로의 액세스를 제한해야 합니다.

예: `listen.allowed_clients = 127.0.0.1`

#### 정적 또는 동적 구성

php-fpm 프로세스는 정적 또는 동적으로 관리할 수 있습니다.

정적 모드에서는 자식 프로세스의 수가 `pm.max_children` 값에 의해 설정됩니다.

```
pm = static
pm.max_children = 10
```

이 구성은 10개의 프로세스를 시작합니다.

동적 모드에서는 PHP-FPM이 최대 `pm.max_children` 값에 해당하는 프로세스 수를 시작합니다. `pm.start_servers`에 해당하는 프로세스 수를 시작하고, 최소한 `pm.min_spare_servers` 개의 비활성 프로세스와 최대 `pm.max_spare_servers` 개의 비활성 프로세스를 유지합니다.

예시:

```
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM은 `pm.max_requests`에 해당하는 요청을 처리한 프로세스를 대체하기 위해 새로운 프로세스를 생성합니다.

기본적으로 `pm.max_requests`는 0으로 설정되어 있으며, 이는 프로세스가 절대로 재사용되지 않음을 의미합니다. `pm.max_requests` 옵션을 사용하면 메모리 누수가 있는 애플리케이션에 유용할 수 있습니다.

`ondemand` 모드라는 세 번째 운영 모드도 있습니다. 이 모드는 요청을 받을 때만 프로세스를 시작합니다. 강력한 영향을 받는 사이트에는 최적의 모드가 아니며, 특정한 필요에 대해서만 사용해야 합니다(요청이 매우 적은 사이트, 관리 백엔드 등).

!!! note "참고 사항"

    PHP-FPM의 운영 모드 구성은 웹 서버의 최적 동작을 보장하기 위해 필수적입니다.


#### 프로세스 상태

PHP-FPM은 Apache와 `mod_status` 모듈과 마찬가지로 프로세스 상태를 나타내는 페이지를 제공합니다.

페이지를 활성화하려면 `pm.status_path` 지시문을 통해 액세스 경로를 설정하세요.

```
pm.status_path = /status
```

```
$ curl http://localhost/status_php
pool:                 www
process manager:      dynamic
start time:           03/Dec/2021:14:00:00 +0100
start since:          600
accepted conn:        548
listen queue:         0
max listen queue:     15
listen queue len:     128
idle processes:       3
active processes:     3
total processes:      5
max active processes: 5
max children reached: 0
slow requests:        0
```

#### 긴 요청 로깅

slowlog 지시문은 시간이 `request_slowlog_timeout` 지시문의 값보다 긴(즉, 제한 시간을 초과한) 요청의 로깅을 수행할 파일을 지정합니다.

생성된 파일의 기본 위치는 `/var/log/php-fpm/www-slow.log`입니다.

```
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

`request_slowlog_timeout`에 0 값을 설정하면 로깅이 비활성화됩니다.

### NGinx 통합

Nginx의 기본 설정에는 PHP-FPM과 함께 작동하기 위해 필요한 구성이 이미 포함되어 있습니다.

구성 파일 `fastcgi.conf` (또는 `fastcgi_params`)은 `/etc/nginx/` 아래에 위치합니다.

```
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP 전용, PHP가 --enable-force-cgi-redirect로 빌드된 경우 필요
fastcgi_param  REDIRECT_STATUS    200;
```

nginx가 `.php` 파일을 처리하려면 사이트 구성 파일에 다음 지시문을 추가해야 합니다.

php-fpm이 포트 9000에서 수신하는 경우:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

php-fpm이 유닉스 소켓에서 수신하는 경우:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### 아파치 통합

PHP 풀을 사용하기 위한 아파치의 구성은 매우 간단합니다. 예를 들어 `ProxyPassMatch` 지시문과 함께 프록시 모듈을 사용해야 합니다.

```
<VirtualHost *:80>
  ServerName web.rockylinux.org
  DocumentRoot "/var/www/html/current/public"

  <Directory "/var/www/html/current/public">
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>
  ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/html/current/public"

</VirtualHost>

```

### PHP 풀의 견고한 구성

서비스할 수 있는 요청의 양을 최적화하기 위해 PHP 스크립트에서 사용되는 메모리를 분석하고 최대로 시작되는 스레드의 양을 최적화하는 것이 중요합니다.

먼저, 다음 명령어를 사용하여 PHP 프로세스가 사용하는 평균 메모리 양을 알아야 합니다:

```
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

잠시 후, 이 명령어는 이 서버의 PHP 프로세스의 평균 메모리 사용량에 대해 꽤 정확한 아이디어를 제공해야 합니다.

이 문서의 나머지 부분에서, 이 결과가 해당 서버의 프로세스의 평균 메모리 사용량이 120MB라고 가정해 봅시다.

8GB의 RAM을 가진 서버에서, 시스템에 1GB, OPCache에 1GB을 유지하고 PHP 클라이언트 요청을 처리하기 위해 6GB가 남습니다.

우리는 이 서버가 최대 **50개의 스레드**를 처리할 수 있다고 결론을 내릴 수 있습니다. `((6*1024) / 120)`.

이러한 사용 사례에 특화된 `php-fpm`의 좋은 구성은 다음과 같을 것입니다:

```
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

그리고 :

* `pm.start_servers` = 25% of `max_children`
* `pm.min_spare_servers` = 25% of `max_children`
* `pm.max_spare_servers` = 75% of `max_children`

### OPCache 구성

`opcache` (Optimizer Plus Cache)는 우리가 영향을 줄 수 있는 첫 번째 캐시 수준입니다.

이는 메모리에 컴파일된 PHP 스크립트를 유지하여 웹 페이지의 실행에 강력한 영향을 미칩니다(스크립트의 디스크에서의 읽기 + 컴파일 시간을 제거합니다).

구성하기 위해 다음 사항에 작업해야 합니다:

* 적중 비율에 따라 opcache에 할당된 메모리의 크기

정확하게 구성함으로써





* 캐시할 PHP 스크립트의 수 (키의 수 + 최대 스크립트 수)
* 캐시할 문자열의 수

설치하려면:

```
$ sudo dnf install php-opcache
```

구성하기 위해 `/etc/php.d/10-opcache.ini` 구성 파일을 편집하세요:

```
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

여기서:

* `opcache.memory_consumption`은 opcache에 필요한 메모리 양에 해당합니다 (올바른 적중 비율을 얻을 때까지 증가시킵니다).
* `opcache.interned_strings_buffer`는 캐시할 문자열의 양입니다.
* `opcache.max_accelerated_files`는 `find ./ -iname "*.php" | wc -l` 명령의 결과에 근접해야 합니다.

`info.php` 페이지( `phpinfo();`를 포함)를 참조하여 opcache를 구성할 수 있습니다 (예: `Cached scripts` 및 `Cached strings`의 값 확인).

!!! note "참고 사항"

    새로운 코드를 배포할 때마다 opcache를 비워야 합니다 (예: php-fpm 프로세스를 다시 시작하여 비웁니다).

!!! note "참고 사항"

    올바르게 설치하고 구성하는 것으로 얻을 수 있는 속도 향상을 과소평가하지 마십시오.
