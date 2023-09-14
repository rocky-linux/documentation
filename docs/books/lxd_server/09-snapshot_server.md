---
title: 9 Snapshot Server
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd snapshot server
---

# Chapter 9: snapshot server

This chapter uses a combination of the privileged (root) user, and the unprivileged (lxdadmin) user, based on the tasks you are executing.

As noted at the beginning, the snapshot server for LXD must be a mirror of the production server in every way possible. The reason is that you might need to take it to production if the hardware fails on your primary server, and having backups, and a quick way to restart production containers, keeps those system administrator panic telephone calls and text messages to a minimum. THAT is ALWAYS good!

The process of building the snapshot server is exactly like the production server. To fully emulate our production server set up, do all of **Chapters 1-4** again on the snapshot server, and when completed, return to this spot.

You are back!! Congratulations, this must mean that you have successfully completed the basic installation for the snapshot server. 

## Setting up the primary and snapshot server relationship

Some housekeeping is necessary before continuing. First, if you are running in a production environment, you probably have access to a DNS server that you can use for setting up IP to name resolution.

In our lab, we do not have that luxury. Perhaps you've got the same scenario running. For this reason, you are going to add both servers IP addresses and names to the /etc/hosts file on the primary and the snapshot server. You'll need to do this as your root (or _sudo_) user.

In our lab, the primary LXD server is running on 192.168.1.106 and the snapshot LXD server is running on 192.168.1.141. SSH into each server and add the following to the /etc/hosts file:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```

Next, you need to allow all traffic between the two servers. To do this, you are going to change the `firewalld` rules. First, on the lxd-primary server, add this line:

```
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

and on the snapshot server, add this rule:

```
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

then reload:

```
firewall-cmd reload
```

Next, as our unprivileged (lxdadmin) user, you need to set the trust relationship between the two machines. This is done by running the following on lxd-primary:

```
lxc remote add lxd-snapshot
```

This displays the certificate to accept. Accept it, and it will prompt for your password. This is the "trust password" that you set up when doing the LXD initialization step. Hopefully, you are securely keeping track of all of these passwords. When you enter the password, you will receive this:

```
Client certificate stored at server:  lxd-snapshot
```

It does not hurt to have this in reverse also. For example, set the trust relationship on the lxd-snapshot server too. That way, if needed, the lxd-snapshot server can send snapshots back to the lxd-primary server. Repeat the steps and substitute in "lxd-primary" for "lxd-snapshot."

### Migrating your first snapshot

Before you can migrate your first snapshot, you need to have any profiles created on lxd-snapshot that you have created on the lxd-primary. In our case, this is the "macvlan" profile.

You will need to create this for lxd-snapshot. Go back to [Chapter 6](06-profiles.md) and create the "macvlan" profile on lxd-snapshot if you need to. If your two servers have the same parent interface names ("enp3s0" for example) then you can copy the "macvlan" profile over to lxd-snapshot without recreating it:

```
lxc profile copy macvlan lxd-snapshot
```

With all of the relationships and profiles set up, the next step is to actually send a snapshot from lxd-primary over to lxd-snapshot. If you have been following along exactly, you have probably deleted all of your snapshots. Create another snapshot:

```
lxc snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

If you run the "info" command for `lxc`, you can see the snapshot at the bottom of our listing:

```
lxc info rockylinux-test-9
```

Which will show something like this at the bottom:

```
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

OK, fingers crossed! Let us try to migrate our snapshot:

```
lxc copy rockylinux-test-9/rockylinux-test-9-snap1 lxd-snapshot:rockylinux-test-9
```

This command says, within the container rockylinux-test-9, you want to send the snapshot, rockylinux-test-9-snap1 over to lxd-snapshot and name it rockylinux-test-9.

After a short time, the copy will be complete. Want to find out for sure? Do an `lxc list` on the lxd-snapshot server. Which should return the following:

```
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Success! Try starting it. Because we are starting it on the lxd-snapshot server, you need to stop it first on the lxd-primary server to avoid an IP address conflict:

```
lxc stop rockylinux-test-9
```

And on the lxd-snapshot server:

```
lxc start rockylinux-test-9
```

Assuming all of this works without error, stop the container on lxd-snapshot and start it again on lxd-primary.

## Setting boot.autostart to off for containers

The snapshots copied to lxd-snapshot will be down when they migrate, but if you have a power event or need to reboot the snapshot server because of updates or something, you will end up with a problem. Those containers will try to start on the snapshot server creating a potential IP address conflict.

To eliminate this, you need to set the migrated containers so that they will not start on reboot of the server. For our newly copied rockylinux-test-9 container, you will do this with: 

```
lxc config set rockylinux-test-9 boot.autostart 0
```

Do this for each snapshot on the lxd-snapshot server. The "0" in the command will make sure that `boot.autostart` is off.

## Automating the snapshot process

It is great that you can create snapshots when you need to, and sometimes you _do_ need to manually create a snapshot. You might even want to manually copy it over to lxd-snapshot. But for all the other times, particularly for many containers running on your lxd-primary server, the **last** thing you want to do is spend an afternoon deleting snapshots on the snapshot server, creating new snapshots and sending them over to the snapshot server. For the bulk of your operations, you will want to automate the process.

The first thing you need to do is schedule a process to automate snapshot creation on lxd-primary. You will do this for each container on the lxd-primary server. When completed, it will take care of this going forward. You do this with the following syntax. Note the similarities to a crontab entry for the timestamp:

```
lxc config set [container_name] snapshots.schedule "50 20 * * *"
```

What this is saying is, do a snapshot of the container name every day at 8:50 PM.

To apply this to our rockylinux-test-9 container:

```
lxc config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

You also want to set up the name of the snapshot to be meaningful by our date. LXD uses UTC everywhere, so our best bet to keep track of things, is to set the snapshot name with a date and time stamp that is in a more understandable format:

```
lxc config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

GREAT, but you certainly do not want a new snapshot every day without getting rid of an old one, right? You would fill up the drive with snapshots. To fix this you run:

```
lxc config set rockylinux-test-9 snapshots.expiry 1d
```
