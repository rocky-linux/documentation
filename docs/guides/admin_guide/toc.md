# Introduction

This is a collection of educational documents focused on System Administrators. They can be used by future System Administrators trying to get up to speed, by current System Administrators who would like a refresher, or by any Linux user who'd like to learn more about the Linux environment, commands, processes, and more. Like all documents of this type, it is meant to evolve and update.

First, we will discuss Linux, distributions, and the whole ecosystem around our operating system.

We will then look at the user commands that are essential for getting to grips with Linux. The more experienced users will also be able to consult the chapter dedicated to the more "advanced" commands.

Next, comes the chapter on the VI editor. While Linux comes with many editors, VI is one of the most powerful. Other commands sometimes use some of the same syntax as VI (`sed` comes to mind) which means that knowing something about VI, or at least demystifying its the basic functions (how to open a file, save, quit or quit without saving), seems very important to know. The user will become more comfortable with the other functions of VI as they use this editor.

We can then get into the heart of the matter and into the functioning of Linux to discover how the system manages:

* users,
* file systems,
* processes.

We will make an aside on backups, a subject that is always so important that it is essential to talk about it: we will never make enough backups. We will discover two tools: `tar` but also `cpio`, less widespread, which in certain cases can be very interesting.

Next, we will cover a very important subject for a System Administrator: Backups. While there are a host of software solutions that can be used with Linux to enhance backups (rsnapshot, lsyncd, etc.), It's good to know the basic components of the backup that are provided within the operating system. We will discover two tools: `tar` and the less widespread `cpio` in this chapter.

We will come back to the management of the system with the boot, which has evolved enormously in recent years since the arrival of systemd.

We will conclude by studying the management of tasks, the implementation of the network and the installation of software.

Enjoy your reading.

## Table Of Contents

* [Chapter 1. - Introduction to the Linux operating system](../admin_guide/01-presentation.md)
* [Chapter 2. - Installation]
* [Chapter 3. - Commands for Linux users](../admin_guide/03-commands.md)
* [Chapter 4. - Advanced Commands]
* [Chapter 5. - VI Text Editor](../admin_guide/05-vi.md)
* [Chapter 6. - User and Group Management](../admin_guide/06-users.md)
* [Chapter 7. - File System](../admin_guide/07-file-systems.md)
* [Chapter 8. - Process Management](../admin_guide/08-process.md)
* [Chapter 9. - Backup]
* [Chapter 10. - System Startup](../admin_guide/10-boot.md)
* [Chapter 11. - Managing Tasks With Cron]
* [Chapter 12. - Networking](../admin_guide/12-network.md)
* [Chapter 13. - Managing Software](../admin_guide/13-softwares.md)
