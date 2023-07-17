---
title: NvChad 설치
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
---

# Neovim을 고급 IDE로 전환

## 사전 요구 사항

NvChad 사이트에 명시된 대로 다음 요구 사항을 충족하는지 확인해야 합니다.

- [Neovim 0.8.3](https://github.com/neovim/neovim/releases/tag/v0.8.3).
- [Nerd Font](https://www.nerdfonts.com/) 터미널 에뮬레이터에서 설정하세요.
  - 설정한 nerd 글꼴이 **Mono**로 끝나지 않는지 확인하세요.
   - **예:** ~~Iosevka Nerd Font Mono~~가 아닌 Iosevka Nerd 글꼴
- [Ripgrep](https://github.com/BurntSushi/ripgrep)은 Telescope**(선택사항)**로 검색하는 grep에 필요합니다.
- GCC

이것은 실제로 실제 "설치"가 아니라 사용자를 위한 사용자 지정 Neovim 구성을 작성하는 것입니다.

!!! 경고 "새로운 설치(clean Installation) 실행"

    요구 사항에 지정된 대로 이전 구성 위에 이 새 구성을 설치하면 수정할 수 없는 문제가 발생할 수 있습니다. 새로운 설치(clean installation)를 권장합니다.

### 사전 작업:

이전에 Neovim 설치를 사용한 경우 파일을 작성할 세 개의 폴더가 생성됩니다.

```text
~/.config/nvim
~/.local/share/nvim
~/.cache/nvim
```

구성을 새로 설치하려면 먼저 이전 구성을 백업해야 합니다.

```bash
mkdir ~/backup_nvim
cp -r ~/.config/nvim ~/backup_nvim
cp -r ~/.local/share/nvim ~/backup_nvim
cp -r ~/.cache/nvim ~/backup_nvim
```

그런 다음 이전 구성과 파일을 모두 삭제합니다.

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
```

이제 정리를 마쳤으므로 NvChad 설치로 넘어갈 수 있습니다.

이렇게 하려면 _홈 디렉토리_ 내의 아무 위치에서나 다음 명령을 실행하기만 하면 됩니다.

```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

명령의 첫 번째 부분은 NvChad 리포지토리를 `~/.config/nvim` 폴더에 복제합니다. 이것은 사용자 구성을 검색하기 위한 Neovim의 기본 경로입니다. `--depth 1` 옵션은 _git_이 GitHub에서 "default"로 설정된 리포지토리만 복제하도록 지시합니다.

명령의 두 번째 부분에서 복제 프로세스가 완료되면 Neovim 실행 파일(_nvim_)이 호출되며, 구성 폴더를 찾으면 해당 파일의 `init.lua` 파일에서 발생한 구성을 미리 정의된 순서로 가져오기 시작합니다.

부트스트랩을 시작하기 전에 설치는 추가 사용자 정의를 위한 기본 구조(_template chadrc_) 설치를 제공합니다.

> Do you want to install chadrc template? (y/n) :

권장 구조를 설치하는 것이 필수는 아니지만, 이 편집기를 처음 사용하는 사용자에게 권장됩니다. 이미 `custom` 폴더가 있는 NvChad의 현재 사용자는 필요한 변경을 한 후 계속 사용할 수 있습니다.

템플릿으로 생성된 구조는 Markdown에서 문서를 작성하는 데 사용할 구성을 개발하기 위해 이 가이드에서도 사용됩니다.

설치를 시작하기 전에 이 주제에 대해 자세히 알고 싶은 사용자는 전용 페이지 [템플릿 Chadrc](template_chadrc.md)를 참조할 수 있습니다.

이 페이지에는 생성될 폴더의 구조, 관련 파일의 기능 및 NvChad 사용자 정의에 대한 기타 유용한 정보에 대한 정보가 포함되어 있습니다.

이 시점에서 기본 플러그인의 다운로드 및 구성과 템플릿 설치를 선택한 경우 구성된 언어 서버의 설치가 시작됩니다. 프로세스가 완료되면 편집기를 사용할 수 있습니다.

![설치](images/installed_first_time.png)

아래 스크린샷에서 알 수 있듯이 설정 변경으로 에디터가 Neovim 기본 버전과 완전히 달라졌다. 그러나 NvChad의 구성이 편집기를 완전히 변형하더라도 기본은 Neovim으로 남아 있다는 점을 기억해야 합니다.

![NvChad Rockydocs](images/nvchad_ui.png)

### 구성 구조

이제 구성이 생성한 구조를 분석해 보겠습니다. 구조는 다음과 같습니다.

```text
.config/nvim
├── init.lua
├── lazy-lock.json
├── LICENSE
└── lua
    ├── core
    │   ├── bootstrap.lua
    │   ├── default_config.lua
    │   ├── init.lua
    │   ├── mappings.lua
    │   └── utils.lua
    └── plugins
        ├── configs
        │   ├── cmp.lua
        │   ├── lazy_nvim.lua
        │   ├── lspconfig.lua
        │   ├── mason.lua
        │   ├── nvimtree.lua
        │   ├── others.lua
        │   ├── telescope.lua
        │   ├── treesitter.lua
        │   └── whichkey.lua
        └── init.lua
```

_template chadrc_도 설치하도록 선택한 경우 다음 구조의 `nvim/lua/custom` 폴더도 갖게 됩니다.

```text
.config/nvim/lua/custom/
├── chadrc.lua
├── configs
│   ├── lspconfig.lua
│   ├── null-ls.lua
│   └── overrides.lua
├── highlights.lua
├── init.lua
├── mappings.lua
└── plugins.lua
```


우리가 접하는 첫 번째 파일은 `lua/core`폴더와 `lua/core/utils.lua`(및 있는 경우 `lua/custom/init.lua`) 파일을 _nvim_트리에 삽입하여 구성을 초기화하는 `init.lua` 파일입니다. `lazy.nvim`(플러그인 관리자)의 부트스트랩을 실행하고 완료되면 `plugins` 폴더를 초기화합니다.

특히 `load_mappings()` 함수는 키보드 단축키를 로드하기 위해 호출됩니다. 또한 `gen_chadrc_template()` 함수는 `custom` 폴더를 생성하기 위한 서브루틴을 제공합니다.

```lua
require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

vim.opt.rtp:prepend(lazypath)
require "plugins"

dofile(vim.g.base46_cache .. "defaults")
```

`core` 폴더를 포함하면 일부 Neovim 인터페이스 구성을 재정의하고 버퍼 관리를 준비하는 `core/init.lua` 파일도 포함됩니다.

보시다시피 각각의 `init.lua` 파일은 정해진 순서대로 포함되어 있습니다. 이것은 기본 설정에서 다양한 옵션을 선택적으로 무시하는 데 사용됩니다. 대체로 `init.lua` 파일에는 전역 옵션, autocmds 또는 기타 항목을 로드하는 기능이 있다고 말할 수 있습니다.

다음은 기본 명령 매핑을 반환하는 호출입니다.

```lua
require("core.utils").load_mappings()
```

이렇게 하면 다른 키와 관련하여 명령을 실행할 수 있는 4개의 기본 키가 설정됩니다. 주요 키는 다음과 같습니다.

- C = <kbd>CTRL</kbd>
- leader = <kbd>SPACE</kbd>
- A = <kbd>ALT</kbd>
- S = <kbd>SHIFT</kbd>

!!! 참고 사항

    이 문서 전체에서 이러한 키 매핑을 여러 번 참조할 것입니다.

기본 매핑은 _core/mapping.lua_에 포함되어 있지만 고유한 _mappings.lua_를 사용하여 다른 사용자 지정 명령으로 확장할 수 있습니다.

표준 매핑의 몇 가지 예는 다음과 같습니다.

```text
<space>th to change the theme
<CTRL-n> to open nvimtree
<ALT-i> to open a terminal in a floating tab
```

사용자를 위해 미리 설정된 많은 조합이 있으며 NvChad의 모든 사용법을 다룹니다. NvChad로 구성된 Neovim 인스턴스를 사용하기 전에 키 매핑을 분석하기 위해 일시 중지할 가치가 있습니다.

구조 분석을 계속하면서 내장 플러그인 설정 및 구성이 포함된 _lua/plugins_ 폴더를 찾습니다. 구성의 주요 플러그인은 다음 섹션에서 설명합니다. 보시다시피 _core/plugins_폴더에는 플러그인 설치 및 후속 컴파일에 사용되는 `init.lua`파일도 포함되어 있습니다.

마지막으로 `lazy-lock.json` 파일을 찾습니다. 이 파일을 사용하면 여러 워크스테이션에서 NvChad 플러그인 구성을 동기화할 수 있으므로 사용되는 모든 워크스테이션에서 동일한 기능을 사용할 수 있습니다. 그 기능은 플러그인 관리자 전용 섹션에서 더 잘 설명될 것입니다.
