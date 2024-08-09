---
title: dconf Config Editor
author: Ezequiel Bruni
contributors: Steven Spencer
---

## Introduction

GNOME takes a very streamlined approach to its user interface and its features. This is not a bad thing, as it is easy enough to learn, and the default GNOME experience lets you get right to work doing your work.

However, this approach also means that it is not as easily configurable as some people would like. Sure, if you can not find what you need in the Settings panel, you can install GNOME Tweaks to expand your options. You can even install GNOME extensions to get new features and options.

But what if you want to see all the little settings, features, and configurations that the GNOME developers have hidden from you? Sure, you can look up your current problem online, and type in a command to change an obscure variable, or you could install `dconf Editor`.

`dconf Editor` is essentially a GNOME Settings app that has *everything*. In fact, it might remind you a little bit of the Windows Registry, and it *is* similar. However, it is more readable, it only covers GNOME functionality, and some of the software built for GNOME.

Oh, and you can also edit settings for GNOME extensions, so that is cool.

!!! Warning

    The comparison to the Windows Registry was quite intentional. Like bad Registry keys, *some* of the GNOME Shell settings can actually break your GNOME installation, or at least cause issues. You may need to restore the old settings via the command line.

    If you are not sure what a particular setting does, research it first. Changing app settings is fine, though, and much easier to reverse.

## Assumptions

For this guide, you are going to need:

* Rocky Linux with GNOME installed.
* The authority to install software on your system (`sudo` privileges).

And that is it.

## Installing `dconf Editor`

Go to the "Software" app, search for "Dconf Editor", and hit this install button. It is available in the default Rocky Linux repository.

![the GNOME software center, featuring dconf Editor](images/dconf-01.png)

For those of you who want to do it the command line way, that is:

```bash
sudo dnf install dconf-editor
```

## Using `dconf Editor`

Once you open up the app, you will see three important bits of the user interface. Up at the top is the path. Yes, your GNOME settings are all organized in a path/folder structure.

At the top right, you will see a button with a little star on it. That is the favorites button, so you can save your place in the app and come back to it later quickly and easily. Down below is the main panel where you select your settings subfolders, and actually change settings as you see fit.

![a screenshot of the dconf Editor window with arrows pointing at the aforementioned elements](images/dconf-02.png)

Left of the favorite button, you will see the search button, which does exactly what you would expect.

Now, what if you want to change some settings in the file manager? For example, I love the sidebar. I find it very handy. But maybe you feel differently, and want to change things up. So, for the purposes of this guide, it has got to go.

![a screenshot of the Nautilus file manager, with a threatening red X over the doomed sidebar](images/dconf-03.png)

*Good night, sweet prince.*

Go to `/org/gnome/nautilus/window-state`, and you will see an option called `start-with-sidebar`. Hit the toggle, and click the "Reload" button when that shows up like this:

![a screenshot of dconf Editor, showing the toggle and reload button in question](images/dconf-04.png)

If everything has gone right, the next file browser window you open should look like this:

![a screenshot of the file manager, bereft of its sidebar](images/dconf-05.png)

If that feels wrong to you -- and this author contends that it should -- just switch it right back, hit Reload again, and open a new file browser window.

Lastly, you can also click directly on any setting in the `dconf Editor` window to see more information (and sometimes more options). For example, here is what the `initial-size` settings screen for the GNOME file manager looks like.

![a screenshot of dconf Editor showing the initial-size settings for the file manager](images/dconf-06.png)

## Troubleshooting

If you are making changes to your settings in `dconf Editor` and you are not seeing anything change, try one of the following fixes:

1. Restart the app to which you are making the changes.
2. Log out and log back in, or reboot for some changes to GNOME Shell.
3. Give up because that option just is not functional anymore.

On that last point: Yes, the GNOME developers will sometimes just take away your ability to actually change a setting, even with `dconf Editor`.

For example, I tried making changes to the window switcher settings (the list of open windows that shows up when you press ++alt+tab++), and got nowhere. No matter what I tried, `dconf Editor` seems to have no effect on some of its functions.

Now that could be a bug, but it would not be the first time a setting shown in `dconf Editor` was essentially stealth-disabled. If you run into that problem, search the GNOME Extensions site to see if there is an extension that adds the option you want back into GNOME.

## Conclusion

That is all you need to know to get started. Just remember to keep track of all your changes, do not change settings without knowing exactly what they do, and have fun exploring the options that are (mostly) available to you.

Have fun!
