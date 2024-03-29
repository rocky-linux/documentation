---
title: 개요
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - 편집기
---

# 소개

이 책에서는 NvChad와 함께 Neovim을 구현하여 완전히 기능적인 통합 개발 환경(IDE)를 만드는 방법을 찾을 수 있습니다(**I**ntegrated **D**evelopment **E**nvironment).

"방법"이라고 말한 이유는 다양한 가능성이 있기 때문입니다. 저자는 여기에서 이 도구들을 마크다운 작성에 사용하는 방법에 초점을 맞추지만, 마크다운이 주요 관심사가 아니라면 걱정하지 마세요. 이 책을 읽으면서 NvChad나 Neovim에 익숙하지 않다면 두 도구에 대한 소개를 받게 되고, 이 문서를 따라가면 프로그래밍이나 스크립트 작성에 필요한 환경을 큰 도움으로 구성할 수 있는 것을 빨리 깨달을 수 있을 것입니다.

Ansible 플레이북 작성에 도움이 되는 IDE가 필요하신가요? 가능합니다! Golang용 IDE를 원하시나요? 가능합니다. BASH 스크립트 작성에 좋은 인터페이스가 필요한가요? 가능합니다.

**L**anguage **S**erver **P**rotocols과 린터(linter)를 사용하여 사용자 정의 환경을 설정할 수 있습니다. 가장 좋은 점은 환경을 설정한 후에는 [lazy.nvim](https://github.com/folke/lazy.nvim) 와 [Mason](https://github.com/williamboman/mason.nvim)을 통해 새로운 변경 사항이 사용 가능할 때마다 빠르게 업데이트할 수 있다는 점입니다. 이 두 가지는 여기에서 다루고 있습니다.

Neovim은 `vim`의 파생 버전이므로 `vim` 사용자에게는 전반적인 인터페이스가 익숙할 것입니다. `vim` 사용자가 아니라면 이 책을 통해 명령어의 구문을 빠르게 익힐 수 있습니다. 여기에서 다루는 내용은 많지만 따라가기 쉽고, 내용을 완료한 후에는 이 도구들로 자신에게 필요한 IDE를 구축할 수 있을 정도의 지식을 얻게 될 것입니다.

저자는 이 책을 장(chapter)으로 **분할하지 않은 것**이 의도되었습니다. 이는 따라야 하는 순서를 가리키는 것이므로 대부분의 경우에는 필요하지 않기 때문입니다. 이 페이지부터 시작하여 "추가 소프트웨어", "Neovim 설치" 및 "NvChad 설치" 섹션을 읽고 따라가는 것이 *좋지만*, 그 이후에는 진행 방식을 선택할 수 있습니다.

## Neovim을 IDE로 사용하기

Neovim의 기본 설치는 개발을 위한 우수한 편집기를 제공하지만 아직 IDE라고 부를 수는 없습니다. 더 발전된 IDE 기능들은 이미 사전에 설정되어 있지만 아직 활성화되지 않았습니다. 이를 위해 Neovim에 필요한 구성을 전달해야 하는데, 여기서 NvChad가 도움이 됩니다. 이를 통해 하나의 명령으로 기본 구성을 가져올 수 있습니다!

이 구성은 Lua로 작성된다는 점이 특징입니다. Lua는 매우 빠른 프로그래밍 언어로, NvChad가 매우 빠른 시작 및 실행 시간을 가지는 명령 및 키 입력을 수행할 수 있게 합니다. 이는 또한 필요할 때만 플러그인을 로드하는 `Lazy loading` 기법에 의해 가능합니다.

인터페이스는 매우 깨끗하고 쾌적합니다.

NvChad 개발자들은 이 프로젝트가 개인적인 IDE를 구축하기 위한 기초로 사용되기를 원한다고 강조하고 있습니다. 나중에는 플러그인을 사용하여 추가적인 사용자 정의를 수행합니다.

![NvChad UI](images/nvchad_rocky.png)

### 주요 기능

- **빠른 속도.** 프로그래밍 언어 선택부터 구성 요소 로딩 기법까지 모든 것이 실행 시간을 최소화하기 위해 설계되었습니다.

- **매력적인 인터페이스.** _cli_ 응용 프로그램임에도 불구하고 그래픽적으로 현대적이고 아름다운 인터페이스를 제공하며, 모든 구성 요소가 UI에 완벽하게 맞춰집니다.

- **매우 유연한 가능.**  기본 응용 프로그램(NeoVim)에서 파생된 모듈성 덕분에 편집기를 자신의 요구에 맞게 완벽하게 조정할 수 있습니다. 그러나 사용자 정의에 대해 언급할 때 인터페이스의 모양이 아닌 기능적인 부분을 의미한다는 점을 명심하세요.

- **자동 업데이트 메커니즘.** 이 편집기는 _git_ 을 통해 업데이트할 수 있는 메커니즘(`:NvChadUpdate` 명령)을 제공합니다.

- **Lua로 작성.** NvChad의 구성은 전적으로 _lua_ 로 작성되어 있으며, 기반이 되는 편집기의 모든 잠재력을 활용하기 위해 Neovim의 구성에 매끄럽게 통합될 수 있습니다.

- **다양한 내장 테마.** 구성에는 사용할 수 있는 다양한 테마가 이미 포함되어 있으며,  _cli_ 응용 프로그램에 대한 얘기를 하는 것을 명심하세요. 테마는 `<leader> + th` 키로 선택할 수 있습니다.

![NvChad 테마](images/nvchad_th.png)

## 참고

### Lua

#### Lua란 무엇입니까?

Lua는 다양한 프로그래밍 방법을 지원하는 강력하고 가벼운 스크립팅 언어입니다. "Lua"라는 이름은 "달"을 의미하는 포르투갈어에서 온 것입니다.

Lua는 로베르토 이루살림스키(Roberto Ierusalimschy), 루이스 헨리케 데 피게이레도(Luiz Henrique de Figueiredo) 및 왈데마르 셀레스(Waldemar Celes)에 의해 리우데자네이루 카톨리카 대학교에서 개발되었습니다. 이 개발은 1992년까지 브라질이 하드웨어와 소프트웨어에 엄격한 수입 규제를 받았기 때문에 그들에게 필요한 일이었으며, 그들은 필요에 의해 Lua라는 자체 스크립팅 언어를 개발했습니다.

Lua는 주로 스크립트에 초점을 맞추고 있기 때문에 독립적인 프로그래밍 언어로 사용되는 경우는 드뭅니다. 대신 주로 다른 프로그램에 통합(임베디드)될 수 있는 스크립팅 언어로 사용됩니다.

Lua는 비디오 게임 및 게임 엔진 개발(로블록스, 워프레임 등), 다양한 네트워크 프로그램(엔맵, ModSecurity 등)에서 프로그래밍 언어로 사용되며, 산업용 프로그램에서도 프로그래밍 언어로 사용됩니다. 또한 Lua는 호스트 응용 프로그램의 일부로서 스크립팅 기능을 제공하기 위해 개발자가 프로그램에 통합할 수 있는 라이브러리로 사용됩니다.

#### Lua 작동 방식

Lua에는 두 가지 주요 구성 요소가 있습니다.

- Lua 인터프리터
- Lua 가상 머신(VM)

Lua는 다른 언어(예: Python)처럼 Lua 파일을 직접 해석하는 것이 아니라 Lua 인터프리터를 사용하여 Lua 파일을 바이트코드로 컴파일합니다. 대신 Lua 인터프리터를 사용하여 Lua 파일을 바이트코드로 컴파일합니다. Lua 인터프리터는 매우 이식성이 뛰어나며 다양한 장치에서 실행할 수 있습니다.

#### 주요 특징

- 속도: Lua는 해석형 스크립트 언어 중에서 가장 빠른 프로그래밍 언어 중 하나로 여겨지며, 다른 대부분의 프로그래밍 언어보다 더 빠르게 성능 요구가 큰 작업을 수행할 수 있습니다.

- 크기: Lua는 다른 프로그래밍 언어에 비해 크기가 매우 작습니다. 이 작은 크기는 Lua를 임베디드 장치에서부터 게임 엔진까지 다양한 플랫폼에 통합하기에 이상적입니다.

- 이식성 및 통합성: Lua의 이식성은 거의 제한이 없습니다. 표준 C 컴파일러를 지원하는 모든 플랫폼에서 Lua를 문제없이 실행할 수 있습니다. Lua는 다른 프로그래밍 언어와 호환되도록 복잡한 변경이 필요하지 않습니다.

- 단순성: Lua는 간결한 설계를 가지고 있지만 강력한 기능을 제공합니다. Lua의 주요 특징 중 하나는 메타 기능을 통해 사용자 정의 기능을 구현할 수 있다는 점입니다. 구문은 간단하고 이해하기 쉬운 형식으로 작성되어 누구나 쉽게 Lua를 배우고 자신의 프로그램에서 사용할 수 있습니다.

- 라이선스: Lua는 MIT 라이선스로 배포되는 무료 오픈 소스 소프트웨어입니다. 이를 통해 라이선스 비용이나 로열티 없이 어떤 목적으로든 사용할 수 있습니다.

### Neovim

Neovim은 [전용 페이지](install_nvim.md)에 자세히 설명되어 있으므로 여기서는 주요 기능에 대해 다루겠습니다. 다음과 같습니다:

- 성능: 매우 빠릅니다.

- 사용자 정의 가능: 다양한 플러그인과 테마의 생태계가 있습니다.

- 구문 강조 표시: Treesitter 및 LSP와의 통합(추가 구성이 필요)을 지원합니다.

- 다중 플랫폼: Linux, Windows 및 macOS

- 라이센스: Mit: 저작권 및 라이선스 공지사항만 보존하도록 조건이 있는 간단하고 짧은 허가 라이선스입니다.

### LSP

언어 서버 프로토콜(**L**anguage **S**erver **P**rotocol)은 무엇입니까?

언어 서버는 자동 완성, 정의로 이동 또는 마우스 오버 정의와 같은 기능을 지원하기 위해 자체 프로시저(프로토콜)를 사용하는 표준화된 언어 라이브러리입니다.

언어 서버 프로토콜(LSP)의 아이디어는 도구와 서버 사이의 통신 프로토콜을 표준화하여 단일 언어 서버를 여러 개발 도구에서 재사용할 수 있게 하는 것입니다. 이렇게 하면 개발자는 그들의 편집기에 이러한 라이브러리를 통합하기만 하면 되므로 코드를 포함하기 위해 사용자 정의 코드를 작성할 필요가 없게 됩니다.

### tree-sitter

[Tree-sitter](https://tree-sitter.github.io/tree-sitter/)는 기본적으로 두 가지 구성 요소로 구성되어 있습니다: 파서 생성기와 증분 파싱 라이브러리입니다. 이를 사용하여 소스 파일의 구문 트리를 구축하고 각 변경 사항과 함께 효율적으로 업데이트할 수 있습니다.

파서는 다른 언어로 쉽게 번역되기 위해 데이터를 더 작은 요소로 분해하는 구성 요소입니다. 소스 파일이 분해되면 파싱 라이브러리가 코드를 파싱하고 구문 트리로 변환하여 코드의 구조를 더 지능적으로 조작할 수 있도록 합니다. 이로 인해 개선(및 가속화)할 수 있습니다.

- 구문 강조 표시
- 코드 탐색
- 리팩토링
- 텍스트 개체 및 이동

!!! "LSP와 tree-sitter 상호보완성"

    두 서비스(LSP와 tree-sitter)가 중복되는 것처럼 보일 수 있지만, 실제로는 LSP는 프로젝트 수준에서 작동하고 tree-sitter는 현재 열려 있는 소스 파일에만 작동하기 때문에 서로 보완적인 역할을 합니다.

IDE를 구축하기 위해 사용되는 기술에 대해 약간 설명했으니 이제 NvChad를 구성하기 위해 필요한 [추가 소프트웨어](additional_software.md)로 넘어갈 수 있습니다.
