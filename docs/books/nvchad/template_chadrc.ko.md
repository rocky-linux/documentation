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

NvChad의 2.0 버전에서 개발자들은 설치 단계에서 `사용자 정의` 폴더를 생성하는 기능을 도입했습니다. 이 기능을 통해 처음부터 IDE의 기본 기능을 갖춘 편집기를 사용할 수 있게 되었습니다.

_사용자 정의_ 폴더를 생성하는 가장 중요한 측면은 언어 서버, 린터 및 포매터와 같은 고급 기능을 설정하기 위한 구성을 포함하는 파일을 작성하는 것입니다. 이러한 파일들을 통해 필요한 기능을 몇 가지 변경으로 통합할 수 있습니다.

이 폴더에는 코드 강조 및 사용자 지정 명령 매핑에 대한 파일도 포함되어 있습니다.

이 폴더는 NvChad의 GitHub 리포지토리([example-config](https://github.com/NvChad/example_config))의 예제를 기반으로 생성됩니다. 설치 중에 이 폴더를 생성하려면 설치 시작 시 묻는 질문에 "y"로 대답하기만 하면 됩니다:

> Do you want to install chadrc template? (y/N) :

yes라고 답하면 GitHub의 _example-config_ 폴더의 내용을 **~/.config/nvim/lua/custom/**으로 클론하고 완료되면 **.git** 폴더를 제거하는 프로세스가 시작됩니다. 이는 구성을 자체 버전 관리로 관리할 수 있게 하기 위함입니다.

완료되면 다음과 같은 구조가 생성됩니다:

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

보시다시피, 이 폴더에는 NvChad의 기본 구조에서도 볼 수 있는 동일한 이름의 일부 파일이 포함되어 있습니다. 이 파일들은 구성을 통합하고 편집기의 기본 설정을 덮어쓸 수 있게 해줍니다.

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

이 함수는 _사용자 정의_ 폴더에서 파일을 NvChad 구성에 삽입하여 기본 파일과 함께 _Neovim_ 인스턴스를 시작할 때 사용됩니다. 파일은 `require` 함수를 통해 구성 트리에 삽입됩니다. 예를 들어:

```lua
require "custom.mappings"
```

이 파일은 **~/.config/nvim/lua/core/utils.lua** 파일에서 설정된 `load_config` 함수에 의해 Neovim 구성에 삽입됩니다. 이 함수는 기본 설정을 로드하고, 필요한 경우 _chadrc.lua_ 의 설정도 함께 로드하는 역할을 합니다:

요약하자면, 위에서 설명한 호출은 **custom/mappings.lua** 파일에 작성된 구성을 NvChad 매핑에 삽입하여 플러그인의 명령을 호출하는 단축키를 삽입합니다.

또한, `M.ui` 섹션을 통해 **~/.config/nvim/lua/core/default_config.lua**에 포함된 NvChad UI 구성 설정을 덮어쓰는 섹션이 있습니다. 이 섹션을 사용하여 밝거나 어두운 테마를 선택할 수 있습니다.

그리고 **custom/plugins.lua**에 정의된 플러그인들을 "custom.plugins" 문자열에 대응하여 포함합니다:

```lua
M.plugins = "custom.plugins"
```

이렇게 하면 우리의 플러그인들이 NvChad 구성을 구성하는 플러그인들과 함께 _lazy.nvim_ 에 전달되어 설치 및 관리됩니다. 이 경우에는 포함이 Neovim 트리가 아닌 _lazy.nvim_ 의 구성에 있으며, _lazy.nvim_ 은 `vim.go.loadplugins = false` 호출로 편집기의 관련 기능을 완전히 비활성화합니다.

#### init.lua

이 파일은 **~/.config/nvim/lua/core/init.lua**에서 정의된 설정(들여쓰기 또는 디스크로의 스왑 쓰기 간격 등)을 덮어씁니다. 또한 파일에 주석 처리된 줄에 설명된대로 auto-commands를 생성하는 데 사용됩니다. 예를 들면 다음과 같이 마크다운 문서 작성을 위한 일부 설정이 포함될 수 있습니다:

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

이렇게 함으로써 우리의 설정은 기본 설정을 대체하게 됩니다.

#### plugins.lua

이 파일은 이름에서 알 수 있듯이, 기본 NvChad 구성에 플러그인을 추가하는 데 사용됩니다. 플러그인 삽입에 대한 자세한 내용은 [플러그인 관리자](nvchad_ui/plugins_manager.md) 페이지에서 자세히 설명되어 있습니다.

_템플릿 chadrc_ 에 의해 생성된 _plugins.lua_ 파일은 첫 번째 부분에서 플러그인 정의 옵션과 기본 플러그인 구성을 덮어씁니다. 이 파일의 이 부분은 개발자들이 이 목적을 위해 준비한 특수한 파일들이 _config_ 폴더에 존재하기 때문에 수정할 필요가 없습니다.

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

이 플러그인 다음과 마지막 괄호 사이에 우리의 모든 플러그인을 추가할 수 있습니다. 모든 목적에 적합한 플러그인 생태계가 있습니다. 초기 개요를 위해 [Neovimcraft](https://neovimcraft.com/)를 방문할 수 있습니다.

#### mappings.lua

이 파일은 우리가 추가할 플러그인의 명령을 호출하기 위해 필요한 매핑(단축키)을 구성 트리에 삽입합니다.

또한 형식을 공부하기 위해 예제 설정이 여기에 제시되었습니다:

```lua
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}
```

이 매핑은 NORMAL 상태 `n =` 문자 <kbd>;</kbd> 를 누를 때 문자 <kbd>:</kbd>를 실행합니다. 이 문자는 COMMAND 모드로 들어가기 위해 사용되는 문자입니다. 또한 옵션 `nowait = true`가 지정되어 즉시 그 모드로 진입합니다. 이렇게 함으로써 US QWERTY 레이아웃의 키보드에서는 COMMAND 모드로 진입하기 위해 <kbd>SHIFT</kbd>를 사용할 필요가 없게 됩니다.

!!! tip "팁"

    유럽 키보드(예: 이탈리아어) 사용자의 경우 문자 <kbd>;</kbd>를 <kbd>,</kbd>로 대체하는 것이 좋습니다.

#### highlights.lua

이 파일은 편집기의 스타일을 사용자 정의하는 데 사용됩니다. 여기에 작성된 설정은 글꼴 스타일(**굵게**,_기울임꼴_), 요소의 배경색, 전경색 등과 같은 측면을 변경하는 데 사용됩니다.

### Configs 폴더

이 폴더의 파일들은 **custom/plugins.lua** 파일에서 사용되어 언어 서버(_lspconfig_), 린터/포매터(_null-ls_) 및  **treesitter**, **mason**, **nvim-tree**(_override_)의 기본 설정을 덮어쓰는 데 사용되는 모든 구성 파일입니다.

```text
configs/
├── lspconfig.lua
├── null-ls.lua
└── overrides.lua
```

#### lspconfig.lua

_lspconfig.lua_ 파일은 편집기에서 사용할 수 있는 로컬 언어 서버를 설정합니다. 이를 통해 자동 완성이나 스니펫과 같은 고급 기능을 지원하는 파일에 대해 사용할 수 있습니다. 설정에 우리의 _lsp_를 추가하려면 NvChad 개발자들이 특별히 준비한 테이블(_lua_ 에서 중괄호로 표현되는 것은 테이블입니다)에 간단히 입력하면 됩니다:

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

기본적으로 일부 서버가 이미 설정되어 있는 것을 볼 수 있습니다. 새로운 서버를 추가하려면 테이블 끝에 해당 서버를 입력하면 됩니다. 사용 가능한 서버는 [mason 패키지](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md)에서 찾을 수 있으며, 구성에 대한 정보는 [lsp 서버 구성](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)을 참조할 수 있습니다.

예를 들어 `yaml` 언어에 대한 지원도 추가하려면 다음 예제와 같이 입력할 수 있습니다:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

그러나 파일을 변경하는 것은 관련 언어 서버를 설치하는 것을 의미하지는 않습니다. 이제 Rocky Linux 문서 페이지의 헤더 (_frontmatter_)에 작성된 코드를 제어할 수 있게 될 것입니다. 이는 별도로  _Mason_ 을 사용하여 설치해야 합니다. _yaml_ 을 지원하는 언어 서버인 [yaml-language-server](https://github.com/redhat-developer/yaml-language-server)를 명령어 `:MasonInstall yaml-language-server` 로 설치해야 합니다.

#### null-ls.lua

이 파일은 작성한 코드의 제어 및 포매팅과 관련된 일부 기능을 구성합니다. 이 파일은 이전 파일보다 구성에 대한 조사가 조금 더 필요합니다. 사용 가능한 구성 요소에 대한 개요는 [이 페이지](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md)에서 확인할 수 있습니다.

다시 한번 테이블이 설정되었습니다. `로컬 소스` 테이블에 우리의 사용자 정의를 입력할 수 있습니다. 아래 예시를 확인해보세요:

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

위의 초기 구성에서는 포매터만 포함되어 있지만, 예를 들어 Markdown 언어에 대한 진단이 필요한 경우 다음과 같이 [Markdownlint](https://github.com/DavidAnson/markdownlint)를 추가할 수 있습니다:

```lua
  -- diagnostic markdown
  b.diagnostics.markdownlint,
```

또한, 해당 패키지의 설치가 필요합니다. 이를 위해 _Mason_ 을 사용하여 설치해야 합니다:

```text
:MasonInstall markdownlint
```

!!! 참고 사항

    이 진단 도구의 구성은 홈 폴더에 구성 파일을 생성해야 하는데, 이 문서에서 다루지 않습니다.

#### overrides.lua

overrides.lua 파일에는 기본 플러그인 설정을 변경해야 하는 내용이 포함되어 있습니다. 변경 사항이 적용되어야 할 플러그인은 custom/plugins.lua 파일의 -- override plugin configs 섹션에서 opts 옵션을 사용하여 지정됩니다 (예: opts = overrides.mason).

초기 구성에서는  _treesitter_, _mason_ 및 _nvim-tree_ 와 같이 변경이 필요한 세 개의 플러그인이 지정되어 있습니다. 일단 _nvim-tree_ 를 제외하고 첫 번째 두 개에 초점을 맞추어 우리의 편집 경험을 크게 변경할 수 있습니다.

_treesitter_ 는 상호 작용적으로 코드를 서식 지정하는 코드 파서입니다. _treesitter_ 가 인식하는 파일을 저장할 때마다 해당 파일이 파서로 전달되며 최적으로 들여쓰고 강조 표시된 코드 트리를 반환하여 코드를 더 쉽게 읽고 해석하며 편집할 수 있게 해줍니다.

이를 다루는 코드 부분은 다음과 같습니다:

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

이전에 제시한 예시를 따라 우리가 Rocky Linux의 문서 페이지에서 _frontmatter_ 가 올바르게 강조 표시되길 원한다면, `ensure_installed` 테이블에서 마지막 파서 뒤에 _yaml_ 지원을 추가할 수 있습니다:

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

이제 NvChad를 다음에 열 때 추가한 파서가 자동으로 설치될 것입니다.

실행 중인 NvChad에서 파서를 직접 사용할 수 있도록 하려면 파일을 수정하지 않고도 다음 명령을 사용하여 항상 설치할 수 있습니다:

```text
:TSInstall yaml
```

파일에서 다음은 _Mason_에 의한 서버 설치에 관한 부분입니다. 이 테이블에 설정된 모든 서버는 `:MasonInstallAll` 명령을 사용하여 한 번에 설치됩니다 (이 명령은 _custom_ 폴더 생성 중에도 호출됩니다). 이 부분은 다음과 같습니다:

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

이전에 _yaml_ 지원을 활성화하기 위해 수동으로 서버를 설치한 예제를 따라서 해당 서버를 항상 설치되도록 하려면 테이블에 추가할 수 있습니다:

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

예를 들어, 필요한 모든 기능을 갖춘 `사용자 정의 폴더`를 구성하고 이를 다른 NvChad 설치로 전송하려고 한다고 가정해 봅시다. 이 파일을 구성했다면 `사용자 정의 폴더`를 복사하거나 복제한 후 `:MasonInstallAll` 명령을 사용하면 다른 설치에서도 사용할 준비가 된 모든 서버를 갖게 됩니다.

구성의 마지막 부분인 `M.nvimtree` 섹션은 _nvim-tree_ 를 구성하는 데 사용되며, 파일 트리에서 git 리포지토리와 관련하여 상태를 표시하는 기능을 활성화합니다:

```lua
  git = {
    enable = true,
  },
```

해당 부분과 해당 아이콘을 강조 표시합니다:

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

NvChad 2.0에서 첫 번째 설치 중에 `사용자 정의` 폴더를 생성할 수 있는 기능을 도입함으로써, 이 편집기에 처음 접하는 모든 사용자에게 큰 도움이 됩니다. NvChad를 이미 사용해본 사용자에게는 상당한 시간 절약을 제공합니다.

이 기능을 통해 _Mason_ 의 사용과 함께 자신의 기능을 매우 쉽고 빠르게 통합할 수 있습니다. 몇 가지 변경만 필요하며, IDE를 사용하여 코드를 작성할 준비가 즉시 완료됩니다.
