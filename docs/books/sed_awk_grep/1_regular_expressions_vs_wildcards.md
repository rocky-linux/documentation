---
title: Regular expressions and wildcards
author: tianci li
contributors: 
tags:
  - Regular expressions
  - Wildcards
---

# Regular expressions and wildcards

In the GNU/Linux operating system, regular expressions and wildcards often have the same symbol (or style), so people often confuse them.

What is the difference between regular expressions and wildcards?

Similarities:

* They have the same symbol but represent entirely different meanings.

Differences:

* Regular expressions match file content; Wildcards are typically used to match file or directory names.
* Regular expressions are typically used on commands such as `grep`, `sed`, `awk`, and so on.
* Wildcards are typically used with commands such as `cp`, `find`, `mv`, `touch`, `ls`, and so on.

## Wildcards in GNU/Linux

GNU/Linux operating systems support these wildcards:

| wildcards style | role |
| :---:           | :---|
| ?               | Matches one character of a file or directory name. |
| *               | Matches 0 or more arbitrary characters of a file or directory name.|
| [ ]             |  Matches any single character in parentheses. For example, &#91;one&#93; which means to match o or n or e.|
| [-]             | Matches any single character within the given range in parentheses. For example, &#91;0-9&#93; matches any single number from 0 to 9. |
| [^]             | "logical non" matching of a single character. For example, &#91;^a-zA-Z&#93; represents matching a single non-letter character. |
| {,}             |  Non continuous matching of multiple single characters. Separated by commas. |
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

## Regular expressions in GNU/Linux

Two major schools of regular expressions exist due to historical development:

* POSIX:
    * BRE（basic regular express）
    * ERE（extend regular express）
    * POSIX character class
* PCRE (Perl Compatible Regular Expressions): The most common among various programming languages.

|        | BRE      | ERE                             | POSIX character class | PCRE                       |
| :---:  | :---:    | :---:                           | :---:                 | :---:                      |
| `grep` |  √       | √<br/>(Requires -E option)      | √                     | √<br/>(Requires -P option) |
| `sed`  |  √       | √<br/>(Requires -r option)      | √                     | ×                          |
| `awk`  |  √       | √                               | √                     | ×                          |

For more on regular expressions, visit [this website](https://www.regular-expressions.info/) for more helpful information.

### BRE

BRE (Basic Regular Expression) is the oldest type of regular expression, introduced by the `grep` command in UNIX systems and the **ed** text editor.

| metacharacter | description | bash example |
| :---:         | :---        | :---         |
| *             | Matches the number of occurrences of the previous character, which can be 0 or any number of times. |
| .             | Matches any single character except for line breaks. |
| ^             | Matches line beginning. For example - **^h** will match lines starting with h. |
| $             | Matches End of Line. For example - **h$** will match lines ending in h. |
| []            | Matches any single character specified in parentheses. For example - **[who]** will match w or h or o; **[0-9]** will match one digit; **[0-9][a-z]** will match characters composed of one digit and a single lowercase letter. | 
| [^]           | Matches any single character except for the characters in parentheses. For example - **[^0-9]** will match any single non-numeric character. **[^a-z]** will match any single character that is not a lowercase letter. |
| \             | Escape character, used to cancel the meaning represented by some special symbols. | `echo -e "1.2\n122"  \| grep -E '1\.2'`<br/>**1.2** |
| \\{n\\}       | Matches the number of occurrences of the previous single character, n represents the number of matches.     | `echo -e "1994\n2000\n2222" \| grep "[24]\{4\}"`<br/>**2222** |
| \\{n,\\}      | Matches the previous single character at least n times. | `echo -e "1994\n2000\n2222" \| grep  "[29]\{2,\}"`<br/>1**99**4<br/>**2222** | 
| \\{n,m\\}     | Matches the previous single character at least n times and at most m times. | `echo -e "abcd\n20\n300\n4444" \| grep "[0-9]\{2,4\}"`<br/>**20**<br/>**300**<br/>**4444** |

### ERE

| metacharacter | description | bash example |
| :---:         | :---        | :--- |
| +             | Matches the number of occurrences of the previous single character, which can be 1 or more times.| `echo -e "abcd\nab\nabb\ncdd"  \| grep -E "ab+"`<br/>**ab**cd<br/>**ab**<br/>**abb** |
| ?             | Matches the number of occurrences of the previous single character, which can be 0 or 1. | `echo -e  "ac\nabc\nadd" \| grep -E 'a?c'`<br/>**ac**<br/>ab**c** |
| \\<           | Boundary character, matching the beginning of a string. | `echo -e "1\n12\n123\n1234" \| grep -E "\<123"`<br/>**123**<br/>**123**4 |
| \\>  | Boundary character, matching the end of the string. |  `echo -e "export\nimport\nout"  \| grep -E "port\>"`<br/>ex**port**<br/>im**port**|
| ()           | Combinatorial matching, that is, the string in parentheses as a combination, and then match. | `echo -e "123abc\nabc123\na1b2c3" \| grep -E "([a-z][0-9])+"`<br/>ab**c1**23<br/>**a1b2c3** |
| \|           | The pipeline symbol represents the meaning of "or". | `echo -e "port\nimport\nexport\none123" \| grep -E "port\>\|123"`<br/>**port**<br/>im**port**<br/>ex**port**<br/>one**123** |

ERE also supports characters with special meanings:

| special characters | description  |
| :---:              | :---         |
| \\w                | Equivalent to **[a-zA-Z0-9]**  |
| \\W                | Equivalent to **[^a-zA-Z0-9]** |
| \\d                | Equivalent to **[0-9]**        |
| \\D                | Equivalent to **[^0-9]**       |
| \\b                | Equivalent to **\\<** or **\\>** |
| \\B                | Matches non-boundary character.
| \\s                | Matches any whitespace character. Equivalent to **[ \f\n\r\t\v]** |
| \\S                | Equivalent to **[^ \f\n\r\t\v]**  |

|  blank character   | description                      |
| :---:              | :---                             |
| \\f                | Matches a single feed character. Equivalent to **\\x0c** and **\\cL**|
| \\n                | Matches individual line breaks. Equivalent to **\\x0a** and **\\cJ**    |
| \\r                | Matches a single carriage return. Equivalent to **\\x0d** and **\\cM**           |
| \\t                | Matches a single tab. Equivalent to **\\x09** and **\\cI**      |
| \\v                | Matches a single vertical tab. Equivalent to **\\x0b** and **\\cK**      |

### POSIX character

Sometimes, you may see "POSIX character"(also known as "POSIX character class").
Please note that the author rarely uses the "POSIX character class", but has included this section to enhance basic understanding.

| POSIX character  | equivalent to   |
| :---:            | :---            |
| [:alnum:]        | [a-zA-Z0-9]     |
| [:alpha:]        | [a-zA-Z]        |
| [:lower:]        | [a-z]           |
| [:upper:]        | [A-Z]           |
| [:digit:]        | [0-9]           |
| [:space:]        | [ \f\n\r\t\v]   |
| [:graph:]        | [^ \f\n\r\t\v]  |
| [:blank:]        | [ \t]           |
| [:cntrl:]        | [\x00-\x1F\x7F] |
| [:print:]        | [\x20-\x7E]     |
| [:punct:]        | [][!"#$%&'()*+,./:;<=>?@\^_`{\|}~-] |
| [:xdigit:]       | [A-Fa-f0-9]     |

### Introducing regular expressions

Many websites exist for practicing regular expression skills online, such as:

* [regex101](https://regex101.com/)
* [oschina](https://tool.oschina.net/regex/)
* [oktools](https://oktools.net/regex)
* [regexr](https://regexr.com/)
* [regelearn](https://regexlearn.com/)
* [coding](https://coding.tools/regex-tester)

