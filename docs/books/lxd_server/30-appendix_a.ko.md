---
title: 부록 A - 워크스테이션 설정
author: Steven Spencer
contributors:
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 워크스테이션
---

# 부록 A - 워크스테이션 설정

LXD 서버 챕터의 일부는 아니지만, 이 절차는 Rocky Linux 워크스테이션이나 노트북에서 랩 환경이나 반영구적인 운영 체제와 응용 프로그램을 실행하려는 사용자를 도와줍니다.

## 전제 조건

* 커맨드 라인으로 편안하게
* `vi` 또는 `nano`와 같은 커맨드 라인 편집기를 유창하게 사용할 수 있어야 합니다.
* LXD를 설치하기 위해 `snapd`를 설치하기를 원하는 경우
* 매일 또는 필요할 때마다 사용하는 안정적인 테스트 환경이 필요합니다.
* root가 되거나 `sudo` 권한을 가질 수 있어야 합니다.

## 설치

커맨드 라인에서 다음 명령을 실행하여 EPEL 저장소를 설치합니다:

```
sudo dnf install epel-release 
```

설치가 완료되면 업그레이드를 진행합니다:

```
sudo dnf upgrade
```

`snapd` 설치합니다.

```
sudo dnf install snapd 
```

`snapd` 서비스 활성화합니다.

```
sudo systemctl enable snapd
```

노트북이나 워크스테이션을 재부팅합니다.

LXD를 위한 snap을 설치합니다.

```
sudo snap install lxd
```

## LXD 초기화

프로덕션 서버 챕터를 살펴보았다면, 이것은 거의 프로덕션 서버 초기화 절차와 동일합니다.

```
sudo lxd init
```

그러면 다음과 같은 질문 및 답변 대화 상자가 나타납니다.

다음은 스크립트를 위한 질문과 답변입니다. 필요한 경우 추가 설명이 있습니다.

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

클러스터링에 관심이 있다면 [여기](https://linuxcontainers.org/lxd/docs/master/clustering/)에서  클러스터링에 대해 추가적인 연구를 진행하세요.

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]: storage
```

선택적으로 기본값을 수락할 수 있습니다.

```
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

dir은 btrfs보다 약간 느립니다. 디스크를 비워두는 사전 준비를 할 수 있다면 해당 디바이스(예: /dev/sdb)를 btrfs 디바이스로 사용하고, 호스트 컴퓨터가 btrfs를 지원하는 운영 체제를 사용하고 있다면 btrfs를 선택할 수 있습니다. 하지만 Rocky Linux와 RHEL 클론은 아직 btrfs를 지원하지 않습니다. 랩 환경에는 `dir`을 사용하는 것이 좋습니다.

```
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

MAAS(Metal As A Service)는 이 문서의 범위를 벗어납니다.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

LXD 컨테이너에서 IPv6를 사용하려면 이 옵션을 활성화할 수 있습니다. 이는 선택 사항입니다.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

이는 워크스테이션을 스냅샷하기 위해 필요합니다. 여기서 "yes"로 답변하세요.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

이 신뢰 비밀번호는 스냅샷 서버에 연결하거나 스냅샷 서버로부터 다시 연결하는 데 사용됩니다. 환경에 맞는 의미 있는 값으로 설정하세요. 환경에 맞는 비밀번호를 설정하고 비밀번호 관리자와 같은 안전한 위치에 이 항목을 저장하세요.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## 사용자 권한

다음으로 해야 할 작업은 사용자를 lxd 그룹에 추가하는 것입니다. 다시 한 번 `sudo`를 사용하거나 root 권한이 필요합니다.

```
sudo usermod -a -G lxd [username]
```

여기서 [username]은 시스템에서의 사용자 이름입니다.

이 시점에서 여러 가지 변경사항을 가졌습니다. 더 진행하기 전에 컴퓨터를 재부팅하세요.

## 설치 확인

`lxd`가 시작되고 사용자에게 권한이 있는지 확인하려면 셸 프롬프트에서 다음을 실행하세요:

```
lxc list
```

`sudo`를 사용하지 않았습니다. 사용자는 이 명령을 실행할 수 있는 권한을 가지고 있습니다. 다음과 같은 결과가 표시됩니다:

```
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

만약 이 결과가 나왔다면, 당신은 지금까지 잘 따라오고 계십니다!

## 나머지

이제 "LXD Production Server"의 장(chapter)을 사용하여 계속 진행할 수 있습니다. 그러나 워크스테이션 설정에서는 덜 신경 써도 되는 몇 가지 사항이 있습니다. 다음은 시작할 때 권장되는 장(chapter)입니다:

* [5장: 이미지 설정 및 관리](05-lxd_images.md)
* [6장: 프로필](06-profiles.md)
* [8장: 컨테이너 스냅샷](08-snapshots.md)

## 더 읽어보기

* [LXD 초보자 가이드](../../guides/containers/lxd_web_servers.md)는 LXD를 생산적으로 사용하기 시작할 수 있게 도와줍니다.
* [공식 LXD 개요](https://linuxcontainers.org/lxd/introduction/)
* [공식 문서](https://linuxcontainers.org/lxd/docs/master/)

## 결론

LXD는 워크스테이션이나 서버에서 생산성을 높이기 위해 사용할 수 있는 강력한 도구입니다. 워크스테이션에서는 랩 테스트에 좋지만, 운영 체제와 응용 프로그램의 반영구적인 인스턴스를 자체 개인 공간에 유지할 수도 있습니다. 
