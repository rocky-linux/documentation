---
title: GNOME Tweaks
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## 简介

GNOME Tweaks 是一款用于个性化桌面体验的工具，它允许用户自定义默认字体、窗口管理、工作区等多个方面。

## 前提条件

- 您需要一个安装了图形界面（GUI）的 Rocky Linux 工作站或服务器，并且该系统使用 GNOME 作为桌面环境。

## 安装 GNOME Tweaks

GNOME Tweaks 可以直接从 "appstream" 仓库获取，无需额外配置仓库。 使用以下命令安装：

```bash
sudo dnf install gnome-tweaks 
```

安装过程中会自动包含所有必需的依赖项。

## 界面与功能

![Activities Menu](images/activities.png)

要启动 Tweaks，请点击活动菜单中的搜索框，输入 "tweaks" 并点击出现的 "Tweaks" 应用。

![Tweaks](images/tweaks.png)

<!-- Please, add here a screen where you click Tweaks -->

_General_ 常规部分允许用户更改动画、挂起和过度放大等默认行为的设置。

![Tweaks General](images/01_tweaks.png)

_Appearance_ 外观部分可以修改主题默认设置、背景及锁屏图片。

![Tweaks Appearance](images/02_tweaks.png)

_Fonts_ 字体部分可调整默认字体及其大小。

![Tweaks Fonts](images/03_tweaks.png)

_Keyboard & Mouse_ 键盘与鼠标功能区允许改变键盘和鼠标的默认行为。

![Tweaks Keyboard and Mouse](images/04_tweaks.png)

如果希望某些应用程序随 GNOME 桌面启动，可以在 _Startup Applications_ 启动应用程序中进行设置。

![Tweaks Startup Applications](images/05_tweaks.png)

_Top Bar_ 顶部栏自定义(包括时钟、日历、电池图标) 的默认设置均可在此处调整。

![Tweaks Top Bar](images/06_tweaks.png)

_Window Titlebars_ 窗口标题栏部分能够修改标题栏的默认行为。

![Tweaks Window Titlebars](images/07_tweaks.png)

_Windows_ 窗口部分则用于调整窗口的默认表现。

![Tweaks Windows](images/08_tweaks.png)

_Workspaces_ 工作区让用户设定工作区的创建方式(动态或静态)，以及它们的显示方式。

![Tweaks Workspaces](images/09_tweaks.png)

!!! note "注意"

```
如果需要，可以通过左上角“Tweaks”旁边的 three-bar 三横菜单按钮重置所有设置回到默认状态。
```

## 总结

GNOME Tweaks 是一款优秀的工具，它能让您根据个人喜好定制 GNOME 桌面环境。
