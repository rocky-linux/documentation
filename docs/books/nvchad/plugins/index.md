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

## :material-message-outline: Introduction

The custom configuration created by the developers of NvChad allows you to have an integrated environment with many of the features of a graphical IDE. These features are built into the Neovim configuration by means of plugins. Those selected for NvChad by the developers have the function of setting up the editor for general use.

However, the ecosystem of plugins for Neovim is much broader and through their use, allows you to extend the editor to focus on your own needs.

The scenario addressed in this section is the creation of documentation for Rocky Linux, so plugins for writing Markdown code, managing Git repositories, and other tasks that relate to the purpose will be explained.

### :material-arrow-bottom-right-bold-outline: Requirements

- NvChad properly installed on the system
- Familiarity with the command line
- An active internet connection

### :material-comment-processing-outline: General hints about plugins

The configuration of NvChad involves inserting user plugins from the `lua/plugins` folder, inside it is initially the **init.lua** file with the installation of the *conform.nvim* plugin and some examples for customizing the functionality of the system ones.  
Although you can put your own plugins in the file it is advisable to use separate files for user configurations, this way you can use the initial file for any overrides of the basic plugins while you can organize your plugins in independent files according to your preferences.

### :material-location-enter: Inserting plugins

The `plugins` folder is queried by the configuration and all *.lua* files in it are loaded, this allows for multiple configuration files that will be merged when loading from the editor.  
To be properly inserted, the additional files must have the plugins' configurations enclosed within ==lua tables==:

```lua title="lua table example"
return {
    { -- lua table
    -- your plugin here
    }, -- end lua table
}
```

A `configs` folder is also provided where particularly long settings of some plugins or user-modifiable parts such as in the case of *conform.nvim* can be entered.

Turning to a practical example suppose we want to include in the editor's functionality the [karb94/neoscroll.nvim](https://github.com/karb94/neoscroll.nvim) plugin, which allows for improved scrolling within very long files.  
For its creation we can choose to create a `plugins/editor.lua` file where we put all plugins related to the use of the editor or a `plugins/neoscroll.lua` file and keep all additional plugins separate.

In this example the first option will be followed, so let's create a file in the `plugins` folder:

```bash
touch ~/.config/nvim/lua/plugins/editor.lua
```

And following the information on the project page we insert the following block of code into it:

```lua title="editor.lua"
return {
{
	"karb94/neoscroll.nvim",
	keys = { "<C-d>", "<C-u>" },
	opts = { mappings = {
		"<C-u>",
		"<C-d>",
	} },
},
}
```

Once saved it will be recognized by the NvChad configuration, which will take care of its insertion by making use of the functionality offered by the *lazy.nvim* handler.

Neovim, on which the configuration of NvChad is based, does not integrate an automatic configuration update mechanism with the running editor. This implies that each time the plugins file is modified, it is necessary to stop `nvim` and then reopen it to get the full functionality of the plugin.

![plugins.lua](./images/plugins_lua.png)

## Conclusions and final thoughts

There is a large ecosystem of plugins for Neovim that can be integrated into NvChad, for their research one can use the support of the site [Dotfyle](https://dotfyle.com/) which provides information on plugins and configurations for Neovim or of [Neovimcraft](https://neovimcraft.com/) which focuses instead only on available plugins. Both provide excellent general information about plugins and links to the respective projects on GitHub.

The introduction of the new plugin search feature, which has been present since version 2.5, makes it possible to organize user plugins in a very efficient and highly configurable manner. In a complex configuration, it allows plugins that require special configurations (lua code or autocmds) to be managed separately, greatly simplifying their management.
