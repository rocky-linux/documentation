---
title: cron - 명령 자동화
author: Steven Spencer
contributors: Ezequiel Bruni
tested on: 8.5
tags:
  - 작업 자동화
  - 자동화
  - cron
---

# `cron` 및 `crontab`으로 프로세스 자동화

## 필요 사항

* Rocky Linux가 설치된 컴퓨터.
* 즐겨찾는 편집기를 사용하여 명령줄에서 구성 파일을 수정할 수 있습니다(여기서는 `vi` 사용)

## <a name="assumptions"></a> 전제 조건

* bash, python 또는 기타 스크립팅 또는 프로그래밍 도구의 기본 지식이 있으며, 스크립트를 자동으로 실행하려는 경우입니다.
* root 사용자로 실행 중이거나 `sudo -s`를 사용하여 root로 전환했는지 확인합니다. **(일부 디렉토리에 있는 특정 스크립트를 사용자로서 실행할 수도 있습니다. 이 경우에는 root로 전환할 필요가 없습니다.)**

## 소개

Linux는 프로세스 자동화를 위한 시간 기반 작업 스케줄러인 _cron_ 시스템을 제공합니다. 이는 단순하면서도 매우 강력합니다. 매일 오후 5시에 스크립트나 프로그램을 실행하려면 cron 시스템을 설정하는 곳입니다. 이것이 당신이 그것을 하는 곳입니다.

_crontab_ 은 사용자가 자신의 자동화된 작업과 작업을 추가하는 목록입니다. 많은 옵션을 가지고 있어 작업을 더욱 간소화할 수 있습니다. 이 문서에서는 이러한 기능을 탐색합니다. 어느 정도의 경험이 있는 사용자에게는 잘 알려진 내용을 상기시키는 좋은 기회이며, 새로운 사용자는 `cron` 시스템을 도구 상자에 추가할 수 있습니다.

`anacron`은 `cron` "dot" 디렉토리와 관련하여 간단히 설명됩니다. `cron`은 `anacron`에서 실행되며, 워크스테이션 및 노트북과 같이 항상 켜져 있지 않은 컴퓨터에 유용합니다. 이는 `cron`이 작업을 일정에 맞춰 실행하지만, 작업이 예약된 시간에 컴퓨터가 꺼져 있으면 작업이 실행되지 않는다는 것을 의미합니다. `anacron`을 사용하면 컴퓨터가 다시 켜질 때 예약된 실행이 과거에 있더라도 작업이 실행됩니다. 그러나 `anacron`은 실행 타이밍이 정확하지 않은 더 무작위적인 접근 방식을 사용합니다. 이는 워크스테이션과 노트북에는 적합하지만 서버에는 적합하지 않습니다. 예를 들어 서버 백업은 특정 시간에 작업을 실행해야 하므로 이러한 접근 방식은 문제가 될 수 있습니다. 이 때 `cron`이 서버 관리자에게 가장 좋은 솔루션을 제공합니다. 그러나 서버 관리자와 워크스테이션 또는 노트북 사용자는 두 가지 접근 방식에서 모두 이점을 얻을 수 있습니다. 필요에 따라 혼합해서 사용할 수 있습니다. `anacron`에 대한 자세한 내용은 [anacron - 명령 자동화](anacron.md)를 참조하세요.

### <a name="starting-easy"></a>쉬운 시작 - `cron` Dot 디렉토리

많은 버전의 Linux 시스템에 기본적으로 내장된 `cron` "dot" 디렉토리는 프로세스를 빠르게 자동화하는 데 도움을 줍니다. 이러한 디렉토리는 `cron` 시스템이 호출하는 디렉터리로 나타나며, 이름 규칙에 따라 다르게 실행됩니다. 그러나 호출하는 프로세스인 `anacron` 또는 `cron`에 따라 다르게 실행됩니다. 기본 동작은 `anacron`을 사용하는 것이지만, 이는 서버, 워크스테이션 또는 노트북 관리자에 의해 변경될 수 있습니다.

#### <a name="for_servers"></a>서버

소개에서 언급한 대로, `cron`은 일반적으로 스크립트를 이러한 "dot" 디렉터리에서 실행하기 위해 최근에는 `anacron`을 실행합니다. 이러한 "dot" 디렉터리를 서버에서도 사용하려는 경우, 이러한 "dot" 디렉터리가 엄격한 일정에 따라 실행되도록 확인하기 위해 두 가지 단계를 거쳐야 합니다. 이를 위해서 패키지를 설치하고 다른 패키지를 제거해야 합니다:

`dnf install cronie-noanacron`

그리고

`dnf remove cronie-anacron`

예상한 대로 이렇게 하면 `anacron`이 서버에서 제거되고 "dot" 디렉터리의 작업이 엄격한 일정에 따라 실행됩니다. 일정을 제어하는 파일은 `/etc/cron.d/dailyjobs`이며, 다음과 같은 내용을 포함합니다:

```
# cronie-anacron이 설치되지 않은 경우 매일, 매주, 매월 작업 실행
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# 실행 부분
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

이는 다음과 같이 해석됩니다.

* 매일 04:02:00에 `cron.daily` 디렉터리의 스크립트 실행.
* 매주 일요일 04:22:00에 `cron.weekly` 디렉터리의 스크립트 실행.
* 매월 1일 04:42:00에 `cron.monthly` 디렉터리의 스크립트 실행.

#### <a name="for_workstations"></a>워크스테이션

`cron` "dot" 디렉터리에서 스크립트를 실행하려는 경우, 워크스테이션이나 노트북에서는 특별한 처리가 필요하지 않습니다. 관련 디렉터리에 스크립트 파일을 복사하고 실행 가능하도록 만들기만 하면 됩니다. 다음은 디렉터리입니다:

* `/etc/cron.hourly` - 스크립트는 매시간 정각 한 분 후에 실행됩니다 (이는 `anacron`이 설치되었는지 여부와 상관없이 `cron`에 의해 실행됩니다)
* `/etc/cron.daily` - 스크립트는 매일 실행됩니다. `anacron`이 실행 시간을 조정합니다 (팁 참조)
* `/etc/cron.weekly` - 스크립트는 매주 실행됩니다. 최근 실행 시간의 달력 일에 기반합니다 (팁 참조)
* `/etc/cron.monthly` - 스크립트는 매월 실행됩니다. 최근 실행 시간의 달력 일에 기반합니다 (팁 참조)

!!! !!!

    이들은 매일, 매주, 매월 비슷한(정확히 같지는 않지만) 시간에 실행될 가능성이 높습니다. 보다 정확한 실행 시간은 아래의 @options를 참조하십시오.

시스템이 스크립트를 자동으로 실행하고 지정된 시간 동안 언제 실행될지를 허용하는 경우, 작업의 자동화가 단순화됩니다.

!!! 참고사항

    서버 관리자가 `anacron`이 "dot" 디렉터리의 스크립트를 실행하는 무작위 실행 시간을 사용하지 않을 수 있는 규칙은 없습니다. 이 경우에는 시간에 민감하지 않은 스크립트에 사용됩니다.

### 나만의 `cron` 만들기

자동화된 무작위 실행 시간이 [위의 워크스테이션](#for-workstations)에에서 잘 작동하지 않거나  [위의 서버](#for-servers)에서 예약된 시간이 제대로 작동하지 않는 경우 직접 cron을 생성할 수 있습니다. 이 예제에서는 root 사용자로 작업하는 것을 전제로 합니다. 이를 위해 [가정](#assumptions)를 보고 다음을 입력합니다:

`crontab -e`

명령을 실행하면 선택한 편집기에서 현재 root 사용자의 `crontab` 파일을 열게 됩니다. 다음과 같이 보일 수 있으며, 각 필드에 대한 설명이 포함된 주석 버전을 읽어보세요:

```
# 이 파일을 편집하여 cron에서 실행할 작업을 소개합니다.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

이 특정 `crontab` 파일은 자체적인 문서가 내장되어 있는 것을 알 수 있습니다. 항상 그런 것은 아닙니다. 컨테이너나 미니멀한 운영 체제에서 `crontab`을 수정할 때 `crontab`은 항목이 없으면 빈 파일이 됩니다.

백업 스크립트를 밤 10시에 실행하려고 가정해 봅시다. `crontab`은 24시간 형식을 사용하므로 이는 22:00이 됩니다. 백업 스크립트의 이름은 "backup"이며, 현재 _/usr/local/sbin_ 디렉토리에 있는 것으로 가정합니다.

!!! 참고사항

    `cron`이 실행하려면 이 스크립트도 실행 가능해야 합니다(`chmod +x`).

실행 중인 현재 작업을 나열하려면 다음과 같이 하십시오

`crontab -l`

사용자가 생성한 모든 작업을 나열하려면

`crontab -l -u <username>`

작업을 추가하려면 다음을 수행합니다.

`crontab -e`

`crontab`은 "cron table"을 의미하며, 파일 형식은 사실상 느슨한 테이블 레이아웃입니다. 이제 `crontab`에 들어갑니다. 파일 끝으로 이동하여 새 항목을 추가합니다. 기본 시스템 편집기로 `vi`를 사용하는 경우 다음 키를 사용합니다:

`Shift : $`

파일 끝에 도달하면 줄을 삽입하고 새 항목에 대한 간단한 설명을 입력합니다. 이를 위해 줄의 맨 앞에 "#"를 추가합니다:

`# Backing up the system every night at 10PM`

Enter를 누릅니다. 여전히 삽입 모드에 있어야 하므로 다음 단계는 항목을 추가하는 것입니다. 빈 주석 처리된 `crontab` (위)에서 볼 수 있듯이 **m**은 분, **h**는 시간, **dom**은 월의 일, **mon**은 월, **dow**는 요일을 나타냅니다.

백업 스크립트를 매일 오후 10시에 실행하려면 다음과 같은 항목을 작성합니다:

`00  22  *  *  *   /usr/local/sbin/backup`

이것은 매일 오후 10시에 스크립트를 실행하도록 지정합니다. 이것은 간단한 예시이며 특정 요구 사항이 있는 경우 매우 복잡해질 수 있습니다.

### `crontab`에 대한 @options

또한 엄격한 일정(예: day, week, month, year, 등)에 따라 작업을 실행하는 다른 방법은 @options을 사용하는 것입니다. @options은 더 자연스러운 타이밍을 사용할 수 있습니다. @options은 다음과 같습니다.

* `@hourly` 는 매시 정각마다 매일 스크립트를 실행합니다 (이는 스크립트를 `/etc/cron.hourly`에 두는 것과 정확히 동일한 결과입니다).
* `@daily`는 매일 자정에 스크립트를 실행합니다.
* `@weekly`는 매주 일요일 자정에 스크립트를 실행합니다.
* `@monthly`는 매월 1일 자정에 스크립트를 실행합니다.
* `@yearly`는 매년 1월 1일 자정에 스크립트를 실행합니다.
* `@reboot`는 시스템 시작 시에만 스크립트를 실행합니다.

!!! 참고사항

    이러한 `crontab` 항목을 사용하면 `anacron` 시스템을 우회하고 `anacron` 설치 여부에 관계없이 `crond.service`로 되돌아갑니다.

백업 스크립트 예제에서 @daily 옵션을 사용하여 자정에 백업 스크립트를 실행하려면 항목은 다음과 같습니다:

`@daily  /usr/local/sbin/backup`

### 더 복잡한 옵션

지금까지 사용한 해결책은 꽤 단순한 옵션이었지만 더 복잡한 작업 시간을 사용하려면 어떨까요? 예를 들어 하루 종일 백업 스크립트를 매 10분마다 실행하려는 경우 (아마 실제로는 실용적이지 않을 수 있지만 예시입니다!). crontab은 다음과 같을 것입니다:

`*/10  *   *   *   *   /usr/local/sbin/backup`

매 10분마다 실행하되 월요일, 수요일 및 금요일에만 실행하려면:

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

토요일과 일요일을 제외한 매일 10분마다 실행하려면:

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

표에서 쉼표를 사용하여 필드 내에서 개별 항목을 지정할 수 있으며 대시는 필드 내의 값 범위를 지정할 수 있습니다. 이것은 모든 필드에 대해 참이며 동시에 많은 필드에 대해서도 참입니다. 복잡해질 수 있음을 알 수 있습니다.

스크립트를 실행할 시기를 결정할 때는 시간을 내어 계획해야 하며, 기준이 복잡한 경우 특히 그렇게 해야 합니다.

## 결론

_cron/crontab_ 시스템은 Rocky Linux 시스템 관리자나 데스크톱 사용자에게 강력한 도구입니다. 이를 사용하면 작업과 스크립트를 자동화하여 수동으로 실행하지 않아도 됩니다. 더 복잡한 예시는 다음 위치에서 확인할 수 있습니다.

* **하루 종일 작동하지 않는 기기**의 경우, [anacron - 명령 자동화](anacron.md)를 살펴보세요.
* `cron` 프로세스에 대한 간략한 설명은 [cronie - 타이밍 작업](cronie.md)을 참조하세요.

기본적인 내용은 꽤 쉽지만 옵션은 더 복잡할 수 있습니다. `crontab`에 대한 자세한 정보는 [crontab 메뉴얼 페이지](https://man7.org/linux/man-pages/man5/crontab.5.html)를 참조하세요. 대부분의 시스템에서도 `man crontab`을 입력하여 추가적인 명령어 세부 정보를 얻을 수 있습니다. 또한 "crontab"으로 웹 검색을 수행하면 `crontab` 기술을 더욱 세밀하게 조정하는 데 도움이 되는 다양한 결과가 나타납니다.
