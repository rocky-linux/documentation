---
title: Import To WSL with WSL and rinse
---

# Import Rocky Linux to WSL with WSL and rinse

## Prerequisites
* A Windows 10 PC with WSL 2 enabled. (*see note below).
* Ubuntu, or any debian-based distribution, installed and running on WSL. This guide was tested using Ubuntu 20.04 LTS from the Microsoft store.

## Introduction
This guide is for Windows users who would like to run Rocky Linux (RL) in the Windows Subsystem for Linux (WSL). It assumes the reader is familiar with the command line and has WSL enabled and running in their Windows 10 PC.

The process uses `rinse`, a perl script for creating images of distributions that use the package manager YUM.

Please keep in mind that WSL has significant limitations and quirks, and the resulting distribution may or may not work as you expect it. It may be too slow, or be unpredictable for some applications. With computers, as with life, there are no guarantees.

## Steps

1. Launch your Ubuntu distribution in WSL, update the package manager and install `rinse`<br/>
```bash
$ sudo apt-get update
$ sudo apt-get install rinse
```
`rinse` is not aware of RL, so we need to modify its configuration to add the package repositories and so on.

2. Copy the CentOS 8 packages file and prepare it for RL
```bash
$ sudo cp -p /etc/rinse/centos-8.packages /etc/rinse/rocky-8.packages
```
3. Edit the new file and change all the entries for 'centos' to 'rocky'. Next, add the following lines to it. The order in the file is not important, the entries can be added anywhere. Here you can also add any other packages that you may want to have in your image (servers, utilities like `which`, etc)
```bash
glibc-langpack-en
libmodulemd
libzstd
passwd
sudo
cracklib-dicts
openssh-clients
python3-dbus
dbus-glib
```
4. Edit the `rinse` config file at `/etc/rinse/rinse.conf` and add the following lines, which are the entry for RL mirrors. As of this writing, we have a direct download, but this will be changed to a mirror as soon as available.
```bash
# Rocky Linux 8
[rocky-8]
mirror.amd64 = http://dl.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/Packages/
```
5. Copy the post-install script for CentOS so it can be modified for RL
```bash
$ sudo cp -pR /usr/lib/rinse/centos-8 /usr/lib/rinse/rocky-8
```
6. Edit `/usr/lib/rinse/rocky-8/post-install.sh` and add the following lines at line 14. This is needed to make sure TLS/SSL works as expected for *YUM* and *dnf*.
```bash
echo "  Extracting CA certs..."
$CH /usr/bin/update-ca-trust
```
7. Edit the `rinse` script at `/usr/sbin/rinse`, and at line 1248 remove the text `--extract-over-symlinks`. This option was deprecated in the program called and breaks the script. Don't close the file yet.
8. On the same file, go to line 1249 and replace 'centos' for 'rocky'. Save and close the file.
9. Make a directory to hold the new RL filesystem (any name is fine).
```bash
$ mkdir rocky_rc
```
10. Execute `rinse` with the following command
```bash
$ sudo rinse --arch amd64 --directory ./rocky_rc --distribution rocky-8
```
11. After the script completes downloading and extracting all the packages, you will have a full Rocky Linux file system in the directory you created. Now it's time to package it to pass it to Windows for importing into a new WSL distro. Use this command, creating the tar file in a Windows folder (starting with `/mnt/c/` or similar to have it readily available for the next step).
```bash
$ sudo tar --numeric-owner -c -C ./rocky_rc . -f <path to new tar file>
```
12. Close your WSL session with Ctrl+D or by typing `exit`.
13. Open a PowerShell prompt (does not need to be admin), and create a folder to hold your new RL distro.
14. Import the tar file with this command:
```PowerShell
wsl --import rocky_rc <path to folder from step 9> <path to tar file>
```
Note: Default location of WSL is `%LOCALAPPDATA%\Packages\`
`e.g. for Ubuntu - C:\Users\tahder\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhks2fndhsd\LocalState\rootfs\home\txunil\rocky_rc`

15. In the PowerShell prompt, launch your new distro with:
```PowerShell
wsl -d rocky_rc
```
16. You are now root in your new RL distro. Run these commands to finish setting everything up:
```bash
yum update
yum reinstall passwd sudo cracklib-dicts -y
newUsername=<your new username>
adduser -G wheel $newUsername
echo -e "[user]\ndefault=$newUsername" >> /etc/wsl.conf
passwd $newUsername
```
17. Exit the bash prompt (Ctrl+D or type `exit`).
18. Back in PowerShell, shutdown WSL and relaunch your new distro.
```PowerShell
wsl --shutdown
wsl -d rocky_rc
```
19. Test and enjoy!

## Cleanup
All the downloaded packages are still stored in the debian distro you used at the beginning of the process. You can remove the files from `/var/cache/rinse`, and you can also delete all the files from the `rocky_rc` directory. Next time you want to create a new, updated or modified image, simply make your changes and run the commands from step 10 on.

## Known issues
There are some quirky things that result from extracting packages, rather than installing them. Running `yum reinstall` in some packages fixes the issues, as is the case for `passwd`. The `rinse` script simply extracts the packages and does not execute post-install commands (although it is capable of doing so). Please leave comments for other users if you run into problems and know how to fix them, so that others can benefit from your experience.

## Notes
Most of the `rinse` script runs under WSL 1, but the very last part, where `dnf` is invoked, runs into memory issues and corrupts the `rpm` database. This ruins the distro, and repair attempts fail, even under WSL. If you know how to get `dnf` to work under WSL 1, please let us know, but there are lots of BDB issues related to WSL 1 on different forums on the web. WSL 2 solved those issues with the native Linux kernel.
