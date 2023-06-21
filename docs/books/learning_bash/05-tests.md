---
title: Bash - Tests
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Tests

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: work with the return code;  
:heavy_check_mark: test files and compare them;  
:heavy_check_mark: test variables, strings and integers;  
:heavy_check_mark: perform an operation with numeric integers;  

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 10 minutes

****

Upon completion, all commands executed by the shell return a **return code** (also called **status** or **exit code**).

* If the command ran correctly, the convention is that the status code will be **zero**.
* If the command encountered a problem during its execution, its status code will have a **non-zero value**. There are many reasons for this: lack of access rights, missing file, incorrect input, etc.

You should refer to the manual of the `man command` to know the different values of the return code provided by the developers.

The return code is not visible directly, but is stored in a special variable: `$?`.

```
mkdir directory
echo $?
0
```

```
mkdir /directory
mkdir: unable to create directory
echo $?
1
```

```
command_that_does_not_exist
command_that_does_not_exist: command not found
echo $?
127
```


!!! note

    The display of the contents of the `$?` variable with the `echo` command is done immediately after the command you want to evaluate because this variable is updated after each execution of a command, a command line or a script.

!!! tip

    Since the value of `$?` changes after each command execution, it is better to put its value in a variable that will be used afterwards, for a test or to display a message.

    ```
    ls no_file
    ls: cannot access 'no_file': No such file or directory
    result=$?
    echo $?
    0
    echo $result
    2
    ```

It is also possible to create return codes in a script.
To do so, you just need to add a numeric argument to the `exit` command.

```
bash # to avoid being disconnected after the "exit 2
exit 123
echo $?
123
```

In addition to the correct execution of a command, the shell offers the possibility to run tests on many patterns:

* **Files**: existence, type, rights, comparison;
* **Strings**: length, comparison;
* **Numeric integers**: value, comparison.

The result of the test:

* `$?=0` : the test was correctly executed and is true;
* `$?=1` : the test was correctly executed and is false;
* `$?=2` : the test was not correctly executed.

## Testing the type of a file

Syntax of the `test` command for a file:

```
test [-d|-e|-f|-L] file
```

or:

```
[ -d|-e|-f|-L file ]
```

!!! NOTE

    Note that there is a space after the `[` and before the `]`.

Options of the test command on files:

| Option | Observation                                                     |
|--------|-----------------------------------------------------------------|
| `-e`   | Tests if the file exists                                         |
| `-f`   | Tests if the file exists and is of normal type                   |
| `-d`   | Checks if the file exists and is of type directory              |
| `-L`   | Checks if the file exists and is of type symbolic link          |
| `-b`   | Checks if the file exists and is of special type block mode     |
| `-c`   | Checks if the file exists and is of special type character mode |
| `-p`   | Checks if the file exists and is of type tube                   |
| `-S`   | Checks if the file exists and is of type socket                 |
| `-t`   | Checks if the file exists and is of type terminal               |
| `-r`   | Checks if the file exists and is readable                       |
| `-w`   | Checks if the file exists and is writable                       |
| `-x`   | Checks if the file exists and is executable                     |
| `-g`   | Checks if the file exists and has a set SGID                    |
| `-u`   | Checks if the file exists and has a set SUID                    |
| `-s`   | Tests if the file exists and is non-empty (size > 0 bytes)       |

Example:

```
test -e /etc/passwd
echo $?
0
[ -w /etc/passwd ]
echo $?
1
```

An internal command to some shells (including bash) that is more modern, and provides more features than the external command `test`, has been created.

```
[[ -s /etc/passwd ]]
echo $?
1
```

!!! NOTE

    We will therefore use the internal command for the rest of this chapter.

## Compare two files

It is also possible to compare two files:

```
[[ file1 -nt|-ot|-ef file2 ]]
```

| Option | Observation                                              |
|--------|----------------------------------------------------------|
| `-nt`  | Tests if the first file is newer than the second         |
| `-ot`  | Tests if the first file is older than the second         |
| `-ef`  | Tests if the first file is a physical link of the second |

## Testing variables

It is possible to test variables:

```
[[ -z|-n $variable ]]
```

| Option | Observation                        |
|--------|------------------------------------|
| `-z`   | Tests if the variable is empty     |
| `-n`   | Tests if the variable is not empty |

## Testing strings

It is also possible to compare two strings:

```
[[ string1 =|!=|<|> string2 ]]
```

Example:

```
[[ "$var" = "Rocky rocks!" ]]
echo $?
0
```

| Option | Observation                                                   |
|--------|---------------------------------------------------------------|
| `=`    | Tests if the first string is equal to the second              |
| `!=`   | Tests if the first string is different from the second one    |
| `<`    | Tests if the first string is before the second in ASCII order |
| `>`    | Tests if the first string is after the second in ASCII order  |

## Comparison of integer numbers

Syntax for testing integers:

```
[[ "num1" -eq|-ne|-gt|-lt "num2" ]]
```

Example:

```
var=1
[[ "$var" -eq "1" ]]
echo $?
0
```

```
var=2
[[ "$var" -eq "1" ]]
echo $?
1
```

| Option | Observation                                           |
|--------|-------------------------------------------------------|
| `-eq`  | Test if the first number is equal to the second       |
| `-ne`  | Test if the first number is different from the second |
| `-gt`  | Test if the first number is greater than the second   |
| `-lt`  | Test if the first number is less than the second      |

!!! Note

    Since numeric values are treated by the shell as regular characters (or strings), a test on a character can return the same result whether it is treated as a numeric or not.

    ```
    test "1" = "1"
    echo $?
    0
    test "1" -eq "1"
    echo $?
    0
    ```

    But the result of the test will not have the same meaning:

    * In the first case, it will mean that the two characters have the same value in the ASCII table.
    * In the second case, it will mean that the two numbers are equal.

## Combined tests

The combination of tests allows you to perform several tests in one command.
It is possible to test the same argument (file, string or numeric) several times or different arguments.

```
[ option1 argument1 [-a|-o] option2 argument 2 ]
```

```
ls -lad /etc
drwxr-xr-x 142 root root 12288 sept. 20 09:25 /etc
[ -d /etc -a -x /etc ]
echo $?
0
```

| Option | Observation                                                |
|--------|------------------------------------------------------------|
| `-a`   | AND: The test will be true if all patterns are true.       |
| `-o`   | OR: The test will be true if at least one pattern is true. |


With the internal command, it is better to use this syntax:

```
[[ -d "/etc" && -x "/etc" ]]
```

Tests can be grouped with parentheses `(` `)` to give them priority.

```
(TEST1 -a TEST2) -a TEST3
```

The `!` character is used to perform the reverse test of the one requested by the option:

```
test -e /file # true if file exists
! test -e /file # true if file does not exist
```

## Numerical operations

The `expr` command performs an operation with numeric integers.

```
expr num1 [+] [-] [\*] [/] [%] num2
```

Example:

```
expr 2 + 2
4
```

!!! Warning

    Be careful to surround the operation sign with a space. You will get an error message if you forget.
    In the case of a multiplication, the wildcard character `*` is preceded by `\` to avoid a wrong interpretation.

| Option | Observation            |
|--------|------------------------|
| `+`    | Addition               |
| `-`    | Subtraction            |
| `\*`   | Multiplication         |
| `/`    | Division quotient      |
| `%`    | Modulo of the division |


## The `typeset` command

The `typeset -i` command declares a variable as an integer.

Example:

```
typeset -i var1
var1=1+1
var2=1+1
echo $var1
2
echo $var2
1+1
```

## The `let` command

The `let` command  tests if a character is numeric.

Example:

```
var1="10"
var2="AA"
let $var1
echo $?
0
let $var2
echo $?
1
```

!!! Warning

    The `let` command does not return a consistent return code when it evaluates the numeric `0`.

    ```
    let 0
    echo $?
    1
    ```

The `let` command also allows you to perform mathematical operations:

```
let var=5+5
echo $var
10
```

`let` can be substituted by `$(( ))`.

```
echo $((5+2))
7
echo $((5*2))
10
var=$((5*3))
echo $var
15
```
