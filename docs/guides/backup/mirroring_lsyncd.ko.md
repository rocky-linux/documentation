---
title: 미러링 솔루션 - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - synchronization
  - mirroring
---

# 미러링 솔루션 - `lsyncd`

## 필요 사항

이 가이드를 이해하고 따라야 할 내용은 다음과 같습니다:

* Rocky Linux가 설치된 컴퓨터.
* 명령줄에서 구성 파일을 수정하는 편안함 수준
* 명령줄 편집기 사용 방법에 대한 지식(여기에서는 vi를 사용하지만 선호하는 편집기를 사용할 수 있음)
* root 액세스가 필요하며 이상적으로는 터미널에서 root 사용자로 로그인해야 합니다.
* 퍼블릭 및 프라이빗 SSH 키 쌍
* Fedora의 EPEL 저장소
* 이벤트 모니터 인터페이스인 *inotify*에 익숙해야 합니다.
* 선택 사항: *tail*에 익숙함

## 소개

컴퓨터 간에 파일과 폴더를 자동으로 동기화하는 방법을 찾고 있다면 `lsyncd`가 매우 훌륭한 옵션입니다. 초보자를위한 유일한 단점은 무엇입니까? 명령줄과 텍스트 파일에서 모든 것을 구성해야 합니다.

그럼에도 불구하고 모든 시스템 관리자에게 배울 가치가 있는 프로그램입니다.

`lsyncd`에 대한 가장 좋은 설명은 자체 매뉴얼 페이지에서 나옵니다. 약간 다르게 표현하면 `lsyncd`는 설치가 어렵지 않은 가벼운 라이브 미러 솔루션입니다. 새로운 파일 시스템이나 블록 장치가 필요하지 않으며 로컬 파일 시스템 성능을 방해하지 않습니다. 즉, 파일을 미러링합니다.

`lsyncd`는 로컬 디렉토리 트리의 이벤트 모니터 인터페이스(inotify)를 감시합니다. 몇 초 동안 이벤트를 집계하고 결합한 다음 하나 이상의 프로세스를 생성하여 변경 사항을 동기화합니다. 기본적으로 이것은 `rsync`입니다.

이 가이드의 목적에 따라 원본 파일이 있는 시스템을 "source"라고 하고 동기화할 파일을 "target"이라고 합니다. 실제로 동기화하려는 디렉토리와 파일을 매우 신중하게 지정하여 `lsyncd`를 사용하여 서버를 완전히 미러링하는 것이 가능합니다. 꽤 달콤합니다!

원격 동기화를 위해 [Rocky Linux SSH 퍼블릭 프라이빗 키 쌍](../security/ssh_public_private_keys.md)도 설정해야 합니다. 여기의 예에서는 SSH(포트 22)를 사용합니다.

## `lsyncd` 설치

실제로 `lsyncd`를 설치하는 두 가지 방법이 있습니다. 여기에 둘 다 포함하겠습니다. RPM은 소스 패키지보다 약간 뒤처지는 경향이 있지만 약간만 뒤쳐집니다. 이 글을 쓰는 시점에 RPM 방식으로 설치된 버전은 2.2.2-9인데 소스코드 버전은 현재 2.2.3이다. 즉, 두 가지 옵션을 모두 제공하고 선택할 수 있도록 합니다.

## `lsyncd` 설치 - RPM 방법

RPM 버전 설치는 어렵지 않습니다. 먼저 설치해야 하는 유일한 것은 Fedora의 EPEL 소프트웨어 리포지토리입니다. 이는 단일 명령으로 수행할 수 있습니다.

`dnf install -y epel-release`

그런 다음 `lsyncd`를 설치하기만 하면 누락된 종속성이 함께 설치됩니다.

`dnf install lsyncd`

부팅 시 시작되도록 서비스를 설정하되 아직 시작하지는 마십시오.

`systemctl enable lsyncd`

이게 다입니다!

## `lsyncd` 설치 - 소스 방법

소스에서 설치하는 것은 들리는 것처럼 나쁘지 않습니다. 이 가이드를 따르기만 하면 바로 시작할 수 있습니다!

### 종속성 설치

몇 가지 종속성이 필요합니다. `lsyncd` 자체에 필요한 몇 가지와 소스에서 패키지를 빌드하는 데 필요한 몇 가지가 있습니다. Rocky Linux 컴퓨터에서 이 명령을 사용하여 필요한 종속성이 있는지 확인하십시오. 소스에서 빌드하려는 경우 모든 개발 도구를 설치하는 것이 좋습니다.

`dnf groupinstall 'Development Tools'`

!!! "Rocky Linux 9.0의 경우" 경고

    `lsyncd`는 Rocky Linux 9.0에서 완전히 테스트되었으며 예상대로 작동합니다. 그러나 필요한 종속성을 모두 설치하려면 추가 리포지토리를 활성화해야 합니다.

    ```
    dnf config-manager --enable crb
    ```


    다음 단계 전에 9에서 이 작업을 수행하면 백트래킹 없이 빌드를 완료할 수 있습니다.

다음은 `lsyncd` 자체와 해당 빌드 프로세스에 필요한 종속성입니다.

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### `lsyncd` 다운로드 및 빌드

다음으로 소스 코드가 필요합니다.

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

이제 master.zip 파일의 압축을 풉니다.

`unzip master.zip`

그러면 "lsyncd-master"라는 디렉토리가 생성됩니다. 이 디렉토리로 변경하고 build라는 디렉토리를 생성해야 합니다.

`cd lsyncd-master`

그 다음

`mkdir build`

이제 빌드 디렉토리에 있도록 디렉토리를 다시 변경하십시오.

`cd build`

그리고 다음 명령을 실행합니다:

```
cmake ..
make
make install
```

완료되면 `lsyncd` 바이너리가 설치되고 */usr/local/bin*에서 사용할 준비가 됩니다.

### `lsyncd` 시스템 서비스

RPM 설치 방법을 사용하면 systemd 서비스가 자동으로 설치되지만 소스에서 설치하도록 선택한 경우 systemd 서비스를 생성해야 합니다. systemd 서비스 없이 바이너리를 시작할 수 있지만 부팅 시 *시작*하는지 확인하고자 합니다. 그렇지 않은 경우 서버 재부팅으로 인해 동기화 작업이 중단되고 다시 시작하는 것을 잊은 경우 그럴 가능성이 높습니다. 이는 모든 시스템 관리자에게 매우 당혹스러운 일이 될 수 있습니다!

그러나 systemd 서비스를 만드는 것은 그리 어렵지 않으며 장기적으로 시간을 절약할 수 있습니다.

#### `lsyncd` 서비스 파일 생성

이 파일은 서버의 루트 디렉터리를 비롯한 모든 위치에서 만들 수 있습니다. 생성되면 올바른 위치로 이동할 수 있습니다.

`vi /root/lsyncd.service`

이 파일의 내용은 다음과 같아야 합니다.

```
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```
이제 방금 만든 파일을 올바른 위치에 설치해 보겠습니다.

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

마지막으로 systemd가 새 서비스 파일을 "볼" 수 있도록 `systemctl` 데몬을 다시 로드합니다.

`systemctl daemon-reload`

## `lsyncd` 구성

`lsyncd`를 설치하기 위해 어떤 방법을 선택하든 */etc/lsyncd.conf* 구성 파일이 필요합니다. 다음 섹션에서는 구성 파일을 빌드하고 테스트하는 방법을 설명합니다.

## 테스트를 위한 샘플 구성

다음은 */home*을 다른 컴퓨터와 동기화하는 단순한 구성 파일의 예입니다. 대상 컴퓨터는 로컬 IP 주소가 됩니다: *192.168.1.40*

```
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home",
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

이 파일을 조금 분해하면 다음과 같습니다.

* "logfile" 및 "statusFile"은 서비스 시작 시 자동으로 생성됩니다.
* "statusInterval"은 statusFile에 쓰기 전에 대기하는 시간(초)입니다.
* "maxProcesses"는 `lsyncd`가 생성할 수 있는 프로세스 수입니다. 솔직히, 매우 바쁜 컴퓨터에서 이것을 실행하지 않는 한 프로세스 1개면 충분합니다.
* 동기화 섹션에서 "default.rsyncssh"는 SSH를 통해 rsync를 사용하라고 말합니다.
* "source="는 동기화할 디렉터리 경로입니다.
* "host="는 동기화할 대상 컴퓨터입니다.
* "excludeFrom="은 `lsyncd`에 제외 파일이 있는 위치를 알려줍니다. 존재해야 하지만 비어 있을 수 있습니다.
* "targetdir="은 파일을 보내는 대상 디렉토리입니다. 대부분의 경우 이것은 소스와 같지만 항상 그런 것은 아닙니다.
* 그런 다음 "rsync =" 섹션이 있으며 rsync를 실행하는 옵션입니다.
* 마지막으로 "ssh =" 섹션이 있으며 대상 컴퓨터에서 수신 대기 중인 SSH 포트를 지정합니다.

동기화할 디렉터리를 두 개 이상 추가하는 경우 각 디렉터리에 대한 여는 괄호와 닫는 괄호를 모두 포함하는 전체 "동기화" 섹션을 반복해야 합니다.

## lsyncd.exclude 파일

앞서 언급했듯이 "excludeFrom" 파일이 있어야 하므로 지금 생성해 보겠습니다.

`touch /etc/lsyncd.exclude`

컴퓨터의 /etc 폴더를 동기화하는 경우 제외해야 할 파일과 디렉터리가 많을 것입니다. 제외된 각 파일 또는 디렉터리는 다음과 같이 한 줄에 하나씩 파일에 나열됩니다.

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## 테스트하고 턴업

이제 다른 모든 것이 설정되었으므로 모두 테스트할 수 있습니다. 먼저 systemd lsyncd.service가 시작되는지 확인합니다.

`systemctl start lsyncd`

이 명령을 실행한 후 오류가 표시되지 않으면 서비스 상태를 확인하여 다음을 확인하십시오.

`systemctl status lsyncd`

실행 중인 서비스가 표시되면 tail을 사용하여 두 로그 파일의 끝을 보고 모든 것이 정상으로 표시되는지 확인합니다.

`tail /var/log/lsyncd.log`

그 다음

`tail /var/log/lsyncd-status.log`

이 모든 것이 올바르다고 가정하고 `/home/[user]` 디렉토리로 이동합니다. 여기서 `[user]`는 컴퓨터의 사용자이고 *touch*하세요.

`touch /home/[user]/testfile`

이제 대상 컴퓨터로 이동하여 파일이 나타나는지 확인하십시오. 그렇다면 모든 것이 제대로 작동하는 것입니다. 다음을 사용하여 부팅 시 시작하도록 lsyncd.service를 설정합니다.

`systemctl enable lsyncd`

이제 갈 준비가 되었습니다.

## 조심해야 함을 기억하십시오

파일 또는 디렉터리 집합을 다른 컴퓨터와 동기화할 때마다 대상 컴퓨터에 미칠 영향에 대해 신중하게 생각하십시오. 위의 예에서 **lsyncd.exclude 파일**로 돌아가면 */etc/fstab * 동기화되었습니까?

초보자의 경우 *fstab*은 모든 Linux 컴퓨터에서 스토리지 드라이브를 구성하는 데 사용되는 파일입니다. 디스크와 레이블은 거의 확실하게 다릅니다. 다음에 대상 컴퓨터를 재부팅하면 완전히 부팅되지 않을 수 있습니다.

# 결론 및 참조

`lsyncd`는 컴퓨터 간의 디렉터리 동기화를 위한 강력한 도구입니다. 보시다시피 설치가 어렵지 않고 앞으로 유지 관리가 복잡하지 않습니다. 그 이상을 요구할 수 없습니다.

더 많은 정보는 [공식 사이트](https://github.com/axkibe/lsyncd)로 이동하여 `lsyncd`에 대해 자세히 알아볼 수 있습니다.
