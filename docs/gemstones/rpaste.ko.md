---
title: rpaste - Pastebin Tool
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# `rpaste` 소개

`rpaste`는 코드, 로그 출력 및 기타 매우 긴 텍스트를 공유하기 위한 도구입니다. 이는 Rocky Linux 개발자들이 만든 Pastebin입니다. 이 도구는 무언가를 공개적으로 공유해야하지만 텍스트로 피드를 지배하고 싶지 않을 때 유용합니다. 특히 다른 IRC 서비스와의 연결이 있는 Mattermost를 사용할 때 이는 특히 중요합니다. `rpaste` 도구는 모든 Rocky Linux 시스템에 설치할 수 있습니다. 데스크탑 머신이 Rocky Linux가 아니거나 도구를 설치하고 싶지 않은 경우, [pinnwand URL](https://rpa.st)에 액세스하여 시스템 출력 또는 공유하려는 텍스트를 붙여넣는 방식으로 수동으로 사용할 수 있습니다. `rpaste`를 사용하면 이 정보를 자동으로 생성할 수 있습니다.

## 설치

Rocky Linux에 `rpaste` 설치:

```
sudo dnf --enablerepo=extras install rpaste
```

## 사용

중요한 시스템 문제의 경우, 문제를 검토하기 위해 시스템의 모든 정보를 보내야 할 수도 있습니다. 이를 위해 다음 명령을 실행합니다:

```
rpaste --sysinfo
```

이 명령은 pinnwand 페이지의 링크를 반환합니다:

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

그런 다음 브라우저에서 정보를 직접 검토하고 유지할지 삭제하고 처음부터 다시 시작할지 결정할 수 있습니다. 유지하려면 "Paste URL"을 복사하여 협력하는 사람이나 Mattermost의 피드와 공유할 수 있습니다. 제거하려면 "Removal URL"을 복사하여 브라우저에서 엽니다.

파이프를 사용하여 내용을 pastebin에 추가할 수도 있습니다. 예를 들어, 3월 10일에 `/var/log/messages` 파일에서 내용을 추가하려면 다음과 같이 수행할 수 있습니다:

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## `rpaste` help

명령어의 도움말을 얻으려면 간단히 다음을 입력하십시오:

```
rpaste --help
```

다음과 같은 결과가 나타납니다.

```bash
rpaste:  Rocky paste 서비스를 위해 만든 붙여넣기 유틸리티

Usage: rpaste [options] [filepath]
       command | rpaste [options]

이 명령은 파일이나 표준을 입력으로 사용할 수 있습니다. 옵션:
--life value, -x value      Paste의 수명(1시간, 1일, 1주)을 설정합니다(기본값: 1시간)
--type value, -t value      구문 강조 표시를 설정합니다(기본값: 텍스트)
--sysinfo, -s               일반 시스템 정보 수집합니다(stdin 및 파일 입력 비활성화)(기본값: false)
--dry, -d                   출력을 붙여넣지 않고 stdin(기본값: false)에 데이터를 표시하는 건식 모드를 켭니다. --pastebin value, -p value  보낼 붙여넣기 저장소 서비스를 설정합니다. 현재 지원되는 서비스: rpaste, fpaste(기본값: "rpaste")
--help, -h                  도움말 표시(기본값: false)
--version, -v               버전 정보 표시(기본값: false)
```

## 결론

문제 해결, 코드 또는 텍스트 공유 등의 작업 중에 큰 양의 텍스트를 공유하는 것은 때로 중요합니다. 이를 위해 `rpaste`를 사용하면 다른 사람들이 중요하지 않은 대량의 텍스트 내용을 볼 필요가 없어집니다. 또한 Rocky Linux 채팅 예절에서 중요합니다.

