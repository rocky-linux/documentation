# Rocky Linux - Mirroring Solution - Lsyncd

# Introduction

Lsyncd watches a local directory trees event monitor interface (inotify). It aggregates and combines events for a few seconds and then spawns one (or more) process(es) to synchronize the changes. By default this is rsync. Lsyncd is thus a light-weight live mirror solution that is comparatively easy to install not requiring new filesystems or blockdevices and does not hamper local filesystem performance. That is from the man page for lsyncd and is the best description for what lsyncd is. 

Let's say you have two Rocky Linux servers or workstations, and you want to keep some directories in sync. We will call the system that we normally update, the master, and the one that we are synchronizing to, the slave. It is actually possible to completely mirror a server using lsyncd by very carefully specifying directories and files that you want to synchronize. It's pretty sweet!

For remote syncing, you will also want to setup [Rocky Linux SSH Public Private Key Pairs](RL_ssh_public_private_keys.md). The examples here use SSH (port 22).

## Prerequisites

* Machine running Rocky Linux for install
* A comfort level with modifying configuration files from the command-line
* Know how to use a command line editor (we use vi here, but you could use your favorite editor)
* You will either have to be root or sudo -s

# Installing Lsyncd

There are actually two ways to install lsyncd. We will include them both here, but the preferred method is to install from source. It's relatively easy to do this and there are few dependencies required.  The RPM tends to lag behind the source packages by a little. That said, we want to give you both options and let you choose. 

## Installing Lsyncd - RPM Method

Installing the RPM version is relatively easy. The only thing you will need to install first is the EPEL from Fedora. This can be done with this command:

`dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

To install lsyncd, then, we just need to install it and any missing dependencies will be installed along with it:

`dnf install lsyncd`

That's it!

## Installing Lsyncd - Source Method

Installing from source is not as bad is it sounds. Just follow this guide and you will be up and running in no time!

### Install Dependencies

We will need some dependencies. A few that are required by lsyncd and a few that are required to build from source. Use this command on your Rocky Linux machine to make sure you have the dependencies. If you are going to be building from source, it's a good idea to have all of the development tools installed:

`dnf install groupinstall 'Development Tools'`

and we still need some additional dependencies:

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### Download Lsyncd And Build It

Next we need the source:

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

Now unzip the master.zip file:

`unzip master.zip`

which will create a directory called "lsyncd-master". We need to change to this directory and create a directory called build:

`cd lsyncd-master`

and

`mkdir build`

Now change directories again so that you are in the build directory:

`cd build`

And then execute these commands:

```
cmake ..
make
make install
```

When done, you should have the lsyncd binary installed and ready for use in /usr/local/bin

# Lsyncd Systemd Service

Neither install method will create a systemd service for starting. We want to be able to set this to start on a reboot, because if you are doing mirroring, you don't want the mirror to be offline because you forgot to manually start a service. That's very embarrassing! Creating the systemd service is not terribly difficult. 

## Create The Lsyncd Service File

This file can be created anywhere, even in the root directory of your server, and once it is created, we will install it to the correct location. 

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
Now lets install it in the correct location:

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

Finally, reload the systemctl daemon so that systemd will "see" the new service file:

`systemctl daemon-reload`

# Lsyncd Configuration

Whichever method you choose to do the install, you will need a configuration file, /etc/lsyncd.conf. The next section deals with building a simple configuration file and testing it. 

## Sample Configuration For Testing

Here's an example of a simple configuration file that synchronizes /home to another machine. Our target machine is going to be 192.168.1.40 here:

```
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20
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

* the "logfile" and "statusFile" will be auto created when the service starts.
* the "statusInterval" is the number of seconds to wait before writing to the statusFile.
* "maxProcesses" is the number of processes lsyncd is allowed to spawn. Honestly, unless you are running this on a super busy machine, 1 process is enough.
* In the sync section "default.rsyncssh" says to use rsync over ssh
* the "source=" is the directory path we are syncing from
* the "host=" is our target machine that we are syncing to
* the "excludeFrom=" tells lsyncd where the eclusions file is. It must exist, but can be empty.
* the "targetdir=" is the target directory we are sending to. In most cases this will be equal to the source, but not always.
* then we have the "rsync =" section and these are the options that we are running rsync with
* finally we have the "ssh =" section and this specifies the SSH port that is listening on the target machine.

If we were adding one or more directories to sync, then you need to include the entire "sync" section including all the opening and closing brackets for each directory.

## The lsyncd.exclude File

As noted earlier, the "excludeFrom" file must exist, so let's create that now:

`touch /etc/lsyncd.exclude`

If we were syncing the /etc folder on our machine, there would be a number of files and/or directories that we should leave out. Each excluded file or directory is simply listed in the file, one per line, like this:

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test And Turn Up

Now that everything else is setup, we can now test. For starters, lets make sure our systemd lsyncd.service will start:

`systemctl start lsyncd`

If no errors appear after executing this command, check the status of the service, just to make sure:

`systemctl status lsyncd`

If it shows the service running, tail the two log files and make sure it shows everything OK:

`tail /var/log/lsyncd.log`

and

`tail /var/log/lsyncd-status.log`

Assuming that this all looks correct navigate to the `/home/[user]` directory, where `[user]` is a user on the machine and touch a new file there.

`touch /home/[user]/testfile`

Now go to the target machine and see if the file shows up. If so, everything is working as it should. Set the lsyncd.service to start on boot with:

`systemctl enable lsyncd`

And you should be ready to go.

## Remember To Be Careful

Anytime you are synchronizing a set of files or directories to another machine, think carefully about the effect it will have on the target machine. If you go back to ** The lsyncd.exclude File ** in our example above, can you imagine what might happen if /etc/fstab is synchronized?  The disks and labels are almost certainly different. The next time the target machine was rebooted it would fail. 

# Conclusions And References

Lsyncd is another powerful tool for directory synchronization between machines. It is a tool that is easy to install and once configured the first time, is easy to maintain going forward. 

You can find more about lsyncd by going to [The Official Site](https://github.com/axkibe/lsyncd)

