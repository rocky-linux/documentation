---
title: 8 Container Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd snapshots
---

# Chapter 8: Container Snapshots

Throughout this chapter you will need to execute commands as your unprivileged user ("lxdadmin" if you've been following along from the beginning of this book).

Container snapshots, along with a snapshot server (which we will get to more later), are probably the most important aspect of running a production LXD server. Snapshots ensure quick recovery, and can be used for safety when you are, say, updating the primary software that runs on a particular container. If something happens during the update that breaks that application, you simply restore the snapshot and you are back up and running with only a few seconds worth of downtime.

The author used LXD containers for PowerDNS public facing servers, and the process of updating those applications became so much more worry-free, since you can snapshot the container first before continuing.

You can even snapshot a container while it is running. 

## The snapshot process

We'll start by getting a snapshot of the ubuntu-test container by using this command:

```
lxc snapshot ubuntu-test ubuntu-test-1
```

Here, we are calling the snapshot "ubuntu-test-1", but it can be called anything you like. To make sure that you have the snapshot, do an "lxc info" of the container:

```
lxc info ubuntu-test
```

We've looked at an info screen already, so if you scroll to the bottom, you should see:

```
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Our snapshot is in place.

Now, get into the ubuntu-test container:

```
lxc exec ubuntu-test bash
```

And create an empty file with the _touch_ command:

```
touch this_file.txt
```

Now exit the container.

Before we restore the container as it was prior to creating the file, the safest way to restore a container, particularly if there have been a lot of changes, is to stop it first:

```
lxc stop ubuntu-test
```

Then restore it:

```
lxc restore ubuntu-test ubuntu-test-1
```

Then start the container again:

```
lxc start ubuntu-test
```

If you get back into the container again and look, our "this_file.txt" that we created is now gone.

Once you don't need a snapshot anymore, you can delete it:

```
lxc delete ubuntu-test/ubuntu-test-1
```

!!! warning

    You should always delete snapshots with the container running. Why? Well the _lxc delete_ command also works to delete the entire container. If we had accidentally hit enter after "ubuntu-test" in the command above, AND, if the container was stopped, the container would be deleted. No warning is given, it simply does what you ask.

    If the container is running, however, you will get this message:

    ```
    Error: The instance is currently running, stop it first or pass --force
    ```

    So always delete snapshots with the container running.

The process of creating snapshots automatically, setting expiration of the snapshot so that it goes away after a certain length of time, and auto refreshing the snapshots to the snapshot server will be covered in detail in the following chapters.
