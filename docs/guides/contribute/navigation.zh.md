---
title: 导航变更
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tags:
  - contribute
  - navigation
---

# 导航变更 - 管理者/编辑者的流程文档

## 编写本文档的原因

当文档项目开始时，人们希望 Mkdocs 中的菜单尽可能自动化，使手动导航的编辑变得极少。 在生成文档几个月后，很明显的事情是——仅仅将文档放在正确的文件夹中并让 Mkdocs 生成导航并不能保证整洁。 我们需要分类，而 Mkdocs 不提供分类的功能，除非文档被放在特定的文件夹中。 Mkdocs 将使用字母顺序创建导航。 然而，创建固定导航的文件夹结构并不是全部。 即使这样，我们有时也需要额外的变更来保持事物的组织有序。 例如，在不修改小写文件夹结构的情况下进行大写。

## 目标

我们的目标是：

* 现在根据需要创建文件夹结构（将来可能需要新文件夹）
* 调整导航位置，使 Rocky Installation、Migration 和 Contribution 区域位于顶部
* 调整导航并更好地命名一些文件夹，启用正确的大小写。 例如，"DNS" 和 "File Sharing Services" 在没有经过一些操作的情况下，会显示为 "Dns" 和 "File sharing"。
* 确保这些导航文件仅限于管理者和编辑者使用

对于一些阅读本文的人来说，最后一项可能看起来是不必要的，但随着本文档的继续，它的作用会变得更加明显。

## 假设条件

假设您拥有 Rocky GitHub 存储库的本地克隆： [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation)。

## 环境变更

随着这些环境的变更，我们确实需要 "看到" 你在网站上下文中所做的任何更改对内容的影响，然后才能将内容提交到文档存储库中，随后才能 "上线"。

MkDocs 是一个 [Python](https://www.python.org) 应用程序，它使用的扩展包也是 Python 代码，这意味着运行 MkDocs 需要有一个 **正确配置的 Python 环境**。 设置 Python 以执行开发任务（运行 MkDocs 所做的任务）并不是一项简单的任务，相关说明超出了本文档的范围。 一些注意事项包括：

* Python 的版本应 >= 3.8，此外，**如果操作系统是 Linux或macOS，则必须特别注意不要使用操作系统自带的 Python 版本**。 例如，截至本文撰写时，macOS 上 Python 的系统版本仍然是 2.7。
* 运行 Python 的 'virtual environment'。 在运行 Python 应用程序项目和安装包（例如 MkDocs）时，Python 社区 **强烈建议** 为每个项目 [创建一个隔离的虚拟环境](https://realpython.com/python-virtual-environments-a-primer/) 。
* 使用支持 Python 的现代 IDE（Integrated Development Environment）。 两个流行的 IDE 也集成了对运行虚拟环境的支持，分别是：
    * PyCharm - Python 的领先 IDE（免费版本可用）https://www.jetbrains.com/pycharm/
    * Visual Studio Code - 来自微软（免费版本可用）https://code.visualstudio.com

有效地做到这一点需要：

* 设置一个新的 Python 项目，理想情况下，它应该使用虚拟环境（如上）。
* 安装 `mkdocs`
* 安装一些 python 插件
* 克隆 Rocky GitHub 存储库：[https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* 链接到克隆的文档存储库中的 `docs` 文件夹（如果你想加载正确的文件夹，你也可以只修改 mkdocs.yml 文件，但链接可使你的 mkdocs 环境更整洁）
* 在 docs.rockylinux.org 的克隆中运行 `mkdocs serve`

!!! tip "提示"

    您可以通过使用 "Contribute" 菜单的 "Local Documentation" 部分中的任何步骤，为 `mkdocs` 构建完全独立的环境。

!!! Note "说明"

    本文档是在 Linux 环境中编写的。 如果你的环境不同（Windows 或 Mac），那么你需要研究如何匹配这些步骤。 阅读此内容的编辑者或管理者可以向它提交更改，以便为这些环境添加步骤。

### 安装

* 使用 python 环境安装 `mkdocs`：`pip install mkdocs`
* 安装需要的插件：`pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-redirects mkdocs-i18n`
* 克隆存储库（如上所述）

### 链接并允许 `mkdocs`

在 docs.rockylinux.org 本地克隆中，执行以下操作。 这里假设了文档克隆的位置，您可以根据需要进行修改：

`ln -s /home/username/documentation/docs docs`

此外，如果你愿意，可以修改 `mkdocs.yml` 文件的本地副本以设置路径。 如果使用此方法，您需要修改此行以指向您的 `documentation/docs` 文件夹：

```
docs_dir: 'docs/docs'
```

完成后，您可以尝试运行 `mkdocs serve` ，看看是否得到了您想要的内容。 这将在你的本地主机上运行，端口为8000；例如：<a href="http://127.0.0.1:8000/">http://127.0.0.1:8000/</a> 

## 导航和其他更改

导航是通过 mkdocs `.pages` 文件 **或** 文档头部的 "title:" 元数据值处理的。 `.pages` 文件并不复杂，但是，如果遗漏了某些内容，可能会导致服务器无法加载。 这就是为什么此程序 **仅** 适用于管理者和编辑者。 这些人拥有适合的工具（mkdocs 的本地安装，文档和 docs.rockylinux.org 的克隆），这样推送到 GitHub 的内容就不会破坏文档网站的服务。 不能期望贡献者满足其中任何一个要求。


### `.pages` 文件

如前所述，`.pages` 文件通常非常简单。 它们是 YAML 格式的文件，`mkdocs` 在渲染内容之前会读取它们。 让我们来看看一个更复杂的 `.pages` 文件，它是为帮助格式化侧边导航而创建的：

```
---
nav:
    - ... | index*.md
    - ... | installation*.md
    - ... | migrate2rocky*.md
    - Contribute: contribute
    - Automation: automation
    - Backup & Sync: backup
    - Content Management: cms
    - Communications: communications
    - Containers: containers
    - Database: database
    - Desktop: desktop
    - DNS: dns
    - Email: email
    - File Sharing Services: file_sharing
    - Git: git
    - Interoperability: interoperability
    - Mirror Management: mirror_management
    - Network: network
    - Package Management: package_management
    - ...

```
这里，`index*md` 显示了 "Guides Home: "，`installation*.md` 显示了 "Installing Rocky Linux" 文档链接，`migrate2rocky*.md` 显示了 "Migrating To Rocky Linux" 文档链接。 每个链接中 "*" 表示允许该文档使用 _任何_ 语言。 最后，通过将 "Contribute" 放在下一级，它就落到了这些项目之下，而不是按照正常的字母顺序排序。 从列表向下看，您可以看到每个项目的作用。 请注意，在 "Package Management: package_management" 条目之后，实际上还有两个文件夹（security 和 web）。 这些不需要任何额外的格式，所以我们只是告诉 `mkdocs` 用 "-..." 正常加载它们。

您还可以在实际文件中使用 YAML 格式。 这样做的原因可能是文件的开头标题太长，以至于在导航部分显示不佳。  例如，以这篇文档标题 "# `mod_ssl` on Rocky Linux in an httpd Apache Web-Server Environment" 为例。 这实在太长了。 一旦打开 "Web" 导航项，它在侧边导航中的显示效果非常差。 要解决这个问题，您可以与作者一起更改他的标题，或者，您可以通过在文档内的标题之前添加 title 来更改它在菜单中的显示方式。 对于示例文档，添加了一个 title：
```
---
title: Apache With `mod_ssl`
---
```
这会更改导航的标题，但会在文档中保留作者的原始标题。

可能不太需要额外的 `.pages` 文件。 应该节约使用 .pages 文件。

## 结论

虽然需要进行导航更改且并不困难，但存在破坏实时文档的可能性。 因此，只有具有适当工具的管理员和编辑者才有权编辑这些文件。 拥有一个完整的环境来查看实时页面的外观，可以防止管理者或编辑者在编辑这些文件时出错，导致破坏实时文档。
