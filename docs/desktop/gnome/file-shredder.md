---
title: File Shredder - Secure Deletion
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - security
  - privacy
  - flatpak
---

## Permanently and Securely Delete Files

When you delete a file using your file manager, the data is not actually erased. The operating system marks the space on your hard drive as "available," leaving the original data intact until new files eventually overwrite it. This means that "deleted" files can often be recovered using specialized software.

**File Shredder** is a simple, modern utility for the GNOME desktop that solves this problem by allowing you to permanently and securely delete files. It does this by repeatedly overwriting the file's data with random noise before deleting it, making recovery practically impossible.

## Installation

The recommended way to install File Shredder on Rocky Linux is as a Flatpak from the Flathub repository.

### 1. Enable Flathub

If you have not already done so, please make sure Flatpak is installed and the Flathub remote is configured on your system.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Install File Shredder

Once Flathub is enabled, you can install File Shredder with a single command.

!!! note "Application ID"
    The application is named "File Shredder," but its technical ID on Flathub is `io.github.ADBeveridge.Raider`.

```bash
flatpak install flathub io.github.ADBeveridge.Raider
```

## How to Use File Shredder

After installation, launch the application from the GNOME Activities Overview by searching for "File Shredder".

The process is straightforward:

1.  Drag and drop the files or folders you wish to permanently erase directly onto the File Shredder window. Alternatively, click the **"Add Files..."** or **"Add Folder..."** buttons.
2.  The files will appear in a list. Review this list carefully.
3.  When you are certain you want to destroy the files forever, click the **Shred** button.

!!! warning "This Action Is Irreversible"
    There is no "undo" button. Once a file is shredded, it is gone permanently. Double-check the files you have added before clicking the Shred button.

## An Important Consideration for SSDs

While File Shredder is highly effective on traditional magnetic hard disk drives (HDDs), its effectiveness on modern Solid-State Drives (SSDs) has limitations.

SSDs use complex internal mechanisms, such as wear-leveling and garbage collection, to manage data and prolong the drive's lifespan. These mechanisms mean that the drive itself, not the operating system, decides where data is physically written. A software tool like File Shredder cannot force an SSD to overwrite a specific physical block of data.

Therefore, while using File Shredder on an SSD makes data recovery significantly more difficult than a standard deletion, it **cannot guarantee** that all traces of the data have been physically erased from the drive's memory cells. For the highest level of data security on an SSD, the recommended approach is to use full-disk encryption (such as LUKS, which can be set up during Rocky Linux installation).

File Shredder remains a valuable tool for enhancing your data privacy, especially on HDDs, and provides a strong layer of security for most use cases.
