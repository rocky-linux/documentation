---
title: Built-In Plugins
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
    - nvchad
    - coding
    - plugins
---

# Basic configuration plugins

!!! note "Plugin Naming Convention"

    In this chapter, the format `user_github/plugin_name` will be used to identify the plugin. This is to avoid possible errors with similarly named plugins and to introduce the format that is used for plugin entry by both NvChad, and the `custom` configuration.

Version 2.0 brings numerous new features. The new version adopts `lazy.nvim` as the plugin manager instead of `packer.nvim`, this involves making some changes for users of the previous version with a custom configuration (*custom* folder).

`lazy.nvim` enables convenient management of plugins through a unified interface and integrates a mechanism for synchronizing plugins across installations (*lazy-lock.json*).

NvChad keeps the configuration of its default plugins in the file *lua/plugins/init.lua*. And the additional configurations of the various plugins are contained in the */nvim/lua/plugins/configs* folder.

We can see an excerpt of the *init.lua* file below:

```lua
require "core"
-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {

  "nvim-lua/plenary.nvim",

  {
    "NvChad/base46",
    branch = "v2.0",
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false,
  },

  {
    "NvChad/nvterm",
    init = function()
      require("core.utils").load_mappings "nvterm"
    end,
    config = function(_, opts)
      require "base46.term"
      require("nvterm").setup(opts)
    end,
  },
...
...
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"
```

There's a huge amount of work by the NvChad developers that must be acknowledged. They have created an integrated environment among all plugins which makes the user interface clean and professional. In addition, plugins that work *under the hood* allow for enhanced editing and other features.

All of this means that ordinary users can have, in an instant, a basic IDE with which to start working, and an extensible configuration that can adapt to their needs.  

## Main Plugins

The following is a brief analysis of the main plugins:

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Provides a library of commonly used lua functions that are used by the other plugins, for example *telescope* and *gitsigns*.

- [NvChad/base46](https://github.com/NvChad/base46) - Provides themes for the interface.

- [NvChad/ui](https://github.com/NvChad/ui) - Provides the actual interface and the core utilities of NvChad. Thanks to this plugin we can have a *statusline* that gives us the information during editing and a *tabufline* that allows us to manage open buffers. This plugin also provides the utilities **NvChadUpdate** for updating it, **NvCheatsheet** for an overview of keyboard shortcuts, and **Nvdash** from which file operations can be performed.

- [NvChad/nvterm](https://github.com/NvChad/nvterm) - Provides a terminal to our IDE where we can issue commands. The terminal can be opened within the buffer in various ways:
  
- `<ALT-h>` opens a terminal by dividing the buffer horizontally
- `<ALT-v>` opens the terminal by dividing the buffer vertically
- `<ALT-i>` opens a terminal in a floating tab

- [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) - Another plugin written by the developers of NvChad. It is specifically a high-performance highlighter.

- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - Adds icons (requires one of the Nerd Fonts) to file types and folders in our IDE. This allows us to visually identify file types in our File Explorer, to speed up operations.

- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - Provides guides to better identify indentation in the document, allowing sub-routines and nested commands to be easily recognized.

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Allows you to use the tree-sitter interface in Neovim, and provide some basic functionality, such as highlighting.

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Provides decoration for *git* with reports for added, removed, and changed lines-reports that are also integrated into the *statusline*.

## LSP functionality

Now let's move on to the plugins that provide the functionality to integrate LSPs (Language Server Protocols) into our projects. This is definitely one of the best features provided by NvChad. Thanks to LSPs we can be in control of what we write in real time.

- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - Allows simplified management of LSP (Language Server) installation through a convenient graphical interface. The commands provided are:
  
- `:Mason`
- `:MasonInstall`
- `:MasonUninstall`
- `:MasonUnistallAll`
- `:MasonLog`

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Provides the appropriate configurations for almost every language server available. It is a community collection, with the most relevant settings already set. The plugin takes care of receiving our configurations and putting them into the editor environment.

It provides the following commands:
  
- `:LspInfo`
- `:LspStart`
- `:LspStop`
- `:LspRestart`

## Lua Code

Following LSP, come all the plugins that provide functionality in writing and executing Lua code such as snippets, lsp commands, buffers etc. We will not go into detail on these, but they can be viewed in their respective projects on GitHub.

The plugins are:

- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)

## Mixed Plugins

- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Thanks to this plugin we have the functionality of automatic closing of parentheses and other characters. For example, by inserting a beginning parenthesis `(` completion will automatically insert the closing parenthesis `)` placing the cursor in the middle.

- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) - Provides advanced functionality for code commenting.

## File Management

- [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) - A File Explorer for Neovim that allows the most common operations on files (copy, paste, etc.), has integration with Git, identifies files with different icons, and other features. Most importantly, it updates automatically (this is very useful when you work with Git repositories).
  
  ![Nvim Tree](../images/nvim_tree.png)

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Provides advanced file search capabilities, is highly customizable, and can also be (for example) used for selecting NvChad themes (command `:Telescope themes`).
  
  ![Telescope find_files](../images/telescope_find_files.png)

- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Displays all possible autocompletions available for the entered partial command.
  
  ![Which Key](../images/which_key.png)

Having introduced the plugins that make up the basic configuration of NvChad, we can move on to see how to manage them.
