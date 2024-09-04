---
title: 1 설치 및 구성
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd 설치
---

# 1장: 설치 및 구성

이 장에서는 root 사용자이거나 root로 _sudo_할 수 있는 권한이 필요합니다.

## EPEL 및 OpenZFS 리포지토리 설치

LXD는 EPEL (Enterprise Linux용 추가 패키지) 저장소를 필요로 합니다. 다음 명령을 사용하여 쉽게 설치할 수 있습니다:

```
dnf install epel-release
```

설치 후 패키지의 업데이트가 없는지 확인합니다:

```
dnf upgrade
```

업그레이드 과정 중에 커널 업데이트가 있었다면 서버를 재부팅합니다.

### 8 및 9용 OpenZFS 리포지토리

다음을 사용하여 OpenZFS 리포지토리를 설치합니다.

```
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## snapd, dkms, vim 및 kernel-devel 설치

LXD 설치에는 Rocky Linux에서 snap 패키지가 필요합니다. 이러한 이유로 다음 명령을 사용하여 `snapd` (및 몇 가지 유용한 프로그램)를 설치합니다:

```
dnf install snapd dkms vim kernel-devel
```

snapd를 활성화하고 시작합니다:

```
systemctl enable snapd
```

다음을 실행합니다.

```
systemctl start snapd
```

계속하기 전에 서버를 재부팅합니다.

## LXD 설치

LXD를 설치하기 위해 snap 명령을 사용합니다. 이 시점에서 설정하는 것이 아니라 단순히 설치하는 것입니다:

```
snap install lxd
```

## OpenZFS 설치

```
dnf install zfs
```

## 환경 설정

대부분의 서버 커널 설정은 대량의 컨테이너를 실행하는 데 적합하지 않습니다. 프로덕션에서 서버를 사용할 것으로 가정한다면, "파일 수가 너무 많음"과 같은 오류가 발생하지 않도록 처음부터 이러한 변경 사항을 적용해야 합니다.

다행히도 LXD의 설정을 수정하는 것은 파일 수정 몇 가지와 재부팅으로 간단합니다.

### limits.conf 수정

첫 번째로 수정해야 할 파일은 limits.conf 파일입니다. 이 파일은 자체적으로 문서화되어 있습니다. 파일 안의 주석을 살펴보고 이 파일이 수행하는 작업을 이해하기 위해 설명을 확인하십시오. 수정 사항을 적용하기 위해 다음 명령을 입력합니다:

```
vi /etc/security/limits.conf
```

이 파일은 주석으로만 이루어져 있으며, 맨 아래에는 현재의 기본 설정이 표시됩니다. 파일의 끝 표시자 (#End of file) 위의 공백 공간에 사용자 정의 설정을 추가해야 합니다. 파일의 끝은 다음과 같아야 합니다:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

변경 사항을 저장하고 편집기를 종료합니다. (`SHIFT:wq!` for _vi_)

### 90-lxd.override.conf로 sysctl.conf 수정

_systemd_를 사용하면 기본 구성 파일을 수정하지 않고도 시스템의 전체 구성 및 커널 옵션을 변경할 수 있습니다. 대신 필요한 특정 설정을 무시하는 별도의 파일에 설정을 넣습니다.

이러한 커널 변경을 위해 /etc/sysctl.d 디렉토리에 90-lxd-override.conf라는 파일을 생성합니다. 다음 명령을 입력하여 파일을 생성합니다:

```
vi /etc/sysctl.d/90-lxd-override.conf
```

!!! 경고 "RL 9 및 A의 MAX `net.core.bpf_jit_limit`"

    최근 커널 보안 업데이트로 인해 `net.core.bpf_jit_lrecentimit`의 최대값이 1000000000으로 나타납니다. Rocky Linux 9.x를 실행 중인 경우 아래 자체 문서화 파일에서 이 값을 조정해야 합니다. 이 한도 이상으로 설정하거나 **또는** 전혀 설정하지 않으면 시스템 기본값인 264241152로 기본 설정되며, 대량의 컨테이너를 실행하는 경우 충분하지 않을 수 있습니다.

다음 내용을 파일에 추가합니다. 여기서 무엇을 하는지 궁금하다면, 파일 내용이 자체 문서화되어 있음을 알아두세요:

```
## LXD를 위해 다음 변경 사항이 적용되었습니다 ##


# fs.inotify.max_queued_events는 해당 inotify 인스턴스에 대기 중인 이벤트 수의 상한을 지정합니다. - (기본 값은 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances는 실제 사용자 ID 당 생성할 수 있는 inotify 인스턴스 수의 상한을 지정합니다 - (기본값은 128입니다)


fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches는 실제 사용자 ID 당 생성할 수 있는 감시 수의 상한을 지정합니다 - (기본값은 8192입니다)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count는 프로세스가 가질 수 있는 메모리 맵 영역의 최대 개수를 나타냅니다. 메모리 맵 영역은 malloc을 호출할 때, mmap과 mprotect를 통해 직접 사용되며, 공유 라이브러리를 로드할 때도 사용됩니다 - (기본값은 65530입니다)

vm.max_map_count = 262144

# kernel.dmesg_restrict는 컨테이너가 커널 링 버퍼의 메시지에 액세스할 수 없도록 합니다. 이는 호스트 시스템의 비루트 사용자에게도 액세스를 거부할 것입니다 - (기본값은 0입니다)

kernel.dmesg_restrict = 1

# 이것은 ARP 테이블 (IPv4)의 최대 항목 수입니다. 1024개 이상의 컨테이너를 생성하는 경우 이 값을 증가시키십시오.

net.ipv4.neigh.default.gc_thresh3 = 8192

# 이것은 ARP 테이블 (IPv6)의 최대 항목 수입니다. 1024개 이상의 컨테이너를 생성하는 경우 이 값을 증가시키십시오. IPv6을 사용하지 않는 경우 필요하지 않지만...

net.ipv6.neigh.default.gc_thresh3 = 8192

# 이것은 eBPF JIT 할당의 크기 제한입니다. 일반적으로 PAGE_SIZE * 40000으로 설정됩니다. Rocky Linux 9.x를 실행 중인 경우 1000000000으로 설정하십시오. net.core.bpf_jit_limit = 3000000000

# 이것은 root 아닌 사용자가 사용할 수 있는 키의 최대 개수입니다. 컨테이너 수보다 높아야 합니다. kernel.keys.maxkeys = 2000

# root가 아닌 사용자가 사용할 수 있는 키링의 최대 크기입니다. kernel.keys.maxbytes = 2000000

# 이것은 동시 비동기 I/O 작업의 최대 수입니다. AIO 하위 시스템을 사용하는 작업 부하가 많은 작업을 수행하는 경우 이 값을 더 높게 설정해야 할 수 있습니다 (예: MySQL)


fs.aio-max-nr = 524288
```

변경 사항을 저장하고 편집기를 종료합니다.

이제 서버를 재부팅합니다.

### _sysctl.conf_ 값 확인

재부팅 후 root 사용자로 서버에 다시 로그인합니다. 우리의 오버라이드 파일이 실제로 작업을 완료했는지 확인해야 합니다.

이 작업은 어렵지 않습니다. 원하지 않는 한 모든 설정을 확인할 필요는 없지만 몇 가지를 확인하면 설정이 변경되었는지 확인할 수 있습니다. 이것은 _sysctl_ 명령으로 수행됩니다.

```
sysctl net.core.bpf_jit_limit
```

결과는 다음과 같이 표시됩니다:

```
net.core.bpf_jit_limit = 3000000000
```

오버라이드 파일에 있는 다른 설정도 확인하여 변경 사항을 확인합니다.
