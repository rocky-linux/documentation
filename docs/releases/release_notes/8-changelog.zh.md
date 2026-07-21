---
title: 8 版本的变更日志
author: Louis Abel
contributors: tianci li, Steven Spencer
tags:
  - rocky的变更日志
  - 变更日志
---

# Rocky Linux 8 变更日志

Rocky Linux版本的更改日志数据目前正在进行中。 此文档将介绍如何找到版本 8 的更改日志信息。 将会有一种更正式的方法即将到来，它也将包括版本9。 如果您想对这个信息在未来将如何出现发表意见，请查看 [这个 issue ](https://github.com/rocky-linux/peridot/issues/9) 并添加您的评论。 此外，您还可以在 [此处](https://errata.build.resf.org/) 找到版本8的当前和历史更改。

因为上游发布的更新是在我们当前的架构中发布的， 所以强烈建议所有用户在您当前的 Rocky Linux 计算机中应用 *全部* 更新（包括今天发布的内容）， 您可以通过运行 `dnf update` 来完成更新动作。

所有 Rocky Linux 组件都是由托管在[git.rockylinux.org](https://git.rockylinux.org) 上的源代码进行构建的。 此外，SRPM 与存储库将一起发布在对应的 "source" 目录中， 您可以在我们的任意镜像网站上找到它们， 镜像网站的源码包与我们发布的每个二进制 RPM 相同。
