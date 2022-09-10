---
title: init.lua
author: Franco Colussi
contributors: Steven Spencer, Pedro Garcia
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# `init.lua`

El archivo `nvim/lua/custom/init.lua` se utiliza para sobrescribir las opciones de configuración por defecto de NvChad, que se encuentran definidas en el archivo `lua/core/options.lua` y establecer sus propias opciones. También se utiliza para la ejecución de Auto-Comandos.

La escritura de documentos en Markdown no requiere mucha modificación. Vamos a establecer algunos comportamientos como el número de espacios al tabular, una configuración que hace que el formato de los archivos Markdown sea más fluido y agradable.

Nuestro archivo se verá así:

```lua
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]
-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead

local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
```

En nuestro ejemplo hemos utilizado un auto-comando para el formateo síncrono del buffer y de las opciones.

Para resumir, el archivo `init.lua` que se encuentra en nuestra carpeta `custom` se utiliza para sobrescribir la configuración predeterminada. Esto funciona porque este fichero se lee después del archivo `core/init.lua`, reemplazando todas las opciones anteriores con las nuevas que hemos establecido.
