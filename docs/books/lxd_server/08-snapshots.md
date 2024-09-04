---
title: 8 Container Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd snapshots
---

# Chapter 8: container snapshots

Throughout this chapter you will need to run commands as your unprivileged user ("lxdadmin" if you've been following along from the beginning of this book).

Container snapshots, along with a snapshot server (more on that later), are probably the most important aspect of running a production LXD server. Snapshots ensure quick recovery. It is a good idea to use them as a fail safe when updating the primary software that runs on a particular container. If something happens during the update that breaks that application, you just restore the snapshot and you are back up and running with only a few seconds worth of downtime.

The author used LXD containers for PowerDNS public facing servers, and the process of updating those applications became less worrisome, thanks to taking snapshots before every update.

You can even snapshot a container when it is running.

## The snapshot process

Start by getting a snapshot of the ubuntu-test container by using this command:

```bash
lxc snapshot ubuntu-test ubuntu-test-1
```

Here, you are calling the snapshot "ubuntu-test-1", but you can call it anything. To ensure that you have the snapshot, do an `lxc info` of the container:

```bash
lxc info ubuntu-test
```

You have looked at an info screen already. If you scroll to the bottom, you now see:

```bash
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Our snapshot is in place.

Get into the ubuntu-test container:

```bash
lxc exec ubuntu-test bash
```

Create an empty file with the _touch_ command:

```bash
touch this_file.txt
```

Exit the container.

Before restoring the container how it was prior to creating the file, the safest way to restore a container, particularly if there have been many changes, is to stop it first:

```bash
lxc stop ubuntu-test
```

Restore it:

```bash
lxc restore ubuntu-test ubuntu-test-1
```

Start the container again:

```bash
lxc start ubuntu-test
```

If you get back into the container again and look, our "this_file.txt" that you created is now gone.

When you do not need a snapshot anymore you can delete it:

```bash
lxc delete ubuntu-test/ubuntu-test-1
```

!!! warning

    You should always delete snapshots with the container running. Why? Well the _lxc delete_ command also works to delete the entire container. If we had accidentally hit enter after "ubuntu-test" in the command above, AND, if the container was stopped, the container would be deleted. No warning is given, it simply does what you ask.

    If the container is running, however, you will get this message:

    ```
    Error: The instance is currently running, stop it first or pass --force
    ```

    So always delete snapshots with the container running.

In the chapters that follow you will:

* set up the process of creating snapshots automatically
* set up expiration of a snapshot so that it goes away after a certain length of time
* set up auto refreshing of snapshots to the snapshot server
