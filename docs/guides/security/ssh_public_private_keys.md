---
title: SSH Public and Private Key
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zyhrnova
tested_with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# SSH public and private key

## Prerequisites

* A certain amount of comfort operating from the command line
* A Linux server or workstations with *openssh* installed
* Optional: familiarity with Linux file and directory permissions

## Introduction

SSH is a protocol for accessing one machine from another, usually via the command line. With SSH, you can run commands on remote computers and servers, send files, and generally manage everything you do from one place.

When working with many Rocky Linux servers in various locations, or trying to save some time accessing these servers, you will want to use an SSH public and private key pair. Key pairs make logging into remote machines and running commands easier.

This document will guide you through creating the keys and setting up your servers for access with those keys.

## Process for generating keys

The following commands are all run from the command line on your Rocky Linux workstation:

```
ssh-keygen -t rsa
```

Which will show the following:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Hit <kbd>ENTER</kbd> to accept the default location. Next the system will show:

`Enter passphrase (empty for no passphrase):`

Hit <kbd>ENTER</kbd> here. Finally, it will ask for you to re-enter the passphrase:

`Enter same passphrase again:`

Hit <kbd>ENTER</kbd> a final time.

You will now have an RSA type public and private key pair in your *.ssh* directory:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

You need to send the public key (*id_rsa.pub*) to every machine that you are going to be accessing. Before you do that, you need to ensure that you can SSH into the servers that you are sending the key to. This example uses three servers.

You can access them with SSH by DNS name or IP address, but this example uses the DNS name. The example servers are web, mail, and portal. For each server, you will SSH in (nerds love using SSH as a verb) and leave a terminal window open:

`ssh -l root web.ourourdomain.com`

If you can login without trouble on all three machines, the next step is to send your public key over to each server. Do this with the `ssh-copy-id` command:

`ssh-copy-id -i ~/.ssh/id_rsa.pub` user@web.ourdomain.com

Repeat this step with each of your three machines. This will populate the *authorized_keys* file on each server with your public key. 

Try to SSH from your Rocky Linux workstation to the server again. You should receive no prompt for a password.

## SSH directory and `authorized_keys` security

On each of your target machines, ensure the application of the following permissions:

```
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```
