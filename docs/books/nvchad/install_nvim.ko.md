---
title: Neovim 설치
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - nvim
  - coding
---

## Neovim 소개

Neovim은 속도, 사용자 정의 용이성 및 구성으로 인해 최고의 코드 편집기 중 하나입니다.

Neovim은 `Vim` 편집기의 포크입니다. 2014년에 탄생했는데, 주로 Vim에서 비동기 작업 지원 당시의 부족함 때문이었습니다. 코드를 모듈화하여 관리하기 쉽게 만드는 것을 목표로 Lua 언어로 작성된 Neovim은 현대 사용자를 염두에 두고 설계되었습니다. 공식 웹사이트에 "Neovim은 Vim의 가장 좋은 부분 등을 원하는 사용자를 위해 만들어졌습니다."라고 명시되어 있습니다. 관리가 용이한 Neovim은 현대 사용자를 염두에 두고 설계되었습니다.

Neovim의 개발자들은 LuaJIT를 신속하게 사용하고 간단한 스크립트 지향 구문을 사용하여 임베딩에 완벽했기 때문에 Lua를 선택했습니다.

버전 0.5부터 Neovim은 Treesitter(파서 생성기 도구)를 포함하고 LSP(Language Server Protocol)를 지원합니다. 이것은 고급 편집 기능을 달성하는 데 필요한 플러그인의 수를 줄입니다. 코드 완성 및 linting과 같은 작업의 성능을 향상시킵니다.

이 제품의 장점 중 하나는 맞춤형입니다. 모든 구성은 버전 제어 시스템(Git 또는 기타)을 통해 다양한 설치에 배포할 수 있는 단일 파일에 포함되어 항상 동기화됩니다.

### 개발자 커뮤니티

Vim과 Neovim은 둘 다 오픈 소스 프로젝트이고 GitHub에서 호스팅되지만 개발 모드 간에는 상당한 차이가 있습니다. Neovim은 보다 개방적인 커뮤니티 개발을 제공하는 반면 Vim의 개발은 제작자의 선택에 더 얽매여 있습니다. Neovim의 사용자 및 개발자 기반은 Vim에 비해 매우 작지만 지속적으로 성장하는 프로젝트입니다.

### 주요 특징

- 성능: 매우 빠릅니다.
- 사용자 지정 가능: 플러그인 및 테마의 광범위한 환경,
- 구문 강조 표시: Treesitter 및 LSP와 통합되지만 일부 구성이 필요.

Vim과 마찬가지로 Neovim에는 명령 및 옵션에 대한 기본 지식이 필요합니다. 읽을 수 있는 파일을 호출하는 `:Tutor` 명령을 통해 해당 기능의 개요를 보고 이를 사용하여 연습할 수 있습니다. 완전한 그래픽 IDE보다 학습 시간이 오래 걸리지만 명령에 대한 바로 가기와 포함된 기능을 익히면 문서 편집이 매우 원활하게 진행됩니다.

![Nvim 튜터](images/neovim_tutor.png)

## Neovim 설치

### EPEL에서 설치

NvChad 설치로 이동하기 전에 Neovim 설치가 가능한지 확인해야 합니다. 아직 설치되지 않은 경우 EPEL 저장소에서 설치할 수 있습니다. EPEL 저장소는 NvChad에 필요한 최소 버전(현재 0.7.2)을 제공합니다. 최신 버전을 사용하려면 미리 컴파일된 패키지 또는 소스에서 설치하는 것이 좋습니다.

EPEL에서 제공하는 Neovim 릴리스를 설치하려면 저장소 자체를 아직 설치하지 않은 경우 설치해야 합니다.

```bash
dnf install epel-release
```

다음 명령을 입력하여 애플리케이션을 설치합니다.

```bash
dnf install neovim
```

### 미리 컴파일된 패키지에서 설치

미리 컴파일된 패키지에서 설치하면 Neovim(0.8 이상)의 개발 버전을 테스트할 수 있습니다. 미리 컴파일된 패키지의 버전이 완전히 사용자 수준으로 제한되므로 두 버전(설치)이 동일한 시스템에 공존할 수 있습니다.

새로운 버전의 모든 기능을 사용하기 위해서는 네오빔이 요구하는 의존성을 충족시켜야 하며, _우리의_ `nvim`를 수동으로 제공해야 합니다. 필수 패키지는 다음을 사용하여 설치할 수 있습니다.

```bash
dnf install compat-lua-libs libtermkey libtree-sitter libvterm luajit luajit2.1-luv msgpack unibilium xsel
```

다음으로 다음 주소에서 아키텍처(linux64)용 압축 아카이브를 다운로드합니다.

```text
https://github.com/neovim/neovim/releases
```

다운로드할 파일은 `nvim-linux64.tar.gz`입니다. 아카이브의 무결성을 확인하려면 `nvim-linux64.tar.gz.sha256sum` 파일도 다운로드해야 합니다. 다운로드가 완료되면 무결성을 확인하고 `홈 디렉토리` 어딘가에 압축을 풀어야 합니다. 제안된 솔루션은 `~/.local/share/`에 압축을 푸는 것입니다. _/home/user/downloads/_에 다운로드했다고 가정하면 다음 명령을 실행해야 합니다.

```bash
sha256sum -c /home/user/downloads/nvim-linux64.tar.gz.sha256sum
nvim-linux64.tar.gz: OK

tar xvzf /home/user/downloads/nvim-linux64.tar.gz
mv /home/user/downloads/nvim-linux64 ~/.local/share/nvim-linux64
```

이 시점에서 남은 것은 _nvim_에 대해 `~/.local/bin/`에 심볼릭 링크를 만드는 것입니다.

```bash
cd ~/.local/bin/
ln -sf ~/.local/share/nvim-linux64/bin/nvim nvim
```

이제 `nvim -v` 명령을 사용하여 올바른 버전이 있는지 확인합니다. 이 명령은 다음과 같이 표시됩니다:

```txt
nvim -v
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
```

### 소스에서 설치

위와 같이 미리 컴파일된 패키지에서 설치하면 실행하는 사용자에게만 `nvim`이 제공됩니다. 시스템의 모든 사용자가 Neovim을 사용할 수 있도록 하려면 소스에서 설치를 수행해야 합니다. Neovim 컴파일은 특별히 어렵지 않으며 다음 단계로 구성됩니다.

먼저 컴파일에 필요한 패키지를 설치합니다.

```bash
dnf install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git
```

먼저 컴파일에 필요한 패키지를 설치합니다.

기본적으로 Neovim 클론은 Neovim 개발 브랜치(이 작성 당시 버전 8.0)와 동기화됩니다. 안정적인 버전을 컴파일하려면 다음을 사용하여 복제하기 전에 해당 브랜치로 전환해야 합니다:

```bash
mkdir ~/lab/build
cd ~/lab/build
```

이제 리포지토리를 복제합니다.

```bash
git clone https://github.com/neovim/neovim
```

작업이 완료되면 필요한 모든 파일이 포함된 _neovim_이라는 폴더가 생성됩니다. 다음 단계는 안정적인 분기를 체크아웃한 다음 `make` 명령으로 소스를 구성하고 컴파일하는 것입니다.


```bash
cd ~/lab/build/neovim/
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
```

`RelWithDebInfo` 유형을 선택한 이유는 최적화뿐만 아니라 이후 사용자 지정을 위한 유용한 디버깅 계층도 제공하기 때문입니다. 최대 성능을 원한다면 `Release` 유형을 사용할 수도 있습니다.

이 프로세스는 시스템에 넣을 파일을 구성하고 컴파일하는 작업을 처리합니다. 이러한 파일은 `neovim/build`에 저장됩니다. 설치하려면 _make install_ 명령을 사용합니다.

```bash
make install
```

이 명령은 파일 시스템을 수정하기 때문에 `sudo`를 사용하거나 루트 사용자가 직접 수퍼유저로 실행해야 합니다.

설치가 완료되면 Neovim의 경로를 확인하여 모든 것이 잘 되었는지 확인할 수 있습니다.

```
whereis nvim
nvim: /usr/local/bin/nvim
```

그리고 버전 확인:

```bash
nvim --version
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
....
```

위의 발췌된 명령에서 알 수 있듯이 여기에서 안정 버전의 설치가 수행되었습니다. 안정적인 버전과 개발 버전 모두 Rocky Linux 9에서 NvChad와 완벽하게 작동합니다.

#### 설치 제거

예를 들어 다른 버전으로 전환하기 위해 설치를 제거해야 하는 경우 빌드 폴더로 돌아가서 Neovim 자체에서 제공하는 `target` cmake를 사용해야 합니다. 제거를 수행하려면 다음 명령을 실행해야 합니다.

```bash
cmake --build build/ --target uninstall
```

또한 이 명령은 슈퍼유저 권한이 필요하거나 _root_ 사용자로 실행되어야 합니다.

또는 다음을 사용하여 실행 파일과 라이브러리를 제거하여 수동 방법을 사용할 수 있습니다.

```bash
rm /usr/local/bin/nvim
rm -r /usr/local/share/nvim/
```

다시 말하지만 슈퍼유저 권한으로 이러한 명령을 실행해야 합니다.

## Neovim Basic

스크린샷에서 볼 수 있듯이 Neovim의 기본 설치는 아직 IDE와 비교할 수 없는 편집기를 제공합니다.

![Neovim Standard](images/nvim_standard.png)

이제 기본 편집기가 있으므로 [NvChad](install_nvchad.md)에서 제공하는 구성 덕분에 고급 편집기로 전환할 때입니다.
