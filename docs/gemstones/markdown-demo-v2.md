---
title: Markdown Demo
author: Einstein
contributors: Dr. Ben Dover, Sweet Gypsy Rose
tested_with: 8.5
tags:
  - sample
  - crowdin
  - markdown
---

# Overview

!!! WARNING

    Do not take anything you may read in this document seriously.

As you can tell by reading, this is a pretty silly example, designed to be used to test some translation issues that we are having. But because the problems have not yet been solved we are going to modify the file a little bit here and there to see the effect it has. It's fun to write though!

This guide demos popular Markdown tags used on [https://docs.rockylinux.org](https://docs.rockylinux.org) also includes the admonitions tag, which is not part of the standard Markdown tags.

## The Demo

> This is a quote example. Nicely formatted.

Sometimes you will see things like _this_.

How about a little **bold face**

Most of the time, it straight text like this.

Sometimes you need to show a `command`

Or multiple commands:

```
dnf install my_stapler
dnf update my_pencil
dnf remove my_notepad
systemctl enable my_stapler
```

At other times, you need bulleted or numbered lists:

- I believe you have my stapler
- Come to think of it, I can't even find my compass
- If not, please at least return my pencil
- I definitely need it

1. I didn't know you needed it
2. Here is your broken pencil
3. Sharpening it is useless

And you could need an admonition:

!!! TIP

    Pencils and staplers are really old-school.

More times than not, when a command has multiple options, or you need to list specifics, you might want to use a table to identify things:

| Tool     | Use                                         | Additional Information                          |
| -------- | ------------------------------------------- | ----------------------------------------------- |
| pencil   | writing or printing                         | often replaced with a pen                       |
| pen      | writing or printing                         | often replaced with a stylus                    |
| stylus   | writing or printing on an electronic device | sometimes replaced by a keyboard                |
| keyboard | writing or printing on an electronic device | never replaced - used until full of food crumbs |
| notepad  | take notes                                  | substitute for a sometimes-faulty memory        |
