---
title: Local Documentation - LXD
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6
tags:
  - contribute
  - local environment lxd
---

# Introduction

There are several ways to run a copy of `mkdocs` to see exactly how your Rocky Linux document will appear when merged on the live system. This particular document deals with using an LXD container on your local workstation to separate python code in `mkdocs` from other projects you might be working on.

The recommendation is to keep projects separate to avoid causing problems with your workstation's code.

This is also a companion document to the [Docker version here](rockydocs_web_dev.md).

## Prerequisites and assumptions

* Familiarity and comfort with the command-line
* Comfortable using tools for editing, SSH, and synchronization, or willing to follow along and learn
* LXD reference - there is a long document on [building and using LXD on a server here](../../books/lxd_server/00-toc.md), but you will use just a basic install on our Linux workstation
* Using `lsyncd` for mirroring files. See [documentation on that here](../backup/mirroring_lsyncd.md)
* You will need public keys generated for your user and the "root" user on your local workstation using [this document](../security/ssh_public_private_keys.md)
* Our bridge interface is running on 10.56.233.1 and our container is running on 10.56.233.189 in our examples, however your IPs for the bridge and container will be different 
* "youruser" in this document represents your user id
* The assumption is that you are already doing documentation development with a clone of the documentation repository on your workstation

## The `mkdocs` container

### Create the container

Our first step is to create the LXD container. Using the defaults (bridge interface) for your container is perfectly fine here.

You will add a Rocky container to our workstation for `mkdocs`. Just name it "mkdocs":

```
lxc launch images:rockylinux/8 mkdocs
```

The container needs to be a proxy . By default, when `mkdocs serve` starts, it runs on 127.0.0.1:8000. That is fine when it is on your local workstation without a container. However, when it is in an LXD **container** on your local workstation, you need to set up the container with a proxy port. Do this with:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

In the line above, "mkdocs" is our container name, "mkdocsport" is an arbitrary name you are giving to the proxy port, the type is "proxy", and you are listening on all TCP interfaces on port 8000 and connecting to the localhost for that container on port 8000.

!!! Note

    If you are running the lxd instance on another machine in your network, remember to make sure that port 8000 is open in the firewall.

### Installing packages

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

You will need a few packages to do what you need to do:

```
dnf install git openssh-server python3-pip rsync
```

When installed, you need to enable and start `sshd`:


```
systemctl enable --now sshd
```
### Container users

You need to set a password for our root user and then add our user (the user you use on your local machine) to the sudoers list. You are the "root" user at the moment. To change the password enter:


```
passwd
```

Set the password to something secure and memorable.

Next, add your user and set a password:

```
adduser youruser
passwd youruser
```

Add your user to the sudoers group:

```
usermod -aG wheel youruser
```

At this point, you should be able to SSH into the container with the root user or your user from your workstation and entering a password. Ensure that you can do that before continuing.

## SSH for root and your user

In this procedure, the root user (at minimum) needs to be able to SSH into the container without entering a password; this is because of the `lsyncd` process you will be implementing. The assumption here is that you can sudo to the root user on your local workstation:

```
sudo -s
```

The assumption also is that the root user has an `id_rsa.pub` key in the `./ssh` directory. If not, generate one with [this procedure](../security/ssh_public_private_keys.md):

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

To get SSH access on our container without having to enter a password, provided the `id_rsa.pub` key exists, as it does above, just run:

```
ssh-copy-id root@10.56.233.189
```

For our user, however, you need the entire `.ssh/` directory copied to our container. The reason is that you will keep everything the same for this user so that our access to GitHub over SSH is the same. 

To copy everything over to our container, you just need to do this as your user, **not** sudo:

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Next, SSH into the container as your user:

```
ssh -l youruser 10.56.233.189
```

You need to make things identical. You are doing this with `ssh-add`. To do this, you must ensure that you have the <code>ssh-agent</code> available:

```
eval "$(ssh-agent)"
ssh-add
```

## Cloning repositories

You need two repositories cloned, but no need to add any <code>git</code> remotes. The documentation repository here will only display the current documentation (mirrored from your workstation) and the docs.

The rockylinux.org repository is for running `mkdocs serve` and will use the mirror as its source. Run all these steps as your non-root user. If you are not able to clone the repositories as your userid, then there **IS** a problem with your identity as far as `git` is concerned and you will need to review the last few steps for re-creating your key environment (above).

First, clone the documentation:

```
git clone git@github.com:rocky-linux/documentation.git
```

Next, clone docs.rockylinux.org:

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

If you get errors, return to the steps above and ensure that those are all correct before continuing.

## Setting up `mkdocs`

Installing the needed plugins is all done with `pip3` and the "requirements.txt" file in the docs.rockylinux.org directory. While this process will argue with you about using the root user to write the changes to the system directories, you have to run it as root. 

You are doing this with `sudo` here.

Change into the directory:

```
cd docs.rockylinux.org
```

Then run:

```
sudo pip3 install -r requirements.txt
```

Next you must set up `mkdocs` with an additional directory.  `mkdocs` requires the creation of a docs directory and then the documentation/docs directory linked beneath it. Do this with:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### Testing `mkdocs`

Now that you have `mkdocs` setup, try starting the server. Remember, this process will argue that it looks like this is production. It is not, so ignore the warning. Start `mkdocs serve` with:

```
mkdocs serve -a 0.0.0.0:8000
```

You will see something like this in the console:

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

Now for the moment of truth! If you have done everything correctly, you should be able to open a web browser and go to the IP of your container on port :8000, and see the documentation site.

In our example, enter the following in the browser address (**NOTE** To avoid broken URLs, the IP here has been changed to "your-server-ip". You just need to substitute in the IP):

```
http://your-server-ip:8000
```
## `lsyncd`

You are almost there if you saw the documentation in the web browser. The last step is to keep the documentation in your container synchronized with the one on your local workstation. 

You are doing this here with `lsyncd` as noted above.

Installation of`lsyncd` is different depending on which Linux version you are using. [This document](../backup/mirroring_lsyncd.md) covers ways to install it on Rocky Linux, and also from source. If you are using other Linux types (Ubuntu for example) they generally have their own packages, but there are nuances to them.

Ubuntu's, for example, names the configuration file differently. Just be aware that if you are using another Linux workstation type other than Rocky Linux, and do not want to install from source, there are probably packages available for your platform.

For now, we are assuming that you are using a Rocky Linux workstation and are using the RPM install method from the included document.

### Configuration

!!! Note
    
    The root user must run the daemon, so you must be root to create the configuration files and logs. For this we are assuming `sudo -s`.

You need to have some log files available for `lsyncd` to write to:

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

You also need to have an exclude file created, even though in this case you are not excluding anything:

```
touch /etc/lsyncd.exclude
```

Finally you need to create the configuration file. In this example, we are using `vi` as our editor, but you may use whichever editor you feel comfortable with:

```
vi /etc/lsyncd.conf
```

Then place this content in that file and save it. Be sure to replace "youruser" with your actual user, and the IP address with your own container IP:

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

Assuming that you enabled `lsyncd` when you installed it, at this point you need just to start or restart the process:

```
systemctl restart lsyncd
```

To ensure things are working, check the logs-particularly the `lsyncd.log`, which should show you something like this if everything started correctly:

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Conclusion

As you work on your workstation documentation now, whether it is a `git pull` or a branch you create to make a document (like this one!), you will see the changes appear in your documentation on the container, and `mkdocs serve` will show you the content in your web browser.

The recommended practice is that all Python must run separately from any other Python code you might be developing. LXD containers can make that easier. Give this method a try and see if it works for you.
