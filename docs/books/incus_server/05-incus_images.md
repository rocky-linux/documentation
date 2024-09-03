---
title: 5 Setting Up and Managing Images
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus 
  - enterprise
  - incus images
---

Throughout this chapter you will need to run commands as your unprivileged user ("incusadmin" if you have been following this book from the beginning).

## List available images

You probably can not wait to get started with a container. There are many container operating system possibilities. To get a feel for how many possibilities, enter this command:

```bash
incus image list images: | more
```

Enter the space bar to page through the list. This list of containers and virtual machines continues to grow.

The **last** thing you want to do is to page through looking for a container image to install, particularly if you know the image that you want to create. Change the command to show only Rocky Linux install options:

```bash
incus image list images: | grep rocky
```

This brings up a much more manageable list:

```bash
| rockylinux/8 (3 more)                    | dede6169bb45 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 850.75MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/arm64 (1 more)              | b749bad83e60 | yes    | Rockylinux 8 arm64 (20240903_04:40)        | aarch64      | CONTAINER       | 125.51MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 4fefd464d25d | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 869.95MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 729891475172 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | CONTAINER       | 148.81MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud/arm64                 | 3642ec9652fc | yes    | Rockylinux 8 arm64 (20240903_04:52)        | aarch64      | CONTAINER       | 144.84MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | 9e5e4469e660 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | VIRTUAL-MACHINE | 728.60MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | fff1706d5834 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | CONTAINER       | 111.25MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/arm64 (1 more)              | d3a44df90d69 | yes    | Rockylinux 9 arm64 (20240903_04:49)        | aarch64      | CONTAINER       | 107.18MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | 4329a67099ba | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | VIRTUAL-MACHINE | 749.29MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | bc30d585b9f0 | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | CONTAINER       | 127.16MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud/arm64                 | 5c38ddd506bd | yes    | Rockylinux 9 arm64 (20240903_04:38)        | aarch64      | CONTAINER       | 122.87MiB  | 2024/09/02 19:00 CDT |
```

## Installing, renaming, and listing images

For the first container, you are going to use "rockylinux/8". To install it, you can use:

```bash
incus launch images:rockylinux/8 rockylinux-test-8
```

That will create a Rocky Linux-based container named "rockylinux-test-8". You can rename a container after creating it, but you first need to stop the container, which starts automatically when created.

To start the container manually, use:

```bash
incus start rockylinux-test-8
```

To Rename the image (we are not going to do this here, but this is how to do it) first stop the container:

```bash
incus stop rockylinux-test-8
```

Use the `move` command to change the container's name:

```bash
incus move rockylinux-test-8 rockylinux-8
```

If you followed this instruction anyway, stop the container and move it back to the original name to continue to follow along.

For the purposes of this guide, go ahead and install two more images for now:

```bash
incus launch images:rockylinux/9 rockylinux-test-9
```

and

```bash
incus launch images:ubuntu/22.04 ubuntu-test
```

Examine what you have by listing your images:

```bash
incus list
```

which will return this:

```bash
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
