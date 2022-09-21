---
title: Import Rocky Linux to WSL or WSL2
author: Lukas Magauer
tested with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - windows
  - interoperability
---

# Import Rocky Linux to WSL

## Prerequisites

The Windows-Subsystem for Linux feature has to be enable. This is possible with either of these options:

- Open an administrative Terminal (either PowerShell or Command-Prompt) and run `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Go to the graphical Windows Settings and enable the optional feature `Windows-Subsystem for Linux`

This feature should be available on every supported Windows 10 and 11 version right now.

## Steps

1. Get the container rootfs. This is possible in multiple ways:

    - Download the image from the [CDN images folder](https://dl.rockylinux.org/pub/rocky/9/images/) (if it is available)
    - Download the image from the latest [Github Action build](https://github.com/rocky-linux/sig-cloud-instance-images/actions/workflows/build.yml)
    - Extract the image from either Docker Hub or Quay.io ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))<br>`<podman/docker> export rockylinux:9 > rocky-9-image.tar`

2. (optional) You might have to extract the docker rootfs layer from the image you got
3. Create the directory where the WSL will store its files (mostly somewhere in the userprofile)
4. Finally, import the image into WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL: `wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar>`
    - WSL 2: `wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar> --version 2`

!!! hint "WSL vs. WSL 2"

    Generally speaking WSL 2 should be faster than WSL, but that might differ from use-case to use-case.

!!! hint "Windows Terminal"

    If you have Windows Terminal installed, the new WSL distro name will appear as an option on the pull-down menu, which is quite handy for launching in the future. You can then customize it with colors, fonts, etc.

!!! hint "systemd"

    Microsoft finally decided to bring systemd into the WSL. ([ref](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl)) You only need to add `systemd=true` to the `boot` ini section in the `/etc/wsl.conf` file! (Please make sure you are running a WSL version equals or later 0.67.6)
