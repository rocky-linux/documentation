---
title: "`dump`- und `restore`-Kommandos"
author: tianci li
contributors: Steven Spencer
tested_with: 8.10
tags:
  - dump
  - restore
  - backup
---

## Übersicht

`dump` examines files in a filesystem, determines which to back up, and copies those files to a specified disk, tape, or other storage medium. The `restore` command performs the inverse function of `dump`.

This utility applies to the following file systems:

- ext2
- ext3
- ext4

!!! tip

    For the xfs file system, use `xfsdump`.

[This](https://dump.sourceforge.io/) is the project's homepage.

Before using this utility, run the following command to install it:

```bash
Shell > dnf -y install dump
```

After installation, two commonly used command tools are available:

- `dump`
- `restore`

### Das Kommando `dump`

There are two main uses for this command:

- Perform backup (dump) operations - `dump [option(s)] -f <File-Name> <File1> ...`
- Review backup (dump) information - `dump [-W | -w]`

Gängige Optionen sind Folgende:

- `-<level>` - Backup level. Please replace "level" with any number from 0-9 when used. The number 0 represents full backup, while other numbers represent incremental backup.
- `-f <File-Name>` - Specify the file name and path after backup.
- `-u` - After a successful backup, record the backup time in the **/etc/dumpdates** file. You can use the `-u` option when the backed-up object is an independent partition. However, you cannot use the `-u` option when the backup object is a non-partitioned directory.
- `-v` - Display the processing details during the backup process.
- `-W` - An option for viewing dump information.
- `-z[LEVEL]` - Adjust the compression level using the zlib library, with a default compression level of 2. For example, you can compress the backup file to `.gz` format. The adjustable range of compression level is 1-9.
- `-j[LEVEL]` - Adjust the compression level using the bzlib library, with a default compression level of 2. For example, you can compress the backup file to `.bz2` format. The adjustable range of compression level is 1-9.

#### `dump`-Beispiel

1. Perform a Full Backup of the root partition:

    ```bash
    Shell > dump -0u -j3 -f /tmp/root-20241208.bak.bz2 /
    DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 3 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 14693111 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:04:41 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: 20.69% done at 10133 kB/s, finished in 0:19
    DUMP: 43.74% done at 10712 kB/s, finished in 0:12
    DUMP: 70.91% done at 11575 kB/s, finished in 0:06
    DUMP: 93.23% done at 11415 kB/s, finished in 0:01
    DUMP: Closing /tmp/root-20241208.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 19:26:08 2024
    DUMP: Volume 1 took 0:21:27
    DUMP: Volume 1 transfer rate: 5133 kB/s
    DUMP: Volume 1 14722930kB uncompressed, 6607183kB compressed, 2.229:1
    DUMP: 14722930 blocks (14377.86MB) on 1 volume(s)
    DUMP: finished in 1287 seconds, throughput 11439 kBytes/sec
    DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Date this dump completed:  Sun Dec  8 19:26:08 2024
    DUMP: Average transfer rate: 5133 kB/s
    DUMP: Wrote 14722930kB uncompressed, 6607183kB compressed, 2.229:1
    DUMP: DUMP IS DONE
    
    Shell > ls -lh /tmp/root-20241208.bak.bz2
    -rw-r--r-- 1 root root 6.4G Dec  8 19:26 /tmp/root-20241208.bak.bz2
    ```

2. After successful dumping, check the relevant information:

    ```bash
    Shell > cat /etc/dumpdates
    /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800
    
    Shell > dump -W
    Last dump(s) done (Dump '>' file systems):
    /dev/nvme0n1p2        (     /) Last dump: Level 0, Date Sun Dec  8 19:04:39 2024
    ```

3. Implement Incremental Backup on the basis of Full Backup:

    ```bash
    Shell > echo "jack" >> /tmp/tmpfile.txt
    
    Shell > dump -1u -j4 -f /tmp/root-20241208-LV1.bak.bz2 /
    DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
    DUMP: Date of last level 0 dump: Sun Dec  8 19:04:39 2024
    DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208-LV1.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 4 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 6620898 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:38:58 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: 38.13% done at 8415 kB/s, finished in 0:08
    DUMP: 75.30% done at 8309 kB/s, finished in 0:03
    DUMP: Closing /tmp/root-20241208-LV1.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 19:52:03 2024
    DUMP: Volume 1 took 0:13:05
    DUMP: Volume 1 transfer rate: 8408 kB/s
    DUMP: Volume 1 6620910kB uncompressed, 6600592kB compressed, 1.004:1
    DUMP: 6620910 blocks (6465.73MB) on 1 volume(s)
    DUMP: finished in 785 seconds, throughput 8434 kBytes/sec
    DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
    DUMP: Date this dump completed:  Sun Dec  8 19:52:03 2024
    DUMP: Average transfer rate: 8408 kB/s
    DUMP: Wrote 6620910kB uncompressed, 6600592kB compressed, 1.004:1
    DUMP: DUMP IS DONE
    
    Shell > cat /etc/dumpdates
    /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800
    /dev/nvme0n1p2 1 Sun Dec  8 19:38:51 2024 +0800
    
    Shell > dump -W
    Last dump(s) done (Dump '>' file systems):
    /dev/nvme0n1p2        (     /) Last dump: Level 1, Date Sun Dec  8 19:38:51 2024
    ```

4. For non-partitioned directory, you can only use the Full Backup (`-0`) option, not the `-u` option:

    ```bash
    Shell > dump -0uj -f /tmp/etc-full-20241208.bak.bz2 /etc/
    DUMP: You can't update the dumpdates file when dumping a subdirectory
    DUMP: The ENTIRE dump is aborted.
    
    Shell > dump -0j -f /tmp/etc-full-20241208.bak.bz2 /etc/
    DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
    DUMP: Dumping /dev/nvme0n1p2 (/ (dir etc)) to /tmp/etc-full-20241208.bak.bz2
    DUMP: Label: none
    DUMP: Writing 10 Kilobyte records
    DUMP: Compressing output at transformation level 2 (bzlib)
    DUMP: mapping (Pass I) [regular files]
    DUMP: mapping (Pass II) [directories]
    DUMP: estimated 28204 blocks.
    DUMP: Volume 1 started with block 1 at: Sun Dec  8 20:00:38 2024
    DUMP: dumping (Pass III) [directories]
    DUMP: dumping (Pass IV) [regular files]
    DUMP: Closing /tmp/etc-full-20241208.bak.bz2
    DUMP: Volume 1 completed at: Sun Dec  8 20:00:40 2024
    DUMP: Volume 1 took 0:00:02
    DUMP: Volume 1 transfer rate: 3751 kB/s
    DUMP: Volume 1 29090kB uncompressed, 7503kB compressed, 3.878:1
    DUMP: 29090 blocks (28.41MB) on 1 volume(s)
    DUMP: finished in 2 seconds, throughput 14545 kBytes/sec
    DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
    DUMP: Date this dump completed:  Sun Dec  8 20:00:40 2024
    DUMP: Average transfer rate: 3751 kB/s
    DUMP: Wrote 29090kB uncompressed, 7503kB compressed, 3.878:1
    DUMP: DUMP IS DONE
    ```

   Performing an incremental backup of the /etc/ directory will result in an error:

    ```bash
    Shell > dump -1j -f /tmp/etc-incr-20241208.bak.bz2 /etc/
    DUMP: Only level 0 dumps are allowed on a subdirectory
    DUMP: The ENTIRE dump is aborted.
    ```

### `restore`-Kommando

The usage of this command is - `restore <mode(flag)> [option(s)] -f <Dump-File>`

The mode (flag) can be one of the following:

- `-C` - Compare-Modus. Restore reads the backup and compares its contents with files on the disk. Es wird hauptsächlich zum Vergleichen nach der Durchführung einer Sicherung auf einer Partition verwendet. In diesem Modus vergleicht `restore` nur Änderungen basierend auf den Originaldaten. If there is new data on the disk, you cannot compare or detect it.
- `-i` - Interactive Mode. This mode allows interactive restoration of files from a dump.
- `-t` - List-Mode. List what data is in the backup file.
- `-r` - Restore (rebuild) mode. If it is a "Full Backup + Incremental Backup" method, restoring data will occur chronologically.
- `-x` - Extraktion-Modus. Extract some or all files from the backup file.

#### Example of using `restore`

1. Restore data from /tmp/etc-full-20241208.bak.bz2 :

    ```bash
    Shell > mkdir /tmp/data/
    
    Shell > restore -t -f /tmp/etc-full-20241208.bak.bz2
    
    Shell > cd /tmp/data/ ; restore -r -f /tmp/etc-full-20241208.bak.bz2
    
    Shell > ls -l /tmp/data/
    total 4992
    drwxr-xr-x. 90 root root    4096 Dec  8 17:13 etc
    -rw-------   1 root root 5107632 Dec  8 20:39 restoresymtable
    ```

   As you can see, a file named `restoresymtable` shows up after a successful restore. Diese Datei ist wichtig. It is for incremental backup system restore operations.

2. Process backup files in Interactive mode:

    ```bash
    Shell > restore -i -f /tmp/etc-full-20241208.bak.bz2
    Dump tape is compressed.
    
    restore > ?
    ```

   You can type ++question++ to view the available interactive commands in this mode.
