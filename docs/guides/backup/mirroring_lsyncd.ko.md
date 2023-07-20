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
* 명령 줄에서 구성 파일을 수정하는 데 익숙함
* 명령 줄 편집기 사용 방법을 알고 있어야 합니다(vi를 사용하지만 좋아하는 편집기를 사용할 수도 있습니다.)
* root 액세스가 필요하며, 이상적으로 터미널에서 root 사용자로 로그인되어 있어야 합니다.
* 퍼블릭 및 프라이빗 SSH 키 쌍
* Fedora의 EPEL 저장소
* 이벤트 모니터 인터페이스인 *inotify*에 대한 이해가 필요합니다.
* 선택 사항: *tail*에 대한 이해도

## 소개

자동으로 컴퓨터 간에 파일과 폴더를 동기화할 방법을 찾고 있다면, `lsyncd`는 꽤 훌륭한 선택입니다. 초보자를위한 유일한 단점은 무엇입니까? 초심자에게는 유일한 단점은 모든 것을 명령 줄과 텍스트 파일로 구성해야 한다는 것입니다.

그래도 모든 시스템 관리자에게 가치있는 프로그램입니다.

`lsyncd`에 대한 가장 좋은 설명은 그 자체 매뉴얼 페이지에서 나온 것입니다. 약간 의역하면, `lsyncd`는 가볍고, 설치가 어렵지 않은 라이브 미러 솔루션입니다. 새 파일 시스템이나 블록 장치를 요구하지 않으며, 로컬 파일 시스템 성능에 영향을 미치지 않습니다. 간단히 말해, 파일을 동기화합니다.

`lsyncd`는 로컬 디렉토리 트리의 이벤트 모니터 인터페이스(inotify)를 감시합니다. 몇 초 동안 이벤트를 집계하고 결합한 다음 변경 사항을 동기화하는 하나(또는 그 이상)의 프로세스를 생성합니다. 기본적으로 `rsync`를 사용합니다.

이 가이드에서는 원본 파일이 있는 시스템을 "source"라고 하고, 동기화할 대상 시스템을 "타겟"이라고 합니다. 사실 `lsyncd`를 사용하여 서버를 완전히 미러링하는 것도 가능합니다. 이 경우 동기화하려는 디렉토리와 파일을 매우 주의해서 지정하는 것이 가능합니다. 정말 멋지죠!

원격 동기화를 위해 [Rocky Linux SSH 퍼블릭 프라이빗 키 쌍](../security/ssh_public_private_keys.md)도 설정해야 합니다. 여기의 예제는 SSH(포트 22)를 사용합니다.

## `lsyncd` 설치

`lsyncd`를 설치하는 두 가지 방법이 있습니다. 두 가지 모두 여기에 포함시켜놨습니다. RPM 버전은 일부 차이가 있지만, 그 차이는 약간 뿐입니다. 이 글을 작성하는 시점에서 RPM 방법으로 설치한 버전은 2.2.2-9이고, 소스 코드 버전은 이제 2.2.3입니다. 그럼에도 불구하고 두 가지 옵션을 제공하고 선택하게 해드리겠습니다.

## `lsyncd` 설치 - RPM 방법

RPM 버전 설치는 어렵지 않습니다. 우선 Fedora의 EPEL 소프트웨어 저장소를 먼저 설치해야 합니다. 다음 명령으로 설치할 수 있습니다.

`dnf install -y epel-release`

그런 다음 `lsyncd`를 설치하면 빠진 종속성이 모두 함께 설치됩니다.

`dnf install lsyncd`

서비스를 부팅 시 자동 시작되도록 설정하지만 아직 시작하지 않습니다.

`systemctl enable lsyncd`

이게 다입니다!

## `lsyncd` 설치 - 소스 방법

소스로부터 설치하는 것이 듣기만하면 안 그렇게 어렵지 않습니다. 이 안내서를 따라하면 빠르게 실행할 수 있습니다!

### 종속성 설치

`lsyncd` 자체에 필요한 몇 가지와 소스에서 패키지를 빌드하는 데 필요한 몇 가지입니다. Rocky Linux 컴퓨터에서 이 명령을 사용하여 필요한 종속성이 있는지 확인하십시오. 소스에서 빌드할 계획이라면 모든 개발 도구를 설치하는 것이 좋습니다.

`dnf groupinstall 'Development Tools'`

!!! "Rocky Linux 9.0의 경우" 경고

    `lsyncd`는 Rocky Linux 9.0에서 완벽하게 테스트되었으며, 예상대로 작동합니다. 그러나 모든 필요한 종속성을 설치하려면 추가 저장소를 활성화해야 합니다.

    ```
    dnf config-manager --enable crb
    ```


    이를 9 버전의 단계 이전에 수행하면, 뒤로 돌아가지 않고 빌드를 완료할 수 있습니다.

다음은 `lsyncd` 자체와 해당 빌드 프로세스에 필요한 종속성입니다.

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### `lsyncd` 다운로드 및 빌드

다음으로 소스 코드가 필요합니다.

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

그런 다음 master.zip 파일을 압축 해제합니다.

`unzip master.zip`

이렇게 하면 "lsyncd-master"라는 디렉터리가 생성됩니다. 이 디렉터리로 이동하여 "build"라는 디렉터리를 만듭니다.

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

RPM 설치 방법을 사용하면 systemd 서비스가 자동으로 설치되지만, 소스로 설치를 선택한 경우 systemd 서비스를 생성해야 합니다. systemd 서비스 없이도 바이너리를 시작할 수 있지만, 서비스가 부팅 시 *시작*되도록 하려고 합니다. 그렇지 않으면 서버 재부팅이 동기화 작업을 중단시킬 수 있습니다. 만약 다시 시작하는 것을 잊었다면, 이는 시스템 관리자에게 문제가 될 것입니다!

systemd 서비스를 만드는 것은 그리 어렵지 않지만, 오랜 기간 동안 시간을 절약할 수 있습니다.

#### `lsyncd` 서비스 파일 생성

이 파일은 어디에서나 생성할 수 있으며, 서버의 루트 디렉터리에도 생성할 수 있습니다. 생성되면 올바른 위치로 이동시킬 수 있습니다.

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
이제 만든 파일을 올바른 위치로 설치합니다.

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

마지막으로, systemctl 데몬을 다시 로드하여 `systemd`가 새 서비스 파일을 "보게" 합니다.

`systemctl daemon-reload`

## `lsyncd` 구성

`lsyncd`를 설치하는 데 선택한 방법에 관계없이 구성 파일인 */etc/lsyncd.conf*이 필요합니다. 다음 섹션에서는 구성 파일을 작성하고 테스트하는 방법을 설명합니다.

## 테스트를 위한 예제 구성

다음은 단순한 구성 파일의 예제입니다. */home* 디렉터리를 다른 컴퓨터와 동기화할 것입니다. 대상 컴퓨터는 로컬 IP 주소인 *192.168.1.40*입니다.

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

이 파일을 살펴보겠습니다.

* "logfile" 및 "statusFile"은 서비스 시작 시 자동으로 생성됩니다.
* "statusInterval"은 statusFile에 기록하기 전에 대기하는 시간(초)입니다.
* "maxProcesses"는 `lsyncd`가 생성할 수 있는 프로세스의 최대 수입니다. 사실, 매우 바쁜 컴퓨터가 아닌 한 프로세스 1개로 충분합니다.
* 동기화 섹션에서 "default.rsyncssh"는 SSH를 통해 rsync를 사용하라고 말합니다.
* "source="는 동기화할 디렉터리 경로입니다.
* "host="는 동기화할 대상 컴퓨터입니다.
* "excludeFrom="은 `lsyncd`에게 제외 파일이 있는 위치를 알려줍니다. 이 파일은 존재해야 하지만 비어있을 수 있습니다.
* "targetdir="은 파일을 전송할 대상 디렉터리입니다. 대부분의 경우 source와 같을 것입니다만 항상 그렇지는 않습니다.
* 그런 다음 "rsync =" 섹션이 있으며 rsync를 실행에 사용되는 옵션입니다.
* 마지막으로 "ssh =" 섹션에서 대상 컴퓨터에서 수신 대기하는 SSH 포트를 지정합니다.

디렉터리를 하나 이상 추가하려면 각 디렉터리에 대해 전체 "sync" 섹션을 반복해야 합니다. 각 디렉터리에 대해 모든 여는 괄호와 닫는 괄호를 포함해야 합니다.

## lsyncd.exclude 파일

이전에 언급했듯이 "excludeFrom" 파일은 존재해야 합니다. 이제 해당 파일을 생성합니다.

`touch /etc/lsyncd.exclude`

컴퓨터에서 /etc 폴더를 동기화하고 있다고 가정하면, 제외해야 하는 많은 파일과 디렉터리가 있을 것입니다. 제외할 각 파일 또는 디렉터리는 한 줄에 하나씩 다음과 같이 목록에 기록됩니다.

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## 테스트하고 턴업

이제 모든 준비가 되었으므로 모두 테스트해 보세요. 우선, systemd lsyncd.service가 시작되도록 해 보겠습니다.

`systemctl start lsyncd`

이 명령을 실행한 후 오류가 나타나지 않으면, 서비스 상태를 확인하여 정상적으로 실행되는지 확인하겠습니다.

`systemctl status lsyncd`

서비스가 실행 중인 것을 확인하면, 두 로그 파일의 끝을 확인하기 위해 tail을 사용하여 확인합니다.

`tail /var/log/lsyncd.log`

그 다음

`tail /var/log/lsyncd-status.log`

이 모든 것이 정상적으로 보이면, `/home/[user]` 디렉터리(여기서 `[user]`는 컴퓨터의 사용자)로 이동하여  *touch*를 사용하여 새 파일을 만듭니다.

`touch /home/[user]/testfile`

그런 다음 대상 컴퓨터로 이동하여 파일이 표시되는지 확인합니다. 그렇다면 모든 것이 올바르게 작동하고 있습니다. lsyncd.service를 부팅시 자동 시작하도록 설정합니다.

`systemctl enable lsyncd`

이제 갈 준비가 되었습니다.

## 주의해야 할 점을 기억하십시오

파일 또는 디렉터리 세트를 다른 컴퓨터와 동기화할 때, 대상 컴퓨터에 미치는 영향을 신중히 고려해야 합니다. 위 예제의 **lsyncd.exclude 파일**에서, */etc/fstab*를 동기화한다고 상상해보십시오.

새 컴퓨터에서 *fstab*은 리눅스 컴퓨터의 저장 드라이브를 구성하는 파일입니다. 디스크와 레이블이 거의 항상 다를 것입니다. 대상 컴퓨터가 다시 시작된 다음에는 부팅이 실패할 가능성이 매우 높습니다.

# 결론 및 참조

`lsyncd`는 컴퓨터 간 디렉터리 동기화를 위한 강력한 도구입니다. 설치가 어렵지 않으며, 유지 관리하는 것도 복잡하지 않습니다. 더 바랄 수 없을 만큼 좋습니다.

더 많은 정보는 [공식 사이트](https://github.com/axkibe/lsyncd)로 이동하여 `lsyncd`에 대해 자세히 알아볼 수 있습니다.
