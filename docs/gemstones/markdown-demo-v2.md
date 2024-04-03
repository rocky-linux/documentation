---
title: Markdown Demo
author: Einstein
contributors: Dr. Ben Dover, Sweet Gypsy Rose, fusion94
tested_with: 8.5
tags:
  - sample
  - crowdin
  - markdown
---

# Overview

## Background

* Use [Markdown](https://daringfireball.net/projects/markdown).
* If you don't know Markdown - Learn Markdown; seriously it might be one of the
  most important languages you will learn over the years.

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

### Admonitions

Admonitions, also known as call-outs, are an excellent choice for including side content without significantly interrupting the document flow. Material for MkDocs provides several different types of admonitions and allows for the inclusion and nesting of arbitrary content.

!!! TIP

    Pencils and staplers are really old-school.

#### Usage
Admonitions follow a simple syntax: a block starts with !!!, followed by a single keyword used as a type qualifier. The content of the block follows on the next line, indented by four spaces:

!!! note

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

#### Changing the title
By default, the title will equal the type qualifier in titlecase. However, it can be changed by adding a quoted string containing valid Markdown (including links, formatting, ...) after the type qualifier:

!!! note "Phasellus posuere in sem ut cursus"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.


More times than not, when a command has multiple options, or you need to list specifics, you might want to use a table to identify things:

| Tool     | Use                                         | Additional Information                          |
| -------- | ------------------------------------------- | ----------------------------------------------- |
| pencil   | writing or printing                         | often replaced with a pen                       |
| pen      | writing or printing                         | often replaced with a stylus                    |
| stylus   | writing or printing on an electronic device | sometimes replaced by a keyboard                |
| keyboard | writing or printing on an electronic device | never replaced - used until full of food crumbs |
| notepad  | take notes                                  | substitute for a sometimes-faulty memory        |
