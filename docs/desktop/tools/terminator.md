---
title: Installing the Terminator terminal emulator 
author: Andrew Scott
contributors: Steven Spencer
tested with: 9.4
---

## Introduction

Terminator is a terminal emulator based on GNOME Terminal that supports advanced features such as many terminal panels, grouping terminals, and saving your preferred layouts.

## Assumptions

* You have a Rocky Linux workstation or server with GUI
* You are an administration with `sudo` privileges

## Installing Terminator

Terminator is in the Extra Packages for Enterprise Linux (EPEL) repository, which is not available on a new installation. So first, we need to add EPEL to Rocky Linux.

* Step 1 (optional): Enable the CodeReady Builder (CRB) repository

```bash
sudo dnf config-manager --set-enabled crb
```

While not strictly necessary for Terminator, CRB provides dependencies for some of the packages in EPEL so it can be useful to have if you plan on relying on that repository in the future.

* Step 2: Add the EPEL repository

```bash
sudo dnf install epel-release -y
```

* Step 3 (optional, but highly recommended): Update your system

```bash
sudo dnf update -y --refresh
```

* Step 4: Install Terminator

```bash
sudo dnf install terminator -y
```

## Configuration

By default, Terminator does not look much different from the default GNOME Terminal. In fact, it looks *even more* bare-bones than the default.

![Default layout of Terminator](images/terminator-01.png)

To start customizing your new terminal open the context menu by right clicking anywhere on the background.

![Terminator context menu](images/terminator-02.png)

From this menu we can split the window, open new tabs, and switch layouts. It is also possible to customize the theme from the Preferences sub menu. It might be worth taking some time to familiarize yourself with the available options as there are many settings that are beyond the scope of this guide.

There are also several keybindings available for those who prefer not to move their hand back and forth between the keyboard and mouse. For example, ++shift+ctrl+"O"++ will split the window horizontally into many terminals. Splitting the window many times, and drag-and-drop reordering are additionally supported.

![Terminator window with 3 split terminals](images/terminator-03.png)

Finally, it can also be useful to set up a keyboard shortcut to open your new terminal. To do this, start by opening the Settings menu. You can access the menu in a few different ways, so for this guide you are going to right-click the desktop and left-click "Settings."

![Desktop context menu with "Settings" highlighted](images/terminator-04.png)

From here, navigate to the "Keyboard" section by using the menu on the left, then click "Customize Shortcuts" at the bottom.

![GNOME Settings Keyboard Menu](images/terminator-05.png)

If this is your first time setting a custom shortcut you'll see a button titled "Add Shortcut." Otherwise you'll see a list of your shortcuts with a plus sign at the bottom. Click whichever applies to your situation to open the "Add Custom Shortcut" dialog. In the *Name* field type an easy to remember nickname for your shortcut. For the *Command* field, type the name of our program: `terminator`. Then click "Set Shortcut" to set your new key combination.

![Add Custom Shortcut dialog](images/terminator-06.png)

While ++ctrl+alt+"T"++ is a traditional choice feel free to choose whatever combination you wish. You can always update the shortcut name and key combination later. To save your shortcut click "Add" in the top right of the Add Custom Shortcut dialog.

![Add Custom Shortcut dialog completed for Terminator](images/terminator-07.png)

## Conclusion

Terminator is a powerful terminal emulator for both regular users and power users alike. These examples only represent a small fraction of Terminator's capabilities. While this guide provides an overview of the installation steps for Rocky Linux you might want to take a examine the [documentation](https://gnome-terminator.readthedocs.io/en/latest/) for a full explanation of Terminator's features.
