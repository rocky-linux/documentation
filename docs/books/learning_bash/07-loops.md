---
title: Bash - Loops
author: Antoine Le Morvan
contributors: Steven Spencer
tested with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Loops

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: use loops;

:checkered_flag: **linux**, **script**, **bash**, **loops**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 20 minutes

****

The bash shell allows for the use of **loops**. These structures allow for the execution of **a block of commands several times** (from 0 to infinity) according to a statically defined value, dynamically or on condition:

* `while`
* `until`
* `for`
* `select`

Whatever the loop used, the commands to be repeated are placed **between the words** `do` and `done`.

## The while conditional loop structure

The `while` / `do` / `done` structure evaluates the command placed after `while`.

When the evaluated command is true:

```
$? = 0
```

the commands placed between `do` and `done` are executed. The script then returns to the beginning to evaluate the command again.

When the evaluated command is false:

```
$? != 0
```

the shell resumes the execution of the script at the first command after done.

Syntax of the conditional loop structure `while`:

```
while command
do
  command if $? = 0
done
```

Example using the `while` conditional structure:

```
while [[ -e /etc/passwd ]]
do
  echo "The file exists"
done
```

If the evaluated command does not vary, the loop will be infinite and the shell will never execute the commands placed after the script. This can be intentional, but it can also be an error. So you have to be **very careful with the commands that manage the loop and find a way to get out of it**.

To get out of a `while` loop, you have to make sure that the command being evaluated is no longer true, which is not always possible.

There are commands that allow you to change the behavior of a loop:

* `exit`
* `break`
* `continue`

## The exit command

The `exit` command ends the execution of the script.

Syntax of the `exit` command :

```
exit [n]
```

Example using the `exit` command :

```
bash # to avoid being disconnected after the "exit 1
exit 1
echo $?
1
```

The `exit` command ends the script immediately. It is possible to specify the return code of the script by giving it as an argument (from `0` to `255`).
If no argument is given, the return code of the last command of the script will be passed to the `$?` variable.

## The `break` / `continue` commands

The `break` command allows you to interrupt the loop by going to the first command after `done`.

The `continue` command allows you to restart the loop by going back to the first command after `done`.

```
while [[ -d / ]]                                                   INT ✘  17s 
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## The `true` / `false` commands

The `true` command always returns `true` while the `false` command always returns `false`.

```
true
echo $?
0
false
echo $?
1
```

Used as a condition of a loop, they allow for either an execution of an infinite loop or the deactivation of this loop.

Example:

```
while true
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## The `until` conditional loop structure

The `until` / `do` / `done` structure evaluates the command placed after `until`.

When the evaluated command is false:

```
$? != 0
```

the commands placed between `do` and `done` are executed. The script then returns to the beginning to evaluate the command again.

When the evaluated command is true (`$? = 0`), the shell resumes the execution of the script at the first command after `done`.

Syntax of the conditional loop structure `until`:

```
until command
do
  command if $? != 0
done
```

Example of the use of the conditional structure `until`:

```
until [[ -e test_until ]]
do
  echo "The file does not exist"
  touch test_until
done
```

## The alternative choice structure `select`

The structure `select` / `do` / `done` allows for the display of a menu with several choices and an input request.

Each item in the list has a numbered choice. When you enter a choice, the value chosen is assigned to the variable placed after `select` (created for this purpose).

It then executes the commands placed between `do` and `done` with this value.

* The variable `PS3` contains the invitation to enter the choice;
* The variable `REPLY` will return the number of the choice.

A `break` command is needed to exit the loop.

!!! Note

    The `select` structure is very useful for small and simple menus. To customize a more complete display, the `echo` and `read` commands must be used in a `while` loop.

Syntax of the conditional loop structure `select`:

```
PS3="Your choice:"
select variable in var1 var2 var3
do
  commands
done
```

Example of the use of the conditional structure `select`:

```
PS3="Your choice: "
select choice in coffee tea chocolate
do
  echo "You have chosen the $REPLY: $choice"
done
```

If this script is run, it shows something like this:

```
1) Coffee
2) Tea
3) Chocolate
Your choice : 2
You have chosen choice 2: Tea
Your choice:
```

## The loop structure on a list of values `for`

The `for` / `do` / `done` structure assigns the first element of the list to the variable placed after `for` (created on this occasion). It then executes the commands placed between `do` and `done` with this value. The script then returns to the beginning to assign the next element of the list to the working variable. When the last element has been used, the shell resumes execution at the first command after `done`.

Syntax of the loop structure on list of values `for`:

```
for variable in list
do
  commands
done
```

Example of using the conditional structure `for`:

```
for file in /home /etc/passwd /root/fic.txt
do
  file $file
done
```

Any command producing a list of values can be placed after the `in` using a sub-execution.

* With the variable `IFS` containing `$' \t\n'`, the `for` loop will take **each word** of the result of this command as a list of elements to loop on.
* With the `IFS` variable containing `$'\t\n'` (i.e. without spaces), the `for` loop will take each line of the result of this command.

This can be the files in a directory. In this case, the variable will take as a value each of the words of the file names present:

```
for file in $(ls -d /tmp/*)
do
  echo $file
done
```

It can be a file. In this case, the variable will take as a value each word contained in the file browsed, from the beginning to the end:

```
cat my_file.txt
first line
second line
third line
for LINE in $(cat my_file.txt); do echo $LINE; done
first
line
second
line
third line
line
```

To read a file line by line, you must modify the value of the `IFS` environment variable.

```
IFS=$'\t\n'
for LINE in $(cat my_file.txt); do echo $LINE; done
first line
second line
third line
```
