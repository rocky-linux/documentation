---
title: dnf-automatic으로 패칭
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - security
  - dnf
  - 자동화
  - updates
---

# `dnf-automatic`으로 서버 패치하기

보안 업데이트의 설치를 관리하는 것은 시스템 관리자에게 중요한 문제입니다. 소프트웨어 업데이트 제공 프로세스는 보통 큰 문제를 일으키지 않습니다. 이러한 이유로 매일 자동으로 띄어쓰기 작업과 업데이트를 자동으로 수행하는 것이 합리적입니다.

정보 시스템의 보안이 강화됩니다. `dnf-automatic`은 이를 가능하게 하는 추가 도구입니다.

!!! !!!

    여러 년 전에 이렇게 자동으로 업데이트를 적용하는 것은 재앙의 레시피였을 수 있습니다. 때때로 업데이트가 문제를 일으킬 수도 있었습니다. 지금은 이러한 경우가 드물게 발생하지만 패키지 업데이트로 인해 서버에서 사용 중인 더 이상 사용되지 않는 기능이 제거될 경우에는 가끔 문제가 발생할 수 있습니다. 그러나 대부분의 경우 현재 이는 문제가 아닙니다. 그래도 아직도 `dnf-automatic`에 업데이트를 처리하는 것에 불편함을 느낀다면 업데이트를 다운로드하거나 업데이트가 가능하다는 알림을 받도록 설정해볼 수 있습니다. 그렇게 하면 서버가 오랫동안 패치되지 않은 상태로 유지되지 않습니다. 이러한 기능은 `dnf-automatic-notifyonly` 및 `dnf-automatic-download`입니다. 이러한 기능에 대한 자세한 내용은 [공식 문서](https://dnf.readthedocs.io/en/latest/automatic.html)를 참조하세요.

## 설치

`dnf-automatic`은 Rocky 레포지토리에서 설치할 수 있습니다:

```
sudo dnf install dnf-automatic
```

## 구성

기본적으로 업데이트 프로세스는 오전 6시에 시작하며, 모든 시스템이 동일한 시간에 업데이트되는 것을 피하기 위해 임의의 추가 시간 간격을 가집니다. 이 동작을 변경하려면 응용 프로그램 서비스와 관련된 타이머 구성을 덮어써야 합니다:

```
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

이 구성은 오전 6시부터 6시 10분까지 시작 지연을 줄입니다. (이 시간에 종료된 서버는 자동으로 재시작 후 패치됩니다.)

그런 다음 서비스와 관련된 타이머를 활성화합니다(서비스 자체가 아님):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## CentOS 7 서버는 어떻습니까?

!!! !!!

    예, 이것은 Rocky Linux 문서이지만, 시스템 또는 네트워크 관리자이므로 아직도 CentOS 7 머신이 남아 있을 수 있습니다. 그래서 이 부분을 포함하고 있습니다.

CentOS 7에서의 프로세스는 유사하지만 `yum-cron`을 사용합니다.

```
$ sudo yum install yum-cron
```

이번에는 서비스 구성을 `/etc/yum/yum-cron.conf` 파일에 설정합니다.

필요한 대로 구성하세요:

```
[commands]
# 사용할 업데이트 종류:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# 업데이트가 가능하거나 다운로드 또는 적용되었을 때 메시지를 내보낼지 여부.
update_messages = yes

# 업데이트가 있을 때 다운로드할지 여부.
download_updates = yes

# 업데이트가 있을 때 적용해야 하는지 여부.  #업데이트를 적용하려면 download_updates도 yes여야 합니다.
apply_updates = yes

# 무작위로 잠자기 위한 최대 시간(분).  #프로그램은 실행되기 전에 0분에서 random_sleep분 사이의 임의의 시간 동안 휴면 상태가 됩니다.  # 이 기능은 여러 시스템이 업데이트 서버에 액세스하는 시간을 지연시키는 데 유용합니다.  #random_sleep이 0 또는 음수이면 프로그램이 즉시 실행됩니다.
# 6*60 = 360
random_sleep = 30
```

구성 파일의 주석은 스스로 설명합니다.

이제 서비스를 활성화하고 시작할 수 있습니다:

```
$ sudo systemctl enable --now yum-cron
```

## 결론

패키지의 자동 업데이트는 간단히 활성화되며 정보 시스템의 보안을 크게 향상시킵니다.
