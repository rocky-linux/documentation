---
title: Beginner Contributors Guide
author: Krista Burdine
contributors: Ezequiel Bruni, Steven Spencer, Ganna Zhyrnova
tags:
  - contributing
  - documentation
  - beginners
  - howto
---

# First-Time Contributor Guide

*Everybody starts somewhere. If this is the first time you have contributed to open source documentation on GitHub, congratulations on taking this step. We can not wait to see what you have to say!*

## Git and GitHub

All of our contributor instructions presuppose you have a GitHub account. If you have never done that, now is the time. If you have 12 minutes, learn the basics of what GitHub is with the [Beginner’s Guide to Git and GitHub](https://www.udacity.com/blog/2015/06/a-beginners-git-github-tutorial.html) from Udemy.

You may not start out creating and managing repositories for Rocky Linux, but this [Hello World tutorial](https://docs.github.com/en/get-started/quickstart/hello-world) walks you through creating a GitHub account, learning the lingo, and understanding how repositories work. Focus on learning how to make and Commit updates to existing docs, and how to create a Pull Request.

## Markdown

Markdown is an easy language that allows you to include formatting, code, and plain text in the same file. The first time you update a document, follow the existing code. It will not be long before you are ready to explore additional features. When the time comes, here are the basics.

- [Basic Markdown](https://www.markdownguide.org/basic-syntax#code)
- [Extended Markdown](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)
- Some of the more [advanced formatting](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) options we use in our repository

## Local repository editor

To create a local repository, first find and install a Markdown editor that works with your computer and operating system. Here are some options, but there are others. Use what you know.

- [ReText](https://github.com/retext-project/retext) - Free, cross-platform, and open source
- [Zettlr](https://www.zettlr.com/) - Free, cross-platform, and open source
- [MarkText](https://github.com/marktext/marktext) - Free, cross-platform, and open source
- [Remarkable](https://remarkableapp.github.io/) - Linux and Windows, open source
- [NvChad](https://nvchad.com/) for the vi/vim user and the nvim client. A lot of plugins are available to enhance the editor for markdown. See [this document](https://docs.rockylinux.org/books/nvchad/) for a nice set of installation instructions.
- [VS Code](https://code.visualstudio.com/) - Partially open source, by Microsoft. VS Code is a lightweight and powerful editor available for Windows, Linux and MacOS. To contribute to this document project, you should get the following extensions: Git Graph, HTML Preview, HTML Snippets, Markdown All in One, Markdown Preview Enhanced, Markdown Preview Mermaid Support, and any more that catch your fancy.

## Create a local repository

Once you have a Markdown editor installed, follow instructions to connect it to your GitHub account and download your repository to your local machine. Every time you prepare to update a document, follow these steps to sync your local and online forks with the main branch to ensure you are working with the most current version:

1. Within GitHub, sync your fork of the documentation repository with the main branch.
2. Follow your Markdown editor’s instructions to sync your current fork with your local machine.
3. Inside your Markdown editor, open the document you wish to modify.
4. Modify the document.
5. Save.
6. Commit your changes within your editor, which should sync your local repository with your online fork.
7. Within GitHub, find the updated document in your fork and create a Pull Request to merge it with the main document.

## Submit an update

*Add a missing word, correct an error, or clarify a confusing bit of text.*

1. Start on the page you want to update.

    Click the “Edit” pencil in the upper right corner of the document you want to update. You will be taken to the original document on GitHub.

    The first time you contribute to the RL repository, you will be prompted with a green button to “**Fork** this **repository** and propose changes.” This creates a duplicate copy of the RL repository where you make your suggested edits. Simply click the green button and continue.

2. Make your changes

    Follow the Markdown formatting. Perhaps there’s a missing word, or the link on line 21 needs to be fixed, for example. Make the necessary change.

3. Propose changes

    At the bottom of the page, write a one-line description in the title of the block entitled, “**Propose changes”**. It is helpful, but not necessary, to reference the file name found at the top of the doc.

    So, if you updated a link within line 21 of the markdown text, you would say something like, "Update README.md with correct links."

    **Note: Word your action in the present tense.**

    Then click Propose changes, which will **Commit** your changes to a complete document within your forked repository.

4. Review changes

    Now you can look at what you’ve done, line by line. Did you miss anything? Back up to the previous page and correct it again (you’ll have to start over), then click Propose Changes again.

    Once the doc is the way you want it, click the green button that says Create Pull Request. This provides one more chance to double-check your changes and confirm the doc is ready.

5. Create Pull Request

    All of your work so far has been done in your own repository, with no opportunity to break the RL main repository. Next, you submit it to the documentation team to merge your version into the main version of the document.

    Click the big green button that says Create Pull Request. Good news, you still haven’t broken anything, because now it goes to the RL documentation team for review.

6. Wait

    Once the RL team gets your request, they will respond in one of three ways.

    - Accept and merge your PR
    - Comment with feedback and ask for changes
    - Deny your PR with an explanation

    The last response is unlikely. We really want to include your perspective here! If you have to make changes, you will suddenly understand why you need a local repository. The team can [talk you through](https://chat.rockylinux.org/rocky-linux/channels/documentation) what to do next. In good news, it’s still fixable. Follow the comment section of that request to see what further information is requested.

    Otherwise, your request will be accepted and merged. Welcome to the team, you’re officially a contributor now! Look for your name to show up on the all-contributors list at the bottom of the Contributor Guide in a few days.
