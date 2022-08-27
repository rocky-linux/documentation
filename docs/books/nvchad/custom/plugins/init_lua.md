---
title: WIP - init.lua
tags:
    - nvchad
    - coding
    - editor
---

# init.lua

The file `custom/plugins/init.lua` closes the NvChad configuration, it is the last *init.lua* that is read and inserts our additional plugins into the configuration. Its configuration consists of inserting the plugins in the format:

```lua
  ["github_username/plugin_name"] = {},
```

If the plugin does not need additional configurations, the configuration described above is sufficient, but if additional configurations are needed, they will be placed inside the curly brackets.

Let us then take our example file:

```lua
return {
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
	},
  ["kdheepak/lazygit.nvim"] = {},
  ['folke/which-key.nvim'] = { disable = false  },
}
```

In this configuration we have included only the two necessary plugins *nvim-lspconfig* and *which-key* plus one that requires no additional configuration as an example. The two plugins are necessary since without their configuration we will not have support for LSPs (language servers) even if they are installed and the functionality of *which-key* since it is disabled by default.

As we can see, the first plugin calls the configuration function and reads first the file `nvim/lua/plugins/configs/lspconfig.lua` and then our file `nvim/lua/custom/plugins/lspconfig.lua`. In this case an additional file is used for personal configurations, the choice depends on the amount of changes to be made.

The second is an example of a plugin that needs no additional configuration allows once installed to access Git repository management directly from the editor with the command `:LazyGit`. For the installation of LazyGit you can refer to the [Additional Software](../../additional_software.md) page.

The third is an example of putting configurations to be overwritten directly into the file, in this case the only change is the reactivation of the default disabled plugin. This plugin is enclosed by two single quotes that can replace double quotes; the two notations are equivalent.

Once you have finished configuring the file and related configuration files, to activate the new plugins, it is recommended that you exit the editor, re-enter and perform a `:PackerSync`

In short we can say that this file is the engine of all our personal plugins, this is where most of the additional functionality of our IDE are configured.
