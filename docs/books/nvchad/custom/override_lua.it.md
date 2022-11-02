---
title: override.lua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# `override.lua`

Il file `custom/override.lua` è usato per sovrascrivere le impostazioni dei plugin definiti in `chadrc.lua`, permette di installare vari *parser* all'avvio, estende le funzionalità di *nvimtree* e altre personalizzazioni.

Il file utilizzato per il nostro esempio è il seguente:

```lua
local M = {}

M.treesitter = {
  ensure_installed = {
    "html",
    "markdown",
    "yaml",
    "lua",
  },
}

M.nvimtree = {
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
  view = {
    side = "right",
  },
}

M.blankline = {
  filetype_exclude = {
    "help",
    "terminal",
    "alpha",
    "packer",
    "lspinfo",
    "TelescopePrompt",
    "TelescopeResults",
    "nvchad_cheatsheet",
    "lsp-installer",
    "",
  },
}

M.mason = {
  ensure_installed = {
    "lua-language-server",
    "marksman",
    "html-lsp",
    "yaml-language-server",
  },
}

return M
```

Esaminiamo l'intera configurazione. La prima parte controlla i parser *treesitter* definiti nella tabella e installa quelli mancanti. Nel nostro esempio, abbiamo aggiunto solo quelli utili per scrivere documenti in Markdown. Per un elenco completo dei parser disponibili, si può fare riferimento a [questa pagina](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages).

![Git NvimTree](../images/nvimtree_git.png){ align=right }

La seconda parte arricchisce il nostro file explorer (*nvimtree*) con decorazioni per lo stato dei file rispetto al repository *Git* , e sposta la vista a destra.

Poi abbiamo una sezione che si occupa di rimuovere le righe che indicano annidamento nel codice. Infine, una che si occupa di informare *Mason* su quali server linguistici sono necessari nell'IDE, richiamata dalla funzione `ensure_installed`.

Il controllo e l'eventuale installazione di *parser* e *LSP* è molto utile per gestire le proprie personalizzazioni su più postazioni. Salvando la cartella *custom* in un repository Git, si ha la possibilità di clonare le impostazioni personalizzate su qualsiasi macchina su cui è installato NvChad e le modifiche possono essere sincronizzate tra tutte le macchine su cui si lavora.

Riassumendo, il file `custom/override.lua` è usato per sovrascrivere parti della configurazione predefinita del plugin. Le personalizzazioni impostate in questo file vengono prese in considerazione *solo* se il plugin è definito in `custom/chadrc.lua` nella sezione *override* del plugin.

```lua
M.plugins = {
  user = require("custom.plugins"),
  override = {
    ["kyazdani42/nvim-tree.lua"] = override.nvimtree,
    ["nvim-treesitter/nvim-treesitter"] = override.treesitter,
    ["lukas-reineke/indent-blankline.nvim"] = override.blankline,
    ["williamboman/mason.nvim"] = override.mason,
...
```
