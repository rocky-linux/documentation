---
title: Bash - Tests
author: Antoine Le Morvan
contributors: Steven Spencer
update: 31-mar-2022
---

# Bash - Tests

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: ;
:heavy_check_mark: ;
:heavy_check_mark: ;
:heavy_check_mark: ;

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
$ mkdir directory
echo $?
0
```

```
$ mkdir /directory
mkdir: unable to create directory
$ echo $?
1
```

```
$ command_that_does_not_exist
command_that_does_not_exist: command not found
echo $?
127
```


!!! NOTE

    The display of the contents of the `$?` variable with the `echo` command is done immediately after the command you want to evaluate because this variable is updated after each execution of a command, a command line or a script.

!!! TIP

    Since the value of `$?` changes after each command execution, it is better to put its value in a variable that will be used afterwards, for a test or to display a message.

    ```
    $ ls no_file
    ls: cannot access 'no_file': No such file or directory
    $ result=$?
    $ echo $?
    0
    $ echo $result
    2
    ```

It is also possible to create return codes in a script.
To do so, you just need to add a numeric argument to the `exit` command.

```
$ bash # to avoid being disconnected after the "exit 2
$ exit 123
$ echo $?
123
```

In addition to the correct execution of a command, the shell offers the possibility to run tests on many patterns:

* **Files**: existence, type, rights, comparison;
* **Strings**: length, comparison;
* **Numeric integers**: value, comparison.

The result of the test:

* `$?=0` : the test was correctly executed and is true ;
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
$ test -e /etc/passwd
$ echo $?
0
$ [ -w /etc/passwd ]
$ echo $?
1
```

An internal command to some shells (including bash) more modern and providing more features than the external command `test`, has appeared:

```
$ [[ -s /etc/passwd ]]
$ echo $?
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
$ [[ "$var" = "Rocky rocks!" ]]
$ echo $?
0
```

| Option | Observation                                                   |
|--------|---------------------------------------------------------------|
| `=`    | Tests if the first string is equal to the second              |
| `!=`   | Tests if the first string is different from the second one    |
| `<`    | Tests if the first string is before the second in ASCII order |
| `>`    | Tests if the first string is after the second in ASCII order  |
