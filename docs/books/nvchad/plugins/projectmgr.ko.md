---
title: 프로젝트 매니저
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - plugins
  - editor
---

# 프로젝트 매니저

## 소개

IDE가 반드시 갖춰야 하는 기능 중 하나는 개발자나 출판자가 작업하는 다양한 프로젝트를 관리할 수 있는 능력입니다. NvChad를 열면 *상태 표시줄*에 명령어를 입력하지 않고도 작업할 프로젝트를 선택할 수 있어 시간을 절약하고 많은 프로젝트를 간편하게 관리할 수 있습니다. 이를 통해 시간을 절약하고 프로젝트 수가 많은 경우 관리를 간소화할 수 있습니다.

[charludo/projectmgr.nvim](https://github.com/charludo/projectmgr.nvim)을 사용하면 이러한 기능을 통합할 수 있습니다. 이 플러그인은 `Telescope`와 훌륭한 통합 기능을 제공하며, *프로젝트*를 열 때 *git* 리포지토리를 동기화하는 등 흥미로운 추가 기능을 제공합니다.

또한, 플러그인은 편집기를 닫을 때 편집기의 상태를 추적하여 다음에 열 때 작업하던 모든 페이지를 가질 수 있도록 합니다.

### 플러그인 설치

플러그인을 설치하려면 **custom/plugins.lua** 파일을 열어 다음 코드 블록을 추가해야 합니다:

```lua
{
    "charludo/projectmgr.nvim",
    lazy = false, -- important!
},
```

파일을 저장한 후 플러그인이 설치됩니다. `:Lazy` 명령을 사용하여 *lazy.nvim*을 열고 <kbd>I</kbd>를 입력하여 설치를 진행하면 됩니다. 설치가 완료되면 편집기를 종료한 다음 다시 열어 새로 입력한 구성을 읽을 수 있습니다.

플러그인은 `:ProjectMgr`라는 단일 명령어를 제공합니다. 이 명령어는 키보드 단축키를 사용하여 모든 작업을 수행할 수 있는 대화형 버퍼를 엽니다. 처음 열릴 때 버퍼는 비어 있으며, 아래 스크린샷에서 확인할 수 있습니다:

![ProjectMgr Init](./images/projectmgr_init.png)

### 프로젝트 매니저 사용

모든 작업은 <kbd>Ctrl</kbd> 키 다음에 문자(예: `<C-a`)를 사용하여 수행되며 `<CR>` 키는 <kbd>Enter</kbd> 키에 해당합니다.

다음 표에서 사용 가능한 모든 작업을 보여줍니다.

| 키             | 동작                      |
| ------------- | ----------------------- |
| `<CR>`  | 커서 아래에서 프로젝트를 엽니다.      |
| `<C-a>` | 대화식 절차를 통해 프로젝트를 추가합니다. |
| `<C-d>` | 프로젝트 삭제합니다.             |
| `<C-e>` | 프로젝트 설정 변경합니다.          |
| `<C-q>` | 버퍼를 닫습니다.               |

첫 번째 프로젝트를 추가하려면 *상태 표시줄*에서 <kbd>Ctrl</kbd> + <kbd>a</kbd> 조합을 사용해 대화형 메뉴를 열어야 합니다. 이 예제에서는 **~/lab/rockydocs/documentation**에 저장된 Rocky Linux 문서의 복제본을 사용합니다.

첫 번째 질문은 프로젝트 이름을 묻습니다.

> 프로젝트 이름: documentation

다음으로 프로젝트 경로를 입력해야 합니다:

> 프로젝트 경로: ~/lab/rockydocs/documentation/

이어서 프로젝트를 열 때 실행할 명령어를 설정할 수 있습니다. 이 명령어는 **bash** 언어가 아닌 편집기에서 실행되는 명령어를 참조합니다.

예를 들어, *NvimTree*를 사용하여 에디터를 열 때 측면 버퍼를 컨텍스트에 맞게 열 수 있습니다. 이 경우에는 `NvimTreeToggle` 명령어를 사용합니다.

> 시작 명령(선택 사항): NvimTreeToggle

또는 에디터를 닫을 때 명령어를 실행할 수도 있습니다.

> 종료 명령(선택 사항):

*상태 표시줄*에서 동일한 명령을 실행하는 데 사용되는 `:` 콜론을 생략하여 명령을 입력해야 합니다.

구성이 완료되면 프로젝트가 버퍼에 표시됩니다. 선택한 프로젝트를 열려면 해당 프로젝트를 선택한 후 <kbd>Enter</kbd> 키를 누르면 됩니다.

![ProjectMgr Add](./images/projectmgr_add.png)

**Config & Info** 섹션에서 확인할 수 있듯이 플러그인은 폴더가 *Git*으로 관리되는 것으로 인식하고 몇 가지 정보를 제공합니다.

프로젝트 편집은 <kbd>Ctrl</kbd> + <kbd>e</kbd>로 수행되며, 새로운 대화형 루프로 진행됩니다. 프로젝트 삭제는<kbd>Ctrl</kbd> + <kbd>d</kbd> 조합으로 수행됩니다.

### 추가 기능

플러그인은 [전용 섹션](https://github.com/charludo/projectmgr.nvim#%EF%B8%8F-configuration)에서 설명된 몇 가지 추가 기능을 제공합니다. 가장 흥미로운 기능은 프로젝트를 열 때 git 리포지토리를 동기화하는 기능과 편집기를 닫을 때 편집기의 상태를 저장하는 기능입니다. 기본 구성 파일에 이미 이러한 기능이 포함되어 있지만, *Git*에 대한 기능은 비활성화되어 있습니다.

프로젝트를 열 때 리포지토리 동기화를 추가하려면 다음과 같이 초기 플러그인 구성에 다음 코드를 추가해야 합니다:

```lua
config = function()
    require("projectmgr").setup({
        autogit = {
            enabled = true,
            command = "git pull --ff-only >> .git/fastforward.log 2>&1",
        },
    })
end,
```

코드에서 알 수 있듯이 `require("projectmgr").setup` 함수를 호출하여 기본 설정을 덮어쓸 수 있습니다. 내부에 설정한 내용은 작동 방식을 변경합니다.

`git pull --ff-only` 명령은 리포지토리의 *fast forward* 동기화를 수행하며, 충돌이 없고 개입 없이 업데이트할 수 있는 파일만 다운로드합니다.

명령어의 결과는 **.git/fastforward.log** 파일로 리다이렉트되어 NvChad가 실행 중인 터미널에 표시되지 않도록 하고, 동기화 기록을 사용할 수 있도록 합니다.

또한, 편집기를 닫을 때 세션을 저장하는 옵션이 제공됩니다. 이를 통해 프로젝트를 선택하고 다시 열 때 마지막으로 작업한 파일을 열 수 있습니다.

```lua
session = { enabled = true, file = "Session.vim" },
```

이 옵션은 기본적으로 활성화되지만, 프로젝트의 *root* 디렉터리에**Session.vim** 파일을 작성하며, Rocky Linux 문서의 경우 이는 원하는 동작이 아닙니다. 이 예제에서는 버전 관리되지 않는 `.git` 폴더에 저장합니다.

**Session.vim** 및 **fastforward.log**의 경로를 필요에 맞게 조정하십시오.

변경 사항을 완료한 후 구성은 다음과 같아야 합니다:

```lua
{
    "charludo/projectmgr.nvim",
    lazy = false, -- important!
    config = function()
        require("projectmgr").setup({
            autogit = {
                enabled = true,
                command = "git pull --ff-only > .git/fastforward.log 2>&1",
            },
            session = { enabled = true, file = ".git/Session.vim" },
        })
    end,
},
```

이제 프로젝트를 열 때마다 업데이트된 파일이 자동으로 Git 리포지토리에서 다운로드되고, 편집기에는 편집한 최신 파일이 열려 있게 됩니다.

!!! warning "주의"

    NvChad의 저장된 세션 버퍼에서 열린 파일은 자동으로 업데이트되지 않습니다.

편집기에서 열린 파일이 NvChad 외부에서 수정되었는지 확인하려면 `:checktime` 명령어를 사용할 수 있습니다. 이 명령어는 편집기에서 열린 파일이 NvChad 외부에서 수정되었는지 확인하고 버퍼를 업데이트해야 하는지 알려줍니다.

### 매핑

프로젝트를 빠르게 열기 위해 **/custom/mapping.lua**에 매핑을 생성할 수 있습니다. 다음은 예시입니다:

```lua
-- Projects
M.projects = {
  n = {
    ["<leader>fp"] = { "<cmd> ProjectMgr<CR>", "Open Projects"}
    },
}
```

편집기가 **NORMAL** 상태이면 <kbd>Space</kbd> + <kbd>f</kbd>와 <kbd>p</kbd> 조합을 사용하여 프로젝트 관리자를 열 수 있습니다.

## 결론 및 최종 생각

작업 중인 프로젝트 수가 증가함에 따라 필요한 모든 프로젝트에 접근할 수 있는 도구가 있으면 유용할 수 있습니다. 이 플러그인을 사용하면 필요한 파일에 액세스하는 데 걸리는 시간을 단축하여 작업을 가속화할 수 있습니다.

또한 `Telescope`와의 훌륭한 통합을 강조해야 합니다. 이를 통해 프로젝트 관리가 매우 실용적으로 이루어집니다.
