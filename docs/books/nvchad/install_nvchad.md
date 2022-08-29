---
title: Install NvChad
author: Fanco Colussi
contributors: Steven Spencer
tested with: 9.0
tags:
  - nvchad
  - coding
---

## Turning Neovim into an advanced IDE

This is actually not a real installation but rather writing a custom Neovim configuration into our user configuration.

!!! warning "Performing a Clean Installation"

    As specified in the requirements, installing this new configuration on top of a previous one can create unfixable problems. A clean installation is recommended.

### Preliminary Operations

If you have used the Neovim installation before, it will have created three folders in which to write your files, which are:

```text
~/.config/nvim
~/.local/share/nvim
~/.cache/nvim
```

To perform a clean installation of the configuration, we need to back up the previous one first:

```bash
mkdir ~/backup_nvim
cp -r ~/.config/nvim ~/backup_nvim
cp -r ~/.local/share/nvim ~/backup_nvim
cp -r ~/.cache/nvim ~/backup_nvim
```

And then we delete all previous configurations and files:

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
```

Now that we have cleaned up, we can move on to installing NvChad.

To do this, simply run the following command from any location within your _home directory_:

```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

The command runs a clone of the NvChad configuration hosted on GitHub in the user folder `~/.config/nvim`.

Once the cloning process is finished, the plugins that are part of the default configuration will be installed and configured and when finished, you will have the IDE ready for editing.

![NvChad Themes](images/nvchad_init.png)

As can be seen from the screenshot below, the editor, thanks to the configuration changes made, has completely changed in appearance from the basic version of Neovim. It should be remembered, however, that although the configuration of NvChad completely transforms the editor, the base is, and remains Neovim.

![NvChad Rockydocs](images/nvchad_ui.png)

### Configuration Structure

Let us now go on to analyze the structure that the configuration created, the structure is as follows:

```text
nvim/
├── examples
│   ├── chadrc.lua
│   └── init.lua
├── init.lua
├── LICENSE
├── lua
│   ├── core
│   │   ├── default_config.lua
│   │   ├── init.lua
│   │   ├── lazy_load.lua
│   │   ├── mappings.lua
│   │   ├── options.lua
│   │   ├── packer.lua
│   │   └── utils.lua
│   └── plugins
│       ├── configs
│       │   ├── alpha.lua
│       │   ├── cmp.lua
│       │   ├── lspconfig.lua
│       │   ├── mason.lua
│       │   ├── nvimtree.lua
│       │   ├── nvterm.lua
│       │   ├── others.lua
│       │   ├── telescope.lua
│       │   ├── treesitter.lua
│       │   └── whichkey.lua
│       └── init.lua
└── plugin
    └── packer_compiled.lua
```

!!! note "Note"

    For the moment we will leave out the contents of the `examples` folder as it relates to the `custom` configuration, which we will address in later sections.

The first file we encounter is the `init.lua` file which initializes the configuration by inserting into the _nvim_ tree the `lua/core`, `lua/plugins` and if present, the `lua/custom` folder. It also inserts the `lua/core/options.lua`, `lua/core/utils.lua`, and `lua/core/packer.lua` files. In particular, the `load_mappings` function is called for loading keyboard shortcuts and `bootstrap` for loading preconfigured plugins.

```lua
require "core"
require "core.options"

vim.defer_fn(function()
  require("core.utils").load_mappings()
end, 0)

-- setup packer + plugins
require("core.packer").bootstrap()
require "plugins"

pcall(require, "custom")
```

Inclusion of the `core` folder also results in the inclusion of the _core/init.lua_ file, which overrides some Neovim interface configurations and prepares for buffer management.

As we can see, each _init.lua_ file is included following a well-established order, and we can anticipate that the _init.lua_ file we are going to create in our customization will also be included in turn-last, of course. Broadly speaking, we can say that _init.lua_ files have the following functions:

- load global options, autocmds, or anything else.
- override the default options in _core/options.lua_.

Returning to the call for command mapping:

```lua
`require("core.utils").load_mappings()
```

This sets four main keys from which, in association with other keys, commands can be launched. The main keys are:

- C = CTRL
- leader = space
- A = ALT
- S = SHIFT

The default mapping is contained in _core/mapping.lua_ but can be extended with other custom commands using its own _mappings.lua_.

Some examples of the standard mapping are:

```text
<escape>uu to update NvChad
<escape>th to change the theme
<C-n> to open nvimtree
<A-i> to open a terminal in a floating tab
```

The combinations set are really many, and cover all the use of NvChad. It is worth pausing to analyze the mapping before starting to use it.

Continuing with the structure analysis we find the _lua/plugins_ folder, which contains the setup of the built-in plugins and their configurations. The main plugins in the configuration will be described in the next section. As we can see, the _core/plugins_ folder also contains an _init.lua_ file, which is used here for the installation and subsequent compilation of the plugins.

To close we find the _nvim/plugin_ folder that contains an autogenerated file of the compiled plugins.
