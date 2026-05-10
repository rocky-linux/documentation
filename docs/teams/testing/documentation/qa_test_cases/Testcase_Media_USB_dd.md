---
title: QA:Testcase Media USB dd
author: Trevor Cooper
contributors: Lukas Magauer
tested_with: 8.10
tags:
  - testing
  - qa
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#initialization-requirements](../../guidelines/release_criteria/r9/9_release_criteria.md#initialization-requirements) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This verifies that Rocky Linux ISO image can be written to USB media using `dd` command, and the resulting USB media successfully boots to the Anaconda Installer.

!!! error "DATA LOSS"
    Any data on the USB stick used for this test is likely to be destroyed. Please do not use a stick whose contents you need to keep.

## Setup

1. Provide a USB media device that is larger than the ISO image you wish to test and that it can be completely erased.
2. Provide a Linux (or other *nix system) that has the `dd` command available and an unoccupied USB port.
3. Download the Rocky Linux ISO image you wish to test onto the test system.
    - Example command:

   ```bash
   curl -LOR https://dl.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10-latest-x86_64-boot.iso
   ```

4. Download the `CHECKSUM` file that goes with the Rocky Linux ISO image that you wish to test.
    - Example command:

    ```bash
    curl -LOR https://dl.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM
    ```

5. Download the `CHECKSUM.sig` file that does with the `CHECKSUM` file.
    - Example command:

    ```bash
    curl -LOR https://dl.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM.asc
    ```

6. Download the Rocky Release Engineering GPG key.
    - Example command:

    ```bash
    curl -LOR https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
    ```

## How to test

1. Import the Rocky Release Engineering GPG key.
    - Example command:

    ```bash
    gpg --import RPM-GPG-KEY-rockyofficial
    ```

2. Verify the signature of the CHECKSUM file.
    - Example command:

    ```bash
    gpg --verify-file CHECKSUM.asc
    ```

3. Verify the CHECKSUM of the Rocky Linux ISO...
    - Example command:

    ```bash
    shasum -a 256 --ignore-missing -c CHECKSUM
    ```

4. Write the Rocky Linux ISO to the USB media using `dd`...
    - Example command:

    ```bash
    dd if=Rocky-8.5-x86_64-boot.iso of=/dev/sdX bs=16M status=progress oflag=direct
    ```

    ...where you replace `sdX` with the device identifier of your USB media. **This will destroy all data on the disk.**

5. Boot the test system with the USB media.
6. In the boot menu select the appropriate option to boot the installer.
7. **[OPTIONAL]** Proceed with installation on the test system **Depending on installer choices this MAY destroy all the data on the test system.**

## Expected Results

1. The gpg signature on the `CHECKSUM` file is valid.
2. The `CHECKSUM` of the Rocky Linux ISO is valid.
3. The Rocky Linux ISO is written to the USB stick without errors.
4. The USB stick boots without errors.
5. The Anaconda Installer starts without errors.
6. **[OPTIONAL]** The installation finishes successfully and, if the minimal or DVD ISO were used, the package repository on the USB stick (not a network based repository) was used for the installation.

!!! error "DATA LOSS"
    If you choose to complete the installation of the test system any/all data on the system may be lost. Please do not install on a system whose contents you need to keep.

{% include 'teams/testing/qa_testcase_bottom.md' %}
