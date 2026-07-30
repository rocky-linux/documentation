---
title: Jellyfin Media Server
author: Neel Chauhan
contributors:
tested_with: 10.2
tags:
  - file transfer
---

## Introduction

[Jellyfin](https://jellyfin.org/) is an open source media server designed to stream videos, music, TV shows and live television from a storage device or network TV tuner. Jellyfin has apps for desktops, iOS, Android, Xbox and smart TVs.

## Installation

First install EPEL:

```bash
dnf install -y epel-release
```

Then install RPM Fusion:

```bash
dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
```

Next install CRB:

```bash
crb enable
```

Finally install Jellyfin:

```bash
dnf install -y jellyfin
```

## First setup

Jellyfin runs on TCP Port 8096 by default. Open up the port:

```bash
firewall-cmd --zone=public --add-port=8096/tcp
firewall-cmd --runtime-to-permanent
```

You can now enable Jellyfin:

```bash
systemctl enable --now jellyfin
```

## Configuration

Open a browser to `http://[IP]:8096`, where `[IP]` is the IP address of your Jellyfin server.

Then enter the server name and select your language. Then select **Next**:

![Our Jellyfin Wizard on the Server Name screen](../images/jellyfin1.png)

Now enter the administrator username and password, then select **Next**:

![Our Jellyfin Wizard on the Password screen](../images/jellyfin2.png)

Click on **Add Media Library**:

![Our Jellyfin Wizard on the Media Library screen](../images/jellyfin3.png)

Select the library type and type in the display name. For the sake of simplicity, we will select **Movies**:

![Our Jellyfin Wizard on the Add Media Library screen](../images/jellyfin4.png)

Go to the **Folders** section and click on the **+** (add) sign:

![Our Jellyfin Wizard on the Folders subsection](../images/jellyfin5.png)

Enter in the folder location and select **OK**:

![Our Jellyfin Wizard on the Select Path screen](../images/jellyfin6.png)

The rest of the sections are optional and should be self explanatory. You can look at them, or if you are in a hurry click **OK**.

You can add more media libraries, or if you are done select **Next**:

![Our Jellyfin Wizard on the Media Sources screen with Movies](../images/jellyfin7.png)

Select your preferred metadata language and country, then select **Next**:

![Our Jellyfin Wizard on the Preferred Metadata screen](../images/jellyfin8.png)

Check if we want to allow remote connections and select **Next**:

![Our Jellyfin Wizard on the Remote Access screen](../images/jellyfin9.png)

Finally select **Finish**:

![Our Jellyfin Wizard on the final setup screen](../images/jellyfin10.png)

You should be able to log into Jellyfin from your browser. You can also add the server to smartphones, smart TVs or a load balancer.

![Our Jellyfin Wizard on the login screen](../images/jellyfin11.png)

## Conclusion

For people who prefer owning entertainment over juggling subscription services such as Netflix, Disney+ or Max, Jellyfin is an excellent way to consolidate media on a home server or NAS. That way, you can watch owned movies or TV shows on any internet accessible device.
