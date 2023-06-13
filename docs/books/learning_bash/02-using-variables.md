---
title: Bash - Using Variables
author: Antoine Le Morvan
contributors: Steven Spencer
tested with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Using Variables

In this chapter you will learn how to use variables in your bash scripts.

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: Store information for later use;  
:heavy_check_mark: Delete and lock variables;  
:heavy_check_mark: Use environment variables;  
:heavy_check_mark: Substitute commands;  

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Knowledge**: :star: :star:  
**Complexity**: :star:  

**Reading time**: 10 minutes

****

## Storing information for later use

As in any programming language, the shell script uses variables. They are used to store information in memory to be reused as needed during the script.

A variable is created when it receives its content. It remains valid until the end of the execution of the script or at the explicit request of the script author. Since the script is executed sequentially from start to finish, it is impossible to call a variable before it is created.

The content of a variable can be changed during the script, as the variable continues to exist until the script ends. If the content is deleted, the variable remains active but contains nothing.

The notion of a variable type in a shell script is possible but is very rarely used. The content of a variable is always a character or a string.

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

# Clear the screen
clear

# Launch the backup
echo "Starting the backup of $FILE1, $FILE2, $FILE3, $FILE4 to $DESTINATION:"

cp $FILE1 $FILE2 $FILE3 $FILE4 $DESTINATION

echo "Backup ended!"
```

This script makes use of variables. The name of a variable must start with a letter but can contain any sequence of letters or numbers. Except for the underscore "_", special characters cannot be used.

By convention, variables created by a user have a name in lower case. This name must be chosen with care so as not to be too evasive or too complicated. However, a variable can be named with upper case letters, as in this case, if it is a global variable that should not be modified by the program.

The character `=` assigns content to a variable:

```
variable=value
rep_name="/home"
```

There is no space before or after the `=` sign.

Once the variable is created, it can be used by prefixing it with a dollar $.

```
file=file_name
touch $file
```

It is strongly recommended to protect variables with quotes, as in this example below:

```
file=file name
touch $file
touch "$file"
```

As the content of the variable contains a space, the first `touch` will create 2 files while the second `touch` will create a file whose name will contain a space.

To isolate the name of the variable from the rest of the text, you must use quotes or braces:

```
file=file_name
touch "$file"1
touch ${file}1
```

**The systematic use of braces is recommended.**

The use of apostrophes inhibits the interpretation of special characters.

```
message="Hello"
echo "This is the content of the variable message: $message"
Here is the content of the variable message: Hello
echo 'Here is the content of the variable message: $message'
Here is the content of the variable message: $message
```

## Delete and lock variables

The `unset` command allows for the deletion of a variable.

Example:

```
name="NAME"
firstname="Firstname"
echo "$name $firstname"
NAME Firstname
unset firstname
echo "$name $firstname"
NAME
```

The `readonly` or `typeset -r` command locks a variable.

Example:

```
name="NAME"
readonly name
name="OTHER NAME"
bash: name: read-only variable
unset name
bash: name: read-only variable
```

!!! Note

    A `set -u` at the beginning of the script will stop the execution of the script if undeclared variables are used.

## Use environment variables

**Environment variables** and **system variables** are variables used by the system for its operation. By convention these are named with capital letters.

Like all variables, they can be displayed when a script is executed. Even if this is strongly discouraged, they can also be modified.

The `env` command displays all the environment variables used.

The `set` command displays all used system variables.

Among the dozens of environment variables, several are of interest to be used in a shell script:

| Variables                        | Description                                              |
|----------------------------------|-----------------------------------------------------------|
| `HOSTNAME`                       | Host name of the machine.                                 |
| `USER`, `USERNAME` and `LOGNAME` | Name of the user connected to the session.                |
| `PATH`                           | Path to find the commands.                                |
| `PWD`                            | Current directory, updated each time the cd command is executed. |
| `HOME`                           | Login directory.                                          |
| `$$`                             | Process id of the script execution.                       |
| `$?`                             | Return code of the last command executed.                 |

The `export` command allows you to export a variable.

A variable is only valid in the environment of the shell script process. In order for the **child processes** of the script to know the variables and their contents, they must be exported.

The modification of a variable exported in a child process cannot be traced back to the parent process.

!!! note

    Without any option, the `export` command displays the name and values of the exported variables in the environment.

## Substitute commands

It is possible to store the result of a command in a variable.

!!! Note

    This operation is only valid for commands that return a message at the end of their execution.

The syntax for sub-executing a command is as follows:

```
variable=`command`
variable=$(command) # Preferred syntax
```

Example:

```
$ day=`date +%d`
$ homedir=$(pwd)
```

With everything we've just seen, our backup script might look like this:

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
# Version 1.0.1: Adding what we learned about variables
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

## Readonly variables
readonly FILE1 FILE2 FILE3 FILE4 DESTINATION

# A folder name with the day's number
dir="backup-$(date +%j)"

# Clear the screen
clear

# Launch the backup
echo "****************************************************************"
echo "     Backup Script - Backup on ${HOSTNAME}                      "
echo "****************************************************************"
echo "The backup will be made in the folder ${dir}."
echo "Creating the directory..."
mkdir -p ${DESTINATION}/${dir}

echo "Starting the backup of ${FILE1}, ${FILE2}, ${FILE3}, ${FILE4} to ${DESTINATION}/${dir}:"

cp ${FILE1} ${FILE2} ${FILE3} ${FILE4} ${DESTINATION}/${dir}

echo "Backup ended!"

# The backup is noted in the system event log:
logger "Backup of system files by ${USER} on ${HOSTNAME} in the folder ${DESTINATION}/${dir}."
```

Running our backup script:

```
$ sudo ./backup.sh
```

will give us:

```
****************************************************************
     Backup Script - Backup on desktop                      
****************************************************************
The backup will be made in the folder backup-088.
Creating the directory...
Starting the backup of /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow to /root/backup-088:
Backup ended!
```
