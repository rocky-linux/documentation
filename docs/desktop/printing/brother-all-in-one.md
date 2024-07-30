---
title: Brother All-in-One Printer Installation and Setup
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - printer support
---

## Introduction

Printing and scanning with a Brother all-in-one printer is possible on Linux thanks to third-party Brother all-in-one printer and scanner drivers.

!!! info

    The procedure was tested with a Brother MFC-J480DW.

## Prerequisites and assumptions

- Rocky 9.4 Workstation
- `sudo` privileges
- Brother all-in-one printer and scanner

This guide assumes your printer is accessible from your workstation with a direct USB connection or LAN (Local Area Network). Connecting a printer to your LAN is outside the scope of this article.

## Adding a printer in GNOME

1. Open ++"Settings"++
2. In the left menu, click ++"Printers"++
3. Notice the banner at the top of the window that says "Unlock to Change Settings"
4. Click ++"Unlock"++ and enter `sudo` credentials.
5. Click ++"Add"++

After clicking ++"Add"++, ++"Settings"++ will start scanning for printers. If your printer does not show up, but you know its  IP address on your local area network, enter the IP address manually. Connecting your printer to your home network is beyond the scope of this article.

A Software window launches that attempts to locate and install printer drivers. Generally, this will fail. You must go to Brother's website to install the additional drivers.

## Downloading and installing the drivers

[Brother Driver Installer Script Installation Instructions:](https://support.brother.com/g/b/downloadlist.aspx?&c=us&lang=en&prod=mfcj480dw_us_eu_as&os=127){target="_blank"}

1. [Download the Brother MFC-J480DW Printer driver bash script](https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcj480dw_us_eu_as){target="_blank"}
2. Open a terminal window.
3.Go to the directory where you downloaded the file in the last step. e.g., `cd Downloads`
4. Enter this command to extract the downloaded file:

    ```bash
    gunzip linux-brprinter-installer-*.*.*-*.gz
    ```

5. Get superuser authorization with the `su` command or `sudo su` command.
6. Run the tool:

    ```bash
    bash linux-brprinter-installer-*.*.*-* Brother machine name
    ```

7. The driver installation will start. Follow the installation screen directions.

The installation process may take some time. Please wait until it is complete. Once finished, you can optionally send a test print.

## Scanner support

Xsane is a scanning utility that provides a graphical user interface for scanning. It uses packages available from the app stream repository and requires no additional configuration.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

The Xsane GUI looks intimidating, but a simple scan is straightforward. When you launch Xsane, a window with a button exists where you can ++"Acquire a preview"++. This will take a preview image of a scan. Once ready to scan, click the button ++"Start"++ in the main menu.

For a more comprehensive Xsane guide, read this [article by the University of Cambridge Faculty of Mathematics](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

After installing the necessary Brother drivers and Xsane you should now be able to print and scan on your all-in-one Brother printer and scanner.
