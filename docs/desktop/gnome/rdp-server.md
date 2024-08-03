---
title: Desktop Sharing via RDP
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

If you want to share your (Gnome) desktop on Rocky Linux or access other shared desktops, this guide is for you.

For beginners, you will be using RDP. RDP stands for Remote Desktop Protocol, and it does exactly what that implies: it lets you view and interact with computers from afar, all with a graphical interface. However, you must quickly dive into the command line to set it up.

!!! note

   By default, Rocky Linux allows you to share your desktop via another VNC protocol. VNC is serviceable enough, but RDP usually offers a much smoother experience and can handle weird monitor resolutions.

## Assumptions

For this guide, the assumption is that you have the following set up already:

* Rocky Linux with Gnome
* Flatpak and Flathub installed and working
* A non-root user account
* Admin or sudo access and a willingness to paste commands into the terminal
* The X server (for sharing your desktop)

!!! info

    A few projects are underway to make the Wayland display server and RDP play nice, and more recent versions of Gnome come with a built-in RDP server that does the trick. However, Rocky Linux's version of Gnome doesn't have that feature, so it's a lot easier to power your RDP session with x11.

## Sharing your Rocky Linux Gnome desktop with RDP

You need an RDP server to make your Rocky Linux desktop-accessible remotely. For our purposes, 'xrdp' will more than suffice. You'll need to use the terminal for it, though, as it's a CLI-only program.

```bash
sudo dnf install xrdp
```

Once you have that installed, you need to enable the service:

```bash
sudo systemctl enable --now xrdp
```

If all goes well, the RDP server should be installed, enabled, and running. But you can't connect just yet; you need to open the correct port on your firewall first.

If you want to learn more about how Rocky Linux's firewall app, `firewalld`, works, please see our [beginner's guide to `firewalld`](../../guides/security/firewalld-beginners.md). If you want to get moved along, run these commands:

```bash
sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```

For beginners, those commands open the RDP port in your firewall so you can accept incoming RDP connections. Then, restart the firewall to apply the changes. If you feel so inclined, you can reboot your PC just to be safe.

You might want to log out if you do not want to reboot. RDP uses your user account credentials for security. Logging in remotely while already logged into your desktop locally is not possible. At least, not on the same user account.

!!! info

    You can also use the Firewall app to manage `firewalld` and open any ports you want. Watch this space for a link to my guide to installing and using the Firewall app.

## Accessing your Rocky Linux desktop and/or other desktops with RDP

You have seen how to install an RDP server, and now you need an RDP client application. On Windows, the Remote Desktop Connection app does the trick quite nicely. If you want to access your Rocky Linux machine from another Linux machine, you will need to install a third-party option.

I highly recommend Remmina for Gnome. It is not complex to use, stable, and generally works.

If you have Flatpak/Flathub installed, open up the Software app and search for Remmina.

![The Gnome Software app on the Remmina page](images/rdp_images/01-remmina.png)

Install it and launch it. Note: this is the process for adding an RDP connection in Remmina, but it is similar to almost every other RDP client app you are likely to find.

Hit the plus button in the upper-left corner to add a connection. In the name field, call it what you like, and enter the remote computer's IP address, along with your remote user account's username and password. Remember, if your computers are on the same network, you want to use their local IP address, not the one you'd see on a site like "whatsmyip.com".

![The Remmina connection profile form](images/rdp_images/02-remmina-config.png)

If your computers are not on the same network, I hope you know how to do port forwarding or that the remote computer has a static IP. That is all beyond the scope of this document.

Scroll down for options like multi-monitor support, custom resolutions, and more. Also, your RDP client's "Network connection type" option lets you balance bandwidth usage with image quality.

Use LAN for the best quality if your computers are on the same network.

Then, click ++"Save"++ and ++"Connect"++.

This is what it looks like with the Windows Remote Desktop Connection client. The author wrote this document on his local Rocky Linux server with RDP.

![A screenshot of my docs-writing environment, at a 5120x1440p resolution](images/rdp_images/03-rdp-connection.jpg)

## Conclusion

That is all you need to know to run RDP on Rocky Linux and share your desktop. This will do the trick if you only need to access some files and apps remotely.
