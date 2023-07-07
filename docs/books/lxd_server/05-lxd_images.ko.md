---
title: 5 이미지 설정 및 관리
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd 이미지
---

# 5장: 이미지 설정 및 관리

이 장 전체에서 권한이 없는 사용자(처음부터 이 책을 따랐다면 "lxdadmin")로 명령을 실행해야 합니다.

## 사용 가능한 이미지 리스트

서버 환경이 설정되면 컨테이너를 시작하고 싶을 것입니다. 컨테이너 OS의 가능성은 매우 _많습니다_. 얼마나 많은 가능성이 있는지 알아보려면 다음 명령을 입력하십시오.

```
lxc image list images: | more
```

목록을 통해 페이지를 보려면 스페이스 바를 누르십시오. 이 컨테이너 및 가상 머신 목록은 계속 증가하고 있습니다.

마지막으로 수행할 작업은 특히 생성하려는 이미지를 알고 있는 경우 설치할 컨테이너 이미지를 찾는 것입니다. Rocky Linux 설치 옵션만 표시하도록 위의 명령을 수정해 보겠습니다.

```
lxc image list images: | grep rocky
```

이렇게 하면 훨씬 더 관리하기 쉬운 목록이 나타납니다.

```
| rockylinux/8 (3 more)                    | 0ed2f148f7c6 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 128.68MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8 (3 more)                    | 6411a033fdf1 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 643.15MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/arm64 (1 more)              | e677777306cf | yes    | Rockylinux 8 arm64 (20220805_02:29)          | aarch64      | CONTAINER       | 124.06MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 3d2fe303afd3 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 147.04MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 7b37619bf333 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 659.58MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud/arm64                 | 21c930b2ce7d | yes    | Rockylinux 8 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 143.17MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | 61b0171b7eca | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | VIRTUAL-MACHINE | 526.38MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | e7738a0e2923 | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | CONTAINER       | 107.80MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/arm64 (1 more)              | 917b92a54032 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 103.81MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 16d3f18f2abb | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 123.52MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 605eadf1c512 | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 547.39MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud/arm64                 | db3ce70718e3 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 119.27MB  | Aug 5, 2022 at 12:00am (UTC)  |
```

## 이미지 설치, 이름 바꾸기 및 이미지 목록

첫 번째 컨테이너로 rockylinux/8을 선택하겠습니다. 설치하려면 다음을 *사용할 수 있습니다* .

```
lxc launch images:rockylinux/8 rockylinux-test-8
```

그러면 "rocky linux-test-8"이라는 Rocky Linux 기반 컨테이너가 생성됩니다. 컨테이너를 만든 후에는 이름을 바꿀 수 있지만 먼저 컨테이너를 중지해야 합니다. 컨테이너는 시작될 때 자동으로 시작됩니다.

컨테이너를 수동으로 시작하려면 다음을 사용하십시오.

```
lxc start rockylinux-test-8
```

이 이미지의 이름을 변경하려면(여기서는 이 작업을 수행하지 않지만 이렇게 수행됨) 먼저 컨테이너를 중지합니다:

```
lxc stop rockylinux-test-8
```

그런 다음 컨테이너를 새 이름으로 이동하기만 하면 됩니다.

```
lxc move rockylinux-test-8 rockylinux-8
```

어쨌든 이 지침을 따랐다면 컨테이너를 중지하고 원래 이름으로 다시 이동하여 계속 따르십시오.

이 가이드의 목적을 위해 지금은 두 개의 이미지를 더 설치하십시오.

```
lxc launch images:rockylinux/9 rockylinux-test-9
```

및

```
lxc launch images:ubuntu/22.04 ubuntu-test
```

이제 이미지를 나열하여 지금까지 가지고 있는 것을 살펴보겠습니다.

```
lxc list
```

다음과 같은 결과를 반환해야 합니다.

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

