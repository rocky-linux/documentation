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

Nerd 글꼴을 설치해도 Neovim이나 NvChad의 기능이 변경되지 않고 현재 표준 터미널 글꼴보다 눈에 더 좋은 글꼴이 추가됩니다.

![Nerd Fonts](images/nerd_fonts_site_small.png){ align=right } Nerd 글꼴은 개발자를 대상으로 수정된 글꼴 모음입니다. 특히 Font Awesome, Devicons, Octicons 등과 같은 "아이코닉 글꼴"은 추가 글리프를 추가하는 데 사용됩니다.

Nerd Fonts는 가장 인기 있는 프로그래밍 글꼴을 사용하여 글리프(아이콘) 그룹을 추가하여 글꼴을 수정합니다. 사용하려는 글꼴이 아직 편집되지 않은 경우 글꼴 패치 프로그램도 사용할 수 있습니다. 사이트에서 편리한 미리보기를 사용할 수 있으므로 편집기에서 글꼴이 어떻게 표시되는지 확인할 수 있습니다. 자세한 내용은 프로젝트의 기본 [사이트](https://www.nerdfonts.com/)를 확인하세요.

## 다운로드

글꼴은 다음 사이트에서 다운로드할 수 있습니다.

```text
https://www.nerdfonts.com/font-downloads
```

## 설치

Rocky Linux에서 글꼴을 설치하는 절차는 추가하려는 글꼴을 어딘가에 저장한 다음 `fc-cache` 명령으로 설치하는 것입니다. 이 절차는 실제 설치가 아니라 시스템에 새 글꼴을 등록하는 것입니다.

!!! "압축 패키지 생성" 주의

    아래에 설명된 절차는 각 개발자가 사용자 정의 구성표를 사용하여 글꼴을 패키징했기 때문에 표준 절차가 아닙니다. 그래서 다운받아 압축을 풀고 나면 내용을 확인하여 폰트를 복사하는 절차를 선택해야 합니다.

이 가이드에서는 `Sauce Code Pro Nerd` 글꼴을 사용합니다.

다음을 사용하여 패키지를 다운로드합니다.

```bash
https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip
```

다음으로 폴더의 내용을 압축 해제하고 다음을 사용하여 글꼴을 `~/.local/share/fonts/`에 복사합니다.

```bash
mkdir ~/.local/share/fonts
unzip SourceCodePro.zip -d ~/.local/share/fonts/
fc-cache ~/.local/share/fonts
```

## 구성

이 시점에서 선택한 Nerd 글꼴을 선택할 수 있어야 합니다. 실제로 선택하려면 사용 중인 데스크탑을 참조해야 합니다.

![글꼴 매니저](images/font_nerd_view.png)

기본 Rocky Linux 데스크톱(Gnome)을 사용하는 경우 터미널 에뮬레이터에서 글꼴을 변경하려면 `gnome-terminal`를 열고 "환경 설정"으로 이동한 다음 프로필에 Nerd 글꼴을 설정하기만 하면 됩니다.
