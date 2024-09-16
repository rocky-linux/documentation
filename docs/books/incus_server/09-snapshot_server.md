---
title: 9 Snapshot Server
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus 
  - enterprise
  - incus snapshot server
---

This chapter uses a combination of the privileged (root) user and the unprivileged (incusadmin) user based on the tasks you are executing.

As noted at the beginning, the Incus snapshot server must mirror the production server in every way possible. You might need to take it to production if the hardware fails on your primary server, and having backups and a quick way to restart production containers keeps those system administrators' panic telephone calls and text messages to a minimum. That is ALWAYS good!

The process of building the snapshot server is precisely like that of the production server. To fully emulate your production server setup, repeat Chapters 1-4 on the snapshot server, and when completed, return to this spot.

If you are here, you have completed the basic installation for the snapshot server.

## Setting up the primary and snapshot server relationship

You need some housekeeping before continuing. First, if you are running in a production environment, you probably have access to a DNS server to set up IP to name resolution.

In your lab, you do not have that luxury. Perhaps you have the same scenario running. For this reason, you will add both the server's IP addresses and names to the `/etc/hosts` file on the primary and the snapshot server. You must do this as your root (or _sudo_) user.

In your lab, the primary Incus server is running on 192.168.1.106, and the snapshot Incus server is running on 192.168.1.141. SSH into each server and add the following to the `/etc/hosts` file:

```bash
192.168.1.106 incus-primary
192.168.1.141 incus-snapshot
```

Next, you need to allow all traffic between the two servers. To do this, you will change the `firewalld` rules. First, on the incus-primary server, add this line:

```bash
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

And on the snapshot server, add this rule:

```bash
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

Then reload:

```bash
firewall-cmd reload
```

Next, as your unprivileged (incusadmin) user, you must establish a trusting relationship between the two machines. This is done by running the following on incus-primary:

```bash
incus remote add incus-snapshot
```

This displays the certificate to accept. Accept it, and it will prompt for your password. This is the "trust password" you set up during the Incus initialization step. I hope you are keeping track of all of these passwords. When you enter the password, you will receive this:

```bash
Client certificate stored at server:  incus-snapshot
```

It does not hurt to have this in reverse, either. For example, the trust relationship can also be set on the incus-snapshot server. If needed, the incus-snapshot server can send snapshots back to the incus-primary server. Repeat the steps and substitute "incus-primary" for "incus-snapshot."

### Migrating your first snapshot

Before migrating your first snapshot, you must create any profiles on the incus-snapshot you have made on the incus-primary. In this case, it is the "macvlan" profile.

You will need to create this for incus-snapshot. Go back to [Chapter 6](06-profiles.md) and create the "macvlan" profile on incus-snapshot if you need to. If your two servers have the same parent interface names ("enp3s0" for example), then you can copy the "macvlan" profile over to incus-snapshot without recreating it:

```bash
incus profile copy macvlan incus-snapshot
```

With all of the relationships and profiles set up, the next step is sending a snapshot from incus-primary over to incus-snapshot. If you have followed along exactly, you have probably deleted all your snapshots. Create another snapshot:

```bash
incus snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

If you run the "info" command for `incus`, you can see the snapshot at the bottom of your listing:

```bash
incus info rockylinux-test-9
```

Which will show something like this at the bottom:

```bash
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

Try to migrate your snapshot:

```bash
incus copy rockylinux-test-9/rockylinux-test-9-snap1 incus-snapshot:rockylinux-test-9
```

This command says that within the container rockylinux-test-9, you want to send the snapshot rockylinux-test-9-snap1 over to incus-snapshot and name it rockylinux-test-9.

After a short time, the copy will be complete. Want to find out for sure? Do an `incus list` on the incus-snapshot server. Which should return the following:

```bash
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Success! Try starting it. Because you are starting it on the incus-snapshot server, you need to stop it first on the incus-primary server to avoid an IP address conflict:

```bash
incus stop rockylinux-test-9
```

And on the incus-snapshot server:

```bash
incus start rockylinux-test-9
```

Assuming all this works without error, stop the container on incus-snapshot and start it again on incus-primary.

## Setting `boot.autostart` to off for containers

The snapshots copied to incus-snapshot will be down when they migrate, but if you have a power event or need to reboot the snapshot server because of updates or something, you will have a problem. Those containers will try to start on the snapshot server, creating a potential IP address conflict.

To eliminate this, you need to set the migrated containers so that they will not start on a server reboot. For your newly copied rockylinux-test-9 container, you will do this with the following:

```bash
incus config set rockylinux-test-9 boot.autostart 0
```

Do this for each snapshot on the incus-snapshot server. The "0" in the command will ensure that `boot.autostart` is off.

## Automating the snapshot process

It is excellent that you can create snapshots when needed, and sometimes you _do_ need to create a snapshot manually. You might even want to copy it over to incus-snapshot manually. But for all the other times, particularly for many containers running on your incus-primary server, the **last** thing you want to do is spend an afternoon deleting snapshots on the snapshot server, creating new snapshots, and sending them over to the snapshot server. For the bulk of your operations, you will want to automate the process.

You'll need to schedule a process to automate snapshot creation on incus-primary. You will do this for each container on the incus-primary server. When completed, it will take care of this going forward. You do this with the following syntax. Note the similarities to a crontab entry for the timestamp:

```bash
incus config set [container_name] snapshots.schedule "50 20 * * *"
```

This is saying: do a snapshot of the container name every day at 8:50 PM.

To apply this to your rockylinux-test-9 container:

```bash
incus config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

You also want to set up the name of the snapshot to be meaningful by your date. Incus uses UTC everywhere, so your best bet to keep track of things is to set the snapshot name with a date and time stamp that is in a more understandable format:

```bash
incus config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

GREAT, but you certainly do not want a new snapshot every day without getting rid of an old one. You would fill up the drive with snapshots. To fix this, run the following:

```bash
incus config set rockylinux-test-9 snapshots.expiry 1d
```
