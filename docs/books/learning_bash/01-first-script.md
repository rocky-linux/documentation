---
title: Bash - First script
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - First script

In this chapter you will learn how to write your first script in bash.

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: Write your first script in bash;  
:heavy_check_mark: Execute your first script;  
:heavy_check_mark: Specify which shell to use with the so-called shebang;  

:checkered_flag: **linux**, **script**, **bash**

**Knowledge**: :star:  
**Complexity**: :star:  

**Reading time**: 10 minutes

****

## My first script

To start writing a shell script, it is convenient to use a text editor that supports syntax highlighting.

`vim`, for example, is a good tool for this.

The name of the script should respect some rules:

* no names of existing commands;
* only alphanumeric characters, i.e. no accented characters or spaces;
* extension .sh to indicate that it is a shell script.

!!! note

    The author uses the "$" throughout these lessons to indicate the user's command-prompt.

```bash
#!/usr/bin/env bash
#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Displays the text "Hello world!"
#

# Displays a text on the screen :
echo "Hello world!"
```

To be able to run this script, as an argument to bash:

```bash
$ bash hello-world.sh
Hello world !
```

Or, more simply, after having given it the right to execute:

```bash
$ chmod u+x ./hello-world.sh
$ ./hello-world.sh
Hello world !
```

!!! note

    To execute the script, it needs to be called with `./` before its name when you are in the directory where the script resides. If not in that directory, you will need to call it with the entire path to the script, OR place it in a directory that is within your PATH environment variable: (Examples: `/usr/local/sbin`, `/usr/local/bin`, etc.)
    The interpreter will refuse to execute a script present in the current directory without indicating a path (here with `./` before it).

    The `chmod` command is to be passed only once on a newly created script.

The first line to be written in any script is to indicate the name of the shell binary to be used to execute it.
If you want to use the `ksh` shell or the interpreted language `python`, you would replace the line:

```bash
#!/usr/bin/env bash
```

with :

```bash
#!/usr/bin/env ksh
```

or with :

```bash
#!/usr/bin/env python
```

This first line is called the `shebang`.
It starts with the characters `#!` followed by the path to the binary of the command interpreter to use.

!!! hint "About the shebang"

    You may have encountered the "shebang" in a script that you've looked at that does not contain the "env" section and simply contains the interpreter to use. (Example: `#!/bin/bash`). The author's method is considered to be the recommended and proper way to format the "shebang".

    Why is the author's method recommended? Because it increases the portability of the script. If for some reason the interpreter lived in an entirely different directory, the interpreter would **still** be found if you used the author's method.

Throughout the writing process, you should think about proofreading the script, using comments in particular:

* a general presentation, at the beginning, to indicate the purpose of the script, its author, its version, its use, etc.
* during the text to help understand the actions.

Comments can be placed on a separate line or at the end of a line containing a command.

Example:

```bash
# This program displays the date
date # This line is the line that displays the date!
```
