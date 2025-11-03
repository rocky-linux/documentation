---
title: Decoder QR Code Tool
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - qr code
  - flatpak
---

## Scan and Generate QR Codes

**Decoder** is a simple and elegant utility for the GNOME desktop designed for a single purpose: working with QR codes. In a world where QR codes are used for everything from sharing Wi-Fi passwords to accessing restaurant menus, having a dedicated tool to handle them is essential.

Decoder provides two primary functions in a clean, focused interface:

1. **Scanning:** Decodes QR codes using your computer's webcam or an image file.
2. **Generating:** Creates QR codes from any text you provide.

Its tight integration with the GNOME desktop makes it feel like a natural part of the operating system.

## Installation

The recommended way to install Decoder on Rocky Linux is as a Flatpak from the Flathub repository. This method ensures you have the latest version of the application in a secure, sandboxed environment.

### 1. Enable Flathub

If you have not already done so, please make sure Flatpak is installed and the Flathub remote is configured on your system.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Install Decoder

Once Flathub is enabled, you can install Decoder with a single command:

```bash
flatpak install flathub com.belmoussaoui.Decoder
```

## How to Use Decoder

After installation, you can launch Decoder from the GNOME Activities Overview.

### Scanning a QR Code

When you first open Decoder, it is ready to scan. You have two options:

* **Scan with Camera:** Click the camera icon in the top-left. A window will appear showing your webcam's feed. Point the webcam at a QR code to scan it in real-time.
* **Scan from Image:** Click the image icon in the top-right. This will open a file chooser, allowing you to select a saved image or screenshot that contains a QR code.

Once a code is scanned, Decoder intelligently parses its content. If the code contains a website URL, it will display the link with a button to open it in your default web browser. If it contains plain text, it will display the text with a convenient button to copy it to your clipboard.

### Generating a QR Code

To create your own QR code, click the "Generate" button at the top of the Decoder window.

1. A text box will appear. Type or paste the text you wish to encode into this box.
2. As you type, a QR code representing your text is instantly generated on the right.
3. You can then click the **"Save as Image..."** button to save the QR code as a `.png` file, or click the **"Copy to Clipboard"** button to paste it into other applications.

Decoder is a perfect example of the GNOME design philosophy: a simple, beautiful, and highly effective tool that does one job exceptionally well.
