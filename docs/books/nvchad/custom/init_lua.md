---
title: WIP - init.lua
tags:
    - nvchad
    - coding
    - editor
---

# init.lua

The *nvim/lua/custom/init.lua* file is used for overwriting the default NvChad options defined in *lua/core/options.lua* and setting its own options. It is also used for the execution of Auto-Commands.

Writing documents in Makdown does not require much modification; we are going to set some behaviors such as the number of spaces for tabbing, a setting that makes formatting Markdown files very smooth.

Our file will look like this:

```lua
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
```

In our example we used an auto-command for synchronous buffer formatting and formatting options.

To summarize, the *init.lua* file is used for overwriting the default settings, this is because being read after the *core/init.lua* file replaces all previous options with the new ones we set.
