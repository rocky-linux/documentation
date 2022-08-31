---
title: Built-In Plugins
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.6, 9.0
tags:
    - nvchad
    - coding
    - plugins
---

# Basic configuration plugins

!!! note "Plugin Naming Convention"

    In this chapter, the format `user_github/plugin_name` will be used to identify the plugin. This is to avoid possible errors with similarly named plugins and to introduce the format that is used for plugin entry by both NvChad, and the `custom` configuration.

NvChad keeps the configuration of its plugins in the file `lua/plugins/init.lua`. We can see see an excerpt below:

```lua
vim.cmd "packadd packer.nvim"

local plugins = {

  ["nvim-lua/plenary.nvim"] = { module = "plenary" },
  ["wbthomason/packer.nvim"] = {},
  ["NvChad/extensions"] = { module = { "telescope", "nvchad" } },

  ["NvChad/base46"] = {
    config = function()
      local ok, base46 = pcall(require, "base46")

      if ok then
        base46.load_theme()
      end
    end,
  },
...
...
require("core.packer").run(plugins)
```

There's a huge amount of work by the NvChad developers that must be acknowledged. They have created an integrated environment among all plugins which makes the user interface clean and professional. In addition, plugins that work *under the hood* allow for enhanced editing and other features. All of this means that ordinary users can have, in an instant, a basic IDE to start working, and an extensible configuration that can adapt to their needs.  

## Main Plugins

The following is a brief analysis of the main plugins:

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) Provides a library of commonly used lua functions that are used by the other plugins, for example *telescope* and *gitsigns*.

- [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim) Provides the functionality for managing plugins. It allows for the management of all operations on plugins through convenient commands. The commands provided are:
  
  - `:PackerCompile`
  - `:PackerClean`
  - `:PackerInstall`
  - `:PackerUpdate`
  - `:PackerSync`
  - `:PackerLoad`

- [NvChad/extensions](https://github.com/NvChad/extensions) The core utilities of NvChad. Here we find:
  
  - the *nvchad* folder containing the utilities, *change_theme*, *reload_config*, *reload_theme*, *update_nvchad*.
  - the *telescope/extension* folder that provides the choice of theme directly from Telescope.

- [NvChad/base46](https://github.com/NvChad/base46) Provides themes for the interface.

- [NvChad/ui](https://github.com/NvChad/ui) Provides the actual interface. Thanks to this plugin we can have a *statusline* that gives us the information during editing and a *tabufline* that allows us to manage open buffers.

- [NvChad/nvterm](https://github.com/NvChad/nvterm) Provides a terminal to our IDE where we can issue commands. The terminal can be opened within the buffer in various ways:
  
  - `<ALT-h>` opens a terminal by dividing the buffer horizontally
  - `<ALT-v>` opens the terminal by dividing the buffer vertically
  - `<ALT-i>` opens a terminal in a floating tab 

- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) Adds icons (requires a Font Nerd) to file types and folders in our IDE. This allows us to visually identify file types in our File Explorer by speeding up operations.

- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) Provides guides to better identify indentation in the document, allowing sub-routines and nested commands to be easily recognized.

- [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) Another plugin written by the developers of NvChad. It is specifically a high-performance highlighter.

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) Allows you to use the tree-sitter interface in Neovim, and provide some basic functionality, such as highlighting.

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) Provides decoration for *git* with reports for added, removed, and changed lines-reports that are also integrated into the *statusline*.

## LSP functionality

Now let's move on to the plugins that provide the functionality to integrate LSPs (Language Server Protocols) into our projects. This is definitely one of the best features provided by NvChad. Thanks to LSPs we can be in control of what we write in real time.

- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) Allows simplified management of LSP (Language Server) installation through a convenient graphical interface. Its use is described in the [dedicated page for LSPs](../custom/lsp.md). The commands provided are:
  
  - `:Mason`
  - `:MasonInstall`
  - `:MasonUninstall`
  - `:MasonUnistallAll`
  - `:MasonLog`

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) Provides the appropriate configurations for almost every language server available. It is a community collection, with the most relevant settings already set. The plugin takes care of receiving our configurations and putting them into the editor environment. It provides the commands:
  
  - `:LspInfo`
  - `:LspStart`
  - `:LspStop`
  - `:LspRestart`

## Lua Code

Following LSP, come all the plugins that provide functionality in writing and executing Lua code such as snippets, lsp commands, buffers etc. We will not go into detail on these, but they can be viewed in their respective projects on GitHub. 

The plugins are: 

- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) 
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) 
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) 
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) 
- [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua) 
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) 
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)

## Mixed Plugins

- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) Thanks to this plugin we have the functionality of automatic closing of parentheses and other characters. For example, by inserting a beginning parenthesis `(` completion will automatically insert the closing parenthesis `)` placing the cursor in the middle.

- [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim) Provides a home screen from which to access recent files, open the last session, find files, etc.

- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) Provides advanced functionality for code commenting.

## File Management

- [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) A File Explorer for Neovim that allows the most common operations on files (copy, paste, etc.), has an integration with Git, identifies files with different icons, and other features. Most importantly, it updates automatically (this is very useful when you work with Git repositories).
  
  ![Nvim Tree](../images/nvim_tree.png)

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) Provides advanced file search capabilities, is highly customizable, and for example, is used for selecting NvChad themes (command `:Telescope themes`).
  
  ![Telescope find_files](../images/telescope_find_files.png)

- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) Displays all possible autocompletions available for the entered partial command.
  
  ![Which Key](../images/which_key.png)

- [lewis6991/impatient.nvim](https://github.com/lewis6991/impatient.nvim) Performs several operations at the start of the editor to make the loading of modules faster.

Having introduced the plugins that make up the basic configuration of NvChad, we can move on to the description of the interface.
