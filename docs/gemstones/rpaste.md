---
title: rpaste - Pastebin Tool
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# Introduction to `rpaste`

`rpaste` is a tool for sharing code, log output, and other extra long text. It is a pastebin created by the Rocky Linux developers. This tool is useful when you need to share something publicly, but do not want to dominate the feed with your text. This is especially important when using Mattermost, which has bridges to other IRC services. The `rpaste` tool can be installed on any Rocky Linux system. If your desktop machine isn't Rocky Linux or if you simply do not want to install the tool, you can use it manually, by accessing the [pinnwand URL](https://rpa.st) and then paste the system output or text that you want to share. `rpaste` allows you to create this information automatically.

## Installation

Installation of `rpaste` on Rocky Linux:

```bash
sudo dnf --enablerepo=extras install rpaste
```

## Uses

For major system problems, you may need to send all of your system's information so that it can be reviewed for problems. To do this run:

```bash
rpaste --sysinfo
```

Which will return the link to the pinnwand page:

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

You can then review the information yourself in a browser and decide if you want to keep it or remove it and start over. If you want to keep it, you can copy the "Paste URL" and share that with whomever you are working with, or in the feed on Mattermost. To remove, simply copy the "Removal URL" and open that in your browser.

You can add content to your pastebin by piping the content. As an example, if you wanted to add content from your `/var/log/messages` file from March 10, you might do this:

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## `rpaste` help

To get help with the command, simply type:

```bash
rpaste --help
```

Which gives the following output:

```bash
rpaste: A paste utility originally made for the Rocky paste service

Usage: rpaste [options] [filepath]
       command | rpaste [options]

This command can take a file or standard in as input

Options:
--life value, -x value      Sets the life time of a paste (1hour, 1day, 1week) (default: 1hour)
--type value, -t value      Sets the syntax highlighting (default: text)
--sysinfo, -s               Collects general system information (disables stdin and file input) (default: false)
--dry, -d                   Turns on dry mode, which doesn't paste the output, but shows the data to stdin (default: false)
--pastebin value, -p value  Sets the paste bin service to send to. Current supported: rpaste, fpaste (default: "rpaste")
--help, -h                  show help (default: false)
--version, -v               print the version (default: false)
```

## Conclusions

It is sometimes important to share a large amount of text when working on a problem, sharing code or text, etc. Using `rpaste` for this will save others from having to view large amounts of text content that isn't important to them. It is important Rocky Linux chat etiquette as well.
