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

컨테이너를 설치한 후 컨테이너를 구성하기 위한 다양한 옵션이 있습니다. 그러나 이를 확인하는 방법을 알아보기 전에 컨테이너에 대한 info 명령을 살펴보겠습니다. 이 예에서는 ubuntu-test 컨테이너를 사용합니다.

```
lxc info ubuntu-test
```

이는 다음과 같은 내용을 보여줍니다.

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

적용된 프로필에서 사용 중인 메모리, 사용 중인 디스크 공간 등에 이르기까지 좋은 정보가 많이 있습니다.

### 구성 및 일부 옵션에 대한 정보

기본적으로 LXD는 필요한 시스템 메모리, 디스크 공간, CPU 코어 등을 컨테이너에 할당합니다. 하지만 좀 더 구체적으로 알고 싶다면 어떻게 해야 할까요? 그것은 완전히 가능합니다.

그러나 이를 수행하는 데는 장단점이 있습니다. 예를 들어 시스템 메모리를 할당했는데 컨테이너가 실제로 모든 메모리를 사용하지 않는 경우 실제로 필요할 수 있는 다른 컨테이너에서 메모리를 보관한 것입니다. 그러나 그 반대가 발생할 수 있습니다. 컨테이너가 메모리의 완전한 돼지인 경우 다른 컨테이너가 충분한 메모리를 확보하지 못하게 하여 성능을 저하시킬 수 있습니다.

컨테이너를 구성하기 위해 수행하는 모든 작업이 다른 곳에 부정적인 영향을 _할 수_ 있다는 점을 명심하십시오.

구성을 위해 모든 옵션을 실행하는 대신 탭 자동 완성을 사용하여 사용 가능한 옵션을 확인하십시오.

```
lxc config set ubuntu-test
```

그런 다음 TAB을 누르십시오.

이것은 컨테이너 구성을 위한 모든 옵션을 보여줍니다. 구성 옵션 중 하나의 기능에 대해 질문이 있는 경우 [LXD 공식 문서](https://linuxcontainers.org/lxd/docs/master/instances/)로 이동하여 다음을 수행하십시오. 구성 매개변수를 검색하거나 "lxc config set limits.memory"와 같은 전체 문자열을 Google에서 검색하고 검색 결과를 살펴봅니다.

가장 많이 사용되는 몇 가지 구성 옵션을 살펴보겠습니다. 예를 들어 컨테이너가 사용할 수 있는 최대 메모리 양을 설정하려는 경우:

```
lxc config set ubuntu-test limits.memory 2GB
```

즉, 메모리를 사용할 수 있는 한, 즉 2GB의 여유 메모리가 있는 한 컨테이너는 실제로 사용 가능한 경우 2GB 이상을 사용할 수 있습니다. 다른 말로 하자면, 그것은 soft limit입니다.

```
lxc config set ubuntu-test limits.memory.enforce 2GB
```

즉, 컨테이너는 현재 사용 가능 여부에 관계없이 2GB 이상의 메모리를 사용할 수 없습니다. 이 경우 hard limit입니다.

```
lxc config set ubuntu-test limits.cpu 2
```

컨테이너가 사용할 수 있는 CPU 코어 수를 2개로 제한하는 것입니다.

!!! 참고 사항

    이 문서가 Rocky Linux 9.0용으로 재작성되었을 때 9용 ZFS 저장소는 사용할 수 없었습니다. 이러한 이유로 모든 테스트 컨테이너는 init 프로세스에서 "dir"을 사용하여 빌드되었습니다. 이것이 바로 아래 예에서 "zfs" 스토리지 풀 대신 "dir"을 보여주는 이유입니다.

ZFS 장에서 저장소 풀을 설정했던 때를 기억하십니까? 우리는 풀의 이름을 "storage"로 지정했지만 아무 이름이나 지정할 수 있습니다. 이것을 보고 싶다면 다음 명령을 사용할 수 있습니다. 이 명령은 다른 풀 유형에도 똑같이 잘 작동합니다(dir에 대해 표시된 대로).

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

이는 모든 컨테이너가 dir 스토리지 풀을 사용하고 있음을 보여줍니다. ZFS를 사용하는 경우 컨테이너에 디스크 할당량을 설정할 수도 있습니다. 다음은 ubuntu-test 컨테이너에 2GB 디스크 할당량을 설정하는 것과 같습니다.

```
lxc config device override ubuntu-test root size=2GB
```

앞서 설명한 바와 같이 구성 옵션은 리소스 공유보다 훨씬 더 많이 사용하려는 컨테이너가 없는 경우에는 사용하지 않는 것이 좋습니다. LXD는 대부분 자체적으로 환경을 잘 관리합니다.

물론 일부 사람들이 관심을 가질 수 있는 더 많은 옵션이 있습니다. 자신의 환경에서 가치 있는 것이 있는지 알아보기 위해 자체 조사를 수행해야 합니다.

