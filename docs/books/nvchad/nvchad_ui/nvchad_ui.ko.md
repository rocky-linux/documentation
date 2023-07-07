---
title: NvChad UI
author: Franco Colussi
contributors: Steven Spencer
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - nvchad 인터페이스
---

# Nvchad 인터페이스

!!! 참고 "`mappings.lua`에 대한 몇 마디"

    NvChad의 공식 문서 전반에 걸쳐 '<leader>'와 같은 명령과 일반 독자가 이해할 수 없는 다른 키가 언급되어 있습니다. 그 이유는 기본 `mappings.lua` 파일(`../nvim/lua/core/mappings.lua`) 때문입니다.
    
    이 파일과 설명하는 키 매핑은 이곳에 설명되어 있습니다[here](https://nvchad.com/docs/config/mappings).. 명확히 하기 위해 사용자 지정 `mappings.lua` 파일(`../nvim/lua/custom/mappings.lua`)을 사용하여 모든 키 매핑을 재정의할 수 있습니다.
    
    지금 읽고 있는 문서에서 혼동을 방지하기 위해 기본 `mappings.lua` 파일을 사용하고 있다고 가정합니다.함수에 액세스하는 데 사용해야 하는 실제 명령을 대체합니다. 표준 키 참조는 다음과 같습니다.

    * leader = <kbd>SPACE</kbd>
    * A = <kbd>ALT</kbd>
    * C = <kbd>CTRL</kbd>
    * S = <kbd>SHFT</kbd>

    예를 들어 명령에서 `<leader>uu`를 지정하는 경우 <kbd>SPACE</kbd><kbd>uu</kbd>의 실제 키 조합으로 대체합니다.

    이는 다음 섹션[NvChad 사용](./using_nvchad.md)에서 다시 다룰 것입니다.

Neovim이 설치되고 NvChad 구성이 입력되면 IDE는 다음과 같아야 합니다.

![NvChad Default](../images/ui_default.png)

인터페이스에는 이미 git 리포지토리의 상태 표시와 같은 일부 고급 기능이 포함되어 있지만 Language Server를 사용하여 추가로 향상되고 일부 기본 구성을 재정의하여 사용자 정의할 수 있습니다. 이를 구성하는 기본 모듈은 아래에 자세히 설명되어 있습니다.

## Tabufline

![Tabufline](../images/ui_tabufline.png)

사용자 인터페이스는 열린 버퍼가 관리되는 `Tabufline`이라는 상단 표시줄을 제공합니다. `Tabufline`은 하나 이상의 파일이 열려 있는 경우에만 표시됩니다. 열린 버퍼는 파일 유형 아이콘, 파일 이름 및 해당 상태를 나타냅니다. 상태는 아이콘으로 표시됩니다.

스크린샷에서와 같이 빨간색 `x`가 있으면 파일이 이미 저장되어 있으므로 닫을 수 있음을 의미합니다. 대신 아이콘이 녹색 점 `.`이면 파일을 저장해야 하며 닫기 명령 <kbd>SHIFT</kbd> + <kbd>:q</kbd>는 다음과 같은 경고를 생성합니다: "마지막 변경 이후 쓰기가 없습니다."

오른쪽에는 _어둡게_ 또는 _밝게_ 테마를 설정하는 아이콘이 있습니다. 마우스로 클릭하면 원하는 테마를 선택할 수 있습니다.

![NvChad Light](../images/ui_default_light.png)

오른쪽에는 편집기를 닫는 아이콘도 있습니다.

## 중간 섹션 - 오픈 버퍼

편집기의 중앙 부분은 그 순간 편집기에서 활성화된 버퍼(_index.en.md_)로 구성됩니다. 몇 가지 추가 기능을 소개하기 위해 예제(_index.it.md_)에서 파일을 하나 더 열어 분할 버퍼에서 두 파일에 대해 동시에 작업할 수 있습니다.

편집기에서 전경에 첫 번째 버퍼가 있고 Tabufline에 나열된 두 번째 버퍼가 있습니다. 이제 <kbd>SHIFT</kbd> + <kbd>:vsplit</kbd> 명령으로 첫 번째 버퍼를 분할하고 올바른 버퍼를 선택하면 두 번째 파일의 이름(*index.it.md*) tabufline에서 이것은 오른쪽 버퍼에서 열리고 두 파일을 나란히 작업할 수 있습니다.

![NvChad Split](../images/ui_nvchad_split.png)

## Statusline

![Statusline](../images/ui_statusline.png)

하단에는 상태 정보를 처리하는 Statusline이 있습니다. 하단에는 상태 정보를 처리하는 Statusline이 있습니다. 우리는 텍스트 편집기를 사용하고 있으며 특히 Vim의 철학과 운영을 유지한다는 사실을 잊지 말아야 합니다. 가능한 상태는 다음과 같습니다.

- **NORMAL**
- **INSERT**
- **COMMAND**
- **VISUAL**

문서 편집은 파일을 여는 **NORMAL** 모드에서 시작한 다음 **INSERT** 모드로 전환하여 다음을 수행할 수 있습니다. 편집을 마치면 <kbd>ESC</kbd>를 눌러 종료하고 **NORMAL** 모드로 돌아갑니다.

이제 파일을 저장하려면 상태 표시줄에 `:`를 입력한 다음 `w`(_write_) 작성하고 <kbd>ESC</kbd>를 누르면 **NORMAL** 모드로 돌아갑니다. 상태 표시는 사용 방법을 배우는 동안 특히 Vim 작업 흐름에 익숙하지 않은 경우 매우 유용합니다.

그런 다음 열린 파일의 이름을 찾고 git 리포지토리에서 작업하는 경우 리포지토리 상태에 대한 표시가 나타납니다. 이는 _lewis6991/gitsigns.nvim_ 플러그인 덕분입니다.

오른쪽으로 돌아가면 편집기를 연 폴더의 이름이 있습니다. LSP를 사용하는 경우 `workspace`로 간주되어 진단 시 결과적으로 평가되는 폴더를 나타내며, 파일 내에서 커서의 위치를 따라갑니다.

## 통합 도움말

NvChad 및 Neovim은 사전 설정 키 조합 및 사용 가능한 옵션을 표시하는 몇 가지 유용한 명령을 제공합니다.

<kbd>SPACE</kbd> 키만 누르면 다음 스크린샷과 같이 관련 명령의 범례가 제공됩니다.

![스페이스 키](../images/ui_escape_key.png)

편집기에 포함된 모든 명령을 보려면 <kbd>SPACE</kbd> + <kbd>wK</kbd> 명령을 사용하면 다음과 같은 결과를 얻을 수 있습니다.

![leader wK](../images/ui_wK_key.png)

그리고 <kbd>d</kbd>를 누르면 나머지 명령을 표시할 수 있습니다.

![leader wK d](../images/ui_wK_01.png)

보시다시피 거의 모든 명령은 문서 또는 버퍼 내 탐색을 참조합니다. 파일을 여는 명령은 포함되어 있지 않습니다. 이것들은 Neovim에서 제공합니다.

Neovim의 모든 옵션을 보려면 <kbd>SHIFT</kbd> + <kbd>:options</kbd> 명령을 사용할 수 있습니다. 이 명령은 범주별로 색인화된 옵션 트리를 제공합니다.

![Nvim 옵션](../images/nvim_options.png)

이렇게 하면 내장 도움말을 통해 편집기를 사용하는 동안 명령을 배우고 사용 가능한 옵션을 자세히 알아볼 수 있습니다.

## NvimTree

파일로 작업하려면 파일 탐색기가 필요하며 이는 _kyazdani42/nvim-tree.lua_ 플러그인에서 제공합니다. <kbd>CTRL</kbd> + <kbd>n</kbd> 조합으로 NvimTree를 열 수 있습니다.

![NvimTree](../images/nvim_tree.png)

NvimTree의 명령 및 기능에 대한 자세한 설명은 [전용 페이지](nvimtree.md)에서 확인할 수 있습니다.

이제 인터페이스 구성 요소를 살펴보았으므로 NvChad 사용으로 넘어갈 수 있습니다.
