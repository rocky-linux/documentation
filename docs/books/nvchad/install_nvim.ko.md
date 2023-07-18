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

Neovim은 속도, 사용자 정의의 용이성 및 설정 가능성으로 인해 최고의 코드 편집기 중 하나입니다.

Neovim은 `Vim`` 편집기의 포크입니다. 2014년에 비동기 작업 지원이 부족한 Vim 때문에 탄생했습니다. 루아 언어로 작성되어 코드를 모듈화하여 관리하기 쉽게 만들기 위한 목표로 설계되었으며, 현대 사용자를 위해 개발되었습니다. 공식 웹사이트에 따르면 "Neovim은 Vim의 가장 좋은 부분과 그 이상을 원하는 사용자를 위해 만들어졌습니다".

Neovim 개발자들은 Lua를 선택했는데, 이는 LuaJIT를 사용하여 빠르게 간단하고 스크립트 중심의 구문으로 포함할 수 있기 때문입니다.

0.5 버전부터 Neovim은 Treesitter(파서 생성 도구)를 포함하고 언어 서버 프로토콜(LSP)을 지원합니다. 이를 통해 고급 편집 기능을 달성하기 위해 필요한 플러그인 수를 줄일 수 있습니다. 코드 완성 및 린팅과 같은 작업의 성능을 향상시킵니다.

Neovim의 한 가지 강점은 사용자 정의입니다. 모든 구성은 단일 파일에 포함되어 Git 또는 기타 버전 관리 시스템을 통해 다양한 설치에 배포할 수 있으므로 항상 동기화됩니다.

### 개발자 커뮤니티

Vim과 Neovim은 모두 오픈 소스 프로젝트이며 GitHub에서 호스팅되지만 개발 방식 사이에는 중요한 차이가 있습니다. Neovim은 더 개방적인 커뮤니티 개발을 가지고 있으며, Vim의 개발은 창시자의 선택에 더 종속적입니다. Neovim의 사용자 및 개발자 기반은 Vim에 비해 상당히 작지만, 계속 성장하고 있는 프로젝트입니다.

### 주요 특징

- 성능: 매우 빠릅니다.
- 사용자 지정 가능: 다양한 플러그인과 테마 생태계가 있습니다.
- 구문 강조 표시: Treesitter 및 LSP와 통합되어 있지만 일부 구성이 필요합니다.

Vim과 마찬가지로 Neovim은 명령어와 옵션에 대한 기본적인 지식이 필요합니다. `:Tutor` 명령어를 사용하여 해당 기능을 개요로 확인할 수 있습니다. 이 명령은 읽고 연습할 수 있는 파일을 호출합니다. 학습 속도는 완전한 그래픽 IDE보다 더 오래 걸리지만, 명령어의 단축키와 포함된 기능을 한 번 익힌 후에는 문서 편집에 매우 원활하게 진행할 수 있습니다.

![Nvim 튜터](images/neovim_tutor.png)

## Neovim 설치

### EPEL에서 설치

NvChad 설치로 넘어가기 전에 Neovim 설치가 가능한지 확인해야 합니다. 이미 설치되어 있지 않은 경우 EPEL 저장소에서 설치할 수 있습니다. EPEL 저장소는 NvChad에서 필요한 최소한의 버전(현재 0.7.2)을 제공합니다. 더 최신 버전을 사용하려면 미리 컴파일된 패키지 또는 소스에서 설치하는 것을 권장합니다.

EPEL에서 제공하는 Neovim 릴리스를 설치하려면 이전에 수행하지 않았다면 저장소 자체를 설치해야 합니다.

```bash
dnf install epel-release
```

다음 명령을 사용하여 응용 프로그램을 설치합니다.

```bash
dnf install neovim
```

### 미리 컴파일된 패키지에서 설치

미리 컴파일된 패키지에서 설치를 통해 Neovim의 개발 버전(0.8 이상)을 테스트할 수 있습니다. 두 버전(설치)은 동일한 시스템에 공존할 수 있으며, 미리 컴파일된 패키지에서의 버전은 사용자 수준에서 완전히 제한됩니다.

새 버전의 모든 기능을 사용하려면 Neovim에서 필요한 종속성을 충족해야 합니다. 종속성은 수동으로 `nvim`에게 제공해야 합니다. 필요한 패키지를 다음과 같이 설치할 수 있습니다.

```bash
dnf install compat-lua-libs libtermkey libtree-sitter libvterm luajit luajit2.1-luv msgpack unibilium xsel
```

그다음, 해당 주소에서 아키텍처(linux64)에 맞는 압축된 아카이브를 다운로드합니다:

```text
https://github.com/neovim/neovim/releases
```

다운로드할 파일은 `nvim-linux64.tar.gz`입니다. 아카이브의 무결성을 확인하기 위해 `nvim-linux64.tar.gz.sha256sum` 파일도 다운로드해야 합니다. 다운로드한 후에는 그의 무결성을 확인하고 `홈 디렉토리`의 적절한 위치에 압축을 해제해야 합니다. 제안된 솔루션은 `~/.local/share/`에 압축을 해제하는 것입니다. _/home/user/downloads/_ 에 다운로드했다고 가정하면 다음 명령을 실행해야 합니다:

```bash
sha256sum -c /home/user/downloads/nvim-linux64.tar.gz.sha256sum
nvim-linux64.tar.gz: OK

tar xvzf /home/user/downloads/nvim-linux64.tar.gz
mv /home/user/downloads/nvim-linux64 ~/.local/share/nvim-linux64
```

이제  _nvim_ 을 위한 심볼릭 링크를 `~/.local/bin/`에 생성하면 됩니다.

```bash
cd ~/.local/bin/
ln -sf ~/.local/share/nvim-linux64/bin/nvim nvim
```

이제 `nvim -v` 명령을 사용하여 올바른 버전을 확인합니다. 이제 다음과 같이 표시되어야 합니다:

```txt
nvim -v
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
```

### 소스에서 설치

위에서 언급한대로 미리 컴파일된 패키지를 사용하면 실행하는 사용자에게만 `nvim`이 제공됩니다. 시스템의 모든 사용자에게 Neovim을 사용할 수 있게 하려면 소스에서 설치를 진행해야 합니다. Neovim을 컴파일하는 것은 어렵지 않으며 다음 단계로 구성됩니다.

먼저 컴파일에 필요한 패키지를 설치합니다:

```bash
dnf install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git
```

필요한 패키지를 설치한 후에는 Neovim을 빌드하기 위한 폴더를 생성하고 해당 폴더로 이동해야 합니다:

기본적으로 Neovim 클론은 Neovim 개발 브랜치(현재 버전 8.0)와 동기화됩니다. 안정 버전을 컴파일하려면 클론하기 전에 해당 브랜치로 전환해야 합니다:

```bash
mkdir ~/lab/build
cd ~/lab/build
```

이제 리포지토리를 복제합니다.

```bash
git clone https://github.com/neovim/neovim
```

작업이 완료되면 _neovim_ 이라는 이름의 폴더가 생성되며 필요한 모든 파일이 포함됩니다. 다음 단계는 안정 브랜치를 체크아웃하고, 그런 다음 `make` 명령을 사용하여 소스를 구성하고 컴파일하는 것입니다.


```bash
cd ~/lab/build/neovim/
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
```

여기에서는 최적화뿐만 아니라 나중에 사용자 정의에 유용한 디버깅 레이어도 제공하는 `RelWithDebInfo` 유형을 선택했습니다. 최고의 성능을 원한다면 `Release` 유형을 사용할 수도 있습니다.

이 과정은 시스템에 설치할 파일을 구성하고 컴파일하는 작업을 수행합니다. 이러한 파일은 `neovim/build`에 저장됩니다. 이를 설치하기 위해 _make install_ 명령을 사용합니다:

```bash
make install
```

이 명령은 파일 시스템을 수정하기 때문에 `sudo` 또는 root 사용자로 실행해야 합니다.

설치가 완료되면 Neovim의 경로가 올바른지 확인할 수 있습니다:

```
whereis nvim
nvim: /usr/local/bin/nvim
```

버전을 확인하여 모든 것이 잘 실행되었는지 확인합니다:

```bash
nvim --version
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
....
```

위의 명령 예시에서 확인할 수 있듯이 안정 버전의 설치가 수행되었습니다. 안정 버전과 개발 버전은 Rocky Linux 9에서 NvChad와 완벽하게 작동합니다.

#### 설치 제거

다른 버전으로 전환하기 위해 설치를 제거해야 하는 경우 빌드 폴더로 이동한 후에 Neovim 자체에서 제공하는 `target` cmake을 사용해야 합니다. 제거를 수행하기 위해 다음 명령을 실행해야 합니다:

```bash
cmake --build build/ --target uninstall
```

이 명령도 슈퍼유저 권한이 필요하거나 _root_ 사용자로 실행해야 합니다.

또는 다음 명령을 사용하여 실행 가능한 파일과 라이브러리를 수동으로 제거할 수 있습니다:

```bash
rm /usr/local/bin/nvim
rm -r /usr/local/share/nvim/
```

다시 말하지만 슈퍼유저 권한으로 이러한 명령을 실행해야 합니다.

## Neovim Basic

스크린샷에서 알 수 있듯이 기본 Neovim 설치는 아직 IDE와 비교할 수 없는 편집기를 제공합니다.

![Neovim Standard](images/nvim_standard.png)

이제 기본 편집기가 있으므로 [NvChad](install_nvchad.md)에서 제공하는 설정을 통해 더 고급으로 변환할 시간입니다.
