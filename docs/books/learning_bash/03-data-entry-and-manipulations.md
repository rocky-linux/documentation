---
title: Bash - Data entry and manipulations
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Data entry and manipulations

In this chapter you will learn how to make your scripts interact with users and manipulate the data.

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: read input from a user;     
:heavy_check_mark: manipulate data entries;     
:heavy_check_mark: use arguments inside a script;     
:heavy_check_mark: manage positional variables;     

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star:  

**Reading time**: 10 minutes

****

Depending on the purpose of the script, it may be necessary to send it information when it is launched or during its execution. This information, not known when the script is written, can be extracted from files or entered by the user. It is also possible to send this information in the form of arguments when the script command is entered. This is the way many Linux commands work.

## The `read` command

The `read` command allows you to enter a character string and store it in a variable.

Syntax of the read command:

```
read [-n X] [-p] [-s] [variable]
```

The first example below, prompts you for two variable inputs: "name" and "firstname", but since there is no prompt, you would have to know ahead of time that this was the case. In the case of this particular entry, each variable input would be separated by a space.  The second example prompts for the variable "name" with the prompt text included:

```
read name firstname
read -p "Please type your name: " name
```

| Option | Functionality                                   |
|--------|-----------------------------------------------|
| `-p`   | Displays a prompt message.                    |
| `-n`   | Limits the number of characters to be entered. |
| `-s`   | Hides the input.                              |

When using the `-n` option, the shell automatically validates the input after the specified number of characters. The user does not have to press the <kbd>ENTER</kbd> key.

```
read -n5 name
```

The `read` command allows you to interrupt the execution of the script while the user enters information. The user's input is broken down into words assigned to one or more predefined variables. The words are strings of characters separated by the field separator.

The end of the input is determined by pressing the <kbd>ENTER</kbd> key.

Once the input is validated, each word will be stored in the predefined variable.

The division of the words is defined by the field separator character.
This separator is stored in the system variable `IFS` (**Internal Field Separator**).

```
set | grep IFS
IFS=$' \t\n'
```

By default, the IFS contains the space, tab and line feed.

When used without specifying a variable, this command simply pauses the script. The script continues its execution when the input is validated.

This is used to pause a script when debugging or to prompt the user to press <kbd>ENTER</kbd> to continue.

```
echo -n "Press [ENTER] to continue..."
read
```

## The `cut` command

The cut command allows you to isolate a column in a file or in a stream.

Syntax of the cut command:

```
cut [-cx] [-dy] [-fz] file
```

Example of use of the cut command:

```
cut -d: -f1 /etc/passwd
```

| Option | Observation                                                      |
|--------|------------------------------------------------------------------|
| `-c`   | Specifies the sequence numbers of the characters to be selected. |
| `-d`   | Specifies the field separator.                                   |
| `-f`   | Specifies the order number of the columns to select.             |

The main benefit of this command will be its association with a stream, for example the `grep` command and the `|` pipe.

* The `grep` command works "vertically" (isolation of one line from all the lines in the file).
* The combination of the two commands allows for the  **isolation of a specific field in the file**.

Example:

```
grep "^root:" /etc/passwd | cut -d: -f3
0
```

!!! NOTE

    Configuration files with a single structure using the same field separator are ideal targets for this combination of commands.

## The `tr` command

The `tr` command allows you to convert a string.

Syntax of the `tr` command:

```
tr [-csd] string1 string2
```

| Option | Observation                                                                                            |
|--------|--------------------------------------------------------------------------------------------------------|
| `-c`   | All characters not specified in the first string are converted to the characters of the second string. |
| `-d`   | Deletes the specified character.                                                                       |
| `-s`   | Reduce the specified character to a single unit.                                                       |

An example of using the `tr` command follows. If you use `grep` to return root's `passwd` file entry, you would get this:

```
grep root /etc/passwd
```
returns:
```
root:x:0:0:root:/root:/bin/bash
```
Now let's use `tr` command and the reduce the "o's" in the line:

```
grep root /etc/passwd | tr -s "o"
```
which returns this:
```
rot:x:0:0:rot:/rot:/bin/bash
```
## Extract the name and path of a file

The `basename` command allows you to extract the name of the file from a path.

The `dirname` command allows you to extract the parent path of a file.

Examples:

```
echo $FILE=/usr/bin/passwd
basename $FILE
```
Which would result in "passwd"
```
dirname $FILE
```
Which would result in: "/usr/bin"

## Arguments of a script

The request to enter information with the `read` command interrupts the execution of the script as long as the user does not enter any information.

This method, although very user-friendly, has its limits if the script is scheduled to run at night.
To overcome this problem, it is possible to inject the desired information via arguments.

Many Linux commands work on this principle.

This way of doing things has the advantage that once the script is executed, it will not need any human intervention to finish.

Its major disadvantage is that the user will have to be warned about the syntax of the script to avoid errors.

The arguments are filled in when the script command is entered.
They are separated by a space.

```
./script argument1 argument2
```

Once executed, the script saves the entered arguments in predefined variables: `positional variables`.

These variables can be used in the script like any other variable, except that they cannot be assigned.

* Unused positional variables exist but are empty.
* Positional variables are always defined in the same way:

| Variable     | Observation                                             |
|--------------|---------------------------------------------------------|
| `$0`         | contains the name of the script as entered.             |
| `$1` to `$9` | contain the values of the 1st to 9th argument           |
| `${x}`       | contains the value of the argument `x`, greater than 9. |
| `$#`         | contains the number of arguments passed.                |
| `$*` or `$@` | contains in one variable all the arguments passed.      |

Example:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# The field separator will be "," or space
# Important to see the difference in $* and $@
IFS=", "

# Display a text on the screen:
echo "The number of arguments (\$#) = $#"
echo "The name of the script  (\$0) = $0"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

This will give:

```
$ ./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The name of the script  ($0) = ./arguments.sh
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four
```

!!! warning

    Beware of the difference between `$@` and `$*`. It is in the argument storage format:

    * `$*` : Contains the arguments in the format `"$1 $2 $3 ..."`
    * `$@` : Contains arguments in the format `"$1" "$2" "$3" ...`

    It is by modifying the `IFS` environment variable that the difference is visible.

### The shift command

The shift command allows you to shift positional variables.

Let's modify our previous example to illustrate the impact of the shift command on positional variables:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# The field separator will be "," or space
# Important to see the difference in $* and $@
IFS=", "

# Display a text on the screen:
echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"

shift 2
echo ""
echo "-------- SHIFT 2 ----------------"
echo ""

echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

This will give:

```
./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four

-------- SHIFT 2 ----------------

The number of arguments ($#) = 1
The 1st argument        ($1) = tree four
The 2nd argument        ($2) =
The 3rd argument        ($3) =
All separated by IFS    ($*) = tree four
All without separation  ($@) = tree four
```

As you can see, the `shift` command has shifted the place of the arguments "to the left", removing the first 2.

!!! WARNING

    When using the `shift` command, the `$#` and `$*` variables are modified accordingly.

### The `set` command

The `set` command splits a string into positional variables.

Syntax of the set command:

```
set [value] [$variable]
```

Example:

```
$ set one two three
$ echo $1 $2 $3 $#
one two three 3
$ variable="four five six"
$ set $variable
$ echo $1 $2 $3 $#
four five six 3
```

You can now use positional variables as seen before.
