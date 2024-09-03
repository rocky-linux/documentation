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

This chapter uses a combination of the privileged (root) user, and the unprivileged (incusadmin) user, based on the tasks you are executing.

As noted at the beginning, the snapshot server for Incus must be a mirror of the production server in every way possible. The reason is that you might need to take it to production if the hardware fails on your primary server, and having backups, and a quick way to restart production containers, keeps those system administrator panic telephone calls and text messages to a minimum. THAT is ALWAYS good!

The process of building the snapshot server is exactly like the production server. To fully emulate our production server set up, do all of **Chapters 1-4** again on the snapshot server, and when completed, return to this spot.

You are back!! Congratulations, this must mean that you have successfully completed the basic installation for the snapshot server.

## Setting up the primary and snapshot server relationship

Some housekeeping is necessary before continuing. First, if you are running in a production environment, you probably have access to a DNS server that you can use for setting up IP to name resolution.

In our lab, we do not have that luxury. Perhaps you've got the same scenario running. For this reason, you are going to add both servers IP addresses and names to the /etc/hosts file on the primary and the snapshot server. You'll need to do this as your root (or _sudo_) user.

In our lab, the primary Incus server is running on 192.168.1.106 and the snapshot Incus server is running on 192.168.1.141. SSH into each server and add the following to the `/etc/hosts` file:

```bash
192.168.1.106 incus-primary
192.168.1.141 incus-snapshot
```

Next, you need to allow all traffic between the two servers. To do this, you are going to change the `firewalld` rules. First, on the incus-primary server, add this line:

```bash
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

and on the snapshot server, add this rule:

```bash
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

then reload:

```bash
firewall-cmd reload
```

Next, as our unprivileged (incusadmin) user, you need to set the trust relationship between the two machines. This is done by running the following on incus-primary:

```bash
incus remote add incus-snapshot
```

This displays the certificate to accept. Accept it, and it will prompt for your password. This is the "trust password" that you set up when doing the Incus initialization step. Hopefully, you are securely keeping track of all of these passwords. When you enter the password, you will receive this:

```bash
Client certificate stored at server:  incus-snapshot
```

It does not hurt to have this in reverse also. For example, set the trust relationship on the incus-snapshot server too. That way, if needed, the incus-snapshot server can send snapshots back to the incus-primary server. Repeat the steps and substitute in "incus-primary" for "incus-snapshot."

### Migrating your first snapshot

Before you can migrate your first snapshot, you need to have any profiles created on incus-snapshot that you have created on the incus-primary. In our case, this is the "macvlan" profile.

You will need to create this for incus-snapshot. Go back to [Chapter 6](06-profiles.md) and create the "macvlan" profile on incus-snapshot if you need to. If your two servers have the same parent interface names ("enp3s0" for example) then you can copy the "macvlan" profile over to incus-snapshot without recreating it:

```bash
incus profile copy macvlan incus-snapshot
```

With all of the relationships and profiles set up, the next step is to actually send a snapshot from incus-primary over to incus-snapshot. If you have been following along exactly, you have probably deleted all of your snapshots. Create another snapshot:

```bash
incus snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

If you run the "info" command for `incus`, you can see the snapshot at the bottom of our listing:

```bash
incus info rockylinux-test-9
```

Which will show something like this at the bottom:

```bash
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

OK, fingers crossed! Let us try to migrate our snapshot:

```bash
incus copy rockylinux-test-9/rockylinux-test-9-snap1 incus-snapshot:rockylinux-test-9
```

This command says, within the container rockylinux-test-9, you want to send the snapshot, rockylinux-test-9-snap1 over to incus-snapshot and name it rockylinux-test-9.

After a short time, the copy will be complete. Want to find out for sure? Do an `incus list` on the incus-snapshot server. Which should return the following:

```bash
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Success! Try starting it. Because we are starting it on the incus-snapshot server, you need to stop it first on the incus-primary server to avoid an IP address conflict:

```bash
incus stop rockylinux-test-9
```

And on the incus-snapshot server:

```bash
incus start rockylinux-test-9
```

Assuming all of this works without error, stop the container on incus-snapshot and start it again on incus-primary.

## Setting `boot.autostart` to off for containers

The snapshots copied to incus-snapshot will be down when they migrate, but if you have a power event or need to reboot the snapshot server because of updates or something, you will end up with a problem. Those containers will try to start on the snapshot server creating a potential IP address conflict.

To eliminate this, you need to set the migrated containers so that they will not start on reboot of the server. For our newly copied rockylinux-test-9 container, you will do this with:

```bash
incus config set rockylinux-test-9 boot.autostart 0
```

Do this for each snapshot on the incus-snapshot server. The "0" in the command will ensure that `boot.autostart` is off.

## Automating the snapshot process

It is great that you can create snapshots when you need to, and sometimes you _do_ need to manually create a snapshot. You might even want to manually copy it over to incus-snapshot. But for all the other times, particularly for many containers running on your incus-primary server, the **last** thing you want to do is spend an afternoon deleting snapshots on the snapshot server, creating new snapshots and sending them over to the snapshot server. For the bulk of your operations, you will want to automate the process.

The first thing you need to do is schedule a process to automate snapshot creation on incus-primary. You will do this for each container on the incus-primary server. When completed, it will take care of this going forward. You do this with the following syntax. Note the similarities to a crontab entry for the timestamp:

```bash
incus config set [container_name] snapshots.schedule "50 20 * * *"
```

What this is saying is, do a snapshot of the container name every day at 8:50 PM.

To apply this to our rockylinux-test-9 container:

```bash
incus config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

You also want to set up the name of the snapshot to be meaningful by our date. Incus uses UTC everywhere, so our best bet to keep track of things, is to set the snapshot name with a date and time stamp that is in a more understandable format:

```bash
incus config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

GREAT, but you certainly do not want a new snapshot every day without getting rid of an old one, right? You would fill up the drive with snapshots. To fix this you run:

```bash
incus config set rockylinux-test-9 snapshots.expiry 1d
```
