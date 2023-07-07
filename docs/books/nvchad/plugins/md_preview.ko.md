---
title: 마크다운 프리뷰
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.2
tags:
  - nvchad
  - plugins
  - editor
---

# 마크다운 프리뷰

## 소개

Markdown 언어의 특징 중 하나는 기술 문서 작성에 널리 사용되는 변환 가능성입니다. 코드는 다양한 형식(HTML, PDF, 일반 텍스트 등) 으로 표시하기 위해 변환될 수 있으므로 다양한 시나리오에서 컨텐츠를 사용할 수 있습니다.

특히 Rocky Linux용으로 작성된 문서는 *python* 애플리케이션을 사용하여 `HTML`로 변환됩니다. 애플리케이션은 *markdown*으로 작성된 문서를 정적 HTML 페이지로 변환합니다.

Rocky Linux용 문서를 작성할 때 `HTML` 코드로 변환할 때 올바른 표시인지 확인하는 문제가 발생합니다.

이 기능을 편집기에 통합하기 위해 이 목적에 사용할 수 있는 두 가지 플러그인인 [toppair/peek.nvim](https://github.com/toppair/peek.nvim) 와 [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)가 이 페이지에 설명되어 있습니다. 이 두 가지 모두 *github 스타일*, 미리 보기에 사용할 브라우저 선택 및 편집기와 동기화된 스크롤을 지원합니다.

### Peek.nvim

[Peek](https://github.com/toppair/peek.nvim)는 작동을 위한 기본 보안 설정과 함께 [Deno](https://deno.com/manual) JavaScript, TypeScript 및 WebAssembly 런타임을 사용합니다. 기본적으로 Deno는 명시적으로 활성화하지 않는 한 파일, 네트워크 또는 환경 액세스를 허용하지 않습니다.

[Template Chadrc](../template_chadrc.md)도 설치한 경우 이 구성 요소는 기본적으로 설치되는 언어 서버 중 하나이므로 이미 사용할 수 있습니다. 아직 편집기에 없는 경우 `:MasonInstall deno` 명령으로 설치할 수 있습니다.

!!! !!!

    플러그인 설치를 진행하기 전에 언어 서버를 **반드시** 설치해야 합니다. 그렇지 않으면 설치에 실패하고 **/custom/plugins.lua**에서 코드를 제거해야 합니다. `Lazy`를 열고 <kbd>X</kbd>를 입력하여 구성 정리를 수행하십시오. 플러그인을 삭제한 다음 설치 절차를 반복합니다.

플러그인을 설치하려면 다음 코드 블록을 추가하여 **/custom/plugins.lua** 파일을 편집해야 합니다.

```lua
{
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    keys = {
        {
        "<leader>op",
            function()
            local peek = require("peek")
                if peek.is_open() then
            peek.close()
            else
            peek.open()
            end
        end,
        desc = "Peek (Markdown Preview)",
        },
},
    opts = { theme = "dark", app = "browser" },
},
```

파일을 저장했으면 `:Lazy` 명령으로 플러그인 관리자 인터페이스를 열어 설치를 수행할 수 있습니다. 플러그인 관리자는 이미 자동으로 인식하고 <kbd>I</kbd>를 입력하여 설치할 수 있습니다.

그러나 전체 기능을 사용하려면 NvChad(*nvim*)를 닫았다가 다시 열어야 합니다. 이는 편집기가 구성에 **Peek** 항목을 로드할 수 있도록 하기 위한 것입니다.

구성에는 키보드에서 <kbd>Space</kbd> + <kbd>o</kbd>로 변환되는 `<leader>op`를 활성화하는 명령과 <kbd>p</kbd>가 뒤따르는 명령이 이미 포함되어 있습니다.

![Peek](./images/peek_command.png)

다음 문자열도 있습니다.

```lua
opts = { theme = "dark", app = "browser" },
```

미리 보기의 밝은 테마 또는 어두운 테마에 대한 옵션과 표시에 사용할 방법을 전달할 수 있습니다.

이 구성에서는 "브라우저" 방법이 선택되어 시스템의 기본 브라우저에서 파일을 볼 수 있지만 플러그인은 "webview" 방법을 통해 [webview_deno](https://github.com/webview/webview_deno) 구성 요소를 통해 **Deno**만 사용하여 파일을 미리 볼 수 있습니다.

![Peek Webview](./images/peek_webview.png)

### Markdown-preview.nvim

[Markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)은 `node.js`(JavaScript)로 작성된 플러그인입니다. 개발자가 편집기에서 완벽하게 작동하는 미리 컴파일된 버전을 제공하므로 NvChad에 설치할 때 종속성이 필요하지 않습니다.

이 버전을 설치하려면 이 코드 블록을 **/custom/plugins.lua**에 추가해야 합니다.

```lua
{
    "iamcco/markdown-preview.nvim",
    cmd = {"MarkdownPreview", "MarkdownPreviewStop"},
    lazy = false,
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
        vim.g.mkdp_theme = 'dark'
    end
},
```

이전 플러그인과 마찬가지로 NvChad가 새 구성을 로드할 수 있도록 편집기를 닫았다가 다시 열어야 합니다. 다시 프로젝트 저장소의 [전용 섹션](https://github.com/iamcco/markdown-preview.nvim#markdownpreview-config)에 설명된 일부 사용자 지정 옵션을 플러그인에 전달할 수 있습니다.

그러나 옵션은 `lazy.nvim`의 구성, 특히 이 예에서 구성된 옵션에 맞게 수정되어야 합니다.

```lua
vim.g.mkdp_theme = 'dark'
```

프로젝트 사이트에 다음과 같이 설명된 옵션에 해당합니다.

```lua
let g:mkdp_theme = 'dark'
```

보시다시피 옵션을 설정하려면 옵션을 해석할 수 있도록 초기 부분을 수정해야 합니다. 또 다른 예를 들기 위해 다음과 같이 지정된 미리 보기에 사용할 브라우저를 선택할 수 있는 옵션을 사용하겠습니다.

```lua
let g:mkdp_browser = '/usr/bin/chromium-browser'
```

NvChad에서 이를 올바르게 해석하려면 `let g:`를 `vim.g.`로 교체하여 수정해야 합니다.


```lua
vim.g.mkdp_browser = '/usr/bin/chromium-browser'
```

이렇게 하면 다음에 NvChad를 열 때 시스템의 기본 브라우저에 관계없이 `chromium-browser`가 사용됩니다.

또한 구성은 각각 미리 보기를 열고 닫는 `:MarkdownPreview` 및 `:MarkdownPreviewStop` 명령을 제공합니다. 명령에 더 빠르게 액세스하려면 다음과 같이 명령을 **/custom/mapping.lua** 파일에 매핑할 수 있습니다.

```lua
-- binding for Markdown Preview
M.mdpreview = {
  n = {
    ["<leader>mp"] = { "<cmd> MarkdownPreview<CR>", "Open Preview"},
    ["<leader>mc"] = { "<cmd> MarkdownPreviewStop<CR>", "Close Preview"},
    },
}
```

이렇게 하면 <kbd>Enter</kbd> + <kbd>m</kbd>다음에 <kbd>p</kbd> 를 입력하여 마크다운 미리보기를 열고 <kbd>Enter</kbd> + <kbd>m</kbd> 다음에 <kbd>c</kbd> 조합으로 닫을 수 있습니다.

!!! 참고 사항

    플러그인은 `:MarkdownPreviewToggle` 명령도 제공하지만 이 문서를 작성하는 시점에는 제대로 작동하지 않는 것 같습니다. 호출하려고 하면 미리보기 테마가 변경되지 않지만 동일한 미리보기가 있는 새 브라우저 탭이 열립니다.

![마크다운 프리뷰](./images/markdown_preview_nvim.png)

## 결론 및 최종 생각

작성 중인 내용의 미리 보기는 이 편집기를 처음 사용하는 사용자와 Markdown 언어에 대한 심층 지식이 있는 사용자 모두에게 유용할 수 있습니다. 미리 보기를 통해 변환된 코드의 영향과 포함된 모든 오류를 평가할 수 있습니다.

어떤 플러그인을 사용할지 선택하는 것은 전적으로 주관적이며 두 가지를 모두 시도하여 자신에게 가장 적합한 플러그인을 평가하는 것이 좋습니다.

이러한 플러그인 중 하나를 사용하면 사용된 코드를 준수하는 Rocky Linux의 문서에 문서를 제공할 수 있으므로 문서 검토자의 작업을 완화할 수 있습니다.
