---
title: Вбудовані плагіни
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.8, 9.3
tags:
  - nvchad
  - coding
  - плагіни
---

# :material-folder-multiple-outline: Плагіни базової конфігурації

!!! note "Угода про іменування плагінів"

    У цій главі формат `user_github/plugin_name` використовуватиметься для ідентифікації плагіна. Це зроблено для того, щоб уникнути можливих помилок із плагінами з подібними назвами та запровадити формат, який використовується для введення плагінів як NvChad, так і `спеціальною` конфігурацією.

Основні плагіни NvChad знаходяться в папці `~/.local/share/nvim/lazy/NvChad/lua/nvchad/plugins/`:

```text title=".local/share/nvchad/lazy/NvChad/lua/nvchad/plugins/"
├── init.lua
└── ui.lua
```

і відповідні конфігурації в папці `~/.local/share/nvim/lazy/NvChad/lua/nvchad/configs/`:

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

У папці `plugins` знаходяться файли *init.lua* та *ui.lua*, перший стосується конфігурації плагінів, які пропонують додаткові функції для редактор (*telescope*, *gitsigns*, *tree-sitter* тощо), тоді як останній налаштовує зовнішній вигляд редактора (кольори, піктограми, файловий менеджер тощо).

## :material-download-circle-outline: Основні плагіни

Нижче наведено короткий аналіз основних плагінів:

=== "init.lua plugins"

    - [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) – надає бібліотеку поширених функцій lua, які використовуються іншими плагінами, наприклад *telescope* і *gitsigns*.

    - [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) Плагін форматування для Neovim, швидкий і розширюваний завдяки файлу `configs/conform.lua`, наданому конфігурацією користувача

    - [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) – дозволяє використовувати інтерфейс Treesitter у Neovim і надає деякі основні функціональність, наприклад підсвічування.

    - [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) – прикрашає *git* зі звітами для доданих, видалених і змінених рядків-звітів, які також інтегровані в *рядок стану*.

    - [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) – дозволяє спрощувати керування встановленням LSP (Language Server) через зручний графічний інтерфейс.

    - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) – надає відповідні конфігурації майже для кожного доступного мовного сервера. Це колекція спільноти з уже встановленими найбільш релевантними параметрами. Плагін піклується про отримання наших конфігурацій і розміщення їх у середовищі редактора.

    - [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) з відповідними джерелами, наданими плагінами:

        - [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
        - [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
        - [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
        - [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
        - [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
        - [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)

    - [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) – завдяки цьому плагіну ми маємо функцію автоматичного закриття дужок та інших символів. Наприклад, вставивши початкову дужку `(` завершення автоматично вставить закриваючу дужку `)`, розмістивши курсор посередині.

    - [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) – надає розширені функції для коментування коду.

    - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) – надає розширені можливості пошуку файлів, має широкі можливості налаштування та також може бути (для прикладу), який використовується для вибору тем NvChad (команда `:Telescope themes`).

    ![Telescope find_files](../images/telescope_find_files.png)

=== "ui.lua plugins"

    - [NvChad/base46](https://github.com/NvChad/base46) – надає теми для інтерфейсу.

    - [NvChad/ui](https://github.com/NvChad/ui) – надає фактичний інтерфейс і основні утиліти NvChad. Завдяки цьому плагіну ми можемо мати *рядок стану*, який надає нам інформацію під час редагування, і *рядок вкладок*, який дозволяє щоб керувати відкритими буферами. Цей плагін також містить утиліти **NvChadUpdate** для його оновлення, **NvCheatsheet** для огляду комбінацій клавіш і **Nvdash**, з якого можна виконувати операції з файлами.

    - [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) – ще один плагін, написаний розробниками NvChad. Це особливо високоефективний хайлайтер.

    - [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) – додає піктограми (потрібен один із Nerd Fonts) до типів файлів і папок до нашої IDE. Це дозволяє нам візуально ідентифікувати типи файлів у нашому Провіднику файлів, щоб пришвидшити операції.

    - [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) – надає вказівки для кращого визначення відступів у документі, дозволяючи суб - підпрограми та вкладені команди, які легко розпізнаються.

    - [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua) – Провідник файлів для Neovim, який дозволяє виконувати найпоширеніші операції з файлами (копіювати, вставити тощо), має інтеграцію з Git, ідентифікує файли з різними значками та іншими функціями. Найважливіше те, що він оновлюється автоматично (це дуже корисно, коли ви працюєте зі сховищами Git).

    ![Дерево Nvim](../images/nvim_tree.png)

    - [folke/which-key.nvim](https://github.com/folke/which-key.nvim) – відображає всі можливі автозаповнення, доступні для введеної часткової команди.

    ![Which Key](../images/which_key.png)

## Висновки та заключні думки

Розробники NvChad провели величезну роботу, яку слід відзначити. Вони створили інтегроване середовище серед усіх плагінів, що робить інтерфейс користувача чистим і професійним. Крім того, плагіни, які працюють *під капотом*, дозволяють розширене редагування та інші функції.

Це означає, що звичайні користувачі можуть миттєво отримати базову IDE, з якою можна почати роботу, і розширювану конфігурацію, яку можна адаптувати до їхніх потреб.
