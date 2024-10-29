---
title: Installing the Kitty terminal emulator 
author: Alex Zolotarov 
contributors: Steven Spencer
tested with: 9
---

## Introduction

**Kitty is a blazing fast terminal emulator on steroids**, anything you can possibly imagine is customizable in Kitty.
You can use tab management, tiling, image previews, and many more options, just within this terminal emulator.
You can even replace `tmux` or even a Window Manager with **Kitty** (if you work mostly within a terminal).

## Assumptions

- You have a Rocky Linux workstation or server with GUI
- You are an administration with `sudo` privileges

## Installing Kitty

**First, install the EPEL repository (Extra Packages for Enterprise Linux):**

```bash
dnf install -y epel-release
```

Next, install **Kitty**:

```bash
dnf install -y kitty
```

Once installed, you can start Kitty.

## Quick Overview

### Configuration file

Once you have started **Kitty** you can open Kitty configuration file with ++ctrl+shift+f2++.
You can also find the configuration file at `$HOME/.config/kitty`.

This document is not going to go deep into the configuration file itself. Just know that you can change any default shortcuts, or anything related to the appearance, in the configuration.

### Tabs

You can create a new tab with ++ctrl+shift+t++.

You can close a tab with ++ctrl+shift+w++ *or* ++ctrl+shift+q++.

You can select tabs with ++ctrl+shift+left++ *or* ++ctrl+shift+right++.

![kittytabs](./images/kitty_tabs.png)

### Tiling

Press ++ctrl+shift+enter++ to open a new pane or window.
You can press it many times to create a tiling layout.

You can switch layouts with ++ctrl+shift+l++.

You can select windows or panes with ++ctrl+shift+bracket-left++ or ++ctrl+shift+bracket-right++.
If you prefer, you can just click the pane or window with your mouse.

![kittytiling](./images/kitty_tilling.png)

## Conclusion

Kitty offers many features without additional configuration.
If you already have a configured window manager, `zsh`, or `tmux` on your workstation, you probably do not need Kitty. Consider the fact that you can combine `zsh` shortcuts, `tmux` tiling, and many window manager features, just in one terminal emulator.
But, if you have not tried any of these power tools yet, the **author** would definitely recommend that you start with Kitty.
