---
title: WIP -Custom Folder
tags:
    - nvchad
    - coding
---

## Advanced configuration of the Custom Folder

### Introduction

NvChad uses the version manager `git` for updates, this implies that at every update part or the whole configuration is overwritten by new commits, consequently it would be useless to make customizations within the default configuration. To solve this problem the NvChad developers have set up the possibility to make your changes in a folder called `custom` which must be mandatorily placed in `.config/nvim/lua/`. Below we have a representation of the basic structure of a standard NvChad installation 

```text
nvim/
├── examples
│   ├── chadrc.lua
│   └── init.lua
├── init.lua
├── LICENSE
├── lua
│   ├── core
│   └── plugins
└── plugin
    └── packer_compiled.lua
```

### Structure Creation

To start the customization we have to create for first the `custom` folder that will contain all our files, let's take the opportunity to also create the `plugins` folder that will contain the _configuration files_ of our plugins, since surely the folders will not be present we will use the `-p` flag to tell the _mkdir_ command to create the missing folders, the command will be as follows:

```bash
mkdir -p ~/.config/nvim/lua/custom/plugins
```

The structure of the `nvim/lua` folder should now look like this:

```text
├── lua
│   ├── core
│   ├── custom
│   │   └── plugins
│   └── plugins
```

The choice of path is not accidental but responds to the need to preserve this folder from updates, otherwise with each update the folder would simply be deleted as it is not part of the repository. The NvChad developers have prepared a `.gitignore` file for this, which determines its exclusion.

```bash
cat .config/nvim/.gitignore 
plugin
custom
spell
```

### Structure of the Custom Folder

The structure of the _custom_ folder used for this guide is as follows:

```text
custom/
├── chadrc.lua
├── init.lua
├── mappings.lua
├── override.lua
└── plugins
    ├── init.lua
    └── lspconfig.lua
```

We are going to analyze its contents and briefly describe the files it contains; the files will be analyzed in detail later on the pages dedicated to them.

- `chadrc.lua`: this file allows the override of default configurations. It also allows plugins to be overridden so that they can then be associated with _override.lua_ configurations. For example, it is used to save the interface theme with:

```lua
M.ui = {
  theme = "everforest",
}
```

- `init.lua`: this file is executed after the main `init.lua` file contained in `nvim/lua/core/` and allows the execution of personalized commands at NvChad startup.

- `mappings.lua`: allows the setting of custom commands, these commands are normally used to abbreviate standard commands. An example is the abbreviation of the command `:Telescope find_files` which with this setting in _mapping.lua_:

```lua
["\\\\"] = { "<cmd> Telescope find_files<CR>", "file finder" },
```

Allows you to retrieve **:Telescope find_files** by typing two `\\`

![Telescope Find Files](../images/telescope_find_files.png) 


- `override.lua`: this file contains the custom configurations that replace the default ones, this is possible thanks to the override effected upstream in _chadrc.lua_.

Let us now move on to the `plugins` folder, the folder contains all the configuration files of the various plugins installed and most importantly the `init.lua` file. In the `init.lua` file should be inserted the plugins we want to install on our IDE. Once inserted and configured, if necessary, they will be installable via the `:PackerSync` command.

The only plugin required is _neovim/nvim-lspconfig_, which enables LSP (language server) functionality for advanced editing.

### Other Plugins

The "Useful Plugins" section shows a few plugins and their configurations selected for the purpose of creating an IDE for writing documentation in Markdown but they may well be substituted by those of your preference.
