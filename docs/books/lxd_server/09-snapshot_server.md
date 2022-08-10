---
title: 9 Snapshot Server
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd snapshot server
---

# Chapter 9: Snapshot Server

This chapter uses a combination of the privileged (root) user, and the unprivileged (lxdadmin) user, based on the tasks we are executing.

As noted at the beginning, the snapshot server for LXD should be a mirror of the production server in every way possible. The reason is that you may need to take it to production in the event of a hardware failure, and having not only backups, but a quick way to bring up production containers, keeps those systems administrator panic phone calls and text messages to a minimum. THAT is ALWAYS good!

So the process of building the snapshot server is exactly like the production server. To fully emulate our production server set up, do all of **Chapters 1-4** again on the snapshot server, and when completed, return to this spot.

You're back!! Congratulations, this must mean that you have successfully completed the basic install for the snapshot server. That's great news!!

## Setting Up The Primary and Snapshot Server Relationship

We've got some housekeeping to do before we continue. First, if you are running in a production environment, you probably have access to a DNS server that you can use for setting up IP to name resolution.

In our lab, we don't have that luxury. Perhaps you've got the same scenario running. For this reason, we are going to add both servers IP addresses and names to the /etc/hosts file on BOTH the primary and the snapshot server. You'll need to do this as your root (or _sudo_) user.

In our lab, the primary LXD server is running on 192.168.1.106 and the snapshot LXD server is running on 192.168.1.141. We will SSH into both servers and add the following to the /etc/hosts file:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```

Next, we need to allow all traffic between the two servers. To do this, we are going to modify the /etc/firewall.conf file with the following. First, on the lxd-primary server, add this line:

### Iptables - (Use the `firewalld` procedure if possible)

```
IPTABLES -A INPUT -s 192.168.1.141 -j ACCEPT
```

And on the lxd-snapshot server, add this line:

```
IPTABLES -A INPUT -s 192.168.1.106 -j ACCEPT
```

This allows bi-directional traffic of all types to travel between the two servers.

### Firewalld

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

## Setting Up The Primary and Snapshot Server Relationship (continued)

Next, as our unprivileged (lxdadmin) user, we need to set the trust relationship between the two machines. This is done by executing the following on lxd-primary:

```
lxc remote add lxd-snapshot
```

This will display the certificate to accept, so do that, and then it will prompt for your password. This is the "trust password" that you set up when doing the LXD initialization step. Hopefully, you are securely keeping track of all of these passwords. Once you
 enter the password, you should receive this:

```
Client certificate stored at server:  lxd-snapshot
```

It does not hurt to have this done in reverse as well. In other words, set the trust relationship on the lxd-snapshot server so that, if needed, snapshots can be sent back to the lxd-primary server. Simply repeat the steps and substitute in "lxd-primary" for "lxd-snapshot."

### Migrating Our First Snapshot

Before we can migrate our first snapshot, we need to have any profiles created on lxd-snapshot that we have created on the lxd-primary. In our case, this is the "macvlan" profile.

You'll need to create this for lxd-snapshot, so go back to [Chapter 6](06-profiles.md) and create the "macvlan" profile on lxd-snapshot. If your two servers have identical parent interface names ("enp3s0" for example) then you can copy the "macvlan" profile over to lxd-snapshot without recreating it:

```
lxc profile copy macvlan lxd-snapshot
```

Now that we have all of the relationships and profiles set up, the next step is to actually send a snapshot from lxd-primary over to lxd-snapshot. If you've been following along exactly, you've probably deleted all of your snapshots, so let's create a new one:

```
lxc snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

If you run the "info" sub-command for lxc, you can see the new snapshot on the bottom of our listing:

```
lxc info rockylinux-test-9
```

Which will show something like this at the bottom:

```
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

OK, fingers crossed! Let's try to migrate our snapshot:

```
lxc copy rockylinux-test-9/rockylinux-test-9-snap1 lxd-snapshot:rockylinux-test-9
```

What this command says is, that within the container rockylinux-test-9, we want to send the snapshot, rockylinux-test-9-snap1 over to lxd-snapshot and copy it as rockylinux-test-9.

After a short period of time has expired, the copy will be complete. Want to find out for sure?  Do an "lxc list" on the lxd-snapshot server. Which should return the following:

```
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Success! Now let's try starting it. Because we are starting it on the lxd-snapshot server, we need to stop it first on the lxd-primary server to avoid an IP address conflict:

```
lxc stop rockylinux-test-9
```

And on the lxd-snapshot server:

```
lxc start rockylinux-test-9
```

Assuming all of this works without error, stop the container on lxd-snapshot and start it again on lxd-primary.

## Setting boot.autostart To Off For Containers

The snapshots copied to lxd-snapshot will be down when they are migrated, but if you have a power event or need to reboot the snapshot server because of updates or something, you will end up with a problem as those containers will attempt to start on the snapshot server.

To eliminate this, we need to set the migrated containers so that they will not start on reboot of the server. For our newly copied rockylinux-test-9 container, this is done with the following:

```
lxc config set rockylinux-test-9 boot.autostart 0
```

Do this for each snapshot on the lxd-snapshot server.

## Automating The Snapshot Process

Ok, so it's great that you can create snapshots when you need to, and sometimes you _do_ need to manually create a snapshot. You might even want to manually copy it over to lxd-snapshot. BUT, once you've got things going and you've got 25 to 30 containers or more running on your lxd-primary machine, the very last thing you want to do is spend an afternoon deleting snapshots on the snapshot server, creating new snapshots and sending them over.

The first thing we need to do is schedule a process to automate snapshot creation on lxd-primary. This has to be done for each container on the lxd-primary server, but once it is set up, it will take care of itself. This is done with the following syntax. Note the similarities to a crontab entry for the timestamp:

```
lxc config set [container_name] snapshots.schedule "50 20 * * *"
```

What this is saying is, do a snapshot of the container name every day at 8:50 PM.

To apply this to our rockylinux-test-9 container:

```
lxc config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

We also want to set up the name of the snapshot to be meaningful by our date. LXD uses UTC everywhere, so our best bet to keep track of things, is to set the snapshot name with a date/time stamp that is in a more understandable format:

```
lxc config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

GREAT, but we certainly don't want a new snapshot every day without getting rid of an old one, right?  We'd fill up the drive with snapshots. So next we run:

```
lxc config set rockylinux-test-9 snapshots.expiry 1d
```
