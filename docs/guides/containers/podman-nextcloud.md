---
title: Nextcloud on Podman
author: Ananda Kammampati
contributors: Ezequiel Bruni, Steven Spencer
tested_with: 8.5
tags:
  - podman
  - containers
  - nextcloud
---
# Running Nextcloud as a Podman Container on Rocky Linux

## Introduction

This document explains all the required steps needed to build and run a [Nextcloud](https://nextcloud.com) instance as a Podman container on Rocky Linux. What's more, this entire guide was tested on a Raspberry Pi, so it should be compatible with every Rocky-supported processor architecture.

The procedure is broken down into multiple steps, each with its own shell scripts for automation:

1. Installing the `podman` and `buildah` packages to manage and build our containers, respectively
2. Creating a base image which will be repurposed for all of the containers we'll need
3. Creating a `db-tools` container image with the required shell scripts for building and running your MariaDB database
4. Creating and running MariaDB as a Podman container
5. Creating and running Nextcloud as a Podman container, using the MariaDB Podman container as backend

You could run most of the commands in the guide manually, but setting up a few bash scripts will make your life a lot easier, especially when you want to repeat these steps with different settings, variables, or container names.

!!! Note "Note for Beginners:"

    Podman is tool for managing containers, specifically OCI (Open Containers Initiative) containers. It's designed to be pretty much Docker-compatible, in that most if not all of the same commands will work for both tools. If "Docker" means nothing to you—or even if you're just curious—you can read more about Podman and how it works on [Podman's own website](https://podman.io).

    `buildah` is a tool that builds Podman container images based on "DockerFiles".

    This guide was designed as an exercise to help people get familiar with running Podman containers in general, and on Rocky Linux specifically.

## Prerequisites and Assumptions

Here's everything you'll need, or need to know, in order to make this guide work:

* Familiarity with the command line, bash scripts, and editing Linux configuration files.
* SSH access if working on a remote machine.
* A command-line based text editor of your choice. We'll be using `vi` for this guide. 
* An internet-connected Rocky Linux machine (again, a Raspberry Pi will work nicely).
* Many of these commands must be run as root, so you'll need a root or sudo-capable user on the machine.
* Familiarity with web servers and MariaDB would definitely help.
* Familiarity with containers and maybe Docker would be a *definite* plus, but is not strictly essential.

## Step 01: Install `podman` and `buildah`

First, make sure your system is up-to-date:

```bash
dnf update
```

Then you'll want to install the `epel-release` repository for all the extra packages we'll be using.

```bash
dnf -y install epel-release 
```

Once that's done, you can update again (which sometimes helps) or just go ahead and install the packages we need:

```bash
dnf -y install podman buildah
```

Once they're installed, run `podman --version` and `buildah --version` to make sure everything is working correctly.

To access Red Hat's registry for downloading container images, you'll need to run:

```bash
vi /etc/containers/registries.conf
```

Find the section that looks like what you see below. If it's commented out, uncomment it.

```
[registries.insecure]
registries = ['registry.access.redhat.com', 'registry.redhat.io', 'docker.io'] 
insecure = true
```

## Step 02: Create the `base` Container Image

In this guide, we're working as the root user, but you can do this in any home directory. Change to the root directory if you're not already there:

```bash
cd /root
```

Now make all of the directories you'll need for your various container builds:

```bash
mkdir base db-tools mariadb nextcloud
```

Now change your working directory to the folder for the base image:

```bash
cd /root/base
```

And make a file called DockerFile. Yes, Podman uses them too.

```bash
vi Dockerfile
```

Copy and paste the following text into your brand new DockerFile.

```
FROM rockylinux/rockylinux:latest
ENV container docker
RUN yum -y install epel-release ; yum -y update
RUN dnf module enable -y php:7.4
RUN dnf install -y php
RUN yum install -y bzip2 unzip lsof wget traceroute nmap tcpdump bridge-utils ; yum -y update
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
```

Save and close the previous file, and make a new bash script file: 

```bash
vi build.sh
```

Then paste in this content:

```
#!/bin/bash
clear
buildah rmi `buildah images -q base` ;
buildah bud --no-cache -t base . ;
buildah images -a
```

Now make your build script executable with:

```bash
chmod +x build.sh
```

And run it:

```bash
./build.sh
```

Wait until it's done, and move on to the next step.

## Step 03: Create the `db-tools` Container Image  

For the purposes of this guide, we're keeping the database setup as simple as we can. You'll want to keep track of the following, and modify them as needed:

* Database name: ncdb
* Database user: nc-user
* Database pass: nc-pass
* Your server IP address (we'll be using an example IP below)

First, change to the folder where you'll be building the db-tools image:

```bash
cd /root/db-tools
```

Now set up some bash scripts that will be used inside the Podman container image. First, make the script that will automatically build your database for you: 

```bash
vi db-create.sh
```

Now copy and paste the following code into that file, using your favorite text editor:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
create database ncdb;
grant all on ncdb.* to 'nc-user'@'10.1.1.160' identified by 'nc-pass';
flush privileges;
eof
```

Save and close, then repeat the steps with the script for deleting databases as needed:

```bash
vi db-drop.sh
```

Copy and paste this code into the new file:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
drop database ncdb;
flush privileges;
eof
```

Lastly, let's setup the DockerFile for the `db-tools` image:

```bash
vi Dockerfile
```

Copy and paste:

```
FROM localhost/base
RUN yum -y install mysql
WORKDIR /root
COPY db-drop.sh db-drop.sh
COPY db-create.sh db-create.sh
```

And last but not least, create the bash script to build your image on command:

```bash
vi build.sh
```

The code you'll want:

```
#!/bin/bash
clear
buildah rmi `buildah images -q db-tools` ;
buildah bud --no-cache -t db-tools . ;
buildah images -a
```

Save and close, then make the file executable:

```bash
chmod +x build.sh
```

And run it:

```bash
./build.sh
```

## Step 04: Create the MariaDB container image 

You're getting the hang of the process, right? It's time to build that actual database container. Change the working directory to `/root/mariadb`:

```bash
cd /root/mariadb
```

Make a script to (re)build the container whenever you want:

```bash
vi db-init.sh
```

And here's the code you'll need:

!!! warning

    For the purposes of this guide, the following script will delete all Podman Volumes. If you have other applications running with their own volumes, modify/comment the line "podman volume rm --all";

```
#!/bin/bash
clear
echo " "
echo "Deleting existing volumes if any...."
podman volume rm --all ;
echo " "
echo "Starting mariadb container....."
podman run --name mariadb --label mariadb -d --net host -e MYSQL_ROOT_PASSWORD=rockylinux -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb-data:/var/lib/mysql/data:Z mariadb ;

echo " "
echo "Initializing mariadb (takes 2 minutes)....."
sleep 120 ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;

echo " "
echo "Listing podman volumes...."
podman volume ls
```

Here's where you make a script to reset your database whenever you like:

```bash
vi db-reset.sh
```

And here's the code:

```
#!/bin/bash
clear
echo " "
echo "Deleting ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-drop.sh ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;
```

And lastly, here's your build script that'll put the whole mariadb container together:

```bash
vi build.sh
```

With its code:

```
#!/bin/bash
clear
buildah rmi `buildah images -q mariadb` ;
buildah bud --no-cache -t mariadb . ;
buildah images -a
```

Now just make your DockferFile (`vi Dockerfile`), and paste in the following single line:

```
FROM arm64v8/mariadb
```

Now make your build script executable and run it:

```bash
chmod +x *.sh

./build.sh
```

## Step 05: Build and Run the Nextcloud Container

We're at the final step, and the process pretty much repeats itself. Change to the Nextcloud image directory:

```bash
cd /root/nextcloud
```

Set up your DockerFile first this time, for variety:

```bash
vi Dockerfile
```

!!! note

    This next bit assumes ARM architecture (for the Raspberry Pi), so if you are using another architecture, remember to change this. 

And paste in this bit:

```
FROM arm64v8/nextcloud
```

Npw create your build script:

```bash
vi build.sh
```

And paste in this code:

```
#!/bin/bash
clear
buildah rmi `buildah images -q nextcloud` ;
buildah bud --no-cache -t nextcloud . ;
buildah images -a
```

Now, we're going to set up a bunch of local folders on the host server (*not* in any Podman container), so that we can rebuild our containers and databases without fear of losing all of our files:

```bash
mkdir -p /usr/local/nc/nextcloud /usr/local/nc/apps /usr/local/nc/config /usr/local/nc/data
```

Lastly, we're going to create the script that will actually build the Nextcloud container for us:

```bash
vi run.sh
```

And here's all the code you need for that. Make sure you change the IP address for `MYSQL_HOST` to the docker container that's running your MariaDB instance.

```
#!/bin/bash
clear
echo " "
echo "Starting nextloud container....."
podman run --name nextcloud --net host --privileged -d -p 80:80 \
-e MYSQL_HOST=10.1.1.160 \
-e MYSQL_DATABASE=ncdb \
-e MYSQL_USER=nc-user \
-e MYSQL_PASSWORD=nc-pass \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=rockylinux \
-e NEXTCLOUD_DATA_DIR=/var/www/html/data \
-e NEXTCLOUD_TRUSTED_DOMAINS=10.1.1.160 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /usr/local/nc/nextcloud:/var/www/html \
-v /usr/local/nc/apps:/var/www/html/custom_apps \
-v /usr/local/nc/config:/var/www/html/config \
-v /usr/local/nc/data:/var/www/html/data \
nextcloud ;
```

Save and close that out, make all of your scripts executable, then run the image building script first: 

```bash
chmod +x *.sh

./build.sh
```

To make sure all of your images have been built correctly, run `podman images`. You should see a list that looks like this:

```
REPOSITORY                      TAG    IMAGE ID     CREATED      SIZE
localhost/db-tools              latest 8f7ccb04ecab 6 days ago   557 MB
localhost/base                  latest 03ae68ad2271 6 days ago   465 MB
docker.io/arm64v8/mariadb       latest 89a126188478 11 days ago  405 MB
docker.io/arm64v8/nextcloud     latest 579a44c1dc98 3 weeks ago  945 MB
```

If it all looks right, run the final script to get Nextcloud up and going:

```bash
./run.sh
```

When you run `podman ps -a`, you should see a list of running containers that looks like this:

```
CONTAINER ID IMAGE                              COMMAND              CREATED        STATUS            PORTS    NAMES
9518756a259a docker.io/arm64v8/mariadb:latest   mariadbd             3 minutes  ago Up 3 minutes ago           mariadb
32534e5a5890 docker.io/arm64v8/nextcloud:latest apache2-foregroun... 12 seconds ago Up 12 seconds ago          nextcloud
```

From there, you should be able to point your browser to your server IP address. If you are following along and have the same IP as our example, you can substitute that in here (e.g., http://your-server-ip) and see Nextcloud up and running.

## Conclusion

Obviously, this guide would have to be somewhat modified on a production server, especially if the Nextcloud instance is intended to be public-facing. Still, that should give you a basic idea of how Podman works, and how you can set it up with scripts and multiple base images to make rebuilds easier.
