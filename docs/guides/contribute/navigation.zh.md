---
title: 导航更改
contributor: tianci li
date: 2021-10-15
---





# 导航更改 - 管理者/编辑者的流程文档

## 编写本文档的原因

当文档项目开始时，人们总是希望MKdocs中的菜单尽可能的自动化，从而减少人为手动编辑导航的次数。在生成文档的几个月后，很明显，仅仅将文档放在正确的文件夹中并让Mkdocs生成导航，并不能保持文档的干净整洁。我们需要分类，但是Mkdocs并不提供，除非将文档放在特定的文件夹中。然而，创建一个修复导航的文件夹结构并不能解决全部问题。即使这样做了，有时候也需要额外的更改才能使事情井井有条。例如，在不修改小写文件夹结构的情况下使用大写。

## 目标

我们的目标是：

* 现在根据需要创建文件夹结构（未来可能需要新的文件夹）
* 调整导航，使Rocky Installation、Migration和Contribution位于导航的顶部
* 调整导航后更好的命名一些文件夹，并且启用正确的大小写。例如，"DNS" 和 "File Sharing Services"在不进行任何操作的情况下，则它们以"Dns" 和 "File sharing" 的形式出现
* 确保这些导航文件的权限仅限于管理者和编辑者

最后一项对阅读文本的某些人来说似乎没有必要，但随着文档的继续，它将变得更加清晰。

## 假设

假设您拥有了Rocky Github repository的clone本地库: [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## 环境变化

随之而来的是一种真正的需求，即在内容提交到文档存储库之前，在网站的上下文中，您所做的任何更改都会对内容产生怎样的影响，然后才会“上线”。

MkDocs是一个 [Python](https://www.python.org) 应用程序，它使用的额外包也是Python代码。也就是说，运行Mkdocs所需的环境是 **正确配置的Python环境**。为开发任务（development tasks）设置Python（运行Mkdocs就是这么做的）并不是一个简单的任务，关于它的说明超过了本文档的范围，一些注意事项包括：

* Python的版本应该 >=3.8 ，另外 **如果计算机运行Linux/macOS，必须注意不要使用计算机系统自带的Python版本**. 例如，在撰写本文档时，macOS自带的Python版本仍然是2.7
* 运行Python的 'virtual environment'（虚拟环境）。 在运行Python应用程序项目和安装包时，例如Mkdocs，Python社区 **强烈建议** 为每个项目 [创建一个隔离的虚拟环境](https://realpython.com/python-virtual-environments-a-primer/) 
* 使用支持Python的IDE（集成开发环境）。两个流行的IDE对运行“虚拟环境”有很好的支持，它们是：
  * PyCharm - (提供免费版本)  https://www.jetbrains.com/pycharm/
  * 来自微软的 Visual Studio Code-(提供免费版本) https://code.visualstudio.com

除了上面的要求外，还需要：

* 建一个新的Python项目，理想情况下，该项目使用“虚拟环境”
* 安装 `mkdocs`
* 安装一些Python插件
* clone这个Rocky Github 远程库到你的本地：[https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* 链接到clone 远程库中的'docs'文件夹（如果您希望加载正确的文件夹，可以只修改mkdocs.yml文件，但链接可以保持mkdocs环境的干净）
* 在您的docs.rockylinux.org clone中运行`mkdocs serve` 

!!! note "笔记"
    本文档在GNU/Linux环境中编写，如果您的环境不同（Windows或Mac），那么您需要进行一些研究来匹配其中的一些步骤。阅读此文件的编辑者或管理者可以提交更改，以添加针对这些环境的步骤。

### 安装

* 安装 `mkdocs` 和Python环境: `pip install mkdocs`
* 安装需要的插件:  `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-i18n`
* Clone the repository，克隆存储库或者叫远程库 (如上所述)

### 链接和运行 `mkdocs`

在您的docs.rockylinux.org本地（clone），执行以下操作。假设这是您的clone文档位置，因此请根据需要进行更改：

`ln -s /home/username/documentation/docs docs`

同样的，如果愿意，您可以修改 `mkdocs.yml` 文件的本地副本来设置路径。如果使用此方法，您需要修改此行以指向您的`documentation/docs` 文件夹:

```
docs_dir: 'docs/docs'
```

完成后，您可以尝试运行 `mkdocs serve` 来查看是否获得了所需的内容.。这将在端口8000的本地主机上运行，例如 [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## 导航与其他更改

导航由Mkdocs`.pages` 文件处理。并不是很复杂，但是，如果遗漏了一些内容，可能导致服务器无法加载，这也是为什么这个过程**仅**适用于管理者与编辑者的原因。这些人将准备好工具（本地安装Mkdocs，以及文档和docs.rockylinux.org的克隆），这样推送和合并到Github的内容就不会中断文档网站的服务。不能期望贡献者具备这些要求中的任何一个。

### `.pages` 文件

如前面所述，.pages 文件通常非常简单。它们是一个YAML格式的文件，`mkdocs`会在呈现内容之前读取它。要查看一个更加复杂的`.pages`文件，让我们看看为帮助格式化侧边导航而创建的内容：

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

在这里， `index*md` 显示的是 "Guides Home: ", `installation*.md` 显示的是"Installing Rocky Linux" 文档链接， `migrate2rocky*.md` 显示的是"Migrating To Rocky Linux" 文档链接。每个链接中的 " * " 允许该文档使用_任意语言_。最后，通过将"Contribute"放在下一个位置，它将位于这些项的下面，而不是按照正常的字母顺序排序。如果看一下清单，您可以看到每一项都在做什么。请注意，在 "Package Management: package_management" 的后面，实际上还有两个文件夹——security 和 web，这些不需要任何额外的格式，我们只是告诉 `mkdocs`用"-..."正常加载它们。

您还可以在实际文件中使用YAML格式。这样做的一个原因可能是文件的开始标题太长，以至于它在导航部分不能很好的显示。例如， "# `mod_ssl` on Rocky Linux in an httpd Apache Web-Server Environment" 这样的文档标题就太长了，当web导航被打开时，它在侧边导航栏上的显示就非常糟糕。要解决这个问题，您可以与作者一起合作更改其标题（heading），也可以通过在文档的heading之前添加 **title** 来更改其在菜单中的显示方式。对于示例文档，添加了一个 title ：

```
---
title: Apache With `mod_ssl`
---
```

就导航来说，这将会更改标题，但会在文档中保留作者的原始标题。

可能不需要太多额外的 .pages文件，它们应该被合理的节约使用。

## 结尾

虽然可能被需要的导航更改并不困难，但是存在破坏实时文档的可能性。因此，只有具备适当工具的管理者和编辑者才有权限编辑这些文件。拥有一个完整环境来查看实时页面的外观，可防止管理者或编辑者在编辑这些文件时犯错误，从而破坏实时文档