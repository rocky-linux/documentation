---
title: 初学者贡献指南
author: Krista Burdine
contributors: Ezequiel Bruni, Steven Spencer, Ganna Zhyrnova
tags:
  - contributing
  - documentation
  - beginners
  - howto
---

# 首次贡献指南

*凡事都有个开头。 如果这是您第一次在 GitHub 上为开源文档做出贡献，恭喜您迈出了这一步。 我们迫不及待地想听听你要说什么！*

## Git 和 GitHub

我们所有的贡献者使用说明都预先假定您有一个 GitHub 账户。 如果你从来没有做过，现在是时候了。 如果你有12分钟的时间，可以从 [ Git 和 GitHub 入门指南](https://www.udacity.com/blog/2015/06/a-beginners-git-github-tutorial.html) 中学习 GitHub 的基本知识。

你可能一开始并没有为 Rocky Linux 创建和管理存储库，但这个 [Hello World](https://docs.github.com/en/get-started/quickstart/hello-world) 教程会引导你创建 GitHub 账户，学习术语并了解存储库的工作原理。 重点学习如何对现有文档进行更新和提交（Commit），以及如何创建拉取请求（Pr）。

## Markdown

Markdown 是一种简单的语言，允许您在同一文件中包含格式、代码和纯文本。 首次更新文档时，请遵循现有代码。 用不了多久，您就可以开始探索其他功能了。 当时机成熟时，以下就是基础。

- [基础 Markdown](https://www.markdownguide.org/basic-syntax#code)
- [扩展 Markdown](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)
- 在存储库中，我们还使用了一些更[高级的格式选项](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/)

## 本地存储库编辑器

要创建本地存储库，首先找到并安装一个适用于您的计算机和操作系统的 Markdown 编辑器。 这里有一些选择，但还有其他选择。 使用你所知道的就可以了。

- [ReText](https://github.com/retext-project/retext) - 免费、跨平台、开源
- [Zettlr](https://www.zettlr.com/) - 免费、跨平台、开源
- [MarkText](https://github.com/marktext/marktext) - 免费、跨平台、开源
- [Remarkable](https://remarkableapp.github.io/) - 适用于 Linux 和 Windows，开源
- 用于 vi/vim 用户和 nvim客户端的 [NvChad](https://nvchad.com/)。 有很多插件可以增强 Markdown 编辑器。 请参阅 [本文档](https://docs.rockylinux.org/books/nvchad/) 以获取一套很好的安装说明。
- [VS Code](https://code.visualstudio.com/) - 部分开源，由微软提供。 VS Code 是一个轻量级且功能强大的编辑器，可用于 Windows、Linux 和 MacOS 。 要为这个文档项目做出贡献，您应该获取以下扩展程序：Git Graph、HTML Preview、HTML Snippets、Markdown All in One、Markdown Preview Enhanced、Markdown Preview Mermaid Support 以及任何您喜欢的扩展程序。

## 创建本地存储库

安装好 Markdown 编辑器后，按照说明将其连接到您的 GitHub 帐户，并将您的存储库下载到本地计算机。 每次准备更新文档时，请按照以下步骤将本地和在线分支与 main 分支同步，以确保您使用的是最新版本：

1. 在 GitHub 中，将文档存储库的分支与 main 分支同步。
2. 按照你 Markdown 编辑器的说明，将你当前的 fork 与本地机器同步。
3. 在您的 Markdown 编辑器中，打开您要修改的文档。
4. 修改文档。
5. 保存。
6. 在您的编辑器中提交（Commit）您的更改，这应该会将您的本地存储库与您的在线分支同步。
7. 在 GitHub 中，在你的 fork 中找到更新的文档，并创建一个 Pull Request，将其与主文档合并。

## 提交更新

*添加遗漏的单词、更正错误或澄清令人困惑的文本。*

1. 从要更新的页面开始。

    点击您要更新的文档右上角的 "Edit" 铅笔。 您将被引领到 GitHub 上的原始文档。

    当您第一次向 RL 仓库贡献代码时，您将看到一个绿色按钮，提示您 "**Fork** this **repository** and propose changes."。 这将创建 RL 存储库的副本，您可以在其中进行建议的编辑。 只需点击绿色按钮并继续。

2. 进行更改

    遵循 Markdown 格式。 例如，也许有一个单词遗漏了，或者第 21 行的链接需要修复。 做出必要的改变。

3. 提出更改建议

    在页面底部，在标题为 "**Propose changes"** 的区块标题中写一行描述。 参考文档顶部的文件名是有帮助的，但不是必需的。

    因此，如果你更新了 Markdown 文本第 21 行中的链接，你会说 "Update README.md with correct links."。

    **注意：用现在时态描述你的操作。**

    然后单击 "Propose changes"，这将把您的更改 **Commit** 到您 fork 的存储库的完整文档中去。

4. 审核更改

    现在你可以逐行查看你所做的工作。 你是否遗漏了一些东西？ 返回上一页并再次更正（你必须重新开始），然后再次单击 "Propose Changes"。

    文档变成您想要的样子后，单击绿色按钮 "Create Pull Request"。 这又提供了一次机会来再次检查您的更改并确认文档已准备好。

5. 创建 PR

    到目前为止，您的所有工作都是在您自己的存储库中完成的，没有机会破坏 RL main 存储库。 接下来，您将其提交给文档团队，以将您的版本合并到文档的 main 版本中。

    点击 "Create Pull Request" 的大绿色按钮。 好消息是，你还没有破坏任何东西，因为现在它要交给 RL 文档团队进行审查。

6. 等待

    RL 团队收到您的请求后，他们将以三种方式之一作出回应。

    - 接受并合并您的 PR
    - 提出反馈意见并要求更改
    - 拒绝你的 PR 并解释原因

    最后一个回应不大可能出现。 我们真的很想在这里包括你的观点！ 如果你必须进行更改，你会突然明白为什么需要本地存储库。 团队可以 [告诉您](https://chat.rockylinux.org/rocky-linux/channels/documentation) 下一步该怎么做。 好消息是，它仍然是可以解决的。 请关注该请求的评论部分，以了解需要进一步提供哪些信息。

    否则，您的请求将被接受并合并。 欢迎加入团队，您现在正式成为了贡献者！ 过几天，你的名字就会出现在《贡献者指南》底部的 all-contributors 名单上。
