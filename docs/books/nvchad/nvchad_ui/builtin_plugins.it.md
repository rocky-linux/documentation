---
title: Plugin Integrati
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.8, 9.3
tags:
  - nvchad
  - coding
  - plugins
---

# :material-folder-multiple-outline: Plugins della configurazione di base

!!! note "Convenzione Nomenclatura Plugin"

    Questo capitolo identificherà il plugin usando il formato `user_github/nome_plugin`. Questo per evitare possibili errori con plugin dal nome simile e per introdurre il formato usato per l'inserimento dei plugin sia da NvChad che dalla configurazione `custom`.

I plugin di base di NvChad si trovano nella cartella `~/.local/share/nvim/lazy/NvChad/lua/nvchad/plugins/`:

```text title=".local/share/nvchad/lazy/NvChad/lua/nvchad/plugins/"
├── init.lua
└── ui.lua
```

e le rispettive configurazioni nella cartella `~/.local/share/nvim/lazy/NvChad/lua/nvchad/configs/`:

```text title=".local/share/nvchad/lazy/NvChad/lua/nvchad/configs/"
├── cmp.lua
├── gitsigns.lua
├── lazy_nvim.lua
├── lspconfig.lua
├── luasnip.lua
├── mason.lua
├── nvimtree.lua
├── telescope.lua
└── treesitter.lua
```

Nella cartella `plugins` sono presenti i file *init.lua* e *ui.lua*. Il primo si occupa della configurazione dei plugin che offrono funzionalità aggiuntive all'editor (*telescope*, *gitsigns*, *tree-sitter*, ecc.), mentre il secondo imposta l'aspetto dell'editor (colori, icone, file manager, ecc.).

## :material-download-circle-outline: Plugins Principali

Di seguito una breve analisi dei principali plugin:

=== "init.lua plugins"

    - [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Fornisce una libreria di funzioni lua comunemente utilizzate dagli altri plugin, ad esempio *telescope* e *gitsigns*.

    - [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) Plugin di formattazione per Neovim, veloce ed estensibile grazie al file `configs/conform.lua` fornito dalla configurazione utente

    - [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Permette di utilizzare l'interfaccia tree-sitter di Neovim e di fornire alcune funzionalità di base, come l'evidenziazione.

    - [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Fornisce una decorazione per *git* con rapporti per le linee aggiunte, rimosse e modificate, rapporti che sono anche integrati nella *statusline*.

    - [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - Consente una gestione semplificata dell'installazione di LSP (Language Server) attraverso una comoda interfaccia grafica.

    - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Fornisce le configurazioni appropriate per quasi tutti i server linguistici disponibili. Si tratta di una raccolta comunitaria, con le impostazioni più importanti già impostate. Il plugin si occupa di ricevere le nostre configurazioni e di inserirle nell'ambiente dell'editor.

    - [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) con i rispettivi sorgenti forniti dai plugin:

        - [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
        - [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
        - [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
        - [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
        - [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
        - [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)

    - [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Grazie a questo plugin abbiamo la funzionalità di chiusura automatica delle parentesi e di altri caratteri. Ad esempio, inserendo una parentesi iniziale `(` il completamento inserirà automaticamente la parentesi di chiusura `)` posizionando il cursore al centro.

    - [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) - Fornisce funzionalità avanzate per il commento del codice.

    - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Offre funzionalità avanzate di ricerca dei file, è altamente personalizzabile e può anche essere utilizzato (ad esempio) per selezionare i temi di NvChad (comando `:Telescope themes`).

    ![Telescope find_files](../images/telescope_find_files.png)

=== "ui.lua plugins"

    - [NvChad/base46](https://github.com/NvChad/base46) - Fornisce i temi per l'interfaccia.

    - [NvChad/ui](https://github.com/NvChad/ui) - Fornisce l'interfaccia attuale e le utilità di base di NvChad. Grazie a questo plugin possiamo avere una *statusline* che ci fornisce le informazioni durante la modifica e una *tabufline* che ci permette di gestire i buffer aperti. Questo plugin fornisce anche le utilità **NvChadUpdate** per l'aggiornamento, **NvCheatsheet** per una panoramica delle scorciatoie da tastiera e **Nvdash** da cui è possibile eseguire operazioni sui file.

    - [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) - Un altro plugin scritto dagli sviluppatori di NvChad. Si tratta in particolare di un evidenziatore di codice ad alte prestazioni.

    - [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - Aggiunge icone (richiede uno dei Nerd Font) ai tipi di file e alle cartelle del nostro IDE. Questo ci permette di identificare visivamente i tipi di file nell'Esplora File, per velocizzare le operazioni.

    - [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - Fornisce delle guide per identificare meglio l'indentazione nel documento, consentendo di riconoscere facilmente le subroutine e i comandi annidati.

    - [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) - Un Esplora file per Neovim che consente le operazioni più comuni sui file (copia, incolla, ecc.), ha un'integrazione con Git, identifica i file con diverse icone e altre funzioni. Soprattutto, si aggiorna automaticamente (cosa molto utile quando si lavora con i repository Git).

    ![Nvim Tree](../images/nvim_tree.png)

    - [folke/which-key.nvim](https://github.com/folke/which-key.nvim) - Visualizza tutti i possibili autocompletamenti disponibili per il comando parziale inserito.

    ![Which Key](../images/which_key.png)

## Conclusioni e considerazioni finali

Gli sviluppatori di NvChad hanno svolto un lavoro enorme che va riconosciuto. Hanno creato un ambiente integrato tra tutti i plugins che rende l'interfaccia utente pulita e professionale. Inoltre, i plugin che lavorano *sotto il cofano* consentono di migliorare l'editing e le altre funzioni.

Ciò significa che gli utenti comuni possono disporre immediatamente di un IDE di base con cui iniziare a lavorare e di una configurazione estensibile che può adattarsi alle loro esigenze.
