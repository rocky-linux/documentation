---
title: Incus Method
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6
tags:
  - contribute
  - local environment lxd
  - local environment incus
---

!!! info

    While this method still works for LXD, the author prefers Incus instead. The reason is that from a development standpoint, Incus appears to be out in front of LXD, and that includes the images available. With Incus, as of September 2025, there are images for Rocky Linux 10, and other RHEL rebuild 10 images. LXD images only include 9 builds currently. This may be due to the [licensing change](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) announced by Linux Containers project lead, Stéphane Graber, back in December 2023.

    In addition, this procedure still works with the current versioning of documentation. If a document is created or edited on any of the version branches (main, rocky-9, and rocky-8), the document synced to the container will show the correct content. This means that you can continue to use this procedure as is. Included are some addtional notes important to versioning.

!!! tip

    If you are using Rocky Linux 10 as your workstation, you need to keep in mind that as of the rewriting of this document, `lsyncd` is not available from the EPEL. You will need to use the install from source method.

## Introduction

There are several ways to run a copy of `mkdocs` to see exactly how your Rocky Linux document will appear when merged on the live system. This particular document deals with using an `incus` container on your local workstation to separate python code in `mkdocs` from other projects you might be working on.

The recommendation is to keep projects separate to avoid causing problems with your workstation's code.

## Prerequisites and assumptions

- Familiarity and comfort with the command-line
- Comfortable using tools for editing, SSH, and synchronization, or willing to follow along and learn
- Incus reference - there is a long document on [building and using `incus` on a server here](../../../books/incus_server/00-toc.md), but you will use just a basic install on our Linux workstation
- Using `lsyncd` for mirroring files. See [documentation on that here](../../backup/mirroring_lsyncd.md)
- You will need public keys generated for your user and the "root" user on your local workstation using [this document](../../security/ssh_public_private_keys.md)
- Our bridge interface is running on 10.56.233.1 and our container is running on 10.56.233.189 in our examples. However your IPs for the bridge and container will be different.
- "youruser" in this document represents your user id
- The assumption is that you are already doing documentation development with a clone of the documentation repository on your workstation

## The `mkdocs` container

### Create the container

Our first step is to create the `incus` container. Using your container's defaults (bridge interface) is perfectly fine here.

You will add a Rocky container to our workstation for `mkdocs`. Just name it "mkdocs":

```bash
incus launch images:rockylinux/10 mkdocs
```

The container needs to be a proxy. By default, when `mkdocs serve` starts, it runs on 127.0.0.1:8000. That is fine when it is on your local workstation without a container. However, when it is in an `incus` **container** on your local workstation, you need to set up the container with a proxy port. Do this with:

```bash
incus config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

In the line above, "mkdocs" is our container name, "mkdocsport" is an arbitrary name you are giving to the proxy port, the type is "proxy", and you are listening on all TCP interfaces on port 8000 and connecting to the localhost for that container on port 8000.

!!! Note

    If you are running an `incus` instance on another machine in your network, remember to make sure that port 8000 is open in the firewall.

### Installing packages

First, get into the container with:

```bash
incus shell mkdocs bash
```

For Rocky Linux 10 you will need a few packages:

```bash
dnf install git openssh-server python3-pip rsync
```

When installed, you need to enable and start `sshd`:

```bash
systemctl enable --now sshd
```

### Container users

You need to set a password for our root user and then add our user (the user you use on your local machine) to the sudoers list. You are the "root" user at the moment. To change the password enter:

```text
passwd
```

Set a secure and memorable password.

Next, add your user and set a password:

```bash
adduser youruser
passwd youruser
```

Add your user to the sudoers group:

```bash
usermod -aG wheel youruser
```

You should be able to SSH into the container with the root user or your user from your workstation and enter a password. Ensure that you can do that before continuing.

## SSH for root and your user

In this procedure, the root user (at minimum) needs to be able to SSH into the container without entering a password. This is because of the `lsyncd` process you will be implementing. The assumption here is that you can `sudo` to the root user on your local workstation:

```bash
sudo -s
```

The assumption also is that the root user has an `id_rsa.pub` key in the `./ssh` directory. If not, generate one with [this procedure](../../security/ssh_public_private_keys.md):

```bash
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

To get SSH access on our container without having to enter a password, provided the `id_rsa.pub` key exists, just run:

```bash
ssh-copy-id root@10.56.233.189
```

For your user, however, you need the entire `.ssh/` directory copied to your container. You will keep everything the same for this user so that your access to GitHub over SSH is the same.

To copy everything over to your container, you just need to do this as your user, **not** `sudo`:

```bash
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

Next, SSH into the container as your user:

```bash
ssh -l youruser 10.56.233.189
```

You need to ensure things are identical. You will do this with `ssh-add`. You must also ensure that you have the `ssh-agent` available:

```bash
eval "$(ssh-agent)"
ssh-add
```

## Cloning repositories

You need two repositories cloned, but no need to add any `git` remotes. The documentation repository here will only display the current documentation (mirrored from your workstation) and the docs.

The rockylinux.org repository is for running `mkdocs serve` and will use the mirror as its source. Run all these steps as your non-root user. If you are not able to clone the repositories as your userid, then there **IS** a problem with your identity as far as `git` is concerned and you will need to review the last few steps for re-creating your key environment (above).

First, clone the documentation:

```bash
git clone git@github.com:rocky-linux/documentation.git
```

Next, clone docs.rockylinux.org:

```bash
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

If you get errors, return to the earlier steps and ensure that those are all correct before continuing.

## Setting up `mkdocs`

Installing the needed plugins is all done with `pip3` and the "requirements.txt" file in the docs.rockylinux.org directory. While this process will argue with you about using the root user to write the changes to the system directories, you have to run it as root.

You do this with `sudo` here.

Change into the directory:

```bash
cd docs.rockylinux.org
```

Then run:

```bash
sudo pip3 install -r requirements.txt
```

Next you must set up `mkdocs` with an additional directory.  `mkdocs` requires the creation of a docs directory and then the `documentation/docs` directory linked beneath it. Do this with:

```bash
mkdir docs
cd docs
ln -s ../../documentation/docs
```

### Testing `mkdocs`

Now that you have `mkdocs` setup, try starting the server. Remember, this process will argue that it looks like this is production. It is not, so ignore the warning. Start `mkdocs serve` with:

```bash
mkdocs serve -a 0.0.0.0:8000
```

You will see this or similar in the console:

```bash
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

If you have done everything correctly, you should be able to open a web browser and go to the IP of your container on port :8000, and see the documentation site.

In our example, enter the following in the browser address (**NOTE** To avoid broken URLs, the IP here is "your-server-ip". You just need to substitute in the IP):

```bash
http://your-server-ip:8000
```

## `lsyncd`

You are almost there if you saw the documentation in the web browser. The last step is to keep the documentation in your container synchronized with the one on your local workstation.

As noted, you are doing this here with `lsyncd`.

Installation of `lsyncd` differs depending on your Linux version. [This document](../../backup/mirroring_lsyncd.md) covers ways to install it on Rocky Linux with an RPM from the EPEL (Extra Packages for Enterprise Linux), and from source. If you are using other Linux types (Ubuntu for example), they generally have their own packages, but with nuances.

Ubuntu's, for example, names the configuration file differently. Just be aware that if you are using another Linux workstation type other than Rocky Linux, and do not want to install from source, there are probably packages available for your platform.

For now, we are assuming that you are using a Rocky Linux workstation and are using the RPM install method from the included document.

!!! note

    As of this writing, `lsyncd` is not available from the EPEL for Rocky Linux 10. You will need to use the source install method if that is your workstation version.

### Configuration

!!! Note

    The root user must run the daemon, so you must be root to create the configuration files and logs. For this we are assuming `sudo -s`.

You need to have some logs available for `lsyncd` to write to:

```bash
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

You also need to have an exclude file created, even though in this case you are not excluding anything:

```bash
touch /etc/lsyncd.exclude
```

Finally you need to create the configuration file. In this example, we are using `vi` as our editor, but use the editor you feel comfortable with:

```bash
vi /etc/lsyncd.conf
```

Then place this content in that file and save it. Be sure to replace "youruser" with your actual user, and the IP address with your own container IP:

```bash
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

```bash
systemctl restart lsyncd
```

To ensure things are working, check the logs-particularly the `lsyncd.log`, which should show content similar to this if everything started correctly:

```bash
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## Versioning notes

You need a clone of the documentation repository from [Rocky Linux documentation repository](https://github.com/rocky-linux/documentation). That part is important, because if you have instead cloned your own fork of the repository, then your ability to `git checkout` the `rocky-8` and `rocky-9` branches will not be there. Only the `main` branch will be available.

### GitHub workstation setup

These steps are not for your container, but for your workstation's copy of the documentation:

1. Clone the Rocky Linux documentation repository:

    ```bash
    git clone git@github.com:rocky-linux/documentation.git
    ```

2. The `git remote` name will be "upstream", rather than "origin." Check the remote name with:

    ```bash
    git remote -v
    ```

    Immediately after cloning, this shows:

    ```bash
    origin git@github.com:rocky-linux/documentation.git (fetch)
    origin git@github.com:rocky-linux/documentation.git (push)
    ```

    Rename the remote with:

    ```bash
    git remote rename origin upstream
    ```

    Run `git remote -v` again and you will see:

    ```bash
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

3. Add your fork as a remote with the "origin" name. Substitute your actual GitHub username:

    ```bash
    git remote add origin git@github.com:[your-github-user-name]/documentation.git
    ```

    Run `git remote -v` again and you will see:

    ```bash
    origin git@github.com:[your-github-user-name]/documentation.git (fetch)
    origin git@github.com:[your-github-user-name]/documentation.git (push)
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

4. You need to populate your fork with the version branches (other than `main`). The `main` branch currently holds version 10 information. You want to populate your fork with the `rocky-8` and `rocky-9` branches so that you are ready to edit documents in those older versions. The first step is to `git checkout` these branch names:

    ```bash
    git checkout rocky-8
    ```

    The first time you do this, your will see:

    ```bash
    branch 'rocky-8' set up to track 'upstream/rocky-8'.
    Switched to a new branch 'rocky-8'
    ```

    Next, push the branch to your fork:

    ```bash
    git push origin rocky-8
    ```

    This acts like it is creating a new pull request, but when you check your fork branch contents, you will see `rocky-8` is now one of the branches.

    Repeat these steps with the `rocky-9` branch.

### How this applies to this procedure

With the branches created, if you want to edit the `README.md` for only `rocky-9`, you need to create a new branch based on the `rocky-9` version branch:

```bash
git checkout -b fixes_for_rocky9_readme rocky-9
```

Then edit the document normally. As you save your work, your container documents will update, and running `mkdocs serve` as described in this document, will show that content.

Once finished and changes pushed to your fork to create a pull request, you can checkout the `main` branch again. Since all of your work was within the checked out rocky-9 branch, your synced documentation in your container reverts to what it was before starting the process. In this way, you can always track your work regardless of what version you are working with. Your container will remain in sync with your local workstation content.

## Conclusion

You can work on your workstation documentation while seeing changes appear in your synced copy in your container. The recommended practice is that all Python must run separately from any other Python code you might be developing. Using `incus` containers makes that easier.
