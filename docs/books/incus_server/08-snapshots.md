---
title: 8 Container Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus 
  - enterprise
  - incus snapshots
---

Throughout this chapter, you must run commands as your unprivileged user ("incusadmin" if you've been following them from the beginning of this book).

Container snapshots and a snapshot server (more on later) are the most critical aspects of running a production Incus server. Snapshots ensure quick recovery. It is a good idea to use them as a failsafe when updating the primary software that runs on a particular container. If something happens during the update that breaks that application, you just restore the snapshot, and you are back up and running with only a few seconds of downtime.

The author used Incus containers for PowerDNS public-facing servers, and updating those applications became less problematic, thanks to taking snapshots before every update.

You can even snapshot a container when it is running.

## The snapshot process

Start by getting a snapshot of the ubuntu-test container by using this command:

```bash
incus snapshot create ubuntu-test ubuntu-test-1
```

Here, you call the snapshot "ubuntu-test-1", but you can call it anything. To ensure that you have the snapshot, do an `incus info` of the container:

```bash
incus info ubuntu-test
```

You have already looked at an info screen. If you scroll to the bottom, you now see:

```bash
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Our snapshot is in place.

Get into the ubuntu-test container:

```bash
incus shell ubuntu-test
```

Create an empty file with the _touch_ command:

```bash
touch this_file.txt
```

Exit the container.

Before restoring the container how it was before creating the file, the safest way to restore a container, mainly if there have been many changes, is to stop it first:

```bash
incus stop ubuntu-test
```

Restore it:

```bash
incus snapshot restore ubuntu-test ubuntu-test-1
```

Start the container again:

```bash
incus start ubuntu-test
```

If you return to the container again and look, the "this_file.txt" you created is gone.

When you do not need a snapshot anymore, you can delete it:

```bash
incus snapshot delete ubuntu-test ubuntu-test-1
```

!!! warning

    You should permanently delete snapshots while the container is running. Why? Well, the _incus delete_ command also works to delete the entire container. If we accidentally hit enter after "ubuntu-test" in the command above, AND if the container was stopped, the container would be deleted. I just wanted to let you know that no warning is given. It simply does what you ask.

    If the container is running, however, you will get this message:

    ```
    Error: The instance is currently running, stop it first or pass --force
    ```

    So always delete snapshots with the container running.

In the chapters that follow, you will:

* set up the process of creating snapshots automatically
* set up the expiration of a snapshot so that it goes away after a certain length of time
* set up auto-refreshing of snapshots to the snapshot server
