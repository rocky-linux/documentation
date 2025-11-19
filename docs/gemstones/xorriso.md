---
title: Write to Physical CD/DVD with Xorriso 
author: Joseph Brinkman 
---

## Introduction

I recently discovered that burning hybrid ISOs onto a physical CD/DVD on Rocky Linux using graphical tools poses a challenge. Thankfully, Xorriso is a simple to use CLI app that handles this task well!

## Problem Description

Burn an ISO onto a physical CD/DVD.

## Prerequisites

- Internet connection
- Familiarity with terminal
- CD/DVD RW drive

## Procedure

**Install Extra Packages for Enterprise Linux (EPEL)**:

   ```bash
   sudo dnf install epel-release -y
   ```

**Install Xorris and Library**:

   ```bash
   sudo dnf install libisofs xorriso -y
   ```

**Write ISO to Disk**:

   ```bash
   sudo xorriso -as cdrecord -v dev/=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso
   ```

## Conclusion

In this gemstone you learned how to write an ISO to a physical disk with Xorriso! Keep in mind that Xorriso can be used to write other filetypes to physical disks, but I found it especially handy for hybrid ISO format that graphical tools didn't know how to deal with.
