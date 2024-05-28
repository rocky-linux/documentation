---
title: micro
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
tested version: 8.5
tags:
  - editor
  - editors
  - micro
---

# Install micro on Rocky Linux

## Introduction

*[micro](https://micro-editor.github.io)* is a fantastic little terminal-based text editor that sits between *nano* and *vim* in terms of complexity. It has a simple, easily-recognized workflow with several awesome features:

- All of your usual ++control+c++, ++control+v++, and ++control+f++ commands work as they would in a desktop-based text editor. All keybindings can be re-bound, of course.
- Mouse support — click and drag to select text, double-click to select words, triple-click to select lines.
- Over 75 languages are supported with syntax highlighting by default.
- Multiple cursors for when you need to edit multiple lines at a time.
- Includes a plugin system.
- Multiple panes.

And here’s how it looks in my own terminal:

![A screenshot of the micro text editor](images/micro-text-editor.png)

!!! Note

    You *can* install micro via a snap app. If you're already using snap on your machine.. I mean... why not? But I prefer to get it straight from the source.

## Prerequisites

- Any internet-connected Rocky Linux machine or container.
- A basic knowledge of the command line, and a desire to edit your text there.
- Some commands will need to be run as root, or with `sudo`.

### How to Install micro

This is maybe the easiest tutorial I’ve written so far, with exactly three commands. First, you make sure that *tar* and *curl* are installed. This should only really be relevant if you’re running a minimal install of Rocky, or running it inside a container.

```bash
sudo dnf install tar curl
```

Next, you’ll need the installer from *micro*’s website. The following command will get the installer, and run it for you in whatever directory you’re working in. I know we don’t normally advise copying and pasting commands from websites, but this one has never given me any trouble.

```bash
curl https://getmic.ro | bash
```

To install the app system-wide (and so you can just type “micro” to open up the app), you can run the script as root inside of `/usr/bin/`. However, if you want to check it out first and be careful about it, you can install the *micro* to any folder you want, and then move the app later with:

```bash
sudo mv micro /usr/bin/
```

And that’s it! Happy text editing.

### The Really Easy Way

I created a dead-simple script that basically just runs all of those commands. You can find it in my [Github gists](https://gist.github.com/EzequielBruni/0e29f2c0a63500baf6fe9e8c51c7b02f), and either copy/paste the text to a file on your machine, or download it with `wget`.

## Uninstalling micro

Go to the folder you installed *micro* in and (using your godly root powers as necessary) run:

```bash
rm micro
```

Also, *micro* will leave some configuration files in your home directory (and the home directories of every user who has run it). You can get rid of those with:

```bash
rm -rf /home/[username]/.config/micro
```

## Conclusion

If you want a full guide to using *micro*, check out the [main website](https://micro-editor.github.io), and the documentation in the [Github repo](https://github.com/zyedidia/micro/tree/master/runtime/help). You can also press “Control-G” to open the main help file inside of the app itself.

*micro* probably won’t meet the needs of those who have dedicated themselves to the *vim* or *emacs* experience, but it’s perfect for people like me. I’ve always wanted that old Sublime Text experience in the terminal, and now I have something *really* close.

Try it out, see if it works for you.
