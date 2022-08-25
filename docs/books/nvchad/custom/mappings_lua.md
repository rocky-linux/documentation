---
title: WIP - mappings.lua
tags:
    - nvchad
    - coding
    - editor
---

The *custom/mappings.lua* file allows us to set up custom commands, these allow to perform even non-editor tasks as well as greatly shortening the typing of full commands.

This is probably the most "personal" file of those contained in the `custom` folder in that everyone has their own set of commands and associated utilities to which they are accustomed. We will try to lay out the subject in a general way to give you the foundation on which to build your own mapping.

The interesting thing about mappings is that they can be inserted into the various working states of the editor (INSERT, NORMAL..) giving us a way to have even more granular customization of commands.

The states are denoted by the letters `n`, `v`, `i`, `t`. As can be seen these are corresponding to the various NORMAL, VISUAL, etc. Let us take the following example to introduce the configuration:

```lua
local M = {}

M.general = {
  i = {
    -- navigate within insert mode
    ["<C-l>"] = { "<Left>", "move left" },
    ["<C-r>"] = { "<Right>", "move right" },
    ["<C-d>"] = { "<Down>", "move down" },
    ["<C-u>"] = { "<Up>", "move up" },
  },
}

M.packer = {
  n = {
    ["<leader>ps"] = { "<cmd>PackerSync<cr>", "Packer Sync" },
    ["<leader>pS"] = { "<cmd>PackerStatus<cr>", "Packer Status" },
    ["<leader>pu"] = { "<cmd>PackerUpdate<cr>", "Packer Update" },
  },
}

M.telescope = {
  n = {
    ["<leader><leader>"] = { "<cmd> Telescope<CR>", "open telescope" },
    ["\\\\"] = { "<cmd> Telescope find_files<CR>", "file finder" },
    ["\\f"] = { "<cmd> Telescope live_grep<CR>", "telescope live grep" },
  },
}

M.git = {
   n = {
      ["<leader>lg"] = { "<cmd>LazyGit<CR>", "open lazygit" },
      ["<leader>gc"] = { "<cmd> Telescope git_commits<CR>", "git commits" },
      ["<leader>gs"] = { "<cmd> Telescope git_status<CR>", "git status" },
   },
}

return M
```

In this file the `M` variable initialized in the first line passes and collects all our mappings before being returned to the configuration from the last line, so everything we set in this file will be available in the editor in the form of keyboard shortcuts.

The first part `M.general` is an example of overriding the default settings, the new mapping replaces the default mapping for movement between rows in INSERT mode `i = {` with one that is easier to remember (and also more logical, the original shortcut <kbd>Ctrl</kbd> + <kbd>l</kbd> to move to the right is an example)  

In the second part we have the command mapping for plugin management with `:Packer` this time set for the NORMAL `n = {` state.

And in the final part of our example we have two sets of shortcuts both for the NORMAL `n = {` state, one concerning the opening of *Telescope* for searching files and some shortcuts for controlling and managing *Git repositories*,

As you can see this file allows you to manage the keyboard shortcuts of all NvChad/Neovim commands and also of its plugins allowing a much faster workflow.

This example is only meant to be an introduction to a level of customization that can be very high; to consult the standard mapping you can refer to [this file](https://github.com/NvChad/NvChad/blob/main/lua/core/mappings.lua), while for plugin-specific commands you must refer to the various projects.
