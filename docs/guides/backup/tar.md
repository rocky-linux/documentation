---
title: tar command
author: tianci li
contributors: Ganna Zhyrnova, Steven Spencer
tested_with: 8.10
tags:
  - tar
  - backup
  - archive
---

## Overview

`tar` is a tool for processing archive files on GNU/Linux and other UNIX operating systems. It stands for "tape archive."

Storing files conveniently on magnetic tape was the initial use of tar archives. The name "tar" comes from this use. Despite the utility's name, `tar` can direct its output to available devices, files, or other programs (using pipes) and access remote devices or files (as archives).

The `tar` currently used on modern GNU/Linux initially came from the [GNU Project](https://www.gnu.org/). You can browse and download all versions of `tar` on [GNU's website](https://ftp.gnu.org/gnu/tar/).

!!! note

    The `tar` in different distributions may have different default options. Please be careful when you use them.

    ```bash
    # RockyLinux 8 and Fedora 41
    tar --show-defaults
    --format=gnu -f- -b20 --quoting-style=escape --rmt-command=/etc/rmt --rsh-command=/usr/bin/ssh
    ```

## Use `tar`

When using `tar`, note that it has two saving modes:

* **Relative mode** (default): Remove the leading character '/' from the file. Even if you have added the file with an absolute path, `tar` will remove the leading character "/" in this mode.
* **Absolute mode**: Keep the leading character '/' and include it in the filename. You need to use the `-P` option to enable this save mode. In this mode, you must represent all files as absolute paths. For security reasons, you should not use this save mode in most cases unless there are special scenario requirements.

When you use `tar,` you will encounter suffixes such as `.tar.gz`, `.tar.xz`, and `.tar.bz2`, which indicate that you create an archive first (categorizing related files as a single file) and then compress the file with the relevant compression type or algorithm.

The compression type or algorithm can be gzip, bzip2, xz, zstd, or another.

`tar` allows the extraction of a single file or a directory from a backup, viewing its contents, or validating its integrity.

The usage of creating an archive and using compression is:

* `tar [option] [PATH] [DIR1] ... [FILE1] ...`. For example, `tar -czvf /tmp/Fullbackup-20241201.tar.gz /etc/ /var/log/`

The usage to extract a file from an archive is:

* `tar [option] [PATH] -C [dir]`. For example `tar -xzvf /tmp/Fullbackup-20241201.tar.gz -C /tmp/D1`

!!! tip

     When you extract files from archived files, `tar` automatically selects the compression type based on the manually added suffix. For example, for `.tar.gz` files, you can directly use `tar -vxf` without using `tar -zvxf`. You **must** select the compression type for creating archive compressed files.

!!! Note

    In GNU/Linux, most files do not require an extension except for the desktop environment (GUI). The reason for artificially adding suffixes is to facilitate human users' recognition. If the systems administrator sees a `.tar.gz` or `.tgz` file extension, for instance, then he knows how to deal with the file.

### Operating parameters or types

| types | description |
| :---: | :--- |
| `-A`  | Appends all files in one archive to the end of another archive. Only applicable to archive non-compressed files of the `.tar` type |
| `-c`  | Creates archive. Very commonly used  |
| `-d`  | Compares the differences between archived and corresponding unarchived files |
| `-r`  | Appends the files or directories to the end of the archive. Only applicable to archive non-compressed files of the `.tar` type  |
| `-t`  | Lists the contents of the archive |
| `-u`  | Only appends newer files to the archive. Only applicable to archive non-compressed files of the `.tar` type |
| `-x`  | Extract from archive. Very commonly used |
| `--delete` | Deletes files or directories from the ".tar" archive. Only applicable to archive non-compressed files of the `.tar` type |

!!! Tip

    The author recommends keeping the prefix "-" to preserve user habits regarding operation types. It is not required. The operational parameters here indicate your primary function with `tar`. In other words, you need to choose one of the above types.

### Common auxiliary options

| option | description                                                                                             |
|--------|---------------------------------------------------------------------------------------------------------|
| `-z`   | Use `gzip` as its compression type. Both creating archives and extracting from archives are applicable  |
| `-v`   | Displays detailed processing details                                                                    |
| `-f`   | Specifies the filename for archiving (including file suffix)                                            |
| `-j`   | Use `bzip2` as its compression type. Both creating archives and extracting from archives are applicable |
| `-J`   | Use `xz` as its compression type. Both creating archives and extracting from archives are applicable    |
| `-C`   | Saves location after extracting files from the archive                                                  |
| `-P`   | Saves using the absolute mode                                                                           |

For other auxiliary options not mentioned, see `man 1 tar`

!!! warning "Version differences"

    In some older versions of tar, option(s) are referred to as "key(s)", which means that using options with a "-" prefix may cause the `tar` not to work as expected. At this point, you need to remove the "-" prefix to make it work properly.

### About styles of options

`tar` provides three styles of options:

1. Traditional style:

    * `tar {A|c|d|r|t|u|x}[GnSkUWOmpsMBiajJzZhPlRvwo] [ARG...]`.

2. The usage of the short-option style is:

    * `tar -A [OPTIONS] ARCHIVE ARCHIVE`
    * `tar -c [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar -d [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar -t [-f ARCHIVE] [OPTIONS] [MEMBER...]`
    * `tar -r [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar -u [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar -x [-f ARCHIVE] [OPTIONS] [MEMBER...]`

3. The usage of the long-option style is:

    * `tar {--catenate|--concatenate} [OPTIONS] ARCHIVE ARCHIVE`
    * `tar --create [--file ARCHIVE] [OPTIONS] [FILE...]`
    * `tar {--diff|--compare} [--file ARCHIVE] [OPTIONS] [FILE...]`
    * `tar --delete [--file ARCHIVE] [OPTIONS] [MEMBER...]`
    * `tar --append [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar --list [-f ARCHIVE] [OPTIONS] [MEMBER...]`
    * `tar --test-label [--file ARCHIVE] [OPTIONS] [LABEL...]`
    * `tar --update [--file ARCHIVE] [OPTIONS] [FILE...]`
    * `tar --update [-f ARCHIVE] [OPTIONS] [FILE...]`
    * `tar {--extract|--get} [-f ARCHIVE] [OPTIONS] [MEMBER...]`

The second method is more commonly used by most GNU/Linux users.

### Compression efficiency and frequency of use

`tar` does not have compression capabilities, so you must use it with other compression tools. Compression and decompression will impact resource consumption.

Here is a ranking of the compression of a set of text files from least to most efficient:

* compress (`.tar.Z`) - Less popular
* gzip (`.tar.gz` or `.tgz`) - Popular
* bzip2 (`.tar.bz2` or `.tb2` or `.tbz`) - Popular
* lzip (`.tar.lz`) - Less popular
* xz (`.tar.xz`) - Popular

### Naming convention for a `tar`

Here are examples of naming conventions for `tar` archives:

| Main function and auxiliary options   | Files   | Suffix | Functionality   |
|--------  |---------|------------------|----------------------------------------------|
| `-cvf`   | `home`  | `home.tar`       | `/home` in relative mode, uncompressed form  |
| `-cvfP`  | `/etc`  | `etc.A.tar`      | `/etc` in absolute mode, no compression      |
| `-cvfz`  | `usr`   | `usr.tar.gz`     | `/usr` in relative mode, *gzip* compression  |
| `-cvfj`  | `usr`   | `usr.tar.bz2`    | `/usr` in relative mode, *bzip2* compression |
| `-cvfPz` | `/home` | `home.A.tar.gz`  | `/home` in absolute mode, *gzip* compression  |
| `-cvfPj` | `/home` | `home.A.tar.bz2` | `/home` in absolute mode, *bzip2* compression |

You might also add the date to the filename.

### Example of use

#### `-c` type

1. Archive and compress **/etc/** in relative mode, with a suffix of `.tar.gz`:

    ```bash
    tar -czvf /tmp/etc-20241207.tar.gz /etc/
    ```

    Due to `tar` working in relative mode by default, the first line of the command output will display the following:

    ```bash
    tar: Removing leading '/' from member names
    ```

2. Archive **/var/log/** and select xz type for compression:

    ```bash
    tar -cJvf /tmp/log-20241207.tar.xz /var/log/

    du -sh /var/log/ ; ls -lh /tmp/log-20241207.tar.xz
    18M     /var/log/
    -rw-r--r-- 1 root root 744K Dec  7 14:40 /tmp/log-20241207.tar.xz
    ```

3. Estimate file size without generating an archive:

    ```bash
    tar -cJf - /etc | wc -c
    tar: Removing leading `/' from member names
    3721884
    ```

    The output unit of the `wc -c` command is bytes.

4. Cut large `.tar.gz` files:

    ```bash
    cd /tmp/ ; tar -czf - /etc/  | split -d -b 2M - etc-backup20241207.tar.gz.

    ls -lh /tmp/
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.00
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.01
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.02
    -rw-r--r-- 1 root root  70K Dec  7 20:46 etc-backup20241207.tar.gz.03
    ```

    The first "-" represents the input parameters of `tar` while the second "-" tells `tar` to redirect the output to `stdout`.

    To extract these cut small files, you can point to the following operation:

    ```bash
    cd /tmp/ ; cat etc-backup20241207.tar.gz.* >> /tmp/etc-backup-20241207.tar.gz

    cd /tmp/ ; tar -xvf etc-backup-20241207.tar.gz -C /tmp/dir1/
    ```

#### `-x` type

1. Download the Redis source code and extract it to the `/usr/local/src/` directory：

    ```bash
    wget -c https://github.com/redis/redis/archive/refs/tags/7.4.1.tar.gz

    tar -xvf 7.4.1.tar.gz -C /usr/local/src/
    ```

2. Extract only one file from the archive zip file

    ```bash
    tar -xvf /tmp/etc-20241207.tar.gz etc/chrony.conf
    ```

#### `-A` or `-r` type

1. Append one `.tar` file to another `.tar` file:

    ```bash
    tar -cvf /tmp/etc.tar /etc/

    tar -cvf /tmp/log.tar /var/log/

    tar -Avf /tmp/etc.tar /tmp/log.tar
    ```

    This means that all files in "log.tar" will append to the end of "etc.tar".

2. Append files or directories to a `.tar` file:

    ```bash
    tar -rvf /tmp/log.tar /etc/chrony.conf
    tar: Removing leading `/' from member names
    /etc/chrony.conf
    tar: Removing leading `/' from hard link targets
    
    tar -rvf /tmp/log.tar /tmp/dir1
    ```

!!! warning

    Whether you use the `-A` or `-r` option, consider the saving mode of the relevant archive files.

!!! warning

    `-A` and `-r` are not applicable for archived compressed files.

#### `-t` type

1. Review the contents of the archive:

    ```bash
    tar -tvf /tmp/log.tar

    tar -tvf /tmp/etc-20241207.tar.gz | less
    ```

#### `-d` type

1. Compare file differences:

    ```bash
    cd / ; tar -dvf /tmp/etc.tar etc/chrony.conf
    etc/chrony.conf

    cd / ; tar -dvf /tmp/etc-20241207.tar.gz etc/
    ```

    For storage methods that use relative mode, when using the `-d` type, switch the file path to '/'.

#### `-u` type

1. If there are multiple versions of the same file, you can use the `-u` type:

    ```bash
    touch /tmp/tmpfile1

    tar -rvf /tmp/log.tar /tmp/tmpfile1

    echo "File Name" >> /tmp/tmpfile1

    tar -uvf /tmp/log.tar /tmp/tmpfile1

    tar -tvf /tmp/log.tar
    ...
    -rw-r--r-- root/root         0 2024-12-07 18:53 tmp/tmpfile1
    -rw-r--r-- root/root        10 2024-12-07 18:54 tmp/tmpfile1
    ```

#### `--delete` type

1. You can also use `--delete` to delete files inside a `.tar` file.

    ```bash
    tar --delete -vf /tmp/log.tar tmp/tmpfile1

    tar --delete -vf /tmp/etc.tar etc/motd.d/
    ```

    When deleting, you will delete all files with the same name from the archive.

## Common terminology

Some websites mention two terms:

* **tarfile** - Refers to uncompressed archive files, such as `.tar` files
* **tarball** - Refers to compressed archive files, such as `.tar.gz` and `.tar.xz`
