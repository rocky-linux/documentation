---
title: 10 스냅샷 자동화
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - 기업
  - lxd 자동화
---

# 10장: 스냅샷 자동화

이 장에서는 root 권한 또는 root가 될 수 있는 `sudo`` 권한이 필요합니다.

스냅샷 프로세스를 자동화하면 작업이 훨씬 쉬워집니다.

## 스냅샷 복사 프로세스 자동화


이 프로세스는 lxd-primary에서 수행됩니다. 가장 먼저 해야 할 일은 "refresh-containers"라는 /usr/local/sbin에서 cron이 실행할 스크립트를 생성합니다.

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

스크립트 내용은 다음과 같습니다.

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 실행 가능하게 만드십시오.

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

이 스크립트의 소유권을 lxdadmin 사용자와 그룹으로 변경합니다.

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

lxdadmin 사용자의 crontab을 설정하여 이 스크립트를 실행하도록 합니다. 이 경우, 매일 오후 10시에 실행되도록 설정합니다.

```
crontab -e
```

입력 내용은 다음과 같습니다:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

변경 사항을 저장하고 편집기를 종료합니다.

이렇게 하면 lxdadmin의 홈 디렉토리에 "refreshlog"라는 로그 파일이 생성되며, 프로세스가 작동했는지 여부에 대한 정보를 확인할 수 있습니다. 매우 중요합니다!

자동 프로시저는 때때로 실패할 수 있습니다. 일반적으로 특정 컨테이너의 갱신에 실패하는 경우입니다. 다음 명령을 사용하여 수동으로 갱신을 다시 실행할 수 있습니다(여기서는 rockylinux-test-9가 우리의 컨테이너라고 가정합니다).

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
