---
title: 使用 Xorriso 写入物理 CD/DVD
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## 简介

我最近发现，在 Rocky Linux 上使用图形化工具将混合 ISO 烧录到物理 CD/DVD 非常困难。幸运的是，**Xorriso** 是一款简单易用的命令行应用，可以很好地完成这项任务！

## 问题描述

将 ISO 镜像烧录到物理 CD/DVD。

## 前置条件

- 互联网连接
- 熟悉终端操作
- CD/DVD 刻录机（RW 驱动器）

## 操作步骤

**安装 Xorriso**：

   ```bash
   sudo dnf install xorriso -y
```

**将 ISO 写入光盘**：

   ```bash
   sudo xorriso -as cdrecord -v dev=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso -eject
```

## 补充信息

Xorriso 依赖于 C 库 libisofs。你可以在 Fedora 的软件包监控页面 了解更多关于 libisofs 的信息。

## 总结

在本篇文档中，你学习了如何使用 Xorriso 将 ISO 镜像写入物理光盘！请注意，Xorriso 也可以用来将其他文件类型写入物理光盘，但我发现它在处理图形化工具无法识别的混合 ISO 格式时尤其得心应手。
