---
title: OliveTin
author: Ezequiel Bruni
contributors: Steven Spencer
tested_with: 8.5, 8.6
tags:
  - automation
  - web
  - bash
---

# How to install & use OliveTin on Rocky Linux

## Introduction

Have you ever gotten tired of typing in the same CLI commands over and over again? Have you ever wanted everyone else in your house to be able to restart the Plex server without your intervention? Do you want to just type in a name in a web panel, push a button, and watch a customized Docker/LXD container magically appear?

Then you might want to check out OliveTin. OliveTin is literally just an app that lets you generate a web page from a configuration file, and that web page has buttons. Push the buttons, and OliveTin will run preset bash commands that you set up yourself.

Sure, you could technically create something like this yourself, from scratch, with enough programming experience... but this is *way* easier. It looks a little something like this when set up (image courtesy of the [OliveTin repository](https://github.com/OliveTin/OliveTin)):

![A screenshot of OliveTin on the desktop; it features several squares in a grid, with labels and actions for each command that can be run.](olivetin/screenshotDesktop.png)

!!! Warning "NEVER run this app on a public server"

    This app is, by design and the creator's own admission, meant to be used on local networks, *maybe* on dev setups. However, it has no user authentication system at present, and (until the developer fixes this) *runs as root by default*.

    So yeah, use this all you want on a secured and firewalled network. *Don't* put it on anything meant to be used by the public. For now.

## Prerequisites and assumptions

To follow this guide you will need:

* A computer running Rocky Linux
* A minimal amount of comfort or experience with the command line.
* Root access, or  the ability to use `sudo`.
* To learn the basics of YAML. It is not hard; you'll get the hang of it down below.

## Installing OliveTin

OliveTin includes pre-built RPMs. Just download the latest release here for your architecture, and install it. If you're following this guide on a workstation with a graphical desktop, just download the file and double-click on it in your file manager of choice.

If you are installing this app on a server, then you can download it on your work machine and upload it by way of SSH/SCP/SFTP, or do the thing some people say not to do, and download it with `wget`.

For example:

```bash
wget https://github.com/OliveTin/OliveTin/releases/download/2022-04-07/OliveTin_2022-04-07_linux_amd64.rpm
```

Then install the app with (again, for example):

```bash
sudo rpm -i OliveTin_2022-04-07_linux_amd64.rpm
```

OliveTin can run as a normal `systemd` service, but do not enable it just yet. You need to set up your configuration file first.

!!! Note

    After some testing, I have determined that these same install instructions will work just fine in a Rocky Linux LXD container. For anyone who likes Docker, pre-built images are available.

## Configuring OliveTin actions

OliveTin can do anything bash can do, and more. You can use it to run apps with CLI options, run bash scripts, restart services, and so on. To get started, open up the configuration file with the text editor of your choice with root/sudo:

```bash
sudo nano /etc/OliveTin/config.yaml
```

The most basic kind of action is a button; you click it, and the command is run on the host computer. You can define it in the YAML file like so:

```yaml
actions:
  - title: Restart Nginx
    shell: systemctl restart nginx
```

You can also add custom icons to every action like with unicode emoji:

```yaml
actions:
  - title: Restart Nginx
    icon: "&#1F504"
    shell: systemctl restart nginx
```

I'm not going to go into every detail of the customization options, but you can also use text inputs and dropdown menus to add variables and options to the commands you want to run. If you do, OliveTin will prompt you for input before the command is run.

By doing this, you can run any program, control remote machines with SSH, trigger webhooks, and more. Check out [the official documentation](https://docs.olivetin.app/actions.html) for more ideas.

But here's an example of my own: I have a personal script that I use to generate LXD containers with web servers pre-installed on them. With OliveTin, I was able to quickly make a GUI for said script like this:

```yaml
actions:
- title: Build Container
  shell: sh /home/ezequiel/server-scripts/rocky-host/buildcontainer -c {{ containerName }} -d {{ domainName }} {{ softwarePackage }}
  timeout: 60
  arguments:
    - name: containerName
      title: Container Name
      type: ascii_identifier

    - name: domainName
      title: Domain
      type: ascii_identifier

    - name: softwarePackage
      title: Default Software
      choices:
        - title: None
          value:

        - title: Nginx
          value: -s nginx

        - title: Nginx & PHP
          value: -s nginx-php

        - title: mariadb
          value: -s mariadb
```

On the front end, that looks like this (and yes, OliveTin has a dark mode, and I *really* need to change that icon):

![A form with three text inputs and a dropdown menu](olivetin/containeraction.png)

## Enabling OliveTin

Once you have your configuration file built the way you want it, just enable and start OliveTin with:

```bash
sudo systemctl enable --now OliveTin
```

Every time you edit the configuration file, you'll need to restart the service in the usual way:

```bash
sudo systemctl restart OliveTin
```

## Conclusion

OliveTin is a pretty great way to run everything from bash commands to some fairly complex operations with scripts. Remember that everything runs as root by default, unless you use su/sudo in your shell commands to change the user for that particular command.

As such, you should be careful how you set this whole thing up, especially if you plan to give access to (for example) your family, to control home servers and appliances, and so on.

And again, do not put this on a public server unless you're ready to try and secure the page yourself.

Otherwise, have fun with it. It is a neat little tool.
