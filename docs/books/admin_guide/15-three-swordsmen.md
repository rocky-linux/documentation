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
| {,}             |  Non continuous matching of multiple single characters. Separate with commas. |
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

### Regular expressions in the GNU/Linux

Due to historical development, there are two major schools of regular expressions:

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

If you are interested in regular expressions, please visit [this website](https://www.regular-expressions.info/) to learn more useful information.

#### BRE

BRE (Basic Regular Expression) is the oldest type of regular expression, introduced by the `grep` command in UNIX systems and the **ed** text editor.

| metacharacter | description | bash example |
| :---:         | :---        | :---         |
| *             | Match the number of occurrences of the previous character, which can be 0 or any number of times. |
| .             | Match any single character except for line breaks. |
| ^             | Match line beginning. For example - **^h** will match lines starting with h. |
| $             | Match End of Line. For example - **h$** will match lines ending in h. | 
| []            | Matches any single character specified in parentheses. For example - **[who]** will match w or h or o; **[0-9]** will match one digit; **[0-9][a-z]** will match characters composed of one digit and a single lowercase letter. | 
| [^]           | Match any single character except for the characters in parentheses. For example - **[^0-9]** will match any single non numeric character. **[^a-z]** will match any single character that is not a lowercase letter. |
| \             | Escape character, used to cancel the meaning represented by some special symbols. | `echo -e "1.2\n122"  \| grep -E '1\.2'`<br/>**1.2** |
| \\{n\\}       | Matches the number of occurrences of the previous single character, n represents the number of matches.     | `echo -e "1994\n2000\n2222" \| grep "[24]\{4\}"`<br/>**2222** |
| \\{n,\\}      | Matches the previous single character at least n times. | `echo -e "1994\n2000\n2222" \| grep  "[29]\{2,\}"`<br/>1**99**4<br/>**2222** | 
| \\{n,m\\}     | Matches the previous single character at least n times and at most m times. | `echo -e "abcd\n20\n300\n4444" \| grep "[0-9]\{2,4\}"`<br/>**20**<br/>**300**<br/>**4444** |

#### ERE

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
| \\B                | Match non-boundary character.
| \\s                | Match any whitespace character. Equivalent to **[ \f\n\r\t\v]** |
| \\S                | Equivalent to **[^ \f\n\r\t\v]**  |


|  blank character   | description                      |
| :---:              | :---                             |
| \\f                | Match a single feed character. Equivalent to **\\x0c** and **\\cL**|
| \\n                | Match individual line breaks. Equivalent to **\\x0a** and **\\cJ**    |
| \\r                | Matches a single carriage return. Equivalent to **\\x0d** and **\\cM**           |
| \\t                | Matches a single tab. Equivalent to **\\x09** and **\\cI**      |
| \\v                | Matches a single vertical tab. Equivalent to **\\x0b** and **\\cK**      |

#### POSIX character

Sometimes, you may see "POSIX character"(also known as "POSIX character class"). However, the author himself rarely uses the "POSIX character", so this section is only for basic understanding.

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

#### Introducing regular expressions

There are many websites available to practice your regular expression skills online, such as:

* [regex101](https://regex101.com/)
* [oschina](https://tool.oschina.net/regex/)
* [oktools](https://oktools.net/regex)
* [regexr](https://regexr.com/)
* [regelearn](https://regexlearn.com/)
* [coding](https://coding.tools/regex-tester)
* ...

### `grep` command

The `grep` command is used to filter the content of a single or multiple file. There are some variants of this command tool, such as `egrep (grep -E)` and `fgrep (grep -f)`.

The usage of the grep command is:

```text
grep [OPTIONS] PATTERN [FILE...]
grep [OPTIONS] -e PATTERN ... [FILE...]
grep [OPTIONS] -f FILE ... [FILE...]
```

The options are mainly divided into four parts:
* match control
* output control
* content line control
* directory or file control

match control：

| options                  | description |
| :---                     | :---        |
| -E<br/>--extended-regexp | Enable ERE  |
| -P<br/>--perl-regexp     | Enable PCRE |
| -G<br/>--basic-regexp    | Enable BRE by default |
| -e<br/>--regexp=PATTERN  | Pattern matching, multiple -e options can be specified. | 
| -i                       | Ignore case |
| -w                       | Accurately match the entire word |
| -f FILE                  | Obtain patterns from FILE, one per line |
| -x                       | Pattern matching entire line |
| -v                       | Select content lines that do not match |

output control:

| options                  | description |
| :---                     | :---        |
| -m NUM                   | Output the first few matching results |
| -n                       | Print line numbers on output |
| -H                       | When matching the file content of multiple files, display the file name at the beginning of the line. This is the default setting |
| -h                       | When matching the file content of multiple files, the file name is not displayed at the beginning of the line |
| -o                       | Print only matching content without outputting the entire line |
| -q                       | Not outputting normal information |
| -s                       | Do not output error messages      |
| -r                       | Recursive matching for directories |
| -c                       | Prints the number of lines matched by each file based on the content of the user |

content line control:

| options                  | description |
| :---                     | :---        |
| -B NUM                   | Print NUM lines of leading context before matching lines |
| -A NUM                   | Print NUM lines of trailing context after matching lines |
| -C NUM                   | Print  NUM  lines  of  output  context                   |

directory or file control:

| options                  | description |
| :---                     | :---        |
| --include=FILE_PATTERN   | Search only files that match FILE_PATTERN. Wildcard characters for file names support *, ?, [], [^], [-], {..}, {,} |
| --exclude=FILE_PATTERN   | Skip files and directories matching FILE_PATTERN. Wildcard characters for file names support *, ?, [], [^], [-], {..}, {,}  |
| --exclude-dir=PATTERN    | Exclude the specified directory name. Directory name support *, ?, [], [^], [-], {..}, {,} | 
| --exclude-from=FILE      | Exclude the specified directory from the file content. | 

1. -f option and -o option

    ```bash
    Shell > cat /root/a
    abcdef
    123456
    338922549
    24680
    hello world

    Shell > cat /root/b
    12345
    test
    world
    aaaaa

    # Treat each line of file b as a matching pattern and output the lines that match file a.
    Shell > grep -f /root/b /root/a
    123456
    hello world

    Shell > grep -f /root/b /root/a -o
    12345
    world
    ```

2. Multiple pattern matching (using the -e option)

    ```bash
    Shell > echo -e "a\nab\nbc\nbcde" | grep -e 'a' -e 'cd'
    a
    ab
    bcde
    ```

    or:

    ```bash
    Shell > echo -e "a\nab\nbc\nbcde" | grep -E "a|cd"
    a
    ab
    bcde
    ```

3. Remove blank lines and comment lines from the configuration file

    ```bash
    Shell > grep -v -E "^$|^#" /etc/chrony.conf
    server ntp1.tencent.com iburst
    server ntp2.tencent.com iburst
    server ntp3.tencent.com iburst
    server ntp4.tencent.com iburst
    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    keyfile /etc/chrony.keys
    leapsectz right/UTC
    logdir /var/log/chrony
    ```

4. Print the top 5 results that all match

    ```bash
    Shell > seq 1 20 | grep -m 5 -E "[0-9]{2}"
    10
    11
    12
    13
    14
    ```

    or:

    ```bash
    Shell > seq 1 20 | grep -m 5  "[0-9]\{2\}"
    10
    11
    12
    13
    14
    ```

5. -B option and -A option

    ```bash
    Shell > seq 1 20 | grep -B 2 -A 3 -m 5 -E "[0-9]{2}"
    8
    9
    10
    11
    12
    13
    14
    15
    16
    17
    ```

6. -C option

    ```bash
    Shell > seq 1 20 | grep -C 3 -m 5 -E "[0-9]{2}"
    7
    8
    9
    10
    11
    12
    13
    14
    15
    16
    17
    ```

7. -c option

    ```bash
    Shell > cat /etc/ssh/sshd_config | grep  -n -i -E "port"
    13:# If you want to change the port on a SELinux system, you have to tell
    15:# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
    17:#Port 22
    99:# WARNING: 'UsePAM no' is not supported in RHEL and may cause several
    105:#GatewayPorts no

    Shell > cat /etc/ssh/sshd_config | grep -E -i "port" -c
    5
    ```

8. -v option

    ```bash
    Shell > cat /etc/ssh/sshd_config | grep -i -v -E "port" -c
    140
    ```

9. Filter which files in a directory have which lines that match the string (Exclude files in subdirectories)

    ```bash
    Shell > grep -i -E "port" /etc/n*.conf -n
    /etc/named.conf:11:     listen-on port 53 { 127.0.0.1; };
    /etc/named.conf:12:     listen-on-v6 port 53 { ::1; };
    /etc/nsswitch.conf:32:# winbind                 Use Samba winbind support
    /etc/nsswitch.conf:33:# wins                    Use Samba wins support
    ```
  
10. Filter which files in a directory have which lines that match the string (Include/Exclude files or directories in subdirectories)

    Include syntax for multiple files:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --include={0..20}_*
    /etc/grub.d/20_ppc_terminfo:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_ppc_terminfo:27:export TEXTDOMAINDIR=/usr/share/locale
    /etc/grub.d/20_linux_xen:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_linux_xen:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/20_linux_xen:46:# Default to disabling partition uuid support to maintian compatibility with
    /etc/grub.d/10_linux:26:export TEXTDOMAIN=grub
    /etc/grub.d/10_linux:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/10_linux:47:# Default to disabling partition uuid support to maintian compatibility with

    Shell > grep -n -i -r -E  "port" /etc/ --include={{0..20}_*,sshd_config} -c
    /etc/ssh/sshd_config:5
    /etc/grub.d/20_ppc_terminfo:2
    /etc/grub.d/10_reset_boot_success:0
    /etc/grub.d/12_menu_auto_hide:0
    /etc/grub.d/20_linux_xen:3
    /etc/grub.d/10_linux:3
    ```

    If you need to exclude a single directory, refer to the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir=selin[u]x
    ```

    If you need to exclude multiple directories, please refer to the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it}
    ```

    If you need to exclude a single file, please refer to the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude=sshd_config
    ```

    If you need to exclude multiple files, please refer to the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude={ssh[a-z]_config,*.conf,services}
    ```

    If you need to exclude multiple files and directories at the same time, please refer to the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it} --exclude={ssh[a-z]_config,*.conf,services,[0-9][0-9]*}
    ```
    
11. Count all IPv4 addresses of the current machine

    ```bash
    Shell > ip a | grep -o  -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v -E "127|255"
    192.168.100.3
    ```
