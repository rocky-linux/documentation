---
title: OliveTin
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5, 8.6
tags:
  - 自动化
  - 网页
  - bash
---

# 如何在 Rocky Linux 上安装 & 使用 OliveTin

## 介绍

您是否已经对在同一个CLI命令中连续和多次输入感到厌倦？ 您是否曾经希望家中的其他人能够在不受您干预的情况下重启Plex服务器？ 您想要在网页面板中输入一个名字，按下按钮，然后观看定制Docker/LXD容器的奇迹般出现吗？

如果是这样的话, 可以试试 OliveTin。 OliveTin实际上只是一个让你从配置文件生成网页的应用程序，而且网页有按钮。 点击按钮，OliveTin将运行你之前预设的基础命令。

当然, 你也可以手动创建类似的功能, 从头开始的那种, 需要大量编程经验... 但这种 *方式* 更简单罢了. 它在设置时看起来有点像这样( 开源仓库地址 [OliveTin 仓库](https://github.com/OliveTin/OliveTin)):

![桌面上的 OliveTin 截图；它有一个网格中的几个正方形，每个命令都有可以运行的标签和动作。](olivetin/screenshotDesktop.png)

!!! 警告“永远不要在公共服务器上运行此应用”

    根据设计和创建者自己的承认，这款应用程序旨在用于本地网络，*也许* 用于开发设置。 然而，它目前没有用户认证系统，并且(直到开发者修正它) *默认运行为 root* 。
    
    所以，在安全和防火墙的网络上使用你想要的一切。 *不要*将其放在任何供公开使用的地方。 至少现在是这样的。

## 先决条件和假设

要遵循本指南，您将需要：

* 一台运行Rocky Linux的计算机
* 在最舒适的环境给命令行编写代码。
* Root 访问权限或使用 `sudo` 的能力。
* 学习YAML的基本知识。 这不是很难，你会在后续的介绍中学会它。

## 安装 OliveTin

OliveTin 包括预构建的 RPM 包。 只需根据你电脑的架构下载最新版并安装即可。 如果您在一个带有图形桌面的工作站查看本指南， 只需下载文件并双击它即可进行安装。

如果你期望在服务器上安装此应用程序，那么可以在工作机器上下载并通过SSH/SCP/SFTP上传安装包。 或者根据需要找其他开发者的定制版安装包，然后用 `wget` 下载它。

例如:

```bash
wget https://github.com/OliveTin/OliveTin/releases/download/2022-04-07/OliveTin_2022-04-07_linux_amd64.rpm
```

然后通过以下方式安装应用程序 (还是示例):

```bash
sudo rpm -i OliveTin_2022-04-07_linux_amd64.rpm
```

现在，OliveTin 可以正常运行 `systemd` 服务了，但先不要着急启用它。 你需要先配置文件。

!!! Note "说明"

    经过一些测试，我已经确定这些安装指令将在Rocky Linux LXD容器中正常工作。 任何喜欢Docker的人都可以使用预制的镜像。

## 配置 OliveTin 动作

OliveTin可以做任何 bash 脚本可以做到的事情，甚至更多。 您可以使用 CLI 选项执行应用，运行基本脚本，重启服务等。 若要启动，请使用 root 或 sudo 打开配置文件，并使用你喜欢的文本编辑器：

```bash
sudo nano /etc/OliveTin/config.yaml
```

最基本的动作是一个简单的按钮，你点击它，对应命令就会在主机运行一次。 您可以在 YAML 文件中定义：

```yaml
actions:
  - title: Restart Nginx
    shell: systemctl restart nginx
```

您也可以添加自定义图标到每个动作，如Unicode emoji：

```yaml
actions:
  - title: Restart Nginx
    icon: "&#1F504"
    shell: systemctl restart nginx
```

这里不会详细介绍自定义选项，仅说一下基础的定义规则, 比如使用文本输入和下拉菜单向要运行的命令添加变量和选项。 这样配置后，OliveTin会在页面提示你输入相关参数, 之后才会执行命令。

为此，您可以运行任何程序，通过 SSH 控制远程机器，触发网络钩子等等。 查看 [官方文档](https://docs.olivetin.app/actions.html) 了解更多详情。

这里是我自己的例子：我有一个个人脚本，用来生成LXD容器, 容器里面预装了 web 服务。 通过OliveTin，我能够为像这样的脚本快速制作一个GUI：

```yaml
actions:
- title: 构建容器
  shell: sh /home/ezequiel/server-scripts/rocky-host/buildcontainer -c {{ containerName }} -d {{ domainName }} {{ softwarePackage }}
  timeout: 60
  arguments:
    - name: containerName
      title: 容器名称
      type: ascii_identifier

    - name: domainName
      title: 域名
      type: ascii_identifier

    - name: softwarePackage
      title: 默认软件
      choices:
        - title: None
          value:

        - title: Nginx
          value: -s nginx

        - title: Nginx & PHP
          value: -s nginx-php

        - title: mariadb
          value: -s mariadb
```

在前端，看起来是这样的(OliveTin有一个黑暗模式，我 *真的* 需要更改那个图标)：

![一个包含两个文本输入和一个下拉菜单的表单](olivetin/containeraction.png)

## 启用 OliveTin

一旦你拥有你想要的配置文件，只需开启并启动 OliveTin ：

```bash
sudo systemctl enable --now OliveTin
```

每次您编辑配置文件时，您都需要以通常方式重新启动服务：

```bash
sudo systemctl restart OliveTin
```

## 总结

从简单的基础命令到一些相当复杂的操作脚本, 使用 OliveTin 来运行他们是非常好的方法。 但牢记，默认一切都是 root 账号运行， 除非使用 su/sudo 在 shell 命令中更改该特定命令的用户。

因此，你应该谨慎地设置这件事， 特别是如果打算让家人访问(例如控制服务器和设备等)。

再说一遍，除非你准备好尝试并保护你自己的页面，否则不要把它放在公共服务器上。

通常情况下它很有趣, 这是一个简洁的小工具。
