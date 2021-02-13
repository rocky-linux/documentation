# Rock Linux Documentation How-To Contribute Guide #

## Introduction ##

So you want to contributed documentation to the new Rock Linux project, but aren't sure how to go about that? Well if so, You've come to the right place. We're excited to have you on board with us. One of our big goals for Rocky is to have not just good, but GREAT documentation, and we can't do it alone. This document will let you know how to contribute and will (hopefully) take away any worry you might have about doing so. We're always here to help, too, so feel free to ask questions and join in the conversation.

## Document Subject Matter ##

If you can dream it, or better yet have done it before, then your subject matter is probably important to the Rocky Linux documentation. Once a build is finally out there, then we expect that documentation will really start to explode, but we want to be ready with some things already documented out of the gate. This is where you come in-both now and in the future. If you have experience with something in Linux, and can translate that to Rocky Linux, then we want you to start writing!

## Where to Start ##

While you can create documentation in any format, the preferred format is Markdown. You can easily create documents in Markdown, plus Mardown is super-easy to learn. The best way to get started with Markdown is to have a Markdown editor installed and read the tutorial. You can create Mardown files with any text editor, but most Markdown editors allow you to preview what you've input already, so they can be very helpful. 

### Markdown Editor ###

As we've said already, the best way to create Markdown files, particularly if you've not done it before, is to grab an editor for the operating system that you use on your PC or Laptop. A simple web search for "Markdown editors" will show you a bunch to choose from. Pick one that is compatible with your OS and get started. This particular How-To doc was created with ReText, a cross-platform Markdown editor. Again, if you'd prefer to create your Markdown files in your own text editor that you are already familiar with, that's no problem at all.

### Markdown Tutorial ###

You can get a good feel on how to write Markdown files, by taking a look at [Mastering Markdown](hhttps://guides.github.com/features/mastering-markdown/). This online resource will get you up-to-speed in no time. 

## Using Git ##

Rocky Linux, like loads of other projects out there, uses Git. In order to submit your document idea, we ask that you create a Git account. When you are ready to submit your document idea for approval, follow these easy steps:

### From Git GUI ###

Most tasks can be completed from the web gui on Git. Here's and example of adding a file you've created on your local machine to the Git repository.

1. Login to your Git account.
2. Navigate to the Rock Linux Documentation at [https://github.com/rocky-linux/documentation.git](https://github.com/rocky-linux/documentation.git)
3. You should be on the "Main" branch, so check the drop down label down in the middle section, just to be sure you are. Your document might not ultimately end up in the "Main" branch, but admins will move it around where it logically fits later. On the right-hand side of the page, click the "Fork" button, which will create your own copy of the documentation.
4. In the middle of the page on the forked copy, just to the left of the Green "Code" drop down, is an "Add file" button. Click this and choose the "Upload files" option.
5. This will give you a way to either drag and drop files here, or to browse to them on your computer. Go ahead and use the method you are most comfortable with.
6. Once the file is uploaded, the next thing you need to do is create a Pull Request. This request lets the upstream administrators know that you've got a new file (or files) that you would like them to merge with the master. Click on "Pull Request" in the upper-left of the screen
7. Write a brief message in the "Write" section letting the administrators know what you've done. (New document, revision, suggested change, etc.,) then submit your change.

### From Git Command-Line ###

If you prefer, though, and would like to run Git locally on your own machine, you can clone the Rocky Linux Documentation, make changes, and then do a commit changes afterwards.

1. Git clone the repository `git clone https://github.com/rocky-linux/documentation.git`
2. Now, on your own machine, add files to the directory. Example: `mv /home/myname/help.md /home/myname/documentation/`
3. Next, run git add for that file name. Example:  `git add help.md`
4. Now, run git commit for the changes you have made. Example: `git commit -m "Added the help.md file"
5. Finally, do the pull request. Example: `git pull

Once all of that is done, you simply wait for confirmation that your request has been successfully merged. 

## Keep Up With The Conversation ##

If you haven't already, join the conversation on the Rocky [Linux Mattermost Channel](https://chat.rockylinux.org/rocky-linux/) and stay up-to-date with what is going on. Join the "Documentation" channel, or any other channel you are interested in. We are glad to have you on board with us!!

