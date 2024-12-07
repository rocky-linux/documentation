---
title: tar command
author: tianci li
contributors: 
tested_with: 8.10
tags:
  - tar
  - backup
  - archive
---

# Overview

`tar` is a powerful tool for archiving files in GNU/Linux and UNIX operating systems, and it stands for "tape archive".

Initially, tar archives were used to store files conveniently on magnetic tape. The name "Tar" comes from this use; it stands for tape archiver. Despite the utility's name, Tar can direct its output to available devices, files, or other programs (using pipes), it can even access remote devices or files (as archives).

The `tar` currently used on GNU/Linux operating systems is derived from "GNU Tar". You can browse and download all versions of `tar` on [this ftp server](https://ftp.gnu.org/gnu/tar/).

The `tar` in different distributions may have different default options, so be careful when using them!

```bash
# RockyLinux 8 and Fedora 41
Shell > tar --show-defaults
--format=gnu -f- -b20 --quoting-style=escape --rmt-command=/etc/rmt --rsh-command=/usr/bin/ssh
```

## Use `tar`

When using `tar`, please note that it has two saving modes:

* **Relative mode** (default): Remove the leading character '/' from the file to be archived. Even if you have added the file to be archived with an absolute path, the leading character "/" will still be removed in this mode.
* **Absolute mode**: Keep the leading character '/' and include it as part of the file name. To enable this save mode, you need to use the `-P` option. In this mode, all files you add must be represented as absolute paths. For security reasons, you should not use this save mode in most cases unless there are special scenario requirements.

When you use `tar`, you will encounter suffixes such as `.tar.gz`, `.tar.xz`, `.tar.bz2`, which indicate creating an archive first (categorizing related files as a single file), and then compressing the file using the relevant compression type or compression algorithm.

The compression type or compression algorithm can be `gzip`, `bzip2`, `xz`, `zstd` etc.

`tar` allows you to extract a single file or a directory from a backup, view its contents, or validate its integrity.

The usage of creating an archive and using compression is:

* `tar [option] [PATH] [DIR1] ... [FILE1] ...`. For example `tar -czvf /tmp/Fullbackup-20241201.tar.gz /etc/ /var/log/`

The usage to extract a file from an archive is:

* `tar [option] [PATH] -C [dir]`. For example `tar -xzvf /tmp/Fullbackup-20241201.tar.gz -C /tmp/D1`

!!! tip "antic"

    When you extract files from archived files `tar` will automatically select the compression type based on the manually added suffix. For example, for `.tar.gz` files, you can directly use `tar -vxf` without using the `tar -zvxf`. 
    For creating archive compressed files, the compression type **must be** selected.

!!! Note

    In the GNU/Linux world, except for a few exceptions in GUI environments (such as .jpg, .mp4, .gif), most files do not have the concept of extension. In other words, most files do not require an extension. The reason for artificially adding suffixes is to facilitate recognition by human users. If the systems administrator sees a `.tar.gz` or `.tgz` file extension, for instance, then he knows how to deal with the file.

Operating parameters or types:

| types | describe |
| :---: | :--- |
| `-A`  | Merge the current archive with an existing archive. Only applicable to archive non-compressed files of the `.tar` type |
| `-c`  | Create archive. Very commonly used  |
| `-d`  | Compare the differences between archived and corresponding unarchived files |
| `-r`  | Append the files or directories to the end of the archive. Only applicable to archive non-compressed files of the `.tar` type  |
| `-t`  | Lists the contents of the archive |
| `-u`  | Only newer files are appended to the archive. Only applicable to archive non-compressed files of the `.tar` type |
| `-x`  | Extract from archive. Very commonly used |
| `--delete` | Delete files or directories from the ".tar" archive. Only applicable to archive non-compressed files of the `.tar` type |

!!! Tip

    In terms of operation types, in order to preserve user habits, we recommend that you keep the prefix "-". Of course, it's not required. The operational parameters here indicate what your primary function is with `tar`. In other words, you need to choose one of the above types.

Common auxiliary options:

| option | describe |
| :---: | :--- |
| `-z`  | Use `gzip` as its compression type. Both creating archives and extracting from archives are applicable |
| `-v`  | Display detailed processing details |
| `-f`  | Specify the file name for archiving (including file suffix) |
| `-j`  | Use `bzip2` as its compression type. Both creating archives and extracting from archives are applicable |
| `-J`  | Use `xz` as its compression type. Both creating archives and extracting from archives are applicable |
| `-C`  | Save location after extracting files from the archive |
| `-P`  | Save using absolute mode |

Other auxiliary options are explained in the following examples.

!!! warning "Version difference"

    In some older versions of tar, option(s) are referred to as "key(s)", which means that using options with a "-" prefix may cause the `tar` to not work as expected. At this point, you need to remove the "-" prefix to make it work properly.

### About styles of options

`tar` provides three styles of options:

1. Traditional style. Its usage is: 

   * `tar {A|c|d|r|t|u|x}[GnSkUWOmpsMBiajJzZhPlRvwo] [ARG...]`.

2. UNIX-style (The short-option style of GNU/Linux). Its usage is:

   * `tar -A [OPTIONS] ARCHIVE ARCHIVE`
   * `tar -c [-f ARCHIVE] [OPTIONS] [FILE...]`
   * `tar -d [-f ARCHIVE] [OPTIONS] [FILE...]`
   * `tar -t [-f ARCHIVE] [OPTIONS] [MEMBER...]`
   * `tar -r [-f ARCHIVE] [OPTIONS] [FILE...]`
   * `tar -u [-f ARCHIVE] [OPTIONS] [FILE...]`
   * `tar -x [-f ARCHIVE] [OPTIONS] [MEMBER...]`

3. GNU-style (The long-option style of GNU/Linux). Its usage is:

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

Generally speaking, the second method is more commonly used and in line with the user's habits on GNU/Linux.

### Compression efficiency and frequency of use

`tar` itself does not have compression capabilities, so it needs to be used in conjunction with other compression tools. Please note that! Compression, and consequently decompression, will impact resource consumption (time and CPU usage).

Here is a ranking of the compression of a set of text files from least to most efficient:

* compress (`.tar.Z`) - Less usage
* gzip (`.tar.gz` or `.tgz`) - Frequent use
* bzip2 (`.tar.bz2` or `.tb2` or `.tbz`) - Frequent use
* lzip (`.tar.lz`) - Less usage
* xz (`.tar.xz`) - Frequent use

### Naming convention for a `tar`

Here is an example of a naming convention for a `tar` backup, knowing that the date will be added to the name.

| Main function and auxiliary options   | Files   | Suffix | Functionality   |
|--------  |---------|------------------|----------------------------------------------|
| `-cvf`   | `home`  | `home.tar`       | `/home` in relative mode, uncompressed form  |
| `-cvfP`  | `/etc`  | `etc.A.tar`      | `/etc` in absolute mode, no compression      |
| `-cvfz`  | `usr`   | `usr.tar.gz`     | `/usr` in relative mode, *gzip* compression  |
| `-cvfj`  | `usr`   | `usr.tar.bz2`    | `/usr` in relative mode, *bzip2* compression |
| `-cvfPz` | `/home` | `home.A.tar.gz`  | `home` in absolute mode, *gzip* compression  |
| `-cvfPj` | `/home` | `home.A.tar.bz2` | `home` in absolute mode, *bzip2* compression |
| …        |         |                  |                                              |

### Example of use

#### `-c` type

1. Archive and compress **/etc/** in relative mode, with a suffix of ".tar.gz":

    ```bash
    Shell > tar -czvf /tmp/etc-20241207.tar.gz /etc/
    ```

    Due to `tar` working in relative mode by default, the first line of the command output will display the following text:

    ```
    tar: Removing leading '/' from member names
    ```

2. Archive **/var/log/** and select xz type for compression:

    ```bash
    Shell > tar -cJvf /tmp/log-20241207.tar.xz /var/log/

    Shell > du -sh /var/log/ ; ls -lh /tmp/log-20241207.tar.xz
    18M     /var/log/
    -rw-r--r-- 1 root root 744K Dec  7 14:40 /tmp/log-20241207.tar.xz
    ```

3. Estimate file size without generating files:

    ```bash
    Shell > tar -cJf - /etc | wc -c
    tar: Removing leading `/' from member names
    3721884
    ```

    The output unit of the `wc -c` command is "bytes".

4. Cut large ".tar.gz" files:

    ```bash
    Shell > cd /tmp/ ; tar -czf - /etc/  | split -d -b 2M - etc-backup20241207.tar.gz.

    Shell > ls -lh /tmp/
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.00
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.01
    -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.02
    -rw-r--r-- 1 root root  70K Dec  7 20:46 etc-backup20241207.tar.gz.03
    ```

    The first "-" represents the output parameter of `tar`; the second "-" represents the input parameter of `split`.

    To extract these cut small files, you can point to the following operation:

    ```bash
    Shell > cd /tmp/ ; cat etc-backup20241207.tar.gz.* >> /tmp/etc-backup-20241207.tar.gz

    Shell > cd /tmp/ ; tar -xvf etc-backup-20241207.tar.gz -C /tmp/dir1/
    ```

#### `-x` type

1. Download the Redis source code and extract it to the **/etc/local/src/** directory：

    ```bash
    Shell > wget -c https://github.com/redis/redis/archive/refs/tags/7.4.1.tar.gz

    Shell > tar -xvf 7.4.1.tar.gz -C /usr/local/src/
    ```

2. Extract only one file from the archive zip file

    ```bash
    Shell > tar -xvf /tmp/etc-20241207.tar.gz etc/chrony.conf
    ```

#### `-A` or `-r` type

1. Append one ".tar" file to another ".tar" file:

    ```bash
    Shell > tar -cvf /tmp/etc.tar /etc/

    Shell > tar -cvf /tmp/log.tar /var/log/

    Shell > tar -Avf /tmp/etc.tar /tmp/log.tar
    ```

    This means appending "log.tar" to "etc.tar".

2. Append files or directories to a ".tar" file:

    ```bash
    Shell > tar -rvf /tmp/log.tar /etc/chrony.conf
    tar: Removing leading `/' from member names
    /etc/chrony.conf
    tar: Removing leading `/' from hard link targets
    
    Shell > tar -rvf /tmp/log.tar /tmp/dir1
    ```

!!! warning

    Whether you use the `-A` or `-r` option, please pay attention to the saving mode of the relevant archive files.

!!! warning

    `-A` and `-r` are not applicable for archived compress files.

#### `-t` type

1. Review the contents of the archive:

    ```bash
    Shell > tar -tvf /tmp/log.tar

    Shell > tar -tvf /tmp/etc-20241207.tar.gz | less
    ```

#### `-d` type

1. Compare file differences:

    ```bash
    Shell > cd / ; tar -dvf /tmp/etc.tar etc/chrony.conf
    etc/chrony.conf

    Shell > cd / ; tar -dvf /tmp/etc-20241207.tar.gz etc/
    ```

    For storage methods that use relative mode, when using the `-d` type, please switch the file path to '/'.

### `-u` type

1. If there are multiple versions of the same file, the `-u` type can be used:

    ```bash
    Shell > touch /tmp/tmpfile1

    Shell > tar -rvf /tmp/log.tar /tmp/tmpfile1

    Shell > echo "File Name" >> /tmp/tmpfile1

    Shell > tar -uvf /tmp/log.tar /tmp/tmpfile1

    Shell > tar -tvf /tmp/log.tar
    ...
    -rw-r--r-- root/root         0 2024-12-07 18:53 tmp/tmpfile1
    -rw-r--r-- root/root        10 2024-12-07 18:54 tmp/tmpfile1
    ```

### `--delete` type

1. You can also use `--delete` to delete files from the ".tar" file.

    ```bash
    Shell > tar --delete -vf /tmp/log.tar tmp/tmpfile1

    Shell > tar --delete -vf /tmp/etc.tar etc/motd.d/
    ```

    When deleting, all files with the same name are deleted from the archive.


## Terminology Explanation

In some website documents, two terms are mentioned:

* **tarfile** - Refers to uncompressed archive files, such as ".tar" files
* **tarball** - Refers to compressed archive files, such as ".tar.gz" and ".tar.xz"
