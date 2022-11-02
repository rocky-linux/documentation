---
title: chadrc.lua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvhad
  - coding
  - editor
---

# `chadrc.lua`

Il file `chadrc.lua` nella nostra cartella `custom` contiene informazioni su dove NvChad deve cercare ulteriori configurazioni e plugin personali.

È necessario prestare particolare attenzione alla gerarchia dei file, poiché potrebbero esserci più file con lo stesso nome (vedere *init.lua*) ma in posizioni diverse. La posizione determina l'ordine in cui i file vengono inclusi nella configurazione. L'ordine è `core` -&gt; `custom` -&gt; `plugins`.

Il contenuto del file `chadrc.lua` è il seguente:

```lua
local M = {}
local override = require("custom.override")

M.ui = {
    theme = "everforest",
    theme_toggle = { "everforest", "everforest_light" },
}

M.mappings = require("custom.mappings")

M.plugins = {
  user = require("custom.plugins"),
  override = {
    ["kyazdani42/nvim-tree.lua"] = override.nvimtree,
    ["nvim-treesitter/nvim-treesitter"] = override.treesitter,
    ["lukas-reineke/indent-blankline.nvim"] = override.blankline,
  },
}

return M
```

La prima chiamata che si incontra si riferisce all'inclusione del nostro file `custom/override.lua` contenente le impostazioni personalizzate per i plugin nella tabella degli *override* definita in `M.plugins`.

In particolare, le personalizzazioni si riferiscono allo stato dei file in un *repository* Git (se si lavora con uno di essi), all'installazione automatica dei *parser treesitter* e all'esclusione delle linee di riferimento di routine e comandi annidati. Questa funzionalità nella scrittura della documentazione in Markdown non è così importante.

Se si desidera avere anche questa funzionalità, è sufficiente rimuovere la riga:

```lua
["lukas-reineke/indent-blankline.nvim"] = override.blankline,
```

Ed eseguire un <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd> dalla modalità NORMAL nell'editor.

Segue la configurazione del tema predefinito con la sua variante chiara, seguita dalla chiamata `require` del file `custom/mapping.lua` che contiene i comandi personalizzati.

Infine, troviamo impostazioni che richiamano file di configurazione personali (contenuti in *custom/plugins*) che sostituiscono le impostazioni predefinite.

Quindi possiamo dire che il file `chadrc.lua` è il file che si occupa di alcuni aspetti dell'interfaccia utente e, soprattutto, dell'inclusione dei *nostri* file nella configurazione di NvChad.
