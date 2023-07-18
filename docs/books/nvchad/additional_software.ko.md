---
title: 추가 소프트웨어
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
---

# 추가 소프트웨어 필요

이 소프트웨어는 필수적이지는 않지만 NvChad의 전반적인 사용에 도움이 될 것입니다. 아래 섹션에서 해당 소프트웨어와 그 사용법을 안내해 드리겠습니다.

## RipGrep

`ripgrep`는 현재 디렉토리를 재귀적으로 검색하여 _regex_(regular expression) 패턴과 일치하는 줄을 찾아주는 줄 지향 검색 도구입니다. _ripgrep_은 기본적으로 _gitignore_ 규칙을 존중하며, 숨겨진 파일/디렉토리와 이진 파일을 자동으로 건너뜁니다. Ripgrep은 Windows, macOS, Linux에서 모두 훌륭한 지원을 제공하며, 각 릴리스별로 바이너리가 제공됩니다.

### EPEL에서 RipGrep 설치

Rocky Linux 8 및 9에서는 EPEL을 통해 RipGrep을 설치할 수 있습니다. 이를 위해 `epel-release`를 설치하고 시스템을 업그레이드한 다음 `ripgrep.`을 설치합니다:

```
sudo dnf install -y epel-release
sudo dnf upgrade
sudo dnf install ripgrep
```

### `cargo`를 사용하여 RipGrep 설치

Ripgrep은 _Rust_로 작성된 소프트웨어로, `cargo` 유틸리티를 사용하여 설치할 수 있습니다. 그러나 `cargo`는 _rust_의 기본 설치에 포함되지 않으므로 명시적으로 설치해야 합니다. 이 방법을 사용할 때 오류가 발생하는 경우 EPEL에서 설치하는 방법으로 되돌아가세요.

```bash
dnf install rust cargo
```

필요한 소프트웨어가 설치되었다면 다음 명령을 사용하여 `ripgrep`을 설치할 수 있습니다:

```bash
cargo install ripgrep
```

설치는 `rg` 실행 파일을 `~/.cargo/bin`폴더에 저장하는데, 이 폴더는 PATH에 포함되어 있지 않습니다. 사용자 수준에서 사용하기 위해 해당 실행 파일을 `~/.local/bin/`에 링크하겠습니다.

```bash
ln -s ~/.cargo/bin/rg ~/.local/bin/
```

## RipGrep 인증

이 시점에서 다음 명령을 사용하여 모든 것이 정상적으로 설치되었는지 확인할 수 있습니다:

```bash
rg --version
ripgrep 13.0.0
-SIMD -AVX (compiled)
+SIMD +AVX (runtime)
```

`:Telescope`에서 재귀적인 검색을 위해 RipGrep이 필요합니다.

## Lazygit

[LazyGit](https://github.com/jesseduffield/lazygit)은 더 사용자 친화적인 방식으로 모든 `git` 작업을 수행할 수 있게 해주는 ncurses 스타일 인터페이스입니다. _lazygit.nvim_ 플러그인에서 필요합니다. 이 플러그인을 사용하면 NvChad에서 직접 LazyGit을 사용할 수 있으며, 모든 레포지토리에 대한 모든 작업을 수행할 수 있는 부동 윈도우를 엽니다. 따라서 편집기를 떠나지 않고도 _git 리포지토리_ 에 모든 변경 사항을 적용할 수 있습니다.

Fedora 저장소를 사용하여 설치할 수 있습니다. Rocky Linux 9에서는 완벽하게 작동합니다.

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

설치가 완료되면 터미널을 열고 `lazygit` 명령어를 입력하면 다음과 유사한 인터페이스가 표시됩니다:

![LazyGit UI](images/lazygit_ui.png)

<kbd>x</kbd> 키로 사용 가능한 모든 명령을 보여주는 메뉴를 열 수 있습니다.

![LazyGit UI](images/lazygit_menu.png)

이제 시스템에 필요한 모든 지원 소프트웨어가 있으므로 기본 소프트웨어 설치로 넘어갈 수 있습니다. 이제 시스템에 필요한 모든 지원 소프트웨어가 설치되었으므로, NvChad를 기반으로한 편집기인 [Neovim](install_nvim.md)의 설치로 이동할 수 있습니다.
