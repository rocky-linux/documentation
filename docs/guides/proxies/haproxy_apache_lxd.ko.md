---
title: HAProxy-Apache-LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Antoine Le Morvan
tested_with: 8.5, 8.6, 9.0
---

# LXD 컨테이너를 사용하는 HAProxy 로드 밸런싱 Apache

## 소개

HAProxy는 "고가용성 프록시"의 약어입니다. 이 프록시는 어떤 TCP 애플리케이션(예: 웹 서버) 앞에 위치할 수 있지만, 주로 여러 웹사이트 인스턴스 사이의 로드 밸런서로 사용됩니다.

이를 수행하는 이유는 여러 가지가 있을 수 있습니다. 웹 사이트에 높은 트래픽이 발생하는 경우, 동일한 웹 사이트 인스턴스를 추가하고 HAProxy를 두 인스턴스 앞에 놓음으로써 트래픽을 분산할 수 있습니다. 다른 이유로는 웹 사이트의 콘텐츠를 다운 타임 없이 업데이트할 수 있도록 하는 것입니다. HAProxy는 DOS 및 DDOS 공격을 완화하는 데에도 도움이 될 수 있습니다.

이 가이드에서는 두 개의 웹사이트 인스턴스를 사용하여 HAProxy를 사용하는 방법과 라운드 로빈 방식의 로드 밸런싱을 동일한 LXD 호스트에서 수행합니다. 이것은 업데이트를 다운 타임 없이 수행하기 위한 완벽한 솔루션일 수 있습니다.

그러나 웹사이트 성능에 문제가 있는 경우, 여러 사이트를 실제 물리적 서버 또는 여러 LXD 호스트 간에 분산하는 것이 필요할 수 있습니다. 물론 LXD를 전혀 사용하지 않고 바로 물리적 서버에서 모든 작업을 수행하는 것도 가능하지만, LXD는 유연성과 성능면에서 우수하며, 실습 테스트에도 좋습니다.

## 전제 조건 및 가정

* 리눅스 머신의 명령 줄에서 완전히 익숙해야 함
* 명령줄 편집기 사용 경험(여기서는 `vim` 사용)
* `crontab` 사용 경험
* LXD에 대한 지식. 추가 정보는 [LXD 서버 문서](../../books/lxd_server/00-toc.md)를 참조하면 됩니다. 완전한 서버 설치를 하지 않고도 노트북이나 워크스테이션에 LXD를 설치하는 것도 완전히 괜찮습니다. 이 문서는 LXD를 사용하는 랩 머신에 작성되었습니다. 하지만 위에 링크된 문서처럼 완전한 서버로 설정되지는 않았습니다.
* 웹 서버 설치, 구성 및 사용에 대한 지식
* 이 문서에서는 LXD 호스트가 이미 설치되어 컨테이너를 만들 준비가 되어 있다고 가정합니다.

## 컨테이너 설치

이 가이드에서는 세 개의 컨테이너가 필요합니다. 물론 원한다면 더 많은 웹 서버 컨테이너를 사용할 수도 있습니다. **web1** 및 **web2**를 웹사이트 컨테이너로, 그리고 **proxyha**를 HAProxy 컨테이너로 사용할 것입니다. 이를 LXD 호스트에서 설치하려면 다음 명령을 사용하세요:

```
lxc launch images:rockylinux/8 web1
lxc launch images:rockylinux/8 web2
lxc launch images:rockylinux/8 proxyha
```
`lxc list`를 실행하면 다음과 같이 반환됩니다:

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 10.181.87.137 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 10.181.87.207 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 10.181.87.34 (eth0)  |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## `macvlan` 프로필 생성 및 사용

현재 컨테이너는 기본 브리지 인터페이스에 브릿지가 할당된 DHCP 주소로 실행 중입니다. 로컬 LAN의 DHCP 주소를 사용하려면 먼저 `macvlan` 프로파일을 생성하고 할당해야 합니다.

먼저 프로파일을 생성합니다:

`lxc profile create macvlan`

사용하려는 편집기가 기본 편집기로 설정되어 있는지 확인합니다. 여기서는 `vim`을 사용합니다:

`export EDITOR=/usr/bin/vim`

그 다음 `macvlan` 프로파일을 수정해야 합니다. 하지만 그 전에 호스트가 LAN에 사용하는 인터페이스를 알아내야 합니다. `ip addr`를 실행하여 LAN IP 할당이 있는 인터페이스를 찾습니다:

```
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a8:5e:45:52:f8:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.141/24 brd 192.168.1.255 scope global dynamic noprefixroute eno1
```
!!! 참고 사항

    이 경우 사용하는 인터페이스는 "eno1"입니다. 하지만 여러분의 시스템에서는 완전히 다를 수 있습니다. **자신의** 인터페이스 정보를 사용하세요!

이제 LAN 인터페이스를 알았으므로 `macvlan` 프로파일을 수정합니다. 이를 위해 명령 줄에서 다음 명령을 입력합니다:

`lxc profile edit macvlan`

프로파일은 다음과 같이 보이도록 해야 합니다. 파일 상단의 주석은 제외했습니다. LXD에 익숙하지 않은 경우 주석도 확인해보세요:

```
config: {}
description: ""
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: eno1
    type: nic
name: macvlan
```

`macvlan` 프로파일을 생성하면 `default` 프로파일이 복사되었습니다. `default` 프로파일은 변경할 수 없습니다.

이제 `macvlan` 프로파일을 우리의 세 개 컨테이너에 적용해야 합니다:

```
lxc profile assign web1 default,macvlan
lxc profile assign web2 default,macvlan
lxc profile assign proxyha default,macvlan
```

불행하게도, 컨테이너 내에서 커널에서 구현된 `macvlan`의 기본 동작은 예상치 못하게도 동작하지 않습니다([이 문서](../../books/lxd_server/06-profiles.md) 참조). `dhclient`가 컨테이너에서 부팅될 때 마다 실행되지 않습니다.

이는 DHCP를 사용하는 경우 매우 간단합니다. 각 컨테이너에서 다음을 수행하세요:

* `lxc exec web1 bash` : **web1** 컨테이너의 명령줄로 이동합니다.
* `crontab -e` : 컨테이너의 루트 `crontab`을 편집합니다.
* `i`를 입력하여 삽입 모드로 진입합니다.
* 한 줄 추가: `@reboot /usr/sbin/dhclient`
* 'ESC' 키를 눌러 삽입 모드를 종료합니다.
* `SHIFT: wq`를 사용하여 변경 사항을 저장합니다.
* `exit`를 입력하여 컨테이너를 종료합니다.

**web2** 및 **proxyha**에 대해 동일한 단계를 반복합니다.

이 단계를 완료한 후에 컨테이너를 재시작합니다:

```
lxc restart web1
lxc restart web2
lxc restart proxyha
```

그리고 `lxc list`를 다시 실행하면 DHCP 주소가 LAN에서 할당된 것을 확인할 수 있습니다.

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 192.168.1.149 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 192.168.1.150 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 192.168.1.101 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## Apache 설치 및 시작 화면 수정

환경 설정이 완료되었으므로 각 웹 컨테이너에 Apache(`httpd`)를 설치해야 합니다. 직접 접근하지 않고도 다음 명령으로 수행할 수 있습니다:

```
lxc exec web1 dnf install httpd
lxc exec web2 dnf install httpd
```
현대적인 웹 서버를 위해서는 아파치 이외에도 많은 것이 필요하다는 점은 이해하셨을 것입니다. 그러나 이는 몇 가지 테스트를 실행하기에 충분합니다.

다음으로 `httpd`를 활성화하고 시작한 다음, 디폴트 환영 화면을 수정하여 프록시로 액세스할 때 어떤 서버를 타겟으로 하고 있는지 확인해봅시다.

`httpd` 활성화하고 시작합니다:

```
lxc exec web1 systemctl enable httpd
lxc exec web1 systemctl start httpd
lxc exec web2 systemctl enable httpd
lxc exec web2 systemctl start httpd
```

`httpd`를 활성화하고 시작한 이후에, 환영 화면을 수정해봅시다. 이는 웹사이트가 구성되지 않은 경우에 나타나는 화면, 즉 기본 페이지를 의미합니다. Rocky Linux에서 이 페이지는 `/usr/share/httpd/noindex/index.html` 위치에 있습니다. 다시 말하지만 컨테이너에 직접 액세스할 필요가 없습니다. 다음과 같이 수행하세요:

`lxc exec web1 vi /usr/share/httpd/noindex/index.html`

그런 다음 `<h1>` 태그를 검색하면 다음과 같이 표시됩니다.

`<h1>HTTP Server <strong>Test Page</strong></h1>`

그냥 이 줄을 다음과 같이 변경하세요:

`<h1>SITE1 HTTP Server <strong>Test Page</strong></h1>`

이제 web2에 대해 동일한 작업을 반복하세요. 브라우저에서 IP로 이 머신들에 접속하면 각각 올바른 환영 페이지가 반환됩니다. 웹 서버에서 해야 할 작업이 더 많지만, 웹 서버는 두고 프록시 서버로 이동합니다.

## proxyha 및 LXD 프록시 구성에 HAProxy 설치

프록시 컨테이너에도 HAProxy를 설치하는 것은 매우 간단합니다. 다시 말하지만, 해당 컨테이너에 직접 액세스할 필요가 없습니다:

`lxc exec proxyha dnf install haproxy`

다음으로 `haproxy`를 80포트와 443포트에서 웹 서비스를 수신하도록 구성하려고 합니다. 이는 `lxc`의 configure 하위 명령어를 사용하여 수행합니다:
```
lxc config device add proxyha http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxyha https proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

테스트에서는 80포트 또는 HTTP 트래픽만 사용할 것이지만, 이렇게 하면 컨테이너가 HTTP와 HTTPS 모두의 기본 웹 포트에서 수신하도록 구성하는 방법을 보여줍니다. 이 명령을 사용하면 **proxyha** 컨테이너를 다시 시작해도 해당 수신 포트가 유지됩니다.

## HAProxy 구성

이미 프록시 컨테이너에 HAProxy를 설치했지만, 아직 구성을 하지 않았습니다. 아무 것도 하기 전에 호스트를 해결하기 위해 무언가를 수행해야 합니다. 일반적으로는 완전히 정규화된 도메인 이름을 사용하지만, 이 랩 환경에서는 IP를 사용하고 있습니다. **proxyha** 컨테이너에 몇 개의 호스트 파일 레코드를 추가하여 머신과 연관된 일부 이름을 추가하겠습니다.

`lxc exec proxyha vi /etc/hosts`

파일의 맨 아래에 다음 레코드를 추가하세요:

```
192.168.1.150   site1.testdomain.com     site1
192.168.1.101   site2.testdomain.com     site2
```

이렇게 하면 **proxyha**  컨테이너에서 이러한 이름을 해결할 수 있습니다.

이 작업이 완료되면 `haproxy.cfg 파일을 편집합니다. 원본 파일에는 사용하지 않을 수많은 설정이 들어있기 때문에 다른 이름으로 백업하겠습니다:

`lxc exec proxyha mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig`

이제 새 구성 파일을 생성해봅시다:

`lxc exec proxyha vi /etc/haproxy/haproxy.cfg`

현재 https 프로토콜 라인은 모두 주석 처리되어 있습니다. 운영 환경에서는 웹 서버를 커버하는 와일드카드 인증서를 사용하고 HTTPS를 활성화하길 원할 것입니다:

```
global
log /dev/log local0
log /dev/log local1 notice
chroot /var/lib/haproxy
stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
stats timeout 30s
user haproxy
group haproxy
daemon

# 지금은 모든 https가 표시됩니다. #
#ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
#ssl-default-bind-ciphers EECDH+AESGCM:EDH+AESGCM
#tune.ssl.default-dh-param 2048

defaults
log global
mode http
option httplog
option dontlognull
option forwardfor
option http-server-close
timeout connect 5000
timeout client 50000
timeout server 50000
errorfile 400 /etc/haproxy/errors/400.http
errorfile 403 /etc/haproxy/errors/403.http
errorfile 408 /etc/haproxy/errors/408.http
errorfile 500 /etc/haproxy/errors/500.http
errorfile 502 /etc/haproxy/errors/502.http
errorfile 503 /etc/haproxy/errors/503.http
errorfile 504 /etc/haproxy/errors/504.http

# 지금은 모든 https가 표시됩니다. # frontend www-https
# bind *:443 ssl crt /etc/letsencrypt/live/example.com/example.com.pem
# reqadd X-Forwarded-Proto:\ https

# acl host_web1 hdr(host) -i site1.testdomain.com
# acl host_web2 hdr(host) -i site2.testdomain.com

# use_backend subdomain1 if host_web1
# use_backend subdomain2 if host_web2

frontend http_frontend
bind *:80

acl web_host1 hdr(host) -i site1.testdomain.com
acl web_host2 hdr(host) -i site2.testdomain.com

use_backend subdomain1 if web_host1
use_backend subdomain2 if web_host2

backend subdomain1
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site1 site1.testdomain.com:80 check
     server site2 web2.testdomain.com:80 check

backend subdomain2
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site2 site2.testdomain.com:80 check
     server site1 site1.testdomain.com:80 check
```

위에서 무슨 일이 일어나는지 간단히 설명해드리겠습니다. 테스트하는 동안 이해하게 될 것입니다. 이 가이드의 테스트 섹션으로 이동하면 다음과 같이 확인할 수 있습니다.

**site1**과 **site2**가 "acl" 섹션에서 정의되어 있습니다. 그런 다음 각 웹 서버의 "roundrobin"에  **site1**과 **site2**가 서로 포함됩니다. 테스트에서 site1.testdomain.com로 이동하는 경우 URL은 변경되지 않지만 페이지 내부는 **site1**에서 **site2** 테스트 페이지로 전환됩니다. site2.testdomain.com도 마찬가지로 작동합니다.

이렇게 하면 전환이 발생하는 것을 보여주기 위한 것이지만, 실제로는 어떤 서버를 타겟으로 하더라도 웹사이트 내용은 동일합니다. 여러 호스트 사이에서 트래픽을 분산시키는 방법을 보여주기 위해 이렇게 하는 것입니다. "leastcon"을 balance 라인에 사용하여 이전 히트에 따라 전환하는 대신 연결 수가 가장 적은 사이트를 로드할 수도 있습니다.

### 오류 파일

일부 HAProxy 버전에는 표준 웹 에러 파일 세트가 포함되어 있지만 Rocky Linux (및 상위 업스트림 공급업체)에서 제공되는 버전에는 이러한 파일이 없습니다. 문제를 해결하는 데 도움이 될 수 있으므로 이 파일을 만들어보는 것이 좋습니다. 이 파일은 존재하지 않는 `/etc/haproxy/errors` 디렉터리에 위치해야 합니다.

가장 먼저 해야 할 일은 해당 디렉토리를 만드는 것입니다.

`lxc exec proxyha mkdir /etc/haproxy/errors`

그런 다음 해당 디렉터리에 각 파일을 생성해야 합니다. 파일 이름은 각각 filename.http를 사용하여 LXD 호스트에서 `lxc exec proxyha vi /etc/haproxy/errors/filename.http` 명령으로 생성할 수 있습니다. 운영 환경에서는 회사별로 사용하고 싶은 더 구체적인 에러 파일이 있을 수 있습니다:

파일 이름 `400.http`:

```
HTTP/1.0 400 Bad request
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>400 Bad request</h1>
Your browser sent an invalid request.
</body></html>
```

파일 이름 `403.http`:

```
HTTP/1.0 403 Forbidden
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>403 Forbidden</h1>
Request forbidden by administrative rules.
</body></html>
```

파일 이름 `408.http`:

```
HTTP/1.0 408 Request Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>408 Request Time-out</h1>
Your browser didn't send a complete request in time.
</body></html>
```

파일 이름 `500.http`:

```
HTTP/1.0 500 Internal Server Error
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>500 Internal Server Error</h1>
An internal server error occurred.
</body></html>
```

파일 이름 `502.http`:

```
HTTP/1.0 502 Bad Gateway
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>502 Bad Gateway</h1>
The server returned an invalid or incomplete response.
</body></html>
```

파일 이름 `503.http`:

```
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
```

파일 이름 `504.http`:

```
HTTP/1.0 504 Gateway Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>504 Gateway Time-out</h1>
The server didn't respond in time.
</body></html>
```

## 프록시 실행

서비스를 시작하기 전에 `haproxy`를 실행할 "run" 디렉토리를 생성해야 합니다:

`lxc exec proxyha mkdir /run/haproxy`

다음으로 서비스를 활성화하고 시작합니다:
```
lxc exec proxyha systemctl enable haproxy
lxc exec proxyha systemctl start haproxy
```
오류가 발생하면 다음 명령으로 이유를 조사하세요:

`lxc exec proxyha systemctl status haproxy`

문제 없이 모든 것이 시작되고 실행된다면, 이제 테스트를 진행할 준비가 된 것입니다.

## 프록시 테스트

로깅

`/etc/hosts` 파일을 수정하여 우리의 프록시 컨테이너인 **proxyha**가 웹 서버를 해석할 수 있도록 설정한 것처럼, 랩 환경에서 로컬 DNS 서버가 없기 때문에 로컬 머신에서도 site1과 site2 웹 사이트에 대한 IP 값을 haproxy 컨테이너와 일치시켜야 합니다. 이러한 도메인 해석 방법을 "집착스러운 사람의 DNS"라고 생각하면 됩니다.

`sudo vi /etc/hosts`

그리고 다음 두 줄을 추가합니다:

```
192.168.1.149   site1.testdomain.com     site1
192.168.1.149   site2.testdomain.com     site2
```

지금 로컬 컴퓨터에서 **site1** 또는 **site2**를 ping하면 **proxyha**에서 응답을 받아야 합니다.

```
PING site1.testdomain.com (192.168.1.149) 56(84) bytes of data.
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=2 ttl=64 time=0.430 ms
```

웹 브라우저를 열고 주소 창에 site1.testdomain.com (또는 site2.testdomain.com)을 입력하면 두 개의 테스트 페이지 중 하나로부터 응답을 받아야 합니다. 페이지를 다시 로드하면 다음 서버의 테스트 페이지를 얻게 될 것입니다. URL은 변경되지 않지만 반환되는 페이지는 서버간에 번갈아 변경됩니다.


![screenshot of web1 being loaded and showing the second server test message](../images/haproxy_apache_lxd.png)

## 로깅

구성 파일이 로깅에 대해 올바르게 설정되어 있더라도 두 가지가 필요합니다. 먼저 /var/lib/haproxy/ 디렉토리에 "dev" 디렉토리가 있어야 합니다:

`lxc exec proxyha mkdir /var/lib/haproxy/dev`

다음으로, `rsyslogd`에서 소켓(`/var/lib/haproxy/dev/log`)에서 인스턴스를 가져와 이를 `/var/log/haproxy.log`에 저장하는 시스템 프로세스를 만들어야 합니다:

`lxc exec proxyha vi /etc/rsyslog.d/99-haproxy.conf`

다음 내용을 파일에 추가합니다:

```
$AddUnixListenSocket /var/lib/haproxy/dev/log

# HAProxy 메시지를 전용 로그 파일로 보내기
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}
```
파일을 저장하고 종료한 다음 `rsyslog`를 다시 시작합니다.

`lxc exec proxyha systemctl restart rsyslog`

그리고 바로 로그 파일에 내용을 채우기 위해 `haproxy`를 다시 시작합니다:

`lxc exec proxyha systemctl restart haproxy`

로그 파일을 확인하려면 다음 명령을 실행합니다:

`lxc exec proxyha more /var/log/haproxy.log`

그러면 다음과 같은 내용이 표시됩니다.

```
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
```

## 결론

HAProxy는 많은 용도로 사용될 수 있는 강력한 프록시 엔진입니다. TCP 및 HTTP 애플리케이션에 대한 고성능 오픈소스 로드 밸런서 및 리버스 프록시입니다. 이 문서에서는 두 개의 웹 서버 인스턴스를 로드 밸런싱하는 방법을 보여주었습니다.

또한 데이터베이스를 포함하여 다른 애플리케이션에도 사용할 수 있습니다. LXD 컨테이너 내부뿐만 아니라 베어 메탈 및 독립 실행형 서버에서도 작동합니다.

이 문서에서 다루지 않은 다양한 사용 사례들이 있습니다. [여기에서 HAProxy 공식 설명서](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html)를 확인하세요.
