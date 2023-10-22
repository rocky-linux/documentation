---
title: Three Swordsmen
author: tianci li
contributors: 
tags:
  - grep
  - sed
  - awk
  - Regular expression
---

# Overview

As we all know, the GNU/Linux operating system follows the philosophy of "everything is a file", so system administrators often need to deal with problems related to file names and file contents. 

In terms of processing file content, the three tools `grep`, `sed`, and `awk` are very powerful and frequently used, so people call them the "Three Swordsmen".

## Regular expressions VS wildcards

In the GNU/Linux operating system, regular expressions and wildcards often have the same symbol (or style), so people often confuse them. 

What is the difference between regular expressions and wildcards?

Similarities:

* Having the same symbol, but representing completely different meanings.

Differences:

* Regular expressions are used to match file content; Wildcards are typically used to match file or directory names.
* Regular expressions can be used on commands such as `grep`, `sed`, `awk`, etc; Wildcards can be used on commands such as `cp`, `find`, `mv`, `touch`, `ls`, etc.

###  Wildcards in the GNU/Linux

The GNU/Linux OS supports these wildcards:

| wildcards style | role |
| :---:           | :---|
| ?               | Match one character of a file or directory name. | 
| *               | Match 0 or more arbitrary characters of a file or directory name.|
| [ ]             | Match any single character in parentheses. For example, &#91;one&#93; which means to match o or n or e.|
| [-]             | Matches any single character within the given range in parentheses. For example, &#91;0-9&#93; represents matching any single number from 0 to 9. |
| [^]             | "logical non" matching of a single character. For example, &#91;^a-zA-Z&#93; represents matching a single non letter character. |
| {,}           |  Non continuous matching of multiple single characters. Separate with commas. |
| {..}            | Same as &#91;-&#93;. For example {0..9} and {a..z}  |

Different commands have different support for wildcard styles:

* `find`: Supports *, ?, [ ], [-], [^]
* `ls`: All supported
* `mkdir`: Supports {,} and {..}
* `touch`: Supports {,} and {..}
* `mv`: All supported
* `cp`: All supported

For example:

```bash
Shell > mkdir -p /root/dir{1..3}
Shell > cd /root/dir1/
Shell > touch file{1,5,9}
Shell > cd 
Shell > mv /root/dir1/file[1-9]  /root/dir2/
Shell > cp /root/dir2/file{1..9} /root/dir3/
Shell > find / -iname "dir[1-9]" -a -type d
```