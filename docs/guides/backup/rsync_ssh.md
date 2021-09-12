---
title: Synchronization With rsync
---

# Using rsync To Keep Two Machines Synchronized

## Prerequisites

This is everything you'll need to understand and follow along with this guide.

* A machine running Rocky Linux.
* To be comfortable with modifying configuration files from the command-line.
* Knowledge of how to use a command line editor (we use _vi_ here, but you could use your favorite editor).
* You will need root access, and ideally be signed in as the root user in your terminal.
* Public and Private SSH key pairs.
* Able to create a simple bash script, using vi or your favorite editor, and test it.
* Able to use _crontab_ to automate the running of the script.

# Introduction

Using _rsync_ over SSH is neither as powerful as [lsyncd](../backup/mirroring_lsyncd.md) (which allows you to watch a directory or file for changes and keep it synchronized in real time), or as flexible as [rsnapshot](../backup/rsnapshot_backup.md) (which offers the ability to easily backup multiple targets from a single machine). But, it does offer the ability to keep two machines up-to-date on a schedule that you define.

rsync has been around since the dawn of time (OK, maybe not quite that long, but a long time!) so every Linux distribution has it available, and most still install it with the base packages. rsync over SSH might be a solution, if you need to keep a set of directories up-to-date on a target machine, but real-time syncing is not particularly important.

For all of the below, we will be doing things as the root user, so either login as root or use the `sudo -s` command to switch to the root user in your terminal.

## Installing rsync

While rsync is probably already installed, it's a good idea to update rsync to the latest version on both the source and target machines. To make sure that rsync is installed and up-to-date, do this on both machines:

`dnf install rsync`

If the package is not installed, dnf will ask you to confirm installation and if it is installed, dnf will look for an update and give you the opportunity to install it.

## Preparing The Environment

This particular example will use rsync on the target to pull from the source, rather than pushing from the source to the target, so we will need to set up an [SSH key pair](../security/ssh_public_private_keys.md) for this for this. Once the SSH key pairs are created, and you have confirmed access without a password from the target machine to the source, we are ready to start.

## rsync Parameters And Setting Up A Script

Before we get terribly carried away with the setting up a script, we first need to decide what parameters we want to use with rsync. There are a many possibilities, so take a look at the [manual for rsync](https://linux.die.net/man/1/rsync). The most common way to use rsync is to use the -a option, because -a, or archive, combines a number of options into one and these are very common options. What does -a include?

* -r, recurse the directories
* -l, maintain symbolic links as symbolic links
* -p, preserve permissions
* -t, preserve modification times
* -g, preserve group-
* -o, preserve owner
* -D, preserve device files

The only other options that we need to specify in this example is:

* -e, specify the remote shell to use
* --delete, which says if the target directory has a file in it that doesn't exist on the source, get rid of it

Next, we need to set up a script by creating a file for it. (Again, use your favorite editor if you are not familiar with vi.) To create the file, just use this command:

`vi /usr/local/sbin/rsync_dirs`

And then make it executable:

`chmod +x /usr/local/sbin/rsync_dirs`

## Testing

For now, let's make it super simple and safe so that we can test without fear. Note that below where we are using the URL "source.domain.com". Replace that with your own source computer's domain or IP address, both will work. Remember too, that in this case we are creating the script on the "target" machine, as we are pulling files in from the source machine:

```
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```
In this case, we are assuming that your home directory does not exist on the target. **If it does, you may want to back it up before you execute the script!**

Now run the script:

`/usr/local/sbin/rsync_dirs`

If all is well, you should get a completely synchronized copy of your home directory on the target machine. Check to be sure this is the case.

Assuming all of that worked out as we hoped, go next go ahead and create a new file on the source machine in your home directory:

`touch /home/your_user/testfile.txt`

Run the script again:

`/usr/local/sbin/rsync_dirs`

And then verify that the target machine received the new file. If so, the next step is to check the delete process.  On the source machine again, remove the file we just created:

`rm -f /home/your_user/testfile.txt`

Run the script again:

`/usr/local/sbin/rsync_dirs`

Verify the file is now gone on the target machine.

Finally, let's create a file on the target machine that doesn't exist on the source. So on the target:

`touch /home/your_user/a_different_file.txt`

Run the script a final time:

`/usr/local/sbin/rsync_dirs`

The file we just created on the target should now be gone, because it does not exist on the source.

Assuming all of this worked as expected, go ahead and modify the script to synchronize all the directories that you want.

## Automating Everything

We probably don't want to be running this script manually every time we want to synchronize, so the next step is to automate this. Let's say that you want to want to run this script every evening at 11 PM. To automate that with Rocky Linux, we use crontab:

`crontab -e`

This will pull up the cron, which may look something like this:

```
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
The cron is set up on a 24 hour clock, so what we will need for our entry at the bottom of this file is:

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

What this says is to run this command at 00 minutes, 23 hundred hours, every day, every month, and every day of the week. Save your cron entry with:

`Shift : wq!`

... or with the commands that your favorite editor uses for saving a file.

# Conclusions

While rsync may not be as flexible or powerful as some of the other options, it offers simple file synchronization. And there's always a use for that.
