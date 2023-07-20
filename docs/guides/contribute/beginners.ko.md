---
title: 처음 기여자를 위한 가이드
author: Krista Burdine
contributors: Ezequiel Bruni, Steven Spencer
tags:
  - 기여하기
  - 문서
  - 입문자
  - howto
---

# 처음 기여자를 위한 가이드

_모든 사람들은 어딘가에서 시작합니다. GitHub의 오픈 소스 문서에 기여한 것이 이번이 처음이라면 이 단계를 수행한 것을 축하합니다. 우리는 당신이 말해야 할 것을 기다릴 수 없습니다!_

## Git and GitHub

모든 기여자 지침은 GitHub 계정이 있다고 가정합니다. 한 번도 해본 적이 없다면 지금이 그 때입니다. 12분의 시간이 있다면 Udemy의 [Git 및 GitHub 초보자 가이드](https://www.udacity.com/blog/2015/06/a-beginners-git-github-tutorial.html)와 함께 GitHub가 무엇인지에 대한 기본 사항을 알아보세요.

Rocky Linux용 리포지토리 생성 및 관리를 시작하지 않을 수도 있지만 이 [Hello World 튜토리얼](https://docs.github.com/en/get-started/quickstart/hello-world)는 GitHub 계정 생성, 용어 학습 및 저장소가 어떻게 작동하는지 이해하는 과정을 안내합니다. 기존 문서를 업데이트하고 커밋하는 방법과 끌어오기 요청을 만드는 방법을 배우는 데 집중하세요.

## Markdown

Markdown은 동일한 파일에 서식 지정, 코드 및 일반 텍스트를 포함할 수 있는 쉬운 언어입니다. 문서를 처음 업데이트할 때 기존 코드를 따르기만 하면 됩니다. 머지않아 추가 기능을 탐색할 준비가 됩니다. 때가되면 여기에 기본 사항이 있습니다.

* [Basic Markdown](https://www.markdownguide.org/basic-syntax#code)
* [Extended Markdown](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)
* 저장소에서 사용하는 [고급 서식 지정](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) 옵션 중 일부

## 로컬 리포지토리 편집기

로컬 리포지토리를 만들려면 먼저 컴퓨터 및 운영 체제에서 작동하는 Markdown 편집기를 찾아 설치합니다. 여기에 몇 가지 옵션이 있지만 다른 옵션도 있습니다. 알고 있는 것을 사용하십시오.

* [ReText](https://github.com/retext-project/retext) - 무료, 교차 플랫폼 및 오픈 소스
* [Zettlr](https://www.zettlr.com/) - 무료, 교차 플랫폼 및 오픈 소스
* [MarkText](https://github.com/marktext/marktext) - 무료, 교차 플랫폼 및 오픈 소스
* [Remarkable](https://remarkableapp.github.io/) - Linux 및 Windows, 오픈 소스
* [NvChad](https://nvchad.com/) vi/vim 사용자 및 nvim 클라이언트용. 마크다운 편집기를 향상시키기 위해 많은 플러그인을 사용할 수 있습니다. 유용한 설치 지침은 [이 문서](https://docs.rockylinux.org/books/nvchad/)를 참조하세요.
* [VS Code](https://code.visualstudio.com/) - 부분적으로 Microsoft에서 공개한 소스입니다. VS Code는 Windows, Linux 및 MacOS에서 사용할 수 있는 가볍고 강력한 편집기입니다. 이 문서 프로젝트에 기여하려면 Git Graph, HTML 미리보기, HTML 스니펫, Markdown All in One, Markdown Preview Enhanced, Markdown Preview Mermaid 지원 등의 확장 프로그램을 받아야 합니다.

## 로컬 리포지토리 만들기

Markdown 편집기가 설치되면 지침에 따라 GitHub 계정에 연결하고 리포지토리를 로컬 컴퓨터에 다운로드합니다. 문서 업데이트를 준비할 때마다 다음 단계에 따라 로컬 및 온라인 포크를 메인 브랜치와 동기화하여 최신 버전으로 작업하고 있는지 확인하세요.

1. GitHub 내에서 설명서 리포지토리의 포크를 기본 분기와 동기화합니다.
2. Markdown 편집기 지침에 따라 현재 포크를 로컬 컴퓨터와 동기화합니다.
3. Markdown 편집기 내에서 수정하려는 문서를 엽니다.
4. 문서를 수정합니다.
5. 저장합니다
6. 편집기 내에서 변경 사항을 커밋하면 로컬 리포지토리가 온라인 포크와 동기화됩니다.
7. GitHub 내에서 포크에서 업데이트된 문서를 찾고 끌어오기 요청을 생성하여 이를 기본 문서와 병합합니다.

## 업데이트 제출

_누락된 단어를 추가하고, 오류를 수정하고, 혼란스러운 텍스트 부분을 명확히 합니다._

1. 업데이트하려는 페이지에서 시작하십시오.

    업데이트하려는 문서의 오른쪽 상단 모서리에 있는 "편집" 연필을 클릭합니다. GitHub의 원본 문서로 이동합니다.

    RL 저장소에 처음 기여할 때 "이 **저장소**를 **포크**하고 변경 사항을 제안합니다"라는 녹색 버튼이 표시됩니다. 이렇게 하면 제안된 편집을 수행하는 RL 저장소의 복제본이 생성됩니다. 녹색 버튼을 클릭하고 계속 진행하면 됩니다.

2. 변경합니다

    Markdown 형식을 따릅니다. 예를 들어 누락된 단어가 있거나 21행의 링크를 수정해야 할 수 있습니다. 필요한 변경을 합니다.

3. 변경 제안

    페이지 하단에서 "**변경 제안"**이라는 제목의 블록 제목에 한 줄 설명을 작성합니다. 문서 맨 위에 있는 파일 이름을 참조하는 것이 도움이 되지만 필수는 아닙니다.

    따라서 마크다운 텍스트의 21행에 있는 링크를 업데이트한 경우"Update README.md with correct links." 와 같이 말할 수 있습니다.

    **참고: 당신의 행동을 현재 시제로 말하세요.**

    그런 다음 변경 제안을 클릭하면 포크된 저장소 내에서 전체 문서에 대한 변경 사항을 **커밋**합니다.

4. 변경 사항 검토

    이제 수행한 작업을 한 줄씩 볼 수 있습니다. 놓친 것이 있습니까? 이전 페이지로 돌아가서 다시 수정한 다음(처음부터 다시 시작해야 함) 변경 제안을 다시 클릭합니다.

    문서가 원하는 방식이 되면 Create Pull Request라는 녹색 버튼을 클릭합니다. 이렇게 하면 변경 사항을 다시 확인하고 문서가 준비되었는지 확인할 수 있는 기회가 한 번 더 제공됩니다.

5. 풀 리퀘스트 생성

    지금까지의 모든 작업은 RL 기본 리포지토리를 중단할 기회 없이 자체 리포지토리에서 수행되었습니다. 다음으로 문서 팀에 제출하여 문서의 기본 버전에 버전을 병합합니다.

    Create Pull Request라고 표시된 큰 녹색 버튼을 클릭합니다. 좋은 소식입니다. 이제 검토를 위해 RL 문서화 팀으로 이동하기 때문에 아직 아무 것도 깨지지 않았습니다.

6. 기다리십쇼.

    RL 팀이 귀하의 요청을 받으면 세 가지 방법 중 하나로 응답합니다.

    * PR 수락 및 병합
    * 피드백과 함께 의견을 제시하고 변경 요청
    * 설명과 함께 PR 거부

    마지막 응답이 있을 것 같지 않습니다. 여기에 여러분의 관점을 포함시키고 싶습니다! 변경해야 하는 경우 로컬 리포지토리가 필요한 이유를 갑자기 이해할 수 있습니다. 팀에서 다음에 해야 할 일을 [설명](https://chat.rockylinux.org/rocky-linux/channels/documentation)할 수 있습니다. 좋은 소식은 여전히 고칠 수 있다는 것입니다. 요청된 추가 정보를 보려면 해당 요청의 설명 섹션을 따르십시오.

    그렇지 않으면 귀하의 요청이 수락되고 병합됩니다. 팀에 오신 것을 환영합니다. 이제 공식적으로 기여자입니다! 며칠 후 기여자 가이드 하단에 있는 모든 기여자 목록에 귀하의 이름이 표시되는지 확인하십시오.
