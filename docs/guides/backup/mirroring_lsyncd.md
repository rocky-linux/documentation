---
title: Mirroring Solution - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - synchronization
  - mirroring
---
# Mirroring Solution - `lsyncd`

## Prerequisites

This is everything you'll need to understand and follow along with this guide:

* A computer running Rocky Linux
* A comfort level with modifying configuration files from the command-line
* Knowledge of how to use a command line editor (we use vi here, but you could use your favorite editor)
* You will need root access, and ideally be signed in as the root user in your terminal
* Public and Private SSH key pairs
* The EPEL repositories from Fedora
* You will need to be familiar with *inotify*, an event monitor interface
* Optional: familiarity with *tail*

## Introduction

If you're looking for a way to synchronize files and folders between computers automatically, `lsyncd` is a pretty great option. The only downside for beginners? You have to configure everything at the command line, and text files.

Even so, it is a program worth learning for any sysadmin.

The best description of `lsyncd`, comes from its own man page. Slightly paraphrased, `lsyncd` is a light-weight live mirror solution that is not hard to install. It does not  require new filesystems or block devices, and does not hamper local filesystem performance. In short, it mirrors files.

`lsyncd` watches a local directory tree's event monitor interface (inotify). It aggregates and combines events for a few seconds, and then spawns one (or more) process(es) to synchronize the changes. By default this is `rsync`.

For the purposes of this guide, you will call the system with the original files the "source", and the one that we are synchronizing to will be the "target". It is actually possible to completely mirror a server using `lsyncd` by very carefully specifying directories and files that you want to synchronize. It's pretty sweet!

For remote syncing, you will also want to set up [Rocky Linux SSH Public Private Key Pairs](../security/ssh_public_private_keys.md). The examples here use SSH (port 22).

## Installing `lsyncd`

There are actually two ways to install `lsyncd`. We will include them both here. The RPM tends to lag behind the source packages by a little, but only by a little. The version installed by the RPM method at the time of this writing is 2.2.2-9, whereas the source code version is now 2.2.3. That said, we want to give you both options and let you choose.

## Installing `lsyncd` - RPM Method

Installing the RPM version is not hard. The only thing you will need to install first is the EPEL software repository from Fedora. This can be done with a single command:

`dnf install -y epel-release`

Then, we just need to install `lsyncd` and any missing dependencies will be installed along with it:

`dnf install lsyncd`

Set up the service to start on boot, but don't start it just yet:

`systemctl enable lsyncd`

That's it!

## Installing `lsyncd` - Source Method

Installing from the source is not as bad as it sounds. Just follow this guide and you will be up and running in no time!

### Install Dependencies

We will need some dependencies: a few that are required by `lsyncd` itself, and a few that are required to build packages from source. Use this command on your Rocky Linux computer to ensure you have the dependencies you need. If you are going to be building from source, it is a good idea to have all of the development tools installed:

`dnf groupinstall 'Development Tools'`

!!! warning "For Rocky Linux 9.0"

    `lsyncd` has been fully tested in Rocky Linux 9.0, and will work as expected. In order to get all of the needed dependencies installed, however, you will need to enable an additional repository:

    ```
    dnf config-manager --enable crb
    ```

    Doing this in 9 before the next steps, will allow you to finish the build without backtracking.

And here are the dependencies we need for `lsyncd` itself, and its build process:

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### Download `lsyncd` And Build It

Next we need the source code:

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

Now uncompress the master.zip file:

`unzip master.zip`

This will create a directory called "lsyncd-master". We need to change to this directory and create a directory called build:

`cd lsyncd-master`

And then:

`mkdir build`

Now change directories again so that you are in the build directory:

`cd build`

Now run these commands:

```
cmake ..
make
make install
```

When done, you will have the `lsyncd` binary installed and ready for use in */usr/local/bin*

### `lsyncd` Systemd Service

With the RPM install method, the systemd service will be installed for you, but if you choose to install from source, you will need to create the systemd service. While you can start the binary without the systemd service, we want to ensure that it *does* start on boot. If not, a server reboot would stop your synchronization effort. If you forgot to start it again, which is highly likely, that would be a problem for any systems administrator!

Creating the systemd service is not terribly difficult, though, and will save you time in the long run.

#### Create The `lsyncd` Service File

This file can be created anywhere, even in the root directory of your server. When created, you can move it to the right location.

`vi /root/lsyncd.service`

The contents of this file should be:

```
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```
Now let's install the file you just made to the correct location:

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

Finally, reload the `systemctl` daemon so that systemd will "see" the new service file:

`systemctl daemon-reload`

## `lsyncd` Configuration

Whichever method you choose for installing `lsyncd`, you will need a configuration file: */etc/lsyncd.conf*. The next section will tell you how to build a configuration file, and test it.

## Sample Configuration For Testing

Here's an example of a simplistic configuration file that synchronizes */home* to another computer. Our target computer is going to be a local IP address: *192.168.1.40*

```
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home",
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Breaking down this file a bit:

* The "logfile" and "statusFile" will be automatically created when the service starts.
* The "statusInterval" is the number of seconds to wait before writing to the statusFile.
* "maxProcesses" is the number of processes `lsyncd` is allowed to spawn. Honestly, unless you are running this on a super busy computer, 1 process is enough.
* In the sync section "default.rsyncssh" says to use rsync over SSH
* The "source=" is the directory path we are syncing from.
* The "host=" is our target computer that we are syncing to.
* The "excludeFrom=" tells `lsyncd` where the exclusions file is. It must exist, but can be empty.
* The "targetdir=" is the target directory we are sending files to. In most cases this will be equal to the source, but not always.
* Then we have the "rsync =" section, and these are the options that we are running rsync with.
* Finally we have the "ssh =" section, and this specifies the SSH port that is listening on the target computer.

If you are adding more than one directory to sync, then you need to repeat the entire "sync" section including all the opening and closing brackets for each directory.

## The lsyncd.exclude File

As noted earlier, the "excludeFrom" file must exist, so let's create that now:

`touch /etc/lsyncd.exclude`

If you were syncing the /etc folder on our computer, there would be many files and directories that you should exclude. Each excluded file or directory is listed in the file, one per line, like this:

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test And Turn Up

Now that everything else is set up, you can test it all. For starters, lets ensure our systemd lsyncd.service will start:

`systemctl start lsyncd`

If no errors appear after executing this command, check the status of the service, just to ensure:

`systemctl status lsyncd`

If it shows the service running, use tail to see the ends of the two log files, and ensure everything shows up OK:

`tail /var/log/lsyncd.log`

And then:

`tail /var/log/lsyncd-status.log`

Assuming that this all looks correct, navigate to the `/home/[user]` directory, where `[user]` is a user on the computer and create a new file there with *touch*.

`touch /home/[user]/testfile`

Now go to the target computer and see if the file shows up. If so, everything is working as it should. Set the lsyncd.service to start on boot with:

`systemctl enable lsyncd`

And you are ready to go.

## Remember To Be Careful

Anytime you are synchronizing a set of files or directories to another computer, think carefully about the effect it will have on the target computer. If you go back to **The lsyncd.exclude File** in our example above, can you imagine what might happen if */etc/fstab* is synchronized?

For newbies, *fstab* is the file that is used to configure storage drives on any Linux computer. The disks and labels are almost certainly different. The next time the target computer was rebooted it would likely fail to boot entirely.

# Conclusions And References

`lsyncd` is a powerful tool for directory synchronization between computers. As you've seen, it is not hard to install, and it is not complex to maintain going forward. You can not ask for more than that.

You can find out more about `lsyncd` by going to [The Official Site](https://github.com/axkibe/lsyncd)
