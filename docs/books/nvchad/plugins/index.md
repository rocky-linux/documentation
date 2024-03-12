---
title: Overview
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - plugins
  - editor
---

# Overview

!!! danger "Wrong instructions"

    With the release of version 2.5, the instructions on this page are no longer correct; its use is not recommended for new installations. For more information see [the main page of the guide](../index.md).

## Introduction

The custom configuration created by the developers of NvChad allows you to have an integrated environment with many of the features of a graphical IDE. These features are built into the Neovim configuration by means of plugins. Those selected for NvChad by the developers have the function of setting up the editor for general use.

However, the ecosystem of plugins for Neovim is much broader and through their use, allows you to extend the editor to focus on your own needs.

The scenario addressed in this section is the creation of documentation for Rocky Linux, so plugins for writing Markdown code, managing Git repositories, and other tasks that relate to the purpose will be explained.

## Requirements

- NvChad properly installed on the system with the "*template chadrc*"
- Familiarity with the command line
- An active internet connection

## General hints about plugins

If you chose during the installation of NvChad to also install the [template chadrc](../template_chadrc.md) you will have in your configuration a **~/.config/nvim/lua/custom/** folder. All changes for your plugins should be made in the **/custom/plugins.lua** file in that folder. In case the plugin needs additional configurations, these are placed in the **/custom/configs** folder.

Neovim, on which the configuration of NvChad is based, does not integrate an automatic configuration update mechanism with the running editor. This implies that each time the plugins file is modified, it is necessary to stop `nvim` and then reopen it to get the full functionality of the plugin.

Installation of the plugin can be performed immediately after it is placed in the file since the `lazy.nvim` plugins manager keeps track of the changes in **plugins.lua** and therefore allows its "live" installation.

![plugins.lua](./images/plugins_lua.png)
