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

문서화 프로젝트가 시작되었을 때 Mkdocs의 메뉴가 가능한 한 자동이 되어 탐색을 수동으로 편집하는 일이 드물기를 바랐습니다. 몇 달 동안 문서를 생성한 후 올바른 폴더에 문서를 배치하고 Mkdocs가 탐색을 생성하도록 하는 것만으로는 문서를 깨끗하고 깔끔하게 유지할 수 없다는 것이 분명해졌습니다. 우리는 문서가 특정 폴더에 배치되지 않는 한 Mkdocs가 제공하지 않는 카테고리가 필요했습니다. 그런 다음 Mkdocs는 알파벳순으로 탐색을 만듭니다. 그러나 탐색을 수정하는 폴더 구조를 만드는 것이 전체 그림은 아닙니다. 심지어 상황을 체계적으로 유지하기 위해 추가 변경이 필요할 수도 있습니다. 예를 들어 소문자 폴더 구조를 수정하지 않고 대문자를 사용합니다.

## 목표

우리의 목표는 다음과 같습니다.

* 지금 필요에 따라 폴더 구조를 만듭니다(나중에 새 폴더가 필요할 수 있음).
* Rocky Installation, Migration 및 Contribution 영역이 맨 위에 오도록 탐색을 조정합니다.
* 탐색을 조정하여 일부 폴더의 이름을 더 잘 지정하고 올바른 대소문자를 사용하도록 설정합니다. 예를 들어 "DNS" 및 "파일 공유 서비스"는 일부 조작 없이 "Dns" 및 "파일 공유"로 표시됩니다.
* 이러한 탐색 파일이 관리자 및 편집자로 제한되어 있는지 확인하십시오.

이 마지막 항목은 이 문서를 읽는 일부에게는 불필요해 보일 수 있지만 이 문서가 계속됨에 따라 더 명확해질 것입니다.

## 전제 조건

Rocky GitHub 리포지토리의 로컬 복제본이 있다고 가정합니다: [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## 환경 변화

이러한 변경으로 인해 콘텐츠가 문서 저장소에 커밋되기 _전에_" 웹 사이트 컨텍스트에서 변경 사항이 콘텐츠에 어떤 영향을 미치는지 "확인"해야 하며 이후에 '활성화'됩니다.

MkDocs는 [Python](https://www.python.org)애플리케이션이며 사용하는 추가 패키지도 Python 코드입니다. 즉, MkDocs를 실행하는 데 필요한 환경은 **올바르게 구성된 Python 환경**이어야 합니다. 개발 작업을 위해 Python을 설정하는 것(MkDocs를 실행하여 수행되는 작업)은 사소한 작업이 아니며 이에 대한 지침은 이 문서의 범위를 벗어납니다. 몇 가지 고려 사항은 다음과 같습니다:

* Python의 버전은 >= 3.8이어야 하며 **컴퓨터가 Linux/macOS를 실행하는 경우 컴퓨터의 '시스템' Python 버전을 사용하지 않도록 특별히 주의해야 합니다**. 예를 들어 이 문서를 작성하는 시점에서 macOS의 Python 시스템 버전은 여전히 버전 2.7입니다.
* Python '가상 환경' 실행. Python 애플리케이션 프로젝트를 실행하고 패키지(예: MkDocs)를 설치할 때 Python 커뮤니티에서는 각 프로젝트에 대해 [격리된 가상 환경을 생성](https://realpython.com/python-virtual-environments-a-primer/)할 것을 **강력히 권장**합니다.
* Python을 잘 지원하는 최신 IDE(통합 개발 환경)를 사용하십시오. 가상 환경 실행을 위한 통합 지원 기능이 있는 두 가지 인기 있는 IDE는 다음과 같습니다.
    * PyCharm - (무료 버전 사용 가능) Python을 위한 최고의 IDE https://www.jetbrains.com/pycharm/
    * Visual Studio Code - Microsoft https://code.visualstudio.com의 (무료 버전 사용 가능)

이를 효과적으로 수행하려면 다음이 필요합니다.

* 이상적으로는 가상 환경(위)을 사용하는 새 Python 프로젝트 설정.
* `mkdocs` 설치
* 일부 Python 플러그인 설치
* 이 Rocky GitHub 저장소 복제: [https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* 복제된 문서 저장소 내의 `docs` 폴더에 연결(올바른 폴더를 로드하려는 경우 mkdocs.yml 파일을 수정할 수도 있지만 연결하면 mkdocs 환경이 더 깨끗해집니다.)
* docs.rockylinux.org 복제본 내에서 `mkdocs serve` 실행

!!! 팁

    다음 두 절차 중 하나를 사용하여 `mkdocs`에 대해 완전히 별개의 환경을 구축할 수도 있습니다.

    * [로컬 문서 - 도커](rockydocs_web_dev.md)
    * [로컬 문서 - LXD](mkdocs_lsyncd.md)

!!! 참고 사항

    이 문서는 Linux 환경에서 작성되었습니다. 환경이 다른 경우(Windows 또는 Mac), 이러한 단계 중 일부를 일치시키기 위해 약간의 조사를 수행해야 합니다. 이 문서를 읽는 편집자 또는 관리자는 변경 사항을 제출하여 해당 환경에 대한 단계를 추가할 수 있습니다.

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

네비게이션은 mkdocs `.pages` 파일 **또는** 문서 머리말의 "title:" 메타 값으로 처리됩니다. `.pages` 파일은 그다지 복잡하지 않지만, 누락된 것이 있으면 서버 로드에 실패할 수 있습니다. 그렇기 때문에 이 절차는 관리자 및 편집자에게만 **해당**됩니다. 이 사람들은 GitHub에 푸시 및 병합된 어떤 것이 문서 웹 사이트의 서비스를 손상시키지 않도록 도구(mkdocs의 로컬 설치 및 문서 및 docs.rockylinux.org 의 복제본)를 마련할 것입니다. 기여자는 이러한 요구 사항 중 하나라도 갖추고 있다고 기대할 수 없습니다.


### `.pages` 파일

이미 언급했듯이 `.pages` 파일은 일반적으로 매우 간단합니다. 콘텐츠를 렌더링하기 전에 `mkdocs`가 읽는 YAML 형식의 파일입니다. 더 복잡한 `.pages` 파일 중 하나를 살펴보기 위해 측면 탐색 형식을 지원하기 위해 생성된 파일을 살펴보겠습니다.

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
여기에서 `index*md`는 "Guides Home:"을 보여주고, `installation*.md`는 "Installing Rocky Linux" 문서 링크를 보여주며, `migrate2rocky*. md`는 "Migrating To Rocky Linux" 문서 링크를 보여줍니다. 이러한 각 링크 내의 "*"는 해당 문서를 _모든_ 언어로 허용합니다. 마지막으로, "기여"를 다음에 배치하면 일반(알파벳) 정렬 순서가 아닌 이러한 항목 아래에 들어갑니다. 목록을 살펴보면 각 항목이 수행하는 작업을 볼 수 있습니다. "패키지 관리: 패키지 관리" 항목 뒤에는 실제로 두 개의 폴더(security 및 web)가 더 있습니다. 여기에는 추가 서식이 필요하지 않으므로 `mkdocs`에 "-..."를 사용하여 정상적으로 로드하도록 지시합니다.

실제 파일 내에서 YAML 형식을 사용할 수도 있습니다. 이렇게 하는 이유는 파일의 시작 머리글이 너무 길어 탐색 섹션에 제대로 표시되지 않기 때문일 수 있습니다.  예를 들어 "httpd Apache 웹 서버 환경의 Rocky Linux에서 # `mod_ssl`"이라는 제목의 이 문서를 살펴보십시오. 그것은 매우 깁니다. "웹" 탐색 항목이 열리면 측면 탐색에서 매우 제대로 표시되지 않습니다. 이 문제를 해결하려면 작성자와 작업하여 제목을 변경하거나 문서 내부의 제목 앞에 제목을 추가하여 메뉴에 표시되는 방식을 변경할 수 있습니다. 예제 문서의 경우 제목이 추가됩니다.
```
---
title: Apache With `mod_ssl`
---
```
이렇게 하면 탐색과 관련하여 제목이 변경되지만 작성자의 원래 제목은 문서 내에서 그대로 유지됩니다.

추가 `.pages` 파일이 많이 필요하지 않을 것입니다. 경제적으로 사용해야 합니다.

## 결론

수행해야 할 수 있는 탐색 변경은 어렵지 않지만 라이브 문서를 깨뜨릴 가능성이 있습니다. 이러한 이유로 적절한 도구를 갖춘 관리자와 편집자만 이러한 파일을 편집할 수 있는 권한을 가져야 합니다. 라이브 페이지가 어떻게 보이는지 볼 수 있는 전체 환경이 있으면 관리자나 편집자가 이러한 파일을 편집하는 동안 라이브 문서를 손상시키는 실수를 방지할 수 있습니다.
