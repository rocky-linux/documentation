---
title: Example Config
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Example configuration

## :material-message-outline: Introduction

Version 2.0 of NvChad introduces the ability to create a ==custom== folder during the installation phase. Its creation is the starting point for customizing the editor by modifying its files. Installed at bootstrap it allows for an editor with the basic features of an IDE at first startup but can also be included after the installation of NvChad.

The most important aspect of its installation is the creation of the basic structures for the inclusion of some advanced features such as language servers, linters and formatters. These structures allow the necessary functionality to be integrated with little modification.

The folder is created from an example one on NvChad's GitHub repository: ([example-config](https://github.com/NvChad/example_config)).

## :material-monitor-arrow-down-variant: Installation

=== "Install at bootstrap"

    To create it during the installation, answer "y" to the question we are asked at the beginning of the installation:

    > Do you want to install example custom config? (y/N):

    An affirmative answer will start a process that will clone the contents of the *example-config* folder from GitHub into **~/.config/nvim/lua/custom/** and once finished, will remove the **.git** folder from it.  
    Removing it allows the folder to be placed under a personal version control.

    The folder is ready and will be used the next time NvChad is started to enter custom configurations into the editor.

=== "Install from repository"

    The configuration installation provided by ==example-config== can also be done after the installation of NvChad, in which case the repository is still used but is retrieved by a manual operation.

    The standard installation without ==example-config== still creates a *custom* folder where to save the ==chadrc.lua== file for user customizations and should be deleted or saved in a ==backup== to allow the clone to run. Then save the existing configuration with:

    ```bash
    mv ~/.config/nvim/lua/custom/ ~/.config/nvim/lua/custom.bak
    ```

    And clone the GitHub repository to your configuration:

    ```bash
    git clone https://github.com/NvChad/example_config.git ~/.config/nvim/lua/custom
    ```

    The command copies the entire repositories contents found online to the `~/.config/nvim/lua/custom/` folder, copying the hidden `.git` folder, which you must delete manually to allow the switch to a personal version control. For its deletion run the command:

    ```bash
    rm rf ~/.config/nvim/lua/custom/.git/
    ```

    The folder is ready and will be used the next time NvChad is started to enter custom configurations into the editor.

## :material-file-outline: Structure

The structure of the ==custom== folder consists of several configuration files and a `configs` folder containing the plugin option files set in *plugins.lua*.

Using separate files for plugin settings allows you to have a much more streamlined *plugins.lua* file, and to work only on the plugin code while customizing it. This is also the recommended method for developing plugins that you will be adding later.

The structure created is as follows:

```text
custom/
├── chadrc.lua
├── configs
│   ├── conform.lua
│   ├── lspconfig.lua
│   └── overrides.lua
├── highlights.lua
├── init.lua
├── mappings.lua
├── plugins.lua
└── README.md

```

As we can see, the folder contains some files with the same name, which are also encountered in the basic structure of NvChad. These files allow you to integrate the configuration and override the basic settings of the editor.

## :octicons-file-code-16: Structure Analysis

Let us now go on to examine its contents:

### :material-file-multiple-outline: Main Files

#### :material-language-lua: chadrc.lua

```lua
---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
```

The file is inserted into the Neovim configuration by the `load_config` function set in the file **~/.config/nvim/lua/core/utils.lua**. The function takes care of loading the default settings and, if present, also those of the *chadrc.lua* file in the *custom* folder:

```lua
M.load_config = function()
  local config = require "core.default_config"
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]
...
```

Its function is to insert files from the *custom* folder into the NvChad configuration, and then use them along with the default files to start the *Neovim* instance. The files are inserted into the configuration tree through `require' functions, such as:

```lua
require("custom.mappings")
```

The string **custom.mappings** indicates the relative path to the file without the extension as opposed to the default path, which in this case is **~/.config/nvim/lua/**. The dot replaces the slash since this is the convention in code written in Lua (in the *lua language* there is no concept of *directory*).

In summary, we can say that the call described above inserts the configurations written in the file `custom/mappings.lua` into the NvChad mapping, thus inserting shortcuts to invoke the commands for the plugins set in `custom/plugins.lua`.

A section in the file also overrides some of the NvChad user interface configuration settings contained in `core/default_config.lua`, specifically the **M.ui** section that allows, for example, to select a light or dark theme.

At the end of the file is set the ==require== call to the `custom/plugins.lua` file corresponding to the string:

```lua
M.plugins = "custom.plugins"
```

This way, plugins set in `custom/plugins.lua` are passed along with those that make up the NvChad configuration to *lazy.nvim* for installation and their management. In this case, inclusion is not in the Neovim tree. Instead, it is in the configuration of *lazy.nvim*, since this plugin completely disables the related editor functionality with the call `vim.go.loadplugins = false`.

#### :material-language-lua: init.lua

This file is used for overwriting settings defined in `core/init.lua`, such as indentation or swap write interval, to disk. It is also used to create auto-commands, as described in the commented lines in the file. An example might be the following in which some settings for writing documents in Markdown have been included:

```lua
--local autocmd = vim.api.nvim_create_autocmd

-- settings for Markdown
local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Auto resize panes when resizing nvim window
--autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
```

This, among other things, replaces the 2-space tabulation with 4-space tabulation more suitable for Markdown code.

#### :material-language-lua: plugins.lua

This file sets the plugins to be added to those in the basic NvChad configuration. Adding plugins is explained in detail on the page dedicated to [Plugins Manager](nvchad_ui/plugins_manager.md).

The *plugins.lua* file created by the *example-config* has in the first part a number of customizations that override the plugin definition options and default plugin configurations. This part of the file does not need to be modified by us as the developers have prepared special files for this purpose that are present in the *config* folder.

Installation of a plugin follows. This was created as an example so that you can become familiar with the format used by *lazy.nvim*.

```lua
  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
```

You can insert all additional plugins after this plugin and before the last parenthesis. There is a whole ecosystem of plugins suitable for every purpose. You can visit [Neovimcraft](https://neovimcraft.com/) for a first overview.

#### :material-language-lua: mappings.lua

This file is for the inclusion in the configuration tree of the mappings (keyboard shortcuts) needed to invoke additional plugin commands.

An example setting is also presented here so that its format can be studied:

```lua
M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
	},
}
```

This mapping is entered for the NORMAL state `n =` the character ++";"++ which when pressed on the keyboard plays the character ++colon++. This character is the character used to enter COMMAND mode. The option `nowait = true` is also set to enter that mode immediately. In this way on a keyboard with a US QWERTY layout, we will not need to use ++shift++ to enter COMMAND mode.

!!! Tip

    For users of European keyboards (such as Italian), it is recommended to substitute the character ++";"++ with ++","++.

#### :material-language-lua: highlights.lua

The file is used to customize the style of the editor. The settings written here are used to change aspects such as font style (**bold**,*italic*), background color of an element, foreground color and so on.

### :material-folder-cog-outline: Configs folder

This folder contains all configuration files used in the **custom/plugins.lua** file to change the default settings of the plugins that deal with language servers (*lspconfig*), linter/formatters (*conform*), and for overriding the basic settings of **treesitter**, **mason**, and **nvim-tree** (*override*).

```text
configs/
├── conform.lua
├── lspconfig.lua
└── overrides.lua
```

#### :material-language-lua: lspconfig.lua

The *lspconfig.lua* file sets the local language servers that the editor can use. This will allow advanced features for supported files, such as autocomplete or snippets, to create code pieces quickly. To add our *lsp* to the configuration, we simply edit the table (in *lua* what is represented below in curly brackets is a table) prepared especially by the NvChad developers:

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

As we can see some servers are already set up by default. To add a new one, enter it at the end of the table. The available servers can be found at [mason packages](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md) and for their configurations you can refer to [lsp server configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

For example if we also want to have support for the `yaml` language we can add it as in the following example:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

Changing the file, however, does not involve installing the related language server. This must be installed separately with *Mason*. The language server that provides support for *yaml* is [yaml-language-server](https://github.com/redhat-developer/yaml-language-server) which we will have to install with the command `:MasonInstall yaml-language-server`. At this point we will have, for example, control of the code written in the headers (*frontmatter*) of the Rocky Linux documentation pages.

#### :material-language-lua: conform.lua

 This file configures some features geared toward controlling and formatting written code. Editing this file requires more research for configuration than the previous one. An overview of the available components can be found on [the builtins page](https://github.com/stevearc/conform.nvim/tree/master?tab=readme-ov-file#formatters).

Again, a table was created, the ==formatters_by_ft== table, in which to enter customizations:

```lua
--type conform.options
local options = {
  lsp_fallback = true,

  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    sh = { "shfmt" },
  },
}
```

As you can see, only standard formatters were included in the initial configuration. You might, for example, need a formatter for the Markdown language, and in that case you could add, for example [Markdownlint](https://github.com/DavidAnson/markdownlint):

```lua
    markdown = { "markdownlint" },
```

Again, configuration requires installation of the corresponding package, which is done with *Mason*:

```text
:MasonInstall markdownlint
```

!!! Note

    Configuration of this formatter also requires the creation of a configuration file in your home folder, which will not be covered in this document.

#### :material-language-lua: overrides.lua

The *overrides.lua* file contains the changes to be made to the default plugin settings. The plugins to which the changes are to be applied are specified in the ==-- Override plugin definition options== section of the `custom/plugins.lua` file through the use of the **opts** option (e.g. `opts = overrides.mason`).

In the initial configuration there are three plugins marked as needing to be overridden and they are *treesitter*, *mason* and *nvim-tree*. Leaving out *nvim-tree* for the moment, we will focus on the first two that allow us to change our editing experience significantly.

*treesitter* is a code parser that takes care of its formatting in an interactive way. Whenever we save a file recognized by *treesitter*, it is passed to the parser, which returns an optimally indented and highlighted code tree, making it easier to read, interpret, and edit the code in the editor.

The part of the code that deals with this is as follows:

```lua
M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"c",
		"markdown",
		"markdown_inline",
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
}
```

Now following the example given earlier, if we want the *frontmatter* of our documentation pages on Rocky Linux to be highlighted correctly we can add support for *yaml* in the `ensure_installed` table after the last parser set:

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

The next time we open NvChad, the parser we just added will also be automatically installed.

To have the parser available directly in the running instance of NvChad we can always install it, even without having edited the file, with the command:

```text
:TSInstall yaml
```

Following in the file is the part regarding the installing servers by *Mason*. All servers set in this table are installed in one operation with the command `:MasonInstallAll` (this command is also invoked during the creation of the *custom* folder). The part is as follows:

```lua
M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"deno",
		"prettier",
	},
}
```

Again, following the initial example where we enabled support for *yaml* by manually installing the server, we can make sure we always have it installed by adding it to the table:

```text
    ...
    "typescript-language-server",
    "deno",
    "prettier",

    -- yaml-language-server
    "yaml-language-server",
    ...
```

Although this aspect may be marginal on a running instance of NvChad since we can always manually install the missing servers it turns out to be very useful during the transfer of our configuration from one machine to another.

For example, suppose we have configured our `custom` folder and want to transfer it to another installation of NvChad. If we have configured this file, after copying or cloning our `custom` folder a `:MasonInstallAll` will be sufficient to have all the servers ready to use on the other installation as well.


The final part of the configuration, the `M.nvimtree` section, takes care of configuring *nvim-tree* by enabling the functionality to display the state in the file tree concerning the git repository:

```lua
  git = {
    enable = true,
  },
```

their highlighting and corresponding icons:

```lua
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
```

## :material-contain-end: Conclusion

The introduction in NvChad 2.0 of the possibility to create a `custom` folder during the first installation is certainly a great help for all those users who are approaching this editor for the first time. It is also a considerable time-saver for those who have already dealt with NvChad.

Thanks to its introduction and the use of *Mason*, integrating your own functionality is straightforward and fast. It only takes a few changes and you are immediately ready to use the IDE to write code.
