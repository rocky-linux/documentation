---
title: Firewall GUI App
author: Ezequiel Bruni
contributors: Steven Spencer
---

## Introduction

Want to manage your firewall without all that command line stuff? You can! There's a great app specifically built for `firewalld`, the firewall used in Rocky Linux, and it's available on Flathub. This guide will show you how to get it up and running quickly, and the basics of the interface.

We won't be covering everything that `firewalld` or the GUI can accomplish, but it should be enough to get you started.

## Assumptions

For this guide, we assume that you have the following:

* A Rocky Linux install with any graphical desktop environment.
* sudo or admin access.
* A fundamental understanding of how `firewalld` works.

!!! note

    Now keep in mind that while this app definitely makes your life easier if you prefer using a GUI, you'll still need to understand the basic concepts behind `firewalld`. You'll need to know about ports, zones, services, sources, and so on.

    If you're not clear on any of this, please see the [Beginner's guide to `firewalld`](../../guides/security/firewalld-beginners.md), and read about zones in particular, to get a feel for what they do.

## Installing the app

Just go into the Software Center app, and search for "Firewall". It's a native package in the Rocky Linux repository, and it will be literally called "Firewall", so it should be easy to find.

![Firewall in the Software Center](images/firewallgui-01.png)

For those curious, it's call `firewall-config` in the repository, and can be installed with the usual command:

```bash
sudo dnf install firewall-config
```

When you open the app, it will ask for your password. It will also ask again before performing sensitive operations.

## Configuration modes

The first thing to keep in mind is the configuration mode you're in, which is selectable in the dropdown menu at the top of the window. Your choices are: Runtime, and Permanent.

![the configuration mode dropdown menu is near the top of the window](images/firewallgui-02.png)

Opening up ports, adding permitted services, and any other changes made in the Runtime mode are *temporary*, and it doesn't give you access to all features. Upon reboot, or when reloading the firewall manually, those changes will disappear. This is great for when you only need to make a quick change to accomplish a single task, or if you want to test your changes before you make them permanent.

Once you have, for example, opened up a port in th Public zone, you can go to `Options > Runtime To Permanent` to save your changes.

Permament mode is more risky to use, but opens up all of the features. It allows the creation of new zones, the individual configuration of services, managing your network interfaces, and the addition of IPSets (i.e. sets of IP addresses that are or aren't allowed to contact your computer or server).

After making permanent changes, go to `Options > Reload Firewalld` enable them properly.

## Managing Interfaces/Connections

The panel on the far left, labelled "Active Bindings" is where you'll find your network connections and manually-added network interface. If you scroll back up, you'll see my Ethernet connection (eno1). By default, your network connection will be assigned to the "public" Zone, which is locked down fairly tight.

At the bottom of the panel you'll find the "Change Zone" button, which allows you to assign your connection to another zone if you want to. In Permanent mode, you'll also be able to create your own custom Zones.

![a screenshot featuring the Active Bindings panel on the left of the window](images/firewallgui-03.png)

## Managing Zones

In the first tab on the right panel, you'll find the Zone menu. Here you can, as you might have already surmised, open and close ports, enable or disable services, add trusted IP addresses for incoming traffic (think local networks), enable port forwarding, add rich rules, and more.

For most basic desktop users, this is where you'll spend most of your time, and the most useful sub-tabs in this panel will be the ones for configuring services and ports.

!!! Note

    If you install your apps and services from the repository, some of them (usually the ones designed for Desktop use) will automatically enable the relevant services or open the proper ports. However, if that doesn't happen, you can follow the steps below to do it all manually.

### Adding a service to a Zone

Services are popular apps and background services that `firewalld` supports by default. You can quickly and easily enable them by scrolling through the list, and enabling the relevant checkbox.

Now, if you've installed KDE Connect* to help sync your desktop with other devices, and you want to allow it through your firewall so it'll actually work, you would:

1. First, select the zone you want to edit. Let's just go with the default public zone, for this example.
2. Scroll down the list, and select "kdeconnect".
3. If you're in the Runtime configuration mode, don't forget to click "Runtime To Permanent" and "Reload Firewalld" in the options menu.

\* Available in the EPEL repository.

![a screenshot featuring the Zones tab in the right panel, and the Services sub-panel](images/firewallgui-04.png)

Other popular services on the list include HTTP & HTTPS for hosting websites, SSH for allowing terminal-based access from other devices, samba for hosting Windows-compatible file shares, and quite a few more.

However, not every program is on the list, and you might need to open a port manually.

### Opening ports on a Zone

Opening ports for specific apps is simple enough. Just make sure to read the documentation to know which ports you needs, and go.

1. Again, select the zone you want to edit.
2. Go to the Ports tab in the panel on the right.
3. Click the Add button.
4. Fill in the text field with the port(s) you need open. Double check which protocol the app needs as, as well as the networking protocol it uses (ie. TCP/UDP, etc.)
5. Click OK, and use the "Runtime To Permanent" and "Reload Firewalld" options as per usual.

![a screenshot featuring the Ports subpanel, and the popup window where you can enter the port number as needed](images/firewallgui-05.png)

## Conclusion

Well, I did say we'd be keeping this guide simple. If you really want to give your brain a workout, you should go and try to read some more about the fundamentals of `firewalld`. You can also use the "Services" tab at the top of the right panel (next to "Zones") to configure exactly how your services work, or control exactly which other computers are allowed to talk to yours with IPSets and Sources.

Or you can just open up the port for your Jellyfin server and get on with your day. It's up to you. `firewalld` is an incredibly powerful tool, and the Firewall app can help you discover its capabilities in a beginner-friendly way... up to a point.

Have fun, and stay safe out there!