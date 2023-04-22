---
title: Using vale in NvChad
author: Steven Spencer
contributors: Franco Colussi
tags:
  - vale
  - linters
---

# `vale` in NvChad (Neovim)

## Introduction

`vale.sh` is one of the foremost open source projects for technical writers looking to improve their voice and style consistency. It can be used with a number of editors on nearly every major OS platform (Linux, MacOS, Windows). You can find out more about the project by heading up to [the vale.sh website](https://vale.sh/). This guide is going to walk you through adding `vale` to NvChad. Since it is included in the Mason packages for install, the process is not too difficult, although it does involve some minor editing and configuration to get things going. To be clear, NvChad is really the configuration manager for the editor Neovim, so from this point forward, the reference will be `nvim`.

## Prerequisites

* Familiarity with NvChad 2.0 is helpful
* Ability to change files from the command line by using your favorite editor. (`vi` or your favorite)

## Installing `vale` using Mason

Installing `vale` from within NvChad using Mason, will allow for you to stay up-to-date with the package without a whole lot of extra steps. Running Mason periodically from within `nvim` will show you if there are updates that need to be installed and allow you to update them from there. This includes `vale` once it is installed. Let us start by running `nvim` to pull up an empty file and then get into the command mode by using <kbd>SHIFT</kbd>+<kbd>:</kbd>+Mason, which should show an interface similar to this one:

![vale_mason](images/vale_mason.png)

Rather than looking at the entire list of packages, let us use menu item 4 to limit the listing to linters. Press <kbd>4</kbd> and scroll down in the list until you find `vale` and with your cursor on that line, press <kbd>i</kbd> to install. Your listing should now show `vale` installed:

![vale_mason_installed](images/vale_mason_installed.png)

## Configuring and initializing `vale`

Just having `vale` installed isn't enough. You need a couple of additional things. First, you need a `.vale.ini` file that will live in your home directory eventually, but will be in the `~/.local/share/nvim/mason/packages/vale/` directory to start. The reason for putting this here first is that running the command that will create the styles directory will be easier if you can be in the same directory as the binary, rather than having to call the binary from the that long path in your home directory root. Creating this file is really easy if you use the configuration utility from [the `vale.sh` website](https://vale.sh/generator). Here, choose "Red Hat Documentation Style Guide" for the base style and "alex" for the supplementary style. Using "alex" is optional, but it does a good job of keeping your writing gender neutral, which is important. If you choose those options, your screen should look like this:

![vale_ini_nvchad](images/vale_ini_nvchad.png)

Simply copy the contents at the bottom, and create the `.vale.ini` file.

You need to create the "styles" folder. This is done by running the `vale` binary with the `sync` command. Again, we are doing this from the `~/.local/share/nvim/mason/packages/vale/` directory, so do:

```
./vale sync
```

This will show the following when done:

![vale_sync](images/vale_sync.png)

Copy the `.vale.ini` and the `styles` folder to the root of your home folder:

```
cp .vale.ini ~/
cp -rf styles ~/
```

If you prefer not to have to copy the files and just want to create them in your home directory, you can use this command from `~/`:

```
~/.local/share/nvim/mason/packages/vale/vale sync
```

## The `null-ls.lua` file changes

There is one final step needed. You need to change the `null-ls.lua` file found in `~/.config/nvim/lua/custom/configs/` and add the `vale` linter.

If you have no other linters installed, make a section with two dashes (comments) called "linters" then place this code there:

```
b.diagnostics.vale, sources = { null_ls.builtins.diagnostics.vale },
```

Your file will look something like this when completed:

![vale_null-ls](images/vale_null-ls.png)

## Conclusions and final thoughts

Starting `nvim` normally will now invoke `vale`, and your documents will now be compared against your preferred style. Opening an existing file will start `vale` and show you any flagged items, while starting a new file will not show you anything in insert mode. When you exit insert mode, your file will then be checked. This keeps the screen from being too cluttered. `vale` is an excellent open source product with great integration into many editors. NvChad is no exception, and while getting it up and running does take a few steps, it is not a difficult procedure.
