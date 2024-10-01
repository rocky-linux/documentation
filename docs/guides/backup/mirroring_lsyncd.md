---
title: Mirroring Solution - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - synchronization
  - mirroring
---

## Prerequisites

- A computer running Rocky Linux
- A comfort level with modifying configuration files from the command-line
- Knowledge of how to use a command line editor (using `vi` here, but use your favorite editor)
- You will need root access or `sudo` privileges (using `sudo -s` from the start is a good idea)
- Public and Private SSH key pairs
- The EPEL (Extra Packages for Enterprise Linux) repositories from Fedora
- You will need to be familiar with *inotify*, an event monitor interface
- Optional: familiarity with *tail*

## Introduction

If you are looking for a way to synchronize files and folders between computers automatically, `lsyncd` is a great option. But, you must configure everything from the command line.

It is a program worth learning for any system administrator.

The best description of `lsyncd`, comes from its own man page. Slightly paraphrased, `lsyncd` is a light-weight live mirror solution that is not hard to install. It does not  require new file systems or block devices, and does not hamper local file system performance. In short, it mirrors files.

`lsyncd` watches a local directory tree's event monitor interface (inotify). It aggregates and combines events for a few seconds, and spawns one (or more) process(es) to synchronize the changes. By default this is `rsync`.

For the purposes of this guide, you will call the system with the original files the "source", and the one that you are synchronizing to will be the "target". It is actually possible to completely mirror a server using `lsyncd` by carefully specifying directories and files that you want to synchronize.

For remote syncing, you will also want to set up [Rocky Linux SSH Public Private Key Pairs](../security/ssh_public_private_keys.md). The examples here use SSH (port 22).

## Installing `lsyncd`

Installing `lsyncd` happens in one of two ways. Included are descriptions of each method. The RPM tends to lag behind the source packages by a little, but only by a little. The version installed by the RPM method at the time of this writing is 2.2.3-5, whereas the source code version is now 2.3.1. Choose the method you feel the most comfortable with.

## Installing `lsyncd` - RPM method

Installing the RPM version is not hard. The only thing you will need to install first is the EPEL software repository from Fedora. Do this with:

```bash
dnf install -y epel-release
```

Now install `lsyncd` along with any missing dependencies:

```bash
dnf install lsyncd
```

Set up the service to start on boot, but do not start it just yet:

```bash
systemctl enable lsyncd
```

## Installing `lsyncd` - source method

Installing from the source is not difficult.

### Install dependencies

You will need some dependencies for `lsyncd` and for building packages from source. Use this command on your Rocky Linux computer to ensure you have the dependencies you need. If you are going to be building from source, it is a good idea to have all of the development tools installed:

```bash
dnf groupinstall 'Development Tools'
```

!!! warning "For Rocky Linux 9.0"

    `lsyncd` has been fully tested in Rocky Linux 9.0, and will work as expected. In order to get all of the needed dependencies installed, however, you will need to enable an additional repository:

    ```
    dnf config-manager --enable crb
    ```

    Doing this in 9 before the next steps will allow you to finish the build without backtracking.

Here are the dependencies needed for `lsyncd`:

```bash
dnf install lua lua-libs lua-devel cmake unzip wget rsync
```

### Download `lsyncd` and build

Next you need the source code:

```bash
wget https://github.com/axkibe/lsyncd/archive/master.zip
```

Decompress the `master.zip` file:

`unzip master.zip`

This will create a directory called "lsyncd-master". You need to change to this directory and create a directory called build:

```bash
cd lsyncd-master
```

Then:

```bash
mkdir build
```

Change directories to access the build directory:

```bash
cd build
```

Run these commands:

```bash
cmake ..
make
make install
```

When completed, you will have the `lsyncd` binary installed and ready for use in */usr/local/bin*

### `lsyncd` systemd service

With the RPM install method, the systemd service will install for you, but if you install from source, you will need to create the systemd service. While you can start the binary without the systemd service, you want to ensure that it *does* start on boot. If not, a server reboot will stop your synchronization effort. If you forgot to manually start it again, it would be a problem!

Creating the systemd service is not terribly difficult, and will save you time in the long run.

#### Create the `lsyncd` service file

Create this file anywhere, even in the root directory of your server. When created, you can move it to the right location.

```bash
vi /root/lsyncd.service`
```

The contents of this file will be:

```bash
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

Install the file you just made to the correct location:

```bash
install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service
```

Finally, reload the `systemctl` daemon so that systemd will "see" the new service file:

```bash
systemctl daemon-reload
```

## `lsyncd` configuration

With either `lsyncd` install method, you will need a configuration file: */etc/lsyncd.conf*. The next section will tell you how to build a configuration file, and test it.

### Sample configuration for testing

Here is an example of a simplistic configuration file that synchronizes */home* to another computer. Our target computer is going to be a local IP address: *192.168.1.40*

```bash
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

- The `logfile` and `statusFile` will be automatically created when the service starts
- The `statusInterval` is the number of seconds to wait before writing to the status file
- `maxProcesses` is the number of `lsyncd` processes allowed to spawn. Unless you are running this on a busy computer, 1 process is enough.
- In the sync section `default.rsyncssh` says to use `rsync` over SSH
- The `source=` is the directory path you are syncing from
- The `host=` is our target computer that you are syncing to
- The `excludeFrom=` tells `lsyncd` where the exclusions file is. It must exist, but can be empty.
- The `targetdir=` is the target directory you are sending files to. In most cases this will be equal to the source, but not always.
- The `rsync =` section, and the options that you are running `rsync` with
- The `ssh =` section, specifying the SSH port that is listening on the target computer

If you are adding more than one directory to sync, you need to repeat the entire "sync" section including all the opening and closing brackets for each directory.

## The lsyncd.exclude file

As noted earlier, the `excludeFrom` file must exist. Create that now:

```bash
touch /etc/lsyncd.exclude
```

As an example, if you were syncing the `/etc` folder on our computer there would be many files and directories that you want to exclude in the `lsyncd` process. Each excluded file or directory is in the file, one per line:

```bash
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test And turn Up

With everything set up, you can test it all. Ensure our systemd `lsyncd.service` will start:

```bash
systemctl start lsyncd
```

If no errors appear after executing this command, check the status of the service, just to ensure:

```bash
systemctl status lsyncd
```

If it shows the service running, use tail to see the ends of the two log files, and ensure everything shows up OK:

```bash
tail /var/log/lsyncd.log
tail /var/log/lsyncd-status.log
```

Assuming that this all looks correct, navigate to the `/home/[user]` directory, where `[user]` is a user on the computer and create a file there with *touch*.

```bash
touch /home/[user]/testfile
```

Go to the target computer and see if the file shows up. If so, everything is working. Set the `lsyncd.service` to start on boot with:

```bash
systemctl enable lsyncd
```

## Remember to be careful

Anytime you are synchronizing a set of files or directories to another computer, think carefully about the effect it will have on the target computer. If you go back to **The lsyncd.exclude File** in our example above, can you imagine what might happen if you failed to exclude */etc/fstab*?

`fstab` is the file used to configure storage drives on any Linux computer. The disks and labels are almost certainly different on different machines. The next reboot of the target computer would likely fail entirely.

## Conclusions and references

`lsyncd` is a powerful tool for directory synchronization between computers. As you have seen, it is not hard to install, and it is not complex to maintain going forward.

You can find out more about `lsyncd` by going to [The Official Site](https://github.com/axkibe/lsyncd)
