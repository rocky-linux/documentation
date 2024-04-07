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
  - curl
  - curl-minimal
  - allowerasing
  - coreutils-single
---


# Introduction

In order to make container images and cloud images as small as possible, distribution maintainers and packagers may sometimes ship stripped down versions of popular packages. Examples of stripped-down packages bundled with container or cloud images are **vim-minimal, curl-minimal, coreutils-single** and so on.

Although some of the shipped packages are stripped down versions, they are often fully acceptable for most use cases.

For cases, when the stripped-down package is not enough, you can use the `dnf swap` command to quickly replace the minimal package with the regular package.

## Objective

This Rocky Linux GEMstone demonstrates how to use **dnf** to _swap_ the bundled `curl-minimal` package with the regular `curl` package.

## Check existing curl variant

While logged into your container or virtual machine environment as a user with administrative privileges, first verify the variant of `curl` package installed. Type:

```bash
# rpm -qa | grep  ^curl-minimal
curl-minimal-*
```

We have curl-minimal on our demo system!

## Swap curl-minimal for curl

Use `dnf` to swap the installed `curl-minimal` package with regular `curl` package.

```bash
# dnf -y swap curl-minimal curl

```

## Check new curl package variant

To confirm the changes, query the rpm database again for the installed curl package(s) by running:

```bash
# rpm -qa | grep  ^curl
curl-*
```

And it's a GEM !

## Notes

DNF Swap Command

**Syntax**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Under the hood, `dnf swap` uses DNF's `--allowerasing` option to resolve any package conflict issues. Therefore the curl minimal example demonstrated in this GEMstone could also have been done by running:

```bash
dnf install -y --allowerasing curl
```
