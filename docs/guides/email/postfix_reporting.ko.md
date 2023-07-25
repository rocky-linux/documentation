---
title: Postfix 프로세스 보고
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - 이메일
  - reports
  - tools
---

# Postfix를 사용한 서버 프로세스 보고서 작성하기¶

## 필요 사항

* Rocky Linux 서버에서 명령 줄을 편안하게 사용할 수 있는 능력
* 선호하는 편집기에 익숙해야 합니다(이 문서에서는 _vi_ 편집기를 사용하지만, 선호하는 편집기로 대체할 수 있습니다)
* DNS(도메인 이름 시스템) 및 호스트 이름에 대한 이해
* bash 스크립트에서 변수 할당하는 방법을 알아야 합니다
* _tail_, _more_, _grep_, and _date_ 명령어의 사용 방법을 알고 있어야 합니다

## 소개

많은 Rocky Linux 서버 관리자들은 백업이나 파일 동기화와 같은 특정 작업을 수행하는 스크립트를 작성하며, 이러한 스크립트들은 유용하고 때로는 매우 중요한 정보를 담고 있는 로그를 생성합니다. 그러나 단순히 로그가 있는 것만으로는 충분하지 않습니다. 프로세스가 실패하고 그 실패를 로그에 남겼지만, 바쁜 관리자가 로그를 검토하지 않으면 대참사가 발생할 수 있습니다.

이 문서에서는 _postfix_ MTA(mail transfer agent)를 사용하여 특정 프로세스에서 로그 세부 정보를 가져와 이메일로 보내는 방법을 보여줍니다. 또한 로그에서 날짜 형식에 대해 언급하며, 보고 절차에서 사용해야 할 형식을 식별하는 데 도움이 됩니다.

그러나 이는 postfix를 통해 보고서를 생성하는 데 있어서 가능한 방법 중 하나에 불과합니다. 또한 항상 보안을 고려하여 필요한 상시 실행 프로세스만 제한하는 것이 좋습니다.

이 문서에서는 postfix를 보고에 필요한 용도로만 사용하도록 설정하고, 그 후에 다시 종료하는 방법을 보여줍니다.

## Postfix 정의

postfix는 이메일을 보내는 데 사용되는 서버 데몬입니다. sendmail보다 더 안전하고 간단하며, 오랫동안 기본 MTA로 사용되었습니다. postfix는 완전한 기능을 갖춘 메일 서버의 일부로 사용할 수 있습니다.

## postfix 설치

postfix 외에도 이메일을 보내는 기능을 테스트하기 위해 _mailx_가 필요합니다. 두 가지를 모두 설치하고 필요한 종속성을 설치하려면 Rocky Linux 서버 명령 줄에 다음을 입력합니다:

`dnf install postfix mailx`

!!! "Rocky Linux 9.0 변경 사항" 경고

    이 절차는 Rocky Linux 9.0에서 완벽하게 작동합니다. 차이점은 `mailx` 명령이 어디에서 온 것인지입니다. 8.x에서는 이름으로 설치할 수 있지만, 9.0에서는 `mailx`는 appstream 패키지인 `s-nail`에서 옵니다. 필요한 패키지를 설치하려면 다음과 같이 입력해야 합니다:

    ```
    dnf install postfix s-nail
    ```

## Postfix 테스트 및 구성

### 먼저 메일 테스트하기

postfix를 구성하기 전에 메일이 서버에서 나갈 때 어떻게 보일지 알아야 합니다. 이를 위해 postfix를 시작합니다:

`systemctl start postfix`

그런 다음 mailx로 설치된 mail 명령을 사용하여 테스트합니다:

`mail -s "Testing from server" myname@mydomain.com`

빈 줄이 나타납니다. 여기에 테스트 메시지를 입력합니다:

`testing from the server`

이제 Enter를 누르고 마침표 하나를 입력합니다:

`.`

시스템은 다음과 같이 응답합니다.

`EOT`

우리가 이것을 하는 목적은 외부 세계에서 우리의 메일이 어떻게 보이는지 확인하기 위함이며, 이를 postfix 시작 시 활성화되는 maillog에서 확인할 수 있습니다.

다음 명령을 사용하여 로그 파일의 출력을 확인합니다:

`tail /var/log/maillog`

아래와 비슷한 내용이 표시되어야 합니다(로그 파일에 이메일 주소의 다른 도메인 등이 있을 수 있습니다):

```
Mar  4 16:51:40 hedgehogct postfix/postfix-script[735]: starting the Postfix mail system
Mar  4 16:51:40 hedgehogct postfix/master[737]: daemon started -- version 3.3.1, configuration /etc/postfix
Mar  4 16:52:04 hedgehogct postfix/pickup[738]: C9D42EC0ADD: uid=0 from=<root>
Mar  4 16:52:04 hedgehogct postfix/cleanup[743]: C9D42EC0ADD: message-id=<20210304165204.C9D42EC0ADD@somehost.localdomain>
Mar  4 16:52:04 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: from=<root@somehost.localdomain>, size=457, nrcpt=1 (queue active)
Mar  4 16:52:05 hedgehogct postfix/smtp[745]: connect to gmail-smtp-in.l.google.com[2607:f8b0:4001:c03::1a]:25: Network is unreachable
Mar  4 16:52:06 hedgehogct postfix/smtp[745]: C9D42EC0ADD: to=<myname@mydomain.com>, relay=gmail-smtp-in.l.google.com[172.217.212.26]
:25, delay=1.4, delays=0.02/0.02/0.99/0.32, dsn=2.0.0, status=sent (250 2.0.0 OK  1614876726 z8si17418573ilq.142 - gsmtp)
Mar  4 16:52:06 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: removed
```
"somehost.localdomain"은 변경해야 할 부분이 있음을 보여줍니다. 따라서 먼저 postfix 데몬을 중지합니다:

`systemctl stop postfix`

## Postfix 구성

우리가 완전한 기능을 갖춘 메일 서버를 설치하는 것이 아니기 때문에 사용할 구성 옵션은 그리 많지 않습니다. 먼저 _main.cf_ 파일(말 그대로 postfix의 주 구성 파일)을 수정해야 합니다. 따라서 먼저 백업을 만들어봅시다:

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

그런 다음 편집하십시오.

`vi /etc/postfix/main.cf`

우리의 예제에서 서버 이름은 "bruno"이고 도메인 이름은 "ourdomain.com"입니다. 파일에서 다음 줄을 찾습니다:

`#myhostname = host.domain.tld`

주석(#)을 제거하거나 새로운 줄을 추가할 수 있습니다. 우리의 예제를 기반으로 한다면 다음과 같이 작성될 것입니다:

`myhostname = bruno.ourdomain.com`

다음으로 도메인 이름에 해당하는 줄을 찾습니다:

`#mydomain = domain.tld`

주석(#)을 제거하고 변경하거나 새로운 줄을 추가할 수 있습니다:

`mydomain = ourdomain.com`

마지막으로 파일의 맨 아래로 이동하여 다음 줄을 추가합니다:

`smtp_generic_maps = hash:/etc/postfix/generic`

변경 사항을 저장하고(vi에서는 `Shift : wq!`임) 파일을 종료합니다.

generic 파일을 편집하기 전에 이메일이 어떻게 보일지 확인해야 합니다. 구체적으로, 우리는 _main.cf_ 파일에서 참조한 "generic" 파일을 생성하려고 합니다:

`vi /etc/postfix/generic`

이 파일은 postfix에게 이 서버에서 온 이메일이 어떻게 보여야 하는지 알려줍니다. 우리의 테스트 이메일과 로그 파일을 기억하나요? 이곳에서 이 모든 것을 수정합니다:

```
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```
이제 postfix에게 우리의 모든 변경 사항을 사용하도록 알려줘야 합니다. 이것은 postmap 명령을 사용하여 수행합니다:

`postmap /etc/postfix/generic`

이제 postfix를 시작하고 앞에서 사용한 절차와 동일한 방법으로 이메일을 다시 테스트합니다. 이제 "localdomain" 인스턴스가 모두 실제 도메인으로 변경된 것을 확인해야 합니다.

### date 명령과 today라는 변수¶

각 응용 프로그램은 날짜에 대해 동일한 로깅 형식을 사용하지 않을 수 있습니다. 따라서 날짜별 보고서를 작성하는 데 작성하는 스크립트에서 창의적으로 대응해야 할 수도 있습니다.

예를 들어, dbus-daemon에 대한 오늘 날짜의 시스템 로그를 보고싶다고 가정해봅시다. 그리고 이 로그를 이메일로 받고 싶습니다. (이것은 아마도 최선의 예제는 아니지만, 이를 통해 이를 수행하는 방법을 알 수 있을 것입니다.)

스크립트에서는 "today"라는 변수를 사용하고, "date" 명령에서 출력된 형식을 원하는 방식으로 지정합니다. 그러기 위해 시스템 로그(_/var/log/messages_)에서 필요한 데이터를 가져올 수 있습니다. 먼저 조사를 시작해봅시다.

먼저, 명령 줄에 date 명령을 입력합니다:

`date`

이렇게 하면 기본 시스템 날짜 출력을 얻을 수 있으며, 다음과 같을 수 있습니다:

`Thu Mar  4 18:52:28 UTC 2021`

그런 다음 시스템 로그를 확인하고 정보를 기록하는 방식을 알아봅시다. 이를 위해 "more"와 "grep" 명령을 사용합니다:

`more /var/log/messages | grep dbus-daemon`

다음과 같은 정보를 제공해야 합니다:

```
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

날짜와 로그 출력은 스크립트에서 정확히 동일해야 하므로, "today"와 같은 변수를 사용하여 날짜 형식을 살펴봅시다.

먼저, 날짜를 /var/log/messages와 같은 형식으로 포맷하는 방법을 살펴보겠습니다. [Linux 메뉴얼 페이지](https://man7.org/linux/man-pages/man1/date.1.html)를 참조하거나 명령 줄에서 `man date`를 입력하여 날짜 메뉴얼 페이지를 불러와 필요한 정보를 얻을 수 있습니다.

발견한 내용은 _/var/log/messages_와 동일한 방식으로 날짜를 포맷하려면 %b와 %e 형식 문자열을 사용해야 합니다. %b는 3자리 월을, %e는 공백으로 패딩된 일을 나타냅니다.

### 스크립트

bash 스크립트에서는 date 명령과 "today"라는 변수를 사용합니다. (기억해 주세요, "today"는 임의의 이름입니다. "late_for_dinner"라고도 할 수 있습니다!). 이 예에서는 test.sh라는 스크립트를 만들고 / _/usr/local/sbin_에 배치합니다:

`vi /usr/local/sbin/test.sh`

먼저, 우리의 스크립트의 시작을 확인해봅시다. 파일의 주석이 이 메시지를 이메일로 보낸다고 되어 있지만, 지금은 그냥 표준 로그 출력으로 보내기 때문에 정확성을 확인할 수 있습니다.

또한, 첫 번째 시도에서는 현재 날짜에 대한 모든 메시지를 가져오고 있으며, dbus-daemon 메시지만 가져오도록 수정하겠습니다. 우리는 곧 이 문제에 대해 다룰 것입니다.

또 다른 사항은 grep 명령이 출력에 파일 이름을 반환할 것이고, 이 경우에는 원하지 않기 때문에 grep에 "-h" 옵션을 추가하여 파일 이름의 접두사를 제거한 것입니다. 또한 "today" 변수가 설정되면 전체 변수를 문자열로 찾아야 하므로 모두 따옴표로 묶어야 합니다:

```
#!/bin/bash

# /var/log/messages와 일치하도록 날짜 문자열 설정
today=`date +"%b %e"`

# dbus-daemon 메시지를 가져와 이메일로 보냅니다. grep -h "$today" /var/log/messages
```

이상으로 변경 내용을 저장한 다음 스크립트를 실행합니다:

`chmod +x /usr/local/sbin/test.sh`

그런 다음 테스트해 보겠습니다:

`/usr/local/sbin/test.sh`

모든 것이 올바르게 작동하면, 오늘(/var/log/messages에 있는 모든 메시지가 아닌 dbus-daemon 메시지만 포함된)의 로그 메시지 목록을 얻게 될 것입니다.  그렇다면, 다음 단계는 dbus-daemon 메시지로 제한하는 것입니다. 따라서 스크립트를 다시 수정해봅시다:

`vi /usr/local/sbin/test.sh`

```
#!/bin/bash

# 날짜 문자열을 /var/log/messages와 일치하도록 설정
today=`date +"%b %e"`

# dbus-daemon 메시지를 가져와 이메일로 보냅니다. grep -h "$today" /var/log/messages | grep dbus-daemon
```

스크립트를 다시 실행하면 오늘 하루 동안(dbus-daemon 메시지만)의 로그 메시지를 얻게 될 것입니다 (이 가이드를 따라하는 동안 어느 날이든 상관없습니다).

그러나 여기서 마지막 단계가 있습니다. 기억해주세요, 이것을 관리자에게 이메일로 보고해야 합니다. 또한, 이 서버에서는 보고용으로만 _postfix_를 사용하므로 _postfix_가 계속 실행되지 않도록 하고, 스크립트의 처음에서 시작하고 마지막에서 중지합니다. 여기서는 _sleep_ 명령을 도입하여 이메일이 전송되고 나서 _postfix_를 다시 중지하기 전에 20초간 일시 중지합니다.  이 최종 편집에서는 방금 논의한 stop, start, 그리고 sleep 이슈를 추가하고, 내용을 관리자의 이메일로 파이프합니다.

`vi /usr/local/sbin/test.sh`

그리고 스크립트를 수정합니다:

```
#!/bin/bash

# postfix 시작
/usr/bin/systemctl start postfix

# 날짜 문자열을 /var/log/messages와 일치하도록 설정합니다
today=`date +"%b %e"`

# dbus-daemon 메시지를 받아 전자 메일로 보냅니다
grep -h "$today" /var/log/messages | grep dbus-daemon | mail -s "dbus-daemon messages for today" myname@mydomain.com

# 계속 진행하기 전에 전자 메일이 완료되었는지 확인합니다
sleep 20

# postfix 중지
/usr/bin/systemctl stop postfix
```

스크립트를 다시 실행하면 서버에서 dbus-daemon 메시지와 함께 이메일을 받게 될 것입니다.

이제 [crontab](../automation/cron_jobs_howto.md)을 사용하여 특정 시간에 이 스크립트를 실행하도록 예약할 수 있습니다.

## 결론

postfix를 사용하면 모니터링하려는 프로세스 로그를 추적할 수 있습니다. bash 스크립팅과 함께 사용하여 시스템 프로세스를 확실히 이해하고 문제가 발생하면 알림을 받을 수 있습니다.
