---
title: Chadrc Template
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Template Chadrc

Nella versione 2.0 di NvChad, gli sviluppatori hanno introdotto la possibilità di creare, durante la fase di installazione, una cartella `custom` in cui è possibile effettuare le proprie personalizzazioni. L'introduzione di questa funzione consente di avere un editor con le caratteristiche di base di un IDE fin dall'inizio.

L'aspetto più importante della creazione della cartella _custom_ è la scrittura dei file che contengono le configurazioni per l'impostazione di alcune funzioni avanzate, come i server linguistici, i linters e i formattatori. Questi file ci permettono di integrare, con poche modifiche, le funzionalità di cui abbiamo bisogno.

La cartella contiene anche i file per l'evidenziazione del codice e la mappatura dei comandi personalizzati.

La cartella viene creata a partire da un esempio presente sul repository GitHub di NvChad: ([example-config](https://github.com/NvChad/example_config)). Per crearlo durante l'installazione è sufficiente rispondere "y" alla domanda che ci viene posta all'inizio dell'installazione:

> Do you want to install chadrc template? (y/N) :

Una risposta affermativa avvierà un processo che clonerà il contenuto della cartella _example-config_ da GitHub in **~/.config/nvim/lua/custom/** e, una volta terminato, rimuoverà la cartella **.git** da essa. Questo ci permette di mettere la configurazione sotto il nostro controllo di versione.

Al termine avremo la seguente struttura:

```text
custom/
├── chadrc.lua
├── init.lua
├── plugins.lua
├── mappings.lua
├── highlights.lua
├── configs
│   ├── lspconfig.lua
│   ├── null-ls.lua
│   └── overrides.lua
└── README.md
```

Come si può vedere, la cartella contiene alcuni file con lo stesso nome che si trovano anche nella struttura di base di NvChad. Questi file consentono di integrare la configurazione e di sovrascrivere le impostazioni di base dell'editor.

## Analisi della struttura

Passiamo ora ad esaminarne il contenuto:

### File principali

#### chadrc.lua

```lua
---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
```

Il file viene inserito nella configurazione di Neovim dalla funzione `load_config` impostata nel file **~/.config/nvim/lua/core/utils.lua**, una funzione che si occupa di caricare le impostazioni predefinite e, se presenti, anche quelle del nostro _chadrc.lua:_

```lua
M.load_config = function()
  local config = require "core.default_config"
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]
...
```

La sua funzione è quella di inserire i file della nostra cartella _custom_ nella configurazione di NvChad, per poi utilizzarli insieme ai file predefiniti per avviare l'istanza di _Neovim_. I file vengono inseriti nell'albero di configurazione attraverso funzioni `require` come:

```lua
require "custom.mappings"
```

La stringa **custom.mappings** indica il percorso relativo al file senza estensione rispetto al percorso predefinito, che in questo caso è **~/.config/nvim/lua/**. Il punto sostituisce la barra, poiché questa è la convenzione nel codice scritto in Lua (nel _linguaggio lua_ non esiste il concetto di _directory_).

In sintesi, possiamo dire che la chiamata descritta sopra inserisce le configurazioni scritte nel file **custom/mappings.lua** nella mappatura di NvChad, inserendo così le scorciatoie per richiamare i comandi dei nostri plugin.

Abbiamo poi una sezione che sovrascrive alcune impostazioni di configurazione dell'interfaccia utente di NvChad contenute in **~/.config/nvim/lua/core/default_config.lua**, in particolare la sezione `M.ui` che ci permette, ad esempio, di selezionare un tema chiaro o scuro.

E abbiamo anche l'inclusione dei nostri plugin definiti in **custom/plugins.lua** corrispondenti alla stringa:

```lua
M.plugins = "custom.plugins"
```

In questo modo i nostri plugin saranno passati insieme a quelli che compongono la configurazione di NvChad a _lazy.nvim_ per l'installazione e la gestione. L'inclusione in questo caso non è nell'albero di Neovim, ma piuttosto nella configurazione di _lazy.nvim_, poiché questo plugin disabilita completamente la funzionalità relativa dell'editor con la chiamata `vim.go.loadplugins = false`.

#### init.lua

Questo file è usato per sovrascrivere su disco le impostazioni definite in **~/.config/nvim/lua/core/init.lua**, come l'indentazione o l'intervallo di scrittura dello swap. Viene utilizzato anche per la creazione di comandi automatici, come descritto nelle righe commentate del file. Un esempio potrebbe essere il seguente, in cui sono state inserite alcune impostazioni per la scrittura di documenti in Markdown:

```lua
--local autocmd = vim.api.nvim_create_autocmd

-- settings for Markdown
local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Auto resize panes when resizing nvim window
--autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
```

In questo modo le nostre impostazioni sostituiranno quelle predefinite.

#### plugins.lua

Questo file, come si può intuire dal nome, è usato per aggiungere i nostri plugin a quelli presenti nella configurazione di base di NvChad. L'inserimento dei plugin è spiegato in dettaglio nella pagina dedicata al [Plugins Manager](nvchad_ui/plugins_manager.md).

Il file _plugins.lua_ creato dal _template chadrc_ ha nella prima parte una serie di personalizzazioni che sovrascrivono le opzioni di definizione dei plugin e le configurazioni predefinite dei plugin. Questa parte del file non deve essere modificata da noi, poiché gli sviluppatori hanno preparato dei file speciali a questo scopo, presenti nella cartella _config_.

Segue l'installazione di un plugin. Questo è un esempio per iniziare a familiarizzare con il formato usato da _lazy.nvim_, che differisce leggermente dal formato usato da _packer.nvim_, il gestore usato nella versione 1.0.

```lua
  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
```

Dopo questo plugin e prima dell'ultima parentesi possiamo inserire tutti i nostri plugin. Esiste un intero ecosistema di plugin adatti a ogni scopo. Per una prima panoramica è possibile visitare il sito [Neovimcraft](https://neovimcraft.com/).

#### mappings.lua

Questo file inserisce nell'albero di configurazione le mappature (scorciatoie da tastiera) che saranno necessarie per richiamare i comandi dei plugin che stiamo per aggiungere.

Viene inoltre presentato un esempio di impostazioni, in modo da poterne studiare il formato:

```lua
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}
```

Questa mappatura viene inserita per lo stato NORMAL `n =` il carattere <kbd>;</kbd> una volta premuto sulla tastiera, riproduce il carattere <kbd>:</kbd>. Questo carattere è quello utilizzato per accedere alla modalità COMMAND. L'opzione `nowait = true` è anche impostata per entrare immediatamente in questa modalità. In questo modo, su una tastiera con layout QWERTY statunitense, non sarà necessario utilizzare <kbd>MAIUSC</kbd> per accedere alla modalità COMMAND.

!!! Tip "Suggerimento"

    Per gli utenti di tastiere europee (come quella italiana), si consiglia di sostituire il carattere <kbd>;</kbd> con <kbd>,</kbd>.

#### highlights.lua

Il file viene utilizzato per personalizzare lo stile dell'editor. Le impostazioni scritte qui servono a modificare aspetti come lo stile dei caratteri (**bold**, _italic_), il colore di sfondo di un elemento, il colore di primo piano e così via.

### Cartella Configs

I file contenuti in questa cartella sono tutti file di configurazione usati nel file **custom/plugins.lua** per modificare le impostazioni predefinite dei plugin che si occupano dei server linguistici (_lspconfig_), linter/formatters (_null-ls_) e per sovrascrivere le impostazioni di base di **treesitter**, **mason** e **nvim-tree (**_override_).

```text
configs/
├── lspconfig.lua
├── null-ls.lua
└── overrides.lua
```

#### lspconfig.lua

Il file _lspconfig.lua_ imposta i server linguistici locali che l'editor può utilizzare. Ciò consentirà di utilizzare funzioni avanzate per i file supportati, come il completamento automatico o gli snippet, per la creazione rapida di parti di codice. Per aggiungere il nostro _lsp_ alla configurazione, basta modificare la tabella (in _lua_ ciò che è rappresentato qui sotto tra parentesi graffe è una tabella) preparata appositamente dagli sviluppatori di NvChad:

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

Come si può vedere, alcuni server sono già impostati di default. Per aggiungerne uno nuovo è sufficiente inserirlo alla fine della tabella. I server disponibili si trovano nei [pacchetti mason](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md) e per le loro configurazioni si può fare riferimento a [configurazioni dei server lsp](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

Per esempio, se vogliamo avere anche il supporto per il linguaggio `yaml`, possiamo aggiungerlo come nell'esempio seguente:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

La modifica del file, tuttavia, non comporta l'installazione del relativo server linguistico. Dovrà essere installato separatamente con _Mason_. Il server linguistico che fornisce il supporto per _yaml_ è [yaml-language-server](https://github.com/redhat-developer/yaml-language-server), da installare con il comando `:MasonInstall yaml-language-server`. A questo punto avremo, ad esempio, il controllo del codice scritto nelle intestazioni(_frontmatter_) delle pagine di documentazione di Rocky Linux.

#### null-ls.lua

Questo file si occupa di configurare alcune funzioni orientate al controllo e alla formattazione del codice scritto. La modifica di questo file richiede un po' più di ricerca per la configurazione rispetto al file precedente. Una panoramica dei componenti disponibili si trova nella [pagina dei builtins](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md).

Anche in questo caso è stata creata una tabella, la tabella delle `local sources`, in cui inserire le nostre personalizzazioni, come si può vedere qui sotto:

```lua
local sources = {

  -- webdev stuff
  b.formatting.deno_fmt,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } },
  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,
}
```

Come si può vedere, nella configurazione iniziale sono stati inclusi solo i formattatori, ma potremmo ad esempio aver bisogno di una diagnostica per il linguaggio Markdown e in tal caso potremmo aggiungere [Markdownlint](https://github.com/DavidAnson/markdownlint) in questo modo:

```lua
  -- diagnostic markdown
  b.diagnostics.markdownlint,
```

Anche in questo caso, la configurazione richiede l'installazione del relativo pacchetto, che installeremo sempre con _Mason_:

```text
:MasonInstall markdownlint
```

!!! Note "Nota"

    La configurazione di questo strumento di diagnostica richiede anche la creazione di un file di configurazione nella cartella principale, che non verrà trattato in questo documento.

#### overrides.lua

Il file _overrides.lua_ contiene le modifiche da apportare alle impostazioni predefinite del plugin. I plugin a cui applicare le modifiche sono specificati nella sezione `-- override plugin configs` del file **custom/plugins.lua** tramite l'opzione `opts` (ad esempio `opts = overrides.mason`).

Nella configurazione iniziale ci sono tre plugin che devono essere sovrascritti: _treesitter_, _mason_ e _nvim-tree_. Tralasciando per il momento _nvim-tree_, ci concentreremo sui primi due che ci permettono di cambiare in modo significativo la nostra esperienza di editing.

_treesitter_ è un parser di codice che si occupa della sua formattazione in modo interattivo. Ogni volta che salviamo un file riconosciuto da _treesitter_, questo viene passato al parser che restituisce un albero di codice ottimamente indentato ed evidenziato, in modo da facilitare la lettura, l'interpretazione e la modifica del codice nell'editor.

La parte del codice che si occupa di questo aspetto è la seguente:

```lua
M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}
```

Ora, seguendo l'esempio precedente, se vogliamo che il _frontmatter_ delle nostre pagine di documentazione su Rocky Linux sia evidenziato correttamente, possiamo aggiungere il supporto per _yaml_ nella tabella `ensure_installed` dopo l'ultimo parser impostato:

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

Ora, la prossima volta che si apre NvChad, anche il parser appena aggiunto verrà installato automaticamente.

Per avere il parser disponibile direttamente nell'istanza in esecuzione di NvChad possiamo sempre installarlo, anche senza aver modificato il file, con il comando:

```text
:TSInstall yaml
```

Proseguendo, il file contiene la parte relativa all'installazione dei server da parte di _Mason_. Tutti i server impostati in questa tabella vengono installati in un'unica operazione con il comando `:MasonInstallAll` (questo comando viene invocato anche durante la creazione della cartella _custom_ ). La parte è la seguente:

```lua
M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier"
  },
}
```

Ancora una volta, seguendo l'esempio iniziale in cui abbiamo abilitato il supporto per _yaml_ installando manualmente il server, possiamo assicurarci di averlo sempre installato aggiungendolo alla tabella:

```text
    ...
    "typescript-language-server",
    "deno",
    "prettier",

    -- yaml-language-server
    "yaml-language-server",
    ...
```

Sebbene questo aspetto possa essere marginale su un'istanza in esecuzione di NvChad, dato che possiamo sempre installare manualmente i server mancanti, si rivela molto utile durante il trasferimento della nostra configurazione da una macchina all'altra.

Ad esempio, supponiamo di aver configurato la nostra cartella `custom` con tutte le funzioni necessarie e di volerla trasferire a un'altra installazione di NvChad. Se abbiamo configurato questo file, dopo aver copiato o clonato la nostra cartella `custom` sarà sufficiente un `:MasonInstallAll` per avere tutti i server pronti all'uso anche sull'altra installazione.

La parte finale della configurazione, la sezione `M.nvimtree`, si occupa di configurare _nvim-tree_ abilitando la funzionalità di visualizzazione dello stato dell'albero dei file rispetto al repository git:

```lua
  git = {
    enable = true,
  },
```

la loro evidenziazione e le icone corrispondenti:

```lua
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
```

## Conclusione

L'introduzione in NvChad 2.0 della possibilità di creare una cartella `custom` durante la prima installazione è sicuramente un grande aiuto per tutti gli utenti che si avvicinano a questo editor per la prima volta. È anche un notevole risparmio di tempo per chi ha già avuto a che fare con NvChad.

Grazie alla sua introduzione e all'uso di _Mason_, è molto facile e veloce integrare le proprie funzionalità. Bastano poche modifiche e si è subito pronti a usare l'IDE per scrivere codice.
