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

이 장에서는 NvChad 특정 명령어와 일반 Neovim(vim) 명령어를 소개합니다.  이전에 [NvChad UI](nvchad_ui.md)에서 설명한 대로, NvChad 명령어는 `..nvim/lua/core/mapping.lua`파일에 설정되어 있으며, 키를 사용하여 때로는 매우 긴 복합 명령을 실행할 수 있습니다.

모든 시퀀스는 주 키와 옵션으로 시작합니다. 네 가지 주요 키는 다음과 같습니다:

* leader = <kbd>SPACE</kbd>
* A = <kbd>ALT</kbd>
* C = <kbd>CTRL</kbd>
* S = <kbd>SHFT</kbd>

"NvChad UI" 문서와 마찬가지로, 매핑 대신 실제로 입력해야 하는 명령을 대체하겠습니다.

## 파일 열기

편집기에서 파일을 열기 위해 여러 가지 방법을 사용할 수 있습니다. 파일 이름을 지정하여 명령 줄에서 간단히 시작할 수 있습니다:

```bash
nvim /path/to/the/file
```

또는 `nvim` 명령으로 편집기를 열 수 있습니다.

후자의 방법을 사용하면 몇 가지 가능성이 있습니다. <kbd>SHIFT</kbd> + <kbd>: e</kbd> + <kbd>SPACE</kbd>(edit) 명령 뒤에 경로를 입력하거나 명령 뒤에 <kbd>TAB</kbd>키를 입력하여 버퍼에서 파일을 열 수 있습니다.

이렇게 하면 프로젝트의 root에서 시작하는 모든 사용 가능한 파일과 폴더가 표시됩니다. 파일 열기 명령에서 <kbd>TAB</kbd> 키를 사용할 때 편리한 드롭다운 메뉴에서 파일을 선택할 수 있습니다. 이 드롭다운 메뉴가 열린 후에는 <kbd>TAB</kbd> 키를 반복해서 사용하여 메뉴 내에서 계속 이동할 수 있습니다.

![Command :e + TAB](../images/e_tab_command.png)

나열된 각 명령 앞에는 <kbd>SHIFT</kbd>가 있고 뒤에는 <kbd>SPACE</kbd>와 경로 또는 <kbd>TAB</kbd> 키가 옵니다. 다른 작업 목록은 다음과 같습니다.

* `:view` - 변경할 수 없는 읽기 전용 모드로 파일 보기. 중요한 파일의 보호에 매우 좋습니다.
* `:split` - 파일을 수평으로 분할된 화면에 열기.
* `:vsplit` - 파일을 수직으로 분할된 화면에 열기.
* `:tabedit` - 새 탭에서 파일 열기.

다음 예제에서는 `:vsplit`을 사용하여 파일을 열었습니다.

![Vsplit Open](../images/vsplit_open.png)

NvChad 개발자들의 노력 덕분에 *nvim-telescope/telescope.nvim* 플러그인을 사용하여 파일을 열 수 있는 추가적인 방법을 제공받을 수 있습니다.

이 플러그인은 *RipGrep*과 함께 사용할 때 상호작용 모드에서 파일을 검색하고 열 수 있도록 합니다. 우리가 찾고자 하는 파일의 초기 문자를 입력하면, 플러그인은 일치하지 않는 모든 파일을 무시하고 검색과 일치하는 파일만 보여줍니다. 이를 통해 매우 원활한 검색 및 열기 프로세스를 할 수 있습니다.

telescope의 파일 검색 기능에 액세스하려면 편집기에서 NORMAL 모드에 있어야 하며, 다음과 같이 입력해야 합니다: <kbd>SHIFT</kbd> + <kbd>:Telescope fd</kbd>

![<leader>ff](../images/leader_ff.png)

## 편집기 작업

파일을 열면 편집을 시작할 수 있습니다. 이를 위해 INSERT 모드로 전환해야 합니다. INSERT 모드로 전환하려면 <kbd>i</kbd>(insert) 키를 누르면 됩니다. 상태 표시줄에 있는 모드 표시기는 NORMAL에서 INSERT로 변경되어야 하며, 버퍼에 있는 커서도 색이 있는 사각형에서 `|` 파이프로 변경되어야 합니다.

이제 입력하는 모든 문자는 커서 위치를 기준으로 문서에 삽입됩니다. INSERT 모드에서 커서를 이동하기 위해 Nvchad 개발자들이 편리한 매핑을 설정했습니다. 이 매핑은 다음과 같습니다:

- <kbd>CTRL</kbd> + <kbd>b</kbd> 줄의 시작으로 이동
- <kbd>CTRL</kbd> + <kbd>e</kbd> 줄의 끝으로 이동
- <kbd>CTRL</kbd> + <kbd>h</kbd> 왼쪽으로 한 글자 이동
- <kbd>CTRL</kbd> + <kbd>l</kbd> 오른쪽으로 한 글자 이동
- <kbd>CTRL</kbd> + <kbd>j</kbd> 다음 줄로 이동
- <kbd>CTRL</kbd> + <kbd>k</kbd> 이전 줄로 이동

모든 조합을 학습하는 데는 시간이 걸리지만, 한 번 습득하면 탐색이 매우 빨라집니다. 예를 들어, 커서가 있는 위치에서 다음 줄의 끝을 편집하려면 <kbd>CTRL</kbd> + <kbd>e</kbd>로 현재 줄의 끝으로 이동한 다음 <kbd>CTRL</kbd> + <kbd>j</kbd>로 다음 줄로 이동하여 변경 사항을 추가할 준비를 할 수 있습니다.

문서 내에서 탐색은 키보드의 화살표 키나 마우스를 사용하여 수행할 수도 있습니다.

### 텍스트 선택

텍스트 선택은 마우스를 사용하여 매우 편리하게 수행할 수 있지만, 이 장에서는 전통적인 키보드 기반 방법을 사용하겠습니다.

텍스트를 선택하려면 VISUAL 모드로 진입해야 합니다. 이를 위해 먼저 삽입 모드를 종료하고 NORMAL 모드로 전환해야 하는데, 이는 <kbd>ESC</kbd> 키로 수행됩니다.

원하는 부분의 시작 위치에 커서를 배치한 후, 키보드에서 <kbd>CTRL</kbd> + <kbd>v</kbd> 키를 사용하여 V-BLOC(Visual Block) 모드로 진입합니다. 이제 커서로 이동하면 선택한 부분이 강조 표시될 것입니다. 이제 텍스트의 선택 부분에서 작업을 수행할 수 있습니다.

선택한 부분을 클립보드에 복사하려면 <kbd>y</kbd> 키를 사용합니다. 삭제하려면 <kbd>d</kbd> 키를 사용합니다. 작업을 완료하면 텍스트가 더 이상 강조되지 않습니다. Visual 모드에서 수행할 수 있는 모든 작업에 대한 개요는 <kbd>SHIFT</kbd> + <kbd>:help Visual-Mode</kbd>을 통해 편집기에서 직접 도움말을 참조할 수 있습니다.

![Visual Mode 도움말](../images/help_visual_mode.png)

### 텍스트 검색

검색을 위해 슬래시 문자 <kbd>/</kbd> 다음에 검색 키 `/search_key`를 사용하여 모든 발생을 강조 표시합니다. 다음으로 이동하려면 <kbd>/</kbd> + <kbd>Enter</kbd> 조합을 사용합니다. 이전으로 이동하려면 <kbd>?</kbd> + <kbd>Enter</kbd>를 사용합니다.

검색을 완료하면 강조 표시를 제거할 수 있습니다. 이를 위해 <kbd>SHIFT</kbd> + <kbd>:noh</kbd>(강조표시 없음) 명령을 사용합니다.

![명령 찾기](../images/find_command.png)

검색은 위의 예시보다 더 복잡할 수 있습니다. 와일드카드, 카운터 및 기타 옵션을 사용할 수 있습니다. 더 많은 옵션을 보려면 도움말 명령(<kbd>SHIFT</kbd> + <kbd>:help /</kbd>)을 사용할 수 있습니다.

## 문서 저장

파일을 생성하거나 수정한 후에는 먼저 <kbd>ESC</kbd>를 사용하여 INSERT 모드를 종료한 다음, 명령 <kbd>SHIFT</kbd> + <kbd>:w</kbd>(write)를 입력하여 현재 위치에 해당 파일을 저장합니다. 파일을 다른 이름이나 다른 위치에 저장하려면 저장 경로에 따라 명령을 입력하면 됩니다:

```text
:w /path/to/new/file_or_position
```

편집기를 저장하고 동시에 닫으려면 <kbd>SHIFT</kbd> + <kbd>:wq</kbd>(write - quit) 명령을 사용합니다.

이 장에서는 편집기를 소개했습니다. 여기에 설명된 것보다 더 많은 고급 기능이 있습니다. 이러한 기능은 [Neovim 도움말](https://neovim.io/doc/user/) 페이지에서 참조하거나 편집기에서 다음 명령 <kbd>SHIFT</kbd> + <kbd>:help</kbd>을 입력하여 참조할 수 있습니다.

