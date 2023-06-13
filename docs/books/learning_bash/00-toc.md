---
title: Learning bash with Rocky
author: Antoine Le Morvan
contributors: Steven Spencer
tested with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Learning Bash with Rocky

In this section, you will learn more about Bash scripting, an exercise that every administrator will have to perform one day or another.

## Generalities

The shell is the command interpreter of Linux.
It is a binary that is not part of the kernel, but forms an additional layer, hence its name "shell".

It parses the commands entered by the user and then executes them by the system.

There are several shells, all of which share some common features.
The user is free to use the one that suits them best. Some examples are:

* the **Bourne-Again shell** (`bash`),
* the **Korn shell** (`ksh`),
* the **C shell** (`csh`),
* etc.

`bash` is present by default in most (all) Linux distributions.
It is characterized by its practical and user-friendly features.

The shell is also a **basic programming language** which, thanks to some dedicated commands, allows:

* the use of **variables**,
* **conditional execution** of commands,
* the **repetition** of commands.

Shell scripts have the advantage that they can be created **quickly** and **reliably**, without **compiling** or installing additional commands. A shell script is just a text file without any embellishments (bold, italics, etc.).

!!! NOTE

    Although the shell is a "basic" programming language, it is still very powerful and sometimes faster than badly compiled code.

To write a shell script, you just have to put all the necessary commands in a single text file.
By making this file executable the shell reads it sequentially, and executes the commands in it one by one.
It is also possible to execute it by passing the name of the script as an argument to the bash binary.

When the shell encounters an error, it displays a message to identify the problem but continues to execute the script.
But there are mechanisms to stop the execution of a script when an error occurs.
Command-specific errors are also displayed on the screen or inside files.

What is a good script? It is:

* **reliable**: its operation is flawless even in case of misuse;
* **commented**: its code is annotated to facilitate the rereading and future evolution;
* **readable**: the code is indented appropriately, the commands are spaced out, ...
* **portable**: the code runs on any Linux system, dependency management, rights management, etc.
