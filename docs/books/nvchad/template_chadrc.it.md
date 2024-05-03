---
title: Esempio di configurazione
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Esempio di configurazione

!!! danger "Non più fornito"

    L'esempio di configurazione non viene più fornito durante l'installazione di NvChad; di conseguenza, questa pagina è obsoleta e verrà rimossa nella nuova versione della guida. Le istruzioni verranno aggiornate al più presto.

## :material-message-outline: Introduzione

La versione 2.0 di NvChad introduce la possibilità di creare una cartella ==custom== durante la fase di installazione. La sua creazione è il punto di partenza per personalizzare l'editor modificando i suoi file. Installato al bootstrap permette, al primo avvio, di avere un editor con le caratteristiche di base di un IDE, ma può essere incluso anche dopo l'installazione di NvChad.

L'aspetto più importante della sua installazione è la creazione delle strutture di base per l'inclusione di alcune funzionalità avanzate come i server linguistici, i linters e i formattatori. Queste strutture consentono di integrare le funzionalità necessarie con poche modifiche.

La cartella viene creata da un modello della repository di NvChad di GitHub: ([example-config](https://github.com/NvChad/example_config)).

## :material-monitor-arrow-down-variant: Installazione

=== "Installazione all'avvio"

    Per crearla durante l'installazione, rispondere "y" alla domanda che viene posta all'inizio dell'installazione:
    
    > Do you want to install example custom config? (y/N):
    
    Una risposta affermativa avvierà un processo che clonerà il contenuto della cartella *example-config* da GitHub in **~/.config/nvim/lua/custom/** e, una volta terminato, rimuoverà la cartella **.git** da essa.  
    Rimuovendola, la cartella può essere posta sotto un controllo di versione personale.
    
    La cartella è pronta e verrà utilizzata al successivo avvio di NvChad per inserire le configurazioni personalizzate nell'editor.

=== "Installazione dal repository"

    L'installazione della configurazione fornita da ==example-config== può essere fatta anche dopo l'installazione di NvChad, nel qual caso il repository è ugualmente utilizzato ma viene recuperato con un'operazione manuale.
    
    L'installazione standard senza ==example-config== crea comunque una cartella *custom* in cui salvare il file ==chadrc.lua== per le personalizzazioni dell'utente e deve essere cancellata o salvata in un ==backup== per consentire l'esecuzione del clone. Salvare quindi la configurazione esistente con:

    ```bash
    mv ~/.config/nvim/lua/custom/ ~/.config/nvim/lua/custom.bak
    ```


    E clonare il repository GitHub nella propria configurazione:

    ```bash
    git clone https://github.com/NvChad/example_config.git ~/.config/nvim/lua/custom
    ```


    Il comando copia l'intero contenuto dei repository trovati online nella cartella `~/.config/nvim/lua/custom/`, copiando la cartella nascosta `.git`, che è necessario cancellare manualmente per consentire il passaggio a un controllo di versione personale. Eseguire il comando per la sua rimozione:

    ```bash
    rm rf ~/.config/nvim/lua/custom/.git/
    ```


    La cartella è pronta e verrà utilizzata al successivo avvio di NvChad per inserire le configurazioni personalizzate nell'editor.

## :material-file-outline: Struttura

La struttura della cartella ==custom== consiste in diversi file di configurazione e in una cartella `configs` contenente i file delle opzioni dei plugin impostati in *plugins.lua*.

L'uso di file separati per le impostazioni dei plugin consente di avere un file *plugins.lua* molto più snello e di lavorare solo sul codice del plugin mentre lo si personalizza. Questo è anche il metodo consigliato per sviluppare i plugin che verranno aggiunti in seguito.

La struttrua creata è la seguente:

```text
custom/
├── chadrc.lua
├── configs
│   ├── conform.lua
│   ├── lspconfig.lua
│   └── overrides.lua
├── highlights.lua
├── init.lua
├── mappings.lua
├── plugins.lua
└── README.md

```

Come si può notare, la cartella contiene alcuni file con lo stesso nome, che si incontrano anche nella struttura di base di NvChad. Questi, ti consentono di integrare la configurazione e sovrascrivere le impostazioni di base dell'editor.

## :octicons-file-code-16: Analisi della struttura

Passiamo ora ad esaminarne i contenuti:

### :material-file-multiple-outline: File principali

#### :material-language-lua: chadrc.lua

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

Il file viene inserito nella configurazione di Neovim dalla funzione `load_config`, impostata nel file **~/.config/nvim/lua/core/utils.lua**. La funzione si occupa di caricare le impostazioni predefinite e, se presenti, anche quelle del file *chadrc.lua* nella cartella *custom*:

```lua
M.load_config = function()
  local config = require "core.default_config"
  local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]
...
```

La sua funzione è quella di inserire i file della cartella *custom* nella configurazione di NvChad, per poi utilizzarli insieme ai file predefiniti per avviare l'istanza di *Neovim*. I file vengono inseriti nell'albero della configurazione attraverso le funzioni `require`, come ad esempio:

```lua
require("custom.mappings")
```

La stringa **custom.mappings** indica il percorso relativo al file senza estensione rispetto al percorso predefinito, che in questo caso è **~/.config/nvim/lua/**. Il punto sostituisce la slash, in quanto questa è la convenzione nel codice scritto in Lua (nel linguaggio *lua* non esiste il concetto di *directory*).

In sintesi, possiamo dire che la chiamata descritta sopra inserisce le configurazioni scritte nel file `custom/mappings.lua` nella mappatura di NvChad, inserendo così le scorciatoie per richiamare i comandi per i plugin impostati in `custom/plugins.lua`.

Una sezione del file sovrascrive anche alcune impostazioni di configurazione dell'interfaccia utente di NvChad contenute in `core/default_config.lua`, in particolare la sezione **M.ui** che consente, ad esempio, di selezionare un tema chiaro o scuro.

Alla fine del file viene impostata la chiamata ==require== al file `custom/plugins.lua` corrispondente alla stringa:

```lua
M.plugins = "custom.plugins"
```

In questo modo, i plugin impostati in `custom/plugins.lua` vengono passati insieme a quelli che compongono la configurazione di NvChad a *lazy.nvim* per l'installazione e la loro gestione. In questo caso, l'inclusione non è nell'albero di Neovim. Si trova invece nella configurazione di *lazy.nvim*, in quanto questo plugin disabilita completamente la funzionalità correlata dell'editor con la chiamata `vim.go.loadplugins = false`.

#### :material-language-lua: init.lua

Questo file è usato per sovrascrivere su disco le impostazioni definite in `core/init.lua`, come l'indentazione o l'intervallo di scrittura della swap. Viene utilizzato anche per creare comandi automatici, come descritto nelle righe commentate del file. Un esempio potrebbe essere il seguente, in cui sono state inserite alcune impostazioni per la scrittura di documenti in Markdown:

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

Questo, tra l'altro, sostituisce la tabulazione a 2 spazi con una a 4 spazi, più adatta al codice Markdown.

#### :material-language-lua: plugins.lua

Questo file imposta i plugin da aggiungere a quelli presenti nella configurazione di base di NvChad. Le istruzioni per inserire i plugin sono spiegate in dettaglio nella pagina dedicata al [Gestore dei plugin](nvchad_ui/plugins_manager.md).

Il file *plugins.lua* creato dal file *example-config* ha nella prima parte una serie di personalizzazioni che sovrascrivono le opzioni di definizione dei plugin e le loro configurazioni predefinite. Questa parte del file non ha bisogno di essere modificata, in quanto gli sviluppatori hanno preparato dei file speciali per questo scopo, presenti nella cartella *config*.

Segue l'installazione di un plugin. Questo è stato creato come esempio, in modo da familiarizzare con il formato utilizzato da *lazy.nvim*.

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

È possibile inserire tutti i plugin aggiuntivi dopo questo plugin e prima dell'ultima parentesi. Esiste un intero ecosistema di plugin adatti a ogni scopo. È possibile visitare [Neovimcraft](https://neovimcraft.com/) per una prima panoramica.

#### :material-language-lua: mappings.lua

Questo file consente di inserire nell'albero della configurazione le mappature (scorciatoie da tastiera) necessarie per richiamare i comandi aggiuntivi del plugin.

Viene inoltre presentato un esempio di impostazione, in modo da poterne studiare il formato:

```lua
M.general = {
    n = {
        [";"] = { ":", "enter command mode", opts = { nowait = true } },
    },
}
```

Questa mappatura viene inserita per lo stato NORMAL `n =` il carattere ++";"++ una volta premuto sulla tastiera, riproduce il carattere ++"colon"++. Questo carattere è quello utilizzato per accedere alla modalità COMMAND. Inoltre, viene impostata l'opzione `nowait = true` per entrare immediatamente in questa modalità. In questo modo, su una tastiera con layout QWERTY statunitense, non sarà necessario utilizzare ++shift++ per accedere alla modalità COMMAND.

!!! Tip "Suggerimento"

    Per gli utenti con tastiere europee (come quella italiana), si consiglia di sostituire il carattere ++";"++ con ++","++.

#### :material-language-lua: highlights.lua

Il file viene utilizzato per personalizzare lo stile dell'editor. Le impostazioni inserite qui servono a modificare aspetti come lo stile dei caratteri (**bold**, *italic*), il colore di sfondo di un elemento, il colore di primo piano e così via.

### :material-folder-cog-outline: Cartella configs

Questa cartella contiene tutti i file di configurazione utilizzati nel file **custom/plugins.lua** che consentono di modificare le impostazioni predefinite dei plugin che si occupano dei server linguistici (*lspconfig*) e dei linter/formatter (*conform*), e per sovrascrivere le impostazioni di base di **treesitter**, **mason**, e **nvim-tree** (*override*).

```text
configs/
├── conform.lua
├── lspconfig.lua
└── overrides.lua
```

#### :material-language-lua: lspconfig.lua

Il file *lspconfig.lua* imposta i server linguistici locali che l'editor può utilizzare. Ciò consentirà di utilizzare funzioni avanzate per i file supportati, come il completamento automatico o gli snippet, per creare rapidamente parti di codice. Per aggiungere il nostro *lsp* alla configurazione, è sufficiente modificare la tabella (in *lua* quello che viene rappresentato qui sotto tra parentesi graffe è una tabella) preparata appositamente dagli sviluppatori di NvChad:

```lua
local servers = { "html", "cssls", "tsserver", "clangd" }
```

Come possiamo vedere, alcuni server sono già impostati di default. Per aggiungerne uno nuovo, inserirlo alla fine della tabella. I server disponibili si trovano all'indirizzo [pacchetti mason](https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md) e per le loro configurazioni si può fare riferimento a [configurazioni dei server lsp](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

Ad esempio, se vogliamo avere anche il supporto per il linguaggio `yaml`, possiamo aggiungerlo come nell'esempio seguente:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "yamlls" }
```

La modifica del file, tuttavia, non comporta l'installazione del relativo server linguistico. Questo, dev'essere installato separatamente con *Mason*. Il server linguistico che fornisce il supporto a *yaml* è [yaml-language-server](https://github.com/redhat-developer/yaml-language-server) che andrà installato con il comando `:MasonInstall yaml-language-server`. A questo punto avremo, ad esempio, il controllo del codice scritto nelle intestazioni (*frontmatter*) delle pagine di documentazione di Rocky Linux.

#### :material-language-lua: conform.lua

 Questo file configura alcune funzioni orientate al controllo e la formattazione del codice scritto. La modifica di questo file richiede maggiori ricerche per la configurazione rispetto al precedente. Una panoramica dei componenti disponibili si trova nella pagina [dei builtins](https://github.com/stevearc/conform.nvim/tree/master?tab=readme-ov-file#formatters).

Anche in questo caso è stata creata una tabella, la tabella ==formatters_by_ft==, dove inserire le personalizzazioni:

```lua
--type conform.options
local options = {
  lsp_fallback = true,

  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    sh = { "shfmt" },
  },
}
```

Come si può vedere, nella configurazione iniziale sono stati inclusi solo i formattatori standard. Ad esempio, si potrebbe aver bisogno di un formattatore per il linguaggio Markdown e in questo caso si potrebbe aggiungere, ad esempio, [Markdownlint](https://github.com/DavidAnson/markdownlint):

```lua
    markdown = { "markdownlint" },
```

Anche in questo caso, la configurazione richiede l'installazione del pacchetto corrispondente, che viene effettuata con *Mason*:

```text
:MasonInstall markdownlint
```

!!! Note "Nota"

    La configurazione di questo formattatore richiede anche la creazione di un file di configurazione nella cartella home, che non verrà trattato in questo documento.

#### :material-language-lua: overrides.lua

Il file *overrides.lua* contiene le modifiche da apportare alle impostazioni predefinite del plugin. I plugin a cui applicare le modifiche sono specificati nella sezione ==-- Override plugin definition options== del file `custom/plugins.lua` tramite l'opzione **opts** (ad esempio `opts = overrides.mason`).

Nella configurazione iniziale ci sono tre plugin che devono essere sovrascritti e sono *treesitter*, *mason* e *nvim-tree*. Tralasciando per il momento *nvim-tree*, ci concentreremo sui primi due che ci permettono di cambiare in modo significativo la nostra esperienza di editing.

*treesitter* è un parser di codice che si occupa della sua formattazione in modo interattivo. Ogni volta che viene salvato un file riconosciuto da *treesitter*, questo viene passato al parser, che restituisce un albero di codice indentato ed evidenziato in modo ottimale, rendendo più facile la lettura, l'interpretazione e la modifica del codice nell'editor.

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

Ora, seguendo l'esempio precedente, se vogliamo che il *frontmatter* delle nostre pagine di documentazione su Rocky Linux sia evidenziato correttamente, possiamo aggiungere il supporto per *yaml* nella tabella `ensure_installed` dopo l'ultimo parser impostato:

```text
    ...
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "yaml",
    ...
```

La prossima volta che si aprirà NvChad, verrà installato automaticamente anche il parser appena aggiunto.

Per avere il parser disponibile direttamente nell'istanza in esecuzione di NvChad possiamo sempre installarlo, anche senza aver modificato il file, con il comando:

```text
:TSInstall yaml
```

Di seguito nel file è riportata la parte relativa all'installazione dei server da parte di *Mason*. Tutti i server impostati in questa tabella vengono installati in un'unica operazione con il comando `:MasonInstallAll` (questo comando viene richiamato anche durante la creazione della cartella *custom*). La parte è la seguente:

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
        "prettier",
    },
}
```

Ancora una volta, seguendo l'esempio iniziale in cui abbiamo abilitato il supporto per *yaml* installando manualmente il server, possiamo assicurarci di averlo sempre installato aggiungendolo alla tabella:

```text
    ...
    "typescript-language-server",
    "deno",
    "prettier",

    -- yaml-language-server
    "yaml-language-server",
    ...
```

Sebbene questo aspetto possa essere marginale su un'istanza di esecuzione di NvChad, poiché possiamo sempre installare manualmente i server mancanti, si rivela molto utile durante il trasferimento della nostra configurazione da una macchina all'altra.

Ad esempio, supponiamo di aver configurato la nostra cartella `custom` e di volerla trasferire ad un'altra installazione di NvChad. Se si è configurato questo file, dopo aver copiato o clonato la cartella `custom` sarà sufficiente un `:MasonInstallAll` per avere tutti i server pronti all'uso anche sull'altra installazione.


La parte finale della configurazione, la sezione `M.nvimtree`, si occupa di configurare *nvim-tree* abilitando la funzionalità di visualizzazione dello stato dell'albero dei file relativo al repository git:

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

## :material-contain-end: Conclusione

L'introduzione in NvChad 2.0 della possibilità di creare una cartella `custom` durante la prima installazione è sicuramente un grande aiuto per tutti quegli utenti che si avvicinano a questo editor per la prima volta. Inoltre, offre anche un notevole risparmio di tempo per coloro che hanno già avuto a che fare con NvChad.

Grazie alla sua introduzione e all'uso di *Mason*, l'integrazione delle proprie funzionalità è semplice e veloce. Bastano poche modifiche e si è subito pronti a utilizzare l'IDE per scrivere del codice.
