# 贡献指南

## 简介

所以你想为Rocky Linux的文档做出贡献，但不知道如何去做？你已经来到了正确的地方。我们很高兴你能加入我们的行列。我们对Rocky的主要目标之一是不仅要有好的，而且要有伟大的文档，而我们不能独自完成。这份文件将使你开始工作，并将（希望）减轻你可能对这样做的任何担忧。我们会一直在这里提供帮助，所以请随时提出问题并加入对话。

## 文档主题内容

如果你能梦想成真--或者更好的是，你曾经做过--那么你的主题可能对Rocky Linux文档项目很重要。现在有了Rocky Linux版本，我们预计提交的文档将会增加。

现在和将来，你的作用在哪里？如果你有任何与Linux相关的经验，并能将其转化为Rocky Linux，我们希望你能开始写作

## 从哪里开始

虽然你可以用任何格式创建文档，但首选格式是Markdown。你可以很容易地用Markdown创建文档，另外Markdown也超级容易学习。开始使用Markdown的最好方法是安装一个Markdown编辑器并阅读教程。你可以用任何文本编辑器来创建Markdown文件，但大多数Markdown编辑器允许你预览你已经输入的内容，所以它们会很有帮助。

### Markdown 编辑器

正如我们已经说过的，创建Markdown文件的最好方法，特别是如果你以前没有做过的话，是为你的PC或Laptop上使用的操作系统抓一个编辑器。在网上简单地搜索一下 "Markdown编辑器"，就会发现有一堆可供选择的编辑器。

挑选一个与你的操作系统兼容的产品来使用 [ReText](https://github.com/retext-project/retext), 一个跨平台的Markdown编辑器，被用来创建这个文件。同样，如果你喜欢在你已经熟悉的文本编辑器中创建你的Markdown文件，那也很好。

#### 替代的 Markdown 编辑器

ReText很好，但如果你觉得要探索你的其他选择，有几个选择。

* [Zettlr](https://www.zettlr.com) - 免费、跨平台和开放源代码
* [Mark Text](https://marktext.app) - 免费、跨平台和开放源代码
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - 免费，Windows和Linux，开放源代码
* [Remarkable](https://remarkableapp.github.io) - Linux-only, 开放源代码
* [Typora](https://typora.io) - 免费和跨平台，但 *不* 开放源代码
* [Atom](https://atom.io) - 免费的、跨平台的和开源的。不仅仅是一个Markdown编辑器。内置了与Git和GitHub的集成。是跨平台的，但不是*开源的。


### Markdown 教程

你可以通过查看以下内容，对如何编写Markdown文件有一个良好的感觉 [掌握 Markdown](https://guides.github.com/features/mastering-markdown/). 这一在线资源将使你很快进入状态。

## 使用 Git

像其他许多项目一样，Rocky Linux使用 "git "来管理其代码和文件，包括文档文件。本教程假定对Git及其工作原理有基本了解。第二个例子也是以熟悉命令行为前提的。

下面列出的步骤可以让你开始学习。同时（在我们不可避免地开发出我们的指南之前），你可以通过这个深入学习Git [免费的Udacity课程](https://www.udacity.com/course/version-control-with-git--ud123). 如果你没有时间，这里有 [一个较短的指南](https://blog.udacity.com/2015/06/a-beginners-git-github-tutorial.html).

为了提交你的文本，我们要求你创建一个GitHub账户。当你准备提交你的书面文件供批准时，请遵循这些简单的步骤。

### 使用 GitHub GUI

你可以通过GitHub上的Web GUI完成几乎所有的任务。下面是一个将你在本地机器上创建的文件添加到 Rocky Linux 文档 GitHub 仓库的例子。

1. 登录到你的GitHub账户。
2. 导航到Rocky Linux文档库，地址是 [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git)
3. 你应该在 "Main" 分支上，所以检查中间部分的下拉标签，以确定你在那里。你的文件最终可能不会出现在 "主 "分支中，但管理员会在以后将其移动到符合逻辑的地方。 在页面的右侧，点击 "Fork "按钮，这将创建你的文件副本。
4. 在分叉副本的页面中间，就在绿色 "代码" 下拉菜单的左边，有一个 "添加文件" 按钮。点击它并选择 "上传文件"选项。
5. 5.这将给你提供一种方法，可以在这里拖放文件或在你的电脑上浏览它们。继续并使用你喜欢的方法。
6. 一旦文件被上传，你需要做的下一件事就是创建一个拉动请求。这个请求让上游管理员知道你有一个新的文件（或多个文件），你希望他们与主文件合并。 点击屏幕左上角的 "Pull Request"。
7. 在 "写 "部分写一条简短的信息，让管理员知道你做了什么。(新文件、修订、建议修改等)，然后提交你的修改。

### 在Git命令行中

如果你喜欢在你的机器上运行 Git，你可以克隆 Rocky Linux 文档仓库，进行修改，然后提交修改。为了简单起见，从上面的*使用GitHub GUI*开始执行步骤1-3，然后:

1. 用Git克隆存储库: `git clone https://github.com/your_fork_name/documentation.git`
2. 现在，在你的机器上，将文件添加到该目录。  
例: `mv /home/myname/help.md /home/myname/documentation/`
3. 接下来，为该文件名运行 Git add 
例:  `git add help.md`
4. 现在对你所作的修改进行git commit
例: `Git commit -m "Added the help.md file"
5. 接下来，推送你的改动到你的仓库分支。 `git push https://github.com/your_fork_name/documentation main`
6. 接下来，我们重复上面的步骤6和7。创建一个拉取请求。这个请求让上游管理员知道，你有一个（或多个）新文件，希望他们与主分支合并。点击屏幕左上角的 "Pull Request"。

一旦上述所有工作完成，你就等待Github成功合并你的请求的确认。(或者不合并，视情况而定)。

## 跟上对话的节奏

如果你还没有，请加入我们的对话。 [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) 并随时了解最新的情况。加入我们 [文档频道](https://chat.rockylinux.org/rocky-linux/channels/documentation), 或任何其他你感兴趣的频道。我们很高兴你能和我们在一起!
