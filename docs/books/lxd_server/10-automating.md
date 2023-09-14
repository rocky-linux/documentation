---
title: 10 Automating Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd automation
---

# Chapter 10: automating snapshots

Throughout this chapter you will need to be root or able to `sudo` to become root.

Automating the snapshot process makes things a whole lot easier. 

## Automating the snapshot copy process


Perform this process on lxd-primary. First thing you need to do is create a script that will run by a cron in /usr/local/sbin called "refresh-containers" :

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

The script is pretty minimal:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Make it executable:

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Change the ownership of this script to your lxdadmin user and group:

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

Set up the crontab for the lxdadmin user to run this script, in this case at 10 PM:

```
crontab -e
```

Your entry will look like this:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

Save your changes and exit.

This will create a log in lxdadmin's home directory called "refreshlog" which will give you knowledge of whether your process worked or not. Very important!

The automated procedure will fail sometimes. This generally happens when a particular container fails to refresh. You can manually re-run the refresh with the following command (assuming rockylinux-test-9 here, is our container):

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
