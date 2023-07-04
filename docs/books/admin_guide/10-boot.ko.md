---
title: 시스템 시작
---

# 시스템 시작

이 문서에서는 시스템을 시작하는 방법을 배웁니다.

****
**목표**: 이 문서에서는 미래의 Linux 관리자가 다음을 수행하는 방법을 배웁니다:

:heavy_check_mark: 부팅 프로세스의 여러 단계;   
:heavy_check_mark: Rocky Linux가 GRUB2 및 systemd를 통해 이 부팅을 지원하는 방법;   
:heavy_check_mark: GRUB2를 공격으로부터 보호하는 방법;   
:heavy_check_mark: 서비스 관리 방법;   
:heavy_check_mark: journald에서 로그에 액세스하는 방법.

:checkered_flag: **사용자**

**지식**: :star: :star:   
**복잡성**: :star: :star: :star:

**소요 시간**: 20분
****

## 부팅 프로세스

문제를 해결할 수 있도록 하기 위해 Linux의 부팅 프로세스를 이해하는 것이 중요합니다.

부팅 프로세스에는 다음이 포함됩니다.

### The BIOS startup

**BIOS** (Basic Input/Output System) 는 시스템 하드웨어 구성 요소를 감지, 테스트 및 초기화하기 위해 **POST** (power on self-test)를 수행합니다.

그런 다음 **MBR** (Master Boot Record)을 로드합니다.

### 마스터 부트 레코드 (MBR)

마스터 부트 레코드는 부트 디스크의 첫 512바이트입니다. MBR은 부팅 장치를 찾아서 부트로더 **GRUB2**를 메모리에 로드하고 제어를 전송합니다.

다음 64바이트는 디스크의 파티션 테이블을 포함합니다.

### GRUB2 부트로더

Rocky 8 배포용 기본 부트로더는 **GRUB2**(GRand Unified Bootloader)입니다. GRUB2는 이전 GRUB 부트로더(GRUB legacy라고도 함)를 대체합니다.

GRUB 2 구성 파일은 `/boot/grub2/grub.cfg` 아래에 있지만 이 파일을 직접 편집하면 안 됩니다.

GRUB2 메뉴 구성 설정은 `/etc/default/grub` 아래에 있으며 `grub.cfg` 파일을 생성하는 데 사용됩니다.

```
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

이러한 매개변수 중 하나 이상을 변경한 경우 `grub2-mkconfig` 명령을 실행하여 `/boot/grub2/grub.cfg` 파일을 다시 생성해야 합니다.

```
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2는 `/boot` 디렉토리에서 압축된 커널 이미지(`vmlinuz` 파일)를 찾습니다.
* GRUB2는 커널 이미지를 메모리에 로드하고 `initramfs` 이미지 파일의 내용을 `tmpfs`파일 시스템을 사용하여 메모리의 임시 폴더에 추출합니다.

### 커널

커널은 PID 1로 `systemd` 프로세스를 시작합니다.
```
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

Systemd는 모든 시스템 프로세스의 부모입니다. `/etc/systemd/system/default.target` 링크의 대상(예: `/usr/lib/systemd/system/multi-user.target`)을 읽어 시스템의 기본 대상을 결정합니다. 이 파일은 시작할 서비스를 정의합니다.

그런 다음 Systemd는 다음 초기화 작업을 수행하여 시스템을 대상으로 정의된 상태로 설정합니다:

1. 머신 이름 설정
2. 네트워크 초기화
3. SELinux 초기화
4. 환영 메시지 표시
5. 부팅 시 커널에 전달된 인수를 기반으로 하드웨어 초기화
6. 가상 파일 시스템인 /proc을 포함한 파일 시스템 마운트
7. /var디렉토리에서 디렉토리 정리
8. 가상 메모리 시작(swap)

## GRUB2 부트로더 보호하기

부트로더를 비밀번호로 보호하는 이유는 무엇입니까?

1. *단일* 사용자 모드 액세스 방지 - 공격자가 단일 사용자 모드로 부팅할 수 있으면 root 사용자가 됩니다.
2. GRUB 콘솔에 대한 액세스 방지 - 공격자가 GRUB 콘솔을 사용할 수 있다면 구성을 변경하거나 `cat` 명령을 사용하여 시스템에 대한 정보를 수집할 수 있습니다.
3. 보안 취약한 운영 체제 접근 방지. 시스템에 이중 부팅이 있는 경우, 공격자는 부팅 시에 DOS와 같은 운영 체제를 선택하여 액세스 제어 및 파일 권한을 무시할 수 있습니다.

GRUB2 부트로더를 암호로 보호하려면:

* `/etc/grub.d/10_linux` 파일의 기본 `CLASS=` 문에서 `-unrestricted`를 제거합니다.

* 아직 사용자가 구성되지 않은 경우 `grub2-setpassword` 명령을 사용하여 root 사용자의 비밀번호를 제공합니다:

```
# grub2-setpassword
```

이미 존재하지 않는 경우 `/boot/grub2/user.cfg` 파일이 생성됩니다. 이 파일에는 GRUB2의 해시된 비밀번호가 포함되어 있습니다.

!!! 참고 사항

    이 명령은 단일 루트 사용자가 있는 구성만 지원합니다.

```
[root]# cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.CC6F56....A21
```

* `grub2-mkconfig` 명령을 사용하여 구성 파일을 재생성하세요:

```
[root]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-f9725b0c842348ce9e0bc81968cf7181
Found initrd image: /boot/initramfs-0-rescue-f9725b0c842348ce9e0bc81968cf7181.img
done
```

* 서버를 다시 시작하고 확인하십시오.

GRUB 메뉴에 정의된 모든 항목은 이제 부팅할 때마다 사용자 이름과 암호를 입력해야 합니다. 시스템은 콘솔에서 직접 사용자 개입 없이 커널을 부팅하지 않습니다.

* 사용자가 요청하면 `root`를 입력합니다.
* 암호가 요청되면 `grub2-setpassword` 명령에서 제공된 암호를 입력합니다.

GRUB 메뉴 항목 편집 및 콘솔 액세스만 보호하려면 `grub2-setpassword` 명령을 실행하는 것으로 충분합니다. 이러한 이유로만 수행하는 경우도 있을 수 있습니다. 이는 서버가 재부팅될 때마다 암호를 입력하는 것이 어렵거나 불가능한 원격 데이터 센터에서 특히 그럴 수 있습니다.

## Systemd

*Systemd*는 Linux 운영 체제의 서비스 관리자입니다.

다음을 위해 개발되었습니다.

* 이전 SysV 초기화 스크립트와의 호환성을 유지합니다.
* 시스템 시작 시 시스템 서비스의 병렬 시작, 데몬의 온디맨드 활성화, 스냅샷 지원 또는 서비스 간의 종속성 관리와 같은 많은 기능을 제공합니다.

!!! 참고 사항

    Systemd는 RedHat/CentOS 7 이후의 기본 초기화 시스템입니다.

Systemd는 systemd 단위의 개념을 도입합니다.

| 유형           | 파일 확장자       | 기능                |
| ------------ | ------------ | ----------------- |
| Service unit | `.service`   | 시스템 서비스           |
| Target unit  | `.target`    | systemd 단위 그룹     |
| Mount unit   | `.automount` | 파일 시스템의 자동 마운트 지점 |

!!! 참고 사항

    장치 단위, 마운트 단위, 경로 단위, 범위 단위, 슬라이스 단위, 스냅샷 단위, 소켓 단위, 스왑 단위, 타이머 단위 등 다양한 유형의 단위가 있습니다.

* Systemd는 시스템 상태 스냅샷 및 복원을 지원합니다.

* 마운트 지점은 systemd 타겟으로 구성할 수 있습니다.

* 시작 시 systemd는 이 유형의 활성화를 지원하는 모든 시스템 서비스에 대해 수신 대기 소켓을 생성하고 시작될 때 이러한 소켓을 서비스에 전달합니다. 이를 통해 일시적으로 사용할 수 없을 때에도 네트워크에서 보낸 메시지를 수신했던 서비스를 다시 시작할 수 있습니다. 해당 소켓은 접근 가능하며 모든 메시지는 대기열에 유지됩니다.

* D-BUS를 사용하는 시스템 서비스는 클라이언트가 처음 사용할 때에만 필요한 경우에 요구에 따라 필요할 때 시작될 수 있습니다.

* Systemd는 실행 중인 서비스만 중지하거나 다시 시작합니다. 이전 버전(RHEL7 이전)은 현재 상태를 확인하지 않고 서비스를 직접 중지하려고 시도했습니다.

* 시스템 서비스는 HOME 및 PATH 환경 변수와 같은 컨텍스트를 상속하지 않습니다. 각 서비스는 자체 실행 컨텍스트에서 작동합니다.

오작동하는 서비스로 인해 시스템이 정지되는 것을 방지하기 위해 모든 서비스 장치 작업에는 5분의 기본 제한 시간이 적용됩니다.

### 시스템 서비스 관리

서비스 단위는 `.service` 파일 확장자로 끝나며 init 스크립트와 비슷한 목적을 가지고 있습니다. `systemctl` 명령은 시스템 서비스를 `표시`, `시작`, `중지`, `재시작`하는 데 사용됩니다.

| systemctl                                 | 설명                   |
| ----------------------------------------- | -------------------- |
| systemctl start _name_.service            | 서비스 시작               |
| systemctl stop _name_.service             | 서비스 정지               |
| systemctl restart _name_.service          | 서비스 재시작              |
| systemctl reload _name_.service           | 구성 파일 다시 로드          |
| systemctl status _name_.service           | 서비스가 실행 여부 확인        |
| systemctl try-restart _name_.service      | 실행 중인 경우에만 서비스 다시 시작 |
| systemctl list-units --type service --all | 모든 서비스의 상태 표시        |

`systemctl` 명령은 시스템 서비스의 `enable` 또는 `disable` 및 관련 서비스 표시에도 사용됩니다.

| systemctl                                | 설명                       |
| ---------------------------------------- | ------------------------ |
| systemctl enable _name_.service          | 서비스 활성화                  |
| systemctl disable _name_.service         | 서비스 비활성화                 |
| systemctl list-unit-files --type service | 모든 서비스를 목록 및 실행 여부 확인    |
| systemctl list-dependencies --after      | 지정된 단위보다 먼저 시작하는 서비스 목록  |
| systemctl list-dependencies --before     | 지정된 단위보다 나중에 시작하는 서비스 목록 |

예시:

```
systemctl stop nfs-server.service
# 또는
systemctl stop nfs-server
```

현재 로드된 유닛을 나열하려면:

```
systemctl list-units --type service
```

활성화 여부를 확인하기 위해 모든 유닛을 나열하려면:

```
systemctl list-unit-files --type service
```

```
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### postfix 서비스용 .service 파일의 예

```
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### 시스템 타겟 사용

Rocky8/RHEL8에서는 실행 수준 개념이 Systemd 타겟으로 대체되었습니다.

Systemd 타겟은 타겟 유닛으로 표시됩니다. 타겟 유닛은 `.target` 파일 확장자로 끝나며 유일한 목적은 다른 Systemd 장치를 종속성 체인으로 그룹화하는 것입니다.

예를 들어 그래픽 세션을 시작하는 데 사용되는 `graphical.target` 유닛은 **GNOME 디스플레이 매니저**(`gdm.service`) 또는 **계정 서비스**(`accounts-daemon.service`)와 같은 시스템 서비스를 시작하고 `multi-user.target` 유닛도 활성화합니다.

마찬가지로 `multi-user.target` 유닛은 **NetworkManager**(`NetworkManager.service`) 또는 **D-Bus**(`dbus.service`) 와 같은 다른 필수 시스템 서비스를 시작하고 `basic.target`이라는 다른 타겟 유닛을 활성화합니다.

| 타겟 유닛             | 설명                          |
| ----------------- | --------------------------- |
| poweroff.target   | 시스템을 종료                     |
| rescue.target     | Rescue 셸 활성화                |
| multi-user.target | 그래픽 인터페이스 없이 다중 사용자 시스템 활성화 |
| graphical.target  | 그래픽 인터페이스로 다중 사용자 시스템 활성화   |
| reboot.target     | 시스템을 종료하고 다시 시작             |

#### 기본 타겟

기본적으로 사용되는 타겟(대상)을 결정하려면 다음을 수행하십시오.

```
systemctl get-default
```

이 명령은 `/etc/systemd/system/default.target`에 위치한 심볼릭 링크의 대상을 검색하고 결과를 표시합니다.

```
$ systemctl get-default
graphical.target
```

`systemctl` 명령은 사용 가능한 타겟 목록도 제공할 수 있습니다.

```
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

다른 기본 타겟을 사용하도록 시스템을 구성하려면:

```
systemctl set-default name.target
```

예시:

```
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

현재 세션에서 다른 타겟 장치로 전환하려면:

```
systemctl isolate name.target
```

**Rescue mode(복구 모드)**는 정상적인 부팅 프로세스를 수행할 수 없는 경우 시스템을 수리하기 위한 간단한 환경을 제공합니다.

`복구 모드`에서 시스템은모든 로컬 파일 시스템을 마운트하고 여러 중요한 시스템 서비스를 시작하지만 네트워크 인터페이스를 활성화하지 않거나 다른 사용자가 동시에 시스템에 연결되지 않도록합니다.

Rocky 8에서 `복구 모드`는 이전 `단일 사용자 모드`와 동일하며 root 비밀번호를 요구합니다.

현재 타겟을 변경하고 현재 세션에서 `복구 모드`를 진입하려면:

```
systemctl rescue
```

**Emergency Mode(비상 모드)**는  시스템이 복구 모드로 진입할 수 없는 상황에서도 시스템을 복구할 수 있도록 가장 최소한의 환경을 제공합니다. 비상 모드에서 시스템은 읽기 전용으로 root 파일 시스템만 마운트합니다. 다른 로컬 파일 시스템을 마운트하려고 시도하지 않으며 네트워크 인터페이스를 활성화하지 않으며 일부 필수 서비스를 시작합니다.

현재 타겟을 변경하고 현재 세션에서 비상 모드로 전환하려면:

```
systemctl emergency
```

#### 종료, 정지 및 최대 절전 모드

`systemctl` 명령은 이전 버전에서 사용된 여러 전원 관리 명령을 대체합니다.

| 이전 명령               | 새 명령                     | 설명                            |
| ------------------- | ------------------------ | ----------------------------- |
| `halt`              | `systemctl halt`         | 시스템을 중지합니다.                   |
| `poweroff`          | `systemctl poweroff`     | 시스템의 전원을 끕니다.                 |
| `reboot`            | `systemctl reboot`       | 시스템을 다시 시작합니다.                |
| `pm-suspend`        | `systemctl suspend`      | 시스템을 일시 중단합니다.                |
| `pm-hibernate`      | `systemctl hibernate`    | 시스템을 최대 절전 모드로 전환합니다.         |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | 시스템을 최대 절전 모드로 전환하고 일시 중단합니다. |

### `journald` 프로세스

로그 파일은 `rsyslogd` 외에도 `systemd`의 구성 요소인 `journald` 데몬으로 관리할 수 있습니다.

`journald` 데몬은 Syslog 메시지, 커널 로그 메시지, 초기 RAM 디스크 및 부팅 시작 시 발생하는 메시지, 그리고 모든 서비스의 표준 출력 및 표준 오류 출력에 기록된 메시지를 캡처하고, 인덱싱하여 사용자에게 제공합니다.

구조화되고 인덱싱된 이진 형식의 기본 로그 파일 형식은 검색을 개선하고 더 빠른 작동을 가능하게 하며 타임스탬프 또는 사용자 ID와 같은 메타데이터 정보를 저장합니다.

### `journalctl` 명령

`journalctl` 명령은 로그 파일을 표시합니다.

```
journalctl
```

이 명령은 시스템에서 생성된 모든 로그 파일을 나열합니다. 이 출력의 구조는 `/var/log/messages/`에서 사용되는 구조와 유사하지만 다음과 같은 개선 사항이 있습니다:

* 항목의 우선 순위는 시각적으로 표시됩니다.
* 타임스탬프는 시스템의 로컬 시간대로 변환됩니다.
* 회전 로그를 포함하여 모든 기록된 데이터가 표시됩니다.
* 시작 부분은 특별한 선으로 표시됩니다.

#### 연속 표시 사용

지속적인 표시를 통해 로그 메시지가 실시간으로 표시됩니다.

```
journalctl -f
```

이 명령은 가장 최근의 10개 로그 줄 목록을 반환합니다. 그런 다음 journalctl 유틸리티는 계속 실행되고 즉시 변경 사항이 발생할 때까지 기다립니다.

#### 메시지 필터링

다양한 필터링 방법을 사용하여 다양한 요구에 맞는 정보를 추출할 수 있습니다. 로그 메시지는 종종 시스템의 잘못된 동작을 추적하는 데 사용됩니다. 선택한 우선순위 이상의 항목을 보려면 다음과 같이 하십시오:

```
journalctl -p priority
```

우선 순위를 다음 키워드(또는 숫자) 중 하나로 바꿔야 합니다.

* debug (7),
* info (6),
* notice (5),
* warnung (4),
* err (3),
* crit (2),
* alert (1),
* emerg (0).
