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

이 장에서는 루트가 되거나 루트가 되려면 `sudo`가 가능해야 합니다.

스냅샷 프로세스를 자동화하면 작업이 훨씬 쉬워집니다.

## 스냅샷 복사 프로세스 자동화


이 프로세스는 lxd-primary에서 수행됩니다. 가장 먼저 해야 할 일은 "refresh-containers"라는 /usr/local/sbin에서 cron이 실행할 스크립트를 만드는 것입니다.

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

스크립트는 매우 간단합니다.

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

이 스크립트의 소유권을 lxdadmin 사용자 및 그룹으로 변경합니다.

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

lxdadmin 사용자가 이 스크립트를 실행하도록 crontab을 설정합니다(이 경우 오후 10시).

```
crontab -e
```

입력 내용은 다음과 같습니다:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

변경 사항을 저장하고 편집기를 종료합니다.

이렇게 하면 "refreshlog"라는 lxdadmin의 홈 디렉토리에 로그인이 생성되어 프로세스가 작동했는지 여부를 알 수 있습니다. 매우 중요합니다!

자동 절차는 때때로 실패할 수 있습니다. 이는 일반적으로 특정 컨테이너가 새로고침되지 않을 때 발생합니다. 다음 명령을 사용하여 새로 고침을 수동으로 다시 실행할 수 있습니다(여기서는 rockylinux-test-9를 컨테이너로 가정).

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
