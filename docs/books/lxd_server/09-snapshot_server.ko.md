---
title: 9 스냅샷 서버
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd  스냅샷 서버
---

# 9장: 스냅샷 서버

이 장에서는 실행하는 작업에 따라 권한이 있는 (root) 사용자와 권한이 없는 (lxdadmin) 사용자의 조합을 사용합니다.

처음에 언급한 대로, LXD의 스냅샷 서버는 가능한 모든 방법으로 운영 서버와 동일해야 합니다. 그 이유는 주 서버의 하드웨어가 고장 났을 때 이를 운영 환경으로 가져가야 할 수도 있기 때문입니다. 백업이 있고, 생산 컨테이너를 빠르게 다시 시작할 수 있는 방법이 있다면, 시스템 관리자의 공황 전화와 문자 메시지를 최소화할 수 있습니다. 그것은 언제나 좋은 일입니다!

따라서 스냅샷 서버를 구축하는 프로세스는 프로덕션 서버와 정확히 동일합니다. 프로덕션 서버 설정을  완벽하게 모방하기 위해, 스냅샷 서버에서 다시 **1-4장**까지의 모든 과정을 수행한 후 이어서 진행하시면 됩니다.

돌아오셨군요! 이는 스냅샷 서버의 기본 설치를 성공적으로 완료한 것을 의미합니다.

## Primary 및 Snapshot 서버 간의 관계 설정

계속하기 전에 몇 가지 정리 작업이 필요합니다. 첫째로, 운영 환경에서는 IP를 이름으로 해석할 수 있는 DNS 서버에 액세스할 수 있을 것입니다.

우리의 실험 환경에서는 그런 기능이 없습니다. 아마도 당신도 비슷한 시나리오를 실행하고 있을 것입니다. 이러한 이유로, Primary 서버와 스냅샷 서버의 IP 주소와 이름을 /etc/hosts 파일에 추가해야 합니다. 이 작업은 root (또는 _sudo_) 사용자로 수행해야 합니다.

우리의 실험 환경에서 주 LXD 서버는 192.168.1.106에서 실행되고 스냅샷 LXD 서버는 192.168.1.141에서 실행됩니다. 각 서버에 SSH로 접속하여 다음 내용을 /etc/hosts 파일에 추가하세요:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```

다음으로 두 서버 간의 모든 트래픽을 허용해야 합니다. 이를 위해 /etc/firewall.conf 파일을 다음과 같이 수정합니다. 먼저 lxd-primary 서버에서 다음 줄을 추가하세요:

```
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

그리고 스냅샷 서버에서 다음 규칙을 추가하세요:

```
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

그런 다음 다시 로드합니다:

```
firewall-cmd reload
```

다음으로, 권한이 없는 (lxdadmin) 사용자로서 두 기기 간의 신뢰 관계를 설정해야 합니다. 이를 위해 lxd-primary에서 다음 명령을 실행하세요:

```
lxc remote add lxd-snapshot
```

이렇게 하면 인증서가 표시됩니다. 인증서를 수락하고 암호를 입력하라는 메시지가 나올 것입니다. 이것은 LXD 초기화 단계를 수행할 때 설정하는 "신뢰 암호"입니다. 이 모든 암호를 안전하게 보관하고 있을 것을 바랍니다. 암호를 입력하면 다음과 같은 메시지가 표시됩니다:

```
서버에 저장된 클라이언트 인증서: lxd-snapshot
```

역으로도 이를 수행하는 것은 문제가 되지 않습니다. 예를 들어, lxd-snapshot 서버에도 신뢰 관계를 설정하세요. 이렇게 하면 필요한 경우 lxd-snapshot 서버가 스냅샷을 lxd-primary 서버로 다시 보낼 수 있습니다. 단계를 반복하고 "lxd-snapshot" 대신에 "lxd-primary"을 사용하세요.

### 첫 번째 스냅샷 마이그레이션하기

첫 번째 스냅샷을 마이그레이션하기 전에, lxd-primary에서 생성한 프로필이 lxd-snapshot에서도 생성되어 있어야 합니다. 우리의 경우 "macvlan" 프로필입니다.

lxd-snapshot에서 이를 생성해야 합니다. 필요한 경우 6장으로 돌아가서 lxd-snapshot에 "macvlan" 프로필을 생성하세요. 두 서버가 상위 인터페이스 이름이 동일한 경우("enp3s0" 예를 들어), "macvlan" 프로필을 다시 생성하지 않고 lxd-snapshot으로 복사할 수 있습니다:

```
lxc profile copy macvlan lxd-snapshot
```

관계와 프로필이 모두 설정되었다면, 다음 단계는 실제로 스냅샷을 lxd-primary에서 lxd-snapshot으로 보내는 것입니다. 정확하게 따라오셨다면 아마도 모든 스냅샷을 삭제한 상태일 것입니다. 다른 스냅샷을 생성하세요:

```
lxc snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

`lxc`의 "info" 명령을 실행하면 스냅샷이 리스트의 맨 아래에 표시됩니다:

```
lxc info rockylinux-test-9
```

아래와 같이 표시될 것입니다:

```
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

좋아요, 행운을 빕니다! L스냅샷을 마이그레이션해 봅시다:

```
lxc copy rockylinux-test-9/rockylinux-test-9-snap1 lxd-snapshot:rockylinux-test-9
```

이 명령은 컨테이너 rockylinux-test-9 내에서 스냅샷 rockylinux-test-9-snap1을 lxd-snapshot으로 보내고, 이름을 rockylinux-test-9로 지정한다는 의미입니다.

잠시 후에 복사가 완료될 것입니다. 확실하게 확인하고 싶으신가요? lxd-snapshot 서버에서 `lxc list`를 실행하세요. 다음을 반환해야 합니다.

```
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

성공입니다! 이제 시작해보세요. lxd-snapshot 서버에서 시작하려면 lxd-primary 서버에서 IP 주소 충돌을 피하기 위해 먼저 컨테이너를 중지해야 합니다:

```
lxc stop rockylinux-test-9
```

그리고 lxd-snapshot 서버에서 다음을 실행하세요:

```
lxc start rockylinux-test-9
```

모든 작업이 오류 없이 작동한다고 가정하고, lxd-snapshot에서 컨테이너를 중지한 후 lxd-primary에서 다시 시작하세요.

## 컨테이너에 대해 boot.autostart를 Off로 설정

lxd-snapshot으로 복사된 스냅샷은 마이그레이션 시에 중지 상태가 될 것입니다. 그러나 전원 이벤트가 발생하거나 업데이트로 인해 스냅샷 서버를 다시 시작해야 하는 경우 문제가 발생할 수 있습니다. 이러한 경우 해당 컨테이너는 스냅샷 서버에서 시작하려고 하여 IP 주소 충돌이 발생할 수 있습니다.

이를 방지하기 위해 마이그레이션된 컨테이너가 서버 재부팅 시 자동으로 시작하지 않도록 설정해야 합니다. 새로 복사한 rockylinux-test-9 컨테이너의 경우 다음과 같이 수행합니다:

```
lxc config set rockylinux-test-9 boot.autostart 0
```

lxd-snapshot 서버의 각 스냅샷에 대해 이 작업을 수행하세요. 명령어에서 "0"은 `boot.autostart`가 꺼져 있음을 의미합니다.

## 스냅샷 프로세스 자동화

필요할 때 스냅샷을 수동으로 생성할 수 있는 것은 좋지만, 때로는 수동으로 스냅샷을 생성하고 lxd-snapshot으로 복사하는 것이 _필요할 수_도 있습니다. lxd-snapshot에 수동으로 복사할 수도 있습니다. 그러나 대부분의 경우, 특히 lxd-primary 서버에서 여러 컨테이너를 실행할 때, 스냅샷 서버에서 스냅샷을 삭제하고 새로운 스냅샷을 생성하여 스냅샷 서버로 보내는 시간을 오후에 쓰고 싶지 않을 것입니다. 대부분의 작업에 대해서는 프로세스를 자동화하는 것이 좋습니다.

먼저, lxd-primary에서 스냅샷 생성을 자동화하기 위한 프로세스를 예약해야 합니다. lxd-primary 서버의 각 컨테이너에 대해 이 작업을 수행할 것입니다. 완료되면 계속해서 작동합니다. 다음 구문을 사용하여 이 작업을 수행합니다. 타임스탬프를 위한 크론탭 항목과 유사한 점을 주목하세요.

```
lxc config set [container_name] snapshots.schedule "50 20 * * *"
```

이 명령은 container_name의 컨테이너 이름에 대해 매일 오후 8시 50분에 스냅샷을 생성하도록 지정합니다.

우리의 rockylinux-test-9 컨테이너에 적용하기 위해 다음을 실행합니다:

```
lxc config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

스냅샷 이름도 날짜에 따라 의미 있는 이름으로 설정하려고 합니다. LXD는 어디서든 UTC를 사용하므로 우리의 추적을 위해 날짜와 시간을 이해하기 쉬운 형식의 타임스탬프로 스냅샷 이름을 설정하는 것이 가장 좋습니다.

```
lxc config set [container_name] snapshots.schedule "50 20 * * *"
```

좋습니다. 하지만 이제는 매일 새로운 스냅샷을 생성하면서 이전 스냅샷을 삭제하지 않는 것은 원하지 않을 것입니다. 스냅샷으로 드라이브를 가득 채우게 될 것입니다. 이를 수정하기 위해 다음을 실행합니다:

```
lxc config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```
