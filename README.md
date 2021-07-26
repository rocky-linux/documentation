# Contribution Guide

## Introduction

So you want to contribute to the Rocky Linux documentation, but aren't sure how to go about that? You've come to the right place. We're excited to have you on board with us.

One of our big goals for Rocky is to have not just good, but GREAT documentation, and we can't do it alone. This document will get you started, and will (hopefully) allay any worries you might have about doing so. We're always here to help, too, so feel free to ask questions and join in the conversation.

## Documentation Subject Matter

If you can dream it — or better yet, have done it before — then your subject matter is probably important to the Rocky Linux documentation project. Now that a Rocky Linux release is available, we expect that documentation submissions will increase.

This is where you come in — both now and in the future. If you have experience with anything Linux-related, and can translate that to Rocky Linux, then we want you to start writing!

## Where to Start

While you can create documentation in any format, the preferred format is Markdown. You can easily create documents in Markdown, plus Markdown is super-easy to learn. The best way to get started with Markdown is to have a Markdown editor installed and read the tutorial. You can create Markdown files with any text editor, but most Markdown editors allow you to preview what you've input already, so they can be very helpful.

### Markdown Editor

As we've said already, the best way to create Markdown files, particularly if you've not done it before, is to grab an editor for the operating system that you use on your PC or Laptop. A simple web search for "Markdown editors" will show you a bunch to choose from.

Pick one that is compatible with your OS and get started. This particular How-To doc was created with [ReText](https://github.com/retext-project/retext), a cross-platform Markdown editor. Again, if you'd prefer to create your Markdown files in your own text editor that you are already familiar with, that's no problem at all.

#### Alternate Markdown Editors

ReText is good, but if you feel like exploring your other options, there are a few:

* [Zettlr](https://www.zettlr.com) - Free, cross-platform, and open source
* [Mark Text](https://marktext.app) - Free, cross-platform, and open source
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - Free, Windows and Linux, open source
* [Remarkable](https://remarkableapp.github.io) - Linux-only, open source
* [Typora](https://typora.io) - Free and cross-platform, but *not* open source
* [Atom](https://atom.io) - Free, cross-platform and open source. Not _only_ a Markdown editor. Has integration with Git and GitHub built-in.

### Markdown Tutorial

You can get a good feel for how to write Markdown files, by taking a look at [Mastering Markdown](https://guides.github.com/features/mastering-markdown/). This online resource will get you up-to-speed in no time.

## Using Git

Rocky Linux, like loads of other projects out there, uses "git" to manage its code and files, including documentation files. This tutorial assumes a very basic knowledge of git, and how it works. The second example also presupposes familiarity with the command line.

The steps listed below will get you started. In the meantime (and until we inevitably develop our own guide), you can learn Git in-depth with this [free Udacity course](https://www.udacity.com/course/version-control-with-git--ud123). If you don't have the time for that, here's [a shorter guide](https://blog.udacity.com/2015/06/a-beginners-git-github-tutorial.html).

In order to submit your text, we ask that you create a GitHub account. When you are ready to submit your written documentation for approval, follow these easy steps:

### With the GitHub GUI

Most tasks can be completed from the web GUI on GitHub. Here's an example of adding a file you've created on your local machine to the Rocky Linux documentation GitHub repository.

1. Login to your GitHub account.
2. Navigate to the Rocky Linux Documentation repository at: [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git)
3. You should be on the "Main" branch, so check the drop down label down in the middle section, just to be sure you are. Your document might not ultimately end up in the "Main" branch, but admins will move it around to where it logically fits later.  
On the right-hand side of the page, click the "Fork" button, which will create your own copy of the documentation.
4. In the middle of the page on the forked copy, just to the left of the Green "Code" drop down, is an "Add file" button. Click this and choose the "Upload files" option.
5. This will give you a way to either drag and drop files here, or to browse to them on your computer. Go ahead and use the method you are most comfortable with.
6. Once the file is uploaded, the next thing you need to do is create a Pull Request. This request lets the upstream administrators know that you've got a new file (or files) that you would like them to merge with the master.  
Click on "Pull Request" in the upper-left of the screen.
7. Write a brief message in the "Write" section letting the administrators know what you've done. (New document, revision, suggested change, etc.,) then submit your change.

### From the Git Command-Line

If you prefer to run Git locally on your own machine, you can clone the Rocky Linux Documentation repository, make changes, and then do a commit changes afterwards. To make things super-easy, do steps 1-3 on *From Git Gui* above then:

1. Git clone the repository: `git clone https://github.com/your_fork_name/documentation.git`
2. Now, on your own machine, add files to the directory.  
Example: `mv /home/myname/help.md /home/myname/documentation/`
3. Next, run git add for that file name.  
Example:  `git add help.md`
4. Now, run git commit for the changes you have made.  
Example: `git commit -m "Added the help.md file"
5. Next, push your changes to your forked repository: `git push https://github.com/your_fork_name/documentation main`
6. Next, we repeat step 6 and 7 above: ...create a Pull Request. This request lets the upstream administrators know that you've got a new file (or files) that you would like them to merge with the master branch. Click on "Pull Request" in the upper-left of the screen

Once all of that is done, you simply wait for confirmation that your request has been successfully merged. (Or not, as the case may be.)

## Keep Up With The Conversation

If you haven't already, join the conversation on the [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) and stay up-to-date with what is going on. Join the [~Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation), or any other channel you are interested in. We'd be glad to have you with us!
