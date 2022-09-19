---
title: Language Server
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# lspconfig.lua

This configuration file assigns the functionality defined in `nvim/lua/plugins/configs/lspconfig.lua` to the language servers we have installed with `Mason`. The language servers should be placed in the local servers according to this format:

```lua
local servers = { "html", "marksman", "yamlls"}
```

As pointed out earlier, there is no need to make explicit support for Lua as it is enabled by default by NvChad; however, the _lua-language-server_ must be installed with _Mason_ to be available in the IDE.

Let us then look at our `lspconfig.lua` file:

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

The first two instructions import the `on_attach` and `capabilities` features from NvChad's `lspconfig.lua` file. Following this comes the configuration of the language servers to provide the features. Finally, the routine that associates the features with the LSPs set up is called.

After the first configuration, it is advisable to exit and re-enter the editor before running <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd>. Subsequent language server entries to the configuration can be registered with <kbd>SHIFT</kbd> + <kbd>:LspRestart</kbd> without the need to reload the configuration. The next time a supported file is opened, it will bring up an icon at the bottom with associated LSP and language server used. This gives us confirmation that the LSP is running properly.

Summarizing, the `lspconfig.lua` file configures the functionality of the servers we install. It is a file that, after the first configuration, will not need much editing as long as we write documentation in Markdown. For more information on the **L**anguage **S**erver **P**rotocol you can consult the [dedicated page](../lsp.md).
