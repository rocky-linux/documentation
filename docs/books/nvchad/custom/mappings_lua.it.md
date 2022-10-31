---
title: mappings.lua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

Il file `custom/mappings.lua` consente di impostare comandi personalizzati. Questi comandi ci permettono di eseguire operazioni non legate all'editor e di abbreviare notevolmente la digitazione di comandi completi.

Questo è probabilmente il file più "personale" tra quelli contenuti nella cartella `custom`. Ognuno di noi ha una propria serie di comandi e utilità associate a cui è abituato. Cercheremo di esporre questo argomento in modo generale per darvi le basi su cui costruire la vostra mappatura.

La cosa interessante delle mappature è che possono essere inserite nei vari stati di lavoro dell'editor (INSERT, NORMAL...), consentendo una personalizzazione ancora più granulare dei comandi.

Gli stati sono indicati dalle lettere `n`, `v`, `i`, `t`. Questi corrispondono ai vari comandi dell'editor NORMAL, VISUAL, ecc. Prendiamo il seguente esempio per introdurre la configurazione:

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

In questo file, la variabile `M` inizializzata nella prima riga passa e raccoglie tutte le mappature prima di essere restituita alla configurazione dall'ultima riga. In questo modo, tutto ciò che abbiamo impostato in questo file sarà disponibile nell'editor sotto forma di scorciatoie da tastiera.

La prima parte `M.general` è un esempio di sovrascrittura delle impostazioni predefinite. La nuova mappatura sostituisce quella predefinita per lo spostamento tra le righe in modalità INSERT `i = {` con una più facile da ricordare e anche più logica. La scorciatoia originale <kbd>CTRL</kbd> + <kbd>l</kbd> per spostarsi a destra ne è un esempio.

Nella seconda parte abbiamo la mappatura dei comandi per la gestione dei plugin con `:Packer`, questa volta impostata per lo stato NORMAL `n = {`.


Nella parte finale del nostro esempio abbiamo due serie di scorciatoie, entrambe per lo stato NORMAL `n = {`; una riguarda l'apertura di *Telescope* per la ricerca dei file e alcune scorciatoie per il controllo e la gestione dei *repository Git*.

Come si può vedere, questo file permette di gestire le scorciatoie da tastiera di tutti i comandi e i plugin di NvChad/Neovim, consentendo un flusso di lavoro molto più veloce.

Questo esempio vuole essere solo un'introduzione al livello di personalizzazione che si può ottenere. Le personalizzazioni possono essere molto ampie. Per consultare la mappatura standard, si può fare riferimento a [questo file](https://github.com/NvChad/NvChad/blob/main/lua/core/mappings.lua). Per i comandi specifici dei plugin è necessario fare riferimento ai vari progetti.
