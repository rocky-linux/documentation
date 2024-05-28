---
title: Synchronization With rsync
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tags:
  - synchronization
  - rsync
---

# Using `rsync` To Keep Two Machines Synchronized

## Prerequisites

This is everything you will need to understand and follow along with this guide:

- A machine running Rocky Linux
- To be comfortable with modifying configuration files from the command-line
- Knowledge of how to use a command line editor (using _vi_ here, but you can use your favorite editor)
- You will need root access, and ideally be signed in as the root user in your terminal
- Public and Private SSH key pairs
- Able to create a bash script with `vi` or your favorite editor, and test it.
- Able to use _crontab_ to automate the running of the script

## Introduction

Using `rsync` over SSH is neither as powerful as [lsyncd](../backup/mirroring_lsyncd.md) (which allows you to watch a directory or file for changes and keep it synchronized in real time), or as flexible as [rsnapshot](../backup/rsnapshot_backup.md) (which offers the ability to backup multiple targets from a single machine). However, it provides the ability to keep two computers up to date on a schedule that you define.

If you need to keep a set of directories on the target computer up to date, and you do not care about real-time synchronization as a feature, then `rsync` over SSH is probably the best solution.

For this procedure, you will be doing things as the root user. Either login as root or use the `sudo -s` command to switch to the root user in your terminal.

### Installing `rsync`

Although `rsync` is probably already installed, it is best to update `rsync` to the latest version on the source and target computers. To ensure that `rsync` is up to date, do the following on both computers:

`dnf install rsync`

If the package is not installed, `dnf` will ask you to confirm the installation, if it is already installed, `dnf` will look for an update and prompt to install it.

### Preparing The Environment

This particular example will use `rsync` on the target machine to pull from the source instead of pushing from the source to the target. You need to set up an [SSH key pair](../security/ssh_public_private_keys.md) for this. Once the SSH key pair has been created and password-free access from the target computer to the source computer has been confirmed, you can start.

### `rsync` Parameters And Setting Up A Script

Before we get terribly carried away with setting up a script, we first need to decide what parameters we want to use with `rsync`. There are many possibilities, so take a look at the [manual for rsync](https://linux.die.net/man/1/rsync). The most common way to use `rsync` is to use the `-a` option, because `-a`, or archive, combines a number of options into one and these are very common options. What does -a include?

- `-r`, recurses the directories
- `-l`, maintains symbolic links as symbolic links
- `-p`, preserves permissions
- `-t`, preserves modification times
- `-g`, preserves group
- `-o`, preserves owner
- `-D`, preserves device files

The only other options that we need to specify in this example are:

- `-e`, specify the remote shell to use
- `--delete`, which says if the target directory has a file in it that doesn't exist on the source, get rid of it

Next, we need to set up a script by creating a file for it (again, use your favorite editor if you are not familiar with vi). To create the file, just use this command:

`vi /usr/local/sbin/rsync_dirs`

And then make it executable:

`chmod +x /usr/local/sbin/rsync_dirs`

## Testing

Now, scripting makes it super simple and safe so that you can test it fearlessly. Please note that the URL used below is "source.domain.com". Replace it with the domain or IP address of your own source computer, both will work. Also remember that in this example, the script is created on the "target" computer, because the file is pulled from the source computer:

```bash
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

!!! warning

    In this case, we assume that your home directory does not exist on the target machine. **If it exists, you may want to back it up before executing the script!**

Now run the script:

`/usr/local/sbin/rsync_dirs`

If all is well, you should get a completely synchronized copy of your home directory on the target machine. Check to be sure this is the case.

Assuming all of that worked out as we hoped, go ahead and create a new file on the source machine in your home directory:

`touch /home/your_user/testfile.txt`

Run the script again:

`/usr/local/sbin/rsync_dirs`

Then verify that the target computer receives the new file. If so, the next step is to check the deletion process. Delete the file we just created on the source computer:

`rm -f /home/your_user/testfile.txt`

Run the script again:

`/usr/local/sbin/rsync_dirs`

Verify that the file no longer exists on the target computer.

Finally, let's create a file on the target machine that doesn't exist on the source. So, on the target:

`touch /home/your_user/a_different_file.txt`

Run the script a final time:

`/usr/local/sbin/rsync_dirs`

The file we just created on the target should now be gone, because it does not exist on the source.

Assuming all of this worked as expected, go ahead and modify the script to synchronize all the directories that you want.

## Automating Everything

We may not want to manually run this script every time we want to synchronize, so the next step is to do this automatically. Suppose you want to run this script at 11 PM every night. To automate this, use crontab:

`crontab -e`

This will pull up the cron, which may look something like this:

```bash
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

The cron is set up on a 24-hour clock, so what we will need for our entry at the bottom of this file is:

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

What this says is to run this command at 00 minute, 23 h, every day, every month, and every day of the week. Save your cron entry with:

++shift+colon+"w"+"q"+exclam++

... or with the commands that your favorite editor uses for saving a file.

## Optional Flags

```bash
-n : Dry-Run to see what files wouold be transferred 
-v : list out all the files which are being transferred 
-vvv : to provide debug info while transferring files 
-z : to enable compression during the transfer 
```

## Conclusions

Although `rsync` is not as flexible or powerful as other tools, it provides simple file synchronization, which is always useful.
