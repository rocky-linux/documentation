---
title: 2 ZFS 설정
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd zfs
---

# 2장: ZFS 설정

이 장 전체에서 루트 사용자이거나 루트가 되기 위해 `sudo`할 수 있어야 합니다.

이미 ZFS를 설치한 경우, 이 섹션에서 ZFS 설정 과정을 안내합니다.

## ZFS 활성화 및 풀 설정

먼저 다음 명령을 입력합니다:

```
/sbin/modprobe zfs
```

에러가 없으면 프롬프트로 돌아가며 아무런 메시지가 표시되지 않습니다. 오류가 발생한 경우 지금 중단하고 문제 해결을 시작하세요. 다시 한 번, secure boot가 꺼져 있는지 확인하십시오. 그것이 가장 가능성이 높은 문제입니다.

다음으로 시스템의 디스크를 조사하고 운영 체제가 있는 위치와 ZFS 풀로 사용 가능한 것을 알아내어 _lsblk_ 명령을 사용합니다: _lsblk_를 사용하여 이 작업을 수행합니다.

```
lsblk
```

이 명령은 다음과 같은 결과를 반환할 것입니다(시스템마다 결과가 다릅니다!):

```
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

이 목록에서 우리는 운영 체제에서 */dev/sda*을 사용 중임을  확인할 수 있습니다. 우리의 zpool에 */dev/sdb*을 사용할 것 입니다. 많은 사용 가능한 하드 드라이브가 있는 경우 ZFS를 위한 소프트웨어 RAID 인 raidz를 사용하는 것을 고려해볼 수 있습니다.

이 문서의 범위를 벗어나지만, 제품 환경에서 고려해야 할 사항입니다. 더 나은 성능과 장애 조치 기능을 제공합니다. 일단, 확인한 단일 장치에 풀을 생성하세요:

```
zpool create storage /dev/sdb
```

위 명령은 */dev/sdb* 장치에 "storage"라는 이름의 ZFS 풀을 생성하라는 의미입니다.

풀을 생성한 후에도 서버를 다시 재부팅합니다.
