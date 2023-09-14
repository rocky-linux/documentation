---
title: Podman Method
author: Wale Soyinka
contributors: , Ganna Zyhrnova
update: 13-Feb-2023
---

# Running the docs.rockylinux.org website locally for web development | Podman


This document walks through how to recreate and run a local copy of the entire docs.rockylinux.org website on your local machine.
Running a local copy of the documentation website might be useful in the following scenarios:

* You are interested in learning about and contributing to the web development aspects of the docs.rockylinux.org website
* You are an author and you'd like to see how your documents will render/look on the docs website before contributing them


## Create the content environment

1. Ensure that the prerequisites are satisfied. If not please skip to the "[Setup the prerequisites](#setup-the-prerequisites)" section and then return here. 

2. Change the current working directory on your local system to a folder where you intend to do your writing. 
  We will refer to this directory as
`$ROCKYDOCS` in the rest of this guide. For our demo here, `$ROCKYDOCS` points to `$HOME/projects/rockydocs` on our demo system.

Create $ROCKYDOCS if it doesn't already exist and change your working directory to $ROCKYDOCS type:

```
mkdir -p $HOME/projects/rockydocs
export ROCKYDOCS=${HOME}/projects/rockydocs
cd  $ROCKYDOCS
```

3. Ensure you have `git` installed (`dnf -y install git`).  While in $ROCKYDOCS use git to clone the official Rocky Documentation content repo. Type:

```
git clone https://github.com/rocky-linux/documentation.git
```

You will now have a `$ROCKYDOCS/documentation` folder. This folder is a git repository and under git's control.

4. Also use `git` to clone the official docs.rockylinux.org repo. Type:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

You will now have a `$ROCKYDOCS/docs.rockylinux.org` folder. This folder is where you can experiment with your web development contributions.


## Create and Start the RockyDocs web developmwnt environment

5.  Ensure you have Podman up and running on your local machine (you can check with `systemctl `). Test by running:

```
systemctl  enable --now podman.socket
```

6. Create a new `docker-compose.yml` file with the following contents:

```
version: '2'
services:
  mkdocs:
    privileged: true
    image: rockylinux:9.1
    ports:
      - 8001:8001
    environment:
      PIP_NO_CACHE_DIR: "off"
      PIP_DISABLE_PIP_VERSION_CHECK: "on"
    volumes:
       - type: bind
         source: ./documentation
         target: /app/docs
       - type: bind
         source: ./docs.rockylinux.org
         target: /app/docs.rockylinux.org
    working_dir: /app
    command: bash -c "dnf install -y python3 pip git && \
       ln -sfn  /app/docs   docs.rockylinux.org/docs && \
       cd docs.rockylinux.org && \
       git config  --global user.name webmaster && \
       git config  --global user.email webmaster@rockylinux.org && \
       curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/mike-plugin-changes.patch -o mike-plugin-changes.patch && \
       git apply --reverse --check mike-plugin-changes.patch && \
       /usr/bin/pip3 install --no-cache-dir -r requirements.txt && \
       /usr/local/bin/mike deploy -F mkdocs.yml 9.1 91alias && \
       /usr/local/bin/mike set-default 9.1 && \
       echo  All done && \
       /usr/local/bin/mike serve  -F mkdocs.yml -a  0.0.0.0:8001"
       
```

Save the file with the file name `docker-compose.yml` in your $ROCKYDOCS working directory. 

You can also quickly download a copy of the docker-compose.yml file by running:

```
curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
```


7. Finally use docker-compose to bring up the service. Type:

```
docker-compose  up
```


## View the local docs.rockylinux.org website

8. If you have a firewall running on your Rocky Linux system, ensure that port 8001 is open. Type:

```
firewall-cmd  --add-port=8001/tcp  --permanent
firewall-cmd  --reload
```

With the container up and running, you should now be able to point your web browser to the following URL to view your local copy of the site:

http://localhost:8001

OR

http://SERVER_IP:8001




## Setup the prerequisites

Install and setup Podman and other tools by running:

```
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket

```

Install docker-compose and make it executable. Type:

```
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```


Fix permissions on docker socket. Type:

```
sudo chmod 666 /var/run/docker.sock
```


### Notes:

* The instructions in this guide are **NOT** a prerequisite for Rocky documentation authors or content contributors
* The entire environment runs in a Podman container and so you will need Podman properly setup on your local machine
* The container is built on top of the official Rocky Linux 9.1 docker image available here https://hub.docker.com/r/rockylinux/rockylinux
* The container keeps the documentation content separate from the web engine (mkdocs)
* The container starts a local web server listening on port 8001. 
