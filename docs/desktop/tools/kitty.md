---
title: Installing the Kitty terminal emulator 
author: Alex Zolotarov 
contributors: Steven Spencer
tested with: 9
---

## Introduction

**Kitty is a blazing fast terminal emulator on steroids**, anything you can possibly imagine is customizable in Kitty.
You can utilize tab management, tilling, image previews, and many more just within this terminal emulator. 
You can basically replace tmux or even a Window Manager with **Kitty** (if you work mostly within a terminal).

## Assumptions

- You have a Rocky Linux workstation or server with GUI
- You are an administration with `sudo` privileges

## Installing Kitty

**First, install the EPEL repository (Extra Packages for Enterprise Linux):**

```bash
dnf install -y epel-release
```

Next, install **Kitty** 

```bash
dnf install -y kitty
```

And there you have it. Now, you can start Kitty.

## Quick Overview

### Configuration File

Once you have started **Kitty** you can open Kitty configuration file with `Control`+`Shift`+'F2'. 
Alternatively, you can find configuration file at `$HOME/.config/kitty`.

We are not going to go deep into configuration file itself, just keep in mind that you can change any default shortcuts, or anything related to the appearance.

### Tabs

You can create a new tab with `Control`+`Shift`+`T`.

You can close a tab with `Control`+`Shift`+`W`*or*`Q`

You can select tabs with `Control`+`Shift`+`[Arrow Keys]`

![kittytabs](./images/kitty_tabs.png)

### Tilling

Press `Control`+`Shift`+`Enter` to open a new pane/window.
You can press it multiple times to create a tilling layout. 

You can switch layouts with `Control`+`Shift`+`L`.

You can select windows/panes with `Control`+`Shift`+`[`*or*`]`.
Alternatively, you can just click on the pane/window with your mouse.

![kittytilling](./images/kitty_tilling.png)

## Conclusion

Kitty offers a lot of features out of the box.
If you already have configured window manager, zsh, or tmux on your workstation.
You probably don't really need Kitty if you are not willing to reconfigure everything from scratch.
Consider the fact that you can combine zsh shortcuts, tmux tilling, and many wm features just in one terminal emulator.
But if you haven't tried any of these powertools yet, **author** would definitely recommend you to start with Kitty.
