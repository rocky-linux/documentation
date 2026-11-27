---
title: Git initial configuration
author: tianci li
contributors: 
update: 2026-11-26
---

## Overview

After Git is installed on the operating system, users need to perform some basic configurations to be able to use it properly. It should be noted that these basic configurations only need to be set up once.

## Initial configuration

After Git installation is successful, you can use the `git config` command to set Git configuration items. The common options for this command are:

* `--system` - Write configuration items to the system configuration file, which is effective for any user logging into the operating system. In Windows OS, configuration modification refers to the contents of the **/etc/gitconfig** file in the Git installation directory; In GNU/Linux, if installing Git from a repository, the configuration modification correspond to the contents of the **/etc/gitconfig** file.
* `--global` - Write configuration items to the global configuration file, which only applies to the user currently logged into the operating system. The configuration modification here corresponds to the contents of the **.gitconfig** file in the current user's home directory (also known as the primary directory).
* `--local` - Write configuration items to the project configuration file, which only applies to a Git project directory. The configuration modification here corresponds to the content of the git/config file in the project.
* `--list` - List relevant information.
* `--show-origin` - Output specific configuration items and their file paths.
* `--unset <name>` - Delete certain configurations from the system configuration file, global configuration file, or project configuration.file.

The sequence in which Git reads configuration files:

1. system configuration file
2. global configuration file
3. project configuration file

If there is a duplicate configuration item, the last read configuration shall prevail.

## Windows

You can configure your username and email address in Git Bash:

```bash
Bash > git config --global user.name "xxxx"

Bash > git config --global user.email "xxxx@outlook.com"
```

If your Git has other configuration settings, your output might be something like this:

```bash
Bash > git config --list --show-origin
file:D:/Program Files/Git/etc/gitconfig diff.astextplain.textconv=astextplain
file:D:/Program Files/Git/etc/gitconfig filter.lfs.clean=git-lfs clean -- %f
file:D:/Program Files/Git/etc/gitconfig filter.lfs.smudge=git-lfs smudge -- %f
file:D:/Program Files/Git/etc/gitconfig filter.lfs.process=git-lfs filter-process
file:D:/Program Files/Git/etc/gitconfig filter.lfs.required=true
file:D:/Program Files/Git/etc/gitconfig http.sslbackend=openssl
file:D:/Program Files/Git/etc/gitconfig http.sslcainfo=D:/Program Files/Git/mingw64/etc/ssl/certs/ca-bundle.crt
file:D:/Program Files/Git/etc/gitconfig core.autocrlf=true
file:D:/Program Files/Git/etc/gitconfig core.fscache=true
file:D:/Program Files/Git/etc/gitconfig core.symlinks=false
file:D:/Program Files/Git/etc/gitconfig pull.rebase=false
file:D:/Program Files/Git/etc/gitconfig credential.helper=manager
file:D:/Program Files/Git/etc/gitconfig credential.https://dev.azure.com.usehttppath=true
file:D:/Program Files/Git/etc/gitconfig init.defaultbranch=master
file:C:/Users/litia/.gitconfig  http.sslverify=false
file:C:/Users/litia/.gitconfig  user.email=xxxx@outlook.com
file:C:/Users/litia/.gitconfig  user.name=xxxx
file:C:/Users/litia/.gitconfig  user.signingkey=4D6FE61DACDB01E6
file:C:/Users/litia/.gitconfig  commit.gpgsign=true

Bash > git config --global --list
http.sslverify=false
user.email=xxxx@outlook.com
user.name=xxxx
user.signingkey=4D6FE61DACDB01E6
commit.gpgsign=true
```

In the author's current environment:

* `D:/Program Files/Git/` - Git installation directory
* `D:/Program Files/Git/etc/gitconfig` - system configuration file
* `C:/Users/litia/.gitconfig` - Global configuration file for "litia" user

## GNU/Linux

Write configuration items to the global configuration file:

```bash
[root@RL10.3 ~]# git config --global user.name "xxxx"

[root@RL10.3 ~]# git config --global user.email "xxxx@gmail.com"

[root@RL10.3 ~]# git config --global -l
user.name=xxxx
user.email=xxxx@gmail.com

[root@RL10.3 ~]# git config --list --show-origin
file:/root/.gitconfig   user.name=xxxx
file:/root/.gitconfig   user.email=xxxx@gmail.com
```

## Content of configuration file

The content of Git configuration files follows the INI format, for example:

```ini
[user]
	namae = xxxx
	email = xxxx@outlook.com
	signingkey = B301AD47E264A878
[commit]
	gpgsign = true
```

* Use "[ ]" to include section name.
* Key value pairs follow the "Key = Value" format
* A section can contain one or more key value pairs
* Lines starting with ";" or "#" are called comment lines
* Whether key value pairs are indented or not does not affect Git reading
