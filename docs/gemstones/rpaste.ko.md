---
title: rpaste - Pastebin Tool
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# `paste` 소개

`rpaste`는 코드, 로그 출력 및 기타 긴 텍스트를 공유하기 위한 도구입니다. Rocky Linux 개발자가 만든 페이스트빈입니다. 이 도구는 무언가를 공개적으로 공유해야 하지만 텍스트로 피드를 지배하고 싶지 않을 때 유용합니다. 이것은 다른 IRC 서비스에 대한 브리지가 있는 Mattermost를 사용할 때 특히 중요합니다. `rpaste` 도구는 모든 Rocky Linux 시스템에 설치할 수 있습니다. 데스크톱 컴퓨터가 Rocky Linux가 아니거나 단순히 도구를 설치하지 않으려는 경우 [pinnwand URL](https://rpa.st)에 액세스하여 수동으로 사용할 수 있습니다. 공유할 시스템 출력 또는 텍스트를 붙여넣습니다. `rpaste`를 사용하면 이 정보를 자동으로 생성할 수 있습니다.

## 설치

Rocky Linux에 `rpaste` 설치:

```
sudo dnf --enablerepo=extras install rpaste
```

## 사용

주요 시스템 문제의 경우 문제를 검토할 수 있도록 모든 시스템 정보를 보내야 할 수 있습니다. 이렇게 하려면 다음을 실행하십시오:

```
rpaste --sysinfo
```

pinnwand 페이지에 대한 링크를 반환합니다.

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

그런 다음 브라우저에서 직접 정보를 검토하고 정보를 유지하거나 제거하고 다시 시작할 것인지 결정할 수 있습니다. 유지하려면 "URL 붙여넣기"를 복사하여 함께 작업하는 사람과 공유하거나 Mattermost의 피드에서 공유할 수 있습니다. 제거하려면 "제거 URL"을 복사하고 브라우저에서 엽니다.

콘텐츠를 파이핑하여 pastebin에 콘텐츠를 추가할 수 있습니다. 예를 들어 3월 10일부터 `/var/log/messages` 파일의 콘텐츠를 추가하려는 경우 다음과 같이 할 수 있습니다.

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## `rpaste` help

명령에 대한 도움말을 보려면 다음을 입력하십시오.

```
rpaste --help
```

다음과 같은 결과가 나타납니다.

```bash
rpaste: 원래 Rocky 붙여넣기 서비스용으로 만들어진 붙여넣기 유틸리티

Usage: rpaste [options] [filepath]
       command | rpaste [options]

이 명령은 파일이나 표준을 입력으로 사용할 수 있습니다.

옵션:
--life value, -x value      붙여넣기의 수명(1시간, 1일, 1주)을 설정합니다(기본값: 1시간)
--type value, -t value      구문 강조 표시를 설정합니다(기본값: 텍스트)
--sysinfo, -s               일반 시스템 정보 수집(stdin 및 파일 입력 비활성화)(기본값: false)
--dry, -d                   출력을 붙여넣지 않고 stdin(기본값: false)에 데이터를 표시하는 건식 모드를 켭니다.
--pastebin value, -p value  보낼 붙여넣기 저장소 서비스를 설정합니다. 현재 지원되는 항목: rpaste, fpaste(기본값: "rpaste")
--help, -h                  도움말 표시(기본값: false)
--version, -v               버전 출력(기본값: false)
```

## 결론

문제를 해결하거나 코드나 텍스트를 공유하는 등 많은 양의 텍스트를 공유하는 것이 때때로 중요합니다. 이를 위해 `rpaste`를 사용하면 다른 사람들이 그들에게 중요하지 않은 많은 양의 텍스트 콘텐츠를 보지 않아도 됩니다. Rocky Linux 채팅 에티켓도 중요합니다.

