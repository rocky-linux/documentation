---
title: Bash - Conditional structures if and case
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Conditional structures if and case

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: use the conditional syntax `if`;  
:heavy_check_mark: use the conditional syntax `case`;  

:checkered_flag: **linux**, **script**, **bash**, **conditional structures**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 20 minutes

****

## Conditional structures

If the `$?` variable is used to know the result of a test or the execution of a command, it can only be displayed and has no effect on the execution of a script.

But we can use it in a condition.
**If** the test is good **then** I do this action **otherwise** I do this other action.

Syntax of the conditional alternative `if`:

```
if command
then
    command if $?=0
else
    command if $?!=0
fi
```

The command placed after the word `if` can be any command since it is its return code (`$?`) that will be evaluated.
It is often convenient to use the `test` command to define several actions depending on the result of this test (file exists, variable not empty, write rights set).

Using a classical command (`mkdir`, `tar`, ...) allows you to define the actions to be performed in case of success, or the error messages to be displayed in case of failure.

Examples:

```
if [[ -e /etc/passwd ]]
then
    echo "The file exists"
else
    echo "The file does not exist"
fi

if mkdir rep
then
    cd rep
fi
```

If the `else` block starts with a new `if` structure, you can merge the `else` and `if` with `elif` as shown below:

```
[...]
else
  if [[ -e /etc/ ]]
[...]

[...]
# is equivalent to
elif [[ -e /etc ]]
[...]
```

!!! Note "Summary"

    The structure `if` / `then` / `else` / `fi` evaluates the command placed after if:

    * If the return code of this command is `0` (`true`) the shell will execute the commands placed after `then`;
    * If the return code is different from `0` (`false`) the shell will execute the commands placed after `else`.

    The `else` block is optional.

    There is often a need to perform some actions only if the evaluation of the command is true and to do nothing if it is false.

    The word `fi` closes the structure.

When there is only one command to execute in the `then` block, it is possible to use a simpler syntax.

The command to execute if `$?` is `true` is placed after `&&` while the command to execute if `$?` is `false` is placed after `||` (optional).

Example:

```
[[ -e /etc/passwd ]] && echo "The file exists" || echo "The file does not exist"
mkdir dir && echo "The directory is created".
```

It is also possible to evaluate and replace a variable with a lighter structure than `if`.

This syntax implements the braces:

* Displays a replacement value if the variable is empty:
    ```
    ${variable:-value}
    ```
* Displays a replacement value if the variable is not empty:
    ```
    ${variable:+value}
    ```
* Assigns a new value to the variable if it is empty:
    ```
    ${variable:=value}
    ```

Examples:

```
name=""
echo ${name:-linux}
linux
echo $name

echo ${name:=linux}
linux
echo $name
linux
echo ${name:+tux}
tux
echo $name
linux
```

!!! hint

    When deciding on the use of `if`, `then`, `else`, `fi` OR the use of the simpler syntax examples described, keep in mind the readability of your script. If no one is going to use the script but yourself, then you can use what works best for you. If someone else might need to review, debug, or trace through the script that you create, either use the more self documenting form (`if`,`then`, etc) or make sure that you document your script thoroughly so that the simpler syntax is actually understood by those who may need to modify and use the script. Documenting the script is *always* a good thing to do anyway, as noted several times earlier in these lessons.

## Alternative conditional: structure `case`

A succession of `if` structures can quickly become heavy and complex. When it concerns the evaluation of the same variable, it is possible to use a conditional structure with several branches.
The values of the variable can be specified or belong to a list of possibilities.

**Wildcards can be used**.

The structure `case ... in` / `esac` evaluates the variable placed after `case` and compares it with the defined values.

At the first equality found, the commands placed between `)` and `;;` are executed.

The variable evaluated and the values proposed can be strings or results of sub-executions of commands.

Placed at the end of the structure, the choice `*` indicates the actions to be executed for all the values that have not been previously tested.

Syntax of the conditional alternative case:

```
case $variable in
  value1)
    commands if $variable = value1
    ;;
  value2)
    commands if $variable = value2
    ;;
  [..]
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

When the value is subject to variation, it is advisable to use wildcards `[]` to specify the possibilities:

```
[Yy][Ee][Ss])
  echo "yes"
  ;;
```

The character `|` also allows you to specify a value or another:

```
"yes" | "YES")
  echo "yes"
  ;;
```
