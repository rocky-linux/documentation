# Contribution Guide
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Introduction

So you want to contribute to the Rocky Linux documentation, but aren't sure how to go about that? You've come to the right place. We're excited to have you on board with us.

One of our main goals for Rocky is to have not just good but GREAT documentation, and we cannot do it alone. This document will get you started and will (hopefully) ease any worries you might have about doing so. We will always be here to help, so feel free to ask questions and join in the conversation.

## Documentation Subject Matter

If you can dream it — or better yet, have done it before — then your subject matter is probably important to the Rocky Linux documentation project. Now that a Rocky Linux release is available, we expect that documentation submissions will increase.

Where do you come in — both now and in the future? If you have experience with anything Linux-related and can translate that to Rocky Linux, we would like you to start writing!

## Where to Start

While you can create documentation in any format, the preferred format is Markdown. You can easily create documents in Markdown, plus Markdown is super-easy to learn. The best way to get started with Markdown is to have a Markdown editor installed and read the tutorial. You can create Markdown files with any text editor, but most Markdown editors allow you to preview what you've input already, so they can be very helpful.

### Markdown Editor

As we've said already, the best way to create Markdown files, particularly if you've not done it before, is to grab an editor for the operating system that you use on your PC or Laptop. A simple web search for "Markdown editors" will show you a bunch to choose from.

Pick one to use that is compatible with your Operating System [ReText](https://github.com/retext-project/retext), a cross-platform Markdown editor, was used to create this document. Again, if you prefer to create your Markdown files in your text editor that you are already familiar with, that is just fine.

#### Alternate Markdown Editors

ReText is good, but if you feel like exploring your other options, there are a few:

* [Zettlr](https://www.zettlr.com) - Free, cross-platform, and open source
* [Mark Text](https://marktext.app) - Free, cross-platform, and open source
* [ghostwriter](https://wereturtle.github.io/ghostwriter/) - Free, Windows and Linux, open source
* [Remarkable](https://remarkableapp.github.io) - Linux-only, open source
* [Atom](https://atom.io) - Free, cross-platform and open source. Not _only_ a Markdown editor. Has integration with Git and GitHub built-in.

### Markdown Tutorial

You can get a good feel for how to write Markdown files, by taking a look at [Mastering Markdown](https://guides.github.com/features/mastering-markdown/). This online resource will get you up-to-speed in no time.

### Admonitions and Translations

Towards the end of 2021, we started translating our documents using [Crowdin](https://crowdin.com/). We need more translators for this effort, so if you would like to translate these documents into your language, please consider joining that effort. You can find more information by joining the conversation [here](https://chat.rockylinux.org/rocky-linux/channels/documentation).

It should be noted that admonitions are **NOT** required, but if you choose to use them, they should be formatted a little differently than the default. Here is the default way of creating an admonition:
```
!!! type "optional additional title within double quotes"
    Any number of other indented markdown elements.
```
To make this work for our translators in Crowdin, however, we need to format it like this:
```
!!! type "optional additional title within double quotes"

    Any number of other indented markdown elements.
```
The first line of the text detail for the admonition must have that extra line feed. Note that each example shows that there are 4 spaces before the actual text begins. When the page is rendered, the document will not have the extra line feed. Here's what the admonition above looks like:

!!! type "optional additional title within double quotes"

    Any number of other indented markdown elements.

If you are reading this on GitHub, it will not display the admonition. You can see how it actually displays [here](https://docs.rockylinux.org/guides/contribute/).    

## Using Git

Like many other projects out there, Rocky Linux uses "git" to manage its code and files, including documentation files. This tutorial assumes a fundamental knowledge of Git and how it works. The second example also presupposes familiarity with the command line.

The steps  listed below will get you started. In the meantime (and until we inevitably develop our guide), you can learn Git in-depth with this [free Udacity course](https://www.udacity.com/course/version-control-with-git--ud123). If you don't have the time for that, here's [a shorter guide](https://blog.udacity.com/2015/06/a-beginners-git-github-tutorial.html).

To submit your text, we ask that you create a GitHub account. When you are ready to submit your written documentation for approval, follow these easy steps:

### With the GitHub GUI

You can complete almost all tasks from the web GUI on GitHub. Here's an example of adding a file you've created on your local machine to the Rocky Linux documentation GitHub repository.

1. log in to your GitHub account.
2. Navigate to the Rocky Linux Documentation repository at [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git)
3. You should be on the "Main" branch, so check the drop-down label down in the middle section to be sure you are. Your document might not ultimately end up in the "Main" branch, but admins will move it around to where it logically fits later.  
On the right-hand side of the page, click the "Fork" button, which will create your copy of the documentation.
4. In the middle of the page on the forked copy, just to the left of the Green "Code" drop-down, is an "Add file" button. Click this and choose the "Upload files" option.
5. This will give you a way to either drag and drop files here or browse to them on your computer. Go ahead and use the method which you prefer.
6. Once the file is uploaded, the next thing you need to do is create a Pull Request. This request lets the upstream administrators know that you have a new file (or files) that you would like them to merge with the master.  
Click on "Pull Request" in the upper-left of the screen.
7. Write a brief message in the "Write" section letting the administrators know what you've done. (New document, revision, suggested change, etc.,) then submit your change.

### From the Git Command-Line

If you prefer to run Git locally on your machine, you can clone the Rocky Linux Documentation repository, make changes, and then commit changes afterward. To make things simple, execute steps 1-3 on from *With the GitHub GUI* above then:

1. Git clone the repository: `git clone https://github.com/your_fork_name/documentation.git`
2. Now, on your machine, add files to the directory.  
Example: `mv /home/myname/help.md /home/myname/documentation/`
3. Next, run Git add for that file name.  
Example:  `git add help.md`
4. Now, run git commit for the changes you have made.  
Example: `git commit -m "Added the help.md file"`
5. Next, push your changes to your forked repository: `git push https://github.com/your_fork_name/documentation main`
6. Next, we repeat steps 6 and 7 above: Create a Pull Request. This request lets the upstream administrators know that you have a new file (or files) that you would like them to merge with the master branch. Click on "Pull Request" in the upper-left of the screen

Once all of the above is complete, you wait for confirmation that Github successfully merged your request. (Or not, as the case may be.)

## More Advanced Documents

If you are wanting to add more advanced elements in your document than just text (admonitions, tables, block quotes, etc.), [this document](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) will help you get there.

## Keep Up With The Conversation

If you haven't already, join the conversation on the [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) and stay up-to-date with what is going on. Join the [~Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation), or any other channel you are interested in. We'd be glad to have you with us!

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/wsoyinka"><img src="https://avatars.githubusercontent.com/u/23367125?v=4?s=100" width="100px;" alt=""/><br /><sub><b>wale soyinka</b></sub></a><br /><a href="#projectManagement-wsoyinka" title="Project Management">📆</a> <a href="#maintenance-wsoyinka" title="Maintenance">🚧</a> <a href="#content-wsoyinka" title="Content">🖋</a></td>
    <td align="center"><a href="https://github.com/sspencerwire"><img src="https://avatars.githubusercontent.com/u/4265212?v=4?s=100" width="100px;" alt=""/><br /><sub><b>sspencerwire</b></sub></a><br /><a href="#projectManagement-sspencerwire" title="Project Management">📆</a> <a href="#maintenance-sspencerwire" title="Maintenance">🚧</a> <a href="#content-sspencerwire" title="Content">🖋</a></td>
    <td align="center"><a href="https://github.com/alemorvan"><img src="https://avatars.githubusercontent.com/u/3603739?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Antoine Le Morvan</b></sub></a><br /><a href="#content-alemorvan" title="Content">🖋</a> <a href="#translation-alemorvan" title="Translation">🌍</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!