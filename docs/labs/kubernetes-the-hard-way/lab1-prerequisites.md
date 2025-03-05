---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower).
Unlike the original that bases itself on Debian like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux running on x86_64 architecture.

# Prerequisites

In this lab you will review the machine requirements necessary to follow this tutorial.

## Virtual or Physical Machines

This tutorial requires four (4) virtual or physical x86_64 machines running Debian 12 (bookworm). The following table list the four machines and thier CPU, memory, and storage requirements.

| Name    | Description            | CPU | RAM   | Storage |
|---------|------------------------|-----|-------|---------|
| jumpbox | Administration host    | 1   | 512MB | 10GB    |
| server  | Kubernetes server      | 1   | 2GB   | 20GB    |
| node-0  | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node-1  | Kubernetes worker node | 1   | 2GB   | 20GB    |

How you provision the machines is up to you, the only requirement is that each machine meet the above system requirements including the machine specs and operating system version. Once you have all four machine provisioned, verify the system requirements by running the `uname` command on each machine:

```bash
uname -mov
```

After running the `uname` command you should see the following output:

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

The `x86_64` that you see in the output confirms that the system is a x86_64 architecture. This should be the case for various AMD and Intel based systems.

Next: [setting-up-the-jumpbox](lab2-jumpbox.md)
