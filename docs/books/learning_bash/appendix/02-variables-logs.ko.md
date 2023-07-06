---
title: 변수 - 로그와 함께 사용
author: Steven Spencer
contributors: Antoine Le Morvan
tested_with: 8.5
tags:
  - bash 스크립팅
  - bash
  - 변수 예제
---

# 변수 사용 - 로그를 사용한 실용적인 응용

## 소개

2과 "배시 - 변수 사용"에서는 변수를 사용하는 몇 가지 방법을 보고 어떤 변수에 사용할 수 있는지에 대해 많이 배웠습니다. 이는 bash 스크립트 내에서 변수를 사용하는 실제 사례 중 하나일 뿐입니다.

## 정보

시스템 관리자가 로그 파일을 처리해야 하는 경우 다른 형식이 적용되는 경우가 있습니다. `dnf.log` (`/var/log/dnf.log`)에서 정보를 얻고 싶다고 가정해 보겠습니다. `tail /var/log/dnf.log`를 사용하여 해당 로그 파일이 어떻게 보이는지 간단히 살펴보겠습니다.


```
2022-05-04T09:02:18-0400 DEBUG extras: using metadata from Thu 28 Apr 2022 04:25:35 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: powertools
2022-05-04T09:02:18-0400 DEBUG powertools: using metadata from Thu 28 Apr 2022 04:25:36 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel
2022-05-04T09:02:18-0400 DEBUG epel: using metadata from Tue 03 May 2022 11:55:16 AM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel-modular
2022-05-04T09:02:18-0400 DEBUG epel-modular: using metadata from Sun 17 Apr 2022 07:09:16 PM EDT.
2022-05-04T09:02:18-0400 INFO Last metadata expiration check: 3:07:06 ago on Wed 04 May 2022 05:55:12 AM EDT.
2022-05-04T09:02:18-0400 DDEBUG timer: sack setup: 512 ms
2022-05-04T09:02:18-0400 DDEBUG Cleaning up.
```

이제 `messages` 로그 파일 `tail /var/log/messages`를 살펴보십시오.

```
May  4 08:47:19 localhost systemd[1]: Starting dnf makecache...
May  4 08:47:19 localhost dnf[108937]: Metadata cache refreshed recently.
May  4 08:47:19 localhost systemd[1]: dnf-makecache.service: Succeeded.
May  4 08:47:19 localhost systemd[1]: Started dnf makecache.
May  4 08:51:59 localhost NetworkManager[981]: <info>  [1651668719.5310] dhcp4 (eno1): state changed extended -> extended, address=192.168.1.141
May  4 08:51:59 localhost dbus-daemon[843]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.10' (uid=0 pid=981 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
May  4 08:51:59 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
May  4 08:51:59 localhost dbus-daemon[843]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
May  4 08:51:59 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
May  4 08:52:09 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
```

마지막으로 `date` 명령의 출력을 살펴보겠습니다.

```
Wed May  4 09:47:00 EDT 2022
```

## 결론 및 목표

여기서 볼 수 있는 것은 `dnf.log` 및 `messages`라는 두 개의 로그 파일이 완전히 다른 방식으로 날짜를 표시한다는 것입니다. `date`를 사용하여 bash 스크립트의 `messages` 로그에서 정보를 가져오고 싶다면 별 어려움 없이 그렇게 할 수 있습니다. 그러나 `dnf.log`에서 동일한 정보를 얻으려면 약간의 작업이 필요합니다. 시스템 관리자는 매일 `dnf.log`를 검토하여 자신이 모르고 있거나 문제를 일으킬 수 있는 것이 시스템에 도입되지 않았는지 확인해야 한다고 가정해 보겠습니다. 이 정보를 `dnf.log` 파일에서 날짜별로 수집한 다음 매일 이메일로 전송하기를 원합니다. 이를 자동화하기 위해 `cron` 작업을 사용하지만 먼저 원하는 작업을 수행할 스크립트를 가져와야 합니다.

## 스크립트

원하는 것을 달성하기 위해 `dnf.log`에 표시된 날짜에 따라 날짜 형식을 지정하는 "today"라는 스크립트의 변수를 사용할 것입니다.  올바른 `date` 형식을 얻으려면 찾고 있는 yyyy-mm-dd 형식을 얻을 수 있는 `+%F`를 사용하고 있습니다. 우리가 관심을 갖는 것은 시간이나 다른 정보가 아니라 날짜이기 때문에 `dnf.log`에서 올바른 정보를 얻는 데 필요한 전부입니다. 스크립트의 이 정도만 시도해 보세요.

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
echo $today
```

여기서는 `echo` 명령을 사용하여 날짜 형식이 제대로 되었는지 확인합니다. 스크립트를 실행하면 다음과 같이 오늘 날짜가 포함된 출력이 표시됩니다.

```
2022-05-04
```

그렇다면 "디버그" 줄을 제거하고 계속할 수 있습니다. `/var/log/dnf.log`로 설정할 "logfile"이라는 또 다른 변수를 추가한 다음 "today" 변수를 사용하여 `grep`할 수 있는지 알아보겠습니다. 지금은 표준 출력으로 실행되도록 합시다.

```
!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile
```

`dnf.log`에는 매일 많은 정보가 포함되어 있으므로 여기서 화면에 게시하지는 않지만 오늘의 데이터만 포함된 출력이 표시되어야 합니다. 스크립트를 사용해 보고 작동하면 다음 단계로 넘어갈 수 있습니다. 출력을 확인한 후 다음 단계는 파이프 리디렉션을 수행하여 정보를 전자 메일로 보내는 것입니다.

!!! 팁

    다음 단계를 달성하려면 `mailx` 와 `postfix` 와 같은 메일 데몬이 설치되어 있어야 합니다. 서버에서 회사 이메일 주소로 이메일을 수신하기 위해 *아마도* 필요한 일부 구성도 있습니다. 이 시점에서 이러한 단계에 대해 걱정하지 마세요. 'maillog'를 확인하여 시도가 있었는지 확인한 다음 서버에서 이메일 주소로 이메일을 가져오는 작업을 할 수 있기 때문입니다. 그것은 이 문서에서 다룰 내용이 아닙니다. 지금은 다음을 수행하십시오.

    ```
    dnf install mailx postfix
    systemctl enable --now postfix
    ```

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile | /bin/mail -s "DNF logfile data for $today" systemadministrator@domain.ext
```

여기에서 스크립트에 추가된 사항을 살펴보겠습니다. 파이프 `|`를 추가하여 출력을 `/bin/mail`로 리디렉션하여 이메일 제목(`-s`)을 설정했습니다. 큰따옴표로 묶고 수신자를 "systemadministrator@domain.ext"로 설정합니다. 마지막 비트를 이메일 주소로 바꾼 다음 스크립트를 다시 실행해 보십시오.

언급했듯이 Postfix 메일 설정을 일부 변경하지 않으면 이메일을 받지 못할 수 있지만 `/var/log/maillog`에서 시도를 볼 수 있습니다.

## 다음 단계

다음으로 해야 할 일은 서버에서 이메일을 보내는 것입니다. [Postfix for Reporting](../../../guides/email/postfix_reporting.md)를 살펴보고 그 일을 시작할 수 있습니다. 또한 `cron`을 사용하여 매일 실행되도록 이 스크립트를 자동화해야 합니다. 여기에 여러 참조가 있습니다: [cron](../../../guides/automation/cron_jobs_howto.md), [anacron](../../../guides/automation/anacron.md), 그리고 [cronie](../../../guides/automation/cronie.md). 날짜 형식에 대한 자세한 내용은 `man date` 또는 [이 링크](https://man7.org/linux/man-pages/man1/date.1.html)를 확인하세요.
