---
title: GNOME Shell Extensions
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - gnome
---

## Introduction

From the [GNOME website](https://extensions.gnome.org/about/){:target="_blank"}:

>GNOME Shell provides core user interface functions for GNOME, like switching to windows and launching applications. User interface elements provided by GNOME Shell include the Panel at the top of the screen, the Activities Overview, and Message Tray at the bottom of the screen."
>GNOME Shell extensions are small pieces of code written by third party developers that modify the way GNOME works. (If you are familiar with Chrome Extensions or Firefox Addons, GNOME Shell extensions are similar to them.) You can find and install GNOME Shell extensions using this website.
>Creation of extensions are created outside of the normal GNOME design and development process, they are supported by their authors, rather than by the GNOME community. Some features first implemented as extensions might find their way into future versions of GNOME.

## Assumptions

* A Rocky Linux Workstation or Server with GUI installation that uses GNOME.

## Install GNOME extensions

GNOME Extensions are provided from the gnome-shell package in the "appstream" repository. Install with:

```bash
sudo dnf install gnome-shell
```

Installation includes all needed dependencies.

## Install browser integration

Gnome Extensions has a software library available through its website, gnome.extensions.org, where you can install extensions directly from the website. To achieve this, your browser and gnome extensions must facilitate a connection.

```bash
sudo dnf install chrome-gnome-shell
```

[installation guide](https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html){target="_blank"}

## Determining the GNOME shell version

The browser extension used to facilitate extension installations from extensions.gnome.org should automatically detect the version of the GNOME shell your system is currently running.

To perform a local installation, you must download the extension using the correct GNOME shell version.

```bash
gnome-shell --version
```

## Installing an extension

For this example, we will install the popular dash-to-dock extension.

1. Go to [dash to dock extension webpage](https://extensions.gnome.org/extension/307/dash-to-dock/){target="_blank"}
2. Toggle the extension from "off" to "on"
![Toggle extension](images/gnome_extensions_images/gnome-shell-extensions-toggle-btn.webp)
3. When prompted to install the extension, click "yes".

## Managing installed extensions

GNOME extensions are installed and managed on gnome.extensions.org.

To manage your GNOME extensions, first go to <https://extensions.gnome.org/local/>

![Manage GNOME extensions](images/gnome_extensions_images/gnome-shell-installed-extensions.webp)

On this page, you will find a list of installed extensions. You can toggle each of these on or off. You can also configure the shell settings by clicking the toggle button for either of the two available menu options: "Disable all extensions" or "Disable version validation."

## Conclusion

GNOME Extensions is a good tool for adding functionality and customizing your GNOME desktop environment.
