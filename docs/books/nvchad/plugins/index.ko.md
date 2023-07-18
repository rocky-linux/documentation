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

NvChad 개발자들이 만든 사용자 정의 구성을 사용하면 그래픽 IDE의 많은 기능을 갖춘 통합 환경을 구성할 수 있습니다. 이러한 기능은 플러그인을 통해 Neovim 구성에 내장되어 있습니다. NvChad 개발자들이 선택한 플러그인은 일반적인 사용을 위해 편집기를 설정하는 역할을 합니다.

하지만 Neovim을 위한 플러그인 생태계는 훨씬 더 다양하며, 이를 통해 편집기를 사용자의 개인적인 요구에 맞게 확장할 수 있습니다.

이 섹션에서 다루는 시나리오는 Rocky Linux의 문서 작성이므로, Markdown 코드 작성, Git 저장소 관리 및 해당 목적과 관련된 다른 작업을 위한 플러그인에 대해 설명될 것입니다.

## 요구 사항

- NvChad가 "*template chadrc*"로 시스템에 제대로 설치되어 있어야 함
- 커맨드 라인에 익숙해야 함
- 인터넷 연결 활성화

## 플러그인에 대한 일반적인 팁

NvChad를 설치하는 동안 [template chadrc](../template_chadrc.md)도 설치하도록 선택한 경우 구성에 **~/.config/nvim/lua/custom/**폴더가 있습니다. 플러그인에 대한 모든 변경 사항은 해당 폴더의 **/custom/plugins.lua** 파일에서 이루어져야 합니다. 플러그인에 추가 구성이 필요한 경우 **/custom/configs** 폴더에 배치됩니다.

NvChad 구성이 기반으로 하는 Neovim은 실행 중인 편집기와 자동 구성 업데이트 메커니즘을 통합하지 않습니다. 따라서 플러그인 파일이 수정될 때마다 `nvim`을 중지하고 다시 열어야 플러그인의 모든 기능을 사용할 수 있습니다.

플러그인의 설치는 파일에 배치된 즉시 수행될 수 있으며, `lazy.nvim` 플러그인 관리자는 **plugins.lua**의 변경 사항을 추적하기 때문에 "live"으로 설치가 가능합니다.

![plugins.lua](./images/plugins_lua.png)
