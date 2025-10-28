---
title: Test CPU compatibility
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test 
---

# Introduction

Some installations on x86-64 platforms can fail with a kernel panic. In most cases, ==this is due to the CPU's incompatibility== with Rocky Linux.

## Testing

1. Obtain a boot image of Rocky Linux 9, Fedora, or others.

2. Boot this live image on the machine where you want to install Rocky Linux 10.

3. After the boot completes, open a terminal window and run this procedure:

    ```bash
    /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
    ```

    You should receive output similar to this:

    ```bash
    Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
    This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
    x86-64-v4
    x86-64-v3 (supported, searched)
    x86-64-v2 (supported, searched)
    ```

    This output indicates the minimum required x86-64 version (v3). Installation can continue in this case. If "(supported, searched)" is missing next to the "x86-64-v3" entry, then your CPU is **not** compatible with Rocky Linux 10. If the test indicates that your installation can proceed and it also lists x86-64-v4 as "(supported, searched)", your CPU is well-supported for future versions of Rocky Linux.
