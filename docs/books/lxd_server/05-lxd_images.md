---
title: 5 Setting Up and Managing Images
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd images
---

# Chapter 5: Setting Up and Managing Images

Throughout this chapter you will need to execute commands as your unprivileged user ("lxdadmin" if you have been following this book from the beginning).

## List Available Images

Once you have your server environment set up, you'll probably be itching to get started with a container. There are a _lot_ of container OS possibilities. To get a feel for how many possibilities, enter this command:

```
lxc image list images: | more
```

Hit the space bar to page through the list. This list of containers and virtual machines continues to grow. For now, we are sticking with containers.

The last thing you want to do is to page through looking for a container image to install, particularly if you know the image that you want to create. Let's modify the command above to show only Rocky Linux install options:

```
lxc image list images: | grep rocky
```

This brings up a much more manageable list:

```
| rockylinux/8 (3 more)                    | 0ed2f148f7c6 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 128.68MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8 (3 more)                    | 6411a033fdf1 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 643.15MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/arm64 (1 more)              | e677777306cf | yes    | Rockylinux 8 arm64 (20220805_02:29)          | aarch64      | CONTAINER       | 124.06MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 3d2fe303afd3 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 147.04MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 7b37619bf333 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 659.58MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud/arm64                 | 21c930b2ce7d | yes    | Rockylinux 8 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 143.17MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | 61b0171b7eca | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | VIRTUAL-MACHINE | 526.38MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | e7738a0e2923 | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | CONTAINER       | 107.80MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/arm64 (1 more)              | 917b92a54032 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 103.81MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 16d3f18f2abb | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 123.52MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 605eadf1c512 | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 547.39MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud/arm64                 | db3ce70718e3 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 119.27MB  | Aug 5, 2022 at 12:00am (UTC)  |
```

## Installing, Renaming, And Listing Images

For the first container, we are going to choose rockylinux/8. To install it, we *could* use:

```
lxc launch images:rockylinux/8 rockylinux-test-8
```

That will create a Rocky Linux-based container named "rockylinux-test-8". You can rename a container after it has been created, but you first need to stop the container, which starts automatically when it is launched.

To start the container manually, use:

```
lxc start rockylinux-test-8
```

To rename this image (we aren't going to do this here, but this is how it is done) first stop the container:

```
lxc stop rockylinux-test-8
```

Then simply move the container to a new name:

```
lxc move rockylinux-test-8 rockylinux-8
```

If you followed this instruction anyway, stop the container and move it back to the original name to continue to follow along.

For the purposes of this guide, go ahead and install two more images for now:

```
lxc launch images:rockylinux/9 rockylinux-test-9
```

and

```
lxc launch images:ubuntu/22.04 ubuntu-test
```

Now let's take a look at what we have so far by listing our images:

```
lxc list
```

which should return something like this:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

