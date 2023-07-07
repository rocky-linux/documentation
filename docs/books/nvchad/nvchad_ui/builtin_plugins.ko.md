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

    이 장에서는 `user_github/plugin_name` 형식을 사용하여 플러그인을 식별합니다. 이것은 유사한 이름의 플러그인으로 발생할 수 있는 오류를 방지하고 NvChad 및 'custom' 구성 모두에서 플러그인 항목에 사용되는 형식을 도입하기 위한 것입니다.

버전 2.0은 수많은 새로운 기능을 제공합니다. 새 버전은 플러그인 관리자로 `packer.nvim` 대신 `lazy.nvim` 을 채택합니다. 여기에는 사용자 지정 구성(_custom_ 폴더)을 사용하여 이전 버전의 사용자를 위해 일부 변경 작업이 포함됩니다.

`lazy.nvim`은 통합 인터페이스를 통해 플러그인을 편리하게 관리할 수 있도록 하고 설치 간에 플러그인을 동기화하는 메커니즘을 통합합니다(_lazy-lock.json_).

NvChad는 _lua/plugins/init.lua_ 파일에 기본 플러그인 구성을 유지합니다. 그리고 다양한 플러그인의 추가 구성은 _/nvim/lua/plugins/configs_ 폴더에 포함되어 있습니다.

아래에서 _init.lua_ 파일의 발췌 부분을 볼 수 있습니다.

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

다음은 주요 플러그인에 대한 간략한 분석입니다.

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - 다른 플러그인에서 사용되는 일반적으로 사용되는 lua 기능 라이브러리를 제공합니다. 예를 들어 *telescope* 및 *gitsigns*.

- [NvChad/extensions](https://github.com/NvChad/extensions) - NvChad의 핵심 유틸리티입니다. 여기에서 찾을 수 있습니다: Telescope에서 직접 테마를 선택할 수 있는 *change_theme*, *reload_config*, *reload_theme*, *update_nvchad* 및 *telescope/extension* 폴더입니다.

- [NvChad/base46](https://github.com/NvChad/base46) - 인터페이스에 대한 테마를 제공합니다.

- [NvChad/ui](https://github.com/NvChad/ui) - 실제 인터페이스를 제공합니다. 이 플러그인 덕분에 편집 중에 정보를 제공하는 *statusline* 과 열린 버퍼를 관리할 수 있는 *tabufline*을 가질 수 있습니다.

- [NvChad/nvterm](https://github.com/NvChad/nvterm) - 명령을 실행할 수 있는 IDE에 터미널을 제공합니다. 터미널은 다양한 방법으로 버퍼 내에서 열 수 있습니다.

  - `<ALT-h>`는 버퍼를 수평으로 분할하여 터미널을 엽니다.
  - `<ALT-v>`는 버퍼를 수직으로 분할하여 터미널을 엽니다.
  - `<ALT-i>`는 플로팅 탭에서 터미널을 엽니다.

- [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) - NvChad 개발자가 작성한 또 다른 플러그인입니다. 특히 고성능 하이라이터입니다.

- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - IDE의 파일 유형 및 폴더에 아이콘(Nerd 글꼴 중 하나 필요)을 추가합니다. 이를 통해 파일 탐색기에서 파일 유형을 시각적으로 식별하여 작업 속도를 높일 수 있습니다.

- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - 문서 내 들여쓰기를 보다 잘 식별할 수 있도록 가이드를 제공하여 하위 루틴 및 중첩된 명령을 쉽게 인식할 수 있도록 합니다.

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Neovim에서 트리 시터 인터페이스를 사용하고 강조 표시와 같은 일부 기본 기능을 제공할 수 있습니다.

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - *statusline*에도 통합되는 추가, 제거 및 변경된 라인에 대한 보고서로 *git*에 대한 장식을 제공합니다.

## LSP 기능

이제 LSP(Language Server Protocols)를 프로젝트에 통합하는 기능을 제공하는 플러그인으로 이동하겠습니다. 이것은 확실히 NvChad가 제공하는 최고의 기능 중 하나입니다. LSP 덕분에 실시간으로 작성하는 내용을 제어할 수 있습니다.

- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - 편리한 그래픽 인터페이스를 통해 LSP(Language Server) 설치를 간편하게 관리할 수 있습니다. 제공되는 명령은 다음과 같습니다.

  - `:Mason`
  - `:MasonInstall`
  - `:MasonUninstall`
  - `:MasonUnistallAll`
  - `:MasonLog`

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - 사용 가능한 거의 모든 언어 서버에 적합한 구성을 제공합니다. 가장 관련성이 높은 설정이 이미 설정된 커뮤니티 모음입니다. 플러그인은 구성을 수신하여 편집기 환경에 배치합니다.

다음 명령을 제공합니다.

  - `:LspInfo`
  - `:LspStart`
  - `:LspStop`
  - `:Lsprestart`

## Lua 코드

LSP에 이어 snippets, lsp 명령, 버퍼 등과 같은 Lua 코드를 작성하고 실행하는 기능을 제공하는 모든 플러그인이 나옵니다. 이에 대해 자세히 설명하지는 않지만 GitHub의 해당 프로젝트에서 볼 수 있습니다.

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

- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - 이 플러그인 덕분에 괄호 및 기타 문자를 자동으로 닫는 기능이 있습니다. 예를 들어, 시작 괄호 `(`를 삽입하면 종료 괄호 `)`가 자동으로 삽입됩니다.

- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) - 코드 주석 처리를 위한 고급 기능을 제공합니다.

## 파일 관리

- [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) - 파일에 대한 가장 일반적인 작업(복사, 붙여넣기 등)을 허용하는 Neovim용 파일 탐색기는 Git과 통합되어 있으며 다른 아이콘 및 기타 기능으로 파일을 식별합니다. 가장 중요한 것은 자동으로 업데이트된다는 점입니다(Git 리포지토리로 작업할 때 매우 유용함).

  ![Nvim Tree](../images/nvim_tree.png)

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - 고급 파일 검색 기능을 제공하고 고도로 사용자 정의할 수 있으며 (예를 들어) NvChad 테마(명령 `:Telescope themes`)를 선택하는 데 사용할 수도 있습니다.

  ![Telescope find_files](../images/telescope_find_files.png)

- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - 입력한 부분 명령에 사용할 수 있는 모든 자동 완성을 표시합니다.

  ![Which Key](../images/which_key.png)

NvChad의 기본 구성을 구성하는 플러그인을 소개했으므로 이를 관리하는 방법을 살펴보겠습니다.
