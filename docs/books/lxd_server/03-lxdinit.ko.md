---
title: 3 LXD 초기화 및 사용자 설정
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd initialization
  - lxd setup
---

# 3장: LXD 초기화 및 사용자 설정

이 장에서는 루트가 되거나 루트가 되려면 `sudo`가 가능해야 합니다. 또한 [2장](02-zfs_setup.md)에 설명된 대로 ZFS 저장소 풀을 설정했다고 가정합니다. ZFS를 사용하지 않기로 선택한 경우 다른 저장소 풀을 사용할 수 있지만 초기화 질문과 답변을 조정해야 합니다.

## LXD Initialization

이제 환경이 모두 설정되었습니다. LXD를 초기화할 준비가 되었습니다. 이것은 LXD 인스턴스를 시작하고 실행하기 위해 일련의 질문을 하는 자동화된 스크립트입니다.

```
lxd init
```

다음은 스크립트에 대한 질문과 답변입니다. 필요한 경우 약간의 설명이 제공됩니다.

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

클러스터링에 관심이 있다면 [여기](https://linuxcontainers.org/lxd/docs/master/clustering/)에서 추가 조사를 해보세요.

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

이것은 ZFS 풀을 이미 만들었기 때문에 직관에 반하는 것처럼 보일 수 있지만 나중 질문에서 해결될 것입니다. 이미 ZFS 풀을 생성했지만, 나중에 나오는 질문에서 명확해질 것입니다. 기본값을 수락하세요.

```
Name of the new storage pool [default=default]: storage
```

"default"를 사용하는 것도 옵션이지만, 명확성을 위해 앞에서 지정한 ZFS 풀과 동일한 이름을 사용하는 것이 좋습니다.

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

기본값을 수락하세요.

```
Create a new ZFS pool? (yes/no) [default=yes]: no
```

앞서 스토리지 풀을 생성하는 질문에 대한 해결 방법입니다.

```
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

MAAS(Metal As A Service)는 이 문서의 범위를 벗어납니다.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

LXD 컨테이너에서 IPv6를 사용하려면 이 옵션을 켤 수 있습니다. 선택은 당신에게 달려 있습니다.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

이는 서버 스냅샷에 필요하므로 여기에서 "yes"로 대답하십시오.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

이 신뢰 비밀번호는 스냅샷 서버로부터 연결하거나 스냅샷 서버로부터 돌아오기 위한 방법입니다. 환경에 맞는 의미 있는 값으로 설정하세요. 이 항목을 암호 관리자와 같은 안전한 위치에 저장하세요.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## 사용자 권한 설정

계속하기 전에 "lxdadmin" 사용자를 생성하고 필요한 권한을 부여해야 합니다. "lxdadmin" 사용자가 root로 _sudo할 수 있도록하고 lxd 그룹의 구성원이 되어야 합니다. 사용자를 추가하고 두 그룹의 구성원임을 확인하려면 다음을 수행하세요.

```
useradd -G wheel,lxd lxdadmin
```

그런 다음 비밀번호를 설정합니다.

```
passwd lxdadmin
```

다른 비밀번호와 마찬가지로 안전한 위치에 저장하세요.
