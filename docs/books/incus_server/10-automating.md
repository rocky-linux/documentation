---
title: 10 Automating Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus automation
---

Throughout this chapter you will need to be root or able to `sudo` to become root.

Automating the snapshot process makes things a whole lot easier.

## Automating the snapshot copy process

Perform this process on incus-primary. First thing you need to do is create a script that will run by a cron in /usr/local/sbin called "refresh-containers" :

```bash
sudo vi /usr/local/sbin/refreshcontainers.sh
```

The script is pretty minimal:

```bash
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x incus-snapshot:$x
        done

```

 Make it executable:

```bash
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Change the ownership of this script to your incusadmin user and group:

```bash
sudo chown incusadmin.incusadmin /usr/local/sbin/refreshcontainers.sh
```

Set up the crontab for the incusadmin user to run this script, in this case at 10 PM:

```bash
crontab -e
```

Your entry will look like this:

```bash
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/incusadmin/refreshlog 2>&1
```

Save your changes and exit.

This will create a log in incusadmin's home directory called "refreshlog" which will give you knowledge of whether your process worked or not. Very important!

The automated procedure will fail sometimes. This generally happens when a particular container fails to refresh. You can manually re-run the refresh with the following command (assuming rockylinux-test-9 here, is our container):

```bash
lxc copy --refresh rockylinux-test-9 incus-snapshot:rockylinux-test-9
```
