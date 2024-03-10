---
title: 在 GitHub 上创建新文档
author: Ezequiel Bruni
contributors: Grammaresque, Ganna Zhyrnova
tags:
  - contributing
  - documentation
---

# 如何在 GitHub 中创建新文档

_当您准备好提交原始书面文档以供审批时，请执行以下简单步骤：_


## 使用 GitHub GUI

您几乎可以在 GitHub 上的 Web 图形用户界面中完成所有任务。 下面是将您在本地计算机上创建的文件添加到 Rocky Linux Documentation GitHub 存储库的示例。



1. 登录您的 GitHub 账户。
2. 导航到 Rocky Linux Documentation 存储库地址 [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation)。
3. 您应该在 "Main" 分支上，所以请检查中间部分的下拉标签，以确保您是这样做的。 您的文档最终可能不会出现在 "Main" 分支中，但管理员稍后会将其移动到逻辑上的适合位置。
4. 在页面右侧，单击 "Fork" 按钮，这将创建属于您的文档副本。
5. 在 fork 副本的页面中间，绿色 "Code" 下拉列表的左侧，是一个 "Add file" 按钮。 点击此按钮，选择 "Upload files" 选项。
6. 这将允许您将文件拖放到此处或在您的计算机上浏览到它们。 继续使用你喜欢的方法。
7. 上传文件后，接下来需要做的就是创建 PR 。 此请求会让上游管理员知道您有一个（或多个）希望与 main 分支合并的新文件。
8. 点击屏幕左上角的 "Pull Request"。
9. 在 "Write" 部分写一条简短的消息，让管理员知道您做了什么。 比如新文档、修改、建议更改等。然后提交您的变更。


## 使用 Git 命令行

如果您更喜欢在本地计算机上运行 Git，则可以克隆 [Rocky Linux Documentation](https://github.com/rocky-linux/documentation) 存储库，进行更改并提交更改。 为了简单起见，使用上述 **使用 GitHub GUI** 方法执行步骤 1-3 ，然后：



1. 使用 Git 命令克隆存储库：git clone https://github.com/your_fork_name/documentation.git
2. 现在，在您的计算机上，将新文件添加到该目录中。
3. 例如这样的命令：mv /home/myname/help.md /home/myname/documentation/
4. 接下来，为该文件名运行 git add 命令。
5. 示例：git added help.md
6. 现在，运行 git commit 命令以提交您所做的更改。
7. 例如：git commit -m "Added the help.md file"
8. 接下来，将您的更改推送到您的分支存储库：git push https://github.com/your_fork_name/documentation main
9. 接下来重复上述步骤 6 和 7：创建 PR 。 此请求会让上游管理员知道您有一个（或多个）希望与 main 分支合并的新文件。 点击屏幕左上角的 "Pull Request"。

请注意 PR 中的评论，以获取请求的修改和解释。 
