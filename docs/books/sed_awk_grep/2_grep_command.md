---
title: Grep command
author: tianci li
contributors: 
tags:
  - grep
---

# `grep` command

The `grep` command filters the content of single or multiple files. Some variants of this command tool exist, such as `egrep (grep -E)` and `fgrep (grep -f)`. For information not covered, see [the `grep` manual](https://www.gnu.org/software/grep/manual/ "grep manual").

The usage of the `grep` command is:

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
| -C NUM                   | Print NUM lines of output context                   |

directory or file control:

| options                  | description |
| :---                     | :---        |
| --include=FILE_PATTERN   | Searches only files that match FILE_PATTERN. Wildcard characters for file names support *, ?, [], [^], [-], {..}, {,} |
| --exclude=FILE_PATTERN   | Skips files and directories matching FILE_PATTERN. Wildcard characters for file names support *, ?, [], [^], [-], {..}, {,}  |
| --exclude-dir=PATTERN    | Excludes the specified directory name. Directory name support *, ?, [], [^], [-], {..}, {,} |
| --exclude-from=FILE      | Excludes the specified directory from the file content. |

## Examples of usage

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

9. Filter files in a directory that have lines that match the string (Exclude files in subdirectories)

    ```bash
    Shell > grep -i -E "port" /etc/n*.conf -n
    /etc/named.conf:11:     listen-on port 53 { 127.0.0.1; };
    /etc/named.conf:12:     listen-on-v6 port 53 { ::1; };
    /etc/nsswitch.conf:32:# winbind                 Use Samba winbind support
    /etc/nsswitch.conf:33:# wins                    Use Samba wins support
    ```
  
10. Filter files in a directory that have lines that match the string (include or exclude files or directories in subdirectories)

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

    If you need to exclude a single directory, use the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir=selin[u]x
    ```

    If you need to exclude multiple directories, use the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it}
    ```

    If you need to exclude a single file, use the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude=sshd_config
    ```

    If you need to exclude multiple files, use the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude={ssh[a-z]_config,*.conf,services}
    ```

    If you need to exclude multiple files and directories at the same time, use the following syntax:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it} --exclude={ssh[a-z]_config,*.conf,services,[0-9][0-9]*}
    ```

11. Count all IPv4 addresses of the current machine

    ```bash
    Shell > ip a | grep -o  -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v -E "127|255"
    192.168.100.3
    ```
