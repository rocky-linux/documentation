---
title: Local Documentation - LXD
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6
tags:
  - contribute
  - local envirmonent lxd
---

# Introduction

There are several ways to run a copy of `mkdocs` so that you can see exactly how your Rocky Linux document will appear when it is merged on the live system. This particular document deals with using an LXD container on your local workstation to separate python code in `mkdocs` from other projects you might be working on.

It is recommended to keep projects separate to avoid causing problems with your workstation's code.

This is also a partner document to the [Docker version here](rockydocs_web_dev.md).

## Prerequisites and Assumptions

A few things you should have/know/be:

* Familiarity and comfort with the command-line
* Comfortable using tools for editing, SSH, and synchronization, or willing to follow along and learn
* We will reference LXD - there's a long document on [building and using LXD on a server here](../../books/lxd_server/00-toc.md), but we will be using just a basic install on our Linux workstation. This document assumes that you are already using LXD for other things, and does not cover the build and initialization of LXD.
* We will be using `lsyncd` for mirroring files, and you can find [documentation on that here](../backup/mirroring_lsyncd.md)
* You will need public keys generated for your user and the "root" user on your local workstation using [this document](../security/ssh_public_private_keys.md)
* Our bridge interface is running on 10.56.233.1 and our container is running on 10.56.233.189 in our examples below.
* "youruser" in this document represents your user id, so substitute in your own.
* We are assuming that you are already doing documentation development with a clone of the documentation repository on your workstation.

## The mkdocs container

### Create the Container

Our first step is to create the LXD container. There's no need to use anything other than defaults here, so allow your container to be built using the bridge interface.

We will add a Rocky container to our workstation for `mkdocs`, so we are just calling it "mkdocs":

```
lxc launch images:rockylinux/8 mkdocs
```

The container needs to be set up with a proxy. By default, when `mkdocs serve` is started, it runs on 127.0.0.1:8000. That's fine when it is on your local workstation without a container. However, when it is in an LXD **container** on your local workstation, you need to set up the container with a proxy port. This is done with:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

In the line above, "mkdocs" is our container name, "mkdocsport" is an arbitrary name we are giving to the proxy port, the type is "proxy", and then we are listening on all tcp interfaces on port 8000 and connecting to the localhost for that container on port 8000.

!!! Note

    If you're running the lxd instance on another machine in your network, remember to make sure that port 8000 is open in the firewall.

### Installing Packages

First, get into the container with:

```
lxc exec mkdocs bash
```

!!! warning "Changes in requirements.txt for 8.x"

    The current `requirements.txt` will require a newer version of Python than what is installed by default in Rocky Linux 8.5 or 8.6. To be able to install all the other dependencies, do the following: 

    ```
    sudo dnf module enable python38
    sudo dnf install python38
    ```

    You can then skip installing `python3-pip` in the packages found below.

We will need a few packages to accomplish what we need to do:

```
dnf install git openssh-server python3-pip rsync
```

Once installed, we need to enable and start `sshd`:

```
systemctl enable --now sshd
```
### Container Users

We need to set a password for our root user, and then add our own user (the user that you use on your local machine) and add it to the sudoers list. We should be the "root" user at the moment, so to change the password type:

```
passwd
```

And set the password to something secure and memorable.

Next, add your user and set a password:

```
adduser youruser
passwd youruser
```

And add your user to the sudoers group:

```
usermod -aG wheel youruser
```

At this point, you should be able to SSH into the container using either the root user or your user from your workstation and entering a password. Make sure that you can do that before continuing.

## SSH for root and Your user

In this procedure, the root user (at minimum) needs to be able to SSH into the container without entering a password; this is because of the `lsyncd` process we will be implementing. We are assuming here that you can sudo to the root user on your local workstation:

```
sudo -s
```

We are also assuming that the root user has an `id_rsa.pub` key in the `./ssh` directory. If not, generate one using [this procedure](../security/ssh_public_private_keys.md):

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

To get SSH access on our container without having to enter a password, as long as the `id_rsa.pub` key exists, like it does above, all we need to do is run:

```
ssh-copy-id root@10.56.233.189
```

In the case of our user, however, we need the entire .ssh/ directory copied to our container. The reason is that we are going to be keeping everything identical for this user so that our access to GitHub over SSH is the same.

To copy everything over to our container, we just need to do this as your user, **not** sudo:

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Next, SSH into the container as your user:

```
ssh -l youruser 10.56.233.189
```

We need to make things identical, and this is done with `ssh-add`. To do this, though, we need to make sure that we have the `ssh-agent` available. Enter the following:

```
eval "$(ssh-agent)"
ssh-add
```

## Cloning repositories

We need two repositories cloned, but there is no need to add any `git` remotes. The documentation repository here will only be used to display the current documentation (mirrored from your workstation) and the docs.

The rockylinux.org repository will be used for running `mkdocs serve` and will use the mirror as it's source. All of these steps should be done as your non-root user. If you are not able to clone the repositories as your userid, then there **IS** a problem with your identity as far as `git` is concerned and you will need to review the last few steps for re-creating your key environment (above).

First, clone the documentation:

```
git clone git@github.com:rocky-linux/documentation.git
```

Assuming that worked, then clone the docs.rockylinux.org:

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

If everything worked as planned, then you can move on.

## Setting Up mkdocs

Installing the needed plugins is all done with `pip3` and the "requirements.txt" file in the docs.rockylinux.org directory. While this process will argue with you about using the root user for this, in order to write the changes to the system directories, you pretty much have to run it as root.

We are doing this with `sudo` here.

Change into the directory:

```
cd docs.rockylinux.org
```

Then run:

```
sudo pip3 install -r requirements.txt
```

Next we need to set up `mkdocs` with an additional directory. Right now, `mkdocs` requires a docs directory to be created and then the documentation/docs directory linked beneath it. All this is done with:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### Testing mkdocs

Now that we have `mkdocs` setup, let's try starting the server. Remember, this process is going to argue that it looks like this is production. It's not, so ignore the warning. Start `mkdocs serve` with:

```
mkdocs serve -a 0.0.0.0:8000
```

You should see something like this in the console:

```
INFO     -  Building documentation...
WARNING  -  Config value: 'dev_addr'. Warning: The use of the IP address '0.0.0.0' suggests a production environment or the use of a
            proxy to connect to the MkDocs server. However, the MkDocs' server is intended for local development purposes only. Please
            use a third party production-ready server instead.
INFO     -  Adding 'sv' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'pt' to the 'plugins.search.lang' option
WARNING  -  Language 'zh' is not supported by lunr.js, not setting it in the 'plugins.search.lang' option
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Building en documentation
INFO     -  Building de documentation
INFO     -  Building fr documentation
INFO     -  Building es documentation
INFO     -  Building it documentation
INFO     -  Building ja documentation
INFO     -  Building zh documentation
INFO     -  Building sv documentation
INFO     -  Building pt documentation
INFO     -  [14:12:56] Reloading browsers
```

Now for the moment of truth!  If you've done everything correctly above, you should be able to open a web browser and go to the IP of your container on port :8000, and see the documentation site.

In our example, we would enter the following in the browser address (**NOTE** To avoid broken URLs, the IP here has been changed to "your-server-ip". You just need to substitute in the IP):

```
http://your-server-ip:8000
```
## lsyncd

If you saw the documentation in the web browser, we are almost there. The last step is to keep the documentation that's in your container in synchronization with the one on your local workstation.

We are doing this here with `lsyncd` as noted above.

Depending on which Linux version you are using, `lsyncd` is installed differently. [This document](../backup/mirroring_lsyncd.md) covers ways to install it on Rocky Linux, and also from source. If you are using some of the other Linux type (Ubuntu for example) they generally have their own packages, but there are nuances to them.

Ubuntu's, for example, names the configuration file differently. Just be aware that if you are using another Linux workstation type other than Rocky Linux, and don't want to install from source, there are probably packages available for your platform.

For now, we are assuming that you are using a Rocky Linux workstation and are using the RPM install method from the included document.

### Configuration

!!! Note
    The root user must run the daemon, so you will need to be root to create the configuration files and logs. For this we are assuming `sudo -s`.

We need to have some log files available for `lsyncd` to write to:

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

We also need to have an exclude file created, even though in this case we are not excluding anything:

```
touch /etc/lsyncd.exclude
```

Finally we need to create the configuration file. In this example, we are using `vi` as our editor, but you may use whichever editor you feel comfortable with:

```
vi /etc/lsyncd.conf
```

And then place this content in that file and save it. Be sure to replace "youruser" with your actual user, and the IP address with your own container IP:

```
settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home/youruser/documentation",
   host="root@10.56.233.189",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home/youruser/documentation",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

We are assuming that you enabled `lsyncd` when you installed it, so at this point we need to just start or restart the process:

```
systemctl restart lsyncd
```

To make sure things are working, check the logs-particularly the `lsyncd.log`, which should show you something like this if everything started correctly:

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Conclusion

As you work on your workstation documentation now, whether it is a `git pull` or a branch you create to make a document (like this one!), you will see the changes appear in your documentation on the container, and `mkdocs serve` will show you the content in your web browser.

It's recommended practice that all Python code should be run separate from any other Python code you might be developing. LXD containers can make that a lot easier; give this method a try and see if it works for you.
