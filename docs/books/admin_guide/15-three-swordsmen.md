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

## `grep` command

The `grep` command is used to filter the content of a single or multiple file. There are some variants of this command tool, such as `egrep (grep -E)` and `fgrep (grep -f)`. For information not covered, please refer to [here]( https://www.gnu.org/software/grep/manual/ "grep manual").

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

### Examples of usage

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

## `sed` command

`sed`: Stream EDitor

**Working principle**: The `sed` command will read the currently processed row and place it in the "pattern space" for processing. After processing, the result will be output and the "pattern space" will be cleared. Next, read the next line and place it in the "pattern space" for processing, and so on, until the last line. Some documents also mention a term called "hold space" (also known as "temporary-storage space"), which can be used to temporarily store some processed data and output it through "pattern space".

**"pattern space" and "hold space"**: An area of memory where data is processed and stored.

For information not covered, please refer to [here](https://www.gnu.org/software/sed/manual/ "sed manual").

The usage of the command is:

```bash
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

| options | description |
| :---: | :--- |
| -n    | Output text lines that will only be processed by the sed command to the screen |
| -e    | Apply multiple `sed` operation commands to the input text line data |
| -f    | Call and execute `sed` script command file |
| -i    | Modify the original file |
| -r    | Regular expression | 

| Operation command<br/>(sometimes called operation instruction)| description |
| :---:                  | :--- |
| s/regexp/replacement/  | Replacement string |
|  p                     | Print the current "pattern space". Often used with the -n option, for example: `cat -n /etc/services \| sed -n '3,5p'` | 
|  d                     | Delete "pattern space". Start next cycle    |
|  D                     | Delete the first line of the "pattern space" and start next  cycle |
|  =                     | Print Line Number |
| a \text                | Add one or more lines of content after the matching line. When adding multiple lines, all lines except the last line need to use "\" to indicate that the content is not ended | 
| i \text                | Add one or more lines of content before the matching line. When adding multiple lines, all lines except the last line need to use "\" to indicate that the content is not ended |
| c \text                | Replace matching lines with new text | 
| q                      | Immediately exit the `sed` script    |
| r                      | Append text read from file |
| : label                | Label for b and t commands |
| b label                | Branch to label; if label is omitted, branch to end of script |
| t label                | If "s///" is a successful replacement, then jump to the label |
| h H                    | Copy/append "pattern space" to "hold space"  |
| g G                    | Copy/append "hold space" to "pattern space"  |
| x                      | Exchange the contents of the hold and pattern spaces |
| l                      | List out the current line in a "visually unambiguous" form |
| n N                    | Read/append the next line of input into the "pattern space" |
| w FILENAME             | Write the current pattern space to FILENAME       |
| !                      | negation |
| &                      | Referencing a string that already matches | 

| Addresses    | description |
| :---:        |  :---       |
| first~step   | Use "first" to specify the first line, and 'step' to specify the step size. For example, outputting odd lines of text can be done using `sed -n "1~2p" /etc/services` |
| $            | Match the last line of text |
| /regexp/     | Using regular expressions to match text lines | 
| number       | Specify line number  |
| addr1,addr2  | Use line number positioning to match all lines from "addr1" to "addr2" | 
| addr1,+N     | Use line number positioning to match addr1 and the N lines following addr1  | 

### Examples of usage

1. Match and print (`p`)

    * Print a line that begins with a netbios string

      ```bash
      Shell > cat /etc/services | sed -n '/^netbios/p'
      netbios-ns      137/tcp                         # NETBIOS Name Service
      netbios-ns      137/udp
      netbios-dgm     138/tcp                         # NETBIOS Datagram Service
      netbios-dgm     138/udp
      netbios-ssn     139/tcp                         # NETBIOS session service
      netbios-ssn     139/udp
      ```

      !!! tip

          As we all know, double quotation marks and single quotation marks in Shell play a different role. The **$**, **\`**, and **\\** in double quotes have a special meaning, so we recommend that you use single quotes more often when using the `sed` command.

    * Print the text from lines 23 to 26

      ```bash
      Shell > cat -n /etc/services | sed -n '23,26p'
      23  tcpmux          1/tcp                           # TCP port service multiplexer
      24  tcpmux          1/udp                           # TCP port service multiplexer
      25  rje             5/tcp                           # Remote Job Entry
      26  rje             5/udp                           # Remote Job Entry
      ```

    * Print odd lines

      ```bash
      Shell > cat -n /etc/services | sed -n '1~2p'
      1  # /etc/services:
      3  #
      5  # IANA services version: last updated 2016-07-08
      7  # Note that it is presently the policy of IANA to assign a single well-known
      9  # even if the protocol doesn't support UDP operations.
      11  # are included, only the more common ones.
      13  # The latest IANA port assignments can be gotten from
      15  # The Well Known Ports are those from 0 through 1023.
      17  # The Dynamic and/or Private Ports are those from 49152 through 65535
      19  # Each line describes one service, and is of the form:
      ...
      ```

    * Print line 10 to the last line

      ```bash
      Shell > cat -n /etc/services | sed -n '10,$p'
      10  # Updated from RFC 1700, ``Assigned Numbers'' (October 1994).  Not all ports
      11  # are included, only the more common ones.
      12  #
      13  # The latest IANA port assignments can be gotten from
      14  #       http://www.iana.org/assignments/port-numbers
      15  # The Well Known Ports are those from 0 through 1023.
      16  # The Registered Ports are those from 1024 through 49151
      17  # The Dynamic and/or Private Ports are those from 49152 through 65535
      ...
      ```

    * Lines 10 to the last do not print

      ```bash
      Shell > cat -n /etc/services | sed -n '10,$!p'
      1  # /etc/services:
      2  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
      3  #
      4  # Network services, Internet style
      5  # IANA services version: last updated 2016-07-08
      6  #
      7  # Note that it is presently the policy of IANA to assign a single well-known
      8  # port number for both TCP and UDP; hence, most entries here have two entries
      9  # even if the protocol doesn't support UDP operations.
      ```

    * Print the line number and content of the matched string

      ```bash
      Shell > sed -n -e '/netbios/=' -e '/netbios/p' /etc/services
      123
      netbios-ns      137/tcp                         # NETBIOS Name Service
      124
      netbios-ns      137/udp
      125
      netbios-dgm     138/tcp                         # NETBIOS Datagram Service
      126
      netbios-dgm     138/udp
      127
      netbios-ssn     139/tcp                         # NETBIOS session service
      128
      netbios-ssn     139/udp
      ```

    * Match string range and print it

      Use commas to separate string ranges

      ```bash
      Shell > cat  /etc/services | sed -n '/^netbios/,/^imap/p'
      netbios-ns      137/tcp                         # NETBIOS Name Service
      netbios-ns      137/udp
      netbios-dgm     138/tcp                         # NETBIOS Datagram Service
      netbios-dgm     138/udp
      netbios-ssn     139/tcp                         # NETBIOS session service
      netbios-ssn     139/udp
      imap            143/tcp         imap2           # Interim Mail Access Proto v2
      ```

      !!! info

          **Start of range**: Match the line where the string is located, only matching the first string that appears.
          **End of range**: Match the line where the string is located, only matching the first string that appears.

      ```bash
      Shell > grep -n ^netbios /etc/services
      123:netbios-ns      137/tcp                         # NETBIOS Name Service
      124:netbios-ns      137/udp
      125:netbios-dgm     138/tcp                         # NETBIOS Datagram Service
      126:netbios-dgm     138/udp
      127:netbios-ssn     139/tcp                         # NETBIOS session service
      128:netbios-ssn     139/udp

      Shell > grep -n ^imap /etc/services
      129:imap            143/tcp         imap2           # Interim Mail Access Proto v2
      130:imap            143/udp         imap2
      168:imap3           220/tcp                         # Interactive Mail Access
      169:imap3           220/udp                         # Protocol v3
      260:imaps           993/tcp                         # IMAP over SSL
      261:imaps           993/udp                         # IMAP over SSL
      ```

      In other words, the content printed above is lines 123 to 129

    * Print the line where the string is located and until the last line

      ```bash
      Shell > cat /etc/services | sed -n '/^netbios/,$p'
      ```

    * Using variables in bash scripts

      ```bash
      Shell > vim test1.sh
      #!/bin/bash
      a=10

      sed -n ''${a}',$!p' /etc/services
      # or
      sed -n "${a},\$!p" /etc/services
      ```

    * Regular expression

      Matches only "Three Digits" + "/udp".

      ```bash
      Shell > cat /etc/services | sed -r -n '/[^0-9]([1-9]{3}\/udp)/p'
      sunrpc          111/udp         portmapper rpcbind      # RPC 4.0 portmapper UDP
      auth            113/udp         authentication tap ident
      sftp            115/udp
      uucp-path       117/udp
      nntp            119/udp         readnews untp   # USENET News Transfer Protocol
      ntp             123/udp                         # Network Time Protocol
      netbios-ns      137/udp
      netbios-dgm     138/udp
      netbios-ssn     139/udp
      ...
      ```
      
2. Match and delete (`d`)

    It's similar to printing, except that the operation command is replaced with `d` and the -n option is not required.

    * Delete all lines that match the udp string, and delete all comment lines, and delete all Blank line

      ```bash
      Shell > sed -e '/udp/d' -e '/^#/d' -e '/^$/d' /etc/services
      tcpmux          1/tcp                           # TCP port service multiplexer
      rje             5/tcp                           # Remote Job Entry
      echo            7/tcp
      discard         9/tcp           sink null
      systat          11/tcp          users
      daytime         13/tcp
      qotd            17/tcp          quote
      chargen         19/tcp          ttytst source
      ftp-data        20/tcp
      ftp             21/tcp
      ssh             22/tcp                          # The Secure Shell (SSH) Protocol
      telnet          23/tcp
      ...
      ```

    * Delete consecutive lines of text

      ```bash
      Shell > cat -n /etc/services | sed '10,$d'
      1  # /etc/services:
      2  # $Id: services,v 1.49 2017/08/18 12:43:23 ovasik Exp $
      3  #
      4  # Network services, Internet style
      5  # IANA services version: last updated 2016-07-08
      6  #
      7  # Note that it is presently the policy of IANA to assign a single well-known
      8  # port number for both TCP and UDP; hence, most entries here have two entries
      9  # even if the protocol doesn't support UDP operations.
      ```

    * Regular expression

      ```bash
      Shell > cat  /etc/services | sed -r '/(tcp)|(udp)|(^#)|(^$)/d'
      http            80/sctp                         # HyperText Transfer Protocol
      bgp             179/sctp
      https           443/sctp                        # http protocol over TLS/SSL
      h323hostcall    1720/sctp                       # H.323 Call Control
      nfs             2049/sctp       nfsd shilp      # Network File System
      rtmp            1/ddp                           # Routing Table Maintenance Protocol
      nbp             2/ddp                           # Name Binding Protocol
      echo            4/ddp                           # AppleTalk Echo Protocol
      zip             6/ddp                           # Zone Information Protocol
      discard         9/sctp                  # Discard
      discard         9/dccp                  # Discard SC:DISC
      ...
      ```

3. Replace strings(`s///g`)

    | Syntax                               | Syntax description|
    | :---                                 | :---              |
    | `sed 's/string/replace/g' FILENAME`  | **s**: All lines representing the content of the file. You can also specify the range of lines, for example: `sed '20,200s/netbios/TMP/g' /etc/services`<br/>**g** (Global): If there is no g, This means that when multiple matching strings appear on a single line, only the first matching string will be replaced.<br/> **/**: Delimiter style. You can also specify other styles, for example: `sed '20,200s?netbios?TMP?g' /etc/services` |

    !!! tip

        Example in the bash script:

        ```bash
        Shell > vim /root/sedReplace.sh
        #!/bin/bash
        a="SELINUX=enforcing"
        b="SELINUX=disabled"

        sed -i 's/'${a}'/'${b}'/g' /etc/selinux/config
        # or
        sed -i "s/${a}/${b}/g" /etc/selinux/config
        ```

    * Replace and print

      ```bash
      Shell > sed -n '44,45s/ssh/SSH/gp' /etc/services
      SSH             22/tcp
      SSH             22/udp
      ```

    * Use the "&" symbol to reference a string

      ```bash
      Shell > sed -n '44,45s/ssh/&-SSH/gp' /etc/services
      ssh-SSH             22/tcp
      ssh-SSH             22/udp
      ```

    * Use a string to locate one or more lines and replace the specified string within the line range

      ```bash
      Shell > grep ssh /etc/services -n
      44:ssh             22/tcp                          # The Secure Shell (SSH) Protocol
      45:ssh             22/udp                          # The Secure Shell (SSH) Protocol
      551:x11-ssh-offset  6010/tcp                        # SSH X11 forwarding offset
      593:ssh             22/sctp                 # SSH
      1351:sshell          614/tcp                 # SSLshell
      1352:sshell          614/udp                 #       SSLshell
      1607:netconf-ssh     830/tcp                 # NETCONF over SSH
      1608:netconf-ssh     830/udp                 # NETCONF over SSH
      7178:sdo-ssh         3897/tcp                # Simple Distributed Objects over SSH
      7179:sdo-ssh         3897/udp                # Simple Distributed Objects over SSH
      7791:netconf-ch-ssh  4334/tcp                # NETCONF Call Home (SSH)
      8473:snmpssh         5161/tcp                # SNMP over SSH Transport Model
      8474:snmpssh-trap    5162/tcp                # SNMP Notification over SSH Transport Model
      9126:tl1-ssh         6252/tcp                # TL1 over SSH
      9127:tl1-ssh         6252/udp                # TL1 over SSH
      10796:ssh-mgmt        17235/tcp               # SSH Tectia Manager
      10797:ssh-mgmt        17235/udp               # SSH Tectia Manager

      Shell > sed '/ssh/s/tcp/TCP/gp' -n  /etc/services
      ssh             22/TCP                          # The Secure Shell (SSH) Protocol
      x11-ssh-offset  6010/TCP                        # SSH X11 forwarding offset
      sshell          614/TCP                 # SSLshell
      netconf-ssh     830/TCP                 # NETCONF over SSH
      sdo-ssh         3897/TCP                # Simple Distributed Objects over SSH
      netconf-ch-ssh  4334/TCP                # NETCONF Call Home (SSH)
      snmpssh         5161/TCP                # SNMP over SSH Transport Model
      snmpssh-trap    5162/TCP                # SNMP Notification over SSH Transport Model
      tl1-ssh         6252/TCP                # TL1 over SSH
      ssh-mgmt        17235/TCP               # SSH Tectia Manager
      ```

    * String replacement for consecutive lines

      ```bash
      Shell > sed '10,30s/tcp/TCP/g' /etc/services
      ```

    * Multiple matches and replacements

      ```bash
      Shell > cat /etc/services | sed 's/netbios/test1/g ; s/^#//d ; s/dhcp/&t2/g'
      ```

    * Group replacement of regular expressions

      In regular expressions, a "()" is a grouping. \1 represents reference group 1, \2 represents reference group 2, and so on. 

      ```bash
      Shell > cat /etc/services
      ...
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures

      Shell > cat /etc/services | sed -r 's/([0-9]*\/tcp)/\1\tCONTENT1/g ; s/([0-9]*\/udp)/\1\tADD2/g'
      ...
      axio-disc       35100/tcp       CONTENT1               # Axiomatic discovery protocol
      axio-disc       35100/udp       ADD2               # Axiomatic discovery protocol
      pmwebapi        44323/tcp       CONTENT1               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp       ADD2               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp       CONTENT1               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp       CONTENT1               # Capture handwritten signatures
      ```

      **\t**: That is, a tab

    * Replace all comment lines with blank space

      ```bash
      Shell > cat /etc/services | sed -r 's/(^#.*)//g'
      ...
      chargen         19/udp          ttytst source
      ftp-data        20/tcp
      ftp-data        20/udp

      ftp             21/tcp
      ftp             21/udp          fsp fspd
      ssh             22/tcp                          # The Secure Shell (SSH) Protocol
      ssh             22/udp                          # The Secure Shell (SSH) Protocol
      ...
      ```

    * Replace one of the lowercase letters of a word with a capital letter

      ```bash
      Shell > echo -e "hello,world\nPOSIX" | sed -r 's/(.*)w/\1W/g'
      hello,World
      POSIX
      ```

    * String position swapping

      ```bash
      Shell > cat /etc/services
      ...
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

      We can divide this file into five parts:

      ```txt
      cloudcheck-ping    45514       /     udp        # ASSIA CloudCheck WiFi Management keepalive
       ↓                   ↓         ↓      ↓               ↓
      (.*)           (\<[0-9]+\>)   \/   (tcp|udp)         (.*)
       ↓                   ↓                ↓               ↓ 
       \1                 \2               \3              \4
      ```

      ```bash
      Shell > cat /etc/services | sed -r 's/(.*)(\<[0-9]+\>)\/(tcp|udp)(.*)/\1\3\/\2\4/g'
      ...
      edi_service     udp/34567               # dhanalakshmi.org EDI Service
      axio-disc       tcp/35100               # Axiomatic discovery protocol
      axio-disc       udp/35100               # Axiomatic discovery protocol
      pmwebapi        tcp/44323               # Performance Co-Pilot client HTTP API
      cloudcheck-ping udp/45514               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      tcp/45514               # ASSIA CloudCheck WiFi Management System
      spremotetablet  tcp/46998               # Capture handwritten signatures
      ```

    * Remove any blank characters

      ```bash
      Shell > echo -e "abcd\t1 2 3 4\tWorld"
      abcd    1 2 3 4 World
      Shell > echo -e "abcd\t1 2 3 4\tWorld" | sed -r 's/(\s)*//g'
      abcd1234World
      ```
    
4. Execute multiple times using the -e option

    The following example:
   
    ```bash
    Shell > tail -n 10 /etc/services
    aigairserver    21221/tcp               # Services for Air Server
    ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
    ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
    edi_service     34567/udp               # dhanalakshmi.org EDI Service
    axio-disc       35100/tcp               # Axiomatic discovery protocol
    axio-disc       35100/udp               # Axiomatic discovery protocol
    pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
    cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
    cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
    spremotetablet  46998/tcp               # Capture handwritten signatures

    Shell > tail -n 10 /etc/services | sed  -e '1,3d' -e '/cloud/s/ping/PING/g'
    # or
    Shell > tail -n 10 /etc/services | sed  '1,3d ; /cloud/s/ping/PING/g'      
    edi_service     34567/udp               # dhanalakshmi.org EDI Service
    axio-disc       35100/tcp               # Axiomatic discovery protocol
    axio-disc       35100/udp               # Axiomatic discovery protocol
    pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
    cloudcheck-PING 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
    cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
    spremotetablet  46998/tcp               # Capture handwritten signatures
    ```

5. Add content above or below a specific line (`i` and `a`)

    * Add two lines of content above the specified line number

      ```bash
      Shell > tail -n 10 /etc/services > /root/test.txt
      Shell > cat /root/test.txt
      aigairserver    21221/tcp               # Services for Air Server
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      edi_service     34567/udp               # dhanalakshmi.org EDI Service
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures

      Shell > cat /root/test.txt | sed '3i 123\
      abc'
      aigairserver    21221/tcp               # Services for Air Server
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      123
      abc
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      edi_service     34567/udp               # dhanalakshmi.org EDI Service
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

   * Add three lines below the specified line number

     ```bash
     Shell > cat /root/test.txt | sed '5a 123\
     comment yes\
     tcp or udp'
     aigairserver    21221/tcp               # Services for Air Server
     ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
     ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
     edi_service     34567/udp               # dhanalakshmi.org EDI Service
     axio-disc       35100/tcp               # Axiomatic discovery protocol
     123
     comment yes
     tcp or udp
     axio-disc       35100/udp               # Axiomatic discovery protocol
     pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
     cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
     cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
     spremotetablet  46998/tcp               # Capture handwritten signatures
     ```

    * Match a specific line based on a string and add 2 lines of content above it 

      ```bash
      Shell > cat /root/test.txt | sed '/tcp/iTCP\
      UDP'
      TCP
      UDP
      aigairserver    21221/tcp               # Services for Air Server
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      TCP
      UDP
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      edi_service     34567/udp               # dhanalakshmi.org EDI Service
      TCP
      UDP
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      TCP
      UDP
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      TCP
      UDP
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      TCP
      UDP
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

6. Replace lines (`c`)

    * Locate one or more lines based on a string and replace these lines of text

      ```bash
      Shell > cat /root/test.txt | sed '/ser/c\TMP1 \
      TMP2'
      TMP1
      TMP2
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      TMP1
      TMP2
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

    * Single line replacement

      ```bash
      Shell > cat /root/test.txt | sed '7c REPLACE'
      aigairserver    21221/tcp               # Services for Air Server
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      edi_service     34567/udp               # dhanalakshmi.org EDI Service
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      REPLACE
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

    * Replace consecutive lines of text

      ```bash
      Shell > cat /root/test.txt | sed '2,$c REPLACE1 \
      replace2'
      aigairserver    21221/tcp               # Services for Air Server
      REPLACE1
      replace2
      ```

    * Replace even numbered lines

      ```bash
      Shell > cat /root/test.txt | sed '2~2c replace'
      aigairserver    21221/tcp               # Services for Air Server
      replace
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      replace
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      replace
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      replace
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      replace
      ```

7. Read the contents of the file and append its contents below the matching line (`r`)

    ```bash
    Shell > cat /root/app.txt
    append1
    POSIX
    UNIX

    Shell > cat /root/test.txt | sed '/ping/r /root/app.txt'
    aigairserver    21221/tcp               # Services for Air Server
    ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
    ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
    edi_service     34567/udp               # dhanalakshmi.org EDI Service
    axio-disc       35100/tcp               # Axiomatic discovery protocol
    axio-disc       35100/udp               # Axiomatic discovery protocol
    pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
    cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
    append1
    POSIX
    UNIX
    cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
    spremotetablet  46998/tcp               # Capture handwritten signatures
    ```

8. Write matching lines to other files (`w`)

    ```bash
    Shell > cat /root/test.txt | sed '/axio/w /root/storage.txt'

    Shell > cat /root/storage.txt
    axio-disc       35100/tcp               # Axiomatic discovery protocol
    axio-disc       35100/udp               # Axiomatic discovery protocol
    ```

9. Read/append the next line of input into the "pattern space" (`n` and `N`)

    * Print the next line of the matching line

      ```bash
      Shell > cat /root/test.txt
      aigairserver    21221/tcp               # Services for Air Server
      ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      edi_service     34567/udp               # dhanalakshmi.org EDI Service
      axio-disc       35100/tcp               # Axiomatic discovery protocol
      axio-disc       35100/udp               # Axiomatic discovery protocol
      pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      spremotetablet  46998/tcp               # Capture handwritten signatures

      Shell > cat /root/test.txt | sed '/ping/{n;p}' -n
      cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      ```

      !!! tip

          Multiple `sed` operation commands may affect each other, and you can use "**{ }**" to reduce this effect.

    * Print even text lines

      First read the first line, as there is an `n` command present, the second line will be printed out, and so on.

      ```bash
      Shell > cat -n /root/test.txt | sed -n '{n;p}'
      # or
      Shell > cat -n /root/test.txt | sed -n '2~2p'
      2  ka-kdp          31016/udp               # Kollective Agent Kollective Delivery
      4  edi_service     34567/udp               # dhanalakshmi.org EDI Service
      6  axio-disc       35100/udp               # Axiomatic discovery protocol
      8  cloudcheck-ping 45514/udp               # ASSIA CloudCheck WiFi Management keepalive
      10  spremotetablet  46998/tcp               # Capture handwritten signatures
      ```

    * Print odd text lines

      ```bash
      Shell > cat -n /root/test.txt | sed -n '{p;n}'
      # or
      Shell > cat -n /root/test.txt | sed -n '1~2p'
      # or
      Shell > cat -n /root/test.txt | sed 'n;d'
      1  aigairserver    21221/tcp               # Services for Air Server
      3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      5  axio-disc       35100/tcp               # Axiomatic discovery protocol
      7  pmwebapi        44323/tcp               # Performance Co-Pilot client HTTP API
      9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      ```

    * Print 3n lines

      ```bash
      Shell > cat -n /root/test.txt | sed -n '{n;n;p}'
      # or
      Shell > cat -n /root/test.txt | sed -n '3~3p'
      3  ka-sddp         31016/tcp               # Kollective Agent Secure Distributed Delivery
      6  axio-disc       35100/udp               # Axiomatic discovery protocol
      9  cloudcheck      45514/tcp               # ASSIA CloudCheck WiFi Management System
      ```

    * `N`

      Read the first line and append one line after encountering the `N` command. In this example, the "pattern space" is "1\n2". Finally, execute the `q` command to exit.

      ```bash
      Shell > seq 1 10 | sed 'N;q'
      1
      2
      ```

      Because there is no additional line after line 9, the output is as follows:

      ```bash
      Shell > seq 1 9 | sed -n 'N;p'
      1
      2
      3
      4
      5
      6
      7
      8
      ```
      
      When the last line is read, the `N` command is not executed and the output is as follows:

      ```bash
      Shell > seq 1 9 | sed -n '$!N;p'
      1
      2
      3
      4
      5
      6
      7
      8
      9
      ```

      Merge two lines into one line. Replace the "\n" of the "pattern space" with a blank character.

      ```bash
      Shell > seq 1 6 | sed 'N;{s/\n//g}'
      12
      34
      56
      ```

10. Ignore case (`I`)

      There seems to be no information about ignoring case in `man 1 sed`.    

      ```bash
      Shell > echo -e "abc\nAbc" | sed -n 's/a/X/Igp'
      Xbc
      XBC
      ```

      ```bash
      Shell > cat /etc/services | sed '/OEM/Ip' -n
      oem-agent       3872/tcp                # OEM Agent
      oem-agent       3872/udp                # OEM Agent
      oemcacao-jmxmp  11172/tcp               # OEM cacao JMX-remoting access point
      oemcacao-rmi    11174/tcp               # OEM cacao rmi registry access point
      oemcacao-websvc 11175/tcp               # OEM cacao web service access point
      ```

      ```bash
      Shell > cat /etc/services | sed -r '/(TCP)|(UDP)/Id'
      ```

      ```bash
      Shell > cat /etc/services | sed -r '/(TCP)|(UDP)/Ic TMP'
      ```

11. Gets the total number of lines in a file

      ```bash
      Shell > cat /etc/services | sed -n '$='
      # or
      Shell > cat /etc/services | wc -l

      11473
      ```

## `awk` command

In 1977, a programming language-level tool for processing text was born at Bell Labs, named `awk`. The name comes from the first letters of the last names of three famous people:

* Alfred **A**ho
* Peter **W**einberger
* Brian **K**ernighan

Just as shell is divided into bash, csh, zsh, and ksh, awk has different variants or derivatives with the development of history:

* `awk`: Born in 1977 Bell Labs.
* `nawk` (new awk): It was born in 1985 and is an updated and enhanced version of awk. It was widely used with the release of Unix System V Release 3.1 (1987). The old version of awk is called `oawk` (old awk).
* `gawk` (GNU awk): It was written by Paul Rubin in 1986. The GNU Project was born in 1984.
* `mawk`: It was written in 1996 by Mike Brennan, which is the interpreter of the awk programming language.
* `jawk`: Implementation of awk in JAVA

In the GNU/Linux operating system, the usual awk refers to `gawk`. However, some distributions use `mawk` as their default awk, such as Ubuntu or Debian.

In the Rocky Linux 8.8, awk refers to gawk.

```bash
Shell > whereis awk
awk: /usr/bin/awk /usr/libexec/awk /usr/share/awk /usr/share/man/man1/awk.1.gz

Shell > ls -l /usr/bin/awk
lrwxrwxrwx. 1 root root 4 4月  16 2022 /usr/bin/awk -> gawk

Shell > rpm -qf /usr/bin/awk
gawk-4.2.1-4.el8.x86_64
```

For information not covered, please refer to [here](https://www.gnu.org/software/gawk/manual/ "gawk manual")

Although `awk` is a tool for processing text, it has some programming language features:

* variable
* process control (loop)
* data type
* logical operation
* function
* array
* ...

**The working principle of `awk`**: Similar to relational databases, it supports processing of fields (columns) and records (rows). By default, awk treats each line of a file as a record and places these records in memory for line-by-line processing, with a portion of each line treated as a field in the record. By default, Spaces and tabs are used as delimiters to separate different fields, and numbers are used to represent different fields in the row record. To reference multiple fields, separate them with commas or tabs.

A simple example that is easy to understand：

```bash
Shell > df -hT 
| 1             |     2        |  3    |  4   |  5    |   6   |   7            | 8       |
|Filesystem     |    Type      | Size  | Used | Avail | Use%  | Mounted        | on      |←← 1 (first line)
|devtmpfs       |    devtmpfs  | 1.8G  |   0  | 1.8G  |  0%   | /dev           |         |←← 2
|tmpfs          |    tmpfs     | 1.8G  |    0 | 1.8G  |  0%   | /dev/shm       |         |←← 3
|tmpfs          |    tmpfs     | 1.8G  | 8.9M | 1.8G  |  1%   | /run           |         |←← 4
|tmpfs          |    tmpfs     | 1.8G  |   0  | 1.8G  |  0%   | /sys/fs/cgroup |         |←← 5
|/dev/nvme0n1p2 |    ext4      | 47G   | 2.6G |  42G  |  6%   | /              |         |←← 6
|/dev/nvme0n1p1 |    xfs       | 1014M | 182M | 833M  |  18%  | /boot          |         |←← 7
|tmpfs          |    tmpfs     | 364M  |   0  | 364M  |  0%   | /run/user/0    |         |←← 8  (end line)

Shell > df -hT | awk '{print $1,$2}'
Filesystem  Type
devtmpfs devtmpfs
tmpfs tmpfs
tmpfs tmpfs
tmpfs tmpfs
/dev/nvme0n1p2 ext4
/dev/nvme0n1p1 xfs
tmpfs tmpfs

# $0: Reference the entire text content.
Shell > df -hT | awk '{print $0}'
Filesystem     Type      Size   Used  Avail Use% Mounted on
devtmpfs       devtmpfs  1.8G     0  1.8G    0%  /dev
tmpfs          tmpfs     1.8G     0  1.8G    0%  /dev/shm
tmpfs          tmpfs     1.8G  8.9M  1.8G    1%  /run
tmpfs          tmpfs     1.8G     0  1.8G    0%  /sys/fs/cgroup
/dev/nvme0n1p2 ext4       47G  2.6G   42G    6%  /
/dev/nvme0n1p1 xfs      1014M  182M  833M   18%  /boot
tmpfs          tmpfs     364M     0  364M    0%  /run/user/0
```

### Instructions for using `awk`

The usage of awk is - `awk option  'pattern {action}'  FileName`

**pattern**: Find specific content in the text
**action**: Action instruction
**{ }**: Group some instructions according to specific patterns

| option | description | 
| :---   | :---        |
| -f program-file<br/>--file program-file | Reading awk program source files from files |
| -F FS  | Specify the separator for separating fields. The 'FS' here is a built-in variable in awk, with default values of spaces or tabs |
| -v var=value | variable assignment |
| --posix | Turn on compatibility mode |
| --dump-variables=[file] | Write global variables in awk to a file. If no file is specified, the default file is awkvars.out |
| --profile=[file] | Write performance analysis data to a specific file. If no file is specified, the default file is awkprof.out |

| pattern                | description | 
| :---                   | :---        |
| BEGIN{ }               | An action that is performed before all row records are read |
| END{ }                 | An action that is performed after all row records are read|
| /regular  expression/  | Match the regular expression for each input line record |
| pattern && pattern     | Logic and operation |
| pattern \|\| pattern   | Logic or operation |
| !pattern               | Logical negation operation|
| pattern1,pattern2      | Specify the pattern range to match all row records within that range |

`awk` is powerful and involves a lot of knowledge, so some of the content will be explained later.

#### `printf`  commands

Before formally learning `awk`, beginners need to understand the command `printf`.

`printf`：format and print data. Its usage is -`printf FORMAT [ARGUMENT]...`

**FORMAT**：Used to control the content of the output. The following common interpretation sequences are supported：

* **\a** - alert (BEL)
* **\b** - backspace
* **\f** - form feed
* **\n** - new line
* **\r** - carriage return
* **\t** - horizontal tab
* **\v** - vertical tab
* **%Ns** - The output string. The N represents the number of strings, for example: `%s %s %s`
* **%Ni** - Output integers. The N represents the number of integers of the output, for example: `%i %i`
* **%m\.nf** - Output Floating Point Number. The m represents the total number of digits output, and the n represents the number of digits after the decimal point. For examle: `%8.5f`

**ARGUMENT**: If it is a file, you need to do some preprocessing to output correctly.

```bash
Shell > cat /tmp/printf.txt
ID      Name    Age     Class
1       Frank   20      3
2       Jack    25      5
3       Django  16      6
4       Tom     19      7

# Example of incorrect syntax:
Shell > printf '%s %s $s\n' /tmp/printf.txt
/tmp/printf.txt

# Change the format of the text
Shell > printf '%s' $(cat /tmp/printf.txt)
IDNameAgeClass1Frank2032Jack2553Django1664Tom197
# Change the format of the text
Shell > printf '%s\t%s\t%s\n' $(cat /tmp/printf.txt)
ID      Name    Age
Class   1       Frank
20      3       2
Jack    25      5
3       Django  16
6       4       Tom
19      7

Shell > printf "%s\t%s\t%s\t%s\n" a b c d 1 2 3 4
a       b       c       d
1       2       3       4
```

There is no `print` command in The RockyLinux OS, `print` can only be used in awk, and its difference from printf is that it automatically adds a newline at the end of each line. For example:

```bash
Shell > awk '{printf $1 "\t" $2"\n"}' /tmp/printf.txt
ID      Name
1       Frank
2       Jack
3       Django
4       Tom

Shell > awk '{print $1 "\t" $2}' /tmp/printf.txt
ID      Name
1       Frank
2       Jack
3       Django
4       Tom
```