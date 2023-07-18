---
title: Nerd 폰트 설치
author: Franco Colussi
contributors: Steven Spencer
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - fonts
---

# Nerd Fonts - 개발자를 위한 폰트

Nerd Fonts를 설치하면 Neovim 또는 NvChad의 기능이 변경되지는 않지만, 현재의 표준 터미널 폰트보다 더 매력적인 폰트를 추가하는 것입니다.

![Nerd Fonts](images/nerd_fonts_site_small.png){ align=right }는 개발자를 위해 수정된 폰트들의 컬렉션입니다. 특히, Font Awesome, Devicons, Octicons 등과 같은 "아이콘 폰트"를 사용하여 추가적인 글리프를 추가합니다.

Nerd Fonts는 가장 인기있는 프로그래밍 폰트를 가져와서 일련의 글리프(아이콘)를 추가로 포함시킵니다. 폰트를 사용하려는 경우 이미 편집되지 않은 경우 폰트 패처도 사용할 수 있습니다. 사이트에서 편리한 미리보기를 제공하여 편집기에서 폰트가 어떻게 보여야 하는지 확인할 수 있습니다. 자세한 정보는 프로젝트의 주요 [사이트](https://www.nerdfonts.com/)를 참조하십시오.

## 다운로드

폰트는 다음 주소에서 다운로드할 수 있습니다:

```text
https://www.nerdfonts.com/font-downloads
```

## 설치

Rocky Linux에서 폰트를 설치하는 절차는 원하는 폰트를 어딘가에 저장한 다음 `fc-cache` 명령을 사용하여 설치하는 것입니다. 이 절차는 새로운 폰트를 시스템에 등록하는 것이므로 정확히 설치라기보다는 등록에 가깝습니다.

!!! "압축 패키지 생성" 주의

    아래에 설명된 절차는 표준 절차가 아닙니다. 각 개발자는 사용자 지정 방식으로 폰트를 패키징했기 때문입니다. 따라서 다운로드하고 추출한 후에 내용을 확인하여 폰트를 복사하기 위한 절차를 선택해야 합니다.

이 가이드에서는 `Sauce Code Pro Nerd` 글꼴을 사용합니다.

다음 명령으로 패키지를 다운로드합니다:

```bash
https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip
```

그런 다음 폴더의 내용을 압축 해제하고 다음 명령으로 폰트를 `~/.local/share/fonts/`에 복사합니다:

```bash
mkdir ~/.local/share/fonts
unzip SourceCodePro.zip -d ~/.local/share/fonts/
fc-cache ~/.local/share/fonts
```

## 구성

이 시점에서 선택한 Nerd 폰트를 사용할 수 있어야 합니다. 실제로 선택하려면 사용 중인 데스크톱 환경에 따라 달라집니다.

![글꼴 매니저](images/font_nerd_view.png)

기본 Rocky Linux 데스크톱(Gnome)을 사용하는 경우 터미널 에뮬레이터에서 폰트를 변경하려면 `gnome-terminal`을 열고 "기본 설정"으로 이동하여 프로필에 Nerd 폰트를 설정하면 됩니다.
