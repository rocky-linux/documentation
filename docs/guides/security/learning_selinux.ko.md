---
title: SELinux 보안
author: Antoine Le Morvan
contributors: Steven Spencer, markooff
tags:
  - security
  - SELinux
---

# SELinux 보안

2.6 버전의 커널이 도입되면서, 액세스 제어 보안 정책을 지원하기 위한 보안 메커니즘이 도입되었습니다.

이 시스템은 **SELinux**(**S**ecurity **E**nhanced **Linux** - 보안 강화 리눅스)라고 하며 Linux 커널 하위 시스템에서 강력한 **M**andatory **A**ccess **C**ontrol(**MAC** - 의무적 액세스 제어) 아키텍처를 구현하기 위해 **NSA** (**N**ational **S**ecurity **A**gency - 국가안보국) 에서 만들었습니다.

지금까지 SELinux를 비활성화하거나 무시한 적이 있다면 이 문서를 통해 이 시스템에 대한 좋은 소개를 얻을 수 있을 것입니다. SELinux는 프로그램 또는 데몬의 위험성을 제거하거나 권한을 제한하여 프로그램이 불법적으로 접근하는 것을 방지합니다.

시작하기 전에 SELinux는 주로 RHEL 배포판을 위해 설계되었음을 알아두시기 바랍니다. 하지만 Debian과 같은 다른 배포판에도 구현할 수 있습니다(그러나 행운을 빕니다!). Debian 패밀리 배포판은 일반적으로 SELinux와는 다른 방식으로 작동하는 AppArmor 시스템을 통합합니다.

## 개요

**SELinux**(Security Enhanced Linux)는 의무적 액세스 제어 시스템입니다.

MAC 시스템이 등장하기 전에 표준 액세스 관리 보안은 **DAC** (**D**iscretionary **A**ccess **C**ontrol - 임시 접근 제어) 시스템을 기반으로 했습니다. **UID** 또는 **SUID**(**S**et **O**wner **U**ser **I**d - 소유자 사용자 ID 설정) 권한으로 작동하여 이 사용자에 따라 권한(파일, 소켓, 다른 프로세스 등)을 평가할 수 있도록 했습니다. 이 작업은 프로그램이 손상될 경우 프로그램의 권한을 충분히 제한하지 않으며, 잠재적으로 운영 체제의 서브시스템에 액세스할 수 있게 합니다.

MAC 시스템은 기밀성과 무결성 정보를 분리하여 격리 시스템을 구현하기 위해 시스템 내에서 독립적으로 작동합니다. 격리 시스템은 기존의 권한 시스템과 독립적이며 슈퍼 사용자(superuser) 개념이 없습니다.

각 시스템 호출마다 커널은 해당 작업을 수행할 수 있는지 여부를 SELinux에 쿼리합니다.

![SELinux](../images/selinux_001.png)

SELinux는 이를 위해 일련의 규칙(정책)을 사용합니다. 두 개의 표준 규칙 세트(**targeted** 및 **strict**) 세트가 제공되며, 각 응용 프로그램은 일반적으로 자체 규칙을 제공합니다.

### SELinux 컨텍스트

SELinux의 작동 방식은 기존의 Unix 권한과는 완전히 다릅니다.

SELinux 보안 컨텍스트는 **identity**+**role**+**domain** 세트로 정의됩니다.

사용자의 신분(identity)은 직접적으로 그의 Linux 계정에 따라 결정됩니다. 아이덴티티는 하나 이상의 역할에 할당되지만, 각 역할에는 하나의 도메인만 해당합니다.

보안 컨텍스트의 도메인(따라서 역할)에 따라 사용자의 자원에 대한 권한이 평가됩니다.

![SELinux context](../images/selinux_002.png)

"도메인"과 "타입"이라는 용어는 유사합니다. 일반적으로 "도메인"은 프로세스를 참조할 때 사용되고, "타입"은 객체를 참조할 때 사용됩니다.

이름 지정 규칙은 다음과 같습니다: **user_u:role_r:type_t**

보안 컨텍스트는 사용자가 연결될 때 사용자의 역할에 따라 할당됩니다. 파일의 SELinux 컨텍스트는 이후에 설명할 `chcon`(**ch**ange **con**text - 컨텍스트 변경) 명령에 의해 정의됩니다.

다음은 SELinux 퍼즐의 일부를 고려해야 할 사항들입니다:

* 주제
* 개체
* 정책
* 모드

주체(예를 들어 응용 프로그램)가 객체(예를 들어 파일)에 접근하려고 할 때, 리눅스 커널의 SELinux 부분은 정책 데이터베이스를 쿼리합니다. 작동 모드에 따라 성공 시 객체에 대한 접근을 승인하고, 그렇지 않은 경우 실패를 `/var/log/messages` 파일에 기록합니다.

#### 표준 프로세스의 SELinux 컨텍스트

프로세스의 권한은 보안 컨텍스트에 따라 결정됩니다.

기본적으로 프로세스의 보안 컨텍스트는 해당 프로세스를 시작하는 사용자(아이덴티티+롤+도메인)의 컨텍스트에 의해 정의됩니다.

도메인은 특정 유형(SELinux에서)과 연결된 프로세스에 종속되며 (보통) 시작한 사용자로부터 상속됩니다. 따라서 해당 도메인의 권한은 객체에 연결된 유형에 대해 승인 또는 거부로 표현됩니다:

컨텍스트에 보안 __domain D__ 가 있는 프로세스는 __type T__ 의 개체에 접근할 수 있습니다.

![표준 프로세스의 SELinux 컨텍스트](../images/selinux_003.png)

#### 중요한 프로세스의 SELinux 컨텍스트

중요한 프로그램들은 각각 전용 도메인에 할당됩니다.

각 실행 파일에는 연결된 프로세스를 (**user_t** 대신) **sshd_t** 컨텍스트로 자동 전환하는 전용 유형(여기서는 **sshd_exec_t**)으로 태그가 지정됩니다.

이 메커니즘은 프로세스의 권한을 가능한 한 제한하는 데 중요합니다.

![중요한 프로세스의 SELinux 컨텍스트 - sshd의 예](../images/selinux_004.png)

## 관리

`semanage` 명령은 SELinux 규칙을 관리하는 데 사용됩니다.

```
semanage [object_type] [options]
```

예시:

```
$ semanage boolean -l
```

| 옵션 | 관찰    |
| -- | ----- |
| -a | 개체 추가 |
| -d | 개체 삭제 |
| -m | 개체 수정 |
| -l | 개체 목록 |

Rocky Linux에서는 `semanage` 명령이 기본적으로 설치되지 않을 수 있습니다.

이 명령을 제공하는 패키지를 모르는 경우 다음 명령으로 패키지 이름을 찾아볼 수 있습니다:

```
dnf provides */semanage
```

그런 다음 설치하십시오.

```
sudo dnf install policycoreutils-python-utils
```

### 부울 객체 관리

부울은 프로세스의 격리를 허용합니다.

```
semanage boolean [options]
```

사용 가능한 부울 목록을 표시하려면:

```
semanage boolean –l
SELinux boolean    State Default  Description
…
httpd_can_sendmail (off , off)  Allow httpd to send mail
…
```

!!! 참고 사항

    시작 시 `default` 상태와 실행 중인 상태가 있습니다.

`setsebool` 명령은 부울 객체의 상태를 변경하는 데 사용됩니다:

```
setsebool [-PV] boolean on|off
```

예시:

```
sudo setsebool -P httpd_can_sendmail on
```

| 옵션   | 관찰                         |
| ---- | -------------------------- |
| `-P` | 시작할 때 기본값 변경 (재부팅 후까지 지속됨) |
| `-V` | 객체 삭제                      |

!!! 주의

    다음 시작 시 상태를 유지하기 위해 `-P` 옵션을 잊지 마십시오.

### 포트 개체 관리

포트 타입의 객체를 관리하기 위해 `semanage` 명령을 사용합니다:

```
semanage port [options]
```

예: httpd 도메인 프로세스에 대해 포트 81 허용

```
sudo semanage port -a -t http_port_t -p tcp 81
```

## 작동 모드

SELinux에는 세 가지 작동 모드가 있습니다:

* Enforcing (시행)

Rocky Linux의 기본 모드입니다. 적용된 규칙에 따라 액세스가 제한됩니다.

* Permissive (허용)

규칙은 감시되며, 액세스 오류는 기록되지만 액세스는 차단되지 않습니다.

* Disabled (사용불가)

제한되는 사항 없이 모든 것이 허용되며, 아무것도 기록되지 않습니다.

대부분의 운영 체제는 SELinux를 Enforcing 모드로 구성되어 있습니다.

`getenforce` 명령은 현재 작동 모드를 반환합니다.

```
getenforce
```

예시:

```
$ getenforce
Enforcing
```

`sestatus` 명령은 SELinux에 대한 정보를 반환합니다.

```
sestatus
```

예시:

```
$ sestatus
SELinux status:                enabled
SELinuxfs mount:                 /sys/fs/selinux
SELinux root directory:    /etc/selinux
Loaded policy name:        targeted
Current mode:                enforcing
Mode from config file:     enforcing
...
Max kernel policy version: 33
```

`setenforce` 명령은 현재 작동 모드를 변경합니다.

```
setenforce 0|1
```

SELinux를 permissive 모드로 전환하려면:

```
sudo setenforce 0
```

### `/etc/sysconfig/selinux` 파일

`/etc/sysconfig/selinux` 파일을 통해 SELinux의 작동 모드를 변경할 수 있습니다.

!!! 주의

    SELinux를 비활성화하는 것은 자체 책임하에 수행되어야 합니다! SELinux 작동 방식을 배우는 것이 무작위로 비활성화하는 것보다 좋습니다!

`/etc/sysconfig/selinux` 파일 편집

```
SELINUX=disabled
```

!!! 참고 사항

    `/etc/sysconfig/selinux`는 `/etc/selinux/config`에 대한 심볼릭 링크입니다.

시스템을 재부팅합니다.

```
sudo reboot
```

!!! 주의

    SELinux 모드 변경에 주의하십시오!

허용 또는 비활성화 모드에서 새로 생성된 파일에는 레이블이 없습니다.

SELinux를 다시 활성화하려면 전체 시스템에서 레이블의 위치를 변경해야 합니다.

전체 시스템에 레이블 지정:

```
sudo touch /.autorelabel
sudo reboot
```

## 정책 유형

SELinux는 두 가지 표준 유형의 규칙을 제공합니다.

* **대상 지정됨**: 네트워크 데몬만 보호됩니다(`dhcpd`, `httpd`, `named`, `nscd`, `ntpd`, `portmap`, `snmpd`, `squid` 및 `syslogd`).
* **Strict**: 모든 데몬이 보호됨

## 문맥

보안 컨텍스트의 표시는 `-Z` 옵션과 관련하여 다음과 같은 명령과 함께 사용됩니다: 많은 명령과 연결되어 있습니다.

예시:

```
id -Z   # 사용자의 컨텍스트
ls -Z   # 현재 파일의 컨텍스트
ps -eZ  #  프로세스의 컨텍스트
netstat –Z # 네트워크 연결에 대한 컨텍스트
lsof -Z # 열린 파일에 대한 컨텍스트
```

`matchpathcon` 명령은 디렉토리의 컨텍스트를 반환합니다.

```
matchpathcon directory
```

예시:

```
sudo matchpathcon /root
 /root  system_u:object_r:admin_home_t:s0

sudo matchpathcon /
 /      system_u:object_r:root_t:s0
```

`chcon` 명령은 보안 컨텍스트를 수정합니다.

```
chcon [-vR] [-u USER] [–r ROLE] [-t TYPE] file
```

예시:

```
sudo chcon -vR -t httpd_sys_content_t /data/websites/
```

| 옵션             | 설명                |
| -------------- | ----------------- |
| `-v`           | 상세 모드로 전환         |
| `-R`           | 재귀 적용             |
| `-u`,`-r`,`-t` | 사용자, 역할 또는 유형에 적용 |

`restorecon` 명령은 기본 보안 컨텍스트(규칙에서 제공하는 컨텍스트)를 복원합니다.

```
restorecon [-vR] directory
```

예시:

```
sudo restorecon -vR /home/
```

| 옵션   | 설명        |
| ---- | --------- |
| `-v` | 상세 모드로 전환 |
| `-R` | 재귀 적용     |

`restorecon`을 통해 컨텍스트 변경을 유지하려면 `semanage fcontext` 명령으로 기본 파일 컨텍스트를 수정해야 합니다:

```
semanage fcontext -a options file
```

!!! 참고 사항

    시스템에 표준이 아닌 폴더에 대한 컨텍스트 전환을 수행하는 경우 룰을 만든 다음 컨텍스트를 적용하는 것이 좋은 관행입니다. 아래 예시와 같이 진행하세요!

예시:

```
$ sudo semanage fcontext -a -t httpd_sys_content_t "/data/websites(/.*)?"
$ sudo restorecon -vR /data/websites/
```

## `audit2why` 명령

`audit2why` 명령은 SELinux 거부의 원인을 나타냅니다.

```
audit2why [-vw]
```

SELinux가 마지막으로 거부한 원인을 가져오는 예:

```
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2why
```

| 옵션   | 설명                                      |
| ---- | --------------------------------------- |
| `-v` | 상세 모드로 전환                               |
| `-w` | SELinux에 의한 거부의 원인을 번역하고 해결책을 제시(기본 옵션) |

### SELinux로 더 나아가기

`audit2allow` 명령은 "audit" 파일의 라인으로부터 SELinux 작업을 허용하는 모듈을 만듭니다(모듈이 존재하지 않는 경우):

```
audit2allow [-mM]
```

예시:

```
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2allow -M mylocalmodule
```

| 옵션   | 설명                        |
| ---- | ------------------------- |
| `-m` | 모듈을 생성 (`*.te`)           |
| `-M` | 모듈 생성, 컴파일 및 패키징 (`*.pp`) |

#### 구성 예

명령을 실행하면 시스템은 명령 프롬프트를 반환하지만 기대한 결과가 화면에 표시되지 않습니다.

* **1단계**: log 파일을 읽습니다. 우리가 관심 있는 메시지 유형은 AVC(SELinux)이며 거부(denied)된 가장 최근 메시지(즉, 마지막 메시지)입니다.

```
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1
```

메시지가 올바르게 분리되었지만 도움이 되지 않습니다.

* **2단계**: `audit2why` 명령으로 분리된 메시지를 읽어 우리의 문제에 대해 더 명확한 메시지를 얻습니다(일반적으로 설정할 부울이 포함됩니다).

```
sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2why
```

두 가지 경우가 있습니다: 컨텍스트를 설정하거나 부울을 채우는 것이거나, 자체 컨텍스트를 만들기 위해 단계 3으로 이동해야 합니다.

* **3단계**: 자신만의 모듈을 만듭니다.

```
$ sudo cat /var/log/audit/audit.log | grep AVC | grep denied | tail -1 | audit2allow -M mylocalmodule
Generating type enforcement: mylocalmodule.te
Compiling policy: checkmodule -M -m -o mylocalmodule.mod mylocalmodule.te
Building package: semodule_package -o mylocalmodule.pp -m mylocalmodule.mod

$ sudo semodule -i mylocalmodule.pp
```
