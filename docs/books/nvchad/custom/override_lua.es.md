---
title: override.lua
author: Franco Colussi
contributors: Steven Spencer, Pedro Garcia
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# `override.lua`

El archivo `custom/override.lua` se utiliza para reemplazar la configuración de los plugins definidos en el archivo `chadrc.lua`, permite que se instalen varios *analizadores* al inicio, extiende la funcionalidad de *nvimtree* ademas de otras modificaciones.

El archivo utilizado para nuestro ejemplo es el siguiente:

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

Echemos un vistazo a toda la configuración. En la primera parte se comprueban los analizadores de *treesitter*> definidos en la tabla y se instala todo necesario. En nuestro ejemplo, sólo añadimos aquellos que son útiles para escribir documentos en Markdown. Puede consultar [esta página web](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages) para obtener una lista completa de los analizadores disponibles.

![NvimTree Git](../images/nvimtree_git.png){ align=right }

La segunda parte enriquece nuestro explorador de archivos (*nvimtree*) con decoraciones para el estado de los archivos con respecto al repositorio *Git*, y mueve la vista hacia la derecha.

Luego tenemos una sección que se encarga de eliminar las líneas que indican anidamiento en el código. Finalmente, se encarga de informar a *Mason* qué servidores de idioma son necesarios en el IDE, mediante la función `ensure_installed`.

El control e instalación eventual del *analizador* y de *LSP* es muy útil para gestionar las modificaciones en diferentes estaciones de trabajo. Al guardar la carpeta *custom* en un repositorio de Git, uno tiene la capacidad de clonar los ajustes personalizados en cualquier máquina en la que NvChad esté instalado, y cualquier cambio puede sincronizarse entre todas las máquinas en las que se está trabajando.

Resumir el archivo `custom/override.lua` se utiliza para reemplazar partes de la configuración predeterminada del plugin. Las personalizaciones establecidas en este archivo se tienen en cuenta *sólo* si el plugin está definido en el archivo `custom/chadrc.lua` en la sección *plugin override*.

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
