---
title: 소프트웨어 관리
author: Antoine Le Morvan
contributors: Colussi Franco, Steven Spencer
tested version: 8.5
tags:
  - 교육
  - 소프트웨어
  - 소프트웨어 관리
---

# 소프트웨어 관리

## 개요

Linux 시스템에서는 두 가지 방법으로 소프트웨어를 설치할 수 있습니다.

* 설치 패키지 사용
* 소스 파일에서 컴파일.

!!! 참고 사항

    소스에서 설치하는 것은 여기에서 다루지 않습니다. 원칙적으로 패키지 관리자를 통해 원하는 소프트웨어를 사용할 수 없는 경우가 아니면 패키지 방법을 사용해야 합니다. 그 이유는 종속성이 일반적으로 패키지 시스템에서 관리되는 반면 소스에서는 종속성을 수동으로 관리해야 하기 때문입니다.

**패키지**: 프로그램을 설치하는 데 필요한 모든 데이터가 포함된 단일 파일입니다. 소프트웨어 리포지토리에서 시스템에 직접 실행할 수 있습니다.

**소스 파일**: 일부 소프트웨어는 설치 준비가 된 패키지로 제공되지 않고 소스 파일이 포함된 아카이브를 통해 제공됩니다. 이러한 파일을 준비하고 컴파일하여 프로그램을 설치하는 것은 관리자의 몫입니다.

## RPM: RedHat Package Manager

**RPM**(RedHat Package Manager)은 소프트웨어 관리 시스템입니다. 패키지에 포함된 소프트웨어를 설치, 제거, 업데이트 또는 확인할 수 있습니다.

**RPM**은 모든 RedHat 기반 배포판(RockyLinux, Fedora, CentOS, SuSe, Mandriva 등)에서 사용되는 형식입니다. Debian 세계에서 이에 상응하는 것은 DPKG(Debian Package)입니다.

RPM 패키지의 이름은 특정 명명법을 따릅니다.

![패키지 이름 그림](images/software-001.png)

### `rpm` 명령

rpm 명령을 사용하면 패키지를 설치할 수 있습니다.

```bash
rpm [-i][-U] package.rpm [-e] package
```

예('package'라는 이름의 패키지의 경우):

```bash
rpm -ivh package.rpm
```

| 옵션               | 설명                   |
| ---------------- | -------------------- |
| `-i package.rpm` | 패키지를 설치합니다.          |
| `-U package.rpm` | 이미 설치된 패키지를 업데이트합니다. |
| `-e package.rpm` | 패키지를 제거합니다.          |
| `-h`             | 진행률 표시줄을 표시합니다.      |
| `-v`             | 작업 진행 상황을 알려줍니다.     |
| `--test`         | 명령을 실행하지 않고 테스트합니다.  |

`rpm` 명령을 사용하면 `-q` 옵션을 추가하여 시스템 패키지 데이터베이스를 쿼리할 수도 있습니다.

설치된 패키지에 대한 다양한 정보를 얻기 위해 여러 유형의 쿼리를 실행할 수 있습니다. RPM 데이터베이스는 `/var/lib/rpm` 디렉토리에 있습니다.

예시:

```bash
rpm -qa
```

이 명령은 시스템에 설치된 모든 패키지를 조회합니다.

```bash
rpm -q [-a][-i][-l] package [-f] file
```

예시:

```bash
rpm -qil package
rpm -qf /path/to/file
```

| 옵션               | 설명                                            |
| ---------------- | --------------------------------------------- |
| `-a`             | 시스템에 설치된 모든 패키지를 나열합니다.                       |
| `-i __package__` | 패키지 정보를 표시합니다.                                |
| `-l __package__` | 패키지에 포함된 파일을 나열합니다.                           |
| `-f`             | 지정된 파일을 포함하는 패키지의 이름을 표시합니다.                  |
| `--last`         | 패키지 목록은 설치 날짜별로 제공됩니다(마지막으로 설치된 패키지가 먼저 표시됨). |

!!! 주의

    `-q` 옵션 뒤에는 패키지 이름이 정확해야 합니다. 메타문자(wildcards)는 지원되지 않습니다.

!!! 팁

    그러나 `grep` 명령으로 설치된 모든 패키지와 필터를 나열할 수 있습니다.

예: 마지막으로 설치된 패키지 나열:

```bash
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

예: 커널의 설치 기록을 나열합니다.

```bash
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

예: `grep`을 사용하여 특정 이름을 가진 설치된 모든 패키지를 나열합니다.

```bash
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF: Dandified Yum

**DNF**(**Dandified Yum**) 는 YUM의 후속 소프트웨어 패키지 관리자입니다. **YUM** (**Y**ellow dog **U**pdater **M**odified). 로컬 또는 원격 리포지토리(패키지를 저장하기 위한 디렉토리)에 그룹화된 **RPM** 패키지와 함께 작동합니다. 가장 일반적인 명령의 경우 사용법은 `yum`과 동일합니다.

`dnf` 명령을 사용하면 시스템에 설치된 패키지와 서버에 정의된 리포지토리의 패키지를 비교하여 패키지를 관리할 수 있습니다. 또한 리포지토리에도 종속성이 있는 경우 종속성을 자동으로 설치합니다.

`dnf`는 많은 RedHat 기반 배포판(RockyLinux, Fedora, CentOS 등)에서 사용하는 관리자입니다. Debian 세계에서 이에 상응하는 것은 **APT**입니다(**A**dvanced **P**ackaging **T**ool).

### `dnf` 명령

`dnf` 명령을 사용하면 짧은 이름만 지정하여 패키지를 설치할 수 있습니다.

```bash
dnf [install][remove][list all][search][info] package
```

예시:

```bash
dnf install tree
```

패키지의 짧은 이름만 필요합니다.

| 옵션                        | 설명                                       |
| ------------------------- | ---------------------------------------- |
| `install`                 | 패키지를 설치합니다.                              |
| `remove`                  | 패키지를 제거합니다.                              |
| `list all`                | 리포지토리에 추가된 최신 패키지를 나열합니다.                |
| `search`                  | 리포지토리에서 패키지를 검색합니다.                      |
| `provides */command_name` | 명령을 검색합니다.                               |
| `info`                    | 패키지 정보를 표시합니다.                           |
| `autoremove`              | 종속성으로 설치되었지만 더 이상 필요하지 않은 모든 패키지를 제거합니다. |


`dnf install` 명령을 사용하면 `dnf` 자체에서 직접 해결되는 종속성에 대해 걱정하지 않고 원하는 패키지를 설치할 수 있습니다.

```bash
dnf install nginx
Last metadata expiration check: 3:13:41 ago on Wed 23 Mar 2022 07:19:24 AM CET.
Dependencies resolved.
============================================================================================================================
 Package                             Architecture    Version                                        Repository         Size
============================================================================================================================
Installing:
 nginx                               aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream         543 k
Installing dependencies:
 nginx-all-modules                   noarch          1:1.14.1-9.module+el8.4.0+542+81547229         appstream          22 k
 nginx-mod-http-image-filter         aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          33 k
 nginx-mod-http-perl                 aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          44 k
 nginx-mod-http-xslt-filter          aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          32 k
 nginx-mod-mail                      aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          60 k
 nginx-mod-stream                    aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          82 k

Transaction Summary
============================================================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.2 M
Is this ok [y/N]:
```

패키지의 정확한 이름이 기억나지 않는 경우 `dnf search name` 명령으로 검색할 수 있습니다. 보시다시피 정확한 이름이 포함된 섹션과 패키지 대응이 포함된 다른 섹션이 있으며 검색하기 쉽도록 모두 강조 표시되어 있습니다.

```bash
dnf search nginx
Last metadata expiration check: 0:20:55 ago on Wed 23 Mar 2022 10:40:43 AM CET.
=============================================== Name Exactly Matched: nginx ================================================
nginx.aarch64 : A high performance web server and reverse proxy server
============================================== Name & Summary Matched: nginx ===============================================
collectd-nginx.aarch64 : Nginx plugin for collectd
munin-nginx.noarch : NGINX support for Munin resource monitoring
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-filesystem.noarch : The basic directory layout for the Nginx server
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
pagure-web-nginx.noarch : Nginx configuration for Pagure
pcp-pmda-nginx.aarch64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver
python3-certbot-nginx.noarch : The nginx plugin for certbot
```

추가 검색 키를 입력하여 패키지를 검색하는 또 다른 방법은 파이프를 통해 `dnf` 명령의 결과를 원하는 키와 함께 grep 명령으로 보내는 것입니다.

```bash
dnf search nginx | grep mod
Last metadata expiration check: 3:44:49 ago on Wed 23 Mar 2022 06:16:47 PM CET.
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
```


`dnf remove` 명령은 시스템 및 해당 종속성에서 패키지를 제거합니다. 다음은 **dnf remove httpd** 명령의 일부입니다.

```bash
dnf remove httpd
Dependencies resolved.
============================================================================================================================
 Package                        Architecture    Version                                            Repository          Size
============================================================================================================================
Removing:
 httpd                          aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         8.9 M
Removing dependent packages:
 mod_ssl                        aarch64         1:2.4.37-43.module+el8.5.0+727+743c5577.1          @appstream         274 k
 php                            aarch64         7.4.19-1.module+el8.5.0+696+61e7c9ba               @appstream         4.4 M
 python3-certbot-apache         noarch          1.22.0-1.el8                                       @epel              539 k
Removing unused dependencies:
 apr                            aarch64         1.6.3-12.el8                                       @appstream         299 k
 apr-util                       aarch64         1.6.1-6.el8.1                                      @appstream         224 k
 apr-util-bdb                   aarch64         1.6.1-6.el8.1                                      @appstream          67 k
 apr-util-openssl               aarch64         1.6.1-6.el8.1                                      @appstream          68 k
 augeas-libs                    aarch64         1.12.0-6.el8                                       @baseos            1.4 M
 httpd-filesystem               noarch          2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         400
 httpd-tools                    aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1
...
```

`dnf list` 명령은 시스템에 설치되고 리포지토리에 있는 모든 패키지를 나열합니다. 다음과 같은 여러 매개변수를 허용합니다.

| 변수          | 설명                                      |
| ----------- | --------------------------------------- |
| `all`       | 설치된 패키지와 리포지토리에서 사용 가능한 패키지를 나열합니다.     |
| `available` | 설치할 수 있는 패키지만 나열합니다.                    |
| `updates`   | 업그레이드할 수 있는 패키지를 나열합니다.                 |
| `obsoletes` | 사용 가능한 상위 버전에서 더 이상 사용되지 않는 패키지를 나열합니다. |
| `recent`    | 리포지토리에 추가된 최신 패키지를 나열합니다.               |

예상할 수 있듯이 `dnf info` 명령은 패키지에 대한 자세한 정보를 제공합니다.

```bash
dnf info firewalld
Last metadata expiration check: 15:47:27 ago on Tue 22 Mar 2022 05:49:42 PM CET.
Installed Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8
Architecture : noarch
Size         : 2.0 M
Source       : firewalld-0.9.3-7.el8.src.rpm
Repository   : @System
From repo    : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.

Available Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8_5.1
Architecture : noarch
Size         : 501 k
Source       : firewalld-0.9.3-7.el8_5.1.src.rpm
Repository   : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.
```

때로는 사용하려는 실행 파일만 알고 있고 이를 포함하는 패키지를 모르는 경우가 있습니다. 이 경우 `dnf provide */package_name` 명령을 사용하면 원하는 일치 항목에 대해 데이터베이스를 검색할 수 있습니다.

`semanage` 명령 검색의 예:

```bash
dnf provides */semanage
Last metadata expiration check: 1:12:29 ago on Wed 23 Mar 2022 10:40:43 AM CET.
libsemanage-devel-2.9-6.el8.aarch64 : Header files and libraries used to build policy manipulation tools
Repo        : powertools
Matched from:
Filename    : /usr/include/semanage

policycoreutils-python-utils-2.9-16.el8.noarch : SELinux policy core python utilities
Repo        : baseos
Matched from:
Filename    : /usr/sbin/semanage
Filename    : /usr/share/bash-completion/completions/semanage
```

`dnf autoremove` 명령에는 매개변수가 필요하지 않습니다. Dnf는 제거할 후보 패키지를 검색합니다.

```bash
dnf autoremove
Last metadata expiration check: 0:24:40 ago on Wed 23 Mar 2022 06:16:47 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
```

### 기타 유용한 `dnf` 옵션

| 옵션          | 설명                     |
| ----------- | ---------------------- |
| `repolist`  | 시스템에 구성된 리포지토리를 나열합니다. |
| `grouplist` | 사용 가능한 패키지 모음을 나열합니다.  |
| `clean`     | 임시 파일을 제거합니다.          |

`dnf repolist` 명령은 시스템에 구성된 리포지토리를 나열합니다. 기본적으로 활성화된 리포지토리만 나열되지만 다음 매개 변수와 함께 사용할 수 있습니다.

| 변수           | 설명                  |
| ------------ | ------------------- |
| `--all`      | 모든 리포지토리를 나열합니다.    |
| `--enabled`  | Default             |
| `--disabled` | 비활성화된 리포지토리만 나열합니다. |

예시:

```bash
dnf repolist
repo id                                                  repo name
appstream                                                Rocky Linux 8 - AppStream
baseos                                                   Rocky Linux 8 - BaseOS
epel                                                     Extra Packages for Enterprise Linux 8 - aarch64
epel-modular                                             Extra Packages for Enterprise Linux Modular 8 - aarch64
extras                                                   Rocky Linux 8 - Extras
powertools                                               Rocky Linux 8 - PowerTools
rockyrpi                                                 Rocky Linux 8 - Rasperry Pi
```

그리고 `--all` 플래그가 있는 명령의 발췌 부분입니다.

```bash
dnf repolist --all

...
repo id                                             repo name                                                                                       status
appstream                                           Rocky Linux 8 - AppStream                                                                       enabled
appstream-debug                                     Rocky Linux 8 - AppStream - Source                                                              disabled
appstream-source                                    Rocky Linux 8 - AppStream - Source                                                              disabled
baseos                                              Rocky Linux 8 - BaseOS                                                                          enabled
baseos-debug                                        Rocky Linux 8 - BaseOS - Source                                                                 disabled
baseos-source                                       Rocky Linux 8 - BaseOS - Source                                                                 disabled
devel                                               Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE                                       disabled
epel                                                Extra Packages for Enterprise Linux 8 - aarch64                                                 enabled
epel-debuginfo                                      Extra Packages for Enterprise Linux 8 - aarch64 - Debug                                         disabled
epel-modular                                        Extra Packages for Enterprise Linux Modular 8 - aarch64                                         enabled
epel-modular-debuginfo                              Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug                                 disabled
epel-modular-source                                 Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
...
```

아래는 비활성화된 리포지토리 목록에서 발췌한 것입니다.

```bash
dnf repolist --disabled
repo id                                 repo name
appstream-debug                         Rocky Linux 8 - AppStream - Source
appstream-source                        Rocky Linux 8 - AppStream - Source
baseos-debug                            Rocky Linux 8 - BaseOS - Source
baseos-source                           Rocky Linux 8 - BaseOS - Source
devel                                   Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
epel-debuginfo                          Extra Packages for Enterprise Linux 8 - aarch64 - Debug
epel-modular-debuginfo                  Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug
epel-modular-source                     Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
epel-source                             Extra Packages for Enterprise Linux 8 - aarch64 - Source
epel-testing                            Extra Packages for Enterprise Linux 8 - Testing - aarch64
...
```

`-v` 옵션을 사용하면 많은 추가 정보로 목록을 향상시킬 수 있습니다. 아래에서 명령 결과의 일부를 볼 수 있습니다.

```bash
dnf repolist -v

...
Repo-id            : powertools
Repo-name          : Rocky Linux 8 - PowerTools
Repo-revision      : 8.5
Repo-distro-tags      : [cpe:/o:rocky:rocky:8]:  ,  , 8, L, R, c, i, k, n, o, u, x, y
Repo-updated       : Wed 16 Mar 2022 10:07:49 PM CET
Repo-pkgs          : 1,650
Repo-available-pkgs: 1,107
Repo-size          : 6.4 G
Repo-mirrors       : https://mirrors.rockylinux.org/mirrorlist?arch=aarch64&repo=PowerTools-8
Repo-baseurl       : https://mirror2.sandyriver.net/pub/rocky/8.7/PowerTools/x86_64/os/ (30 more)
Repo-expire        : 172,800 second(s) (last: Tue 22 Mar 2022 05:49:24 PM CET)
Repo-filename      : /etc/yum.repos.d/Rocky-PowerTools.repo
...
```

!!! info "그룹 사용"

    그룹은 목적(데스크톱 환경, 서버, 개발 도구 등)을 달성하기 위해 일련의 응용 프로그램을 논리적으로 그룹화하는 패키지 집합(가상 패키지라고 생각할 수 있음) 모음입니다.

`dnf grouplist` 명령은 사용 가능한 모든 그룹을 나열합니다.

```bash
dnf grouplist
Last metadata expiration check: 1:52:00 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   KDE Plasma Workspaces
   Custom Operating System
Available Groups:
   Container Management
   .NET Core Development
   RPM Development Tools
   Development Tools
   Headless Management
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
```

`dnf groupinstall` 명령을 사용하면 이러한 그룹 중 하나를 설치할 수 있습니다.

```bash
dnf groupinstall "Network Servers"
Last metadata expiration check: 2:33:26 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Dependencies resolved.
================================================================================
 Package           Architecture     Version             Repository         Size
================================================================================
Installing Groups:
 Network Servers

Transaction Summary
================================================================================

Is this ok [y/N]:
```

명령이 없으면 그룹 이름에 공백이 포함되지 않은 경우에만 올바르게 실행되므로 그룹 이름을 큰따옴표로 묶는 것이 좋습니다.

따라서 `dnf groupinstall Network Servers`는 다음 오류를 생성합니다.

```bash
dnf groupinstall Network Servers
Last metadata expiration check: 3:05:45 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Module or Group 'Network' is not available.
Module or Group 'Servers' is not available.
Error: Nothing to do.
```

그룹을 제거하는 해당 명령은 `dnf groupremove "name group"`입니다.

`dnf clean` 명령은 `dnf`에 의해 생성된 모든 캐시와 임시 파일을 정리합니다. 다음 매개 변수와 함께 사용할 수 있습니다.

| 변수             | 설명                                  |
| -------------- | ----------------------------------- |
| `all`          | 활성화된 리포지토리에 대해 생성된 모든 임시 파일을 제거합니다. |
| `dbcache`      | 리포지토리 메타데이터에 대한 캐시 파일을 제거합니다.       |
| `expire-cache` | 로컬 쿠키 파일을 제거하십시오.                   |
| `metadata`     | 모든 리포지토리 메타데이터를 제거합니다.              |
| `packages`     | 캐시된 패키지를 제거합니다.                     |


### DNF 작동 방식

DNF 관리자는 하나 이상의 구성 파일을 사용하여 RPM 패키지가 포함된 리포지토리를 대상으로 지정합니다.

이러한 파일은 `/etc/yum.repos.d/`에 있으며 DNF에서 사용하려면 `.repo`로 끝나야 합니다.

예시:

```bash
/etc/yum.repos.d/Rocky-BaseOS.repo
```

각 `.repo` 파일은 최소한 다음과 같은 정보, 즉 한 줄에 하나의 지시문으로 구성됩니다.

예시:

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

기본적으로 `enabled` 지시어는 없으며 이는 리포지토리가 활성화되었음을 의미합니다. 리포지토리를 비활성화하려면 `enabled=0` 지시문을 지정해야 합니다.

## DNF 모듈

업스트림에서 Rocky Linux 8에 모듈을 도입했습니다. 모듈을 사용하려면 AppStream 리포지토리가 존재하고 활성화되어 있어야 합니다.

!!! 힌트 "패키지 혼란"

    AppStream 리포지토리에서 모듈 스트림 생성은 많은 사람들에게 혼란을 야기했습니다. 모듈은 스트림 내에서 패키지화되므로(아래 예제 참조) RPM에 특정 패키지가 표시되지만 모듈을 활성화하지 않고 설치를 시도하면 아무 일도 일어나지 않습니다. 패키지를 설치하려고 시도했지만 패키지를 찾지 못한 경우 모듈을 확인해야 합니다.

### 모듈이란 무엇입니까?

모듈은 AppStream 리포지토리에서 제공되며 스트림과 프로필을 모두 포함합니다. 다음과 같이 설명할 수 있습니다.

* **모듈 스트림:** 모듈 스트림은 서로 다른 애플리케이션 버전을 포함하는 AppStream 리포지토리 내 별도의 리포지토리로 생각할 수 있습니다. 이러한 모듈 리포지토리에는 해당 특정 스트림에 대한 애플리케이션 RPM, 종속성 및 설명서가 포함되어 있습니다. Rocky Linux 8에서 모듈 스트림의 예는 `postgresql`입니다. 표준 `sudo dnf install postgresql`을 사용하여 `postgresql`을 설치하면 버전 10이 설치됩니다. 그러나 모듈을 사용하면 버전 9.6, 12 또는 13을 대신 설치할 수 있습니다.

* **모듈 프로필:** 모듈 프로필이 하는 일은 패키지를 설치할 때 모듈 스트림의 사용 사례를 고려하는 것입니다. 프로필을 적용하면 패키지 RPM, 종속성 및 설명서가 모듈 사용을 고려하여 조정됩니다. 이 예에서 동일한 `postgresql` 스트림을 사용하여 "서버" 또는 "클라이언트" 프로필을 적용할 수 있습니다. 분명히 `postgresql`을 클라이언트로 사용하여 서버에 액세스하려는 경우 시스템에 동일한 패키지를 설치할 필요가 없습니다.

### 모듈 나열

다음 명령을 실행하여 모든 모듈 목록을 얻을 수 있습니다.

```
dnf module list
```

이렇게 하면 사용 가능한 모듈과 모듈에 사용할 수 있는 프로필의 긴 목록이 제공됩니다. 관심 있는 패키지가 무엇인지 이미 알고 있을 것이므로 특정 패키지에 대한 모듈이 있는지 확인하려면 "list" 뒤에 패키지 이름을 추가하십시오. 여기에서 `postgresql` 패키지 예제를 다시 사용합니다.

```
dnf module list postgresql
```

그러면 다음과 같은 출력이 표시됩니다.

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

목록에서 "[d]"를 확인하십시오. 이는 기본값임을 의미합니다. 기본 버전은 10이며 선택한 버전에 관계없이 프로필을 지정하지 않으면 서버 프로필도 기본값이므로 서버 프로필이 사용되는 프로필임을 보여줍니다.

### 모듈 활성화

예제 `postgresql` 패키지를 사용하여 버전 12를 활성화한다고 가정해 보겠습니다. 이렇게 하려면 다음을 사용하면 됩니다.

```
dnf module enable postgresql:12
```

여기서 enable 명령에는 모듈 이름과 ":" 및 스트림 이름이 필요합니다.

`postgresql` 모듈 스트림 버전 12를 활성화했는지 확인하려면 list 명령을 다시 사용하여 다음 출력을 표시해야 합니다.

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12 [e]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

여기에서 스트림 12 옆에 있는 "enabled"에 대한 "[e]"를 볼 수 있으므로 버전 12가 활성화되었음을 알 수 있습니다.

### 모듈 스트림에서 패키지 설치

모듈 스트림이 활성화되었으므로 다음 단계는 postgresql 서버용 클라이언트 애플리케이션인 `postgresql`을 설치하는 것입니다. 이는 다음 명령을 실행하여 달성할 수 있습니다.

```
dnf install postgresql
```

이 출력을 제공해야 합니다.

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k

Transaction Summary
========================================================================================================================================
Install  2 Packages
Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

"y"를 입력하여 승인한 후 애플리케이션을 설치했습니다.

### 모듈 스트림 프로필에서 패키지 설치

모듈 스트림을 활성화하지 않고도 패키지를 직접 설치할 수도 있습니다! 이 예에서는 클라이언트 프로필만 설치에 적용하려고 한다고 가정합니다. 이렇게 하려면 다음 명령을 입력하기만 하면 됩니다.

```
dnf install postgresql:12/client
```

이 출력을 제공해야 합니다.

```
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k
Installing module profiles:
 postgresql/client
Enabling module streams:
 postgresql                                        12

Transaction Summary
========================================================================================================================================
Install  2 Packages

Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

프롬프트에 "y"라고 대답하면 postgresql 버전 12를 클라이언트로 사용하는 데 필요한 모든 것이 설치됩니다.

### 모듈 제거 및 재설정 또는 전환

설치 후 어떤 이유로든 스트림의 다른 버전이 필요하다고 결정할 수 있습니다. 첫 번째 단계는 패키지를 제거하는 것입니다. 예제 `postgresql` 패키지를 다시 사용하면 다음과 같이 할 수 있습니다.

```
dnf remove postgresql
```

그러면 패키지와 모든 종속 항목이 제거된다는 점을 제외하면 위의 설치 절차와 유사한 출력이 표시됩니다. 프롬프트에 "y"라고 답하고 Enter 키를 눌러 `postgresql`을 제거합니다.

이 단계가 완료되면 다음을 사용하여 모듈에 대한 재설정 명령을 실행할 수 있습니다.

```
dnf module reset postgresql
```

그러면 다음과 같은 결과가 표시됩니다.

```
Dependencies resolved.
========================================================================================================================================
 Package                         Architecture                   Version                           Repository                       Size
========================================================================================================================================
Disabling module profiles:
 postgresql/client                                                                                                                     
Resetting modules:
 postgresql                                                                                                                            

Transaction Summary
========================================================================================================================================

Is this ok [y/N]:
```

프롬프트에 "y"라고 대답하면 `postgresql`을 활성화한 스트림(이 예시에서는 12)이 더 이상 활성화되지 않은 기본 스트림으로 재설정됩니다.

```
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

이제 기본값을 사용할 수 있습니다.

또한 전환 하위 명령을 사용하여 하나의 활성화된 스트림에서 다른 스트림으로 전환할 수 있습니다. 이 방법을 사용하면 새 스트림으로 전환할 뿐만 아니라 별도의 단계 없이 필요한 패키지(다운그레이드 또는 업그레이드)를 설치합니다. 이 방법을 사용하여 `postgresql` 스트림 버전 13을 활성화하고 "client" 프로필을 사용하려면 다음을 사용합니다.

```
dnf module switch-to postgresql:13/client
```

### 모듈 스트림 비활성화

모듈 스트림에서 패키지를 설치하는 기능을 비활성화하려는 경우가 있을 수 있습니다. 우리의 `postgresql` 예제의 경우, 새로운 버전을 사용할 수 있도록 [PostgreSQL](https://www.postgresql.org/download/linux/redhat/)에서 직접 리포지토리를 사용하고 싶기 때문일 수 있습니다(이 글을 쓰는 시점에서 버전 14 및 15는 이 리포지토리에서 사용할 수 있습니다). 모듈 스트림을 비활성화하면 먼저 다시 활성화하지 않고는 해당 패키지를 설치할 수 없습니다.

`postgresql`에 대한 모듈 스트림을 비활성화하려면 다음을 수행하십시오.

```
dnf module disable postgresql
```

그리고 `postgresql` 모듈을 다시 나열하면 비활성화된 모든 `postgresql` 모듈 버전을 보여주는 다음과 같은 것을 볼 수 있습니다.

```
Rocky Linux 8 - AppStream
Name                       Stream                   Profiles                          Summary                                           
postgresql                 9.6 [x]                  client, server [d]                PostgreSQL server and client module               
postgresql                 10 [d][x]                client, server [d]                PostgreSQL server and client module               
postgresql                 12 [x]                   client, server [d]                PostgreSQL server and client module               
postgresql                 13 [x]                   client, server [d]                PostgreSQL server and client module
```

## EPEL 리포지토리

### EPEL이란 무엇이며 어떻게 사용됩니까?

**EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux)은 Fedora 소스의 RHEL(및 CentOS, Rocky Linux 등)에 대한 추가 패키지 세트를 제공하는 [EPEL Fedora Special Interest Group](https://docs.fedoraproject.org/en-US/epel/)가 유지 관리하는 오픈 소스 및 무료 커뮤니티 기반 리포지토리입니다.

공식 RHEL 리포지토리에 포함되지 않은 패키지를 제공합니다. 이러한 항목은 엔터프라이즈 환경에서 필요하지 않거나 RHEL 범위를 벗어나는 것으로 간주되기 때문에 포함되지 않습니다. 이러한 항목은 엔터프라이즈 환경에서 필요하지 않거나 RHEL 범위를 벗어나는 것으로 간주되기 때문에 포함되지 않습니다.

### 설치

필요한 파일의 설치는 Rocky Linux에서 기본적으로 제공하는 패키지로 쉽게 할 수 있습니다.

인터넷 프록시 뒤에 있는 경우:

```bash
export http_proxy=http://172.16.1.10:8080
```

그 다음에:

```bash
dnf install epel-release
```

패키지가 설치되면 `dnf info` 명령을 사용하여 패키지가 올바르게 설치되었는지 확인할 수 있습니다.

```bash
dnf info epel-release
Last metadata expiration check: 1:30:29 ago on Thu 24 Mar 2022 09:36:42 AM CET.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 14.el8
Architecture : noarch
Size         : 32 k
Source       : epel-release-8-14.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux
             : (EPEL) repository GPG key as well as configuration for yum.
```

위의 패키지 설명에서 볼 수 있듯이 패키지에는 실행 파일, 라이브러리 등이 포함되어 있지 않고 리포지토리 설정을 위한 구성 파일과 GPG 키만 포함되어 있습니다.

올바른 설치를 확인하는 또 다른 방법은 rpm 데이터베이스를 쿼리하는 것입니다.

```bash
rpm -qa | grep epel
epel-release-8-14.el8.noarch
```

이제 `dnf`가 리포지토리를 인식하도록 업데이트를 실행해야 합니다. 리포지토리의 GPG 키를 수락하라는 메시지가 표시됩니다. 확실히 사용하려면 YES라고 대답해야 합니다.

```bash
dnf update
```

업데이트가 완료되면 이제 새 저장소를 나열해야 하는 `dnf repolist` 명령을 사용하여 저장소가 올바르게 구성되었는지 확인할 수 있습니다.

```bash
dnf repolist
repo id            repo name
...
epel               Extra Packages for Enterprise Linux 8 - aarch64
epel-modular       Extra Packages for Enterprise Linux Modular 8 - aarch64
...
```

리포지토리 구성 파일은 `/etc/yum.repos.d/`에 있습니다.

```
ll /etc/yum.repos.d/ | grep epel
-rw-r--r--. 1 root root 1485 Jan 31 17:19 epel-modular.repo
-rw-r--r--. 1 root root 1422 Jan 31 17:19 epel.repo
-rw-r--r--. 1 root root 1584 Jan 31 17:19 epel-testing-modular.repo
-rw-r--r--. 1 root root 1521 Jan 31 17:19 epel-testing.repo
```

그리고 아래에서 `epel.repo` 파일의 내용을 볼 수 있습니다.

```bash
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Debug
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place it's address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1
```

### EPEL 사용

이 시점에서 일단 구성되면 EPEL에서 패키지를 설치할 준비가 된 것입니다. 시작하려면 다음 명령을 사용하여 리포지토리에서 사용 가능한 패키지를 나열할 수 있습니다.

```bash
dnf --disablerepo="*" --enablerepo="epel" list available
```

그리고 그 명령의 발췌문은 아래와 같습니다.

```bash
dnf --disablerepo="*" --enablerepo="epel" list available | less
Last metadata expiration check: 1:58:22 ago on Fri 25 Mar 2022 09:23:29 AM CET.
Available Packages
3proxy.aarch64                                                    0.8.13-1.el8                                    epel
AMF-devel.noarch                                                  1.4.23-2.el8                                    epel
AMF-samples.noarch                                                1.4.23-2.el8                                    epel
AusweisApp2.aarch64                                               1.22.3-1.el8                                    epel
AusweisApp2-data.noarch                                           1.22.3-1.el8                                    epel
AusweisApp2-doc.noarch                                            1.22.3-1.el8                                    epel
BackupPC.aarch64                                                  4.4.0-1.el8                                     epel
BackupPC-XS.aarch64                                               0.62-1.el8                                      epel
BibTool.aarch64                                                   2.68-1.el8                                      epel
CCfits.aarch64                                                    2.5-14.el8                                      epel
CCfits-devel.aarch64                                              2.5-14.el8                                      epel
...
```

명령을 통해 EPEL에서 설치하려면 **dnf**가 옵션 `--disablerepo` 및 `--enablerepo`를 사용하여 요청된 리포지토리를 쿼리하도록 강제해야 함을 알 수 있습니다. 그렇지 않으면 다른 선택적 리포지토리(RPM Fusion, REMI, ELRepo 등)에서 찾은 일치 항목이 더 최신이므로 우선 순위를 가질 수 있기 때문입니다. 리포지토리의 패키지는 공식 패키지에서 사용할 수 없기 때문에 선택적 리포지토리로 EPEL만 설치한 경우에는 이러한 옵션이 필요하지 않습니다. 적어도 같은 버전에서는 그렇습니다!

!!! 관심 "지원 고려"

    지원(업데이트, 버그 수정, 보안 패치)과 관련하여 고려해야 할 한 가지 측면은 EPEL 패키지가 RHEL의 공식 지원을 받지 않으며 기술적으로 수명이 Fedora 개발 공간(6개월) 동안 지속된 다음 사라질 수 있다는 것입니다. 이것은 희박한 가능성이지만 고려해야 할 사항입니다.

따라서 EPEL 리포지토리에서 패키지를 설치하려면 다음을 사용해야합니다.

```bash
dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 2:01:36 ago on Fri 25 Mar 2022 04:28:04 PM CET.
Dependencies resolved.
==============================================================================================================================================================
 Package                            Architecture                          Version                                    Repository                          Size
==============================================================================================================================================================
Installing:
 nmon                               aarch64                               16m-1.el8                                  epel                                71 k

Transaction Summary
==============================================================================================================================================================
Install  1 Package

Total download size: 71 k
Installed size: 214 k
Is this ok [y/N]:
```

### 결론

EPEL은 RHEL의 공식 리포지토리는 아니지만 RHEL 또는 파생 제품으로 작업하고 신뢰할 수 있는 소스에서 RHEL용으로 준비된 일부 유틸리티가 필요한 관리자 및 개발자에게 유용할 수 있습니다.

## DNF 플러그인

`dnf-plugins-core` 패키지는 리포지토리 관리에 유용한 플러그인을 `dnf`에 추가합니다.

!!! 참고사항

    여기에서 더 많은 정보를 확인하세요: https://dnf-plugins-core.readthedocs.io/en/latest/index.html

시스템에 패키지를 설치합니다.

```
dnf install dnf-plugins-core
```

모든 플러그인이 여기에 표시되는 것은 아니지만 전체 플러그인 목록 및 자세한 정보는 패키지 문서를 참조할 수 있습니다.

### `config-manager` 플러그인

DNF 옵션을 관리하거나 리포지토리를 추가하거나 비활성화합니다.

예시:

* `.repo` 파일을 다운로드하여 사용하십시오.

```
dnf config-manager --add-repo https://packages._centreon_.com/rpm-standard/23.04/el8/_centreon_.repo
```

* URL을 저장소의 기본 URL로 설정할 수도 있습니다.

```
dnf config-manager --add-repo https://repo.rocky.lan/repo
```

* 하나 이상의 저장소를 활성화 또는 비활성화합니다.

```
dnf config-manager --set-enabled epel centreon
dnf config-manager --set-disabled epel centreon
```

* 구성 파일에 프록시를 추가합니다.

```
dnf config-manager --save --setopt=*.proxy=http://proxy.rocky.lan:3128/
```

### `copr` plugin

`corp`는 빌드된 패키지가 있는 저장소를 제공하는 자동 rpm 포지입니다.

* copr repo를 활성화합니다:

```
copr enable xxxx
```

### `download` 플러그인

설치하는 대신 rpm 패키지를 다운로드합니다.

```
dnf download ansible
```

패키지의 원격 위치 URL을 얻으려는 경우:

```
dnf download --url ansible
```

또는 종속성도 다운로드하려는 경우:

```
dnf download --resolv --alldeps ansible
```

### `needs-restarting` 플러그인

`dnf 업데이트`를 실행한 후 실행 중인 프로세스는 계속 실행되지만 이전 바이너리를 사용합니다. 코드 변경 사항과 특히 보안 업데이트를 고려하려면 다시 시작해야 합니다.

`needs-restarting` 플러그인을 사용하면 이 경우 프로세스를 감지할 수 있습니다.

```
dnf needs-restarting [-u] [-r] [-s]
```

| 옵션      | 설명                           |
| ------- | ---------------------------- |
| `-u`    | 실행 중인 사용자에게 속한 프로세스만 고려하십시오. |
| `-r`    | 재부팅이 필요한지 확인하십시오.            |
| `-s`    | 서비스를 다시 시작해야 하는지 확인합니다.      |
| `-s -r` | 한 번에 둘 다 할 수 있습니다.           |

### `versionlock` 플러그인

모경우에 따라 모든 업데이트로부터 패키지를 보호하거나 패키지의 특정 버전을 제외하는 것이 유용합니다(예: 알려진 문제로 인해). 이를 위해 versionlock 플러그인이 큰 도움이 될 것입니다.

추가 패키지를 설치해야 합니다.

```
dnf install python3-dnf-plugin-versionlock
```

예시:

* ansible 버전을 잠급니다.

```
dnf versionlock add ansible
Adding versionlock on: ansible-0:6.3.0-2.el9.*
```

* 잠긴 패키지 나열:

```
dnf versionlock list
ansible-0:6.3.0-2.el9.*
```
