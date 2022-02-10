# The Rocky Linux Documentation Style Guide for Writers

## Well that was a mouthful

If you've found your way to this page, then you're a wonderful person who wants to help make Rocky Linux easier to use for everyone. Either that, or you're a wonderful person who is very, very lost.

No matter. It's good to have you here.

If you want to contribute English-language documentation to the Rocky Linux project, you should have a look through these guidelines first. Get comfy, familiarize yourself with how we do things, and take it from there. 

It'll be fun, for given values of fun. Depends on how much you like nerd stuff.

### Before we get started

You don't need to be some sort of programming expert (though it helps) or god-level sysadmin (ditto) to help out with this project, but you will need a few things:

* A working knowledge of Git, and Github.
* A working knowledge of Markdown formatting. Here's [a handy guide](https://guides.github.com/features/mastering-markdown/).
* A good screenshot tool at the ready, and possibly a simple graphics editing program.
* A willingness to work with editors. Every submission to the docs will be given a once-over (at least) to make sure it's:
    * Technically correct and working as intended.
    * Easily read and understood.

One last note... I *really* shouldn't have to say this next bit, but this is the internet, and the internet is a strange place: 

*Don't put anything racist, sexist, or otherwise horrible in your documentation.* And put a lid on the really dark humor, 'cause lots of people just aren't ready to see that when they just want to get LiteSpeed up and running with WordPress, or their docker container's being fussy.

Okay, with that out of the way, here's what you need to know about writing for us:

## Basic writing guidelines

These principles should apply to all documentation written for Rocky Linux:

* **Assume a *basic* level of technical competency on the part of the reader.**  
There *will* be documentation aimed at beginners who've never used Rocky Linux, or RHEL, or built their own servers, but this is an OS for people who have some idea what they want to do with it.
*  **Include lots of examples, and explain exactly what you mean.**  
... But don't make too many assumptions. Lots of Linux and server-building newbies will be reading what you write, so be as clear as you can. Explain every step, and every argument or variable you put into the command line.
* **A screenshot is worth a thousand bits of jargon.**  
Put the "show" in "show and tell". 'Nuff said.
* **List the requirements at the top.**  
On every tutorial, guide, or doc, list the things the reader will need to know or have installed first. There's no worse feeling than getting into the middle of a tutorial, then reading, "Okay, now SSH into your server..." when you haven't had any experience with SSH yet.
* **Link to other guides on the Rocky docs site when it makes sense**
If you're writing a tutorial for beginners, and you reference another technology or process for which we have an existing guide, link it. You can say something like, "If you want to know more about SELinux, check out [our guide on the topic](../docs/guides/security/learning_selinux.md)."
* **Use the metaphor, Luke. And also watch out for the metaphors...**  
And the analogies, similes, idioms, and more obscure cultural references. While *we generally encourage* the use of all these literary devices to spice up documentation (especially the beginner-focused docs), do your best to keep them simple. Non-native English speakers still need to understand our documentation, especially those who will be translating it.
* **The Oxford comma**  
Also known as the serial comma. Love it, use it, and [read up on it](https://en.wikipedia.org/wiki/Serial_comma) if you want to.
* **Things to italicize**  
Things have changed since the last version of this document, and italics should be used as they usually are: for *emphasis*. Nothing more, nothing less.
* **Styling program names**
It can be helpful, but not strictly necessary, to style app names such as `nginx` with inline code backticks (eg `` `an-app-name` ``). We recommend it because it helps people to find app-specific tips and instructions while skimming.
* **Styling directories**
Folders and paths should *always* be styled with the inline code backticks, eg. `/usr/local/bin/`.

## Images & screenshots
A few tips to help you make the best images you can for tutorials.

* There is no strict size requirement for images. Just make sure whatever you want is clearly visible, but don't make the image so big that it'll mess with people on slow connections. Think 1080p max, for most cases.
* The recommended format for images is JPG, though PNGs are acceptable for simple, vector-style graphics.
* If there's a lot going on in your screenshot, consider adding a couple of helpful arrows pointing at the things that matter.
* Terminal commands are best put into a `code` element or block. If you must screenshot your terminal, make sure the text is big enough for people to easily see without zooming in. This is an accessibility concern, so please do be careful of those with visual impairments.
* Speaking of accessibility, make sure every image has alt text.