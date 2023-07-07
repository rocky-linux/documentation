---
title: Chadrc 템플릿
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Chadrc 템플릿

NvChad 버전 2.0에서 개발자는 설치 단계 중에 자신만의 사용자 정의를 만들 수 있는 `custom` 폴더를 생성하는 기능을 도입했습니다. 이 기능을 도입하면 처음부터 IDE의 기본 기능을 갖춘 편집기를 사용할 수 있습니다.

_custom_ 폴더 생성의 가장 중요한 측면은 언어 서버, 린터 및 포맷터와 같은 일부 고급 기능을 설정하기 위한 구성이 포함된 파일을 작성하는 것입니다. 이러한 파일을 사용하면 몇 가지 변경만으로 필요한 기능을 통합할 수 있습니다.

이 폴더에는 코드 강조 표시 및 사용자 지정 명령 매핑을 위한 파일도 포함되어 있습니다.

이 폴더는 NvChad의 GitHub 리포지토리([example-config](https://github.com/NvChad/example_config))에 있는 예제 1에서 생성됩니다. 설치 중에 생성하려면 설치 시작 시 묻는 질문에 "y"라고 대답하면 됩니다.

> Do you want to install chadrc template? (y/N) :

yes라고 답하면 _example-config_ 폴더의 내용을 GitHub에서 **~/.config/nvim/lua/custom/**로 복제하고 완료되면 **.git**폴더를 제거하는 프로세스를 시작할 것입니다. 이것은 우리가 우리 자신의 버전 제어 하에 구성을 넣을 수 있도록 하기 위한 것입니다.

완료되면 다음과 같은 구조를 갖게 됩니다.

```text
custom/
├── chadrc.lua
├── init.lua
├── plugins.lua
├── mappings.lua
├── highlights.lua
├── configs
│   ├── lspconfig.lua
│   ├── null-ls.lua
│   └── overrides.lua
└── README.md
```

보시다시피 폴더에는 NvChad의 기본 구조에서도 발견되는 동일한 이름의 일부 파일이 포함되어 있습니다. 이러한 파일을 사용하면 구성을 통합하고 편집기의 기본 설정을 재정의할 수 있습니다.

## 구조 분석

이제 내용을 살펴보겠습니다.

### 메인 파일

#### chadrc.lua

```lua
---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
```

이 파일은 파일 **~/.config/nvim/lua/core/utils.lua**에 설정된 `load_config` 기능에 의해 Neovim 구성에 삽입됩니다. 이 기능은 기본 설정 및 _chadrc.lua_의 설정(있는 경우)을 로드하는 기능입니다.

```lua
M.load_config = function()
  local config = require "core.default_config"
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]
...
```

이 기능은 우리의 _custom_폴더의 파일을 NvChad 구성에 삽입하여 _Neovim_인스턴스를 시작하는 기본 파일과 함께 사용하는 것입니다. 파일은 다음과 같은 `require` 기능을 통해 구성 트리에 삽입됩니다.

```lua
require "custom.mappings"
```

문자열 **custom.mappings**는 기본 경로(이 경우 **~/.config/nvim/lua/**)와 달리 확장자가 없는 파일에 대한 상대 경로를 나타냅니다. 점은 슬래시를 대체하는데 이는 Lua로 작성된 코드의 규칙이기 때문입니다.(_lua 언어_에는 _directory_라는 개념이 없습니다).

요약하면 위에서 설명한 호출은 **custom/mappings.lua**파일에 작성된 구성을 NvChad 매핑에 삽입하여 플러그인 명령을 호출하는 바로 가기를 삽입한다고 말할 수 있습니다.

그런 다음 **~/.config/nvim/lua/core/default_config.lua**에 포함된 일부 NvChad UI 구성 설정을 재정의하는 섹션, 특히 예를 들어 밝거나 어두운 테마를 선택할 수 있는 `M.ui`섹션이 있습니다.

또한 다음 문자열에 해당하는 **custom/plugins.lua**에 정의된 플러그인이 포함되어 있습니다.

```lua
M.plugins = "custom.plugins"
```

이러한 방식으로 플러그인은 설치 및 관리를 위해 NvChad 구성을 구성하는 플러그인과 함께 _lazy.nvim_으로 전달됩니다. 이 경우 포함은 Neovim 트리가 아니라 _lazy.nvim_ 구성에 있습니다. 왜냐하면 이 플러그인은 `vim.go.loadplugins = false` 호출로 편집기의 관련 기능을 완전히 비활성화하기 때문입니다.

#### init.lua

이 파일은 **~/.config/nvim/lua/core/init.lua**에 정의된 들여쓰기 또는 스왑 쓰기 간격과 같은 설정을 디스크에 덮어쓰는 데 사용됩니다. 파일의 주석 처리된 줄에 설명된 대로 자동 명령 생성에도 사용됩니다. Markdown에서 문서를 작성하기 위한 일부 설정이 포함된 예는 다음과 같습니다.

```lua
--local autocmd = vim.api.nvim_create_autocmd

-- settings for Markdown
local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Auto resize panes when resizing nvim window
--autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
```

이러한 방식으로 설정이 기본 설정을 대체합니다.

#### plugins.lua

이름에서 짐작할 수 있듯이 이 파일은 기본 NvChad 구성에 플러그인을 추가하는 데 사용됩니다. 플러그인 삽입은 [플러그인 관리자](nvchad_ui/plugins_manager.md) 전용 페이지에 자세히 설명되어 있습니다.

_템플릿 chadrc_에 의해 생성된 _plugins.lua_ 파일에는 첫 번째 부분에 플러그인 정의 옵션 및 기본 플러그인 구성을 재정의하는 여러 사용자 정의가 있습니다. 파일의 이 부분은 개발자가 _config_ 폴더에 있는 특수 파일을 준비했기 때문에 수정할 필요가 없습니다.

그런 다음 플러그인 설치를 따릅니다. 이는 버전 1.0에서 사용되는 핸들러인 _packer.nvim_에서 사용하는 형식과 약간 다른 _lazy.nvim_에서 사용하는 형식에 익숙해질 수 있도록 예제로 설정되었습니다.

```lua
  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
```

이 플러그인 다음과 마지막 대괄호 앞에 모든 플러그인을 삽입할 수 있습니다. 모든 목적에 맞는 전체 플러그인 환경이 있습니다. 초기 개요를 보려면 [Neovimcraft](https://neovimcraft.com/)를 방문하세요.

#### mappings.lua

이 파일은 추가하려는 플러그인의 명령을 호출하는 데 필요한 매핑(키보드 단축키)을 구성 트리에 삽입합니다.

형식을 연구할 수 있도록 예제 설정도 여기에 제시되어 있습니다.

```lua
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}
```

이 매핑은 문자 <kbd>;</kbd>가 키보드를 누르면 문자 <kbd>:</kbd>가 재생되는 NORMAL상태 `n =`에 대해 입력됩니다. 이 문자는 COMMAND 모드로 들어가는 데 사용되는 문자입니다. `nowait = true` 옵션도 해당 모드로 즉시 들어가도록 설정됩니다. 이러한 방식으로 US QWERTY 레이아웃의 키보드에서 COMMAND 모드로 들어가기 위해 <kbd>SHIFT</kbd>를 사용할 필요가 없습니다.

!!! !!!

    유럽 키보드(예: 이탈리아어) 사용자의 경우 문자 <kbd>;</kbd>를 <kbd>,</kbd>로 대체하는 것이 좋습니다.

#### highlights.lua

이 파일은 편집기의 스타일을 사용자 지정하는 데 사용됩니다. 여기에 쓰여진 설정은 글꼴 스타일(**굵게**,_기울임꼴_), 요소의 배경색, 전경색 등과 같은 측면을 변경하는 데 사용됩니다.

### Configs 폴더

이 폴더의 파일은 **custom/plugins.lua**파일에서 언어 서버(_lspconfig_), linter/formatters(_null-ls_)을 처리하는 플러그인의 기본 설정을 변경하고 **treesitter**, **mason**, 및 **nvim-tree**(_override_)의 기본 설정을 재정의하는데 사용되는 모든 구성 파일입니다.

```text
configs/
├── lspconfig.lua
├── null-ls.lua
└── overrides.lua
```

#### lspconfig.lua

_lspconfig.lua_ 파일은 편집기가 사용할 수 있는 로컬 언어 서버를 설정합니다. 이렇게 하면 자동 완성 또는 스니펫과 같은 지원되는 파일에 대한 고급 기능을 사용하여 코드 조각을 빠르게 생성할 수 있습니다. 구성에 _lsp_를 추가하려면 NvChad 개발자가 특별히 준비한 테이블(_lua_ 서는 아래 중괄호로 표시된 것이 테이블임) 을 편집하기만 하면 됩니다.

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

보시다시피 일부 서버는 기본적으로 이미 설정되어 있습니다. 새 항목을 추가하려면 표 끝에 입력하면 됩니다. 사용 가능한 서버는 [mason 패키지](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md)에서 찾을 수 있으며 해당 구성은 [lsp 서버 구성](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)를 참조할 수 있습니다.

예를 들어 `yaml` 언어도 지원하려면 다음 예와 같이 추가할 수 있습니다.

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

그러나 파일을 변경하는 것은 관련 언어 서버를 설치하는 것과 관련이 없습니다. _Mason_과 별도로 설치해야 합니다. _yaml_ 지원을 제공하는 언어 서버는 `:MasonInstall yaml-language-server` 명령으로 설치해야 하는 [yaml-language-server](https://github.com/redhat-developer/yaml-language-server) 입니다. 이 시점에서 예를 들어 Rocky Linux 설명서 페이지의 헤더(_frontmatter_) 에 작성된 코드를 제어할 수 있습니다.

#### null-ls.lua

이 파일은 작성된 코드의 제어 및 서식 지정을 위한 일부 기능 구성을 처리합니다. 이 파일을 편집하려면 이전 파일보다 구성에 대해 조금 더 조사해야 합니다. 사용 가능한 구성 요소에 대한 개요는 [이 페이지](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md)에서 찾을 수 있습니다.

다시 한 번 `로컬 소스` 테이블이 설정되어 아래에서 볼 수 있는 사용자 정의를 입력할 수 있습니다.

```lua
local sources = {

  -- webdev stuff
  b.formatting.deno_fmt,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } },
  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,
}
```

보시다시피 초기 구성에는 포맷터만 포함되었지만 예를 들어 Markdown 언어에 대한 진단이 필요할 수 있으며, 이 경우 다음과 같이 [Markdownlint](https://github.com/DavidAnson/markdownlint)를 추가할 수 있습니다.

```lua
  -- diagnostic markdown
  b.diagnostics.markdownlint,
```

다시 말하지만 구성에는 항상 _Mason_과 함께 설치할 관련 패키지의 설치가 필요합니다.

```text
:MasonInstall markdownlint
```

!!! 참고 사항

    이 진단 도구를 구성하려면 홈 폴더에 구성 파일을 만들어야 하며 이 문서에서는 다루지 않습니다.

#### overrides.lua

_overrides.lua_ 파일에는 기본 플러그인 설정에 대한 변경 사항이 포함되어 있습니다. 변경 사항이 적용될 플러그인은 `opts`옵션을 사용하여 **custom/plugins.lua**파일의 `-- override plugin configs`섹션에 지정됩니다(예: `opts = overrides.mason`).

초기 구성에는 재정의가 필요한 것으로 표시된 세 개의 플러그인이 있으며 이들은 _treesitter_, _mason_ 및 _nvim-tree_입니다. _nvim-tree_는 잠시 제외하고, 편집 경험을 크게 바꿀 수 있는 첫 번째 두 가지에 초점을 맞출 것입니다.

_treesitter_는 대화형 방식으로 서식을 처리하는 코드 파서입니다. _treesitter_에서 인식한 파일을 저장할 때마다 최적으로 들여쓰기되고 강조 표시된 코드 트리를 반환하는 파서로 전달되므로, 편집기에서 코드를 더 쉽게 읽고 해석하고 편집할 수 있습니다.

이 문제를 다루는 코드 부분은 다음과 같습니다:

```lua
M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}
```

이제 이전에 제공된 예에 따라 Rocky Linux에 대한 문서 페이지의 _frontmatter_가 올바르게 강조 표시되도록 하려면 마지막 파서 세트 다음에 `ensure_installed` 테이블에서 _yaml_에 대한 지원을 추가할 수 있습니다.

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

이제 다음에 NvChad를 열면 방금 추가한 파서도 자동으로 설치됩니다.

실행 중인 NvChad 인스턴스에서 파서를 직접 사용할 수 있도록 하려면 다음 명령을 사용하여 파일을 편집하지 않고도 항상 설치할 수 있습니다.

```text
:TSInstall yaml
```

파일에서 다음은 _Mason_에 의한 서버 설치에 관한 부분입니다. 이 테이블에 설정된 모든 서버는 `:MasonInstallAll` 명령을 사용하여 한 번의 작업으로 설치됩니다(이 명령은 _custom_ 폴더 생성 중에도 호출됩니다). 해당 부분은 다음과 같습니다.

```lua
M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier"
  },
}
```

다시, 서버를 수동으로 설치하여 _yaml_에 대한 지원을 활성화한 초기 예제에 따라 서버를 테이블에 추가하여 항상 설치되도록 할 수 있습니다.

```text
    ...
    "typescript-language-server",
    "deno",
    "prettier",

    -- yaml-language-server
    "yaml-language-server",
    ...
```

NvChad가 실행 중인 인스턴스에서 이 측면은 한계일 수 있지만 누락된 서버를 항상 수동으로 설치할 수 있으므로 한 컴퓨터에서 다른 컴퓨터로 구성을 전송할 때 매우 도움이 될 수 있습니다.

예를 들어, 필요한 모든 기능으로 `custom` 폴더를 구성했는데 NvChad의 다른 설치로 전송하려고 합니다. 이 파일을 구성한 경우 `custom` 폴더를 복사하거나 복제한 후 `:MasonInstallAll`만 있으면 다른 설치에서도 모든 서버를 사용할 수 있습니다.

구성의 마지막 부분인 `M.nvimtree` 섹션은 git 저장소와 관련하여 파일 트리에 상태를 표시하는 기능을 활성화하여 _nvim-tree_ 구성을 처리합니다.

```lua
  git = {
    enable = true,
  },
```

강조 표시 및 해당 아이콘:

```lua
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
```

## 결론

처음 설치하는 동안 `custom` 폴더를 생성할 수 있는 NvChad 2.0의 도입은 확실히 이 편집기를 처음 접하는 모든 사용자에게 큰 도움이 됩니다. 또한 이미 NvChad를 다루어본 사람들에게는 상당한 시간을 절약해 줍니다.

도입 덕분에 _Mason_의 사용과 함께 자신의 기능을 매우 쉽고 빠르게 통합할 수 있습니다. 몇 가지만 변경하면 즉시 IDE를 사용하여 코드를 작성할 수 있습니다.
