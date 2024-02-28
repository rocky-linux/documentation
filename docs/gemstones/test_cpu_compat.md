---
title: Test CPU compatibility
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test 
---

# Introduction

Since the release of Rocky Linux 9, some installations on x86-64 platforms have failed with a kernel panic. In most cases, ==this is due to the CPU's incompatibility== with Rocky Linux 9. This procedure will verify CPU compatibility before installation.

## Testing

1. Obtain a boot image of Rocky Linux 8, Fedora, or others.

2. Boot this live image on the machine where you want the installation of Rocky Linux 9 to be.

3. After the boot completes, open a terminal window and run this procedure:

    ```bash
    /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
    ```

    You should receive output similar to this:

    ```bash
    Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
    This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
    x86-64-v4
    x86-64-v3
    x86-64-v2 (supported, searched)
    ```

    This output indicates the minimum required x86-64 version (v2). Installation can continue in this case. If "(supported, searched)" is missing next to the "x86-64-v2" entry, then your CPU is **not** compatible with Rocky Linux 9.x. If the test shows that your installation can continue and it also shows x86-64-v3 and x86-64-v4 as "(supported, searched)", your CPU is well supported for 9.x and future versions.
