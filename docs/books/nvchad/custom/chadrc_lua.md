---
title: chadrc.lua
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.6, 9.0
tags:
    - nvhad
    - coding
    - editor
---

# `chadrc.lua`

The `chadrc.lua` file in our `custom` folder contains information about where NvChad should look for additional configurations and personal plugins.

Special attention must be paid to the file hierarchy, as there may be multiple files with the same name (see *init.lua*) but in different locations. The location is what determines the order in which the files are included in the configuration. That order is `core` -> `custom` -> `plugins`.

The contents of the `chadrc.lua` file are as follows:

```lua
local M = {}
local override = require("custom.override")

M.ui = {
    theme = "everforest",
    theme_toggle = { "everforest", "everforest_light" },
}

M.mappings = require("custom.mappings")

M.plugins = {
  user = require("custom.plugins"),
  override = {
    ["kyazdani42/nvim-tree.lua"] = override.nvimtree,
    ["nvim-treesitter/nvim-treesitter"] = override.treesitter,
    ["lukas-reineke/indent-blankline.nvim"] = override.blankline,
  },
}

return M
```

The first call you encounter refers to the inclusion of our `custom/override.lua` file containing the custom settings for the plugins in the *override* table defined in `M.plugins`. In particular, the customizations refer to the state of the files with respect to a Git *repository* (if you are working with one), the automatic installation of *treesitter parsers*, and the exclusion of the reference lines of nested routines and commands. This functionality in writing documentation in Markdown is not that important. If you want to have this functionality as well, just remove the line:

```lua
["lukas-reineke/indent-blankline.nvim"] = override.blankline,
```

And perform a <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd> from NORMAL mode in the editor.

Then follows the configuration of the default theme with its clear variant, followed by the `require` call of the `custom/mapping.lua` file that contains the custom commands.

Finally, we find settings that call up personal configuration files (contained in *custom/plugins*) that will replace the default settings.

So we can say that the `chadrc.lua` file is the file that takes care of some aspects of the UI, and more importantly, the inclusion of *our* files in the NvChad configuration.
