---
title: PAM 인증 모듈
author: Antoine Le Morvan
contributors: Steven Spencer, Ezequiel Bruni
tested_with: 8.5, 8.6
tags:
  - security
  - pam
---

# PAM 인증 모듈

## 전제 조건 및 가정

* 중요하지 않은 Rocky Linux PC, 서버 또는 VM
* 루트 권한
* 기존 Linux 지식(많은 도움이 됨)
* Linux에서 사용자 및 애플리케이션 인증에 대해 학습하고자 하는 의지
* 자신의 행동 결과를 수용할 수 있는 능력

## 소개

PAM(**Pluggable Authentication Modules**)은 GNU/Linux 시스템에서 많은 애플리케이션 또는 서비스가 사용자를 중앙집중식으로 인증할 수 있도록 하는 시스템입니다. 다른 말로 설명하면 다음과 같습니다.

> PAM은 리눅스 시스템 관리자가 사용자를 인증하는 방법을 구성할 수 있도록 하는 라이브러리 스위트입니다. 응용 프로그램 코드를 변경하는 대신 구성 파일을 사용하여 보호된 애플리케이션의 인증 방법을 유연하고 중앙집중식으로 전환할 수 있습니다. \- [Wikipedia](https://en.wikipedia.org/wiki/Linux_PAM)

이 문서는 기계를 정확하게 보호하는 방법을 가르치기 위한 것이 *아닙니다*. PAM이 무엇을 *할 수 있는지*, 무엇을 *해야* 하는지를 보여주기 위한 참고 가이드입니다.

## 일반 사항

인증은 원하는 사람이 진짜 본인인지 확인하는 단계입니다. 가장 일반적인 예는 비밀번호이지만 다른 형태의 인증도 있습니다.

![PAM generalities](images/pam-001.png)

새로운 인증 방법의 구현은 프로그램이나 서비스의 구성 또는 소스 코드 변경을 필요로 하지 않아야 합니다. 이것이 응용 프로그램이 사용자를 인증하기 위해 필요한 기본 기능(원시 도구)을 제공하는 PAM에 의존하는 이유입니다.

따라서 시스템의 모든 애플리케이션은 **SSO**(Single Sign On), **OTP**(One Time password) 또는 **Kerberos**와 같은 복잡한 기능을 완전히 투명하게 구현할 수 있습니다. 시스템 관리자는 애플리케이션과 독립적으로 단일 애플리케이션(예: SSH 서비스를 보안하도록)에 대해 사용될 인증 정책을 정확히 선택할 수 있습니다.

PAM을 지원하는 각 애플리케이션 또는 서비스에는 `/etc/pam.d/` 디렉토리에 해당하는 구성 파일이 있습니다. 예를 들어, `login` 프로세스는 구성 파일을 `/etc/pam.d/login`에 지정합니다.

\* 원시 도구(primitives)는 프로그램이나 언어의 가장 기본적인 요소로, 그 위에 더 정교하고 복잡한 것들을 구축할 수 있게 합니다.

!!! 경고

    PAM의 구성이 잘못되면 전체 시스템의 보안이 위험에 처할 수 있습니다. PAM이 취약하면 전체 시스템이 취약합니다. 변경 사항을 주의하여 수행하세요.

## 지시어

지시어는 애플리케이션을 PAM과 함께 사용하도록 설정하는 데 사용됩니다. 지시어는 다음과 같은 형식을 따릅니다.

```
mechanism [control] path-to-module [argument]
```

**지시문**(완전한 한 줄)은 **메커니즘** (`auth`, `account`, `password` 또는 `session`), **성공 여부 확인**(`include`, `optional`, `required`, 등), **모듈 경로** 및 필요한 경우 **인수**(예: `revoke`)로 구성됩니다.

각 PAM 구성 파일은 일련의 지시어로 구성됩니다. 모듈 인터페이스 지시어는 쌓거나 서로 겹치게 배치할 수 있습니다. 실제로 **모듈이 나열된 순서는 인증 프로세스에 매우 중요**합니다.

예를 들어, 다음은 구성 파일 `/etc/pam.d/sudo`입니다.

```
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

## 메커니즘

### `auth` - 인증

요청자의 인증을 처리하고 계정의 권한을 설정합니다.

* 일반적으로 데이터베이스에 저장된 값과 비교하여 비밀번호로 인증하거나 인증 서버를 사용하여 인증합니다.

* 계정 설정을 설정합니다: uid, gid, 그룹 및 리소스 제한을 설정합니다.

### `계정` - 계정 관리

요청된 계정이 사용 가능한지 확인합니다.

* 인증 외의 이유로 계정의 사용 가능성과 관련됩니다(예: 시간 제한).

### `session` - 세션 관리

세션 설정 및 종료와 관련합니다.

* 세션 설정과 관련된 작업(예: 로깅)을 수행합니다.
* 세션 종료와 관련된 작업을 수행합니다.

### `password` - 비밀번호 관리

계정과 연결된 인증 토큰(만료 또는 변경)을 수정하는 데 사용됩니다.

* 인증 토큰을 변경하고 강력한지 또는 이미 사용되었는지 확인합니다.

## 통제 지시어

PAM 메커니즘(`auth`, `account`, `session` 및 `password`)은 `success` 또는 `failure`를 나타냅니다. 제어 플래그(`required`, `requisite`, `sufficient`, `optional`)는 PAM에게 이 결과를 처리하는 방법을 알려줍니다.

### `required`

모든 `필수` 모듈의 성공적인 완료가 필요합니다.

* **모듈이 통과하는 경우:** 나머지 체인이 실행됩니다. 다른 모듈이 실패하지 않는 한 요청이 허용됩니다.

* **모듈이 실패하는 경우:** 나머지 체인이 실행됩니다. 마지막으로 요청이 거부되었습니다.

인증이 계속되려면 모듈의 확인이 반드시 성공적이어야 합니다. `필수`로 표시된 모듈의 확인이 실패하면 해당 인터페이스에 연결된 모든 모듈의 확인이 완료될 때까지 사용자에게 알리지 않습니다.

### `requisite`

모든 `requisite` 모듈을 성공적으로 완료해야 합니다.

* **모듈이 통과하는 경우:** 나머지 체인이 실행됩니다. 다른 모듈이 실패하지 않는 한 요청이 허용됩니다.

* **모듈이 실패하는 경우:** 요청이 즉시 거부됩니다.

인증이 계속되려면 모듈의 확인이 반드시 성공적이어야 합니다. 그러나 `requisite`로 표시된 모듈의 확인이 실패하면 사용자에게 즉시 첫 번째 `required` 또는 `requisite` 모듈의 실패를 나타내는 메시지를 통지합니다.

### `sufficient`

`sufficient`로 표시된 모듈은 특정 조건하에서 사용자를 "초기"로 허용하는 데 사용할 수 있습니다.

* **모듈이 성공한 경우:** 이전 모듈 중 실패한 것이 없으면 인증 요청이 즉시 허용됩니다.

* **모듈이 실패하는 경우:** 모듈이 무시됩니다. 체인의 나머지 부분이 실행됩니다.

그러나 `sufficient`로 표시된 모듈 검사는 성공했지만 `required` 또는 `requisite`로 표시된 모듈이 검사에 실패하면 `sufficient` 모듈의 성공이 무시되고 요청이 실패합니다.

### `optional`

모듈이 실행되지만 요청 결과는 무시됩니다. 체인의 모든 모듈이 `optional`으로 표시되면 모든 요청이 항상 수락됩니다.

### 결론

![Rocky Linux installation splash screen](images/pam-002.png)

## PAM 모듈

PAM에는 많은 모듈이 있습니다. 여기에는 가장 일반적인 모듈 목록이 있습니다:

* pam_unix
* pam_ldap
* pam_wheel
* pam_cracklib
* pam_console
* pam_tally
* pam_securetty
* pam_nologin
* pam_limits
* pam_time
* pam_access

### `pam_unix`

`pam_unix` 모듈을 사용하여 전역 인증 정책을 관리할 수 있습니다.

`/etc/pam.d/system-auth`에서 다음을 추가할 수 있습니다.

```
password sufficient pam_unix.so sha512 nullok
```

이 모듈에는 아래와 같은 인수가 가능합니다:

* `nullok`: `auth` 메커니즘에서 빈 로그인 암호를 허용합니다.
* `sha512`: 암호 메커니즘에서 암호화 알고리즘을 정의합니다.
* `debug`: `syslog`에 정보를 보냅니다.
* `remember=n`: thid를 사용하여 마지막으로 사용된 `n` 암호를 기억합니다(관리자가 생성할 `/etc/security/opasswd` 파일과 함께 작동).

### `pam_cracklib`

`pam_cracklib` 모듈을 사용하면 암호를 테스트할 수 있습니다.

`/etc/pam.d/password-auth`에 다음을 추가합니다.

```
password sufficient pam_cracklib.so retry=2
```

이 모듈은 `cracklib` 라이브러리를 사용하여 새 비밀번호의 강도를 확인합니다. 또한 새 비밀번호가 이전 비밀번호에서 생성된 것이 아닌지도 확인할 수 있습니다. 이는 password 메커니즘에만 영향을 미칩니다.

기본적으로 이 모듈은 다음 측면을 확인하고 해당하는 경우 거부합니다:

* 새 비밀번호가 사전에서 가져온 것인가요?
* 새 비밀번호가 이전 비밀번호의 팰린드롬인가요(예: azerty <> ytreza)?
* 사용자가 비밀번호의 대소문자만 변경한 경우인가요(예: azerty <> AzErTy)?

이 모듈에 대한 가능한 인수:

* `retry=n`: 새 비밀번호의 요청을 `n`회(기본값은 1회)까지 요구합니다.
* `difok=n`: 이전 비밀번호와 다른 문자(`n`개 이상, 기본값은 `10`개 이상)의 최소값을 요구합니다. 새 비밀번호의 절반이 이전 비밀번호와 다른 경우 새 비밀번호가 확인됩니다.
* `minlen=n`: 최소한 `n+1`개의 문자를 가진 비밀번호를 요구합니다. 최소한 6자리 이상으로 지정할 수 없습니다(모듈이 이렇게 컴파일되었습니다).

기타 가능한 인수:

* `dcredit=-n`: 적어도 `n`개의 숫자를 포함하는 비밀번호를 요구합니다.
* `ucredit=-n`: 적어도 `n`개의 대문자를 포함하는 비밀번호를 요구합니다.
* `credit=-n`: 적어도 `n`개의 소문자를 포함하는 비밀번호를 요구합니다.
* `ocredit=-n`:  적어도 `n`개의 특수 문자를 포함하는 비밀번호를 요구합니다.

### `pam_tally`

`pam_tally` 모듈은 일정 횟수의 실패한 로그인 시도를 기반으로 계정을 잠글 수 있도록 합니다.

이 모듈의 기본 설정 파일은 다음과 같을 수 있습니다: `/etc/pam.d/system-auth`:

```
auth required /lib/security/pam_tally.so onerr=fail no_magic_root
account required /lib/security/pam_tally.so deny=3 reset no_magic_root
```

`auth` 메커니즘은 인증을 허용하거나 거부하며 카운터를 재설정합니다.

`account` 메커니즘은 카운터를 증가시킵니다.

pam_tally 모듈의 일부 인수는 다음과 같습니다:

* `onerr=fail`: 카운터를 증가시킵니다.
* `deny=n`: 실패한 시도의 수 `n`이 초과되면 계정이 잠깁니다.
* `no_magic_root`: 데몬에 의해 실행되는 루트 레벨 서비스에 액세스를 거부하는 데 사용될 수 있습니다.
    * 예를 들어 이것을 `su`에 사용하지 마십시오.
* `reset`: 인증이 확인되면 카운터를 0으로 재설정합니다.
* `lock_time=nsec`: 계정이 `n`초 동안 잠깁니다.

이 모듈은 실패한 시도를 기록하는 기본 파일 `/var/log/faillog`(인수 `file=xxxx`로 다른 파일로 대체할 수 있음) 및 관련된 `faillog` 명령과 함께 작동합니다.

faillog 명령의 구문:

```
faillog[-m n] |-u login][-r]
```

옵션:

* `m`: 명령 표시에서 최대 실패 횟수를 정의합니다
* `u`: 사용자를 지정합니다.
* `r`: 사용자의 잠금을 해제합니다.

### `pam_time`

`pam_time` 모듈을 사용하면 PAM으로 관리되는 서비스의 액세스 시간을 제한할 수 있습니다.

활성화하려면 `/etc/pam.d/system-auth`를 편집하고 다음을 추가합니다.

```
account required /lib/security/pam_time.so
```

구성은 `/etc/security/time.conf` 파일에서 수행됩니다.

```
login ; * ; users ;MoTuWeThFr0800-2000
http ; * ; users ;Al0000-2400
```

지시문의 구문은 다음과 같습니다.

```
services; ttys; users; times
```

다음 정의에서 논리 목록은 다음을 사용합니다.

* `&`: "and" 논리입니다.
* `|`: "or" 논리입니다.
* `!`: 부정을 나타내며 "all except"를 의미합니다.
* `*`: 와일드카드 문자입니다.

열은 다음과 같습니다 :

* `services`: 이 규칙으로 관리되는 PAM으로 관리되는 서비스의 논리적 목록입니다.
* `ttys`: 관련 장치의 논리적 목록입니다.
* `users`: 규칙으로 관리되는 사용자의 논리적 목록입니다.
* `times`: 허용된 시간 대의 논리적 목록입니다.

시간대 관리 방법 :

* 요일: `Mo`, `Tu`, `We`, `Th`, `Fr`, `Sa`, `Su`, `Wk`, (월요일부터 금요일까지), `Wd` (토요일과 일요일), 및 'Al'(월요일~일요일)
* 시간 범위: `HHMM-HHMM`
* 반복하면 효과가 취소됩니다. 'WkMo' = 모든 요일(월~금)에서 월요일(반복)을 뺀 값입니다.

예시:

* Bob은 수요일을 제외하고 매일 07:00부터 09:00까지 터미널을 통해 로그인할 수 있습니다:

```
login; tty*; bob; alth0700-0900
```

root를 제외한 모든 사용자는 매일 17:30부터 다음날 7:45까지 터미널 또는 원격 로그인이 불가능합니다:

```
login; tty* | pts/*; !root; !wk1730-0745
```

### `pam_nologin`

`pam_nologin` 모듈은 root를 제외한 모든 계정을 비활성화합니다.

`/etc/pam.d/login`에 다음을 입력합니다.

```
auth required pam_nologin.so
```

`/etc/nologin` 파일이 존재하면 root만 연결할 수 있습니다.

### `pam_wheel`

`pam_wheel` 모듈을 사용하면 `su` 명령에 대한 액세스를 `wheel` 그룹의 구성원으로 제한할 수 있습니다.

`/etc/pam.d/su`에 다음을 입력합니다.

```
auth required pam_wheel.so
```

`group=my_group` 인수는 `su` 명령의 사용을 `my_group` 그룹의 구성원으로 제한합니다.

!!! 참고사항

    그룹 `my_group`이 비어 있으면 시스템에서 `su` 명령을 더 이상 사용할 수 없으므로 sudo 명령을 강제로 사용해야 합니다.

### `pam_mount`

`pam_mount` 모듈을 사용하면 사용자 세션에 대한 볼륨을 마운트할 수 있습니다.

`/etc/pam.d/system-auth`에 다음을 입력합니다.

```
auth optional pam_mount.so
password optional pam_mount.so
session optional pam_mount.so
```

마운트 지점은 `/etc/security/pam_mount.conf` 파일에서 구성됩니다.

```
<volume fstype="nfs" server="srv" path="/home/%(USER)" mountpoint="~" />
<volume user="bob" fstype="smbfs" server="filesrv" path="public" mountpoint="/public" />
```

## 마무리

이제 PAM이 수행할 수 있는 작업과 필요한 경우 변경하는 방법에 대해 훨씬 더 잘 이해하고 있을 것입니다. 그러나 PAM 모듈에 대한 모든 변경 사항을 *매우* 신중히 처리해야 함을 다시 한 번 강조해드립니다. 시스템에서 자신을 차단하거나 더 나쁜 경우 다른 모든 사용자가 접근할 수 있습니다.

PAM 모듈에 대한 모든 변경 사항을 쉽게 이전 구성으로 되돌릴 수 있는 환경에서 모든 변경 사항을 테스트하는 것을 강력히 권장합니다. 그럼 재미있게 사용하세요!
