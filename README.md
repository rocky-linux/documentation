# Contribution Guide
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-74-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Introduction

So you want to contribute to the Rocky Linux documentation, but aren't sure how to go about that? You've come to the right place. We're excited to have you on board with us.

One of our main goals for Rocky is to have not just good but GREAT documentation, and we cannot do it alone. This document will get you started and will (hopefully) ease any worries you might have about doing so. We will always be here to help, so feel free to ask questions and join in the conversation.

## Documentation Subjects

If you can dream it — or better yet, have done it before — then your subject is probably important to the Rocky Linux documentation project.

Where do you come in — both now and in the future? If you have experience with anything Linux-related and can translate that to Rocky Linux, we would like you to start writing!

## Where to Start

While you can create documentation in **any format** (seriously, we will accept it any way you create it), the preferred format is Markdown. You can easily create documents in Markdown, plus Markdown is super-easy to learn. The best way to get started with Markdown is to have a Markdown editor installed and read the tutorial. You can create Markdown files with any text editor, but most Markdown editors allow you to preview what you've input already, so they can be very helpful.

### Markdown Editor

As we've said already, the best way to create Markdown files, particularly if you've not done it before, is to grab an editor for the operating system that you use on your PC or Laptop. A simple web search for "Markdown editors" will show you a bunch to choose from.

Pick one to use that is compatible with your Operating System [ReText](https://github.com/retext-project/retext), a cross-platform Markdown editor, was used to create this document. Again, if you prefer to create your Markdown files in your text editor that you are already familiar with, that is just fine.

#### Alternate Markdown Editors

ReText is good, but if you feel like exploring your other options, there are a few:

* [Zettlr](https://www.zettlr.com) - Free, cross-platform, and open source
* [Mark Text](https://github.com/marktext/marktext) - Free, cross-platform, and open source
* [Remarkable](https://remarkableapp.github.io) - Linux and Windows, open source
* [NvChad](https://nvchad.github.io) for the `vi`/`vim` user and the `nvim` client. A lot of plugins are available to enhance the editor for markdown. See [this document](https://docs.rockylinux.org/books/nvchad/) for a nice set of installation instructions.
* [VS Code](https://code.visualstudio.com/) - A partially open source project from none other than Microsoft; VS Code is a lightweight and powerful editor available for Windows, Linux and MacOS. To contribute to this document project, you should get the following extensions: Git Graph, HTML Preview, HTML Snippets, Markdown All in One, Markdown Preview Enhanced, Markdown Preview Mermaid Support, and any more that catch your fancy.

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

## Author, Contributor, and Other Meta Content

We started to add specific meta to our documentation some time ago. The idea is to get the primary information in the meta. This is done in the source (English) documents. Here's an example of the meta information as it currently stands:

```
---
title: Document title or the title that appears in the table of contents. (this can be overridden with `.pages` by editors if necessary.) 
author: the author of the source (English) version of the document.
contributors: a comma separated list of contributors to the source document.
tested with: a comma separated list of versions example: 8.6, 9.0
tags: 
  - displayable tags
  - these are also searchable
  - they are two space indented and start with a "-" as shown here
  - generally, they should be one word
---
```

We ask those involved in translations to leave the meta as is in the document you are translating. We definitely **DO** want to acknowledge those involved in our translation efforts! That is what the all-contributors bot is for. If you scroll to the bottom of this page, you'll see a list of those who have contributed to the documentation project, even if it was just to change a word or phrase or fix an error. 

If a translator runs into a word or phrase that does not translate well from the source document to their language, we ask them to go ahead and push a change to the source document through the normal Git processes. When they do this, they definitely *should* add their name to the "contributors:" meta!

If you notice that your effort is not properly acknowledged in the all-contributors section, please let someone know in the [Mattermost channel](https://chat.rockylinux.org/rocky-linux/channels/documentation) so that we can fix it for you. Thank you to everyone who participates!

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

Once all of the above is complete, you wait for confirmation that GitHub successfully merged your request. (Or not, as the case may be.)

## More Advanced Documents

If you are wanting to add more advanced elements in your document than just text (admonitions, tables, block quotes, etc.), [this document](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) will help you get there.

## Documentation Local Server 

The advantage of having documentation running on a local server instance is that you get to see how your changes will look when they are taken to the live system. You can build a complete documentation system on your local Linux workstation or VM. This procedure isn't for everyone, and is definitely a more advanced topic. There are two documents that will get you to a nice, complete, and protected documentation system, using either Docker or LXD:

* Docker Version [here](https://docs.rockylinux.org/guides/contribute/rockydocs_web_dev/)
* LXD Version [here](https://docs.rockylinux.org/guides/contribute/mkdocs_lsyncd/)

There is a third method that will get you up and running fast without either Docker or LXD, but read the caveats of this procedure carefully:

* Fast Documentation System [here](https://docs.rockylinux.org/guides/contribute/local_docs/)

## Keep Up With The Conversation

If you haven't already, join the conversation on the [Rocky Linux Mattermost Server](https://chat.rockylinux.org/rocky-linux/) and stay up-to-date with what is going on. Join the [~Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation), or any other channel you are interested in. We'd be glad to have you with us!

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://github.com/wsoyinka"><img src="https://avatars.githubusercontent.com/u/23367125?v=4?s=100" width="100px;" alt=""/><br /><sub><b>wale soyinka</b></sub></a><br /><a href="#projectManagement-wsoyinka" title="Project Management">📆</a> <a href="#maintenance-wsoyinka" title="Maintenance">🚧</a> <a href="#content-wsoyinka" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/sspencerwire"><img src="https://avatars.githubusercontent.com/u/4265212?v=4?s=100" width="100px;" alt=""/><br /><sub><b>sspencerwire</b></sub></a><br /><a href="#projectManagement-sspencerwire" title="Project Management">📆</a> <a href="#maintenance-sspencerwire" title="Maintenance">🚧</a> <a href="#content-sspencerwire" title="Content">🖋</a></td>
      <td align="center"><a href="https://ezequiel.works"><img src="https://avatars.githubusercontent.com/u/1215780?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ezequiel Bruni</b></sub></a><br /><a href="#maintenance-EzequielBruni" title="Maintenance">🚧</a> <a href="#content-EzequielBruni" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/ambaradan"><img src="https://avatars.githubusercontent.com/u/87865413?v=4?s=100" width="100px;" alt=""/><br /><sub><b>ambaradan</b></sub></a><br /><a href="#translation-ambaradan" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/alemorvan"><img src="https://avatars.githubusercontent.com/u/3603739?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Antoine Le Morvan</b></sub></a><br /><a href="#content-alemorvan" title="Content">🖋</a> <a href="#translation-alemorvan" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/jimcat8"><img src="https://avatars.githubusercontent.com/u/86754294?v=4?s=100" width="100px;" alt=""/><br /><sub><b>tianci li</b></sub></a><br /><a href="#content-jimcat8" title="Content">🖋</a> <a href="#translation-jimcat8" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/Student"><img src="https://avatars.githubusercontent.com/u/19212264?v=4?s=100" width="100px;" alt=""/><br /><sub><b>student</b></sub></a><br /><a href="#content-Student" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/NezSez"><img src="https://avatars.githubusercontent.com/u/17833417?v=4?s=100" width="100px;" alt=""/><br /><sub><b>NezSez</b></sub></a><br /><a href="#content-NezSez" title="Content">🖋</a> <a href="#ideas-NezSez" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/justasojourner"><img src="https://avatars.githubusercontent.com/u/66750169?v=4?s=100" width="100px;" alt=""/><br /><sub><b>justasojourner</b></sub></a><br /><a href="#content-justasojourner" title="Content">🖋</a> <a href="#ideas-justasojourner" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="http://shrug.pw/"><img src="https://avatars.githubusercontent.com/u/680198?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Neil Hanlon</b></sub></a><br /><a href="#content-NeilHanlon" title="Content">🖋</a> <a href="#maintenance-NeilHanlon" title="Maintenance">🚧</a> <a href="#ideas-NeilHanlon" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/pajamian"><img src="https://avatars.githubusercontent.com/u/92609?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Peter Ajamian</b></sub></a><br /><a href="#content-pajamian" title="Content">🖋</a></td>
      <td align="center"><a href="http://www.flaviosiqueira.com.br/"><img src="https://avatars.githubusercontent.com/u/3700397?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Flávio Siqueira Prado</b></sub></a><br /><a href="#translation-Bakrog" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/Norio4"><img src="https://avatars.githubusercontent.com/u/25744143?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Norio4</b></sub></a><br /><a href="#translation-Norio4" title="Translation">🌍</a></td>
      <td align="center"><a href="https://www.volted.net/"><img src="https://avatars.githubusercontent.com/u/40760290?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sébastien Pascal-Poher</b></sub></a><br /><a href="#translation-sjpp" title="Translation">🌍</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/ltrecanao"><img src="https://avatars.githubusercontent.com/u/76416245?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lucas Trecanao</b></sub></a><br /><a href="#translation-ltrecanao" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/calderds"><img src="https://avatars.githubusercontent.com/u/37597884?v=4?s=100" width="100px;" alt=""/><br /><sub><b>calderds</b></sub></a><br /><a href="#content-calderds" title="Content">🖋</a> <a href="https://github.com/rocky-linux/documentation/pulls?q=is%3Apr+reviewed-by%3Acalderds" title="Reviewed Pull Requests">👀</a></td>
      <td align="center"><a href="https://github.com/execion"><img src="https://avatars.githubusercontent.com/u/49331776?v=4?s=100" width="100px;" alt=""/><br /><sub><b>execion</b></sub></a><br /><a href="#translation-execion" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/lillolollo"><img src="https://avatars.githubusercontent.com/u/730814?v=4?s=100" width="100px;" alt=""/><br /><sub><b>lillolollo</b></sub></a><br /><a href="#content-lillolollo" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/batashi"><img src="https://avatars.githubusercontent.com/u/6708191?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ahmed alBattashi</b></sub></a><br /><a href="#content-batashi" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/StackKorora"><img src="https://avatars.githubusercontent.com/u/42156355?v=4?s=100" width="100px;" alt=""/><br /><sub><b>StackKorora</b></sub></a><br /><a href="#content-StackKorora" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/3xtant"><img src="https://avatars.githubusercontent.com/u/13157282?v=4?s=100" width="100px;" alt=""/><br /><sub><b>3xtant</b></sub></a><br /><a href="#content-3xtant" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/almrv"><img src="https://avatars.githubusercontent.com/u/18002181?v=4?s=100" width="100px;" alt=""/><br /><sub><b>almrv</b></sub></a><br /><a href="#translation-almrv" title="Translation">🌍</a></td>
      <td align="center"><a href="https://hbjy.dev/"><img src="https://avatars.githubusercontent.com/u/22327045?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hayden</b></sub></a><br /><a href="#content-hbjydev" title="Content">🖋</a></td>
      <td align="center"><a href="https://linuxguideandhints.com/"><img src="https://avatars.githubusercontent.com/u/11469736?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Louis Abel</b></sub></a><br /><a href="#content-nazunalika" title="Content">🖋</a></td>
      <td align="center"><a href="https://www.threemysticapes.com/"><img src="https://avatars.githubusercontent.com/u/787308?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ron</b></sub></a><br /><a href="#content-tikicoder" title="Content">🖋</a></td>
      <td align="center"><a href="https://aminvakil.com/"><img src="https://avatars.githubusercontent.com/u/12948692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Amin Vakil</b></sub></a><br /><a href="#content-aminvakil" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/prasad15"><img src="https://avatars.githubusercontent.com/u/12524081?v=4?s=100" width="100px;" alt=""/><br /><sub><b>K.Prasad</b></sub></a><br /><a href="#content-prasad15" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/IncorrigiblyBelligerent"><img src="https://avatars.githubusercontent.com/u/77499937?v=4?s=100" width="100px;" alt=""/><br /><sub><b>IncorrigiblyBelligerent</b></sub></a><br /><a href="#content-IncorrigiblyBelligerent" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/jaijunior"><img src="https://avatars.githubusercontent.com/u/53584770?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jairo Nonato Júnior</b></sub></a><br /><a href="#content-jaijunior" title="Content">🖋</a></td>
      <td align="center"><a href="https://saifhalila.github.io/"><img src="https://avatars.githubusercontent.com/u/10274380?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Saif Eddine Halila</b></sub></a><br /><a href="#content-saifhalila" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/DrCool2"><img src="https://avatars.githubusercontent.com/u/32649803?v=4?s=100" width="100px;" alt=""/><br /><sub><b>DrCool2</b></sub></a><br /><a href="#content-DrCool2" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/bzuelly"><img src="https://avatars.githubusercontent.com/u/15173198?v=4?s=100" width="100px;" alt=""/><br /><sub><b>codedude</b></sub></a><br /><a href="#content-bzuelly" title="Content">🖋</a></td>
      <td align="center"><a href="https://cubeops.net/"><img src="https://avatars.githubusercontent.com/u/16643747?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Graham</b></sub></a><br /><a href="#content-gp-Airee" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/theputta"><img src="https://avatars.githubusercontent.com/u/22313054?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Aditya Putta</b></sub></a><br /><a href="#content-theputta" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/yangxuan74"><img src="https://avatars.githubusercontent.com/u/20755861?v=4?s=100" width="100px;" alt=""/><br /><sub><b>yangxuan74</b></sub></a><br /><a href="#content-yangxuan74" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/xpseudonym"><img src="https://avatars.githubusercontent.com/u/5032475?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Morgan Read</b></sub></a><br /><a href="#content-xpseudonym" title="Content">🖋</a></td>
      <td align="center"><a href="https://ersei.saggis.com/"><img src="https://avatars.githubusercontent.com/u/17993169?v=4?s=100" width="100px;" alt=""/><br /><sub><b>9p4</b></sub></a><br /><a href="#content-9p4" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/liquidspikes"><img src="https://avatars.githubusercontent.com/u/5150291?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alex Zimmerman</b></sub></a><br /><a href="#content-liquidspikes" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/viscountstyx"><img src="https://avatars.githubusercontent.com/u/46753436?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrew Faulkner</b></sub></a><br /><a href="#content-viscountstyx" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/televi"><img src="https://avatars.githubusercontent.com/u/3333248?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Todd Levi</b></sub></a><br /><a href="#content-televi" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/tahder"><img src="https://avatars.githubusercontent.com/u/5017393?v=4?s=100" width="100px;" alt=""/><br /><sub><b>tahder</b></sub></a><br /><a href="#content-tahder" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/tacahiroy"><img src="https://avatars.githubusercontent.com/u/76614?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Takahiro Yoshihara</b></sub></a><br /><a href="#content-tacahiroy" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/garthus1"><img src="https://avatars.githubusercontent.com/u/12569720?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gerard Arthus</b></sub></a><br /><a href="#content-garthus1" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/HadManySons"><img src="https://avatars.githubusercontent.com/u/3620051?v=4?s=100" width="100px;" alt=""/><br /><sub><b>HadManySons</b></sub></a><br /><a href="#content-HadManySons" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/bmayfi3ld"><img src="https://avatars.githubusercontent.com/u/563214?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Brandon Mayfield</b></sub></a><br /><a href="#content-bmayfi3ld" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/astauntonie"><img src="https://avatars.githubusercontent.com/u/25220665?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Anthony Staunton</b></sub></a><br /><a href="#content-astauntonie" title="Content">🖋</a></td>
      <td align="center"><a href="https://blog.iclouds.work/"><img src="https://avatars.githubusercontent.com/u/21030747?v=4?s=100" width="100px;" alt=""/><br /><sub><b>whg517</b></sub></a><br /><a href="#content-whg517" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/MrSkribb"><img src="https://avatars.githubusercontent.com/u/44088296?v=4?s=100" width="100px;" alt=""/><br /><sub><b>MrSkribb</b></sub></a><br /><a href="#content-MrSkribb" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/payagej"><img src="https://avatars.githubusercontent.com/u/20729061?v=4?s=100" width="100px;" alt=""/><br /><sub><b>jules</b></sub></a><br /><a href="#content-payagej" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/brendanfattig"><img src="https://avatars.githubusercontent.com/u/54815652?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Brendan Fattig</b></sub></a><br /><a href="#content-brendanfattig" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/bittin"><img src="https://avatars.githubusercontent.com/u/43197?v=4?s=100" width="100px;" alt=""/><br /><sub><b>bittin</b></sub></a><br /><a href="#content-bittin" title="Content">🖋</a></td>
      <td align="center"><a href="https://ichibariki.com/"><img src="https://avatars.githubusercontent.com/u/4787502?v=4?s=100" width="100px;" alt=""/><br /><sub><b>ichibariki</b></sub></a><br /><a href="#content-ichibariki" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/bernipuig"><img src="https://avatars.githubusercontent.com/u/12746940?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Bernat Puigdomenech Pascual</b></sub></a><br /><a href="#content-bernipuig" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/netzwergehh"><img src="https://avatars.githubusercontent.com/u/79668910?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Dennis Körner</b></sub></a><br /><a href="#content-netzwergehh" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/bezunartea"><img src="https://avatars.githubusercontent.com/u/13090619?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pedro Bezunartea López</b></sub></a><br /><a href="#translation-bezunartea" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/danopogac"><img src="https://avatars.githubusercontent.com/u/8373145?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Daniel Pogac</b></sub></a><br /><a href="#content-danopogac" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/Oats"><img src="https://avatars.githubusercontent.com/u/18314360?v=4?s=100" width="100px;" alt=""/><br /><sub><b>oats</b></sub></a><br /><a href="#content-Oats" title="Content">🖋</a></td>
      <td align="center"><a href="http://alexharden.org/"><img src="https://avatars.githubusercontent.com/u/8281207?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alex Harden</b></sub></a><br /><a href="#content-aharden" title="Content">🖋</a></td>
      <td align="center"><a href="https://jorp.xyz/"><img src="https://avatars.githubusercontent.com/u/18096435?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jordan Pisaniello</b></sub></a><br /><a href="#content-jorp" title="Content">🖋</a></td>
      <td align="center"><a href="https://hennig.mse.ufl.edu/"><img src="https://avatars.githubusercontent.com/u/8710634?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Richard Hennig</b></sub></a><br /><a href="#content-rhennig" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/caffenix"><img src="https://avatars.githubusercontent.com/u/64636709?v=4?s=100" width="100px;" alt=""/><br /><sub><b>caffenix</b></sub></a><br /><a href="#content-caffenix" title="Content">🖋</a></td>
      <td align="center"><a href="https://manickathan.ch/"><img src="https://avatars.githubusercontent.com/u/3255070?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lento Manickathan</b></sub></a><br /><a href="#content-lento234" title="Content">🖋</a></td>
      <td align="center"><a href="http://www.depts.ttu.edu/cac/"><img src="https://avatars.githubusercontent.com/u/2364484?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alan Sill</b></sub></a><br /><a href="#content-alansill" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://bandism.net/"><img src="https://avatars.githubusercontent.com/u/22633385?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ikko Ashimine</b></sub></a><br /><a href="#content-eltociear" title="Content">🖋</a></td>
      <td align="center"><a href="http://www.williamperron.com"><img src="https://avatars.githubusercontent.com/u/15235219?v=4?s=100" width="100px;" alt=""/><br /><sub><b>William Perron</b></sub></a><br /><a href="#content-williamperron" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/romh87"><img src="https://avatars.githubusercontent.com/u/81292426?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Roman Gherta</b></sub></a><br /><a href="#content-romh87" title="Content">🖋</a></td>
      <td align="center"><a href="http://cybertrouble.com"><img src="https://avatars.githubusercontent.com/u/12031564?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Yiğit can BAŞALMA</b></sub></a><br /><a href="#content-yigitbasalma" title="Content">🖋</a></td>
      <td align="center"><a href="https://github.com/markooff"><img src="https://avatars.githubusercontent.com/u/24265888?v=4?s=100" width="100px;" alt=""/><br /><sub><b>markooff</b></sub></a><br /><a href="#content-markooff" title="Content">🖋</a> <a href="#translation-markooff" title="Translation">🌍</a></td>
      <td align="center"><a href="http://www.dengwenbin.com"><img src="https://avatars.githubusercontent.com/u/20312281?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Deng Wenbin</b></sub></a><br /><a href="#translation-dengwenbin" title="Translation">🌍</a></td>
      <td align="center"><a href="https://github.com/alikates"><img src="https://avatars.githubusercontent.com/u/59802505?v=4?s=100" width="100px;" alt=""/><br /><sub><b>alikates</b></sub></a><br /><a href="#content-alikates" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/hopnux"><img src="https://avatars.githubusercontent.com/u/110078361?v=4?s=100" width="100px;" alt=""/><br /><sub><b>hopnux</b></sub></a><br /><a href="#translation-hopnux" title="Translation">🌍</a></td>
      <td align="center"><a href="https://www.breakingpitt.es"><img src="https://avatars.githubusercontent.com/u/10740572?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pedro Garcia Rodriguez</b></sub></a><br /><a href="#translation-BreakingPitt" title="Translation">🌍</a></td>
      <td align="center"><a href="http://laurenzkruty.de"><img src="https://avatars.githubusercontent.com/u/37706897?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lau</b></sub></a><br /><a href="#content-LauKr" title="Content">🖋</a></td>
      <td align="center"><a href="http://www.meteocontrol.cn"><img src="https://avatars.githubusercontent.com/u/11520535?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Serge Croisé</b></sub></a><br /><a href="#content-SergeCroise" title="Content">🖋</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
