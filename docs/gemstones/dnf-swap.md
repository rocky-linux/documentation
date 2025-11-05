---
title: dnf - swap command
author: wale soyinka
contributors:
date: 2023-01-24
tags:
  - cloud images
  - containers
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
---


# Introduction

In order to make container images and cloud images as small as possible, distribution maintainers and packagers may sometimes ship stripped down versions of popular packages. Examples of stripped-down packages bundled with container or cloud images are **vim-minimal, curl-minimal, coreutils-single** and so on.

Although some of the shipped packages are stripped down versions, they are often fully acceptable for most use cases.

For cases, when the stripped-down package is not enough, you can use the `dnf swap` command to quickly replace the minimal package with the regular package.

## Objective

This Rocky Linux GEMstone demonstrates how to use **dnf** to _swap_ the bundled `vim-minimal` package with the regular `vim` package.

## Check existing `vim` variant

While logged into your container or virtual machine environment as a user with administrative privileges, first verify the variant of `vim` package installed. Type:

```bash
# rpm -qa | grep  ^vim
vim-minimal-8.2.2637-22.el9_6.1.x86_64
```

The `vim-minimal` package is on your system.

## Swap `vim-minimal` for `vim`

Use `dnf` to swap the installed `vim-minimal` package with regular `vim` package.

```bash
# dnf -y swap vim-minimal vim

```

## Check new `vim` package variant

To confirm the changes, query the rpm database again for the installed `vim` package(s) by running:

```bash
# rpm -qa | grep  ^vim
vim-enhanced-8.2.2637-22.el9_6.1.x86_64
```

And it's a GEM !

## Notes

DNF Swap Command

**Syntax**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Under the hood, `dnf swap` uses DNF's `--allowerasing` option to resolve any package conflict issues. Therefore the `vim` minimal example demonstrated in this GEMstone could also have been done by running:

```bash
dnf install -y --allowerasing vim
```
