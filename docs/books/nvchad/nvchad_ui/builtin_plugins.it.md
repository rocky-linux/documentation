---
title: Plugin Integrati
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Plugins della configurazione di base

!!! note "Convenzione Nomenclatura Plugin"

    In questo capitolo, il formato `user_github/nome_plugin` sarà usato per identificare il plugin. Questo per evitare possibili errori con plugin dal nome simile e per introdurre il formato usato per l'inserimento dei plugin sia da NvChad che dalla configurazione `custom`.

La versione 2.0 introduce numerose novità. La nuova versione adotta `lazy.nvim` come gestore di plugin al posto di `packer.nvim`, questo comporta alcune modifiche per gli utenti della versione precedente con una configurazione personalizzata (_custom_ folder).

`lazy.nvim` consente una comoda gestione dei plugin attraverso un'interfaccia unificata e integra un meccanismo di sincronizzazione dei plugin tra le varie installazioni (_lazy-lock.json_).

NvChad memorizza la configurazione dei suoi plugin predefiniti nel file _lua/plugins/init.lua_. Le configurazioni aggiuntive dei vari plugin sono contenute nella cartella */nvim/lua/plugins/configs*.

Di seguito possiamo vedere un estratto del file *init.lua*:

```lua
require "core"
-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {

  "nvim-lua/plenary.nvim",

  {
    "NvChad/base46",
    branch = "v2.0",
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false,
  },

  {
    "NvChad/nvterm",
    init = function()
      require("core.utils").load_mappings "nvterm"
    end,
    config = function(_, opts)
      require "base46.term"
      require("nvterm").setup(opts)
    end,
  },
...
...
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"
```

Gli sviluppatori di NvChad hanno svolto un lavoro enorme che va riconosciuto. Hanno creato un ambiente integrato tra tutti i plugins che rende l'interfaccia utente pulita e professionale. Inoltre, i plugin che lavorano *sotto il cofano* consentono di migliorare l'editing e le altre funzioni.

Tutto ciò significa che gli utenti comuni possono disporre in un attimo di un IDE di base con cui iniziare a lavorare e di una configurazione estensibile che si adatta alle loro esigenze.

## Plugins Principali

Di seguito è riportata una breve analisi dei principali plugins:

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Fornisce una libreria di funzioni lua comunemente utilizzate dagli altri plugin, ad esempio *telescope* e *gitsigns*.

- [NvChad/base46](https://github.com/NvChad/base46) - Fornisce i temi per l'interfaccia.

- [NvChad/ui](https://github.com/NvChad/ui) - Fornisce l'interfaccia vera e propria e le utilità di base di NvChad. Grazie a questo plugin possiamo avere una *statusline* che ci dà le informazioni durante l'editing e una *tabufline* che ci permette di gestire i buffer aperti. Questo plugin fornisce anche le utilità **NvChadUpdate** per l'aggiornamento, **NvCheatsheet** per una panoramica delle scorciatoie da tastiera e **Nvdash** da cui è possibile eseguire operazioni sui file.

- [NvChad/nvterm](https://github.com/NvChad/nvterm) - Fornisce un terminale all'IDE, dove si possono impartire comandi. Il terminale può essere aperto all'interno del buffer in vari modi:

- `<ALT-h>` apre un terminale dividendo orizzontalmente il buffer
- `<ALT-v>` apre il terminale dividendo il buffer verticalmente
- `<ALT-i>` apre un terminale in una scheda fluttuante

- [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) - Un altro plugin scritto dagli sviluppatori di NvChad. Si tratta in particolare di un evidenziatore di codice ad alte prestazioni.

- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - Aggiunge icone (richiede uno dei Nerd Font) ai tipi di file e alle cartelle del nostro IDE. Questo ci permette di identificare visivamente i tipi di file nell'Esplora File, per velocizzare le operazioni.

- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - Fornisce delle guide per identificare meglio l'indentazione nel documento, permettendo di riconoscere facilmente le subroutine e i comandi annidati.

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Permette di utilizzare l'interfaccia tree-sitter in Neovim e di fornire alcune funzionalità di base, come l'evidenziazione.

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Fornisce una decorazione per *git* con rapporti per le linee aggiunte, rimosse e modificate, rapporti che sono anche integrati nella *statusline*.

## Funzionalità LSP

Ora passiamo ai plugin che forniscono la funzionalità per integrare i LSP (Language Server Protocols) nei nostri progetti. Questa è sicuramente una delle migliori caratteristiche fornite da NvChad. Grazie agli LSP possiamo avere il controllo di ciò che scriviamo in tempo reale.

- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - Consente una gestione semplificata dell'installazione di LSP (Language Server) attraverso una comoda interfaccia grafica. I comandi forniti sono:

- `:Mason`
- `:MasonInstall`
- `:MasonUninstall`
- `:MasonUnistallAll`
- `:MasonLog`

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Fornisce le configurazioni appropriate per quasi tutti i server linguistici disponibili. Si tratta di una raccolta comunitaria, con le impostazioni più importanti già impostate. Il plugin si occupa di ricevere le nostre configurazioni e di inserirle nell'ambiente dell'editor.

Fornisce i seguenti comandi:

- `:LspInfo`
- `:LspStart`
- `:LspStop`
- `:LspRestart`

## Codice Lua

Dopo LSP, vengono tutti i plugin che forniscono funzionalità per la scrittura e l'esecuzione di codice Lua, come snippet, comandi LSP, buffer e così via. Non entreremo nel dettaglio di questi, ma possono essere visualizzati nei rispettivi progetti su GitHub.

I plugin sono:

- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [snippet rafamadriz/friendly-](https://github.com/rafamadriz/friendly-snippets)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)

## Plugin Misti

- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Grazie a questo plugin abbiamo la funzionalità di chiusura automatica delle parentesi e di altri caratteri. Ad esempio, inserendo una parentesi iniziale `(` il completamento inserirà automaticamente la parentesi di chiusura `)` posizionando il cursore al centro.

- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) - Fornisce funzionalità avanzate per il commento del codice.

## Gestione File

- [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) - Un Esplora File per Neovim che consente le operazioni più comuni sui file (copia, incolla, ecc.), ha un'integrazione con Git, identifica i file con diverse icone e altre caratteristiche. Soprattutto, si aggiorna automaticamente (questo è molto utile quando si lavora con i repository Git).

  ![Nvim Tree](../images/nvim_tree.png)

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fornisce funzionalità avanzate di ricerca dei file, è altamente personalizzabile e può anche essere usato (ad esempio) per selezionare i temi di NvChad (comando `:Telescope themes`).

  ![Telescope find_files](../images/telescope_find_files.png)

- [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Visualizza tutti i possibili autocompletamenti disponibili per il comando parziale inserito.

  ![Which Key](../images/which_key.png)

Dopo aver introdotto i plugin che costituiscono la configurazione di base di NvChad, possiamo passare alla descrizione dell'interfaccia.
