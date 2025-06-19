---
title: Backup and Restore
---

# Backup and Restore

In this chapter, you will learn how to back up and restore your data using Linux.

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

    Throughout this chapter, the command structures use "device" to specify both a target location for backup and the source location when restoring. The device can be either external media or a local file. You should get a feel for this as the chapter unfolds, but you can always refer back to this note for clarification if you need to.

The backup will answer the need to conserve and restore data effectively.

The backup allows you to protect yourself from the following:

* **Destruction**: voluntary or involuntary. Human or technical. Virus, ...
* **Deletion**: voluntary or involuntary. Human or technical. Virus, ...
* **Integrity**: data becomes unusable.

No system is infallible, and no human is infallible, so to avoid losing data, it must be backed up to restore it after a problem.

The backup media should be kept in another room (or building) than the server so that a disaster does not destroy the server and the backups.

In addition, the administrator must regularly check that the media are still readable.

## Generalities

There are two principles: the **backup** and the **archive**.

* The archive destroys the information source after the operation.
* The backup preserves the source of information after the operation.

These operations consist of saving information in a file, on a peripheral, or a supported media (tapes, disks, and so on).

### The process

Backups require a lot of discipline and rigor from the system administrator. System administrators need to consider the following issues before performing backup operations:

* What is the appropriate medium?
* What should be backed up?
* How many copies?
* How long will the backup take?
* Method?
* How often?
* Automatic or manual?
* Where to store it?
* How long will it be kept?
* Is there a cost issue to consider?

In addition to these issues, system administrators should also consider factors such as performance, data importance, bandwidth consumption, and maintenance complexity based on actual situations.

### Backup methods

* **Full backup**: Refers to a one-time copy of all files, folders, or data in the hard disk or database.
* **Incremental backup**: Refers to the backup of the data updated after the last Full backup or Incremental backup.
* **Differential backup**: Refers to the backup of the changed files after the Full backup.
* **Selective backup (Partial backup)**: Refers to backing up a part of the system.
* **Cold backup**: Refers to the backup when the system is in a shutdown or maintenance state.  The backed-up data is precisely the same as the data in the system during this period.
* **Hot backup**: Refers to the backup when the system is operating normally.  As the data in the system is updated at any time, the backed-up data has a certain lag relative to the system's real data.
* **Remote backup**: Refers to backing up data in another geographic location to avoid data loss and service interruption caused by fire, natural disasters, theft, and more.

### Frequency of backups

* **Periodic**: Backup within a specific period before a major system update (usually during off-peak hours)
* **cycle**: Backup in units of days, weeks, months, etc

!!! Tip

    Before a system change, it can be useful to make a backup. However, there is no point in backing up data every day that only changes every month.

### Recover methods

Depending on the utilities available, performing several types of recovery will be possible.

In some relational database management systems, the corresponding operations of "recover" (sometimes "recovery" is used in the documentation) and "restore" are different. For further information, consult the official documentation. This basic document will not go into too much detail regarding this part of RDBMS.

* **Full recover**: Data recovery based on Full backup or "Full backup + Incremental backup" or "Full backup + Differential backup".
* **Selective recover**: Data recovery based on Selective backup (Partial backup).

We do not recommend directly deleting directories or files in the currently active operating system before performing a recovery operation (unless you know what will happen after deletion). If you don't know what will happen, you can perform a 'snapshot' operation on the current operating system.

!!! Tip

    For security reasons, storing the restored directory or file in the /tmp directory before performing the recovery operation is recommended to avoid situations where old files (old directory) overwrite new files (new directory).

### The tools and related technologies

There are many utilities to make backups.

* **editor tools**;
* **graphical tools**;
* **command line tools**: `tar`, `cpio`, `pax`, `dd`, `dump`, ...

The commands we will use here are `tar` and `cpio`. If you want to learn about the `dump` tool, please refer to [this document](../../guides/backup/dump_restore.md).

* `tar`:
  
  1. easy to use;
  2. allows adding files to an existing backup.
  
* `cpio`:

  1. retains owners;
  2. retains groups, dates and rights;
  3. skips damaged files;
  4. can be used for the entire file system.

!!! Note

    These commands save in a proprietary and standardized format.

**Replication**: A backup technology that copies a set of data from one data source to another or multiple data sources, mainly divided into **Synchronous Replication** and **Asynchronous Replication**. This is an advanced backup part for novice system administrators, so this basic document will not elaborate on these contents.

### Naming convention

Using a naming convention allows one to quickly target a backup file's contents and thus avoid hazardous restorations.

* name of the directory;
* utility used;
* options used;
* date.

!!! Tip

    The name of the backup must be explicit.

!!! Note

    In the Linux world, most files do not have the extension concept except for a few exceptions in GUI environments (such as .jpg, .mp4, .gif). In other words, most file extensions are not required. The reason for artificially adding suffixes is to facilitate recognition by human users. If the systems administrator sees a `.tar.gz` or `.tgz` file extension, for instance, then he knows how to deal with the file.

### Properties of the backup file

A single backup file can include the following properties:

* file name (including manually added suffixes);
* backup the atime, ctime, mtime, btime (crtime) of the file itself;
* file size of the backup file itself;
* the properties or characteristics of files or directories in the backup file will be partially preserved. For example, mtime for files or directories will be retained, but `inode` number will not be retained.

### Storage methods

There are two different storage methods:

* Internal: Store backup files on the current working disk.
* External: Store backup files on external devices. External devices can be USB drives, CDs, disks, servers, or NAS, and more.

## Tape ArchiveR - `tar`

The `tar` command allows saving on several successive media (multi-volume options).

It is possible to extract all or part of a backup.

`tar` implicitly backs up in relative mode even if the path of the information to be backed up is mentioned in absolute mode. However, backups and restores in absolute mode are possible. If you want to see a separate example of the usage of `tar`, please refer to [this document](../../guides/backup/tar.md).

### Restoration guidelines

The right questions to ask are:

* what: partial or complete;
* where: the place where the data will be restored;
* how: absolute or relative.

!!! Warning

    Before a restoration, it is important to consider and determine the most appropriate method to avoid mistakes.

Restorations are usually performed after a problem has occurred that needs to be resolved quickly. A poor restoration can, in some cases, make the situation worse.

### Backing up with `tar`

The default utility for creating backups on UNIX systems is the `tar` command. These backups can be compressed by `bzip2`, `xz`, `lzip`, `lzma`, `lzop`, `gzip`, `compress` or `zstd`.

`tar` allows you to extract a single file or a directory from a backup, view its contents, or validate its integrity.

#### Estimate the size of a backup

The following command estimates the size in bytes of a possible *tar* file:

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

Here is an example of a naming convention for a `tar` backup, knowing that the date will be added to the name.

| keys    | Files   | Suffix           | Functionality                                |
|---------|---------|------------------|----------------------------------------------|
| `cvf`   | `home`  | `home.tar`       | `/home` in relative mode, uncompressed form  |
| `cvfP`  | `/etc`  | `etc.A.tar`      | `/etc` in absolute mode, no compression      |
| `cvfz`  | `usr`   | `usr.tar.gz`     | `/usr` in relative mode, *gzip* compression  |
| `cvfj`  | `usr`   | `usr.tar.bz2`    | `/usr` in relative mode, *bzip2* compression |
| `cvfPz` | `/home` | `home.A.tar.gz`  | `/home` in absolute mode, *gzip* compression  |
| `cvfPj` | `/home` | `home.A.tar.bz2` | `/home` in absolute mode, *bzip2* compression |
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

    The hyphen (`-`) in front of the `tar` keys is optional!

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

    With the `P` key, the path of the files to be backed up must be entered as **absolute**. If the two conditions (`P` key and **absolute** path) are not indicated, the backup is in relative mode.

##### Creating a compressed backup with `gzip`

Creating a compressed backup with `gzip` is done with the `cvfz` keys:

```bash
tar cvzf backup.tar.gz dirname/
```

| Key | Description                      |
|-----|----------------------------------|
| `z` |Compresses the backup in *gzip*. |

!!! Note

    The `.tgz` extension is equivalent to `.tar.gz`.

!!! Note

    Keeping the `cvf` (`tvf` or `xvf`) keys unchanged for all backup operations and simply adding the compression key to the end of the keys makes the command easier to understand (such as: `cvfz` or `cvfj`, and others).

##### Creating a compressed backup with `bzip2`

Creating a compressed backup with `bzip2` is done with the keys `cvfj`:

```bash
tar cvfj backup.tar.bz2 dirname/
```

| Key | Description                       |
|-----|-----------------------------------|
| `j` |Compresses the backup in *bzip2*. |

!!! Note

    The `.tbz` and `.tb2` extensions are equivalent to `.tar.bz2` extensions.

##### Comparison of compression efficiency

Compression, and consequently decompression, will impact resource consumption (time and CPU usage).

Here is a ranking of the compression of a set of text files from least to most efficient:

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
| `r` | Appends the files or directories to the end of the archive.                       |
| `A` | Appends all files in one archive to the end of another archive.         |

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

When the number of files in the backup increases, you can use pipe characters (`|`) and some commands (`less`, `more`, `most`, and others) to achieve the effect of paging viewing:

```bash
tar tvf backup.tar | less
```

!!! Tip

    To list or retrieve the contents of a backup, it is not necessary to mention the compression algorithm used when the backup was created. That is, a `tar tvf` is equivalent to `tar tvfj`, to read the contents. The compression type or algorithm **must** only be selected when creating a compressed backup.

!!! Tip

    You should always check and view the backup file's contents before performing a restore operation.

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

You cannot verify the compressed archive with the `W` key. Instead, you must use the `d` key.

```bash
tar dfz file_name.tgz
tar dfj file_name.tar.bz2
```

#### Extract (*untar*) a backup

Extract (*untar*) a ``*.tar`` backup is done with the `xvf` keys:

Extract the `etc/exports` file from the `/savings/etc.133.tar` backup into the `etc` directory of the current directory:

```bash
tar xvf /backups/etc.133.tar etc/exports
```

Extract all files from the compressed backup `/backups/home.133.tar.bz2` into the current directory:

```bash
[root]# tar xvfj /backups/home.133.tar.bz2
```

Extract all files from the backup `/backups/etc.133.P.tar` to their original directory:

```bash
tar xvfP /backups/etc.133.P.tar
```

!!! Warning

    For security reasons, you should use caution when extracting backup files saved in absolute mode.

    Once again, before performing extraction operations, you should always check the contents of the backup files (particularly those saved in absolute mode).

| Key |Description                                       |
|------|----------------------------------------------------|
| `x`  | Extracts files from backups (whether compressed or not) |

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

##### Extract a group of files from a *tar* backup using wildcard

Specify a wildcard to extract the files matching the specified selection pattern.

For example, to extract all files with the extension `.conf`:

```bash
tar xvf backup.tar --wildcards '*.conf'
```

keys:

* __--wildcards *.conf__ corresponds to files with the extension `.conf`.

!!! tip "Expanded Knowledge"

    Although wildcard characters and regular expressions usually have the same symbol or style, the objects they match are completely different, so people often confuse them.

    **wildcard (wildcard character)**: used to match file or directory names. 
    **regular expression**: used to match the content of a file.

    You can see an introduction with extra detail in [this document](../sed_awk_grep/1_regular_expressions_vs_wildcards.md). 

## *CoPy Input Output* - `cpio`

The `cpio` command allows saving on several successive media without specifying any options.

It is possible to extract all or part of a backup.

Unlike the `tar` command, there is no option to backup and compress simultaneously.
So, it is done in two steps: backup and compression.

`cpio` has three operating modes, each corresponding to a different function:

1. **copy-out mode** - Creates a backup (archive). Enable this mode through the `-o` or `--create` options. In this mode, you must generate a list of files with a specific command (`find`, `ls`, or `cat`) and pass it to cpio.

   * `find`: browses a tree, recursive or not;
   * `ls`: lists a directory, recursive or not;
   * `cat`: reads a file containing the trees or files to be saved.

    !!! Note

        `ls` cannot be used with `-l` (details) or `-R` (recursive).

        It requires a simple list of names.

2. **copy-in mode** – extracts files from an archive. You can enable this mode through the `-i` option.
3. **copy-pass mode** – copies files from one directory to another. You can enable this mode through the `-p` or `--pass-through` options.

Like the `tar` command, users must consider how the file list is saved (**absolute path** or **relative path**) when creating an archive.

Secondary function:

1. `-t` - Prints a table of input contents.
2. `-A` - Appends to an existing archive. It only works in copy-in mode.

!!! note

    Some options of `cpio` need to be combined with the correct operating mode to work correctly. See `man 1 cpio`

### copy-out mode

Syntax of the `cpio` command:

```bash
[files command |] cpio {-o| --create} [-options] [< file-list] [> device]
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

The result of the `find` command is sent as input to the `cpio` command via a *pipe* (character `|`, ++left-shift+backslash++).

Here, the `find /etc` command returns a list of files corresponding to the contents of the `/etc` directory (recursively) to the `cpio` command, which performs the backup.

Do not forget the `>` sign when saving or the `F save_name_cpio`.

| Options |Description                                    |
|---------|------------------------------------------------|
| `-o`    |Creates a backup through _cp-out_ mode.                   |
| `-v`    |Displays the name of the processed files.      |
| `-F`    |Backup to specific media, which can replace standard input ("<") and standard output (">") in the `cpio` command |

Backup to a media:

```bash
find /etc | cpio -ov > /dev/rmt0
```

The media can be of several types:

* tape drive: `/dev/rmt0`;
* a partition: `/dev/sda5`, `/dev/hda5`, etc.

#### Relative and absolute paths of the file list

```bash
cd /
find etc | cpio -o > /backups/etc.cpio
```

```bash
find /etc | cpio -o > /backups/etc.A.cpio
```

!!! Warning

    If the path specified in the `find` command is **absolute**, the backup will be performed in **absolute**.

    If the path indicated in the `find` command is **relative**, the backup will be done in **relative**.

#### Append files to existing backups

```bash
[files command |] cpio {-o| --create} -A [-options] [< fic-list] {F| > device}
```

Example:

```bash
find /etc/shadow | cpio -o -AF SystemFiles.A.cpio
```

Adding files is only possible on direct access media.

| Option | Description                                 |
|--------|---------------------------------------------|
| `-A`   | Appends one or more files to an existing backup. |
| `-F`   | Designates the backup to be modified.       |

#### Compressing a backup

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

Unlike the `tar` command, there is no option to save and compress simultaneously.
So, it is done in two steps: saving and compressing.

The syntax of the first method is easier to understand and remember because it is done in two steps.

For the first method, the backup file is automatically renamed by the `gzip` utility, which adds `.gz` to the end of the file name. Similarly, the `bzip2` utility automatically adds `.bz2`.

### Read the contents of a backup

Syntax of the `cpio` command to read the contents of a *cpio* backup:

```bash
cpio -t [-options] [< fic-list]
```

Example:

```bash
cpio -tv < /backups/etc.152.cpio | less
```

| Options |Description               |
|---------|---------------------------|
| `-t`    | Reads a backup.           |
| `-v`    | Displays file attributes. |

After making a backup, you need to read its contents to ensure there are no errors.

In the same way, before performing a restore, you must read the contents of the backup that will be used.

### copy-in mode

Syntax of the `cpio` command to restore a backup:

```bash
cpio {-i| --extract} [-E file] [-options] [< device]
```

Example:

```bash
cpio -iv < /backups/etc.152.cpio | less
```

| Options                      | Description                                                         |
|------------------------------|---------------------------------------------------------------------|
| `-i`                         | Restores a complete backup.                                          |
| `-E file`                    | Restores only the files whose name is contained in file.            |
| `--make-directories` or `-d` | Rebuilds the missing tree structure.                                |
| `-u`                         | Replaces all files even if they exist.                              |
| `--no-absolute-filenames`    | Allows to restore a backup made in absolute mode in a relative way. |

!!! Warning

    By default, at the time of restoration, files on the disk whose last modification date is more recent or equal to the date of the backup are not restored (to avoid overwriting recent information with older information).

    On the other hand, the `u` option allows you to restore older versions of the files.

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

The long option `no-absolute-filenames` allows a restoration in relative mode. Indeed, the `/` at the beginning of the path will be removed.

```bash
cpio --no-absolute-filenames -divuF home.A.cpio
```

!!! Tip

    The creation of directories is perhaps necessary, hence the use of the `d` option

* Restore a relative backup

```bash
cpio –iv < etc.cpio
```

* Absolute restoration of a file or directory

Restoring a particular file or directory requires the creation of a list file that must then be deleted.

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

    It is, therefore, better to make a backup and compress it than to compress it during the backup.

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

### Compressing with `bzip2`

The `bzip2` command also compresses data.

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

Compression by `bzip2` is better than compression by `gzip`, but executing it takes longer.

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

* `.z`;
* `-z`;
* `_z`;
* `-gz`;

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

The file name is truncated by `bunzip2`, and the extension `.bz2` is removed.

`bunzip2` also decompresses the file with the following extensions:

* `-bz`;
* `.tbz2`;
* `tbz`.
