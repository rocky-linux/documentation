---
title: 7 컨테이너 구성 옵션
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd 구성
---

# 7장: 컨테이너 구성 옵션

이 장 전체에서 권한이 없는 사용자(이 책의 처음부터 팔로우한 경우 "lxdadmin")로 명령을 실행해야 합니다.

컨테이너를 설치한 후 컨테이너를 구성하기 위한 다양한 옵션을 살펴볼 것입니다. 그러나 먼저 컨테이너에 대한 `info` 명령을 살펴보겠습니다. 이 예제에서는 ubuntu-test 컨테이너를 사용합니다.

```
lxc info ubuntu-test
```

다음과 같은 내용이 표시됩니다:

```
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

거기에는 프로필 적용된 정보, 사용 중인 메모리, 사용 중인 디스크 공간 등 많은 유용한 정보가 있습니다.

### 구성 및 일부 옵션에 대한 정보

기본적으로 LXD는 컨테이너에 필요한 시스템 메모리, 디스크 공간, CPU 코어 및 기타 리소스를 할당합니다. 하지만 좀 더 구체적으로 알고 싶다면 어떻게 해야 할까요? 그것은 완전히 가능합니다.

그러나 이렇게 하는 것에는 타협점이 있습니다. 예를 들어 시스템 메모리를 할당하고 컨테이너가 모두 사용하지 않으면 실제로 필요한 다른 컨테이너가 해당 메모리를 사용할 수 없게 됩니다. 그러나 그 반대의 경우도 발생할 수 있습니다. 컨테이너가 할당된 메모리보다 더 많이 사용하려고 할 경우 다른 컨테이너의 성능이 저하될 수 있습니다.

컨테이너를 구성하기 위해 수행하는 모든 작업이 다른 곳에 부정적인 영향을 _할 수_ 있다는 점을 명심하십시오.

구성 옵션에 대한 모든 내용을 확인하기 위해 모든 옵션을 실행하는 대신, 탭 자동 완성을 사용하여 사용 가능한 옵션을 확인할 수 있습니다:

```
lxc config set ubuntu-test
```

그런 다음 TAB을 누르십시오.

이것은 컨테이너 구성을 위한 모든 옵션을 보여줍니다. 구성 옵션 중 하나의 기능에 대해 질문이 있는 경우 [LXD 공식 문서](https://linuxcontainers.org/lxd/docs/master/instances/)로 이동하여 다음을 수행하십시오. 구성 매개변수를 검색하거나 "lxc config set limits.memory"와 같은 전체 문자열을 구글에서 검색하여 검색 결과를 확인하면 됩니다.

여기서는 가장 많이 사용되는 일부 구성 옵션을 살펴보겠습니다. 예를 들어, 컨테이너가 사용할 수 있는 최대 메모리 양을 설정하려면:

```
lxc config set ubuntu-test limits.memory 2GB
```

이는 메모리가 사용 가능한 경우(예: 2GB의 사용 가능한 메모리가 있는 경우) 컨테이너가 실제로 사용할 수 있는 양을 2GB보다 크게 설정한다는 의미입니다. 이는 소프트 제한입니다.

```
lxc config set ubuntu-test limits.memory.enforce 2GB
```

이는 컨테이너가 현재 사용 가능한지 여부와 상관없이 메모리를 2GB 이상 사용할 수 없다는 의미입니다. 이 경우 하드 제한입니다.

```
lxc config set ubuntu-test limits.cpu 2
```

컨테이너가 사용할 수 있는 CPU 코어 수를 2개로 제한하는 것입니다.

!!! 참고 사항

    이 문서가 Rocky Linux 9.0용으로 다시 작성될 때 9의 ZFS 저장소가 사용할 수 없었습니다. 이러한 이유로 모든 테스트 컨테이너는 초기 프로세스에서 "dir"을 사용하여 구축되었습니다. 이 예제에서는 "dir" 대신 "zfs" 저장소 풀을 보여줍니다.

ZFS 장에서 스토리지 풀을 설정할 때 기억하시나요? 풀의 이름을 "storage"로 지정했지만 다른 이름으로도 지정할 수 있습니다. 이를 확인하려면 다음 명령을 사용할 수 있습니다. 이 명령은 dir와 같은 다른 풀 유형에 대해서도 동일하게 작동합니다:

```
lxc storage show storage
```


이는 다음을 보여줍니다.

```
config:
  source: /var/snap/lxd/common/lxd/storage-pools/storage
description: ""
name: storage
driver: dir
used_by:
- /1.0/instances/rockylinux-test-8
- /1.0/instances/rockylinux-test-9
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

이를 통해 우리의 모든 컨테이너가 dir 저장소 풀을 사용한다는 것을 확인할 수 있습니다. ZFS를 사용하는 경우 컨테이너에 디스크 할당량을 설정할 수도 있습니다. 다음은 ubuntu-test 컨테이너에 2GB 디스크 할당량을 설정하는 명령의 예입니다:

```
lxc config device override ubuntu-test root size=2GB
```

이전에 언급했듯이, 자원의 공유 이상을 사용하려는 컨테이너가 없는 한 구성 옵션을 절약하도록 하세요. 대부분의 경우 LXD는 환경을 스스로 잘 관리할 것입니다.

물론 일부 사람들이 관심을 가질 수 있는 더 많은 옵션이 있습니다. 자신의 환경에서 가치 있는 것이 있는지 알아보기 위해 자체 조사를 수행해야 합니다.

