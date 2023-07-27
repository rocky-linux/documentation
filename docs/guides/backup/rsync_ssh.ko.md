---
title: rsync와 동기화
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li
tags:
  - 동기화
  - rsync
---

# `rsync`를 사용하여 두 시스템의 동기화 유지

## 필요 사항

이 가이드를 이해하고 따라가기 위해 필요한 모든 것은 다음과 같습니다:

* Rocky Linux를 실행하는 머신.
* 명령 줄에서 구성 파일을 수정하는 데 편안함
* 명령 줄 편집기 사용 방법 (여기서는 _vi_ 를 사용하지만 원하는 편집기를 사용할 수 있습니다)
* 루트 액세스 권한이 필요하며 이상적으로 터미널에서 루트 사용자로 로그인되어 있어야 합니다.
* 퍼블릭 및 프라이빗 SSH 키 쌍
* vi 또는 원하는 편집기를 사용하여 bash 스크립트를 생성하고 테스트할 수 있어야 합니다.
* _crontab_을 사용하여 스크립트 실행을 자동화할 수 있어야 합니다.

## 소개

SSH를 통한 `rsync` 사용은 실시간 동기화 기능을 제공하는 [lsyncd](../backup/mirroring_lsyncd.md)보다는 강력하지 않으며, 한 대의 컴퓨터에서 여러 대의 대상을 백업하는 [rsnapshot](../backup/rsnapshot_backup.md)만큼 유연하지 않습니다. 그러나 정의한 일정에 따라 두 대의 컴퓨터를 최신 상태로 유지할 수 있는 기능을 제공합니다.

대상 컴퓨터의 디렉토리를 최신 상태로 유지해야 하고 실시간 동기화는 중요하지 않은 경우 `rsync`를 통한 SSH는 아마도 최적의 솔루션일 것입니다.

이 절차에서는 루트 사용자로 모든 작업을 수행합니다. 루트로 로그인하거나 터미널에서 `sudo -s` 명령을 사용하여 루트 사용자로 전환합니다.

### `rsync` 설치

`rsync`가 이미 설치되어 있을 수 있지만, 소스 및 대상 컴퓨터에서 `rsync`를 최신 버전으로 업데이트하는 것이 가장 좋습니다.`rsync`가 최신 상태인지 확인하려면 두 컴퓨터 모두에서 다음을 수행합니다. `rsync`가 설치되고 최신 상태인지 확인하려면 두 컴퓨터에서 다음을 수행하십시오.

`dnf install rsync`

패키지가 설치되어 있지 않은 경우 `dnf`가 설치를 확인하라는 메시지가 표시되며 이미 설치된 경우 `dnf`는 업데이트를 찾고 설치하라는 메시지가 표시됩니다.

### 환경 준비

이 특정 예제에서는 대상 컴퓨터에서 `rsync`를 사용하여 소스에서 풀어오는 대신 소스에서 대상으로 푸시하는 대신 rsync를 사용합니다. 이를 위해 [SSH 키 쌍](../security/ssh_public_private_keys.md)을 설정해야 합니다. SSH 키 쌍을 생성하고 대상 컴퓨터에서 소스 컴퓨터로 암호 없이 액세스할 수 있게 되면 시작할 수 있습니다.

### `rsync` 매개변수 및 스크립트 설정

스크립트를 설정하기 전에 먼저 `rsync`에 어떤 매개변수를 사용할지 결정해야 합니다. 많은 가능성이 있으므로 [rsync 설명서](https://linux.die.net/man/1/rsync)를 살펴보세요. rsync를 사용하는 가장 일반적인 방법은 `-a` 옵션을 사용하는 것입니다. 왜 `-a` 또는 archive를 사용하는 것일까요? `-a`는 여러 옵션을 하나로 결합하며 이들은 매우 일반적인 옵션입니다. -a에는 다음이 포함됩니다.

* -r, 디렉토리 재귀
* -l, 심볼릭 링크를 심볼릭 링크로 유지
* -p, 권한 유지
* -t, 수정 시간 유지
* -g, 그룹 유지
* -o, 소유자 유지
* -D, 장치 파일 유지

이 예제에서 명시해야 하는 다른 옵션은 다음과 같습니다.

* -e, 사용할 원격 쉘 지정
* --delete, 대상 디렉터리에 소스에 없는 파일이 있으면 제거합니다.

그런 다음 스크립트를 설정하기 위해 파일을 생성합니다(만약 vi에 익숙하지 않다면 원하는 편집기를 사용하세요). 파일을 생성하려면 다음 명령을 사용하세요.

`vi /usr/local/sbin/rsync_dirs`

그리고 실행 가능하도록 만듭니다.

`chmod +x /usr/local/sbin/rsync_dirs`

## 테스트

이제 스크립트를 사용하면 테스트가 매우 간단하고 안전하게 진행됩니다. 아래에서 사용하는 URL은 "source.domain.com"입니다. 자신의 소스 컴퓨터의 도메인 또는 IP 주소로 바꿔주세요. 두 가지 모두 작동합니다. 또한 이 예제에서 스크립트는 "대상" 컴퓨터에 생성됩니다. 파일이 소스 컴퓨터에서 풀려옵니다.

```
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

!!! 주의

    이 경우 대상 머신에 홈 디렉토리가 없다고 가정합니다. **만약 존재한다면 스크립트를 실행하기 전에 백업을 해두는 것이 좋습니다!**

이제 스크립트를 실행합니다.

`/usr/local/sbin/rsync_dirs`

모든 것이 정상적으로 작동하면 대상 컴퓨터에 홈 디렉토리의 완전히 동기화된 복사본이 생성될 것입니다. 이것이 정상적으로 이루어지는지 확인하세요.

이제 가정하고자 하는 대로 모든 작업이 수행되었다고 가정하고, 소스 컴퓨터의 홈 디렉토리에 새 파일을 생성해 보세요:

`touch /home/your_user/testfile.txt`

다시 스크립트를 실행하세요:

`/usr/local/sbin/rsync_dirs`

그런 다음 대상 컴퓨터에서 새 파일이 수신되는지 확인하세요. 그렇다면 다음 단계는 삭제 프로세스를 확인하는 것입니다. 소스 컴퓨터에서 방금 생성한 파일을 삭제해 보세요:

`rm -f /home/your_user/testfile.txt`

스크립트를 다시 실행합니다.

`/usr/local/sbin/rsync_dirs`

대상 컴퓨터에서 파일이 더 이상 존재하지 않는지 확인하세요.

마지막으로, 소스에는 존재하지 않지만 대상에는 존재하는 파일을 만들어 보겠습니다. 따라서 대상에서 다음을 수행하세요:

`touch /home/your_user/a_different_file.txt`

스크립트를 마지막으로 실행합니다.

`/usr/local/sbin/rsync_dirs`

이제 대상에 방금 만든 파일이 사라져야 합니다. 왜냐하면 소스에는 존재하지 않기 때문입니다.

모든 것이 기대한 대로 작동한다고 가정하고 스크립트를 수정하여 동기화할 모든 디렉토리를 지정하세요.

## 모든 것을 자동화하기

동기화 스크립트를 수동으로 실행하는 것은 번거로울 수 있습니다. 따라서 다음 단계는 이를 자동화하는 것입니다. 예를 들어 매일 밤 11시에 이 스크립트를 실행하려면 crontab을 사용합니다: 이를 자동화하려면 crontab을 사용하십시오.

`crontab -e`

이렇게 하면 cron이 열리며 다음과 비슷할 수 있습니다:

```bash
# Edit this file to introduce tasks to be run by cron.
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
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```
cron은 24시간 형식으로 설정되어 있으므로 이 파일의 맨 아래에 다음과 같은 항목이 필요합니다:

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

이것은 매일, 매월, 매주의 모든 요일, 23시 00분에 이 명령을 실행하도록 지정합니다. cron 항목을 저장하려면 다음과 같이 입력하세요:

`Shift : wq!`

... 또는 사용하는 편집기의 파일 저장 명령을 사용하세요.

## 선택적 플래그
```
-n : Dry-Run을 실행하여 전송할 파일을 확인합니다
-v : 전송 중인 모든 파일을 나열합니다
-vvv : 파일을 전송하는 동안 디버그 정보를 제공합니다
-z : 전송 중 압축을 활성화합니다 
```


## 결론

결론적으로 `rsync`는 다른 도구들만큼 유연하거나 강력하지는 않지만, 항상 유용한 간단한 파일 동기화 기능을 제공합니다.
