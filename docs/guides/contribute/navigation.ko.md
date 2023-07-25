---
title: 네비게이션 변경
author: Steven Spencer
contributors: Ezequiel Bruni
tags:
  - contribute
  - navigation
---

# 네비게이션 변경 - 관리자/편집자를 위한 프로세스 문서

## 이 문서의 이유

문서 프로젝트가 시작될 때에는 MkDocs의 메뉴가 가능한 한 자동으로 구성되어서 내비게이션을 수동으로 편집하는 경우는 드물 것으로 기대되었습니다. 몇 달 동안 문서를 생성해보니 MkDocs가 문서를 올바른 폴더에 놓기만 하면 내비게이션을 자동으로 생성할 수 없어서 정리된 내비게이션을 유지하는 데 의존할 수 없음을 알게 되었습니다. 우리는 카테고리가 필요했으며, 이는 MkDocs가 특정 폴더에 문서를 놓지 않으면 제공하지 않습니다. 그렇게 하면 MkDocs는 알파벳 순서로 내비게이션을 생성합니다. 내비게이션을 고정하는 폴더 구조를 만들어도 그것만으로는 전부가 아닙니다. 심지어 상황을 체계적으로 유지하기 위해 추가 변경이 필요할 수도 있습니다. 예를 들어 소문자 폴더 구조를 수정하지 않고 대문자를 사용합니다.

## 목표

우리의 목표는 다음과 같습니다.

* 필요한 대로 폴더 구조 생성하기 (미래에 새 폴더가 필요할 수 있음).
* Rocky Installation, Migration 및 Contribution 영역을 상단에 배치하는 내비게이션 조정.
* 내비게이션을 조정하여 일부 폴더의 이름을 더욱 적절하게 변경하고 올바른 대소문자를 사용하기. 예를 들어, "DNS"와 "File Sharing Services"를 "Dns"와 "File sharing"으로 표시하지 않고 올바르게 대문자로 표시하는 것과 같은 처리.
* 이러한 내비게이션 파일이 관리자와 편집자에게만 제한되도록 하기.

이 마지막 항목은 이 문서를 읽는 일부 사람들에게는 불필요해 보일 수 있지만, 이 문서가 계속되면 더욱 명확해질 것입니다.

## 전제 조건

Rocky GitHub 리포지토리의 로컬 복제본이 있다고 가정합니다: [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## 환경 변화

이러한 변경으로 인해 콘텐츠가 문서 저장소에 커밋되기 _전에_ 웹 사이트 컨텍스트에서 변경 사항이 콘텐츠에 어떤 영향을 미치는지 "확인"해야 하며 이후에 '활성화'됩니다.

MkDocs는 [Python](https://www.python.org) 응용 프로그램이며, 사용하는 추가 패키지도 Python 코드이므로 MkDocs를 실행하는 데 필요한 환경은 **올바르게 구성된 Python 환경**이어야 합니다. 개발 작업을 위해 Python을 설정하는 것은 간단한 작업이 아니며, 이에 대한 지침은 이 문서의 범위를 벗어납니다. 고려해야 할 몇 가지 사항은 다음과 같습니다.

* Python의 버전은 >= 3.8이어야 하며 **컴퓨터가 Linux/macOS를 실행하는 경우 컴퓨터의 '시스템' Python 버전을 사용하지 않도록 특별히 주의해야 합니다**. 예를 들어, 이 문서를 작성하는 시점에서 macOS의 시스템 버전은 여전히 2.7 버전입니다.
* Python '가상 환경' 실행. Python 응용 프로그램 프로젝트를 실행하고 패키지 (예: MkDocs)를 설치할 때 Python 커뮤니티에서는 각 프로젝트에 대해 [격리된 가상 환경을 생성](https://realpython.com/python-virtual-environments-a-primer/)할 것을 **강력히 권장**합니다.
* Python을 잘 지원하는 최신 IDE(통합 개발 환경)를 사용하십시오. 가상 환경 실행을 위한 통합 지원 기능이 있는 두 가지 인기 있는 IDE는 다음과 같습니다.
    * PyCharm - (무료 버전 제공) Python을 위한 최고의 IDE https://www.jetbrains.com/pycharm/
    * Visual Studio Code - Microsoft https://code.visualstudio.com의 (무료 버전 제공)

이를 효과적으로 수행하려면 다음이 필요합니다.

* 새로운 Python 프로젝트를 설정하고 가상 환경을 사용하는 것이 이상적입니다.
* `mkdocs` 설치하기.
* 일부 Python 플러그인 설치하기.
* 이 Rocky GitHub 저장소 복제하기: [https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org).
* 복제된 문서 저장소 내의 `docs` 폴더에 링크하기(mkdocs 환경을 더욱 깨끗하게 유지하는 방법을 원한다면 mkdocs.yml 파일을 수정할 수도 있습니다)
* docs.rockylinux.org 복제본 내에서 `mkdocs serve` 실행하기

!!! !!!

    다음 두 가지 절차를 사용하여 `mkdocs`를 위해 완전히 별도의 환경을 구축할 수도 있습니다:

    * [로컬 문서 - 도커](rockydocs_web_dev.md)
    * [로컬 문서 - LXD](mkdocs_lsyncd.md)

!!! 참고 사항

    이 문서는 Linux 환경에서 작성되었습니다. 환경이 다른 경우 (Windows 또는 Mac) 이 단계에 맞추기 위해 약간의 연구가 필요합니다. 이 문서를 읽는 편집자나 관리자는 해당 환경에 대한 단계를 추가하여 변경 사항을 제출할 수 있습니다.

### 설치

* Python 환경에 `mkdocs` 설치: `pip install mkdocs`
* 필요한 플러그인 설치: `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-redirects mkdocs-i18n`
* 저장소 복제(위에 언급됨)

### `mkdocs` 연결 및 실행

docs.rockylinux.org 로컬(클론) 내에서 다음을 수행합니다. 이것은 문서 복제본의 위치를 가정하므로 필요에 따라 수정하십시오.

`ln -s /home/username/documentation/docs docs`

다시 말하지만 원하는 경우 `mkdocs.yml` 파일의 로컬 복사본을 수정하여 경로를 설정할 수 있습니다. 이 방법을 사용하는 경우 `documentation/docs` 폴더를 가리키도록 이 줄을 수정합니다.

```
docs_dir: 'docs/docs'
```

완료되면 `mkdocs serve`를 실행하여 원하는 콘텐츠를 얻을 수 있는지 확인할 수 있습니다. 포트 8000의 로컬 호스트에서 실행됩니다. 예: [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## 네비게이션 및 기타 변경 사항

네비게이션은 mkdocs `.pages` 파일 **또는** 문서 머리말의 "title:" 메타 값으로 처리됩니다. `.pages` 파일은 그다지 복잡하지 않지만, 누락된 부분이 있으면 서버가 로드되지 않을 수 있습니다. 이것이 바로 이 절차가 오직 관리자와 편집자를 위한 것인 이유입니다. 이러한 사용자들은 도구 (mkdocs의 로컬 설치 및 documentation과 docs.rockylinux.org의 복제)를 갖추어서 GitHub에 푸시하고 병합된 내용이 문서 웹 사이트의 서비스를 중단하지 않도록 할 수 있으므로 기여자들은 이러한 요구 사항을 한 가지만 갖추어야 할 것으로 기대할 수 없습니다. 기여자는 이러한 요구 사항 중 하나라도 갖추고 있다고 기대할 수 없습니다.


### `.pages` 파일

이미 언급한 대로, `.pages` 파일은 일반적으로 꽤 간단합니다. 이들은 YAML 형식의 파일로, `mkdocs`가 콘텐츠를 렌더링하기 전에 읽습니다. 더 복잡한 `.pages` 파일 중 하나를 살펴보겠습니다. 측면 내비게이션을 형식화하는 데 도움이 되도록 생성된 파일을 살펴보죠:

```
---
nav:
    - ... | index*.md
    - ... | installation*.md
    - ... | migrate2rocky*.md
    - Contribute: contribute
    - Automation: automation
    - Backup & Sync: backup
    - Content Management: cms
    - Communications: communications
    - Containers: containers
    - Database: database
    - Desktop: desktop
    - DNS: dns
    - Email: email
    - File Sharing Services: file_sharing
    - Git: git
    - Interoperability: interoperability
    - Mirror Management: mirror_management
    - Network: network
    - Package Management: package_management
    - ...

```
여기서 index*.md는 "Guides Home: "를 보여주고, installation*.md는 "Installing Rocky Linux" 문서 링크를 보여주며, migrate2rocky*.md는 "Migrating To Rocky Linux" 문서 링크를 보여줍니다. 이러한 링크들의 각각에 "*"를 넣어 해당 언어의 문서를 모두 포함할 수 있습니다. 마지막으로 "Contribute"를 넣으면 이 항목은 일반적인 (알파벳 순서) 정렬 순서가 아닌 이 항목 아래로 배치됩니다. 목록을 둘러보면 각 항목이 무엇을 하는지 확인할 수 있습니다. "Package Management: package_management" 항목 다음에는 사실 두 개의 폴더 (security와 web)가 더 있습니다. 이들은 추가적인 형식이 필요하지 않기 때문에 "-..."을 통해 정상적으로 로드하도록 mkdocs에게 알려줍니다.

실제 파일 내에서 YAML 형식을 사용할 수도 있습니다. 이렇게 하는 이유는 파일의 처음 제목이 너무 길어서 내비게이션 섹션에서 제대로 표시되지 않기 때문입니다.  예를 들어, 다음과 같은 문서 제목 "# `mod_ssl` on Rocky Linux in an httpd Apache Web-Server Environment"이 매우 길기 때문에 "Web" 내비게이션 항목이 열리면 측면 내비게이션에서 매우 잘 표시되지 않습니다. 그것은 매우 깁니다. "웹" 탐색 항목이 열리면 측면 탐색에서 매우 제대로 표시되지 않습니다. 이를 해결하기 위해 저자와 협력하여 제목을 변경하거나 문서 내부에서 제목 앞에 제목을 추가하여 메뉴에 표시 방법을 변경할 수 있습니다. 예를 들어, 예제 문서에는 다음과 같이 제목이 추가되어 있습니다:
```
---
title: Apache With `mod_ssl`
---
```
이렇게 하면 내비게이션에 표시되는 제목이 변경되지만 문서 내부에는 저자의 원래 제목이 그대로 남아 있습니다.

추가 `.pages` 파일이 필요한 경우는 아마도 많지 않을 것입니다. 이들은 절약해서 사용해야 합니다.

## 결론

필요한 내비게이션 변경 사항은 어렵지 않지만, 라이브 문서를 깨트릴 수 있는 가능성이 있습니다. 이러한 이유로 인해, 라이브 문서를 깨트리지 않도록 적절한 도구를 갖추고 있는 관리자와 편집자만이 이러한 파일을 편집할 권한이 있어야 합니다. 라이브 페이지가 어떻게 보일지 미리 볼 수 있는 완전한 환경을 갖추어서 관리자나 편집자가 이러한 파일을 편집하면서 실수를 범하지 않도록 합니다.
