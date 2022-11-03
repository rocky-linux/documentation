---
title: Server Lingua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# lspconfig.lua

Questo file di configurazione assegna le funzionalità definite in `nvim/lua/plugins/configs/lspconfig.lua` ai server linguistici installati con `Mason`. I server linguistici devono essere collocati nei server locali secondo questo formato:

```lua
local servers = { "html", "marksman", "yamlls"}
```

Come sottolineato in precedenza, non c'è bisogno di un supporto esplicito per Lua, in quanto è abilitato di default da NvChad; tuttavia, il _lua-language-server_ deve essere installato con _Mason_ per essere disponibile nell'IDE.

Diamo quindi un'occhiata al nostro file `lspconfig.lua`:

```lua
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "marksman", "yamlls"}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
```

Le prime due istruzioni importano le funzioni `on_attach` e `capabilities` dal file `lspconfig.lua` di NvChad. Segue la configurazione dei server linguistici per fornire le funzionalità. Infine, viene richiamata la routine che associa le caratteristiche ai LSP impostati.

Dopo la prima configurazione, è consigliabile uscire e rientrare nell'editor prima di eseguire <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd>. Le voci successive del server linguistico nella configurazione possono essere registrate con <kbd>SHIFT</kbd> + <kbd>:LspRestart</kbd> senza dover ricaricare la configurazione. La prossima volta che si apre un file supportato, verrà visualizzata un'icona in basso con l'LSP associato e il server linguistico utilizzato. Questo conferma che l'LSP funziona correttamente.

Riassumendo, il file `lspconfig.lua` configura le funzionalità dei server che installiamo. È un file che, dopo la prima configurazione, non avrà bisogno di molte modifiche, finché scriveremo la documentazione in Markdown. Per ulteriori informazioni sul **L**anguage **S**erver **P**rotocol è possibile consultare la [pagina dedicata](../lsp.md).
