---
title: SSH Public and Private Key
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# SSH Public and Private Key

## Prerequisites

* A certain amount of comfort operating from the command line
* Rocky Linux servers and/or workstations with *openssh* installed
    * Okay technically, this process should work on any Linux system with openssh installed
* Optional: familiarity with Linux file and directory permissions

## Introduction

SSH is a protocol used to access one machine from another, usually via the command line. With SSH, you can run commands on remote computers and servers, send files, and generally manage everything you do from one place.

When you are working with multiple Rocky Linux servers in multiple locations, or if you are just trying to save some time accessing these servers, you'll want to use an SSH public and private key pair. Key pairs basically make logging into remote machines and running commands easier.

This document will guide you through the process of creating the keys and setting up your servers for easy access with those keys.

## Process For Generating Keys

The following commands are all executed from the command line on your Rocky Linux workstation:

```
ssh-keygen -t rsa
```

Which will display the following:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Hit Enter to accept the default location. Next the system will show:

`Enter passphrase (empty for no passphrase):`

So just hit Enter here. Finally, it will ask for you to re-enter the passphrase:

`Enter same passphrase again:`

So hit Enter a final time.

You now should have an RSA type public and private key pair in your .ssh directory:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Now we need to send the public key (id_rsa.pub) to every machine that we are going to be accessing... but before we do that, we need to make sure that we can SSH into the servers that we will be sending the key to. For our example, we are going to be using just three servers.

You can either access them via SSH by a DNS name or IP address, but for our example we are going to be using the DNS name. Our example servers are web, mail, and portal. For each server, we will attempt to SSH in (nerds love using SSH as a verb) and leave a terminal window open for each machine:

`ssh -l root web.ourourdomain.com`

Assuming that we can login without trouble on all three machines, then the next step is to send our public key over to each server:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/`

Repeat this step with each of our three machines.

In each of the open terminal windows, you should now be able to see *id_rsa.pub* when you enter the following command:

`ls -a | grep id_rsa.pub`

If so, we are now ready to either create or append the *authorized_keys* file in each server's *.ssh* directory. On each of the servers, enter this command:

`ls -a .ssh`

!!! warning "Important!"

    Make sure you read everything below carefully. If you are not sure if you will break something, then make a backup copy of authorized_keys (if it exists) on each of the machines before continuing.

If there is no *authorized_keys* file listed, then we will create it by entering this command while in our _/root_ directory:

`cat id_rsa.pub > .ssh/authorized_keys`

If _authorized_keys_ does exist, then we simply want to append our new public key to the ones that are already there:

`cat id_rsa.pub >> .ssh/authorized_keys`

Once the key has been either added to _authorized_keys_, or the _authorized_keys_ file has been created, try to SSH from your Rocky Linux workstation to the server again. You should not be prompted for a password.

Once you have verified that you can SSH in without a password, remove the id_rsa.pub file from the _/root_ directory on each machine.

`rm id_rsa.pub`

## SSH Directory and authorized_keys Security

On each of your target machines, make sure that the following permissions are applied:

```
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```
