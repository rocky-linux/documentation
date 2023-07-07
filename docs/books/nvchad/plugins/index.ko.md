---
title: 개요
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - plugins
  - editor
---

# 개요

## 소개

NvChad 개발자가 만든 사용자 정의 구성을 사용하면 그래픽 IDE의 많은 기능과 통합된 환경을 가질 수 있습니다. 이러한 기능은 플러그인을 통해 Neovim 구성에 내장되어 있습니다. 개발자가 NvChad용으로 선택한 항목에는 일반적인 사용을 위해 편집기를 설정하는 기능이 있습니다.

그러나 Neovim용 플러그인 생태계는 훨씬 더 광범위하며 사용을 통해 편집기를 확장하여 자신의 필요에 집중할 수 있습니다.

이 섹션에서 다루는 시나리오는 Rocky Linux용 문서 작성이므로 Markdown 코드 작성, Git 리포지토리 관리 및 목적과 관련된 기타 작업을 위한 플러그인에 대해 설명합니다.

## 요구 사항

- NvChad가 "*template chadrc*"로 시스템에 제대로 설치됨
- 커맨드 라인에 익숙하다.
- 인터넷 연결 활성화

## 플러그인에 대한 일반적인 팁

NvChad를 설치하는 동안 [template chadrc](../template_chadrc.md)도 설치하도록 선택한 경우 구성에 **~/.config/nvim/lua/custom/**폴더가 있습니다. 플러그인에 대한 모든 변경 사항은 해당 폴더의 **/custom/plugins.lua** 파일에서 이루어져야 합니다. 플러그인에 추가 구성이 필요한 경우 **/custom/configs** 폴더에 배치됩니다.

NvChad 구성의 기반이 되는 Neovim은 자동 구성 업데이트 메커니즘을 실행 중인 편집기와 통합하지 않습니다. 이는 플러그인 파일이 수정될 때마다 `nvim`을 중지한 다음 플러그인의 전체 기능을 사용하려면 다시 열어야 함을 의미합니다.

플러그인 설치는 `lazy.nvim` 플러그인 관리자가 **plugins.lua**의 변경 사항을 추적하여 "live" 설치를 허용하므로 파일에 배치된 직후에 수행할 수 있습니다.

![plugins.lua](./images/plugins_lua.png)
