---
title: 클러스터링-GlusterFS
author: Antoine Le Morvan
contributors: Steven Spencer
update: 11-Feb-2022
---

# GlusterFS를 사용한 고가용성 클러스터

## 필요사항

* 명령줄 편집기에 능숙함(이 예제에서는 _vi_를 사용함)
* 명령 줄에서 명령을 실행하고 로그를 확인하는 등 일반 시스템 관리자 업무에 대한 높은 숙련도\
* 모든 명령은 root 사용자 또는 sudo로 실행됩니다.

## 소개

GlusterFS는 분산 파일 시스템입니다.

매우 높은 가용성을 갖는 클러스터로 분산된 대량의 데이터를 저장할 수 있습니다.

이는 서버 클러스터의 모든 노드에 설치되는 서버 부분으로 구성됩니다.

클라이언트는 `glusterfs` 클라이언트 또는 `mount` 명령을 통해 데이터에 액세스할 수 있습니다.

GlusterFS는 두 가지 모드로 작동할 수 있습니다.

  * 복제 모드: 클러스터의 각 노드에 모든 데이터가 있습니다.
  * 분산 모드: 데이터의 중복이 없습니다. 저장소가 실패하면 실패한 노드의 데이터가 손실됩니다.

두 모드를 모두 사용하여 적절한 수의 서버가 있는 경우 복제 및 분산 파일 시스템을 제공할 수 있습니다.

데이터는 브릭(Brick) 내에 저장됩니다.

> 브릭은 GlusterFS의 기본 저장 단위로, 신뢰할 수 있는 저장 풀의 서버에 있는 내보낸 디렉토리로 나타냅니다.

## 테스트 플랫폼

우리의 가상 플랫폼은 두 대의 서버와 클라이언트, 모두 Rocky Linux 서버로 구성되어 있습니다.

* 첫 번째 노드: node1.cluster.local - 192.168.1.10
* 두 번째 노드: node2.cluster.local - 192.168.1.11
* 클라이언트1: client1.clients.local - 192.168.1.12

!!! note "참고 사항"

    클러스터의 서버 간에 필요한 대역폭이 있는지 확인하세요.

클러스터의 각 서버에는 데이터 저장을 위한 두 번째 디스크가 있습니다.

## 디스크 준비

먼저, 클러스터의 두 서버 모두 `/data/glusterfs/vol0`에 마운트되는 새로운 LVM 논리 볼륨을 생성합니다.

```
$ sudo pvcreate /dev/sdb
$ sudo vgcreate vg_data /dev/sdb
$ sudo lvcreate -l 100%FREE -n lv_data vg_data
$ sudo mkfs.xfs /dev/vg_data/lv_data
$ sudo mkdir -p /data/glusterfs/volume1
```

!!! note "참고 사항"

    LVM이 서버에 설치되어 있지 않은 경우 다음 명령으로 설치합니다.

    ```
    $ sudo dnf install lvm2
    ```

이제 해당 논리 볼륨을 `/etc/fstab` 파일에 추가할 수 있습니다:

```
/dev/mapper/vg_data-lv_data /data/glusterfs/volume1        xfs     defaults        1 2
```

그리고 마운트하십시오:

```
$ sudo mount -a
```

데이터가 brick라는 하위 볼륨에 저장되므로, 새로운 데이터 공간에 해당하는 디렉토리를 생성합니다.

```
$ sudo mkdir /data/glusterfs/volume1/brick0
```

## 설치

이 문서를 작성하는 시점에는 원래의 CentOS Storage SIG 저장소는 더 이상 사용할 수 없으며 RockyLinux 저장소는 아직 준비되지 않았습니다.

그러나 우리는 (당분간) 보관된 버전을 사용할 것입니다.

먼저, 두 서버 모두 (버전 9에서) Gluster에 전용 저장소를 추가해야 합니다.

```
sudo dnf install centos-release-gluster9
```

!!! note "참고 사항"

    나중에 Rocky 측에서 준비되면 이 패키지의 이름을 변경할 수 있습니다.

repo 목록과 url이 더 이상 사용 가능하지 않으므로, `/etc/yum.repos.d/CentOS-Gluster-9.repo`의 내용을 변경해 보겠습니다:

```
[centos-gluster9]
name=CentOS-$releasever - Gluster 9
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-9
baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/storage/x86_64/gluster-9/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
```

이제 glusterfs 서버를 설치할 준비가 되었습니다.

```
$ sudo dnf install glusterfs glusterfs-libs glusterfs-server
```

## 방화벽 규칙

서비스가 정상적으로 작동하려면 몇 가지 규칙이 필요합니다.

```
$ sudo firewall-cmd --zone=public --add-service=glusterfs --permanent
$ sudo firewall-cmd --reload
```

또는:

```
$ sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
$ sudo firewall-cmd --zone=public --add-port=49152/tcp --permanent
$ sudo firewall-cmd --reload
```

## 이름 풀이

클러스터의 서버 이름 해결을 DNS에 맡길 수도 있고, 서버의 `/etc/hosts` 파일에 각각의 레코드를 삽입하여 이 작업을 서버에서 완료할 수도 있습니다. 이렇게 하면 DNS 장애가 발생해도 작동을 유지할 수 있습니다.

```
192.168.10.10 node1.cluster.local
192.168.10.11 node2.cluster.local
```

## 서비스 시작

더 이상 지체하지 않고 서비스를 시작하겠습니다:

```
$ sudo systemctl enable glusterfsd.service glusterd.service
$ sudo systemctl start glusterfsd.service glusterd.service
```

이제 두 노드를 동일한 풀에 추가할 준비가 되었습니다.

이 명령은 단일 노드에서 한 번만 수행해야 합니다 (여기서는 node1에서 실행):

```
sudo gluster peer probe node2.cluster.local
peer probe: success
```

확인합니다:

```
node1 $ sudo gluster peer status
Number of Peers: 1

Hostname: node2.cluster.local
Uuid: c4ff108d-0682-43b2-bc0c-311a0417fae2
State: Peer in Cluster (Connected)
Other names:
192.168.10.11

```

```
node2 $ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Connected)
Other names:
192.168.10.10
```

이제 2개의 복제본으로 볼륨을 생성할 수 있습니다:

```
$ sudo gluster volume create volume1 replica 2 node1.cluster.local:/data/glusterfs/volume1/brick0/ node2.cluster.local:/data/glusterfs/volume1/brick0/
Replica 2 volumes are prone to split-brain. Use Arbiter or Replica 3 to avoid this. See: https://docs.gluster.org/en/latest/Administrator-Guide/Split-brain-and-ways-to-deal-with-it/.
Do you still want to continue?
 (y/n) y
volume create: volume1: success: please start the volume to access data
```

!!! 참고 사항

    위 명령이 말하듯이, 2노드 클러스터는 split brain에 대해 최선의 아이디어가 아닙니다. 하지만 우리의 테스트 플랫폼 목적에는 이러한 복제본이 충분합니다.

이제 데이터에 액세스하려면 볼륨을 시작할 수 있습니다:

```
$ sudo gluster volume start volume1

volume start: volume1: success
```

볼륨 상태를 확인합니다:

```
$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node1.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1210
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1227
Self-heal Daemon on node2.cluster.local     N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

```
$ sudo gluster volume info

Volume Name: volume1
Type: Replicate
Volume ID: f51ca783-e815-4474-b256-3444af2c40c4
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: node1.cluster.local:/data/glusterfs/volume1/brick0
Brick2: node2.cluster.local:/data/glusterfs/volume1/brick0
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

상태는 "Started"이어야 합니다.

이제 볼륨에 대한 액세스를 약간 제한할 수 있습니다:

```
$ sudo gluster volume set volume1 auth.allow 192.168.10.*
```

이렇게 간단합니다.

## 클라이언트 액세스

클라이언트에서 데이터에 액세스하는 방법에는 여러 가지가 있습니다.

권장하는 방법:

```
$ sudo dnf install glusterfs-client
$ sudo mkdir /data
$ sudo mount.glusterfs node1.cluster.local:/volume1 /data
```

추가 저장소를 구성할 필요가 없습니다. 클라이언트는 이미 기본 저장소에 포함되어 있습니다.

파일을 만들고 클러스터의 모든 노드에 있는지 확인합니다:

클라이언트에서:

```
sudo touch /data/test
```

두 서버 모두에서:

```
$ ll /data/glusterfs/volume1/brick0/
total 0
-rw-r--r--. 2 root root 0 Feb  3 19:21 test
```

잘 작동합니다! 그러나 노드 1이 실패하는 경우 어떻게 될까요? 원격 액세스를 마운트할 때 지정된 노드입니다.

노드 1을 중지해 봅시다:

```
$ sudo shutdown -h now
```

노드2의 상태를 확인합니다:

```
$ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Disconnected)
Other names:
192.168.10.10
[antoine@node2 ~]$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

노드 1이 떠나갔습니다.

그리고 클라이언트에서:

```
$ ll /data/test
-rw-r--r--. 1 root root 0 Feb  4 16:41 /data/test
```

파일이 이미 존재합니다.

연결 시, glusterfs 클라이언트는 주소를 지정할 수 있는 노드 목록을 받아서 방금 목격한 투명한 스위치가 발생한 이유를 설명합니다.

## 결론

현재 저장소가 없지만, CentOS가 GlusterFS에 대해 가진 보관된 저장소를 사용하면 여전히 작동합니다. 설치와 유지 관리가 꽤 쉽습니다. 명령 줄 도구를 사용하는 것은 매우 간단한 과정입니다. GlusterFS를 사용하면 데이터 저장과 중복성을 위한 고가용성 클러스터를 생성하고 유지 관리하는 데 도움이 됩니다. GlusterFS와 도구 사용에 대한 자세한 정보는 [공식 설명서 페이지](https://docs.gluster.org/en/latest/)에서 찾을 수 있습니다.
