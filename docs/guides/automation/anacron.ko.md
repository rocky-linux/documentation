---
title: anacron - 명령 자동화
author: tianci li
contributors: Steven Spencer
update: 2021-10-20
---

# `anacron` - 정기적으로 명령 실행

## 필요 사항

* Rocky Linux가 설치된 컴퓨터.
* 선호하는 편집기를 사용하여 명령줄 환경에서 구성 파일(예: *vim*)을 변경하는 방법을 알아두십시오.
* 기본적인 RPM 패키지 관리에 대한 이해가 필요합니다.

## 전제 조건

* bash, python 또는 기타 스크립팅 또는 프로그래밍 도구의 기본적인 지식을 이해하고 자동으로 스크립트를 실행하려는 경우입니다.
* root 사용자로 로그인했거나 `su - root`를 사용하여 root로 전환했습니다.

## `anacron` 소개

**`anacron`정기적으로 명령을 실행하며 운영 빈도는 일(day) 단위로 정의됩니다. 노트북 및 데스크탑과 같이 24/7 동작하지 않는 컴퓨터에 적합합니다. 예를 들어 매일 새벽에 실행되어야 하는 예약된 작업(백업 스크립트와 같은)을 crontab을 사용하여 실행하도록 예약했습니다. 잠들면 데스크탑이나 노트북이 꺼집니다. 백업 스크립트가 실행되지 않습니다. 그러나 `anacron`을 사용하면 다음 번에 데스크탑이나 노트북을 켤 때 백업 스크립트가 실행될 것입니다.**

`anacron`의 등장은 `crontab`을 대체하기 위한 것이 아니라 `crontab`을 보완하기 위한 것입니다. 그들의 관계는 다음과 같습니다:

![ 관계 ](../images/anacron_01.png)

## `anacron` 구성 파일

```bash
shell > rpm -ql cronie-anacron
/etc/anacrontab
/etc/cron.hourly/0anacron
/usr/lib/.build-id
/usr/lib/.build-id/0e
/usr/lib/.build-id/0e/6b094fa55505597cb69dc5a6b7f5f30b04d40f
/usr/sbin/anacron
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man8/anacron.8.gz
/var/spool/anacron
/var/spool/anacron/cron.daily
/var/spool/anacron/cron.monthly
/var/spool/anacron/cron.weekly
```

먼저 기본 구성 파일을 확인합니다.
```bash
shell > cat /etc/anacrontab
# /etc/anacrontab: anacron 설정 파일
# 자세한 내용은 anacron(8) 및 anacrontab(5) 를 참조하십시오.
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# 지정된 각 작업에 대해 기본 45분 지연 시간은 0-45분 증가합니다.
RANDOM_DELAY=45
# 근무 시간 범위를 지정합니다. 여기에는 3:00 ~ 22:00이 표시됩니다. START_HOURS_RANGE=3-22
# 기간(일) 지연(분) job-identifier 명령
# 매일 부팅하여 /etc/cron.daily 디렉토리의 파일이 5분 안에 실행되는지 확인하고, 오늘 실행되지 않으면 다음으로 실행합니다. 1 5 cron.daily nice run-parts /etc/cron.daily
# 부팅 후 /etc/cron.weekly 디렉토리 파일 검사를 25분 이내에 7일마다 실행하고, 1주일 이내에 실행하지 않으면 다음에 실행
7 25 cron.weekly nice run-parts /etc/cron.weekly
# /etc/cron.monthly 45분 디렉토리에 있는 파일을 한 달 동안 시작할 때마다 검사하는지 여부
@monthly 45 cron.monthly nice run-parts /etc/cron.monthly.
```

**/etc/cron.hourly/** - `journalctl -u crond.service`를 통해 내부에 넣은 파일들이 실제로 crond.server에 의해 호출됨을 알 수 있습니다. 이는 명령이 매시간 1분 후에 실행됨을 의미합니다. 다음과 같습니다.

```bash
shell > cat /etc/cron.d/0hourly
# 매시간 작업 실행
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 *  *  *  * root run-parts /etc/cron.hourly
```
```
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-20 23:32:42 CST. -
October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)

```

구성 파일 정보에 대한 자세한 내용은 [매뉴얼 페이지 찾아보기](https://man7.org/linux/man-pages/man5/anacrontab.5.html)를 참조하십시오.

## User 사용

특정 파일을 이러한 자동으로 정의된 시간 내에서 실행하도록 하려면, 단지 스크립트 파일을 해당 디렉터리로 복사하고 **x 실행 권한 (chmod +x)**이 있는지 확인하면 됩니다. 따라서 이러한 예약된 시간 중 하나에 시스템이 스크립트를 자동으로 실행하도록만 하면 자동화 작업이 간소화됩니다.

/etc/anacrontab의 실행 프로세스를 설명하기 위해 cron.daily를 사용하겠습니다:

1. `anacron`은 **/var/spool/anacron/cron.daily** 파일을 읽고 파일의 내용은 마지막 실행 시간을 보여줍니다.
2. 현재 시간과 비교하여 두 시간의 차이가 1일을 초과하면 cron.daily 작업이 실행됩니다.
3. 이 작업은 03:00~22:00에만 진행됩니다.
4. 부팅 후 5분 후에 파일이 실행되는지 확인합니다. 첫 번째 작업이 실행될 때, 다음 작업을을 실행하기 위해 0~45분 동안 임의로 지연됩니다.
5. nice 매개 변수를 사용하여 기본 우선 순위를 지정하고 run-parts 매개 변수를 사용하여 /etc/cron.daily/ 디렉토리의 모든 실행 파일을 실행합니다.

## 관련 명령

`anacron` 명령을 사용하세요. 일반적으로 사용되는 옵션은 다음과 같습니다.

| 옵션 | 설명                                     |
| -- | -------------------------------------- |
| -f | 타임스탬프를 무시하고 모든 작업을 실행합니다.              |
| -u | 아무 작업도 수행하지 않고 타임스탬프를 현재 시간으로 업데이트합니다. |
| -T | 구성 파일 /etc/anacrontab의 유효성 테스트합니다.     |

자세한 도움말 정보는 [매뉴얼 페이지](https://man7.org/linux/man-pages/man8/anacron.8.html)를 참조하세요.
