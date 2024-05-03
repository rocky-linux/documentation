---
title: Bash - Check your knowledge
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Check your knowledge

:heavy_check_mark: Every order must return a return code at the end of its execution:

- [ ] True
- [ ] False

:heavy_check_mark: A return code of 0 indicates an execution error:

- [ ] True
- [ ] False

:heavy_check_mark: The return code is stored in the variable `$@`:

- [ ] True
- [ ] False

:heavy_check_mark: The test command allows you to:

- [ ] Test the type of a file
- [ ] Test a variable
- [ ] Compare numbers
- [ ] Compare the content of 2 files

:heavy_check_mark: The command `expr`:

- [ ] Concatenates 2 strings of characters
- [ ] Performs mathematical operations
- [ ] Display text on the screen

:heavy_check_mark: Does the syntax of the conditional structure below seem correct to you? Explain why.

```bash
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] True
- [ ] False

:heavy_check_mark: What does the following syntax mean: `${variable:=value}`

- [ ] Displays a replacement value if the variable is empty
- [ ] Display a replacement value if the variable is not empty
- [ ] Assigns a new value to the variable if it is empty

:heavy_check_mark: Does the syntax of the conditional alternative structure below seem correct to you? Explain why.

```bash
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] True
- [ ] False

:heavy_check_mark: Which of the following is not a structure for looping?

- [ ] while
- [ ] until
- [ ] loop
- [ ] for
