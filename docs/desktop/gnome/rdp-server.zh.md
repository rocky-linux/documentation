---
title: 通过 RDP 进行桌面共享
author: Ezequiel Bruni
contributors: Steven Spencer
---

## 简介

如果你想在 Rocky Linux 上共享你的 (Gnome) 桌面，或访问其他共享桌面，这就是适合你的指南。 更不要说, 它非常简单!

对于初学者，你将使用RDP。 RDP 代表远程桌面协议，它正是这样做的：它允许你从远处查看计算机并与之交互，所有这些都有一个图形界面。 除了一些必要的命令行设置。

!!! note "提示"

```
默认情况下，Rocky Linux能够通过另一种称为VNC的协议共享桌面。VNC足够可用，RDP通常提供更流畅的体验，并且可以处理奇怪的监视器分辨率。
```

## 前提条件

对于本指南，假设你已经设置了以下内容：

- Rocky Linux 已安装 Gnome
- Flatpak 和 Flathub 已安装并可用
- 一个非 root 用户账号
- 拥有管理员或 sudo 访问权限，并愿意将命令粘贴到终端中
- X server (用于共享你的桌面)

!!! info "信息"

```
目前有一些项目正在进行中，以使Wayland显示服务器和RDP运行良好，而最新版本的Gnome附带了一个内置的RDP服务器来实现这一功能。但是，Rocky Linux的Gnome版本没有这个功能，因此使用x11为RDP会话展示要容易得多。
```

## 使用 RDP 协议共享你的 Rocky Linux Gnome 桌面

要想让你的 Rocky Linux 桌面可远程访问, 你需要一个 RDP 服务. 就我们的目的而言，'xrdp' 就足够了。 不过，你需要使用终端，因为它是一个仅支持 CLI 的程序。

```bash
sudo dnf install xrdp
```

安装完成后你需要启动此服务

```bash
sudo systemctl enable --now xrdp
```

如果一切顺利，RDP 服务器应该已被安装、启用并运行。 但是你现在还不能连接，还需要先在防火墙上打开对应的端口。

如果你想了解更多关于 Rocky Linux 防火墙应用程序 `firewalld` 的工作原理，请参阅我们的 [`firewalld` 初学者指南](../../guides/security/firewalld-beginners.md). 如果你只是想继续前进，请运行以下命令：

```bash
sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```

对于初学者：这些命令打开防火墙中的RDP端口，以便 xrdp 服务可以接受传入的RDP连接，并重新启动防火墙以应用更改。 此时，如果你觉得有必要，为了安全起见，你可以重新启动电脑。

如果您不想重新启动，可能需要注销。 RDP 使用你的用户帐户凭据进行安全保护。 请注意, 无法在本地登录到桌面的同时远程登录。 至少不是在同一个用户帐户上。

!!! info "信息"

```
你还可以使用防火墙应用程序来管理 `firewalld` 并打开需要的任何端口。请查看此空间，以获取我的安装和使用防火墙应用程序指南的链接。
```

## 使用 RDP 访问 Rocky Linux 桌面和/或其他系统的桌面

你已经了解了如何安装 RDP 服务器，现在你需要一个RDP客户端应用程序。 在Windows上，远程桌面连接应用程序很好地完成了这一任务。 如果你想从另一台Linux机器访问你的 Rocky Linux 机器，你需要安装第三方依赖。

在Gnome上，Remmina得到了我的最高推荐。 它使用起来并不复杂，非常稳定，而且通常都能正常工作。

如果你安装了Flatpak/Flathub，只需打开软件应用程序并搜索Remmina。

![Gnome Software 应用 Remmina 页](images/rdp_images/01-remmina.png)

安装并启动它 注意：这是在 Remmina 中添加 RDP 连接的过程，但对于你可能找到的几乎所有其他 RDP 客户端应用程序来说，都是类似的流程。

开始吧，点击左上角的加号按钮添加连接。 在名称字段中输入你喜欢的名称，并输入远程计算机的IP地址以及你的远程用户帐户的用户名和密码。 记住，如果你的电脑在同一个网络上，你可以使用它的本地IP地址，而不是你在 "whatsmyip.com" 这样的网站上看到的地址。

![Remmina 连接输入表单](images/rdp_images/02-remmina-config.png)

如果你的电脑不在同一个网络上，那么我真的希望你知道如何进行端口转发，或者远程电脑有某种静态IP。 这完全超出了本指南的范围。

请务必向下滚动以查看多显示器支持、自定义分辨率等选项。 此外，"Network connection type" 网络连接类型选项将允许你在 RDP 客户端中平衡带宽使用和图像质量。

如果你的电脑在同一个网络上，只需使用局域网即可获得最佳质量。

然后点击 ++"Save"++ 和 ++"Connect"++, 就可以了!

这就是 Windows 远程桌面连接客户端的样子。 作者使用 RDP 在他的本地 Rocky Linux 服务器上编写了整个文档。 RDP 能够处理奇怪的监视器分辨率，这可不是在开玩笑哦。

![我在编写文档时的环境截图, 5120x1440p 分辨率](images/rdp_images/03-rdp-connection.jpg)

## 总结

恭喜你完成了所有流程! 这就是在 Rocky Linux 上启动和运行 RDP，并尽情共享桌面所需了解的所有内容。 如果你只需要远程访问一些文件和应用程序，这就可以了。
