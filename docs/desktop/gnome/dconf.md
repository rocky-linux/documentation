---
title: dconf Config Editor
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

GNOME takes a very streamlined approach to its user interface and its features. This is not bad, as it is easy to learn, and the default GNOME experience lets you get to work doing your work.

However, this approach also means it is not as quickly configurable. If you can not find what you need in the Settings panel, you can install GNOME Tweaks to expand your options. You can even install GNOME extensions to get new features and options.

But what if you want to see all the little settings, features, and configurations the GNOME developers have hidden? You can look up your current problem online and type in a command to change an obscure variable, or you can install `dconf Editor`.

`dconf Editor` is a GNOME Settings app with *everything*. It might remind you a little bit of the Windows Registry, and it *is* similar. However, it is more readable; it only covers GNOME functionality, and some software is built for GNOME.

And you can also edit settings for GNOME extensions.

!!! Warning

    The comparison to the Windows Registry was entirely intentional. Like bad Registry keys, *some* of the GNOME Shell settings can break your GNOME installation or at least cause issues. You may need to restore the old settings via the command line.

    If you are unsure what a particular setting does, research it first. Changing app settings is fine, though, and much easier to reverse.

## Assumptions

For this guide, you need the following:

* Rocky Linux with GNOME installed.
* The authority to install software on your system (`sudo` privileges).


## Installing `dconf Editor`

Go to the "Software" app, search for "Dconf Editor", and click the install button. It is available in the default Rocky Linux repository.

![the GNOME software center, featuring dconf Editor](images/dconf-01.png)

To install the dconf editor with the command line, do the following:

```bash
sudo dnf install dconf-editor
```

## Using `dconf Editor`

Once you open the app, you will see three important user interface bits. Up at the top is the path. All GNOME settings are in a path/folder structure.

At the top right, you will see a button with a little star on it. That is the favorites button, which allows you to save your place in the app and return to it later quickly and easily. Below is the central panel where you select your settings subfolders and change settings as you see fit.

![a screenshot of the dconf Editor window with arrows pointing at the aforementioned elements](images/dconf-02.png)

To the left of the favorite button is the search button, which does exactly what you would expect.

What if you want to change some settings in the file manager? For example, I love the sidebar. I find it very handy. But maybe you feel differently and want to change things up. So, for this guide, it has got to go.

![a screenshot of the Nautilus file manager, with a threatening red X over the doomed sidebar](images/dconf-03.png)


Go to `/org/gnome/nautilus/window-state`, and you will see an option called `start-with-sidebar`. Hit the toggle, and click the "Reload" button when that shows, as shown in the screenshot below:

![a screenshot of dconf Editor, showing the toggle and reload button in question](images/dconf-04.png)

If everything has gone right, the following file browser window you open should look like this:

![a screenshot of the file manager, bereft of its sidebar](images/dconf-05.png)

If that feels wrong, switch it back, hit Reload again, and open a new file browser window.

Lastly, you can click directly on any setting in the `dconf Editor` window to see more information (and sometimes more options). For example, here is the `initial-size` settings screen for the GNOME file manager.

![a screenshot of dconf Editor showing the initial-size settings for the file manager](images/dconf-06.png)

## Troubleshooting

If you are making changes to your settings in `dconf Editor` and you are not seeing anything change, try one of the following fixes:

1. Restart the app to which you are making the changes.
2. Log out, log back in, or reboot for some changes to GNOME Shell.
3. Give up because that option just is not functional anymore.

On that last point: Yes, the GNOME developers sometimes disable your ability to change a setting, even with `dconf Editor`.

For example, I tried changing the window switcher settings (the list of open windows that shows up when you press ++alt+tab++) and got nowhere. No matter what I tried, `dconf Editor` does not affect some of its functions.

That could be a bug, but it would not be the first time a setting shown in `dconf Editor` was essentially stealth-disabled. If you run into that problem, search the GNOME Extensions site to see if there is an extension that adds the option you want back into GNOME.

## Conclusion

That is all you need to know to get started. Just remember to keep track of all your changes, do not change settings without knowing exactly what they do, and have fun exploring the options that are (mostly) available to you.
