---
title: Packaging And Developer Guide
---

# Packaging and developer starter guide

Rocky Devtools refers to a set of homegrown scripts and utilities created by members of the Rocky Linux community to help with sourcing, creating, branding, patching, and building software packages distributed with the Rocky Linux Operating system.
Rocky Devtools consists of `rockyget`, `rockybuild`, `rockypatch`, and `rockyprep`.

At a low level Rocky Devtools is a wrapper for running some custom and traditional programs for various package management tasks. Rocky Devtools relies heavily on [`srpmproc`](https://github.com/mstg/srpmproc), `go`, `git`, and `rpmbuild`.

You'll need an existing modern RPM based Linux system to install and use Rocky devtools.

Let's walk through a typical installation and usage scenario of the devtools.

## Dependencies

Several packages are required on the system before you can begin to use the devtools. These commands have been tested on Rocky Linux but should work on CentOS 8 / RHEL 8 too

```bash
dnf install git make golang
```

## 1. Download Rocky Devtools

Download the devtools zipped source from the following URL:

<https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip>

Here we use the `curl` command:

```bash
curl -OJL https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip
```

You should now have a zipped archive named `devtools-main.zip`

## 2. Install Rocky Devtools

Locate and uncompress the devtools archive that you just downloaded.

Here we'll use the `unzip` command line utility:

```bash
unzip devtools-main.zip
```

Change your working directory to the new devtool source directory that was just created:

```bash
cd devtools-main
```

Run `make` to configure and compile devtools:

```bash
make
```

Install devtools:

```bash
sudo make install
```

## 3. Use Rocky Devtools (rockyget) to search for and download Source RPMs (SRPMs)

Once installed, the main utility for finding and downloading SRPMs is the `rockyget` utility.

Let's use `rockyget` to download the SRPM for the popular `sed` package:

```bash
rockyget sed
```

The first time rockyget is run, it will automatically create a directory structure that roughly mimics the repository structure of Rocky's build servers. For example the `~/rocky/rpms` folder will be automaically created.

For our current sed example, its sources will be stored under the following sample folder hierchy:

```bash
~rocky/rpms/sed/
└── r8
    ├── SOURCES
    │   ├── sed-4.2.2-binary_copy_args.patch
    │   ├── sed-4.5.tar.xz
    │   ├── sedfaq.txt
    │   ├── sed-fuse.patch
    │   └── sed-selinux.patch
    └── SPECS
        └── sed.spec
```

!!! Tip

    Once you have the original sources, this might be a good time to look through the SPECs file (`~rocky/rpms/sed/SPECS/specs.spec`) to look for potential debranding opportinites in the given package. Debranding might include replacing upstream artwork/logos and so on.

!!! Tip

    If you are looking for other Rocky packages to build and experiment with, you can browse the list of packages that are currently failing in the Rocky automated build environment [here](https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id)

## 4. Use Rocky Devtools (rockybuild) to build a new package for the Rocky OS

Under the hood, `rockybuild` calls `rpmbuild` and `mock` utilities to build the source package in a chroot environment for the application specified on the command-line. It relies on the application sources and RPM SPEC file that was automatically downloaded via the `rockyget` command.

Use `rockybuild` to build the sed utility:

```bash
rockybuild sed
```

The time needed to complete the build process/step depends on the size and complexity of the application you are trying to build.

At the end of the `rockybuild` run, an output similar to the one here indicates that the build completed successfully.

```bash
..........
+ exit 0
Finish: rpmbuild sed-4.5-2.el8.src.rpm
Finish: build phase for sed-4.5-2.el8.src.rpm
INFO: Done(~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm) Config(baseos) 4 minutes 34 seconds
INFO: Results and/or logs in: /home/centos/rocky/builds/sed/r8
........
```

If all goes well you should end up with a Rocky ready SRPM file under the `~/rocky/builds/sed/r8` directory.

`~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm`

## 5. Debugging a failed package build

The previous rockybuild process will generate some log files that can be used in debugging failed application builds. The results and/or logs of the build process are stored under the `~/rocky/builds/<PACKAGE NAME>/r8`. For example `~/rocky/builds/sed/r8`

```bash
~/rocky/builds/sed/r8
├── build.log
├── hw_info.log
├── installed_pkgs.log
├── root.log
├── sed-4.5-2.el8_3.src.rpm
├── sed-4.5-2.el8_3.x86_64.rpm
├── sed-debuginfo-4.5-2.el8_3.x86_64.rpm
├── sed-debugsource-4.5-2.el8_3.x86_64.rpm
└── state.log
```

The main files to search for clues for the causes any error(s) are the build.log and root.log.     The build.log file should detail all build errors and the root.log file will contain information about the chroot environment setup and tear down processes. With everything else being equal, most of the build debugging/troubleshooting process can be performed with the contents of the build.log file.
