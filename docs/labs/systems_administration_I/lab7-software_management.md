---
author: Wale Soyinka
contributors: Steven Spencer, tianci li
tested on: 8.8
tags:
  - lab exercise
  - software management
---

# Lab 7: Managing and installing software

## Objectives

After completing this lab, you will be able to

- Query packages for information
- Install software from binary packages
- Resolve some basic dependencies issues
- Compile and install software from source

Estimated time to complete this lab: 90 minutes

## Binary files and source files

The applications you currently have installed on your system depend on a few factors. The major factor depends on the software package groups selected during the operating system installation. The other factor depends on what has been done to the system since its use. 

You will find that one of your routine tasks as a Systems Administrator is software management. This often involves:

- installing new software
- uninstalling software
- updating already installed software

Software can be installed on Linux based systems using several methods. You can install from source or precompiled binaries. The latter method is the easiest way, but it is also the least customizable. When you install from precompiled binaries most of the work has already been done for you – but even then, you do need to know the name and where to find the particular software you want.

Almost all software originally come as C or "C++" programming language source files. The source programs are usually distributed as archives of source files. Usually  tar’ed or gzip’ed d or bzip2’ed files. This means they come compressed or as a single bundle.

Most developers have made their source code conform to GNU standards, making it easier to share. It also means that the packages will compile on any UNIX or UNIX like system (e.g., Linux).

RPM is the underlying tool for managing applications (packages) on Red Hat based distributions such as  Rocky Linux, Fedora, Red Hat Enterprise Linux (RHEL), openSuSE, Mandrake, and so on.

The applications used for managing software on Linux distributions are called package managers. Examples are:

- The Red Hat Package Manager (`rpm`). The packages have the suffix “ .rpm”
- The Debian package management system (`dpkg`).  The packages have the suffix “ .deb”

Some popular command-line options and syntax for the RPM command are listed next:

**rpm**

Usage: rpm [OPTION...]

**QUERYING PACKAGES**

```
Query options (with -q or --query):
  -c, --configfiles                  list all configuration files
  -d, --docfiles                     list all documentation files
  -L, --licensefiles                 list all license files
  -A, --artifactfiles                list all artifact files
      --dump                         dump basic file information
  -l, --list                         list files in package
      --queryformat=QUERYFORMAT      use the following query format
  -s, --state                        display the states of the listed files
```

**VERIFYING PACKAGES**

```
Verify options (with -V or --verify):
      --nofiledigest                 don't verify digest of files
      --nofiles                      don't verify files in package
      --nodeps                       don't verify package dependencies
      --noscript                     don't execute verify script(s)
```

**INSTALLING, UPGRADING, AND REMOVING PACKAGES**

```
Install/Upgrade/Erase options:
      --allfiles                     install all files, even configurations which might otherwise be skipped
  -e, --erase=<package>+             erase (uninstall) package
      --excludedocs                  do not install documentation
      --excludepath=<path>           skip files with leading component <path>
      --force                        shorthand for --replacepkgs --replacefiles
  -F, --freshen=<packagefile>+       upgrade package(s) if already installed
  -h, --hash                         print hash marks as package installs (good with -v)
      --noverify                     shorthand for --ignorepayload --ignoresignature
  -i, --install                      install package(s)
      --nodeps                       do not verify package dependencies
      --noscripts                    do not execute package scriptlet(s)
      --percent                      print percentages as package installs
      --prefix=<dir>                 relocate the package to <dir>, if relocatable
      --relocate=<old>=<new>         relocate files from path <old> to <new>
      --replacefiles                 ignore file conflicts between packages
      --replacepkgs                  reinstall if the package is already present
      --test                         don't install, but tell if it would work or not
  -U, --upgrade=<packagefile>+       upgrade package(s)
      --reinstall=<packagefile>+     reinstall package(s)
```

## Exercise 1

### Installing, Querying and Uninstalling Packages

In this Lab you will learn how to use the RPM system and you will also install a sample application on your system.

!!! tip

    You have lots of options for where to obtain Rocky Linux packages from. You can manually download them from trusted [or untrusted] repositories. You can get them from the distribution ISO. You can get them from a centrally shared location using protocols such as - nfs, git, https, ftp, smb, cifs and so  on. If you are curious you can view the following official website and browse through the applicable repository for the desired package(s):

    https://download.rockylinux.org/pub/rocky/8.8/

#### To query packages for information.

1. To see a list of all the packages currently installed on your local system type:
   
    ```
    $ rpm -qa
    python3-gobject-base-*
    NetworkManager-*
    rocky-repos-*
    ...<OUTPUT TRUNCATED>...
    ```
    
    You should see a long list.

2. Let us delve a little deeper and learn more about one of the packages installed on the system. We will examine NetworkManager. We will use the --query (-q) and --info (-i) options with the `rpm` command. Type:

    ```
    $ rpm -qi NetworkManager
    Name        : NetworkManager
    Epoch       : 1
    ...<OUTPUT TRUNCATED>...
    ```

   That is a great deal of information (metadata)! 

3. Let us say we are only interested in the Summary field of the previous command. We can use rpm's --queryformat option to filter the information that we get back from the query option.

    For example, to view only the Summary field, type:

    ```
    $ rpm -q --queryformat '%{summary}\n' NetworkManager
    ```

    The name of the field is case insensitive.

4. To view both the Version and Summary fields of the installed NetworkManager package type:

    ```
    $ rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager 
    ```

5. Type the command to view information about the bash package that is installed on the system.
   
    ```
    $ rpm -qi bash
    ```

    !!! note 

        The previous exercises were querying and working with packages that are already installed on the system. In the following exercises, we'll start working with packages not yet installed. We'll use the DNF application to download the packages we'll use in the following steps. 

6. First ensure that the `wget` application is not already installed on the system. Type:

    ```
    $ rpm -q wget
    package wget is not installed
    ```

    It looks like `wget` is not installed on our demo system.

7. As of Rocky Linux 8.x, the `dnf download` command will allow you to get the latest `rpm` package for `wget`. Type:

    ```
    dnf download wget
    ```

8. Use the `ls` command to ensure that the package was downloaded into your current directory. Type:

    ```
    $ ls -lh wg*
    ```

9. Use the `rpm` command to query for information about the downloaded wget-*.rpm. Type:

    ```
    $ rpm -qip wget-*.rpm
    Name        : wget
    Architecture: x86_64
    Install Date: (not installed)
    Group       : Applications/Internet
    ...<TRUNCATED>...
    ```

10. From your output in the previous step, what exactly is the `wget` package? Hint: you can use the rpm query format option to view the description field for the download package. 

11.  If you are interested in the `wget files-.rpm` package, you could list all the files included in the package by typing: 

    ```
    $ rpm -qlp wget-*.rpm | head
    /etc/wgetrc
    /usr/bin/wget
    ...<TRUNCATED>...
    /usr/share/doc/wget/AUTHORS
    /usr/share/doc/wget/COPYING
    /usr/share/doc/wget/MAILING-LIST
    /usr/share/doc/wget/NEWS
    ```

12. Let us view the contents of the `/usr/share/doc/wget/AUTHORS` file that is listed as part of the `wget` package. We will use the `cat` command. Type:

    ```
    $ cat /usr/share/doc/wget/AUTHORS
    cat: /usr/share/doc/wget/AUTHORS: No such file or directory
    ```

    `wget` is not [yet] installed on our demo system! And so, we can't view the AUTHORS file that is packaged with it!

13. View the list of files that come with another package (curl) that is *already* installed on the system. Type:

    ```
    $ rpm -ql curl
    /usr/bin/curl
    /usr/lib/.build-id
    /usr/lib/.build-id/fc
    ...<>...
    ```

    !!! note

        You will notice that you did not have to refer to the full name of the `curl` package in the previous command. This is because `curl` is already installed. 

#### Extended knowledge about package name

* **Full package name** : When you download a package from a trusted source (for example - vendor website, developer repository), the name of the downloaded file is the full package name, such as -- htop-3.2.1-1.el8.x86_64.rpm. When using the `rpm` command to install/update this package, the object operated by the command must be the full name (or matching wildcard equivalent) of the package, such as:
    
    ```
    $ rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
    ```

    ```
    $ rpm -Uvh htop-3.2.1-1.*.rpm
    ```

    ```
    $ rpm -qip htop-3.*.rpm
    ```

    ```
    $ rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
    ```

    The full name of the package follows a naming convention similar to this —— `[Package_Name]-[Version]-[Release].[OS].[Arch].rpm` or `[Package_Name]-[Version]-[Release].[OS].[Arch].src.rpm`

* **Package name**: Because RPM uses a database to manage software, once the package installation is completed, the database will have corresponding records. At this time, the operating object of the `rpm` command only needs to type the package name. such as:

    ```
    $ rpm -qi bash
    ```

    ```
    $ rpm -q systemd
    ```

    ```
    $ rpm -ql chrony
    ```



## Exercise 2

### Package integrity

1. It is possible to download or end up with a corrupted or tainted file. Verify the integrity of the `wget` package that you downloaded. Type:

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
    ```

    The "digests signatures OK" message in the output shows the package is fine. 

2. Let us be malicious and deliberately alter the downloaded package. This can be done by adding anything to, or removing something from, the original package.  Anything that changes the package in a way the original packagers did not intend will corrupt the package. We will alter the file by using the echo command to add the string "haha" to the package. Type:

    ```
    $ echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
    ```

3. Now try to verify the integrity of the package again using rpm's -K option.

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
    ```

    Very different message now. The output "DIGESTS SIGNATURES NOT OK" clearly warns you should not try using or installing the package. It should no longer be trusted.

4. Use the `rm` command to delete the corrupted `wget` package file and download a fresh copy using `dnf`. Type:
    
    ```
    $ rm wget-*.rpm  && dnf download wget
    ```

    Check one more time that the newly downloaded package passes RPMs integrity checks. 

## Exercise 3

### Installing Packages

While trying to install software on your system, you might stumble on “failed dependencies” issues. This is especially common when using the low-level RPM utility to manage applications on a system manually. 

For example, if you try to install package “abc.rpm” the RPM installer might complain about some failed dependencies. It might tell you that package “abc.rpm” requires another package “xyz.rpm” to first be installed. The dependencies issue arises because software applications almost always depend on another software or library. If a required program or shared library is not already on the system, that prerequisite must be satisfied before installing the target application. 

The low-level RPM utility often knows about the inter-dependencies between applications. But it does not usually know how or where to obtain the application or library needed to resolve the issue. Stated another way, RPM knows the *what* and *how* but does not have the built-in ability to answer the *where* question. This is where tools like `dnf`, `yum`, and so on shine. 

#### To install packages

In this exercise you will try to install the `wget` package (wget-*.rpm).

1. Try installing the `wget` application. Use RPM's -ivh command line options. Type:

    ```
    $ rpm -ivh wget-*.rpm
    error: Failed dependencies:
        libmetalink.so.3()(64bit) is needed by wget-*
    ```

    Right away - a dependency problem! The sample output shows that `wget` needs some kind of library file named "libmetalink.so.3"

    !!! note

        According to the output of the test above, the wget-*.rpm package requires that the libmetalink-*.rpm package be installed. In other words, libmetalink is a prerequisite for installing wget-*.rpm. You can forcefully install wget-*.rpm package using the “nodeps” option if you absolutely know what you are doing, but this is generally a BAD practice. 

2. RPM has helpfully given us a hint for what is missing. You will remember that rpm knows the what and how but does not necessarily know the where. Let us use the `dnf` utility to try to figure out the package name that provides the missing library. Type:
    
    ```
    $ dnf whatprovides libmetalink.so.3
    ...<TRUNCATED>...
    libmetalink-* : Metalink library written in C
    Repo        : baseos
    Matched from:
    Provide    : libmetalink.so.3
    ```

3. From the output, we need to download the `libmetalink` package that provides the missing library. Specifically we want the 64bit version of the library. Let us call on a separate utility (`dnf`) to help us find and download the package for our demo 64bit (x86_64) architecture. Type:

    ```
    dnf download --arch x86_64  libmetalink
    ```

4. You should now have at least 2 rpm packages in your working directory. Use the `ls` command to confirm this.

5. Install the missing `libmetalink` dependency. Type:
    
    ```
    $ sudo rpm -ivh libmetalink-*.rpm
    ```

6. With the dependency now installed, we can now revisit our original objective of installing the `wget` package. Type:

    ```
    $ sudo rpm -ivh wget-*.rpm
    ```
    
    !!! note
    
        RPM supports transactions. In the previous exercises, we could have performed a single rpm transaction that included the original package we wanted to install and all the packages and libraries it depended on. A single command such as the one below would have sufficed:

            ```
            $  rpm -Uvh  wget-*.rpm  libmetalink-*.rpm
            ```

7. Moment of truth now. Try running the `wget` program without any option to see if it is installed. Type:

    ```
    $ wget
    ```

8. Let us see `wget` in action. Use `wget` to download a file from the internet from the command line. Type:

    ```
    wget  https://kernel.org
    ```

    This will download the default index.html from kernel.org website!

9. Use `rpm` to view a list of all the files that come with the `wget` application. 
    
10. Use `rpm` to view any documentation that comes packaged with `wget`.
    
11. Use `rpm` to view the list of all the binaries that come installed with the `wget` package. 

12. You had to install the `libmetalink` package in order to install `wget`. Try running or executing `libmetalink` from the command-line. Type:
    
    ```
    $ libmetalink
    -bash: libmetalink: command not found
    ```

    !!! attention

        What gives? Why can't you run or execute `libmetalink`?


#### To import a public key via rpm

!!! tip 

    The GPG keys used for signing packages used in the Rocky Linux project can be obtained from various sources such as - the Project website, ftp site,    distribution media, local source and so on. Just in case the proper key is missing on your RL system's keyring, you can use the `rpm`'s `--import` option to import Rocky Linux’s public key from your local RL system by running: `sudo  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`

!!! question
    
    When installing packages, what is the difference between `rpm -Uvh` and `rpm -ivh`. 
    Consult the man page for `rpm`.

## Exercise 4

### Uninstalling packages

Uninstalling packages is just as easy as installing, with Red Hat’s package manager (RPM).

 In this exercise, you will try to use `rpm` to uninstall some packages from the system. 

#### To uninstall packages

1. Uninstall the `libmetalink` package from your system. Type:

    ```
    $ sudo rpm -e libmetalink
    ```

    !!! question

        Explain why you couldn’t remove the package?


2. The clean and proper way to remove packages using RPM is to remove the package(s) along with their dependencies. To remove `libmetalink` package we will also have to remove the `wget` package that depends on it. Type:

    ```
    $ sudo rpm -e libmetalink wget
    ```

    !!! note
     
        If you want to break the package that relies on libmetalink and *forcefully* remove the package from your system, you can use rpm's `--nodeps` option like this: `$ sudo rpm  -e  --nodeps  libmetalink`.

        **i.** The “nodeps” option means No dependencies. I.e., ignore all dependencies.  
        **ii.** The above is just to show you how to remove a package from your system forcefully. Sometimes you need to do this, but it is generally *not a good practice*.   
        **iii.** Forcefully removing a package “xyz” that another installed package “abc” relies on effectively makes package “abc” unusable or somewhat broken.  

## Exercise 5

### DNF - Package Manager

DNF is a package manager for RPM-based Linux distributions. It is the successor to the popular YUM utility. DNF maintains compatibility with YUM and both utilities share very similar command-line options and syntax.

DNF is one of the many tools for managing RPM-based software such as Rocky Linux. In comparison to `rpm`, these higher-level tools help to simplify installing, uninstalling, and querying packages. It is important to note that these tools make use of the underlying framework provided by the RPM system. This is why it is helpful to understand how to use RPM. 

DNF (and other tools like it) acts as a sort of wrapper around RPM and provides additional functionality not offered by RPM. DNF knows how to deal with package and library dependencies and also knows how to use configured repositories to resolve most issues automatically. 

Common options used with the `dnf` utility are:

```
    usage: dnf [options] COMMAND

    List of Main Commands:

    alias                     List or create command aliases
    autoremove                remove all unneeded packages that were originally installed as dependencies
    check                     check for problems in the packagedb
    check-update              check for available package upgrades
    clean                     remove cached data
    deplist                   [deprecated, use repoquery --deplist] List package's dependencies and what packages provide them
    distro-sync               synchronize installed packages to the latest available versions
    downgrade                 Downgrade a package
    group                     display, or use, the groups information
    help                      display a helpful usage message
    history                   display, or use, the transaction history
    info                      display details about a package or group of packages
    install                   install a package or packages on your system
    list                      list a package or groups of packages
    makecache                 generate the metadata cache
    mark                      mark or unmark installed packages as installed by user.
    module                    Interact with Modules.
    provides                  find what package provides the given value
    reinstall                 reinstall a package
    remove                    remove a package or packages from your system
    repolist                  display the configured software repositories
    repoquery                 search for packages matching keyword
    repository-packages       run commands on top of all packages in given repository
    search                    search package details for the given string
    shell                     run an interactive DNF shell
    swap                      run an interactive DNF mod for remove and install one spec
    updateinfo                display advisories about packages
    upgrade                   upgrade a package or packages on your system
    upgrade-minimal           upgrade, but only 'newest' package match which fixes a problem that affects your system

```

#### To use `dnf` for package installation

Assuming you have already uninstalled the `wget` utility from an exercise, we will use DNF to install the package in the following steps. The 2-3 step process that we needed earlier when we installed `wget` via `rpm` should be reduced to a one steps process using `dnf`. `dnf` will quietly resolve any dependencies. 

1. First, let us ensure that `wget` and `libmetalink` are uninstalled from the system. Type:

    ```
    $ sudo rpm -e wget libmetalink
    ```
    
    After removing, if you try running `wget` from the CLI you see a message like *wget: command not found*

2. Now use dnf to install `wget`. Type:

    ```
    $ sudo dnf -y install wget
    Dependencies resolved.
    ...<TRUNCATED>...
    Installed:
    libmetalink-*           wget-*
    Complete!
    ```

    !!! tip

        The "-y" option used in the preceding command suppresses the "[y/N]" prompt to confirm the action that `dnf` is about to perform. This means that all confirmation actions (or interactive responses) will be "yes" (y).


3. DNF provides an "Environment Group" option that makes adding a new feature set to a system easy. To add the feature, you would typically have to install a few packages individually, but using `dnf`, all you need to know is the name or description of the feature you want. Use `dnf` to display a list of all the groups available to you. Type:

    ```
    $ dnf group list
    ```

4. We are interested in the "Development Tools" group/feature. Let us get more information about that group. Type:
  
    ```
   $ dnf group info "Development Tools"
   ```

5. Later, we will need some programs with the "Development Tools" group. Install the "Development Tools" group using `dnf` by running:

    ```
    $ sudo dnf -y group install "Development Tools"
    ```

#### To use `dnf` for uninstalling packages


1. To use `dnf` to uninstall the `wget` package type:

    ```
    $ sudo dnf -y remove wget
    ```

2. Use `dnf` to ensure the package has indeed been removed from the system. Type:

    ```
    $ sudo dnf -y remove wget
    ```

3. Try using/running `wget`. Type:

    ```
    $ wget
    ```

#### To use `dnf` for package update

DNF can check for and install the latest version of individual packages available in repositories. It can also be used to install specific versions of packages. 

1. Use the list option with `dnf` to view all available versions of the `wget` program that are available for your system. Type

    ```
    $ dnf list wget
    ```

2. If you only want to see if there are updated versions available for a package, use the check-update option with `dnf`. For example, for the `wget` package type:

    ```
    $ dnf check-update wget
    ```

3. Now list all the available versions for the kernel package for your system. Type:

    ```
    $ sudo dnf list kernel
    ```

4. Now check if any updated packages are available for the installed kernel package. Type:

    ```
    $ dnf  check-update kernel
    ```

5. Updates to packages might be due to bug fixes, new features or security patches. To view if there are any security related updates for the kernel package, type:

    ```
    $ dnf  --security check-update kernel
    ```

#### To use `dnf` for system updates

DNF can be used to check for and install the latest versions all packages installed on a system. Periodically checking for installing updates is an important aspect of system administration. 

1. To check if there are any updates for the packages you currently have installed on your system, type:

    ```
    $ dnf check-update
    ```

2. To check if there are any security related updates for all packages installed on your system, type:

    ```
    $ dnf --security check-update
    ```

3. To update the entire packages installed on your system to the most up-to-date versions available for your distribution run:

    ```
    $ dnf -y check-update
    ```

## Exercise 6

### Building Software from Source

All software/applications/packages originate from plain human-readable text files. The files are collectively known as source code. The RPM packages that are installed on Linux distributions are born from source code. 

In this exercise you are going to download, compile and install a sample program from its original source files. For convenience, source files are usually distributed as a single compressed file called a tar-ball (pronounced tar-dot-gee-zee).

The following exercises will be based on the venerable Hello project source code. `hello` is a simple command-line application written in C++, that does nothing more than print "hello" to the terminal. You can learn more about [the project here](http://www.gnu.org/software/hello/hello.html)

#### To download the source file

1. Use `curl` to download the latest source code for the `hello` application. Let us download and save the file in the Downloads folder. 

    https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### To un-tar the file

1. Change to the directory on your local machine where you downloaded the hello source code.

2. Unpack (un-tar) the tarball using the `tar` program. Type:

    ```
    $ tar -xvzf hello-2.12.tar.gz
    hello-2.12/
    hello-2.12/NEWS
    hello-2.12/AUTHORS
    hello-2.12/hello.1
    hello-2.12/THANKS
    ...<TRUNCATED>...
    ```

3. Use the `ls` command to view the contents of your pwd.

    A new directory named  hello-2.12 should have been created for you during the un-taring.

4. Change to that directory and list its contents. Type:

    ```
    $ cd hello-2.12 ; ls
    ```

5. It is always good practice to review any special installation instructions that might be come with the source code. Those files usually have names like: INSTALL, README and so on.

    Use a pager to open up the INSTALL file and read it. Type:

    ```
    $ less INSTALL
    ```

    Exit the pager when you are done reviewing the file.

#### To configure the package

Most applications have features that can be enabled or disabled by the user. This is one of the benefits of having access to the source code and installing from the same. You have control over configurable features that the application has; this is in contrast to accepting everything a package manager installs from pre-compiled binaries.

The script that usually lets you configure the software is usually aptly named “configure”

1. Use the `ls` command again to ensure that you indeed have a file named *configure* in your pwd.  

2. To see all the options, you can enable or disable in the `hello` program type:

    ```
    $ ./configure --help
    ```

    !!! question

        From the output of the command what does the “--prefix” option do?

3. If you are happy with the default options that the configure script offers. Type:

    ```
    $ ./configure
    ```

    !!! note

        Hopefully the configure stage went smoothly and you can go on to the compilation stage.

    If you got some errors during the configure stage, you should carefully look through the tail-end of the output to see the source of the error. The errors are *sometimes* self-explanatory and easy to fix. For example, you might see an error like:

    configure: error: no acceptable C compiler found in $PATH

    The above error simply means that you don’t have a C Compiler (e.g., gcc) installed on the system or the compiler is installed somewhere that is not in your PATH variable.

#### To compile the package

You will build the hello application in the following steps. This is where some of the programs that come with the Development Tools group that you installed earlier using DNF come in handy. 

1. Use the make command to compile the package after running the “configure” script. Type:

    ```
    $ make
    ...<OUTPUT TRUNCATED>...
    gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
    make[2]: Leaving directory '/home/rocky/hello-2.12'
    make[1]: Leaving directory '/home/rocky/hello-2.12'
    ```

    If all goes well - this important `make` step is the step that will help generate the final `hello` application binary.

2. List the files in your current working directory again. You should see some newly created files in there including the `hello` program.

#### To install the application

Amongst other housekeeping tasks, the final installation step also involves copying any application binaries and libraries over to the proper folders. 

1. To install the hello application run the make install command. Type:

    ```
    $ sudo make install
    ```

    This will install package into the location specified by the default prefix (--prefix) argument that may have been used with the “configure” script earlier. If no --prefix was set, a default prefix of `/usr/local/` will be used. 

#### To run the hello program

1. Use the `whereis` command to see where the `hello` program is on your system. Type:
   
    ```
    $ whereis hello
    ```

2. Try running the `hello` application to see what it does. Type:
   
    ```
    $ hello
    ```

3. Run `hello` again, with the `--help` option to see the other things it can do.

4. Using `sudo`, run `hello` again as a superuser. Type:
   
    ```
    $ sudo hello
    ```

    !!! tip
    
        It is good practice to test a program as a regular user to ensure that regular users can indeed use the program. It is possible that the permissions on the binary are set incorrectly such that only the super-user can use the programs. This of course assumes that you indeed want regular users to be able to use the program.

5. That is it. This lab is complete!

## Exercise 7

### Checking file integrity after package installation

After installing relevant packages, in some cases, we need to determine whether the associated files have been modified to prevent malicious modifications by others.

#### File verification

Using the "-V" option of the `rpm` command.

Take the time synchronization program chrony as an example to illustrate the meaning of its output. It is assumed that you have installed chrony and modified the configuration file (/etc/chrony.conf)

```
$ rpm -V chrony
S.5....T.  c /etc/chrony.conf
```

* **S.5....T.**: Indicates 9 useful information in the validation file content, and the unmodified ones are represented by ".". These 9 useful information are:
  * S: Whether the size of the file has been modified.
  * M: Whether the type of file or file permissions (rwx) have been modified.
  * 5: Whether the file MD5 checksum has modified.
  * D: Whether the number of the device has been modified.
  * L: Whether the path to the file has been modified.
  * U: Whether the owner of the file has been modified.
  * G: Whether the group to which the file belongs has been modified.
  * T: Whether the mTime (modify time) of the file has been modified.
  * P: Whether the program function has been modified.

* **c**: Indicates modifications to the configuration file. It can also be the following values:
  * d: documentation file.
  * g: ghost file. Very few can be seen.
  * l: license file.
  * r: readme file.

* **/etc/chrony.conf**: Represents the path of the modified file.
