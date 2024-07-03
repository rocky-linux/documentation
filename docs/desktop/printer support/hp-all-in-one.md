---
title: HP All-in-One Printer Installation and Setup
author: Joseph Brinkman
tested with: 9.4
tags:
  - desktop
  - printer support
---

## Introduction

Printing and scanning with an all-in-one HP printer is possible on linux thanks to [HPLIP](https://developers.hp.com/hp-linux-imaging-and-printing/about){target="_blank"}. 

This guide was tested with an HP Deskjet 2700 series. 

See [All Supported Printers](https://developers.hp.com/hp-linux-imaging-and-printing/supported_devices/index){target="_blank"} to see if the HPLIP package supports your printer. 

## Download and Install HPLIP

HPLIP is third-party software by HP that contains necessary printer drivers. Install the 3 packages below for full support with a graphical user interface.

```bash
sudo dnf install hplip-common.x86_64 hplip-libs.x86_64 hplip-gui
```

## Printer Setup 

Once your printer drivers are installed, you should be able to add your hp all-in-one printer to your Rocky Workstation. The printer will need to be connected to the same network either through wifi or a direct connection. 

Go to Settings

In the left menu click Printers

Click Add a Printer

Select your HP all-in-one printer.

## Scanner Support

While you can scan using cli commands with the HPLIP package, they do not supply a scanner app. Install xsane, an easy to use scanner utility.

```bash
sudo dnf install sane-backends sane-frontends xsane
```
The xsane gui looks a little intimidating but doing a simple scan is straightfoward. When you launch xsane there is a window with a button where you can 'Acquire a preview'. This will take a preview image of a scan. Once read to scan click the button 'Start' in the main menu.

For a more comprehensive xsane guide read this [article by the University of Cambridge Faculty of Mathematics](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

After installing HPLIP and xsane you should now be able to print and scan on your all-in-one HP printer. 