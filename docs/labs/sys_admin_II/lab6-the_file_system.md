---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - lab exercise
  - file system
  - cli
  - Logical volume manager
  - lvm 
---


# Lab 6: The File system

## Objectives

After completing this lab, you will be able to 

- Partition a disk
- Use the Logical Volume Management (LVM) System
- Create new file systems
- Mount and make use of file systems 

Estimated time to complete this lab: 90 minutes 

## Overview of useful file system applications

Below is a summary of common applications used to manage file-systems. 

### `sfdisk`

Used for displaying or manipulating disk partition tables
  
Synopsis:

    ```
    Usage:
    sfdisk [options] <dev> [[-N] <part>]
    sfdisk [options] <command>

    Commands:
    -A, --activate <dev> [<part> ...] list or set bootable (P)MBR partitions
    -d, --dump <dev>                  dump partition table (usable for later input)
    -J, --json <dev>                  dump partition table in JSON format
    -g, --show-geometry [<dev> ...]   list geometry of all or specified devices
    -l, --list [<dev> ...]            list partitions of each device
    -F, --list-free [<dev> ...]       list unpartitioned free areas of each device
    -r, --reorder <dev>               fix partitions order (by start offset)
    -s, --show-size [<dev> ...]       list sizes of all or specified devices
    -T, --list-types                  print the recognized types (see -X)
    -V, --verify [<dev> ...]          test whether partitions seem correct
        --delete <dev> [<part> ...]   delete all or specified partitions

    --part-label <dev> <part> [<str>] print or change partition label
    --part-type <dev> <part> [<type>] print or change partition type
    --part-uuid <dev> <part> [<uuid>] print or change partition uuid
    --part-attrs <dev> <part> [<str>] print or change partition attributes

    --disk-id <dev> [<str>]           print or change disk label ID (UUID)
    --relocate <oper> <dev>           move partition header
    ```
    
### `debugfs`

ext2/ext3/ext4 file system debugger

Synopsis:

    ```
     debugfs [-b blocksize] [-s superblock] [-f cmd_file] [-R request] [-d data_source_device] [-i] [-n] [-D] [-V] [[-w] [-z undo_file] [-c]] [device]
    ```
    
### `badblocks`

Search for bad blocks on a device

Synopsis: 

    ```
     badblocks  [ -svwnfBX ] [ -b block_size ] [ -c blocks_at_once ] [ -d read_delay_factor ] [ -e max_bad_blocks ] [ -i input_file ] [ -o output_file ] [ -p num_passes ] [
       -t test_pattern ] device [ last_block ] [ first_block ]
    ```

### `dosfsck`

Check FAT filesystem on DEVICE for errors.
  
Synopsis:

    ```
    Usage: dosfsck [OPTIONS] DEVICE
    Options:
    -a              automatically repair the filesystem
    -A              toggle Atari variant of the FAT filesystem
    -b              make read-only boot sector check
    -c N            use DOS codepage N to decode short file names (default: 850)
    -d PATH         drop file with name PATH (can be given multiple times)
    -f              salvage unused chains to files
    -F NUM          specify FAT table NUM used for filesystem access
    -l              list path names
    -n              no-op, check non-interactively without changing
    -p              same as -a, for compat with other *fsck
    -r              interactively repair the filesystem (default)
    -S              disallow spaces in the middle of short file names
    -t              test for bad clusters
    -u PATH         try to undelete (non-directory) file that was named PATH (can be
                      given multiple times)
    -U              allow only uppercase characters in volume and boot label
    -v              verbose mode
    -V              perform a verification pass
    --variant=TYPE  handle variant TYPE of the filesystem
    -w              write changes to disk immediately
    -y              same as -a, for compat with other *fsck
    --help          print this message
    ```

### `mkdosfs` or `mkfs.fat`

Used for creating MS-DOS (FAT12, FAT16 and FAT32) file system in Linux

Synopsis: 

    ```
      Usage: mkdosfs [OPTIONS] TARGET [BLOCKS]

      Options:
        -a              Disable alignment of data structures
        -A              Toggle Atari variant of the filesystem
        -b SECTOR       Select SECTOR as location of the FAT32 backup boot sector
        -c              Check device for bad blocks before creating the filesystem
        -C              Create file TARGET then create filesystem in it
        -D NUMBER       Write BIOS drive number NUMBER to boot sector
        -f COUNT        Create COUNT file allocation tables
        -F SIZE         Select FAT size SIZE (12, 16 or 32)
        -g GEOM         Select disk geometry: heads/sectors_per_track
        -h NUMBER       Write hidden sectors NUMBER to boot sector
        -i VOLID        Set volume ID to VOLID (a 32 bit hexadecimal number)
        -I              Ignore and disable safety checks
        -l FILENAME     Read bad blocks list from FILENAME
        -m FILENAME     Replace default error message in boot block with contents of FILENAME
        -M TYPE         Set media type in boot sector to TYPE
        .........
    ```
    
### `dumpe2fs`

Lists the superblock and blocks group information on the device listed.

Synopsis: 

    ```
    Usage: dumpe2fs [-bfghimxV] [-o superblock=<num>] [-o blocksize=<num>] device
    ```

### `fdisk` 

View and manipulate (add, remove and modify) disk partition tables 

Synopsis:

    ```
    Usage:
    fdisk [options] <disk>         change partition table
    fdisk [options] -l [<disk>...] list partition table(s)
    Display or manipulate a disk partition table.

    Options:
    -b, --sector-size <size>      physical and logical sector size
    -B, --protect-boot            don't erase bootbits when creating a new label
    -c, --compatibility[=<mode>]  mode is 'dos' or 'nondos' (default)
    -L, --color[=<when>]          colorize output (auto, always or never) colors are enabled by default
    -l, --list                    display partitions and exit
    -x, --list-details            like --list but with more details
    -n, --noauto-pt               don't create default partition table on empty devices
    -o, --output <list>           output columns
    -t, --type <type>             recognize specified partition table type only
    -u, --units[=<unit>]          display units: 'cylinders' or 'sectors' (default)
    -s, --getsz                   display device size in 512-byte sectors [DEPRECATED]
     --bytes                   print SIZE in bytes rather than in human readable format
     --lock[=<mode>]           use exclusive device lock (yes, no or nonblock)
    -w, --wipe <mode>             wipe signatures (auto, always or never)
    -W, --wipe-partitions <mode>  wipe signatures from new partitions (auto, always or never)
    -C, --cylinders <number>      specify the number of cylinders
    -H, --heads <number>          specify the number of heads
    -S, --sectors <number>        specify the number of sectors per track
    ```

### `fsck`

Used for checking and repairing Linux file systems. Actually a wrapper to several other file system specific utilities (e.g. fsck.ext3, fsck.ext2 and so on).

Synopsis:

    ```
    Usage:
        fsck [options] -- [fs-options] [<filesystem> ...]

        Check and repair a Linux filesystem.

    Options:
        -A         check all filesystems
        -C [<fd>]  display progress bar; file descriptor is for GUIs
        -l         lock the device to guarantee exclusive access
        -M         do not check mounted filesystems
        -N         do not execute, just show what would be done
        -P         check filesystems in parallel, including root
        -R         skip root filesystem; useful only with '-A'
        -r [<fd>]  report statistics for each device checked;
                    file descriptor is for GUIs
        -s         serialize the checking operations
        -T         do not show the title on startup
        -t <type>  specify filesystem types to be checked;
                    <type> is allowed to be a comma-separated list
        -V         explain what is being done
    ```

### `hdparm`

Used to get or set the hard disk parameters

Synopsis: 

    ```
    hdparm [options] [device]
    ```

### `tune2fs`

Used for adjusting tunable file system parameters on ext2/ext3/ext4 file systems. The filesystem must not be mounted write when this operation is performed.
  
Synopsis: 

    ```
    Usage: tune2fs [-c max_mounts_count] [-e errors_behavior] [-f] [-g group]
        [-i interval[d|m|w]] [-j] [-J journal_options] [-l]
        [-m reserved_blocks_percent] [-o [^]mount_options[,...]]
        [-r reserved_blocks_count] [-u user] [-C mount_count]
        [-L volume_label] [-M last_mounted_dir]
        [-O [^]feature[,...]] [-Q quota_options]
        [-E extended-option[,...]] [-T last_check_time] [-U UUID]
        [-I new_inode_size] [-z undo_file] device
    ```

### `mkswap`

Creates a Linux swap area on a device

Synopsis: 

    ```
    mkswap [-c] [-vN] [-f] [-p PSZ] device [size]
    ```

### `mkfs`

Create Linux file systems

Synopsis: 

    ```
    mkfs [ -V ] [ -t fstype ] [ fs-options ] filesys [ blocks ]
    ```

### `parted`

A disk partitioning and partition resizing program.

Synopsis: 

    ```
    Parted [options] [device [command [options]]]
    ```

### `swapon` and `swapoff`

Enable/disable devices and files for paging and swapping

Synopsis:

    ```
    swapon [-v] [-p priority] specialfile
    ```

### `mount`

Used to mount a filesystem.

Synopsis: 

    ```
    Mount [-fnrsvw] [-o options [,...]] device | dir
    ```

## Exercise 1 

PERFORM THIS EXERCISE ON YOUR LOCAL-SYSTEM 

Creating partitions (`fdisk`, `mke2fs`, `fsck`, `tune2fs`) 

In this exercise you will create additional partitions on your hard disk. During the initial installation you left some free space. You will create partitions on this space. 

Partitioning a disk allows the disk to be regarded as a group of independent storage areas.  

Partitions also make backups easier and help to restrict and confine potential problem areas. 

Hard disk space is not infinite and one of your duties administrator is managing the available finite space. For instance, a simple way to restrict the total storage area on a disk where users can store their personal files is to create a separate partition for the users’ home directory (Of course quotas can also be used).

#### To explore block storage devices

You will be using the `fdisk` utility  

1. While logged on as root, display the current structure of your disk. Type: 

    ```bash
    [root@serverXY root]# fdisk -l
    
        Disk /dev/vda: 25 GiB, 26843545600 bytes, 52428800 sectors
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0xb3053db5

        Device     Boot Start      End  Sectors Size Id Type
        /dev/vda1  *     2048 52428766 52426719  25G 83 Linux
    ```
    
2. Display the current disk usage statistics. Type:  

    ```bash
      [root@serverXY root]#  df -h
      Filesystem      Size  Used Avail Use% Mounted on
      devtmpfs        4.0M     0  4.0M   0% /dev
      tmpfs           479M   84K  479M   1% /dev/shm
      /dev/vda1        24G  8.5G   14G  39% /
      ...<SNIPPED>...
    ```
    
    From the sample output above under the Used column, you can see that the primary partition ( /dev/vda1) on which our root (/) directory is mounted on is completely (100%) filled up.

    Of course your output might be different if you have a different sized disk or if you didn’t follow the partitioning scheme used during the OS install. 

#### To create a [fake] block device

We don't want you to accidentally alter the local hard disk on your system and make it inoperable,  so we'll complete the following exercises on a pseudo-device that behaves and mimics an actual block device. This will be done by creating a reasonably sized [sparse] file and associating it with a pseudo-device. On Linux systems, these pseudo-devices are referred to as loop devices. A loop device is a pseudo-device that makes it possible to treat [and access] a regular data file as if it were a block device. 

(This step is roughly equal to the same decisions you must make about purchasing actual disks/storage for a server. Decisions like - type, make, size, interface, form-factor and so on)

1. While still logged into the system as the root user, use the losetup utility to create a sparse 10GB file. Type:

    ```bash
    [root@serverPR root]# truncate --size 10GiB /tmp/10G-fake-disk.img
    ```
    
2. Run the `losetup` command without any options to show active loop devices. Type:

    ```bash
    [root@serverPR root]# losetup
    ```
    
3. Run the `losetup` command again to view/find the first unused loop device. Type:
    
    ```bash
    [root@serverPR root]# losetup -f --nooverlap
    /dev/loop0
    ```
    
    The first usable or unused loop device in the output of our sample system is `/dev/loop0`.
    
4. Using the 10G-fake-disk.img as a backing file, associate the file with an available loop device by running:

    ```bash
    losetup -f --nooverlap --partscan /tmp/10G-fake-disk.img
    ```
    
5. Run the `losetup` command again to show loop devices in use. Type:

    ```bash
    [root@serverPR root]# losetup
    NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE              DIO LOG-SEC
    /dev/loop0         0      0         0  0 /tmp/10G-fake-disk.img   0     512
    ```

6. Use the `sfdisk` utility to list any partitions on the new pseudo-block device. Type:
    
    ```bash
    [root@localhost ~]# sfdisk -l /dev/loop0
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```
    
7. Now use `fdisk` to list any partitions on the same device. Type:
    
    ```bash
    [root@localhost ~]# fdisk -l /dev/loop0
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```
    
#### To create partitions

1. You will create a new partition using the `fdisk` program. `fdisk` runs interactively, so you'll have many question-and-answer style prompts to complete specific tasks.
    
    Start by passing the name of the loop block device as an argument to the `fdisk`. Type:
    
    ```bash
    [root@localhost ~]# fdisk /dev/loop0
    
    Welcome to fdisk (util-linux 2.*).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.
    
    Device does not contain a recognized partition table.
    Created a new DOS disklabel with disk identifier 0xe3aa91a1.
    
    Command (m for help):
    ```
    
2. Display the built-in help system for `fdisk`, by typing `m` at the `fdisk` prompt.

    ```bash
    Command (m for help): m
    Help:
    
    DOS (MBR)
    a   toggle a bootable flag
    b   edit nested BSD disklabel
    c   toggle the dos compatibility flag
    
    Generic
    d   delete a partition
    F   list free unpartitioned space
    l   list known partition types
    n   add a new partition
    p   print the partition table
    t   change a partition type
    v   verify the partition table
    i   print information about a partition
    ...<SNIP>...
    ```
    
3. From the displayed help listing, we can see that the `n` is used for adding a new partition. Type `n` at the prompt:

    ```bash
    Command (m for help): n
    Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
    ```
    
4. Create a primary partition type by typing `p `:
    
    ```bash
    Command (m for help): n
    Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
    Select (default p): p
    ```
    
5. This is the first primary partition on the block device. Set the partition number to 1:
    
    ```bash
    Partition number (1-4, default 1): 1
    ```
    
6. Accept the default value for the first sector of the block device by pressing <kbd>ENTER</kbd>:
    
    ```bash
    First sector (2048-20971519, default 2048):
    ```
    
7. Accept the default value for the last sector of the block device by pressing <kbd>ENTER</kbd>:
    
    ```bash
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-20971519, default 20971519):
    ```
    
8. Back at the main `fdisk` prompt, type `p` to print the current partition table of the block device:
    
    ```bash
    Command (m for help): p
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe3aa91a1
    
    Device       Boot Start      End  Sectors Size Id Type
    /dev/loop0p1       2048 20971519 20969472  10G 83 Linux
    ```
    
    The new partition you created is the one on `/dev/loop0p1` above. You will notice that the partition type is “83”.
    
9. Everything looks good. Write all the changes to the partition table by typing the `w` sub command of `fdisk`:
    
    ```bash
    Command (m for help): w
    ```
    
    You'll likely see a warning about a failure to re-read the partition table. 
    
    The `w` `fdisk` command will also exit the `fdisk` program and return the shell prompt.
    
10. Per the warning message you may have gotten after writing the partition table to disk in the previous step, you may sometimes need to take extra steps to urge the kernel to acknowledge the new hard disk changes. Use the `partprobe` command to do this: 
    
    ```bash
    [root@localhost ~]# partprobe
    ```
    
    !!! tip
        
        When using `fdisk`, the default partition type for newly created partitions is Linux (0x83). You can use the `fdisk` `t` command to change the type. For example to change the partition type to the LVM (0x8e) type you would do the following:
        
        Type `t` to change the partition type: 
        
        ```bash
        Command (m for help): t
        ```
          
        Then input the hexcode (0x8e) for the LVM type partitions at the prompt:
        
        ```bash
        Hex code or alias (type L to list all): 8e
        ```
        
        Write all the changes to the partition table by typing the `w` `fdisk` command:

        ```bash
        Command (m for help): w
        ```

#### To create a physical volume 

To help demonstrate some of the subtle differences between the traditional method of managing block devices and the more modern approaches like the volume manager approach, we'll create a new pseudo-block device and attempt to prepare it (similar to partitioning) for use with a file system.

In the following steps we are going to create a new loop device backed by another regular file. And then we'll go on to setting up the device for the Logical Volume Manager (LVM) system. 

1. While logged in as a user with administrator privileges, create a sparse 10GB file called `10G-fake-lvm-disk.img`. Type:
    
    ```bash
    [root@server root]# truncate --size 10GiB /tmp/10G-fake-lvm-disk.img
    ```
    
2. Run the `losetup` command to view/find the first unused loop device. Type:
    
    ```bash
    [root@serverPR root]# losetup -f --nooverlap
    ```

    Our sample system's first usable or unused loop device has been incremented and is now /dev/loop1.
    
3. Using the 10G-fake-lvm-disk.img as a backing file, associate the file with an available loop device by running:
    
    ```bash
    [root@server root]# losetup -f --nooverlap --partscan /tmp/10G-fake-lvm-disk.img
    ```
    
4. Run the `losetup` command to show loop devices in use. Type:
    
    ```bash
    [root@localhost ~]# losetup
    NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE                  DIO LOG-SEC
    /dev/loop1         0      0         0  0 /tmp/10G-fake-lvm-disk.img   0     512
    /dev/loop0         0      0         0  0 /tmp/10G-fake-disk.img       0     512
    ```
    
    We see the mapping of /dev/loop1 to the /tmp/10G-fake-lvm-disk.img backing file in our output. Perfect.
    
5. Use the `pvdisplay` command to view the physical volumes currently defined on the system. Type: 
    
    ```bash
    [root@localhost ~]# pvdisplay
    --- Physical volume ---
    PV Name               /dev/vda3
    VG Name               rl
    PV Size               98.41 GiB / not usable 2.00 MiB
    ...<SNIP>...
    ```
    
2. Initialize the new /dev/loop1 block device (10G-fake-lvm-disk.img) as a physical volume. Use the `pvcreate` utility. Type: 
    
    ```bash
    [root@localhost ~]# pvcreate /dev/loop1
    Physical volume "/dev/loop1" successfully created.
    ```
    
3. Run the `pvdisplay` command to view any changes.

#### To assign a physical volume to a volume group 

In this section, you will learn how to assign a PV device to an existing volume group. This has the net effect of increasing the storage capacity of an existing volume group. 

You'll add the `/dev/loop1` physical volume (PV) that was prepped and created above to the existing `rl` Volume Group (VG).

1. Use the `vgdisplay` command to view the currently configured volume groups. Type: 
    
    ```bash
    [root@localhost ~]# vgdisplay
    --- Volume group ---
    VG Name               rl
    System ID
    Format                lvm2
    ..........
    VG Size               98.41 GiB
    PE Size               4.00 MiB
    Total PE              25193
    Alloc PE / Size       25193 / 98.41 GiB
    Free  PE / Size       0 / 0
    ...<SNIP>...
    ```
    
    !!! note
        
        From the output above: 
        - The volume group name is rl 
        - The size of the VG is 98.41 GiB
        - There are 0 (zero) physical extents (PE) that are free in the VG, which is equivalent to 0MB of space. 
    
2. Assign the new PV (/dev/loop1) to the existing `rl` volume group. Use the `vgextend` command, type: 
    
    ```bash
    [root@localhost ~]# vgextend rl /dev/loop1
    Volume group "rl" successfully extended
    ```
    
3. Run the `vgdisplay` command again to view your changes. Type: 
    
    ```bash
    [root@localhost ~]# vgdisplay
    --- Volume group ---
    VG Name               rl
    System ID
    Format                lvm2
    Metadata Areas        2
    Metadata Sequence No  5
    .......
    VG Size               <108.41 GiB
    PE Size               4.00 MiB
    Total PE              27752
    Alloc PE / Size       25193 / 98.41 GiB
    Free  PE / Size       2559 / <10.00 GiB
    ...<SNIP>...
    ```
    
    !!! Question

        Using your `vgdisplay` output, note down the changes on your system. What are the new values for "Free PE / Size"?  
    
#### To remove a LV, VG and PV 

This section will step through how to delete the `/dev/loop1`` PV that you assigned to the existing `rl` VG in the previous section. 

1. Remove the logical volume named scratch2. Type:
    
    ```bash
    [root@localhost ~]# lvremove -f  /dev/rl/scratch2
    Logical volume "scratch2" successfully removed.
    ```
    
2. Remove the scratch3 logical volume, by running:
    
    ```bash
    [root@localhost ~]# lvremove -f  /dev/rl/scratch3
    ```

3. With the relevant volumes now removed, you can now reduce the size of the `rl` VG to make it consistent. Type:
    
    ```bash
    [root@localhost ~]# vgreduce --removemissing  rl
    ```
    
4. Remove any LVM labels from the `/dev/loop1` PV. Type:
    
    ```bash
    [root@localhost ~]# pvremove /dev/loop1
    Labels on physical volume "/dev/loop1" successfully wiped.
    ```

#### To create a new volume group 

In this section, you will create a brand new standalone volume group named "scratch".  The scratch VG will get it's space entirely from the `/dev/loop1` pseudo block device.

1. Create the new `scratch` space. Type:
    
    ```bash
    [root@localhost ~]# vgcreate scratch /dev/loop1
    Physical volume "/dev/loop1" successfully created.
    Volume group "scratch" successfully created
    ```
    
2. Run the `vgdisplay` command to view your changes. Type: 
    
    ```bash
    [root@localhost ~]# vgdisplay scratch
    --- Volume group ---
    VG Name               scratch
    System ID
    Format                lvm2
    Metadata Areas        1
    Metadata Sequence No  1
    .......
    VG Size               <10.00 GiB
    PE Size               4.00 MiB
    Total PE              2559
    Alloc PE / Size       0 / 0
    Free  PE / Size       2559 / <10.00 GiB
    VG UUID               nQZPfK-bo7E-vOSR***
    ...<SNIP>...
    ```
    
    !!! question 
        
        Review your `vgdisplay` output. What are the values for "Free PE / Size"? And how are these values different from the earlier section when you added the `/dev/loop1` PV to the existing `rl` volume group?
    
#### To create a logical volume 

With the additional free space we have been able to add to the rl volume group (VG), it is now possible to add a Logical volume that can be used to store data after formatting.

1. Use the `lvdisplay` command to view the currently configured logical volumes. Type: 
    
    ```bash
    [root@localhost ~]# lvdisplay
    ```
    
    !!! question
        
        From your output answer the following questions: 

        1. How many logical volumes (LVs) are defined?
        
        2. What are the names of the LVs?

        3. What are the various LVs being used for on your system?
        
    
2. Use the `lvs` command to similarly display the logical volumes, but this time filter the output to show specific fields. Filter to view the lv_name (logical volume name), lv_size (logical volume size), lv_path, vg_name (volume group name) fields. Type:
    
    ```bash
    [root@localhost ~]# lvs  -o lv_name,lv_size,lv_path,vg_name
    LV   LSize   Path         VG
    home <29.68g /dev/rl/home rl
    root <60.79g /dev/rl/root rl
    swap  <7.95g /dev/rl/swap rl
    ```
    
    !!! note

        lv_name = logical volume name, lv_size = logical volume size, lv_path = logical volume path, vg_name = volume group.
    
3. On the new `scratch` VG, create a new logical volume called “scratch2” using the `lvcreate` command. Set the size for `scratch2` to be 2GB. Type:
    
    ```bash
    [root@localhost ~]# lvcreate -L 2G --name scratch2 scratch
    Logical volume "scratch2" created.
    ```
    
4. Create a second logical volume called “scratch3”. This time use up the entire remaining available space on the `scratch` volume group. Type:
    
    ```bash
    [root@localhost ~]# lvcreate -l 100%FREE --wipesignatures y --yes --zero y --name scratch3 scratch
    Logical volume "scratch3" created.
    ```
    
5. Use the `lvdisplay` command again to view the new LV. 
    
## Exercise 2

To make the traditional partition and LVM-style volumes created earlier usable by the operating system, you need to create file systems on it. Writing a file system to a device is also known as formatting the disk.

This exercise covers file system creation as well the use of some common file system maintenance tools.

#### To create a VFAT file system 

Here you will use the `mke2fs` program to create an vFAT file system on the new /dev/loop0p1 partition.

1. Use the `mkfs.vfat` utility to create an vfat type file system on the `/dev/loop0p1` volume. Type: 
    
    ```bash
    [root@localhost ~]# mkfs.vfat /dev/loop0p1
    mkfs.fat 4.*
    ```

2. Use the `lsblk` to query the system for interesting information about the block device. Type:
    
    ```bash
    [root@localhost ~]# lsblk -f /dev/loop0
    NAME      FSTYPE LABEL UUID                 MOUNTPOINT
    loop0
    └─loop0p1 vfat         658D-4A90
    ```
    
#### To create an EXT4 file system

To make the logical volumes that were created earlier usable by the operating system, you need to create file systems on them. Writing a file system to a device is also known as formatting the disk.

Here you will use the `mke2fs` program to create an EXT4 file system on the new scrtach1 volume.

1. Use the `mkfs.ext4` utility to create an EXT4 type filesystem on the `/dev/scratch/scratch2` volume. Type: 
    
    ```bash
    [root@localhost ~]# mkfs.ext4 /dev/scratch/scratch2
    ...<SNIP>...
    Writing superblocks and filesystem accounting information: done
    ```
    
2. Use the `lsblk` to query the system for interesting information about the scratch1 volume. Type:
    
    ```bash
    [root@localhost ~]# lsblk -f /dev/scratch/scratch2
    NAME        FSTYPE LABEL UUID          MOUNTPOINT
    scratch-scratch2 ext4         6689b6aa****
    ```
    
#### To create an XFS file system 

Here you will use the `mke2fs` program to create a XFS file system on the new scratch2 volume.

1. Use the `mkfs.xfs` utility to create a XFS type filesystem on the `/dev/rl/scratch3` volume. Type: 
    
    ```bash
    [root@localhost ~]# mkfs.xfs /dev/scratch/scratch3
    meta-data=/dev/scratch/scratch3  isize=512    agcount=4, agsize=524032 blks
    ...<SNIP>...
    Discarding blocks...Done.
    ```

2. Use the `lsblk` to query the system for interesting information about the scratch2 volume. Type:
    
    ```bash
    [root@localhost ~]# lsblk -f /dev/scratch/scratch3
    NAME        FSTYPE LABEL UUID         MOUNTPOINT
    scratch-scratch3 xfs          1d1ac306***
    ```
    
#### To use `dumpe2fs`, `tune2fs`, `lsblk` and `fsck`

Here we will walk through the use of some common filesystem utilities that can be used in maintaining the filesystem, fixing filesystem problems, debugging filesystem issues etc. 

1. Find out the value of the current “maximal mount count” on the scratch2 volume. Type: 
    
    ```bash
    [root@localhost ~]# dumpe2fs /dev/scratch/scratch2 | grep -i  "maximum mount count"
    dumpe2fs 1.4***
    Maximum mount count:      -1
    ```
    
    !!! question
        
        1. What purpose does the “maximum mount count” serve?
        2. What is the value of the maximal mount count of your `root` volume (/dev/rl/root)?
    
2. Adjust/set the maximal mount count value to zero between filesystem checks on the `/dev/scratch/scratch2` volume. Use the `tune2fs` command. Type: 
    
    ```bash
    [root@localhost ~]# tune2fs -c 0 /dev/scratch/scratch2
    tune2fs 1.*.*
    Setting maximal mount count to -1
    ```
    
3. Use the `fsck` command to check the scratch1 file system. Type: 
    
    ```bash
    [root@localhost ~]# fsck -Cfp /dev/scratch/scratch2
    fsck from util-linux 2.*
    /dev/mapper/scratch-scratch2: 11/131072 files (0.0% non-contiguous), 26156/524288 blocks
    ```
    
4. Create a volume label for the new EXT4 volume using the `tune2fs` program. Type:
    
    ```bash
    [root@localhost root]# tune2fs -L scratch2 /dev/scratch/scratch2
    ```
    
5. Use `lsblk` to view information about `/dev/scratch/scratch2`. Type:
    
    ```bash
    [root@localhost ~]# lsblk -o name,size,label /dev/scratch/scratch2
    NAME        SIZE LABEL    
    scratch-scratch2   2G scratch2
    ```
    
6. Check the XFS file system on the scratch3 volume. Type:
    
    ```bash
    [root@localhost ~]# fsck -Cfp /dev/scratch/scratch3
    fsck from util-linux 2.*
    /usr/sbin/fsck.xfs: XFS file system.  
    ```
    
## Exercise 3

The previous exercises walked through preparing a block/storage device for use on a system. After going through all the motions of partitioning, formatting and so on, the final step in making the file system available to users for storing data is known as mounting. 

This exercise will cover how to `mount` and `umount` the file systems that we created in the previous exercise.

### `mount`

The `mount` command is used for attaching the filesystem created on a device to the file hierarchy. 

#### To mount an VFAT file system

1. Log into the system as a user with administrative privileges.

2. Create a folder named `/mnt/10gb-scratch1-partition`. This folder will be used at the mount point for the scratch1 file system. Type:
    
    ```bash
    [root@localhost ~]# mkdir /mnt/10gb-scratch1-partition
    ```
    
3. Mount the partition. Type:
    
    ```bash
    [root@localhost ~]# mount /dev/loop0p1  /mnt/10gb-scratch1-partition
    ```
    
4. Use the `mount` command to display all VFAT file systems on the system. Use grep to filter the output for the word `scratch`. Type:
    
    ```bash
    [root@localhost ~]# mount -t vfat | grep scratch
    ```

5. Use the `df` command to view a report of the file system disk space usage on the server. Type:
    
    ```bash
    [root@localhost ~]# df -ht vfat | grep scratch
    ```
    
6. Use the `--bind` option with the `mount` command to make the `/mnt/10gb-scratch1-partition` file-system also appear under a simpler or more user friendly name/path such as `/mnt/scratch1`. Type:
    
    ```bash
    [root@localhost ~]# mount --bind /mnt/10gb-scratch1-partition /mnt/scratch1
    ```
    
7. Use the `df` command again to view the effect of the bind mount.
    
#### To mount a EXT4 file system

1. Create a folder named `/mnt/2gb-scratch2-volume`. This folder will be used at the mount point for the scratch2 volume. Type:
    
    ```bash
    [root@localhost ~]# mkdir /mnt/2gb-scratch2-volume
    ```
    
2. Mount the partition. Type:
    
    ```bash
    [root@localhost ~]# mount /dev/scratch/scratch2  /mnt/2gb-scratch2-volume
    ```

3. Use the `mount` command to display all EXT4 file systems on the system. Type:
    
    ```bash
    [root@localhost ~]# mount -t ext4
    ```
    
4. Ensure that the mount point has the right permissions for allowing all system users can write to the mounted volume, by running: 
    
    ```bash
    [root@localhost ~]# chmod 777 /mnt/2gb-scratch2-volume
    ```
    
5. Use the `df` command to view a report of the file system disk space usage on the server.

#### To mount a XFS file system

1. Create a folder named `/mnt/8gb-scratch3-volume`. This will be the mount point for the scratch3 file system. Type:
    
    ```bash
    [root@localhost ~]# mkdir /mnt/8gb-scratch3-volume
    ```
    
2. Mount the partition. Type:
    
    ```bash
    [root@localhost ~]# mount /dev/scratch/scratch3  /mnt/8gb-scratch3-volume
    ```

3. Use the `mount` command to display all XFS file systems on the system. Type:
    
    ```bash
    [root@localhost ~]# mount -t xfs | grep scratch
    ```
    
4. Use the `df` command to view a report of the file system disk space usage on the server.

#### To make file system mounts persistent

1. Use the `cat` command to review the current contents of the `/etc/fstab` file. 

2. Before making any changes, backup the `/etc/fstab` file. Type:
    
    ```bash
    [root@localhost ~]# cp /etc/fstab  /etc/fstab.copy
    ```
    
3. Using a text editor, carefully append the following new entries in the `/etc/fstab` file for the 3 file systems that we created earlier.
    
    The new entries are:

    ```bash
    /dev/loop0p1           /mnt/10gb-scratch1-partition   auto   defaults,nofail  0  0
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume       ext4   defaults,nofail  0  0
    /dev/scratch/scratch3  /mnt/2gb-scratch3-volume        xfs   defaults,nofail  0  0
    ```
    
    We'll use the BASH heredoc method below to create the entries. Carefully type:
    
    ```bash
    [root@localhost ~]# cat >> /etc/fstab << EOF
    /dev/loop0p1           /mnt/10gb-scratch1-partition   auto   defaults,nofail  0  0
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume       ext4   defaults,nofail  0  0
    /dev/scratch/scratch3  /mnt/8gb-scratch3-volume        xfs   defaults,nofail  0  0 
    EOF
    ```
    
4. With real disk or storage devices, the previous steps will be enough to make the system automatically and correctly  mount all the new file systems and apply any special mount options. 
    
    BUT, because we've been using special pseudo-block devices (loop devices) in this lab, we must complete an additional important task to ensure that the correct loop devices are automatically recreated after the system reboots. 
    
    To do this we'll create a custom systemd service unit to help with this.
    
    Use any text editor that you are comfortable with to create the `/etc/systemd/system/loopdevices.service` file.
    
    Enter the following text in the file. 
    
    ```bash
    [Unit]
    Description=Activate loop devices
    DefaultDependencies=no
    After=systemd-udev-settle.service
    Before=lvm2-activation.service
    Wants=systemd-udev-settle.service
    
    [Service]
    ExecStart=losetup -P /dev/loop0 /tmp/10G-fake-disk.img
    ExecStart=losetup -P /dev/loop1 /tmp/10G-fake-lvm-disk.img
    Type=oneshot
    
    [Install]
    WantedBy=local-fs.target
    ```
    
    Ensure you save your changes to the file.
    
5. Use the `systemctl` command to enable the new loopdevice service. Type:
    
    ```bash
    [root@localhost ~]# systemctl enable loopdevices.service
    ```
    
6. Try starting the service to ensure that it starts successfully. Type:
    
    ```bash
    [root@localhost ~]# systemctl start loopdevices.service
    ```

    If it starts without any errors, you can now go on to the next step where you'll do the real test of rebooting the system.
    
7. Reboot the system and ensure everything works fine and that the new file systems got mounted automatically.

## Exercise 4

**Preamble:** 

For no good reason, the user named “unreasonable” has decided to create an extremely LARGE file on a system shared with other users!! 

The file has taken up a lot of space on the local hard disk.  

As an administrator, you can find and delete the offending file and carry on with your day and hope it's a one time occurrence, OR you can find and delete the file to free up disk space and devise a plan to prevent a reoccurrence. We will attempt the latter solution in later exercise.

In the interim - 

>Unreasonable user strikes again!

#### To create the large file 

**Perform this exercise from your partner-system** 

Unreasonable user accidentally notices that new ***scratch*** file systems have been made available on the server overnight. Score. Profit.

He then proceeds to fill up the volume with an arbitrarily large file.

1. Log into the system as the `unreasonable` user.

2. Check the system to see if there are any new file systems that you can abuse. Type:

    ```bash
    [unreasonable@localhost ~]$ df  -h
    ```
    
3. Proceed immediately to fill up the available shared file system with garbage. Type
    
    ```bash
    [unreasonable@localhost ~]$ dd if=/dev/zero  of=/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar bs=10240
    dd: error writing '/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar': No space left on device
    187129+0 records in
    187128+0 records out
    1916194816 bytes (1.9 GB, 1.8 GiB) copied, 4.99021 s, 384 MB/s
    ```
    
4. After kicking off the `dd` process, go for a walk and return when the command completes or when it errors out because it can’t go any further. Or go and find the Administrator and complain about the disk space being full on the system.

5. Explore further unreasonable/senseless/annoying things can be done on the system. You are ***unreasonable user***. 

## Exercise 5 

### Quotas

Implementing and enforcing the use of disk quotas provides a way to ensure that the system has enough disk space and that users stay within their allotted disk space. Before implementing quotas you need to: 

* Decide which partitions or volumes that you want to implement disk quotas on. 
* Decide the level at which to enforce the quotas – i.e. per user, per group or both. 
* Decide what your soft and hard limits will be. 
* Decide what the grace periods will be (i.e. if there will be any at all). 

*Hard Limit* 

The hard limit defines the absolute maximum amount of disk space that a user or group can use. Once this limit is reached, no further disk space can be used.

*Soft Limit*

The soft limit defines the maximum amount of disk space that can be used. However, unlike the hard limit, the soft limit can be exceeded for a certain amount of time. That time is known as the grace period. 

*Grace Period*

The grace period is the time during which the soft limit may be exceeded. The grace period can be expressed in seconds, minutes, hours, days, weeks, or months, thus giving the system administrator a great deal of freedom in determining how much time to give users to get their disk usage below their soft limit. 

These are the high-level steps involved in implementing quotas. 

* Installing the quota software 
* Modifying the “/etc/fstab” file 
* Remounting the file system(s) 
* Running quotacheck 
* Assigning quotas 

The commands you will be using are: 

`quotacheck`: 

Utility for checking and repairing quota files. 

```bash
quotacheck [-gucbfinvdmMR] [-F <quota-format>] filesystem|-a

  -u, --user                check user files
  -g, --group               check group files
  -c, --create-files        create new quota files
  -b, --backup              create backups of old quota files
  -f, --force               force check even if quotas are enabled
  -i, --interactive         interactive mode
  -n, --use-first-dquot     use the first copy of duplicated structure
  -v, --verbose             print more information
  -d, --debug               print even more messages
  -m, --no-remount          do not remount filesystem read-only
  -M, --try-remount         try remounting filesystem read-only,
                            continue even if it fails
  -R, --exclude-root        exclude root when checking all filesystems
  -F, --format=formatname   check quota files of specific format
  -a, --all                 check all filesystems
```

`edquota`:  

Tool for editing user quotas

```bash
  SYNOPSIS
       edquota [ -p protoname ] [ -u | -g | -P ] [ -rm ] [ -F format-name ] [ -f filesystem ] username | groupname | projectname...

       edquota [ -u | -g | -P ] [ -F format-name ] [ -f filesystem ] -t

       edquota [ -u | -g | -P ] [ -F format-name ] [ -f filesystem ] -T username | groupname | projectname...
```

`repquota`:  

Utility for reporting quotas. 

```bash
  Usage:
  repquota [-vugsi] [-c|C] [-t|n] [-F quotaformat] [-O (default | xml | csv)] (-a | mntpoint)

  -v, --verbose               display also users/groups without any usage
  -u, --user                  display information about users
  -g, --group                 display information about groups
  -P, --project               display information about projects
  -s, --human-readable        show numbers in human friendly units (MB, GB, ...)
  -t, --truncate-names        truncate names to 9 characters
  -p, --raw-grace             print grace time in seconds since epoch
  -n, --no-names              do not translate uid/gid to name
  -i, --no-autofs             avoid autofs mountpoints
  -c, --cache                 translate big number of ids at once
  -C, --no-cache              translate ids one by one
  -F, --format=formatname     report information for specific format
  -O, --output=format         format output as xml or csv
  -a, --all                   report information for all mount points with quotas
```

`quotaon` and `quotaoff`:

Tools used for turning filesystem quotas on and off

```bash
  SYNOPSIS
       quotaon [ -vugfp ] [ -F format-name ] filesystem...
       quotaon [ -avugPfp ] [ -F format-name ]

       quotaoff [ -vugPp ] [ -x state ] filesystem...
       quotaoff [ -avugp ]
```

#### To install the quota software 

1.  While logged in as root, first check to see if the `quota-*.rpm` package is installed on your system. Type: 
    
    ```bash
    [root@localhost ~]# rpm -q quota
    quota-*
    ```
    
    !!! question
        
        What was your output?

2. IF you don't have the quote package installed on your system, use `dnf` to install it.

#### To setup and configure quota

1. You have decided to implement EXT4 style quotas on the “/dev/rl/scratch2" volume. You have also decided to implement quotas both at the user and group level. 

2. Review the `/etc/fstab` file with your editor of choice. Below is the relevant entry in the file before we make any changes to the file.
    
    ```bash
    [root@localhost ~]# grep scratch2 /etc/fstab
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume    ext4     defaults  0  0
    ```
    
3. Make a backup of `/etc/fstab`.
    
4. As a part of implementing quotas, some new quota related mount options need to be added to the scratch2 volume entry. The scratch2 volume entry needs to be update to the new line here:
    
    ```bash
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume   ext4   defaults,usrquota,grpquota  0  0
    ```
    
    You can either use your favorite text editor to make the change or use the `sed` utility as shown in the next step.
    
5. Use the `sed` utility to search for the line we want to change and make the update in place. Type:
    
    ```bash
    [root@localhost ~]# sudo sed -i \
    '/^\/dev\/scratch\/scratch2/ s|.*|/dev/scratch/scratch2  /mnt/2gb-scratch2-volume   ext4   defaults,usrquota,grpquota  0  0|'\
    /etc/fstab
    ```

6. Use `grep` again to quickly review the file to ensure the correct change was made in `/etc/fstab`.

7. For the changes to `/etc/fstab` to become effective you'll need to do a few more things. First reload systemd-daemon, by running:
    
    ```bash
    [root@localhost ~]# systemctl daemon-reload
    ```

8. Next remount the relevant file system. Type:
    
    ```bash
    [root@localhost ~]# mount -o remount /mnt/2gb-scratch2-volume
    ```

9. Verify that the new mount options have been applied by checking the `/proc/mounts` file. Type:
    
    ```bash
    [root@localhost ~]# cat /proc/mounts  | grep scratch2
    /dev/mapper/rl-scratch2 /mnt/2gb-scratch2-volume ext4 rw,relatime,quota,usrquota,grpquota 0 0
    ```
    
    !!! tip
        
        You can also check the mount options that are in use for any file system by using the `mount` command. For the previous example you can view the mount options for the ext4 formatted scratch2 volume by running:
        
        ```bash
        [root@localhost ~]# mount -t ext4 | grep scratch2
        /dev/mapper/scratch-scratch2 on /mnt/2gb-scratch2-volume type ext4 (rw,relatime,quota,usrquota,grpquota)
        ``` 
    
    !!! question
        
        Write down the commands to separately `unmount` a given filesystem and then `mount` it back? 

10. You now need to make the file system ready to support quotas. Create the quota files and also generate the table of current disk usage per file system. Type: 
    
    ```bash
    [root@localhost ~]# quotacheck -avcug
    ....
    quotacheck: Scanning /dev/mapper/scratch-scratch2 [/mnt/2gb-scratch2-volume] done
    ...<SNIP>...
    quotacheck: Old file not found.
    quotacheck: Old file not found.  
    ```
    
    !!! question
        
        After the above command has executed you will notice two new files created under the “/mnt/2gb-scratch2-volume" directory. List the files here? 
    
    
    !!! tip
        
        To get up-to-date status of the quota file system you should run the `quotacheck -avcug` command periodically while quota is turned off on the file system.  
    
11. To enable user and group quotas on all the file systems specified in “/etc/fstab” type: 
    
    ```bash
    [root@localhost ~]# quotaon -av
    ```
    
#### To assign quotas to users 

You have decided to assign a soft limit of 90 MB and a hard limit of 100 MB for each user on the system with a grace period of 5 minutes.   

This means that all users for which we apply the quota cannot exceed the hard limit of 100 MB, but they have about 5 minutes to exceed their soft limit of 90 MB but still stay under their hard limit. 

1. You will create the limits using a prototype user. The user called “me” will be your prototype user. Use the `edquota` command to create the limits. Type: 
    
    ```bash
    [root@serverXY  root]# edquota -u me
    ```
    The above command will bring up your default editor with the contents below: 
    
    ```bash
    Disk quotas for user me (uid 1001):
    Filesystem                   blocks       soft       hard     inodes     soft     hard
    /dev/mapper/scratch-scratch2           0          0          0          0        0        0
    ```
    
    Modify/edit the above file (the 3rd line) to reflect the limits you want. Change the file to read: 
    
    ```bash
    Disk quotas for user me (uid 1001):
    Filesystem                   blocks       soft       hard     inodes     soft     hard
    /dev/mapper/scratch-scratch2        0         90000      100000       0        0        0
    ```
    
    Save your changes to the file and close it.
    
2. You will create the grace period using the `-t` option with the `edquota` command. Type: 

    ```bash
    [root@serverXY  root]# edquota -t 
    ```
    
    This command will bring up your default editor with the contents similar to the one shown below: 
    
    ```bash
    Grace period before enforcing soft limits for users:
    Time units may be: days, hours, minutes, or seconds
    Filesystem             Block grace period     Inode grace period
    /dev/mapper/scratch-scratch2                  7days                  7days
    ```
    
    Edit the above file (the 4th line) to reflect the grace period you want. 
    
    Change the file to read: 
    
    ```bash
    Grace period before enforcing soft limits for users:
    Time units may be: days, hours, minutes, or seconds
    Filesystem             Block grace period     Inode grace period
    /dev/mapper/scratch-scratch1       5minutes                  7days
    ```
    
3. Next apply the settings you have configured for the prototype user “me” to the users - “ying” and “unreasonable”.  Type:
    
    ```bash
    [root@localhost ~]# edquota -p me -u ying unreasonable
    ```
    
4. To get a status report for all quotas you have enabled, Type: 
    
    ```bash
    [root@localhost ~]# repquota /mnt/2gb-scratch2-volume
    *** Report for user quotas on device /dev/mapper/scratch-scratch2
    Block grace time: 00:05; Inode grace time: 7days
                          Block limits                File limits
    User            used    soft    hard  grace    used  soft  hard  grace
    ----------------------------------------------------------------------
    root      --      20       0       0              2     0     0
    unreasonable +- 1871288   90000  100000  00:04       1     0     0
    ```
    
    !!! Question
        
        From the output above under the grace column for user `unreasonable`, how much grace period does the user have left? 
    
5. From the report, you notice that unreasonable user has exceeded their quota limits on the server. You search for the offending file and help unreasonable user "clean it up" and get them back in compliance. Type:
    
    ```bash
    [root@localhost ~]# rm -rf /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    ```
    
6. Use the `su`` command to temporarily assume the identity of the `unreasonable` user and try creating additional files or directories as that user. Type: 
    
    ```bash
    [root@localhost ~]# su - unreasonable
    ```

7. While logged on as the user unreasonable, you check and notice that the `/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar` file that you created in a previous exercise is missing! Irritated you decide to create it again. Type:
    
    ```bash
    [unreasonable@localhost ~]$ dd if=/dev/zero  of=/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar bs=10240
    ...<SNIP>...
    dd: error writing '/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar': Disk quota exceeded
    10001+0 records in
    10000+0 records out
    102400000 bytes (102 MB, 98 MiB) copied, 0.19433 s, 527 MB/s
    ```
    
    Hmmmm...interesting you mutter. 
    
8. Try creating a folder called test under /mnt/2gb-scratch2-volume/. An empty folder should not take up or use a lot of disk space and so you type:
    
    ```bash
    [unreasonable@localhost ~]$ mkdir /mnt/2gb-scratch2-volume/test
    mkdir: cannot create directory ‘/mnt/2gb-scratch2-volume/test’: Disk quota exceeded
    ```
    
9. Check the size of the LARGE-USELESS-FILE.tar file. Type:
    
    ```bash
    [unreasonable@localhost ~]$ ls -l /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    -rw-rw-r-- 1 unreasonable unreasonable 102400000 Oct  5 19:37 /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    ```

    !!! Question
        
        What happened? 
    
10. Frustrated with ignorance the unreasonable user types:
    
    ```bash
    [unreasonable@localhost ~]$ man quota
    ```
    
    !!! Note
        
        The “unreasonable” user will be forced to do something about the “LARGE-USELESS-FILE.tar” that he created.  Until that user brings his total file size under his limit he will not be able to do a whole lot else. 
    
11. All done with this lab on Linux file systems.
