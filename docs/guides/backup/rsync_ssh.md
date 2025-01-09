---
title: Synchronization With rsync
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tags:
  - synchronization
  - rsync
---

## Prerequisites

This is everything you will need to understand and follow along with this guide:

- A computer running Rocky Linux
- To be comfortable with modifying configuration files from the command line
- Knowledge of how to use a command line editor (using _vi_ here, but you can use your favorite editor)
- You will need root access or `sudo` privileges
- Public and Private SSH key pairs
- Able to create a bash script with `vi` or your favorite editor and test it.
- Able to use `crontab` to automate the running of the script

## Introduction

Using `rsync` over SSH is not as powerful as [lsyncd](../backup/mirroring_lsyncd.md) (which allows you to watch a directory or file for changes and keep it synchronized in real-time), nor as flexible as [rsnapshot](../backup/rsnapshot_backup.md) (which offers the ability to backup multiple targets from a single computer). However, it allows you to keep two computers up to date on a schedule you define.

If you need to keep a set of directories on the target computer up to date, and you do not care about real-time synchronization as a feature, then `rsync` over SSH is probably the best solution.

You will be working as the root user for this procedure. Either log in as root or use the `sudo -s` command to switch to the root user in your terminal.

### Installing `rsync`

Although `rsync` is probably already installed. To ensure that `rsync` is up to date, do the following on both computers:

```bash
dnf install rsync
```

If the package is not installed, `dnf` will ask you to confirm the installation. If it is already installed, `dnf` will look for an update and prompt you to install it.

### Preparing the environment

This example will use `rsync` on the target computer to pull from the source instead of pushing from the source to the target. You need to set up an [SSH key pair](../security/ssh_public_private_keys.md) for this. After creating the SSH key pair, verify passwordless access from the target computer to the source computer.

### `rsync` parameters and setting up a script

Before the script setup continues, you must decide what parameters to use with `rsync`. Many possibilities exist. Review the [manual for rsync](https://linux.die.net/man/1/rsync) for a complete list. The most common way to use `rsync` is to use the `-a` option because `-a`, or "archive", combines several common options. What does `-a` include?

- `-r`, recurses the directories
- `-l`, maintains symbolic links as symbolic links
- `-p`, preserves permissions
- `-t`, preserves modification times
- `-g`, preserves group
- `-o`, preserves owner
- `-D`, preserves device files

The only other options that you need to specify in this example are:

- `-e`, specify the remote shell to use
- `--delete`, which says if the target directory has a file in it that does not exist on the source, get rid of it

Next, set up a script on the target computer by creating a file for it (again, use your favorite editor if you are unfamiliar with `vi`). To create the file, use this command:

```bash
vi /usr/local/sbin/rsync_dirs
```

Add the content:

```bash
#!/usr/bin/env bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

Replace "source.domain.com" with your domain name, hostname, or IP address.

Make it executable:

```bash
chmod +x /usr/local/sbin/rsync_dirs
```

## Testing

Scripting ensures you can test without worry.

!!! warning

    In this case, the assumption is that your home directory does not exist on the target computer. **If it exists, you may want to back it up before executing the script!**

Run the script:

```bash
/usr/local/sbin/rsync_dirs
```

If all is well, you will get a synchronized copy of your home directory on the target computer. Ensure this is the case.

Assuming all of that worked, create a new file on the source computer in your home directory:

```bash
touch /home/your_user/testfile.txt
```

Rerun the script:

```bash
/usr/local/sbin/rsync_dirs
```

Verify that the target computer receives the new file. If so, the next step is to verify the deletion process. Delete the file you just created on the source computer:

```bash
rm -f /home/your_user/testfile.txt
```

Rerun the script:

```bash
/usr/local/sbin/rsync_dirs
```

Verify that the file no longer exists on the target computer.

Finally, create a file on the target computer that does not exist on the source:

```bash
touch /home/your_user/a_different_file.txt
```

Run the script a final time:

```bash
/usr/local/sbin/rsync_dirs
```

The file you created on the target should no longer exist because it does not exist on the source.

Assuming all this worked as expected, change the script to synchronize all your desired directories.

## Automating everything

You may not want to run this script whenever you want to synchronize manually. Use a `crontab` to do this automatically on a schedule. To run this script at 11 PM every night:

```bash
crontab -e
```

This will pull up and look similar to this:

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

!!! info

    The example `crontab` shows an empty but commented file. The commenting does not appear on every computer instance and may be an empty file. On an active computer, you may see other entries.

The `crontab` is on a 24-hour clock. You will need your entry at the bottom of this file:

```crontab
00 23   *  *  *    /usr/local/sbin/rsync_dirs
```

This says to run this command at 00 minutes and 23 hours daily, every month, and every day of the week. Save your `crontab` entry with:

++shift+colon+"w"+"q"+exclam++

## Optional flags

```bash
-n: Dry-Run to see what files would be transferred
-v: list out all the files that are being transferred
-vvv: to provide debug info while transferring files
-z: to enable compression during the transfer
```

## Conclusions

Although `rsync` is not as flexible or robust as other tools, it provides file synchronization, which is always helpful.
