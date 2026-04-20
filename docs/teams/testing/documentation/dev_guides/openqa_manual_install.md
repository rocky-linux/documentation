---
title: Manual Install of openQA for rockylinux
author: Alan Marshall
version: v1.2
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  level: Issue
render_macros: true
---


#### Intended Audience
Those who wish to use the openQA automated testing system configured for Rocky Linux tests. If so, you will need a PC or server with hardware virtualisation running an up-to-date Fedora Linux, or RockyLinux >= 9.6.

### Introduction
This guide explains the use of the openQA automated testing system to test various aspects of Rocky Linux releases either at the pre-release stage or thereafter.

openQA is an automated test tool that makes it possible to test the whole installation process. It uses virtual machines which it sets up to reproduce the process, check the output (both serial console and GUI screen) in every step and send the necessary keystrokes and commands to proceed to the next step. openQA checks whether the system can be installed, whether it works properly, whether applications work and whether the system responds as expected to different installation options and commands.

Rocky Linux openQA tests can be found in the [os-autoinst-distri-rocky](https://github.com/rocky-linux/os-autoinst-distri-rocky) repository

openQA can run numerous combinations of tests for every revision of the operating system, reporting the errors detected for each combination of hardware configuration, installation options and variant of the operating system.

### WebUI
The web UI is a very useful feature of the openQA system since it provides an easily accessed view of the progress and details of openQA tests either on the local machine or remotely or both. It is intended to be intuitive and self-explanatory.

Some pages use queries to select what should be shown. The query parameters are generated on clickable links, for example starting from the index page or the group overview page clicking on single builds. On the query pages there can be UI elements to control the parameters, for example to look for older builds or show only failed jobs, or other settings. Additionally, the query parameters can be tweaked by hand if you want to provide a link to specific views.

## Step-by-step Install Guide

openQA can be installed only on a Fedora, OpenSUSE, or RockyLinux(>=9.6) server or workstation. The following install procedure was tested on Fedora 40 Server. You can use either a local terminal or an ssh login from another host on the lan.

```
# install Packages
# for openqa
sudo dnf install -y openqa openqa-httpd openqa-worker fedora-messaging python3-jsonschema
sudo dnf install -y perl-REST-Client.noarch

# and for createhdds
sudo dnf install -y libguestfs-tools libguestfs-xfs python3-fedfind python3-libguestfs
sudo dnf install -y libvirt libvirt-daemon-config-network libvirt-python3 virt-install withlock

# configure httpd:
cd /etc/httpd/conf.d/
sudo cp openqa.conf.template openqa.conf
sudo cp openqa-ssl.conf.template openqa-ssl.conf
sudo setsebool -P httpd_can_network_connect 1
sudo systemctl restart httpd

# configure the web UI
sudoedit /etc/openqa/openqa.ini
[global]
branding=plain
download_domains = rockylinux.org
[auth]
method = Fake

sudo dnf install postgresql-server
sudo postgresql-setup --initdb

# enable and start services
sudo systemctl enable postgresql --now
sudo systemctl enable httpd --now
sudo systemctl enable openqa-gru --now
sudo systemctl enable openqa-scheduler --now
sudo systemctl enable openqa-websockets --now
sudo systemctl enable openqa-webui --now
sudo systemctl enable fm-consumer@fedora_openqa_scheduler --now
sudo systemctl enable libvirtd --now
sudo setsebool -P httpd_can_network_connect 1
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
sudo systemctl restart httpd

# to create API key in local web interface at http://localhost
#   or on remote system   http://<ip addr>
# Click Login, then Manage API Keys, create a key and secret.

# insert key and secret
sudoedit /etc/openqa/client.conf

[localhost]
key = ...
secret = ...

# create workers
sudo systemctl enable openqa-worker@1 --now
# then ...@2 ...etc as desired. Look in webui workers to check shown idle.
# as a rule of thumb, you can have about half the number of workers as cores

# get Rocky tests
cd /var/lib/openqa/tests/
sudo git clone https://github.com/rocky-linux/os-autoinst-distri-rocky.git rocky
sudo chown -R geekotest:geekotest rocky
cd rocky

# when working in /var/lib/openqa nearly all commands need sudo.

sudo git config --global --add safe.directory /var/lib/openqa/share/tests/rocky

sudo git checkout develop
# or whichever branch has the latest updates for your tests

sudo ./fifloader.py -l -c templates.fif.json
sudo git clone https://github.com/rocky-linux/createhdds.git  ~/createhdds
sudo mkdir -p /var/lib/openqa/share/factory/hdd/fixed

# will need about 200GB disk space available for ongoing tests
cd /var/lib/openqa/factory/hdd/fixed

# start a long running process that provides hdd image files for ongoing tests
~/createhdds/createhdds.py -t -b stg all

# get Rocky iso files for testing from staging repository
sudo mkdir -p /var/lib/openqa/share/factory/iso/fixed
cd /var/lib/openqa/factory/iso/fixed

sudo curl -LOR https://dl.rockylinux.org/stg/rocky/9/isos/x86_64/Rocky-9.3-x86_64-boot.iso
sudo curl -LOR https://dl.rockylinux.org/stg/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
sudo curl -LOR https://dl.rockylinux.org/stg/rocky/9/isos/x86_64/Rocky-9.3-x86_64-dvd.iso
sudo curl -LOR https://dl.rockylinux.org/stg/rocky/9/isos/x86_64/CHECKSUM

sha256sum -c CHECKSUM

# fix ownership, add <user> to group, reboot
cd /var/lib/openqa/factory/
sudo chown -R geekotest:geekotest ./
sudo usermod -aG geekotest <user>
sudo init 6

# post tests and view progress on webui
cd /var/lib/openqa/tests/rocky/
sudo ./fifloader.py -c -l templates.fif.json
sudo openqa-cli api -X POST isos ISO=Rocky-9.3-x86_64-minimal.iso ARCH=x86_64 DISTRI=rocky FLAVOR=minimal-iso VERSION=9.3 BUILD="$(date +%Y%m%d.%H%M%S).0"-minimal
sudo openqa-cli api -X POST isos ISO=Rocky-9.3-x86_64-boot.iso ARCH=x86_64 DISTRI=rocky FLAVOR=boot-iso VERSION=9.3 BUILD="$(date +%Y%m%d.%H%M%S).0"-boot
and for a  full build (this will post 95 jobs)
sudo openqa-cli api -X POST isos ISO=Rocky-9.3-x86_64-dvd.iso ARCH=x86_64 DISTRI=rocky FLAVOR=dvd-iso VERSION=9.3 BUILD="$(date +%Y%m%d.%H%M%S).0"-dvd-iso
sudo openqa-cli api -X POST isos ISO=Rocky-9.3-x86_64-dvd.iso ARCH=x86_64 DISTRI=rocky FLAVOR=universal VERSION=9.3 BUILD="$(date +%Y%m%d.%H%M%S).0"-universal
```
You can watch progress of these tests on the webui on any browser on the same lan as the test host at 

```http://<ip_addr_of_test_host>/tests```

If you click "login" in the top right corner you will be able to control tests from the webui.

At this point the multi-vm tests will fail or be skipped. This is because at the moment your system is configured for single vm deployment and it can be used as such. Pause your installation here if you wish to get some practice using openQA before progressing further (recommended).

Installation of facilities for multi-vm testing, which is substantially more complicated, will be described in this document in a later revision (watch this space).


### Helpers

#### Createhdds
```Createhdds``` is used to prepare ```.img``` and ```.qcow2``` files for some of the Rocky tests. If you ran the above procedure you will have noticed that it produces a number of files in ```/var/lib/openqa/factory/hdd/fixed``` determined by the files provided in [createhdds](https://github.com/rocky-linux/createhdds).

#### openqa-cli

Tests are normally posted using ```openqa-cli``` as you have already used above. Test parameters are listed and explained in the [openQA VARIABLES definition document](https://github.com/rocky-linux/os-autoinst-distri-rocky/blob/develop/VARIABLES.md)

#### Scripts
[helper scripts](https://github.com/rocky-linux/os-autoinst-distri-rocky/tree/develop/scripts) - 
```cancel-build.sh``` is especially useful when you discover that you have initiated a large build and got it wrong... d'oh.

### Using Templates

#### Challenge
One of the challenges that arises when testing an operating system, especially when doing continuous testing, is that there is always a certain combination of jobs, each one with its own settings, that needs to be run for every revision. These combinations can be different for different ```FLAVORs``` of the same revision, like running a different set of jobs for each architecture. This combinational problem can go one step further if openQA is being used for different kinds of tests, like running some simple pre-integration tests for some snapshots combined with more comprehensive post-integration tests for release candidates.

This section describes how an instance of openQA *could* be configured using the options in the admin area of the webUI to automatically create all the required jobs for each revision of your operating system that needs to be tested. *If* you were starting from scratch (the difficult way), you would probably go through the following order:

1. Define machines in 'Machines' menu
1. Define medium types (products) you have in 'Medium types' menu
1. Specify various collections of tests you want to run in the 'Test suites' menu
1. Define job groups in 'Job groups' menu for groups of tests
1. Select individual 'Job groups' and decide what combinations make sense and need to be tested

If you followed the install guide above then the cloned Rocky tests from [os-autoinst-distri-rocky](https://github.com/rocky-linux/os-autoinst-distri-rocky) will have pre-configured the admin area of the webUI. You may find it useful to consult when reading the following sections.

Machines, mediums, test suites and job templates can all set various configuration variables. The job templates within the job groups define how the test suites, mediums and machines should be combined in various ways to produce individual 'jobs'. All the variables from the test suite, medium, machine and job template are combined and made available to the actual test code run by the 'job', along with variables specified as part of the job creation request. Certain variables also influence openQA’s and/or os-autoinst’s own behavior in terms of how it configures the environment for the job.

The configuration is set up from ```/var/lib/openqa/tests/rocky/templates.fif.json```

#### Machines
You need to have at least one machine set up to be able to run any tests. These machines represent virtual machine types that you want to test. Realistically to make tests actually happen, you have to have a number of ```openQA workers``` connected that can fulfill these specifications.

- ```Name``` User defined ```string``` - only needed for operator to identify the machine configuration.
- ```Backend``` What ```backend``` should be used for this ```machine``` Recommended value is ```qemu``` as it is the most tested one, but other options such as ```kvm2usb``` or ```vbox``` are also possible.
- ```Variables``` Most machine variables influence os-autoinst’s behavior in terms of how the test machine is set up. A few important examples:
    - ```QEMUCPU``` can be ```qemu32``` or ```qemu64``` and specifies the architecture of the virtual CPU
    - ```QEMUCPUS``` is an ```integer``` that specifies the number of cores you wish to be used

    - ```USBBOOT``` when set to ```1``` the image will be loaded through an emulated USB stick.

#### Medium Types
- ```product```
    - A medium type ```product``` in openQA is a simple description without any definite meaning. It basically consists of a ```name``` and a set of ```variables``` that define or characterise this product in os-autoinst.

Some example variables are:

- ```ISO_MAXSIZE``` contains the maximum size of the ```product```. There is a test that checks that the current size of the product is less or equal than this variable.
- ```DVD``` if it is set to ```1``` this indicates that the medium is a DVD.
- ```LIVECD``` if it is set to ```1``` this indicates that the medium is a live image (can be a ```CD``` or ```USB```)
- ```GNOME``` this variable, if it is set to ```1``` indicates that it is a ```GNOME``` only distribution.
- ```RESCUECD``` is set to ```1``` for rescue CD images.

#### Test Suites
A test suite consists of a name and a set of test variables that are used inside this particular test together with an optional description. The test variables can be used to parameterise the actual test code and influence the behaviour according to the settings.

Some sample variables are:

- ```DESKTOP``` possible values are ```kde``` ```gnome``` ```lxde``` ```xfce``` or ```textmode```. Used to indicate the desktop selected by the user during the test.
- ```ENCRYPT``` encrypt the home directory via ```YaST```
- ```HDDSIZEGB``` hard disk size in GB.
- ```HDD_1``` path for the pre-created hard disk
- ```RAIDLEVEL RAID``` configuration variable

#### Job Groups
The job groups are the place where the actual test scenarios are defined by the selection of the medium type, the test suite and machine together with a priority value.

The priority value is used in the scheduler to choose the next job. If multiple jobs are scheduled and their requirements for running them are fulfilled the ones with a lower priority value are triggered. The id is the second sorting key of two jobs with equal requirements and same priority value the one with lower id is triggered first.

Job groups themselves can be created over the web UI as well as the REST API. Job groups can optionally be nested into categories. The display order of job groups and categories can be configured by drag-and-drop in the web UI.

The scenario definitions within the job groups can be created and configured by different means:

- A simple web UI wizard which is automatically shown for job groups when a new medium is added to the job group.
- An intuitive table within the web UI for adding additional test scenarios to existing media including the possibility to configure the priority values.
- The scripts ```openQA-load-templates``` and ```openQA-dump-templates``` to quickly dump and load the configuration from custom plain-text dump format files using the REST API.
- Using declarative schedule definitions in the YAML format using REST API routes or an online-editor within the web UI including a syntax checker.

### Needles
Needles are very precise and the slightest deviation from the specified display will be detected. This means that every time there is a new release, very small changes occur in layout of displays resulting in many new or modified needles being required. There is always a significant amount of work needed by the Test Team to produce the automatic tests for a new version.

A very useful feature of the webui is the online needle editor. When a test fails for a missing needle, the needle editor can be activated by clicking the icon and a new needle can be created, usually by copying a similar needle together with the current screenshot. The needle files are saved in the  ```/var/lib/openqa/tests/rocky/needles directory```

### Upstream Documentation
[Starter Guide](http://open.qa/docs/) and [Upstream documentation](https://github.com/os-autoinst/openqa/blob/master/docs/Installing.asciidoc) are useful for reference but since they are a mixture of advice and instructions relating to openSUSE and Fedora which have substantial differences between them it is not always clear which are significant for Rocky.  However, as an rpm based distribution, Rocky Linux use is loosely related to the [Fedora](https://fedoraproject.org/wiki/OpenQA) version.

### Glossary
The following terms are used within the context of openQA:-

- test module
    - An individual test case in a single perl module ```.pm``` file, e.g. ```sshxterm``` If not further specified a test module is denoted with its short ```name``` equivalent to the filename including the test definition. The full ```name``` is composed of the test group, which itself is formed by the top-folder of the test module file, and the short name, e.g. ```x11-sshxterm``` (for ```x11/sshxterm.pm```)

- test suite
    - A collection of test modules, e.g. ```textmode``` All test modules within one test suite are run serially

    - One run of individual test cases in a row denoted by a unique number for one instance of openQA, e.g. one installation with subsequent testing of applications within ```gnome```

- test run
    - Equivalent to job
- test result
    - The result of one job, e.g. ```passed``` with the details of each individual test module
- test step
    - the execution of one test module within a job

- distri
    - A test distribution but also sometimes referring to a ```product``` (CAUTION: ambiguous, historically a "GNU/Linux distribution"), composed of multiple test modules in a folder structure that composes test suites, e.g. ```rocky``` (test distribution, short for ```os-autoinst-distri-rocky```)

- product
    - The main ```system under test (SUT)```  e.g. ```rocky``` also called ```Medium Types``` in the web interface of openQA

- job group
    - Equivalent to product, used in context of the webUI

- version
    - One version of a product, don’t confuse with ```build```

- flavor
    - Keyword for a specific variant of a product to distinguish differing variants, e.g. ```dvd-iso```

- arch
    - An architecture variant of a product, e.g. ```x86_64```

- machine
    - Additional variant of machine, e.g. used for ```64bit``` ```bios``` ```uefi``` etc.

- scenario
    - A composition of ```<distri>-<version>-<flavor>-<arch>-<test_suite>@<machine>``` e.g. ```Rocky-9-dvd-x86_64-gnome@64bit```

- build
    - Different versions of a product as tested, can be considered a ```sub-version``` of ```version```, e.g. ```Build1234``` CAUTION: ambiguity: either with the prefix ```build``` included or not

### History (briefly)
openQA started with OS-autoinst: automated testing of Operating Systems
The OS-autoinst project aims at providing a means to run fully automated tests, especially to run tests of basic and low-level operating system components such as bootloader, kernel, installer and upgrade, which can not easily be tested with other automated testing frameworks. However, it can just as well be used to test firefox and openoffice operation on top of a newly installed OS.
openQA is a test-scheduler and web-front for openSUSE and Fedora using OS-autoinst as a backend.
openQA originated at openSuse and was adopted by Fedora as the automated test system for their frequent distribution updates. Maintenance activity is fairly intense and is ongoing at various levels of users. openQA was adopted by Rocky Linux Test Team as the preferred automated testing system for the ongoing releases of it's distribution.
openQA is free software released under the GPLv2 license.

### Attribution
This guide is heavily inspired by the numerous upstream documents in which installation and usage of OS-autoinst and openQA are described.

### References
Since Rocky Linux use of openQA is drawn from upstream Fedora and hence openSUSE this document contains **many** passages which are edited versions of upstream documentation and that use is hereby gratefully acknowledged. As with many open source projects, we build on previous work.

See also: [Installation Info](https://github.com/rocky-linux/OpenQA-Fedora-Installation) for more details.

### Revision History

* v1.2 - 2026/04/16 - Add content_bottom.md include
* v1.1 - 2025/06/05 - Minor updates
* v1.0 - 2024/04/30 - First Issue

{% include 'teams/testing/content_bottom.md' %}

