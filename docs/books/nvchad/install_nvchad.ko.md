---
title: NvChad 설치
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
---

# Neovim을 고급 IDE로 변환하기

## 사전 요구 사항

NvChad 사이트에서 명시된대로 시스템이 다음 요구 사항을 충족하는지 확인해야 합니다.

- [Neovim 0.8.3](https://github.com/neovim/neovim/releases/tag/v0.8.3).
- [Nerd Font](https://www.nerdfonts.com/) 터미널 에뮬레이터에서 설정하세요.
  - 설정한 nerd 글꼴이 **Mono**로 끝나지 않는지 확인하세요.
   - **예시:** ~~Iosevka Nerd Font Mono~~가 아닌 Iosevka Nerd 글꼴
- [Ripgrep](https://github.com/BurntSushi/ripgrep)은 Telescope **(선택사항)**로 검색하는 grep에 필요합니다.
- GCC

이것은 실제로 실제 "설치"가 아니라 사용자를 위한 사용자 지정 Neovim 구성을 직접 작성하는 것입니다.

!!! 경고 "깨끗한 설치(clean Installation) 실행"

    요구 사항에 명시된대로 이전 구성 위에 새로운 구성을 설치하는 것은 수정할 수 없는 문제를 만들 수 있으므로 깨끗한 설치를 권장합니다. 새로운 설치(clean installation)를 권장합니다.

### 사전 작업:

Neovim 설치를 이전에 사용한 경우, 파일을 작성하기 위해 세 개의 폴더가 생성되었을 것입니다.

```text
~/.config/nvim
~/.local/share/nvim
~/.cache/nvim
```

구성의 깨끗한 설치를 수행하려면 먼저 이전 구성을 백업해야 합니다.

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

이제 청소 작업을 완료했으므로 NvChad를 설치할 수 있습니다.

이렇게 하려면 _홈 디렉토리_ 내의 아무 위치에서 다음 명령을 실행하면 됩니다.

```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

명령어의 첫 번째 부분은 NvChad 리포지토리를 `~/.config/nvim` 폴더에 클론합니다. 이는 Neovim의 기본 경로로, 사용자 구성을 찾기 위한 경로입니다. `--depth 1` 옵션은 _git_에게 GitHub에서 "default"으로 설정된 리포지토리만 클론하도록 지시합니다.

클론 작업이 완료되면 두 번째 부분의 명령으로 Neovim 실행 파일(_nvim_)이 호출됩니다. 이 명령은 구성 폴더를 찾았을 때 구성에서 발견한 `init.lua` 파일을 미리 정의된 순서로 가져오기 시작합니다.

부트스트랩을 시작하기 전에 설치 프로세스에서는 추가적인 사용자 정의 작업을 위한 기본 구조(_template chadrc_)를 설치할 것인지 여부를 물어봅니다.

> Do you want to install chadrc template? (y/n) :

권장 구조를 설치하는 것은 필수 사항은 아니지만, 이 편집기를 처음 사용하는 사람에게는 확실히 권장됩니다. 이미 `custom` 폴더가 있는 NvChad 사용자는 필요한 변경을 가한 후 계속해서 사용할 수 있습니다.

템플릿에 의해 생성된 구조는 이 가이드에서 Markdown으로 문서를 작성하기 위해 개발할 구성에도 사용될 것입니다.

설치를 시작하기 전에 이 주제에 대해 자세히 알고 싶은 사용자는 전용 페이지 [템플릿 Chadrc](template_chadrc.md)를 참조할 수 있습니다.

이 페이지에는 생성될 폴더의 구조, 관련 파일의 기능 및 NvChad 사용자 정의에 대한 기타 유용한 정보에 대한 내용이 포함되어 있습니다.

이제 다운로드 및 기본 플러그인 구성 및 템플릿 설치(선택한 경우)와 구성된 언어 서버의 설치와 같은 과정이 시작됩니다. 작업이 완료되면 편집기를 사용할 준비가 된 상태가 될 것입니다.

![설치](images/installed_first_time.png)

아래 스크린샷에서 볼 수 있듯이 구성 변경으로 인해 기본 Neovim 버전부터 완전히 다른 외관을 갖게 됩니다. 그러나 NvChad의 구성은 편집기를 완전히 변환시키지만 기본은 Neovim입니다.

![NvChad Rockydocs](images/nvchad_ui.png)

### 구성 구조

이제 생성된 구성의 구조를 분석해보겠습니다. 구조는 다음과 같습니다:

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


첫 번째로 만나는 파일은 `init.lua` 파일입니다. 이 파일은 `init.lua/core` 폴더와 `lua/core/utils.lua` (그리고 있을 경우 `lua/custom/init.lua`) 파일을 nvim 트리에 삽입하여 구성을 초기화합니다. `lazy.nvim`(플러그인 매니저)의 부트스트랩을 실행하고, 완료되면 `plugins` 폴더를 초기화합니다.

특히, `load_mappings()` 함수가 호출되어 키보드 단축키를 로드합니다. 또한 `gen_chadrc_template()` 함수는 `custom` 폴더를 생성하기 위한 하위 루틴을 제공합니다.

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

`core` 폴더가 포함되면 `core/init.lua` 파일이 포함되어 Neovim 인터페이스 구성을 일부 재정의하고 버퍼 관리를 준비합니다.

`init.lua` 파일은 잘 정립된 순서에 따라 포함되는 각 `init.lua` 파일을 사용합니다. 이를 통해 기본 설정에서 여러 옵션을 선택적으로 재정의할 수 있습니다. 대체로 `init.lua` 파일은 전역 옵션, autocmd 또는 기타 사항을 로드하는 함수를 포함하고 있습니다.

다음은 기본 명령 매핑을 반환하는 호출입니다:

```lua
require("core.utils").load_mappings()
```

이는 다른 키와 결합하여 명령을 실행할 수 있는 네 개의 주요 키를 설정합니다. 주요 키는 다음과 같습니다:

- C = <kbd>CTRL</kbd>
- leader = <kbd>SPACE</kbd>
- A = <kbd>ALT</kbd>
- S = <kbd>SHIFT</kbd>

!!! 참고 사항

    이러한 키 매핑은 이 문서 전반에 걸쳐 여러 번 언급될 것입니다.

기본 매핑은 _core/mapping.lua_ 에 포함되어 있지만, 별도의 _mappings.lua_ 를 사용하여 다른 사용자 정의 명령을 추가로 확장할 수도 있습니다.

일부 표준 매핑의 예시는 다음과 같습니다:

```text
<space>th to change the theme
<CTRL-n> to open nvimtree
<ALT-i> to open a terminal in a floating tab
```

사용 가능한 많은 조합이 미리 설정되어 있으며, NvChad의 모든 사용 사례를 다룹니다. NvChad로 구성된 Neovim 인스턴스를 사용하기 시작하기 전에 키 매핑을 분석하는 데 시간을 할애하는 것이 좋습니다.

구조 분석을 계속하면 _lua/plugins_ 폴더를 찾을 수 있습니다. 이 폴더에는 내장 플러그인 및 해당 구성이 포함되어 있습니다. 구성의 주요 플러그인은 다음 섹션에서 설명될 것입니다. 우리는 또한 _core/plugins_ 폴더에 `init.lua` 파일이 포함되어 있습니다. 이 파일은 플러그인의 설치 및 이후 컴파일에 사용됩니다.

마지막으로 `lazy-lock.json` 파일을 찾을 수 있습니다. 이 파일은 NvChad 플러그인의 구성을 여러 작업 스테이션에서 동기화하여 사용하는 기능을 제공합니다. 이를 위한 기능은 플러그인 관리자에 대한 섹션에서 자세히 설명될 것입니다.
