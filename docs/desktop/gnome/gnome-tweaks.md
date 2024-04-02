---
title: GNOME Tweaks
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## Introduction

GNOME Tweaks is a tool for customizing desktop experiences, including default fonts, windowing, workspaces, and more.

## Assumptions

* A Rocky Linux Workstation or Server with GUI installation that uses GNOME.

## Install GNOME tweaks

GNOME Tweaks is available from the "appstream" repository, requiring no additional repository configuration. Install with:

```bash
sudo dnf install gnome-tweaks 
```

Installation includes all needed dependencies.

## Screens and functions

To start tweaks, from the Activities menu's search, type "tweaks" and click on "Tweaks."

<!-- Please, add here a screen where you click Tweaks -->

*General* allows changing the default behavior of animations, suspension, and over-amplification.

![Tweaks General](images/01_tweaks.png)


*Appearance* allows the changing of theme defaults and the background and lock screen images.

![Tweaks Appearance](images/02_tweaks.png)


*Fonts* allows the changing of default fonts and sizes.

![Tweaks Fonts](images/03_tweaks.png)


*Keyboard & Mouse* allows changing default keyboard and mouse behavior.

![Tweaks Keyboard and Mouse](images/04_tweaks.png)

If you have applications you want to start when the GNOME shell starts, you can set that up in *Startup Applications*.

![Tweaks Startup Applications](images/05_tweaks.png)

Customize the *Top Bar* (clock, calendar, battery) defaults here.

![Tweaks Top Bar](images/06_tweaks.png)

*Window Titlebars* allows changing the default behavior of titlebars.

![Tweaks Window Titlebars](images/07_tweaks.png)

*Windows* allows changing the default behavior of windows.

![Tweaks Windows](images/08_tweaks.png)

*Workspaces* allows you to change how workspaces are created (dynamically or statically) and how you want those workspaces to appear.

![Tweaks Workspaces](images/09_tweaks.png)

!!! note

    You can reset everything back to defaults by using the three-bar menu next to "Tweaks" in the left-hand corner.

## Conclusion

GNOME Tweaks is a good tool for customizing your GNOME desktop environment.
