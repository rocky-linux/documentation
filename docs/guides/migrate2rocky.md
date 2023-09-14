---
title: Migrating To Rocky Linux
author: Ezequiel Bruni
contributors: tianci li, Steven Spencer, Ganna Zyhrnova
update: 11-23-2021
---

# How to migrate to Rocky Linux from CentOS Stream, CentOS, Alma Linux, RHEL, or Oracle Linux

## Prerequisites and assumptions

* CentOS Stream, CentOS, Alma Linux, RHEL, or Oracle Linux running well on a hardware server or VPS. The current supported version for each of these is 8.8 or 9.2.
* A working knowledge of the command line
* A working knowledge of SSH for remote machines
* A mildly risk-taking attitude
* Run commands as root. Either log in as root, or have the ability to elevate privileges with `sudo`.

## Introduction

In this guide, you will learn how to convert all the above OSes to fully functional Rocky Linux installs. This is probably one of the most roundabout ways of installing Rocky Linux, but it will come in handy for people in a variety of situations.

For example, some server providers will not support Rocky Linux by default for a while. Or you may have a production server that you want to convert to Rocky Linux without reinstalling everything.

Well, we have the tool for you: [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

It is a script that, when run, will change out all of your repositories to those of Rocky Linux. Packages will install and upgrade or down-grade as necessary, and your OS's branding will also change. 

Do not worry, if you are new to systems administration, I will be keeping this as user friendly as possible. Well, as user friendly as the command line gets.

### Caveats and warnings

1. Do check out migrate2rocky's README page (linked above), because known clashes between the script and Katello's repositories exist. In time, we will probably discover (and eventually patch) more clashes and incompatibilities, so you will want to know about those, especially for production servers. 
2. This script is most likely to work without incident on completely fresh installs. _If you want to convert a production server, **make a data backup and system snapshot, or do it in a staging environment first.**_

Are you ready?

## Prepare your server

You will need to grab the actual script file from the repository. You can do this several ways.

### The manual way

Download the compressed files from GitHub and extract the one you need (That will be *migrate2rocky.sh*). You can find zip files for any GitHub repository on the right-ish side of the repositorie's main page:

![The "Download Zip" button](images/migrate2rocky-github-zip.png)

Then, upload the executable to your server with SSH by running this command on your local machine:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

Adjust all the file paths and server domains or IP addresses as needed.

### The `git` way

Install `git` on your server with:

```
dnf install git
```

Then clone the rocky-tools repository with:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

Note: this method will download all of the scripts and files in the rocky-tools repository.

### The easy way

This is probably the easiest way to obtain the script. You only need a suitable HTTP client (`curl`, `wget`, `lynx` and so on) installed on the server.

Assuming you have the `curl` utility installed, run this command to download the script into whatever directory you are using:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

That command will download the file straight to your server, and *only* the file you want. But again, security concerns suggest this is not necessarily the best practice, so keep that in mind.

## Running the script and installation

Use the `cd` command to switch to the directory where the script is, ensure the file is executable, and give the owner of the script file x permissions.

```
chmod u+x migrate2rocky.sh
```

And now, at long last, run the script:

```
./migrate2rocky.sh -r
```

That "-r" option tells the script to just go ahead and install everything.

If you have done everything right, your terminal window will look a bit like this:

![a successful script startup](images/migrate2rocky-convert-01.png)

Now, it will take the script a while to convert everything, depending on the actual machine, and the connection it has to the wider internet.

If you see a **Complete!** message at the end, then everything is fine and you can restart the server.

![a successful OS migration message](images/migrate2rocky-convert-02.png)

Give it some time, log back in, and you should have a new Rocky Linux server. Run the `hostnamectl` command to check that your OS migrated properly, and you are good.

![The results of the hostnamectl command](images/migrate2rocky-convert-03.png)
