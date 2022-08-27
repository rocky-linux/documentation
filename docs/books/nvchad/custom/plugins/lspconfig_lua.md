---
title: WIP - lspconfig.lua
tags:
    - nvchad
    - coding
    - editor
---

# lspconfig.lua

This configuration file assigns the functionality defined in `nvim/lua/plugins/configs/lspconfig.lua` to the language servers we have installed with `Mason`, the language servers should be placed in the local servers according to this format:

```lua
local servers = { "html", "marksman", "yamlls"}
```

As pointed out earlier, there is no need to make explicit support for Lua as it is enabled by default by NvChad; however, the *lua-language-server* must be installed with *Mason* to be available in the IDE.

Let us then look at our *lspconfig.lua* file:

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

The first two instructions import the `on_attach` and `capabilities` features from NvChad's *lspconfig.lua* file, then follows the configuration of the language servers to which to provide the features, and finally the routine that associates the features with the LSPs set up.

At the first configuration it is advisable to exit and re-enter the editor before running `:PackerSync`, subsequent language server entries to the configuration can be registered with `:LspRestart` without the need to reload the configuration. The next time a supported file is opened it will bring up an icon at the bottom with associated LSP and language server used, this gives us confirmation that the LSP is running properly.

Summarizing the *lspconfig.lua* file configures the functionality of the servers we install, it is a file that after the first configuration will not need much editing as long as we write documentation in Markdown. For more information on the **L**anguage **S**erver **P**rotocol you can consult the [dedicated page](../lsp.md).  




