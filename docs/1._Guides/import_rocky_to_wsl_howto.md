# Import Rocky Linux to WSL2 with Virtualbox and Docker

## Prerequisites

* Linux PC running VirtualBox - VirtualBox will not run under windows 10 with WSL2, which is needed for later steps. You can also use a dual boot PC, or a live distribution, but make sure you have VirtualBox available.
* Windows 10 PC running **WSL2**
* Internet access

## Introduction

This guide shows the steps to create a tar image for a Docker container, and how to import that image into the Windows Subsystem for Linux (WSL). The steps outlined below are largely taken from Microsoft's [Import any Linux distribution to use with WSL](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro) and from Docker's [Create a base image](https://docs.docker.com/develop/develop-images/baseimages/), and adapted to the new distribution. 

Please note that you **do not need Docker** to accomplish this task. If you go to either of the original guides for reference, do not install Docker on your PC(s), unless you need it for other purposes. This guide assumes the user is familiar with VirtualBox, and knows how to perform tasks like installing the VirtualBoxAdditions, and mounting shared drives.

It is also important to be familiar with the limitations of WSL, which will cause some functionality to break, work slowly, or work in unexpected ways. Depending on what you want to accomplish, the resulting distribution may or may not do what you want it to do. There are no guarantees.

----

## Install Steps

### On Linux PC with VirtualBox
1. Download the minimal image from [Rocky Linux](https://rockylinux.org/download).
2. Boot and install Rocky Linux on a new VirtualBox VM. The default settings are fine.
3. Install VirtualBoxAdditions on your VM. This will require installing additional packages (as shown in the suggested command):<br />
```bash
$ sudo yum install gcc make kernel-devel bzip2 binutils patch libgomp glibc-headers glibc-devel kernel-headers elfutils-libelf-devel tar

```
4. Make a working directory, and copy files to be used for the tar image.<br />
```bash
$ mkdir wsl_tar
$ cd wsl_tar
$ cp -p /etc/yum.conf .
$ cp -p /etc/yum.repos.d/Rocky-BaseOS.repo .
```
5. Edit *your copy* of `yum.conf` and add this line to it (modify the path as needed):<br />
```bash
reposdir=/home/<your_username>/wsl_tar/
```
6. Download the script to create a base image from Docker GitHub.<br/>
    The script is called [mkimage-yum.sh](https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh).
7. Modify the script to create a tar file at the end, instead of starting Docker. Here are the suggested changes to the file:
```bash
## Change line 143 to simply create the tar file, without invoking Docker
tar --numeric-owner -c -C "$target" . -f <path-to-the-new-tar-file>

## Comment out line 145
```
8. Execute the script using this command (modify the path as needed):<br/>
```bash
$ sudo ./mkimage-yum.sh -y /home/<your_username>/wsl_tar/yum.conf baseos
```
9. After the script finishes, your new tar file will be in the path you entered in the script above. Mount a shared drive with the host and move the tar file there.  
    You could also move the file to a USB drive or folder accessible to the Windows 10 PC. After moving the file to an external drive or folder, you won't need the VM anymore. You can delete it or modify it for other purposes.

### On your Windows 10 PC
10. Create a directory to hold the Rocky Linux filesystem.
11. In a PowerShell prompt, import Rocky Linux (it's named `rocky_rc` here, but you can name it anything you like).<br/>
```PowerShell
wsl --import rocky_rc <Path to RockyLinuxDirectory> <Path to tar file from above>
```
12. Verify Rocky Linux is installed with:<br/>
```PowerShell
wsl -l -v
```
13. Launch Rocky Linux with<br/>
```PowerShell
wsl -d rocky_rc
```
14. Set up Rocky Linux with the following bash commands (you'll need to be running as root).<br/>
```bash
yum update
yum install glibc-langpack-en -y
yum reinstall passwd sudo cracklib-dicts -y
newUsername=<your new username>
adduser -G wheel $newUsername
echo -e "[user]\ndefault=$newUsername" >> /etc/wsl.conf
passwd $newUsername
```
15. Exit the bash prompt (Ctrl+D or exit).
16. Back in a PowerShell prompt, shutdown all WSL running instances and start Rocky.<br/>
```PowerShell
wsl --shutdown
wsl -d rocky_rc
```
17. Test and enjoy!

If you have Windows Terminal installed, the new WSL distro name will appear as an option on the pull-down menu, which is quite handy to launch it in the future. You can then customize it with colors, fonts, etc. 

Even though you need WSL2 in order to perform the steps above, you can use the distro as WSL 1 or 2, by converting it with PowerShell commands.