---
title: GNOME Shell 扩展
author: Joseph Brinkman
contributors: Steven Spencer
tested with: 9.4
tags:
  - 桌面
  - gnome
---

## 介绍

来源 [GNOME 官网](https://extensions.gnome.org/about/){:target="_blank"}:

> GNOME Shell为GNOME提供了核心用户界面功能，如切换到窗口和启动应用程序。 GNOME Shell提供的用户界面元素包括屏幕顶部的面板、活动概述和屏幕底部的消息托盘。
> GNOME Shell扩展是由第三方开发人员编写的修改GNOME工作方式的小代码。 (如果你熟悉Chrome扩展程序或Firefox插件，GNOME Shell扩展程序与它们相似。) 你可以使用此网站查找并安装GNOME Shell扩展。
> 扩展的创建是在正常的GNOME设计和开发过程之外创建的，它们由作者支持，而不是由GNOME社区支持。 一些最初作为扩展实现的功能可能会进入GNOME的未来版本。

## 前提条件

- 您需要一个安装了图形界面（GUI）的 Rocky Linux 工作站或服务器，并且该系统使用 GNOME 作为桌面环境。

## 安装 GNOME 扩展

GNOME扩展是由“appstream”存储库中的 gnome-shell 包提供的。 使用以下命令安装：

```bash
sudo dnf install gnome-shell
```

安装过程中会自动包含所有必需的依赖项。

## 安装浏览器集成

Gnome Extensions有一个软件库，可以通过他们的网站 gnome.extensions.org 获得，在那里你可以直接在他们的网站上安装扩展。 为了实现这一点，你的浏览器和 gnome 扩展需要建立连接。

```bash
sudo dnf install chrome-gnome-shell
```

[安装指导](https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html){target="_blank"}

## 检测 GNOME shell 版本

方便从 extensions.gnome.org 安装浏览器扩展程序时检测系统当前运行的gnome shell版本。

如果想执行本地安装，你需要下载具有正确GNOME shell版本的扩展。

```bash
gnome-shell --version
```

## 安装一个扩展

对于这个例子，我们将安装常用的 dash-to-dock 扩展。

1. 进入 [dash to dock 扩展页面](https://extensions.gnome.org/extension/307/dash-to-dock/){target="_blank"}
2. 将扩展从 off 关闭切换到 on 打开
   ![Toggle extension](images/gnome_extensions_images/gnome-shell-extensions-toggle-btn.webp)
3. 当系统提示是否安装扩展时，点击 yes

## 管理已安装的扩展

GNOME 扩展在 gnome.extensions.org 上安装和管理。

要想管理你的 GNOME 扩展, 首先要进入 https://extensions.gnome.org/local/

![管理 GNOME 扩展](images/gnome_extensions_images/gnome-shell-installed-extensions.webp)

在这个页面你将看到一份已安装的扩展列表. 你可以控制每一个扩展是否启用. 还可以通过使用两个可用菜单选项禁用所有扩展(Disable all extensions)和禁用版本验证(Disable version validation)中的任何一个上的切换按钮来切换shell设置。

## 总结

GNOME 扩展是添加附加功能和自定义 GNOME 桌面环境的好工具。
