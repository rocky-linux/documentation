---
title: Decoder
author: Christine Belzie
contributors: Steven Spencer 
---

## Introduction

Need a QR code for your website, application, or social media profiles? Check out  Decoder! It is an application that lets create, save, and export QR codes.

## Assumptions

This guide assumes you have the following:

- Rocky Linux
- Flatpak
- FlatHub

## Installation Process

1. Go to the [Flathub website](https://flathub.org/), type "Decoder" in the search bar, and click on **Install**. ![Screenshot of the install button highlighted by a red rectangle](images/01_decoder.png)

    ![manual install](images/decoder_install.png)

2. Copy the **Manual Install** script and run it in a terminal:

    ```bash
    flatpak install flathub com.belmoussaoui.Decoder
    ```

3. Finally, copy the run command and run that in your terminal:

    ```bash
    flatpak run com.belmoussaoui.Decoder
    ```

## How to Create a QR Code

Two types of QR codes are available. Choose the option that best suits your needs:

- [Text](#text)
- [Wifi](#wifi)

### Text

![Screenshot with numbered items for text, add text, and create](images/02_decoder-text.png)

1. Click on the **Text** button
2. Add a link to your desired website and add a description if wanted
3. Click on **Create**

    ![Screenshot of a Save and Export with arrows](images/03_decoder-text.png)

4. Click on **Save**
5. Click on **Export**

### Wifi

![Decoder WiFi screen with numbered arrows for WiFi, network name, password, hidden or not, encryption, export and save](images/01_decoder-wifi.png)

1. Click on the **Wifi** button
2. Add the name of your network
3. Add the password
4. Click the hidden button if it is a hidden network
5. Select the encryption type from the **Encryption Algorithm** selection tool
6. Click on **Export**
7. Click on **Save**

### How to Scan a QR code

In addition to creating and generating QR codes, you can use Decoder to scan QR codes you saved on you computer. Here is how:

![Screenshot of a red circle on a greay button that has the word "Scan" written in black.](images/01_decoder-scan.png)

1. Click on **Scan**

    ![Screenshot of a red rectangle on a blue button that has the words "From a Screenshot" written in white.](images/02_decoder-scan.png)

2. Click on  **From a Screenshot**

    ![Screenshot of a grey square surrounding the options menu with a red arrow pointing towards it and the number one written on top.](images/03_decoder-scan.png)

3. Pick your desired effects and click on **Take a Screenshot**

    ![Screenshot of a red arrow pointing at a blue button that has the word "Share" written in white.](images/04_decoder-scan.png)

4. Click on **Share**
5. Scan the QR code with your mobile device

!!! note

    To scan a QR code straight from your computer, ensure that you grant the app access to your computer's camera.

## Conclusion

Whether it is to share a restaurant's Wi-Fi with friends, grow your business, or network with other professionals at a conference, Decoder can ease the process of creating and scanning QR codes. Eager to learn more about or have more ideas for this application? [Submit an issue to its repository at GitLab](https://gitlab.gnome.org/World/decoder/-/issues).
