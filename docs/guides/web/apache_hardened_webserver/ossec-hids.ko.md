---
title: 호스트 기반 침입 탐지 시스템 (HIDS - Host-based Intrusion Detection System)
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.8, 9.2
tags:
  - web
  - security
  - ossec-hids
  - hids
---

# 호스트 기반 침입 탐지 시스템 (HIDS - Host-based Intrusion Detection System)

## 필요 사항

* 명령 줄 텍스트 편집기에 능숙해야 합니다. (이 예시에서는 `vi`를 사용합니다.)
* 명령 줄에서 명령 실행, 로그 확인 및 기타 시스템 관리자 업무에 능숙해야 합니다.
* 이 도구를 설치하는 것은 환경에 따라 모니터링 및 조정이 필요하다는 점을 이해해야 합니다.
* 모든 명령은 root 사용자 또는 `sudo` 권한이 있는 일반 사용자로 실행해야 합니다.

## 소개

`ossec-hids` ossec-hids는 호스트 기반 침입 탐지 시스템으로, 호스트 침입 공격을 완화하는데 도움이 되는 자동 대응 절차를 제공합니다. 이것은 강화된 Apache 웹 서버 구성의 가능한 한 부분일 뿐입니다. 다른 도구와 함께 사용하거나 독립적으로 사용할 수 있습니다.

다른 도구와 함께 사용하려면 [Apache Hardened Web Server](index.md) 문서를 참조하세요. 이 문서는 해당 원본 문서에서 제시한 가정과 규칙을 모두 사용합니다. 계속하기 전에 검토하는 것이 좋습니다.

## Atomicorp 리포지토리 설치

`ossec-hids`를 설치하려면 Atomicorp의 타사 리포지토리가 필요합니다. Atomicorp는 문제가 발생할 경우 전문적인 지원을 받기를 원하는 사용자를 위해 합리적인 가격의 유료 지원 버전도 제공합니다.

지원을 원하고 예산이 있으신 경우 [Atomicorp의 유료 ossec-hids](https://atomicorp.com/atomic-enterprise-ossec/) 버전을 확인해보세요. 무료 리포지토리에서 필요한 몇 가지 패키지만 설치하면 됩니다. 다운로드한 후 리포지토리를 변경합니다.

먼저 `wget`을 설치합니다. 이전에 설치하지 않았다면 EPEL 리포지토리를 설치하세요.

```
dnf install wget epel-release
```

그리고 Atomicorp의 무료 리포지토리를 다운로드하고 활성화합니다.

```
wget -q -O - http://www.atomicorp.com/installers/atomic | sh
```

이 스크립트는 사용 약관에 동의하시는지 물어볼 것입니다. "yes" 또는 <kbd>Enter</kbd>을 입력하여 기본 설정을 수락하세요.

다음으로 리포지토리를 기본적으로 활성화할지 물어볼 것이며, 다시 기본 설정을 수락하거나 "yes"를 입력하세요.

### Atomicorp 리포지토리 구성

몇 개의 패키지에 대한 atomic 저장소만 있으면 됩니다. 그렇기때문에 Atomicorp 리포지토리를 변경하고 필요한 패키지만 지정해야 합니다.

```
vi /etc/yum.repos.d/atomic.repo
```

다음 줄을 상단의 "enabled = 1" 아래에 추가하세요.

```
includepkgs = ossec* GeoIP* inotify-tools
```

이것이 유일한 변경사항입니다. 변경 사항을 저장하고 리포지토리를 빠져나옵니다 (`vi`에서는 <kbd>esc</kbd>를 누른 다음 <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd>를 누르면 됩니다).

이렇게 하면 Atomicorp 리포지토리가 이러한 패키지만 설치하고 업데이트하도록 제한됩니다.

## `ossec-hids` 설치

리포지토리를 구성했으므로 패키지를 설치해야 합니다.

```
dnf install ossec-hids-server ossec-hids inotify-tools
```

### `ossec-hids` 구성

기본 구성은 많은 변경이 필요한 상태입니다. 대부분은 서버 관리자에게 알림 및 로그 위치와 관련이 있습니다.

`ossec-hids`는 공격이 진행 중인지와 `ossec-hids`가 관측한 내용에 따라 완화 조치를 취할지를 결정하기 위해 로그를 확인합니다. 또한 서버 관리자에게 알림 메시지를 보내거나 `ossec-hids`가 본 내용에 따라 시작된 완화 절차에 대한 메시지를 보냅니다.

구성 파일을 편집하려면 다음 명령을 입력하세요.

```
vi /var/ossec/etc/ossec.conf
```

저희는 이 구성을 세부적으로 나누어 변경 사항을 한 줄씩 보여드리고 진행하면서 설명할 것입니다.

```
<global>
  <email_notification>yes</email_notification>  
  <email_to>admin1@youremaildomain.com</email_to>
  <email_to>admin2@youremaildomain.com</email_to>
  <smtp_server>localhost</smtp_server>
  <email_from>ossec-webvms@yourwebserverdomain.com.</email_from>
  <email_maxperhour>1</email_maxperhour>
  <white_list>127.0.0.1</white_list>
  <white_list>192.168.1.2</white_list>
</global>
```

기본적으로 이메일 알림이 꺼져 있으며, `<global>` 구성은 기본적으로 비어 있습니다. 이메일 알림을 켜고 이메일 보고서를 받을 사람들의 이메일 주소를 입력해야 합니다.

`<smtp_server>` 섹션은 현재 localhost로 표시되어 있지만, 원하는 경우 이메일 서버 릴레이를 지정하거나 로컬 호스트의 postfix 이메일 설정을 설정할 수 있습니다. 이 [가이드](../../email/postfix_reporting.md)를 따라 로컬 호스트의 postfix 이메일 설정을 구성할 수도 있습니다.

"from" 이메일 주소를 설정해야 합니다. 이것은 이메일 서버의 SPAM 필터가 이 이메일을 스팸으로 간주할 수 있으므로 필요합니다. 너무 많은 이메일로 침습당하고 싶지 않다면, 이메일 보고서를 1시간에 1개로 설정하세요. `ossec-hids`를 시작하는 동안 빠르게 결과를 확인해야 할 때는 이것을 확장하거나 주석 처리할 수 있습니다.

`<white_list>` 섹션은 서버의 localhost IP와 방화벽의 "공용" IP 주소(개인 IP 주소로 교체한 것을 기억하세요)를 다룹니다. 많은 `<white_list>` 항목을 추가할 수 있습니다.

```
<syscheck>
  <!-- Frequency that syscheck is executed -- default every 22 hours -->
  <frequency>86400</frequency>
...
</syscheck>
```

`<syscheck>` 섹션은 침해된 파일을 찾을 때 포함 및 제외할 디렉터리 목록을 검토합니다. 이는 파일 시스템을 취약성에 대해 감시하고 보호하기 위한 또 다른 도구입니다. `<syscheck>` 섹션의 디렉터리 목록을 검토하고 원하는 추가 디렉터리를 추가해야 합니다.

`<syscheck>` 섹션 바로 아래에 있는 `<rootcheck>` 섹션은 또 다른 보호 계층입니다. `<syscheck>`와 `<rootcheck>`이 관찰하는 위치는 편집 가능하지만, 보통 변경할 필요가 없을 것입니다.

`<rootcheck>`의 `<frequency>`를 기본 22시간에서 24시간(86400초)로 변경하는 것은 선택 사항으로 표시된 변경입니다.

```
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*access_log</location>
</localfile>
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*error_log</location>
</localfile>
```

`<localfile>` 섹션은 감시할 로그의 위치를 다룹니다. 이미 _syslog_와 secure 로그에 대한 항목이 있으며, 확인해야 할 경로만 남겨두면 됩니다.

Apache 로그 위치를 추가해야 하며, 여러 다른 웹 고객을 위해 와일드카드 형태로 추가해야 합니다.

```
  <command>
    <name>firewalld-drop</name>
    <executable>firewall-drop.sh</executable>
    <expect>srcip</expect>
  </command>

  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <level>7</level>
  </active-response>
```

마지막으로 파일의 끝 부분에 액티브 응답(Active Response) 섹션을 추가해야 합니다. 이 섹션에는 `<command>` 섹션과 `<active-response>` 섹션이 있습니다.

"firewall-drop" 스크립트가 `ossec-hids` 경로 내에 이미 있습니다. `osec-hids`에 레벨 7이 발생하면 방화벽 규칙을 추가하여 IP 주소를 차단하라는 메시지가 표시됩니다.

원하는 구성 변경을 모두 완료하면 서비스를 활성화하고 시작합니다. 모든 것이 정상적으로 시작되면 계속 진행할 준비가 된 것입니다.

```
systemctl enable ossec-hids
systemctl start ossec-hids
```

`ossec-hids` 구성 파일에는 많은 옵션이 있습니다. 이 옵션들에 대해 자세히 알아보려면 [공식 문서 사이트](https://www.ossec.net/docs/)를 참조하세요.

## 결론

`ossec-hids`는 강화된 Apache 웹 서버의 하나의 요소일 뿐입니다. 다른 도구와 함께 선택하여 더욱 높은 보안 수준을 얻을 수 있습니다.

설치 및 구성은 비교적 간단하지만, 이것은 **설치 후 잊고 놔두는** 애플리케이션이 아닙니다. 최대한 많은 보안과 false-positive 응답 수를 최소화하기 위해 환경에 맞게 조정해야 합니다.
