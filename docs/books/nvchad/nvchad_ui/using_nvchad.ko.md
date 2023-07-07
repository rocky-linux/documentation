---
title: NvChad 사용
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# NvChad로 편집

이 장에서는 일부 NvChad 관련 명령과 일부 표준 Neovim(vim) 명령을 소개합니다.  이전에 [NvChad UI](nvchad_ui.md)에서 설명한 것처럼 NvChad 명령은 `..nvim/lua/core/mapping.lua`파일에 설정되며 키를 사용하여 때때로 매우 긴 복합 명령을 실행할 수 있습니다.

모든 시퀀스는 기본 키와 옵션으로 시작됩니다. 네 가지 주요 키는 다음과 같습니다.

* leader = <kbd>SPACE</kbd>
* A = <kbd>ALT</kbd>
* C = <kbd>CTRL</kbd>
* S = <kbd>SHFT</kbd>

"NvChad UI" 문서에서와 마찬가지로 매핑이 아닌 입력할 실제 명령으로 대체할 것입니다.

## 파일 열기

편집기에서 파일을 열려면 다양한 방법을 사용할 수 있습니다. 다음과 같이 파일 이름을 표시하여 명령줄에서 간단하게 시작할 수 있습니다.

```bash
nvim /path/to/the/file
```

또는 `nvim` 명령으로 편집기를 엽니다.

후자의 방법을 사용하면 몇 가지 가능성이 있습니다. <kbd>SHIFT</kbd> + <kbd>: e</kbd> + <kbd>SPACE</kbd>(edit) 명령 뒤에 경로를 입력하거나 명령 뒤에 <kbd>TAB</kbd>키를 입력하여 버퍼에서 파일을 열 수 있습니다.

이렇게 하면 프로젝트의 root에서 시작하여 사용 가능한 모든 파일과 폴더가 표시됩니다. 파일 열기 명령에서 <kbd>TAB</kbd> 키를 사용할 때 편리한 드롭다운 메뉴에서 파일을 선택할 수 있다는 점을 기억하는 것이 좋습니다. 이 드롭다운 메뉴가 열리면 <kbd>TAB</kbd> 키를 반복해서 사용하여 계속 탐색합니다.

![Command :e + TAB](../images/e_tab_command.png)

나열된 각 명령 앞에는 <kbd>SHIFT</kbd>가 있고 뒤에는 <kbd>SPACE</kbd>와 경로 또는 <kbd>TAB</kbd> 키가 옵니다. 다른 작업 목록은 다음과 같습니다.

* `:view` - 파일을 변경하지 않고 읽기 전용 모드로 봅니다. 중요한 파일 보호에 매우 좋습니다.
* `:split` - 가로 분할 화면에서 파일을 엽니다.
* `:vsplit` - 세로 분할 화면에서 파일을 엽니다.
* `:tabedit` - 새 탭에서 파일을 엽니다.

다음 예제에서는 `:vsplit`을 사용하여 파일을 열었습니다.

![Vsplit Open](../images/vsplit_open.png)

NvChad 개발자의 작업 덕분에 *nvim-telescope/telescope.nvim* 플러그인을 사용하여 파일을 여는 추가 방법이 제공됩니다.

이 플러그인을 *RipGrep*과 함께 사용하면 대화형 모드에서 열 파일을 검색할 수 있습니다. 찾고 있는 파일의 초기 문자를 입력하면 플러그인은 일치하지 않는 모든 파일을 무시하고 검색과 일치하는 파일만 제공합니다. 이를 통해 매우 원활한 검색 및 공개 프로세스가 가능합니다.

망원경의 파일 찾기 기능에 액세스하려면 편집기에서 NORMAL 모드에 있어야 하며 <kbd>SHIFT</kbd> + <kbd>:Telescope fd</kbd>를 입력해야 합니다.

![<leader>ff](../images/leader_ff.png)

## 편집기 작업

파일이 열리면 편집을 시작할 수 있습니다. 이렇게 하려면 <kbd>i</kbd>(insert) 키를 눌러 활성화되는 INSERT 모드로 전환해야 합니다. 상태 표시줄의 모드 표시기가 NORMAL에서 INSERT로 변경되고 버퍼에 놓인 커서도 색상 사각형에서 `|` 파이프로 변경되어야 합니다.

이제 입력한 모든 문자가 커서 위치에서 시작하여 문서에 삽입됩니다. INSERT 모드에서 커서를 이동하기 위해 Nvchad 개발자는 다음과 같은 몇 가지 편리한 매핑을 설정했습니다.

- <kbd>CTRL</kbd> + <kbd>b</kbd> 줄의 시작 부분으로 이동
- <kbd>CTRL</kbd> + <kbd>e</kbd> 줄 끝으로 이동
- <kbd>CTRL</kbd> + <kbd>h</kbd> 왼쪽으로 한 문자 이동
- <kbd>CTRL</kbd> + <kbd>l</kbd> 오른쪽으로 한 문자 이동
- <kbd>CTRL</kbd> + <kbd>j</kbd> 다음 줄로 이동
- <kbd>CTRL</kbd> + <kbd>k</kbd> 이전 줄로 이동

모든 조합을 배우는 데는 시간이 좀 걸리지만 일단 습득하면 탐색 속도가 매우 빨라집니다. 예를 들어 커서가 있는 다음 줄의 끝을 편집하려는 경우 <kbd>CTRL</kbd> + <kbd>e</kbd>를 사용하여 현재 줄의 끝으로 이동할 수 있습니다. 그런 다음 <kbd>CTRL</kbd> + <kbd>j</kbd>를 사용하여 다음 항목으로 이동하고  변경 사항을 추가할 수 있습니다.

키보드 또는 마우스의 화살표 키를 사용하여 문서 탐색을 수행할 수도 있습니다.

### 텍스트 선택

텍스트 선택은 마우스로도 할 수 있어 매우 편리하지만 이 장에서는 기존의 키보드 기반 방법을 사용하겠습니다.

텍스트를 선택하려면 VISUAL 모드로 들어가야 합니다. 이렇게 하려면 먼저 삽입 모드를 종료하고 <kbd>ESC</kbd> 키를 사용하여 일반 모드로 전환해야 합니다.

선택하려는 부분의 시작 부분에 커서를 놓으면 <kbd>CTRL</kbd> + <kbd>v</kbd> 키를 사용하여 V-BLOC(Visual Block) 모드로 들어갑니다. 이제 커서로 이동하면 선택 항목이 강조 표시됩니다. 이 시점에서 텍스트의 선택된 부분에 대해 작업할 수 있습니다.

선택 항목을 클립보드에 복사하려면 <kbd>y</kbd> 키를 사용합니다. 삭제하려면 <kbd>d</kbd> 키를 누릅니다. 작업이 완료되면 텍스트가 더 이상 강조 표시되지 않습니다. 시각 모드에서 수행할 수 있는 모든 작업에 대한 개요는 <kbd>SHIFT</kbd> + <kbd>:help Visual-Mode</kbd>를 사용하여 편집기에서 직접 도움말을 참조할 수 있습니다.

![Visual Mode 도움말](../images/help_visual_mode.png)

### 텍스트 검색

검색을 위해 슬래시 문자 <kbd>/</kbd> 다음에 검색 키 `/search_key`가 사용되어 발견된 모든 항목을 강조 표시합니다. 다음으로 이동하려면 <kbd>/</kbd> + <kbd>Enter</kbd> 조합을 사용합니다. 이전 항목으로 이동하려면 <kbd>?</kbd> + <kbd>Enter</kbd>를 누르십시오.

검색이 완료되면 <kbd>SHIFT</kbd> + <kbd>:noh</kbd>(강조표시 없음) 명령을 사용하여 강조표시를 제거할 수 있습니다.

![명령 찾기](../images/find_command.png)

검색은 위에서 설명한 것보다 훨씬 더 복잡할 수 있습니다. 와일드카드, 카운터 및 기타 옵션을 사용할 수 있습니다. 도움말 명령(<kbd>SHIFT</kbd> + <kbd>:help /</kbd>)을 사용하여 더 많은 옵션을 볼 수 있습니다.

## 문서 저장

파일이 생성되거나 수정되면 먼저 <kbd>ESC</kbd>를 사용하여 INSERT 모드를 종료한 다음 명령 <kbd>SHIFT</kbd> + <kbd>:w</kbd>(write) 파일이 있는 위치에 현재 이름으로 파일을 저장합니다. 다른 이름이나 다른 위치에 파일을 저장하려면 저장 경로를 따라가는 명령을 내리기만 하면 됩니다.

```text
:w /path/to/new/file_or_position
```

편집기를 저장하고 동시에 닫으려면 <kbd>SHIFT</kbd> + <kbd>:wq</kbd>(write - quit) 명령을 사용합니다.

이 장에서는 편집기를 소개했습니다. 여기에 설명된 것보다 더 많은 고급 기능이 있습니다. 이러한 기능은 [Neovim 도움말](https://neovim.io/doc/user/) 페이지에서 참조하거나 편집기에서 다음 명령 <kbd>SHIFT</kbd> + <kbd>:help</kbd>을 입력하여 참조할 수 있습니다.

