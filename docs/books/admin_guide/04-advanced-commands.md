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

To illustrate how the `uniq` command works, let us use a `firstnames.txt` file containing a list of first names:

```text
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

```bash
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

To display only the rows that appear only once, use the `-u` option:

```bash
$ sort firstnames.txt | uniq -u
patrick
```

Conversely, to display only the lines that appear at least twice in the file, use the `-d` option:

```bash
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

To simply delete lines that appear only once, use the `-D` option:

```bash
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

```bash
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```bash
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` commands

The `xargs` command allows the construction and execution of command lines from standard input.

The `xargs` command reads whitespace or linefeed delimited arguments from standard input, and executes the command (`/bin/echo` by default) one or more times using the initial arguments followed by the arguments read from standard input.

A first and simplest example would be the following:

```bash
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

The `xargs` command waits for an input from the standard **stdin** input. Three lines are entered. The end of the user input is specified to `xargs` by the keystroke sequence ++ctrl+d++. `xargs` then executes the default command `echo` followed by the three arguments corresponding to the user input, namely:

```bash
$ echo "use" "of" "xargs"
use of xargs
```

It is possible to specify a command to be run by `xargs`.

In the following example, `xargs` will run the command `ls -ld` on the set of folders specified in the standard input:

```bash
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

```bash
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

The `xargs` command attempted to execute the `find` command with multiple arguments behind the `-name` option, which caused `find` to generate an error:

```bash
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

In this case, the `xargs` command must be forced to execute the `find` command several times (once per line entered as standard input). The `-L` option followed by an **integer** allows you to specify the maximum number of entries to be processed with the command at one time:

```bash
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

```bash
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

```bash
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

The special feature of the `xargs` command is that it places the input argument at the end of the called command. This works very well with the above example since the files passed in will form the list of files to be added to the archive.

Using the example of the `cp` command, to copy a list of files in a directory, this list of files will be added at the end of the command... but what the `cp` command expects at the end of the command is the destination. To do this,  use the `-I` option to put the input arguments somewhere else than at the end of the line.

```bash
find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

The `-I` option allows you to specify a character (the `%` character in the above example) where the input files to `xargs` will be placed.

## `yum-utils` package

The `yum-utils` package is a collection of utilities, built for `yum` by various authors, which make it easier and more powerful to use.

!!! Note

    While `yum` has been replaced by `dnf` in Rocky Linux 8, the package name has remained `yum-utils`, although it can be installed as `dnf-utils` as well. These are classic YUM utilities implemented as CLI shims on top of DNF to maintain backwards compatibility with `yum-3`.

Here are some examples of these utilities.

### `repoquery` command

The `repoquery` command is used to query the packages in the repository.

Examples of use:

* Display the dependencies of a package (it can be a software package that has been installed or not installed), equivalent to `dnf deplist <package-name>`

```bash
repoquery --requires <package-name>
```

* Display the files provided by an installed package (does not work for packages that are not installed), equivalent to `rpm -ql <package-name>`

```bash
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

### `yumdownloader` command

The `yumdownloader` command downloads RPM packages from the repositories.  Equivalent to `dnf download --downloadonly --downloaddir ./  package-name`

!!! Note

    This command is very useful to quickly build a local repository of a few rpms!

Example: `yumdownloader` will download the _samba_ rpm package and all its dependencies:

```bash
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

```bash
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

```bash
# killall httpd
```

Kill processes (option `-k`) that access the `/etc/httpd/conf/httpd.conf` file:

```bash
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` command

The `watch` command regularly executes a command and displays the result in the terminal in full screen.

The `-n` option allows you to specify the number of seconds between each execution of the command.

!!! Note

    To exit the `watch` command, you must type the keys: <kbd>CTRL</kbd>+<kbd>C</kbd> to kill the process.

Examples:

* Display the end of the `/etc/passwd` file every 5 seconds:

```bash
watch -n 5 tail -n 3 /etc/passwd
```

Result:

```bash
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Monitoring the number of files in a folder:

```bash
watch -n 1 'ls -l | wc -l'
```

* Display a clock:

```bash
watch -t -n 1 date
```

## `install` command

Contrary to what its name might suggest, the `install` command is not used to install new packages.

This command combines file copying (`cp`) and directory creation (`mkdir`), with rights management (`chmod`, `chown`) and other useful functionalities (like backups).

```bash
install source dest  
install -t directory source [...]
install -d directory
```

Options:

| Options | Remarks                                                      |
| ------- | ------------------------------------------------------------ |
| `-b` or `--backup[=suffix]` | creates a backup of destination file     |
| `-d`    | treats arguments as directory names                          |
| `-D`    | creates all leading components before copying SOURCE to DEST |
| `-g` and `-o`    | sets ownership                                      |
| `-m`    | sets permissions                                             |
| `-p`    | preserves the timestamps of the sources files                |
| `-t`    | copies all source arguments to the directory                 |

!!! note

    There are options for managing the SELinux context (see the manual page).

Examples:

Create a directory with the `-d` option:

```bash
install -d ~/samples
```

Copy a file from a source location to a directory:

```bash
install src/sample.txt ~/samples/
```

These two orders could have been carried out with a single command:

```bash
$ install -v -D -t ~/samples/ src/sample.txt
install: creating directory '~/samples'
'src/sample.txt' -> '~/samples/sample.txt'
```

This command already saves time. Combine it with owner, owner group, and rights management to improve the time savings:

```bash
sudo install -v -o rocky -g users -m 644 -D -t ~/samples/ src/sample.txt
```

 !!! note

     `sudo` is required in this case to make property changes.

You can also create a backup of existing files thanks to the `-b` option:

```bash
$ install -v -b -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt~')
```

As you can see, the `install` command creates a backup file with a `~` tilde appended to the original file name.

The suffix can be specified thanks to the `-S` option:

```bash
$ install -v -b -S ".bak" -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt.bak')
```

## `tree` command

Expand the files or directories contained in the directory in a tree like manner. 

| options | desction |
| :--- | :--- |
| `-a` | All files are listed |
| `-h` | Print the size in a more human readable way |
| `-u` | Displays file owner or UID number |
| `-g` | Displays file group owner or GID number |
| `-p` | Print the protections for each file |

For example:

```bash
$ tree -hugp /etc/yum.repos.d/
/etc/yum.repos.d/
├── [-rw-r--r-- root     root      1.6K]  epel-modular.repo
├── [-rw-r--r-- root     root      1.3K]  epel.repo
├── [-rw-r--r-- root     root      1.7K]  epel-testing-modular.repo
├── [-rw-r--r-- root     root      1.4K]  epel-testing.repo
├── [-rw-r--r-- root     root       710]  Rocky-AppStream.repo
├── [-rw-r--r-- root     root       695]  Rocky-BaseOS.repo
├── [-rw-r--r-- root     root      1.7K]  Rocky-Debuginfo.repo
├── [-rw-r--r-- root     root       360]  Rocky-Devel.repo
├── [-rw-r--r-- root     root       695]  Rocky-Extras.repo
├── [-rw-r--r-- root     root       731]  Rocky-HighAvailability.repo
├── [-rw-r--r-- root     root       680]  Rocky-Media.repo
├── [-rw-r--r-- root     root       680]  Rocky-NFV.repo
├── [-rw-r--r-- root     root       690]  Rocky-Plus.repo
├── [-rw-r--r-- root     root       715]  Rocky-PowerTools.repo
├── [-rw-r--r-- root     root       746]  Rocky-ResilientStorage.repo
├── [-rw-r--r-- root     root       681]  Rocky-RT.repo
└── [-rw-r--r-- root     root      2.3K]  Rocky-Sources.repo

0 directories, 17 files
```

## `stat` command

The `stat` command is used to display the status of a file or file system.

```bash
$ stat /root/anaconda-ks.cfg
  File: /root/anaconda-ks.cfg
  Size: 1352            Blocks: 8          IO Block: 4096   regular file
Device: 10302h/66306d   Inode: 2757097     Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-01-20 13:04:57.012033583 +0800
Modify: 2023-09-25 14:04:48.524760784 +0800
Change: 2024-01-24 16:37:34.315995221 +0800
 Birth: 2
```

* `File` - Displays the path location of the file.
* `Size` - Displays the file size in bytes. If this is a directory, display the fixed 4096 bytes occupied by the directory name.
* `Blocks` - Displays the number of allocated blocks. Attention, please! The size of each block in this command is 512 bytes. The default size of each block in 'ls-ls' is 1024 bytes.
* `Device` - Device number in decimal notation. Device number in hexadecimal notation.
* `Inode` - Inode is a unique ID number assigned by the Linux kernel to a file or directory.
* `Links` - Number of hard links. Hard links are sometimes referred to as physical links.
* `Access` - The last access time of files and directories, i.e. `atime` in GNU/Linux.
* `Modify` - The last modification time of files and directories, i.e. `mtime` in GNU/Linux.
* `Change` - The last time the property is changed, i.e. `ctime` in GNU/Linux.
* `Birth` - Birth time (Creation time). In some documents, it is abbreviated as `btime` or `crtime`. To display the creation time, you need a file system and kernel version higher than a certain version.

For files:

**atime** - After accessing the file content using commands such as `cat`, `less`, `more`, and `head`, the `atime` of the file can be updated. Please pay attention! The `atime` of the file is not updated in real-time, and for performance reasons, it needs to wait for a period of time before it can be displayed.
**mtime** - Modifying the file content can update the `mtime` of the file (such as appending or overwriting the file content through redirection), because the file size is a property of the file, the `ctime` will also be updated simultaneously.
**ctime** - Changing the owner, group, permissions, file size, and links (soft and hard links) of the file will update ctime.

For directories:

**atime** - After using the `cd` command to enter a new directory that has never been accessed before, you can update and fix the `atime` of that directory.
**mtime** - Performing operations such as creating, deleting, and renaming files in this directory will update the `mtime` and `ctime` of the directory.
**ctime** - When the permissions, owner, group, etc. of a directory change, the `ctime` of the directory will be updated.

!!! tip

    * If you create a new file or directory, its `atime`, `mtime`, and `ctime` are exactly the same
    * If the file content is modified, the `mtime` and `ctime` of the file will inevitably be updated.
    * If a brand new file is created in the directory, the `atime`, `ctime`, and `mtime` of that directory will be updated simultaneously.
    * If the `mtime` of a directory is updated, then the `ctime` of that directory must be updated.
