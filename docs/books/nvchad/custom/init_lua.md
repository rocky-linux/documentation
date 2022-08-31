---
title: init.lua 
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.6, 9.0
tags:
    - nvchad
    - coding
    - editor
---

# `init.lua`

The `nvim/lua/custom/init.lua` file is used for overwriting the default NvChad options, defined in `lua/core/options.lua`, and setting its own options. It is also used for the execution of Auto-Commands.

Writing documents in Markdown does not require much modification. We are going to set some behaviors such as the number of spaces for tabbing, a setting that makes formatting Markdown files very smooth.

Our file will look like this:

```lua
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]
-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead

local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
```

In our example we used an auto-command for synchronous buffer formatting and options.

To summarize, the `init.lua` file in our `custom` folder is used for overwriting the default settings. This works because it is being read after the `core/init.lua` file, replacing all previous options with the new ones we have set.
