---
title: Install Neovim
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - nvchad
  - nvim
  - coding
---

## Introduction to Neovim

Neovim is one of the best code editors due of its speed, ease of customization, and configuration.

Neovim is a fork of the `Vim` editor. It was born in 2014, mainly due to the lack at the time of asynchronous job support in Vim. Written in the Lua language with the goal of modularizing the code to make it more manageable, Neovim was designed with the modern user in mind. As the official website states, "Neovim is built for users who want the best parts of Vim, and more".

The developers of Neovim chose Lua as it was perfect for embedding, using LuaJIT quickly, and with a simple, script-oriented syntax.

From version 0.5 Neovim includes Treesitter (a parser generator tool) and supports Language Server Protocol (LSP). This reduces the number of plugins needed to achieve advanced editing functions. It improves the performance of operations such as code completion and linting.

One of its strengths is its customization. All of its configuration is contained in a single file that can be distributed to various installations through version control systems (Git or other) so that they are always synchronized.

### Community of developers

Although Vim and Neovim are both open-source projects and hosted on GitHub, there is a significant difference between the modes of development. Neovim has a more open community development, while Vim's development is more tied to the choices of its creator. Neovim's user and developer base is quite small compared to Vim, but it is a continuously growing project.

### Key Features

- Performance: Very fast.
- Customizable: Wide ecosystem of plugins and themes
- Syntax highlighting: Integrated with Treesitter and LSP, but requires some configuration

As with Vim, Neovim requires a basic knowledge of its commands and options. You can get an overview of its features through the `:Tutor` command that invokes a file where you can read, and practice using it. Learning takes longer than a fully graphical IDE, but once you learn the shortcuts to the commands and the included features, you will proceed very smoothly in editing documents.

![Nvim Tutor](images/neovim_tutor.png)

## Neovim Installation

### Installation from EPEL

Before moving on to the installation of NvChad, we need to make sure that we have an installation of Neovim available. If it is not already installed, you can install it from the EPEL repository. The EPEL repository provides the minimum version required by NvChad (currently 0.7.2). In case you want to use a newer version, we recommend installation from precompiled package or from source

To install the Neovim release provided by EPEL, you'll need to install the repository itself if you have not done so already.

```bash
dnf install epel-release
```

Type the following command to install the application:

```bash
dnf install neovim
```

### Installation from Precompiled Package

Installation from the precompiled package allows the development versions of Neovim (0.8 and later) to be tested. The two versions (installations) can coexist on the same system since the version from the precompiled package remains confined entirely to the user level.

In order to use all the features of the new version, we still have to satisfy the dependencies required by Neovim, we have to provide _our_ `nvim` with the dependencies manually. The required packages can be installed with:

```bash
dnf install compat-lua-libs libtermkey libtree-sitter libvterm luajit luajit2.1-luv msgpack unibilium xsel
```

Next, we download the compressed archive for our architecture (linux64) from this address:

```text
https://github.com/neovim/neovim/releases
```

The file to be downloaded is `nvim-linux64.tar.gz`. To verify the integrity of the archive we also need to download the file `nvim-linux64.tar.gz.sha256sum`. Once downloaded we need to verify its integrity and unpack it somewhere in our `home directory`. The proposed solution is to unpack it in `~/.local/share/`. Assuming we downloaded it in _/home/user/downloads/_, we will need to run the following commands:

```bash
sha256sum -c /home/user/downloads/nvim-linux64.tar.gz.sha256sum
nvim-linux64.tar.gz: OK

tar xvzf /home/user/downloads/nvim-linux64.tar.gz
mv /home/user/downloads/nvim-linux64 ~/.local/share/nvim-linux64
```

All that remains at this point is to create a symbolic link in `~/.local/bin/` for our _nvim_.

```bash
cd ~/.local/bin/
ln -sf ~/.local/share/nvim-linux64/bin/nvim nvim
```

Now verify you have the correct version with the `nvim -v` command, which should now show:

```txt
nvim -v
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
```

### Installation from Source

Installing from precompiled package, as above, provides `nvim` only for the user who runs it. If you want to make Neovim available to all users of the system, you will have to do an installation from source. Compiling Neovim is not particularly difficult and consists of the following steps.

We first install the packages required for compilation:

```bash
dnf install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git
```

Once we have installed the necessary packages we need to create a folder to build neovim from and change into it:

The Neovim clone, by default, is synchronized with the Neovim development branch (at the time of this writing, version 8.0). To compile the stable version we will have to switch to the corresponding branch before cloning with:

```bash
mkdir ~/lab/build
cd ~/lab/build
```

Now clone the repository:

```bash
git clone https://github.com/neovim/neovim
```

Once the operation is finished, we will have a folder named _neovim_ containing all the necessary files. The next step is to checkout the stable branch, and then configure and compile the sources with the `make` command.


```bash
cd ~/lab/build/neovim/
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
```

We chose the `RelWithDebInfo` type because it provides not only optimizations, but also a useful debugging layer for later customizations. You could have also used the `Release` type if you want maximum performance.

The process takes care of configuring and compiling the files that are to be put into our system. These files are saved in `neovim/build`. To install them, we will use the _make install_ command:

```bash
make install
```

Because this command is going to modify the filesystem, it needs to be run as the superuser, either with `sudo`, or directly by the root user.

Once the installation is finished, we can verify that everything went well by checking the path to Neovim:

```
whereis nvim
nvim: /usr/local/bin/nvim
```

And verifying the version:

```bash
nvim --version
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
....
```

As you can see from the command excerpt above, an installation of the stable version was performed here. Both versions, stable and development, work perfectly with NvChad on Rocky Linux 9.

#### Uninstall

In case we need to remove the installation, for example to switch to another version, we will have to take ourselves back to the build folder and use the `target` cmake provided by Neovim itself. To perform the uninstallation, you need to execute the following command:

```bash
cmake --build build/ --target uninstall
```

This command also requires superuser privileges or to be run as a _root_ user.

Alternatively, you can use the manual method by removing the executable and libraries with:

```bash
rm /usr/local/bin/nvim
rm -r /usr/local/share/nvim/
```

Again, you need to execute these commands with superuser permissions.

## Neovim Basic

As you can see from the screenshot, a basic installation of Neovim provides an editor that cannot yet be compared to an IDE.

![Neovim Standard](images/nvim_standard.png)

Now that we have our basic editor, it is time to turn it into something more advanced thanks to the configuration provided by [NvChad](install_nvchad.md).
