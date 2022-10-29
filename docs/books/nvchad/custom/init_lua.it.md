---
title: init.lua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# `init.lua`

Il file `nvim/lua/custom/init.lua` è usato per sovrascrivere le opzioni predefinite di NvChad, definite in `lua/core/options.lua`, e impostare le proprie opzioni. Viene utilizzato anche per l'esecuzione di Auto-Comandi.

Scrivere documenti in Markdown non richiede molte modifiche. Si tratta di impostare alcuni comportamenti come il numero di spazi per la tabulazione, un'impostazione che rende la formattazione dei file Markdown molto agevole.

Il nostro file avrà il seguente aspetto:

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

Nel nostro esempio abbiamo utilizzato un comando automatico per la formattazione sincrona del buffer e alcune opzioni.

Per riassumere, il file `init.lua` nella nostra cartella `custom` viene usato per sovrascrivere le impostazioni predefinite. Questo funziona perché viene letto dopo il file `core/init.lua` , sostituendo tutte le opzioni precedenti con quelle nuove che abbiamo impostato.
