---
title: Advanced Linux Commands
---

# Advanced Commands for Linux users

Advanced commands provide greater customization and controls in more specialized situations once you become familiar with basic commands.

****

**Objectives**: In this chapter, future Linux administrators will learn:

:heavy_check_mark: some useful commands not covered in the previous chapter.   
:heavy_check_mark: some advanced commands.

:checkered_flag: **user commands**, **Linux**

**Knowledge**: :star:   
**Complexity**: :star: :star: :star:

**Reading time**: 20 minutes

****

## `uniq` command

The `uniq` command is a very powerful command, used with the `sort` command, especially for log file analysis. It allows you to sort and display entries by removing duplicates.

To illustrate how the `uniq` command works, let's use a `firstnames.txt` file containing a list of first names:

```
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! Note

    `uniq` requires the input file to be sorted before running because it only compares consecutive lines.

With no argument, the `uniq` command will not display identical lines that follow each other in the `firstnames.txt` file:

```
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

To display only the rows that appear only once, use the `-u` option:

```
$ sort firstnames.txt | uniq -u
patrick
```

Conversely, to display only the lines that appear at least twice in the file, use the `-d` option:

```
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

To simply delete lines that appear only once, use the `-D` option:

```
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

Finally, to count the number of occurrences of each line, use the `-c` option:

```
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` commands

The `xargs` command allows the construction and execution of command lines from standard input.

The `xargs` command reads whitespace or linefeed delimited arguments from standard input, and executes the command (`/bin/echo` by default) one or more times using the initial arguments followed by the arguments read from standard input.

A first and simplest example would be the following:

```
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

The `xargs` command waits for an input from the standard **stdin** input. Three lines are entered. The end of the user input is specified to `xargs` by the keystroke sequence <kbd>CTRL</kbd>+<kbd>D</kbd>. `xargs` then executes the default command `echo` followed by the three arguments corresponding to the user input, namely:

```
$ echo "use" "of" "xargs"
use of xargs
```

It is possible to specify a command to be run by `xargs`.

In the following example, `xargs` will run the command `ls -ld` on the set of folders specified in the standard input:

```
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

In practice, the `xargs` command executed the `ls -ld /home /tmp /root` command.

What happens if the command to be executed does not accept multiple arguments, such as with the `find` command?

```
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

The `xargs` command attempted to execute the `find` command with multiple arguments behind the `-name` option, which caused `find` to generate an error:

```
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

In this case, the `xargs` command must be forced to execute the `find` command several times (once per line entered as standard input). The `-L` option followed by an **integer** allows you to specify the maximum number of entries to be processed with the command at one time:

```
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

To specify both arguments on the same line, use the `-n 1` option:

```
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Case study of a backup with a `tar` based on a search:

```
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

The special feature of the `xargs` command is that it places the input argument at the end of the called command. This works very well with the above example since the files passed in will form the list of files to be added to the archive.

Using the example of the `cp` command, to copy a list of files in a directory, this list of files will be added at the end of the command... but what the `cp` command expects at the end of the command is the destination. To do this,  use the `-I` option to put the input arguments somewhere else than at the end of the line.

```
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

The `-I` option allows you to specify a character (the `%` character in the above example) where the input files to `xargs` will be placed.

## `yum-utils` package

The `yum-utils` package is a collection of utilities, built for `yum` by various authors, which make it easier and more powerful to use.

!!! Note

    While `yum` has been replaced by `dnf` in Rocky Linux 8, the package name has remained `yum-utils`, although it can be installed as `dnf-utils` as well. These are classic YUM utilities implemented as CLI shims on top of DNF to maintain backwards compatibility with `yum-3`.

Here are some examples of these utilities:

* `repoquery` command

The `repoquery` command is used to query the packages in the repository.

Examples of use:

  * Display the dependencies of a package (it can be a software package that has been installed or not installed), equivalent to `dnf deplist <package-name>`
    ```
    repoquery --requires <package-name>
    ```
    
  * Display the files provided by an installed package (does not work for packages that are not installed), equivalent to `rpm -ql <package-name>`

    ```
    $ repoquery -l yum-utils
    /etc/bash_completion.d
    /etc/bash_completion.d/yum-utils.bash
    /usr/bin/debuginfo-install
    /usr/bin/find-repos-of-install
    /usr/bin/needs-restarting
    /usr/bin/package-cleanup
    /usr/bin/repo-graph
    /usr/bin/repo-rss
    /usr/bin/repoclosure
    /usr/bin/repodiff
    /usr/bin/repomanage
    /usr/bin/repoquery
    /usr/bin/reposync
    /usr/bin/repotrack
    /usr/bin/show-changed-rco
    /usr/bin/show-installed
    /usr/bin/verifytree
    /usr/bin/yum-builddep
    /usr/bin/yum-config-manager
    /usr/bin/yum-debug-dump
    /usr/bin/yum-debug-restore
    /usr/bin/yum-groups-manager
    /usr/bin/yumdownloader
    …
    ```

* `yumdownloader` command:

The `yumdownloader` command downloads RPM packages from the repositories.  Equivalent to `dnf download --downloadonly --downloaddir ./  package-name`

!!! Note

    This command is very useful to quickly build a local repository of a few rpms!

Example: `yumdownloader` will download the _samba_ rpm package and all its dependencies:

```
$ yumdownloader --destdir /var/tmp --resolve samba
or
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Options     |  Comments                                                       |
|-------------|-----------------------------------------------------------------|
| `--destdir` | The downloaded packages will be stored in the specified folder. |
| `--resolve` | Also downloads the package dependencies.                        |

## `psmisc` packages

The `psmisc` package contains utilities for managing system processes:

* `pstree`: the `pstree` command displays the current processes on the system in a tree-like structure.
* `killall`: the `killall` command sends a kill signal to all processes identified by name.
* `fuser`: the `fuser` command identifies the `PID` of processes that use the specified files or file systems.

Examples:

```
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```
# killall httpd
```

Kill processes (option `-k`) that access the `/etc/httpd/conf/httpd.conf` file:

```
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` command

The `watch` command regularly executes a command and displays the result in the terminal in full screen.

The `-n` option allows you to specify the number of seconds between each execution of the command.

!!! Note

    To exit the `watch` command, you must type the keys: <kbd>CTRL</kbd>+<kbd>C</kbd> to kill the process.

Examples:

* Display the end of the `/etc/passwd` file every 5 seconds:

```
$ watch -n 5 tail -n 3 /etc/passwd
```

Result:

```
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Monitoring the number of files in a folder:

```
$ watch -n 1 'ls -l | wc -l'
```

* Display a clock:

```
$ watch -t -n 1 date
```
