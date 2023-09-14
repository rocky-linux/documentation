---
title: Docker Method
author: Wale Soyinka
contributors: Steve Spencer, Ganna Zhyrnova
update: 27-Feb-2022
---

# Running a local copy of the docs.rockylinux.org website for web development and/or content authors

This document walks through how to recreate and run a local copy of the entire docs.rockylinux.org website on your local machine. **It is a work-in-progress.**

Running a local copy of the documentation website might be useful in the following scenarios:

* You are interested in learning about and contributing to the web development aspects of the docs.rockylinux.org website
* You are an author and you'd like to see how your documents will render/look on the docs website before contributing them
* You are a web developer looking to contribute to or help maintain the docs.rockylinux.org website


### Some notes:

* The instructions in this guide are **NOT** a prerequisite for Rocky documentation Authors/Content contributors
* The entire environment runs in a Docker container and so you'll need a Docker engine on your local machine
* The container is built on top of the official RockyLinux docker image available here https://hub.docker.com/r/rockylinux/rockylinux
* The container keeps the documentation content (guides, books, images and so on) separate from the web engine (mkdocs)
* The container starts a local web server listening on port 8000.  And port 8000 will be forwarded to the Docker host


## Create the content environment

1. Change the current working directory on your local system to a folder where you intend to do your writing. We'll refer to this directory as
`$ROCKYDOCS` in the rest of this guide.  For our demo here, `$ROCKYDOCS` points to `~/projects/rockydocs` on our demo system.

Create $ROCKYDOCS if it doesn't already exist and then type:

```
cd  $ROCKYDOCS
```

2. Make sure you have `git` installed (`dnf -y install git`).  While in $ROCKYDOCS use git to clone the official Rocky Documentation content repo. Type:

```
git clone https://github.com/rocky-linux/documentation.git
```

You'll now have a `$ROCKYDOCS/documentation` folder. This folder is a git repository and under git's control.


## Create and Start the RockyDocs web developmwnt environment

3.  Make sure you have Docker up and running on your local machine (you can check with `systemctl `)

4. From a terminal type:

```
docker pull wsoyinka/rockydocs:latest
```

5. Check to make sure the image downloaded successfully. Type:

```
docker image  ls
```

## Start the RockyDocs container

1. Start a container from the rockydocs image. Type:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


Alternatively if you prefer and if you have `docker-compose` installed, you can create compose file named `docker-compose.yml` with the following contents:

```
version: "3.9"
services:
  rockydocs:
    image: wsoyinka/rockydocs:latest
    volumes:
      - type: bind
        source: ./documentation
        target: /documentation
    container_name: rocky
    ports:
       - "8000:8000"

```

Save the file with the file name `docker-compose.yml` in your $ROCKYDOCS working directory.  And start the service/container by running:

```
docker-compose  up
```


## View the local docs.rockylinux.org website

With the container up and running, you should now be able to point your web browser to the following URL to view your local copy of the site:

http://localhost:8000
