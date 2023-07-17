---
title: 기본 제공 플러그인
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - plugins
---

# 기본 구성 플러그인

!!! 참고 "플러그인 명명 규칙"

    이 장에서는 플러그인을 식별하기 위해 `user_github/plugin_name` 형식을 사용합니다. 이는 비슷한 이름의 플러그인으로 인한 오류를 피하기 위한 것이며, `NvChad`와 사용자 정의 구성 모두에서 플러그인 엔트리로 사용되는 형식을 소개하기 위한 것입니다.

버전 2.0은 많은 새로운 기능을 제공합니다. 새 버전에서는 `packer.nvim`` 대신`lazy.nvim`을 플러그인 관리자로 사용하고 있습니다. 이로 인해 이전 버전의 사용자들은 사용자 정의 구성 (custom 폴더)을 위해 일부 변경을 해야 합니다.

`lazy.nvim`을 사용하면 통합 인터페이스를 통해 플러그인을 편리하게 관리할 수 있으며, 설치 간 플러그인 동기화 메커니즘(_lazy-lock.json_)을 통합합니다.

NvChad는 _lua/plugins/init.lua_ 파일에 기본 플러그인 구성을 유지합니다. 그리고 다양한 플러그인의 추가 구성은 _/nvim/lua/plugins/configs_ 폴더에 포함되어 있습니다.

아래는 _init.lua_ 파일의 일부입니다:

```lua
local default_plugins = {

  "nvim-lua/plenary.nvim",

  -- nvchad plugins
  { "NvChad/extensions", branch = "v2.0" },

  {
    "NvChad/base46",
    branch = "v2.0",
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false,
    config = function()
      require "nvchad_ui"
    end,
  },
...
...
-- lazy_nvim startup opts
local lazy_config = vim.tbl_deep_extend("force", require "plugins.configs.lazy_nvim", config.lazy_nvim)

require("lazy").setup(default_plugins, lazy_config)
```

NvChad 개발자들이 인정해야 할 엄청난 양의 작업이 있습니다. 이들은 사용자 인터페이스를 깨끗하고 전문적으로 만드는 모든 플러그인 간의 통합 환경을 만들었습니다. 또한 *내부적으로* 작동하는 플러그인을 통해 향상된 편집 및 기타 기능을 사용할 수 있습니다.

이 모든 것은 일반 사용자가 즉시 작업을 시작할 수 있는 기본 IDE와 필요에 따라 조정할 수 있는 확장 가능한 구성을 가질 수 있음을 의미합니다.

## 메인 플러그인

주요 구성 플러그인들에 대한 간단한 분석을 제시합니다:

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - 다른 플러그인에서 사용되는 일반적으로 사용되는 lua 함수들의 라이브러리를 제공합니다. 예를 들어 *telescope* 또는 *gitsigns*에서 사용됩니다.

- [NvChad/extensions](https://github.com/NvChad/extensions) - NvChad의 핵심 유틸리티입니다. 여기에서 찾을 수 있습니다: Telescope에서 직접 테마를 선택할 수 있는 *change_theme*, *reload_config*, *reload_theme*, *update_nvchad* 및 *telescope/extension* 폴더입니다.

- [NvChad/base46](https://github.com/NvChad/base46) - 인터페이스에 대한 테마를 제공합니다.

- [NvChad/ui](https://github.com/NvChad/ui) - 실제 인터페이스를 제공합니다. 이 플러그인을 통해 편집 중에 정보를 제공하는 *statusline* 과 열린 버퍼를 관리할 수 있는 *tabufline*을 가질 수 있습니다.

- [NvChad/nvterm](https://github.com/NvChad/nvterm) - 명령을 실행할 수 있는 IDE에 터미널을 제공합니다. 터미널은 다양한 방법으로 버퍼 내에서 열 수 있습니다.

  - `<ALT-h>`는 버퍼를 가로로 분할하여 터미널을 엽니다.
  - `<ALT-v>`는 버퍼를 세로로 분할하여 터미널을 엽니다.
  - `<ALT-i>`는 플로팅 탭에서 터미널을 엽니다.

- [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) - NvChad 개발자들에 의해 작성된 또 다른 플러그인입니다. 고성능 하이라이터입니다.

- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - IDE에서 파일 유형과 폴더에 아이콘을 추가합니다. 이를 통해 파일 탐색기에서 파일 유형을 시각적으로 식별하고 작업을 더 빠르게 수행할 수 있습니다.

- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - 문서에서 들여쓰기를 더 잘 식별할 수 있는 가이드를 제공합니다. 이를 통해 서브루틴과 중첩된 명령을 쉽게 인식할 수 있습니다.

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Neovim에서 tree-sitter 인터페이스를 사용할 수 있게 해주며, 강조 표시와 같은 기본 기능을 제공합니다.

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - *statusline*에도 통합되는 추가, 제거 및 변경된 라인에 대한 보고서로 *git*에 대한 장식을 제공합니다.

## LSP 기능

다음으로, LSP (Language Server Protocol)를 프로젝트에 통합하는 기능을 제공하는 플러그인으로 넘어갑시다. 이는 확실히 NvChad에서 제공하는 가장 좋은 기능 중 하나입니다. LSP를 통해 실시간으로 작성하는 내용을 제어할 수 있습니다.

- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - 편리한 그래픽 인터페이스를 통해 LSP (Language Server) 설치를 단순화합니다. 제공되는 명령어는 다음과 같습니다:

  - `:Mason`
  - `:MasonInstall`
  - `:MasonUninstall`
  - `:MasonUnistallAll`
  - `:MasonLog`

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - 거의 모든 언어 서버에 대한 적절한 구성을 제공합니다. 이 플러그인은 커뮤니티 컬렉션으로, 가장 관련 있는 설정을 이미 설정해 두었습니다. 플러그인은 우리의 구성을 수신하고 편집기 환경에 적용하는 역할을 담당합니다.

또한 다음과 같은 명령어를 제공합니다:

  - `:LspInfo`
  - `:LspStart`
  - `:LspStop`
  - `:Lsprestart`

## Lua 코드

LSP 이후에는 코드 작성 및 실행에 기능을 제공하는 모든 플러그인이 있습니다. 이러한 플러그인들에 대해서는 자세히 설명하지는 않겠지만, 각각의 프로젝트에서 GitHub에서 확인할 수 있습니다.

플러그인은 다음과 같습니다.

- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-Pfad](https://github.com/hrsh7th/cmp-path)

## 혼합 플러그인

- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - 이 플러그인을 통해 자동으로 괄호 및 기타 문자를 닫을 수 있습니다. 예를 들어, 여는 괄호를 삽입하면 `(` 완성을 자동으로 닫히는 `)` 괄호가 삽입되고 커서가 중간에 위치합니다.

- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) - 코드 주석에 대한 고급 기능을 제공합니다.

## 파일 관리

- [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) - Neovim용 파일 탐색기로 파일에 대한 가장 일반적인 작업 (복사, 붙여넣기 등)을 수행할 수 있으며, Git과 통합되어 다른 아이콘으로 파일을 식별하고 기타 기능을 제공합니다. 가장 중요한 것은 자동으로 업데이트된다는 점입니다 (Git 저장소와 작업할 때 매우 유용합니다).

  ![Nvim Tree](../images/nvim_tree.png)

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - 고급 파일 검색 기능을 제공하며, 매우 맞춤 설정이 가능하며, 예를 들어 NvChad 테마 선택에도 사용할 수 있습니다 (명령어 `:Telescope themes`).

  ![Telescope find_files](../images/telescope_find_files.png)

- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - 입력한 부분 명령에 대해 가능한 모든 자동 완성을 표시합니다.

  ![Which Key](../images/which_key.png)

NvChad의 기본 구성을 구성하는 플러그인을 소개한 후, 이를 관리하는 방법을 알아보도록 하겠습니다.
