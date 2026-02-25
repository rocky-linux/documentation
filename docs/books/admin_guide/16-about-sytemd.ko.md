---
title: systemd 관하여
author: tianci li
contributors: Steven Spencer
tags:
  - init 소프트웨어
  - systemd
  - Upstart
  - System V
---

# 기본 개요

**`systemd`**, 또한 **시스템 데몬**으로 알려져 있으며, GNU/Linux 운영체제 하에서 init 소프트웨어의 일종입니다.

개발 목적:

- 서비스 간의 의존성을 표현하기 위한 더 나은 프레임워크 제공
- 시스템 초기화 시 서비스의 병렬 시작 구현
- 쉘 오버헤드 감소 및 SysV 스타일 init 대체

\*\*`systemd`\*\*는 GNU/Linux 운영체제를 위한 일련의 시스템 구성요소를 제공하여, GNU/Linux 배포판 간의 서비스 구성 및 동작을 통일하고 그들의 사용에서 차이를 없앱니다.

2015년 이후, 대부분의 GNU/Linux 배포판은 `systemd`를 채택하여 전통적인 init 프로그램들, 예를 들어 SysV를 대체하였습니다. 많은 `systemd`의 개념과 디자인이 Apple Mac OS의 **launchd**에서 영감을 받았다는 것은 주목할 가치가 있습니다.

![init-compare](./images/16-init-compare.jpg)

`systemd`의 등장은 오픈 소스 커뮤니티에서 큰 논란을 일으켰습니다.

찬사의 목소리:

- 개발자와 사용자들은 `systemd`가 GNU/Linux 간의 사용 차이를 제거하고, 더 안정적이고 빠른 즉시 사용 가능한 솔루션을 제공했다고 칭찬했습니다.

비판적인 목소리:

- `systemd`는 운영체제에서 너무 많은 구성요소를 제어하며, UNIX의 KISS(**K**eep **I**t **S**imple, **S**tupid) 원칙을 위반한다.
- 코드 관점에서, `systemd`는 너무 복잡하고 다루기 힘들며, 코드 라인이 백만 줄을 넘어서 유지보수성이 떨어지고 공격 표면을 증가시킨다.

공식 웹사이트 - [https://systemd.io/](https://systemd.io/)
GitHub 저장소 - [https://github.com/systemd/systemd](https://github.com/systemd/systemd)

## 개발 역사

2010년, 레드햇의 소프트웨어 엔지니어인 Lennart Poettering와 Kay Sievers는 전통적인 SysV를 대체하기 위해 `systemd`의 첫 번째 버전을 개발했습니다.

![Lennart Poettering](./images/16-Lennart-Poettering.jpg)

![Kay Sievers](./images/16-Kay-Sievers.jpg)

2011년 5월, 페도라 15는 기본적으로 `systemd`를 활성화한 첫 번째 GNU/Linux 배포판이 되었습니다.

> systemd는 공격적인 병렬화 기능을 제공하며, 서비스를 시작하기 위해 소켓 및 D-Bus 활성화를 사용하고, 데몬의 수요에 따른 시작을 제공하며, Linux cgroups를 사용하여 프로세스를 추적하고, 시스템 상태의 스냅샷과 복원을 지원하며, 마운트 지점과 자동 마운트 지점을 유지하고, 강력한 트랜잭션 기반의 서비스 제어 로직을 구현합니다. 이는 sysvinit에 대한 드롭인 대체품으로 작동할 수 있습니다.

2012년 10월, 아치 리눅스는 기본적으로 `systemd`로 부팅되었습니다.

2013년 10월부터 2014년 2월까지, 데비안 기술 위원회는 데비안 메일링 리스트에서 긴 논의를 가졌으며, "데비안 8 Jessie의 시스템 기본으로 사용될 init은 무엇인가"에 초점을 맞추고 최종적으로 `systemd`를 사용하기로 결정했습니다.

2014년 2월, 우분투는 자체 Upstart를 포기하고 `systemd`를 init으로 채택했습니다.

2015년 8월, `systemd`는 `machinectl`을 통해 호출할 수 있는 로그인 쉘을 제공하기 시작했습니다.

2016년, `systemd`는 비특권 사용자가 `systemd`에 대해 "서비스 거부 공격"을 수행할 수 있는 보안 취약점을 발견했습니다.

2017년, `systemd`는 또 다른 보안 취약점 - **CVE-2017-9445**를 발견했습니다. 원격 공격자는 악의적인 DNS 응답을 통해 버퍼 오버플로 취약점을 트리거하고 악성 코드를 실행할 수 있습니다.

!!! info

    **버퍼 오버플로우**: 프로그램의 입력 버퍼에 프로그램이 오버플로우되도록 설계된 결함(보통 버퍼에 저장될 수 있는 최대 데이터량보다 더 많은 데이터를 작성함)으로, 프로그램 운영을 방해하고, 방해의 기회를 이용하여 프로그램이나 심지어 시스템의 제어권을 획득할 수 있습니다.

## 아키텍처 설계

여기서, 저자는 Samsung의 Tizen에서 사용된 `systemd`의 예를 들어 그 아키텍처를 설명합니다.

![Tizen-systemd](./images/16-tizen-systemd.png)

!!! info

    **Tizen** - 리눅스 재단이 지원하는 리눅스 커널 기반의 모바일 운영 체제로, 주로 삼성에서 개발 및 사용됩니다.

!!! info

    'systemd'의 일부 "타겟"은 systemd 구성요소에 속하지 않으며, 예를 들어 'telephony', 'bootmode', 'dlog', 'tizen service'와 같은 것들은 Tizen에 속합니다.

`systemd`는 모듈식 디자인을 사용합니다. 컴파일 시간에 존재하는 많은 구성 스위치가 무엇이 빌드될지를 결정하며, 리눅스 커널의 모듈식 디자인과 유사합니다. 컴파일될 때, `systemd`는 다음과 같은 작업을 수행하는 최대 69개의 바이너리 실행 파일을 가질 수 있습니다:

- `systemd`는 PID 1로 실행되며 가능한 한 많은 병렬 서비스의 시작을 제공합니다. 이는 또한 종료 순서를 관리합니다.
- `systemctl` 프로그램은 서비스 관리를 위한 사용자 인터페이스를 제공합니다.
- SysV 및 LSB 스크립트에 대한 지원도 제공되어 호환성을 보장합니다.
- SysV에 비해, `systemd` 서비스 관리 및 보고는 더 자세한 정보를 출력할 수 있습니다.
- 파일 시스템을 레이어로 마운트 및 언마운트함으로써, `systemd`는 마운트된 파일 시스템을 보다 안전하게 연결할 수 있습니다.
- `systemd`는 호스트 이름, 시간 및 날짜, 로케일, 로그 등을 포함한 기본 구성요소 구성의 관리를 제공합니다.
- 소켓의 관리를 제공합니다.
- `systemd` 타이머는 cron 예약 작업과 유사한 기능을 제공합니다.
- 임시 파일의 생성 및 관리, 포함하여 삭제를 지원합니다.
- D-Bus 인터페이스는 장치가 삽입되거나 제거될 때 스크립트를 실행할 수 있도록 합니다. 이 방식으로, 모든 장치는 플러그 앤 플레이 장치로 간주될 수 있으며, 따라서 장치 처리를 크게 단순화할 수 있습니다.
- 가장 오랜 시간이 걸리는 서비스를 찾을 수 있는 시작 순서 분석 도구.
- 로그 및 서비스 로그의 관리.

**`systemd`는 단순한 초기화 프로그램이 아니라, 많은 시스템 구성요소를 인수하는 대규모 소프트웨어 제품군입니다.**

## `systemd` PID 1로서

`systemd` 마운트는 **/etc/fstab** 파일의 내용을 사용하여 결정됩니다.

기본 "타겟" 구성은 **/etc/systemd/system/default.target**을 사용하여 결정됩니다.

이전에 SysV 초기화와 함께, \*\*런레벨(runlevel)\*\*의 개념이 있었습니다. `systemd`에도 아래와 같이 관련 호환성 비교 표가 있습니다 (의존성 수에 따라 내림차순으로 나열):

| systemd 타겟                        | SystemV 런레벨 | 타겟 별칭 (소프트 링크) | 설명                                                                                                                                                                                                                                                                                                                                                   |
| :-------------------------------- | :---------- | :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| default.target    |             |                                   | 이 "타겟"은 항상 "multi-user.target" 또는 "graphical.target"으로의 소프트 링크입니다. `systemd`는 항상 "default.target"을 사용하여 시스템을 시작합니다. 주의하십시오! "halt.target", "poweroff.target" 또는 "reboot.target"으로의 소프트 링크가 될 수 없습니다. |
| graphical.target  | 5           | runlevel5.target  | GUI 환경입니다.                                                                                                                                                                                                                                                                                                                           |
|                                   | 4           | runlevel4.target  | 예약되어 있으며 사용되지 않습니다. SysV 초기화 프로그램에서 runlevel4는 runlevel3와 동일합니다. `systemd` 초기화 프로그램에서 사용자는 기본 "multi-user.target"을 변경하지 않고 로컬 서비스를 시작하기 위해 이 "타겟"을 생성하고 사용자 정의할 수 있습니다.                                                                                                              |
| multi-user.target | 3           | runlevel3.target  | 전체 다중 사용자 명령 줄 모드입니다.                                                                                                                                                                                                                                                                                                                |
|                                   | 2           |                                   | SystemV에서는 NFS 서비스를 포함하지 않는 다중 사용자 명령 줄 모드를 의미합니다.                                                                                                                                                                                                                                                                                   |
| rescue.target     | 1           | runlevel1.target  | SystemV에서는 \*\*단일 사용자 모드(single-user mode)\*\*라고 불리며, 최소한의 서비스만 시작하고 다른 추가 프로그램이나 드라이버는 시작하지 않습니다. 주로 운영 체제를 수리하는 데 사용됩니다. 윈도우 운영 체제의 안전 모드와 유사합니다.                                                                                                                               |
| emergency.target  |             |                                   | 기본적으로 "rescue.target"과 동등합니다.                                                                                                                                                                                                                                                                                        |
| reboot.target     | 6           | runlevel6.target  | 재부팅합니다.                                                                                                                                                                                                                                                                                                                              |
| poweroff.target   | 0           | runlevel0.target  | 운영 체제를 종료하고 전원을 끕니다.                                                                                                                                                                                                                                                                                                                 |

```bash
Shell > find  / -iname  runlevel?\.target -a -type l -exec ls -l {} \;
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel6.target -> reboot.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx 1 root root 16 8月  23 03:05 /usr/lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx 1 root root 15 8月  23 03:05 /usr/lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel2.target -> multi-user.target

Shell > ls -l /etc/systemd/system/default.target
lrwxrwxrwx. 1 root root 41 12月 23 2022 /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target
```

각 "타겟"은 특정 런레벨에서 GNU/Linux 호스트를 실행하는 데 필요한 서비스인 구성 파일에 설명된 일련의 의존성을 가지고 있습니다. 더 많은 기능을 가질수록 "타겟"이 요구하는 의존성이 더 많아집니다. 예를 들어, GUI 환경은 명령 줄 모드보다 더 많은 서비스를 요구합니다.

맨 페이지(`man 7 bootup`)에서 `systemd`의 부팅 다이어그램을 조회할 수 있습니다:

```text
 local-fs-pre.target
                    |
                    v
           (다양한 마운트 및    (다양한 스왑    (다양한 cryptsetup
            fsck 서비스...)     장치...)        장치...)          (다양한 저수준    (다양한 저수준
                    |                 |                 |           서비스: udevd,    API VFS 마운트:
                    v                 v                 v           tmpfiles, random    mqueue, configfs,
             local-fs.target      swap.target     cryptsetup.target  seed, sysctl, ...)     debugfs, ...)
                    |                 |                 |                  |                  |
                    \__________________|_________________ | ___________________|____________________/
                                                         \|/
                                                          v
                                                   sysinit.target
                                                          |
                     ____________________________________/|\________________________________________
                    /                  |                  |                    |                    \
                    |                  |                  |                    |                    |
                    v                  v                  |                    v                    v
                (다양한            (다양한                |                (다양한           rescue.service
               타이머...)           경로...)              |               소켓...)               |
                    |                 |                  |                    |                    v
                    v                 v                  |                    v              rescue.target
              timers.target      paths.target             |             sockets.target
                    |                 |                  |                    |
                    v                  \_________________ | ___________________/
                                                         \|/
                                                          v
                                                    basic.target
                                                          |
                     ____________________________________/|                                 emergency.service
                    /                  |                  |                                         |
                    |                  |                  |                                         v
                    v                  v                  v                                 emergency.target
                display-        (다양한 시스템      (다양한 시스템
            manager.service         서비스            서비스)
                    |            그래픽 UI를 위한)          |
                    |                  |                  v
                    |                  |           multi-user.target
                    |                  |                  |
                    \_________________ | _________________/
                                      \|/
                                       v
                             graphical.target
```

- "sysinit.target"과 "basic.target"은 시작 과정 동안의 체크포인트입니다. `systemd`의 설계 목표 중 하나는 시스템 서비스를 병렬로 시작하는 것이지만, 다른 서비스와 "타겟"을 시작하기 전에 특정 서비스와 기능의 "타겟"을 먼저 시작해야 합니다.
- "sysinit.target"에 의존하는 "유닛"들이 완료되면, 시작은 "sysinit.target" 단계로 이동합니다. 이러한 "유닛"들은 병렬로 시작될 수 있으며, 다음을 포함합니다:
  - 파일 시스템 마운트
  - 스왑 파일 설정
  - udev 시작
  - 랜덤 생성기 시드 설정
  - 저수준 서비스 시작
  - 암호화 서비스 설정
- "sysinit.target"은 운영 체제의 필수 기능에 필요한 모든 저수준 서비스와 "유닛"을 시작하며, 이는 "basic.target" 단계로 들어가기 전에 필요합니다.
- "sysinit.target" 단계를 완료한 후, `systemd`는 다음 "타겟"(즉, "basic.target")을 완료하는 데 필요한 모든 "유닛"을 시작합니다. 타겟은 추가 기능을 제공하며, 다음을 포함합니다:
  - 다양한 실행 파일의 디렉토리 경로 설정
  - 통신 소켓
  - 타이머
- 마지막으로, 사용자 수준 "타겟"("multi-user.target" 또는 "graphical.target")에 대한 초기화가 수행됩니다. `systemd`는 "graphical.target"으로 들어가기 전에 "multi-user.target"에 도달해야 합니다.

전체 시작에 필요한 의존성을 보려면 다음 명령을 실행할 수 있습니다:

```bash
Shell > systemctl list-dependencies multi-user.target
multi-user.target
● ├─auditd.service
● ├─chronyd.service
● ├─crond.service
● ├─dbus.service
● ├─irqbalance.service
● ├─kdump.service
● ├─NetworkManager.service
● ├─sshd.service
● ├─sssd.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
● ├─tuned.service
● ├─basic.target
● │ ├─-.mount
● │ ├─microcode.service
● │ ├─paths.target
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─dbus.socket
● │ │ ├─sssd-kcm.socket
● │ │ ├─systemd-coredump.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ └─systemd-udevd-kernel.socket
● │ ├─sysinit.target
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─dracut-shutdown.service
● │ │ ├─import-state.service
● │ │ ├─kmod-static-nodes.service
● │ │ ├─ldconfig.service
● │ │ ├─loadmodules.service
● │ │ ├─nis-domainname.service
● │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─selinux-autorelabel-mark.service
● │ │ ├─sys-fs-fuse-connections.mount
● │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─systemd-ask-password-console.path
● │ │ ├─systemd-binfmt.service
● │ │ ├─systemd-firstboot.service
● │ │ ├─systemd-hwdb-update.service
● │ │ ├─systemd-journal-catalog-update.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
● │ │ ├─systemd-machine-id-commit.service
● │ │ ├─systemd-modules-load.service
● │ │ ├─systemd-random-seed.service
● │ │ ├─systemd-sysctl.service
● │ │ ├─systemd-sysusers.service
● │ │ ├─systemd-tmpfiles-setup-dev.service
● │ │ ├─systemd-tmpfiles-setup.service
● │ │ ├─systemd-udev-trigger.service
● │ │ ├─systemd-udevd.service
● │ │ ├─systemd-update-done.service
● │ │ ├─systemd-update-utmp.service
● │ │ ├─cryptsetup.target
● │ │ ├─local-fs.target
● │ │ │ ├─-.mount
● │ │ │ ├─boot.mount
● │ │ │ ├─systemd-fsck-root.service
● │ │ │ └─systemd-remount-fs.service
● │ │ └─swap.target
● │ │   └─dev-disk-by\x2duuid-76e2324e\x2dccdc\x2d4b75\x2dbc71\x2d64cd0edb2ebc.swap
● │ └─timers.target
● │   ├─dnf-makecache.timer
● │   ├─mlocate-updatedb.timer
● │   ├─systemd-tmpfiles-clean.timer
● │   └─unbound-anchor.timer
● ├─getty.target
● │ └─getty@tty1.service
● └─remote-fs.target
```

`--all` 옵션을 사용하여 모든 "유닛"을 확장할 수도 있습니다.

## `systemd` 사용하기

### 유닛 타입

`systemctl` 명령은 `systemd`를 관리하기 위한 주요 도구이며, 이전의 `service` 명령과 `chkconfig` 명령의 조합입니다.

`systemd`는 시스템 자원과 서비스의 표현인 소위 "유닛"을 관리합니다. 다음 목록은 `systemd`가 관리할 수 있는 "유닛" 타입을 보여줍니다:

- **service** - 시스템의 서비스로, 서비스 시작, 재시작, 중지에 대한 지시사항이 포함됩니다. `man 5 systemd.service`를 참조하세요.
- **socket** - 서비스와 연결된 네트워크 소켓입니다. `man 5 systemd.socket`을 참조하세요.
- **device** - `systemd`로 특별히 관리되는 장치입니다. `man 5 systemd.device`를 참조하세요.
- **mount** - `systemd`로 관리되는 마운트 포인트입니다. `man 5 systemd.mount`를 참조하세요.
- **automount** - 부팅 시 자동으로 마운트되는 마운트 포인트입니다. `man 5 systemd.automount`를 참조하세요.
- **swap** - 시스템의 스왑 공간입니다. `man 5 systemd.swap`를 참조하세요.
- **target** - 다른 유닛을 위한 동기화 지점입니다. 주로 부팅 시 활성화된 서비스를 시작하는 데 사용됩니다. `man 5 systemd.target`를 참조하세요.
- **path** - 경로 기반 활성화를 위한 경로입니다. 예를 들어, 특정 경로의 상태(존재 여부 등)에 따라 서비스를 시작할 수 있습니다. `man 5 systemd.path`를 참조하세요.
- **timer** - 다른 유닛의 활성화를 예약하기 위한 타이머입니다. `man 5 systemd.timer`를 참조하세요.
- **snapshot** - 현재 `systemd` 상태의 스냅샷입니다. 주로 `systemd`에 임시 변경을 한 후 롤백하는 데 사용됩니다.
- **slice** - 리눅스 제어 그룹 노드(cgroups)를 통한 리소스 제한입니다. `man 5 systemd.slice`를 참조하세요.
- **scope** - `systemd` 버스 인터페이스로부터의 정보입니다. 주로 외부 시스템 프로세스를 관리하는 데 사용됩니다. `man 5 systemd.scope`를 참조하세요.

### 운영 "유닛"

`systemictl` 명령의 사용법은 - `systemctl [OPTIONS...] COMMAND [UNIT...]` 입니다.

COMMAND는 다음으로 나눌 수 있습니다:

- 유닛 명령
- 유닛 파일 명령
- 머신 명령
- 작업 명령
- 환경 명령
- 관리자 라이프사이클 명령
- 시스템 명령

`systemctl --help`를 사용하여 세부사항을 발견할 수 있습니다.

일부 일반적인 운영 시연 명령은 다음과 같습니다:

```bash
# 서비스 시작
Shell > systemctl start sshd.service

# 서비스 중지
Shell > systemctl stop sshd.service

# 서비스 리로드
Shell > systemctl reload sshd.service

# 서비스 재시작
Shell > systemctl restart sshd.service

# 서비스 상태 보기
Shell > systemctl status sshd.service

# 시스템 시작 후 서비스가 자동으로 시작되도록 함
Shell > systemctl enable sshd.service

# 시스템 시작 후 서비스가 자동으로 중지되도록 함
Shell > systemctl disable sshd.service

# 서비스가 시작 후 자동으로 시작되는지 확인
Shell > systemctl is-enabled sshd.service

# 하나의 유닛을 마스크 처리
Shell > systemctl mask sshd.service

# 하나의 유닛 마스크 해제
Shell > systemctl unmask sshd.service

# 유닛 파일 내용 보기
Shell > systemctl cat sshd.service

# 유닛 파일 내용을 편집하고 /etc/systemd/system/ 디렉토리에 편집 후 저장
Shell > systemctl edit sshd.service

# 유닛의 완전한 속성 보기
Shell > systemctl show sshd.service
```

!!! info

      위의 작업에 대해 하나 이상의 단위를 한 번의 명령줄에서 조작할 수 있습니다. 위의 작업은 '.service'에만 제한되지 않습니다.

"유닛"에 대하여:

```bash
# 현재 실행 중인 모든 유닛을 나열합니다.
Shell > systemctl
## 또는
Shell > systemctl list-units
## 유형 필터링을 위해 "--type=TYPE"을 추가할 수 있습니다
Shell > systemctl --type=target

# 모든 유닛 파일을 나열합니다. "--type=TYPE"을 사용하여 필터링할 수 있습니다
Shell > systemctl list-unit-files
```

"타겟"에 대하여:

```bash
# 현재 "타겟"("런레벨") 정보를 조회합니다
Shell > systemctl get-default
multi-user.target

# "타겟"（"런레벨"）을 전환합니다. 예를 들어, GUI 환경으로 전환해야 하는 경우
Shell > systemctl isolate graphical.target

# 기본 "타겟"("런레벨")을 정의합니다
Shell > systemctl set-default graphical.target
```

### 중요한 디렉토리들

우선 순위에 따라 정렬된 세 가지 주요 중요 디렉토리가 있습니다:

- **/usr/lib/systemd/system/** - 설치된 RPM 패키지와 함께 배포된 systemd 유닛 파일들입니다. Centos 6의 /etc/init.d/ 디렉토리와 유사합니다.
- **/run/systemd/system/** - 실행 시간에 생성된 systemd 유닛 파일들입니다.
- **/etc/systemd/system/** - `systemctl enable`을 통해 생성된 systemd 유닛 파일들 및 서비스를 확장하기 위해 추가된 유닛 파일들입니다.

### `systemd` 구성 파일들

`man 5 systemd-system.conf`:

> 시스템 인스턴스로 실행될 때, systemd는 "system.conf" 구성 파일과 "system.conf.d" 디렉토리들의 파일들을 해석합니다; 사용자 인스턴스로 실행될 때는, 사용자의 홈 디렉토리에 있는 user.conf 구성 파일(또는 "/etc/systemd/" 아래에서 찾지 못한 경우)과 "user.conf.d" 디렉토리들의 파일들을 해석합니다. 이 구성 파일들은 기본 매니저 작업을 제어하는 몇 가지 설정을 포함합니다.

Rocky Linux 8.x 운영 체제에서 관련 구성 파일들은 다음과 같습니다:

- **/etc/systemd/system.conf** - 설정을 변경하기 위해 파일을 편집합니다. 파일을 삭제하면 기본 설정이 복원됩니다. `man 5 systemd-system.conf`를 참조하세요.
- **/etc/systemd/user.conf** - "/etc/systemd/user.conf.d/\*.conf"에서 파일을 생성하여 이 파일의 지시문을 재정의할 수 있습니다. `man 5 systemd-user.conf`를 참조하세요.

### `systemd` 유닛 파일 내용 설명

예를 들어 sshd.service 파일을 예로 들어보겠습니다:

```bash
Shell > systemctl cat sshd.service
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.target
Wants=sshd-keygen.target

[Service]
Type=notify
EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config
EnvironmentFile=-/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

보시다시피, 유닛 파일의 내용은 RL 9 네트워크 카드의 구성 파일과 동일한 스타일을 가지고 있습니다. 이는 ++여는 괄호++와 ++닫는 괄호++를 사용하여 제목을 포함하며, 제목 아래에 관련된 키-값 쌍이 있습니다

```bash
# RL 9
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection
[connection]
id=ens160
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e
type=ethernet
interface-name=ens160
timestamp=1670056998

[ethernet]
mac-address=00:0C:29:47:68:D0

[ipv4]
address1=192.168.100.4/24,192.168.100.1
dns=8.8.8.8;114.114.114.114;
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

".service" 유닛 타입의 주로 존재하는 세 가지 섹션:

- **Unit**
- **Service**
- **Install**

1. Unit 섹션

   다음 키-값 쌍을 사용할 수 있습니다:

   - `Description=OpenSSH server daemon`. "유닛"을 설명하는 문자열입니다.
   - `Documentation=man:sshd(8) man:sshd_config(5)`.  이 "유닛" 또는 그 설정에 대한 문서를 참조하는 URI의 공백으로 구분된 목록입니다. "http://", "https://", "file:", "info:", "man:" 유형의 URI만 허용됩니다.
   - `After=network.target sshd-keygen.target`. 다른 "유닛"들과의 시작 순서 관계를 정의합니다. 이 예에서는 "network.target"과 "sshd-keygen.target"이 먼저 시작되고 "sshd.service"가 마지막에 시작됩니다.
   - `Before=`. 다른 "유닛"들과의 시작 순서 관계를 정의합니다.
   - `Requires=`. 다른 "유닛"들에 대한 의존성을 구성합니다. 값은 공백으로 구분된 여러 유닛일 수 있습니다. 현재 "유닛"이 활성화되면 여기에 나열된 값들도 활성화됩니다. 나열된 "유닛" 값 중 하나라도 활성화에 성공하지 못하면 `systemd`는 현재 "유닛"을 시작하지 않습니다.
   - `Wants=sshd-keygen.target`. `Requires` 키와 유사합니다. 차이점은 의존하는 유닛의 시작이 실패하더라도 현재 "유닛"의 정상 작동에 영향을 주지 않는다는 것입니다.
   - `BindsTo=`. `Requires` 키와 유사합니다. 차이점은 의존하는 어떤 "유닛"이 시작에 실패하면 현재 유닛이 의존성이 중지된 "유닛"뿐만 아니라 추가로 중지됩니다.
   - `PartOf=`. `Requires` 키와 유사합니다. 차이점은 의존하는 어떤 "유닛"이 시작에 실패할 경우, 의존하는 유닛을 중지하고 재시작할 뿐만 아니라 현재 "유닛"도 중지되고 재시작됩니다.
   - `Conflicts=`. 값은 공백으로 구분된 "유닛" 목록입니다. 값으로 나열된 "유닛"이 실행 중이면 현재 "유닛"은 실행할 수 없습니다.
   - `OnFailure=`. 현재 "유닛"이 실패할 경우, 값에 있는 "유닛" 또는 "유닛들" (공백으로 구분) 이 활성화됩니다.

   자세한 정보는 `man 5 systemd.unit`을 참조하세요.

2. 서비스 제목

   다음 키-값 쌍을 사용할 수 있습니다:

   - `Type=notify`. 이 ".service" 유닛의 유형을 구성하며, 다음 중 하나일 수 있습니다:
     - `simple` - 서비스가 주 프로세스로 시작됩니다. 이것은 기본값입니다.
     - `forking` - 서비스가 포크된 프로세스를 호출하고 주 데몬의 일부로 실행됩니다.
     - `exec` - `simple`과 유사합니다. 서비스 매니저는 주 서비스의 바이너리를 실행한 직후에 이 유닛을 즉시 시작합니다. 다른 후속 유닛은 이 지점 이후에야 시작할 수 있습니다.
     - `oneshot` - `simple`과 유사하지만, 프로세스가 종료되어야 `systemd`가 후속 서비스를 시작합니다.
     - `dbus` - `simple`과 유사하지만, 데몬이 D-Bus 버스의 이름을 획득합니다.
     - `notify` - `simple`과 유사하지만, 데몬이 시작 후 `sd_notify` 또는 동등한 호출을 사용하여 알림 메시지를 보냅니다.
     - `idle` - `simple`과 유사하지만, 서비스의 실행이 모든 활성 작업이 디스패치될 때까지 지연됩니다.
   - `RemainAfterExit=`. 서비스의 모든 프로세스가 종료된 후 현재 서비스를 활성 상태로 간주할지 여부입니다. 기본값은 아니요입니다.
   - `GuessMainPID=`. 값은 불리언 유형이며 기본값은 예입니다. 서비스의 주 프로세스의 명확한 위치가 없는 경우, `systemd`가 주 프로세스의 PID를 추측해야 합니다(정확하지 않을 수 있음). `Type=forking`을 설정하고 `PIDFile`을 설정하지 않은 경우 이 키-값 쌍이 효력을 발휘합니다. 그렇지 않으면 이 키-값 쌍을 무시합니다.
   - `PIDFile=`. 서비스 PID의 파일 경로 (절대 경로) 를 지정합니다. `Type=forking` 서비스의 경우 이 키-값 쌍을 사용하는 것이 권장됩니다. `systemd`는 서비스 시작 후 데몬의 주 프로세스의 PID를 읽습니다.
   - `BusName=`. 이 서비스에 도달하기 위한 D-Bus 버스 이름입니다. `Type=dbus`를 사용하는 서비스의 경우 이 옵션은 필수입니다.
   - `ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY`. 서비스가 시작될 때 실행되는 명령어와 인수입니다.
   - `ExecStartPre=`. `ExecStart`의 명령어 전에 실행되는 다른 명령어입니다.
   - `ExecStartPost=`. `ExecStart`의 명령어 후에 실행되는 다른 명령어입니다.
   - `ExecReload=/bin/kill -HUP $MAINPID`. 서비스가 리로드될 때 실행되는 명령어와 인수입니다.
   - `ExecStop=`. 서비스가 중지될 때 실행되는 명령어와 인수입니다.
   - `ExecStopPost=`. 서비스가 중지된 후 실행되는 추가 명령어입니다.
   - `RestartSec=42s`. 서비스를 재시작하기 전에 대기하는 시간(초)입니다.
   - `TimeoutStartSec=`. 서비스가 시작되기를 기다리는 시간(초)입니다.
   - `TimeoutStopSec=`. 서비스가 중지되기를 기다리는 시간(초)입니다.
   - `TimeoutSec=`. `TimeoutStartSec`과 `TimeoutStopSec`을 동시에 구성하는 단축키입니다.
   - `RuntimeMaxSec=`. 서비스가 실행될 최대 시간(초)입니다. 무제한 시간을 구성하려면 `infinity`(기본값)를 전달합니다.
   - `Restart=on-failure`. 서비스의 프로세스가 종료되거나, 종료되거나, 시간 초과에 도달할 때 서비스를 재시작할지 여부를 구성합니다:
     - `no` - 서비스는 재시작되지 않습니다. 이것은 기본값입니다.
     - `on-success` - 서비스 프로세스가 깨끗하게 종료될 때만(종료 코드 0) 재시작됩니다.
     - `on-failure` - 서비스 프로세스가 깨끗하게 종료되지 않을 때만(비제로 종료 코드) 재시작됩니다.
     - `on-abnormal` - 프로세스가 신호로 종료되거나 시간 초과가 발생할 경우 재시작됩니다.
     - `on-abort` - 프로세스가 깨끗한 종료 상태로 지정되지 않은 포착되지 않은 신호로 인해 종료되면 재시작됩니다.
     - `on-watchdog` - `on-watchdog`로 설정된 경우, 감시견 타임아웃이 만료될 때만 서비스가 재시작됩니다.
     - `always` - 항상 재시작됩니다.

   `Restart=` 설정이 그들에 대한 종료 원인에 미치는 영향:

   ![effect](./images/16-effect.png)

   - `KillMode=process`. 이 유닛의 프로세스가 어떻게 종료될지를 지정합니다. 값은 다음 중 하나일 수 있습니다:
     - `control-group` - 기본값입니다. `control-group`으로 설정되면, 이 유닛의 제어 그룹에 남아 있는 모든 프로세스는 유닛이 중지될 때 종료됩니다.
     - `process` - 주 프로세스만 종료됩니다.
     - `mixed` - SIGTERM 신호가 주 프로세스에 보내지고 이어서 SIGKILL 신호가 유닛의 제어 그룹에 남아 있는 모든 프로세스에 보내집니다.
     - `none` - 어떤 프로세스도 종료하지 않습니다.
   - `PrivateTmp=`. 개인 tmp 디렉토리를 사용할지 여부입니다. 일부 보안에 따라 값을 예로 설정하는 것이 권장됩니다.
   - `ProtectHome=`. 홈 디렉토리를 보호할지 여부입니다. 값은 다음 중 하나일 수 있습니다:
     - `yes` - (/root/, /home/, /run/user/) 세 디렉토리가 유닛에게 보이지 않습니다.
     - `no` - 세 디렉토리가 유닛에게 보입니다.
     - `read-only` - 세 디렉토리가 유닛에게 읽기 전용입니다.
     - `tmpfs` - 임시 파일 시스템이 이 세 디렉토리에 읽기 전용으로 마운트됩니다.
   - `ProtectSystem=`. 서비스로부터 시스템을 수정하는 것을 보호하는 데 사용되는 디렉토리입니다. 값은 다음과 같을 수 있습니다:
     - `yes` - 유닛이 호출하는 프로세스가 /usr/ 및 /boot/ 디렉토리에 대해 읽기 전용으로 마운트됨을 나타냅니다.
     - `no` - 기본값입니다
     - `full` - /usr/, /boot/, /etc/ 디렉토리가 읽기 전용으로 마운트됩니다.
     - `strict` - 모든 파일 시스템이 읽기 전용으로 마운트됩니다(/dev/, /proc/, /sys/와 같은 가상 파일 시스템 디렉토리 제외).
   - `EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config`. 텍스트 파일에서 환경 변수를 읽습니다. "-"는 파일이 존재하지 않으면 파일을 읽지 않고 오류나 경고를 로그하지 않음을 의미합니다.

   자세한 정보는 `man 5 systemd.service`를 참조하세요.

3. Install title

   - `Alias=`. 공백으로 구분된 추가 이름 목록입니다. 주의하십시오! 추가 이름은 현재 유닛과 동일한 유형 (접미사) 을 가져야 합니다.

   - `RequiredBy=` 또는 `WantedBy=multi-user.target`. 값의 유닛에 대한 현재 작업의 유닛을 의존성으로 정의합니다. 정의가 완료되면 /etc/systemd/systemd/ 디렉토리에서 관련 파일을 찾을 수 있습니다. 예를 들어:

      ```bash
      Shell > systemctl is-enabled chronyd.service
      enabled
      
      Shell > systemctl cat chronyd.service
      ...
      [Install]
      WantedBy=multi-user.target
      
      Shell > ls -l /etc/systemd/system/multi-user.target.wants/
      총 0
      lrwxrwxrwx. 1 root root 38 Sep 25 14:03 auditd.service -> /usr/lib/systemd/system/auditd.service
      lrwxrwxrwx. 1 root root 39 Sep 25 14:03 chronyd.service -> /usr/lib/systemd/system/chronyd.service  ←←
      lrwxrwxrwx. 1 root root 37 Sep 25 14:03 crond.service -> /usr/lib/systemd/system/crond.service
      lrwxrwxrwx. 1 root root 42 Sep 25 14:03 irqbalance.service -> /usr/lib/systemd/system/irqbalance.service
      lrwxrwxrwx. 1 root root 37 Sep 25 14:03 kdump.service -> /usr/lib/systemd/system/kdump.service
      lrwxrwxrwx. 1 root root 46 Sep 25 14:03 NetworkManager.service -> /usr/lib/systemd/system/NetworkManager.service
      lrwxrwxrwx. 1 root root 40 Sep 25 14:03 remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
      lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sshd.service -> /usr/lib/systemd/system/sshd.service
      lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sssd.service -> /usr/lib/systemd/system/sssd.service
      lrwxrwxrwx. 1 root root 37 Sep 25 14:03 tuned.service -> /usr/lib/systemd/system/tuned.service
      ```

   - `Also=`. 이 유닛을 설치하거나 제거할 때 설치 또는 제거하는 다른 유닛들입니다.

     위에서 언급한 매뉴얼 페이지 외에도 `man 5 systemd.exec` 또는 `man 5 systemd.kill`을 입력하여 다른 정보에 액세스할 수 있습니다.

## 다른 구성요소와 관련된 명령어

- `timedatactl` - 시스템의 시간 및 날짜 설정을 조회하거나 변경합니다.
- `hostnamectl` - 시스템 호스트명을 조회하거나 변경합니다.
- `localectl` - 시스템 로케일 및 키보드 설정을 조회하거나 변경합니다.
- `systemd-analyze` - `systemd`를 프로파일링하며, 유닛 의존성을 보여주고 유닛 파일을 확인합니다.
- `journalctl` - 시스템 또는 서비스 로그를 조회합니다. `journalctl` 명령어는 그 중요성 때문에 사용 방법과 주의해야 할 사항을 설명하는 별도의 섹션이 나중에 제공됩니다.
- `loginctl` - 로그인 사용자의 세션 관리입니다.
