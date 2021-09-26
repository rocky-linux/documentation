**[简体中文](README_cn.md)**

**[English](README.md)**

# 贡献指南

## 介绍

所以您想为 Rocky Linux 文档做出贡献，但不确定怎么去做？你来对地方了。我们很高兴您能加入我们。

我们对 Rocky 设计的主要目标之一是要求有很好很棒的文档，但我们并不能单独完成。本文档将帮助您入门，且希望减轻您对此的任何担忧。我们将随时为您提供帮助，因此请随时提出问题并参与对话。

## 文档主题

如果你以前做过类似主题，或者有更好的----那么你的主题对于Rocky Linux文档项目可能很重要。现在Rocky Linux版本已经可以在生产环境下使用，我们预计提交的文档数量会增加。无论是现在还是未来，如果您有任何与 Linux 相关的经验并且可以将其转换为 Rocky Linux，我们希望您开始写作！

## 从哪儿开始

虽然您可以创建任何格式的文档，但首选格式是 Markdown。您可以轻松地在 Markdown 中创建文档，而且 Markdown 非常容易学习。开始使用 Markdown 的最佳方法是安装 Markdown 编辑器并阅读教程。大多数 Markdown 编辑器都能提供即时预览的功能，因此它们非常有用。

### Markdown 编辑器

正如我们前面说过的，创建 Markdown 文件的最佳方式，是需要首先您在 PC 或笔记本电脑上使用操作系统获取一个编辑器软件。对“Markdown 编辑器”进行简单的网络搜索，您将看到一堆可供选择的内容，这其中涉及到的是`Markdown语法`。

选择一个跨平台的、与您操作系统兼容的Markdown编辑器——[ReText](https://github.com/retext-project/retext) ，用于创建此文档。同样的，如果您有更喜欢且更熟悉的Markdown编辑器，也是可以的。

#### 替代品

ReText已经很好了，但如果要使用其他的作为替代，有那么几个：

* [Zettlr](https://www.zettlr.com) - 免费、跨平台、开源
* [Mark Text](https://marktext.app) - 免费、跨平台、开源
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - 免费，windows和Linux，开源
* [Remarkable](https://remarkableapp.github.io) - 仅限Linux，开源
* [Typora](https://typora.io) - 免费和跨平台，不开源
* [Atom](https://atom.io) - 免费、跨平台、开源。不只是一个Markdown编辑器，还能将git和github进行内置集成

### Markdown 教程

通过查看[Mastering Markdown](https://guides.github.com/features/mastering-markdown/)，您可以很好地了解如何编写 Markdown 文件。

## 使用Git

与其他许多项目一样，Rocky Linux 使用“git”来管理其代码和文件，包括文档文件。本教程假定您了解 Git 及其工作原理。第二个示例也以熟悉命令行为前提。

下面列出的步骤将帮助您入门。与此同时（直到我们不可避免地开发我们的指南），您可以通过这个[免费的 Udacity 课程](https://www.udacity.com/course/version-control-with-git--ud123)深入学习 Git 。如果您没有时间这样做，这里[有一个较短的指南](https://blog.udacity.com/2015/06/a-beginners-git-github-tutorial.html)。对于中文新手用户，你可以使用[这个](https://backlog.com/git-tutorial/cn/) 或者在视频网站进行学习（大概1~3小时即可）

要提交您的文本，我们要求您**创建一个 GitHub 帐户**。当您准备好提交文件以供批准时，请按照以下简单步骤操作：

### 使用Github GUI

您可以从 GitHub 上的 Web GUI 完成几乎所有任务。这个示例告诉您，在本地计算机上创建的文件是如何添加到Rocky Linux documentation远程库的。

1. 登录到您的 GitHub 帐户。
2. 导航到位于https://github.com/rocky-linux/documentation.git的 Rocky Linux 文档远程库
3. 请检查中间部分的下拉标签以确保您是在“main”分支上。您的文档最终可能不会出现在“main”分支中，但管理员稍后会将其移动到符合逻辑的位置。
   在页面的右侧，单击“Fork”按钮，这将创建您的文档副本。
4. 在Fork副本的页面中间，就在绿色“Code”下拉菜单的左侧，选择`Add file`按钮，单击此按钮并选择`Upload files`
5. 这将为您提供一种在此处拖放文件或在计算机上浏览文件的方法。
6. 文件上传后，您需要做的下一件事就是创建一个**Pull Request**（Github的通知机制）。此请求让上游管理员知道您有一个新文件（或多个文件），您希望他们合并到上游主分支当中。
   单击屏幕左上角的`Pull Request`。
7. 在“Write”部分写一条简短的消息，让管理员知道你做了什么。（新文档、修订、建议更改等）然后提交您的更改。

### 使用Git命令行

如果您更喜欢在您的机器上本地运行 Git，您可以克隆 Rocky Linux 文档存储库，进行更改，然后提交更改。为了简单起见，从上面的 GitHub GUI 执行步骤 1-3 后面开始，然后：

1. Git clone你的远程库: `git clone https://github.com/your_fork_name/documentation.git`
2. 现在，在您的机器上，将文件添加到目录中。 
   示例： `mv /home/myname/help.md /home/myname/documentation/`
3. 接下来，为该文件名运行 Git add，添加到暂存区
   示例：`git add help.md`
4. 现在，为您所做的更改运行 git commit，提交到本地库，-m指定你要提交的信息
   示例： `Git commit -m "Added the help.md file`
5. push到你的远程库： `git push https://github.com/your_fork_name/documentation main`
6. 接下来，在web页面中，创建Pull Request。此请求让上游管理员知道您有一个新文件（或多个文件），您希望他们合并到上游 main 分支中。单击屏幕左上角的`Pull Request`。

完成上述所有操作后，您需要等待确认 Github 已成功合并您的请求。（视情况而定）

## 保持沟通

如果您还没有，请加入[Rocky Linux Mattermost 服务器](https://chat.rockylinux.org/rocky-linux/) 上的对话，了解最新动态。加入[~Documentation 频道](https://chat.rockylinux.org/rocky-linux/channels/documentation)，或您感兴趣的任何其他频道。我们很高兴与您在一起！