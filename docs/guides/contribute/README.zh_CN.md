# 贡献指南

## 介绍

如果您想对Rocky Linux文档做出贡献，但不知道如何去做，那么你来对地方了。我们很高兴您能加入我们。

我们为Rocky Linux设计的目标之一就是要有又好又棒的文档，但这些工作我们无法单独完成。本文档将帮助您入门，并且希望解答您的部分担心。我们将随时为您提供帮助，因此请随时提出问题并参与沟通对话。

## 文档主题

如果您曾经做过类似的或者有更加好的主题，您的想法或者经验可能对Rocky Linux文档项目很重要。目前的Rocky Linux版本为可用，我们预计文档提交数量会增加。

不管是现在还是未来，如果您有任何与Linux相关的经验并且愿意抽出时间将其转换为Rocky Linux，我们都希望您开始写作参与其中！

## 从哪开始

虽然您可以创建任何格式的文档，但首选的格式是Markdown（.md文件后缀名）。Markdown非常容易学习，您可以轻松的在Markdown中创建文档。开始使用Markdown的最佳方法是安装Markdown编辑器软件，大多数Markdown编辑器软件都支持即时预览的功能，这非常有用。

### Markdown编辑器软件

如前面所说，您需要在您的操作系统中安装编辑器软件。选择一个与您操作系统兼容的编辑器----例如 [ReText](https://github.com/retext-project/retext)，这是一个跨平台的Markdown编辑器，用于创建文件，当然您也可以选择其他的文本编辑器创建Markdown文件。

#### 其他Markdown编辑器

ReText 很棒，但如果您更加熟悉其他的，有那么几个：

* [Zettlr](https://www.zettlr.com) - 免费、开源和跨平台
* [Mark Text](https://marktext.app) - 免费、开源和跨平台
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - 免费、开源和，Windows 和 Linux
* [Remarkable](https://remarkableapp.github.io) - 开源，仅限Linux
* [Typora](https://typora.io) - 免费和跨平台，但不开源。
* [Atom](https://atom.io) - 免费、开源和跨平台。不仅仅是编辑器，还能与Git和Github进行集成。

### Markdown教程

教程方面可以参考这四个网站：

* [Markdown官方教程](https://markdown.com.cn/)
* [Markdown标准规范](https://commonmark.org/)
* [Github关于Markdown的指南](https://guides.github.com/features/mastering-markdown/)
* [Markdown指南](https://www.markdownguide.org/)

## 使用Git

与其他的项目一样，Rocky Linux使用 "git" 来管理其代码和文件，包括文档文件。本教程假设您了解git的工作原理、熟悉命令行为前提。

下面列出的步骤将帮助您入门。当然你可以在通过 [免费的Udacity教程](https://www.udacity.com/course/version-control-with-git--ud123) 深入学习Git。对于使用中文语言环境的，您可以在 [猴子都能懂的Git入门](https://backlog.com/git-tutorial/cn/)  或者是视频网站（大约1～3小时）去学习。

要提交您的文本文件，我们要求您*创建一个Github账户*。当准备好后，请按照以下简单步骤进行操作：

### 使用GitHub GUI

您可以在Github 上的web GUI完成几乎所有的任务。将您本地计算机创建的文件添加到Rocky Linux文档的Github存储库（也叫远程库），示例如下：

1. 导航到您的Github账户
2. 导航到位于 [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git) 的远程库
3. 请确认您位于下拉三角的的 "main" 分支上，在页面的右上角单击 **"Fork"** ，这将在你的账户下面创建一个一模一样的远程库副本。
4. 在您的副本页面，位于绿色"Code"下拉标签的左侧，点击**"Add file"** 下的 **"upload files"**
5. 将您的文件拖放到此处或者在计算机上浏览找到它们。
6. 文件上传后，需要做的第一件事情就是创建 "Pull requests"（简称PR）。它是一个通知机制，表示让上游管理员知道您有一个或多个文件，希望它们合并到上游的主分支上。
7. 在"Write"部分写一个简短的消息，让管理员知道您做了什么。然后提交您的更改。

### 从Git命令行（推荐）

如果您更加喜欢在您的机器上本地运行Git，执行了上面Github GUI的1～3步骤，然后：

1. git 克隆您Github的存储库 

    `shell > git clone https://github.com/your_fork_name/documentation.git`

2. 现在，在您的机器上将文件添加到目录中
   例如：`shell > mv /home/myname/help.md /home/myname/documentation/`

3. `cd`到对应的目录，将文件添加到暂存区，使其被追踪
   例如:  `shell > git add help.md`

4. 将文件提交到本地库（本地仓库），-m 指定您的提交说明。
   
   例如： `shell > git commit -m "Added the help.md file"`
   
5. 接下来，push推到您的远程库

     `shell > git push https://github.com/your_fork_name/documentation`

6. 在github web页面中，创建您的PR请求。

完成上述所有步骤后，等待Github管理员将其合并到上游的主分支上（不一定，视情况而定）

## 保持沟通

如果您还没有，请加入 [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) 上的对话， 加入 [~Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation) 频道，或者您感兴趣的任何其他频道。我们很高兴与您在一起！

