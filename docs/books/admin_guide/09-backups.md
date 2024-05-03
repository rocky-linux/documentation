---
title: Backup and Restore
---

# Backup and Restore

In this chapter you will learn how to back up and restore your data with Linux.

****

**Objectives**: In this chapter, future Linux administrators will learn how to:

:heavy_check_mark: use the `tar` and `cpio` command to make a backup;  
:heavy_check_mark: check their backups and restore data;  
:heavy_check_mark: compress or decompress their backups.  

:checkered_flag: **backup**, **restore**, **compression**  

**Knowledge**: :star: :star: :star:  
**Complexity**: :star: :star:  

**Reading time**: 40 minutes

****

!!! Note

    Throughout this chapter the command structures use "device" to specify both a target location for backup, and the source location when restoring. The device can be either external media or a local file. You should get a feel for this as the chapter unfolds, but you can always refer back to this note for clarification if you need to.

The backup will answer a need to conserve and restore data in a sure and effective way.

The backup allows you to protect yourself from the following:

* **Destruction**: voluntary or involuntary. Human or technical. Virus, ...
* **Deletion**: voluntary or involuntary. Human or technical. Virus, ...
* **Integrity**: data becomes unusable.

No system is infallible, no human is infallible, so to avoid losing data, it must be backed up to be able to restore after a problem.

The backup media should be kept in another room (or building) than the server so that a disaster does not destroy the server and the backups.

In addition, the administrator must regularly check that the media are still readable.

## Generalities

There are two principles, the **backup** and the **archive**.

* The archive destroys the information source after the operation.
* The backup preserves the source of information after the operation.

These operations consist of saving information in a file, on a peripheral or a supported media (tapes, disks, ...).

### The process

Backups require a lot of discipline and rigor from the system administrator. It is necessary to ask the following questions:

* What is the appropriate medium?
* What should be backed up?
* How many copies?
* How long will the backup take?
* Method?
* How often?
* Automatic or manual?
* Where to store it?
* How long will it be kept?

### Backup methods

* **Complete**: one or more **filesystems** are backed up (kernel, data, utilities, ...).
* **Partial**: one or more **files** are backed up (configurations, directories, ...).
* **Differential**: only files modified since the last **complete** backup are backed up.
* **Incremental**: only files modified since the last backup are backed up.

### Periodicity

* **Pre-current**: at a given time (before a system update, ...).
* **Periodic**: Daily, weekly, monthly, ...

!!! Tip

    Before a system change, it can be useful to make a backup. However, there is no point in backing up data every day that is only changed every month.

### Restoration methods

Depending on the utilities available, it will be possible to perform several types of restorations.

* **Complete restoration**: trees, ...
* **Selective restoration**: part of tree, files, ...

It is possible to restore a whole backup, but it is also possible to restore only a part of it. However, when restoring a directory, the files created after the backup are not deleted.

!!! Tip

    To recover a directory as it was at the time of the backup, it is necessary to completely delete its contents before launching the restoration.

### The tools

There are many utilities to make backups.

* **editor tools**;
* **graphical tools**;
* **command line tools**: `tar`, `cpio`, `pax`, `dd`, `dump`, ...

The commands we will use here are `tar` and `cpio`.

* `tar`:
  
  1. easy to use;
  2. allows adding files to an existing backup.
  
* `cpio`:

  1. retains owners;
  2. retains groups, dates and rights;
  3. skips damaged files;
  4. entire file system.

!!! Note

    These commands save in a proprietary and standardized format.

### Naming convention

The use of a naming convention makes it possible to quickly target the contents of a backup file and thus avoid hazardous restorations.

* name of the directory;
* utility used;
* options used;
* date.

!!! Tip

    The name of the backup must be an explicit name.

!!! Note

    The notion of extension under Linux does not exist. In other words, our use of extensions here is for the human operator. If the systems administrator sees a `.tar.gz` or `.tgz` file extension, for instance, then he knows how to deal with the file.

### Contents of a backup

A backup generally contains the following elements:

* the file;
* the name;
* the owner;
* the size;
* the permissions;
* access date.

!!! Note

    The `inode` number is missing.

### Storage modes

There are two different storage modes:

* file on disk;
* device.

## Tape ArchiveR - `tar`

The `tar` command allows saving on several successive media (multi-volume options).

It is possible to extract all or part of a backup.

`tar` implicitly backs up in relative mode even if the path of the information to be backed up is mentioned in absolute mode. However, backups and restores in absolute mode are possible.

### Restoration guidelines

The right questions to ask are:

* what: partial or complete;
* where: the place where the data will be restored;
* how: absolute or relative.

!!! Warning

    Before a restoration, it is important to take time to think about and determine the most appropriate method to avoid mistakes.

Restorations are usually performed after a problem has occurred that needs to be resolved quickly. A poor restoration can, in some cases, make the situation worse.

### Backing up with `tar`

The default utility for creating backups on UNIX systems is the `tar` command. These backups can be compressed by `bzip2`, `xz`, `lzip`, `lzma`, `lzop`, `gzip`, `compress` or `zstd`.

`tar` allows you to extract a single file or a directory from a backup, view its contents or validate its integrity.

#### Estimate the size of a backup

The following command estimates the size in kilobytes of a possible *tar* file:

```bash
$ tar cf - /directory/to/backup/ | wc -c
20480
$ tar czf - /directory/to/backup/ | wc -c
508
$ tar cjf - /directory/to/backup/ | wc -c
428
```

!!! Warning

    Beware, the presence of "-" in the command line disturbs `zsh`. Switch to `bash`!

#### Naming convention for a `tar` backup

Here is an example of a naming convention for a `tar` backup, knowing that the date is to be added to the name.

| keys    | Files   | Suffix           | Functionality                                |
|---------|---------|------------------|----------------------------------------------|
| `cvf`   | `home`  | `home.tar`       | `/home` in relative mode, uncompressed form  |
| `cvfP`  | `/etc`  | `etc.A.tar`      | `/etc` in absolute mode, no compression      |
| `cvfz`  | `usr`   | `usr.tar.gz`     | `/usr` in relative mode, *gzip* compression  |
| `cvfj`  | `usr`   | `usr.tar.bz2`    | `/usr` in relative mode, *bzip2* compression |
| `cvfPz` | `/home` | `home.A.tar.gz`  | `home` in absolute mode, *gzip* compression  |
| `cvfPj` | `/home` | `home.A.tar.bz2` | `home` in absolute mode, *bzip2* compression |
| …       |         |                  |                                        |

#### Create a backup

##### Create a backup in relative mode

Creating a non-compressed backup in relative mode is done with the `cvf` keys:

```bash
tar c[vf] [device] [file(s)]
```

Example:

```bash
[root]# tar cvf /backups/home.133.tar /home/
```

| Key | Description                                            |
|-----|--------------------------------------------------------|
| `c` | Creates a backup.                                      |
| `v` | Displays the name of the processed files.              |
| `f` | Allows you to specify the name of the backup (medium). |

!!! Tip

    The hyphen (`-`) in front of the `tar` keys is not necessary!

##### Create a backup in absolute mode

Creating a non-compressed backup explicitly in absolute mode is done with the `cvfP` keys:

```bash
tar c[vf]P [device] [file(s)]
```

Example:

```bash
[root]# tar cvfP /backups/home.133.P.tar /home/
```

| Key | Description                       |
|-----|-----------------------------------|
| `P` |Creates a backup in absolute mode. |

!!! Warning

    With the `P` key, the path of the files to be backed up must be entered as **absolute**. If the two conditions (key `P` and path **absolute**) are not indicated, the backup is in relative mode.

##### Creating a compressed backup with `gzip`

Creating a compressed backup with `gzip` is done with the `cvfz` keys:

```bash
tar cvzf backup.tar.gz dirname/
```

| Key | Description                      |
|-----|----------------------------------|
| `z` |Compresses the backup in *gzip*. |

!!! Note

    The `.tgz` extension is an equivalent extension to `.tar.gz`.

!!! Note

    Keeping the `cvf` (`tvf` or `xvf`) keys unchanged for all backup operations and simply adding the compression key to the end of the keys makes the command easier to understand (e.g., `cvfz` or `cvfj`, etc.).

##### Creating a compressed backup with `bzip`

Creating a compressed backup with `bzip` is done with the keys `cvfj`:

```bash
tar cvfj backup.tar.bz2 dirname/
```

| Key | Description                       |
|-----|-----------------------------------|
| `j` |Compresses the backup in *bzip2*. |

!!! Note

    The `.tbz` and `.tb2` extensions are equivalent to `.tar.bz2` extensions.

##### Compression `compress`, `gzip`, `bzip2`, `lzip` and `xz`

Compression, and consequently decompression, will have an impact on resource consumption (time and CPU usage).

Here is a ranking of the compression of a set of text files, from least to most efficient:

* compress (`.tar.Z`)
* gzip (`.tar.gz`)
* bzip2 (`.tar.bz2`)
* lzip (`.tar.lz`)
* xz (`.tar.xz`)

#### Add a file or directory to an existing backup

It is possible to add one or more items to an existing backup.

```bash
tar {r|A}[key(s)] [device] [file(s)]
```

To add `/etc/passwd` to the backup `/backups/home.133.tar`:

```bash
[root]# tar rvf /backups/home.133.tar /etc/passwd
```

Adding a directory is similar. Here add `dirtoadd` to `backup_name.tar`:

```bash
tar rvf backup_name.tar dirtoadd
```

| Key | Description                                                                      |
|-----|----------------------------------------------------------------------------------|
| `r` |Adds one or more files at the end of a direct access media backup (hard disk).   |
| `A` |Adds one or more files at the end of a backup on sequential access media (tape). |

!!! Note

    It is not possible to add files or folders to a compressed backup.

    ```
    $ tar rvfz backup.tgz filetoadd
    tar: Cannot update compressed archives
    Try `tar --help' or `tar --usage' for more information.
    ```

!!! Note

    If the backup was performed in relative mode, add files in relative mode. If the backup was done in absolute mode, add files in absolute mode.

    Mixing modes can cause problems when restoring.

#### List the contents of a backup

Viewing the contents of a backup without extracting it is possible.

```bash
tar t[key(s)] [device]
```

| Key |Description                                           |
|-----|-------------------------------------------------------|
| `t` |Displays the content of a backup (compressed or not). |

Examples:

```bash
tar tvf backup.tar
tar tvfz backup.tar.gz
tar tvfj backup.tar.bz2
```

When the number of files in a backup becomes large, it is possible to *pipe* the result of the `tar` command to a *pager* (`more`, `less`, `most`, etc.):

```bash
tar tvf backup.tar | less
```

!!! Tip

    To list or retrieve the contents of a backup, it is not necessary to mention the compression algorithm used when the backup was created. That is, a `tar tvf` is equivalent to `tar tvfj`, to read the contents, and a `tar xvf` is equivalent to `tar xvfj`, to extract.

!!! Tip

    Always check the contents of a backup.

#### Check the integrity of a backup

The integrity of a backup can be tested with the `W` key at the time of its creation:

```bash
tar cvfW file_name.tar dir/
```

The integrity of a backup can be tested with the key `d` after its creation:

```bash
tar vfd file_name.tar dir/
```

!!! Tip

    By adding a second `v` to the previous key, you will get the list of archived files as well as the differences between the archived files and those present in the file system.

    ```
    $ tar vvfd  /tmp/quodlibet.tar .quodlibet/
    drwxr-x--- rockstar/rockstar     0 2021-05-21 00:11 .quodlibet/
    -rw-r--r-- rockstar/rockstar     0 2021-05-19 00:59 .quodlibet/queue
    […]
    -rw------- rockstar/rockstar  3323 2021-05-21 00:11 .quodlibet/config
    .quodlibet/config: Mod time differs
    .quodlibet/config: Size differs
    […]
    ```

The `W` key is also used to compare the content of an archive against the filesystem:

```bash
$ tar tvfW file_name.tar
Verify 1/file1
1/file1: Mod time differs
1/file1: Size differs
Verify 1/file2
Verify 1/file3
```

The verification with the `W` key cannot be done with a compressed archive. The key ++d++ must be used:

```bash
tar dfz file_name.tgz
tar dfj file_name.tar.bz2
```

#### Extract (*untar*) a backup

Extract (*untar*) a ``*.tar`` backup is done with the `xvf` keys:

Extract the `etc/exports` file from the `/savings/etc.133.tar` backup into the `etc` directory of the active directory:

```bash
tar xvf /backups/etc.133.tar etc/exports
```

Extract all files from the compressed backup `/backups/home.133.tar.bz2` into the active directory:

```bash
[root]# tar xvfj /backups/home.133.tar.bz2
```

Extract all files from the backup `/backups/etc.133.P.tar` to their original directory:

```bash
tar xvfP /backups/etc.133.P.tar
```

!!! Warning

    Go to the right place.

    Check the contents of the backup.

| Key |Description                                       |
|------|----------------------------------------------------|
| `x`  |Extracts files from the backup, compressed or not. |

Extracting a *tar-gzipped* (`*.tar.gz`) backup is done with the `xvfz` keys:

```bash
tar xvfz backup.tar.gz
```

Extracting a *tar-bzipped* (`*.tar.bz2`) backup is done with the `xvfj` keys:

```bash
tar xvfj backup.tar.bz2
```

!!! Tip

    To extract or list the contents of a backup, it is not necessary to mention the compression algorithm used to create the backup. That is, a `tar xvf` is equivalent to `tar xvfj`, to extract the contents, and a `tar tvf` is equivalent to `tar tvfj`, to list.

!!! Warning

    To restore the files in their original directory (key `P` of a `tar xvf`), you must have generated the backup with the absolute path. That is, with the `P` key of a `tar cvf`.

##### Extract only a file from a *tar* backup

To extract a specific file from a *tar* backup, specify the name of that file at the end of the `tar xvf` command.

```bash
tar xvf backup.tar /path/to/file
```

The previous command extracts only the `/path/to/file` file from the `backup.tar` backup. This file will be restored to the `/path/to/` directory created, or already present, in the active directory.

```bash
tar xvfz backup.tar.gz /path/to/file
tar xvfj backup.tar.bz2 /path/to/file
```

##### Extract a folder from a backup *tar*

To extract only one directory (including its subdirectories and files) from a backup, specify the directory name at the end of the `tar xvf` command.

```bash
tar xvf backup.tar /path/to/dir/
```

To extract multiple directories, specify each of the names one after the other:

```bash
tar xvf backup.tar /path/to/dir1/ /path/to/dir2/
tar xvfz backup.tar.gz /path/to/dir1/ /path/to/dir2/
tar xvfj backup.tar.bz2 /path/to/dir1/ /path/to/dir2/
```

##### Extract a group of files from a *tar* backup using regular expressions (*regex*)

Specify a regular expression (*regex*) to extract the files matching the specified selection pattern.

For example, to extract all files with the extension `.conf`:

```bash
tar xvf backup.tar --wildcards '*.conf'
```

keys:

* **--wildcards *.conf** corresponds to files with the extension `.conf`.

## *CoPy Input Output* - `cpio`

The `cpio` command allows saving on several successive media without specifying any options.

It is possible to extract all or part of a backup.

There is no option, unlike the `tar` command, to backup and compress at the same time.
So, it is done in two steps: backup and compression.

To perform a backup with `cpio`, you have to specify a list of files to backup.

This list is provided with the commands `find`, `ls` or `cat`.

* `find` : browses a tree, recursive or not;
* `ls` : lists a directory, recursive or not;
* `cat` : reads a file containing the trees or files to be saved.

!!! Note

    `ls` cannot be used with `-l` (details) or `-R` (recursive).

    It requires a simple list of names.

### Create a backup with `cpio` command

Syntax of the `cpio` command:

```bash
[files command |] cpio {-o| --create} [-options] [<file-list] [>device]
```

Example:

With a redirection of the output of `cpio`:

```bash
find /etc | cpio -ov > /backups/etc.cpio
```

Using the name of a backup media:

```bash
find /etc | cpio -ovF /backups/etc.cpio
```

The result of the `find` command is sent as input to the `cpio` command via a *pipe* (character `|`, ++alt-graph+6++).

Here, the `find /etc` command returns a list of files corresponding to the contents of the `/etc` directory (recursively) to the `cpio` command, which performs the backup.

Do not forget the `>` sign when saving or the `F save_name_cpio`.

| Options |Description                                    |
|---------|------------------------------------------------|
| `-o`    |Creates a backup (*output*).                   |
| `-v`    |Displays the name of the processed files.      |
| `-F`    |Designates the backup to be modified (medium). |

Backup to a media:

```bash
find /etc | cpio -ov > /dev/rmt0
```

The media can be of several types:

* tape drive: `/dev/rmt0`;
* a partition: `/dev/sda5`, `/dev/hda5`, etc.

### Type of backup

#### Backup with relative path

```bash
cd /
find etc | cpio -o > /backups/etc.cpio
```

#### Backup with absolute path

```bash
find /etc | cpio -o > /backups/etc.A.cpio
```

!!! Warning

    If the path specified in the `find` command is **absolute**, then the backup will be performed in **absolute**.

    If the path indicated in the `find` command is **relative**, then the backup will be done in **relative**.

### Add to a backup

```bash
[files command |] cpio {-o| --create} -A [-options] [<fic-list] {F|>device}
```

Example:

```bash
find /etc/shadow | cpio -o -AF SystemFiles.A.cpio
```

Adding files is only possible on direct access media.

| Option | Description                                 |
|--------|---------------------------------------------|
| `-A`   | Adds one or more files to a backup on disk. |
| `-F`   | Designates the backup to be modified.       |

### Compressing a backup

* Save **then** compress

```bash
$ find /etc | cpio  –o > etc.A.cpio
$ gzip /backups/etc.A.cpio
$ ls /backups/etc.A.cpio*
/backups/etc.A.cpio.gz
```

* Save **and** compress

```bash
find /etc | cpio –o | gzip > /backups/etc.A.cpio.gz
```

There is no option, unlike the `tar` command, to save and compress at the same time.
So it is done in two steps: saving and compressing.

The syntax of the first method is easier to understand and remember, because it is done in two steps.

For the first method, the backup file is automatically renamed by the `gzip` utility which adds `.gz` to the end of the file name. Similarly, the `bzip2` utility automatically adds `.bz2`.

### Read the contents of a backup

Syntax of the `cpio` command to read the contents of a *cpio* backup:

```bash
cpio -t [-options] [<fic-list]
```

Example:

```bash
cpio -tv </backups/etc.152.cpio | less
```

| Options |Description               |
|---------|---------------------------|
| `-t`    | Reads a backup.           |
| `-v`    | Displays file attributes. |

After making a backup, you need to read its contents to be sure that there were no errors.

In the same way, before performing a restore, you must read the contents of the backup that will be used.

### Restore a backup

Syntax of the `cpio` command to restore a backup:

```bash
cpio {-i| --extract} [-E file] [-options] [<device]
```

Example:

```bash
cpio -iv </backups/etc.152.cpio | less
```

| Options                      | Description                                                         |
|------------------------------|---------------------------------------------------------------------|
| `-i`                         | Restores a complete backup.                                          |
| `-E file`                    | Restores only the files whose name is contained in file.            |
| `--make-directories` or `-d` | Rebuilds the missing tree structure.                                |
| `-u`                         | Replaces all files even if they exist.                              |
| `--no-absolute-filenames`    | Allows to restore a backup made in absolute mode in a relative way. |

!!! Warning

    By default, at the time of restoration, files on the disk whose last modification date is more recent or equal to the date of the backup are not restored (in order to avoid overwriting recent information with older information).

    The `u` option, on the other hand, allows you to restore older versions of the files.

Examples:

* Absolute restoration of an absolute backup

```bash
cpio –ivF home.A.cpio
```

* Absolute restoration on an existing tree structure

The `u` option allows you to overwrite existing files at the location where the restore takes place.

```bash
cpio –iuvF home.A.cpio
```

* Restore an absolute backup in relative mode

The long option `no-absolute-filenames` allows a restoration in relative mode. Indeed the `/` at the beginning of the path will be removed.

```bash
cpio --no-absolute-filenames -divuF home.A.cpio
```

!!! Tip

    The creation of directories is perhaps necessary, hence the use of the `d` option

* Restore a relative backup

```bash
cpio –iv <etc.cpio
```

* Absolute restoration of a file or directory

The restoration of a particular file or directory requires the creation of a list file that must then be deleted.

```bash
echo "/etc/passwd" > tmp
cpio –iuE tmp -F etc.A.cpio
rm -f tmp
```

## Compression - decompression utilities

Using compression at the time of a backup can have a number of drawbacks:

* Lengthens the backup time as well as the restore time.
* It makes it impossible to add files to the backup.

!!! Note

    It is therefore better to make a backup and compress it than to compress it during the backup.

### Compressing with `gzip`

The `gzip` command compresses data.

Syntax of the `gzip` command:

```bash
gzip [options] [file ...]
```

Example:

```bash
$ gzip usr.tar
$ ls
usr.tar.gz
```

The file receives the extension `.gz`.

It keeps the same rights and the same last access and modification dates.

### Compressing with `bunzip2`

The `bunzip2` command also compresses data.

Syntax of the `bzip2` command:

```bash
bzip2 [options] [file ...]
```

Example:

```bash
$ bzip2 usr.cpio
$ ls
usr.cpio.bz2
```

The file name is given the extension `.bz2`.

Compression by `bzip2` is better than compression by `gzip` but it takes longer to execute.

### Decompressing with `gunzip`

The `gunzip` command decompresses compressed data.

Syntax of the `gunzip` command:

```bash
gunzip [options] [file ...]
```

Example:

```bash
$ gunzip usr.tar.gz
$ ls
usr.tar
```

The file name is truncated by `gunzip` and the extension `.gz` is removed.

`gunzip` also decompresses files with the following extensions:

* `.z` ;
* `-z` ;
* `_z` .

### Decompressing with `bunzip2`

The `bunzip2` command decompresses compressed data.

Syntax of the `bzip2` command:

```bash
bzip2 [options] [file ...]
```

Example:

```bash
$ bunzip2 usr.cpio.bz2
$ ls
usr.cpio
```

The file name is truncated by `bunzip2` and the extension `.bz2` is removed.

`bunzip2` also decompresses the file with the following extensions:

* `-bz` ;
* `.tbz2` ;
* `tbz` .
