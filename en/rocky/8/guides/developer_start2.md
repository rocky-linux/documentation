** Work in progress **

Rocky devtools refers to a set of home grown scripts and utlities created by members of the Rocky Linux community to help with sourcing, creating, branding, patching and building software packages distributed with the Rocky Linux Operating system.
Rocky devtools consists of rockyget, rockybuild, rockypatch and rockyprep.

At a low level Rocky Devtools is a wrapper for running some custom and tradtional programs that are used for various Package management tasks. Rocky Devtools relies  heavily on [srpmproc](https://github.com/mstg/srpmproc), go, git and rpmbuild.

You'll need an existing modern RPM based Linux system to install and use Rocky devtools.

Let's walk through a typical installation and usage scenario of the devtools.

## 1 - Download Rocky Devtools

Download devtools zipped source from the following URL

https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip

Here we use the curl command to do this. Type:

```
curl  -OJL  https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip
```

You should now have a zipped archive named `devtools-main.zip`


## 2 - Install Rocky Devtools

Locate and unzip (uncompress) the devtools archive that you just downloaded.

Here we'll use the unzip command line utility. Type:

```
unzip  devtools-main.zip 
```

Change your working directory to the new devtool source directory that was just created. Type:

```
cd devtools-main
```

Run the make and then install devtools command. Type:

```
make
```

Install devtools.  Type:

```
sudo make install
```

## 3 - Use Rocky Devtools (rockyget) to search for and download Source RPMs (SRPMs)

Once installed, the main utility for find and downloading SRPMs is the `rockyget` utility. 

Let's use rockyget to download the SRPM for the popular `sed` package. 

Type:
```
rockyget sed
```
The first time rockyget is run, it will automatically create a directory structure that roughly mimics the repository structure of Rocky's build servers.  For example the ~/rocky/rpms folder will be automaically created.  

For our current sed example, it's sources will be stored under the following sample folder hierchy.

```
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

### TIP :
Once you have the original sources, this might be a good time to look through the SPECs file (`~rocky/rpms/sed/SPECS/specs.spec`) to look for potential debranding opportinites in the given package.  Debranding might include replacing upstream artwork/logos and so on. 


## 4 - Use Rocky Devtools (rockybuild) to build a new package for the Rocky OS

Under the hood, rockybuild calls rpmbuild and mock utilities to build the source package in a chroot environment for the application specified on the command-line. It relies on the application sources and RPM SPEC file that was automatically downloaded via the rockyget command. 

Use rockybuild to build the sed utility. Type:

```
rockybuild sed
```

The time needed to complete the build process/step depends on the size and complexity of the application you are trying to build.  

At the end of the rockybuild run, an output similar to the one here indicates that the build completed successfully.

```
..........
+ exit 0
Finish: rpmbuild sed-4.5-2.el8.src.rpm
Finish: build phase for sed-4.5-2.el8.src.rpm
INFO: Done(~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm) Config(baseos) 4 minutes 34 seconds
INFO: Results and/or logs in: /home/centos/rocky/builds/sed/r8
........
```

If all goes well you should end up with a Rocky ready SRPM file under the `~/rocky/builds/sed/r8` directory.

~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm



## 5 - Debugging a failed package build 

The previous rockybuild process will generate some log files that can be used in debugging failed application builds.  The results and/or logs of the build process are stored under the `~/rocky/builds/<PACKAGE NAME>/r8`. For example `~/rocky/builds/sed/r8`


``` 
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

