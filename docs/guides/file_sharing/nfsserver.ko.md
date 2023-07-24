---
title: 네트워크 파일 시스템
author: Antoine Le Morvan
contributors: Steven Spencer, OSSLAB
---

# 네트워크 파일 시스템

**지식**: :star: :star:   
**복잡성**: :star: :star:

**소요 시간**: 15분

**N**etwork **F**ile **S**ystem (**NFS**)은 네트워크로 마운트된 파일 공유 시스템입니다.

## 개요

NFS는 클라이언트/서버 프로토콜입니다. 서버는 네트워크의 전체 또는 일부를 위해 파일 시스템 리소스를 제공합니다(클라이언트).

클라이언트와 서버 간의 통신은 **R**emote **P**rocedure **C**all (**RPC**) 서비스를 통해 이루어집니다.

원격 파일은 디렉토리에 마운트되어 로컬 파일 시스템처럼 나타납니다. 클라이언트 사용자는 서버가 공유하는 파일에 원활하게 접근하여 로컬 디렉토리를 탐색할 수 있습니다.

## 설치

NFS는 다음 두 가지 서비스를 필요로 합니다:

* `network` 서비스 (물론)
* `rpcbind` 서비스

서비스 상태는 다음 명령으로 확인할 수 있습니다:

```
systemctl status rpcbind
```

만약 `nfs-utils`` 패키지가 설치되어 있지 않다면:

```
sudo dnf install nfs-utils
```

`nfs-utils` 패키지는 `rpcbind`를 포함하여 여러 종속성을 필요로 합니다.

NFS 서비스를 시작합니다:

```
sudo systemctl enable --now nfs-server rpcbind
```

NFS 서비스를 설치하면 다음 두 개의 사용자가 생성됩니다:

* `nobody`: 익명 연결에 사용됨
* `rpcuser`: RPC 프로토콜 동작에 사용됨

방화벽 설정이 필요합니다:

```
sudo firewall-cmd --add-service={nfs,nfs3,mountd,rpc-bind} --permanent 
sudo firewall-cmd --reload
```

## 서버 구성

!!! warning "경고"

    디렉토리 권한과 NFS 권한은 일관성이 있어야 합니다.

### `/etc/exports` 파일

`/etc/exports` 파일을 사용하여 리소스 공유를 설정합니다. 이 파일의 각 줄은 NFS 공유에 해당합니다.

```
/share_name client1(permissions) client2(permissions)
```

* **/share_name**: 공유 디렉토리의 절대 경로
* **clients**: 리소스에 액세스할 수 있는 클라이언트들
* **(permissions)**: 리소스의 권한

리소스에 액세스할 수 있는 기계를 다음과 같이 지정할 수 있습니다:

* **IP 주소**: `192.168.1.2`
* **Network 주소**: `192.168.1.0/255.255.255.0` 또는 CIDR 형식 `192.168.1.0/24`
* **FQDN**: client_*.rockylinux.org: rockylinux.org 도메인에서 client_로 시작하는 FQDN 허용
* `*` for everybody

하나의 줄에 여러 클라이언트를 지정하는 것도 가능합니다. 여러 클라이언트를 공유하려면 공백으로 구분합니다.

### 리소스의 권한

두 가지 유형의 권한이 있습니다:

* `ro`: read-only(읽기 전용)
* `rw`: read-write(읽기/쓰기)

만약 권한이 지정되지 않았다면, 읽기 전용 권한이 적용됩니다.

기본적으로 NFS 서버는 클라이언트 사용자 UID와 GID를 보존합니다(단, `root`는 제외).

리소스를 작성하는 사용자의 UID나 GID가 아닌 다른 UID나 GID를 사용하도록 강제하려면 `anonuid=UID`와 `anongid=GID` 옵션을 지정하거나 `all_squash` 옵션으로 데이터에 대해 `anonymous` 액세스를 제공합니다.

!!! warning "경고" 

    `no_root_squash`라는 매개변수는 클라이언트의 root 사용자를 서버의 root 사용자로 식별합니다. 이 매개변수는 시스템 보안 관점에서 위험할 수 있습니다.

`root_squash` 매개변수의 활성화는 기본값입니다(지정하지 않아도 됨). 이로 인해 `root`는 `anonymous` 사용자로 식별됩니다.

### 사례 연구

* `/share client(ro,all_squash)` : 클라이언트 사용자는 리소스에 대해 읽기 전용 액세스하며 서버에서 익명으로 식별됩니다.

* `/share client(rw)` : 클라이언트 사용자는 리소스를 수정할 수 있으며 서버에서는 사용자의 UID를 유지합니다. 오직 `root`만이 `anonymous`으로 식별됩니다.

* `/share client1(rw) client2(ro)` : 클라이언트 워크스테이션 1의 사용자는 리소스를 수정할 수 있고, 클라이언트 워크스테이션 2의 사용자는 읽기 전용 액세스를 갖습니다. 서버에서는 사용자의 UID를 유지하며 오직 `root`만이 `anonymous`으로 식별됩니다.

* `/share client(rw,all_squash,anonuid=1001,anongid=100)`: Client1 사용자는 리소스를 수정할 수 있습니다. 그들의 UID는 서버에서 `1001`로 변경되며 GID는 `100`으로 변경됩니다.

### `exportfs` 명령

`exportfs`(exported file systems - 내보낸 파일 시스템) 명령은 NFS 클라이언트와 공유된 로컬 파일 시스템의 테이블을 관리하는 데 사용됩니다.

```
exportfs [-a] [-r] [-u share_name] [-v]
```

| 옵션              | 설명                             |
| --------------- | ------------------------------ |
| `-a`            | NFS 공유를 활성화합니다                 |
| `-r`            | `/etc/exports`  파일에서 공유를 적용합니다 |
| `-u share_name` | 지정된 공유를 비활성화합니다                |
| `-v`            | 공유 목록을 표시합니다                   |

### `showmount` 명령

`showmount` 명령을 사용하여 클라이언트를 모니터링합니다.

```
showmount [-a] [-e] [host]
```

| 옵션   | 설명                  |
| ---- | ------------------- |
| `-e` | 지정된 서버에서 공유를 표시합니다  |
| `-a` | 서버에 현재 모든 공유를 표시합니다 |

이 명령은 클라이언트 워크스테이션이 공유된 리소스를 마운트할 수 있는 권한이 있는지 여부도 결정합니다.

!!! note "메모"

    `showmount`는 결과에서 정렬하고 중복을 숨기므로 클라이언트가 동일한 디렉토리를 여러 번 마운트했는지 여부를 알 수 없습니다.

## 클라이언트 구성

NFS 서버의 공유 리소스는 클라이언트의 마운트 지점을 통해 액세스할 수 있습니다.

필요에 따라 마운트할 로컬 폴더를 생성합니다:

```
$ sudo mkdir /mnt/nfs
```

서버의 NFS 공유를 마운트합니다:

```
$ showmount –e 172.16.1.10
/share *
```

서버에서 사용 가능한 NFS 공유 목록을 확인합니다:

```
$ mount –t nfs 172.16.1.10:/share /mnt/nfs
```

마운트를 시스템 시작시 자동으로 수행하려면 `/etc/fstab` 파일에 다음과 같이 설정합니다:

```
$ sudo vim /etc/fstab
172.16.1.10:/share /mnt/nfs nfs defaults 0 0
```
