---
title: Chadrc Template
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Template Chadrc

In version 2.0 of NvChad, the developers introduced the ability to create, during the installation phase, a `custom` folder where you can make your own customizations. The introduction of this feature allows you to have an editor with the basic features of an IDE from the start.

The most important aspect of creating the _custom_ folder is writing the files that contain the configurations for setting up some advanced features such as language servers, linters, and formatters. These files allow us to integrate, with just a few changes, the functionality we need.

The folder also contains files for code highlighting and custom command mapping.

The folder is created from an example one on NvChad's GitHub repository: ([example-config](https://github.com/NvChad/example_config)). To create it during the installation, simply answer "y" to the question we are asked at the beginning of the installation:

> Do you want to install chadrc template? (y/N) :

An affirmative answer will start a process that will clone the contents of the _example-config_ folder from GitHub into **~/.config/nvim/lua/custom/** and once finished, will remove the **.git** folder from it. This is to allow us to put the configuration under our own version control.

Upon completion we will have the following structure:

```text
custom/
├── chadrc.lua
├── init.lua
├── plugins.lua
├── mappings.lua
├── highlights.lua
├── configs
│   ├── lspconfig.lua
│   ├── null-ls.lua
│   └── overrides.lua
└── README.md
```

As we can see, the folder contains some files with the same name also encountered in the basic structure of NvChad. These files allow you to integrate the configuration and override the basic settings of the editor.

## Structure Analysis

Let us now go on to examine its contents:

### Main Files

#### chadrc.lua

```lua
---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("custom.highlights")

M.ui = {
	theme = "onedark",
	theme_toggle = { "onedark", "one_light" },

	hl_override = highlights.override,
	hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require("custom.mappings")

return M
```

The file is inserted into the Neovim configuration by the `load_config` function set in the file **~/.config/nvim/lua/core/utils.lua**, a function that takes care of loading the default settings and, if present, also those of our _chadrc.lua_:

```lua
M.load_config = function()
  local config = require "core.default_config"
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]
...
```

Its function is to insert files from our _custom_ folder into the NvChad configuration to then be used along with the default files to start the _Neovim_ instance. The files are inserted into the configuration tree through `require` functions such as:

```lua
require("custom.mappings")
```

The string **custom.mappings** indicates the relative path to the file without the extension as opposed to the default path, which in this case is **~/.config/nvim/lua/**. The dot replaces the slash since this is the convention in code written in Lua (in the _lua language_ there is no concept of _directory_).

In summary, we can say that the call described above inserts the configurations written in the **custom/mappings.lua** file into the NvChad mapping thus inserting our shortcuts to invoke the commands of our plugins.

We then have a section that overrides some of the NvChad UI configuration settings contained in **~/.config/nvim/lua/core/default_config.lua**, more specifically the `M.ui` section that allows us, for example, to select a light or dark theme.

And we also have the inclusion of our plugins defined in **custom/plugins.lua** corresponding to the string:

```lua
M.plugins = "custom.plugins"
```

In this way our plugins will be passed along with those that make up the NvChad configuration to _lazy.nvim_ for installation and management. The inclusion in this case is not in the Neovim tree but rather in the configuration of _lazy.nvim_ since this plugin completely disables the relative functionality of the editor with the call `vim.go.loadplugins = false`.

#### init.lua

This file is used for overwriting settings defined in **~/.config/nvim/lua/core/init.lua**, such as indentation or swap write interval, to disk. It is also used for the creation of auto-commands, as described in the commented lines in the file. An example might be the following in which some settings for writing documents in Markdown have been included:

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

In this way our settings will replace the default settings.

#### plugins.lua

This file, as you can guess from the name, is used to add our plugins to those in the basic NvChad configuration. The insertion of plugins is explained in detail on the page dedicated to [Plugins Manager](nvchad_ui/plugins_manager.md).

The _plugins.lua_ file created by the _template chadrc_ has in the first part a number of customizations that override the plugin definition options and default plugin configurations. This part of the file does not need to be modified by us as the developers have prepared special files for this purpose that are present in the _config_ folder.

Then follows the installation of a plugin. This is set up as an example so that you can begin to become familiar with the format used by _lazy.nvim_ which differs slightly from the format used by _packer.nvim_, the handler used in version 1.0.

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

After this plugin and before the last bracket we can insert all our plugins. There is a whole ecosystem of plugins suitable for every purpose. For an initial overview you can visit [Neovimcraft](https://neovimcraft.com/).

#### mappings.lua

This file inserts into the configuration tree the mappings (keyboard shortcuts) that will be needed to invoke the commands of the plugins we are going to add.

An example setting is also presented here so that its format can be studied:

```lua
M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
	},
}
```

This mapping is entered for the NORMAL state `n =` the character ++;++ which when pressed on the keyboard plays the character ++:++. This character is the character used to enter COMMAND mode. The option `nowait = true` is also set to enter that mode immediately. In this way on a keyboard with a US QWERTY layout, we will not need to use ++SHIFT++ to enter COMMAND mode.

!!! Tip

    For users of European keyboards (such as Italian), it is recommended to substitute the character ++;++ with ++,++.

#### highlights.lua

The file is used to customize the style of the editor. The settings written here are used to change aspects such as font style (**bold**,_italic_), background color of an element, foreground color and so on.

### Configs folder

The files in this folder are all configuration files that are used in the **custom/plugins.lua** file to change the default settings of the plugins that deal with language servers (_lspconfig_), linter/formatters (_null-ls_), and for overriding the basic settings of **treesitter**, **mason**, and **nvim-tree** (_override_).

```text
configs/
├── lspconfig.lua
├── null-ls.lua
└── overrides.lua
```

#### lspconfig.lua

The _lspconfig.lua_ file sets the local language servers that the editor can use. This will allow for advanced features for supported files, such as autocomplete or snippets, for quick creation of pieces of code. To add our _lsp_ to the configuration, we simply edit the table (in _lua_ what is represented below in curly brackets is a table) prepared especially by the NvChad developers:

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

As we can see some servers are already set up by default. To add a new one simply enter it at the end of the table. The available servers can be found at [mason packages](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md) and for their configurations you can refer to [lsp server configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

For example if we also want to have support for the `yaml` language we can add it as in the following example:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

Changing the file, however, does not involve installing the related language server. This will have to be installed separately with _Mason_. The language server that provides support for _yaml_ is [yaml-language-server](https://github.com/redhat-developer/yaml-language-server) which we will have to install with the command `:MasonInstall yaml-language-server`. At this point we will have, for example, control of the code written in the headers (_frontmatter_) of the Rocky Linux documentation pages.

#### null-ls.lua

This file takes care of configuring some features geared toward control and formatting of written code. Editing this file requires a bit more research for configuration than the previous file. An overview of the available components can be found on [the builtins page](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md).

Again, a table has been set up, the `local sources` table, where we can enter our customizations which we can see below:

```lua
local sources = {

	-- webdev stuff
	b.formatting.deno_fmt,
	b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }),
	-- Lua
	b.formatting.stylua,

	-- cpp
	b.formatting.clang_format,
}
```

As we can see, in the initial configuration only formatters were included, but we might for example need a diagnostic for the Markdown language and in that case we could add [Markdownlint](https://github.com/DavidAnson/markdownlint) like this:

```lua
  -- diagnostic markdown
  b.diagnostics.markdownlint,
```

Again, the configuration needs the installation of the related package, which we are going to install always with _Mason_:

```text
:MasonInstall markdownlint
```

!!! Note

    Configuration of this diagnostic tool also requires the creation of a configuration file in your home folder, which will not be covered in this document.

#### overrides.lua

The _overrides.lua_ file contains the changes to be made to the default plugin settings. The plugins to which the changes are to be applied are specified in the `-- override plugin configs` section of the **custom/plugins.lua** file through the use of the `opts` option (e.g. `opts = overrides.mason`).

In the initial configuration there are three plugins marked as needing to be overridden and they are _treesitter_, _mason_ and _nvim-tree_. Leaving out _nvim-tree_ for the moment, we will focus on the first two that allow us to change our editing experience significantly.

_treesitter_ is a code parser that takes care of its formatting in an interactive way. Whenever we save a file recognized by _treesitter_ it is passed to the parser which returns an optimally indented and highlighted code tree, so it will be easier to read, interpret and edit the code in the editor.

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

Now following the example given earlier, if we want the _frontmatter_ of our documentation pages on Rocky Linux to be highlighted correctly we can add support for _yaml_ in the `ensure_installed` table after the last parser set:

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

Now the next time we open NvChad, the parser we just added will also be automatically installed.

To have the parser available directly in the running instance of NvChad we can always install it, even without having edited the file, with the command:

```text
:TSInstall yaml
```

Following in the file is the part regarding the installation of servers by _Mason_. All servers set in this table are installed in one operation with the command `:MasonInstallAll` (this command is also invoked during the creation of the _custom_ folder). The part is as follows:

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

Again, following the initial example where we enabled support for _yaml_ by manually installing the server, we can make sure we always have it installed by adding it to the table:

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

For example, suppose we have configured our `custom` folder with all the features we need and we want to transfer it to another installation of NvChad. If we have configured this file, after copying or cloning our `custom` folder a `:MasonInstallAll` will be sufficient to have all the servers ready to use on the other installation as well.

The final part of the configuration, the `M.nvimtree` section, takes care of configuring _nvim-tree_ by enabling the functionality to display the state in the file tree with respect to the git repository:

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

## Conclusion

The introduction in NvChad 2.0 of the possibility to create a `custom` folder during the first installation is certainly a great help for all those users who are approaching this editor for the first time. It is also a considerable time-saver for those who have already dealt with NvChad.

Thanks to its introduction, and along with the use of _Mason_, it is very easy and fast to integrate your own functionality. It only takes a few changes and you are immediately ready to use the IDE to write code.
