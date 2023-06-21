---
title: Backup Solution - rsnapshot
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - backup
  - rsnapshot
---

# Backup Solution - _rsnapshot_

## Prerequisites

  * Know how to install additional repositories and snapshots from the command-line
  * Know about mounting filesystems external of your machine (external hard drive, remote filesystem, etc.)
  * Know how to use an editor (`vi` is used here, but you can use your favorite editor)
  * Know a little BASH scripting
  * Know how to modify the crontab for the root user
  * Knowledge of SSH public and private keys (only if you plan to run remote backups from another server)

## Introduction

_rsnapshot_ is a very powerful backup utility that can be installed on any Linux-based machine. It can either back up a machine locally, or you can back up multiple machines, say servers for instance, from a single machine.

_rsnapshot_ uses `rsync` and is written entirely in perl with no library dependencies, so there are no weird requirements for installation. In the case of Rocky Linux, you should generally be able to install _rnapshot_ by using the EPEL repository. After the initial release of Rocky Linux 9.0, there was a period of time when the EPEL did not contain the _rsnapshot_ package. That has since been rectified, but we have included a method of installing from source just in case this should happen again.

This documentation covers the installation of _rsnapshot_ on Rocky Linux only.

=== "EPEL Install"

    ## Installing _rsnapshot_

    All commands shown here are called from the command-line on your server or workstation unless otherwise noted.

    ### Installing The EPEL repository

    We need the EPEL software repository from Fedora to install _rsnapshot_. To install the repository, just use this command:

    ```
    sudo dnf install epel-release
    ```

    The repository should now be active.

    ### Install the _rsnapshot_ Package

    Next, install _rsnapshot_ and some other needed tools, which are probably already installed:

    ``` 
    sudo dnf install rsnapshot openssh-server rsync
    ```

    If there are any missing dependencies, those will show up and you simply need to answer the prompt to continue. For example:

    ```
    dnf install rsnapshot
    Last metadata expiration check: 0:00:16 ago on Mon Feb 22 00:12:45 2021.
    Dependencies resolved.
    ========================================================================================================================================
    Package                           Architecture                 Version                              Repository                    Size
    ========================================================================================================================================
    Installing:
    rsnapshot                         noarch                       1.4.3-1.el8                          epel                         121 k
    Installing dependencies:
    perl-Lchown                       x86_64                       1.01-14.el8                          epel                          18 k
    rsync                             x86_64                       3.1.3-9.el8                          baseos                       404 k

    Transaction Summary
    ========================================================================================================================================
    Install  3 Packages

    Total download size: 543 k
    Installed size: 1.2 M
    Is this ok [y/N]: y
    ```

=== "Source Install"

    ## Installing _rsnapshot_ From Source

    Installing _rsnapshot_ from source is not difficult. It does come with a downside, however, in that if there is a new version released, it would require a fresh install from source to update the version, whereas the EPEL installation method would keep you up-to-date with a simple `dnf upgrade`. 

    ### Installing Development Tools and Downloading the Source

    As stated, the first step here is to install the 'Development Tools' group:

    ```
    dnf groupinstall 'Development Tools'
    ```

    You also need a few other packages:

    ```
    dnf install wget unzip rsync openssh-server
    ```

    Next we will need to download the source files from the GitHub repository. You can do this multiple ways, but the easiest in this case is probably just to download the ZIP file from the repository.

    1. Go to https://github.com/rsnapshot/rsnapshot
    2. Click on the Green "Code" button on the right
    ![Code](images/code.png)
    3. Right-click on the "Download ZIP" and copy the link location
    ![Zip](images/zip.png)
    4. Use `wget` or `curl` to download the copied link. Example:
    ```
    wget https://github.com/rsnapshot/rsnapshot/archive/refs/heads/master.zip
    ```
    5. Unzip the `master.zip` file
    ```
    unzip master.zip
    ```

    ### Building the Source

    Now that we've got everything on our machine, the next step is to build. When we unzipped the `master.zip` file, we ended up with an `rsnapshot-master` directory. We will need to change into this for our build procedure. Note that our build is using all of the package defaults, so if you want something else, you'll need to do a little investigation. Also, these steps are directly taken from the [GitHub Installation](https://github.com/rsnapshot/rsnapshot/blob/master/INSTALL.md) page:

    ```
    cd rsnapshot-master
    ```

    Run the `authogen.sh` script to generate the configure script:

    ```
    ./autogen.sh
    ```

    !!! tip

        You may get several lines that look like this:

        ```
        fatal: not a git repository (or any of the parent directories): .git
        ```

        These are not fatal.

    Next, we need to run `configure` with the configuration directory set:

    ```
    ./configure --sysconfdir=/etc
    ```

    Finally, run `make install`:

    ```
    sudo make install
    ```

    During all of this, the `rsnapshot.conf` file will be created as `rsnapshot.conf.default`. We need to copy this over to `rsnapshot.conf` and then edit it to fit what we need on our system.

    ```
    sudo cp /etc/rsnapshot.conf.default /etc/rsnapshot.conf
    ```

    This covers copying the configuration file over. The section below on "Configuring rsnapshot" will cover the changes needed in this configuration file.

## Mounting A Drive or Filesystem For Backup

In this step, we show how to mount a hard drive, such as an external USB hard drive, that will be used to back up your system. This particular step is only necessary if you are backing up a single machine or server, as seen in our first example below.

1. Plug in the USB drive.
2. Type `dmesg | grep sd` which should show you the drive you want to use. In this case, it'll be called _sda1_.  
Example: `EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem`.
3. Unfortunately (or fortunately depending on your opinion) most modern Linux desktop operating systems automount the drive if they can. This means that, depending on various factors, _rsnapshot_ might lose track of the hard drive. We want the drive to "mount" or make its files available in the same place every time.  
To do that, take the drive information revealed in the `dmesg` command above and type `mount | grep sda1`, which should show something like this: `/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Type `sudo umount /dev/sda1` to unmount your external hard drive.
5. Next, create a new mount point for the backup: `sudo mkdir /mnt/backup`
6. Now mount the drive to your backup folder location: `sudo mount /dev/sda1 /mnt/backup`
7. Now type `mount | grep sda1` again, and you should see something like this: `/dev/sda1 on /mnt/backup type ext2 (rw,relatime)`
8. Next create a directory that must exist for the backup to continue on the mounted drive. We are using a folder called "storage" for this example: `sudo mkdir /mnt/backup/storage`

Note that for a single machine, you will have to either repeat the `umount` and `mount` steps each time the drive is plugged in again, or each time the system reboots, or automate these commands with a script.

We recommend automation. Automation is the sysadmin way.

## Configuring rsnapshot

This is the most important step. It's easy to make a mistake when making changes to the configuration file. The _rsnapshot_ configuration requires tabs for any separation between elements, and a warning to that effect is at the very top of the configuration file.

A space character will cause the entire configuration—and your backup—to fail. For instance, near the top of the configuration file is a section for the `# SNAPSHOT ROOT DIRECTORY #`. If you were adding this in from scratch, you would type `snapshot_root` then TAB and then type `/whatever_the_path_to_the_snapshot_root_will_be/`

The best thing is that the default configuration that comes with _rsnapshot_ only needs minor changes to make it work for a backup of a local machine. It's always a good idea, though, to make a backup copy of the configuration file before you start editing:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## Basic Machine or Single Server Backup

In this case, _rsnapshot_ is going to be run locally to back up a particular machine. In this example, we'll break down the configuration file, and show you exactly what you need to change.

You will need to use `vi` (or edit with your favorite editor) to open the _/etc/rsnapshot.conf_ file.

The first thing to change is the _snapshot_root_ setting which by default has this value:

`snapshot_root   /.snapshots/`

We need to change this to our mount point that we created above plus the addition of "storage".

`snapshot_root   /mnt/backup/storage/`

We also want to tell the backup NOT to run if the drive is not mounted. To do this, remove the "#" sign (also called a remark, pound sign, number sign, hash symbol, etc.) next to `no_create_root` so that it looks like this:

`no_create_root 1`

Next go down to the section titled `# EXTERNAL PROGRAM DEPENDENCIES #` and remove the comment (again, the "#" sign) from this line:

`#cmd_cp         /usr/bin/cp`

So that it now reads:

`cmd_cp         /usr/bin/cp`

While we do not need `cmd_ssh` for this particular configuration, we will need it for our other option below and it doesn't hurt to have it enabled. So find the line that says:

`#cmd_ssh        /usr/bin/ssh`

And remove the "#" sign so that it looks like this:

`cmd_ssh        /usr/bin/ssh`

Next we need to skip down to the section titled `#     BACKUP LEVELS / INTERVALS         #`

This has been changed from earlier versions of _rsnapshot_ from `hourly, daily, monthly, yearly` to `alpha, beta, gamma, delta`. Which is a bit confusing. What you need to do is add a remark to any interval that you won't be using. In the configuration, delta is already remarked out.

For this example, we aren't going to be running any other increments other than a nightly backup, so just add a remark to alpha and gamma so that the configuration looks like this when you are done:

```
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Now skip down to the logfile line, which by default should read:

`#logfile        /var/log/rsnapshot`

And remove the remark so that it is enabled:

`logfile        /var/log/rsnapshot`

Finally, skip down to the `### BACKUP POINTS / SCRIPTS ###` section and add any directories that you want to add in the `# LOCALHOST` section, remember to use TAB rather than SPACE between elements!

For now write your changes (`SHIFT :wq!` for `vi`) and exit the configuration file.

### Checking The Configuration

We want to make sure that we didn't add spaces or any other glaring errors to our configuration file while we were editing it. To do this, we run _rsnapshot_ against our configuration with the `configtest` option:

`rsnapshot configtest` will show `Syntax OK` if there are no errors in the configuration.

You should get into the habit of running `configtest` against a particular configuration. The reason for that will be more evident when we get into the **Multiple Machine or Multiple Server Backups** section.

To run `configtest` against a particular configuration file, run it with the -c option to specify the configuration:

`rsnapshot -c /etc/rsnapshot.conf configtest`

## Running The Backup The First Time

Everything has checked out, so it's time to go ahead and run the backup for the first time. You can run this in test mode first if you like, so that you can see what the backup script is going to do.

Again, to do this you don't necessarily have to specify the configuration in this case, but you should get into the habit of doing so:

`rsnapshot -c /etc/rsnapshot.conf -t beta`

Which should return something like this, showing you what will happen when the backup is actually run:

```
echo 1441 > /var/run/rsnapshot.pid
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /mnt/backup/storage/beta.0/localhost/
touch /mnt/backup/storage/beta.0/
```

Once you are satisfied with the test, go ahead and run it manually the first time without the test:

`rsnapshot -c /etc/rsnapshot.conf beta`

When the backup finishes, navigate to /mnt/backup and take a look at the directory structure that was created there. There will be a `storage/beta.0/localhost` directory, followed by the directories that you specified to backup.

### Further Explanation

Each time the backup is run, it will create a new beta increment, 0-6, or 7 days worth of backups. The newest backup will always be beta.0 whereas yesterday's backup will always be beta.1.

The size of each of these backups will appear to take up the same amount (or more) of disk space, but this is because of _rsnapshot's_ use of hard links. To restore files from yesterday's backup, you would simply copy them back from beta.1's directory structure.

Each backup is only an incremental backup from the previous run, BUT, because of the use of hard links, each backup directory, contains either the file or the hard-link to the file in whichever directory it was actually backed up in.

So to restore files, you don't have to pick and choose which directory or increment to restore them from, just what time stamp the backup should have that you are restoring. It's a great system and uses far less disk space than many other backup solutions.

## Setting The Backup To Run Automatically

Once everything has been tested and we know that things will work without issue, the next step is to set up the crontab for the root user, so that all of this can be done automatically every day:

`sudo crontab -e`

If you haven't run this before, choose vim.basic as your editor or your own editor preference when the `Select an editor` line comes up.

We are going to set our backup to automatically run at 11 PM, so we will add this to the crontab:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Multiple Machine or Multiple Server Backups

Doing backups of multiple machines from a machine with a RAID array or large storage capacity, either on premises or from across the Internet works very well.

If running these backups from across the Internet, you need to make sure that both locations have adequate bandwidth for the backups to occur. You can use _rsnapshot_ to synchronize an on-site server with an off-site backup array or backup server to improve data redundancy.

## Assumptions

We are assuming that you are running _rsnapshot_ from a machine remotely, on-premise. This exact configuration can be duplicated, as indicated above, remotely off-premise as well.

In this case, you will want to install _rsnapshot_ on the machine that is doing all of the backups. We are also assuming:

* That the servers you will be backing up to, have a firewall rule that allows the remote machine to SSH into it
* That each server that you will be backing up has a recent version of `rsync` installed. For Rocky Linux servers, run `dnf install rsync` to update your system's version of `rsync`.
* That you've either connected to the machine as the root user, or that you have run `sudo -s` to switch to the root user.

## SSH Public / Private Keys

For the server that will be running the backups, we need to generate an SSH key-pair for use during the backups. For our example, we will be creating RSA keys.

If you already have a set of keys generated, you can skip this step. You can find out by doing an `ls -al .ssh` and looking for an `id_rsa` and `id_rsa.pub` key pair. If none exists, use the following link to set up keys for your machine and the server(s) that you want to access:

[SSH Public Private Key Pairs](../security/ssh_public_private_keys.md)

## _rsnapshot_ Configuration

The configuration file needs to be just like the one we created for the **Basic Machine or Single Server Backup** above, except that we want to change some of the options.

The snapshot root can be reverted back to the default like so:

`snapshot_root   /.snapshots/`

And this line:

`no_create_root 1`

... can be commented out again:

`#no_create_root 1`

The other difference here is that each machine will have its very own configuration. Once you get used to this, you'll simply copy one of your existing configuration files over to a new name and then modify it to fit any additional machines that you want to backup.

For now, we want to modify the configuration file just like we did above, and then save it. Then copy that file as a template for our first server:

`cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf`

We want to modify the new configuration file and create the log and lockfile with the machine's name:

`logfile /var/log/rsnapshot_web.log`

`lockfile        /var/run/rsnapshot_web.pid`

Next, we want to modify rsnapshot_web.conf so that it includes the directories we want to back up. The only thing that is different here is the target.

Here's an example of the web.ourdomain.com configuration:

```
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### Checking The Configuration and Running The Initial Backup

Just like before, we can now check the configuration to make sure it is syntactically correct:

`rsnapshot -c /etc/rsnapshot_web.conf configtest`

And just like before, we are looking for the `Syntax OK` message. If all is well, we can execute the backup manually:

`/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta`

Assuming that everything works alright, we can then create the configuration files for the mail server (rsnapshot_mail.conf) and portal server (rsnapshot_portal.conf), test them, and do a trial backup.

## Automating The Backup

Automating backups for the multiple machine/server version is slightly different. We want to create a bash script to call the backups in order. When one finishes the next will start. This script will look something like this and be stored in /usr/local/sbin:

`vi /usr/local/sbin/backup_all`

With the content:

```
#!/bin/bash/
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```
Then we make the script executable:

`chmod +x /usr/local/sbin/backup_all`

Then create the crontab for root to run the backup script:

`crontab -e`

And add this line:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Reporting The Backup Status

To make sure that everything is backing up according to plan, you might want to send the backup log files to your email. If your are running multiple machine backups using _rsnapshot_, each log file will have its own name, which you can then send to your email for review by [Using the postfix For Server Process Reporting](../email/postfix_reporting.md) procedure.

## Restoring a Backup

Restoring a backup, either a few files or a complete restore, involves copying the files you want from the directory with the date that you want to restore from back to your machine. Simple!

## Conclusions and Other Resources

Getting the setup right with _rsnapshot_ is a little daunting at first, but can save you loads of time backing up your machines or servers.

_rsnapshot_ is very powerful, very fast, and very economical on disk space usage. You can find more information on _rsnapshot_, by visiting [rsnapshot.org](https://rsnapshot.org/download.html)
